codeunit 6184779 "NPR Adyen Trans. Matching"
{
    Access = Internal;

    #region Creating
    internal procedure CreateSettlementDocuments(ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; RecreateExistingDocument: Boolean; ExistingDocumentNo: Code[20]) NewDocumentsList: JsonArray
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReportType: Enum "NPR Adyen Report Type";
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        MBCombination: JsonObject;
        MerchantBatchValues: List of [JsonObject];
        CurrentMerchantAccount: Text;
        CurrentBatchNumber: Integer;
        EntryAmount: Integer;
        SetupDoesNotExist: Label 'G/L Setup or Adyen Setup does not exist.';
        GLSetupLCYCodeIsEmpty: Label 'LCY Code is not set in General Ledger Setup.';
    begin
        if (not _GLSetup.Get()) or (not _AdyenSetup.Get()) then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Init Setup", false, SetupDoesNotExist, 0);
            exit;
        end;

        if _GLSetup."LCY Code" = '' then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Init Setup", false, GLSetupLCYCodeIsEmpty, 0);
            exit;
        end;

        if ReportWebhookRequest.ID = 0 then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Get Report", false, StrSubstNo(GetWebhookError, Format(ReportWebhookRequest.ID)), 0);
            exit;
        end;

        if not GetReportData(ReportWebhookRequest, false) then
            exit;

        if not RecreateExistingDocument then begin
            case ReportWebhookRequest."Report Type" of
                ReportWebhookRequest."Report Type"::"Settlement details":
                    CreateMerchantBatchListFromLines(MerchantBatchValues, ReportType::"Settlement details");
                ReportWebhookRequest."Report Type"::"External Settlement detail (C)":
                    CreateMerchantBatchListFromLines(MerchantBatchValues, ReportType::"External Settlement detail (C)");
            end;
        end else begin
            JsonObject.Add('Merchant Account', ReconciliationHeader."Merchant Account");
            JsonObject.Add('Batch Number', ReconciliationHeader."Batch Number");
            if MerchantBatchValues.IndexOf(JsonObject) = 0 then
                MerchantBatchValues.Add(JsonObject);
        end;

        foreach MBCombination in MerchantBatchValues do begin
            MBCombination.Get('Merchant Account', JsonToken);
            CurrentMerchantAccount := JsonToken.AsValue().AsText();
            if ReportWebhookRequest."Report Type" in [ReportWebhookRequest."Report Type"::"Settlement details"] then begin
                MBCombination.Get('Batch Number', JsonToken);
                CurrentBatchNumber := JsonToken.AsValue().AsInteger();
            end;

            if InitReconciliationHeader(ReconciliationHeader, RecreateExistingDocument, CurrentBatchNumber, CurrentMerchantAccount, ExistingDocumentNo, ReportWebhookRequest) then begin
                EntryAmount := InsertReconciliationLines(CurrentMerchantAccount, CurrentBatchNumber, ReconciliationHeader, ReportWebhookRequest);

                if (EntryAmount > 0) then begin
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Import Lines", true, StrSubstNo(ImportLinesSuccess01, ReconciliationHeader."Document No.", Format(EntryAmount)), ReportWebhookRequest.ID);
                    NewDocumentsList.Add(ReconciliationHeader."Document No.");
                end else begin
                    ReconciliationHeader.Delete();
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Import Lines", false, StrSubstNo(ImportLinesError02, ReportWebhookRequest."Report Name", CurrentMerchantAccount), ReportWebhookRequest.ID);
                end;
            end;
        end;
        exit(NewDocumentsList);
    end;

    internal procedure RecreateDocumentEntries(var RecHeader: Record "NPR Adyen Reconciliation Hdr"): Integer
    var
        RecLine: Record "NPR Adyen Recon. Line";
        WebhookRequest: Record "NPR AF Rec. Webhook Request";
        InsertedEntryAmount: Integer;
        WebhookRequestDoesNotExistLbl: Label 'Webhook Request with ID %1 does not exist anymore.';
        DocumentIsPostedLbl: Label 'Document %1 is already posted.';
        NoUnpostedEntriesLbl: Label 'Document %1 is not yet posted, however there are no unposted entries to recreate.';
        GLSetupDoesNotExistLbl: Label 'General Ledger Setup does not exist.';
    begin
        if not _GLSetup.Get() then
            Error(GLSetupDoesNotExistLbl);

        _AdyenSetup.GetRecordOnce();

        if RecHeader.Posted then
            Error(DocumentIsPostedLbl, RecHeader."Document No.");

        RecLine.Reset();
        RecLine.SetRange("Document No.", RecHeader."Document No.");
        RecLine.SetFilter(Status, '<>%1', RecLine.Status::Posted);
        if RecLine.IsEmpty() then
            Error(NoUnpostedEntriesLbl, RecHeader."Document No.");

        if not WebhookRequest.Get(RecHeader."Webhook Request ID") then
            Error(WebhookRequestDoesNotExistLbl, Format(RecHeader."Webhook Request ID"));

        if RecLine.FindSet(true) then
            RecLine.DeleteAll();

        GetReportData(WebhookRequest, true);
        InsertedEntryAmount := InsertReconciliationLines(RecHeader."Merchant Account", RecHeader."Batch Number", RecHeader, WebhookRequest);

        /*
        RecLine.SetRange(Status, RecLine.Status::Posted);
        if RecLine.FindSet() then
            DeletedEntryAmount := DeleteDuplicateEntries(RecLine, RecHeader);
        */
        exit(InsertedEntryAmount);
    end;

    local procedure InitReconciliationHeader(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; RecreateExistingDocument: Boolean; CurrentBatchNumber: Integer; CurrentMerchantAccount: Text; ExistingDocumentNo: Code[20]; WebhookRequest: Record "NPR AF Rec. Webhook Request"): Boolean
    var
        AdyenGenericSetup: Record "NPR Adyen Setup";
        DocumentExistLbl: Label 'A Reconciliation document with identification fields Merchant Account: ''%1'' and Batch Number: ''%2'' already exist.';
    begin
        if (not RecreateExistingDocument) then begin
            AdyenGenericSetup.Get();
            if AdyenGenericSetup."Reconciliation Document Nos." = '' then begin
                _AdyenManagement.CreateReconciliationLog(_LogType::"Import Lines", false, NoSeriesError01, WebhookRequest.ID);
                exit(false);
            end;
            ReconciliationHeader.Reset();
            ReconciliationHeader.SetRange("Batch Number", CurrentBatchNumber);
            ReconciliationHeader.SetRange("Merchant Account", CurrentMerchantAccount);
            if not ReconciliationHeader.IsEmpty() then begin
                _AdyenManagement.CreateReconciliationLog(_LogType::"Get Report", false, StrSubstNo(DocumentExistLbl, CurrentMerchantAccount, Format(CurrentBatchNumber)), WebhookRequest.ID);
                exit(false);
            end;

            ReconciliationHeader.Init();
            ReconciliationHeader."Document No." := _NoSeriesMgt.GetNextNo(AdyenGenericSetup."Reconciliation Document Nos.", Today(), true);
            ReconciliationHeader."Document Date" := Today();
            ReconciliationHeader."Posting Date" := Today();
            ReconciliationHeader.Insert();
        end else begin
            ReconciliationHeader.Get(ExistingDocumentNo);
            if ReconciliationHeader.Posted then
                exit(false);
            ReconciliationHeader."Document Date" := Today();
            ReconciliationHeader."Posting Date" := Today();
            _AdyenManagement.DeleteReconciliationLines(ReconciliationHeader."Document No.");
        end;
        ReconciliationHeader."Document Type" := WebhookRequest."Report Type";
        ReconciliationHeader."Webhook Request ID" := WebhookRequest.ID;
        ReconciliationHeader."Batch Number" := CurrentBatchNumber;
        ReconciliationHeader."Merchant Account" := CopyStr(CurrentMerchantAccount, 1, MaxStrLen(ReconciliationHeader."Merchant Account"));
        ReconciliationHeader.Modify();
        exit(true);
    end;

    local procedure InitReconciliationLine(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; var ReconciliationLine: Record "NPR Adyen Recon. Line")
    var
        xReconciliationLine: Record "NPR Adyen Recon. Line";
    begin
        xReconciliationLine.SetCurrentKey("Line No.");
        xReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.Init();
        ReconciliationLine."Document No." := ReconciliationHeader."Document No.";
        ReconciliationLine."Line No." := 1;

        if xReconciliationLine.FindLast() then
            ReconciliationLine."Line No." += xReconciliationLine."Line No.";
    end;

    local procedure InsertReconciliationLine(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; BatchNumber: Integer; MerchantAccount: Text; ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; LineNo: Integer; var EntryAmount: Integer): Boolean
    begin
        InitReconciliationLine(ReconciliationHeader, ReconciliationLine);
        case ReconciliationHeader."Document Type" of
            ReconciliationHeader."Document Type"::"Settlement details":
                begin
                    ReconciliationLine."Merchant Order Reference" := CopyStr(GetValueAtCell(LineNo, 24), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
                    if Evaluate(ReconciliationLine."Scheme Fees (NC)", GetValueAtCell(LineNo, 25), 9) then;
                    if Evaluate(ReconciliationLine."Interchange (NC)", GetValueAtCell(LineNo, 26), 9) then;
                    if Evaluate(ReconciliationLine."Payment Fees (NC)", GetValueAtCell(LineNo, 27), 9) then;

                end;
            ReconciliationHeader."Document Type"::"External Settlement detail (C)":
                begin
                    ReconciliationLine."Merchant Order Reference" := CopyStr(GetValueAtCell(LineNo, 21), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
                    if Evaluate(ReconciliationLine."Scheme Fees (NC)", GetValueAtCell(LineNo, 22), 9) then;
                    if Evaluate(ReconciliationLine."Interchange (NC)", GetValueAtCell(LineNo, 23), 9) then;
                end;
        end;
        ReconciliationLine."Batch Number" := BatchNumber;

        ReconciliationLine."Company Account" := CopyStr(GetValueAtCell(LineNo, 1), 1, MaxStrLen(ReconciliationLine."Company Account"));
        ReconciliationLine."Merchant Account" := CopyStr(MerchantAccount, 1, MaxStrLen(ReconciliationLine."Merchant Account"));
        ReconciliationLine."PSP Reference" := CopyStr(GetValueAtCell(LineNo, 3), 1, MaxStrLen(ReconciliationLine."PSP Reference"));
        ReconciliationLine."Merchant Reference" := CopyStr(GetValueAtCell(LineNo, 4), 1, MaxStrLen(ReconciliationLine."Merchant Reference"));

        if Evaluate(ReconciliationLine."Transaction Date", GetValueAtCell(LineNo, 6)) then begin
            if ReconciliationHeader."Transactions Date" = 0D then begin
                ReconciliationHeader."Transactions Date" := DT2Date(ReconciliationLine."Transaction Date");
                ReconciliationHeader.Modify();
            end;
        end;

        ReconciliationLine."Modification Reference" := CopyStr(GetValueAtCell(LineNo, 9), 1, MaxStrLen(ReconciliationLine."Modification Reference"));
        ReconciliationLine."Transaction Currency Code" := CopyStr(GetValueAtCell(LineNo, 10), 1, MaxStrLen(ReconciliationLine."Transaction Currency Code"));

        if Evaluate(ReconciliationLine."Exchange Rate", GetValueAtCell(LineNo, 13), 9) then;
        ReconciliationLine."Adyen Acc. Currency Code" := CopyStr(GetValueAtCell(LineNo, 14), 1, MaxStrLen(ReconciliationLine."Adyen Acc. Currency Code"));
        ReconciliationHeader."Adyen Acc. Currency Code" := ReconciliationLine."Adyen Acc. Currency Code";

        if Evaluate(ReconciliationLine."Commission (NC)", GetValueAtCell(LineNo, 17), 9) then;
        if Evaluate(ReconciliationLine."Markup (NC)", GetValueAtCell(LineNo, 18), 9) then;

        if Evaluate(ReconciliationLine."Gross Debit", GetValueAtCell(LineNo, 11), 9) then
            ReconciliationLine.Validate("Gross Debit");
        if Evaluate(ReconciliationLine."Gross Credit", GetValueAtCell(LineNo, 12), 9) then
            ReconciliationLine.Validate("Gross Credit");
        if Evaluate(ReconciliationLine."Net Debit", GetValueAtCell(LineNo, 15), 9) then
            ReconciliationLine.Validate("Net Debit");
        if Evaluate(ReconciliationLine."Net Credit", GetValueAtCell(LineNo, 16), 9) then
            ReconciliationLine.Validate("Net Credit");

        ReconciliationLine."Other Commissions (NC)" := ReconciliationLine."Payment Fees (NC)" - ReconciliationLine."Markup (NC)";

        case GetValueAtCell(LineNo, 8) of
            'Fee':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::Fee;
            'Settled':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::Settled;
            'Refunded':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::Refunded;
            'Chargeback':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::Chargeback;
            'SecondChargeback':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::SecondChargeback;
            'ChargebackReversed':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::ChargebackReversed;
            'RefundedReversed':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::RefundedReversed;
            'InvoiceDeduction':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::InvoiceDeduction;
            'MerchantPayout':
                begin
                    FillMerchantPayout(ReconciliationHeader, LineNo);
                    ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::MerchantPayout;
                end;
            'AcquirerPayout':
                begin
                    InsertAcquirerPayout(ReconciliationHeader, LineNo);
                    ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::AcquirerPayout;
                end;
            'PaymentCost':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::PaymentCost;
            'SettledExternallyWithInfo':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::SettledExternallyWithInfo;
            'RefundedExternallyWithInfo':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::RefundedExternallyWithInfo;
            'ChargebackExternallyWithInfo':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::ChargebackExternallyWithInfo;
            'ChargebackReversedExternallyWithInfo':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo;
            'AdvancementCommissionExternallyWithInfo':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::AdvancementCommissionExternallyWithInfo;
            'RefundedInstallmentExternallyWithInfo':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::RefundedInstallmentExternallyWithInfo;
            'SettledInstallmentExternallyWithInfo':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::SettledInstallmentExternallyWithInfo;
            else begin
                Clear(ReconciliationLine);
                _AdyenManagement.CreateReconciliationLog(_LogType::"Import Lines", false, StrSubstNo(ImportLinesError03, GetValueAtCell(LineNo, 8)), ReportWebhookRequest.ID);
                exit;
            end;
        end;

        if ReconciliationLine."Transaction Type" in [ReconciliationLine."Transaction Type"::Chargeback, ReconciliationLine."Transaction Type"::ChargebackExternallyWithInfo, ReconciliationLine."Transaction Type"::SecondChargeback] then
            ReconciliationLine."Posting allowed" := _AdyenSetup."Post Chargebacks Automatically";

        ReconciliationLine."Webhook Request ID" := ReportWebhookRequest.ID;
        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"To Be Determined";

        if ReconLineIsUnique(ReconciliationLine) then begin
            if _GLSetup."LCY Code" <> ReconciliationLine."Adyen Acc. Currency Code" then
                CalculateLCYAmounts(ReconciliationLine)
            else
                CopyAACtoLCYAmounts(ReconciliationLine);

            EntryAmount += 1;

            ReconciliationLine.Insert(true)
        end;
        ReconciliationHeader.Modify();
    end;

    local procedure FillMerchantPayout(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; LineNo: Integer)
    begin
        if Evaluate(ReconciliationHeader."Merchant Payout", GetValueAtCell(LineNo, 15), 9) then
            ReconciliationHeader.Modify();
    end;

    local procedure InsertBalanceTransfer(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; LineNo: Integer)
    var
        FromBalance: Decimal;
        ToBalance: Decimal;
    begin
        if GetValueAtCell(LineNo, 20).Contains('from') then begin
            if Evaluate(FromBalance, GetValueAtCell(LineNo, 16), 9) then
                ReconciliationHeader."Opening Balance" += FromBalance; // Might close multiple batches
        end else
            if GetValueAtCell(LineNo, 20).Contains('to') then begin
                if Evaluate(ToBalance, GetValueAtCell(LineNo, 15), 9) then
                    ReconciliationHeader."Closing Balance" += ToBalance; // Probably always is a single closing balance entry
            end;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertAcquirerPayout(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; LineNo: Integer)
    begin
        if Evaluate(ReconciliationHeader."Merchant Payout", GetValueAtCell(LineNo, 15), 9) then;
        if Evaluate(ReconciliationHeader."Acquirer Commission", GetValueAtCell(LineNo, 17), 9) then;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertReconciliationLines(CurrentMerchantAccount: Text; CurrentBatchNumber: Integer; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; ReportWebhookRequest: Record "NPR AF Rec. Webhook Request") EntryAmount: Integer
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        LineNo: Integer;
    begin
        EntryAmount := 0;
        for LineNo := 2 to GetNumberOfRows() do begin
            if (GetValueAtCell(LineNo, 2) = CurrentMerchantAccount) then begin
                if (GetValueAtCell(LineNo, 21) = Format(CurrentBatchNumber)) or
                    (ReportWebhookRequest."Report Type" <> ReportWebhookRequest."Report Type"::"Settlement details")
                then begin
                    case GetValueAtCell(LineNo, 8) of
                        'Balancetransfer':
                            InsertBalanceTransfer(ReconciliationHeader, LineNo);
                        else
                            InsertReconciliationLine(ReconciliationLine, ReconciliationHeader, CurrentBatchNumber, CurrentMerchantAccount, ReportWebhookRequest, LineNo, EntryAmount);
                    end;
                end;
            end;
        end;
    end;
    #endregion

    #region Matching
    internal procedure MatchEntries(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer;
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        ReconciliationLine2: Record "NPR Adyen Recon. Line";
        UnmatchedEntries: Integer;
        Handled: Boolean;
        Window: Dialog;
        MatchingEntriesLbl: Label 'Attempting to Match Reconciliation Line entries...\\Matching #1 Entry out of #2';
        ProcessedEntries: Integer;
        TotalEntries: Integer;
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.SetFilter(Status, '%1|%2', ReconciliationLine.Status::" ", ReconciliationLine.Status::"Failed to Match");
        if not ReconciliationLine.FindSet(true) then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError02, ReconciliationHeader."Document No.", ReconciliationHeader."Merchant Account"), ReconciliationHeader."Webhook Request ID");
            exit(MatchedEntries);
        end;
        Clear(MatchedEntries);
        Clear(UnmatchedEntries);

        if GuiAllowed() then begin
            Clear(ProcessedEntries);
            TotalEntries := ReconciliationLine.Count();
            Window.Open(MatchingEntriesLbl);
            Window.Update(1, TotalEntries);
        end;

        repeat
            ReconciliationLine2 := ReconciliationLine;
            Handled := false;

            //TODO Future event

            if not Handled then begin
                case ReconciliationLine2."Transaction Type" of
                    ReconciliationLine2."Transaction Type"::Settled,
                    ReconciliationLine2."Transaction Type"::SettledExternallyWithInfo,
                    ReconciliationLine2."Transaction Type"::Refunded,
                    ReconciliationLine2."Transaction Type"::RefundedExternallyWithInfo,
                    ReconciliationLine2."Transaction Type"::Chargeback,
                    ReconciliationLine2."Transaction Type"::SecondChargeback,
                    ReconciliationLine2."Transaction Type"::ChargebackExternallyWithInfo,
                    ReconciliationLine2."Transaction Type"::ChargebackReversed,
                    ReconciliationLine2."Transaction Type"::RefundedReversed,
                    ReconciliationLine2."Transaction Type"::ChargebackReversedExternallyWithInfo:
                        begin
                            MatchedEntries += TryMatchingPayment(ReconciliationLine2, UnmatchedEntries, ReconciliationHeader);
                        end;
                    ReconciliationLine2."Transaction Type"::Fee,
                    ReconciliationLine2."Transaction Type"::InvoiceDeduction,
                    ReconciliationLine2."Transaction Type"::PaymentCost,
                    ReconciliationLine2."Transaction Type"::MerchantPayout,
                    ReconciliationLine2."Transaction Type"::AcquirerPayout,
                    ReconciliationLine2."Transaction Type"::AdvancementCommissionExternallyWithInfo,
                    ReconciliationLine2."Transaction Type"::RefundedInstallmentExternallyWithInfo,
                    ReconciliationLine2."Transaction Type"::SettledInstallmentExternallyWithInfo:
                        begin
                            MatchedEntries += TryMatchingAdjustments(ReconciliationLine2, UnmatchedEntries, ReconciliationHeader);
                        end;
                end;
                ReconciliationLine2.Modify();
            end;

            if GuiAllowed() then begin
                ProcessedEntries += 1;
                Window.Update(2, ProcessedEntries);
            end;

        until ReconciliationLine.Next() = 0;

        if GuiAllowed() then
            Window.Close();

        if UnmatchedEntries > 0 then
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError03, Format(UnmatchedEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID")
        else
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", true, StrSubstNo(MatchTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
        exit(MatchedEntries);
    end;

    local procedure TryMatchingPayment(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var UnmatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer
    begin
        if ReconciliationLine."PSP Reference" = '' then begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false,
                MatchTransactionsError06,
                ReconciliationHeader."Webhook Request ID");
            exit;
        end;
        if TryMatchingPaymentWithEFT(ReconciliationLine, MatchedEntries, ReconciliationHeader) then
            exit;
        if TryMatchingPaymentWithMagento(ReconciliationLine, MatchedEntries, ReconciliationHeader) then
            exit;
        ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
        UnmatchedEntries += 1;
    end;

    local procedure TryMatchingPaymentWithEFT(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var MatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PaymentLine: Record "NPR POS Entry Payment Line";
        AdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integrat.";
        AdyenLocalIntegration: Codeunit "NPR EFT Adyen Local Integrat.";
        EFTAmountFactor: Integer;
    begin
        EFTTransactionRequest.Reset();
        EFTTransactionRequest.SetRange("PSP Reference", ReconciliationLine."PSP Reference");
        EFTTransactionRequest.SetFilter("Integration Type", '%1|%2', AdyenCloudIntegration.IntegrationType(), AdyenLocalIntegration.IntegrationType());
        if not (ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo])
        then
            EFTTransactionRequest.SetRange(EFTTransactionRequest.Reconciled, false)
        else
            EFTTransactionRequest.SetRange(Reversed, false);

        if not EFTTransactionRequest.FindFirst() then
            exit;

        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"EFT Transaction";
        ReconciliationLine."Matching Entry System ID" := EFTTransactionRequest.SystemId;

        if ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]
        then begin
            if not PaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID") then begin
                ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
                _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false,
                    MatchTransactionsError05,
                    ReconciliationHeader."Webhook Request ID");
                exit(true);
            end;
        end;

        EFTAmountFactor := 1;
        if ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]
        then
            EFTAmountFactor := 1;

        if ((EFTTransactionRequest."Result Amount" * EFTAmountFactor) = (ReconciliationLine."Amount (TCY)")) and EFTTransactionRequest."Financial Impact" then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            MatchedEntries += 1;
            if PaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID") and
                (ReconciliationLine."Adyen Acc. Currency Code" <> ReconciliationLine."Transaction Currency Code") and
                (ReconciliationLine."Transaction Type" in
                    [ReconciliationLine."Transaction Type"::Settled,
                    ReconciliationLine."Transaction Type"::Refunded,
                    ReconciliationLine."Transaction Type"::Chargeback,
                    ReconciliationLine."Transaction Type"::SecondChargeback,
                    ReconciliationLine."Transaction Type"::SettledExternallyWithInfo,
                    ReconciliationLine."Transaction Type"::RefundedExternallyWithInfo,
                    ReconciliationLine."Transaction Type"::ChargebackExternallyWithInfo])
            then begin
                ReconciliationLine."Realized Gains or Losses" := CalculateRealizedGL(ReconciliationLine, PaymentLine);
            end;
        end else begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false,
                StrSubstNo(MatchTransactionsError01, Format(EFTTransactionRequest."Entry No."),
                Format(EFTTransactionRequest."Result Amount" = ReconciliationLine."Amount (TCY)"),
                Format(EFTTransactionRequest."Result Amount"),
                Format(ReconciliationLine."Amount (TCY)"),
                Format(EFTTransactionRequest."Financial Impact")),
                ReconciliationHeader."Webhook Request ID");
            exit;
        end;
        exit(true);
    end;

    local procedure TryMatchingPaymentWithMagento(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var MatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        FilterPGCodes: Text;
        GLSetup: Record "General Ledger Setup";
        MagentoAmountFactor: Integer;
    begin
        PaymentGateway.Reset();
        PaymentGateway.SetRange("Integration Type", Enum::"NPR PG Integrations"::Adyen);
        if PaymentGateway.FindSet() then begin
            repeat
                FilterPGCodes += PaymentGateway.Code + '|';
            until PaymentGateway.Next() = 0;
            if StrLen(FilterPGCodes) > 0 then
                FilterPGCodes := FilterPGCodes.TrimEnd('|');
        end else
            exit;

        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("Transaction ID", ReconciliationLine."PSP Reference");
        MagentoPaymentLine.SetFilter("Payment Gateway Code", FilterPGCodes);
        if not (ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo])
        then
            MagentoPaymentLine.SetRange(Reconciled, false)
        else
            MagentoPaymentLine.SetRange(Reversed, false);
        if not MagentoPaymentLine.FindFirst() then
            exit;

        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"Magento Payment Line";
        ReconciliationLine."Matching Entry System ID" := MagentoPaymentLine.SystemId;

        MagentoAmountFactor := 1;

        if ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]
        then
            MagentoAmountFactor := -1;

        if GLSetup.Get() and (GLSetup."LCY Code" = ReconciliationLine."Transaction Currency Code") and ((MagentoPaymentLine.Amount * MagentoAmountFactor) = (ReconciliationLine."Amount (TCY)")) then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            MatchedEntries += 1;
            // TODO Calculate Realized Gains or Losses
        end else begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false,
                StrSubstNo(MatchTransactionsError04,
                    Format(MagentoPaymentLine."Document Type"),
                    Format(MagentoPaymentLine."Document No."),
                    Format(MagentoPaymentLine."Line No."),
                    Format(MagentoPaymentLine.Amount),
                    Format(ReconciliationLine."Amount (TCY)")),
                ReconciliationHeader."Webhook Request ID");
        end;
        exit(true);
    end;

    local procedure TryMatchingAdjustments(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var UnmatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer
    var
        FeeCreatePost: Codeunit "NPR Adyen Fee Posting";
        RecordPrepared: Boolean;
        GLAccountType: Enum "NPR Adyen Posting GL Accounts";
    begin
        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"G/L Entry";
        RecordPrepared := false;
        case ReconciliationLine."Transaction Type" of
            ReconciliationLine."Transaction Type"::Fee:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Fee G/L Account");
            ReconciliationLine."Transaction Type"::InvoiceDeduction:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Invoice Deduction G/L Account");
            ReconciliationLine."Transaction Type"::PaymentCost:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Chargeback Fees G/L Account");
            ReconciliationLine."Transaction Type"::MerchantPayout:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Merchant Payout Account");
            ReconciliationLine."Transaction Type"::AcquirerPayout:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Acquirer Payout Account");
            ReconciliationLine."Transaction Type"::AdvancementCommissionExternallyWithInfo:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Advancement External Commission G/L Account");
            ReconciliationLine."Transaction Type"::RefundedInstallmentExternallyWithInfo:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Refunded External Commission G/L Account");
            ReconciliationLine."Transaction Type"::SettledInstallmentExternallyWithInfo:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Settled External Commission G/L Account");
        end;
        if RecordPrepared then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            if FeeCreatePost.FeePosted(ReconciliationLine) then begin
                ReconciliationLine."Matching Entry System ID" := FeeCreatePost.GetGlEntrySystemID();
                ReconciliationLine.Status := ReconciliationLine.Status::Posted;
            end;
            MatchedEntries += 1;
        end else begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
        end;
    end;
    #endregion

    #region Posting
    internal procedure PostEntries(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") Success: Boolean;
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        UnPostedEntries: Integer;
        Handled: Boolean;
        Window: Dialog;
        TotalEntries: Integer;
        ProcessedEntries: Integer;
        PostingEntriesLbl: Label 'Attempting to Post Reconciliation Line entries...\\Posting #1 Entry out of #2';
        PostAllowed: Boolean;
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.SetFilter(Status, '<>%1', ReconciliationLine."Status"::Posted);
        if ReconciliationLine.IsEmpty() then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", true, StrSubstNo(PostTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            ReconciliationHeader.Posted := true;
            ReconciliationHeader.Modify();
            exit(true);
        end;

        ReconciliationLine.SetRange(Status, ReconciliationLine."Status"::Matched);
        if ReconciliationLine.IsEmpty() then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            exit(false);
        end;
        ReconciliationLine.SetFilter(Status, '<>%1', ReconciliationLine.Status::Posted);
        ReconciliationLine.FindSet();

        if GuiAllowed() then begin
            Clear(ProcessedEntries);
            TotalEntries := ReconciliationLine.Count();
            Window.Open(PostingEntriesLbl);
            Window.Update(1, TotalEntries);
        end;

        repeat
            Handled := false;
            if not Handled then begin
                PostAllowed := true;
                if ReconciliationLine."Matching Table Name" in [ReconciliationLine."Matching Table Name"::"EFT Transaction", ReconciliationLine."Matching Table Name"::"Magento Payment Line"] then
                    PostAllowed := PostingAllowed(ReconciliationLine);

                if PostAllowed then begin
                    AssignPostingDateAndNo(ReconciliationLine, ReconciliationHeader);
                    Commit();
                    case ReconciliationLine."Matching Table Name" of
                        ReconciliationLine."Matching Table Name"::"EFT Transaction",
                        ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                            begin
                                UnPostedEntries += TryPostingPayment(ReconciliationLine, ReconciliationHeader);
                            end;
                        ReconciliationLine."Matching Table Name"::"G/L Entry":
                            begin
                                UnPostedEntries += TryPostingAdjustments(ReconciliationLine, ReconciliationHeader);
                            end;
                        ReconciliationLine."Matching Table Name"::"To Be Determined":
                            begin
                                UnPostedEntries += 1;
                            end;
                    end;
                end else
                    UnPostedEntries += 1;

                ReconciliationLine.Modify();
            end;

            if GuiAllowed() then begin
                ProcessedEntries += 1;
                Window.Update(2, ProcessedEntries);
            end;
        until ReconciliationLine.Next() = 0;

        if GuiAllowed() then
            Window.Close();

        if UnPostedEntries > 0 then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError03, Format(UnPostedEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            exit(false);
        end;
        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", true, StrSubstNo(PostTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
        ReconciliationHeader.Posted := true;
        ReconciliationHeader.Modify();
        exit(true);
    end;

    local procedure TryPostingPayment(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnPostedEntries: Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        PostEFTTransaction: Codeunit "NPR Adyen EFT Trans. Posting";
    begin
        case ReconciliationLine."Matching Table Name" of
            ReconciliationLine."Matching Table Name"::"EFT Transaction":
                begin
                    if not EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsEFTError01, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
                        UnPostedEntries += 1;
                        exit(UnPostedEntries);
                    end;
                end;
            ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                begin
                    if not MagentoPaymentLine.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsMagentoError01, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
                        UnPostedEntries += 1;
                        exit(UnPostedEntries);
                    end;
                end;
        end;


        if not (ReconciliationLine.Status in [ReconciliationLine.Status::Matched, ReconciliationLine.Status::"Matched Manually"]) then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError04, Format(ReconciliationLine."PSP Reference")), ReconciliationHeader."Webhook Request ID");
            UnPostedEntries += 1;
            exit(UnPostedEntries);
        end;

        if PostEFTTransaction.PrepareRecords(ReconciliationLine, ReconciliationHeader) then begin
            if not PostEFTTransaction.LineIsPosted(ReconciliationLine) then begin
                if not PostEFTTransaction.Run() then begin
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                    UnPostedEntries += 1;
                    exit(UnPostedEntries);
                end;
                if ((not IsNullGuid(PostEFTTransaction.GetNewReversedSystemId()))) and (ReconciliationLine."Transaction Type" in
                    [ReconciliationLine."Transaction Type"::Chargeback,
                    ReconciliationLine."Transaction Type"::SecondChargeback,
                    ReconciliationLine."Transaction Type"::RefundedReversed,
                    ReconciliationLine."Transaction Type"::ChargebackReversed,
                    ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo])
                then begin
                    ReconciliationLine."Matching Entry System ID" := PostEFTTransaction.GetNewReversedSystemId();
                    ReconciliationLine.Modify();
                end;
            end;
            ReconciliationLine.Status := ReconciliationLine.Status::Posted;
            case ReconciliationLine."Matching Table Name" of
                ReconciliationLine."Matching Table Name"::"EFT Transaction":
                    begin
                        if EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                            EFTTransactionRequest.Reconciled := true;
                            EFTTransactionRequest."Reconciliation Date" := Today();
                            EFTTransactionRequest.Modify();
                        end;
                    end;
                ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                    begin
                        if MagentoPaymentLine.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                            MagentoPaymentLine.Reconciled := true;
                            MagentoPaymentLine."Reconciliation Date" := Today();
                            MagentoPaymentLine.Modify();
                        end;
                    end;
            end;

        end else begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
            UnPostedEntries += 1;
        end;
    end;

    local procedure TryPostingAdjustments(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnPostedEntries: Integer
    var
        FeeCreateAndPost: Codeunit "NPR Adyen Fee Posting";
        GLAccountType: Enum "NPR Adyen Posting GL Accounts";
        RecordsOK: Boolean;
    begin
        if not IsNullGuid(ReconciliationLine."Matching Entry System ID") then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Posted;
            exit(UnPostedEntries);
        end;
        RecordsOK := false;
        case ReconciliationLine."Transaction Type" of
            ReconciliationLine."Transaction Type"::Fee:
                RecordsOK := FeeCreateAndPost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Fee G/L Account");
            ReconciliationLine."Transaction Type"::InvoiceDeduction:
                RecordsOK := FeeCreateAndPost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Invoice Deduction G/L Account");
            ReconciliationLine."Transaction Type"::PaymentCost:
                RecordsOK := FeeCreateAndPost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Chargeback Fees G/L Account");
            ReconciliationLine."Transaction Type"::MerchantPayout:
                RecordsOK := FeeCreateAndPost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Merchant Payout Account");
            ReconciliationLine."Transaction Type"::AcquirerPayout:
                RecordsOK := FeeCreateAndPost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Acquirer Payout Account");
            ReconciliationLine."Transaction Type"::AdvancementCommissionExternallyWithInfo:
                RecordsOK := FeeCreateAndPost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Advancement External Commission G/L Account");
            ReconciliationLine."Transaction Type"::RefundedInstallmentExternallyWithInfo:
                RecordsOK := FeeCreateAndPost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Refunded External Commission G/L Account");
            ReconciliationLine."Transaction Type"::SettledInstallmentExternallyWithInfo:
                RecordsOK := FeeCreateAndPost.PrepareRecords(ReconciliationLine, ReconciliationHeader, GLAccountType::"Settled External Commission G/L Account");
        end;
        if not RecordsOK then begin
            UnPostedEntries += 1;
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
            exit(UnPostedEntries);
        end;
        if not FeeCreateAndPost.FeePosted(ReconciliationLine) then begin
            if not FeeCreateAndPost.Run() then begin
                UnPostedEntries += 1;
                _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                exit(UnPostedEntries);
            end;
        end;
        ReconciliationLine."Matching Entry System ID" := FeeCreateAndPost.GetGlEntrySystemID();
        ReconciliationLine.Status := ReconciliationLine.Status::Posted;
    end;

    internal procedure AssignPostingDateAndNo(var RecLine: Record "NPR Adyen Recon. Line"; var RecHeader: Record "NPR Adyen Reconciliation Hdr")
    begin
        if _AdyenSetup.Get() and (_AdyenSetup."Posting Document Nos." <> '') then begin
            RecLine."Posting No." := _NoSeriesMgt.GetNextNo(_AdyenSetup."Posting Document Nos.", Today(), true);
            if _AdyenSetup."Post with Transaction Date" then
                RecLine."Posting Date" := DT2Date(RecLine."Transaction Date")
            else
                RecLine."Posting Date" := RecHeader."Posting Date";
            RecLine.Modify();
        end;
    end;

    local procedure PostingAllowed(var ReconciliationLine: Record "NPR Adyen Recon. Line"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ChargebackNeedsConfirmationLbl: Label 'It is not allowed to post %1 entry. Chargeback transactions require your confirmation first.';
        PostingNotAllowedLbl: Label 'It is not allowed to post %1 entry.';
        ParkedSaleLbl: Label 'The sale %1 is parked. Please finish the sale and try again.';
        SaleNotFinishedLbl: Label 'The sale %1 has not yet been finished. Please finish the sale and try again.';
        EFTTransactionRequestDoesNotExistLbl: Label 'EFT Transaction Request %1 does not exist anymore.';
        SavedPOSSale: Record "NPR POS Saved Sale Entry";
    begin
        case ReconciliationLine."Matching Table Name" of
            ReconciliationLine."Matching Table Name"::"EFT Transaction":
                begin
                    if not EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(EFTTransactionRequestDoesNotExistLbl, ReconciliationLine."Matching Entry System ID"), ReconciliationLine."Webhook Request ID");
                        ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                        exit(false);
                    end;
                    if not ReconciliationLine."Posting allowed" then begin
                        if ReconciliationLine."Transaction Type" in [ReconciliationLine."Transaction Type"::Chargeback, ReconciliationLine."Transaction Type"::ChargebackExternallyWithInfo, ReconciliationLine."Transaction Type"::SecondChargeback] then
                            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(ChargebackNeedsConfirmationLbl, ReconciliationLine."Line No."), ReconciliationLine."Webhook Request ID")
                        else
                            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostingNotAllowedLbl, ReconciliationLine."Line No."), ReconciliationLine."Webhook Request ID");

                        ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                        exit(false);
                    end;

                    /* Unknown use  //TODO (confirm with Tim)
                    if ((EFTTransactionRequest.Finished = 0DT) or (not EFTTransactionRequest."External Result Known")) and (EFTTransactionRequest."Amount Input" <> 0) then begin
                        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(SaleNotFinishedLbl, EFTTransactionRequest."Sales Ticket No."), ReconciliationLine."Webhook Request ID");
                        ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                        exit(false);
                    end;
                    */

                    if EFTTransactionRequest."Result Amount" <> 0 then begin
                        EFTTransactionRequest.CalcFields("FF Moved to POS Entry");
                        if not EFTTransactionRequest."FF Moved to POS Entry" then begin
                            if SavedPOSSale.GetBySystemId(EFTTransactionRequest."Sales ID") then
                                _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(ParkedSaleLbl, Format(EFTTransactionRequest."Sales Ticket No.")), ReconciliationLine."Webhook Request ID")
                            else
                                _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(SaleNotFinishedLbl, Format(EFTTransactionRequest."Sales Ticket No.")), ReconciliationLine."Webhook Request ID");
                            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                            exit(false);
                        end;
                    end;
                end;
            ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                begin
                end;
        end;
        exit(true);
    end;
    #endregion

    #region Miscellaneous
    internal procedure ValidateReportScheme(var WebhookRequest: Record "NPR AF Rec. Webhook Request"): Boolean
    var
        SchemeValid: Boolean;
        SchemeValidationField: Text;
        i: Integer;
        SchemeColumnNumber: Integer;
        InvalidSchemeError: Label 'Validation Scheme Failed: Report did not meet validation criteria. Column ''%1'' does not exist or has an incorrect placement. Please check report''s configuration.';
        ValidSchemeText: Label 'Validation Success: Report passed all validation criteria.';
        NoSetupCreated: Label 'Adyen Setup configuration does not exist.';
        PostingNosEmpty: Label 'Posting Document Nos. is not specified in Adyen Setup.';
        Scheme: array[50] of Text[35];
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        if WebhookRequest.ID = 0 then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Get Report", false, StrSubstNo(GetWebhookError, Format(WebhookRequest.ID)), 0);
            exit;
        end;
        if not AdyenSetup.Get() then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Init Setup", false, NoSetupCreated, WebhookRequest.ID);
            exit;
        end;
        if AdyenSetup."Posting Document Nos." = '' then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Init Setup", false, PostingNosEmpty, WebhookRequest.ID);
            exit;
        end;
        if not GetReportData(WebhookRequest, false) then
            exit;
        _AdyenManagement.DefineReportScheme(WebhookRequest."Report Type", Scheme, SchemeColumnNumber);

        if WebhookRequest."Report Type" = WebhookRequest."Report Type"::Undefined then
            exit;

        SchemeValid := true;
        i := 1;

        while SchemeValid and (i <= SchemeColumnNumber) do begin
            SchemeValidationField := Scheme[i];
            SchemeValid := ValidateFieldName(SchemeValidationField, GetValueAtCell(1, i));
            i += 1;
        end;

        if not SchemeValid then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Validate Report Scheme", false, StrSubstNo(InvalidSchemeError, SchemeValidationField), WebhookRequest.ID);
            exit;
        end;

        _AdyenManagement.CreateReconciliationLog(_LogType::"Validate Report Scheme", true, ValidSchemeText, WebhookRequest.ID);
        WebhookRequest.Processed := true;
        WebhookRequest.Modify();
        exit(true);
    end;

    internal procedure MarkAsPostedIfPossible(var RecHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        RecLine: Record "NPR Adyen Recon. Line";
    begin
        RecLine.SetRange("Document No.", RecHeader."Document No.");
        if RecLine.IsEmpty() then
            exit;
        RecLine.SetFilter(Status, '<>%1', RecLine.Status::Posted);
        if not RecLine.IsEmpty() then
            exit;
        if RecHeader.Posted then
            exit;
        RecHeader.Posted := true;
        RecHeader.Modify(false);
        exit(true);
    end;

    internal procedure PostUnmatchedEntries(var Lines: Record "NPR Adyen Recon. Line"; var RecHeader: Record "NPR Adyen Reconciliation Hdr") PostedEntries: Integer
    var
        Window: Dialog;
        EntryPosting: Integer;
        PostMissingTransaction: Codeunit "NPR Adyen Missing Trans. Post";
        ProcessingLbl: Label 'Posting the Reconciliation Line/s...\\Posting #1 entry out of #2.';
    begin
        Window.Open(ProcessingLbl);
        Window.Update(2, Lines.Count());
        EntryPosting := 0;
        repeat
            EntryPosting += 1;
            Window.Update(1, Format(EntryPosting));
            if RecHeader.Get(Lines."Document No.") then begin
                Lines.LockTable();
                AssignPostingDateAndNo(Lines, RecHeader);
            end;
            Lines.LockTable();
            Commit();
            Clear(PostMissingTransaction);
            if PostMissingTransaction.Run(Lines) then begin
                Lines."Matching Table Name" := Lines."Matching Table Name"::"G/L Entry";
                Lines."Matching Entry System ID" := PostMissingTransaction.GetGLSystemID();
                Lines.Status := Lines.Status::Posted;
                Lines.Modify();
                PostedEntries += 1;
            end;
        until Lines.Next() = 0;
        Window.Close();

        MarkAsPostedIfPossible(RecHeader);
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        if (Temp_ExcelBuffer.Get(RowNo, ColNo)) then
            exit(Temp_ExcelBuffer."Cell Value as Text");
        exit('');
    end;

    local procedure CalculateRealizedGL(var ReconciliationLine: Record "NPR Adyen Recon. Line"; PaymentLine: Record "NPR POS Entry Payment Line") RealizedGLAmount: Decimal
    var
        AmountLCY: Decimal;
        GrossCreditAAC: Decimal;
        GrossCreditLCY: Decimal;
    begin
        AmountLCY := PaymentLine."Amount (LCY)";

        if AmountLCY = 0 then
            AmountLCY := ReconciliationLine."Amount (TCY)";

        GrossCreditAAC := ReconciliationLine."Gross Credit" * ReconciliationLine."Exchange Rate";

        if (_GLSetup."LCY Code" <> ReconciliationLine."Adyen Acc. Currency Code") then
            GrossCreditLCY := Round(_CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", GrossCreditAAC, _CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")))
        else
            GrossCreditLCY := GrossCreditAAC;

        RealizedGLAmount := Round(AmountLCY - GrossCreditLCY, 0.01);
    end;

    local procedure GetReportData(var ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; RecreateDocument: Boolean): Boolean
    var
        ReportInStream: InStream;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        InStr: InStream;
        OutStr: OutStream;
        ErrorLabel: Text;
        DownloadURLMissingLbl: Label 'Webhook request with ID %1 does not have a Report Download URL.\Please contact your System Administrator.';
        AdyenSetupDoesNotExistLbl: Label 'Adyen Setup does not exist.';
        HttpErrorText: Text;
        FromFile: Boolean;
        LocalFileLbl: Label 'Local File Upload', Locked = true;
    begin
        if not _AdyenSetup.Get() then begin
            if RecreateDocument then
                Error(AdyenSetupDoesNotExistLbl)
            else begin
                _AdyenManagement.CreateReconciliationLog(_LogType::"Init Setup", false, AdyenSetupDoesNotExistLbl, ReportWebhookRequest.ID);
                exit(false);
            end;
        end;

        FromFile := ReportWebhookRequest."Report Download URL" = LocalFileLbl;

        if not FromFile then begin
            Clear(ReportWebhookRequest."Report Data");

            if ReportWebhookRequest."Report Download URL" = '' then begin
                if RecreateDocument then
                    Error(DownloadURLMissingLbl, Format(ReportWebhookRequest.ID));
                _AdyenManagement.CreateReconciliationLog(_LogType::"Get Report", false, StrSubstNo(GetReportError02, Format(ReportWebhookRequest.ID)), ReportWebhookRequest.ID);
                exit(false);
            end;

            HttpClient.DefaultRequestHeaders.Add('x-api-key', _AdyenSetup."Download Report API Key");
            HttpClient.Get(ReportWebhookRequest."Report Download URL", HttpResponseMessage);
            if (HttpResponseMessage.IsSuccessStatusCode()) then begin
                HttpContent := HttpResponseMessage.Content();
                ReportWebhookRequest."Report Data".CreateInStream(InStr);
                HttpContent.ReadAs(InStr);
                ReportWebhookRequest."Report Data".CreateOutStream(OutStr);
                CopyStream(OutStr, InStr);

                ReportWebhookRequest.Modify();
            end else begin
                if not RecreateDocument then begin
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Get Report", false, Format(HttpResponseMessage.HttpStatusCode()) + ': ' + HttpResponseMessage.ReasonPhrase(), ReportWebhookRequest.ID);
                    exit(false);
                end else begin
                    HttpErrorText := Format(HttpResponseMessage.HttpStatusCode()) + ': ' + HttpResponseMessage.ReasonPhrase();
                    Error(HttpErrorText);
                end;
            end;
        end;

        ReportWebhookRequest.CalcFields("Report Data");
        ReportWebhookRequest."Report Data".CreateInStream(ReportInStream, TextEncoding::UTF8);

        ReadExcelSheet(ReportInStream);

        if GetNumberOfRows() < 2 then begin
            ErrorLabel := Format(ReportWebhookRequest."Report Data".HasValue) + ': ' + Format(ReportWebhookRequest."Report Data".Length);
            if not RecreateDocument then begin
                _AdyenManagement.CreateReconciliationLog(_LogType::"Import Lines", false, StrSubstNo(ImportLinesError01, ReportWebhookRequest."Report Name", ErrorLabel), ReportWebhookRequest.ID);
                exit(false);
            end else
                Error(ImportLinesError01, ReportWebhookRequest."Report Name", ErrorLabel);
        end;
        exit(true);
    end;

    local procedure ReadExcelSheet(var ReportInStream: InStream)
    var
        SheetNameLbl: Label 'data', Locked = true;
    begin
        Temp_ExcelBuffer.Reset();
        Temp_ExcelBuffer.DeleteAll();
        Temp_ExcelBuffer.OpenBookStream(ReportInStream, SheetNameLbl);
        Temp_ExcelBuffer.ReadSheet();
    end;

    local procedure CreateMerchantBatchListFromLines(var MerchantBatchValues: List of [JsonObject]; ReportType: Enum "NPR Adyen Report Type")
    var
        LineNo: Integer;
        JsonObject: JsonObject;
    begin

        for LineNo := 2 to GetNumberOfRows() do begin
            Clear(JsonObject);
            JsonObject.Add('Merchant Account', GetValueAtCell(LineNo, 2));
            case ReportType of
                ReportType::"Settlement details":
                    JsonObject.Add('Batch Number', GetValueAtCell(LineNo, 21));
                ReportType::"External Settlement detail (C)":
                    JsonObject.Add('Batch Number', '0');
            end;

            if MerchantBatchValues.IndexOf(JsonObject) = 0 then
                MerchantBatchValues.Add(JsonObject);
        end;
    end;

    local procedure GetNumberOfRows(): Integer
    begin
        Temp_ExcelBuffer.Reset();
        if Temp_ExcelBuffer.FindLast() then
            exit(Temp_ExcelBuffer."Row No.");
    end;

    local procedure ValidateFieldName(ControlName: Text; Value: Text): Boolean
    begin
        if (ControlName = Value) then
            exit(true);
        exit(false);
    end;

    local procedure CalculateLCYAmounts(var ReconciliationLine: Record "NPR Adyen Recon. Line")
    begin
        if ReconciliationLine."Amount(AAC)" <> 0 then
            ReconciliationLine."Amount (LCY)" := Round(_CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", ReconciliationLine."Amount(AAC)", _CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")));
        if ReconciliationLine."Markup (NC)" <> 0 then
            ReconciliationLine."Markup (LCY)" := Round(_CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", ReconciliationLine."Markup (NC)", _CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")));
        if ReconciliationLine."Payment Fees (NC)" <> 0 then
            ReconciliationLine."Payment Fees (LCY)" := Round(_CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", ReconciliationLine."Payment Fees (NC)", _CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")));
        if ReconciliationLine."Commission (NC)" <> 0 then
            ReconciliationLine."Commission (LCY)" := Round(_CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", ReconciliationLine."Commission (NC)", _CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")));
        if ReconciliationLine."Scheme Fees (NC)" <> 0 then
            ReconciliationLine."Scheme Fees (LCY)" := Round(_CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", ReconciliationLine."Scheme Fees (NC)", _CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")));
        if ReconciliationLine."Interchange (NC)" <> 0 then
            ReconciliationLine."Interchange (LCY)" := Round(_CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", ReconciliationLine."Interchange (NC)", _CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")));
        if ReconciliationLine."Other Commissions (NC)" <> 0 then
            ReconciliationLine."Other Commissions (LCY)" := Round(_CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", ReconciliationLine."Other Commissions (NC)", _CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")));
    end;

    local procedure CopyAACtoLCYAmounts(var ReconciliationLine: Record "NPR Adyen Recon. Line")
    begin
        ReconciliationLine."Amount (LCY)" := ReconciliationLine."Amount(AAC)";
        ReconciliationLine."Markup (LCY)" := ReconciliationLine."Markup (NC)";
        ReconciliationLine."Payment Fees (LCY)" := ReconciliationLine."Payment Fees (NC)";
        ReconciliationLine."Commission (LCY)" := ReconciliationLine."Commission (NC)";
        ReconciliationLine."Scheme Fees (LCY)" := ReconciliationLine."Scheme Fees (NC)";
        ReconciliationLine."Interchange (LCY)" := ReconciliationLine."Interchange (NC)";
        ReconciliationLine."Other Commissions (LCY)" := ReconciliationLine."Other Commissions (NC)";
    end;

    local procedure ReconLineIsUnique(ReconciliationLine: Record "NPR Adyen Recon. Line"): Boolean
    var
        RecLine: Record "NPR Adyen Recon. Line";
    begin
        RecLine.Reset();
        if ReconciliationLine."PSP Reference" <> '' then begin
            RecLine.SetRange("PSP Reference", ReconciliationLine."PSP Reference");
            RecLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type");
            RecLine.SetRange("Amount (TCY)", ReconciliationLine."Amount (TCY)");
            if RecLine.IsEmpty() then
                exit(true);
        end else begin
            case ReconciliationLine."Transaction Type" of
                ReconciliationLine."Transaction Type"::Fee:
                    begin
                        RecLine.SetRange("Modification Reference", ReconciliationLine."Modification Reference");
                        RecLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type");
                        RecLine.SetRange("Amount (TCY)", ReconciliationLine."Amount (TCY)");
                        if RecLine.IsEmpty() then
                            exit(true);
                    end;
                else begin
                    RecLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type");
                    RecLine.SetRange("Amount(AAC)", ReconciliationLine."Amount(AAC)");
                    if RecLine.IsEmpty() then
                        exit(true);
                end;
            end;
        end;
    end;
    #endregion
    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
        _GLSetup: Record "General Ledger Setup";
        _AdyenSetup: Record "NPR Adyen Setup";
        Temp_ExcelBuffer: Record "Excel Buffer" temporary;
        _LogType: Enum "NPR Adyen Rec. Log Type";
        _CurrExchRate: Record "Currency Exchange Rate";
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        _NoSeriesMgt: Codeunit "No. Series";
#else
        _NoSeriesMgt: Codeunit NoSeriesManagement;
#endif
        GetWebhookError: Label 'Webhook request with ID %1 does not exist.';
        GetReportError02: Label 'Webhook request with ID %1 does not have a Report Download URL.\Please contact your System Administrator.';
        ImportLinesError01: Label 'Report ''%1'' has no entries. Report Data exist - %2';
        ImportLinesError02: Label 'Report ''%1'' has no transactions within Merchant Account ''%2''.';
        ImportLinesError03: Label 'Unsupported Journal Type: %1.\Entry was skipped.';
        ImportLinesSuccess01: Label 'Adyen Reconciliation Document %1 was successfully created with %2 transaction entries.';
        MatchTransactionsError01: Label 'Failed to match with EFT Transaction Request No. %1 because of one of the conditions:\\    Amounts are equal: %2\EFT Transaction Amount:%3, Reconciliation Line Transaction Amount:%4\\Financial Impact: %5';
        MatchTransactionsError02: Label 'Adyen Reconciliation Document %1 does not contain any transactions within Marchant Account ''%2''.';
        MatchTransactionsError03: Label 'Couldn''t match %1 entries in Adyen Reconciliation Document %2.';
        MatchTransactionsError04: Label 'Failed to match with Magento Payment Line (Document Type: %1, Document No.: %2, Document Line No.: %3).\\    Amounts are not equal:\Magento Payment Line Amount:%4, Reconciliation Line Transaction Amount:%5';
        MatchTransactionsError05: Label 'EFT Transaction Request was found, however the POS Entry Payment Line does not exist. Please check if the Sale is posted.';
        MatchTransactionsError06: Label 'PSP Reference is empty.';
        MatchTransactionsSuccess01: Label 'Successfully matched entries in Adyen Reconciliation Document %1.';
        PostTransactionsError01: Label 'Couldn''t find any matched transactions to post in Adyen Reconciliation Document %1.';
        PostTransactionsEFTError01: Label 'EFT Transaction Request %1 does not exist.';
        PostTransactionsMagentoError01: Label 'Magento Payment Line %1 does not exist.';
        PostTransactionsError03: Label 'Couldn''t post %1 entries in Adyen Reconciliation Document %2.';
        PostTransactionsError04: Label 'Transaction %1 is not matched yet.';
        PostTransactionsSuccess01: Label 'Successfully posted entries in Adyen Reconciliation Document %1.';
        NoSeriesError01: Label 'No. Series in Adyen Generic Setup is not specified.';
}

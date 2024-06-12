codeunit 6184779 "NPR Adyen Trans. Matching"
{
    Access = Internal;

#IF NOT BC17
    internal procedure CreateSettlementDocuments(ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; RecreateExistingDocument: Boolean; ExistingDocumentNo: Code[20]) NewDocumentsList: List of [Code[20]]
#ELSE
    internal procedure CreateSettlementDocuments(ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; RecreateExistingDocument: Boolean; ExistingDocumentNo: Code[20]) NewDocumentsList: JsonArray
#ENDIF
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
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
            _AdyenManagement.CreateLog(_LogType::"Init Setup", false, SetupDoesNotExist, 0);
            exit;
        end;

        if _GLSetup."LCY Code" = '' then begin
            _AdyenManagement.CreateLog(_LogType::"Init Setup", false, GLSetupLCYCodeIsEmpty, 0);
            exit;
        end;

        if ReportWebhookRequest.ID = 0 then begin
            _AdyenManagement.CreateLog(_LogType::"Get Report", false, StrSubstNo(GetWebhookError, Format(ReportWebhookRequest.ID)), 0);
            exit;
        end;

        if not GetReportData(ReportWebhookRequest) then
            exit;

        if not RecreateExistingDocument then
            CreateMerchantBatchListFromLines(MerchantBatchValues)
        else begin
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
                    _AdyenManagement.CreateLog(_LogType::"Import Lines", true, StrSubstNo(ImportLinesSuccess01, ReconciliationHeader."Document No.", Format(EntryAmount)), ReportWebhookRequest.ID);
                    NewDocumentsList.Add(ReconciliationHeader."Document No.");
                end else begin
                    ReconciliationHeader.Delete();
                    _AdyenManagement.CreateLog(_LogType::"Import Lines", false, StrSubstNo(ImportLinesError02, ReportWebhookRequest."Report Name", CurrentMerchantAccount), ReportWebhookRequest.ID);
                end;
            end;
        end;
        exit(NewDocumentsList);
    end;

    internal procedure MatchEntries(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer;
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        ReconciliationLine2: Record "NPR Adyen Recon. Line";
        UnmatchedEntries: Integer;
        Handled: Boolean;
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.SetFilter(Status, '%1|%2', ReconciliationLine.Status::" ", ReconciliationLine.Status::"Failed to Match");
        if not ReconciliationLine.FindSet(true) then begin
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError02, ReconciliationHeader."Document No.", ReconciliationHeader."Merchant Account"), ReconciliationHeader."Webhook Request ID");
            exit(MatchedEntries);
        end;
        Clear(MatchedEntries);
        Clear(UnmatchedEntries);
        repeat
            ReconciliationLine2 := ReconciliationLine;
            Handled := false;
            //Future event
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
        until ReconciliationLine.Next() = 0;
        if UnmatchedEntries > 0 then
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError03, Format(UnmatchedEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID")
        else
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", true, StrSubstNo(MatchTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
        exit(MatchedEntries);
    end;

    internal procedure PostEntries(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") Success: Boolean;
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        UnPostedEntries: Integer;
        Handled: Boolean;
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.SetRange(Status, ReconciliationLine."Status"::Matched);
        if ReconciliationLine.IsEmpty() then begin
            _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            exit(false);
        end;
        ReconciliationLine.SetRange(Status);
        ReconciliationLine.FindSet();
        repeat
            Handled := false;
            if not Handled then begin
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
                ReconciliationLine.Modify();
            end;
        until ReconciliationLine.Next() = 0;

        if UnPostedEntries > 0 then begin
            _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError03, Format(UnPostedEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            exit(false);
        end;
        _AdyenManagement.CreateLog(_LogType::"Post Transactions", true, StrSubstNo(PostTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
        ReconciliationHeader.Posted := true;
        ReconciliationHeader.Modify();
        exit(true);
    end;

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
            _AdyenManagement.CreateLog(_LogType::"Get Report", false, StrSubstNo(GetWebhookError, Format(WebhookRequest.ID)), 0);
            exit;
        end;
        if not AdyenSetup.Get() then begin
            _AdyenManagement.CreateLog(_LogType::"Init Setup", false, NoSetupCreated, WebhookRequest.ID);
            exit;
        end;
        if AdyenSetup."Posting Document Nos." = '' then begin
            _AdyenManagement.CreateLog(_LogType::"Init Setup", false, PostingNosEmpty, WebhookRequest.ID);
            exit;
        end;
        if not GetReportData(WebhookRequest) then
            exit;

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
            _AdyenManagement.CreateLog(_LogType::"Validate Report Scheme", false, StrSubstNo(InvalidSchemeError, SchemeValidationField), WebhookRequest.ID);
            exit;
        end;

        _AdyenManagement.CreateLog(_LogType::"Validate Report Scheme", true, ValidSchemeText, WebhookRequest.ID);
        WebhookRequest.Processed := true;
        WebhookRequest.Modify();
        exit(true);
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        if (Temp_CSVBuffer.Get(RowNo, ColNo)) then
            exit(Temp_CSVBuffer.Value);
        exit('');
    end;

    local procedure InitReconciliationHeader(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; RecreateExistingDocument: Boolean; CurrentBatchNumber: Integer; CurrentMerchantAccount: Text; ExistingDocumentNo: Code[20]; WebhookRequest: Record "NPR AF Rec. Webhook Request"): Boolean
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        NoSeriesMgt: Codeunit "No. Series";
#else
        NoSeriesMgt: Codeunit NoSeriesManagement;
#endif
        AdyenGenericSetup: Record "NPR Adyen Setup";
        DocumentExistLbl: Label 'A Reconciliation document with identification fields Merchant Account: ''%1'' and Batch Number: ''%2'' already exist.';
    begin
        if (not RecreateExistingDocument) then begin
            AdyenGenericSetup.Get();
            if AdyenGenericSetup."Reconciliation Document Nos." = '' then begin
                _AdyenManagement.CreateLog(_LogType::"Import Lines", false, NoSeriesError01, WebhookRequest.ID);
                exit(false);
            end;
            ReconciliationHeader.Reset();
            ReconciliationHeader.SetRange("Batch Number", CurrentBatchNumber);
            ReconciliationHeader.SetRange("Merchant Account", CurrentMerchantAccount);
            if not ReconciliationHeader.IsEmpty() then begin
                _AdyenManagement.CreateLog(_LogType::"Get Report", false, StrSubstNo(DocumentExistLbl, CurrentMerchantAccount, Format(CurrentBatchNumber)), WebhookRequest.ID);
                exit(false);
            end;

            ReconciliationHeader.Init();
            ReconciliationHeader."Document No." := NoSeriesMgt.GetNextNo(AdyenGenericSetup."Reconciliation Document Nos.", Today(), true);
            ReconciliationHeader."Document Date" := Today();
            ReconciliationHeader."Posting Date" := Today();
            ReconciliationHeader.Insert();
        end else begin
            ReconciliationHeader.Get(ExistingDocumentNo);
            if ReconciliationHeader.Posted then
                exit(false);
            ReconciliationHeader."Document Date" := Today();
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
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        NoSeriesMgt: Codeunit "No. Series";
#else
        NoSeriesMgt: Codeunit NoSeriesManagement;
#endif
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        xReconciliationLine.SetCurrentKey("Line No.");
        xReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.Init();
        ReconciliationLine."Document No." := ReconciliationHeader."Document No.";
        ReconciliationLine."Line No." := 1;
        if AdyenSetup.Get() and (AdyenSetup."Posting Document Nos." <> '') then
            ReconciliationLine."Posting No." := NoSeriesMgt.GetNextNo(AdyenSetup."Posting Document Nos.", Today(), true);
        if xReconciliationLine.FindLast() then
            ReconciliationLine."Line No." += xReconciliationLine."Line No.";
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

    local procedure InsertReconciliationLine(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; BatchNumber: Integer; MerchantAccount: Text; ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; LineNo: Integer; var EntryAmount: Integer): Boolean
    var
    begin
        InitReconciliationLine(ReconciliationHeader, ReconciliationLine);
        ReconciliationLine."Merchant Order Reference" := CopyStr(GetValueAtCell(LineNo, 24), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
        ReconciliationLine."Batch Number" := BatchNumber;

        ReconciliationLine."Company Account" := CopyStr(GetValueAtCell(LineNo, 1), 1, MaxStrLen(ReconciliationLine."Company Account"));
        ReconciliationLine."Merchant Account" := CopyStr(MerchantAccount, 1, MaxStrLen(ReconciliationLine."Merchant Account"));
        ReconciliationLine."PSP Reference" := CopyStr(GetValueAtCell(LineNo, 3), 1, MaxStrLen(ReconciliationLine."PSP Reference"));
        ReconciliationLine."Merchant Reference" := CopyStr(GetValueAtCell(LineNo, 4), 1, MaxStrLen(ReconciliationLine."Merchant Reference"));
        if Evaluate(ReconciliationLine."Transaction Date", GetValueAtCell(LineNo, 6)) then;

        if _AdyenSetup."Post with Transaction Date" then
            ReconciliationLine."Posting Date" := DT2Date(ReconciliationLine."Transaction Date")
        else
            ReconciliationLine."Posting Date" := ReconciliationHeader."Posting Date";

        ReconciliationLine."Modification Reference" := CopyStr(GetValueAtCell(LineNo, 9), 1, MaxStrLen(ReconciliationLine."Modification Reference"));
        ReconciliationLine."Transaction Currency Code" := CopyStr(GetValueAtCell(LineNo, 10), 1, MaxStrLen(ReconciliationLine."Transaction Currency Code"));

        if Evaluate(ReconciliationLine."Exchange Rate", GetValueAtCell(LineNo, 13), 9) then;
        ReconciliationLine."Adyen Acc. Currency Code" := CopyStr(GetValueAtCell(LineNo, 14), 1, MaxStrLen(ReconciliationLine."Adyen Acc. Currency Code"));
        ReconciliationHeader."Adyen Acc. Currency Code" := ReconciliationLine."Adyen Acc. Currency Code";

        if Evaluate(ReconciliationLine."Commission (NC)", GetValueAtCell(LineNo, 17), 9) then;
        if Evaluate(ReconciliationLine."Markup (NC)", GetValueAtCell(LineNo, 18), 9) then;
        if Evaluate(ReconciliationLine."Scheme Fees (NC)", GetValueAtCell(LineNo, 25), 9) then;
        if Evaluate(ReconciliationLine."Interchange (NC)", GetValueAtCell(LineNo, 26), 9) then;
        if Evaluate(ReconciliationLine."Payment Fees (NC)", GetValueAtCell(LineNo, 27), 9) then;

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
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::MerchantPayout;
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
                _AdyenManagement.CreateLog(_LogType::"Import Lines", false, StrSubstNo(ImportLinesError03, GetValueAtCell(LineNo, 8)), ReportWebhookRequest.ID);
                exit(false);
            end;
        end;
        ReconciliationLine."Webhook Request ID" := ReportWebhookRequest.ID;
        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"To Be Determined";
        ReconciliationLine.Insert(true);

        if _GLSetup."LCY Code" <> ReconciliationLine."Adyen Acc. Currency Code" then
            CalculateLCYAmounts(ReconciliationLine)
        else
            CopyAACtoLCYAmounts(ReconciliationLine);

        EntryAmount += 1;
        ReconciliationHeader.Modify();
    end;

    local procedure TryMatchingPayment(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var UnmatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer
    begin
        if ReconciliationLine."PSP Reference" = '' then begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
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
        if not (ReconciliationLine."Transaction Type" in [ReconciliationLine."Transaction Type"::Chargeback,
                                                    ReconciliationLine."Transaction Type"::SecondChargeback,
                                                    ReconciliationLine."Transaction Type"::RefundedReversed,
                                                    ReconciliationLine."Transaction Type"::ChargebackReversed,
                                                    ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]) then
            EFTTransactionRequest.SetRange(EFTTransactionRequest.Reconciled, false)
        else
            EFTTransactionRequest.SetRange(Reversed, false);

        if not EFTTransactionRequest.FindFirst() then
            exit;

        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"EFT Transaction";
        ReconciliationLine."Matching Entry System ID" := EFTTransactionRequest.SystemId;

        if ReconciliationLine."Transaction Type" in [ReconciliationLine."Transaction Type"::Chargeback,
                                                    ReconciliationLine."Transaction Type"::SecondChargeback,
                                                    ReconciliationLine."Transaction Type"::RefundedReversed,
                                                    ReconciliationLine."Transaction Type"::ChargebackReversed,
                                                    ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo] then begin
            if not PaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID") then begin
                ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
                _AdyenManagement.CreateLog(_LogType::"Match Transactions", false,
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

        if ((EFTTransactionRequest."Result Amount" * EFTAmountFactor) = (ReconciliationLine."Amount (TCY)"))
            and EFTTransactionRequest."Financial Impact"
        then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            MatchedEntries += 1;
            if PaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID") and
                (ReconciliationLine."Adyen Acc. Currency Code" <> ReconciliationLine."Transaction Currency Code") and
                (ReconciliationLine."Transaction Type" in [ReconciliationLine."Transaction Type"::Settled,
                                                            ReconciliationLine."Transaction Type"::Refunded,
                                                            ReconciliationLine."Transaction Type"::Chargeback,
                                                            ReconciliationLine."Transaction Type"::SecondChargeback,
                                                            ReconciliationLine."Transaction Type"::SettledExternallyWithInfo,
                                                            ReconciliationLine."Transaction Type"::RefundedExternallyWithInfo,
                                                            ReconciliationLine."Transaction Type"::ChargebackExternallyWithInfo]) then begin
                ReconciliationLine."Realized Gains or Losses" := CalculateRealizedGL(ReconciliationLine, PaymentLine);
            end;
        end else begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", false,
                StrSubstNo(MatchTransactionsError01, Format(EFTTransactionRequest."Entry No."),
                                                        Format(EFTTransactionRequest."Result Amount" = ReconciliationLine."Amount (TCY)"),
                                                        Format(EFTTransactionRequest."Result Amount"),
                                                        Format(ReconciliationLine."Amount (TCY)"),
                                                        Format(EFTTransactionRequest."Financial Impact")),
                ReconciliationHeader."Webhook Request ID");
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
        if not (ReconciliationLine."Transaction Type" in [ReconciliationLine."Transaction Type"::Chargeback,
                                                   ReconciliationLine."Transaction Type"::SecondChargeback,
                                                   ReconciliationLine."Transaction Type"::RefundedReversed,
                                                   ReconciliationLine."Transaction Type"::ChargebackReversed,
                                                   ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]) then
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
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", false,
                StrSubstNo(MatchTransactionsError04, Format(MagentoPaymentLine."Document Type"),
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
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
        end;
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
                        _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsEFTError01, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
                        UnPostedEntries += 1;
                        exit(UnPostedEntries);
                    end;
                end;
            ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                begin
                    if not MagentoPaymentLine.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsMagentoError01, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
                        UnPostedEntries += 1;
                        exit(UnPostedEntries);
                    end;
                end;
        end;


        if not (ReconciliationLine.Status in [ReconciliationLine.Status::Matched, ReconciliationLine.Status::"Matched Manually"]) then begin
            _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError04, Format(ReconciliationLine."PSP Reference")), ReconciliationHeader."Webhook Request ID");
            UnPostedEntries += 1;
            exit(UnPostedEntries);
        end;

        if PostEFTTransaction.PrepareRecords(ReconciliationLine, ReconciliationHeader) then begin
            if not PostEFTTransaction.LineIsPosted(ReconciliationLine) then begin
                if not PostEFTTransaction.Run() then begin
                    _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                    UnPostedEntries += 1;
                    exit(UnPostedEntries);
                end;
                if ((ReconciliationLine."Transaction Type" in [ReconciliationLine."Transaction Type"::Chargeback,
                                                ReconciliationLine."Transaction Type"::SecondChargeback,
                                                ReconciliationLine."Transaction Type"::RefundedReversed,
                                                ReconciliationLine."Transaction Type"::ChargebackReversed,
                                                ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]) and (not IsNullGuid(PostEFTTransaction.GetNewReversedSystemId()))) then begin
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
            _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
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
            _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
            exit(UnPostedEntries);
        end;
        if not FeeCreateAndPost.FeePosted(ReconciliationLine) then begin
            if not FeeCreateAndPost.Run() then begin
                UnPostedEntries += 1;
                _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                exit(UnPostedEntries);
            end;
        end;
        ReconciliationLine."Matching Entry System ID" := FeeCreateAndPost.GetGlEntrySystemID();
        ReconciliationLine.Status := ReconciliationLine.Status::Posted;
    end;

    local procedure GetReportData(var ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"): Boolean
    var
        ReportInStream: InStream;
        ReportOutStream: OutStream;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        ErrorLabel: Text;
    begin
        if not ReportWebhookRequest."Report Data".HasValue() then begin
            if ReportWebhookRequest."Report Download URL" = '' then begin
                _AdyenManagement.CreateLog(_LogType::"Get Report", false, StrSubstNo(GetReportError02, Format(ReportWebhookRequest.ID)), ReportWebhookRequest.ID);
                exit(false);
            end;
            _AdyenManagement.CreateLog(_LogType::"Get Report", false, StrSubstNo(GetReportError01, Format(ReportWebhookRequest.ID)), ReportWebhookRequest.ID);
            HttpClient.Get(ReportWebhookRequest."Report Download URL", HttpResponseMessage);

            if (not HttpResponseMessage.IsSuccessStatusCode()) then begin
                _AdyenManagement.CreateLog(_LogType::"Get Report", false, Format(HttpResponseMessage.HttpStatusCode()) + ': ' + HttpResponseMessage.ReasonPhrase(), ReportWebhookRequest.ID);
                exit(false);
            end;
            // Downloading CSV Report
            HttpResponseMessage.Content.ReadAs(ResponseText);
            ReportWebhookRequest."Report Data".CreateOutStream(ReportOutStream, TextEncoding::UTF8);
            ReportOutStream.WriteText(ResponseText);
            ReportWebhookRequest.Validate("Report Data");
            ReportWebhookRequest.Modify();
        end else
            _AdyenManagement.CreateLog(_LogType::"Get Report", true, StrSubstNo(GetReportSuccess01, ReportWebhookRequest."Report Name"), ReportWebhookRequest.ID);

        ReportWebhookRequest.CalcFields("Report Data");
        ReportWebhookRequest."Report Data".CreateInStream(ReportInStream);

        // Create Lines from Report Data
        if not Temp_CSVBuffer.IsEmpty() then
            Temp_CSVBuffer.DeleteAll();
        Temp_CSVBuffer.LoadDataFromStream(ReportInStream, ',');

        if Temp_CSVBuffer.GetNumberOfLines() < 2 then begin
            ErrorLabel := Format(ReportWebhookRequest."Report Data".HasValue) + ': ' + Format(ReportWebhookRequest."Report Data".Length);
            _AdyenManagement.CreateLog(_LogType::"Import Lines", false, StrSubstNo(ImportLinesError01, ReportWebhookRequest."Report Name", ErrorLabel), ReportWebhookRequest.ID);
            exit(false);
        end;

        exit(true);
    end;

    local procedure CreateMerchantBatchListFromLines(var MerchantBatchValues: List of [JsonObject])
    var
        LineNo: Integer;
        JsonObject: JsonObject;
    begin
        for LineNo := 2 to Temp_CSVBuffer.GetNumberOfLines() do begin
            Clear(JsonObject);
            JsonObject.Add('Merchant Account', GetValueAtCell(LineNo, 2));
            JsonObject.Add('Batch Number', GetValueAtCell(LineNo, 21));
            if MerchantBatchValues.IndexOf(JsonObject) = 0 then
                MerchantBatchValues.Add(JsonObject);
        end;
    end;

    local procedure InsertBalanceTransfer(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; LineNo: Integer)
    var
        FromBalance: Decimal;
        ToBalance: Decimal;
    begin
        if GetValueAtCell(LineNo, 20).Contains('from') then begin
            if Evaluate(FromBalance, GetValueAtCell(LineNo, 16), 9) then;
            ReconciliationHeader."Opening Balance" += FromBalance; // Might close multiple batches
        end else
            if GetValueAtCell(LineNo, 20).Contains('to') then begin
                if Evaluate(ToBalance, GetValueAtCell(LineNo, 15), 9) then;
                ReconciliationHeader."Closing Balance" += ToBalance; // Probably always is a single closing balance entry
            end;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertAcquirerPayout(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; LineNo: Integer)
    begin
        if Evaluate(ReconciliationHeader."Closing Balance", GetValueAtCell(LineNo, 15), 9) then;
        if Evaluate(ReconciliationHeader."Acquirer Commission", GetValueAtCell(LineNo, 17), 9) then;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertReconciliationLines(CurrentMerchantAccount: Text; CurrentBatchNumber: Integer; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; ReportWebhookRequest: Record "NPR AF Rec. Webhook Request") EntryAmount: Integer
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        LineNo: Integer;
    begin
        EntryAmount := 0;
        for LineNo := 2 to Temp_CSVBuffer.GetNumberOfLines() do begin
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

        ReconciliationLine.Modify();
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
        ReconciliationLine.Modify();
    end;

    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
        _GLSetup: Record "General Ledger Setup";
        _AdyenSetup: Record "NPR Adyen Setup";
        Temp_CSVBuffer: Record "CSV Buffer" temporary;
        _LogType: Enum "NPR Adyen Rec. Log Type";
        _CurrExchRate: Record "Currency Exchange Rate";
        GetWebhookError: Label 'Webhook request with ID %1 does not exist.';
        GetReportError01: Label 'Webhook request with ID %1 does not store any Report Data. Retrying download...';
        GetReportError02: Label 'Webhook request with ID %1 does not have a Report Download URL.\Please contact your System Administrator.';
        GetReportSuccess01: Label 'Report ''%1'' was successfully retrieved.';
        ImportLinesError01: Label 'Report ''%1'' has no entries. Report Data exist - %2';
        ImportLinesError02: Label 'Report ''%1'' has no transactions within Merchant Account ''%2''.';
        ImportLinesError03: Label 'Unsupported Journal Type: %1.\Entry was skipped.';
        ImportLinesSuccess01: Label 'Adyen Reconciliation Document %1 was successfully created with %2 transaction entries.';
        MatchTransactionsError01: Label 'Failed to match with EFT Transaction Request No. %1 because of one of the conditions:\\    Amounts are equal: %2\EFT Transaction Amount:%3, Reconciliation Line Transaction Amount:%4\\Financial Impact: %5';
        MatchTransactionsError02: Label 'Adyen Reconciliation Document %1 does not contain any transactions within Marchant Account ''%2''.';
        MatchTransactionsError03: Label 'Couldn''t match %1 entries in Adyen Reconciliation Document %2.';
        MatchTransactionsError04: Label 'Failed to match with Magento Payment Line (Document Type: %1, Document No.: %2, Document Line No.: %3).\\    Amounts are not equal:\Magento Payment Line Amount:%4, Reconciliation Line Transaction Amount:%5';
        MatchTransactionsError05: Label 'EFT Transaction Request was found, however the POS Entry Payment Line does not exist. Please check if the Sale is posted.';
        MatchTransactionsSuccess01: Label 'Successfully matched entries in Adyen Reconciliation Document %1.';
        PostTransactionsError01: Label 'Couldn''t find any matched transactions to post in Adyen Reconciliation Document %1.';
        PostTransactionsEFTError01: Label 'EFT Transaction Request %1 does not exist.';
        PostTransactionsMagentoError01: Label 'Magento Payment Line %1 does not exist.';
        PostTransactionsError03: Label 'Couldn''t post %1 entries in Adyen Reconciliation Document %2.';
        PostTransactionsError04: Label 'Transaction %1 is not matched yet.';
        PostTransactionsSuccess01: Label 'Successfully posted entries in Adyen Reconciliation Document %1.';
        NoSeriesError01: Label 'No. Series in Adyen Generic Setup is not specified.';
}

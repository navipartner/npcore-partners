codeunit 6184779 "NPR Adyen Trans. Matching"
{
    Access = Internal;

#IF NOT BC17
    procedure CreateSettlementDocuments(ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; RecreateExistingDocument: Boolean; ExistingDocumentNo: Code[20]) NewDocumentsList: List of [Code[20]]
#ELSE
    procedure CreateSettlementDocuments(ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; RecreateExistingDocument: Boolean; ExistingDocumentNo: Code[20]) NewDocumentsList: JsonArray
#ENDIF
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        JsonToken: JsonToken;
        MBCombination: JsonObject;
        MerchantBatchValues: List of [JsonObject];
        CurrentMerchantAccount: Text;
        CurrentBatchNumber: Integer;
        EntryAmount: Integer;
    begin
        if ReportWebhookRequest.ID = 0 then begin
            _AdyenManagement.CreateLog(_LogType::"Get Report", false, StrSubstNo(GetWebhookError, Format(ReportWebhookRequest.ID)), 0);
            exit;
        end;

        if not GetReportData(ReportWebhookRequest) then
            exit;

        CreateMerchantBatchListFromLines(MerchantBatchValues);

        foreach MBCombination in MerchantBatchValues do begin
            MBCombination.Get('Merchant Account', JsonToken);
            CurrentMerchantAccount := JsonToken.AsValue().AsText();
            if ReportWebhookRequest."Report Type" in [ReportWebhookRequest."Report Type"::"Settlement details"] then begin
                MBCombination.Get('Batch Number', JsonToken);
                CurrentBatchNumber := JsonToken.AsValue().AsInteger();
            end;

            if not InitReconciliationHeader(ReconciliationHeader, RecreateExistingDocument, CurrentBatchNumber, CurrentMerchantAccount, ExistingDocumentNo, ReportWebhookRequest) then
                exit;

            EntryAmount := InsertReconciliationLines(CurrentMerchantAccount, CurrentBatchNumber, ReconciliationHeader, ReportWebhookRequest);

            if (EntryAmount > 0) then begin
                _AdyenManagement.CreateLog(_LogType::"Import Lines", true, StrSubstNo(ImportLinesSuccess01, ReconciliationHeader."Document No.", Format(EntryAmount)), ReportWebhookRequest.ID);
                NewDocumentsList.Add(ReconciliationHeader."Document No.");
            end else
                _AdyenManagement.CreateLog(_LogType::"Import Lines", false, StrSubstNo(ImportLinesError02, ReportWebhookRequest."Report Name"), ReportWebhookRequest.ID);
        end;
        exit(NewDocumentsList);
    end;

    procedure MatchEntries(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer;
    var
        ReconciliationLine: Record "NPR Adyen Reconciliation Line";
        UnmatchedEntries: Integer;
        Handled: Boolean;
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.SetFilter(Status, '<>%1', ReconciliationLine.Status::Posted);
        if not ReconciliationLine.FindSet() then begin
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError02, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            exit(MatchedEntries);
        end;
        repeat
            Handled := false;
            if not Handled then begin
                case ReconciliationLine."Transaction Type" of
                    ReconciliationLine."Transaction Type"::Settled,
                    ReconciliationLine."Transaction Type"::SettledExternallyWithInfo,
                    ReconciliationLine."Transaction Type"::Refunded,
                    ReconciliationLine."Transaction Type"::RefundedExternallyWithInfo,
                    ReconciliationLine."Transaction Type"::Chargeback,
                    ReconciliationLine."Transaction Type"::SecondChargeback,
                    ReconciliationLine."Transaction Type"::ChargebackExternallyWithInfo:
                        begin
                            MatchedEntries += TryMatchingPayment(ReconciliationLine, UnmatchedEntries, ReconciliationHeader);
                        end;
                    ReconciliationLine."Transaction Type"::ChargebackReversed,
                    ReconciliationLine."Transaction Type"::RefundedReversed,
                    ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                        begin
                            MatchedEntries += TryMatchingReversedPayment(ReconciliationLine, UnmatchedEntries);
                        end;
                    ReconciliationLine."Transaction Type"::Fee,
                    ReconciliationLine."Transaction Type"::InvoiceDeduction,
                    ReconciliationLine."Transaction Type"::PaymentCost,
                    ReconciliationLine."Transaction Type"::MerchantPayout,
                    ReconciliationLine."Transaction Type"::AdvancementCommissionExternallyWithInfo,
                    ReconciliationLine."Transaction Type"::RefundedInstallmentExternallyWithInfo,
                    ReconciliationLine."Transaction Type"::SettledInstallmentExternallyWithInfo:
                        begin
                            MatchedEntries += TryMatchingAdjustments(ReconciliationLine, UnmatchedEntries, ReconciliationHeader);
                        end;
                end;
                ReconciliationLine.Modify();
            end;
        until ReconciliationLine.Next() = 0;
        if UnmatchedEntries > 0 then
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError03, Format(UnmatchedEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID")
        else
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", true, StrSubstNo(MatchTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
        exit(MatchedEntries);
    end;

    procedure ReconcileEntries(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") Success: Boolean;
    var
        ReconciliationLine: Record "NPR Adyen Reconciliation Line";
        UnReconciledEntries: Integer;
        Handled: Boolean;
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.SetFilter(Status, '=%1|%2', ReconciliationLine."Status"::Matched, ReconciliationLine.Status::"Matched Manually");
        if ReconciliationLine.IsEmpty() then begin
            _AdyenManagement.CreateLog(_LogType::"Reconcile Transactions", false, StrSubstNo(ReconcileTransactionsError01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            exit(false);
        end;
        ReconciliationLine.SetRange(Status);
        ReconciliationLine.FindSet(true);
        repeat
            Handled := false;
            if not Handled then begin
                case ReconciliationLine."Matching Table Name" of
                    ReconciliationLine."Matching Table Name"::"EFT Transaction":
                        begin
                            UnReconciledEntries += TryReconcilingEFT(ReconciliationLine, ReconciliationHeader);
                        end;
                    ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                        begin
                            UnReconciledEntries += TryReconcilingMagento(ReconciliationLine, ReconciliationHeader);
                        end;
                    ReconciliationLine."Matching Table Name"::"To Be Determined":
                        begin
                            UnReconciledEntries += 1;
                        end;
                end;
            end;
        until ReconciliationLine.Next() = 0;
        if UnReconciledEntries > 0 then begin
            _AdyenManagement.CreateLog(_LogType::"Reconcile Transactions", false, StrSubstNo(ReconcileTransactionsError03, Format(UnReconciledEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            exit(false);
        end;
        _AdyenManagement.CreateLog(_LogType::"Reconcile Transactions", true, StrSubstNo(ReconcileTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
        ReconciliationHeader.Modify();
        exit(true);
    end;

    procedure PostEntries(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") Success: Boolean;
    var
        ReconciliationLine: Record "NPR Adyen Reconciliation Line";
        UnPostedEntries: Integer;
        Handled: Boolean;
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.SetRange(Status, ReconciliationLine."Status"::Reconciled);
        if ReconciliationLine.IsEmpty() then begin
            _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            exit(false);
        end;
        ReconciliationLine.SetRange(Status);
        ReconciliationLine.FindSet();
        repeat
            Handled := false;
            if not Handled then begin
                case ReconciliationLine."Matching Table Name" of
                    ReconciliationLine."Matching Table Name"::"EFT Transaction":
                        begin
                            UnPostedEntries += TryPostingEFT(ReconciliationLine, ReconciliationHeader);
                        end;
                    ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                        begin
                            // UnPostedEntries += TryPostingMagento(ReconciliationLine, ReconciliationHeader);
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
                Commit();
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

    procedure ValidateReportScheme(WebhookRequest: Record "NPR AF Rec. Webhook Request"): Boolean
    var
        SchemeValid: Boolean;
        SchemeValidationField: Text;
        i: Integer;
        SchemeColumnNumber: Integer;
        InvalidSchemeError: Label 'Validation Scheme Failed: Report did not meet validation criteria! Column ''%1'' does not exist or has an incorrect placement! Please check report''s configuration!';
        ValidSchemeText: Label 'Validation Success: Report passed all validation criteria!';
        Scheme: array[50] of Text[35];
    begin
        if WebhookRequest.ID = 0 then begin
            _AdyenManagement.CreateLog(_LogType::"Get Report", false, StrSubstNo(GetWebhookError, Format(WebhookRequest.ID)), 0);
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
        NoSeriesMgt: Codeunit NoSeriesManagement;
        AdyenGenericSetup: Record "NPR Adyen Setup";
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
            if ReconciliationHeader.FindSet(true) then begin
                ReconciliationHeader.DeleteAll();
                DeleteReconciliationLines(CurrentBatchNumber, CurrentMerchantAccount);
            end;
            ReconciliationHeader.Init();

            ReconciliationHeader."Document No." := NoSeriesMgt.GetNextNo(AdyenGenericSetup."Reconciliation Document Nos.", Today(), true);
            ReconciliationHeader."Document Date" := Today();
            ReconciliationHeader.Insert();
        end else begin
            DeleteReconciliationLines(CurrentBatchNumber, CurrentMerchantAccount);
            ReconciliationHeader.Get(ExistingDocumentNo);
            ReconciliationHeader.Posted := false;
            ReconciliationHeader."Document Date" := Today();
        end;
        ReconciliationHeader."Document Type" := WebhookRequest."Report Type";
        ReconciliationHeader."Webhook Request ID" := WebhookRequest.ID;
        ReconciliationHeader."Batch Number" := CurrentBatchNumber;
        ReconciliationHeader."Merchant Account" := CopyStr(CurrentMerchantAccount, 1, MaxStrLen(ReconciliationHeader."Merchant Account"));
        ReconciliationHeader.Modify();
        exit(true);
    end;

    local procedure InitReconciliationLine(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; var ReconciliationLine: Record "NPR Adyen Reconciliation Line")
    var
        xReconciliationLine: Record "NPR Adyen Reconciliation Line";
    begin
        xReconciliationLine.SetCurrentKey("Line No.");
        xReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.Init();
        ReconciliationLine."Document No." := ReconciliationHeader."Document No.";
        ReconciliationLine."Line No." := 10000;
        if xReconciliationLine.FindLast() then
            ReconciliationLine."Line No." += xReconciliationLine."Line No.";
    end;

    local procedure CalculateRealizedGL(var ReconciliationLine: Record "NPR Adyen Reconciliation Line") RealizedGLAmount: Decimal
    var
        AmountLCY: Decimal;
        GrossCreditAAC: Decimal;
        GrossCreditLCY: Decimal;
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        AmountLCY := Round(CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Transaction Currency Code", ReconciliationLine."Amount (TCY)", CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Transaction Currency Code")));
        if AmountLCY = 0 then
            AmountLCY := ReconciliationLine."Amount (TCY)";

        GrossCreditAAC := ReconciliationLine."Gross Credit" * ReconciliationLine."Exchange Rate";

        GrossCreditLCY := Round(CurrExchRate.ExchangeAmtFCYToLCY(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code", GrossCreditAAC, CurrExchRate.ExchangeRate(DT2Date(ReconciliationLine."Transaction Date"), ReconciliationLine."Adyen Acc. Currency Code")));

        if GrossCreditLCY = 0 then
            GrossCreditLCY := GrossCreditAAC;

        RealizedGLAmount := Round(AmountLCY - GrossCreditLCY, 0.01);
    end;

    local procedure InsertReconciliationLine(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; BatchNumber: Integer; MerchantAccount: Text; ReportWebhookRequest: Record "NPR AF Rec. Webhook Request"; LineNo: Integer; var EntryAmount: Integer): Boolean
    begin
        InitReconciliationLine(ReconciliationHeader, ReconciliationLine);
        ReconciliationLine."Merchant Order Reference" := CopyStr(GetValueAtCell(LineNo, 24), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
        ReconciliationLine."Batch Number" := BatchNumber;

        ReconciliationLine."Company Account" := CopyStr(GetValueAtCell(LineNo, 1), 1, MaxStrLen(ReconciliationLine."Company Account"));
        ReconciliationLine."Merchant Account" := CopyStr(MerchantAccount, 1, MaxStrLen(ReconciliationLine."Merchant Account"));
        ReconciliationLine."PSP Reference" := CopyStr(GetValueAtCell(LineNo, 3), 1, MaxStrLen(ReconciliationLine."PSP Reference"));
        ReconciliationLine."Merchant Reference" := CopyStr(GetValueAtCell(LineNo, 4), 1, MaxStrLen(ReconciliationLine."Merchant Reference"));
        if Evaluate(ReconciliationLine."Transaction Date", GetValueAtCell(LineNo, 6)) then;
        ReconciliationLine."Modification Reference" := CopyStr(GetValueAtCell(LineNo, 9), 1, MaxStrLen(ReconciliationLine."Modification Reference"));
        ReconciliationLine."Transaction Currency Code" := CopyStr(GetValueAtCell(LineNo, 10), 1, MaxStrLen(ReconciliationLine."Transaction Currency Code"));
        if Evaluate(ReconciliationLine."Gross Debit", GetValueAtCell(LineNo, 11)) then
            ReconciliationLine.Validate("Gross Debit");
        if Evaluate(ReconciliationLine."Gross Credit", GetValueAtCell(LineNo, 12)) then
            ReconciliationLine.Validate("Gross Credit");
        if Evaluate(ReconciliationLine."Exchange Rate", GetValueAtCell(LineNo, 13)) then;
        ReconciliationLine."Adyen Acc. Currency Code" := CopyStr(GetValueAtCell(LineNo, 14), 1, MaxStrLen(ReconciliationLine."Adyen Acc. Currency Code"));
        ReconciliationHeader."Adyen Acc. Currency Code" := ReconciliationLine."Adyen Acc. Currency Code";
        if Evaluate(ReconciliationLine."Net Debit", GetValueAtCell(LineNo, 15)) then
            ReconciliationLine.Validate("Net Debit");
        if Evaluate(ReconciliationLine."Net Credit", GetValueAtCell(LineNo, 16)) then
            ReconciliationLine.Validate("Net Credit");
        if Evaluate(ReconciliationLine."Commission (NC)", GetValueAtCell(LineNo, 17)) then;
        if Evaluate(ReconciliationLine."Markup (NC)", GetValueAtCell(LineNo, 18)) then;
        if Evaluate(ReconciliationLine."Scheme Fees (NC)", GetValueAtCell(LineNo, 25)) then;
        if Evaluate(ReconciliationLine."Intercharge (NC)", GetValueAtCell(LineNo, 26)) then;
        if Evaluate(ReconciliationLine."Payment Fees (NC)", GetValueAtCell(LineNo, 27)) then;
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
        EntryAmount += 1;
        ReconciliationHeader.Modify();
        if (ReconciliationLine."Adyen Acc. Currency Code" <> ReconciliationLine."Transaction Currency Code") and
            (ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Settled,
            ReconciliationLine."Transaction Type"::Refunded,
            ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SettledExternallyWithInfo,
            ReconciliationLine."Transaction Type"::RefundedExternallyWithInfo,
            ReconciliationLine."Transaction Type"::ChargebackExternallyWithInfo])
        then begin
            ReconciliationLine."Realized Gains or Losses" := CalculateRealizedGL(ReconciliationLine);
            ReconciliationLine.Modify();
        end;
    end;

    local procedure DeleteReconciliationLines(CurrentBatchNumber: Integer; CurrentMerchantAccount: Text)
    var
        ReconciliationLine: Record "NPR Adyen Reconciliation Line";
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Batch Number", CurrentBatchNumber);
        ReconciliationLine.SetRange("Merchant Account", CurrentMerchantAccount);
        if ReconciliationLine.FindSet(true) then
            ReconciliationLine.DeleteAll();
    end;

    local procedure TryMatchingPayment(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; var UnmatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer
    begin
        if ReconciliationLine."PSP Reference" = '' then begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
            exit;
        end;
        if TryMatchingPaymentWithEFT(ReconciliationLine, UnmatchedEntries, MatchedEntries, ReconciliationHeader) then
            exit;
        if TryMatchingPaymentWithMagento(ReconciliationLine, UnmatchedEntries, MatchedEntries, ReconciliationHeader) then
            exit;
        ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
        UnmatchedEntries += 1;
    end;

    local procedure TryMatchingPaymentWithEFT(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; var UnmatchedEntries: Integer; var MatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Reset();
        EFTTransactionRequest.SetRange("PSP Reference", ReconciliationLine."PSP Reference");
        EFTTransactionRequest.SetRange(EFTTransactionRequest.Reconciled, false);
        if not EFTTransactionRequest.FindFirst() then
            exit;

        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"EFT Transaction";
        ReconciliationLine."Matching Entry System ID" := EFTTransactionRequest.SystemId;
        if (EFTTransactionRequest."Result Amount" = ReconciliationLine."Amount (TCY)")
            and EFTTransactionRequest."Financial Impact"
        then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            MatchedEntries += 1;
        end else begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
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

    local procedure TryMatchingPaymentWithMagento(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; var UnmatchedEntries: Integer; var MatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("Transaction ID", ReconciliationLine."PSP Reference");
        if not MagentoPaymentLine.FindFirst() then
            exit;

        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"Magento Payment Line";
        // Matching Entry?
        if (MagentoPaymentLine.Amount = ReconciliationLine."Amount (TCY)") then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            MatchedEntries += 1;
        end else begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
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

    local procedure TryMatchingReversedPayment(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; var UnmatchedEntries: Integer) MatchedEntries: Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        if ReconciliationLine."PSP Reference" = '' then begin
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
            exit;
        end;

        EFTTransactionRequest.Reset();
        EFTTransactionRequest.SetRange("PSP Reference", ReconciliationLine."PSP Reference");
        if EFTTransactionRequest.FindFirst() then begin
            ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"EFT Transaction";
            ReconciliationLine."Matching Entry System ID" := EFTTransactionRequest.SystemId;
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            MatchedEntries += 1;
        end else begin
            MagentoPaymentLine.Reset();
            MagentoPaymentLine.SetRange("Transaction ID", ReconciliationLine."PSP Reference");
            if MagentoPaymentLine.FindFirst() then begin
                ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"Magento Payment Line";
                // Matching Entry?
                ReconciliationLine.Status := ReconciliationLine.Status::Matched;
                MatchedEntries += 1;
            end else begin
                ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
                UnmatchedEntries += 1;
            end;
        end;
        exit(MatchedEntries);
    end;

    local procedure TryMatchingAdjustments(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; var UnmatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer
    var
        FeeCreatePost: Codeunit "NPR Adyen Fee Posting";
        RecordPrepared: Boolean;
        GLAccountType: Enum "NPR Adyen Posting GL Accounts";
        GLEntry: Record "G/L Entry";
    begin
        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"G/L Entry";
        RecordPrepared := false;
        case ReconciliationLine."Transaction Type" of
            ReconciliationLine."Transaction Type"::Fee:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, GLAccountType::"Fee G/L Account");
            ReconciliationLine."Transaction Type"::InvoiceDeduction:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, GLAccountType::"Invoice Deduction G/L Account");
            ReconciliationLine."Transaction Type"::PaymentCost:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, GLAccountType::"Chargeback Fees G/L Account");
            ReconciliationLine."Transaction Type"::MerchantPayout:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, GLAccountType::"Merchant Payout G/L Account");
            ReconciliationLine."Transaction Type"::AdvancementCommissionExternallyWithInfo:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, GLAccountType::"Advancement External Commission G/L Account");
            ReconciliationLine."Transaction Type"::RefundedInstallmentExternallyWithInfo:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, GLAccountType::"Refunded External Commission G/L Account");
            ReconciliationLine."Transaction Type"::SettledInstallmentExternallyWithInfo:
                RecordPrepared := FeeCreatePost.PrepareRecords(ReconciliationLine, GLAccountType::"Settled External Commission G/L Account");
        end;
        if RecordPrepared then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Reconciled;
            if FeeCreatePost.GLEntryExists(GLEntry, ReconciliationLine) then begin
                ReconciliationLine."Matching Entry System ID" := GLEntry.SystemId;
                ReconciliationLine.Status := ReconciliationLine.Status::Posted;
            end;
            MatchedEntries += 1;
        end else begin
            _AdyenManagement.CreateLog(_LogType::"Match Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            UnmatchedEntries += 1;
        end;
    end;

    local procedure TryReconcilingEFT(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnReconciledEntries: Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        ReverseEFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSPaymentLine: Record "NPR POS Entry Payment Line";
        ReversePOSPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        case ReconciliationLine."Transaction Type" of
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                begin
                    EFTTransactionRequest.Reset();
                    EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID");
                    ReverseEFTTransactionRequest := EFTTransactionRequest;
                    ReverseEFTTransactionRequest."Entry No." := 0;
                    ReverseEFTTransactionRequest."Result Amount" *= -1;
                    ReverseEFTTransactionRequest."Amount Input" *= -1;
                    ReverseEFTTransactionRequest."Amount Output" *= -1;
                    case ReconciliationLine."Transaction Type" of
                        ReconciliationLine."Transaction Type"::RefundedReversed:
                            ReverseEFTTransactionRequest."Auxiliary Operation Desc." := 'Adyen: Refunded Reversed';
                        ReconciliationLine."Transaction Type"::ChargebackReversed:
                            ReverseEFTTransactionRequest."Auxiliary Operation Desc." := 'Adyen: Chargeback Reversed';
                        ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                            ReverseEFTTransactionRequest."Auxiliary Operation Desc." := 'Adyen: External Chargeback Reversed';
                    end;
                    ReverseEFTTransactionRequest.Insert();
                    EFTTransactionRequest."Reversed by Entry No." := ReverseEFTTransactionRequest."Entry No.";
                    EFTTransactionRequest.Modify();

                    POSPaymentLine.Reset();
                    POSPaymentLine.SetRange("Document No.", EFTTransactionRequest."Sales Ticket No.");
                    POSPaymentLine.SetRange("Line No.", EFTTransactionRequest."Sales Line No.");
                    POSPaymentLine.SetRange(Amount, EFTTransactionRequest."Result Amount");
                    if POSPaymentLine.FindFirst() then begin
                        ReversePOSPaymentLine := POSPaymentLine;
                        POSPaymentLine.Reset();
                        POSPaymentLine.SetRange("Document No.", EFTTransactionRequest."Sales Ticket No.");
                        if POSPaymentLine.FindLast() then
                            ReversePOSPaymentLine."Line No." := POSPaymentLine."Line No." + 10000
                        else
                            _AdyenManagement.CreateLog(_LogType::"Reconcile Transactions", false, StrSubstNo(PostRefundError06, Format(EFTTransactionRequest."Sales Ticket No."), Format(EFTTransactionRequest."Sales Line No.")), ReconciliationHeader."Webhook Request ID");
                        ReversePOSPaymentLine.Amount *= -1;
                        ReversePOSPaymentLine."Amount (LCY)" *= -1;
                        ReversePOSPaymentLine."Payment Amount" *= -1;
                        ReversePOSPaymentLine."Amount (Sales Currency)" *= -1;
                        ReversePOSPaymentLine."VAT Base Amount (LCY)" *= -1;
                        ReversePOSPaymentLine.Insert();
                    end else
                        _AdyenManagement.CreateLog(_LogType::"Reconcile Transactions", false, StrSubstNo(PostRefundError06, Format(EFTTransactionRequest."Sales Ticket No."), Format(EFTTransactionRequest."Sales Line No.")), ReconciliationHeader."Webhook Request ID");
                end;
        end;
        if not EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
            _AdyenManagement.CreateLog(_LogType::"Reconcile Transactions", false, StrSubstNo(ReconcileTransactionsError02, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
            UnReconciledEntries += 1;
        end else begin
            ReconciliationLine.Status := ReconciliationLine.Status::Reconciled;
            ReconciliationLine.Modify();
        end;
    end;

    local procedure TryReconcilingMagento(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnReconciledEntries: Integer
    var
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        case ReconciliationLine."Transaction Type" of
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                begin
                    // Is it possible?
                end;
        end;
        MagentoPaymentLine.Reset();
        MagentoPaymentLine.SetRange("Transaction ID", ReconciliationLine."PSP Reference");
        if not MagentoPaymentLine.FindFirst() then begin
            _AdyenManagement.CreateLog(_LogType::"Reconcile Transactions", false, StrSubstNo(ReconcileTransactionsError04, ReconciliationLine."PSP Reference"), ReconciliationHeader."Webhook Request ID");
            UnReconciledEntries += 1;
        end else begin
            ReconciliationLine.Status := ReconciliationLine.Status::Reconciled;
            ReconciliationLine.Modify();
        end;
    end;

    local procedure TryPostingEFT(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnPostedEntries: Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PostEFTTransaction: Codeunit "NPR Adyen EFT Trans. Posting";
    begin
        if not EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
            _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError02, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
            UnPostedEntries += 1;
            exit(UnPostedEntries);
        end;

        if not (ReconciliationLine.Status = ReconciliationLine.Status::Reconciled) then begin
            _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError05, Format(EFTTransactionRequest."Entry No.")), ReconciliationHeader."Webhook Request ID");
            UnPostedEntries += 1;
            exit(UnPostedEntries);
        end;

        if ReconciliationLine."Transaction Type" <> ReconciliationLine."Transaction Type"::SecondChargeback then begin
            if PostEFTTransaction.PrepareRecords(ReconciliationLine) then begin
                if not PostEFTTransaction.LineIsPosted(ReconciliationLine) then begin
                    Commit();
                    if not PostEFTTransaction.Run() then begin
                        _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                        UnPostedEntries += 1;
                        exit(UnPostedEntries);
                    end;
                end;
                ReconciliationLine.Status := ReconciliationLine.Status::Posted;
                EFTTransactionRequest.Reconciled := true;
                EFTTransactionRequest."Reconciliation Date" := Today();
                EFTTransactionRequest.Modify();
            end else begin
                _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                UnPostedEntries += 1;
            end;
        end else
            ReconciliationLine.Status := ReconciliationLine.Status::"Not to be Posted";
    end;

    /* // Post Magento?
    local procedure TryPostingMagento(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnPostedEntries: Integer
    var

    begin

    end;
    */

    local procedure TryPostingAdjustments(var ReconciliationLine: Record "NPR Adyen Reconciliation Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnPostedEntries: Integer
    var
        FeeCreateAndPost: Codeunit "NPR Adyen Fee Posting";
        GLAccountType: Enum "NPR Adyen Posting GL Accounts";
        GLEntry: Record "G/L Entry";
        GLEntryNo: Integer;
    begin
        if not IsNullGuid(ReconciliationLine."Matching Entry System ID") then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Posted;
            exit(UnPostedEntries);
        end;
        case ReconciliationLine."Transaction Type" of
            ReconciliationLine."Transaction Type"::Fee:
                FeeCreateAndPost.PrepareRecords(ReconciliationLine, GLAccountType::"Fee G/L Account");
            ReconciliationLine."Transaction Type"::InvoiceDeduction:
                FeeCreateAndPost.PrepareRecords(ReconciliationLine, GLAccountType::"Invoice Deduction G/L Account");
            ReconciliationLine."Transaction Type"::PaymentCost:
                FeeCreateAndPost.PrepareRecords(ReconciliationLine, GLAccountType::"Chargeback Fees G/L Account");
            ReconciliationLine."Transaction Type"::MerchantPayout:
                FeeCreateAndPost.PrepareRecords(ReconciliationLine, GLAccountType::"Merchant Payout G/L Account");
            ReconciliationLine."Transaction Type"::AdvancementCommissionExternallyWithInfo:
                FeeCreateAndPost.PrepareRecords(ReconciliationLine, GLAccountType::"Advancement External Commission G/L Account");
            ReconciliationLine."Transaction Type"::RefundedInstallmentExternallyWithInfo:
                FeeCreateAndPost.PrepareRecords(ReconciliationLine, GLAccountType::"Refunded External Commission G/L Account");
            ReconciliationLine."Transaction Type"::SettledInstallmentExternallyWithInfo:
                FeeCreateAndPost.PrepareRecords(ReconciliationLine, GLAccountType::"Settled External Commission G/L Account");
        end;
        if not FeeCreateAndPost.GLEntryExists(GLEntry, ReconciliationLine) then begin
            Commit();
            if not FeeCreateAndPost.Run() then begin
                UnPostedEntries += 1;
                _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                exit(UnPostedEntries);
            end;

            GLEntryNo := FeeCreateAndPost.GetGlEntryNo();
            if GLEntry.Get(GLEntryNo) then begin
                ReconciliationLine."Matching Entry System ID" := GLEntry.SystemId;
                ReconciliationLine.Status := ReconciliationLine.Status::Posted;
            end else begin
                UnPostedEntries += 1;
                _AdyenManagement.CreateLog(_LogType::"Post Transactions", false, PostFeeError01 + ' ' + GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
            end;
        end else begin
            if GLEntry.Get(FeeCreateAndPost.GetGlEntryNo()) then begin
                ReconciliationLine."Matching Entry System ID" := GLEntry.SystemId;
                ReconciliationLine.Status := ReconciliationLine.Status::Posted;
            end;
        end;
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
            if Evaluate(FromBalance, GetValueAtCell(LineNo, 16)) then;
            ReconciliationHeader."Opening Balance" += FromBalance; // Might close multiple batches
        end else
            if GetValueAtCell(LineNo, 20).Contains('to') then begin
                if Evaluate(ToBalance, GetValueAtCell(LineNo, 15)) then;
                ReconciliationHeader."Closing Balance" += ToBalance; // Probably always is a single closing balance entry
            end;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertAcquirerPayout(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; LineNo: Integer)
    begin
        if Evaluate(ReconciliationHeader."Closing Balance", GetValueAtCell(LineNo, 15)) then;
        if Evaluate(ReconciliationHeader."Acquirer Commission", GetValueAtCell(LineNo, 17)) then;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertReconciliationLines(CurrentMerchantAccount: Text; CurrentBatchNumber: Integer; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; ReportWebhookRequest: Record "NPR AF Rec. Webhook Request") EntryAmount: Integer
    var
        ReconciliationLine: Record "NPR Adyen Reconciliation Line";
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
                        'AcquirerPayout':
                            InsertAcquirerPayout(ReconciliationHeader, LineNo);
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

    var
        _AdyenManagement: Codeunit "NPR Adyen Management";
        Temp_CSVBuffer: Record "CSV Buffer" temporary;
        _LogType: Enum "NPR Adyen Rec. Log Type";
        GetWebhookError: Label 'Webhook request with ID %1 does not exist!';
        GetReportError01: Label 'Webhook request with ID %1 does not store any Report Data! Retrying download...';
        GetReportError02: Label 'Webhook request with ID %1 does not have a Report Download URL!\Please contact your System Administrator!';
        GetReportSuccess01: Label 'Report ''%1'' was successfully retrieved!';
        ImportLinesError01: Label 'Report ''%1'' has no entries! Report Data exist - %2';
        ImportLinesError02: Label 'Report ''%1'' has no transactions!';
        ImportLinesError03: Label 'Unsupported Journal Type: %1.\Entry was skipped.';
        ImportLinesSuccess01: Label 'Adyen Reconciliation Document %1 was successfully created with %2 transaction entries!';
        MatchTransactionsError01: Label 'Failed to match with EFT Transaction Request No. %1 because of one of the conditions:\\    Amounts are equal: %2\EFT Transaction Amount:%3, Reconciliation Line Transaction Amount:%4\\Financial Impact: %5';
        MatchTransactionsError02: Label 'Adyen Reconciliation Document %1 does not contain any transaction!';
        MatchTransactionsError03: Label 'Couldn''t match %1 entries in Adyen Reconciliation Document %2!';
        MatchTransactionsError04: Label 'Failed to match with Magento Payment Line (Document Type: %1, Document No.: %2, Document Line No.: %3)!\\    Amounts are not equal:\Magento Payment Line Amount:%4, Reconciliation Line Transaction Amount:%5';
        MatchTransactionsSuccess01: Label 'Successfully matched entries in Adyen Reconciliation Document %1!';
        ReconcileTransactionsError01: Label 'Couldn''t find any matched transaction in Adyen Reconciliation Document %1!';
        ReconcileTransactionsError02: Label 'EFT Transaction Request %1 does not exist!';
        ReconcileTransactionsError03: Label 'Couldn''t reconcile %1 entries in Adyen Reconciliation Document %2!';
        ReconcileTransactionsError04: Label 'Magento Payment Line with Transaction ID ''%1'' does not exist!';
        ReconcileTransactionsSuccess01: Label 'Successfully reconciled entries in Adyen Reconciliation Document %1!';
        PostTransactionsError01: Label 'Couldn''t find any reconciled transactions to post in Adyen Reconciliation Document %1!';
        PostTransactionsError02: Label 'EFT Transaction Request No. %1 does not exist!';
        PostTransactionsError03: Label 'Couldn''t post %1 entries in Adyen Reconciliation Document %2!';
        PostTransactionsError05: Label 'EFT Transaction Request No. %1 is not reconciled yet!';
        PostRefundError06: Label 'Could not find a POS Entry Payment Line for a Refund (Document No. - %1, Line No. - %2)!';
        PostTransactionsSuccess01: Label 'Successfully posted entries in Adyen Reconciliation Document %1!';
        PostFeeError01: Label 'Could not post General Journal Line!';
        NoSeriesError01: Label 'No. Series in Adyen Generic Setup is not specified!';
}

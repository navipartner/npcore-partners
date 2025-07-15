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
    begin
        ReportWebhookRequest.TestField(ID);
        _GLSetup.Get();
        _GLSetup.TestField("LCY Code");
        _AdyenSetup.Get();

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

        if RecHeader.Status = RecHeader.Status::Posted then
            Error(DocumentIsPostedLbl, RecHeader."Document No.");

        RecLine.Reset();
        RecLine.SetRange("Document No.", RecHeader."Document No.");
        RecLine.SetFilter(Status, '<>%1', RecLine.Status::Posted);
        if RecLine.IsEmpty() then
            Error(NoUnpostedEntriesLbl, RecHeader."Document No.");

        if not WebhookRequest.Get(RecHeader."Webhook Request ID") then
            Error(WebhookRequestDoesNotExistLbl, Format(RecHeader."Webhook Request ID"));

        if not RecLine.IsEmpty() then
            RecLine.DeleteAll(true);

        GetReportData(WebhookRequest, true);
        InsertedEntryAmount := InsertReconciliationLines(RecHeader."Merchant Account", RecHeader."Batch Number", RecHeader, WebhookRequest);

        if (InsertedEntryAmount > 0) and (RecHeader.Status <> RecHeader.Status::Unmatched) then begin
            RecHeader.Status := RecHeader.Status::Unmatched;
            RecHeader.Modify();
        end;

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
            if ReconciliationHeader."Document No." = '' then begin
                _AdyenManagement.CreateReconciliationLog(_LogType::"Import Lines", false, StrSubstNo(NoSeriesError02, AdyenGenericSetup."Reconciliation Document Nos."), WebhookRequest.ID);
                exit(false);
            end;
            ReconciliationHeader."Document Date" := Today();
            ReconciliationHeader."Posting Date" := Today();
            ReconciliationHeader.Insert();
        end else begin
            ReconciliationHeader.Get(ExistingDocumentNo);
            if ReconciliationHeader.Status = ReconciliationHeader.Status::Posted then
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
    var
        TypeHelper: Codeunit "Type Helper";
        UTCOffset: Integer;
        UserTimeZoneOffset: Duration;
    begin
        InitReconciliationLine(ReconciliationHeader, ReconciliationLine);
        if ReconciliationHeader."Document Type" = ReconciliationHeader."Document Type"::"Settlement details" then
            if Evaluate(ReconciliationLine."Payment Fees (NC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Payment Fees (NC)"), ReportWebhookRequest."Report Type")), 9) then;

        ReconciliationLine."Merchant Order Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Merchant Order Reference"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
        if Evaluate(ReconciliationLine."Scheme Fees (NC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Scheme Fees (NC)"), ReportWebhookRequest."Report Type")), 9) then;
        if Evaluate(ReconciliationLine."Interchange (NC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Interchange (NC)"), ReportWebhookRequest."Report Type")), 9) then;

        ReconciliationLine."Batch Number" := BatchNumber;

        ReconciliationLine."Company Account" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Company Account"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Company Account"));

        ReconciliationLine."Merchant Account" := CopyStr(MerchantAccount, 1, MaxStrLen(ReconciliationLine."Merchant Account"));
        ReconciliationLine."PSP Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex('Psp Reference', ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."PSP Reference"));
        ReconciliationLine."Merchant Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Merchant Reference"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Merchant Reference"));
        ReconciliationLine."Payment Method" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Payment Method"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Payment Method"));

        case ReportWebhookRequest."Report Type" of
            ReportWebhookRequest."Report Type"::"Settlement details":
                begin
                    if Evaluate(ReconciliationLine."Transaction Date", GetValueAtCell(LineNo, GetColumnIndex('Creation Date (AMS)', ReportWebhookRequest."Report Type"))) then begin
                        // AMS to UTC
                        UTCOffset := -CalculateAmsterdamToUTCOffset(ReconciliationLine."Transaction Date");
                        if not TypeHelper.GetUserTimezoneOffset(UserTimeZoneOffset) then
                            UserTimeZoneOffset := 0;
                        // UTC to Local
                        ReconciliationLine."Transaction Date" := TypeHelper.AddHoursToDateTime(ReconciliationLine."Transaction Date", UTCOffset) + UserTimeZoneOffset;
                    end;
                end;
            ReportWebhookRequest."Report Type"::"External Settlement detail (C)":
                begin
                    if Evaluate(ReconciliationLine."Transaction Date", GetValueAtCell(LineNo, GetColumnIndex('Creation Date', ReportWebhookRequest."Report Type"))) then begin
                        if not TypeHelper.GetUserTimezoneOffset(UserTimeZoneOffset) then
                            UserTimeZoneOffset := 0;
                        // UTC to Local
                        ReconciliationLine."Transaction Date" := ReconciliationLine."Transaction Date" + UserTimeZoneOffset;
                        // It is assumed that External Settlement Detail report's "Creation Date" is UTC
                    end;
                end;
        end;

        if ReconciliationHeader."Transactions Date" = 0D then begin
            ReconciliationHeader."Transactions Date" := DT2Date(ReconciliationLine."Transaction Date");
            ReconciliationHeader.Modify();
        end;

        ReconciliationLine."Modification Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Modification Reference"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Modification Reference"));
        ReconciliationLine."Transaction Currency Code" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex('Gross Currency', ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Transaction Currency Code"));

        if Evaluate(ReconciliationLine."Exchange Rate", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Exchange Rate"), ReportWebhookRequest."Report Type")), 9) then;
        ReconciliationLine."Adyen Acc. Currency Code" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex('Net Currency', ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Adyen Acc. Currency Code"));
        ReconciliationHeader."Adyen Acc. Currency Code" := ReconciliationLine."Adyen Acc. Currency Code";

        if Evaluate(ReconciliationLine."Commission (NC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Commission (NC)"), ReportWebhookRequest."Report Type")), 9) then;
        if Evaluate(ReconciliationLine."Markup (NC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Markup (NC)"), ReportWebhookRequest."Report Type")), 9) then;

        ReconciliationLine."Payment Method Variant" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Payment Method Variant"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Payment Method Variant"));

        if Evaluate(ReconciliationLine."Gross Debit", GetValueAtCell(LineNo, GetColumnIndex('Gross Debit (GC)', ReportWebhookRequest."Report Type")), 9) then
            ReconciliationLine.Validate("Gross Debit");
        if Evaluate(ReconciliationLine."Gross Credit", GetValueAtCell(LineNo, GetColumnIndex('Gross Credit (GC)', ReportWebhookRequest."Report Type")), 9) then
            ReconciliationLine.Validate("Gross Credit");
        if Evaluate(ReconciliationLine."Net Debit", GetValueAtCell(LineNo, GetColumnIndex('Net Debit (NC)', ReportWebhookRequest."Report Type")), 9) then
            ReconciliationLine.Validate("Net Debit");
        if Evaluate(ReconciliationLine."Net Credit", GetValueAtCell(LineNo, GetColumnIndex('Net Credit (NC)', ReportWebhookRequest."Report Type")), 9) then
            ReconciliationLine.Validate("Net Credit");

        ReconciliationLine."Other Commissions (NC)" := ReconciliationLine."Payment Fees (NC)" - ReconciliationLine."Markup (NC)";

        ReconciliationLine."Modif. Merchant Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex('Modification Merchant Reference', ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Modif. Merchant Reference"));
        if Evaluate(ReconciliationLine."Authorised Date", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Authorised Date"), ReportWebhookRequest."Report Type"))) then;
        ReconciliationLine."Authorised Date TimeZone" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Authorised Date TimeZone"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Authorised Date TimeZone"));
        ReconciliationLine."Balance Currency Code" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Balance Currency Code"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Balance Currency Code"));
        if Evaluate(ReconciliationLine."Net Debit (BC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Net Debit (BC)"), ReportWebhookRequest."Report Type"))) then;
        if Evaluate(ReconciliationLine."Net Credit (BC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Net Credit (BC)"), ReportWebhookRequest."Report Type"))) then;
        if Evaluate(ReconciliationLine."DCC Markup (NC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("DCC Markup (NC)"), ReportWebhookRequest."Report Type"))) then;
        ReconciliationLine."Global Card Brand" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Global Card Brand"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Global Card Brand"));
        if Evaluate(ReconciliationLine."Gratuity Amount", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Gratuity Amount"), ReportWebhookRequest."Report Type"))) then;
        if Evaluate(ReconciliationLine."Surcharge Amount", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Surcharge Amount"), ReportWebhookRequest."Report Type"))) then;
        if Evaluate(ReconciliationLine."Advanced (NC)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Advanced (NC)"), ReportWebhookRequest."Report Type"))) then;
        ReconciliationLine."Advancement Code" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Advancement Code"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Advancement Code"));
        ReconciliationLine."Advancement Batch" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Advancement Batch"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Advancement Batch"));
        ReconciliationLine."Booking Type" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Booking Type"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Booking Type"));
        ReconciliationLine.Acquirer := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName(Acquirer), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine.Acquirer));
        ReconciliationLine."Split Settlement" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Split Settlement"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Split Settlement"));
        ReconciliationLine."Split Payment Data" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Split Payment Data"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Split Payment Data"));
        ReconciliationLine."Funds Destination" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Funds Destination"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Funds Destination"));
        if Evaluate(ReconciliationLine."Balance Platform Debit", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Balance Platform Debit"), ReportWebhookRequest."Report Type"))) then;
        if Evaluate(ReconciliationLine."Balance Platform Credit", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Balance Platform Credit"), ReportWebhookRequest."Report Type"))) then;
        if Evaluate(ReconciliationLine."Booking Date", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Booking Date"), ReportWebhookRequest."Report Type"))) then;
        ReconciliationLine."Booking Date TimeZone" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Booking Date TimeZone"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Booking Date TimeZone"));
        if Evaluate(ReconciliationLine."Booking Date (AMS)", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Booking Date (AMS)"), ReportWebhookRequest."Report Type"))) then;
        ReconciliationLine.AdditionalType := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName(AdditionalType), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine.AdditionalType));
        ReconciliationLine.Installments := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName(Installments), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine.Installments));
        ReconciliationLine."Issuer Country" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Issuer Country"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Issuer Country"));
        ReconciliationLine."Shopper Country" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Shopper Country"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Shopper Country"));
        ReconciliationLine."Clearing Network" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Clearing Network"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Clearing Network"));
        ReconciliationLine."Terminal ID" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Terminal ID"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Terminal ID"));
        ReconciliationLine."Tender Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Tender Reference"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Tender Reference"));
        ReconciliationLine.Metadata := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName(Metadata), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine.Metadata));
        if Evaluate(ReconciliationLine."Pos Transaction Date", GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Pos Transaction Date"), ReportWebhookRequest."Report Type"))) then;
        ReconciliationLine."Pos Transaction Date TimeZone" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Pos Transaction Date TimeZone"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Pos Transaction Date TimeZone"));
        ReconciliationLine.Store := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName(Store), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine.Store));
        ReconciliationLine."Dispute Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Dispute Reference"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Dispute Reference"));
        ReconciliationLine."Register Booking Type" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Register Booking Type"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Register Booking Type"));
        ReconciliationLine.ARN := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName(ARN), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine.ARN));
        ReconciliationLine."Shopper Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Shopper Reference"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Shopper Reference"));
        ReconciliationLine."Payment Transaction Group" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Payment Transaction Group"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Payment Transaction Group"));
        ReconciliationLine."Settlement Flow" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Settlement Flow"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Settlement Flow"));
        ReconciliationLine."Authorisation Code" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Authorisation Code"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Authorisation Code"));
        ReconciliationLine."Card Number" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Card Number"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Card Number"));

        // External Settlement Detail specific
        ReconciliationLine.MID := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName(MID), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine.MID));
        ReconciliationLine."Acquirer Reference" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Acquirer Reference"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Acquirer Reference"));
        ReconciliationLine."Store Code" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Store Code"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Store Code"));
        ReconciliationLine."Acquirer Auth Code" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Acquirer Auth Code"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Acquirer Auth Code"));
        ReconciliationLine."Card BIN" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Card BIN"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Card BIN"));
        ReconciliationLine."Card Number Summary" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Card Number Summary"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Card Number Summary"));
        ReconciliationLine."Submerchant Identifier" := CopyStr(GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Card Number"), ReportWebhookRequest."Report Type")), 1, MaxStrLen(ReconciliationLine."Submerchant Identifier"));

        case GetValueAtCell(LineNo, GetColumnIndex('Type', ReportWebhookRequest."Report Type")) of
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
            'SentForSettle':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::SentForSettle;
            'SentForRefund':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::SentForRefund;
            'SettledInstallment':
                ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::SettledInstallment;
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
                _AdyenManagement.CreateReconciliationLog(_LogType::"Import Lines", false, StrSubstNo(ImportLinesError03, GetValueAtCell(LineNo, GetColumnIndex('Type', ReportWebhookRequest."Report Type"))), ReportWebhookRequest.ID);
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
        if Evaluate(ReconciliationHeader."Merchant Payout", GetValueAtCell(LineNo, GetColumnIndex('Net Debit (NC)', ReconciliationHeader."Document Type")), 9) then
            ReconciliationHeader.Modify();
    end;

    local procedure InsertBalanceTransfer(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; LineNo: Integer)
    var
        FromBalance: Decimal;
        ToBalance: Decimal;
    begin
        if GetValueAtCell(LineNo, GetColumnIndex('Modification Merchant Reference', ReconciliationHeader."Document Type")).Contains('from') then begin
            if Evaluate(FromBalance, GetValueAtCell(LineNo, GetColumnIndex('Net Credit (NC)', ReconciliationHeader."Document Type")), 9) then
                ReconciliationHeader."Opening Balance" += FromBalance; // Might close multiple batches
        end else
            if GetValueAtCell(LineNo, GetColumnIndex('Modification Merchant Reference', ReconciliationHeader."Document Type")).Contains('to') then begin
                if Evaluate(ToBalance, GetValueAtCell(LineNo, GetColumnIndex('Net Debit (NC)', ReconciliationHeader."Document Type")), 9) then
                    ReconciliationHeader."Closing Balance" += ToBalance; // Probably always is a single closing balance entry
            end;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertAcquirerPayout(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; LineNo: Integer)
    begin
        if Evaluate(ReconciliationHeader."Merchant Payout", GetValueAtCell(LineNo, GetColumnIndex('Net Debit (NC)', ReconciliationHeader."Document Type")), 9) then;
        if Evaluate(ReconciliationHeader."Acquirer Commission", GetValueAtCell(LineNo, GetColumnIndex('Commission', ReconciliationHeader."Document Type")), 9) then;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertReconciliationLines(CurrentMerchantAccount: Text; CurrentBatchNumber: Integer; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; ReportWebhookRequest: Record "NPR AF Rec. Webhook Request") EntryAmount: Integer
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        LineNo: Integer;
        ReportFirstLineNo: Integer;
    begin
        EntryAmount := 0;
        case ReportWebhookRequest."Report Type" of
            ReportWebhookRequest."Report Type"::"Settlement details":
                ReportFirstLineNo := 2;
            ReportWebhookRequest."Report Type"::"External Settlement detail (C)":
                ReportFirstLineNo := 5;
        end;

        for LineNo := ReportFirstLineNo to GetNumberOfRows() do begin
            if (GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Merchant Account"), ReconciliationHeader."Document Type")) = CurrentMerchantAccount) then begin
                if (GetValueAtCell(LineNo, GetColumnIndex(ReconciliationLine.FieldName("Batch Number"), ReconciliationHeader."Document Type")) = Format(CurrentBatchNumber)) or
                    (ReportWebhookRequest."Report Type" <> ReportWebhookRequest."Report Type"::"Settlement details")
                then begin
                    case GetValueAtCell(LineNo, GetColumnIndex('Type', ReconciliationHeader."Document Type")) of
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
    internal procedure MatchEntries(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer;
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
            ReconciliationHeader.Status := ReconciliationHeader.Status::Matched;
            ReconciliationHeader."Failed Lines Exist" := false;
            ReconciliationHeader.Modify();
            exit(MatchedEntries);
        end;
        Clear(MatchedEntries);
        Clear(UnmatchedEntries);

        if GuiAllowed() then begin
            Clear(ProcessedEntries);
            TotalEntries := ReconciliationLine.Count();
            Window.Open(MatchingEntriesLbl);
            Window.Update(2, TotalEntries);
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
                            MatchedEntries += TryMatchingAdjustments(ReconciliationLine2, ReconciliationHeader);
                        end;
                end;
                ReconciliationLine2.Modify();
            end;

            if GuiAllowed() then begin
                ProcessedEntries += 1;
                Window.Update(1, ProcessedEntries);
            end;

        until ReconciliationLine.Next() = 0;

        if GuiAllowed() then
            Window.Close();

        ReconciliationHeader."Failed Lines Exist" := UnmatchedEntries > 0;
        if ReconciliationHeader."Failed Lines Exist" then
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError03, Format(UnmatchedEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID")
        else begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", true, StrSubstNo(MatchTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            ReconciliationHeader.Status := ReconciliationHeader.Status::Matched;
        end;
        ReconciliationHeader.Modify();
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
        if TryMatchingPaymentWithSubscr(ReconciliationLine, MatchedEntries, ReconciliationHeader) then
            exit;
        ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
        UnmatchedEntries += 1;
    end;

    local procedure TryMatchingPaymentWithSubscr(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var MatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetRange("PSP Reference", ReconciliationLine."PSP Reference");
        SubscrPaymentRequest.SetRange(PSP, Enum::"NPR MM Subscription PSP"::Adyen);
        if not (ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo])
        then
            SubscrPaymentRequest.SetRange(Reconciled, false)
        else
            SubscrPaymentRequest.SetRange(Reversed, false);
        if not SubscrPaymentRequest.FindFirst() then
            exit;

        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"Subscription Payment";
        ReconciliationLine."Matching Entry System ID" := SubscrPaymentRequest.SystemId;

        if SubscriptionMatchingAllowed(SubscrPaymentRequest, ReconciliationLine, ReconciliationHeader, false) then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            MatchedEntries += 1;
        end else
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";

        exit(true);
    end;

    local procedure TryMatchingPaymentWithEFT(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var MatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Reset();
        EFTTransactionRequest.SetRange("PSP Reference", ReconciliationLine."PSP Reference");
        _AdyenManagement.SetEFTAdyenIntegrationFilter(EFTTransactionRequest);
        if not (ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo])
        then
            EFTTransactionRequest.SetRange(Reconciled, false)
        else
            EFTTransactionRequest.SetRange(Reversed, false);

        if not EFTTransactionRequest.FindFirst() then
            exit;

        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"EFT Transaction";
        ReconciliationLine."Matching Entry System ID" := EFTTransactionRequest.SystemId;

        if EFTMatchingAllowed(EFTTransactionRequest, ReconciliationLine, ReconciliationHeader, true) then begin
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            MatchedEntries += 1;
        end else
            ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";

        exit(true);
    end;

    local procedure TryMatchingPaymentWithMagento(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var MatchedEntries: Integer; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        ReconciliationLine2: Record "NPR Adyen Recon. Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        FilterPGCodes: Text;
        MatchingFound: Boolean;
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
        MagentoPaymentLine.SetFilter(Amount, '=%1', Abs(ReconciliationLine."Amount (TCY)"));

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

        if not MagentoPaymentLine.Find('-') then
            exit;

        MatchingFound := false;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        ReconciliationLine2.ReadIsolation := IsolationLevel::ReadUncommitted;
#endif
        repeat
            ReconciliationLine2.SetFilter(SystemId, '<>%1', ReconciliationLine.SystemId);
            ReconciliationLine2.SetRange("Matching Table Name", ReconciliationLine2."Matching Table Name"::"Magento Payment Line");
            ReconciliationLine2.SetRange("Matching Entry System ID", MagentoPaymentLine.SystemId);
            FilterReconciliationLineTransactionType(ReconciliationLine2, ReconciliationLine);
            MatchingFound := ReconciliationLine2.IsEmpty();

            if MatchingFound then begin
                ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"Magento Payment Line";
                ReconciliationLine."Matching Entry System ID" := MagentoPaymentLine.SystemId;
                if MagentoMatchingAllowed(MagentoPaymentLine, ReconciliationLine, ReconciliationHeader, true) then begin
                    ReconciliationLine.Status := ReconciliationLine.Status::Matched;
                    MatchedEntries += 1;
                end else
                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Match";
            end;
        until MatchingFound or (MagentoPaymentLine.Next() = 0);

        exit(MatchingFound);
    end;

    local procedure FilterReconciliationLineTransactionType(var ReconciliationLine2: Record "NPR Adyen Recon. Line"; ReconciliationLine: Record "NPR Adyen Recon. Line")
    begin
        case ReconciliationLine."Transaction Type" of
            ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed:
                ReconciliationLine2.SetRange("Transaction Type", ReconciliationLine."Transaction Type");

            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo:
                ReconciliationLine2.SetFilter("Transaction Type", '%1|%2',
                    ReconciliationLine."Transaction Type"::ChargebackReversed,
                    ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo)

            else
                ReconciliationLine2.SetFilter("Transaction Type", '<>%1&<>%2&<>%3&<>%4&<>%5',
                    ReconciliationLine."Transaction Type"::Chargeback,
                    ReconciliationLine."Transaction Type"::SecondChargeback,
                    ReconciliationLine."Transaction Type"::RefundedReversed,
                    ReconciliationLine."Transaction Type"::ChargebackReversed,
                    ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo);
        end;
    end;

    local procedure TryMatchingAdjustments(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") MatchedEntries: Integer
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
        ReconciliationLine.Status := ReconciliationLine.Status::"Not to be Matched";
        if RecordPrepared then
            if FeeCreatePost.FeePosted(ReconciliationLine) then begin
                ReconciliationLine."Matching Entry System ID" := FeeCreatePost.GetGlEntrySystemID();
                ReconciliationLine.Status := ReconciliationLine.Status::Posted;
            end;
        MatchedEntries += 1;
    end;
    #endregion

    #region Reconciling
    internal procedure ReconcileEntries(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean;
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        Window: Dialog;
        ProcessedEntries: Integer;
        TotalEntries: Integer;
        UnReconciledEntries: Integer;
        ReconcileAllowed: Boolean;
        ReconcilingEntriesLbl: Label 'Attempting to Reconcile Entries...\\Reconciling entry #1 of #2.';
        ReconcilingIsNotPossibleLbl: Label 'Reconciling is not possible while Posting is enabled. Please either proceed with Posting or disable it in NP Pay Setup.';
    begin
        if CheckPostedOrReconciled(ReconciliationLine, ReconciliationHeader, Enum::"NPR Adyen Rec. Line Status"::Reconciled) then
            exit(true);

        if not LinesToProcessExist(ReconciliationLine, ReconciliationHeader, Enum::"NPR Adyen Rec. Line Status"::Reconciled) then
            exit;

        _AdyenSetup.GetRecordOnce();
        if _AdyenSetup."Enable Automatic Posting" then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", false, ReconcilingIsNotPossibleLbl, ReconciliationHeader."Webhook Request ID");
            exit;
        end;

        if GuiAllowed() then begin
            Clear(ProcessedEntries);
            TotalEntries := ReconciliationLine.Count();
            Window.Open(ReconcilingEntriesLbl);
            Window.Update(2, TotalEntries);
        end;

        ReconciliationLine.SetFilter(Status, '<>%1&<>%2&<>%3&<>%4', ReconciliationLine.Status::Reconciled, ReconciliationLine.Status::"Not to be Reconciled", ReconciliationLine.Status::Posted, ReconciliationLine.Status::"Not to be Posted");
        ReconciliationLine.FindSet();
        repeat
            ReconcileAllowed := true;
            if ReconciliationLine."Matching Table Name" in [ReconciliationLine."Matching Table Name"::"EFT Transaction", ReconciliationLine."Matching Table Name"::"Magento Payment Line", ReconciliationLine."Matching Table Name"::"Subscription Payment"] then
                ReconcileAllowed := PostingOrReconcilingAllowed(ReconciliationLine, Enum::"NPR Adyen Rec. Line Status"::Reconciled);

            if ReconcileAllowed then begin
                case ReconciliationLine."Matching Table Name" of
                    ReconciliationLine."Matching Table Name"::"EFT Transaction",
                    ReconciliationLine."Matching Table Name"::"Magento Payment Line",
                    ReconciliationLine."Matching Table Name"::"Subscription Payment":
                        UnReconciledEntries += TryReconcilingPayment(ReconciliationLine, ReconciliationHeader);
                    ReconciliationLine."Matching Table Name"::"G/L Entry":
                        ReconcileAdjustments(ReconciliationLine);
                    ReconciliationLine."Matching Table Name"::"To Be Determined":
                        UnReconciledEntries += 1;
                end;
            end else
                UnReconciledEntries += 1;

            ReconciliationLine.Modify();
            Commit();

            if GuiAllowed() then begin
                ProcessedEntries += 1;
                Window.Update(1, ProcessedEntries);
            end;
        until ReconciliationLine.Next() = 0;

        if GuiAllowed() then
            Window.Close();

        if UnReconciledEntries > 0 then
            _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", false, StrSubstNo(ReconcileTransactionsError02, Format(UnReconciledEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID")
        else begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", true, StrSubstNo(ReconcileTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            ReconciliationHeader.Status := ReconciliationHeader.Status::Reconciled;
        end;
        ReconciliationHeader."Failed Lines Exist" := UnReconciledEntries > 0;
        ReconciliationHeader.Modify();
        exit(not ReconciliationHeader."Failed Lines Exist");
    end;

    local procedure TryReconcilingPayment(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnReconciledEntries: Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        if not (ReconciliationLine.Status in [ReconciliationLine.Status::Matched, ReconciliationLine.Status::"Not to be Matched", ReconciliationLine.Status::"Failed to Reconcile", ReconciliationLine.Status::"Failed to Post"]) then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", false, StrSubstNo(TransactionNotMatchedLbl, Format(ReconciliationLine."PSP Reference")), ReconciliationHeader."Webhook Request ID");
            UnReconciledEntries += 1;
            exit;
        end;

        case ReconciliationLine."Matching Table Name" of
            ReconciliationLine."Matching Table Name"::"EFT Transaction":
                begin
                    if EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        EFTTransactionRequest.Reconciled := true;
                        EFTTransactionRequest."Reconciliation Date" := Today();
                        EFTTransactionRequest.Modify();
                        ReconciliationLine.Status := ReconciliationLine.Status::Reconciled;
                        exit;
                    end;
                end;
            ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                begin
                    if MagentoPaymentLine.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        MagentoPaymentLine.Reconciled := true;
                        MagentoPaymentLine."Reconciliation Date" := Today();
                        MagentoPaymentLine.Modify();
                        ReconciliationLine.Status := ReconciliationLine.Status::Reconciled;
                        exit;
                    end;
                end;
            ReconciliationLine."Matching Table Name"::"Subscription Payment":
                begin
                    if SubscrPaymentRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        SubscrPaymentRequest.Reconciled := true;
                        SubscrPaymentRequest."Reconciliation Date" := Today();
                        SubscrPaymentRequest.Modify();
                        ReconciliationLine.Status := ReconciliationLine.Status::Reconciled;
                        exit;
                    end;
                end;
        end;
        UnReconciledEntries += 1;
    end;

    local procedure ReconcileAdjustments(var ReconciliationLine: Record "NPR Adyen Recon. Line")
    begin
        ReconciliationLine.Status := ReconciliationLine.Status::"Not to be Reconciled";
    end;
    #endregion

    #region Posting
    internal procedure PostEntries(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") Success: Boolean;
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        UnPostedEntries: Integer;
        Window: Dialog;
        TotalEntries: Integer;
        ProcessedEntries: Integer;
        PostingEntriesLbl: Label 'Attempting to Post Reconciliation Line entries...\\Processing entry #1 of #2.';
        PostingDateIsNotAllowedLbl: Label 'The transaction date of line %1 cannot be earlier than the specified ''%2'' in the NP Pay Setup.', Comment = '%1 - Reconciliation line number, %2 - "Reconciliation Posting Starting Date" from the NP Pay Setup page';
        PostAllowed: Boolean;
    begin
        if CheckPostedOrReconciled(ReconciliationLine, ReconciliationHeader, Enum::"NPR Adyen Rec. Line Status"::Posted) then
            exit(true);

        if not LinesToProcessExist(ReconciliationLine, ReconciliationHeader, Enum::"NPR Adyen Rec. Line Status"::Posted) then
            exit;

        if GuiAllowed() then begin
            Clear(ProcessedEntries);
            TotalEntries := ReconciliationLine.Count();
            Window.Open(PostingEntriesLbl);
            Window.Update(2, TotalEntries);
        end;

        _AdyenSetup.GetRecordOnce();
        ReconciliationLine.SetFilter(Status, '<>%1&<>%2', ReconciliationLine.Status::Posted, ReconciliationLine.Status::"Not to be Posted");
        ReconciliationLine.SetAutoCalcFields("Transaction Posted", "Markup Posted", "Commissions Posted", "Realized Gains Posted", "Realized Losses Posted");
        ReconciliationLine.FindSet();
        repeat
            PostAllowed := true;
            if ReconciliationLine."Matching Table Name" in [ReconciliationLine."Matching Table Name"::"EFT Transaction", ReconciliationLine."Matching Table Name"::"Magento Payment Line", ReconciliationLine."Matching Table Name"::"Subscription Payment"] then
                PostAllowed := PostingOrReconcilingAllowed(ReconciliationLine, Enum::"NPR Adyen Rec. Line Status"::Posted);
            if _AdyenSetup."Recon. Posting Starting Date" > 0DT then
                if ReconciliationLine."Transaction Date" < _AdyenSetup."Recon. Posting Starting Date" then begin
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostingDateIsNotAllowedLbl, Format(ReconciliationLine."Line No."), _AdyenSetup.FieldCaption("Recon. Posting Starting Date")), ReconciliationHeader."Webhook Request ID");
                    PostAllowed := false;
                end;

            if PostAllowed then begin
                AssignPostingDateAndNo(ReconciliationLine, ReconciliationHeader);
                case ReconciliationLine."Matching Table Name" of
                    ReconciliationLine."Matching Table Name"::"EFT Transaction",
                    ReconciliationLine."Matching Table Name"::"Magento Payment Line",
                    ReconciliationLine."Matching Table Name"::"Subscription Payment":
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
            Commit();

            if GuiAllowed() then begin
                ProcessedEntries += 1;
                Window.Update(1, ProcessedEntries);
            end;
        until ReconciliationLine.Next() = 0;

        if GuiAllowed() then
            Window.Close();

        if UnPostedEntries > 0 then
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError03, Format(UnPostedEntries), ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID")
        else begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", true, StrSubstNo(PostTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
            ReconciliationHeader.Status := ReconciliationHeader.Status::Posted;
        end;
        ReconciliationHeader."Failed Lines Exist" := UnPostedEntries > 0;
        ReconciliationHeader.Modify();
        exit(not ReconciliationHeader."Failed Lines Exist");
    end;

    local procedure TryPostingPayment(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnPostedEntries: Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        PostEFTTransaction: Codeunit "NPR Adyen EFT Trans. Posting";
    begin
        case ReconciliationLine."Matching Table Name" of
            ReconciliationLine."Matching Table Name"::"EFT Transaction":
                if not EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsEFTError01, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
                    UnPostedEntries += 1;
                    exit;
                end;
            ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                if not MagentoPaymentLine.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsMagentoError01, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
                    UnPostedEntries += 1;
                    exit;
                end;
            ReconciliationLine."Matching Table Name"::"Subscription Payment":
                if not SubscrPaymentRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsSubscriptionError01, ReconciliationLine."Matching Entry System ID"), ReconciliationHeader."Webhook Request ID");
                    UnPostedEntries += 1;
                    exit;
                end;
        end;

        if not (ReconciliationLine.Status in [ReconciliationLine.Status::Matched, ReconciliationLine.Status::"Not to be Matched", ReconciliationLine.Status::Reconciled, ReconciliationLine.Status::"Not to be Reconciled", ReconciliationLine.Status::"Failed to Post"]) then begin
            _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(TransactionNotMatchedLbl, Format(ReconciliationLine."PSP Reference")), ReconciliationHeader."Webhook Request ID");
            UnPostedEntries += 1;
            exit;
        end;

        if not ReconciliationLine.IsPosted(false) then begin
            if PostEFTTransaction.PrepareRecords(ReconciliationLine, ReconciliationHeader) then begin
                if not PostEFTTransaction.Run() then begin
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                    UnPostedEntries += 1;
                    exit;
                end;
                if (not IsNullGuid(PostEFTTransaction.GetNewReversedSystemId())) and
                   (ReconciliationLine."Transaction Type" in
                     [ReconciliationLine."Transaction Type"::Chargeback,
                      ReconciliationLine."Transaction Type"::SecondChargeback,
                      ReconciliationLine."Transaction Type"::RefundedReversed,
                      ReconciliationLine."Transaction Type"::ChargebackReversed,
                      ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo])
                then
                    ReconciliationLine."Matching Entry System ID" := PostEFTTransaction.GetNewReversedSystemId();

                if PostEFTTransaction.IsRealizedGLPosted() then
                    ReconciliationLine."Realized Gains or Losses" := PostEFTTransaction.RealizedGLAmount();
            end else begin
                _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, GetLastErrorText(), ReconciliationHeader."Webhook Request ID");
                UnPostedEntries += 1;
                exit;
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
            ReconciliationLine."Matching Table Name"::"Subscription Payment":
                begin
                    if SubscrPaymentRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        SubscrPaymentRequest.Reconciled := true;
                        SubscrPaymentRequest."Reconciliation Date" := Today();
                        SubscrPaymentRequest.Modify();
                    end;
                end;
        end;
    end;

    local procedure TryPostingAdjustments(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr") UnPostedEntries: Integer
    var
        FeeCreateAndPost: Codeunit "NPR Adyen Fee Posting";
        GLAccountType: Enum "NPR Adyen Posting GL Accounts";
        RecordsOK: Boolean;
    begin
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

    local procedure AssignPostingDateAndNo(var ReconLine: Record "NPR Adyen Recon. Line"; ReconHeader: Record "NPR Adyen Reconciliation Hdr")
    var
        xReconLine: Record "NPR Adyen Recon. Line";
    begin
        xReconLine := ReconLine;
        if ReconLine."Posting No." = '' then begin
            _AdyenSetup.TestField("Posting Document Nos.");
            ReconLine."Posting No." := _NoSeriesMgt.GetNextNo(_AdyenSetup."Posting Document Nos.", Today(), true);
        end;
        if _AdyenSetup."Post with Transaction Date" then
            ReconLine."Posting Date" := DT2Date(ReconLine."Transaction Date")
        else
            ReconLine."Posting Date" := ReconHeader."Posting Date";
        if (xReconLine."Posting No." = ReconLine."Document No.") and (xReconLine."Posting Date" = ReconLine."Posting Date") then
            exit;
        ReconLine.Modify();
        Commit();
    end;

    local procedure PostingOrReconcilingAllowed(var ReconciliationLine: Record "NPR Adyen Recon. Line"; AdyenRecLineStatus: Enum "NPR Adyen Rec. Line Status"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        ChargebackNeedsConfirmationLbl: Label 'It is not allowed to post %1 entry. Chargeback transactions require your confirmation first.';
        PostingNotAllowedLbl: Label 'It is not allowed to post %1 entry.';
        ParkedSaleLbl: Label 'The sale %1 is parked. Please finish the sale and try again.';
        SaleNotFinishedLbl: Label 'The sale %1 has not yet been finished. Please finish the sale and try again.';
        EFTTransactionRequestDoesNotExistLbl: Label 'EFT Transaction Request %1 does not exist anymore.';
        MagentoPaymentLineDoesNotExistLbl: Label 'Magento Payment Line %1 does not exist anymore.', Comment = '%1 - Magento Payment Line entry''s System ID (GUID).';
        SubscrPaymentRequestDoesNotExistLbl: Label 'Subscription Payment Request %1 does not exist anymore.', Comment = '%1 - Subscription Payment Request entry''s System ID (GUID).';
        SavedPOSSale: Record "NPR POS Saved Sale Entry";
    begin
        if ReconciliationLine."Matching Table Name" in [ReconciliationLine."Matching Table Name"::"EFT Transaction", ReconciliationLine."Matching Table Name"::"Magento Payment Line", ReconciliationLine."Matching Table Name"::"Subscription Payment"] then begin
            if not ReconciliationLine."Posting allowed" then begin
                if ReconciliationLine."Transaction Type" in [ReconciliationLine."Transaction Type"::Chargeback, ReconciliationLine."Transaction Type"::ChargebackExternallyWithInfo, ReconciliationLine."Transaction Type"::SecondChargeback] then
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(ChargebackNeedsConfirmationLbl, ReconciliationLine."Line No."), ReconciliationLine."Webhook Request ID")
                else
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostingNotAllowedLbl, ReconciliationLine."Line No."), ReconciliationLine."Webhook Request ID");

                ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                exit;
            end;
        end;

        case ReconciliationLine."Matching Table Name" of
            ReconciliationLine."Matching Table Name"::"EFT Transaction":
                begin
                    if not EFTTransactionRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        case AdyenRecLineStatus of
                            AdyenRecLineStatus::Posted:
                                begin
                                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(EFTTransactionRequestDoesNotExistLbl, ReconciliationLine."Matching Entry System ID"), ReconciliationLine."Webhook Request ID");
                                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                                end;
                            AdyenRecLineStatus::Reconciled:
                                begin
                                    _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", false, StrSubstNo(EFTTransactionRequestDoesNotExistLbl, ReconciliationLine."Matching Entry System ID"), ReconciliationLine."Webhook Request ID");
                                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Reconcile";
                                end;
                        end;
                        exit;
                    end;

                    /* Unknown use  //TODO (confirm with Tim)
                    if ((EFTTransactionRequest.Finished = 0DT) or (not EFTTransactionRequest."External Result Known")) and (EFTTransactionRequest."Amount Input" <> 0) then begin
                        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(SaleNotFinishedLbl, EFTTransactionRequest."Sales Ticket No."), ReconciliationLine."Webhook Request ID");
                        ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                        exit;
                    end;
                    */

                    if EFTTransactionRequest."Result Amount" <> 0 then begin
                        EFTTransactionRequest.CalcFields("FF Moved to POS Entry");
                        if not EFTTransactionRequest."FF Moved to POS Entry" then begin
                            if SavedPOSSale.GetBySystemId(EFTTransactionRequest."Sales ID") then begin
                                case AdyenRecLineStatus of
                                    AdyenRecLineStatus::Posted:
                                        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(ParkedSaleLbl, Format(EFTTransactionRequest."Sales Ticket No.")), ReconciliationLine."Webhook Request ID");
                                    AdyenRecLineStatus::Reconciled:
                                        _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", false, StrSubstNo(ParkedSaleLbl, Format(EFTTransactionRequest."Sales Ticket No.")), ReconciliationLine."Webhook Request ID");
                                end;
                            end else begin
                                case AdyenRecLineStatus of
                                    AdyenRecLineStatus::Posted:
                                        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(SaleNotFinishedLbl, Format(EFTTransactionRequest."Sales Ticket No.")), ReconciliationLine."Webhook Request ID");
                                    AdyenRecLineStatus::Reconciled:
                                        _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", false, StrSubstNo(SaleNotFinishedLbl, Format(EFTTransactionRequest."Sales Ticket No.")), ReconciliationLine."Webhook Request ID");
                                end;
                            end;
                            case AdyenRecLineStatus of
                                AdyenRecLineStatus::Posted:
                                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                                AdyenRecLineStatus::Reconciled:
                                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Reconcile";
                            end;
                            exit;
                        end;
                    end;
                end;
            ReconciliationLine."Matching Table Name"::"Magento Payment Line":
                begin
                    if not MagentoPaymentLine.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        case AdyenRecLineStatus of
                            AdyenRecLineStatus::Posted:
                                begin
                                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(MagentoPaymentLineDoesNotExistLbl, ReconciliationLine."Matching Entry System ID"), ReconciliationLine."Webhook Request ID");
                                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                                end;
                            AdyenRecLineStatus::Reconciled:
                                begin
                                    _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", false, StrSubstNo(MagentoPaymentLineDoesNotExistLbl, ReconciliationLine."Matching Entry System ID"), ReconciliationLine."Webhook Request ID");
                                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Reconcile";
                                end;
                        end;
                        exit;
                    end;
                end;
            ReconciliationLine."Matching Table Name"::"Subscription Payment":
                begin
                    if not SubscrPaymentRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        case AdyenRecLineStatus of
                            AdyenRecLineStatus::Posted:
                                begin
                                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(SubscrPaymentRequestDoesNotExistLbl, ReconciliationLine."Matching Entry System ID"), ReconciliationLine."Webhook Request ID");
                                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Post";
                                end;
                            AdyenRecLineStatus::Reconciled:
                                begin
                                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(SubscrPaymentRequestDoesNotExistLbl, ReconciliationLine."Matching Entry System ID"), ReconciliationLine."Webhook Request ID");
                                    ReconciliationLine.Status := ReconciliationLine.Status::"Failed to Reconcile";
                                end;
                        end;
                        exit;
                    end;
                end;
        end;
        exit(true);
    end;

    procedure ReversePostings(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr")
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        ReversedPostings: Integer;
        Window: Dialog;
        ReverseProcessingLbl: Label 'Reversing postings of the Reconciliation Line(s)...\Processing entry #1 of #2.';
        UnPostedSuccessResultLbl: Label 'The postings for this document have been successfully reversed.';
        NothingToReverseLbl: Label 'Nothing to Reverse.';
    begin
        ReversedPostings := 0;
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.SetRange(Status, ReconciliationLine.Status::Posted);
        if ReconciliationLine.FindSet() then begin
            Window.Open(ReverseProcessingLbl);
            Window.Update(2, Format(ReconciliationLine.Count()));
            repeat
                if ReverseRecLinePosting(ReconciliationLine) then
                    ReversedPostings += 1;
                Window.Update(1, Format(ReversedPostings));
            until ReconciliationLine.Next() = 0;
            Window.Close();
            ReconciliationHeader.Status := ReconciliationHeader.Status::Matched;
            ReconciliationHeader."Posting Date" := 0D;
            ReconciliationHeader."Total Posted Amount" := 0;
            ReconciliationHeader.Modify();
            Message(UnPostedSuccessResultLbl);
        end else
            Message(NothingToReverseLbl);
    end;
    #endregion

    #region Miscellaneous
    internal procedure ValidateReportScheme(var WebhookRequest: Record "NPR AF Rec. Webhook Request"): Boolean
    var
        SchemeValid: Boolean;
        SchemeValidationField: Text;
        i: Integer;
        SchemeColumnNumber: Integer;
        InvalidSchemeError: Label 'Validation Scheme Failed: Report did not meet validation criteria. Column ''%1'' does not exist. Please check report''s configuration.';
        ValidSchemeText: Label 'Validation Success: Report passed all validation criteria.';
        ReportDataIsMissingOrCorruptedLbl: Label 'Report data is missing or could not be read.';
        Scheme: array[50] of Text[35];
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        WebhookRequest.TestField(ID);
        AdyenSetup.GetRecordOnce();
        AdyenSetup.TestField("Posting Document Nos.");

        if not GetReportData(WebhookRequest, false) then
            Error(ReportDataIsMissingOrCorruptedLbl);

        if WebhookRequest."Report Type" = WebhookRequest."Report Type"::Undefined then
            WebhookRequest.FieldError("Report Type");

        _AdyenManagement.DefineReportScheme(WebhookRequest."Report Type", Scheme, SchemeColumnNumber);

        SchemeValid := true;
        i := 1;

        while SchemeValid and (i <= SchemeColumnNumber) do begin
            SchemeValidationField := Scheme[i];
            SchemeValid := ColumnExists(SchemeValidationField, WebhookRequest."Report Type");
            i += 1;
        end;

        if not SchemeValid then
            Error(InvalidSchemeError, SchemeValidationField);

        _AdyenManagement.CreateReconciliationLog(_LogType::"Validate Report Scheme", true, ValidSchemeText, WebhookRequest.ID);
        exit(true);
    end;

    internal procedure MarkAsPostedIfPossible(var RecHeader: Record "NPR Adyen Reconciliation Hdr"): Boolean
    var
        RecLine: Record "NPR Adyen Recon. Line";
    begin
        if RecHeader.Status = RecHeader.Status::Posted then
            exit;

        RecLine.SetRange("Document No.", RecHeader."Document No.");
        if RecLine.IsEmpty() then
            exit;

        RecLine.SetFilter(Status, '<>%1', RecLine.Status::Posted);
        if not RecLine.IsEmpty() then
            exit;

        RecHeader.Status := RecHeader.Status::Posted;
        RecHeader.Modify();
        exit(true);
    end;

    internal procedure PostUnmatchedEntries(var ReconLine: Record "NPR Adyen Recon. Line") PostedEntries: Integer
    var
        RecHeader: Record "NPR Adyen Reconciliation Hdr";
        PostMissingTransaction: Codeunit "NPR Adyen Missing Trans. Post";
        Window: Dialog;
        EntryPosting: Integer;
        TouchedHeader: Code[20];
        TouchedHeaders: List of [Code[20]];
        ProcessingLbl: Label 'Posting the Reconciliation Line(s)...\Processing entry #1 of #2.';
    begin
        Window.Open(ProcessingLbl);
        Window.Update(2, Format(ReconLine.Count()));
        _AdyenSetup.GetRecordOnce();
        EntryPosting := 0;
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        ReconLine.ReadIsolation := IsolationLevel::UpdLock;
#else
        ReconLine.LockTable();
#endif
        ReconLine.FindSet();
        repeat
            EntryPosting += 1;
            Window.Update(1, Format(EntryPosting));
            if RecHeader."Document No." <> ReconLine."Document No." then begin
                RecHeader.Get(ReconLine."Document No.");
                if not TouchedHeaders.Contains(RecHeader."Document No.") then
                    TouchedHeaders.Add(RecHeader."Document No.");
            end;

            AssignPostingDateAndNo(ReconLine, RecHeader);

            Clear(PostMissingTransaction);
            if PostMissingTransaction.Run(ReconLine) then begin
                ReconLine."Matching Table Name" := ReconLine."Matching Table Name"::"G/L Entry";
                ReconLine."Matching Entry System ID" := PostMissingTransaction.GetGLSystemID();
                ReconLine.Status := ReconLine.Status::Posted;
                ReconLine.Modify();
                PostedEntries += 1;
            end;
        until ReconLine.Next() = 0;
        Window.Close();

        foreach TouchedHeader in TouchedHeaders do begin
            if RecHeader."Document No." <> TouchedHeader then
                RecHeader.Get(TouchedHeader);
            MarkAsPostedIfPossible(RecHeader);
        end;
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        if (Temp_ExcelBuffer.Get(RowNo, ColNo)) then
            exit(Temp_ExcelBuffer."Cell Value as Text");
        exit('');
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
        AdyenSetupDoesNotExistLbl: Label 'NP Pay Setup does not exist.';
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

            HttpClient.DefaultRequestHeaders.Add('x-api-key', _AdyenSetup.GetDownloadReportApiKey());
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
        ReportFirstLineNo: Integer;
        JsonObject: JsonObject;
        RecLine: Record "NPR Adyen Recon. Line";
    begin
        case ReportType of
            ReportType::"Settlement details":
                ReportFirstLineNo := 2;
            ReportType::"External Settlement detail (C)":
                ReportFirstLineNo := 5;
        end;
        for LineNo := ReportFirstLineNo to GetNumberOfRows() do begin
            Clear(JsonObject);
            JsonObject.Add('Merchant Account', GetValueAtCell(LineNo, GetColumnIndex(RecLine.FieldName("Merchant Account"), ReportType)));
            case ReportType of
                ReportType::"Settlement details":
                    JsonObject.Add('Batch Number', GetValueAtCell(LineNo, GetColumnIndex(RecLine.FieldName("Batch Number"), ReportType)));
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
        RecLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type");
        RecLine.SetRange("Merchant Account", ReconciliationLine."Merchant Account");

        if ReconciliationLine."PSP Reference" <> '' then begin
            RecLine.SetRange("PSP Reference", ReconciliationLine."PSP Reference");
            RecLine.SetRange("Amount (TCY)", ReconciliationLine."Amount (TCY)");
        end else begin
            RecLine.SetRange("Modification Reference", ReconciliationLine."Modification Reference");
            RecLine.SetRange("Amount(AAC)", ReconciliationLine."Amount(AAC)");
        end;
        if RecLine.IsEmpty() then
            exit(true);
    end;

    local procedure GetColumnIndex(FieldName: Text; ReportType: Enum "NPR Adyen Report Type"): Integer
    begin
        Temp_ExcelBuffer.Reset();
        case ReportType of
            ReportType::"Settlement details":
                Temp_ExcelBuffer.SetRange("Row No.", 1);
            ReportType::"External Settlement detail (C)":
                Temp_ExcelBuffer.SetRange("Row No.", 4);
        end;
        Temp_ExcelBuffer.SetFilter("Cell Value as Text", '=%1', FieldName);
        if Temp_ExcelBuffer.FindFirst() then
            exit(Temp_ExcelBuffer."Column No.");
    end;

    local procedure ColumnExists(SchemeValidationField: Text; ReportType: Enum "NPR Adyen Report Type"): Boolean
    begin
        Temp_ExcelBuffer.Reset();
        case ReportType of
            ReportType::"Settlement details":
                Temp_ExcelBuffer.SetRange("Row No.", 1);
            ReportType::"External Settlement detail (C)":
                Temp_ExcelBuffer.SetRange("Row No.", 4);
        end;
        Temp_ExcelBuffer.SetFilter("Cell Value as Text", '=%1', SchemeValidationField);
        if Temp_ExcelBuffer.IsEmpty() then
            exit;
        exit(true);
    end;

    local procedure ReverseRecLinePosting(ReconciliationLine: Record "NPR Adyen Recon. Line") Reversed: Boolean
    var
        GLEntry: Record "G/L Entry";
        ReconRelation: Record "NPR Adyen Recons.Line Relation";
        ReconRelation2: Record "NPR Adyen Recons.Line Relation";
        ReversalEntry: Record "Reversal Entry";
        SkipPostCheck: Codeunit "NPR Adyen Skip Post Check";
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        ReconciliationLine.ReadIsolation := IsolationLevel::UpdLock;
        ReconRelation.ReadIsolation := IsolationLevel::UpdLock;
#else
        ReconciliationLine.LockTable();
        ReconRelation.LockTable();
#endif
        ReconciliationLine.Find();
        if ReconciliationLine.Status = ReconciliationLine.Status::Posted then begin
            ReconRelation.SetRange("Document No.", ReconciliationLine."Document No.");
            ReconRelation.SetRange("Document Line No.", ReconciliationLine."Line No.");
            ReconRelation.SetRange(Reversed, false);
            if ReconRelation.FindSet() then
                Repeat
                    GLEntry.SetRange("Entry No.", ReconRelation."GL Entry No.");
                    GLEntry.SetRange(Reversed, false);
                    if GLEntry.FindFirst() then begin
                        Clear(ReversalEntry);
                        GLEntry.TestField("Transaction No.");
                        ReversalEntry.SetHideWarningDialogs();
                        BindSubscription(SkipPostCheck);
                        ReversalEntry.ReverseTransaction(GLEntry."Transaction No.");
                        UnBindSubscription(SkipPostCheck);
                    end;

                    ReconRelation2 := ReconRelation;
                    ReconRelation2.Reversed := true;
                    ReconRelation2.Modify();
                until ReconRelation.Next() = 0;

            ReconciliationLine."Posting No." := '';
            ReconciliationLine."Posting Date" := 0D;
            ReconciliationLine.Status := ReconciliationLine.Status::Matched;
            ReconciliationLine.Modify();
            if ReconciliationLine."Matching Table Name" in [ReconciliationLine."Matching Table Name"::"EFT Transaction", ReconciliationLine."Matching Table Name"::"Magento Payment Line", ReconciliationLine."Matching Table Name"::"Subscription Payment"] then
                RevertPaymentReconciliation(ReconciliationLine, ReconciliationLine."Matching Table Name");
            Reversed := true;
        end;
        Commit();
    end;

    internal procedure RevertPaymentReconciliation(ReconciliationLine: Record "NPR Adyen Recon. Line"; MatchingTable: Enum "NPR Adyen Trans. Rec. Table")
    var
        EFTTransRequest: Record "NPR EFT Transaction Request";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        case MatchingTable of
            MatchingTable::"EFT Transaction":
                begin
                    if EFTTransRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        EFTTransRequest.Reconciled := false;
                        EFTTransRequest."Reconciliation Date" := 0D;
                        EFTTransRequest.Modify();
                    end;
                end;
            MatchingTable::"Magento Payment Line":
                begin
                    if MagentoPaymentLine.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        MagentoPaymentLine.Reconciled := false;
                        MagentoPaymentLine."Reconciliation Date" := 0D;
                        MagentoPaymentLine.Modify();
                    end;
                end;
            MatchingTable::"Subscription Payment":
                begin
                    if SubscrPaymentRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID") then begin
                        SubscrPaymentRequest.Reconciled := false;
                        SubscrPaymentRequest."Reconciliation Date" := 0D;
                        SubscrPaymentRequest.Modify();
                    end;
                end;
        end;
    end;

    internal procedure SubscriptionMatchingAllowed(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; ReconciliationLine: Record "NPR Adyen Recon. Line"; Silent: Boolean) Success: Boolean
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
    begin
        Success := SubscriptionMatchingAllowed(SubscrPaymentRequest, ReconciliationLine, ReconciliationHeader, Silent);
    end;

    local procedure SubscriptionMatchingAllowed(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; Silent: Boolean) Success: Boolean
    var
        MatchValidationPassed: Boolean;
        ManualMatchTransactionError01: Label 'Failed to match with Subscription Payment Request No. %1 because amounts aren''t equal or Subscription Payment Request status is either Canceled or Rejected.';
    begin
        if ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]
        then
            MatchValidationPassed := Abs(SubscrPaymentRequest."Amount") = Abs(ReconciliationLine."Amount (TCY)")
        else
            MatchValidationPassed := SubscrPaymentRequest."Amount" = ReconciliationLine."Amount (TCY)";

        MatchValidationPassed := MatchValidationPassed and not (SubscrPaymentRequest.Status in [SubscrPaymentRequest.Status::Cancelled, SubscrPaymentRequest.Status::Rejected]);

        if MatchValidationPassed then begin
            Success := true;
        end else begin
            if not Silent and GuiAllowed() then
                Error(ManualMatchTransactionError01, Format(SubscrPaymentRequest."Entry No."))
            else
                _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError08, Format(SubscrPaymentRequest."Entry No.")), ReconciliationHeader."Webhook Request ID");
        end;
    end;

    internal procedure MagentoMatchingAllowed(MagentoPaymentLine: Record "NPR Magento Payment Line"; ReconciliationLine: Record "NPR Adyen Recon. Line"; Silent: Boolean) Success: Boolean
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
    begin
        Success := MagentoMatchingAllowed(MagentoPaymentLine, ReconciliationLine, ReconciliationHeader, Silent);
    end;

    local procedure MagentoMatchingAllowed(MagentoPaymentLine: Record "NPR Magento Payment Line"; ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; Silent: Boolean) Success: Boolean
    var
        MatchValidationPassed: Boolean;
        ManualMatchTransactionError02: Label 'Failed to match with Magento Payment Line (Document Type: %1, Document No.: %2, Document Line No.: %3) because Amounts aren''t equal.';
    begin
        MatchValidationPassed := Abs(MagentoPaymentLine.Amount) = Abs(ReconciliationLine."Amount (TCY)"); // "Magento Payment Line" Amount seems to be always positive which causes refunds to fail during matching.

        if MatchValidationPassed then
            Success := true
        else begin
            if not Silent and GuiAllowed() then
                Error(ManualMatchTransactionError02, Format(MagentoPaymentLine."Document Type"), Format(MagentoPaymentLine."Document No."), Format(MagentoPaymentLine."Line No."))
            else
                _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false,
                    StrSubstNo(MatchTransactionsError04,
                        Format(MagentoPaymentLine."Document Type"),
                        Format(MagentoPaymentLine."Document No."),
                        Format(MagentoPaymentLine."Line No.")),
                    ReconciliationHeader."Webhook Request ID");
        end;
    end;

    internal procedure EFTMatchingAllowed(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReconciliationLine: Record "NPR Adyen Recon. Line"; Silent: Boolean) Success: Boolean
    var
        RecHeader: Record "NPR Adyen Reconciliation Hdr";
    begin
        Success := EFTMatchingAllowed(EFTTransactionRequest, ReconciliationLine, RecHeader, Silent);
    end;

    local procedure EFTMatchingAllowed(EFTTransactionRequest: Record "NPR EFT Transaction Request"; ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; Silent: Boolean) Success: Boolean
    var
        PaymentLine: Record "NPR POS Entry Payment Line";
        MatchValidationPassed: Boolean;
        ManualMatchTransactionError03: Label 'POS Entry Payment Line does not exist. Please check if the Sale is posted.';
        ManualMatchTransactionError04: Label 'Failed to match with EFT Transaction Request No. %1 because Amounts aren''t equal or EFT Transaction Request has no Financial Impact.';
    begin
        if ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]
        then begin
            if not PaymentLine.GetBySystemId(EFTTransactionRequest."Sales Line ID") then begin
                if not Silent and GuiAllowed() then
                    Error(ManualMatchTransactionError03)
                else
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false, MatchTransactionsError05, ReconciliationHeader."Webhook Request ID");
                exit;
            end;
        end;

        if ReconciliationLine."Transaction Type" in
            [ReconciliationLine."Transaction Type"::Chargeback,
            ReconciliationLine."Transaction Type"::SecondChargeback,
            ReconciliationLine."Transaction Type"::RefundedReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversed,
            ReconciliationLine."Transaction Type"::ChargebackReversedExternallyWithInfo]
        then
            MatchValidationPassed := Abs(EFTTransactionRequest."Result Amount") = Abs(ReconciliationLine."Amount (TCY)")
        else
            MatchValidationPassed := EFTTransactionRequest."Result Amount" = ReconciliationLine."Amount (TCY)";

        MatchValidationPassed := MatchValidationPassed and EFTTransactionRequest."Financial Impact";

        if MatchValidationPassed then
            Success := true
        else begin
            if not Silent and GuiAllowed() then
                Error(ManualMatchTransactionError04, Format(EFTTransactionRequest."Entry No."))
            else
                _AdyenManagement.CreateReconciliationLog(_LogType::"Match Transactions", false, StrSubstNo(MatchTransactionsError01, Format(EFTTransactionRequest."Entry No.")), ReconciliationHeader."Webhook Request ID");
        end;
    end;

    local procedure CheckPostedOrReconciled(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; AdyenRecLineStatus: Enum "NPR Adyen Rec. Line Status"): Boolean
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        case AdyenRecLineStatus of
            AdyenRecLineStatus::Posted:
                begin
                    ReconciliationLine.SetFilter(Status, '<>%1&<>%2', ReconciliationLine.Status::Posted, ReconciliationLine.Status::"Not to be Posted");
                    if ReconciliationLine.IsEmpty() then begin
                        _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", true, StrSubstNo(PostTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
                        ReconciliationHeader.Status := ReconciliationHeader.Status::Posted;
                        ReconciliationHeader."Failed Lines Exist" := false;
                        ReconciliationHeader.Modify();
                        exit(true);
                    end;
                end;
            AdyenRecLineStatus::Reconciled:
                begin
                    ReconciliationLine.SetFilter(Status, '<>%1&<>%2', ReconciliationLine.Status::Reconciled, ReconciliationLine.Status::"Not to be Reconciled");
                    if ReconciliationLine.IsEmpty() then begin
                        _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", true, StrSubstNo(ReconcileTransactionsSuccess01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
                        ReconciliationHeader.Status := ReconciliationHeader.Status::Reconciled;
                        ReconciliationHeader."Failed Lines Exist" := false;
                        ReconciliationHeader.Modify();
                        exit(true);
                    end;
                end;
        end;
    end;

    local procedure LinesToProcessExist(var ReconciliationLine: Record "NPR Adyen Recon. Line"; var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; AdyenRecLineStatus: Enum "NPR Adyen Rec. Line Status"): Boolean
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        case AdyenRecLineStatus of
            AdyenRecLineStatus::Reconciled:
                begin
                    ReconciliationLine.SetFilter(Status, '%1|%2|%3', ReconciliationLine.Status::Matched, ReconciliationLine.Status::"Not to be Matched", ReconciliationLine.Status::"Failed to Reconcile");
                    if not ReconciliationLine.IsEmpty() then
                        exit(true);
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Reconcile Transactions", false, StrSubstNo(ReconcileTransactionsError01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
                end;
            AdyenRecLineStatus::Posted:
                begin
                    ReconciliationLine.SetFilter(Status, '%1|%2|%3|%4|%5|%6', ReconciliationLine.Status::Matched, ReconciliationLine.Status::"Not to be Matched", ReconciliationLine.Status::Reconciled, ReconciliationLine.Status::"Not to be Reconciled", ReconciliationLine.Status::"Failed to Reconcile", ReconciliationLine.Status::"Failed to Post");
                    if not ReconciliationLine.IsEmpty() then
                        exit(true);
                    _AdyenManagement.CreateReconciliationLog(_LogType::"Post Transactions", false, StrSubstNo(PostTransactionsError01, ReconciliationHeader."Document No."), ReconciliationHeader."Webhook Request ID");
                end;
        end;
    end;

    internal procedure CalculateAmsterdamToUTCOffset(ParsedDateTime: DateTime): Integer
    var
        StandardOffset: Integer;
        DSTOffset: Integer;
        StartDST: Date;
        EndDST: Date;
        Year: Integer;
    begin
        // Define the standard and DST offsets
        StandardOffset := 1; // UTC+1
        DSTOffset := 2;      // UTC+2

        // Example: DST starts last Sunday in March, ends last Sunday in October
        Year := Date2DMY(DT2Date(ParsedDateTime), 3);

        StartDST := CALCDATE('<+1D-WD7>', DMY2Date(31, 3, Year)); // Last Sunday of March
        EndDST := CALCDATE('<+1D-WD7>', DMY2Date(31, 10, Year)); // Last Sunday of October

        if (ParsedDateTime >= CreateDateTime(StartDST, 020000T)) and (ParsedDateTime < CreateDateTime(EndDST, 030000T)) then
            exit(DSTOffset)
        else
            exit(StandardOffset);
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
        GetReportError02: Label 'Webhook request with ID %1 does not have a Report Download URL.\Please contact your System Administrator.';
        ImportLinesError01: Label 'Report ''%1'' has no entries. Report Data exist - %2';
        ImportLinesError02: Label 'Report ''%1'' has no transactions within Merchant Account ''%2''.';
        ImportLinesError03: Label 'Unsupported Journal Type: %1.\Entry was skipped.';
        ImportLinesSuccess01: Label 'NP Pay Reconciliation Document %1 was successfully created with %2 transaction entries.';
        MatchTransactionsError01: Label 'Failed to match with EFT Transaction Request No. %1 because one of the conditions failed:\\ -Amounts aren''t equal.\\ -EFT Transaction Request has no Financial Impact.';
        MatchTransactionsError02: Label 'NP Pay Reconciliation Document %1 does not contain any transactions within Marchant Account ''%2''.';
        MatchTransactionsError03: Label 'Couldn''t match %1 entries in NP Pay Reconciliation Document %2.';
        MatchTransactionsError04: Label 'Failed to match with Magento Payment Line (Document Type: %1, Document No.: %2, Document Line No.: %3) because one of the conditions failed:\\ -Amounts aren''t equal.';
        MatchTransactionsError05: Label 'EFT Transaction Request was found, however the POS Entry Payment Line does not exist. Please check if the Sale is posted.';
        MatchTransactionsError06: Label 'PSP Reference is empty.';
        MatchTransactionsError08: Label 'Failed to match with Subscription Payment Request No. %1 because one of the conditions failed:\\ -Amounts aren''t equal.\\ -Subscription Payment Request status is either Canceled or Rejected.';
        MatchTransactionsSuccess01: Label 'Successfully matched entries in NP Pay Reconciliation Document %1.';
        PostTransactionsError01: Label 'Couldn''t find any matched transactions to post in NP Pay Reconciliation Document %1.';
        ReconcileTransactionsError01: Label 'Couldn''t find any matched transactions to reconcile in NP Pay Reconciliation Document %1.';
        PostTransactionsEFTError01: Label 'EFT Transaction Request %1 does not exist.';
        PostTransactionsMagentoError01: Label 'Magento Payment Line %1 does not exist.';
        PostTransactionsSubscriptionError01: Label 'Subscription Payment Request %1 does not exist.';
        PostTransactionsError03: Label 'Couldn''t post %1 entries in NP Pay Reconciliation Document %2.';
        ReconcileTransactionsError02: Label 'Couldn''t reconcile %1 entries in NP Pay Reconciliation Document %2.';
        PostTransactionsSuccess01: Label 'Successfully posted entries in NP Pay Reconciliation Document %1.';
        ReconcileTransactionsSuccess01: Label 'Successfully reconciled entries in NP Pay Reconciliation Document %1.';
        NoSeriesError01: Label 'No. Series in NP Pay Setup is not specified.';
        NoSeriesError02: Label 'Numbers are configured incorrectly for No. Series %1.';
        TransactionNotMatchedLbl: Label 'Transaction %1 is not matched yet.';
}

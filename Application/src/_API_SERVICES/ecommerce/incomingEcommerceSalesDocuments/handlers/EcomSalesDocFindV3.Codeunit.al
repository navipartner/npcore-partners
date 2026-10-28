codeunit 6184583 "NPR EcomSalesDocFindV3"
{
    Access = Internal;

    var
        _GetById: Codeunit "NPR EcomSalesDocGetV3";

    internal procedure FindIncomingEcomDocumentsByEmail(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        ResponseJson: Codeunit "NPR Json Builder";
        RecRef: RecordRef;
        EmailFieldRef: FieldRef;
        DataFound: Boolean;
        MoreRecords: Boolean;
        PageContinuation: Boolean;
        WithDetails: Boolean;
        EmailFieldNo: Integer;
        EmittedCount: Integer;
        Limit: Integer;
        Email: Text;
        EmailParamName: Text;
        InvoiceEmail: Text;
        PageKey: Text;
    begin
        Request.SkipCacheIfNonStickyRequest(_GetById.GetReadTableIds());

        if (Request.QueryParams().ContainsKey('email')) then
            Email := Request.QueryParams().Get('email').Trim();
        if (Request.QueryParams().ContainsKey('invoiceEmail')) then
            InvoiceEmail := Request.QueryParams().Get('invoiceEmail').Trim();

        if (Email = '') and (InvoiceEmail = '') then
            exit(Response.RespondBadRequest('Missing required parameter: email or invoiceEmail'));
        if (Email <> '') and (InvoiceEmail <> '') then
            exit(Response.RespondBadRequest('Only one of email and invoiceEmail may be given'));

        if (InvoiceEmail <> '') then begin
            Email := InvoiceEmail;
            EmailParamName := 'invoiceEmail';
            EmailFieldNo := EcomSalesHeader.FieldNo("Sell-to Invoice Email");
        end else begin
            EmailParamName := 'email';
            EmailFieldNo := EcomSalesHeader.FieldNo("Sell-to Email");
        end;

        if (StrLen(Email) > MaxStrLen(EcomSalesHeader."Sell-to Email")) then
            exit(Response.RespondBadRequest('Malformed parameter: ' + EmailParamName));

        if (Request.QueryParams().ContainsKey('withDetails')) then
            WithDetails := (Request.QueryParams().Get('withDetails').ToLower() = 'true');

        Limit := 100;
        if (Request.QueryParams().ContainsKey('pageSize')) then
            if not Evaluate(Limit, Request.QueryParams().Get('pageSize')) then
                exit(Response.RespondBadRequest('Malformed parameter: pageSize'));
        if (Limit < 1) then
            Limit := 100;
        if (Limit > 100) then
            Limit := 100;

        EcomSalesHeader.ReadIsolation := EcomSalesHeader.ReadIsolation::ReadCommitted;
        if (EmailFieldNo = EcomSalesHeader.FieldNo("Sell-to Invoice Email")) then
            EcomSalesHeader.SetCurrentKey("Sell-to Invoice Email", SystemCreatedAt)
        else
            EcomSalesHeader.SetCurrentKey("Sell-to Email", SystemCreatedAt);
        EcomSalesHeader.Ascending(false);

        RecRef.GetTable(EcomSalesHeader);
        if (Request.QueryParams().ContainsKey('pageKey')) then begin
            Request.ApplyPageKey(Request.QueryParams().Get('pageKey'), RecRef);
            PageContinuation := true;
        end;
        // The page key carries a caller-supplied view, so the requested e-mail is imposed after it.
        EmailFieldRef := RecRef.Field(EmailFieldNo);
        EmailFieldRef.SetRange(EcomSalesDocUtils.NormalizeEmail(Email));
        if (not WithDetails) then
            RecRef.SetLoadFields(
                EcomSalesHeader.FieldNo("External No."), EcomSalesHeader.FieldNo("External Document No."), EcomSalesHeader.FieldNo("Document Type"),
                EcomSalesHeader.FieldNo("Creation Status"), EcomSalesHeader.FieldNo("Posting Status"), EcomSalesHeader.FieldNo("Capture Processing Status"),
                EcomSalesHeader.FieldNo("Currency Code"), EcomSalesHeader.FieldNo("Created Doc No."), EcomSalesHeader.FieldNo("Sell-to Customer No."),
                EcomSalesHeader.FieldNo("Sell-to Name"), EcomSalesHeader.FieldNo("Sell-to Email"), EcomSalesHeader.FieldNo("Sell-to Invoice Email"),
                EcomSalesHeader.FieldNo("Sell-to Phone No."));
        RecRef.ReadIsolation := IsolationLevel::ReadCommitted;

        ResponseJson.StartObject('').StartArray('salesDocuments');
        if (PageContinuation) then
            DataFound := RecRef.Find('>')
        else
            DataFound := RecRef.Find('-');
        if (DataFound) then
            repeat
                RecRef.SetTable(EcomSalesHeader);
                ResponseJson.StartObject();
                if (WithDetails) then
                    _GetById.AddSalesDocumentProperties(EcomSalesHeader, ResponseJson, false)
                else
                    AddSalesDocumentSummaryProperties(EcomSalesHeader, ResponseJson);
                ResponseJson.EndObject();
                EmittedCount += 1;
                if (EmittedCount = Limit) then
                    PageKey := Request.GetPageKey(RecRef);
                MoreRecords := RecRef.Next() <> 0;
            until (not MoreRecords) or (EmittedCount = Limit);
        ResponseJson.EndArray();

        if (not MoreRecords) then
            PageKey := '';
        ResponseJson.AddProperty('morePages', MoreRecords)
                    .AddProperty('nextPageKey', PageKey)
                    .AddProperty('nextPageURL', Request.GetNextPageUrl(PageKey, true))
                    .EndObject();

        exit(Response.RespondOK(ResponseJson));
    end;

    local procedure AddSalesDocumentSummaryProperties(EcomSalesHeader: Record "NPR Ecom Sales Header"; var IncSalesDocumentJsonObject: Codeunit "NPR Json Builder")
    begin
        IncSalesDocumentJsonObject.AddProperty('externalNo', EcomSalesHeader."External No.")
                                 .AddProperty('id', Format(EcomSalesHeader.SystemId, 0, 4).ToLower())
                                 .AddProperty('documentType', _GetById.GetSalesDocumentApiType(EcomSalesHeader))
                                 .AddProperty('creationStatus', _GetById.GetSalesDocumentCreationStatusApiType(EcomSalesHeader))
                                 .AddProperty('postingStatus', _GetById.GetSalesDocumentPostingStatusApiType(EcomSalesHeader))
                                 .AddProperty('currencyCode', EcomSalesHeader."Currency Code")
                                 .AddProperty('externalDocumentNo', EcomSalesHeader."External Document No.")
                                 .AddProperty('captureProcessingStatus', _GetById.GetSalesDocumentCaptureProcessingStatusApiType(EcomSalesHeader))
                                 .AddProperty('createdAt', EcomSalesHeader.SystemCreatedAt)
                                 .AddProperty('createdDocumentNo', EcomSalesHeader."Created Doc No.");

        _GetById.AddPostedDocumentNos(EcomSalesHeader, IncSalesDocumentJsonObject);

        IncSalesDocumentJsonObject.StartObject('sellToCustomer')
                                    .AddProperty('no', EcomSalesHeader."Sell-to Customer No.")
                                    .AddProperty('name', EcomSalesHeader."Sell-to Name")
                                    .AddProperty('email', EcomSalesHeader."Sell-to Email")
                                    .AddProperty('phone', EcomSalesHeader."Sell-to Phone No.")
                                .EndObject();
    end;
}

codeunit 6014658 "NPR Rep. Get Customers" implements "NPR Replication IEndpoint Meth"
{
    Access = Internal;

    var
        DefaultFileNameLbl: Label 'GetCustomers_%1', Comment = '%1=Current Date and Time';
        ImageCouldNotBeReadErr: Label 'Image for Customer %1 could not be read. Please check Replication Error Log Entry No. %2 for more details';

    procedure SendRequest(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
    begin
        GetCustomers(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure GetCustomers(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; var URI: Text; var NextLinkURI: Text)
    var
        ReplicationAPI: Codeunit "NPR Replication API";
    begin
        // each entity can have it's own 'Get' logic, but mostly should be the same, so code stays in Replication API codeunit
        URI := ReplicationAPI.CreateURI(ReplicationSetup, ReplicationEndPoint, NextLinkURI);
        ReplicationAPI.GetBCAPIResponse(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    procedure ProcessImportedContent(Content: Codeunit "Temp Blob"; ReplicationEndPoint: Record "NPR Replication Endpoint"): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        JTokenMainObject: JsonToken;
        JArrayValues: JsonArray;
        JTokenEntity: JsonToken;
        i: integer;
    begin
        // each entity can have it's own 'Process' logic, but mostly should be the same, so part of code stays in Replication API codeunit
        IF Not ReplicationAPI.GetJTokenMainObjectFromContent(Content, JTokenMainObject) THEN
            exit;

        IF NOT ReplicationAPI.GetJsonArrayFromJsonToken(JTokenMainObject, '$.value', JArrayValues) then
            exit;

        for i := 0 to JArrayValues.Count - 1 do begin
            JArrayValues.Get(i, JTokenEntity);
            HandleArrayElementEntity(JTokenEntity, ReplicationEndPoint);
        end;

        ReplicationAPI.UpdateReplicationCounter(JTokenEntity, ReplicationEndPoint);
    end;

    local procedure HandleArrayElementEntity(JToken: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint")
    var
        Customer: Record Customer;
        ReplicationAPI: Codeunit "NPR Replication API";
        RecFoundBySystemId: Boolean;
        CustNo: Code[20];
        CustId: Text;
    begin
        IF Not ReplicationAPI.CheckEntityReplicationCounter(JToken, ReplicationEndPoint) then
            exit;

        CustNo := COPYSTR(ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.number'), 1, MaxStrLen(CustNo));
        CustId := ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.id');

        IF CustId <> '' then
            IF Customer.GetBySystemId(CustId) then begin
                RecFoundBySystemId := true;
                If Customer."No." <> CustNo then // rename!
                    if NOT Customer.Rename(CustNo) then // maybe another rec with same pk already exists...
                        RecFoundBySystemId := false;
            end;

        IF Not RecFoundBySystemId then
            IF NOT Customer.Get(CustNo) then
                InsertNewRec(Customer, CustNo, CustId);

        IF CheckFieldsChanged(Customer, JToken, ReplicationEndPoint) then
            Customer.Modify(true);
    end;

    local procedure CheckFieldsChanged(var Customer: Record Customer; JToken: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint") FieldsChanged: Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        PictureJToken: JsonToken;
    begin
        IF CheckFieldValue(Customer, Customer.FieldNo(Name), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Name 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.displayName2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Contact Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.type'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo(Address), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.addressLine1'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Address 2"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.addressLine2'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo(City), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.city'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo(County), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.state'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Country/Region Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.country'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Post Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.postalCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Phone No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.phoneNumber'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("E-Mail"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.email'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Home Page"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.website'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Tax Liable"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.taxLiable'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Tax Area ID"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.taxAreaId'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Tax Area Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.taxAreaCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("VAT Registration No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.taxRegistrationNumber'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Currency Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.currencyCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Payment Terms Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.paymentTermsCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Shipment Method Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.shipmentMethodCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Payment Method Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.paymentMethodCode'), true) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo(Blocked), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.blocked'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Responsibility Center"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.responsibilityCenter'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Privacy Blocked"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.privacyBlocked'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Document Sending Profile"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.documentSendingProfile'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("IC Partner Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.icPartnerCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Salesperson Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.salespersonCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Location Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.locationCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Invoice Copies"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.invoiceCopies'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Global Dimension 1 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension1Code'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Global Dimension 2 Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.globalDimension2Code'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Gen. Bus. Posting Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.genBusPostingGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Customer Posting Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.customerPostingGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("VAT Bus. Posting Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.vatBusPostingGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Customer Price Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.customerPriceGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Invoice Disc. Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.invoiceDiscCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Prices Including VAT"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.pricesIncludingVAT'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Customer Disc. Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.customerDiscGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Allow Line Disc."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.allowLineDisc'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Language Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.languageCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Combine Shipments"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.combineShipments'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo(GLN), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.gln'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Credit Limit (LCY)"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.creditLimitLCY'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Prepayment %"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.prepaymentPct'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Application Method"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.applicationMethod'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Partner Type"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.partnerType'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Reminder Terms Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.reminderTermsCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Fin. Charge Terms Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.finChargeTermsCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Block Payment Tolerance"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.blockPaymentTolerance'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("Bill-to Customer No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.billToCustomerNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR Anonymized"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprAnonymized'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR Anonymized Date"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprAnonymizedDate'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR External Customer No."), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprExternalCustomerNo'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR Magento Display Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMagentoDisplayGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR Magento Payment Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMagentoPaymentGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR Magento Shipping Group"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMagentoShippingGroup'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR Magento Store Code"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprMagentoStoreCode'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR To Anonymize"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprToAnonymize'), false) then
            FieldsChanged := true;

        IF CheckFieldValue(Customer, Customer.FieldNo("NPR To Anonymize On"), ReplicationAPI.SelectJsonToken(JToken.AsObject(), '$.nprToAnonymizeOn'), false) then
            FieldsChanged := true;

        IF STRPOS(ReplicationEndPoint.Path, 'picture') > 0 then
            IF JToken.SelectToken('$.picture', PictureJToken) then
                If CheckImage(PictureJToken, Customer, ReplicationEndPoint) then
                    FieldsChanged := true;
    end;

    local procedure CheckFieldValue(var Customer: Record Customer; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean): Boolean
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        DataTypMgmt: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypMgmt.GetRecordRef(Customer, RecRef) then
            exit;

        IF ReplicationAPI.CheckFieldValue(RecRef, FieldNo, SourceTxt, WithValidation) then begin
            RecRef.SetTable(Customer);
            exit(true);
        end;
    end;

    local procedure CheckImage(PictureJToken: JsonToken; var Customer: Record Customer; ReplicationEndPoint: Record "NPR Replication Endpoint"): Boolean
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ErrLog: Record "NPR Replication Error Log";
        TempCust: Record Customer temporary;
        ReplicationAPI: Codeunit "NPR Replication API";
        Response: Codeunit "Temp Blob";
        Client: HttpClient;
        StatusCode: Integer;
        NewImageIStr: InStream;
        TempBlobNewImage: Codeunit "Temp Blob";
        TempBlobExistingImage: Codeunit "Temp Blob";
        NewImageURL: Text;
        MimeType: Text;
        ImageWidth: Integer;
        ImageHeight: Integer;
    begin
        NewImageURL := ReplicationAPI.SelectJsonToken(PictureJToken.AsObject(), '$.[''pictureContent@odata.mediaReadLink'']');
        IF NewImageURL = '' then
            Exit(false);

        IF EValuate(ImageWidth, ReplicationAPI.SelectJsonToken(PictureJToken.AsObject(), '$.width')) then;
        IF Evaluate(ImageHeight, ReplicationAPI.SelectJsonToken(PictureJToken.AsObject(), '$.height')) then;
        MimeType := ReplicationAPI.SelectJsonToken(PictureJToken.AsObject(), '$.contentType');

        IF (ImageWidth > 0) AND (ImageHeight > 0) and (MimeType <> '') then begin
            ServiceSetup.Get(ReplicationEndPoint."Service Code");
            ReplicationAPI.GetBCAPIResponseImage(ServiceSetup, ReplicationEndPoint, Client, Response, StatusCode, NewImageURL);

            IF ReplicationAPI.FoundErrorInResponse(Response, StatusCode) then begin
                ErrLog.InsertLog(ReplicationEndPoint."Service Code", ReplicationEndPoint."EndPoint ID", 'GET', NewImageURL, Response);
                Commit();
                Error(ImageCouldNotBeReadErr, Customer."No.", ErrLog."Entry No.");
            end;

            Response.CreateInStream(NewImageIStr);
            UpdateImage(TempCust, NewImageIStr, MimeType);
            ReadImage(TempCust, TempBlobNewImage); // if use directly the InStream data(without read from temptable) sometimes the hash of 2 same png images is different.
            ReadImage(Customer, TempBlobExistingImage);

            If ReplicationAPI.GetImageHash(TempBlobNewImage) <> ReplicationAPI.GetImageHash(TempBlobExistingImage) then begin
                UpdateImage(Customer, NewImageIStr, MimeType);
                Exit(true);
            end;
        end else begin // no image
            if Customer.Image.HasValue THEN begin
                Clear(Customer.Image); // remove existing image
                Exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure ReadImage(var Customer: Record Customer; var TempBlob: Codeunit "Temp Blob")
    var
        OStr: OutStream;

    begin
        IF Customer.Image.HasValue then begin
            TempBlob.CreateOutStream(OStr);
            Customer.Image.ExportStream(OStr);
        end;
    end;

    local procedure UpdateImage(var Customer: Record Customer; IStr: InStream; MimeType: Text)
    begin
        Clear(Customer.Image);
        Customer.Image.ImportStream(IStr, Customer.Name, MimeType);
    end;

    local procedure InsertNewRec(var Customer: Record Customer; CustNo: Text[20]; CustId: text)
    begin
        Customer.Init();
        Customer."No." := CustNo;
        IF CustId <> '' THEN begin
            IF Evaluate(Customer.SystemId, CustId) Then
                Customer.Insert(false, true)
            Else
                Customer.Insert(false);
        end else
            Customer.Insert(false);
    end;

    procedure GetDefaultFileName(ServiceEndPoint: Record "NPR Replication Endpoint"): Text
    begin
        exit(StrSubstNo(DefaultFileNameLbl, format(Today(), 0, 9)));
    end;

    procedure CheckResponseContainsData(Content: Codeunit "Temp Blob"): Boolean;
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        JTokenMainObject: JsonToken;
        JArrayValues: JsonArray;
    begin
        IF Not ReplicationAPI.GetJTokenMainObjectFromContent(Content, JTokenMainObject) THEN
            exit(false);

        IF NOT ReplicationAPI.GetJsonArrayFromJsonToken(JTokenMainObject, '$.value', JArrayValues) then
            exit(false);

        Exit(JArrayValues.Count > 0);
    end;

}
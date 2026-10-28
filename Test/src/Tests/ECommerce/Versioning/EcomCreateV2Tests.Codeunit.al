codeunit 85578 "NPR Ecom Create V2 Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _LibAPI: Codeunit "NPR Library - NPRetail API";
        _EcomApiPermissionSetLbl: Label 'NPR API Ecom', Locked = true;
        _ApiVersionHeaderLbl: Label 'x-api-version', Locked = true;

    [Test]
    procedure GivenV2Header_WhenCreate_ThenAnswers200WithOnlyTheId()
    var
        ResponseBody: JsonObject;
        ResponseJson: JsonObject;
        IdToken: JsonToken;
        ExternalNo: Code[20];
        Id: Guid;
    begin
        // [Scenario] Creating a document under the V2 date answers 200 and the body carries the id of the
        //            stored document and nothing else.

        // [Given] The API permission and a create request that names the V2 date
        GrantEcomApiPermission();
        ExternalNo := _LibEcom.NextExternalNo('CRTV2A');

        // [When] The request is routed through POST ecommerce/documents
        ResponseJson := PostDocument(ExternalNo, '2025-10-19');

        // [Then] The answer is 200 and the body holds exactly the property id, a lowercase GUID
        _Assert.AreEqual(200, StatusCodeOf(ResponseJson), 'A create request under the V2 date must answer HTTP 200.');
        ResponseBody := _LibAPI.GetResponseBody(ResponseJson);
        ResponseBody.Remove('customFields');
        _Assert.AreEqual(1, ResponseBody.Keys().Count(), 'The create response must carry exactly one property.');
        _Assert.IsTrue(ResponseBody.Get('id', IdToken), 'The create response must carry the property id.');
        _Assert.IsTrue(Evaluate(Id, IdToken.AsValue().AsText()), 'The id must be a GUID.');
        _Assert.AreEqual(LowerCase(Format(Id, 0, 4)), IdToken.AsValue().AsText(), 'The id must be the lowercase GUID without braces.');
        _Assert.AreEqual(IdToken.AsValue().AsText(), IdOf(HeaderOf(ExternalNo)), 'The id must be the system id of the stored document.');
    end;

    [Test]
    procedure GivenHeaderDate_WhenCreate_ThenStoresRequestedAndProcessingDates()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ResponseJson: JsonObject;
        ExternalNo: Code[20];
    begin
        // [Scenario] The stored document keeps the date the caller asked for next to the date the code processed it under.

        // [Given] The API permission and a create request that names a date later than V2
        GrantEcomApiPermission();
        ExternalNo := _LibEcom.NextExternalNo('CRTV2B');

        // [When] The request is routed through POST ecommerce/documents
        ResponseJson := PostDocument(ExternalNo, '2026-10-26');

        // [Then] The requested date is stored as sent and the processing date is the V2 date
        _Assert.AreEqual(200, StatusCodeOf(ResponseJson), 'A create request under a later date must answer HTTP 200.');
        EcomSalesHeader := HeaderOf(ExternalNo);
        _Assert.AreEqual(20261026D, EcomSalesHeader."Requested API Version Date", 'The requested API version date must be stored as sent.');
        _Assert.AreEqual(20251019D, EcomSalesHeader."API Version Date", 'The processing API version date must be the V2 date.');
    end;

    [Test]
    procedure GivenMalformedHeader_WhenCreate_ThenAnswers400AndWritesNothing()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ResponseJson: JsonObject;
        ExternalNo: Code[20];
    begin
        // [Scenario] A version header that is not a date is refused and no document is stored.

        // [Given] The API permission and a create request whose version header is not a date
        GrantEcomApiPermission();
        ExternalNo := _LibEcom.NextExternalNo('CRTV2C');

        // [When] The request is routed through POST ecommerce/documents
        ResponseJson := PostDocument(ExternalNo, 'not-a-date');

        // [Then] The answer is 400 and no ecommerce document carries the external no.
        _Assert.AreEqual(400, StatusCodeOf(ResponseJson), 'A version header that is not a date must answer HTTP 400.');
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'A refused request must leave no document behind.');
    end;

    local procedure PostDocument(ExternalNo: Code[20]; ApiVersion: Text) ResponseJson: JsonObject
    var
        Body: JsonObject;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
    begin
        Body := BuildBody(ExternalNo);
        Headers.Add(_ApiVersionHeaderLbl, ApiVersion);
        Commit();
        ResponseJson := _LibAPI.CallApi('POST', 'ecommerce/documents', Body, QueryParams, Headers);
    end;

    local procedure BuildBody(ExternalNo: Code[20]) Body: JsonObject
    var
        Line: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
    begin
        Body := _LibEcom.BuildEcomDocumentBody(ExternalNo, 'order', '');
        Line.Add('type', 'item');
        Line.Add('no', _LibEcom.CreateItem());
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
    end;

    local procedure HeaderOf(ExternalNo: Code[20]) EcomSalesHeader: Record "NPR Ecom Sales Header"
    begin
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        EcomSalesHeader.FindFirst();
    end;

    local procedure IdOf(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    begin
        exit(LowerCase(Format(EcomSalesHeader.SystemId, 0, 4)));
    end;

    local procedure StatusCodeOf(ResponseJson: JsonObject) StatusCode: Integer
    var
        Token: JsonToken;
    begin
        if ResponseJson.Get('statusCode', Token) then
            StatusCode := Token.AsValue().AsInteger();
    end;

    local procedure GrantEcomApiPermission()
    begin
        _LibAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), CopyStr(_EcomApiPermissionSetLbl, 1, 20));
    end;
}

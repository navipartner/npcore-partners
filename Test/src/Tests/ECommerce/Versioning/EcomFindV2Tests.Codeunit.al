codeunit 85580 "NPR Ecom Find V2 Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibDocApi: Codeunit "NPR Library Ecom Doc Api";
        _V2DateLbl: Label '2025-10-19', Locked = true;
        _LaterDateLbl: Label '2026-10-26', Locked = true;
        _AtVersionLbl: Label '%1 (x-api-version %2)', Locked = true;
        _PagingKeysLbl: Label 'morePages,nextPageKey,nextPageURL', Locked = true;

    [Test]
    procedure GivenMatchingDocument_WhenSummaryFindV2_ThenHitAndEnvelopeKeysArePinned()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] A find without withDetails answers the V2 envelope and a summary hit with a fixed key order.

        // [Given] The API permission and a document with a note, a payment and three lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is found by its e-mail under the V2 date and under a later date before V3
        // [Then] The envelope and the hit carry the pinned keys
        AssertSummaryPinned(EcomSalesHeader, _V2DateLbl);
        AssertSummaryPinned(EcomSalesHeader, _LaterDateLbl);
    end;

    [Test]
    procedure GivenFullDocument_WhenDetailedFindV2_ThenHitEqualsGetByIdWithoutPayments()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] A detailed find answers the get-by-id document minus its payments array.

        // [Given] The API permission and a document with a note, a card payment, dimensions and three lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is found with withDetails=true under the V2 date and under a later date before V3
        // [Then] The hit equals the get-by-id body without payments
        AssertDetailedHitEqualsGetById(EcomSalesHeader, _V2DateLbl);
        AssertDetailedHitEqualsGetById(EcomSalesHeader, _LaterDateLbl);
    end;

    [Test]
    procedure GivenFindCases_WhenFindV3IsCompared_ThenItAnswersLikeFindV2()
    var
        FirstHeader: Record "NPR Ecom Sales Header";
        SecondHeader: Record "NPR Ecom Sales Header";
        ThirdHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
        Email: Text;
        InvoiceEmail: Text;
        PageKey: Text;
        Tag: Text;
    begin
        // [Scenario] Find V3 answers every summary find like Find V2: the same status and the same text, paging
        //            fields included, for matching, order, page size, continuation and the 400 answers.

        // [Given] Three committed documents created one after another under one e-mail, each with the same invoice e-mail
        Tag := DelChr(Format(CreateGuid()), '=', '{}-').ToLower();
        Email := 'versioning.parity.' + Tag + '@versioning.test';
        InvoiceEmail := 'versioning.parity.invoice.' + Tag + '@versioning.test';
        CreateWithInvoiceEmail(Email, InvoiceEmail, FirstHeader);
        CreateWithInvoiceEmail(Email, InvoiceEmail, SecondHeader);
        CreateWithInvoiceEmail(Email, InvoiceEmail, ThirdHeader);

        // [When] Both versions find the e-mail written in upper case
        // [Then] Both answer the same text, the three documents newest first
        QueryParameters.Add('email', UpperCase(Email));
        Body := AssertFindV3AnswersLikeFindV2(QueryParameters, 200, 'email in upper case');
        AssertHitIds(Body, ThirdHeader, SecondHeader, FirstHeader, 'email in upper case');

        // [When] Both versions find the invoice e-mail
        // [Then] Both answer the same text, the three documents newest first
        Clear(QueryParameters);
        QueryParameters.Add('invoiceEmail', InvoiceEmail);
        Body := AssertFindV3AnswersLikeFindV2(QueryParameters, 200, 'invoiceEmail');
        AssertHitIds(Body, ThirdHeader, SecondHeader, FirstHeader, 'invoiceEmail');

        // [When] Both versions find the e-mail with a page size of two
        // [Then] Both answer the same first page, which reports more pages
        Clear(QueryParameters);
        QueryParameters.Add('email', Email);
        QueryParameters.Add('pageSize', '2');
        Body := AssertFindV3AnswersLikeFindV2(QueryParameters, 200, 'pageSize 2');
        _Assert.AreEqual(2, _LibDocApi.ArrayAt(Body, 'salesDocuments').Count(), 'pageSize 2: the first page must hold two documents.');
        _Assert.AreEqual('true', ValueText(Body, 'morePages'), 'pageSize 2: the first page must report more pages.');
        PageKey := _LibDocApi.TextAt(Body, 'nextPageKey');
        _Assert.AreNotEqual('', PageKey, 'pageSize 2: the first page must carry a page key.');

        // [When] Both versions continue with the first page's key
        // [Then] Both answer the same last page, holding the oldest document
        Clear(QueryParameters);
        QueryParameters.Add('email', Email);
        QueryParameters.Add('pageKey', PageKey);
        Body := AssertFindV3AnswersLikeFindV2(QueryParameters, 200, 'pageKey');
        _Assert.AreEqual(1, _LibDocApi.ArrayAt(Body, 'salesDocuments').Count(), 'pageKey: the last page must hold one document.');
        _Assert.AreEqual(IdOf(FirstHeader), _LibDocApi.TextAt(_LibDocApi.ElementAt(_LibDocApi.ArrayAt(Body, 'salesDocuments'), 0), 'id'), 'pageKey: the last page must hold the oldest document.');
        _Assert.AreEqual('false', ValueText(Body, 'morePages'), 'pageKey: the last page must not report more pages.');

        // [When] Both versions get both e-mail parameters, a blank e-mail, and an e-mail longer than 80 characters
        // [Then] Both refuse each with the same 400 answer
        Clear(QueryParameters);
        QueryParameters.Add('email', Email);
        QueryParameters.Add('invoiceEmail', InvoiceEmail);
        Body := AssertFindV3AnswersLikeFindV2(QueryParameters, 400, 'both e-mails');
        _Assert.AreEqual('Only one of email and invoiceEmail may be given', _LibDocApi.TextAt(Body, 'message'), 'both e-mails: refusal message');

        Clear(QueryParameters);
        QueryParameters.Add('email', '   ');
        Body := AssertFindV3AnswersLikeFindV2(QueryParameters, 400, 'whitespace e-mail');
        _Assert.AreEqual('Missing required parameter: email or invoiceEmail', _LibDocApi.TextAt(Body, 'message'), 'whitespace e-mail: refusal message');

        Clear(QueryParameters);
        QueryParameters.Add('email', PadStr('', 81 - StrLen('@versioning.test'), 'a') + '@versioning.test');
        Body := AssertFindV3AnswersLikeFindV2(QueryParameters, 400, 'e-mail longer than 80 characters');
        _Assert.AreEqual('Malformed parameter: email', _LibDocApi.TextAt(Body, 'message'), 'e-mail longer than 80 characters: refusal message');
    end;

    local procedure AssertSummaryPinned(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text)
    var
        Body: JsonObject;
        Hit: JsonObject;
        Documents: JsonArray;
    begin
        Body := FindBody(EcomSalesHeader, false, ApiVersion);
        _Assert.AreEqual(_LibDocApi.EnvelopeKeys(), _LibDocApi.KeysOf(Body), At('Envelope keys', ApiVersion));
        Documents := _LibDocApi.ArrayAt(Body, 'salesDocuments');
        _Assert.AreEqual(1, Documents.Count(), At('The e-mail must find exactly the seeded document.', ApiVersion));
        Hit := _LibDocApi.ElementAt(Documents, 0);
        _Assert.AreEqual(_LibDocApi.SummaryKeys(), _LibDocApi.KeysOf(Hit), At('Summary hit keys', ApiVersion));
        _Assert.AreEqual(_LibDocApi.SummarySellToKeys(), _LibDocApi.KeysOf(_LibDocApi.ObjectAt(Hit, 'sellToCustomer')), At('Summary sellToCustomer keys', ApiVersion));
        _Assert.AreEqual(EcomSalesHeader."External No.", _LibDocApi.TextAt(Hit, 'externalNo'), At('The hit must be the seeded document.', ApiVersion));
    end;

    local procedure AssertDetailedHitEqualsGetById(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text)
    var
        GetResponse: JsonObject;
        GetBody: JsonObject;
        Body: JsonObject;
        Hit: JsonObject;
        Documents: JsonArray;
    begin
        GetResponse := _LibDocApi.GetById(EcomSalesHeader.SystemId, ApiVersion, true);
        _Assert.AreEqual(200, _LibDocApi.StatusOf(GetResponse), At('A get by id of an existing document must answer HTTP 200.', ApiVersion));
        GetBody := _LibDocApi.BodyOf(GetResponse).Clone().AsObject();
        _Assert.IsTrue(GetBody.Contains('payments'), At('The get-by-id document must carry payments for the comparison to mean anything.', ApiVersion));
        GetBody.Remove('payments');

        Body := FindBody(EcomSalesHeader, true, ApiVersion);
        Documents := _LibDocApi.ArrayAt(Body, 'salesDocuments');
        _Assert.AreEqual(1, Documents.Count(), At('The e-mail must find exactly the seeded document.', ApiVersion));
        Hit := _LibDocApi.ElementAt(Documents, 0);
        _Assert.IsFalse(Hit.Contains('payments'), At('A detailed hit must not carry payments.', ApiVersion));
        _Assert.AreEqual(_LibDocApi.WithoutCustomFields(GetBody), _LibDocApi.WithoutCustomFields(Hit), At('A detailed hit must equal the get-by-id document without payments.', ApiVersion));
    end;

    local procedure FindBody(EcomSalesHeader: Record "NPR Ecom Sales Header"; WithDetails: Boolean; ApiVersion: Text) Body: JsonObject
    var
        Response: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        QueryParameters.Add('email', EcomSalesHeader."Sell-to Email");
        if WithDetails then
            QueryParameters.Add('withDetails', 'true');
        Response := _LibDocApi.Find(QueryParameters, ApiVersion, true);
        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A find must answer HTTP 200.', ApiVersion));
        Body := _LibDocApi.BodyOf(Response);
    end;

    local procedure AssertFindV3AnswersLikeFindV2(QueryParameters: Dictionary of [Text, Text]; ExpectedStatus: Integer; Context: Text) V2Body: JsonObject
    var
        FindV2: Codeunit "NPR EcomSalesDocFindV2";
        FindV3: Codeunit "NPR EcomSalesDocFindV3";
        V2Request: Codeunit "NPR API Request";
        V3Request: Codeunit "NPR API Request";
        V2Response: Codeunit "NPR API Response";
        V3Response: Codeunit "NPR API Response";
        V3Body: JsonObject;
        PagingKey: Text;
        PagingKeys: Text;
        V2Text: Text;
        V3Text: Text;
    begin
        // The find reads ReadCommitted, so the fixtures must be committed.
        Commit();
        InitFindRequest(QueryParameters, V2Request);
        InitFindRequest(QueryParameters, V3Request);
        V2Response := FindV2.FindIncomingEcomDocumentsByEmail(V2Request);
        V3Response := FindV3.FindIncomingEcomDocumentsByEmail(V3Request);

        _Assert.AreEqual(ExpectedStatus, V2Response.GetStatusCode(), Context + ': Find V2 status');
        _Assert.AreEqual(V2Response.GetStatusCode(), V3Response.GetStatusCode(), Context + ': Find V3 must answer Find V2''s status.');
        V2Body := V2Response.GetJson();
        V3Body := V3Response.GetJson();
        V2Body.WriteTo(V2Text);
        V3Body.WriteTo(V3Text);
        _Assert.AreEqual(V2Text, V3Text, Context + ': Find V3 must answer Find V2''s text.');

        if ExpectedStatus <> 200 then
            exit;
        PagingKeys := _PagingKeysLbl;
        foreach PagingKey in PagingKeys.Split(',') do
            _Assert.AreEqual(ValueText(V2Body, PagingKey), ValueText(V3Body, PagingKey), StrSubstNo('%1: Find V3 must answer Find V2''s %2.', Context, PagingKey));
    end;

    local procedure InitFindRequest(QueryParameters: Dictionary of [Text, Text]; var Request: Codeunit "NPR API Request")
    var
        EmptyBody: JsonToken;
        Headers: Dictionary of [Text, Text];
        RequestParameters: Dictionary of [Text, Text];
        PathSegments: List of [Text];
        ParameterName: Text;
    begin
        foreach ParameterName in QueryParameters.Keys() do
            RequestParameters.Add(ParameterName, QueryParameters.Get(ParameterName));
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        Request.Init("Http Method"::GET, '/ecommerce/documents', PathSegments, RequestParameters, Headers, EmptyBody);
    end;

    local procedure CreateWithInvoiceEmail(Email: Text; InvoiceEmail: Text; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        _LibDocApi.CreateDocument(Email, 0, 1, EcomSalesHeader);
        EcomSalesHeader."Sell-to Invoice Email" := CopyStr(InvoiceEmail, 1, MaxStrLen(EcomSalesHeader."Sell-to Invoice Email"));
        EcomSalesHeader.Modify();
        Commit();
    end;

    local procedure AssertHitIds(Body: JsonObject; FirstHit: Record "NPR Ecom Sales Header"; SecondHit: Record "NPR Ecom Sales Header"; ThirdHit: Record "NPR Ecom Sales Header"; Context: Text)
    var
        Hits: JsonArray;
    begin
        Hits := _LibDocApi.ArrayAt(Body, 'salesDocuments');
        _Assert.AreEqual(3, Hits.Count(), Context + ': the find must answer the three documents.');
        _Assert.AreEqual(IdOf(FirstHit), _LibDocApi.TextAt(_LibDocApi.ElementAt(Hits, 0), 'id'), Context + ': hit 1 must be the newest document.');
        _Assert.AreEqual(IdOf(SecondHit), _LibDocApi.TextAt(_LibDocApi.ElementAt(Hits, 1), 'id'), Context + ': hit 2 must be the middle document.');
        _Assert.AreEqual(IdOf(ThirdHit), _LibDocApi.TextAt(_LibDocApi.ElementAt(Hits, 2), 'id'), Context + ': hit 3 must be the oldest document.');
    end;

    local procedure ValueText(Object: JsonObject; KeyName: Text) Value: Text
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Object.Get(KeyName, Token), StrSubstNo('The object must carry %1.', KeyName));
        Token.WriteTo(Value);
    end;

    local procedure IdOf(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    begin
        exit(LowerCase(Format(EcomSalesHeader.SystemId, 0, 4)));
    end;

    local procedure At(Message: Text; ApiVersion: Text): Text
    begin
        exit(StrSubstNo(_AtVersionLbl, Message, ApiVersion));
    end;
}

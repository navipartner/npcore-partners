codeunit 85585 "NPR Ecom Doc Event Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibDocApi: Codeunit "NPR Library Ecom Doc Api";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _V2DateLbl: Label '2025-10-19', Locked = true;
        _AtVersionLbl: Label '%1 (x-api-version %2)', Locked = true;

    [Test]
    procedure GivenTwoPaymentsTwoLines_WhenGetById_ThenHeaderPaymentsLinesAreRaisedInOrder()
    begin
        // [Scenario] Get by id raises the header event once, then the payment event per payment line, then the
        //            line event per sales line, each in record order.
        // [Given] The API permission, a document with two payments and two lines, and the recording subscriber bound
        // [When] The document is read by id under the V2 date
        // [Then] The events were raised as H, P, P, L, L for this document's records
        AssertGetByIdRaisesInOrder(_V2DateLbl);
    end;

    [Test]
    procedure GivenTwoPaymentsTwoLines_WhenGetByIdV3_ThenHeaderPaymentsLinesAreRaisedInOrder()
    begin
        // [Scenario] Get by id under the V3 date raises the same sequence: header, payments, lines, each in record order.
        // [Given] The API permission, a document with two payments and two lines, and the recording subscriber bound
        // [When] The document is read by id under the V3 date
        // [Then] The events were raised as H, P, P, L, L for this document's records
        AssertGetByIdRaisesInOrder(V3Date());
    end;

    [Test]
    procedure GivenTwoHitsOfTwoLines_WhenDetailedFind_ThenHeaderAndLinesAreRaisedPerHit()
    begin
        // [Scenario] A detailed find raises, per hit in answer order, the header event and then the line event per
        //            line; it raises no payment event, because a detailed hit carries no payments.
        // [Given] The API permission, two documents under one e-mail, each with one payment and two lines, and the
        //         recording subscriber bound
        // [When] The e-mail is found with withDetails=true under the V2 date
        // [Then] The events were raised as H, L, L for the first hit and H, L, L for the second
        AssertDetailedFindRaisesPerHit(_V2DateLbl);
    end;

    [Test]
    procedure GivenTwoHitsOfTwoLines_WhenDetailedFindV3_ThenHeaderAndLinesAreRaisedPerHit()
    begin
        // [Scenario] A detailed find under the V3 date raises the same sequence: per hit, the header and then its lines,
        //            and no payment event.
        // [Given] The API permission, two documents under one e-mail, each with one payment and two lines, and the
        //         recording subscriber bound
        // [When] The e-mail is found with withDetails=true under the V3 date
        // [Then] The events were raised as H, L, L for the first hit and H, L, L for the second
        AssertDetailedFindRaisesPerHit(V3Date());
    end;

    [Test]
    procedure GivenDocument_WhenSummaryFind_ThenNoEventIsRaised()
    begin
        // [Scenario] A find without withDetails renders summaries only and raises none of the document read events.
        // [Given] The API permission, a document with one payment and two lines, and the recording subscriber bound
        // [When] The document is found by its e-mail under the V2 date
        // [Then] The find answers its one hit and no event was raised
        AssertSummaryFindRaisesNothing(_V2DateLbl);
    end;

    [Test]
    procedure GivenDocument_WhenSummaryFindV3_ThenNoEventIsRaised()
    begin
        // [Scenario] A find without withDetails under the V3 date raises none of the document read events either.
        // [Given] The API permission, a document with one payment and two lines, and the recording subscriber bound
        // [When] The document is found by its e-mail under the V3 date
        // [Then] The find answers its one hit and no event was raised
        AssertSummaryFindRaisesNothing(V3Date());
    end;

    [Test]
    procedure GivenDocument_WhenCreate_ThenCreateResponseEventIsRaisedOnceAndItsKeyAppears()
    begin
        // [Scenario] Creating a document raises the create-response event once, on the builder the answer is made
        //            from, and raises none of the document read events.
        // [Given] The API permission, a create request under the V2 date and the recording subscriber bound
        // [When] The request is routed through POST ecommerce/documents
        // [Then] The answer carries the key the subscriber added, the event was raised once and no read event was raised
        AssertCreateRaisesResponseEventOnce(_V2DateLbl);
    end;

    [Test]
    procedure GivenDocument_WhenCreateV3_ThenCreateResponseEventIsRaisedOnceAndItsKeyAppears()
    begin
        // [Scenario] Creating a document under the V3 date raises the create-response event once and no read event.
        // [Given] The API permission, a create request under the V3 date and the recording subscriber bound
        // [When] The request is routed through POST ecommerce/documents
        // [Then] The answer carries the key the subscriber added, the event was raised once and no read event was raised
        AssertCreateRaisesResponseEventOnce(V3Date());
    end;

    local procedure AssertGetByIdRaisesInOrder(ApiVersion: Text)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EventSubscriber: Codeunit "NPR Ecom Doc Event Subscriber";
        Response: JsonObject;
        Expected: Text;
    begin
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 2, 2, EcomSalesHeader);
        Expected := ExpectedSequence(EcomSalesHeader, true);
        BindSubscription(EventSubscriber);

        Response := _LibDocApi.GetById(EcomSalesHeader.SystemId, ApiVersion, true);
        UnbindSubscription(EventSubscriber);

        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A get by id of an existing document must answer HTTP 200.', ApiVersion));
        _Assert.AreEqual(Expected, EventSubscriber.Sequence(), At('Get by id must raise the header, payment and line events in this order.', ApiVersion));
    end;

    local procedure AssertDetailedFindRaisesPerHit(ApiVersion: Text)
    var
        FirstHeader: Record "NPR Ecom Sales Header";
        SecondHeader: Record "NPR Ecom Sales Header";
        HitHeader: Record "NPR Ecom Sales Header";
        EventSubscriber: Codeunit "NPR Ecom Doc Event Subscriber";
        Response: JsonObject;
        Hits: JsonArray;
        QueryParameters: Dictionary of [Text, Text];
        Email: Text;
        Expected: Text;
        HitId: Guid;
        i: Integer;
    begin
        _LibDocApi.GrantApiPermission();
        Email := NewEmail();
        _LibDocApi.CreateDocument(Email, 1, 2, FirstHeader);
        _LibDocApi.CreateDocument(Email, 1, 2, SecondHeader);
        BindSubscription(EventSubscriber);

        QueryParameters.Add('email', Email);
        QueryParameters.Add('withDetails', 'true');
        Response := _LibDocApi.Find(QueryParameters, ApiVersion, true);
        UnbindSubscription(EventSubscriber);

        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A find must answer HTTP 200.', ApiVersion));
        Hits := _LibDocApi.ArrayAt(_LibDocApi.BodyOf(Response), 'salesDocuments');
        _Assert.AreEqual(2, Hits.Count(), At('The e-mail must find both seeded documents.', ApiVersion));
        for i := 0 to Hits.Count() - 1 do begin
            Evaluate(HitId, _LibDocApi.TextAt(_LibDocApi.ElementAt(Hits, i), 'id'));
            HitHeader.GetBySystemId(HitId);
            if Expected <> '' then
                Expected += ',';
            Expected += ExpectedSequence(HitHeader, false);
        end;
        _Assert.AreNotEqual(_LibDocApi.TextAt(_LibDocApi.ElementAt(Hits, 0), 'id'), _LibDocApi.TextAt(_LibDocApi.ElementAt(Hits, 1), 'id'), At('The two hits must be the two seeded documents.', ApiVersion));
        _Assert.AreEqual(Expected, EventSubscriber.Sequence(), At('A detailed find must raise the header event and then the line events, hit by hit, and no payment event.', ApiVersion));
    end;

    local procedure AssertSummaryFindRaisesNothing(ApiVersion: Text)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EventSubscriber: Codeunit "NPR Ecom Doc Event Subscriber";
        Response: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 2, EcomSalesHeader);
        BindSubscription(EventSubscriber);

        QueryParameters.Add('email', EcomSalesHeader."Sell-to Email");
        Response := _LibDocApi.Find(QueryParameters, ApiVersion, true);
        UnbindSubscription(EventSubscriber);

        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A find must answer HTTP 200.', ApiVersion));
        _Assert.AreEqual(1, _LibDocApi.ArrayAt(_LibDocApi.BodyOf(Response), 'salesDocuments').Count(), At('The e-mail must find exactly the seeded document.', ApiVersion));
        _Assert.AreEqual('', EventSubscriber.Sequence(), At('A summary find must raise no document read event.', ApiVersion));
    end;

    local procedure AssertCreateRaisesResponseEventOnce(ApiVersion: Text)
    var
        EventSubscriber: Codeunit "NPR Ecom Doc Event Subscriber";
        Response: JsonObject;
        ResponseBody: JsonObject;
        ProbeToken: JsonToken;
        ExternalNo: Code[20];
    begin
        _LibDocApi.GrantApiPermission();
        ExternalNo := _LibEcom.NextExternalNo('VEREVT');
        BindSubscription(EventSubscriber);

        Response := _LibDocApi.PostDocument(ExternalNo, ApiVersion);
        UnbindSubscription(EventSubscriber);

        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A create request must answer HTTP 200.', ApiVersion));
        ResponseBody := _LibDocApi.BodyOf(Response);
        _Assert.IsTrue(ResponseBody.Get('versioningProbe', ProbeToken), At('The create response must carry the key its event subscriber added.', ApiVersion));
        _Assert.IsTrue(ProbeToken.AsValue().AsBoolean(), At('The create response must carry the value its event subscriber added.', ApiVersion));
        _Assert.AreEqual(1, EventSubscriber.CreateResponseRaiseCount(), At('Create must raise the create-response event exactly once.', ApiVersion));
        _Assert.AreEqual('', EventSubscriber.Sequence(), At('Create must raise no document read event.', ApiVersion));
    end;

    local procedure ExpectedSequence(EcomSalesHeader: Record "NPR Ecom Sales Header"; IncludePayments: Boolean) Expected: Text
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        EventSubscriber: Codeunit "NPR Ecom Doc Event Subscriber";
    begin
        Expected := EventSubscriber.HeaderEntry(EcomSalesHeader);
        if IncludePayments then begin
            EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
            if EcomSalesPmtLine.FindSet() then
                repeat
                    Expected += ',' + EventSubscriber.PaymentEntry(EcomSalesPmtLine);
                until EcomSalesPmtLine.Next() = 0;
        end;
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        if EcomSalesLine.FindSet() then
            repeat
                Expected += ',' + EventSubscriber.LineEntry(EcomSalesLine);
            until EcomSalesLine.Next() = 0;
    end;

    local procedure NewEmail(): Text
    begin
        exit('versioning.event.' + DelChr(Format(CreateGuid()), '=', '{}-').ToLower() + '@versioning.test');
    end;

    local procedure V3Date(): Text
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        exit(Format(Handler.V3From(), 0, 9));
    end;

    local procedure At(Message: Text; ApiVersion: Text): Text
    begin
        exit(StrSubstNo(_AtVersionLbl, Message, ApiVersion));
    end;
}

codeunit 85579 "NPR Ecom Get V2 Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibDocApi: Codeunit "NPR Library Ecom Doc Api";
        _LibAPI: Codeunit "NPR Library - NPRetail API";
        _V2DateLbl: Label '2025-10-19', Locked = true;
        _LaterDateLbl: Label '2026-10-26', Locked = true;
        _EmptyRootKeysLbl: Label 'externalNo,id,documentType,creationStatus,postingStatus,currencyCode,currencyExchangeRate,externalDocumentNo,yourReference,languageTag,locationCode,pricesExcludingVat,ticketReservationToken,captureProcessingStatus,lastCaptureErrorMessage,createdAt,createdDocumentNo,postedDocumentNos,sellToCustomer,shipToCustomer,shipment', Locked = true;
        _SellToKeysLbl: Label 'no,name,address,address2,postCode,county,city,countryCode,contact,email,phone,ean,vatRegistrationNo,invoiceEmail', Locked = true;
        _ShipToKeysLbl: Label 'name,address,address2,postCode,county,city,countryCode,contact', Locked = true;
        _ShipmentKeysLbl: Label 'shipmentMethod,shipmentService', Locked = true;
        _IssuedAssetKeysLbl: Label 'id,type,referenceNo', Locked = true;
        _DimensionKeysLbl: Label 'code,valueCode', Locked = true;
        _FullDocumentNoteLbl: Label 'Please leave the parcel at the back door.', Locked = true;
        _ForeignNoteLbl: Label 'A note that belongs to another company.', Locked = true;
        _AtVersionLbl: Label '%1 (x-api-version %2)', Locked = true;

    [Test]
    procedure GivenFullDocument_WhenGetByIdV2_ThenKeyOrderAndValuesArePinned()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] Dates from V2From() to the day before V3From() preserve V2 keys, line dates and statuses.

        // [Given] The API permission and a document with a note, a card payment with a fee line, dimensions and three lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is read under the V2 date and under a later date before V3
        // [Then] Both answers carry the pinned V2 keys and values
        AssertFullDocumentPinned(EcomSalesHeader, _V2DateLbl);
        AssertFullDocumentPinned(EcomSalesHeader, _LaterDateLbl);
    end;

    [Test]
    procedure GivenEmptyDocument_WhenGetByIdV2_ThenNoCommentsAndNoLinesKeys()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] A document without notes, payments and lines answers without the comments, payments and
        //            salesDocumentLines keys.

        // [Given] The API permission and a document with no notes, no payments and no lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateEmptyDocument(EcomSalesHeader);

        // [When] The document is read under the V2 date and under a later date before V3
        // [Then] The root keys stop at shipment
        AssertEmptyDocumentPinned(EcomSalesHeader, _V2DateLbl);
        AssertEmptyDocumentPinned(EcomSalesHeader, _LaterDateLbl);
    end;

    [Test]
    procedure GivenNoHeader_WhenGetById_ThenSameBodyAsTodayPinnedHeader()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        WithoutHeader: JsonObject;
        WithToday: JsonObject;
    begin
        // [Scenario] A request without x-api-version is answered as if it named today's date.

        // [Given] The API permission and the full document
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is read without the header and with the header set to today
        WithoutHeader := _LibDocApi.GetById(EcomSalesHeader.SystemId, '', false);
        WithToday := _LibDocApi.GetById(EcomSalesHeader.SystemId, Format(Today(), 0, 9), true);

        // [Then] Both answer 200 with the same body
        _Assert.AreEqual(200, _LibDocApi.StatusOf(WithoutHeader), 'A get by id without x-api-version must answer HTTP 200.');
        _Assert.AreEqual(200, _LibDocApi.StatusOf(WithToday), 'A get by id with today''s date must answer HTTP 200.');
        _Assert.AreEqual(
            _LibDocApi.WithoutCustomFields(_LibDocApi.BodyOf(WithToday)),
            _LibDocApi.WithoutCustomFields(_LibDocApi.BodyOf(WithoutHeader)),
            'A request without x-api-version must answer the same body as one that names today''s date.');
    end;

    [Test]
    procedure GivenEmptyHeader_WhenGetById_ThenV1Answers()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: JsonObject;
    begin
        // [Scenario] An empty x-api-version header is read as a date before V2, so V1 answers.

        // [Given] The API permission and a document with one item line and one card payment, which V1 can render
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument('versioning.v1.' + DelChr(Format(CreateGuid()), '=', '{}-').ToLower() + '@versioning.test', 1, 1, EcomSalesHeader);

        // [When] The document is read with an empty x-api-version header
        Response := _LibDocApi.GetById(EcomSalesHeader.SystemId, '', true);

        // [Then] The V1 document answers
        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), 'A get by id with an empty x-api-version must answer HTTP 200.');
        _Assert.AreEqual('V1', _LibDocApi.VersionOf(_LibDocApi.BodyOf(Response)), 'An empty x-api-version must be answered by V1.');
    end;

    [Test]
    procedure GivenMalformedHeader_WhenGetById_Then400()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: JsonObject;
    begin
        // [Scenario] An x-api-version that is not a date is refused.

        // [Given] The API permission and an existing document
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateEmptyDocument(EcomSalesHeader);

        // [When] The document is read with an x-api-version that is not a date
        Response := _LibDocApi.GetById(EcomSalesHeader.SystemId, 'not-a-date', true);

        // [Then] The answer is 400 with the generic error code
        _Assert.AreEqual(400, _LibDocApi.StatusOf(Response), 'An x-api-version that is not a date must answer HTTP 400.');
        _Assert.AreEqual('generic_error', TextAt(_LibDocApi.BodyOf(Response), 'code'), 'The refusal must carry the generic error code.');
    end;

    [Test]
    procedure GivenMalformedId_WhenGetById_Then400()
    begin
        // [Scenario] A document id that is not a GUID is refused and the answer names the parameter.

        // [Given] The API permission
        _LibDocApi.GrantApiPermission();

        // [When] A get by id names an id that is not a GUID, under the V2 date and under a later date before V3
        // [Then] The answer is 400 with the pinned body
        AssertErrorPinned(GetByIdText('not-a-guid', _V2DateLbl), 400, 'generic_error', 'Malformed parameter: documentId', _V2DateLbl);
        AssertErrorPinned(GetByIdText('not-a-guid', _LaterDateLbl), 400, 'generic_error', 'Malformed parameter: documentId', _LaterDateLbl);
    end;

    [Test]
    procedure GivenUnknownId_WhenGetById_Then404()
    var
        UnknownId: Guid;
    begin
        // [Scenario] A document id that matches no document answers 404.

        // [Given] The API permission and an id that no document carries
        _LibDocApi.GrantApiPermission();
        UnknownId := CreateGuid();

        // [When] The id is read under the V2 date and under a later date before V3
        // [Then] The answer is 404 with the pinned body
        AssertErrorPinned(_LibDocApi.GetById(UnknownId, _V2DateLbl, true), 404, 'resource_not_found', 'The selected resource does not exist.', _V2DateLbl);
        AssertErrorPinned(_LibDocApi.GetById(UnknownId, _LaterDateLbl, true), 404, 'resource_not_found', 'The selected resource does not exist.', _LaterDateLbl);
    end;

    [Test]
    procedure GivenForeignCompanyNote_WhenGetByIdV2_ThenForeignNoteStillAppears()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] V2 keeps answering a note that another company wrote on the same Record ID.

        // [Given] The API permission, the full document with its own note, and a note of another company on the same Record ID
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);
        _LibDocApi.AddForeignCompanyNote(EcomSalesHeader, _ForeignNoteLbl);

        // [When] The document is read under the V2 date and under a later date before V3
        // [Then] comments holds both notes
        AssertBothNotesAnswered(EcomSalesHeader, _V2DateLbl);
        AssertBothNotesAnswered(EcomSalesHeader, _LaterDateLbl);
    end;

    [Test]
    procedure GivenParityDocument_WhenGetV3IsCompared_ThenItEqualsGetV2ExceptTheTemplates()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] V2 and V3 serialize the parity document identically except for sell-to templates.

        // [Given] The parity document: a note, a card payment with a fee line, dimensions, an issued voucher and
        //         three lines with every date and status set
        _LibDocApi.CreateParityDocument(EcomSalesHeader);

        // [When] Both Get versions build the document, with nothing bound
        // [Then] Get V3's text without customerTemplate and configurationTemplate equals Get V2's text
        AssertGetV3EqualsGetV2(EcomSalesHeader, false, 'Nothing bound');
    end;

    [Test]
    procedure GivenNoForeignSubscriber_WhenGetByIdV2WithWriters_ThenCustomFieldsMergeAndSitInPlace()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        FirstHitHeader: Record "NPR Ecom Sales Header";
        SecondHitHeader: Record "NPR Ecom Sales Header";
        ParityHeader: Record "NPR Ecom Sales Header";
        WriteSubscriber: Codeunit "NPR Ecom Doc Write Subscriber";
        ObjectSubscriber: Codeunit "NPR Ecom Doc Object Subscriber";
        Body: JsonObject;
        Email: Text;
    begin
        // [Scenario] V2 merges property writers, nests object writers and preserves customFields placement.
        // An installed object-opening writer would conflict with the test's object writer.

        // [Given] The API permission and the full document, read with nothing bound; the test fails on an empty
        //         customFields and stops when an installed subscriber already writes customFields
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);
        Body := GetByIdBody(EcomSalesHeader);
        _LibDocApi.AssertNoEmptyCustomFields(Body, At('Nothing bound', _V2DateLbl));
        if _LibDocApi.HasCustomFieldsAnywhere(Body) then
            exit;

        // [Given] Two documents under one e-mail, each with one payment and two lines
        Email := 'versioning.writers.' + DelChr(Format(CreateGuid()), '=', '{}-').ToLower() + '@versioning.test';
        _LibDocApi.CreateDocument(Email, 1, 2, FirstHitHeader);
        _LibDocApi.CreateDocument(Email, 1, 2, SecondHitHeader);
        // [Given] The parity document, with every line date and status set
        _LibDocApi.CreateParityDocument(ParityHeader);

        // [When] The full document is read by id and the e-mail is found with details, with the two AddProperty writers bound
        BindSubscription(WriteSubscriber);
        Body := GetByIdBody(EcomSalesHeader);
        // [Then] Every customFields holds both keys; it follows dimensions in the root and is last in each payment and line
        AssertCustomFieldsPlaced(Body);
        AssertBothWriters(Body, 'Root');
        AssertEachElementHasBothWriters(Body, 'payments');
        AssertEachElementHasBothWriters(Body, 'salesDocumentLines');
        // [Then] Each detailed hit holds its own customFields with one of each key, and so does each of its lines
        AssertEachHitHasBothWriters(DetailedFindBody(Email));
        // [Then] Get V3 builds the parity document like Get V2, customFields included, apart from the templates
        AssertGetV3EqualsGetV2(ParityHeader, true, 'Writers bound');
        UnbindSubscription(WriteSubscriber);

        // [When] The full document is read by id and found with details, with only the object-opening writer bound
        BindSubscription(ObjectSubscriber);
        Body := GetByIdBody(EcomSalesHeader);
        // [Then] objectWriter nests under customFields in the root, in each payment and in each line, in the same places
        AssertCustomFieldsPlaced(Body);
        AssertObjectWriter(Body, 'Root');
        AssertEachElementHasObjectWriter(Body, 'payments');
        AssertEachElementHasObjectWriter(Body, 'salesDocumentLines');
        // [Then] The pinned V2 document holds, and the detailed hit equals the get-by-id document without payments
        AssertFullDocumentPinned(EcomSalesHeader, _V2DateLbl);
        AssertDetailedHitEqualsGetByIdWithObjectWriter(EcomSalesHeader);
        UnbindSubscription(ObjectSubscriber);

        // [Then] With nothing bound, neither answer carries customFields
        _Assert.IsFalse(_LibDocApi.HasCustomFieldsAnywhere(GetByIdBody(EcomSalesHeader)), 'With no writer bound, get by id must answer without customFields.');
        _Assert.IsFalse(_LibDocApi.HasCustomFieldsAnywhere(DetailedFindBody(Email)), 'With no writer bound, a detailed find must answer without customFields.');
    end;

    local procedure AssertFullDocumentPinned(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text)
    var
        Response: JsonObject;
        Body: JsonObject;
        Payment: JsonObject;
        Fee: JsonObject;
        Dimension: JsonObject;
        Comment: JsonObject;
        LineA: JsonObject;
        LineB: JsonObject;
        LineC: JsonObject;
        IssuedAsset: JsonObject;
        Lines: JsonArray;
    begin
        Response := _LibDocApi.GetById(EcomSalesHeader.SystemId, ApiVersion, true);
        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A get by id of an existing document must answer HTTP 200.', ApiVersion));
        Body := _LibDocApi.BodyOf(Response);

        _Assert.AreEqual('V2', _LibDocApi.VersionOf(Body), At('The answer must be the V2 document.', ApiVersion));
        _Assert.AreEqual(_LibDocApi.RootKeys(), _LibDocApi.KeysOf(Body), At('Root keys', ApiVersion));
        _Assert.AreEqual(_SellToKeysLbl, _LibDocApi.KeysOf(ObjectAt(Body, 'sellToCustomer')), At('sellToCustomer keys', ApiVersion));
        _Assert.AreEqual(_ShipToKeysLbl, _LibDocApi.KeysOf(ObjectAt(Body, 'shipToCustomer')), At('shipToCustomer keys', ApiVersion));
        _Assert.AreEqual(_ShipmentKeysLbl, _LibDocApi.KeysOf(ObjectAt(Body, 'shipment')), At('shipment keys', ApiVersion));

        Dimension := SingleObjectAt(Body, 'dimensions', ApiVersion);
        _Assert.AreEqual(_DimensionKeysLbl, _LibDocApi.KeysOf(Dimension), At('Header dimension keys', ApiVersion));

        Comment := SingleObjectAt(Body, 'comments', ApiVersion);
        _Assert.AreEqual(_LibDocApi.CommentKeys(), _LibDocApi.KeysOf(Comment), At('Comment keys', ApiVersion));
        _Assert.AreEqual(_FullDocumentNoteLbl, TextAt(Comment, 'comment'), At('Comment text', ApiVersion));

        Lines := ArrayAt(Body, 'salesDocumentLines');
        _Assert.AreEqual(3, Lines.Count(), At('The document must answer its three lines.', ApiVersion));
        LineA := ElementAt(Lines, 0);
        LineB := ElementAt(Lines, 1);
        LineC := ElementAt(Lines, 2);

        Payment := SingleObjectAt(Body, 'payments', ApiVersion);
        _Assert.AreEqual(_LibDocApi.PaymentKeys(), _LibDocApi.KeysOf(Payment), At('Payment keys', ApiVersion));
        Fee := SingleObjectAt(Payment, 'paymentFees', ApiVersion);
        _Assert.AreEqual('paymentFeeId', _LibDocApi.KeysOf(Fee), At('Payment fee keys', ApiVersion));
        _Assert.AreEqual(TextAt(LineA, 'id'), TextAt(Fee, 'paymentFeeId'), At('The payment fee must point at line A.', ApiVersion));

        _Assert.AreEqual(_LibDocApi.LineBaseKeys() + ',externalLineId,dimensions', _LibDocApi.KeysOf(LineA), At('Line A keys', ApiVersion));
        _Assert.AreEqual('VERSIONING-LINE-A', TextAt(LineA, 'externalLineId'), At('Line A externalLineId', ApiVersion));
        _Assert.AreEqual(_DimensionKeysLbl, _LibDocApi.KeysOf(SingleObjectAt(LineA, 'dimensions', ApiVersion)), At('Line A dimension keys', ApiVersion));
        AssertLineDatesAndStatuses(LineA, '2026-03-04', '1990-05-17', '2026-04-01', 'processed', 'error', At('Line A', ApiVersion));

        _Assert.AreEqual(_LibDocApi.LineBaseKeys() + ',externalLineId,parentExternalLineId', _LibDocApi.KeysOf(LineB), At('Line B keys', ApiVersion));
        _Assert.AreEqual('VERSIONING-LINE-A', TextAt(LineB, 'parentExternalLineId'), At('Line B parentExternalLineId', ApiVersion));
        AssertLineDatesAndStatuses(LineB, '', '', '', ' ', ' ', At('Line B', ApiVersion));

        _Assert.AreEqual(_LibDocApi.LineBaseKeys(), _LibDocApi.KeysOf(LineC), At('Line C keys', ApiVersion));
        IssuedAsset := SingleObjectAt(LineC, 'issuedAssets', ApiVersion);
        _Assert.AreEqual(_IssuedAssetKeysLbl, _LibDocApi.KeysOf(IssuedAsset), At('Issued asset keys', ApiVersion));
        _Assert.AreEqual('voucher', TextAt(IssuedAsset, 'type'), At('Issued asset type', ApiVersion));
        AssertLineDatesAndStatuses(LineC, '', '', '', ' ', ' ', At('Line C', ApiVersion));
    end;

    local procedure AssertEmptyDocumentPinned(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text)
    var
        Response: JsonObject;
        Body: JsonObject;
    begin
        Response := _LibDocApi.GetById(EcomSalesHeader.SystemId, ApiVersion, true);
        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A get by id of an existing document must answer HTTP 200.', ApiVersion));
        Body := _LibDocApi.BodyOf(Response);
        _Assert.AreEqual(_EmptyRootKeysLbl, _LibDocApi.KeysOf(Body), At('Root keys of a document without notes and lines', ApiVersion));
        _Assert.IsFalse(Body.Contains('comments'), At('A document without notes must answer without comments.', ApiVersion));
        _Assert.IsFalse(Body.Contains('salesDocumentLines'), At('A document without lines must answer without salesDocumentLines.', ApiVersion));
    end;

    local procedure AssertBothNotesAnswered(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text)
    var
        Response: JsonObject;
        Comments: JsonArray;
    begin
        Response := _LibDocApi.GetById(EcomSalesHeader.SystemId, ApiVersion, true);
        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A get by id of an existing document must answer HTTP 200.', ApiVersion));
        Comments := ArrayAt(_LibDocApi.BodyOf(Response), 'comments');
        _Assert.AreEqual(2, Comments.Count(), At('V2 must answer the document''s own note and the other company''s note.', ApiVersion));
        _Assert.AreEqual(_FullDocumentNoteLbl, TextAt(ElementAt(Comments, 0), 'comment'), At('The first comment must be the document''s own note.', ApiVersion));
        _Assert.AreEqual(_ForeignNoteLbl, TextAt(ElementAt(Comments, 1), 'comment'), At('The second comment must be the other company''s note.', ApiVersion));
    end;

    local procedure GetByIdBody(EcomSalesHeader: Record "NPR Ecom Sales Header"): JsonObject
    var
        Response: JsonObject;
    begin
        Response := _LibDocApi.GetById(EcomSalesHeader.SystemId, _V2DateLbl, true);
        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A get by id of an existing document must answer HTTP 200.', _V2DateLbl));
        exit(_LibDocApi.BodyOf(Response));
    end;

    local procedure DetailedFindBody(Email: Text): JsonObject
    var
        Response: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        QueryParameters.Add('email', Email);
        QueryParameters.Add('withDetails', 'true');
        Response := _LibDocApi.Find(QueryParameters, _V2DateLbl, true);
        _Assert.AreEqual(200, _LibDocApi.StatusOf(Response), At('A detailed find must answer HTTP 200.', _V2DateLbl));
        exit(_LibDocApi.BodyOf(Response));
    end;

    local procedure AssertCustomFieldsPlaced(Body: JsonObject)
    var
        Elements: JsonArray;
        RootKeys: List of [Text];
        Position: Integer;
        i: Integer;
    begin
        RootKeys := Body.Keys();
        Position := RootKeys.IndexOf('customFields');
        _Assert.IsTrue(Position > 1, 'The root must carry customFields after its first key.');
        _Assert.IsTrue(Position < RootKeys.Count(), 'The root must carry keys after customFields.');
        _Assert.AreEqual('dimensions', RootKeys.Get(Position - 1), 'customFields must come right after dimensions in the root.');
        _Assert.AreEqual('comments', RootKeys.Get(Position + 1), 'customFields must come right before comments in the root.');

        Elements := ArrayAt(Body, 'payments');
        for i := 0 to Elements.Count() - 1 do
            AssertCustomFieldsLast(ElementAt(Elements, i), StrSubstNo('Payment %1', i));
        Elements := ArrayAt(Body, 'salesDocumentLines');
        for i := 0 to Elements.Count() - 1 do
            AssertCustomFieldsLast(ElementAt(Elements, i), StrSubstNo('Line %1', i));
    end;

    local procedure AssertCustomFieldsLast(Object: JsonObject; Context: Text)
    var
        KeyList: List of [Text];
    begin
        KeyList := Object.Keys();
        _Assert.AreEqual('customFields', KeyList.Get(KeyList.Count()), Context + ': customFields must be the last key.');
    end;

    local procedure AssertBothWriters(Object: JsonObject; Context: Text)
    var
        CustomFields: JsonObject;
    begin
        CustomFields := ObjectAt(Object, 'customFields');
        _Assert.AreEqual(2, CustomFields.Keys().Count(), Context + ': customFields must hold exactly the two writers'' keys.');
        _Assert.IsTrue(CustomFields.Contains('writerA'), Context + ': customFields must hold writerA.');
        _Assert.IsTrue(CustomFields.Contains('writerB'), Context + ': customFields must hold writerB.');
    end;

    local procedure AssertEachElementHasBothWriters(Object: JsonObject; ArrayName: Text)
    var
        Elements: JsonArray;
        i: Integer;
    begin
        Elements := ArrayAt(Object, ArrayName);
        _Assert.IsTrue(Elements.Count() > 0, ArrayName + ' must not be empty.');
        for i := 0 to Elements.Count() - 1 do
            AssertBothWriters(ElementAt(Elements, i), StrSubstNo('%1 %2', ArrayName, i));
    end;

    local procedure AssertEachHitHasBothWriters(Body: JsonObject)
    var
        Hits: JsonArray;
        Hit: JsonObject;
        i: Integer;
    begin
        Hits := ArrayAt(Body, 'salesDocuments');
        _Assert.AreEqual(2, Hits.Count(), 'The e-mail must find both seeded documents.');
        for i := 0 to Hits.Count() - 1 do begin
            Hit := ElementAt(Hits, i);
            AssertBothWriters(Hit, StrSubstNo('Hit %1', i));
            AssertEachElementHasBothWriters(Hit, 'salesDocumentLines');
        end;
    end;

    local procedure AssertObjectWriter(Object: JsonObject; Context: Text)
    begin
        _Assert.AreEqual('objectWriter', _LibDocApi.KeysOf(ObjectAt(Object, 'customFields')), Context + ': customFields must hold exactly objectWriter.');
    end;

    local procedure AssertEachElementHasObjectWriter(Object: JsonObject; ArrayName: Text)
    var
        Elements: JsonArray;
        i: Integer;
    begin
        Elements := ArrayAt(Object, ArrayName);
        _Assert.IsTrue(Elements.Count() > 0, ArrayName + ' must not be empty.');
        for i := 0 to Elements.Count() - 1 do
            AssertObjectWriter(ElementAt(Elements, i), StrSubstNo('%1 %2', ArrayName, i));
    end;

    local procedure AssertDetailedHitEqualsGetByIdWithObjectWriter(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        GetBody: JsonObject;
        Hit: JsonObject;
        Hits: JsonArray;
        GetText: Text;
        HitText: Text;
    begin
        GetBody := GetByIdBody(EcomSalesHeader).Clone().AsObject();
        _Assert.IsTrue(GetBody.Contains('payments'), 'The get-by-id document must carry payments for the comparison to mean anything.');
        GetBody.Remove('payments');

        Hits := ArrayAt(DetailedFindBody(EcomSalesHeader."Sell-to Email"), 'salesDocuments');
        _Assert.AreEqual(1, Hits.Count(), 'The e-mail must find exactly the seeded document.');
        Hit := ElementAt(Hits, 0);
        AssertObjectWriter(Hit, 'Hit');
        AssertEachElementHasObjectWriter(Hit, 'salesDocumentLines');

        GetBody.WriteTo(GetText);
        Hit.WriteTo(HitText);
        _Assert.AreEqual(GetText, HitText, 'A detailed hit must equal the get-by-id document without payments, customFields included.');
    end;

    local procedure AssertGetV3EqualsGetV2(EcomSalesHeader: Record "NPR Ecom Sales Header"; WritersBound: Boolean; Context: Text)
    var
        GetV2: Codeunit "NPR EcomSalesDocGetV2";
        GetV3: Codeunit "NPR EcomSalesDocGetV3";
        V2Body: JsonObject;
        V3Body: JsonObject;
        SellToCustomer: JsonObject;
        V2Text: Text;
        V3Text: Text;
    begin
        V2Body := GetV2.GetSalesDocumentJsonObject(EcomSalesHeader).Build();
        V3Body := GetV3.GetSalesDocumentJsonObject(EcomSalesHeader).Build();
        AssertParityDocumentHolds(EcomSalesHeader, V2Body, Context);
        if WritersBound then
            _Assert.IsTrue(_LibDocApi.HasCustomFieldsAnywhere(V2Body), Context + ': with the writers bound, Get V2 must carry customFields.');

        SellToCustomer := ObjectAt(V3Body, 'sellToCustomer');
        SellToCustomer.Remove('customerTemplate');
        SellToCustomer.Remove('configurationTemplate');
        _Assert.IsFalse(ObjectAt(V3Body, 'sellToCustomer').Contains('customerTemplate'), Context + ': the templates must be removed from Get V3''s document before the comparison.');

        V2Body.WriteTo(V2Text);
        V3Body.WriteTo(V3Text);
        _Assert.AreEqual(V2Text, V3Text, Context + ': Get V3 must build the same document as Get V2, apart from the sell-to templates.');
    end;

    // The parity document must keep what makes V3's changes invisible on it: own notes only, lines, and every
    // line date and status set. Otherwise V3's added arrays or left-out keys would show up as a difference.
    local procedure AssertParityDocumentHolds(EcomSalesHeader: Record "NPR Ecom Sales Header"; V2Body: JsonObject; Context: Text)
    var
        RecordLink: Record "Record Link";
        Lines: JsonArray;
        Line: JsonObject;
        i: Integer;
    begin
        RecordLink.SetRange("Record ID", EcomSalesHeader.RecordId);
        RecordLink.SetRange(Type, RecordLink.Type::Note);
        _Assert.IsFalse(RecordLink.IsEmpty(), Context + ': the parity document must carry a note.');
        RecordLink.SetFilter(Company, '<>%1', CompanyName());
        _Assert.IsTrue(RecordLink.IsEmpty(), Context + ': every note of the parity document must belong to this company.');
        _Assert.IsTrue(ArrayAt(V2Body, 'comments').Count() > 0, Context + ': the parity document must answer comments.');
        _Assert.IsTrue(ArrayAt(V2Body, 'payments').Count() > 0, Context + ': the parity document must answer payments.');

        Lines := ArrayAt(V2Body, 'salesDocumentLines');
        _Assert.IsTrue(Lines.Count() > 0, Context + ': the parity document must answer lines.');
        for i := 0 to Lines.Count() - 1 do begin
            Line := ElementAt(Lines, i);
            _Assert.AreNotEqual('', TextAt(Line, 'requestedDeliveryDate'), StrSubstNo('%1: line %2 requestedDeliveryDate must be set.', Context, i));
            _Assert.AreNotEqual('', TextAt(Line, 'memberBirthday'), StrSubstNo('%1: line %2 memberBirthday must be set.', Context, i));
            _Assert.AreNotEqual('', TextAt(Line, 'membershipActivationDate'), StrSubstNo('%1: line %2 membershipActivationDate must be set.', Context, i));
            _Assert.AreNotEqual(' ', TextAt(Line, 'virtualItemProcessStatus'), StrSubstNo('%1: line %2 virtualItemProcessStatus must be set.', Context, i));
            _Assert.AreNotEqual(' ', TextAt(Line, 'attractionWalletProcessStatus'), StrSubstNo('%1: line %2 attractionWalletProcessStatus must be set.', Context, i));
        end;
    end;

    local procedure AssertLineDatesAndStatuses(Line: JsonObject; RequestedDeliveryDate: Text; MemberBirthday: Text; MembershipActivationDate: Text; VirtualItemProcessStatus: Text; AttractionWalletProcessStatus: Text; Context: Text)
    begin
        _Assert.AreEqual(RequestedDeliveryDate, TextAt(Line, 'requestedDeliveryDate'), Context + ': requestedDeliveryDate');
        _Assert.AreEqual(MemberBirthday, TextAt(Line, 'memberBirthday'), Context + ': memberBirthday');
        _Assert.AreEqual(MembershipActivationDate, TextAt(Line, 'membershipActivationDate'), Context + ': membershipActivationDate');
        _Assert.AreEqual(VirtualItemProcessStatus, TextAt(Line, 'virtualItemProcessStatus'), Context + ': virtualItemProcessStatus');
        _Assert.AreEqual(AttractionWalletProcessStatus, TextAt(Line, 'attractionWalletProcessStatus'), Context + ': attractionWalletProcessStatus');
    end;

    local procedure AssertErrorPinned(Response: JsonObject; StatusCode: Integer; ErrorCode: Text; Message: Text; ApiVersion: Text)
    var
        Body: JsonObject;
    begin
        _Assert.AreEqual(StatusCode, _LibDocApi.StatusOf(Response), At('Status code', ApiVersion));
        Body := _LibDocApi.BodyOf(Response);
        _Assert.AreEqual('code,message', _LibDocApi.KeysOf(Body), At('Error body keys', ApiVersion));
        _Assert.AreEqual(ErrorCode, TextAt(Body, 'code'), At('Error code', ApiVersion));
        _Assert.AreEqual(Message, TextAt(Body, 'message'), At('Error message', ApiVersion));
    end;

    local procedure GetByIdText(DocumentIdText: Text; ApiVersion: Text) Response: JsonObject
    var
        Body: JsonObject;
        Headers: Dictionary of [Text, Text];
        QueryParameters: Dictionary of [Text, Text];
    begin
        Headers.Add('x-api-version', ApiVersion);
        Commit();
        Response := _LibAPI.CallApi('GET', 'ecommerce/documents/' + DocumentIdText, Body, QueryParameters, Headers);
    end;

    local procedure SingleObjectAt(Object: JsonObject; KeyName: Text; ApiVersion: Text): JsonObject
    var
        Elements: JsonArray;
    begin
        Elements := ArrayAt(Object, KeyName);
        _Assert.AreEqual(1, Elements.Count(), At(KeyName + ' must hold exactly one entry.', ApiVersion));
        exit(ElementAt(Elements, 0));
    end;

    local procedure ObjectAt(Object: JsonObject; KeyName: Text): JsonObject
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Object.Get(KeyName, Token), StrSubstNo('The object must carry %1.', KeyName));
        exit(Token.AsObject());
    end;

    local procedure ArrayAt(Object: JsonObject; KeyName: Text): JsonArray
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Object.Get(KeyName, Token), StrSubstNo('The object must carry %1.', KeyName));
        exit(Token.AsArray());
    end;

    local procedure ElementAt(Elements: JsonArray; Index: Integer): JsonObject
    var
        Token: JsonToken;
    begin
        Elements.Get(Index, Token);
        exit(Token.AsObject());
    end;

    local procedure TextAt(Object: JsonObject; KeyName: Text): Text
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Object.Get(KeyName, Token), StrSubstNo('The object must carry %1.', KeyName));
        exit(Token.AsValue().AsText());
    end;

    local procedure At(Message: Text; ApiVersion: Text): Text
    begin
        exit(StrSubstNo(_AtVersionLbl, Message, ApiVersion));
    end;
}

codeunit 85587 "NPR Ecom Get V3 Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibDocApi: Codeunit "NPR Library Ecom Doc Api";
        _LibAPI: Codeunit "NPR Library - NPRetail API";
        _ForeignNoteLbl: Label 'A note that belongs to another company.', Locked = true;
        _AtVersionLbl: Label '%1 (x-api-version %2)', Locked = true;

    [Test]
    procedure GivenTemplates_WhenGetByIdV3_ThenSellToCustomerCarriesBoth()
    var
        FullHeader: Record "NPR Ecom Sales Header";
        BlankHeader: Record "NPR Ecom Sales Header";
        SellToCustomer: JsonObject;
    begin
        // [Scenario] V3's sellToCustomer carries the header's customer and configuration templates right after
        //            invoiceEmail, and answers "" for a blank template.

        // [Given] The API permission, the full document with both templates set and a document with both blank
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(FullHeader);
        _LibDocApi.CreateEmptyDocument(BlankHeader);
        BlankHeader."Customer Template" := '';
        BlankHeader."Configuration Template" := '';
        BlankHeader.Modify();
        Commit();

        // [When] Both documents are read under the V3 date
        // [Then] The templates follow invoiceEmail and carry the header's values
        SellToCustomer := _LibDocApi.ObjectAt(_LibDocApi.GetByIdBody(FullHeader.SystemId, V3Date()), 'sellToCustomer');
        _Assert.AreEqual(_LibDocApi.V3SellToKeys(), _LibDocApi.KeysOf(SellToCustomer), At('sellToCustomer keys of the full document'));
        _Assert.AreEqual(FullHeader."Customer Template", _LibDocApi.TextAt(SellToCustomer, 'customerTemplate'), At('customerTemplate of the full document'));
        _Assert.AreEqual(FullHeader."Configuration Template", _LibDocApi.TextAt(SellToCustomer, 'configurationTemplate'), At('configurationTemplate of the full document'));

        SellToCustomer := _LibDocApi.ObjectAt(_LibDocApi.GetByIdBody(BlankHeader.SystemId, V3Date()), 'sellToCustomer');
        _Assert.AreEqual(_LibDocApi.V3SellToKeys(), _LibDocApi.KeysOf(SellToCustomer), At('sellToCustomer keys of the document with blank templates'));
        _Assert.AreEqual('', _LibDocApi.TextAt(SellToCustomer, 'customerTemplate'), At('A blank customer template must answer ""'));
        _Assert.AreEqual('', _LibDocApi.TextAt(SellToCustomer, 'configurationTemplate'), At('A blank configuration template must answer ""'));
    end;

    [Test]
    procedure GivenNoNotes_WhenGetByIdV3_ThenCommentsIsAnEmptyArray()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
    begin
        // [Scenario] A document without notes answers comments as an empty array, in its place before payments.

        // [Given] The API permission and a document with one payment and one line but no notes
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);

        // [When] The document is read under the V3 date
        Body := _LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date());

        // [Then] comments sits between shipment and payments and holds nothing
        _Assert.AreEqual(_LibDocApi.EmptyRootKeys() + ',comments,payments,salesDocumentLines', _LibDocApi.KeysOf(Body), At('Root keys of a document without notes'));
        _Assert.AreEqual(0, _LibDocApi.ArrayAt(Body, 'comments').Count(), At('A document without notes must answer an empty comments array.'));
    end;

    [Test]
    procedure GivenNoLines_WhenGetByIdV3_ThenSalesDocumentLinesIsAnEmptyArray()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
    begin
        // [Scenario] A document without lines answers salesDocumentLines as an empty array, as the last root key.

        // [Given] The API permission and a document with no notes, no payments and no lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateEmptyDocument(EcomSalesHeader);

        // [When] The document is read under the V3 date
        Body := _LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date());

        // [Then] The root ends with comments and salesDocumentLines, and salesDocumentLines holds nothing
        _Assert.AreEqual(_LibDocApi.EmptyRootKeys() + ',comments,salesDocumentLines', _LibDocApi.KeysOf(Body), At('Root keys of a document without notes, payments and lines'));
        _Assert.AreEqual(0, _LibDocApi.ArrayAt(Body, 'salesDocumentLines').Count(), At('A document without lines must answer an empty salesDocumentLines array.'));
    end;

    [Test]
    procedure GivenSetDates_WhenGetByIdV3_ThenIsoDates()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LineA: JsonObject;
    begin
        // [Scenario] A line's set dates answer as ISO dates.

        // [Given] The API permission and the full document, whose line A has all three dates set
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is read under the V3 date
        LineA := LineAt(EcomSalesHeader, 0);

        // [Then] Line A answers the three dates as yyyy-mm-dd
        _Assert.AreEqual('2026-03-04', _LibDocApi.TextAt(LineA, 'requestedDeliveryDate'), At('Line A requestedDeliveryDate'));
        _Assert.AreEqual('1990-05-17', _LibDocApi.TextAt(LineA, 'memberBirthday'), At('Line A memberBirthday'));
        _Assert.AreEqual('2026-04-01', _LibDocApi.TextAt(LineA, 'membershipActivationDate'), At('Line A membershipActivationDate'));
    end;

    [Test]
    procedure GivenBlankDates_WhenGetByIdV3_ThenTheDateKeysAreAbsent()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] A line's blank dates are left out instead of answering "".

        // [Given] The API permission and the full document, whose lines B and C have all three dates blank
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is read under the V3 date
        // [Then] Lines B and C carry none of the three date keys
        AssertKeysAbsent(LineAt(EcomSalesHeader, 1), 'requestedDeliveryDate,memberBirthday,membershipActivationDate', 'Line B');
        AssertKeysAbsent(LineAt(EcomSalesHeader, 2), 'requestedDeliveryDate,memberBirthday,membershipActivationDate', 'Line C');
    end;

    [Test]
    procedure GivenStatuses_WhenGetByIdV3_ThenProcessedAndError()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LineA: JsonObject;
    begin
        // [Scenario] A line's set process statuses answer as processed and error.

        // [Given] The API permission and the full document, whose line A is Processed for virtual items and Error for the wallet
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is read under the V3 date
        LineA := LineAt(EcomSalesHeader, 0);

        // [Then] Line A answers processed and error
        _Assert.AreEqual('processed', _LibDocApi.TextAt(LineA, 'virtualItemProcessStatus'), At('Line A virtualItemProcessStatus'));
        _Assert.AreEqual('error', _LibDocApi.TextAt(LineA, 'attractionWalletProcessStatus'), At('Line A attractionWalletProcessStatus'));
    end;

    [Test]
    procedure GivenBlankStatuses_WhenGetByIdV3_ThenTheStatusKeysAreEmptyStrings()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LineB: JsonObject;
        LineC: JsonObject;
    begin
        // [Scenario] A line's blank process statuses keep their keys and answer "" instead of " ".

        // [Given] The API permission and the full document, whose lines B and C have both statuses blank
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is read under the V3 date
        LineB := LineAt(EcomSalesHeader, 1);
        LineC := LineAt(EcomSalesHeader, 2);

        // [Then] Lines B and C carry both status keys, each as ""
        _Assert.AreEqual('', _LibDocApi.TextAt(LineB, 'virtualItemProcessStatus'), At('Line B virtualItemProcessStatus'));
        _Assert.AreEqual('', _LibDocApi.TextAt(LineB, 'attractionWalletProcessStatus'), At('Line B attractionWalletProcessStatus'));
        _Assert.AreEqual('', _LibDocApi.TextAt(LineC, 'virtualItemProcessStatus'), At('Line C virtualItemProcessStatus'));
        _Assert.AreEqual('', _LibDocApi.TextAt(LineC, 'attractionWalletProcessStatus'), At('Line C attractionWalletProcessStatus'));
    end;

    [Test]
    procedure GivenForeignCompanyNote_WhenGetByIdV3_ThenOnlyOwnNotes()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Comments: JsonArray;
    begin
        // [Scenario] V3 answers only the notes of the document's own company, though Record Link is shared by all companies.

        // [Given] The API permission, the full document with its own note, and a note of another company on the same Record ID
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);
        _LibDocApi.AddForeignCompanyNote(EcomSalesHeader, _ForeignNoteLbl);

        // [When] The document is read under the V3 date
        Comments := _LibDocApi.ArrayAt(_LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date()), 'comments');

        // [Then] comments holds the own note only
        _Assert.AreEqual(1, Comments.Count(), At('V3 must answer the document''s own note and not the other company''s.'));
        _Assert.AreEqual(_LibDocApi.FullDocumentNote(), _LibDocApi.TextAt(_LibDocApi.ElementAt(Comments, 0), 'comment'), At('The comment must be the document''s own note.'));
    end;

    [Test]
    procedure GivenFullDocument_WhenGetByIdV3_ThenKeyOrderAndValuesArePinned()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] Get by id under the V3 date answers the V3 document: its key order on every object and the
        //            values of every field V3 changes.

        // [Given] The API permission and a document with a note, a card payment with a fee line, dimensions and three lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is read under the V3 date
        // [Then] The answer carries the pinned V3 keys and values
        _LibDocApi.AssertFullDocumentPinnedV3(_LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date()), true, 'x-api-version ' + V3Date());
    end;

    [Test]
    procedure GivenFullDocument_WhenGetByIdV3_ThenPaymentsDimensionsFeesStayConditional()
    var
        FullHeader: Record "NPR Ecom Sales Header";
        PlainHeader: Record "NPR Ecom Sales Header";
        EmptyHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        Payment: JsonObject;
        Lines: JsonArray;
    begin
        // [Scenario] payments, dimensions and paymentFees appear only when the document has them.

        // [Given] The API permission, the full document, a document with one payment without fee lines and one
        //         line without dimensions, and a document with no payments
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(FullHeader);
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, PlainHeader);
        _LibDocApi.CreateEmptyDocument(EmptyHeader);

        // [When] The documents are read under the V3 date
        // [Then] The full document carries all three where it has them, and lines B and C carry no dimensions
        Body := _LibDocApi.GetByIdBody(FullHeader.SystemId, V3Date());
        _Assert.IsTrue(Body.Contains('dimensions'), At('A document with a header dimension must answer dimensions.'));
        _Assert.IsTrue(Body.Contains('payments'), At('A document with a payment must answer payments.'));
        _Assert.IsTrue(_LibDocApi.SingleObjectAt(Body, 'payments', 'x-api-version ' + V3Date()).Contains('paymentFees'), At('A payment with a fee line must answer paymentFees.'));
        Lines := _LibDocApi.ArrayAt(Body, 'salesDocumentLines');
        _Assert.IsTrue(_LibDocApi.ElementAt(Lines, 0).Contains('dimensions'), At('A line with a dimension must answer dimensions.'));
        _Assert.IsFalse(_LibDocApi.ElementAt(Lines, 1).Contains('dimensions'), At('Line B has no dimension and must answer without dimensions.'));
        _Assert.IsFalse(_LibDocApi.ElementAt(Lines, 2).Contains('dimensions'), At('Line C has no dimension and must answer without dimensions.'));

        // [Then] Without header dimensions and fee lines, the keys are left out
        Body := _LibDocApi.GetByIdBody(PlainHeader.SystemId, V3Date());
        _Assert.IsFalse(Body.Contains('dimensions'), At('A document without header dimensions must answer without dimensions.'));
        Payment := _LibDocApi.SingleObjectAt(Body, 'payments', 'x-api-version ' + V3Date());
        _Assert.IsFalse(Payment.Contains('paymentFees'), At('A payment without fee lines must answer without paymentFees.'));
        _Assert.IsFalse(_LibDocApi.ElementAt(_LibDocApi.ArrayAt(Body, 'salesDocumentLines'), 0).Contains('dimensions'), At('A line without dimensions must answer without dimensions.'));

        // [Then] Without payments, the payments key is left out
        Body := _LibDocApi.GetByIdBody(EmptyHeader.SystemId, V3Date());
        _Assert.IsFalse(Body.Contains('payments'), At('A document without payments must answer without payments.'));
    end;

    [Test]
    procedure GivenMalformedId_WhenGetByIdV3_Then400()
    begin
        // [Scenario] Under the V3 date, a document id that is not a GUID is refused and the answer names the parameter.

        // [Given] The API permission
        _LibDocApi.GrantApiPermission();

        // [When] A get by id names an id that is not a GUID, under the V3 date
        // [Then] The answer is 400 with the pinned body
        AssertErrorPinned(GetByIdText('not-a-guid'), 400, 'generic_error', 'Malformed parameter: documentId');
    end;

    [Test]
    procedure GivenUnknownId_WhenGetByIdV3_Then404()
    begin
        // [Scenario] Under the V3 date, a document id that matches no document answers 404.

        // [Given] The API permission and an id that no document carries
        _LibDocApi.GrantApiPermission();

        // [When] The id is read under the V3 date
        // [Then] The answer is 404 with the pinned body
        AssertErrorPinned(_LibDocApi.GetById(CreateGuid(), V3Date(), true), 404, 'resource_not_found', 'The selected resource does not exist.');
    end;

    [Test]
    procedure GivenUnsupportedLineType_WhenGetByIdV3_ThenTheErrorNamesTheType()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        // [Scenario] Under the V3 date, a document with a line type V3 cannot answer is refused with a message that names the type.

        // [Given] The API permission and a document whose only line has the obsolete type Ticket
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateDocument(NewEmail(), 1, 1, EcomSalesHeader);
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
#pragma warning disable AL0432
        EcomSalesLine.Type := EcomSalesLine.Type::Ticket;
#pragma warning restore AL0432
        EcomSalesLine.Modify();

        // [When] The document is read under the V3 date
        // [Then] The answer is 400 with the pinned body, naming the line type
        AssertErrorPinned(_LibDocApi.GetById(EcomSalesHeader.SystemId, V3Date(), true), 400, 'generic_error', 'Sales line type Ticket is not supported.');
    end;

    [Test]
    procedure GivenNoForeignSubscriber_WhenGetByIdV3WithWriters_ThenCustomFieldsMergeAndSitInPlace()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        FirstHitHeader: Record "NPR Ecom Sales Header";
        SecondHitHeader: Record "NPR Ecom Sales Header";
        WriteSubscriber: Codeunit "NPR Ecom Doc Write Subscriber";
        ObjectSubscriber: Codeunit "NPR Ecom Doc Object Subscriber";
        Body: JsonObject;
        Email: Text;
    begin
        // [Scenario] V3 merges property writers, nests object writers and preserves customFields placement.
        // An installed object-opening writer would conflict with the test's object writer.

        // [Given] The API permission and the full document, read with nothing bound; the test fails on an empty
        //         customFields and stops when an installed subscriber already writes customFields
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);
        Body := _LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date());
        _LibDocApi.AssertNoEmptyCustomFields(Body, At('Nothing bound'));
        if _LibDocApi.HasCustomFieldsAnywhere(Body) then
            exit;

        // [Given] Two documents under one e-mail, each with one payment and two lines
        Email := NewEmail();
        _LibDocApi.CreateDocument(Email, 1, 2, FirstHitHeader);
        _LibDocApi.CreateDocument(Email, 1, 2, SecondHitHeader);

        // [When] The full document is read by id and the e-mail is found with details, with the two AddProperty writers bound
        BindSubscription(WriteSubscriber);
        Body := _LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date());
        // [Then] Every customFields holds both keys; it follows dimensions in the root and is last in each payment and line
        _LibDocApi.AssertCustomFieldsPlaced(Body);
        _LibDocApi.AssertBothWriters(Body, 'Root');
        _LibDocApi.AssertEachElementHasBothWriters(Body, 'payments');
        _LibDocApi.AssertEachElementHasBothWriters(Body, 'salesDocumentLines');
        // [Then] Each detailed hit holds its own customFields with one of each key, and so does each of its lines
        _LibDocApi.AssertEachHitHasBothWriters(_LibDocApi.FindBody(Email, true, V3Date()));
        UnbindSubscription(WriteSubscriber);

        // [When] The full document is read by id and found with details, with only the object-opening writer bound
        BindSubscription(ObjectSubscriber);
        Body := _LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date());
        // [Then] objectWriter nests under customFields in the root, in each payment and in each line, in the same places
        _LibDocApi.AssertCustomFieldsPlaced(Body);
        _LibDocApi.AssertObjectWriter(Body, 'Root');
        _LibDocApi.AssertEachElementHasObjectWriter(Body, 'payments');
        _LibDocApi.AssertEachElementHasObjectWriter(Body, 'salesDocumentLines');
        // [Then] The pinned V3 document holds, and the detailed hit equals the get-by-id document without payments,
        //        customFields included
        _LibDocApi.AssertFullDocumentPinnedV3(_LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date()), true, 'object writer bound, x-api-version ' + V3Date());
        AssertDetailedHitEqualsGetByIdWithObjectWriter(EcomSalesHeader);
        UnbindSubscription(ObjectSubscriber);

        // [Then] With nothing bound, neither answer carries customFields
        _Assert.IsFalse(_LibDocApi.HasCustomFieldsAnywhere(_LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date())), 'With no writer bound, get by id must answer without customFields.');
        _Assert.IsFalse(_LibDocApi.HasCustomFieldsAnywhere(_LibDocApi.FindBody(Email, true, V3Date())), 'With no writer bound, a detailed find must answer without customFields.');
    end;

    local procedure AssertDetailedHitEqualsGetByIdWithObjectWriter(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        GetBody: JsonObject;
        Hit: JsonObject;
        Hits: JsonArray;
        GetText: Text;
        HitText: Text;
    begin
        GetBody := _LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date()).Clone().AsObject();
        _Assert.IsTrue(GetBody.Contains('payments'), 'The get-by-id document must carry payments for the comparison to mean anything.');
        GetBody.Remove('payments');

        Hits := _LibDocApi.ArrayAt(_LibDocApi.FindBody(EcomSalesHeader."Sell-to Email", true, V3Date()), 'salesDocuments');
        _Assert.AreEqual(1, Hits.Count(), 'The e-mail must find exactly the seeded document.');
        Hit := _LibDocApi.ElementAt(Hits, 0);
        _LibDocApi.AssertObjectWriter(Hit, 'Hit');
        _LibDocApi.AssertEachElementHasObjectWriter(Hit, 'salesDocumentLines');

        GetBody.WriteTo(GetText);
        Hit.WriteTo(HitText);
        _Assert.AreEqual(GetText, HitText, 'A detailed hit must equal the get-by-id document without payments, customFields included.');
    end;

    local procedure LineAt(EcomSalesHeader: Record "NPR Ecom Sales Header"; Index: Integer): JsonObject
    var
        Lines: JsonArray;
    begin
        Lines := _LibDocApi.ArrayAt(_LibDocApi.GetByIdBody(EcomSalesHeader.SystemId, V3Date()), 'salesDocumentLines');
        _Assert.AreEqual(3, Lines.Count(), At('The full document must answer its three lines.'));
        exit(_LibDocApi.ElementAt(Lines, Index));
    end;

    local procedure AssertKeysAbsent(Line: JsonObject; KeyNames: Text; Context: Text)
    var
        KeyName: Text;
    begin
        foreach KeyName in KeyNames.Split(',') do
            _Assert.IsFalse(Line.Contains(KeyName), At(Context + ' must answer without ' + KeyName + '; it carries the keys ' + _LibDocApi.KeysOf(Line)));
    end;

    local procedure AssertErrorPinned(Response: JsonObject; StatusCode: Integer; ErrorCode: Text; Message: Text)
    var
        Body: JsonObject;
    begin
        _Assert.AreEqual(StatusCode, _LibDocApi.StatusOf(Response), At('Status code'));
        Body := _LibDocApi.BodyOf(Response);
        _Assert.AreEqual('code,message', _LibDocApi.KeysOf(Body), At('Error body keys'));
        _Assert.AreEqual(ErrorCode, _LibDocApi.TextAt(Body, 'code'), At('Error code'));
        _Assert.AreEqual(Message, _LibDocApi.TextAt(Body, 'message'), At('Error message'));
    end;

    local procedure GetByIdText(DocumentIdText: Text) Response: JsonObject
    var
        Body: JsonObject;
        Headers: Dictionary of [Text, Text];
        QueryParameters: Dictionary of [Text, Text];
    begin
        Headers.Add('x-api-version', V3Date());
        Commit();
        Response := _LibAPI.CallApi('GET', 'ecommerce/documents/' + DocumentIdText, Body, QueryParameters, Headers);
    end;

    local procedure V3Date(): Text
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        exit(Format(Handler.V3From(), 0, 9));
    end;

    local procedure NewEmail(): Text
    begin
        exit('versioning.v3.' + DelChr(Format(CreateGuid()), '=', '{}-').ToLower() + '@versioning.test');
    end;

    local procedure At(Message: Text): Text
    begin
        exit(StrSubstNo(_AtVersionLbl, Message, V3Date()));
    end;
}

codeunit 85588 "NPR Ecom Find V3 Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibDocApi: Codeunit "NPR Library Ecom Doc Api";
        _AtVersionLbl: Label '%1 (x-api-version %2)', Locked = true;

    [Test]
    procedure GivenMatchingDocument_WhenSummaryFindV3_ThenHitAndEnvelopeKeysArePinned()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        Hit: JsonObject;
        Documents: JsonArray;
    begin
        // [Scenario] A find without withDetails under the V3 date answers the same envelope and summary hit keys as V2.

        // [Given] The API permission and a document with a note, a payment and three lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is found by its e-mail under the V3 date
        Body := _LibDocApi.FindBody(EcomSalesHeader."Sell-to Email", false, V3Date());

        // [Then] The envelope and the hit carry the pinned keys
        _Assert.AreEqual(_LibDocApi.EnvelopeKeys(), _LibDocApi.KeysOf(Body), At('Envelope keys'));
        Documents := _LibDocApi.ArrayAt(Body, 'salesDocuments');
        _Assert.AreEqual(1, Documents.Count(), At('The e-mail must find exactly the seeded document.'));
        Hit := _LibDocApi.ElementAt(Documents, 0);
        _Assert.AreEqual(_LibDocApi.SummaryKeys(), _LibDocApi.KeysOf(Hit), At('Summary hit keys'));
        _Assert.AreEqual(_LibDocApi.SummarySellToKeys(), _LibDocApi.KeysOf(_LibDocApi.ObjectAt(Hit, 'sellToCustomer')), At('Summary sellToCustomer keys'));
        _Assert.AreEqual(EcomSalesHeader."External No.", _LibDocApi.TextAt(Hit, 'externalNo'), At('The hit must be the seeded document.'));
    end;

    [Test]
    procedure GivenFullDocument_WhenDetailedFindV3_ThenHitEqualsGetByIdWithoutPayments()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] A detailed find under the V3 date answers the V3 get-by-id document minus its payments array.

        // [Given] The API permission and a document with a note, a card payment, dimensions and three lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is read by id and found with withDetails=true, both under the V3 date
        // [Then] The hit carries no payments and equals the get-by-id body without payments
        _LibDocApi.AssertDetailedHitEqualsGetById(EcomSalesHeader, V3Date());
    end;

    [Test]
    procedure GivenFullDocument_WhenDetailedFindV3_ThenKeyOrderAndValuesArePinned()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Documents: JsonArray;
    begin
        // [Scenario] A detailed hit under the V3 date is the V3 document without payments: its key order on every
        //            object and the values of every field V3 changes.

        // [Given] The API permission and a document with a note, a card payment with a fee line, dimensions and three lines
        _LibDocApi.GrantApiPermission();
        _LibDocApi.CreateFullDocument(EcomSalesHeader);

        // [When] The document is found with withDetails=true under the V3 date
        Documents := _LibDocApi.ArrayAt(_LibDocApi.FindBody(EcomSalesHeader."Sell-to Email", true, V3Date()), 'salesDocuments');

        // [Then] The one hit carries the pinned V3 keys and values, without payments
        _Assert.AreEqual(1, Documents.Count(), At('The e-mail must find exactly the seeded document.'));
        _LibDocApi.AssertFullDocumentPinnedV3(_LibDocApi.ElementAt(Documents, 0), false, 'detailed hit, x-api-version ' + V3Date());
    end;

    local procedure V3Date(): Text
    var
        Handler: Codeunit "NPR EcomApiHandler";
    begin
        exit(Format(Handler.V3From(), 0, 9));
    end;

    local procedure At(Message: Text): Text
    begin
        exit(StrSubstNo(_AtVersionLbl, Message, V3Date()));
    end;
}

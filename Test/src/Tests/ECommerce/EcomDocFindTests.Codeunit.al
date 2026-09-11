codeunit 85422 "NPR Ecom Doc Find Tests"
{

    Subtype = Test;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _LibAPI: Codeunit "NPR Library - NPRetail API";
        _EcomApiPermissionSetLbl: Label 'NPR API Ecom', Locked = true;
        _MissingEmailErrLbl: Label 'Missing required parameter: email or invoiceEmail', Locked = true;
        _BothEmailsErrLbl: Label 'Only one of email and invoiceEmail may be given', Locked = true;
        _HitPropertyErrLbl: Label 'Hit %1 must carry the property ''%2''.', Locked = true;
        _MissingHitErrLbl: Label 'The result must contain a hit with id ''%1''.', Locked = true;
        _MissingHitAtIndexErrLbl: Label 'The result must contain a hit at index %1.', Locked = true;
        _EnvelopePropertyErrLbl: Label 'The response envelope must carry the property ''%1''.', Locked = true;
        _NotConvertedErrLbl: Label 'The conversion must reuse the existing customer card whose e-mail differs only by casing, rather than starting to create a second customer. Creation status: %1. Last error: %2', Locked = true;

    #region Tests

    #region Match

    [Test]
    procedure GivenEcomDocWithEmail_WhenFindByThatEmail_ThenDocumentIsReturnedWithIdsAndStatuses()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
        Tag: Text;
    begin
        Tag := NextTag();
        Email := LowerEmail(Tag);
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'A matching e-mail must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'Exactly the one matching e-commerce document must be returned.');
        _Assert.AreEqual(IdOf(EcomSalesHeader), TextAt(Documents, 0, 'id'), 'The hit must carry the e-commerce document id.');
        _Assert.AreEqual(EcomSalesHeader."External No.", TextAt(Documents, 0, 'externalNo'), 'The hit must carry the external no.');
        _Assert.AreEqual('order', TextAt(Documents, 0, 'documentType'), 'The hit must carry its document type.');
        _Assert.AreEqual('created', TextAt(Documents, 0, 'creationStatus'), 'The hit must carry its creation status.');
        _Assert.AreEqual('pending', TextAt(Documents, 0, 'postingStatus'), 'The hit must carry its posting status.');
    end;

    [Test]
    procedure GivenLowerCaseStoredEmail_WhenFindWithUpperCaseDomain_ThenDocumentIsReturned()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Tag: Text;
    begin
        Tag := NextTag();
        EcomSalesHeader := InsertEcomDoc(LowerEmail(Tag), "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        Response := Find('anja.moeller.' + Tag + '@TIVOLI.DK');

        _Assert.AreEqual(200, Response.GetStatusCode(), 'An upper-case domain must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'An e-mail whose domain is upper case must give the same result as the all lower-case form.');
        _Assert.AreEqual(IdOf(EcomSalesHeader), TextAt(Documents, 0, 'id'), 'The document must be the hit.');
    end;

    [Test]
    procedure GivenDocWithDistinctInvoiceEmail_WhenFindByInvoiceEmail_ThenTheDocumentIsReturnedAndNotByEmail()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        QueryParams: Dictionary of [Text, Text];
        Tag: Text;
    begin
        Tag := NextTag();
        EcomSalesHeader := InsertEcomDoc('card.' + Tag + '@shop.dk', 'buyer.' + Tag + '@gmail.com');

        QueryParams.Add('invoiceEmail', 'Buyer.' + Tag + '@Gmail.com');
        Response := FindWithParams(QueryParams);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'A search by invoice e-mail must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'The shopper''s own address must find the document through invoiceEmail.');
        _Assert.AreEqual(IdOf(EcomSalesHeader), TextAt(Documents, 0, 'id'), 'The hit must be the seeded document.');

        Response := Find('buyer.' + Tag + '@gmail.com');
        _Assert.AreEqual(0, SalesDocumentsOf(Response).Count(), 'The email parameter keeps matching Sell-to Email only.');
    end;

    [Test]
    procedure GivenBothEmailAndInvoiceEmail_WhenFind_ThenBadRequest()
    var
        Response: Codeunit "NPR API Response";
        QueryParams: Dictionary of [Text, Text];
    begin
        QueryParams.Add('email', 'card@shop.dk');
        QueryParams.Add('invoiceEmail', 'buyer@gmail.com');

        Response := FindWithParams(QueryParams);

        _Assert.AreEqual(400, Response.GetStatusCode(), 'Passing both e-mail parameters must be rejected.');
        _Assert.AreEqual(_BothEmailsErrLbl, MessageOf(Response), 'The rejection must name both parameters.');
    end;

    #endregion

    #region Exclusions

    [Test]
    procedure GivenSalesOrderAndPostedInvoiceOnly_WhenFindByThatEmail_ThenResultIsEmpty()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
        Tag: Text;
    begin
        Tag := NextTag();
        Email := LowerEmail(Tag);
        InsertSalesOrderWithEmail(Tag, Email);
        InsertPostedSalesInvoiceWithEmail(Tag, Email);

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must succeed even when only BC documents carry the e-mail.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(0, Documents.Count(), 'A Sales Order and a Posted Sales Invoice with no e-commerce document behind them must not appear in the result.');
    end;

    [Test]
    procedure GivenSalesOrderLinkedOnlyByLegacyNpEcDocument_WhenFindByThatEmail_ThenResultIsEmpty()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
        SalesOrderNo: Code[20];
        Tag: Text;
    begin
        Tag := NextTag();
        Email := LowerEmail(Tag);
        SalesOrderNo := InsertSalesOrderWithEmail(Tag, Email);
        InsertLegacyNpEcDocument(SalesOrderNo);

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must succeed for a legacy-linked sales order.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(0, Documents.Count(), 'A Sales Order linked only through the legacy NpEc Document table must not be returned.');
    end;

    [Test]
    procedure GivenSimilarEmails_WhenFindByExactEmail_ThenOnlyTheExactMatchIsReturned()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
        Tag: Text;
    begin
        Tag := NextTag();
        Email := LowerEmail(Tag);
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        InsertEcomDoc(Email + '.old', "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        InsertEcomDoc('moeller.' + Tag + '@tivoli.dk', "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'An exact search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'Only the document whose e-mail equals the search e-mail may be returned - no prefix, suffix or substring matching.');
        _Assert.AreEqual(IdOf(EcomSalesHeader), TextAt(Documents, 0, 'id'), 'The exact-match document must be the hit.');
    end;

    [Test]
    procedure GivenMatchingDocument_WhenFindWithAsteriskInEmail_ThenResultIsEmpty()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Tag: Text;
    begin
        Tag := NextTag();
        InsertEcomDoc(LowerEmail(Tag), "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        Response := Find('anja.moeller.' + Tag + '@tivoli.*');

        _Assert.AreEqual(200, Response.GetStatusCode(), 'A search e-mail containing an asterisk must still answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(0, Documents.Count(), 'An asterisk in the search e-mail must be treated as a literal character, never as a filter operator.');
    end;

    [Test]
    procedure GivenNoDocumentWithEmail_WhenFindByThatEmail_ThenResultIsEmptyArrayWithStatus200()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
    begin
        Response := Find('nobody.' + NextTag() + '@tivoli.dk');

        _Assert.AreEqual(200, Response.GetStatusCode(), 'A search that matches nothing must succeed with HTTP 200, not 404.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(0, Documents.Count(), 'A search that matches nothing must return an empty salesDocuments array.');
    end;

    #endregion

    #region Rejected input

    [Test]
    procedure GivenWhitespaceOnlyEmail_WhenFind_ThenBadRequestNamesTheEmailParameter()
    var
        Response: Codeunit "NPR API Response";
    begin
        Response := Find('   ');

        _Assert.AreEqual(400, Response.GetStatusCode(), 'A whitespace-only e-mail must be rejected with HTTP 400.');
        _Assert.AreEqual(_MissingEmailErrLbl, MessageOf(Response), 'The rejection must name the email parameter.');
    end;

    [Test]
    procedure GivenEmailLongerThan80Chars_WhenFind_ThenBadRequestAndNoTruncatedMatch()
    var
        Response: Codeunit "NPR API Response";
        Email80: Text;
        Tag: Text;
    begin
        // The seeded document holds exactly the first 80 characters, so a truncate-then-search would false-match.
        Tag := NextTag();
        Email80 := EmailOfLength80(Tag);
        InsertEcomDoc(Email80, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        Response := Find(Email80 + 'x');

        _Assert.AreEqual(400, Response.GetStatusCode(), 'A search e-mail longer than 80 characters must be rejected with HTTP 400 rather than truncated and searched.');
    end;

    #endregion

    #region Document type, status and ordering

    [Test]
    procedure GivenOrderAndReturnOrderForSameEmail_WhenFind_ThenBothAreReturnedWithTheirDocumentType()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
        OrderCount: Integer;
        ReturnOrderCount: Integer;
    begin
        Email := LowerEmail(NextTag());
        InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::"Return Order", "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Invoiced);

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(2, Documents.Count(), 'Both the order and the return order must be returned.');
        CountDocumentTypes(Documents, OrderCount, ReturnOrderCount);
        _Assert.AreEqual(1, OrderCount, 'Exactly one hit must be labelled as an order.');
        _Assert.AreEqual(1, ReturnOrderCount, 'Exactly one hit must be labelled as a return order.');
    end;

    [Test]
    procedure GivenDocumentsInEveryStatus_WhenFind_ThenAllAreReturnedWithTheirStatuses()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
        PendingId: Text;
        CreatedId: Text;
        FailedId: Text;
        PartiallyInvoicedId: Text;
        InvoicedId: Text;
    begin
        Email := LowerEmail(NextTag());
        PendingId := IdOf(InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Pending, "NPR EcomSalesDocPostStatus"::Pending));
        CreatedId := IdOf(InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending));
        FailedId := IdOf(InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Error, "NPR EcomSalesDocPostStatus"::Pending));
        PartiallyInvoicedId := IdOf(InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::"Partially Invoiced"));
        InvoicedId := IdOf(InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Invoiced));

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(5, Documents.Count(), 'Every state must be returned - there is no status filter in this version.');
        _Assert.AreEqual('pending', CreationStatusOfId(Documents, PendingId), 'The pending document must report creationStatus pending.');
        _Assert.AreEqual('created', CreationStatusOfId(Documents, CreatedId), 'The created document must report creationStatus created.');
        _Assert.AreEqual('error', CreationStatusOfId(Documents, FailedId), 'The failed document must report creationStatus error.');
        _Assert.AreEqual('partiallyInvoiced', PostingStatusOfId(Documents, PartiallyInvoicedId), 'The partially invoiced document must report postingStatus partiallyInvoiced.');
        _Assert.AreEqual('invoiced', PostingStatusOfId(Documents, InvoicedId), 'The invoiced document must report postingStatus invoiced.');
    end;

    [Test]
    procedure GivenCancelledDocument_WhenFind_ThenItIsReturnedWithCreationStatusCancelled()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
    begin
        Email := LowerEmail(NextTag());
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Canceled, "NPR EcomSalesDocPostStatus"::Pending);

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'A cancelled document must not fail the whole response.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'A cancelled e-commerce document must be returned by the search.');
        _Assert.AreEqual(IdOf(EcomSalesHeader), TextAt(Documents, 0, 'id'), 'The cancelled document must be the hit.');
        _Assert.AreEqual('canceled', TextAt(Documents, 0, 'creationStatus'), 'A cancelled document must report creationStatus cancelled.');
    end;

    [Test]
    procedure GivenThreeDocumentsCreatedAtDistinctTimes_WhenFind_ThenNewestIsFirst()
    var
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        SecondEcomSalesHeader: Record "NPR Ecom Sales Header";
        ThirdEcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
    begin
        // Rows are spaced in time: SystemCreatedAt is not assignable, and same-millisecond inserts would rest the order on the tie-break.
        Email := LowerEmail(NextTag());
        FirstEcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        Sleep(50);
        SecondEcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        Sleep(50);
        ThirdEcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        FirstEcomSalesHeader.Get(FirstEcomSalesHeader."Entry No.");
        SecondEcomSalesHeader.Get(SecondEcomSalesHeader."Entry No.");
        ThirdEcomSalesHeader.Get(ThirdEcomSalesHeader."Entry No.");
        _Assert.AreNotEqual(CreatedAtOf(FirstEcomSalesHeader), CreatedAtOf(SecondEcomSalesHeader), 'Arrangement: the first two documents must carry different creation timestamps.');
        _Assert.AreNotEqual(CreatedAtOf(SecondEcomSalesHeader), CreatedAtOf(ThirdEcomSalesHeader), 'Arrangement: the last two documents must carry different creation timestamps.');

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(3, Documents.Count(), 'All three documents must be returned.');
        _Assert.AreEqual(IdOf(ThirdEcomSalesHeader), TextAt(Documents, 0, 'id'), 'The newest document must come first.');
        _Assert.AreEqual(IdOf(SecondEcomSalesHeader), TextAt(Documents, 1, 'id'), 'The middle document must come second.');
        _Assert.AreEqual(IdOf(FirstEcomSalesHeader), TextAt(Documents, 2, 'id'), 'The oldest document must come last.');
    end;

    [Test]
    procedure GivenTwoDocumentsWithSameExternalNo_WhenFind_ThenBothAreReturnedWithDistinctIds()
    var
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        SecondEcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
        SharedExternalNo: Code[20];
    begin
        Email := LowerEmail(NextTag());
        SharedExternalNo := _LibEcom.NextExternalNo('TIVDUP');
        FirstEcomSalesHeader := InsertEcomDocWithExternalNo(Email, SharedExternalNo, 'SHOPA');
        SecondEcomSalesHeader := InsertEcomDocWithExternalNo(Email, SharedExternalNo, 'SHOPB');
        _Assert.AreNotEqual(FirstEcomSalesHeader.SystemId, SecondEcomSalesHeader.SystemId, 'Arrangement: the two documents must have different ids.');

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(2, Documents.Count(), 'Two documents from different shops that share an external no. must both be returned.');
        _Assert.AreNotEqual(TextAt(Documents, 0, 'id'), TextAt(Documents, 1, 'id'), 'The two hits must be told apart by their ids.');
    end;

    #endregion

    #region Routing

    [Test]
    procedure GivenEcomDocWithEmail_WhenFindThroughTheRoute_ThenRouteReturnsTheDocument()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        ResponseJson: JsonObject;
        Documents: JsonArray;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        Email: Text;
        Token: JsonToken;
    begin
        GrantEcomApiPermission();
        Email := LowerEmail(NextTag());
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        Commit();

        QueryParams.Add('email', Email);
        ResponseJson := _LibAPI.CallApi('GET', 'ecommerce/documents', Body, QueryParams, Headers);

        _Assert.AreEqual(200, StatusCodeOf(ResponseJson), 'GET /ecommerce/documents must be a routed endpoint.');
        _LibAPI.GetResponseBody(ResponseJson).Get('salesDocuments', Token);
        Documents := Token.AsArray();
        _Assert.AreEqual(1, Documents.Count(), 'The routed search must return the matching document.');
        _Assert.AreEqual(IdOf(EcomSalesHeader), TextAt(Documents, 0, 'id'), 'The routed search must return the document id.');
    end;

    [Test]
    procedure GivenNoEmailParameter_WhenFindThroughTheRoute_ThenRouteAnswersBadRequest()
    var
        Body: JsonObject;
        ResponseJson: JsonObject;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
    begin
        GrantEcomApiPermission();
        Commit();

        ResponseJson := _LibAPI.CallApi('GET', 'ecommerce/documents', Body, QueryParams, Headers);

        _Assert.AreEqual(400, StatusCodeOf(ResponseJson), 'A routed request without the email parameter must answer HTTP 400.');
    end;

    #endregion

    #endregion

    #region Shape

    #region Summary hit

    [Test]
    procedure GivenMatchingDocument_WhenFindWithoutDetailFlag_ThenHitCarriesOnlyTheSummaryFields()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
    begin
        Email := NextEmail();
        InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending, '');

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'The seeded document must be the single hit.');
        AssertSummaryProperties(HitAt(Documents, 0));
    end;

    [Test]
    procedure GivenCreatedOrder_WhenFind_ThenSummaryCarriesCreatedDocumentNoAndCreatedAt()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
    begin
        Email := NextEmail();
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending, 'SO-25-00871');

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual('SO-25-00871', TextAt(Documents, 0, 'createdDocumentNo'), 'The summary must report the BC sales order created from the document.');
        _Assert.AreEqual(Format(EcomSalesHeader.SystemCreatedAt, 0, 9), TextAt(Documents, 0, 'createdAt'), 'The summary must report when the e-commerce document was received.');
        _Assert.AreEqual(0, ArrayAt(Documents, 0, 'postedDocumentNos').Count(), 'Nothing is posted yet, so postedDocumentNos must be an empty array.');
    end;

    [Test]
    procedure GivenPartiallyInvoicedOrder_WhenFind_ThenSummaryListsBothPostedInvoiceNos()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        PostedNos: JsonArray;
        Email: Text;
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
    begin
        Email := NextEmail();
        FirstInvoiceNo := NextDocumentNo('PSI');
        SecondInvoiceNo := NextDocumentNo('PSI');
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::"Partially Invoiced", 'SO-25-00860');
        InsertPostedSalesInvoice(FirstInvoiceNo, EcomSalesHeader.SystemId);
        InsertPostedSalesInvoice(SecondInvoiceNo, EcomSalesHeader.SystemId);

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual('partiallyInvoiced', TextAt(Documents, 0, 'postingStatus'), 'The hit must report postingStatus partiallyInvoiced.');
        PostedNos := ArrayAt(Documents, 0, 'postedDocumentNos');
        _Assert.AreEqual(2, PostedNos.Count(), 'A partially invoiced order must list every posted sales invoice created from it.');
        _Assert.IsTrue(ArrayContains(PostedNos, FirstInvoiceNo), 'The first posted sales invoice no. must be listed.');
        _Assert.IsTrue(ArrayContains(PostedNos, SecondInvoiceNo), 'The second posted sales invoice no. must be listed.');
    end;

    [Test]
    procedure GivenInvoicedReturnOrder_WhenFind_ThenSummaryListsThePostedCreditMemoNo()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        PostedNos: JsonArray;
        Email: Text;
        CreditMemoNo: Code[20];
    begin
        Email := NextEmail();
        CreditMemoNo := NextDocumentNo('PSC');
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::"Return Order", "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Invoiced, '');
        InsertPostedSalesCreditMemo(CreditMemoNo, EcomSalesHeader.SystemId);
        InsertPostedSalesInvoice(NextDocumentNo('PSI'), EcomSalesHeader.SystemId);

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual('returnOrder', TextAt(Documents, 0, 'documentType'), 'The hit must be labelled as a return order.');
        PostedNos := ArrayAt(Documents, 0, 'postedDocumentNos');
        _Assert.AreEqual(1, PostedNos.Count(), 'A return order must list only the posted credit memos created from it, not sales invoices.');
        _Assert.IsTrue(ArrayContains(PostedNos, CreditMemoNo), 'The posted credit memo no. must be listed.');
    end;

    [Test]
    procedure GivenFailedDocument_WhenFind_ThenSummaryHasBlankCreatedDocNoAndEmptyPostedDocumentNos()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
    begin
        Email := NextEmail();
        InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Error, "NPR EcomSalesDocPostStatus"::Pending, '');

        Response := Find(Email);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual('error', TextAt(Documents, 0, 'creationStatus'), 'A failed document must report creationStatus error.');
        _Assert.AreEqual('', TextAt(Documents, 0, 'createdDocumentNo'), 'A failed document has no BC document, so createdDocumentNo must be blank.');
        _Assert.AreEqual(0, ArrayAt(Documents, 0, 'postedDocumentNos').Count(), 'A failed document has nothing posted, so postedDocumentNos must be an empty array.');
    end;

    #endregion

    #region Detail flag

    [Test]
    procedure GivenMatchingDocument_WhenFindWithDetailFlagTrue_ThenHitEqualsTheGetByIdDocument()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
    begin
        Email := NextEmail();
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending, 'SO-25-00871');
        InsertEcomSalesLine(EcomSalesHeader, 10000);
        InsertEcomSalesLine(EcomSalesHeader, 20000);

        Response := FindWithDetails(Email, 'true');

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The detailed search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'The seeded document must be the single hit.');
        _Assert.AreEqual(GetByIdDocumentText(EcomSalesHeader.SystemId), HitText(Documents, 0), 'A detailed hit must be the complete document, identical field-for-field to what GET by id returns for that id.');
    end;

    [Test]
    procedure GivenMatchingDocument_WhenFindWithDetailFlagYes_ThenHitIsSummary()
    var
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
    begin
        Email := NextEmail();
        InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending, '');

        Response := FindWithDetails(Email, 'yes');

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        AssertSummaryProperties(HitAt(Documents, 0));
    end;

    [Test]
    procedure GivenDocumentWithAPaymentLine_WhenFindWithDetailFlagTrue_ThenTheHitCarriesNoPaymentsWhileGetByIdStillDoes()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
        PspToken: Text;
    begin
        Email := NextEmail();
        PspToken := 'PSP-SENTINEL-' + NextTag();
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending, '');
        InsertEcomSalesPmtLine(EcomSalesHeader, PspToken);

        Response := FindWithDetails(Email, 'true');

        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'The seeded document must be the single hit.');
        _Assert.IsFalse(HitAt(Documents, 0).Contains('payments'), 'A detailed search hit must not carry the payments array.');
        _Assert.IsFalse(HitText(Documents, 0).Contains(PspToken), 'A detailed search hit must not leak payment tokens.');
        _Assert.AreEqual(PspToken, FirstPaymentPspTokenOfGetById(EcomSalesHeader.SystemId), 'GET by id must still return the payments array with its tokens.');
    end;

    #endregion

    #region GET by id

    [Test]
    procedure GivenDocumentWithPostedInvoice_WhenGetById_ThenDocumentCarriesTheThreeAdditiveFields()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Document: JsonObject;
        PostedNos: JsonArray;
        Token: JsonToken;
        InvoiceNo: Code[20];
    begin
        InvoiceNo := NextDocumentNo('PSI');
        EcomSalesHeader := InsertEcomDoc(NextEmail(), "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Invoiced, 'SO-25-00790');
        InsertPostedSalesInvoice(InvoiceNo, EcomSalesHeader.SystemId);

        Commit();
        Response := GetById(EcomSalesHeader.SystemId);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'GET by id must answer HTTP 200.');
        Document := SalesDocumentOf(Response);
        _Assert.IsTrue(Document.Get('createdAt', Token), 'GET by id must carry createdAt so the two endpoints stay aligned.');
        _Assert.AreEqual(Format(EcomSalesHeader.SystemCreatedAt, 0, 9), Token.AsValue().AsText(), 'createdAt must be when the e-commerce document was received.');
        _Assert.IsTrue(Document.Get('createdDocumentNo', Token), 'GET by id must carry createdDocumentNo.');
        _Assert.AreEqual('SO-25-00790', Token.AsValue().AsText(), 'createdDocumentNo must be the BC document created from the e-commerce document.');
        _Assert.IsTrue(Document.Get('postedDocumentNos', Token), 'GET by id must carry postedDocumentNos.');
        PostedNos := Token.AsArray();
        _Assert.AreEqual(1, PostedNos.Count(), 'postedDocumentNos must list the posted sales invoice.');
        _Assert.IsTrue(ArrayContains(PostedNos, InvoiceNo), 'The posted sales invoice no. must be listed.');
    end;

    [Test]
    procedure GivenCancelledDocument_WhenGetById_ThenCreationStatusIsCancelled()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Token: JsonToken;
        Succeeded: Boolean;
        GetByIdFailedErrLbl: Label 'GET by id must return the cancelled document, but the endpoint failed with: %1', Locked = true;
    begin
        EcomSalesHeader := InsertEcomDoc(NextEmail(), "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Canceled, "NPR EcomSalesDocPostStatus"::Pending, '');
        // Committed out here rather than inside the guarded call, because writes made inside a try method are not rolled back.
        Commit();

        Succeeded := TryGetById(EcomSalesHeader.SystemId, Response);

        _Assert.IsTrue(Succeeded, StrSubstNo(GetByIdFailedErrLbl, GetLastErrorText()));
        _Assert.AreEqual(200, Response.GetStatusCode(), 'GET by id must succeed for a cancelled document.');
        SalesDocumentOf(Response).Get('creationStatus', Token);
        _Assert.AreEqual('canceled', Token.AsValue().AsText(), 'A cancelled document must be returned with creationStatus cancelled.');
    end;

    #endregion

    #endregion

    #region Casing

    #region The normalisation helper

    [Test]
    procedure GivenPaddedMixedCaseEmail_WhenNormalizeEmail_ThenValueIsTrimmedAndLowerCased()
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        _Assert.AreEqual('andrei@test.com', EcomSalesDocUtils.NormalizeEmail(' AnDrei@Test.com '), 'A padded, mixed-case e-mail must be stored trimmed and lower case.');
    end;

    [Test]
    procedure GivenEmailLongerThan80Chars_WhenNormalizeEmail_ThenValueIsCappedAt80()
    var
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        LongEmail: Text;
    begin
        LongEmail := PadStr('', 75, 'A') + '@Test.com';
        _Assert.AreEqual(80, StrLen(EcomSalesDocUtils.NormalizeEmail(LongEmail)), 'The normalised e-mail must fit the 80-character field it is stored in.');
        _Assert.AreEqual(CopyStr(LowerCase(LongEmail), 1, 80), EcomSalesDocUtils.NormalizeEmail(LongEmail), 'The normalised e-mail must be the lower-cased value capped at 80 characters.');
    end;

    #endregion

    #region Writers

    [Test]
    procedure GivenV2PostWithWhitespaceOnlyEmail_WhenDocumentIsCreated_ThenTheRequestIsRefused()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('TIVWSP');
        Body := BuildV2Body(ExternalNo, '   ', '');

        asserterror _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        _Assert.ExpectedError('Expected an e-mail address');
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'A whitespace-only mandatory e-mail must not create a document.');
    end;

    [Test]
    procedure GivenV2PostWithMalformedEmail_WhenDocumentIsCreated_ThenTheRequestIsRefused()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('TIVBAD');
        Body := BuildV2Body(ExternalNo, 'andreixxx', '');

        asserterror _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        _Assert.ExpectedError('Expected an e-mail address');
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'A refused request must leave no document behind.');
    end;

    [Test]
    procedure GivenV2PostWithMixedCaseEmails_WhenDocumentIsCreated_ThenStoredEmailsAreLowerCase()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('TIVV2');
        Body := BuildV2Body(ExternalNo, ' AnDrei@Test.com ', ' Invoice.AnDrei@Test.com ');

        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        _Assert.AreEqual('andrei@test.com', EcomSalesHeader."Sell-to Email", 'A document posted through the current API version must store the sell-to e-mail trimmed and lower case.');
        _Assert.AreEqual('invoice.andrei@test.com', EcomSalesHeader."Sell-to Invoice Email", 'A document posted through the current API version must store the invoice e-mail trimmed and lower case.');
    end;

    [Test]
    procedure GivenV2PostWithMixedCaseEmail_WhenGetById_ThenResponseEchoesLowerCaseEmail()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Body: JsonObject;
        SellToCustomer: JsonObject;
        Token: JsonToken;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('TIVV2G');
        Body := BuildV2Body(ExternalNo, ' AnDrei@Test.com ', ' Invoice.AnDrei@Test.com ');
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        Commit();
        Response := GetById(EcomSalesHeader.SystemId);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'GET by id must answer HTTP 200.');
        SalesDocumentOf(Response).Get('sellToCustomer', Token);
        SellToCustomer := Token.AsObject();
        SellToCustomer.Get('email', Token);
        _Assert.AreEqual('andrei@test.com', Token.AsValue().AsText(), 'GET by id must return the stored, lower-case e-mail.');
        SellToCustomer.Get('invoiceEmail', Token);
        _Assert.AreEqual('invoice.andrei@test.com', Token.AsValue().AsText(), 'GET by id must return the stored, lower-case invoice e-mail.');
    end;

    [Test]
    procedure GivenV2PostWithPaddedMixedCaseEmail_WhenFindWithUpperCaseEmail_ThenDocumentIsFound()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Body: JsonObject;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('TIVV2F');
        Body := BuildV2Body(ExternalNo, ' AnDrei@Test.com ', '');
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        Response := Find('ANDREI@test.com');

        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.IsTrue(ContainsId(Documents, EcomSalesHeader.SystemId), 'A document posted with a padded, mixed-case e-mail must be found by an upper-case search e-mail.');
    end;

    [Test]
    procedure GivenV2PostWithMixedCaseMemberEmail_WhenDocumentIsCreated_ThenStoredMemberEmailIsLowerCase()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Body: JsonObject;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('TIVMEM');
        Body := BuildV2BodyWithMemberLine(ExternalNo, ' Kid.Moeller@Tivoli.dk ');

        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.IsTrue(EcomSalesLine.FindFirst(), 'Arrangement: the membership line must have been created.');
        _Assert.AreEqual('kid.moeller@tivoli.dk', EcomSalesLine."Member Email", 'A membership line''s member e-mail must be stored trimmed and lower case.');
    end;

    [Test]
    procedure GivenV2PostWithMemberEmailLongerThan80Chars_WhenDocumentIsCreated_ThenTheRequestIsRefusedWithoutEchoingTheAddress()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        ExternalNo: Code[20];
        LongMemberEmail: Text;
    begin
        ExternalNo := _LibEcom.NextExternalNo('TIVMEM');
        LongMemberEmail := 'kid.' + PadStr('', 60, 'k') + '@tivoli.dkxxxxxxxxxx';
        Body := BuildV2BodyWithMemberLine(ExternalNo, LongMemberEmail);

        asserterror _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        _Assert.AreEqual('The value of property: memberEmail is too long. Maximum length: 80. Current length: 84.', GetLastErrorText(), 'An over-long member e-mail must be refused with the shared max-length message, which names only the property and the lengths.');
        _Assert.IsFalse(GetLastErrorText().Contains('kkkkkkkkkk'), 'The rejection must not echo the address.');
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'A refused request must leave no document behind.');
    end;

    // Green from the start: pins the malformed-address rejection and its non-echoing text.
    [Test]
    procedure GivenV2PostWithMalformedMemberEmail_WhenDocumentIsCreated_ThenTheRequestIsRefusedWithoutEchoingTheAddress()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('TIVMEM');
        Body := BuildV2BodyWithMemberLine(ExternalNo, 'Kid.Moeller');

        asserterror _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        _Assert.ExpectedError('Invalid value at memberEmail. Expected an e-mail address.');
        _Assert.IsFalse(GetLastErrorText().Contains('Kid.Moeller'), 'The rejection must not echo the address.');
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        _Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'A refused request must leave no document behind.');
    end;

    [Test]
    procedure GivenV1PostWithMixedCaseEmails_WhenDocumentIsCreated_ThenStoredEmailsAreLowerCase()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgent";
        Request: Codeunit "NPR API Request";
        Body: JsonObject;
        BodyToken: JsonToken;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
        ExternalNo: Code[20];
    begin
        // The previous API version is still dispatched below x-api-version 2025-10-19, so its deserialiser must normalise too.
        ExternalNo := _LibEcom.NextExternalNo('TIVV1');
        Body := BuildV1Body(ExternalNo, ' AnDrei@Test.com ', ' Invoice.AnDrei@Test.com ');
        BodyToken := Body.AsToken();
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        Request.Init("Http Method"::POST, '/ecommerce/documents', PathSegments, QueryParams, Headers, BodyToken);

        ApiAgent.CreateIncomingEcomDocument(Request);

        EcomSalesHeader.SetRange("External No.", ExternalNo);
        _Assert.IsTrue(EcomSalesHeader.FindFirst(), 'Arrangement: the previous API version must have created the document.');
        _Assert.AreEqual('andrei@test.com', EcomSalesHeader."Sell-to Email", 'A document posted through the previous API version must store the sell-to e-mail trimmed and lower case.');
        _Assert.AreEqual('invoice.andrei@test.com', EcomSalesHeader."Sell-to Invoice Email", 'A document posted through the previous API version must store the invoice e-mail trimmed and lower case.');
    end;

    [Test]
    procedure GivenEntriaOrderWithMixedCaseEmail_WhenOrderIsImported_ThenStoredSellToEmailIsLowerCase()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        DocumentNo: Code[20];
    begin
        GetEntriaStore(EntriaStore);
        DocumentNo := NextEntriaDocumentNo();

        EntriaOrderImpl.ImportOrder(BuildEntriaOrderJson(DocumentNo, ' AnDrei@Test.com ', '', ''), EntriaStore, DocumentNo, EcomSalesHeader);

        _Assert.AreEqual('andrei@test.com', EcomSalesHeader."Sell-to Email", 'An order imported from Entria must store the sell-to e-mail trimmed and lower case.');
    end;

    [Test]
    procedure GivenEntriaOrderWithMixedCaseMemberEmail_WhenOrderIsImported_ThenStoredMemberEmailIsLowerCase()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        DocumentNo: Code[20];
    begin
        // The flat metadata.member_email property, which wins over the members array when both carry a value.
        GetEntriaStore(EntriaStore);
        DocumentNo := NextEntriaDocumentNo();

        EntriaOrderImpl.ImportOrder(BuildEntriaOrderJson(DocumentNo, 'buyer@tivoli.dk', ' Kid.Moeller@Tivoli.dk ', ' Array.Moeller@Tivoli.dk '), EntriaStore, DocumentNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.IsTrue(EcomSalesLine.FindFirst(), 'Arrangement: the Entria order line must have been created.');
        _Assert.AreEqual('kid.moeller@tivoli.dk', EcomSalesLine."Member Email", 'An Entria line''s flat member e-mail must be stored trimmed and lower case.');
    end;

    [Test]
    procedure GivenEntriaOrderWithMixedCaseMemberArrayEmail_WhenOrderIsImported_ThenStoredMemberEmailIsLowerCase()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        EntriaStore: Record "NPR Entria Store";
        EntriaOrderImpl: Codeunit "NPR Entria Order Impl.";
        DocumentNo: Code[20];
    begin
        // The members-array fallback: a separate assignment site from the flat property, so it needs its own test.
        GetEntriaStore(EntriaStore);
        DocumentNo := NextEntriaDocumentNo();

        EntriaOrderImpl.ImportOrder(BuildEntriaOrderJson(DocumentNo, 'buyer@tivoli.dk', '', ' Array.Moeller@Tivoli.dk '), EntriaStore, DocumentNo, EcomSalesHeader);

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.IsTrue(EcomSalesLine.FindFirst(), 'Arrangement: the Entria order line must have been created.');
        _Assert.AreEqual('array.moeller@tivoli.dk', EcomSalesLine."Member Email", 'An Entria line''s member e-mail taken from the members array must be stored trimmed and lower case.');
    end;

    [Test]
    procedure GivenShopifyOrderWithPaddedMixedCaseEmails_WhenTheSellToCustomerIsSet_ThenStoredEmailsAreLowerCase()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        NpEcStore: Record "NPR NpEc Store";
        EcomDocFindTests: Codeunit "NPR Ecom Doc Find Tests";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Order: JsonToken;
    begin
        Order.ReadFrom('{"email":" Invoice.AnDrei@Test.com "}');

        BindSubscription(EcomDocFindTests);
        SpfyEcomSalesDocImport.SetSellToCustomer(NpEcStore, Order, EcomSalesHeader);
        UnbindSubscription(EcomDocFindTests);

        _Assert.AreEqual('andrei@test.com', EcomSalesHeader."Sell-to Email", 'An order imported from Shopify must store the customer card''s e-mail trimmed and lower case.');
        _Assert.AreEqual('invoice.andrei@test.com', EcomSalesHeader."Sell-to Invoice Email", 'An order imported from Shopify must store the order''s own e-mail as the invoice e-mail, trimmed and lower case.');
    end;

    #endregion

    #region Customer match at conversion

    [Test]
    procedure GivenMixedCaseCustomerCardEmail_WhenSetCustomerEmailFilterWithLowerCaseEmail_ThenTheCardIsFound()
    var
        Customer: Record Customer;
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        CustomerNo: Code[20];
        Tag: Text;
    begin
        Tag := NextTag();
        CustomerNo := InsertCustomerWithEmail(Tag, 'Anja.Moeller.' + Tag.ToUpper() + '@Tivoli.dk');

        EcomSalesDocUtils.SetCustomerEmailFilter(Customer, 'anja.moeller.' + Tag + '@tivoli.dk');

        _Assert.AreEqual(1, Customer.Count(), 'A lower-case e-mail must select exactly the one customer card whose e-mail differs from it only by casing.');
        _Assert.IsTrue(Customer.FindFirst(), 'The customer card must be found.');
        _Assert.AreEqual(CustomerNo, Customer."No.", 'The card whose e-mail differs only by casing must be the match.');
    end;

    [Test]
    procedure GivenBlankEmail_WhenSetCustomerEmailFilter_ThenOnlyBlankEmailCustomersAreSelected()
    var
        Customer: Record Customer;
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        BlankEmailCustomerNo: Code[20];
        WithEmailCustomerNo: Code[20];
        Tag: Text;
    begin
        // A document without an e-mail must keep selecting blank-e-mail customers, not widen to every customer.
        Tag := NextTag();
        BlankEmailCustomerNo := InsertCustomerWithEmail(Tag, '');
        WithEmailCustomerNo := InsertCustomerWithEmail(NextTag(), 'anja.moeller.' + Tag + '@tivoli.dk');

        EcomSalesDocUtils.SetCustomerEmailFilter(Customer, '');

        Customer.SetRange("No.", WithEmailCustomerNo);
        _Assert.IsTrue(Customer.IsEmpty(), 'A blank search e-mail must not select a customer that has an e-mail.');
        Customer.SetRange("No.", BlankEmailCustomerNo);
        _Assert.IsFalse(Customer.IsEmpty(), 'A blank search e-mail must still select customers whose e-mail is blank.');
    end;

    [Test]
    procedure GivenMixedCaseCustomerCardAndLowerCaseDocument_WhenDocumentIsConverted_ThenNoSecondCustomerIsCreated()
    var
        Customer: Record Customer;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        Body: JsonObject;
        CardEmail: Text;
        DocumentEmail: Text;
        ExternalNo: Code[20];
        ItemNo: Code[20];
        Tag: Text;
    begin
        Tag := NextTag();
        CardEmail := 'Anja.Moeller.' + Tag.ToUpper() + '@Tivoli.dk';
        DocumentEmail := 'anja.moeller.' + Tag + '@tivoli.dk';

        _LibEcom.ResetEcomSetupToDefaults();
        ItemNo := _LibEcom.CreateItem();
        Customer.Get(_LibEcom.CreateCustomer());
        Customer."E-Mail" := CopyStr(CardEmail, 1, MaxStrLen(Customer."E-Mail"));
        Customer.Modify();
        SetCustomerMappingByEmailAndCreateOnly();

        ExternalNo := _LibEcom.NextExternalNo('TIVCNV');
        Body := BuildV2BodyForItem(ExternalNo, DocumentEmail, ItemNo);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.IsTrue(SalesHeader.FindFirst(), StrSubstNo(_NotConvertedErrLbl, EcomSalesHeader."Creation Status", EcomSalesHeader."Last Error Message"));
        _Assert.AreEqual(Customer."No.", SalesHeader."Sell-to Customer No.", 'The conversion must reuse the existing customer card whose e-mail differs only by casing.');

        Customer.Reset();
        Customer.SetFilter("E-Mail", '%1|%2', CardEmail, DocumentEmail);
        _Assert.AreEqual(1, Customer.Count(), 'No second customer may be created for an address that already exists on a card in a different casing.');
    end;

    [Test]
    procedure GivenEveryFilterMetacharacterInAnEmail_WhenSetCustomerEmailFilter_ThenOnlyTheLiteralCardIsHit()
    var
        Customer: Record Customer;
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        CollisionParts: List of [Text];
        LiteralParts: List of [Text];
        CaseNo: Integer;
        HitCount: Integer;
        CollisionEmail: Text;
        FoundCustomerNo: Code[20];
        LiteralCustomerNo: Code[20];
        LiteralEmail: Text;
        Outcome: Text;
        Tag: Text;
    begin
        LiteralParts.Add('a*b');
        LiteralParts.Add('a?b');
        LiteralParts.Add('a&b');
        LiteralParts.Add('a|b');
        LiteralParts.Add('a(b)');
        LiteralParts.Add('a<b');
        LiteralParts.Add('a>b');
        LiteralParts.Add('a=b');
        LiteralParts.Add('a''b');
        LiteralParts.Add('a..b');
        LiteralParts.Add('a\b');
        CollisionParts.Add('axb');
        CollisionParts.Add('axb');
        CollisionParts.Add('axb');
        CollisionParts.Add('axb');
        CollisionParts.Add('axbx');
        CollisionParts.Add('axb');
        CollisionParts.Add('axb');
        CollisionParts.Add('axb');
        CollisionParts.Add('axb');
        CollisionParts.Add('axxb');
        CollisionParts.Add('axb');

        Tag := NextTag();
        for CaseNo := 1 to LiteralParts.Count() do begin
            LiteralEmail := LiteralParts.Get(CaseNo) + '.' + Tag + '@x.com';
            CollisionEmail := CollisionParts.Get(CaseNo) + '.' + Tag + '@x.com';
            LiteralCustomerNo := InsertCustomerWithNoAndEmail(CopyStr('TIVMCL' + Format(CaseNo) + Tag, 1, 20), LiteralEmail);
            InsertCustomerWithNoAndEmail(CopyStr('TIVMCC' + Format(CaseNo) + Tag, 1, 20), CollisionEmail);

            if not TryCountCustomersForEmail(LiteralEmail, HitCount, FoundCustomerNo) then
                Outcome += StrSubstNo('%1 THREW; ', LiteralParts.Get(CaseNo))
            else
                if HitCount <> 1 then
                    Outcome += StrSubstNo('%1 hit %2 cards; ', LiteralParts.Get(CaseNo), HitCount)
                else
                    if FoundCustomerNo <> LiteralCustomerNo then
                        Outcome += StrSubstNo('%1 hit the wrong card; ', LiteralParts.Get(CaseNo));
        end;

        _Assert.AreEqual('', Outcome, 'Every local part must select exactly its own card.');
    end;

    [Test]
    procedure GivenUpdateModeAndCasingOnlyDifference_WhenDocumentIsConverted_ThenTheCardKeepsItsCasing()
    var
        Customer: Record Customer;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        Body: JsonObject;
        CardEmail: Text;
        DocumentEmail: Text;
        ExternalNo: Code[20];
        ItemNo: Code[20];
        Tag: Text;
    begin
        Tag := NextTag();
        CardEmail := 'Anja.Keep.' + Tag.ToUpper() + '@Tivoli.dk';
        DocumentEmail := 'anja.keep.' + Tag + '@tivoli.dk';

        _LibEcom.ResetEcomSetupToDefaults();
        ItemNo := _LibEcom.CreateItem();
        Customer.Get(_LibEcom.CreateCustomer());
        Customer."E-Mail" := CopyStr(CardEmail, 1, MaxStrLen(Customer."E-Mail"));
        Customer.Modify();
        SetCustomerMappingByEmailAndCreateAndUpdate();

        ExternalNo := _LibEcom.NextExternalNo('TIVKEEP');
        Body := BuildV2BodyForItem(ExternalNo, DocumentEmail, ItemNo);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.IsTrue(SalesHeader.FindFirst(), StrSubstNo(_NotConvertedErrLbl, EcomSalesHeader."Creation Status", EcomSalesHeader."Last Error Message"));

        Customer.Get(Customer."No.");
        _Assert.AreEqual(CardEmail, Customer."E-Mail", 'A document differing from the card only by casing must not rewrite the card''s e-mail.');
    end;

    [Test]
    procedure GivenMixedCaseCardWithAmpersand_WhenSetCustomerEmailFilter_ThenCasingIsStillIgnored()
    var
        Customer: Record Customer;
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        CustomerNo: Code[20];
        Tag: Text;
    begin
        // A separator such as '&' is protected by the placeholder, so only the two wildcards leave the filter path.
        Tag := NextTag();
        CustomerNo := InsertCustomerWithNoAndEmail(CopyStr('TIVAMP' + Tag, 1, 20), 'Sales&Marketing.' + Tag.ToUpper() + '@T.com');
        InsertCustomerWithNoAndEmail(CopyStr('TIVAMX' + Tag, 1, 20), 'salesxmarketing.' + Tag + '@t.com');

        EcomSalesDocUtils.SetCustomerEmailFilter(Customer, 'sales&marketing.' + Tag + '@t.com');

        _Assert.AreEqual(1, Customer.Count(), 'An address holding an ampersand must still match its card regardless of casing.');
        _Assert.IsTrue(Customer.FindFirst(), 'The customer card must be found.');
        _Assert.AreEqual(CustomerNo, Customer."No.", 'The mixed-case card must be the match.');
    end;

    [Test]
    procedure GivenMixedCaseCardWithApostrophe_WhenSetCustomerEmailFilter_ThenCasingIsStillIgnored()
    var
        Customer: Record Customer;
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
        CustomerNo: Code[20];
        Tag: Text;
    begin
        // The apostrophe and the dot are not filter operators, so these addresses keep the case-insensitive match.
        Tag := NextTag();
        CustomerNo := InsertCustomerWithEmail(Tag, 'O''Brien.Andrei.Lungu.' + Tag.ToUpper() + '@Yahoo.com');

        EcomSalesDocUtils.SetCustomerEmailFilter(Customer, 'o''brien.andrei.lungu.' + Tag + '@yahoo.com');

        _Assert.AreEqual(1, Customer.Count(), 'An address holding an apostrophe and dots must still match its card regardless of casing.');
        _Assert.IsTrue(Customer.FindFirst(), 'The customer card must be found.');
        _Assert.AreEqual(CustomerNo, Customer."No.", 'The mixed-case card must be the match.');
    end;

    [Test]
    procedure GivenOnlySimilarCard_WhenDocumentWithAsteriskEmailIsConverted_ThenItIsNotBoundToThatCard()
    var
        Customer: Record Customer;
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SalesHeader: Record "Sales Header";
        Body: JsonObject;
        BorjaCustomerNo: Code[20];
        ExternalNo: Code[20];
        ItemNo: Code[20];
        DocumentEmail: Text;
        Tag: Text;
    begin
        Tag := NextTag();
        DocumentEmail := 'an*ja.' + Tag + '@tivoli.dk';

        _LibEcom.ResetEcomSetupToDefaults();
        ItemNo := _LibEcom.CreateItem();
        Customer.Get(_LibEcom.CreateCustomer());
        Customer."E-Mail" := CopyStr('anna.borja.' + Tag + '@tivoli.dk', 1, MaxStrLen(Customer."E-Mail"));
        Customer.Modify();
        BorjaCustomerNo := Customer."No.";
        SetCustomerMappingByEmailAndCreateOnly();

        ExternalNo := _LibEcom.NextExternalNo('TIVWC');
        Body := BuildV2BodyForItem(ExternalNo, DocumentEmail, ItemNo);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);

        _LibEcom.RunEcomJobQueueOnce(Codeunit::"NPR EcomSalesOrderProcJQ", EcomSalesHeader);

        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        SalesHeader.SetRange("Sell-to Customer No.", BorjaCustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'A document whose e-mail holds a filter wildcard must not bind to an unrelated customer card that the wildcard happens to match.');
    end;


    #endregion

    #endregion

    #region Upgrade

    #region Document e-mails

    [Test]
    procedure GivenMixedCaseHeaderEmails_WhenNormalizeEcomEmailsRuns_ThenHeaderEmailsAreLowerCased()
    var
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        SecondEcomSalesHeader: Record "NPR Ecom Sales Header";
        ThirdEcomSalesHeader: Record "NPR Ecom Sales Header";
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
        Tag: Text;
    begin
        Tag := NextTag();
        FirstEcomSalesHeader := InsertEcomDoc('Anja.Moeller.' + Tag.ToUpper() + '@Tivoli.dk', 'Invoice.Anja.' + Tag.ToUpper() + '@Tivoli.dk');
        SecondEcomSalesHeader := InsertEcomDoc('anja.moeller.' + Tag + '@tivoli.dk', '');
        ThirdEcomSalesHeader := InsertEcomDoc('MOELLER.' + Tag.ToUpper() + '@tivoli.dk', '');

        UPGEcomSalesDocs.NormalizeEcomEmails(BatchSize());

        FirstEcomSalesHeader.Get(FirstEcomSalesHeader."Entry No.");
        SecondEcomSalesHeader.Get(SecondEcomSalesHeader."Entry No.");
        ThirdEcomSalesHeader.Get(ThirdEcomSalesHeader."Entry No.");
        _Assert.AreEqual('anja.moeller.' + Tag + '@tivoli.dk', FirstEcomSalesHeader."Sell-to Email", 'A mixed-case sell-to e-mail must be lower-cased by the conversion.');
        _Assert.AreEqual('invoice.anja.' + Tag + '@tivoli.dk', FirstEcomSalesHeader."Sell-to Invoice Email", 'A mixed-case invoice e-mail must be lower-cased by the conversion.');
        _Assert.AreEqual('anja.moeller.' + Tag + '@tivoli.dk', SecondEcomSalesHeader."Sell-to Email", 'An already lower-case e-mail must be left as it is.');
        _Assert.AreEqual('moeller.' + Tag + '@tivoli.dk', ThirdEcomSalesHeader."Sell-to Email", 'An upper-case local part must be lower-cased by the conversion.');
    end;

    [Test]
    procedure GivenLineWithMixedCaseMemberEmail_WhenNormalizeEcomEmailsRuns_ThenMemberEmailIsLowerCased()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
        Tag: Text;
    begin
        Tag := NextTag();
        EcomSalesHeader := InsertEcomDoc('Anja.Moeller.' + Tag.ToUpper() + '@Tivoli.dk', '');
        InsertEcomSalesLineWithMemberEmail(EcomSalesHeader, 'Kid.Moeller.' + Tag.ToUpper() + '@Tivoli.dk');

        UPGEcomSalesDocs.NormalizeEcomEmails(BatchSize());

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.IsTrue(EcomSalesLine.FindFirst(), 'Arrangement: the seeded sales line must exist.');
        _Assert.AreEqual('kid.moeller.' + Tag + '@tivoli.dk', EcomSalesLine."Member Email", 'A sales line''s mixed-case member e-mail must be lower-cased by the conversion.');
    end;

    [Test]
    procedure GivenMixedCaseDocuments_WhenNormalizeEcomEmailsRuns_ThenFindLocatesThemByLowerCaseEmail()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
        Documents: JsonArray;
        Tag: Text;
    begin
        Tag := NextTag();
        EcomSalesHeader := InsertEcomDoc('Anja.Moeller.' + Tag.ToUpper() + '@Tivoli.dk', '');

        UPGEcomSalesDocs.NormalizeEcomEmails(BatchSize());

        Response := Find('anja.moeller.' + Tag + '@tivoli.dk');
        _Assert.AreEqual(200, Response.GetStatusCode(), 'The search must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'After the conversion the search must find the document that used to hold a mixed-case e-mail.');
        _Assert.AreEqual(Format(EcomSalesHeader.SystemId, 0, 4).ToLower(), IdAt(Documents, 0), 'The converted document must be the hit.');
    end;

    [Test]
    procedure GivenThreeMixedCaseDocuments_WhenNormalizeEcomEmailsRuns_ThenNoneIsSkipped()
    var
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        SecondEcomSalesHeader: Record "NPR Ecom Sales Header";
        ThirdEcomSalesHeader: Record "NPR Ecom Sales Header";
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
        Tag: Text;
    begin
        Tag := NextTag();
        FirstEcomSalesHeader := InsertEcomDoc('First.' + Tag.ToUpper() + '@Tivoli.dk', '');
        SecondEcomSalesHeader := InsertEcomDoc('Second.' + Tag.ToUpper() + '@Tivoli.dk', '');
        ThirdEcomSalesHeader := InsertEcomDoc('Third.' + Tag.ToUpper() + '@Tivoli.dk', '');

        UPGEcomSalesDocs.NormalizeEcomEmails(BatchSize());

        FirstEcomSalesHeader.Get(FirstEcomSalesHeader."Entry No.");
        SecondEcomSalesHeader.Get(SecondEcomSalesHeader."Entry No.");
        ThirdEcomSalesHeader.Get(ThirdEcomSalesHeader."Entry No.");
        _Assert.AreEqual('first.' + Tag + '@tivoli.dk', FirstEcomSalesHeader."Sell-to Email", 'The first document in the range must be converted.');
        _Assert.AreEqual('second.' + Tag + '@tivoli.dk', SecondEcomSalesHeader."Sell-to Email", 'A document in the middle of the range must be converted.');
        _Assert.AreEqual('third.' + Tag + '@tivoli.dk', ThirdEcomSalesHeader."Sell-to Email", 'The last document in the range must be converted.');
    end;

    [Test]
    procedure GivenThreeMixedCaseDocuments_WhenNormalizeEcomEmailsRunsWithBatchSizeTwo_ThenTheRowAfterTheBoundaryIsConverted()
    var
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        SecondEcomSalesHeader: Record "NPR Ecom Sales Header";
        ThirdEcomSalesHeader: Record "NPR Ecom Sales Header";
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
        Tag: Text;
    begin
        // Three consecutive entry numbers cannot fit in one batch of two, so the walk has to resume across the boundary.
        Tag := NextTag();
        FirstEcomSalesHeader := InsertEcomDoc('First.' + Tag.ToUpper() + '@Tivoli.dk', '');
        SecondEcomSalesHeader := InsertEcomDoc('Second.' + Tag.ToUpper() + '@Tivoli.dk', '');
        ThirdEcomSalesHeader := InsertEcomDoc('Third.' + Tag.ToUpper() + '@Tivoli.dk', '');

        UPGEcomSalesDocs.NormalizeEcomEmails(2);

        FirstEcomSalesHeader.Get(FirstEcomSalesHeader."Entry No.");
        SecondEcomSalesHeader.Get(SecondEcomSalesHeader."Entry No.");
        ThirdEcomSalesHeader.Get(ThirdEcomSalesHeader."Entry No.");
        _Assert.AreEqual('first.' + Tag + '@tivoli.dk', FirstEcomSalesHeader."Sell-to Email", 'The first of three documents that no longer fit in a single batch must be converted.');
        _Assert.AreEqual('second.' + Tag + '@tivoli.dk', SecondEcomSalesHeader."Sell-to Email", 'The document that falls where one batch ends and the next begins must be converted.');
        _Assert.AreEqual('third.' + Tag + '@tivoli.dk', ThirdEcomSalesHeader."Sell-to Email", 'A document lying after the first batch boundary must still be converted: the next batch has to start at the entry no. right after the one the previous batch ended on, skipping nothing.');
    end;

    #endregion

    #region Idempotence

    [Test]
    procedure GivenAlreadyNormalizedRows_WhenNormalizeEcomEmailsRunsASecondTime_ThenNoRowIsModified()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
        CustomerNo: Code[20];
        SalesOrderNo: Code[20];
        SecondRunCount: Integer;
        Tag: Text;
    begin
        Tag := NextTag();
        // A long-reused container carries foreign mixed-case rows; converting them first makes the seeded count exact.
        UPGEcomSalesDocs.NormalizeEcomEmails(BatchSize());
        CustomerNo := InsertUpgradeCustomerWithEmail(Tag, 'Anja.Moeller.' + Tag.ToUpper() + '@Tivoli.dk');
        SalesOrderNo := InsertSalesOrderForCustomer(Tag, CustomerNo);
        EcomSalesHeader := InsertEcomDoc('Anja.Moeller.' + Tag.ToUpper() + '@Tivoli.dk', 'Invoice.Anja.' + Tag.ToUpper() + '@Tivoli.dk');
        EcomSalesHeader."Created Doc No." := SalesOrderNo;
        EcomSalesHeader.Modify();
        InsertEcomSalesLineWithMemberEmail(EcomSalesHeader, 'Kid.Moeller.' + Tag.ToUpper() + '@Tivoli.dk');

        _Assert.AreEqual(2, UPGEcomSalesDocs.NormalizeEcomEmails(BatchSize()), 'The first run must report exactly the two rows it converted: one header and one line.');

        SecondRunCount := UPGEcomSalesDocs.NormalizeEcomEmails(BatchSize());

        _Assert.AreEqual(0, SecondRunCount, 'A second run of the conversion must modify nothing.');
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        _Assert.AreEqual('anja.moeller.' + Tag + '@tivoli.dk', EcomSalesHeader."Sell-to Email", 'A second run must leave the already converted sell-to e-mail alone.');
        _Assert.AreEqual('invoice.anja.' + Tag + '@tivoli.dk', EcomSalesHeader."Sell-to Invoice Email", 'A second run must leave the already converted invoice e-mail alone.');
    end;

    [Test]
    procedure GivenEntryNoGapWiderThanTheBatch_WhenNormalizeEcomEmailsRuns_ThenTheRowPastTheGapIsConverted()
    var
        BurnedEcomSalesHeader: Record "NPR Ecom Sales Header";
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        LastEcomSalesHeader: Record "NPR Ecom Sales Header";
        UPGEcomSalesDocs: Codeunit "NPR UPG Ecom Sales Docs";
        BurnedEntryNos: List of [BigInteger];
        BurnedEntryNo: BigInteger;
        Tag: Text;
        Burned: Integer;
    begin
        // Rejected orders burn autoincrement values, so the walk must jump gaps rather than step through them.
        Tag := NextTag();
        UPGEcomSalesDocs.NormalizeEcomEmails(BatchSize());

        FirstEcomSalesHeader := InsertEcomDoc('First.' + Tag.ToUpper() + '@Tivoli.dk', '');
        for Burned := 1 to 4 do begin
            BurnedEcomSalesHeader := InsertEcomDoc('Burned' + Format(Burned) + '.' + Tag + '@tivoli.dk', '');
            BurnedEntryNos.Add(BurnedEcomSalesHeader."Entry No.");
        end;
        LastEcomSalesHeader := InsertEcomDoc('Last.' + Tag.ToUpper() + '@Tivoli.dk', '');

        foreach BurnedEntryNo in BurnedEntryNos do begin
            BurnedEcomSalesHeader.Get(BurnedEntryNo);
            BurnedEcomSalesHeader.Delete(true);
        end;

        UPGEcomSalesDocs.NormalizeEcomEmails(2);

        FirstEcomSalesHeader.Get(FirstEcomSalesHeader."Entry No.");
        LastEcomSalesHeader.Get(LastEcomSalesHeader."Entry No.");
        _Assert.AreEqual('first.' + Tag + '@tivoli.dk', FirstEcomSalesHeader."Sell-to Email", 'The row before the gap must be converted.');
        _Assert.AreEqual('last.' + Tag + '@tivoli.dk', LastEcomSalesHeader."Sell-to Email", 'A row beyond a gap of burned entry numbers wider than the batch must still be converted.');
    end;

    #endregion

    #endregion

    #region Endpoint helpers

    local procedure Find(Email: Text) Response: Codeunit "NPR API Response"
    var
        QueryParams: Dictionary of [Text, Text];
    begin
        QueryParams.Add('email', Email);
        Response := FindWithParams(QueryParams);
    end;

    local procedure FindWithDetails(Email: Text; DetailFlag: Text) Response: Codeunit "NPR API Response"
    var
        QueryParams: Dictionary of [Text, Text];
    begin
        QueryParams.Add('email', Email);
        QueryParams.Add('withDetails', DetailFlag);
        Response := FindWithParams(QueryParams);
    end;

    [Test]
    procedure GivenThreeDocumentsForOneEmail_WhenFindWithPageSizeTwo_ThenTheSecondPageHoldsTheRemainingDocumentOnce()
    var
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        SecondEcomSalesHeader: Record "NPR Ecom Sales Header";
        ThirdEcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        QueryParams: Dictionary of [Text, Text];
        SeenIds: List of [Text];
        Email: Text;
        NextPageKey: Text;
    begin
        Email := LowerEmail(NextTag());
        FirstEcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        SecondEcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        ThirdEcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        QueryParams.Add('email', Email);
        QueryParams.Add('pageSize', '2');
        Response := FindWithParams(QueryParams);

        _Assert.AreEqual(200, Response.GetStatusCode(), 'A paged find must answer HTTP 200.');
        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(2, Documents.Count(), 'The first page must hold exactly the requested page size.');
        _Assert.IsTrue(BooleanOf(Response, 'morePages'), 'The first page of three documents must report that more pages follow.');
        NextPageKey := TextOf(Response, 'nextPageKey');
        _Assert.AreNotEqual('', NextPageKey, 'A page that reports more pages must carry a continuation key.');
        _Assert.IsTrue(TextOf(Response, 'nextPageURL').Contains('pageKey='), 'The continuation URL must carry the page key.');
        SeenIds.Add(TextAt(Documents, 0, 'id'));
        SeenIds.Add(TextAt(Documents, 1, 'id'));

        Clear(QueryParams);
        QueryParams.Add('email', Email);
        QueryParams.Add('pageKey', NextPageKey);
        Response := FindWithParams(QueryParams);

        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'The second page must hold the one remaining document.');
        _Assert.IsFalse(BooleanOf(Response, 'morePages'), 'The last page must not report further pages.');
        _Assert.AreEqual('', TextOf(Response, 'nextPageKey'), 'The last page must carry a blank continuation key.');
        _Assert.IsFalse(SeenIds.Contains(TextAt(Documents, 0, 'id')), 'A document must not appear on two pages.');
        SeenIds.Add(TextAt(Documents, 0, 'id'));

        _Assert.IsTrue(SeenIds.Contains(IdOf(FirstEcomSalesHeader)), 'Paging must return the first seeded document exactly once.');
        _Assert.IsTrue(SeenIds.Contains(IdOf(SecondEcomSalesHeader)), 'Paging must return the second seeded document exactly once.');
        _Assert.IsTrue(SeenIds.Contains(IdOf(ThirdEcomSalesHeader)), 'Paging must return the third seeded document exactly once.');
    end;

    [Test]
    procedure GivenThreeDocumentsForOneInvoiceEmail_WhenFindWithPageSizeTwo_ThenTheSecondPageHoldsTheRemainingDocumentOnce()
    var
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        SecondEcomSalesHeader: Record "NPR Ecom Sales Header";
        ThirdEcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        QueryParams: Dictionary of [Text, Text];
        SeenIds: List of [Text];
        InvoiceEmail: Text;
        Tag: Text;
    begin
        Tag := NextTag();
        InvoiceEmail := 'buyer.' + Tag + '@gmail.com';
        FirstEcomSalesHeader := InsertEcomDoc('card.' + Tag + '@shop.dk', InvoiceEmail);
        SecondEcomSalesHeader := InsertEcomDoc('card.' + Tag + '@shop.dk', InvoiceEmail);
        ThirdEcomSalesHeader := InsertEcomDoc('card.' + Tag + '@shop.dk', InvoiceEmail);

        QueryParams.Add('invoiceEmail', InvoiceEmail);
        QueryParams.Add('pageSize', '2');
        Response := FindWithParams(QueryParams);

        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(2, Documents.Count(), 'The first page must hold exactly the requested page size.');
        _Assert.IsTrue(BooleanOf(Response, 'morePages'), 'The first page of three documents must report that more pages follow.');
        SeenIds.Add(TextAt(Documents, 0, 'id'));
        SeenIds.Add(TextAt(Documents, 1, 'id'));

        Clear(QueryParams);
        QueryParams.Add('invoiceEmail', InvoiceEmail);
        QueryParams.Add('pageKey', TextOf(Response, 'nextPageKey'));
        Response := FindWithParams(QueryParams);

        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'The second page must hold the one remaining document.');
        _Assert.IsFalse(BooleanOf(Response, 'morePages'), 'The last page must not report further pages.');
        _Assert.IsFalse(SeenIds.Contains(TextAt(Documents, 0, 'id')), 'A document must not appear on two pages.');
        SeenIds.Add(TextAt(Documents, 0, 'id'));
        _Assert.IsTrue(SeenIds.Contains(IdOf(FirstEcomSalesHeader)) and SeenIds.Contains(IdOf(SecondEcomSalesHeader)) and SeenIds.Contains(IdOf(ThirdEcomSalesHeader)), 'Paging by invoice e-mail must return each seeded document exactly once.');
    end;

    [Test]
    procedure GivenFewerDocumentsThanThePage_WhenFind_ThenMorePagesIsFalseAndKeysAreBlank()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        Email: Text;
    begin
        Email := LowerEmail(NextTag());
        EcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        Response := Find(Email);

        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'The only document must be returned.');
        _Assert.AreEqual(IdOf(EcomSalesHeader), TextAt(Documents, 0, 'id'), 'The seeded document must be the hit.');
        _Assert.IsFalse(BooleanOf(Response, 'morePages'), 'A result smaller than the page must not report further pages.');
        _Assert.AreEqual('', TextOf(Response, 'nextPageKey'), 'A single-page result must carry a blank continuation key.');
        _Assert.AreEqual('', TextOf(Response, 'nextPageURL'), 'A single-page result must carry a blank continuation URL.');
    end;

    [Test]
    procedure GivenTwoDocumentsForAPlusAddressedEmail_WhenFindWithPageSizeOne_ThenNextPageUrlIsPercentEncodedAndLeadsToSecondDocument()
    var
        FirstEcomSalesHeader: Record "NPR Ecom Sales Header";
        SecondEcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: Codeunit "NPR API Response";
        Documents: JsonArray;
        QueryParams: Dictionary of [Text, Text];
        Email: Text;
        FirstPageId: Text;
        NextPageUrl: Text;
        Tag: Text;
    begin
        Tag := NextTag();
        Email := 'an+lu.' + Tag + '@test.com';
        FirstEcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);
        SecondEcomSalesHeader := InsertEcomDoc(Email, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending);

        QueryParams.Add('email', Email);
        QueryParams.Add('pageSize', '1');
        Response := FindWithParams(QueryParams);

        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'The first page must hold one document.');
        FirstPageId := TextAt(Documents, 0, 'id');
        NextPageUrl := TextOf(Response, 'nextPageURL');
        _Assert.IsTrue(NextPageUrl.Contains('email=an%2Blu.' + Tag + '%40test.com'), 'The continuation URL must percent-encode the e-mail; got: ' + NextPageUrl);

        Response := FindWithParams(QueryParamsOfUrl(NextPageUrl));

        Documents := SalesDocumentsOf(Response);
        _Assert.AreEqual(1, Documents.Count(), 'Following the continuation URL must return the remaining document.');
        _Assert.AreNotEqual(FirstPageId, TextAt(Documents, 0, 'id'), 'The second page must hold the other document.');
        _Assert.IsTrue((TextAt(Documents, 0, 'id') = IdOf(FirstEcomSalesHeader)) or (TextAt(Documents, 0, 'id') = IdOf(SecondEcomSalesHeader)), 'The second page must hold one of the seeded documents.');
    end;

    [Test]
    procedure GivenReservedCharactersInQueryValues_WhenGetNextPageUrlWithEncoding_ThenEveryValueIsPercentEncoded()
    var
        Request: Codeunit "NPR API Request";
        EmptyBody: JsonToken;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
        Url: Text;
    begin
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        QueryParams.Add('email', 'an+lu&co=1%@test.com');
        QueryParams.Add('from', '2026-09-11T05:28:38Z');
        QueryParams.Add('pageKey', 'stale');
        Request.Init("Http Method"::GET, '/t/e/c/ecommerce/documents', PathSegments, QueryParams, Headers, EmptyBody);

        Url := Request.GetNextPageUrl('next-Key_1', true);

        _Assert.IsTrue(Url.StartsWith('https://api.npretail.app/t/e/c/ecommerce/documents?'), 'The continuation URL must start with the request path; got: ' + Url);
        _Assert.IsTrue(Url.Contains('email=an%2Blu%26co%3D1%25%40test.com'), 'Reserved characters in a query value must be percent-encoded; got: ' + Url);
        _Assert.IsTrue(Url.Contains('from=2026-09-11T05%3A28%3A38Z'), 'A colon in a query value must be percent-encoded; got: ' + Url);
        _Assert.IsTrue(Url.EndsWith('&pageKey=next-Key_1'), 'The new page key must be appended last, unencoded; got: ' + Url);
        _Assert.IsFalse(Url.Contains('pageKey=stale'), 'The stale page key must not be carried into the continuation URL; got: ' + Url);
        _Assert.AreEqual(2, Url.Split('&').Count() - 1, 'The URL must carry exactly the two request parameters plus the page key; got: ' + Url);
    end;

    local procedure TextOf(Response: Codeunit "NPR API Response"; PropertyName: Text) Value: Text
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Response.GetJson().Get(PropertyName, Token), StrSubstNo(_EnvelopePropertyErrLbl, PropertyName));
        Value := Token.AsValue().AsText();
    end;

    local procedure BooleanOf(Response: Codeunit "NPR API Response"; PropertyName: Text) Value: Boolean
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Response.GetJson().Get(PropertyName, Token), StrSubstNo(_EnvelopePropertyErrLbl, PropertyName));
        Value := Token.AsValue().AsBoolean();
    end;

    local procedure FindWithParams(QueryParams: Dictionary of [Text, Text]) Response: Codeunit "NPR API Response"
    var
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        Request: Codeunit "NPR API Request";
        EmptyBody: JsonToken;
        Headers: Dictionary of [Text, Text];
        PathSegments: List of [Text];
    begin
        // Fixture rows must be committed: the find reads ReadCommitted and would otherwise report a phantom no-match.
        Commit();

        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        Request.Init("Http Method"::GET, '/ecommerce/documents', PathSegments, QueryParams, Headers, EmptyBody);
        Response := ApiAgent.FindIncomingEcomDocumentsByEmail(Request);
    end;

    // Decodes the way the proxy does before handing values to AL: form-style, so a bare '+' is a space and '%2B' is a plus.
    local procedure QueryParamsOfUrl(Url: Text) QueryParams: Dictionary of [Text, Text]
    var
        Uri: Codeunit Uri;
        Pair: Text;
        Separator: Integer;
    begin
        foreach Pair in Url.Substring(Url.IndexOf('?') + 1).Split('&') do begin
            Separator := Pair.IndexOf('=');
            QueryParams.Add(
                Uri.UnescapeDataString(Pair.Substring(1, Separator - 1).Replace('+', ' ')),
                Uri.UnescapeDataString(Pair.Substring(Separator + 1).Replace('+', ' ')));
        end;
    end;

    local procedure GetById(DocumentId: Guid) Response: Codeunit "NPR API Response"
    var
        ApiAgent: Codeunit "NPR EcomSalesDocApiAgentV2";
        Request: Codeunit "NPR API Request";
        EmptyBody: JsonToken;
        Headers: Dictionary of [Text, Text];
        QueryParams: Dictionary of [Text, Text];
        PathSegments: List of [Text];
        DocumentIdText: Text;
    begin
        DocumentIdText := Format(DocumentId, 0, 4).ToLower();
        PathSegments.Add('ecommerce');
        PathSegments.Add('documents');
        PathSegments.Add(DocumentIdText);
        Request.Init("Http Method"::GET, '/ecommerce/documents/' + DocumentIdText, PathSegments, QueryParams, Headers, EmptyBody);
        Response := ApiAgent.GetIncomingEcomDocumentById(Request);
    end;

    // A try method, so that an endpoint that refuses the document yields an outcome the Then can assert instead of aborting the test.
    [TryFunction]
    local procedure TryGetById(DocumentId: Guid; var Response: Codeunit "NPR API Response")
    begin
        Response := GetById(DocumentId);
    end;

    local procedure GetByIdDocumentText(DocumentId: Guid) DocumentText: Text
    var
        Response: Codeunit "NPR API Response";
    begin
        Commit();
        Response := GetById(DocumentId);
        _Assert.AreEqual(200, Response.GetStatusCode(), 'Arrangement: GET by id must succeed for the document under comparison.');
        Response.GetJson().WriteTo(DocumentText);
    end;

    local procedure FirstPaymentPspTokenOfGetById(DocumentId: Guid): Text
    var
        Response: Codeunit "NPR API Response";
        Token: JsonToken;
        Payments: JsonArray;
    begin
        Commit();
        Response := GetById(DocumentId);
        _Assert.AreEqual(200, Response.GetStatusCode(), 'Arrangement: GET by id must succeed.');
        _Assert.IsTrue(SalesDocumentOf(Response).Get('payments', Token), 'GET by id must carry the payments array.');
        Payments := Token.AsArray();
        _Assert.AreEqual(1, Payments.Count(), 'GET by id must carry the one seeded payment line.');
        Payments.Get(0, Token);
        _Assert.IsTrue(Token.AsObject().Get('pspToken', Token), 'The payment must carry pspToken.');
        exit(Token.AsValue().AsText());
    end;

    local procedure SalesDocumentsOf(Response: Codeunit "NPR API Response") Documents: JsonArray
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Response.GetJson().Get('salesDocuments', Token), 'The response envelope must carry a salesDocuments array.');
        Documents := Token.AsArray();
    end;

    // The GET-by-id body is the document object itself - the builder's first StartObject sets the root, so no envelope.
    local procedure SalesDocumentOf(Response: Codeunit "NPR API Response") Document: JsonObject
    begin
        Document := Response.GetJson();
        _Assert.IsTrue(Document.Contains('externalNo'), 'Arrangement: the GET by id body must be the e-commerce document object.');
    end;

    local procedure MessageOf(Response: Codeunit "NPR API Response") ErrorMessage: Text
    var
        Token: JsonToken;
    begin
        if Response.GetJson().Get('message', Token) then
            ErrorMessage := Token.AsValue().AsText();
    end;

    local procedure StatusCodeOf(ResponseJson: JsonObject) StatusCode: Integer
    var
        Token: JsonToken;
    begin
        if ResponseJson.Get('statusCode', Token) then
            StatusCode := Token.AsValue().AsInteger();
    end;

    local procedure HitAt(Documents: JsonArray; Index: Integer) Hit: JsonObject
    var
        HitToken: JsonToken;
    begin
        _Assert.IsTrue(Documents.Get(Index, HitToken), StrSubstNo(_MissingHitAtIndexErrLbl, Index));
        Hit := HitToken.AsObject();
    end;

    local procedure HitText(Documents: JsonArray; Index: Integer) Value: Text
    begin
        HitAt(Documents, Index).WriteTo(Value);
    end;

    local procedure TextAt(Documents: JsonArray; Index: Integer; PropertyName: Text) Value: Text
    var
        ValueToken: JsonToken;
    begin
        _Assert.IsTrue(HitAt(Documents, Index).Get(PropertyName, ValueToken), StrSubstNo(_HitPropertyErrLbl, Index, PropertyName));
        Value := ValueToken.AsValue().AsText();
    end;

    local procedure IdAt(Documents: JsonArray; Index: Integer) Value: Text
    var
        HitToken: JsonToken;
        ValueToken: JsonToken;
    begin
        _Assert.IsTrue(Documents.Get(Index, HitToken), StrSubstNo(_MissingHitAtIndexErrLbl, Index));
        _Assert.IsTrue(HitToken.AsObject().Get('id', ValueToken), 'Every hit must carry an id.');
        Value := ValueToken.AsValue().AsText();
    end;

    local procedure ArrayAt(Documents: JsonArray; Index: Integer; PropertyName: Text) Value: JsonArray
    var
        ValueToken: JsonToken;
    begin
        _Assert.IsTrue(HitAt(Documents, Index).Get(PropertyName, ValueToken), StrSubstNo(_HitPropertyErrLbl, Index, PropertyName));
        Value := ValueToken.AsArray();
    end;

    local procedure ArrayContains(Values: JsonArray; Expected: Text): Boolean
    var
        ValueToken: JsonToken;
    begin
        foreach ValueToken in Values do
            if ValueToken.AsValue().AsText() = Expected then
                exit(true);
    end;

    local procedure ContainsId(Documents: JsonArray; DocumentId: Guid): Boolean
    var
        HitToken: JsonToken;
        ValueToken: JsonToken;
        ExpectedId: Text;
    begin
        ExpectedId := Format(DocumentId, 0, 4).ToLower();
        foreach HitToken in Documents do
            if HitToken.AsObject().Get('id', ValueToken) then
                if ValueToken.AsValue().AsText() = ExpectedId then
                    exit(true);
    end;

    local procedure CountDocumentTypes(Documents: JsonArray; var OrderCount: Integer; var ReturnOrderCount: Integer)
    var
        Index: Integer;
    begin
        for Index := 0 to Documents.Count() - 1 do
            case TextAt(Documents, Index, 'documentType') of
                'order':
                    OrderCount += 1;
                'returnOrder':
                    ReturnOrderCount += 1;
            end;
    end;

    local procedure CreationStatusOfId(Documents: JsonArray; DocumentId: Text): Text
    begin
        exit(PropertyOfId(Documents, DocumentId, 'creationStatus'));
    end;

    local procedure PostingStatusOfId(Documents: JsonArray; DocumentId: Text): Text
    begin
        exit(PropertyOfId(Documents, DocumentId, 'postingStatus'));
    end;

    local procedure PropertyOfId(Documents: JsonArray; DocumentId: Text; PropertyName: Text): Text
    var
        Index: Integer;
    begin
        for Index := 0 to Documents.Count() - 1 do
            if TextAt(Documents, Index, 'id') = DocumentId then
                exit(TextAt(Documents, Index, PropertyName));
        _Assert.Fail(StrSubstNo(_MissingHitErrLbl, DocumentId));
    end;

    // The twelve summary properties and nothing else: no lines, payments, comments, dimensions or custom fields.
    local procedure AssertSummaryProperties(Hit: JsonObject)
    var
        Token: JsonToken;
    begin
        _Assert.IsTrue(Hit.Contains('id'), 'A summary hit must carry id.');
        _Assert.IsTrue(Hit.Contains('externalNo'), 'A summary hit must carry externalNo.');
        _Assert.IsTrue(Hit.Contains('externalDocumentNo'), 'A summary hit must carry externalDocumentNo.');
        _Assert.IsTrue(Hit.Contains('documentType'), 'A summary hit must carry documentType.');
        _Assert.IsTrue(Hit.Contains('creationStatus'), 'A summary hit must carry creationStatus.');
        _Assert.IsTrue(Hit.Contains('postingStatus'), 'A summary hit must carry postingStatus.');
        _Assert.IsTrue(Hit.Contains('captureProcessingStatus'), 'A summary hit must carry captureProcessingStatus.');
        _Assert.IsTrue(Hit.Contains('currencyCode'), 'A summary hit must carry currencyCode.');
        _Assert.IsTrue(Hit.Contains('createdAt'), 'A summary hit must carry createdAt.');
        _Assert.IsTrue(Hit.Contains('createdDocumentNo'), 'A summary hit must carry createdDocumentNo.');
        _Assert.IsTrue(Hit.Contains('postedDocumentNos'), 'A summary hit must carry postedDocumentNos.');
        _Assert.IsTrue(Hit.Get('sellToCustomer', Token), 'A summary hit must carry sellToCustomer.');
        _Assert.AreEqual(12, Hit.Keys().Count(), 'A summary hit must carry exactly the twelve summary properties.');

        _Assert.IsTrue(Token.AsObject().Contains('no'), 'The summary sellToCustomer must carry no.');
        _Assert.IsTrue(Token.AsObject().Contains('name'), 'The summary sellToCustomer must carry name.');
        _Assert.IsTrue(Token.AsObject().Contains('email'), 'The summary sellToCustomer must carry email.');
        _Assert.IsTrue(Token.AsObject().Contains('phone'), 'The summary sellToCustomer must carry phone.');
        _Assert.AreEqual(4, Token.AsObject().Keys().Count(), 'The summary sellToCustomer must be trimmed to no, name, email and phone.');
    end;

    local procedure GrantEcomApiPermission()
    begin
        _LibAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), CopyStr(_EcomApiPermissionSetLbl, 1, 20));
    end;

    #endregion

    #region Request bodies

    local procedure BuildV2Body(ExternalNo: Code[20]; Email: Text; InvoiceEmail: Text) Body: JsonObject
    begin
        Body := BuildV2BodyForItem(ExternalNo, Email, InvoiceEmail, _LibEcom.CreateItem());
    end;

    local procedure BuildV2BodyForItem(ExternalNo: Code[20]; Email: Text; ItemNo: Code[20]) Body: JsonObject
    begin
        Body := BuildV2BodyForItem(ExternalNo, Email, '', ItemNo);
    end;

    local procedure BuildV2BodyForItem(ExternalNo: Code[20]; Email: Text; InvoiceEmail: Text; ItemNo: Code[20]) Body: JsonObject
    var
        Line: JsonObject;
        Lines: JsonArray;
    begin
        Body := BuildV2HeaderOnly(ExternalNo, Email, InvoiceEmail);
        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);
    end;

    local procedure BuildV2HeaderOnly(ExternalNo: Code[20]; Email: Text; InvoiceEmail: Text) Body: JsonObject
    var
        SellTo: JsonObject;
    begin
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        SellTo.Add('name', 'Anja Moeller');
        SellTo.Add('address', 'Tivoli Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Copenhagen');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', Email);
        if InvoiceEmail <> '' then
            SellTo.Add('invoiceEmail', InvoiceEmail);
        Body.Add('sellToCustomer', SellTo);
    end;

    local procedure BuildV2BodyWithMemberLine(ExternalNo: Code[20]; MemberEmail: Text) Body: JsonObject
    var
        Line: JsonObject;
        Lines: JsonArray;
    begin
        Body := BuildV2HeaderOnly(ExternalNo, 'buyer@tivoli.dk', '');
        Line.Add('type', 'item');
        Line.Add('no', _LibEcom.CreateEcomMembershipItem());
        Line.Add('quantity', 1);
        Line.Add('unitPrice', 100);
        Line.Add('vatPercent', 0);
        Line.Add('lineAmount', 100);
        Line.Add('memberFirstName', 'Kid');
        Line.Add('memberLastName', 'Moeller');
        Line.Add('memberEmail', MemberEmail);
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);
    end;

    // The previous API version requires sellToCustomer.type as well, and reads the same property names.
    local procedure BuildV1Body(ExternalNo: Code[20]; Email: Text; InvoiceEmail: Text) Body: JsonObject
    var
        Line: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
        SellTo: JsonObject;
    begin
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        SellTo.Add('type', 'person');
        SellTo.Add('name', 'Anja Moeller');
        SellTo.Add('address', 'Tivoli Street 1');
        SellTo.Add('postCode', '1234');
        SellTo.Add('city', 'Copenhagen');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', Email);
        SellTo.Add('invoiceEmail', InvoiceEmail);
        Body.Add('sellToCustomer', SellTo);

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

    // One donation line in the Entria shape: metadata.member_email is the flat property, metadata.members[0].email the fallback.
    local procedure BuildEntriaOrderJson(DocumentNo: Code[20]; Email: Text; FlatMemberEmail: Text; ArrayMemberEmail: Text) OrderToken: JsonToken
    var
        BillingAddress: JsonObject;
        ItemJson: JsonObject;
        Items: JsonArray;
        MemberJson: JsonObject;
        Members: JsonArray;
        Metadata: JsonObject;
        Order: JsonObject;
        Payment: JsonObject;
        PaymentCollection: JsonObject;
        PaymentCollections: JsonArray;
        PaymentData: JsonObject;
        Payments: JsonArray;
        TaxLines: JsonArray;
    begin
        Order.Add('id', 'order_' + DocumentNo);
        Order.Add('display_id', 16);
        Order.Add('custom_display_id', DocumentNo);
        Order.Add('email', Email);

        BillingAddress.Add('first_name', 'Anja');
        BillingAddress.Add('last_name', 'Moeller');
        BillingAddress.Add('address_1', 'Tivoli Street 1');
        BillingAddress.Add('city', 'Copenhagen');
        BillingAddress.Add('postal_code', '1234');
        BillingAddress.Add('country_code', 'dk');
        Order.Add('billing_address', BillingAddress);

        Metadata.Add('external_id', EntriaMembershipItemNo());
        Metadata.Add('price', 500);
        Metadata.Add('is_custom_price', true);
        Metadata.Add('membership_code', 'DONATIONSMEDLEM');
        if FlatMemberEmail <> '' then
            Metadata.Add('member_email', FlatMemberEmail);
        Metadata.Add('member_first_name', 'Kid');
        if ArrayMemberEmail <> '' then begin
            MemberJson.Add('first_name', 'Kid');
            MemberJson.Add('last_name', 'Moeller');
            MemberJson.Add('email', ArrayMemberEmail);
            Members.Add(MemberJson);
            Metadata.Add('members', Members);
        end;

        ItemJson.Add('id', 'ordli_' + DocumentNo);
        ItemJson.Add('title', 'Donation');
        ItemJson.Add('product_type', 'DONATION');
        ItemJson.Add('is_giftcard', false);
        ItemJson.Add('quantity', 1);
        ItemJson.Add('unit_price', 500);
        ItemJson.Add('subtotal', 500);
        ItemJson.Add('total', 500);
        ItemJson.Add('tax_total', 0);
        ItemJson.Add('tax_lines', TaxLines);
        ItemJson.Add('metadata', Metadata);
        Items.Add(ItemJson);
        Order.Add('items', Items);

        // The importer refuses an order with no payment collections, so the payload needs one.
        PaymentData.Add('pspReference', 'TEST-' + DocumentNo);
        PaymentData.Add('paymentMethod', 'visa');
        Payment.Add('amount', 500);
        Payment.Add('provider_id', 'pp_entria-adyen_adyen');
        Payment.Add('data', PaymentData);
        Payments.Add(Payment);
        PaymentCollection.Add('payments', Payments);
        PaymentCollections.Add(PaymentCollection);
        Order.Add('payment_collections', PaymentCollections);

        OrderToken := Order.AsToken();
    end;

    #endregion

    #region Fixture helpers

    // Hands the writer a customer card directly, so the test pins normalisation rather than customer mapping.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnBeforeFindCustomerInEcommerceDocument', '', false, false)]
    local procedure OnBeforeFindCustomerInEcommerceDocument(OrderJsonToken: JsonToken; var Customer: Record Customer; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var IsHandled: Boolean)
    begin
        Customer."E-Mail" := ' AnDrei@Test.com ';
        IsHandled := true;
    end;

    local procedure InsertEcomDoc(Email: Text; DocumentType: Enum "NPR Ecom Sales Doc Type"; CreationStatus: Enum "NPR EcomSalesDocCrtStatus"; PostingStatus: Enum "NPR EcomSalesDocPostStatus") EcomSalesHeader: Record "NPR Ecom Sales Header"
    begin
        EcomSalesHeader := InsertEcomDoc(Email, _LibEcom.NextExternalNo('TIVFND'), DocumentType, CreationStatus, PostingStatus, '');
    end;

    local procedure InsertEcomDocWithExternalNo(Email: Text; ExternalNo: Code[20]; StoreCode: Code[20]) EcomSalesHeader: Record "NPR Ecom Sales Header"
    begin
        EcomSalesHeader := InsertEcomDoc(Email, ExternalNo, "NPR Ecom Sales Doc Type"::Order, "NPR EcomSalesDocCrtStatus"::Created, "NPR EcomSalesDocPostStatus"::Pending, StoreCode);
    end;

    local procedure InsertEcomDoc(Email: Text; ExternalNo: Code[20]; DocumentType: Enum "NPR Ecom Sales Doc Type"; CreationStatus: Enum "NPR EcomSalesDocCrtStatus"; PostingStatus: Enum "NPR EcomSalesDocPostStatus"; StoreCode: Code[20]) EcomSalesHeader: Record "NPR Ecom Sales Header"
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader."External Document No." := ExternalNo;
        EcomSalesHeader."Document Type" := DocumentType;
        EcomSalesHeader."Creation Status" := CreationStatus;
        EcomSalesHeader."Posting Status" := PostingStatus;
        EcomSalesHeader."Ecommerce Store Code" := StoreCode;
        EcomSalesHeader."Sell-to Name" := 'Anja Moeller';
        EcomSalesHeader."Sell-to Email" := CopyStr(Email, 1, MaxStrLen(EcomSalesHeader."Sell-to Email"));
        EcomSalesHeader.Insert(true);
    end;

    local procedure InsertEcomDoc(Email: Text; DocumentType: Enum "NPR Ecom Sales Doc Type"; CreationStatus: Enum "NPR EcomSalesDocCrtStatus"; PostingStatus: Enum "NPR EcomSalesDocPostStatus"; CreatedDocNo: Code[20]) EcomSalesHeader: Record "NPR Ecom Sales Header"
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := _LibEcom.NextExternalNo('TIVSHP');
        EcomSalesHeader."External Document No." := EcomSalesHeader."External No.";
        EcomSalesHeader."Document Type" := DocumentType;
        EcomSalesHeader."Creation Status" := CreationStatus;
        EcomSalesHeader."Posting Status" := PostingStatus;
        EcomSalesHeader."Created Doc No." := CreatedDocNo;
        EcomSalesHeader."Currency Code" := '';
        EcomSalesHeader."Sell-to Name" := 'Anja Moeller';
        EcomSalesHeader."Sell-to Phone No." := '12345678';
        EcomSalesHeader."Sell-to Email" := CopyStr(Email, 1, MaxStrLen(EcomSalesHeader."Sell-to Email"));
        EcomSalesHeader.Insert(true);
        // Re-read: the endpoints serve the persisted SystemCreatedAt, which can round a millisecond off the pre-persist value.
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
    end;

    // A direct Insert, exactly as a pre-change document sits in the database - a writer would normalise it.
    local procedure InsertEcomDoc(Email: Text; InvoiceEmail: Text) EcomSalesHeader: Record "NPR Ecom Sales Header"
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := _LibEcom.NextExternalNo('TIVUPG');
        EcomSalesHeader."External Document No." := EcomSalesHeader."External No.";
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Created;
        EcomSalesHeader."Posting Status" := EcomSalesHeader."Posting Status"::Pending;
        EcomSalesHeader."Sell-to Name" := 'Anja Moeller';
        EcomSalesHeader."Sell-to Email" := CopyStr(Email, 1, MaxStrLen(EcomSalesHeader."Sell-to Email"));
        EcomSalesHeader."Sell-to Invoice Email" := CopyStr(InvoiceEmail, 1, MaxStrLen(EcomSalesHeader."Sell-to Invoice Email"));
        EcomSalesHeader.Insert(true);
    end;

    local procedure InsertEcomSalesLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; LineNo: Integer)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := LineNo;
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Description := 'Line ' + Format(LineNo);
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := 100;
        EcomSalesLine."Line Amount" := 100;
        EcomSalesLine.Insert(true);
    end;

    local procedure InsertEcomSalesPmtLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; PspToken: Text)
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesPmtLine."Line No." := 10000;
        EcomSalesPmtLine."Payment Method Type" := EcomSalesPmtLine."Payment Method Type"::"Payment Method";
        EcomSalesPmtLine.Amount := 100;
        EcomSalesPmtLine."PSP Token" := CopyStr(PspToken, 1, MaxStrLen(EcomSalesPmtLine."PSP Token"));
        EcomSalesPmtLine.Insert(true);
    end;

    local procedure InsertEcomSalesLineWithMemberEmail(EcomSalesHeader: Record "NPR Ecom Sales Header"; MemberEmail: Text)
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := CopyStr(EcomSalesHeader."External No.", 1, MaxStrLen(EcomSalesLine."External Document No."));
        EcomSalesLine."Line No." := 10000;
        EcomSalesLine.Type := EcomSalesLine.Type::Item;
        EcomSalesLine.Description := 'Membership';
        EcomSalesLine.Quantity := 1;
        EcomSalesLine."Unit Price" := 100;
        EcomSalesLine."Line Amount" := 100;
        EcomSalesLine."Member Email" := CopyStr(MemberEmail, 1, MaxStrLen(EcomSalesLine."Member Email"));
        EcomSalesLine.Insert(true);
    end;

    local procedure InsertSalesOrderWithEmail(Tag: Text; Email: Text) SalesOrderNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesOrderNo := CopyStr('TIVSO' + Tag, 1, MaxStrLen(SalesOrderNo));
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := SalesOrderNo;
        SalesHeader."Sell-to E-Mail" := CopyStr(Email, 1, MaxStrLen(SalesHeader."Sell-to E-Mail"));
        SalesHeader.Insert();
    end;

    local procedure InsertSalesOrderForCustomer(Tag: Text; CustomerNo: Code[20]) SalesOrderNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesOrderNo := CopyStr('TIVUSO' + Tag, 1, MaxStrLen(SalesOrderNo));
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := SalesOrderNo;
        SalesHeader."Sell-to Customer No." := CustomerNo;
        SalesHeader.Insert();
    end;

    local procedure InsertPostedSalesInvoiceWithEmail(Tag: Text; Email: Text)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := CopyStr('TIVPSI' + Tag, 1, MaxStrLen(SalesInvoiceHeader."No."));
        SalesInvoiceHeader."Sell-to E-Mail" := CopyStr(Email, 1, MaxStrLen(SalesInvoiceHeader."Sell-to E-Mail"));
        SalesInvoiceHeader.Insert();
    end;

    local procedure InsertPostedSalesInvoice(DocumentNo: Code[20]; EcomSaleId: Guid)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := DocumentNo;
        SalesInvoiceHeader."NPR Inc Ecom Sale Id" := EcomSaleId;
        SalesInvoiceHeader.Insert();
    end;

    local procedure InsertPostedSalesInvoice(Tag: Text; EcomSaleId: Guid; CustomerNo: Code[20])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := CopyStr('TIVUPSI' + Tag, 1, MaxStrLen(SalesInvoiceHeader."No."));
        SalesInvoiceHeader."Sell-to Customer No." := CustomerNo;
        SalesInvoiceHeader."NPR Inc Ecom Sale Id" := EcomSaleId;
        SalesInvoiceHeader.Insert();
    end;

    local procedure InsertPostedSalesCreditMemo(DocumentNo: Code[20]; EcomSaleId: Guid)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        SalesCrMemoHeader.Init();
        SalesCrMemoHeader."No." := DocumentNo;
        SalesCrMemoHeader."NPR Inc Ecom Sale Id" := EcomSaleId;
        SalesCrMemoHeader.Insert();
    end;

    local procedure InsertLegacyNpEcDocument(SalesOrderNo: Code[20])
    var
        NpEcDocument: Record "NPR NpEc Document";
    begin
        NpEcDocument.Init();
        NpEcDocument."Store Code" := 'MAGENTO';
        NpEcDocument."Reference No." := CopyStr(SalesOrderNo, 1, MaxStrLen(NpEcDocument."Reference No."));
        NpEcDocument."Document Type" := NpEcDocument."Document Type"::"Sales Order";
        NpEcDocument."Document No." := SalesOrderNo;
        NpEcDocument.Insert(true);
    end;

    // Inserted directly: these tests only read E-Mail through a filter, so no posting setup is needed.
    [TryFunction]
    local procedure TryCountCustomersForEmail(Email: Text; var HitCount: Integer; var FoundCustomerNo: Code[20])
    var
        Customer: Record Customer;
        EcomSalesDocUtils: Codeunit "NPR Ecom Sales Doc Utils";
    begin
        EcomSalesDocUtils.SetCustomerEmailFilter(Customer, Email);
        HitCount := Customer.Count();
        FoundCustomerNo := '';
        if Customer.FindFirst() then
            FoundCustomerNo := Customer."No.";
    end;

    local procedure InsertCustomerWithNoAndEmail(CustomerNo: Code[20]; Email: Text) InsertedCustomerNo: Code[20]
    var
        Customer: Record Customer;
    begin
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'Anja Moeller';
        Customer."E-Mail" := CopyStr(Email, 1, MaxStrLen(Customer."E-Mail"));
        Customer.Insert();
        InsertedCustomerNo := Customer."No.";
    end;

    local procedure InsertCustomerWithEmail(Tag: Text; Email: Text) CustomerNo: Code[20]
    var
        Customer: Record Customer;
    begin
        CustomerNo := CopyStr('TIVCAS' + Tag, 1, MaxStrLen(CustomerNo));
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'Anja Moeller';
        Customer."E-Mail" := CopyStr(Email, 1, MaxStrLen(Customer."E-Mail"));
        Customer.Insert();
    end;

    local procedure InsertUpgradeCustomerWithEmail(Tag: Text; Email: Text) CustomerNo: Code[20]
    var
        Customer: Record Customer;
    begin
        CustomerNo := CopyStr('TIVUPG' + Tag, 1, MaxStrLen(CustomerNo));
        Customer.Init();
        Customer."No." := CustomerNo;
        Customer.Name := 'Anja Moeller';
        Customer."E-Mail" := CopyStr(Email, 1, MaxStrLen(Customer."E-Mail"));
        Customer.Insert();
    end;

    local procedure GetEntriaStore(var EntriaStore: Record "NPR Entria Store")
    var
        EntriaSetup: Record "NPR Entria Integration Setup";
        StoreCodeLbl: Label 'NPRENT-CAS', Locked = true, MaxLength = 20;
    begin
        if not EntriaSetup.Get() then begin
            EntriaSetup.Init();
            EntriaSetup.Insert();
        end;

        if EntriaStore.Get(StoreCodeLbl) then
            exit;

        EntriaStore.Init();
        EntriaStore.Code := StoreCodeLbl;
        EntriaStore."Entria Url" := 'https://entria.test';
        EntriaStore.Enabled := true;
        EntriaStore."Sales Order Integration" := true;
        EntriaStore.Insert();
    end;

    // A membership item the Entria importer treats as a membership line, so the member-e-mail sites are reached.
    local procedure EntriaMembershipItemNo() ItemNo: Code[20]
    var
        Item: Record Item;
        ItemNoLbl: Label 'TIV-CAS-DON', Locked = true, MaxLength = 20;
    begin
        ItemNo := CopyStr(ItemNoLbl, 1, MaxStrLen(ItemNo));
        if Item.Get(ItemNo) then
            exit;
        SetUpDonationMembershipItem(ItemNo);
    end;

    local procedure SetUpDonationMembershipItem(ItemNo: Code[20])
    var
        MemberCommunity: Record "NPR MM Member Community";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberModuleLib: Codeunit "NPR Library - Member Module";
        MembershipCodeLbl: Label 'DONATIONSMEDLEM', Locked = true, MaxLength = 20;
        CommunityCode: Code[20];
        MembershipCode: Code[20];
    begin
        MemberModuleLib.Initialize();
        CommunityCode := MemberModuleLib.SetupCommunity_Simple();
        MemberCommunity.Get(CommunityCode);
        MemberCommunity."Member Unique Identity" := MemberCommunity."Member Unique Identity"::NONE;
        MemberCommunity."Member Logon Credentials" := MemberCommunity."Member Logon Credentials"::NA;
        MemberCommunity."Membership to Cust. Rel." := false;
        MemberCommunity.Modify();

        MembershipCode := CopyStr(MembershipCodeLbl, 1, MaxStrLen(MembershipCode));
        MemberModuleLib.SetupMembership_Simple(CommunityCode, MembershipCode, '', 'Donation Membership');
        MembershipSetup.Get(MembershipCode);
        MembershipSetup."Membership Type" := MembershipSetup."Membership Type"::INDIVIDUAL;
        MembershipSetup."Membership Member Cardinality" := 1;
        MembershipSetup.Modify();

        MemberModuleLib.CreateItem(ItemNo, '', 'Donation Item', 0);
        MemberModuleLib.SetupSimpleMembershipSalesItem(ItemNo, MembershipCode);

        MembershipSalesSetup.SetRange("Membership Code", MembershipCode);
        if MembershipSalesSetup.FindFirst() then begin
            MembershipSalesSetup.Blocked := false;
            MembershipSalesSetup.Modify();
        end;
    end;

    local procedure SetCustomerMappingByEmailAndCreateOnly()
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        _LibEcom.GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Customer Mapping" := IncEcomSalesDocSetup."Customer Mapping"::"E-mail";
        IncEcomSalesDocSetup."Customer Update Mode" := IncEcomSalesDocSetup."Customer Update Mode"::Create;
        IncEcomSalesDocSetup.Modify();
    end;

    local procedure SetCustomerMappingByEmailAndCreateAndUpdate()
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        _LibEcom.GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Customer Mapping" := IncEcomSalesDocSetup."Customer Mapping"::"E-mail";
        IncEcomSalesDocSetup."Customer Update Mode" := IncEcomSalesDocSetup."Customer Update Mode"::"Create and Update";
        IncEcomSalesDocSetup.Modify();
    end;

    // The production batch size: a smaller one would make run time depend on the container's autoincrement history.
    local procedure BatchSize(): Integer
    begin
        exit(1000);
    end;

    local procedure IdOf(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    begin
        exit(Format(EcomSalesHeader.SystemId, 0, 4).ToLower());
    end;

    // Millisecond precision as text: Assert compares DateTime through a format that stops at the minute.
    local procedure CreatedAtOf(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    begin
        exit(Format(EcomSalesHeader.SystemCreatedAt, 0, 9));
    end;

    // A tag nobody else holds: the runner rolls back per codeunit, so a shared literal would let tests count each other's rows.
    local procedure NextTag() Tag: Text
    begin
        Tag := DelChr(Format(CreateGuid()), '=', '{}-').ToLower();
    end;

    local procedure LowerEmail(Tag: Text): Text
    begin
        exit('anja.moeller.' + Tag + '@tivoli.dk');
    end;

    // The runner rolls back per codeunit, so every test owns its own search e-mail.
    local procedure NextEmail(): Text
    begin
        exit('anja.moeller.' + DelChr(Format(CreateGuid()), '=', '{}-').ToLower() + '@tivoli.dk');
    end;

    // Generated, not the spec's literal numbers: a posted header is a real row in a shared table and a fixed no. would collide.
    local procedure NextDocumentNo(Prefix: Code[4]) DocumentNo: Code[20]
    begin
        DocumentNo := CopyStr(Prefix + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(DocumentNo));
    end;

    local procedure NextEntriaDocumentNo() DocumentNo: Code[20]
    begin
        DocumentNo := CopyStr('ENTCAS' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(DocumentNo));
    end;

    // Exactly 80 characters - the stored Sell-to Email length - so a caller can append one more and still match the first 80.
    local procedure EmailOfLength80(Tag: Text) Email: Text
    var
        DomainTok: Label '@tivoli.dk', Locked = true;
    begin
        Email := PadStr('', 80 - StrLen(DomainTok) - StrLen(Tag), 'a') + Tag + DomainTok;
        _Assert.AreEqual(80, StrLen(Email), 'Arrangement: the boundary e-mail must be exactly 80 characters long.');
    end;

    #endregion
}

codeunit 85594 "NPR Ecom Doc V1 Tests"
{
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _LibAPI: Codeunit "NPR Library - NPRetail API";
        _LibEcom: Codeunit "NPR Library Ecommerce";
        _FullNoteLinkIds: List of [Integer];
        _EcomApiPermissionSetLbl: Label 'NPR API Ecom', Locked = true;
        _ApiVersionHeaderLbl: Label 'x-api-version', Locked = true;
        _MixedCaseHeaderLbl: Label 'X-Api-Version', Locked = true;
        _DocumentsPathLbl: Label 'ecommerce/documents', Locked = true;
        _CustomFieldsLbl: Label 'customFields', Locked = true;
        _AtVersionLbl: Label '%1 (x-api-version ''%2'')', Locked = true;
        _V1RootKeysLbl: Label 'externalNo,id,documentType,creationStatus,postingStatus,currencyCode,currencyExchangeRate,externalDocumentNo,yourReference,locationCode,pricesExcludingVat,sellToCustomer,shipToCustomer,shipment,comments,payments,salesDocumentLines', Locked = true;
        _V1HeaderOnlyRootKeysLbl: Label 'externalNo,id,documentType,creationStatus,postingStatus,currencyCode,currencyExchangeRate,externalDocumentNo,yourReference,locationCode,pricesExcludingVat,sellToCustomer,shipToCustomer,shipment', Locked = true;
        _V1SellToKeysLbl: Label 'no,type,name,address,address2,postCode,county,city,countryCode,contact,email,phone,ean,vatRegistrationNo,invoiceEmail', Locked = true;
        _ShipToKeysLbl: Label 'name,address,address2,postCode,county,city,countryCode,contact', Locked = true;
        _ShipmentKeysLbl: Label 'shipmentMethod,shipmentService', Locked = true;
        _CommentKeysLbl: Label 'id,comment', Locked = true;
        _V1PaymentKeysLbl: Label 'id,paymentMethodType,externalPaymentMethodCode,externalPaymentType,paymentReference,paymentAmount,pspToken,cardExpiryDate,cardBrand,maskedCardNumber,parToken,cardAliasToken,capturedPaymentAmount', Locked = true;
        _V1LineKeysLbl: Label 'id,type,no,variantCode,barcodeNo,description,unitPrice,quantity,unitOfMeasure,vatPercent,lineAmount,requestedDeliveryDate,invoicedQuantity,invoicedAmount', Locked = true;
        _V2EnvelopeKeysLbl: Label 'salesDocuments,morePages,nextPageKey,nextPageURL', Locked = true;
        _V2SummaryKeysLbl: Label 'externalNo,id,documentType,creationStatus,postingStatus,currencyCode,externalDocumentNo,captureProcessingStatus,createdAt,createdDocumentNo,postedDocumentNos,sellToCustomer', Locked = true;
        _V2SummarySellToKeysLbl: Label 'no,name,email,phone', Locked = true;
        _V2DetailedKeysLbl: Label 'externalNo,id,documentType,creationStatus,postingStatus,currencyCode,currencyExchangeRate,externalDocumentNo,yourReference,languageTag,locationCode,pricesExcludingVat,ticketReservationToken,captureProcessingStatus,lastCaptureErrorMessage,createdAt,createdDocumentNo,postedDocumentNos,sellToCustomer,shipToCustomer,shipment,comments,salesDocumentLines', Locked = true;
        _V2DetailedSellToKeysLbl: Label 'no,name,address,address2,postCode,county,city,countryCode,contact,email,phone,ean,vatRegistrationNo,invoiceEmail', Locked = true;
        _V2DetailedLineKeysLbl: Label 'id,type,no,variantCode,barcodeNo,description,unitPrice,quantity,unitOfMeasure,vatPercent,lineAmount,requestedDeliveryDate,invoicedQuantity,invoicedAmount,captured,virtualItemProcessStatus,virtualItemProcessErrorMessage,attractionWalletProcessStatus,attractionWalletProcessErrorMessage,ticketReservationLineId,membershipId,membershipOperation,memberFirstName,memberLastName,memberMiddleName,memberEmail,memberPhoneNo,memberBirthday,memberGender,memberAddress,memberCity,memberCountry,memberPostCode,memberNewsletter,memberGdprApproval,membershipActivationDate,subscription,issuedAssets', Locked = true;
        _ForeignCompanyLbl: Label 'V1 OTHER CO', Locked = true;
        _FullNote1Lbl: Label 'V1 first note', Locked = true;
        _FullNote2Lbl: Label 'V1 second note', Locked = true;
        _ForeignNoteLbl: Label 'V1 foreign-company note', Locked = true;
        _FullCurrencyLbl: Label 'EUR', Locked = true;
        _FullExtDocNoLbl: Label 'V1-EXT-DOC-001', Locked = true;
        _YourReferenceLbl: Label 'V1 your reference', Locked = true;
        _LocationLbl: Label 'V1LOC', Locked = true;
        _FullCustomerNoLbl: Label 'V1-CUST-001', Locked = true;
        _FullCustomerTypeLbl: Label 'company', Locked = true;
        _FullSellToNameLbl: Label 'V1 Sell-to Name', Locked = true;
        _FullSellToAddressLbl: Label 'V1 Sell-to Street 1', Locked = true;
        _FullSellToAddress2Lbl: Label 'V1 Sell-to Floor 2', Locked = true;
        _FullSellToPostCodeLbl: Label 'V1-1111', Locked = true;
        _FullSellToCountyLbl: Label 'V1 Sell County', Locked = true;
        _FullSellToCityLbl: Label 'V1 Sell City', Locked = true;
        _FullSellToContactLbl: Label 'V1 Sell Contact', Locked = true;
        _FullPhoneLbl: Label '+4511111111', Locked = true;
        _FullEanLbl: Label '5790000000001', Locked = true;
        _FullVatLbl: Label 'DK11111111', Locked = true;
        _FullInvoiceEmailLbl: Label 'v1.invoice@versioning.test', Locked = true;
        _FullShipToNameLbl: Label 'V1 Ship-to Name', Locked = true;
        _FullShipToAddressLbl: Label 'V1 Ship-to Street 9', Locked = true;
        _FullShipToAddress2Lbl: Label 'V1 Ship-to Back Door', Locked = true;
        _FullShipToPostCodeLbl: Label 'V1-2222', Locked = true;
        _FullShipToCountyLbl: Label 'V1 Ship County', Locked = true;
        _FullShipToCityLbl: Label 'V1 Ship City', Locked = true;
        _FullShipToContactLbl: Label 'V1 Ship Contact', Locked = true;
        _FullShipMethodLbl: Label 'V1-SHIP-METHOD', Locked = true;
        _FullShipServiceLbl: Label 'V1-SHIP-SERVICE', Locked = true;
        _CustomerTemplateLbl: Label 'V1TMPL', Locked = true;
        _ConfigTemplateLbl: Label 'V1CFG', Locked = true;
        _LanguageTagLbl: Label 'da-DK', Locked = true;
        _TicketTokenLbl: Label 'V1-TOKEN', Locked = true;
        _CaptureErrorLbl: Label 'V1 capture failed', Locked = true;
        _CreatedDocNoLbl: Label 'V1-SO-1', Locked = true;
        _FullP1CodeLbl: Label 'V1-PAY-METHOD', Locked = true;
        _FullP1TypeLbl: Label 'V1-PAY-TYPE', Locked = true;
        _FullP1ReferenceLbl: Label 'V1-PAY-REF', Locked = true;
        _FullP1PspLbl: Label 'V1-PSP', Locked = true;
        _FullP1ExpiryLbl: Label '03/2030', Locked = true;
        _FullP1BrandLbl: Label 'visa', Locked = true;
        _FullP1MaskedLbl: Label '411111******1111', Locked = true;
        _FullP1ParLbl: Label 'V1-PAR', Locked = true;
        _FullP1AliasLbl: Label 'V1-ALIAS', Locked = true;
        _FullP2CodeLbl: Label 'V1-PAY-METHOD-2', Locked = true;
        _FullL1NoLbl: Label 'V1-ITEM', Locked = true;
        _FullL1VariantLbl: Label 'V1VAR', Locked = true;
        _FullL1BarcodeLbl: Label 'V1-BARCODE', Locked = true;
        _FullL1DescriptionLbl: Label 'V1 item line', Locked = true;
        _UnitOfMeasureLbl: Label 'PCS', Locked = true;
        _FullL1ExternalLineIdLbl: Label 'V1-LINE-A', Locked = true;
        _FullL1MemberEmailLbl: Label 'member@versioning.test', Locked = true;
        _FullL2DescriptionLbl: Label 'V1 comment line', Locked = true;
        _FullL3NoLbl: Label 'V1-SHIPFEE', Locked = true;
        _FullL3DescriptionLbl: Label 'V1 shipment fee', Locked = true;
        _BodyCustomerNoLbl: Label 'V1-CUST-002', Locked = true;
        _BodyExtDocNoLbl: Label 'V1-EXT-DOC-002', Locked = true;
        _BodyCommentLbl: Label 'V1 header comment', Locked = true;
        _V2LineIdLbl: Label 'V1-LINE-1', Locked = true;

    [Test]
    procedure GivenEveryV1Field_WhenCreateDatedLastV1Day_ThenStoredAsV1ReadsItAndEchoedOnRead()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: JsonObject;
        Body: JsonObject;
        ExternalNo: Code[20];
        ItemNo: Code[20];
        PaymentCode: Code[50];
        Email: Text;
        TodayBefore: Date;
        TodayAfter: Date;
    begin
        // [Scenario] A create dated 2025-10-18, the last day V1 serves, answers 200 with only the id, stores the request
        //            the way V1 reads it and tries the conversion once. Read back with an empty header, the document
        //            echoes the request.

        // [Given] A retry budget of 1, a payment mapping, an item number that does not exist and a body with every value V1 reads
        Initialize(1);
        PaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ItemNo := MissingItemNo();
        ExternalNo := _LibEcom.NextExternalNo('V1C01');
        Email := NewEmail('c01');

        // [When] The body is created with x-api-version 2025-10-18
        TodayBefore := Today();
        Response := PostDocument(FullV1Body(ExternalNo, ItemNo, PaymentCode, Email), '2025-10-18', true);
        TodayAfter := Today();

        // [Then] The answer is 200 with exactly the id of the stored document
        _Assert.AreEqual(200, StatusOf(Response), 'A V1 create must answer HTTP 200.');
        Body := BodyOf(Response);
        AssertNoEmptyCustomFields(Body, 'Create answer');
        _Assert.AreEqual('id', KeysOf(Body), 'The create answer must carry exactly the id.');
        SingleHeader(ExternalNo, EcomSalesHeader);
        _Assert.AreEqual(IdText(EcomSalesHeader.SystemId), TextAt(Body, 'id'), 'The id must be the system id of the stored document.');

        // [Then] The header, the lines, the payments and the note hold the request as V1 reads it
        AssertStoredFullHeader(EcomSalesHeader, ExternalNo, Email, TodayBefore, TodayAfter);
        AssertStoredFullLines(EcomSalesHeader, ExternalNo, ItemNo);
        AssertStoredFullPayments(EcomSalesHeader, ExternalNo, PaymentCode);
        AssertStoredNote(EcomSalesHeader, ExternalNo, _BodyCommentLbl);

        // [Then] The conversion ran once and failed, and no sales document exists
        AssertServedByV1(EcomSalesHeader, 20251018D, 'C01');
        _Assert.AreEqual('', EcomSalesHeader."Created Doc No.", 'A failed conversion must leave Created Doc No. blank.');
        _Assert.AreEqual(0, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'A failed conversion must create no sales document.');
        _Assert.IsTrue((EcomSalesHeader."Bucket Id" >= 1) and (EcomSalesHeader."Bucket Id" <= 100), 'V1 create must assign a bucket between 1 and 100.');

        // [When] The document is read with an empty x-api-version
        DeleteForeignRecordLinks(EcomSalesHeader);
        Response := GetById(EcomSalesHeader.SystemId, '', true);

        // [Then] The answer echoes the request with the V1 keys of every object
        _Assert.AreEqual(200, StatusOf(Response), At('A V1 get by id must answer HTTP 200.', ''));
        Body := BodyOf(Response);
        AssertNoEmptyCustomFields(Body, At('Read back', ''));
        AssertV1Keys(Body, _V1RootKeysLbl, At('Read back', ''));
        _Assert.AreEqual(NormalizedText(ExpectedCreatedDocument(EcomSalesHeader, ExternalNo, ItemNo, PaymentCode, Email)), NormalizedText(WithoutCustomFields(Body)), At('The read-back document must echo the request.', ''));
    end;

    [Test]
    procedure GivenV1Bodies_WhenCreateUnderEachHeaderClass_ThenOnlyDatesBeforeV2AndZeroDatesReachV1()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: JsonObject;
        Headers: Dictionary of [Text, Text];
        V1Versions: List of [Text];
        V1Dates: List of [Date];
        ItemNo: Code[20];
        ExternalNo: Code[20];
        Email: Text;
        TodayBefore: Date;
        TodayAfter: Date;
        i: Integer;
    begin
        // [Scenario] A create whose header is a date before 2025-10-19 or evaluates to 0D reaches V1. One dated
        //            2025-10-19 or later, sent without the header, or sent with the header name in another case is stored
        //            by the V2 create. Only V1 requires sellToCustomer.type.

        // [Given] A retry budget of 1, V1 bodies on missing items and V2-valid bodies on a blocked item
        Initialize(1);
        ItemNo := BlockedItemNo();
        V1Versions.Add('2025-10-18');
        V1Dates.Add(20251018D);
        V1Versions.Add('2025-10-10');
        V1Dates.Add(20251010D);
        V1Versions.Add('2025-07-13');
        V1Dates.Add(20250713D);
        V1Versions.Add('2024-10-11');
        V1Dates.Add(20241011D);
        V1Versions.Add('');
        V1Dates.Add(0D);
        V1Versions.Add(' ');
        V1Dates.Add(0D);
        V1Versions.Add(TabValue());
        V1Dates.Add(0D);
        V1Versions.Add('0001-01-01');
        V1Dates.Add(0D);

        // [When] Each V1 body is created under one of the V1-era header values
        // [Then] Each answers 200 with the stored id and is stored by V1 with the requested date
        for i := 1 to V1Versions.Count() do begin
            ExternalNo := _LibEcom.NextExternalNo('V1C02');
            Email := NewEmail('c02');
            Response := PostDocument(MinimalV1Body(ExternalNo, MissingItemNo(), Email), V1Versions.Get(i), true);
            AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, V1Versions.Get(i));
            AssertServedByV1(EcomSalesHeader, V1Dates.Get(i), At('V1 row', V1Versions.Get(i)));
        end;

        // [When] V2-valid bodies are created dated 2026-10-28, 2026-10-29, without the header and with X-Api-Version
        // [Then] Each answers 200 and is stored by the V2 create
        PostV2Row(VersionHeaders('2026-10-28', true), ItemNo, 20261028D, 20261028D, '2026-10-28');
        PostV2Row(VersionHeaders('2026-10-29', true), ItemNo, 20261029D, 20261029D, '2026-10-29');
        Clear(Headers);
        TodayBefore := Today();
        ExternalNo := _LibEcom.NextExternalNo('V1C02');
        Response := PostWithHeaders(V2FieldsBody(ExternalNo, ItemNo, NewEmail('c02'), true), Headers);
        TodayAfter := Today();
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'no header');
        AssertServedByV2(EcomSalesHeader, TodayBefore, TodayAfter, 'no header');
        Headers.Add(_MixedCaseHeaderLbl, '2025-10-18');
        TodayBefore := Today();
        ExternalNo := _LibEcom.NextExternalNo('V1C02');
        Response := PostWithHeaders(V2FieldsBody(ExternalNo, ItemNo, NewEmail('c02'), true), Headers);
        TodayAfter := Today();
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'X-Api-Version');
        AssertServedByV2(EcomSalesHeader, TodayBefore, TodayAfter, 'X-Api-Version');

        // [When] A V2-valid body with sellToCustomer.type is created dated 2025-10-18 and 2025-10-19
        // [Then] V1 stores the first, without the V2-only values, and V2 the second
        ExternalNo := _LibEcom.NextExternalNo('V1C02A');
        Response := PostDocument(V2FieldsBody(ExternalNo, ItemNo, NewEmail('c02a'), true), '2025-10-18', true);
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'A 2025-10-18');
        AssertServedByV1(EcomSalesHeader, 20251018D, 'A 2025-10-18');
        _Assert.AreEqual('', FirstLineExternalId(EcomSalesHeader), 'V1 must not store externalLineId.');
        ExternalNo := _LibEcom.NextExternalNo('V1C02B');
        Response := PostDocument(V2FieldsBody(ExternalNo, ItemNo, NewEmail('c02b'), true), '2025-10-19', true);
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'B 2025-10-19');
        AssertServedByV2(EcomSalesHeader, 20251019D, 20251019D, 'B 2025-10-19');

        // [When] A V2-valid body without sellToCustomer.type is created dated 2025-10-18 and 2025-10-19
        // [Then] V1 refuses the first and stores nothing, and V2 stores the second
        ExternalNo := _LibEcom.NextExternalNo('V1C02C');
        Email := NewEmail('c02c');
        Response := PostDocument(V2FieldsBody(ExternalNo, ItemNo, Email, false), '2025-10-18', true);
        AssertErrorAnswer(Response, 400, 'generic_error', 'Required value missing: body/sellToCustomer.type', 'C 2025-10-18');
        AssertNothingStored(ExternalNo, Email, 'C 2025-10-18');
        ExternalNo := _LibEcom.NextExternalNo('V1C02D');
        Response := PostDocument(V2FieldsBody(ExternalNo, ItemNo, NewEmail('c02d'), false), '2025-10-19', true);
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'D 2025-10-19');
        AssertServedByV2(EcomSalesHeader, 20251019D, 20251019D, 'D 2025-10-19');
    end;

    [Test]
    procedure GivenRetryBudgets_WhenV1ConversionFails_ThenTheBudgetDecidesErrorOrPending()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Response: JsonObject;
        ExternalNo: Code[20];
        TodayBefore: Date;
        TodayAfter: Date;
    begin
        // [Scenario] When the conversion fails, the answer is still 200 and the retry budget decides between Error and Pending.

        // [Given] A retry budget of 1 and a V1 body whose conversion fails
        Initialize(1);
        ExternalNo := _LibEcom.NextExternalNo('V1C03A');

        // [When] The body is created dated 2025-10-18
        TodayBefore := Today();
        Response := PostDocument(MinimalV1Body(ExternalNo, MissingItemNo(), NewEmail('c03a')), '2025-10-18', true);
        TodayAfter := Today();

        // [Then] The document is Error after one attempt, with an error dated today
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'budget 1');
        _Assert.AreEqual(1, EcomSalesHeader."Process Retry Count", 'Budget 1: one attempt must be counted.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Error, EcomSalesHeader."Creation Status", 'Budget 1: the failed attempt must end in Error.');
        _Assert.AreNotEqual('', EcomSalesHeader."Last Error Message", 'Budget 1: the error must be stored.');
        AssertWithinToday(EcomSalesHeader."Last Error Date", TodayBefore, TodayAfter, 'Budget 1: Last Error Date');

        // [Given] A retry budget of 3 and a second V1 body whose conversion fails
        _LibEcom.SetMaxDocProcessRetryCount(3);
        ExternalNo := _LibEcom.NextExternalNo('V1C03B');

        // [When] The body is created dated 2025-10-18
        TodayBefore := Today();
        Response := PostDocument(MinimalV1Body(ExternalNo, MissingItemNo(), NewEmail('c03b')), '2025-10-18', true);
        TodayAfter := Today();

        // [Then] The document stays Pending after one attempt, with an error dated today
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'budget 3');
        _Assert.AreEqual(1, EcomSalesHeader."Process Retry Count", 'Budget 3: one attempt must be counted.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", 'Budget 3: the failed attempt must leave the document Pending.');
        _Assert.AreNotEqual('', EcomSalesHeader."Last Error Message", 'Budget 3: the error must be stored.');
        AssertWithinToday(EcomSalesHeader."Last Error Date", TodayBefore, TodayAfter, 'Budget 3: Last Error Date');
    end;

    [Test]
    procedure GivenMalformedHeader_WhenAV1BodyIsCreated_ThenAnswers400AndStoresNothing()
    var
        Response: JsonObject;
        Body: JsonObject;
        ExternalNo: Code[20];
        Email: Text;
    begin
        // [Scenario] A create whose header is not a date answers 400 and stores nothing, although its body is one V1 would store.

        // [Given] A retry budget of 1 and a body V1 would store
        Initialize(1);
        ExternalNo := _LibEcom.NextExternalNo('V1C04');
        Email := NewEmail('c04');

        // [When] The body is created with x-api-version not-a-date
        Response := PostDocument(MinimalV1Body(ExternalNo, MissingItemNo(), Email), 'not-a-date', true);

        // [Then] The answer is 400 generic_error and nothing is stored
        _Assert.AreEqual(400, StatusOf(Response), 'A create whose header is not a date must answer HTTP 400.');
        Body := BodyOf(Response);
        _Assert.AreEqual('code,message', KeysOf(Body), 'The error answer must carry code and message.');
        _Assert.AreEqual('generic_error', TextAt(Body, 'code'), 'The error code must be generic_error.');
        AssertNothingStored(ExternalNo, Email, 'not-a-date');
    end;

    [Test]
    procedure GivenEachRequiredValueMissing_WhenCreateV1_ThenAnswersThePinned400AndStoresNothing()
    var
        PaymentCode: Code[50];
        ItemNo: Code[20];
    begin
        // [Scenario] V1 refuses a request that lacks a value it requires and names the missing path.

        // [Given] A retry budget of 1, a payment mapping and a body with every value V1 reads
        Initialize(1);
        PaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ItemNo := MissingItemNo();

        // [When] Each required value is removed in turn and the body is created dated 2025-10-18
        // [Then] Each answers 400 generic_error with the missing path and stores nothing
        AssertRequiredRemoved(PaymentCode, ItemNo, '', '', -1, 'externalNo', 'body/externalNo');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', '', -1, 'documentType', 'body/documentType');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', '', -1, 'sellToCustomer', 'body/sellToCustomer');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'sellToCustomer', '', -1, 'type', 'body/sellToCustomer.type');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'sellToCustomer', '', -1, 'name', 'body/sellToCustomer.name');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'sellToCustomer', '', -1, 'address', 'body/sellToCustomer.address');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'sellToCustomer', '', -1, 'postCode', 'body/sellToCustomer.postCode');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'sellToCustomer', '', -1, 'city', 'body/sellToCustomer.city');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'sellToCustomer', '', -1, 'countryCode', 'body/sellToCustomer.countryCode');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'sellToCustomer', '', -1, 'email', 'body/sellToCustomer.email');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'shipToCustomer', '', -1, 'name', 'body/shipToCustomer.name');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'shipToCustomer', '', -1, 'address', 'body/shipToCustomer.address');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'shipToCustomer', '', -1, 'postCode', 'body/shipToCustomer.postCode');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'shipToCustomer', '', -1, 'city', 'body/shipToCustomer.city');
        AssertRequiredRemoved(PaymentCode, ItemNo, 'shipment', '', -1, 'shipmentMethod', 'body/shipment.shipmentMethod');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', '', -1, 'salesDocumentLines', 'body/salesDocumentLines');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 0, 'type', 'body.salesDocumentLines[0]/type');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 0, 'unitPrice', 'body.salesDocumentLines[0]/unitPrice');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 0, 'quantity', 'body.salesDocumentLines[0]/quantity');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 0, 'vatPercent', 'body.salesDocumentLines[0]/vatPercent');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 0, 'lineAmount', 'body.salesDocumentLines[0]/lineAmount');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 1, 'description', 'body.salesDocumentLines[1]/description');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 2, 'description', 'body.salesDocumentLines[2]/description');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 2, 'unitPrice', 'body.salesDocumentLines[2]/unitPrice');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 2, 'quantity', 'body.salesDocumentLines[2]/quantity');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 2, 'vatPercent', 'body.salesDocumentLines[2]/vatPercent');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'salesDocumentLines', 2, 'lineAmount', 'body.salesDocumentLines[2]/lineAmount');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', '', -1, 'payments', 'body/payments');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'payments', 0, 'paymentMethodType', 'body.payments[0]/paymentMethodType');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'payments', 0, 'paymentAmount', 'body.payments[0]/paymentAmount');
        AssertRequiredRemoved(PaymentCode, ItemNo, '', 'payments', 0, 'externalPaymentMethodCode', 'body.payments[0]/externalPaymentMethodCode');
        AssertEmptyCommentRefused(PaymentCode, ItemNo);
    end;

    [Test]
    procedure GivenRefusedValueOrExistingExternalNo_WhenCreateV1_ThenAnswersThePinned400AndStoresNothingNew()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Body: JsonObject;
        Line: JsonObject;
        Lines: JsonArray;
        EmptyObject: JsonObject;
        Response: JsonObject;
        PaymentCode: Code[50];
        ItemNo: Code[20];
        ExternalNo: Code[20];
        LongExternalNo: Text;
        UnknownPaymentCode: Text;
        Email: Text;
        FirstId: Guid;
    begin
        // [Scenario] V1 refuses values it does not accept and an External No. that already exists. It stores nothing new
        //            and keeps the first document.

        // [Given] A retry budget of 1, a payment mapping and a body with every value V1 reads
        Initialize(1);
        PaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        ItemNo := MissingItemNo();

        // [When] Each refused value is sent in turn, dated 2025-10-18
        // [Then] Each answers 400 generic_error with its text and stores nothing
        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        Body.Replace('documentType', 'invoice');
        AssertCreateRefused(Body, ExternalNo, Email, 'body/documentType has unsupported value: invoice.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        Body.Replace('documentType', 'Order');
        AssertCreateRefused(Body, ExternalNo, Email, 'body/documentType has unsupported value: Order.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        Line.Add('type', 'voucher');
        Line.Add('description', 'V1 voucher line');
        Line.Add('quantity', DecimalOf(1));
        Line.Add('unitPrice', DecimalOf(50));
        Line.Add('vatPercent', DecimalOf(0));
        Line.Add('lineAmount', DecimalOf(50));
        Lines.Add(Line);
        Body.Replace('salesDocumentLines', Lines);
        AssertCreateRefused(Body, ExternalNo, Email, 'Property body.salesDocumentLines[0]/type has incorrect value: voucher.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        ElementAt(ArrayAt(Body, 'salesDocumentLines'), 0).Replace('type', 'Item');
        AssertCreateRefused(Body, ExternalNo, Email, 'Property body.salesDocumentLines[0]/type has incorrect value: Item.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        ElementAt(ArrayAt(Body, 'salesDocumentLines'), 0).Remove('no');
        ElementAt(ArrayAt(Body, 'salesDocumentLines'), 0).Remove('barcodeNo');
        AssertCreateRefused(Body, ExternalNo, Email, 'Property body.salesDocumentLines[0]/no has incorrect value: .');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        ElementAt(ArrayAt(Body, 'payments'), 0).Replace('paymentMethodType', 'voucher');
        AssertCreateRefused(Body, ExternalNo, Email, 'Property body.payments[0]/paymentMethodType has incorrect value: voucher.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        UnknownPaymentCode := 'V1NOPAY' + HexText(12);
        ElementAt(ArrayAt(Body, 'payments'), 0).Replace('externalPaymentMethodCode', UnknownPaymentCode);
        AssertCreateRefused(Body, ExternalNo, Email, 'External payment method type: visa, external payment method code: ' + UnknownPaymentCode + ' is not set up for payment.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        ObjectAt(Body, 'sellToCustomer').Replace('name', PadStr('', 151, 'N'));
        AssertCreateRefused(Body, ExternalNo, Email, 'The value of property: sellToCustomer.name is too long. Maximum length: 150. Current length: 151.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        LongExternalNo := 'V1LONGEXT' + HexText(12);
        Body.Replace('externalNo', LongExternalNo);
        AssertCreateRefused(Body, LongExternalNo, Email, 'The value: ' + LongExternalNo + ' of property: externalNo is too long. Maximum length: 20. Current length: 21.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        Body.Replace('salesDocumentLines', EmptyObject.Clone().AsObject());
        AssertCreateRefused(Body, ExternalNo, Email, 'The salesLines property is not an array.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        Body.Replace('payments', EmptyObject.Clone().AsObject());
        AssertCreateRefused(Body, ExternalNo, Email, 'The payments property is not an array.');

        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        Body.Replace('comments', EmptyObject.Clone().AsObject());
        AssertCreateRefused(Body, ExternalNo, Email, 'The comments property is not an array.');

        // [Given] A V1 body created dated 2025-10-18
        ExternalNo := _LibEcom.NextExternalNo('V1C06D');
        Body := MinimalV1Body(ExternalNo, ItemNo, NewEmail('c06d'));
        Response := PostDocument(Body, '2025-10-18', true);
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'first create');
        FirstId := EcomSalesHeader.SystemId;

        // [When] The same body is created again with an empty x-api-version
        Response := PostDocument(Body, '', true);

        // [Then] The answer is 400 with the duplicate text and only the first document remains
        AssertErrorAnswer(Response, 400, 'generic_error', 'Sales document with type Order and no ' + ExternalNo + ' already exists.', 'duplicate');
        SingleHeader(ExternalNo, EcomSalesHeader);
        _Assert.AreEqual(FirstId, EcomSalesHeader.SystemId, 'The first document must remain.');
    end;

    [Test]
    procedure GivenValuesV2Refuses_WhenCreateV1_ThenEachIsStoredAsSent()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Body: JsonObject;
        SellTo: JsonObject;
        Response: JsonObject;
        ExternalNo: Code[20];
        LongItemNo: Text;
        Hex: Text;
    begin
        // [Scenario] V1 stores values V2 refuses: an e-mail that is not an address, a free-text phone, a negative exchange
        //            rate and an item number longer than V2's 20 characters.

        // [Given] A retry budget of 1 and a V1 body with those values
        Initialize(1);
        ExternalNo := _LibEcom.NextExternalNo('V1C07');
        Hex := HexText(32);
        LongItemNo := 'V1LONGITEM' + HexText(15);
        Body := MinimalV1Body(ExternalNo, '', '');
        SellTo := ObjectAt(Body, 'sellToCustomer');
        SellTo.Replace('email', ' Not.An.Email.' + Hex + ' ');
        SellTo.Add('phone', 'phone: ask reception');
        Body.Add('currencyCode', 'EUR');
        Body.Add('currencyExchangeRate', DecimalOf(-7.5));
        ElementAt(ArrayAt(Body, 'salesDocumentLines'), 0).Replace('no', LongItemNo);

        // [When] The body is created dated 2025-10-18
        Response := PostDocument(Body, '2025-10-18', true);

        // [Then] The answer is 200 with normalized e-mail and the other values unchanged
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, '2025-10-18');
        _Assert.AreEqual(LowerCase('not.an.email.' + Hex), EcomSalesHeader."Sell-to Email", 'V1 must store an e-mail that is not an address, trimmed and lower case.');
        _Assert.AreEqual('phone: ask reception', EcomSalesHeader."Sell-to Phone No.", 'V1 must store a free-text phone.');
        _Assert.AreEqual(DecimalOf(-7.5), EcomSalesHeader."Currency Exchange Rate", 'V1 must store a negative exchange rate.');
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        _Assert.AreEqual(LongItemNo, EcomSalesLine."No.", 'V1 must store a 25-character item number.');
    end;

    [Test]
    procedure GivenReturnOrderOrNoCurrency_WhenCreateV1_ThenNoRateAndNoInvoiceEmailIsStored()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Body: JsonObject;
        Response: JsonObject;
        ExternalNo: Code[20];
    begin
        // [Scenario] V1 reads the exchange rate only for an order with a currency code, and the invoice e-mail only for an order.

        // [Given] A retry budget of 1, a return order with a currency, a rate and an invoice e-mail
        Initialize(1);
        ExternalNo := _LibEcom.NextExternalNo('V1C08R');
        Body := MinimalV1Body(ExternalNo, MissingItemNo(), NewEmail('c08r'));
        Body.Replace('documentType', 'returnOrder');
        Body.Add('currencyCode', 'EUR');
        Body.Add('currencyExchangeRate', DecimalOf(7.46));
        ObjectAt(Body, 'sellToCustomer').Add('invoiceEmail', 'v1.return.invoice@versioning.test');

        // [When] The return order is created dated 2025-10-18
        Response := PostDocument(Body, '2025-10-18', true);

        // [Then] It stores the currency, no rate and no invoice e-mail
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'return order');
        _Assert.AreEqual(EcomSalesHeader."Document Type"::"Return Order", EcomSalesHeader."Document Type", 'The header must be a return order.');
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        _Assert.AreEqual(EcomSalesLine."Document Type"::"Return Order", EcomSalesLine."Document Type", 'The line must be a return order line.');
        _Assert.AreEqual('EUR', EcomSalesHeader."Currency Code", 'The return order must store the currency.');
        _Assert.AreEqual(DecimalOf(0), EcomSalesHeader."Currency Exchange Rate", 'A return order must store no exchange rate.');
        _Assert.AreEqual('', EcomSalesHeader."Sell-to Invoice Email", 'A return order must store no invoice e-mail.');

        // [Given] An order with a rate and no currency
        ExternalNo := _LibEcom.NextExternalNo('V1C08O');
        Body := MinimalV1Body(ExternalNo, MissingItemNo(), NewEmail('c08o'));
        Body.Add('currencyExchangeRate', DecimalOf(7.46));

        // [When] The order is created dated 2025-10-18
        Response := PostDocument(Body, '2025-10-18', true);

        // [Then] It stores no currency and no rate
        AssertCreatedWithId(Response, ExternalNo, 'id', EcomSalesHeader, 'order without currency');
        _Assert.AreEqual('', EcomSalesHeader."Currency Code", 'The order must store no currency.');
        _Assert.AreEqual(DecimalOf(0), EcomSalesHeader."Currency Exchange Rate", 'An order without a currency must store no exchange rate.');
    end;

    [Test]
    procedure GivenRecorderBound_WhenCreateV1_ThenItsEventsAreRaisedInOrder()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Subscriber: Codeunit "NPR Ecom Doc V1 Subscriber";
        Response: JsonObject;
        Body: JsonObject;
        ExternalNo: Code[20];
    begin
        // [Scenario] V1 create raises its create events record by record in request order, tries the conversion once, and
        //            raises the create-response event on the builder it answers with.

        // [Given] A retry budget of 1, a body with three lines, two payments and a comment, and the recorder bound
        Initialize(1);
        ExternalNo := _LibEcom.NextExternalNo('V1C09');
        Body := FullV1Body(ExternalNo, MissingItemNo(), _LibEcom.CreateGatewayCapturedPaymentMapping(), NewEmail('c09'));
        BindSubscription(Subscriber);

        // [When] The body is created dated 2025-10-18
        Response := PostDocument(Body, '2025-10-18', true);
        UnbindSubscription(Subscriber);

        // [Then] The answer carries the probe and the events came in request order
        AssertCreatedWithId(Response, ExternalNo, 'id,v1CreateProbe', EcomSalesHeader, '2025-10-18');
        _Assert.AreEqual('true', RawValueAt(BodyOf(Response), 'v1CreateProbe'), 'The probe must be JSON true.');
        _Assert.AreEqual('DH,IH,DL:10000,IL:10000,DL:20000,IL:20000,DL:30000,IL:30000,DP:10000,IP:10000,DP:20000,IP:20000,C,SE:true,HR:false:true,R', Subscriber.Sequence(), 'V1 create must raise its events in this order.');
    end;

    [Test]
    procedure GivenExistingCustomerAndItem_WhenCreateV1_ThenTheSalesOrderIsCreatedDuringTheRequest()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Subscriber: Codeunit "NPR Ecom Doc V1 Subscriber";
        Response: JsonObject;
        Body: JsonObject;
        ExternalNo: Code[20];
        CustomerNo: Code[20];
        ItemNo: Code[20];
        TodayBefore: Date;
        TodayAfter: Date;
    begin
        // [Scenario] A V1 create for an existing customer and item converts during the request. The sales order and its line
        //            exist when the answer arrives, and the document is Created after one attempt.

        // [Given] A retry budget of 1, the recorder bound, a customer without a contact, an item and a body for both
        Initialize(1);
        Subscriber.SetSkipCustomerContact(true);
        BindSubscription(Subscriber);
        CustomerNo := _LibEcom.CreateCustomer();
        ItemNo := _LibEcom.CreateItem();
        ExternalNo := _LibEcom.NextExternalNo('V1C10');
        Body := MinimalV1Body(ExternalNo, ItemNo, NewEmail('c10'));
        ObjectAt(Body, 'sellToCustomer').Add('no', CustomerNo);

        // [When] The body is created dated 2025-10-18
        TodayBefore := Today();
        Response := PostDocument(Body, '2025-10-18', true);
        TodayAfter := Today();
        UnbindSubscription(Subscriber);

        // [Then] The answer carries the stored id and the probe
        AssertCreatedWithId(Response, ExternalNo, 'id,v1CreateProbe', EcomSalesHeader, '2025-10-18');

        // [Then] The document is Created after one attempt and names the sales order
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Created, EcomSalesHeader."Creation Status", 'The conversion must succeed.');
        _Assert.AreEqual(1, EcomSalesHeader."Process Retry Count", 'One attempt must be counted.');
        _Assert.AreEqual('', EcomSalesHeader."Last Error Message", 'A successful conversion must leave no error.');
        _Assert.AreEqual(20250713D, EcomSalesHeader."API Version Date", 'V1 must store the V1 processing date.');
        _Assert.AreEqual(20251018D, EcomSalesHeader."Requested API Version Date", 'The requested date must be stored as sent.');
        AssertWithinToday(EcomSalesHeader."Created Date", TodayBefore, TodayAfter, 'Created Date');

        // [Then] The sales order exists for the customer with one line for the item
        _Assert.AreEqual(1, _LibEcom.CountSalesDocumentsFor(EcomSalesHeader), 'Exactly one sales document must exist.');
        SalesOrderOf(EcomSalesHeader, SalesHeader);
        _Assert.AreEqual(SalesHeader."No.", EcomSalesHeader."Created Doc No.", 'Created Doc No. must name the sales order.');
        _Assert.AreEqual(CustomerNo, SalesHeader."Sell-to Customer No.", 'The sales order must be for the existing customer.');
        _Assert.AreEqual(ExternalNo, SalesHeader."NPR External Order No.", 'The sales order must carry the External No.');
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        _Assert.AreEqual(1, SalesLine.Count(), 'The sales order must hold exactly one line.');
        SalesLine.FindFirst();
        _Assert.AreEqual(SalesLine.Type::Item, SalesLine.Type, 'The sales line must be an item line.');
        _Assert.AreEqual(ItemNo, SalesLine."No.", 'The sales line must hold the item.');
        _Assert.AreEqual(DecimalOf(1), SalesLine.Quantity, 'The sales line quantity');
        _Assert.AreEqual(DecimalOf(100), SalesLine."Unit Price", 'The sales line unit price');
        _Assert.AreEqual(DecimalOf(100), SalesLine."Line Amount", 'The sales line amount');
        _Assert.AreEqual(EcomSalesLine.SystemId, SalesLine."NPR Inc Ecom Sales Line Id", 'The sales line must point at the ecommerce line.');

        // [Then] The success events were raised
        _Assert.AreEqual('DH,IH,DL:10000,IL:10000,SC,HR:true:true,R', Subscriber.Sequence(), 'A successful V1 create must raise its events in this order.');
    end;

    [Test]
    procedure GivenFullDocument_WhenGetByIdUnderEachV1Header_ThenEveryKeyAndValueIsPinned()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        // [Scenario] Get by id under every header value that evaluates to a date before 2025-10-19 or to 0D answers the V1
        //            document: the key order of every object and every value, numbers as JSON numbers, the notes of every
        //            company in Link ID order without the Link record, and fee links only where a line points at the payment.

        // [Given] The API permission and a document with every V1 value, two own notes, a Link record and a foreign note
        GrantApiPermission();
        InsertFullDocument(EcomSalesHeader);

        // [When] The document is read under each V1-era header value
        // [Then] Each answer is the pinned V1 document
        AssertFullDocumentPinned(EcomSalesHeader, '2025-10-18');
        AssertFullDocumentPinned(EcomSalesHeader, '');
        AssertFullDocumentPinned(EcomSalesHeader, ' ');
        AssertFullDocumentPinned(EcomSalesHeader, TabValue());
        AssertFullDocumentPinned(EcomSalesHeader, '0001-01-01');
        AssertFullDocumentPinned(EcomSalesHeader, '2025-10-10');
        AssertFullDocumentPinned(EcomSalesHeader, '2025-07-13');
        AssertFullDocumentPinned(EcomSalesHeader, '2024-10-11');
    end;

    [Test]
    procedure GivenHeaderOnlyDocuments_WhenGetByIdAcrossTheV1Boundary_ThenV1MapsEveryValueOnlyBeforeV2()
    var
        E1: Record "NPR Ecom Sales Header";
        E2: Record "NPR Ecom Sales Header";
        E3: Record "NPR Ecom Sales Header";
        Headers: Dictionary of [Text, Text];
    begin
        // [Scenario] V1 maps every creation status, posting status and document type, and leaves comments, payments and
        //            salesDocumentLines out of a document without them. From 2025-10-19 on, without the header, or with the
        //            header name in another case, V1 does not answer.

        // [Given] The API permission and three header-only documents
        GrantApiPermission();
        InsertHeaderOnlyDocument(E1, E1."Document Type"::Order, E1."Creation Status"::Pending, E1."Posting Status"::Pending);
        InsertHeaderOnlyDocument(E2, E2."Document Type"::"Return Order", E2."Creation Status"::Created, E2."Posting Status"::Invoiced);
        InsertHeaderOnlyDocument(E3, E3."Document Type"::Order, E3."Creation Status"::Error, E3."Posting Status"::Pending);

        // [When] E1 is read dated 2025-10-18 and with an empty header, E2 and E3 dated 2025-10-18
        // [Then] V1 answers each with the mapped texts and the root keys stop at shipment
        AssertHeaderOnlyPinned(E1, '2025-10-18', 'order', 'pending', 'pending');
        AssertHeaderOnlyPinned(E1, '', 'order', 'pending', 'pending');
        AssertHeaderOnlyPinned(E2, '2025-10-18', 'returnOrder', 'created', 'invoiced');
        AssertHeaderOnlyPinned(E3, '2025-10-18', 'order', 'error', 'pending');

        // [When] E1 is read dated 2025-10-19, 2026-10-28, 2026-10-29, 9999-12-31, without the header and with X-Api-Version
        // [Then] V1 does not answer any of them
        AssertNotV1(GetById(E1.SystemId, '2025-10-19', true), '2025-10-19');
        AssertNotV1(GetById(E1.SystemId, '2026-10-28', true), '2026-10-28');
        AssertNotV1(GetById(E1.SystemId, '2026-10-29', true), '2026-10-29');
        AssertNotV1(GetById(E1.SystemId, '9999-12-31', true), '9999-12-31');
        AssertNotV1(GetById(E1.SystemId, '', false), 'no header');
        Headers.Add(_MixedCaseHeaderLbl, '2025-10-18');
        AssertNotV1(GetByIdWithHeaders(E1.SystemId, Headers), 'X-Api-Version');
    end;

    [Test]
    procedure GivenMalformedHeaderOrId_WhenGetById_ThenThePinnedErrorsAnswer()
    var
        E1: Record "NPR Ecom Sales Header";
        Response: JsonObject;
        Body: JsonObject;
    begin
        // [Scenario] A get by id whose header is not a date answers 400. Under V1 a malformed id answers 400 and an unknown
        //            id 404.

        // [Given] The API permission and a header-only document
        GrantApiPermission();
        InsertHeaderOnlyDocument(E1, E1."Document Type"::Order, E1."Creation Status"::Pending, E1."Posting Status"::Pending);

        // [When] The document is read with x-api-version not-a-date
        Response := GetById(E1.SystemId, 'not-a-date', true);

        // [Then] The answer is 400 generic_error
        _Assert.AreEqual(400, StatusOf(Response), 'A get by id whose header is not a date must answer HTTP 400.');
        Body := BodyOf(Response);
        _Assert.AreEqual('code,message', KeysOf(Body), 'The error answer must carry code and message.');
        _Assert.AreEqual('generic_error', TextAt(Body, 'code'), 'The error code must be generic_error.');

        // [When] A malformed id and an unknown id are read dated 2025-10-18 and with an empty header
        // [Then] The malformed id answers 400 and the unknown id 404, with the pinned texts
        AssertErrorAnswer(GetByIdText('not-a-guid', '2025-10-18'), 400, 'generic_error', 'Malformed parameter: documentId', '2025-10-18');
        AssertErrorAnswer(GetByIdText('not-a-guid', ''), 400, 'generic_error', 'Malformed parameter: documentId', '');
        AssertErrorAnswer(GetById(CreateGuid(), '2025-10-18', true), 404, 'resource_not_found', 'The selected resource does not exist.', '2025-10-18');
        AssertErrorAnswer(GetById(CreateGuid(), '', true), 404, 'resource_not_found', 'The selected resource does not exist.', '');
    end;

    [Test]
    procedure GivenVoucherLineOrUnsupportedPayment_WhenGetByIdV1_ThenAnswersThePinned400()
    var
        LineVoucher: Record "NPR Ecom Sales Header";
        PayVoucher: Record "NPR Ecom Sales Header";
        PayBlank: Record "NPR Ecom Sales Header";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        // [Scenario] V1 renders only item, comment and shipment fee lines and only gateway payments. A document with a voucher
        //            line, a voucher payment or a blank payment type answers 400 under V1, and the documents V2 can render
        //            answer 200 under V2.

        // [Given] The API permission, a document with a voucher line, one with a voucher payment and one with a blank payment type
        GrantApiPermission();
        InsertLineVoucherDocument(LineVoucher);
        InsertPaymentOnlyDocument(PayVoucher, EcomSalesPmtLine."Payment Method Type"::Voucher);
        InsertPaymentOnlyDocument(PayBlank, EcomSalesPmtLine."Payment Method Type"::" ");

        // [When] Each is read under V1, and the first two dated 2025-10-19
        // [Then] V1 answers the pinned 400s and V2 answers 200
        AssertErrorAnswer(GetById(LineVoucher.SystemId, '2025-10-18', true), 400, 'generic_error', 'Sales line type  is not supported.', '2025-10-18');
        AssertErrorAnswer(GetById(LineVoucher.SystemId, '', true), 400, 'generic_error', 'Sales line type  is not supported.', '');
        _Assert.AreEqual(200, StatusOf(GetById(LineVoucher.SystemId, '2025-10-19', true)), At('V2 must render a voucher line.', '2025-10-19'));
        AssertErrorAnswer(GetById(PayVoucher.SystemId, '2025-10-18', true), 400, 'generic_error', 'Payment Method Type: Voucher is not supported.', '2025-10-18');
        _Assert.AreEqual(200, StatusOf(GetById(PayVoucher.SystemId, '2025-10-19', true)), At('V2 must render a voucher payment.', '2025-10-19'));
        AssertErrorAnswer(GetById(PayBlank.SystemId, '2025-10-18', true), 400, 'generic_error', 'Payment Method Type:   is not supported.', '2025-10-18');
    end;

    [Test]
    procedure GivenDocumentCreatedByV2_WhenGetByIdUnderAnOldDate_ThenV1RendersIt()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        Response: JsonObject;
        Body: JsonObject;
        Payment: JsonObject;
        Line: JsonObject;
        PaymentCode: Code[50];
        ItemNo: Code[20];
    begin
        // [Scenario] V1 can read a document created through V2.

        // [Given] A document stored by the V2 create with one item line and one card payment
        Initialize(1);
        InsertV2Document(EcomSalesHeader, ItemNo, PaymentCode);

        // [When] The document is read dated 2025-10-10
        Response := GetById(EcomSalesHeader.SystemId, '2025-10-10', true);

        // [Then] V1 renders it with its own keys and the sent values
        _Assert.AreEqual(200, StatusOf(Response), At('V1 must render a V2-created document.', '2025-10-10'));
        Body := BodyOf(Response);
        AssertNoEmptyCustomFields(Body, '2025-10-10');
        _Assert.AreEqual(_V1RootKeysLbl.Replace(',comments,', ','), KeysOf(Body), 'Root keys');
        _Assert.AreEqual('', TextAt(ObjectAt(Body, 'sellToCustomer'), 'type'), 'A V2-created document has no customer type.');
        Payment := SingleElementAt(Body, 'payments', '2025-10-10');
        _Assert.AreEqual(_V1PaymentKeysLbl, KeysOf(Payment), 'Payment keys');
        _Assert.AreEqual('paymentGateway', TextAt(Payment, 'paymentMethodType'), 'paymentMethodType');
        _Assert.AreEqual(PaymentCode, TextAt(Payment, 'externalPaymentMethodCode'), 'externalPaymentMethodCode');
        _Assert.AreEqual('V1-V2-PSP-REF', TextAt(Payment, 'paymentReference'), 'paymentReference');
        _Assert.AreEqual('100', TextAt(Payment, 'paymentAmount'), 'paymentAmount');
        _Assert.AreEqual('V1-V2-PSP-TOKEN', TextAt(Payment, 'pspToken'), 'pspToken');
        _Assert.AreEqual('03/2030', TextAt(Payment, 'cardExpiryDate'), 'cardExpiryDate');
        _Assert.AreEqual('visa', TextAt(Payment, 'cardBrand'), 'cardBrand');
        _Assert.AreEqual('411111******1111', TextAt(Payment, 'maskedCardNumber'), 'maskedCardNumber');
        _Assert.AreEqual('V1-V2-PAR', TextAt(Payment, 'parToken'), 'parToken');
        _Assert.AreEqual('V1-V2-ALIAS', TextAt(Payment, 'cardAliasToken'), 'cardAliasToken');
        Line := SingleElementAt(Body, 'salesDocumentLines', '2025-10-10');
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        _Assert.AreEqual(_V1LineKeysLbl, KeysOf(Line), 'Line keys');
        _Assert.AreEqual(IdText(EcomSalesLine.SystemId), TextAt(Line, 'id'), 'Line id');
        _Assert.AreEqual('item', TextAt(Line, 'type'), 'Line type');
        _Assert.AreEqual(ItemNo, TextAt(Line, 'no'), 'Line no');
        _Assert.AreEqual('V1 item via V2', TextAt(Line, 'description'), 'Line description');
        _Assert.AreEqual('100', TextAt(Line, 'unitPrice'), 'Line unitPrice');
        _Assert.AreEqual('1', TextAt(Line, 'quantity'), 'Line quantity');
        _Assert.AreEqual('100', TextAt(Line, 'lineAmount'), 'Line lineAmount');
    end;

    [Test]
    procedure GivenRecorderAndWriter_WhenGetByIdV1_ThenEventsAreRaisedInOrderAndAdditionsLandWhereRaised()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        Recorder: Codeunit "NPR Ecom Doc V1 Subscriber";
        Writer: Codeunit "NPR Ecom Doc V1 Subscriber";
        Body: JsonObject;
        Lines: JsonArray;
        EntryText: Text;
        i: Integer;
    begin
        // [Scenario] V1 read events fire in order and place subscriber additions at the header, line and root boundaries.

        // [Given] The API permission, the full document and the recorder bound
        GrantApiPermission();
        InsertFullDocument(EcomSalesHeader);
        BindSubscription(Recorder);

        // [When] The document is read dated 2025-10-18
        _Assert.AreEqual(200, StatusOf(GetById(EcomSalesHeader.SystemId, '2025-10-18', true)), 'Recorded read');
        UnbindSubscription(Recorder);

        // [Then] The events came once for the header, once per line in line order and once at the end
        EntryText := Format(EcomSalesHeader."Entry No.", 0, 9);
        _Assert.AreEqual('GH:' + EntryText + ',GL:' + LineIdText(EcomSalesHeader, 10000) + ',GL:' + LineIdText(EcomSalesHeader, 20000) + ',GL:' + LineIdText(EcomSalesHeader, 30000) + ',GE:' + EntryText, Recorder.Sequence(), 'V1 get by id must raise its events in this order.');

        // [Given] The document read with nothing bound carries the pinned keys
        Body := GetByIdBody(EcomSalesHeader.SystemId, '2025-10-18');
        if not HasPinnedV1Keys(Body) then
            exit;

        // [When] The writer is bound and the document is read
        Writer.SetWriteMode(true);
        BindSubscription(Writer);
        Body := GetByIdBody(EcomSalesHeader.SystemId, '2025-10-18');
        UnbindSubscription(Writer);

        // [Then] Each addition lands where its event is raised
        _Assert.AreEqual('externalNo,id,documentType,creationStatus,postingStatus,currencyCode,currencyExchangeRate,externalDocumentNo,yourReference,locationCode,pricesExcludingVat,sellToCustomer,shipToCustomer,shipment,v1AfterHeader,comments,payments,salesDocumentLines,v1BeforeEnd', KeysOf(Body), 'Root keys with the writer bound');
        Lines := ArrayAt(Body, 'salesDocumentLines');
        for i := 0 to Lines.Count() - 1 do
            _Assert.AreEqual(_V1LineKeysLbl + ',v1Line', KeysOf(ElementAt(Lines, i)), StrSubstNo('Line %1 keys with the writer bound', i));

        // [Then] A read with nothing bound carries the pinned keys again
        _Assert.IsTrue(HasPinnedV1Keys(GetByIdBody(EcomSalesHeader.SystemId, '2025-10-18')), 'The writer must leave nothing behind.');
    end;

    [Test]
    procedure GivenDocument_WhenFindUnderV1EraHeaders_ThenThePinnedV2FindAnswers()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SummaryReference: JsonObject;
        DetailedReference: JsonObject;
        Hit: JsonObject;
        Lines: JsonArray;
        Versions: List of [Text];
        ApiVersion: Text;
        i: Integer;
    begin
        // [Scenario] Find has no V1. A caller that sends a V1-era or empty header gets the V2 find, with its key lists, the
        //            fixture's values, and the same answer as a caller dated 2025-10-19.

        // [Given] The API permission and the full document
        GrantApiPermission();
        InsertFullDocument(EcomSalesHeader);

        // [When] The document is found by e-mail, summary and detailed, dated 2025-10-19
        SummaryReference := FindBody(EcomSalesHeader."Sell-to Email", false, '2025-10-19');
        DetailedReference := FindBody(EcomSalesHeader."Sell-to Email", true, '2025-10-19');

        // [Then] Both answers carry the V2 find keys and the fixture's values
        Hit := AssertSingleHitEnvelope(SummaryReference, 'summary');
        _Assert.AreEqual(_V2SummaryKeysLbl, KeysOf(Hit), 'Summary hit keys');
        _Assert.AreEqual(_V2SummarySellToKeysLbl, KeysOf(ObjectAt(Hit, 'sellToCustomer')), 'Summary sellToCustomer keys');
        _Assert.AreEqual(NormalizedText(ExpectedFindSummaryHit(EcomSalesHeader)), NormalizedText(WithoutCreatedAt(Hit)), 'The summary hit must hold the fixture values.');

        Hit := AssertSingleHitEnvelope(DetailedReference, 'detailed');
        _Assert.AreEqual(_V2DetailedKeysLbl, KeysOf(Hit), 'Detailed hit keys');
        _Assert.AreEqual(_V2DetailedSellToKeysLbl, KeysOf(ObjectAt(Hit, 'sellToCustomer')), 'Detailed sellToCustomer keys');
        _Assert.AreEqual(_ShipToKeysLbl, KeysOf(ObjectAt(Hit, 'shipToCustomer')), 'Detailed shipToCustomer keys');
        _Assert.AreEqual(_ShipmentKeysLbl, KeysOf(ObjectAt(Hit, 'shipment')), 'Detailed shipment keys');
        AssertEachKeys(ArrayAt(Hit, 'comments'), _CommentKeysLbl, 'Detailed comment');
        Lines := ArrayAt(Hit, 'salesDocumentLines');
        _Assert.AreEqual(3, Lines.Count(), 'The detailed hit must carry three lines.');
        _Assert.AreEqual(_V2DetailedLineKeysLbl + ',externalLineId', KeysOf(ElementAt(Lines, 0)), 'Detailed line 1 keys');
        _Assert.AreEqual(_V2DetailedLineKeysLbl, KeysOf(ElementAt(Lines, 1)), 'Detailed line 2 keys');
        _Assert.AreEqual(_V2DetailedLineKeysLbl, KeysOf(ElementAt(Lines, 2)), 'Detailed line 3 keys');
        _Assert.AreEqual(NormalizedText(ExpectedFindDetailedHit(EcomSalesHeader)), NormalizedText(WithoutCreatedAt(Hit)), 'The detailed hit must hold the fixture values.');

        // [When] The same finds are sent under each V1-era header value
        // [Then] Each answers the reference text of its mode
        Versions.Add('2025-10-18');
        Versions.Add('2025-07-13');
        Versions.Add('2024-10-11');
        Versions.Add('');
        Versions.Add(' ');
        Versions.Add(TabValue());
        Versions.Add('0001-01-01');
        for i := 1 to Versions.Count() do begin
            ApiVersion := Versions.Get(i);
            _Assert.AreEqual(NormalizedText(WithoutCustomFields(SummaryReference)), NormalizedText(WithoutCustomFields(FindBody(EcomSalesHeader."Sell-to Email", false, ApiVersion))), At('A summary find must answer the 2025-10-19 text.', ApiVersion));
            _Assert.AreEqual(NormalizedText(WithoutCustomFields(DetailedReference)), NormalizedText(WithoutCustomFields(FindBody(EcomSalesHeader."Sell-to Email", true, ApiVersion))), At('A detailed find must answer the 2025-10-19 text.', ApiVersion));
        end;
    end;

    local procedure Initialize(MaxRetryCount: Integer)
    var
        IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup";
    begin
        GrantApiPermission();
        _LibEcom.ResetEcomSetupToDefaults();
        _LibEcom.GetIncEcomSalesDocSetup(IncEcomSalesDocSetup);
        IncEcomSalesDocSetup."Customer Mapping" := IncEcomSalesDocSetup."Customer Mapping"::"E-mail";
        IncEcomSalesDocSetup."Customer Update Mode" := IncEcomSalesDocSetup."Customer Update Mode"::None;
        IncEcomSalesDocSetup."Max Doc Process Retry Count" := MaxRetryCount;
        IncEcomSalesDocSetup.Modify();
    end;

    local procedure GrantApiPermission()
    begin
        _LibAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), CopyStr(_EcomApiPermissionSetLbl, 1, 20));
    end;

    local procedure NewEmail(Tag: Text): Text
    begin
        exit(LowerCase('v1.' + Tag + '.' + HexText(32) + '@versioning.test'));
    end;

    local procedure InvoiceEmailOf(Email: Text): Text
    begin
        exit(LowerCase('invoice.' + CopyStr(Email, 1, StrPos(Email, '@') - 1) + '@example.com'));
    end;

    local procedure HexText(Length: Integer): Text
    begin
        exit(CopyStr(DelChr(Format(CreateGuid()), '=', '{}-') + DelChr(Format(CreateGuid()), '=', '{}-'), 1, Length));
    end;

    local procedure MissingItemNo() ItemNo: Code[20]
    var
        Item: Record Item;
    begin
        ItemNo := CopyStr('V1NOITEM' + HexText(12), 1, MaxStrLen(ItemNo));
        _Assert.IsFalse(Item.Get(ItemNo), 'The missing item must not exist.');
    end;

    local procedure BlockedItemNo(): Code[20]
    var
        Item: Record Item;
    begin
        Item.Get(_LibEcom.CreateItem());
        Item.Blocked := true;
        Item.Modify();
        exit(Item."No.");
    end;

    local procedure TabValue() Value: Text
    var
        Tab: Char;
    begin
        Tab := 9;
        Value := ' ';
        Value[1] := Tab;
    end;

    local procedure DecimalOf(Value: Decimal): Decimal
    begin
        exit(Value);
    end;

    local procedure IdText(Id: Guid): Text
    begin
        exit(LowerCase(Format(Id, 0, 4)));
    end;

    local procedure FullV1Body(ExternalNo: Code[20]; ItemNo: Code[20]; PaymentCode: Code[50]; Email: Text) Body: JsonObject
    var
        SellTo: JsonObject;
        ShipTo: JsonObject;
        Shipment: JsonObject;
        Dimension: JsonObject;
        Dimensions: JsonArray;
        Line: JsonObject;
        Lines: JsonArray;
        Payment: JsonObject;
        Payments: JsonArray;
        Comment: JsonObject;
        Comments: JsonArray;
    begin
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        Body.Add('currencyCode', 'EUR');
        Body.Add('currencyExchangeRate', DecimalOf(7.46));
        Body.Add('externalDocumentNo', _BodyExtDocNoLbl);
        Body.Add('yourReference', _YourReferenceLbl);
        Body.Add('locationCode', _LocationLbl);
        Body.Add('pricesExcludingVat', true);
        Body.Add('languageTag', _LanguageTagLbl);
        Body.Add('ticketReservationToken', _TicketTokenLbl);
        Dimension.Add('code', 'V1DIM');
        Dimension.Add('valueCode', 'V1VAL');
        Dimensions.Add(Dimension);
        Body.Add('dimensions', Dimensions);

        SellTo.Add('no', _BodyCustomerNoLbl);
        SellTo.Add('type', 'person');
        SellTo.Add('name', 'V1 Buyer');
        SellTo.Add('address', 'V1 Street 1');
        SellTo.Add('address2', 'Floor 2');
        SellTo.Add('postCode', '2100');
        SellTo.Add('county', 'Capital');
        SellTo.Add('city', 'Copenhagen');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('contact', 'V1 Contact');
        SellTo.Add('email', ' ' + UpperCase(CopyStr(Email, 1, 3)) + CopyStr(Email, 4) + ' ');
        SellTo.Add('phone', '+45 1234 5678');
        SellTo.Add('ean', '5790000000001');
        SellTo.Add('vatRegistrationNo', 'DK12345678');
        SellTo.Add('invoiceEmail', ' Invoice.' + CopyStr(Email, 1, StrPos(Email, '@') - 1) + '@Example.COM ');
        SellTo.Add('customerTemplate', _CustomerTemplateLbl);
        SellTo.Add('configurationTemplate', _ConfigTemplateLbl);
        Body.Add('sellToCustomer', SellTo);

        ShipTo.Add('name', 'V1 Receiver');
        ShipTo.Add('address', 'Receiver Street 9');
        ShipTo.Add('address2', 'Back entrance');
        ShipTo.Add('postCode', '21100');
        ShipTo.Add('county', 'Skane');
        ShipTo.Add('city', 'Malmo');
        ShipTo.Add('countryCode', 'SE');
        ShipTo.Add('contact', 'Receiver Contact');
        Body.Add('shipToCustomer', ShipTo);

        Shipment.Add('shipmentMethod', 'V1SHIP');
        Shipment.Add('shipmentService', 'EXPRESS');
        Body.Add('shipment', Shipment);

        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('variantCode', 'RED');
        Line.Add('barcodeNo', '5790000000123');
        Line.Add('description', 'V1 item');
        Line.Add('unitPrice', DecimalOf(80));
        Line.Add('quantity', DecimalOf(1.5));
        Line.Add('unitOfMeasure', _UnitOfMeasureLbl);
        Line.Add('vatPercent', DecimalOf(25));
        Line.Add('lineAmount', DecimalOf(120));
        Line.Add('requestedDeliveryDate', '2026-12-24');
        Line.Add('externalLineId', _V2LineIdLbl);
        Lines.Add(Line);
        Clear(Line);
        Line.Add('type', 'comment');
        Line.Add('description', 'Gift wrap please');
        Lines.Add(Line);
        Clear(Line);
        Line.Add('type', 'shipmentFee');
        Line.Add('no', 'V1SHIPFEE');
        Line.Add('description', 'Express shipping');
        Line.Add('unitPrice', DecimalOf(49));
        Line.Add('quantity', DecimalOf(1));
        Line.Add('vatPercent', DecimalOf(25));
        Line.Add('lineAmount', DecimalOf(49));
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);

        Payment.Add('paymentMethodType', 'paymentGateway');
        Payment.Add('externalPaymentMethodCode', PaymentCode);
        Payment.Add('externalPaymentType', 'visa');
        Payment.Add('paymentReference', 'V1-PSP-REF');
        Payment.Add('paymentAmount', DecimalOf(169));
        Payment.Add('pspToken', 'V1-PSP-TOKEN');
        Payment.Add('parToken', 'V1-PAR');
        Payment.Add('cardExpiryDate', '12/26');
        Payment.Add('cardBrand', 'visa');
        Payment.Add('maskedCardNumber', '************1111');
        Payment.Add('cardAliasToken', 'V1-ALIAS');
        Payments.Add(Payment);
        Clear(Payment);
        Payment.Add('paymentMethodType', 'paymentGateway');
        Payment.Add('externalPaymentMethodCode', PaymentCode);
        Payment.Add('paymentReference', 'V1-PSP-REF-2');
        Payment.Add('paymentAmount', DecimalOf(0.5));
        Payments.Add(Payment);
        Body.Add('payments', Payments);

        Comment.Add('comment', _BodyCommentLbl);
        Comments.Add(Comment);
        Body.Add('comments', Comments);
    end;

    local procedure MinimalV1Body(ExternalNo: Code[20]; ItemNo: Code[20]; Email: Text) Body: JsonObject
    var
        SellTo: JsonObject;
        Line: JsonObject;
        Lines: JsonArray;
        Payments: JsonArray;
    begin
        Body.Add('externalNo', ExternalNo);
        Body.Add('documentType', 'order');
        SellTo.Add('type', 'person');
        SellTo.Add('name', 'V1 Minimal Buyer');
        SellTo.Add('address', 'V1 Minimal Street 1');
        SellTo.Add('postCode', '2100');
        SellTo.Add('city', 'Copenhagen');
        SellTo.Add('countryCode', 'DK');
        SellTo.Add('email', Email);
        Body.Add('sellToCustomer', SellTo);
        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('description', 'V1 item');
        Line.Add('unitPrice', DecimalOf(100));
        Line.Add('quantity', DecimalOf(1));
        Line.Add('vatPercent', DecimalOf(0));
        Line.Add('lineAmount', DecimalOf(100));
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);
        Body.Add('payments', Payments);
    end;

    local procedure V2FieldsBody(ExternalNo: Code[20]; ItemNo: Code[20]; Email: Text; WithType: Boolean) Body: JsonObject
    var
        SellTo: JsonObject;
    begin
        Body := MinimalV1Body(ExternalNo, ItemNo, Email);
        SellTo := ObjectAt(Body, 'sellToCustomer');
        if not WithType then
            SellTo.Remove('type');
        SellTo.Add('customerTemplate', _CustomerTemplateLbl);
        ElementAt(ArrayAt(Body, 'salesDocumentLines'), 0).Add('externalLineId', _V2LineIdLbl);
    end;

    local procedure VersionHeaders(ApiVersion: Text; SendHeader: Boolean) Headers: Dictionary of [Text, Text]
    begin
        if SendHeader then
            Headers.Add(_ApiVersionHeaderLbl, ApiVersion);
    end;

    local procedure PostDocument(Body: JsonObject; ApiVersion: Text; SendHeader: Boolean): JsonObject
    begin
        exit(PostWithHeaders(Body, VersionHeaders(ApiVersion, SendHeader)));
    end;

    local procedure PostWithHeaders(Body: JsonObject; Headers: Dictionary of [Text, Text]) Response: JsonObject
    var
        QueryParameters: Dictionary of [Text, Text];
    begin
        Commit();
        Response := _LibAPI.CallApi('POST', _DocumentsPathLbl, Body, QueryParameters, Headers);
    end;

    local procedure GetById(DocumentId: Guid; ApiVersion: Text; SendHeader: Boolean): JsonObject
    begin
        exit(GetByIdWithHeaders(DocumentId, VersionHeaders(ApiVersion, SendHeader)));
    end;

    local procedure GetByIdWithHeaders(DocumentId: Guid; Headers: Dictionary of [Text, Text]) Response: JsonObject
    var
        Body: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        Commit();
        Response := _LibAPI.CallApi('GET', _DocumentsPathLbl + '/' + IdText(DocumentId), Body, QueryParameters, Headers);
    end;

    local procedure GetByIdText(DocumentIdText: Text; ApiVersion: Text) Response: JsonObject
    var
        Body: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        Commit();
        Response := _LibAPI.CallApi('GET', _DocumentsPathLbl + '/' + DocumentIdText, Body, QueryParameters, VersionHeaders(ApiVersion, true));
    end;

    local procedure GetByIdBody(DocumentId: Guid; ApiVersion: Text): JsonObject
    var
        Response: JsonObject;
    begin
        Response := GetById(DocumentId, ApiVersion, true);
        _Assert.AreEqual(200, StatusOf(Response), At('A get by id of an existing document must answer HTTP 200.', ApiVersion));
        exit(BodyOf(Response));
    end;

    local procedure FindBody(Email: Text; WithDetails: Boolean; ApiVersion: Text): JsonObject
    var
        Body: JsonObject;
        Response: JsonObject;
        QueryParameters: Dictionary of [Text, Text];
    begin
        QueryParameters.Add('email', Email);
        if WithDetails then
            QueryParameters.Add('withDetails', 'true');
        Commit();
        Response := _LibAPI.CallApi('GET', _DocumentsPathLbl, Body, QueryParameters, VersionHeaders(ApiVersion, true));
        _Assert.AreEqual(200, StatusOf(Response), At('A find must answer HTTP 200.', ApiVersion));
        exit(BodyOf(Response));
    end;

    local procedure StatusOf(Response: JsonObject): Integer
    var
        Token: JsonToken;
    begin
        if Response.Get('statusCode', Token) then
            exit(Token.AsValue().AsInteger());
    end;

    local procedure BodyOf(Response: JsonObject): JsonObject
    begin
        exit(_LibAPI.GetResponseBody(Response));
    end;

    local procedure KeysOf(Object: JsonObject) KeyList: Text
    var
        KeyName: Text;
    begin
        foreach KeyName in Object.Keys() do
            if KeyName <> _CustomFieldsLbl then begin
                if KeyList <> '' then
                    KeyList += ',';
                KeyList += KeyName;
            end;
    end;

    local procedure WithoutCustomFields(Body: JsonObject): JsonObject
    var
        Stripped: JsonToken;
    begin
        Stripped := Body.Clone();
        RemoveCustomFields(Stripped);
        exit(Stripped.AsObject());
    end;

    local procedure RemoveCustomFields(Token: JsonToken)
    var
        Object: JsonObject;
        Child: JsonToken;
        KeyName: Text;
    begin
        if Token.IsArray() then begin
            foreach Child in Token.AsArray() do
                RemoveCustomFields(Child);
            exit;
        end;
        if not Token.IsObject() then
            exit;
        Object := Token.AsObject();
        if Object.Contains(_CustomFieldsLbl) then
            Object.Remove(_CustomFieldsLbl);
        foreach KeyName in Object.Keys() do begin
            Object.Get(KeyName, Child);
            RemoveCustomFields(Child);
        end;
    end;

    local procedure WithoutCreatedAt(Hit: JsonObject) Stripped: JsonObject
    begin
        _Assert.AreNotEqual('', TextAt(Hit, 'createdAt'), 'A hit must carry a non-empty createdAt.');
        Stripped := WithoutCustomFields(Hit);
        Stripped.Remove('createdAt');
    end;

    local procedure NormalizedText(Object: JsonObject): Text
    var
        ReadBack: JsonObject;
        FirstText: Text;
        SecondText: Text;
    begin
        Object.WriteTo(FirstText);
        ReadBack.ReadFrom(FirstText);
        ReadBack.WriteTo(SecondText);
        exit(SecondText);
    end;

    local procedure TokenAt(Object: JsonObject; KeyName: Text) Token: JsonToken
    begin
        _Assert.IsTrue(Object.Get(KeyName, Token), StrSubstNo('The object must carry %1.', KeyName));
    end;

    local procedure ObjectAt(Object: JsonObject; KeyName: Text): JsonObject
    begin
        exit(TokenAt(Object, KeyName).AsObject());
    end;

    local procedure ArrayAt(Object: JsonObject; KeyName: Text): JsonArray
    begin
        exit(TokenAt(Object, KeyName).AsArray());
    end;

    local procedure ElementAt(Elements: JsonArray; Index: Integer): JsonObject
    var
        Token: JsonToken;
    begin
        Elements.Get(Index, Token);
        exit(Token.AsObject());
    end;

    local procedure TextAt(Object: JsonObject; KeyName: Text): Text
    begin
        exit(TokenAt(Object, KeyName).AsValue().AsText());
    end;

    local procedure RawValueAt(Object: JsonObject; KeyName: Text) ValueText: Text
    begin
        TokenAt(Object, KeyName).WriteTo(ValueText);
    end;

    local procedure SingleElementAt(Object: JsonObject; KeyName: Text; ApiVersion: Text): JsonObject
    var
        Elements: JsonArray;
    begin
        Elements := ArrayAt(Object, KeyName);
        _Assert.AreEqual(1, Elements.Count(), At(KeyName + ' must hold exactly one entry.', ApiVersion));
        exit(ElementAt(Elements, 0));
    end;

    local procedure At(Message: Text; ApiVersion: Text): Text
    begin
        exit(StrSubstNo(_AtVersionLbl, Message, ApiVersion));
    end;

    local procedure SingleHeader(ExternalNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
        EcomSalesHeader.Reset();
        EcomSalesHeader.SetRange("External No.", ExternalNo);
        _Assert.AreEqual(1, EcomSalesHeader.Count(), 'Exactly one document must carry the External No. ' + ExternalNo + '.');
        EcomSalesHeader.FindFirst();
    end;

    local procedure SalesOrderOf(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange("NPR Inc Ecom Sale Id", EcomSalesHeader.SystemId);
        _Assert.AreEqual(1, SalesHeader.Count(), 'Exactly one sales order must point at the document.');
        SalesHeader.FindFirst();
    end;

    local procedure FirstLineExternalId(EcomSalesHeader: Record "NPR Ecom Sales Header"): Text
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.FindFirst();
        exit(EcomSalesLine."External Line ID");
    end;

    local procedure LineIdText(EcomSalesHeader: Record "NPR Ecom Sales Header"; LineNo: Integer): Text
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange("Line No.", LineNo);
        EcomSalesLine.FindFirst();
        exit(IdText(EcomSalesLine.SystemId));
    end;

    local procedure PaymentIdOf(EcomSalesHeader: Record "NPR Ecom Sales Header"; LineNo: Integer): Guid
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesPmtLine.SetRange("Line No.", LineNo);
        EcomSalesPmtLine.FindFirst();
        exit(EcomSalesPmtLine.SystemId);
    end;

    local procedure LineIdOf(EcomSalesHeader: Record "NPR Ecom Sales Header"; LineNo: Integer): Guid
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange("Line No.", LineNo);
        EcomSalesLine.FindFirst();
        exit(EcomSalesLine.SystemId);
    end;

    local procedure LinkSystemIdOf(LinkId: Integer): Guid
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.Get(LinkId);
        exit(RecordLink.SystemId);
    end;

    local procedure AssertErrorAnswer(Response: JsonObject; Status: Integer; ErrorCode: Text; Message: Text; Context: Text)
    var
        Body: JsonObject;
    begin
        _Assert.AreEqual(Status, StatusOf(Response), At('Status code', Context));
        Body := BodyOf(Response);
        _Assert.AreEqual('code,message', KeysOf(Body), At('Error body keys', Context));
        _Assert.AreEqual(ErrorCode, TextAt(Body, 'code'), At('Error code', Context));
        _Assert.AreEqual(Message, TextAt(Body, 'message'), At('Error message', Context));
    end;

    local procedure AssertCreatedWithId(Response: JsonObject; ExternalNo: Code[20]; ExpectedKeys: Text; var EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text)
    var
        Body: JsonObject;
    begin
        _Assert.AreEqual(200, StatusOf(Response), At('The create must answer HTTP 200.', ApiVersion));
        Body := BodyOf(Response);
        AssertNoEmptyCustomFields(Body, At('Create answer', ApiVersion));
        _Assert.AreEqual(ExpectedKeys, KeysOf(Body), At('Create answer keys', ApiVersion));
        SingleHeader(ExternalNo, EcomSalesHeader);
        _Assert.AreEqual(IdText(EcomSalesHeader.SystemId), TextAt(Body, 'id'), At('The id must be the system id of the stored document.', ApiVersion));
    end;

    local procedure AssertNoEmptyCustomFields(Body: JsonObject; Context: Text)
    begin
        CheckCustomFields(Body.AsToken(), Context);
    end;

    local procedure CheckCustomFields(Token: JsonToken; Context: Text)
    var
        Object: JsonObject;
        Child: JsonToken;
        KeyName: Text;
    begin
        if Token.IsArray() then begin
            foreach Child in Token.AsArray() do
                CheckCustomFields(Child, Context);
            exit;
        end;
        if not Token.IsObject() then
            exit;
        Object := Token.AsObject();
        foreach KeyName in Object.Keys() do begin
            Object.Get(KeyName, Child);
            if KeyName = _CustomFieldsLbl then begin
                _Assert.IsTrue(Child.IsObject(), Context + ': customFields must be an object.');
                _Assert.IsTrue(Child.AsObject().Keys().Count() > 0, Context + ': customFields must not be empty.');
            end else
                CheckCustomFields(Child, Context);
        end;
    end;

    local procedure AssertWithinToday(Actual: Date; TodayBefore: Date; TodayAfter: Date; Context: Text)
    begin
        _Assert.IsTrue((Actual = TodayBefore) or (Actual = TodayAfter), Context + ' must be the date of the request.');
    end;

    local procedure AssertNothingStored(ExternalNo: Text; Email: Text; Context: Text)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
    begin
        if Email <> '' then begin
            EcomSalesHeader.SetRange("Sell-to Email", LowerCase(Email));
            _Assert.IsTrue(EcomSalesHeader.IsEmpty(), Context + ': no document may carry the e-mail.');
            EcomSalesHeader.Reset();
        end;
        if (ExternalNo <> '') and (StrLen(ExternalNo) <= MaxStrLen(EcomSalesHeader."External No.")) then begin
            EcomSalesHeader.SetRange("External No.", ExternalNo);
            _Assert.IsTrue(EcomSalesHeader.IsEmpty(), Context + ': no document may carry the External No.');
        end;
    end;

    local procedure AssertServedByV1(EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestedDate: Date; Context: Text)
    begin
        _Assert.AreEqual('person', EcomSalesHeader."Sell-to Customer Type", Context + ': V1 must store sellToCustomer.type.');
        _Assert.AreEqual(RequestedDate, EcomSalesHeader."Requested API Version Date", Context + ': the requested date must be stored as sent.');
        _Assert.AreEqual(20250713D, EcomSalesHeader."API Version Date", Context + ': V1 must store the V1 processing date.');
        _Assert.AreEqual(1, EcomSalesHeader."Process Retry Count", Context + ': V1 must try the conversion once.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Error, EcomSalesHeader."Creation Status", Context + ': the failed attempt must end in Error.');
        _Assert.AreNotEqual('', EcomSalesHeader."Last Error Message", Context + ': the conversion error must be stored.');
        _Assert.AreEqual('', EcomSalesHeader."Customer Template", Context + ': V1 must not store customerTemplate.');
    end;

    local procedure AssertServedByV2(EcomSalesHeader: Record "NPR Ecom Sales Header"; EarliestDate: Date; LatestDate: Date; Context: Text)
    begin
        _Assert.AreEqual('', EcomSalesHeader."Sell-to Customer Type", Context + ': V2 must not store sellToCustomer.type.');
        _Assert.AreEqual(_CustomerTemplateLbl, EcomSalesHeader."Customer Template", Context + ': V2 must store customerTemplate.');
        _Assert.AreEqual(_V2LineIdLbl, FirstLineExternalId(EcomSalesHeader), Context + ': V2 must store externalLineId.');
        _Assert.AreEqual(20251019D, EcomSalesHeader."API Version Date", Context + ': V2 must store the V2 processing date.');
        _Assert.IsTrue((EcomSalesHeader."Requested API Version Date" = EarliestDate) or (EcomSalesHeader."Requested API Version Date" = LatestDate), Context + ': the requested date must be stored as sent.');
        _Assert.AreEqual(0, EcomSalesHeader."Process Retry Count", Context + ': V2 must not try the conversion.');
        _Assert.AreEqual(EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Creation Status", Context + ': V2 must leave the document Pending.');
        _Assert.AreEqual('', EcomSalesHeader."Last Error Message", Context + ': V2 must store no error.');
    end;

    local procedure PostV2Row(Headers: Dictionary of [Text, Text]; ItemNo: Code[20]; EarliestDate: Date; LatestDate: Date; Context: Text)
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('V1C02');
        AssertCreatedWithId(PostWithHeaders(V2FieldsBody(ExternalNo, ItemNo, NewEmail('c02'), true), Headers), ExternalNo, 'id', EcomSalesHeader, Context);
        AssertServedByV2(EcomSalesHeader, EarliestDate, LatestDate, Context);
    end;

    local procedure AssertRequiredRemoved(PaymentCode: Code[50]; ItemNo: Code[20]; ObjectKey: Text; ArrayKey: Text; Index: Integer; KeyName: Text; MissingPath: Text)
    var
        Body: JsonObject;
        ExternalNo: Code[20];
        Email: Text;
    begin
        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        case true of
            ObjectKey <> '':
                ObjectAt(Body, ObjectKey).Remove(KeyName);
            ArrayKey <> '':
                ElementAt(ArrayAt(Body, ArrayKey), Index).Remove(KeyName);
            else
                Body.Remove(KeyName);
        end;
        AssertCreateRefused(Body, ExternalNo, Email, 'Required value missing: ' + MissingPath);
    end;

    local procedure AssertEmptyCommentRefused(PaymentCode: Code[50]; ItemNo: Code[20])
    var
        Body: JsonObject;
        ExternalNo: Code[20];
        Email: Text;
    begin
        NewRefusalCase(PaymentCode, ItemNo, ExternalNo, Email, Body);
        ElementAt(ArrayAt(Body, 'comments'), 0).Replace('comment', '');
        AssertCreateRefused(Body, ExternalNo, Email, 'Required value missing: body.comments[0]/comment');
    end;

    local procedure NewRefusalCase(PaymentCode: Code[50]; ItemNo: Code[20]; var ExternalNo: Code[20]; var Email: Text; var Body: JsonObject)
    begin
        ExternalNo := _LibEcom.NextExternalNo('V1REF');
        Email := NewEmail('refused');
        Clear(Body);
        Body := FullV1Body(ExternalNo, ItemNo, PaymentCode, Email);
    end;

    local procedure AssertCreateRefused(Body: JsonObject; ExternalNo: Text; Email: Text; Message: Text)
    begin
        AssertErrorAnswer(PostDocument(Body, '2025-10-18', true), 400, 'generic_error', Message, Message);
        AssertNothingStored(ExternalNo, Email, Message);
    end;

    local procedure AssertStoredFullHeader(EcomSalesHeader: Record "NPR Ecom Sales Header"; ExternalNo: Code[20]; Email: Text; TodayBefore: Date; TodayAfter: Date)
    begin
        _Assert.AreEqual(ExternalNo, EcomSalesHeader."External No.", 'External No.');
        _Assert.AreEqual(EcomSalesHeader."Document Type"::Order, EcomSalesHeader."Document Type", 'Document Type');
        _Assert.AreEqual('EUR', EcomSalesHeader."Currency Code", 'Currency Code');
        _Assert.AreEqual(DecimalOf(7.46), EcomSalesHeader."Currency Exchange Rate", 'Currency Exchange Rate');
        _Assert.AreEqual(_BodyExtDocNoLbl, EcomSalesHeader."External Document No.", 'External Document No.');
        _Assert.AreEqual(_YourReferenceLbl, EcomSalesHeader."Your Reference", 'Your Reference');
        _Assert.AreEqual(_LocationLbl, EcomSalesHeader."Location Code", 'Location Code');
        _Assert.IsTrue(EcomSalesHeader."Price Excl. VAT", 'Price Excl. VAT');
        _Assert.AreEqual(_BodyCustomerNoLbl, EcomSalesHeader."Sell-to Customer No.", 'Sell-to Customer No.');
        _Assert.AreEqual('person', EcomSalesHeader."Sell-to Customer Type", 'Sell-to Customer Type');
        _Assert.AreEqual('V1 Buyer', EcomSalesHeader."Sell-to Name", 'Sell-to Name');
        _Assert.AreEqual('V1 Street 1', EcomSalesHeader."Sell-to Address", 'Sell-to Address');
        _Assert.AreEqual('Floor 2', EcomSalesHeader."Sell-to Address 2", 'Sell-to Address 2');
        _Assert.AreEqual('2100', EcomSalesHeader."Sell-to Post Code", 'Sell-to Post Code');
        _Assert.AreEqual('Capital', EcomSalesHeader."Sell-to County", 'Sell-to County');
        _Assert.AreEqual('Copenhagen', EcomSalesHeader."Sell-to City", 'Sell-to City');
        _Assert.AreEqual('DK', EcomSalesHeader."Sell-to Country Code", 'Sell-to Country Code');
        _Assert.AreEqual('V1 Contact', EcomSalesHeader."Sell-to Contact", 'Sell-to Contact');
        _Assert.AreEqual(Email, EcomSalesHeader."Sell-to Email", 'Sell-to Email');
        _Assert.AreEqual('+45 1234 5678', EcomSalesHeader."Sell-to Phone No.", 'Sell-to Phone No.');
        _Assert.AreEqual('5790000000001', EcomSalesHeader."Sell-to EAN", 'Sell-to EAN');
        _Assert.AreEqual('DK12345678', EcomSalesHeader."Sell-to VAT Registration No.", 'Sell-to VAT Registration No.');
        _Assert.AreEqual(InvoiceEmailOf(Email), EcomSalesHeader."Sell-to Invoice Email", 'Sell-to Invoice Email');
        _Assert.AreEqual('V1 Receiver', EcomSalesHeader."Ship-to Name", 'Ship-to Name');
        _Assert.AreEqual('Receiver Street 9', EcomSalesHeader."Ship-to Address", 'Ship-to Address');
        _Assert.AreEqual('Back entrance', EcomSalesHeader."Ship-to Address 2", 'Ship-to Address 2');
        _Assert.AreEqual('21100', EcomSalesHeader."Ship-to Post Code", 'Ship-to Post Code');
        _Assert.AreEqual('Skane', EcomSalesHeader."Ship-to County", 'Ship-to County');
        _Assert.AreEqual('Malmo', EcomSalesHeader."Ship-to City", 'Ship-to City');
        _Assert.AreEqual('SE', EcomSalesHeader."Ship-to Country Code", 'Ship-to Country Code');
        _Assert.AreEqual('Receiver Contact', EcomSalesHeader."Ship-to Contact", 'Ship-to Contact');
        _Assert.AreEqual('V1SHIP', EcomSalesHeader."Shipment Method Code", 'Shipment Method Code');
        _Assert.AreEqual('EXPRESS', EcomSalesHeader."Shipment Service", 'Shipment Service');
        AssertWithinToday(EcomSalesHeader."Received Date", TodayBefore, TodayAfter, 'Received Date');
        AssertWithinToday(EcomSalesHeader."Last Error Date", TodayBefore, TodayAfter, 'Last Error Date');
        _Assert.AreEqual(20251018D, EcomSalesHeader."Requested API Version Date", 'Requested API Version Date');
        _Assert.AreEqual(20250713D, EcomSalesHeader."API Version Date", 'API Version Date');
        _Assert.AreEqual('', EcomSalesHeader."Customer Template", 'Customer Template');
        _Assert.AreEqual('', EcomSalesHeader."Configuration Template", 'Configuration Template');
        _Assert.AreEqual('', EcomSalesHeader."Language Tag", 'Language Tag');
        _Assert.AreEqual('', EcomSalesHeader."Ticket Reservation Token", 'Ticket Reservation Token');
        _Assert.AreEqual(0, EcomSalesHeader."Dimension Set ID", 'Dimension Set ID');
    end;

    local procedure AssertStoredFullLines(EcomSalesHeader: Record "NPR Ecom Sales Header"; ExternalNo: Code[20]; ItemNo: Code[20])
    var
        EcomSalesLine: Record "NPR Ecom Sales Line";
    begin
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.AreEqual(3, EcomSalesLine.Count(), 'V1 must store three lines.');
        EcomSalesLine.FindSet();
        AssertStoredLine(EcomSalesLine, ExternalNo, 10000, EcomSalesLine.Type::Item, ItemNo, 'RED', '5790000000123', 'V1 item', 80, 1.5, _UnitOfMeasureLbl, 25, 120, 20261224D);
        EcomSalesLine.Next();
        AssertStoredLine(EcomSalesLine, ExternalNo, 20000, EcomSalesLine.Type::Comment, '', '', '', 'Gift wrap please', 0, 0, '', 0, 0, 0D);
        EcomSalesLine.Next();
        AssertStoredLine(EcomSalesLine, ExternalNo, 30000, EcomSalesLine.Type::"Shipment Fee", 'V1SHIPFEE', '', '', 'Express shipping', 49, 1, '', 25, 49, 0D);
    end;

    local procedure AssertStoredLine(EcomSalesLine: Record "NPR Ecom Sales Line"; ExternalNo: Code[20]; LineNo: Integer; LineType: Enum "NPR Ecom Sales Line Type"; No: Text; VariantCode: Text; BarcodeNo: Text; Description: Text; UnitPrice: Decimal; Quantity: Decimal; UnitOfMeasure: Text; VatPercent: Decimal; LineAmount: Decimal; RequestedDeliveryDate: Date)
    var
        Context: Text;
    begin
        Context := StrSubstNo('Line %1', LineNo);
        _Assert.AreEqual(LineNo, EcomSalesLine."Line No.", Context + ': Line No.');
        _Assert.AreEqual(LineType, EcomSalesLine.Type, Context + ': Type');
        _Assert.AreEqual(No, EcomSalesLine."No.", Context + ': No.');
        _Assert.AreEqual(VariantCode, EcomSalesLine."Variant Code", Context + ': Variant Code');
        _Assert.AreEqual(BarcodeNo, EcomSalesLine."Barcode No.", Context + ': Barcode No.');
        _Assert.AreEqual(Description, EcomSalesLine.Description, Context + ': Description');
        _Assert.AreEqual(UnitPrice, EcomSalesLine."Unit Price", Context + ': Unit Price');
        _Assert.AreEqual(Quantity, EcomSalesLine.Quantity, Context + ': Quantity');
        _Assert.AreEqual(UnitOfMeasure, EcomSalesLine."Unit of Measure Code", Context + ': Unit of Measure Code');
        _Assert.AreEqual(VatPercent, EcomSalesLine."VAT %", Context + ': VAT %');
        _Assert.AreEqual(LineAmount, EcomSalesLine."Line Amount", Context + ': Line Amount');
        _Assert.AreEqual(RequestedDeliveryDate, EcomSalesLine."Requested Delivery Date", Context + ': Requested Delivery Date');
        _Assert.AreEqual('', EcomSalesLine."External Line ID", Context + ': External Line ID');
        _Assert.AreEqual(EcomSalesLine."Document Type"::Order, EcomSalesLine."Document Type", Context + ': Document Type');
        _Assert.AreEqual(ExternalNo, EcomSalesLine."External Document No.", Context + ': External Document No.');
    end;

    local procedure AssertStoredFullPayments(EcomSalesHeader: Record "NPR Ecom Sales Header"; ExternalNo: Code[20]; PaymentCode: Code[50])
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        PaymentMethod: Record "Payment Method";
        Description: Text;
    begin
        PaymentMapping.SetRange("External Payment Method Code", PaymentCode);
        PaymentMapping.FindFirst();
        PaymentMethod.Get(PaymentMapping."Payment Method Code");
        Description := CopyStr(PaymentMethod.Description + ' ' + ExternalNo, 1, MaxStrLen(EcomSalesPmtLine.Description));

        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        _Assert.AreEqual(2, EcomSalesPmtLine.Count(), 'V1 must store two payments.');
        EcomSalesPmtLine.FindSet();
        AssertStoredPayment(EcomSalesPmtLine, 10000, PaymentCode, 'visa', 'V1-PSP-REF', 169, 'V1-PSP-TOKEN', 'V1-PAR', '12/26', 'visa', '************1111', 'V1-ALIAS', Description);
        EcomSalesPmtLine.Next();
        AssertStoredPayment(EcomSalesPmtLine, 20000, PaymentCode, '', 'V1-PSP-REF-2', 0.5, '', '', '', '', '', '', Description);
    end;

    local procedure AssertStoredPayment(EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; LineNo: Integer; PaymentCode: Text; ExternalPaymentType: Text; PaymentReference: Text; Amount: Decimal; PspToken: Text; ParToken: Text; CardExpiryDate: Text; CardBrand: Text; MaskedCardNumber: Text; CardAliasToken: Text; Description: Text)
    var
        Context: Text;
    begin
        Context := StrSubstNo('Payment %1', LineNo);
        _Assert.AreEqual(LineNo, EcomSalesPmtLine."Line No.", Context + ': Line No.');
        _Assert.AreEqual(EcomSalesPmtLine."Payment Method Type"::"Payment Method", EcomSalesPmtLine."Payment Method Type", Context + ': Payment Method Type');
        _Assert.AreEqual(PaymentCode, EcomSalesPmtLine."External Payment Method Code", Context + ': External Payment Method Code');
        _Assert.AreEqual(ExternalPaymentType, EcomSalesPmtLine."External Payment Type", Context + ': External Payment Type');
        _Assert.AreEqual(PaymentReference, EcomSalesPmtLine."Payment Reference", Context + ': Payment Reference');
        _Assert.AreEqual(Amount, EcomSalesPmtLine.Amount, Context + ': Amount');
        _Assert.AreEqual(PspToken, EcomSalesPmtLine."PSP Token", Context + ': PSP Token');
        _Assert.AreEqual(ParToken, EcomSalesPmtLine."PAR Token", Context + ': PAR Token');
        _Assert.AreEqual(CardExpiryDate, EcomSalesPmtLine."Card Expiry Date", Context + ': Card Expiry Date');
        _Assert.AreEqual(CardBrand, EcomSalesPmtLine."Card Brand", Context + ': Card Brand');
        _Assert.AreEqual(MaskedCardNumber, EcomSalesPmtLine."Masked Card Number", Context + ': Masked Card Number');
        _Assert.AreEqual(CardAliasToken, EcomSalesPmtLine."Card Alias Token", Context + ': Card Alias Token');
        _Assert.AreEqual(Description, EcomSalesPmtLine.Description, Context + ': Description');
    end;

    local procedure AssertStoredNote(EcomSalesHeader: Record "NPR Ecom Sales Header"; ExternalNo: Code[20]; NoteText: Text)
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        RecordLink.SetRange("Record ID", EcomSalesHeader.RecordId);
        RecordLink.SetRange(Company, CompanyName());
        _Assert.AreEqual(1, RecordLink.Count(), 'V1 must store exactly one note.');
        RecordLink.FindFirst();
        RecordLink.CalcFields(Note);
        _Assert.AreEqual(RecordLink.Type::Note, RecordLink.Type, 'The note must be of type Note.');
        _Assert.AreEqual('', RecordLink."User ID", 'The note must carry no user.');
        _Assert.AreEqual(ExternalNo, RecordLink.Description, 'The note description must be the External No.');
        _Assert.AreEqual(NoteText, RecordLinkManagement.ReadNote(RecordLink), 'The note text');
    end;

    local procedure DeleteRecordLinks(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID", EcomSalesHeader.RecordId);
        RecordLink.DeleteAll();
    end;

    local procedure DeleteForeignRecordLinks(EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        RecordLink: Record "Record Link";
    begin
        RecordLink.SetRange("Record ID", EcomSalesHeader.RecordId);
        RecordLink.SetFilter(Company, '<>%1', CompanyName());
        RecordLink.DeleteAll();
    end;

    local procedure AddOwnNote(var EcomSalesHeader: Record "NPR Ecom Sales Header"; NoteText: Text): Integer
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
        LinkId: Integer;
    begin
        LinkId := EcomSalesHeader.AddLink('', EcomSalesHeader."External No.");
        RecordLink.Get(LinkId);
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink."User ID" := '';
        RecordLinkManagement.WriteNote(RecordLink, NoteText);
        RecordLink.Modify();
        exit(LinkId);
    end;

    local procedure AddForeignNote(EcomSalesHeader: Record "NPR Ecom Sales Header"; NoteText: Text): Integer
    var
        RecordLink: Record "Record Link";
        RecordLinkManagement: Codeunit "Record Link Management";
    begin
        RecordLink.Init();
        RecordLink."Record ID" := EcomSalesHeader.RecordId;
        RecordLink.Type := RecordLink.Type::Note;
        RecordLink.Company := _ForeignCompanyLbl;
        RecordLink.Created := CurrentDateTime();
        RecordLink."User ID" := CopyStr(UserId(), 1, MaxStrLen(RecordLink."User ID"));
        RecordLink.Insert(true);
        RecordLinkManagement.WriteNote(RecordLink, NoteText);
        RecordLink.Modify();
        exit(RecordLink."Link ID");
    end;

    local procedure InsertFullDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        P1: Record "NPR Ecom Sales Pmt. Line";
        P2: Record "NPR Ecom Sales Pmt. Line";
        L1: Record "NPR Ecom Sales Line";
        L2: Record "NPR Ecom Sales Line";
        L3: Record "NPR Ecom Sales Line";
    begin
        _Assert.AreNotEqual(_ForeignCompanyLbl, CompanyName(), 'The foreign company must differ from the current company.');
        Clear(_FullNoteLinkIds);
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := _LibEcom.NextExternalNo('V1FULL');
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader."Creation Status" := EcomSalesHeader."Creation Status"::Canceled;
        EcomSalesHeader."Posting Status" := EcomSalesHeader."Posting Status"::"Partially Invoiced";
        EcomSalesHeader."Currency Code" := _FullCurrencyLbl;
        EcomSalesHeader."Currency Exchange Rate" := 7.46;
        EcomSalesHeader."External Document No." := _FullExtDocNoLbl;
        EcomSalesHeader."Your Reference" := _YourReferenceLbl;
        EcomSalesHeader."Location Code" := _LocationLbl;
        EcomSalesHeader."Price Excl. VAT" := true;
        EcomSalesHeader."Sell-to Customer No." := _FullCustomerNoLbl;
        EcomSalesHeader."Sell-to Customer Type" := _FullCustomerTypeLbl;
        EcomSalesHeader."Sell-to Name" := _FullSellToNameLbl;
        EcomSalesHeader."Sell-to Address" := _FullSellToAddressLbl;
        EcomSalesHeader."Sell-to Address 2" := _FullSellToAddress2Lbl;
        EcomSalesHeader."Sell-to Post Code" := _FullSellToPostCodeLbl;
        EcomSalesHeader."Sell-to County" := _FullSellToCountyLbl;
        EcomSalesHeader."Sell-to City" := _FullSellToCityLbl;
        EcomSalesHeader."Sell-to Country Code" := 'DK';
        EcomSalesHeader."Sell-to Contact" := _FullSellToContactLbl;
        EcomSalesHeader."Sell-to Email" := CopyStr(NewEmail('full'), 1, MaxStrLen(EcomSalesHeader."Sell-to Email"));
        EcomSalesHeader."Sell-to Phone No." := _FullPhoneLbl;
        EcomSalesHeader."Sell-to EAN" := _FullEanLbl;
        EcomSalesHeader."Sell-to VAT Registration No." := _FullVatLbl;
        EcomSalesHeader."Sell-to Invoice Email" := _FullInvoiceEmailLbl;
        EcomSalesHeader."Ship-to Name" := _FullShipToNameLbl;
        EcomSalesHeader."Ship-to Address" := _FullShipToAddressLbl;
        EcomSalesHeader."Ship-to Address 2" := _FullShipToAddress2Lbl;
        EcomSalesHeader."Ship-to Post Code" := _FullShipToPostCodeLbl;
        EcomSalesHeader."Ship-to County" := _FullShipToCountyLbl;
        EcomSalesHeader."Ship-to City" := _FullShipToCityLbl;
        EcomSalesHeader."Ship-to Country Code" := 'SE';
        EcomSalesHeader."Ship-to Contact" := _FullShipToContactLbl;
        EcomSalesHeader."Shipment Method Code" := _FullShipMethodLbl;
        EcomSalesHeader."Shipment Service" := _FullShipServiceLbl;
        EcomSalesHeader."Customer Template" := _CustomerTemplateLbl;
        EcomSalesHeader."Configuration Template" := _ConfigTemplateLbl;
        EcomSalesHeader."Language Tag" := _LanguageTagLbl;
        EcomSalesHeader."Ticket Reservation Token" := _TicketTokenLbl;
        EcomSalesHeader."Last Capture Error Message" := _CaptureErrorLbl;
        EcomSalesHeader."Created Doc No." := _CreatedDocNoLbl;
        EcomSalesHeader."Ship-to Phone No." := '+4622222222';
        EcomSalesHeader.Insert(true);

        DeleteRecordLinks(EcomSalesHeader);
        _FullNoteLinkIds.Add(AddOwnNote(EcomSalesHeader, _FullNote1Lbl));
        EcomSalesHeader.AddLink('https://example.test/v1', 'V1 link');
        _FullNoteLinkIds.Add(AddOwnNote(EcomSalesHeader, _FullNote2Lbl));
        _FullNoteLinkIds.Add(AddForeignNote(EcomSalesHeader, _ForeignNoteLbl));

        InitPayment(P1, EcomSalesHeader, 10000, P1."Payment Method Type"::"Payment Method");
        P1."External Payment Method Code" := _FullP1CodeLbl;
        P1."External Payment Type" := _FullP1TypeLbl;
        P1."Payment Reference" := _FullP1ReferenceLbl;
        P1.Amount := 250.5;
        P1."Captured Amount" := 100.25;
        P1."PSP Token" := _FullP1PspLbl;
        P1."Card Expiry Date" := _FullP1ExpiryLbl;
        P1."Card Brand" := _FullP1BrandLbl;
        P1."Masked Card Number" := _FullP1MaskedLbl;
        P1."PAR Token" := _FullP1ParLbl;
        P1."Card Alias Token" := _FullP1AliasLbl;
        P1.Insert(true);
        InitPayment(P2, EcomSalesHeader, 20000, P2."Payment Method Type"::"Payment Method");
        P2."External Payment Method Code" := _FullP2CodeLbl;
        P2.Amount := 10;
        P2.Insert(true);

        InitLine(L1, EcomSalesHeader, 10000, L1.Type::Item);
        L1."No." := _FullL1NoLbl;
        L1."Variant Code" := _FullL1VariantLbl;
        L1."Barcode No." := _FullL1BarcodeLbl;
        L1.Description := _FullL1DescriptionLbl;
        L1."Unit Price" := 80;
        L1.Quantity := 1.5;
        L1."Unit of Measure Code" := _UnitOfMeasureLbl;
        L1."VAT %" := 25;
        L1."Line Amount" := 120;
        L1."Requested Delivery Date" := 20260304D;
        L1."Invoiced Qty." := 0.5;
        L1."Invoiced Amount" := 40;
        L1."Created From Pmt. Line Id" := P1.SystemId;
        L1."External Line ID" := _FullL1ExternalLineIdLbl;
        L1.Subtype := L1.Subtype::Item;
        L1."Member Email" := _FullL1MemberEmailLbl;
        L1.Captured := true;
        L1."Virtual Item Process Status" := L1."Virtual Item Process Status"::Processed;
        L1."Membership Activation Date" := 20260401D;
        L1.Insert(true);
        InitLine(L2, EcomSalesHeader, 20000, L2.Type::Comment);
        L2.Description := _FullL2DescriptionLbl;
        L2.Insert(true);
        InitLine(L3, EcomSalesHeader, 30000, L3.Type::"Shipment Fee");
        L3."No." := _FullL3NoLbl;
        L3.Description := _FullL3DescriptionLbl;
        L3."Unit Price" := 9.5;
        L3.Quantity := 1;
        L3."VAT %" := 25;
        L3."Line Amount" := 9.5;
        L3.Insert(true);
        Commit();
    end;

    local procedure InitPayment(var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; LineNo: Integer; PaymentMethodType: Enum "NPR Ecom Pmt Method Type")
    begin
        EcomSalesPmtLine.Init();
        EcomSalesPmtLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesPmtLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesPmtLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesPmtLine."Line No." := LineNo;
        EcomSalesPmtLine."Payment Method Type" := PaymentMethodType;
    end;

    local procedure InitLine(var EcomSalesLine: Record "NPR Ecom Sales Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; LineNo: Integer; LineType: Enum "NPR Ecom Sales Line Type")
    begin
        EcomSalesLine.Init();
        EcomSalesLine."Document Entry No." := EcomSalesHeader."Entry No.";
        EcomSalesLine."Document Type" := EcomSalesHeader."Document Type";
        EcomSalesLine."External Document No." := EcomSalesHeader."External No.";
        EcomSalesLine."Line No." := LineNo;
        EcomSalesLine.Type := LineType;
    end;

    local procedure InsertHeaderOnlyDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; DocumentType: Enum "NPR Ecom Sales Doc Type"; CreationStatus: Enum "NPR EcomSalesDocCrtStatus"; PostingStatus: Enum "NPR EcomSalesDocPostStatus")
    begin
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := _LibEcom.NextExternalNo('V1HDR');
        EcomSalesHeader."Document Type" := DocumentType;
        EcomSalesHeader."Creation Status" := CreationStatus;
        EcomSalesHeader."Posting Status" := PostingStatus;
        EcomSalesHeader.Insert(true);
        DeleteRecordLinks(EcomSalesHeader);
        Commit();
    end;

    local procedure InsertLineVoucherDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    var
        ItemLine: Record "NPR Ecom Sales Line";
        VoucherLine: Record "NPR Ecom Sales Line";
    begin
        InsertHeaderOnlyDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Posting Status"::Pending);
        InitLine(ItemLine, EcomSalesHeader, 10000, ItemLine.Type::Item);
        ItemLine."No." := _FullL1NoLbl;
        ItemLine."Unit Price" := 10;
        ItemLine.Quantity := 1;
        ItemLine."Line Amount" := 10;
        ItemLine.Insert(true);
        InitLine(VoucherLine, EcomSalesHeader, 20000, VoucherLine.Type::Voucher);
        VoucherLine.Subtype := VoucherLine.Subtype::Voucher;
        VoucherLine.Description := 'V1 voucher line';
        VoucherLine.Quantity := 1;
        VoucherLine."Unit Price" := 50;
        VoucherLine."Line Amount" := 50;
        VoucherLine.Insert(true);
        Commit();
    end;

    local procedure InsertPaymentOnlyDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; PaymentMethodType: Enum "NPR Ecom Pmt Method Type")
    var
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
    begin
        InsertHeaderOnlyDocument(EcomSalesHeader, EcomSalesHeader."Document Type"::Order, EcomSalesHeader."Creation Status"::Pending, EcomSalesHeader."Posting Status"::Pending);
        InitPayment(EcomSalesPmtLine, EcomSalesHeader, 10000, PaymentMethodType);
        EcomSalesPmtLine."Payment Reference" := 'V1-VOUCHER-REF';
        EcomSalesPmtLine.Amount := 50;
        EcomSalesPmtLine.Insert(true);
        Commit();
    end;

    local procedure InsertV2Document(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var ItemNo: Code[20]; var PaymentCode: Code[50])
    var
        Body: JsonObject;
        Line: JsonObject;
        Lines: JsonArray;
        Payment: JsonObject;
        Payments: JsonArray;
        ExternalNo: Code[20];
    begin
        ExternalNo := _LibEcom.NextExternalNo('V1BYV2');
        ItemNo := _LibEcom.CreateItem();
        PaymentCode := _LibEcom.CreateGatewayCapturedPaymentMapping();
        Body := _LibEcom.BuildEcomDocumentBody(ExternalNo, 'order', '');
        Line.Add('type', 'item');
        Line.Add('no', ItemNo);
        Line.Add('description', 'V1 item via V2');
        Line.Add('quantity', DecimalOf(1));
        Line.Add('unitPrice', DecimalOf(100));
        Line.Add('vatPercent', DecimalOf(0));
        Line.Add('lineAmount', DecimalOf(100));
        Lines.Add(Line);
        Body.Add('salesDocumentLines', Lines);
        Payment.Add('paymentMethodType', 'paymentGateway');
        Payment.Add('externalPaymentMethodCode', PaymentCode);
        Payment.Add('paymentReference', 'V1-V2-PSP-REF');
        Payment.Add('paymentAmount', DecimalOf(100));
        Payment.Add('pspToken', 'V1-V2-PSP-TOKEN');
        Payment.Add('cardExpiryDate', '03/2030');
        Payment.Add('cardBrand', 'visa');
        Payment.Add('maskedCardNumber', '411111******1111');
        Payment.Add('parToken', 'V1-V2-PAR');
        Payment.Add('cardAliasToken', 'V1-V2-ALIAS');
        Payments.Add(Payment);
        Body.Add('payments', Payments);
        _LibEcom.SubmitEcomDocumentBody(Body, ExternalNo, EcomSalesHeader);
        DeleteRecordLinks(EcomSalesHeader);
        Commit();
    end;

    local procedure AssertV1Keys(Body: JsonObject; ExpectedRootKeys: Text; Context: Text)
    var
        Payments: JsonArray;
        Payment: JsonObject;
        i: Integer;
    begin
        _Assert.AreEqual(ExpectedRootKeys, KeysOf(Body), Context + ': root keys');
        _Assert.AreEqual(_V1SellToKeysLbl, KeysOf(ObjectAt(Body, 'sellToCustomer')), Context + ': sellToCustomer keys');
        _Assert.AreEqual(_ShipToKeysLbl, KeysOf(ObjectAt(Body, 'shipToCustomer')), Context + ': shipToCustomer keys');
        _Assert.AreEqual(_ShipmentKeysLbl, KeysOf(ObjectAt(Body, 'shipment')), Context + ': shipment keys');
        if Body.Contains('comments') then
            AssertEachKeys(ArrayAt(Body, 'comments'), _CommentKeysLbl, Context + ': comment');
        if Body.Contains('payments') then begin
            Payments := ArrayAt(Body, 'payments');
            for i := 0 to Payments.Count() - 1 do begin
                Payment := ElementAt(Payments, i);
                if Payment.Contains('paymentFees') then begin
                    _Assert.AreEqual(_V1PaymentKeysLbl + ',paymentFees', KeysOf(Payment), StrSubstNo('%1: payment %2 keys', Context, i));
                    AssertEachKeys(ArrayAt(Payment, 'paymentFees'), 'paymentFeeId', Context + ': payment fee');
                end else
                    _Assert.AreEqual(_V1PaymentKeysLbl, KeysOf(Payment), StrSubstNo('%1: payment %2 keys', Context, i));
            end;
        end;
        if Body.Contains('salesDocumentLines') then
            AssertEachKeys(ArrayAt(Body, 'salesDocumentLines'), _V1LineKeysLbl, Context + ': line');
    end;

    local procedure AssertEachKeys(Elements: JsonArray; ExpectedKeys: Text; Context: Text)
    var
        i: Integer;
    begin
        for i := 0 to Elements.Count() - 1 do
            _Assert.AreEqual(ExpectedKeys, KeysOf(ElementAt(Elements, i)), StrSubstNo('%1 %2 keys', Context, i));
    end;

    local procedure HasPinnedV1Keys(Body: JsonObject): Boolean
    var
        Lines: JsonArray;
        i: Integer;
    begin
        if KeysOf(Body) <> _V1RootKeysLbl then
            exit(false);
        Lines := ArrayAt(Body, 'salesDocumentLines');
        for i := 0 to Lines.Count() - 1 do
            if KeysOf(ElementAt(Lines, i)) <> _V1LineKeysLbl then
                exit(false);
        exit(true);
    end;

    local procedure AssertFullDocumentPinned(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text)
    var
        Response: JsonObject;
        Body: JsonObject;
        Fee: JsonObject;
    begin
        Response := GetById(EcomSalesHeader.SystemId, ApiVersion, true);
        _Assert.AreEqual(200, StatusOf(Response), At('A V1 get by id must answer HTTP 200.', ApiVersion));
        Body := BodyOf(Response);
        AssertNoEmptyCustomFields(Body, At('Full document', ApiVersion));
        AssertV1Keys(Body, _V1RootKeysLbl, At('Full document', ApiVersion));
        _Assert.AreEqual(3, ArrayAt(Body, 'comments').Count(), At('The document must answer the notes of every company and no Link record.', ApiVersion));
        Fee := SingleElementAt(ElementAt(ArrayAt(Body, 'payments'), 0), 'paymentFees', ApiVersion);
        _Assert.AreEqual(LineIdText(EcomSalesHeader, 10000), TextAt(Fee, 'paymentFeeId'), At('The fee must point at the first line.', ApiVersion));
        _Assert.IsFalse(ElementAt(ArrayAt(Body, 'payments'), 1).Contains('paymentFees'), At('A payment no line points at has no paymentFees.', ApiVersion));
        _Assert.AreEqual(NormalizedText(ExpectedFullDocument(EcomSalesHeader)), NormalizedText(WithoutCustomFields(Body)), At('The full document must hold every fixture value.', ApiVersion));
    end;

    local procedure AssertHeaderOnlyPinned(EcomSalesHeader: Record "NPR Ecom Sales Header"; ApiVersion: Text; DocumentTypeText: Text; CreationStatusText: Text; PostingStatusText: Text)
    var
        Body: JsonObject;
    begin
        Body := GetByIdBody(EcomSalesHeader.SystemId, ApiVersion);
        AssertNoEmptyCustomFields(Body, At('Header-only document', ApiVersion));
        AssertV1Keys(Body, _V1HeaderOnlyRootKeysLbl, At('Header-only document', ApiVersion));
        _Assert.AreEqual(NormalizedText(ExpectedHeaderOnlyDocument(EcomSalesHeader, DocumentTypeText, CreationStatusText, PostingStatusText)), NormalizedText(WithoutCustomFields(Body)), At('The header-only document must hold the mapped texts.', ApiVersion));
    end;

    local procedure AssertNotV1(Response: JsonObject; Context: Text)
    var
        Body: JsonObject;
    begin
        _Assert.AreEqual(200, StatusOf(Response), Context + ': a get by id must answer HTTP 200.');
        Body := BodyOf(Response);
        _Assert.IsFalse(ObjectAt(Body, 'sellToCustomer').Contains('type'), Context + ': V1 must not answer, so sellToCustomer has no type.');
        _Assert.IsTrue(Body.Contains('createdAt'), Context + ': V1 must not answer, so the root has createdAt.');
    end;

    local procedure AssertSingleHitEnvelope(Body: JsonObject; Context: Text): JsonObject
    var
        Hits: JsonArray;
    begin
        _Assert.AreEqual(_V2EnvelopeKeysLbl, KeysOf(Body), Context + ': envelope keys');
        _Assert.AreEqual('false', RawValueAt(Body, 'morePages'), Context + ': morePages');
        _Assert.AreEqual('', TextAt(Body, 'nextPageKey'), Context + ': nextPageKey');
        Hits := ArrayAt(Body, 'salesDocuments');
        _Assert.AreEqual(1, Hits.Count(), Context + ': the e-mail must find exactly the fixture.');
        exit(ElementAt(Hits, 0));
    end;

    local procedure RootJson(EcomSalesHeader: Record "NPR Ecom Sales Header"; DocumentTypeText: Text; CreationStatusText: Text; PostingStatusText: Text; CurrencyCode: Text; CurrencyExchangeRate: Decimal; ExternalDocumentNo: Text; YourReference: Text; LocationCode: Text; PricesExcludingVat: Boolean) Root: JsonObject
    begin
        Root.Add('externalNo', EcomSalesHeader."External No.");
        Root.Add('id', IdText(EcomSalesHeader.SystemId));
        Root.Add('documentType', DocumentTypeText);
        Root.Add('creationStatus', CreationStatusText);
        Root.Add('postingStatus', PostingStatusText);
        Root.Add('currencyCode', CurrencyCode);
        Root.Add('currencyExchangeRate', CurrencyExchangeRate);
        Root.Add('externalDocumentNo', ExternalDocumentNo);
        Root.Add('yourReference', YourReference);
        Root.Add('locationCode', LocationCode);
        Root.Add('pricesExcludingVat', PricesExcludingVat);
    end;

    local procedure SellToJson(No: Text; WithType: Boolean; CustomerType: Text; Name: Text; Address: Text; Address2: Text; PostCode: Text; County: Text; City: Text; CountryCode: Text; Contact: Text; Email: Text; Phone: Text; Ean: Text; VatRegistrationNo: Text; InvoiceEmail: Text) SellTo: JsonObject
    begin
        SellTo.Add('no', No);
        if WithType then
            SellTo.Add('type', CustomerType);
        SellTo.Add('name', Name);
        SellTo.Add('address', Address);
        SellTo.Add('address2', Address2);
        SellTo.Add('postCode', PostCode);
        SellTo.Add('county', County);
        SellTo.Add('city', City);
        SellTo.Add('countryCode', CountryCode);
        SellTo.Add('contact', Contact);
        SellTo.Add('email', Email);
        SellTo.Add('phone', Phone);
        SellTo.Add('ean', Ean);
        SellTo.Add('vatRegistrationNo', VatRegistrationNo);
        SellTo.Add('invoiceEmail', InvoiceEmail);
    end;

    local procedure ShipToJson(Name: Text; Address: Text; Address2: Text; PostCode: Text; County: Text; City: Text; CountryCode: Text; Contact: Text) ShipTo: JsonObject
    begin
        ShipTo.Add('name', Name);
        ShipTo.Add('address', Address);
        ShipTo.Add('address2', Address2);
        ShipTo.Add('postCode', PostCode);
        ShipTo.Add('county', County);
        ShipTo.Add('city', City);
        ShipTo.Add('countryCode', CountryCode);
        ShipTo.Add('contact', Contact);
    end;

    local procedure ShipmentJson(ShipmentMethod: Text; ShipmentService: Text) Shipment: JsonObject
    begin
        Shipment.Add('shipmentMethod', ShipmentMethod);
        Shipment.Add('shipmentService', ShipmentService);
    end;

    local procedure CommentJson(Id: Guid; CommentText: Text) Comment: JsonObject
    begin
        Comment.Add('id', IdText(Id));
        Comment.Add('comment', CommentText);
    end;

    local procedure PaymentJson(Id: Guid; PaymentCode: Text; ExternalPaymentType: Text; PaymentReference: Text; PaymentAmount: Decimal; PspToken: Text; CardExpiryDate: Text; CardBrand: Text; MaskedCardNumber: Text; ParToken: Text; CardAliasToken: Text; CapturedPaymentAmount: Decimal) Payment: JsonObject
    begin
        Payment.Add('id', IdText(Id));
        Payment.Add('paymentMethodType', 'paymentGateway');
        Payment.Add('externalPaymentMethodCode', PaymentCode);
        Payment.Add('externalPaymentType', ExternalPaymentType);
        Payment.Add('paymentReference', PaymentReference);
        Payment.Add('paymentAmount', PaymentAmount);
        Payment.Add('pspToken', PspToken);
        Payment.Add('cardExpiryDate', CardExpiryDate);
        Payment.Add('cardBrand', CardBrand);
        Payment.Add('maskedCardNumber', MaskedCardNumber);
        Payment.Add('parToken', ParToken);
        Payment.Add('cardAliasToken', CardAliasToken);
        Payment.Add('capturedPaymentAmount', CapturedPaymentAmount);
    end;

    local procedure LineJson(Id: Guid; LineTypeText: Text; No: Text; VariantCode: Text; BarcodeNo: Text; Description: Text; UnitPrice: Decimal; Quantity: Decimal; UnitOfMeasure: Text; VatPercent: Decimal; LineAmount: Decimal; RequestedDeliveryDate: Text; InvoicedQuantity: Decimal; InvoicedAmount: Decimal) Line: JsonObject
    begin
        Line.Add('id', IdText(Id));
        Line.Add('type', LineTypeText);
        Line.Add('no', No);
        Line.Add('variantCode', VariantCode);
        Line.Add('barcodeNo', BarcodeNo);
        Line.Add('description', Description);
        Line.Add('unitPrice', UnitPrice);
        Line.Add('quantity', Quantity);
        Line.Add('unitOfMeasure', UnitOfMeasure);
        Line.Add('vatPercent', VatPercent);
        Line.Add('lineAmount', LineAmount);
        Line.Add('requestedDeliveryDate', RequestedDeliveryDate);
        Line.Add('invoicedQuantity', InvoicedQuantity);
        Line.Add('invoicedAmount', InvoicedAmount);
    end;

    local procedure V2DetailedLineJson(V1Line: JsonObject; Captured: Boolean; VirtualItemProcessStatus: Text; MemberEmail: Text; MembershipActivationDate: Text; ExternalLineId: Text) Line: JsonObject
    var
        NilId: Guid;
        IssuedAssets: JsonArray;
    begin
        Line := V1Line.Clone().AsObject();
        Line.Add('captured', Captured);
        Line.Add('virtualItemProcessStatus', VirtualItemProcessStatus);
        Line.Add('virtualItemProcessErrorMessage', '');
        Line.Add('attractionWalletProcessStatus', ' ');
        Line.Add('attractionWalletProcessErrorMessage', '');
        Line.Add('ticketReservationLineId', IdText(NilId));
        Line.Add('membershipId', IdText(NilId));
        Line.Add('membershipOperation', '');
        Line.Add('memberFirstName', '');
        Line.Add('memberLastName', '');
        Line.Add('memberMiddleName', '');
        Line.Add('memberEmail', MemberEmail);
        Line.Add('memberPhoneNo', '');
        Line.Add('memberBirthday', '');
        Line.Add('memberGender', '');
        Line.Add('memberAddress', '');
        Line.Add('memberCity', '');
        Line.Add('memberCountry', '');
        Line.Add('memberPostCode', '');
        Line.Add('memberNewsletter', '');
        Line.Add('memberGdprApproval', '');
        Line.Add('membershipActivationDate', MembershipActivationDate);
        Line.Add('subscription', false);
        Line.Add('issuedAssets', IssuedAssets);
        if ExternalLineId <> '' then
            Line.Add('externalLineId', ExternalLineId);
    end;

    local procedure FullSellToJson(EcomSalesHeader: Record "NPR Ecom Sales Header"; WithType: Boolean): JsonObject
    begin
        exit(SellToJson(_FullCustomerNoLbl, WithType, _FullCustomerTypeLbl, _FullSellToNameLbl, _FullSellToAddressLbl, _FullSellToAddress2Lbl, _FullSellToPostCodeLbl, _FullSellToCountyLbl, _FullSellToCityLbl, 'DK', _FullSellToContactLbl, EcomSalesHeader."Sell-to Email", _FullPhoneLbl, _FullEanLbl, _FullVatLbl, _FullInvoiceEmailLbl));
    end;

    local procedure FullShipToJson(): JsonObject
    begin
        exit(ShipToJson(_FullShipToNameLbl, _FullShipToAddressLbl, _FullShipToAddress2Lbl, _FullShipToPostCodeLbl, _FullShipToCountyLbl, _FullShipToCityLbl, 'SE', _FullShipToContactLbl));
    end;

    local procedure FullComments() Comments: JsonArray
    begin
        Comments.Add(CommentJson(LinkSystemIdOf(_FullNoteLinkIds.Get(1)), _FullNote1Lbl));
        Comments.Add(CommentJson(LinkSystemIdOf(_FullNoteLinkIds.Get(2)), _FullNote2Lbl));
        Comments.Add(CommentJson(LinkSystemIdOf(_FullNoteLinkIds.Get(3)), _ForeignNoteLbl));
    end;

    local procedure FullV1Lines(EcomSalesHeader: Record "NPR Ecom Sales Header") Lines: JsonArray
    begin
        Lines.Add(LineJson(LineIdOf(EcomSalesHeader, 10000), 'item', _FullL1NoLbl, _FullL1VariantLbl, _FullL1BarcodeLbl, _FullL1DescriptionLbl, 80, 1.5, _UnitOfMeasureLbl, 25, 120, '2026-03-04', 0.5, 40));
        Lines.Add(LineJson(LineIdOf(EcomSalesHeader, 20000), 'comment', '', '', '', _FullL2DescriptionLbl, 0, 0, '', 0, 0, '', 0, 0));
        Lines.Add(LineJson(LineIdOf(EcomSalesHeader, 30000), 'shipmentFee', _FullL3NoLbl, '', '', _FullL3DescriptionLbl, 9.5, 1, '', 25, 9.5, '', 0, 0));
    end;

    local procedure ExpectedFullDocument(EcomSalesHeader: Record "NPR Ecom Sales Header") Document: JsonObject
    var
        Payment: JsonObject;
        Fee: JsonObject;
        Fees: JsonArray;
        Payments: JsonArray;
    begin
        Document := RootJson(EcomSalesHeader, 'order', 'canceled', 'partiallyInvoiced', _FullCurrencyLbl, 7.46, _FullExtDocNoLbl, _YourReferenceLbl, _LocationLbl, true);
        Document.Add('sellToCustomer', FullSellToJson(EcomSalesHeader, true));
        Document.Add('shipToCustomer', FullShipToJson());
        Document.Add('shipment', ShipmentJson(_FullShipMethodLbl, _FullShipServiceLbl));
        Document.Add('comments', FullComments());
        Payment := PaymentJson(PaymentIdOf(EcomSalesHeader, 10000), _FullP1CodeLbl, _FullP1TypeLbl, _FullP1ReferenceLbl, 250.5, _FullP1PspLbl, _FullP1ExpiryLbl, _FullP1BrandLbl, _FullP1MaskedLbl, _FullP1ParLbl, _FullP1AliasLbl, 100.25);
        Fee.Add('paymentFeeId', IdText(LineIdOf(EcomSalesHeader, 10000)));
        Fees.Add(Fee);
        Payment.Add('paymentFees', Fees);
        Payments.Add(Payment);
        Payments.Add(PaymentJson(PaymentIdOf(EcomSalesHeader, 20000), _FullP2CodeLbl, '', '', 10, '', '', '', '', '', '', 0));
        Document.Add('payments', Payments);
        Document.Add('salesDocumentLines', FullV1Lines(EcomSalesHeader));
    end;

    local procedure ExpectedHeaderOnlyDocument(EcomSalesHeader: Record "NPR Ecom Sales Header"; DocumentTypeText: Text; CreationStatusText: Text; PostingStatusText: Text) Document: JsonObject
    begin
        Document := RootJson(EcomSalesHeader, DocumentTypeText, CreationStatusText, PostingStatusText, '', 0, '', '', '', false);
        Document.Add('sellToCustomer', SellToJson('', true, '', '', '', '', '', '', '', '', '', '', '', '', '', ''));
        Document.Add('shipToCustomer', ShipToJson('', '', '', '', '', '', '', ''));
        Document.Add('shipment', ShipmentJson('', ''));
    end;

    local procedure ExpectedCreatedDocument(EcomSalesHeader: Record "NPR Ecom Sales Header"; ExternalNo: Code[20]; ItemNo: Code[20]; PaymentCode: Code[50]; Email: Text) Document: JsonObject
    var
        RecordLink: Record "Record Link";
        Comments: JsonArray;
        Payments: JsonArray;
        Lines: JsonArray;
    begin
        Document := RootJson(EcomSalesHeader, 'order', 'error', 'pending', 'EUR', 7.46, _BodyExtDocNoLbl, _YourReferenceLbl, _LocationLbl, true);
        _Assert.AreEqual(ExternalNo, TextAt(Document, 'externalNo'), 'Read back External No.');
        Document.Add('sellToCustomer', SellToJson(_BodyCustomerNoLbl, true, 'person', 'V1 Buyer', 'V1 Street 1', 'Floor 2', '2100', 'Capital', 'Copenhagen', 'DK', 'V1 Contact', Email, '+45 1234 5678', '5790000000001', 'DK12345678', InvoiceEmailOf(Email)));
        Document.Add('shipToCustomer', ShipToJson('V1 Receiver', 'Receiver Street 9', 'Back entrance', '21100', 'Skane', 'Malmo', 'SE', 'Receiver Contact'));
        Document.Add('shipment', ShipmentJson('V1SHIP', 'EXPRESS'));
        RecordLink.SetRange("Record ID", EcomSalesHeader.RecordId);
        RecordLink.SetRange(Company, CompanyName());
        RecordLink.FindFirst();
        Comments.Add(CommentJson(RecordLink.SystemId, _BodyCommentLbl));
        Document.Add('comments', Comments);
        Payments.Add(PaymentJson(PaymentIdOf(EcomSalesHeader, 10000), PaymentCode, 'visa', 'V1-PSP-REF', 169, 'V1-PSP-TOKEN', '12/26', 'visa', '************1111', 'V1-PAR', 'V1-ALIAS', 0));
        Payments.Add(PaymentJson(PaymentIdOf(EcomSalesHeader, 20000), PaymentCode, '', 'V1-PSP-REF-2', 0.5, '', '', '', '', '', '', 0));
        Document.Add('payments', Payments);
        Lines.Add(LineJson(LineIdOf(EcomSalesHeader, 10000), 'item', ItemNo, 'RED', '5790000000123', 'V1 item', 80, 1.5, _UnitOfMeasureLbl, 25, 120, '2026-12-24', 0, 0));
        Lines.Add(LineJson(LineIdOf(EcomSalesHeader, 20000), 'comment', '', '', '', 'Gift wrap please', 0, 0, '', 0, 0, '', 0, 0));
        Lines.Add(LineJson(LineIdOf(EcomSalesHeader, 30000), 'shipmentFee', 'V1SHIPFEE', '', '', 'Express shipping', 49, 1, '', 25, 49, '', 0, 0));
        Document.Add('salesDocumentLines', Lines);
    end;

    local procedure ExpectedFindSummaryHit(EcomSalesHeader: Record "NPR Ecom Sales Header") Hit: JsonObject
    var
        SellTo: JsonObject;
        PostedDocumentNos: JsonArray;
    begin
        Hit.Add('externalNo', EcomSalesHeader."External No.");
        Hit.Add('id', IdText(EcomSalesHeader.SystemId));
        Hit.Add('documentType', 'order');
        Hit.Add('creationStatus', 'canceled');
        Hit.Add('postingStatus', 'partiallyInvoiced');
        Hit.Add('currencyCode', _FullCurrencyLbl);
        Hit.Add('externalDocumentNo', _FullExtDocNoLbl);
        Hit.Add('captureProcessingStatus', 'pending');
        Hit.Add('createdDocumentNo', _CreatedDocNoLbl);
        Hit.Add('postedDocumentNos', PostedDocumentNos);
        SellTo.Add('no', _FullCustomerNoLbl);
        SellTo.Add('name', _FullSellToNameLbl);
        SellTo.Add('email', EcomSalesHeader."Sell-to Email");
        SellTo.Add('phone', _FullPhoneLbl);
        Hit.Add('sellToCustomer', SellTo);
    end;

    local procedure ExpectedFindDetailedHit(EcomSalesHeader: Record "NPR Ecom Sales Header") Hit: JsonObject
    var
        V1Lines: JsonArray;
        Lines: JsonArray;
        PostedDocumentNos: JsonArray;
        Token: JsonToken;
    begin
        Hit.Add('externalNo', EcomSalesHeader."External No.");
        Hit.Add('id', IdText(EcomSalesHeader.SystemId));
        Hit.Add('documentType', 'order');
        Hit.Add('creationStatus', 'canceled');
        Hit.Add('postingStatus', 'partiallyInvoiced');
        Hit.Add('currencyCode', _FullCurrencyLbl);
        Hit.Add('currencyExchangeRate', DecimalOf(7.46));
        Hit.Add('externalDocumentNo', _FullExtDocNoLbl);
        Hit.Add('yourReference', _YourReferenceLbl);
        Hit.Add('languageTag', _LanguageTagLbl);
        Hit.Add('locationCode', _LocationLbl);
        Hit.Add('pricesExcludingVat', true);
        Hit.Add('ticketReservationToken', _TicketTokenLbl);
        Hit.Add('captureProcessingStatus', 'pending');
        Hit.Add('lastCaptureErrorMessage', _CaptureErrorLbl);
        Hit.Add('createdDocumentNo', _CreatedDocNoLbl);
        Hit.Add('postedDocumentNos', PostedDocumentNos);
        Hit.Add('sellToCustomer', FullSellToJson(EcomSalesHeader, false));
        Hit.Add('shipToCustomer', FullShipToJson());
        Hit.Add('shipment', ShipmentJson(_FullShipMethodLbl, _FullShipServiceLbl));
        Hit.Add('comments', FullComments());
        V1Lines := FullV1Lines(EcomSalesHeader);
        V1Lines.Get(0, Token);
        Lines.Add(V2DetailedLineJson(Token.AsObject(), true, 'processed', _FullL1MemberEmailLbl, '2026-04-01', _FullL1ExternalLineIdLbl));
        V1Lines.Get(1, Token);
        Lines.Add(V2DetailedLineJson(Token.AsObject(), false, ' ', '', '', ''));
        V1Lines.Get(2, Token);
        Lines.Add(V2DetailedLineJson(Token.AsObject(), false, ' ', '', '', ''));
        Hit.Add('salesDocumentLines', Lines);
    end;
}

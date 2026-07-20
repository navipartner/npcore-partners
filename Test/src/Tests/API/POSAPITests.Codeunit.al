#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85157 "NPR POS API Tests"
{
    // [FEATURE] POS API end-to-end tests

    Subtype = Test;

    var
        _Initialized: Boolean;
        _RestaurantInitialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;
        _Item2: Record Item;
        _CashPaymentMethod: Record "NPR POS Payment Method";
        _EFTPaymentMethod: Record "NPR POS Payment Method";
        _Salesperson: Record "Salesperson/Purchaser";
        _Seating: Record "NPR NPRE Seating";
        _ItemAddon: Record "NPR NpIa Item AddOn";
        _AddonItem: Record Item;
        _AddonInitialized: Boolean;
        _Menu: Record "NPR NPRE Menu";
        _MenuInitialized: Boolean;
        _VisaPaymentMethod: Record "NPR POS Payment Method";
        _MastercardPaymentMethod: Record "NPR POS Payment Method";
        _EFTMappingInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_AddLine_PayCash_Complete_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ReceiptNo: Text;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        // [SCENARIO] Happy path - Create sale, add item line, pay with cash, complete sale
        Initialize();

        // [GIVEN] A new sale ID
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        // [WHEN] Create a new sale
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [THEN] Sale created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('saleId', JToken), 'Response should contain saleId');
        Assert.AreEqual(FormatGuid(SaleId), JToken.AsValue().AsText(), 'SaleId should match');

        // [WHEN] Add a sale line with item
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);

        // [THEN] Sale line created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Add a cash payment line for the full amount
        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);

        // [THEN] Payment line created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [WHEN] Complete the sale
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Sale completed successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');

        // [THEN] POS Entry is created
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('documentNo', JToken), 'Response should contain documentNo');
        ReceiptNo := JToken.AsValue().AsText();
        POSEntry.SetRange("Document No.", ReceiptNo);
        Assert.IsTrue(POSEntry.FindFirst(), 'POS Entry should be created');
        Assert.AreEqual(_POSUnit."No.", POSEntry."POS Unit No.", 'POS Entry should have correct POS Unit');
        Assert.AreEqual(_Item."Unit Price", POSEntry."Amount Incl. Tax & Round", 'POS Entry should have the fully paid total');

        POSEntrySalesLine.SetCurrentKey("POS Entry No.", "Line No.");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'POS Entry sales line should be created');
        Assert.AreEqual(SaleLineId, POSEntrySalesLine.SystemId, 'First POS Entry sales line should preserve the API sale line ID');

        AssertBillingEvent(
            POSEntry.SystemId,
            Enum::"NPR Billing Event Type"::RETAIL_SELFSERVICE_ORDERS_COUNT,
            1);
        AssertAmountBillingEvent(
            POSEntrySalesLine.SystemId,
            Enum::"NPR Billing Event Type"::RETAIL_SELFSERVICE_ORDERS_AMOUNT_LCY,
            POSEntry."Amount Incl. Tax & Round");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ListEntries_WithLinesParameter_ControlsReturnedLines()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        ReceiptNo: Text;
        EntriesArray: JsonArray;
        EntryToken: JsonToken;
        EntryObject: JsonObject;
        SalesLines: JsonArray;
        PaymentLines: JsonArray;
    begin
        // [SCENARIO] List POS entries returns lines only when withLines=true is requested
        Initialize();

        // [GIVEN] A completed sale that created a POS entry
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('documentNo', JToken), 'Response should contain documentNo');
        ReceiptNo := JToken.AsValue().AsText();

        // [WHEN] List entries without withLines
        Clear(QueryParams);
        QueryParams.Add('documentNo', ReceiptNo);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/entry', Body, QueryParams, Headers);

        // [THEN] The entry is returned without line arrays
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'List entries without withLines should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('data', JToken), 'Response should contain data');
        EntriesArray := JToken.AsArray();
        Assert.AreEqual(1, EntriesArray.Count(), 'Document filter should return exactly one entry');
        EntriesArray.Get(0, EntryToken);
        EntryObject := EntryToken.AsObject();
        Assert.IsFalse(EntryObject.Get('salesLines', JToken), 'salesLines should be omitted by default');
        Assert.IsFalse(EntryObject.Get('paymentLines', JToken), 'paymentLines should be omitted by default');
        Assert.IsFalse(EntryObject.Get('taxLines', JToken), 'taxLines should be omitted by default');

        // [WHEN] List entries with withLines=true
        Clear(QueryParams);
        QueryParams.Add('documentNo', ReceiptNo);
        QueryParams.Add('withLines', 'true');
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/entry', Body, QueryParams, Headers);

        // [THEN] The entry includes serialized lines
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'List entries with withLines should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('data', JToken), 'Response should contain data');
        EntriesArray := JToken.AsArray();
        Assert.AreEqual(1, EntriesArray.Count(), 'Document filter should still return exactly one entry');
        EntriesArray.Get(0, EntryToken);
        EntryObject := EntryToken.AsObject();
        Assert.IsTrue(EntryObject.Get('salesLines', JToken), 'salesLines should be returned when withLines=true');
        SalesLines := JToken.AsArray();
        Assert.AreEqual(1, SalesLines.Count(), 'Completed sale should expose one sales line');
        Assert.IsTrue(EntryObject.Get('paymentLines', JToken), 'paymentLines should be returned when withLines=true');
        PaymentLines := JToken.AsArray();
        Assert.AreEqual(1, PaymentLines.Count(), 'Completed sale should expose one payment line');
        Assert.IsTrue(EntryObject.Get('taxLines', JToken), 'taxLines should be returned when withLines=true');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_NoPOSUnitInUserSetup_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        UserSetup: Record "User Setup";
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Create sale returns 400 when the API user's User Setup has no POS Unit assigned
        Initialize();

        // [GIVEN] API user's User Setup has no POS Unit
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := '';
        UserSetup.Modify();
        Commit();

        // [WHEN] Create a sale
        SaleId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [CLEANUP] Restore User Setup before asserting
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();
        Commit();

        // [THEN] 400 Bad Request
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Should return 400 Bad Request');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_EchoesVATBusinessPostingGroupAndCustomerNo()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        Assert: Codeunit Assert;
        AltVATBusGroup: Record "VAT Business Posting Group";
        AltVATPostingSetup: Record "VAT Posting Setup";
        Customer: Record Customer;
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
    begin
        // [SCENARIO] POST /pos/sale with body.vatBusinessPostingGroup and body.customerNo echoes both back in the response,
        //             confirming the server applied the overrides (regression — response used to echo stale session defaults).
        Initialize();

        LibraryERM.CreateVATBusinessPostingGroup(AltVATBusGroup);
        LibraryERM.CreateVATPostingSetup(AltVATPostingSetup, AltVATBusGroup.Code, _Item."VAT Prod. Posting Group");
        AltVATPostingSetup."VAT %" := 0;
        AltVATPostingSetup."VAT Calculation Type" := AltVATPostingSetup."VAT Calculation Type"::"Normal VAT";
        AltVATPostingSetup."VAT Identifier" := 'ZERO';
        AltVATPostingSetup."Sales VAT Account" := LibraryERM.CreateGLAccountNo();
        AltVATPostingSetup."Purchase VAT Account" := LibraryERM.CreateGLAccountNo();
        AltVATPostingSetup.Modify();
        LibrarySales.CreateCustomer(Customer);
        Commit();

        SaleId := CreateGuid();
        Body.Add('vatBusinessPostingGroup', AltVATBusGroup.Code);
        Body.Add('customerNo', Customer."No.");

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('vatBusinessPostingGroup', JToken), 'Response should contain vatBusinessPostingGroup');
        Assert.AreEqual(AltVATBusGroup.Code, JToken.AsValue().AsText(), 'Response should echo the requested vatBusinessPostingGroup');
        Assert.IsTrue(ResponseBody.Get('customerNo', JToken), 'Response should contain customerNo');
        Assert.AreEqual(Customer."No.", JToken.AsValue().AsText(), 'Response should echo the requested customerNo');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateSale_ChangesVATAndGenOnHeaderAndLines()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        NewVATPostingSetup: Record "VAT Posting Setup";
        NewGenBusPostingGroup: Record "Gen. Business Posting Group";
        POSSaleRec: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        IdToken: JsonToken;
        RefreshedLines: JsonArray;
        LineToken: JsonToken;
        FoundLine: Boolean;
    begin
        // [SCENARIO] PATCH /pos/sale with vat+gen business posting groups updates BOTH the header AND existing sale lines.
        //            Regression: PATCH used to validate only the header VAT field (leaving lines stale) and ignored gen entirely.
        Initialize();

        // [GIVEN] A sale with one item line
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [GIVEN] A new VAT Bus. Posting Group (with a VAT Posting Setup for the item's VAT Prod group) and a new Gen Bus. Posting Group
        LibraryERM.CreateVATPostingSetupWithAccounts(NewVATPostingSetup, NewVATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        LibraryERM.CreateGenBusPostingGroup(NewGenBusPostingGroup);
        NPRLibraryPOSMasterData.CreateVATPostingSetupForSaleItem(NewVATPostingSetup."VAT Bus. Posting Group", _Item."VAT Prod. Posting Group");
        Commit();

        // [WHEN] PATCH the sale with both groups
        Clear(Body);
        Body.Add('vatBusinessPostingGroup', NewVATPostingSetup."VAT Bus. Posting Group");
        Body.Add('genBusinessPostingGroup', NewGenBusPostingGroup.Code);
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Patch sale should succeed');

        // [THEN] The PATCH delta response reports the patched line as refreshed (proves line-level delta capture, not just DB state)
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('refreshedSaleLines', JToken), 'PATCH response should contain refreshedSaleLines');
        RefreshedLines := JToken.AsArray();
        foreach LineToken in RefreshedLines do
            if LineToken.AsObject().Get('id', IdToken) then
                if IdToken.AsValue().AsText() = FormatGuid(SaleLineId) then
                    FoundLine := true;
        Assert.IsTrue(FoundLine, 'refreshedSaleLines should contain the patched item line');

        // [THEN] The header carries both new groups
        Assert.IsTrue(POSSaleRec.GetBySystemId(SaleId), 'Sale header should exist');
        Assert.AreEqual(NewVATPostingSetup."VAT Bus. Posting Group", POSSaleRec."VAT Bus. Posting Group", 'Header VAT Bus. Posting Group should be updated');
        Assert.AreEqual(NewGenBusPostingGroup.Code, POSSaleRec."Gen. Bus. Posting Group", 'Header Gen. Bus. Posting Group should be updated');

        // [THEN] The exact item line (fetched by its SystemId = SaleLineId) ALSO carries both new groups — this is what was broken before the fix
        Assert.IsTrue(SaleLinePOS.GetBySystemId(SaleLineId), 'Item sale line should exist');
        Assert.AreEqual(SaleLinePOS."Line Type"::Item, SaleLinePOS."Line Type", 'Fetched line should be the item line');
        Assert.AreEqual(NewVATPostingSetup."VAT Bus. Posting Group", SaleLinePOS."VAT Bus. Posting Group", 'Line VAT Bus. Posting Group should be updated');
        Assert.AreEqual(NewGenBusPostingGroup.Code, SaleLinePOS."Gen. Bus. Posting Group", 'Line Gen. Bus. Posting Group should be updated');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_AppliesGenBusinessPostingGroup()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        NewGenBusPostingGroup: Record "Gen. Business Posting Group";
        POSSaleRec: Record "NPR POS Sale";
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
    begin
        // [SCENARIO] POST /pos/sale with body.genBusinessPostingGroup applies it to the sale header and echoes it back.
        //            Regression: the API used to ignore genBusinessPostingGroup entirely.
        Initialize();

        LibraryERM.CreateGenBusPostingGroup(NewGenBusPostingGroup);
        Commit();

        SaleId := CreateGuid();
        Body.Add('genBusinessPostingGroup', NewGenBusPostingGroup.Code);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [THEN] Response echoes the gen group
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('genBusinessPostingGroup', JToken), 'Response should contain genBusinessPostingGroup');
        Assert.AreEqual(NewGenBusPostingGroup.Code, JToken.AsValue().AsText(), 'Response should echo the requested genBusinessPostingGroup');

        // [THEN] Header record carries the gen group
        Assert.IsTrue(POSSaleRec.GetBySystemId(SaleId), 'Sale header should exist');
        Assert.AreEqual(NewGenBusPostingGroup.Code, POSSaleRec."Gen. Bus. Posting Group", 'Header Gen. Bus. Posting Group should be set');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateSale_WithCustomerAndGroups_PreservesCustomerAndAppliesGroups()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibrarySales: Codeunit "Library - Sales";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        NewVATPostingSetup: Record "VAT Posting Setup";
        NewGenBusPostingGroup: Record "Gen. Business Posting Group";
        Customer: Record Customer;
        POSSaleRec: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] PATCH /pos/sale with customerNo AND explicit posting groups in the SAME body must keep the new customer
        //            on the header AND apply the explicit groups. Regression: delegating the group change to the VAT helper
        //            (which reads/writes the POS Sale codeunit's cached record) wrote stale pre-customer header state back,
        //            reverting the just-applied Customer No.
        Initialize();

        // [GIVEN] A sale with one item line, created without a customer
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [GIVEN] A customer (whose VAT group has a setup for the item, so the customer-validate cascade can re-VAT the line)
        //         plus explicit VAT and Gen groups to send alongside the customer
        LibraryERM.CreateVATPostingSetupWithAccounts(NewVATPostingSetup, NewVATPostingSetup."VAT Calculation Type"::"Normal VAT", LibraryRandom.RandDecInDecimalRange(10, 25, 0));
        LibraryERM.CreateGenBusPostingGroup(NewGenBusPostingGroup);
        NPRLibraryPOSMasterData.CreateVATPostingSetupForSaleItem(NewVATPostingSetup."VAT Bus. Posting Group", _Item."VAT Prod. Posting Group");
        LibrarySales.CreateCustomer(Customer);
        Customer."VAT Bus. Posting Group" := NewVATPostingSetup."VAT Bus. Posting Group";
        Customer.Modify();
        Commit();

        // [WHEN] PATCH with customerNo AND both posting groups together
        Clear(Body);
        Body.Add('customerNo', Customer."No.");
        Body.Add('vatBusinessPostingGroup', NewVATPostingSetup."VAT Bus. Posting Group");
        Body.Add('genBusinessPostingGroup', NewGenBusPostingGroup.Code);
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Patch sale should succeed');

        // [THEN] The header keeps the new customer (regression guard) AND carries the explicit groups
        Assert.IsTrue(POSSaleRec.GetBySystemId(SaleId), 'Sale header should exist');
        Assert.AreEqual(Customer."No.", POSSaleRec."Customer No.", 'Header Customer No. must survive the combined customer+groups patch');
        Assert.AreEqual(NewVATPostingSetup."VAT Bus. Posting Group", POSSaleRec."VAT Bus. Posting Group", 'Header VAT Bus. Posting Group should be the explicit group');
        Assert.AreEqual(NewGenBusPostingGroup.Code, POSSaleRec."Gen. Bus. Posting Group", 'Header Gen. Bus. Posting Group should override the customer default');

        // [THEN] The existing line also carries the explicit groups
        Assert.IsTrue(SaleLinePOS.GetBySystemId(SaleLineId), 'Item sale line should exist');
        Assert.AreEqual(NewVATPostingSetup."VAT Bus. Posting Group", SaleLinePOS."VAT Bus. Posting Group", 'Line VAT Bus. Posting Group should be the explicit group');
        Assert.AreEqual(NewGenBusPostingGroup.Code, SaleLinePOS."Gen. Bus. Posting Group", 'Line Gen. Bus. Posting Group should override the customer default');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetSale_NonExistent_ReturnsNotFound()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Get non-existent sale returns Not Found
        Initialize();

        // [GIVEN] A random sale ID that doesn't exist
        SaleId := CreateGuid();

        // [WHEN] Get the non-existent sale
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [THEN] Should return Not Found
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(404, StatusCode, 'Should return 404 Not Found');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_WithoutPayment_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Complete sale without payment returns Bad Request
        Initialize();

        // [GIVEN] A sale with a line but no payment
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Try to complete without payment
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Should return Bad Request
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Should return 400 Bad Request when payment is missing');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_Underpayment_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Complete sale with payment 1 less than needed returns Bad Request
        Initialize();

        // [GIVEN] A sale with a line
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [GIVEN] Payment of 1 less than full amount
        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price" - 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [WHEN] Try to complete with underpayment
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Should return Bad Request
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Should return 400 Bad Request when underpaid by 1');
        AssertBillingEventNotRegistered(SaleId);
        AssertBillingEventNotRegistered(SaleLineId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_BalancedExchangeWithoutPayment_RegistersBillingEvents()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        ReturnSaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
    begin
        Initialize();

        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        ReturnSaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create positive sale line should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', -1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(ReturnSaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create return sale line should succeed');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Balanced exchange should complete without payment');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('entryNo', JToken), 'Response should contain entryNo');
        Assert.IsTrue(POSEntry.Get(JToken.AsValue().AsInteger()), 'POS Entry should be created');
        Assert.AreEqual(0, POSEntry."Amount Incl. Tax & Round", 'Balanced exchange should have zero rounded total');

        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSEntryPaymentLine.IsEmpty(), 'Balanced exchange should not require a POS Entry payment line');

        POSEntrySalesLine.SetCurrentKey("POS Entry No.", "Line No.");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'POS Entry sales line should be created');
        Assert.AreEqual(SaleLineId, POSEntrySalesLine.SystemId, 'First POS Entry sales line should preserve the first API sale line ID');

        AssertBillingEvent(
            POSEntry.SystemId,
            Enum::"NPR Billing Event Type"::RETAIL_SELFSERVICE_ORDERS_COUNT,
            1);
        AssertAmountBillingEvent(
            POSEntrySalesLine.SystemId,
            Enum::"NPR Billing Event Type"::RETAIL_SELFSERVICE_ORDERS_AMOUNT_LCY,
            POSEntry."Amount Incl. Tax & Round");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_EFTPayment_StoresMetadata()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        EFTReceiptArray: JsonArray;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
    begin
        // [SCENARIO] EFT payment stores metadata in EFT Transaction Request and receipt lines in EFT Receipt
        Initialize();

        // [GIVEN] A new sale with item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Add EFT payment with metadata
        Clear(Body);
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', _Item."Unit Price");
        Body.Add('maskedCardNo', '************1234');
        Body.Add('pspReference', 'PSP-REF-12345');
        Body.Add('parToken', 'PAR-TOKEN-ABCDEF');
        Body.Add('success', true);
        EFTReceiptArray.Add('CARD PAYMENT');
        EFTReceiptArray.Add('Amount: 100.00');
        EFTReceiptArray.Add('Auth Code: 123456');
        Body.Add('eftReceipt', EFTReceiptArray);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment line should succeed');

        // [WHEN] Complete the sale
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');

        // [THEN] EFT Transaction Request is created with correct metadata
        EFTTransactionRequest.SetRange("Register No.", _POSUnit."No.");
        EFTTransactionRequest.SetRange("Card Number", '************1234');
        Assert.IsTrue(EFTTransactionRequest.FindFirst(), 'EFT Transaction Request should be created');
        Assert.AreEqual('PSP-REF-12345', EFTTransactionRequest."PSP Reference", 'PSP Reference should match');
        Assert.AreEqual('PAR-TOKEN-ABCDEF', EFTTransactionRequest."External Payment Token", 'PAR Token should match');
        Assert.IsTrue(EFTTransactionRequest.Successful, 'Transaction should be marked as successful');

        // [THEN] EFT Receipt lines are created
        EFTReceipt.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        Assert.AreEqual(3, EFTReceipt.Count(), 'Should have 3 EFT receipt lines');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLineOperations_AddUpdateDelete_PricesCorrect()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId1: Guid;
        SaleLineId2: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        TotalAmount: Decimal;
    begin
        // [SCENARIO] Sale line operations (add, update quantity, delete) calculate prices correctly
        Initialize();

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId1 := CreateGuid();
        SaleLineId2 := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add first line with quantity 2
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 2);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId1), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create first sale line should succeed');

        // [WHEN] Add second line
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item2."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId2), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create second sale line should succeed');

        // [THEN] Get sale and verify total (2*100 + 1*50 = 250)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Response should contain totalSalesAmountInclVat');
        TotalAmount := JToken.AsValue().AsDecimal();
        Assert.AreEqual(250, TotalAmount, 'Total should be 250 (2*100 + 1*50)');

        // [WHEN] Update first line to increase quantity to 3
        Clear(QueryParams);
        Clear(Body);
        Body.Add('quantity', 3);
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId1), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Update sale line should succeed');

        // [THEN] Get sale and verify total (3*100 + 1*50 = 350)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Response should contain totalSalesAmountInclVat');
        TotalAmount := JToken.AsValue().AsDecimal();
        Assert.AreEqual(350, TotalAmount, 'Total should be 350 (3*100 + 1*50)');

        // [WHEN] Delete second line
        Clear(QueryParams);
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('DELETE', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId2), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Delete sale line should succeed');

        // [THEN] Get sale and verify total (3*100 = 300)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Response should contain totalSalesAmountInclVat');
        TotalAmount := JToken.AsValue().AsDecimal();
        Assert.AreEqual(300, TotalAmount, 'Total should be 300 (3*100)');

        // [WHEN] Update first line to decrease quantity to 1
        Clear(QueryParams);
        Clear(Body);
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId1), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Update sale line should succeed');

        // [THEN] Get sale and verify total (1*100 = 100)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Response should contain totalSalesAmountInclVat');
        TotalAmount := JToken.AsValue().AsDecimal();
        Assert.AreEqual(100, TotalAmount, 'Total should be 100 (1*100)');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_EmptyVATBusPostGrPrice_PricesInclVAT_Failure()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemWithEmptyVATBusPG: Record Item;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Item with empty "VAT Bus. Posting Gr. (Price)" and Prices Including VAT=true cannot be sold
        // Items with Price Includes VAT=true must have VAT Bus. Posting Gr. (Price) filled
        Initialize();

        // [GIVEN] An item with Prices Including VAT=true but empty VAT Bus. Posting Gr. (Price)
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ItemWithEmptyVATBusPG, _POSUnit, _POSStore);
        ItemWithEmptyVATBusPG."Unit Price" := 100;
        ItemWithEmptyVATBusPG."Price Includes VAT" := true;
        ItemWithEmptyVATBusPG."VAT Bus. Posting Gr. (Price)" := '';
        ItemWithEmptyVATBusPG.Modify();

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add a sale line with item that has empty VAT Bus. Posting Gr. (Price)
        // [THEN] Error is thrown because VAT Bus. Posting Gr. (Price) is required when Price Includes VAT=true
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', ItemWithEmptyVATBusPG."No.");
        Body.Add('quantity', 1);
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.ExpectedError('VAT Bus. Posting Gr. (Price) must have a value');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceAlways_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Always uses addon's defined price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Always and Unit Price = 15
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::Always, 15);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon via separate endpoint
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should be created successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        // [THEN] Verify addon has correct price (15, not 25 from item)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(15, AddonUnitPrice, 'Addon should use defined price (15), not item price (25)');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line in sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceNonZero_WithPrice_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Non-Zero and non-zero price uses addon's price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Non-Zero and Unit Price = 10
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::"Non-Zero", 10);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should be created with price 10
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(10, AddonUnitPrice, 'Addon should use defined price (10)');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_UseUnitPriceNonZero_ZeroPrice_UsesItemPrice()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundAddon: Boolean;
        AddonUnitPrice: Decimal;
    begin
        // [SCENARIO] Addon with Use Unit Price = Non-Zero and zero price uses item's price
        InitializeAddon();

        // [GIVEN] An addon line with Use Unit Price = Non-Zero and Unit Price = 0
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::"Non-Zero", 0);

        // [GIVEN] A new sale with parent item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create parent sale line should succeed');

        // [WHEN] Add addon
        Clear(Body);
        Body.Add('lineId', FormatGuid(AddonLineId));
        Body.Add('parentLineId', FormatGuid(SaleLineId));
        Body.Add('addonNo', _ItemAddon."No.");
        Body.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId) + '/addon', Body, QueryParams, Headers);

        // [THEN] Addon should use item price (25) since addon price is 0
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create addon line should succeed');

        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                FoundAddon := true;
                SaleLineObj.Get('unitPrice', JToken);
                AddonUnitPrice := JToken.AsValue().AsDecimal();
                Assert.AreEqual(25, AddonUnitPrice, 'Addon should use item price (25) when addon price is 0');
            end;
        end;
        Assert.IsTrue(FoundAddon, 'Should find addon line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddon_ParentEmptyVATBusPostGrPrice_Failure()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        ParentItemWithEmptyVAT: Record Item;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Parent item with empty VAT Bus. Posting Gr. (Price) and Prices Including VAT=true cannot be sold
        // Items with Price Includes VAT=true must have VAT Bus. Posting Gr. (Price) filled
        Initialize();

        // [GIVEN] A parent item with empty VAT Bus. Posting Gr. (Price) and Prices Including VAT=true
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(ParentItemWithEmptyVAT, _POSUnit, _POSStore);
        ParentItemWithEmptyVAT."Unit Price" := 100;
        ParentItemWithEmptyVAT."Price Includes VAT" := true;
        ParentItemWithEmptyVAT."VAT Bus. Posting Gr. (Price)" := '';
        ParentItemWithEmptyVAT.Modify();

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add parent item with empty VAT Bus. Posting Gr. (Price)
        // [THEN] Error is thrown because VAT Bus. Posting Gr. (Price) is required when Price Includes VAT=true
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', ParentItemWithEmptyVAT."No.");
        Body.Add('quantity', 1);
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.ExpectedError('VAT Bus. Posting Gr. (Price) must have a value');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleLine_WithAddonsArray_MultipleAddons_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        AddonsArray: JsonArray;
        Addon1: JsonObject;
        Addon2: JsonObject;
        ItemAddOnLine1: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLine2: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId1: Guid;
        AddonLineId2: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        AddonCount: Integer;
    begin
        // [SCENARIO] Multiple addons can be inserted in same request as parent line
        InitializeAddon();

        // [GIVEN] Two addon lines with different prices
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine1, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine1."Use Unit Price"::Always, 15);
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine2, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine2."Use Unit Price"::Always, 10);

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId1 := CreateGuid();
        AddonLineId2 := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add parent line with addons array
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);

        Addon1.Add('lineId', FormatGuid(AddonLineId1));
        Addon1.Add('addonNo', _ItemAddon."No.");
        Addon1.Add('addonLineNo', Format(ItemAddOnLine1."Line No."));
        Addon1.Add('quantity', 1);
        AddonsArray.Add(Addon1);

        Addon2.Add('lineId', FormatGuid(AddonLineId2));
        Addon2.Add('addonNo', _ItemAddon."No.");
        Addon2.Add('addonLineNo', Format(ItemAddOnLine2."Line No."));
        Addon2.Add('quantity', 2);
        AddonsArray.Add(Addon2);

        Body.Add('addons', AddonsArray);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);

        // [THEN] Sale line with addons should be created
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line with addons array should succeed');

        // [THEN] Verify 3 lines total (1 parent + 2 addons)
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        Assert.AreEqual(3, SaleLinesArray.Count(), 'Should have 3 sale lines (1 parent + 2 addons)');

        // Count addon lines
        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then
                AddonCount += 1;
        end;
        Assert.AreEqual(2, AddonCount, 'Should have 2 addon lines');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantMenu_ItemStatus_ReturnsInJSON()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        MenuCategory: Record "NPR NPRE Menu Category";
        MenuItem: Record "NPR NPRE Menu Item";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        MenuContent: JsonObject;
        CategoriesArray: JsonArray;
        CategoryToken: JsonToken;
        CategoryObj: JsonObject;
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        StatusText: Text;
    begin
        // [SCENARIO] Menu item status enum value is returned in JSON response
        InitializeMenu();

        // [GIVEN] Menu has a category with an item set to Inactive Visible
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'STATUS');
        LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'STATUS', _Item."No.");
        MenuItem.Status := MenuItem.Status::"Inactive Visible";
        MenuItem.Modify();

        // [WHEN] Get menu
        Response := LibraryNPRetailAPI.CallApi('GET',
            '/restaurant/' + Format(Restaurant.SystemId, 0, 4).ToLower() + '/menu/' + Format(_Menu.SystemId, 0, 4).ToLower(),
            Body, QueryParams, Headers);

        // [THEN] Menu should be returned successfully
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        // [THEN] Find the item in the STATUS category and verify status
        Assert.IsTrue(ResponseBody.Get('menuContent', JToken), 'Response should have menuContent');
        MenuContent := JToken.AsObject();
        Assert.IsTrue(MenuContent.Get('categories', JToken), 'menuContent should have categories');
        CategoriesArray := JToken.AsArray();

        // Find our STATUS category
        CategoriesArray.Get(CategoriesArray.Count() - 1, CategoryToken);
        CategoryObj := CategoryToken.AsObject();
        Assert.IsTrue(CategoryObj.Get('items', JToken), 'Category should have items');
        ItemsArray := JToken.AsArray();
        ItemsArray.Get(0, ItemToken);
        ItemObj := ItemToken.AsObject();

        // [THEN] Item should have status = "Inactive Visible"
        Assert.IsTrue(ItemObj.Get('status', JToken), 'Item should have status property');
        StatusText := JToken.AsValue().AsText();
        Assert.AreEqual('Inactive Visible', StatusText, 'Item status should be Inactive Visible');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantMenu_LastUpdated_UpdatedOnChildChange()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        MenuCategory: Record "NPR NPRE Menu Category";
        MenuItem: Record "NPR NPRE Menu Item";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        Menu: Record "NPR NPRE Menu";
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        LastUpdatedText: Text;
        LastUpdatedBeforeCategoryInsert: DateTime;
        LastUpdatedAfterCategoryInsert: DateTime;
    begin
        // [SCENARIO] Menu's lastUpdated is refreshed when child records are inserted and appears in API responses
        InitializeMenu();

        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        // [GIVEN] Capture current lastUpdated before changes
        Menu.Get(Restaurant.Code, _Menu.Code);
        LastUpdatedBeforeCategoryInsert := Menu."Last Updated";

        // [WHEN] A menu category is created (triggers subscriber)
        Sleep(100);
        LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'UPDATED');
        Commit();

        // [THEN] Menu's Last Updated should be refreshed
        Menu.Get(Restaurant.Code, _Menu.Code);
        Assert.AreNotEqual(0DT, Menu."Last Updated", 'Last Updated should be set after category insert');
        Assert.IsTrue(Menu."Last Updated" >= LastUpdatedBeforeCategoryInsert,
            'Last Updated should be refreshed after category insert');
        LastUpdatedAfterCategoryInsert := Menu."Last Updated";

        // [WHEN] A menu item is created under the category
        Sleep(100);
        LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'UPDATED', _Item."No.");
        Commit();

        // [THEN] Last Updated should be refreshed again
        Menu.Get(Restaurant.Code, _Menu.Code);
        Assert.IsTrue(Menu."Last Updated" >= LastUpdatedAfterCategoryInsert,
            'Last Updated should be refreshed after item insert');

        // [THEN] lastUpdated appears in get menu response
        Response := LibraryNPRetailAPI.CallApi('GET',
            '/restaurant/' + Format(Restaurant.SystemId, 0, 4).ToLower() + '/menu/' + Format(_Menu.SystemId, 0, 4).ToLower(),
            Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('lastUpdated', JToken), 'Menu should have lastUpdated');
        LastUpdatedText := JToken.AsValue().AsText();
        Assert.AreNotEqual('', LastUpdatedText, 'lastUpdated should not be empty in get menu response');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantMenu_WithItemsAndAddons_ReturnsStructure()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        MenuCategory: Record "NPR NPRE Menu Category";
        MenuItem: Record "NPR NPRE Menu Item";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        MenuContent: JsonObject;
        CategoriesArray: JsonArray;
        CategoryToken: JsonToken;
        CategoryObj: JsonObject;
        ItemsArray: JsonArray;
        ItemToken: JsonToken;
        ItemObj: JsonObject;
        AddonItemsArray: JsonArray;
    begin
        // [SCENARIO] Menu endpoint returns items with their addons
        InitializeMenu();

        // [GIVEN] Menu has a category with an item that has addons
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        LibraryRestaurant.CreateMenuCategory(MenuCategory, Restaurant.Code, _Menu.Code, 'MAIN');
        LibraryRestaurant.CreateMenuItem(MenuItem, Restaurant.Code, _Menu.Code, 'MAIN', _Item."No.");

        // Ensure addon line exists
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::Always, 20);

        // [WHEN] Get menu
        Response := LibraryNPRetailAPI.CallApi('GET',
            '/restaurant/' + Format(Restaurant.SystemId, 0, 4).ToLower() + '/menu/' + Format(_Menu.SystemId, 0, 4).ToLower(),
            Body, QueryParams, Headers);

        // [THEN] Menu should be returned with structure
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        // [THEN] Should have menuContent with categories
        Assert.IsTrue(ResponseBody.Get('menuContent', JToken), 'Response should have menuContent');
        MenuContent := JToken.AsObject();

        Assert.IsTrue(MenuContent.Get('categories', JToken), 'menuContent should have categories');
        CategoriesArray := JToken.AsArray();
        Assert.IsTrue(CategoriesArray.Count() > 0, 'Should have at least one category');

        // [THEN] Category should have items
        CategoriesArray.Get(0, CategoryToken);
        CategoryObj := CategoryToken.AsObject();
        Assert.IsTrue(CategoryObj.Get('items', JToken), 'Category should have items');
        ItemsArray := JToken.AsArray();
        Assert.IsTrue(ItemsArray.Count() > 0, 'Should have at least one item');

        // [THEN] Item should have addonItems array
        ItemsArray.Get(0, ItemToken);
        ItemObj := ItemToken.AsObject();
        Assert.IsTrue(ItemObj.Get('addonItems', JToken), 'Item should have addonItems');
        AddonItemsArray := JToken.AsArray();
        Assert.IsTrue(AddonItemsArray.Count() > 0, 'Should have at least one addon');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaiterPad_FlowStatusCopying_SendsToKitchen()
    var
        Assert: Codeunit Assert;
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        CustomerDetails: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Flow statuses should be copied from item routing profile to waiter pad line
        // and allow sending to kitchen
        InitializeRestaurant();

        // [GIVEN] A POS Sale with an item line
        POSSale.Init();
        POSSale."Register No." := _POSUnit."No.";
        POSSale."Sales Ticket No." := 'TEST001';
        POSSale."POS Store Code" := _POSStore.Code;
        POSSale.Date := Today;
        POSSale.Insert(true);

        POSSaleLine.Init();
        POSSaleLine."Register No." := POSSale."Register No.";
        POSSaleLine."Sales Ticket No." := POSSale."Sales Ticket No.";
        POSSaleLine."Line No." := 10000;
        POSSaleLine."Line Type" := POSSaleLine."Line Type"::Item;
        POSSaleLine."No." := _Item."No.";
        POSSaleLine.Description := _Item.Description;
        POSSaleLine.Quantity := 1;
        POSSaleLine."Quantity (Base)" := 1;
        POSSaleLine."Unit Price" := _Item."Unit Price";
        POSSaleLine."Amount Including VAT" := _Item."Unit Price";
        POSSaleLine.Insert(true);

        // [GIVEN] A waiter pad linked to the seating
        WaiterPadMgt.CreateNewWaiterPad(_Seating.Code, 1, '', CustomerDetails, WaiterPad);
        POSSale."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        POSSale."NPRE Pre-Set Seating Code" := _Seating.Code;
        POSSale.Modify();

        // [WHEN] Sale lines are moved to waiter pad
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(POSSale, WaiterPad, false);
        Commit();

        // [THEN] Waiter pad line should be created with flow statuses
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Item);
        Assert.IsTrue(WaiterPadLine.FindFirst(), 'Waiter pad line should be created');

        AssignedFlowStatus.SetRange("Table No.", DATABASE::"NPR NPRE Waiter Pad Line");
        AssignedFlowStatus.SetRange("Record ID", WaiterPadLine.RecordId);
        AssignedFlowStatus.SetRange("Flow Status Object", AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow);
        Assert.AreEqual(3, AssignedFlowStatus.Count(), 'Waiter pad line should have 3 flow statuses');

        // [THEN] Kitchen order can be sent without error
        RestaurantPrint.PrintWaiterPadPreOrderToKitchenPressed(WaiterPad, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaiterPad_DeletePOSBilledLine_ReducesWaiterPadLineQtyToBilled()
    var
        Assert: Codeunit Assert;
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Record "NPR POS Sale";
        POSSaleLineToDelete: Record "NPR POS Sale Line";
        OrphanLineNo: Integer;
    begin
        // [SCENARIO] A partly billed waiter pad line, loaded to POS and then deleted on the POS,
        // must have its quantity reduced to the billed quantity when the sale is saved back.
        InitializeRestaurant();

        // [GIVEN] A waiter-pad-linked POS sale with two item lines, the first of them partly billed
        SetupWaiterPadLinkedSale(POSSale, WaiterPad, WaiterPadLine, POSSaleLineToDelete);
        OrphanLineNo := WaiterPadLine."Line No.";
        WaiterPadLine."Billed Quantity" := 1;
        WaiterPadLine.Modify();

        // [WHEN] The POS line is deleted and the sale is saved back to the waiter pad
        POSSaleLineToDelete.Delete(true);
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(POSSale, WaiterPad, false);

        // [THEN] The orphaned waiter pad line quantity is reduced to the billed quantity
        WaiterPadLine.Get(WaiterPad."No.", OrphanLineNo);
        Assert.AreEqual(1, WaiterPadLine.Quantity, 'Deleting the POS line should reduce the orphaned waiter pad line qty to its billed quantity');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaiterPad_DeleteKitchenSentPOSLine_ZeroesWaiterPadLineQty()
    var
        Assert: Codeunit Assert;
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Record "NPR POS Sale";
        POSSaleLineToDelete: Record "NPR POS Sale Line";
        OrphanLineNo: Integer;
    begin
        // [SCENARIO] A waiter pad line already sent to the kitchen, loaded to POS and then deleted on the
        // POS, must have its quantity zeroed when the sale is saved back (so the kitchen request is cancelled).
        InitializeRestaurant();

        // [GIVEN] A waiter-pad-linked POS sale with two item lines (the restaurant setup auto-sends lines to the kitchen)
        SetupWaiterPadLinkedSale(POSSale, WaiterPad, WaiterPadLine, POSSaleLineToDelete);
        OrphanLineNo := WaiterPadLine."Line No.";

        // [WHEN] The POS line is deleted and the sale is saved back to the waiter pad
        POSSaleLineToDelete.Delete(true);
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(POSSale, WaiterPad, false);

        // [THEN] The orphaned waiter pad line quantity is zeroed (nothing billed)
        WaiterPadLine.Get(WaiterPad."No.", OrphanLineNo);
        Assert.AreEqual(0, WaiterPadLine.Quantity, 'Deleting the kitchen-sent POS line should zero the orphaned waiter pad line qty');
    end;

    local procedure SetupWaiterPadLinkedSale(var POSSale: Record "NPR POS Sale"; var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLineToOrphan: Record "NPR NPRE Waiter Pad Line"; var POSSaleLineToDelete: Record "NPR POS Sale Line")
    var
        POSSaleLineToKeep: Record "NPR POS Sale Line";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        CustomerDetails: Dictionary of [Text, Text];
    begin
        // Creates a POS sale tied to a waiter pad with two item lines and moves it to the pad once,
        // so both waiter pad lines carry the "Sale Retail ID"/"Sale Line Retail ID" links a real
        // load-to-POS would set. Returns the waiter pad line linked to POSSaleLineToDelete; a second
        // line is kept so the sale is non-empty when it is later saved back.
        POSSale.Init();
        POSSale."Register No." := _POSUnit."No.";
        // Unique ticket per call so the two tests sharing this helper don't collide on committed data
        // when the whole codeunit runs in a single test-isolation session (MoveSaleFromPOSToWaiterPad commits).
        POSSale."Sales Ticket No." := CopyStr('WP' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(POSSale."Sales Ticket No."));
        POSSale."POS Store Code" := _POSStore.Code;
        POSSale.Date := Today;
        POSSale.Insert(true);

        InsertPOSItemSaleLine(POSSale, POSSaleLineToDelete, 10000, 3);
        InsertPOSItemSaleLine(POSSale, POSSaleLineToKeep, 20000, 1);

        WaiterPadMgt.CreateNewWaiterPad(_Seating.Code, 1, '', CustomerDetails, WaiterPad);
        POSSale."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        POSSale."NPRE Pre-Set Seating Code" := _Seating.Code;
        POSSale.Modify();

        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(POSSale, WaiterPad, false);
        Commit();

        WaiterPadLineToOrphan.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLineToOrphan.SetRange("Sale Line Retail ID", POSSaleLineToDelete.SystemId);
        WaiterPadLineToOrphan.FindFirst();
    end;

    local procedure InsertPOSItemSaleLine(POSSale: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; LineNo: Integer; Qty: Decimal)
    begin
        SaleLinePOS.Init();
        SaleLinePOS."Register No." := POSSale."Register No.";
        SaleLinePOS."Sales Ticket No." := POSSale."Sales Ticket No.";
        SaleLinePOS."Line No." := LineNo;
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := _Item."No.";
        SaleLinePOS.Description := _Item.Description;
        SaleLinePOS.Quantity := Qty;
        SaleLinePOS."Quantity (Base)" := Qty;
        SaleLinePOS."Unit Price" := _Item."Unit Price";
        SaleLinePOS."Amount Including VAT" := _Item."Unit Price" * Qty;
        SaleLinePOS.Insert(true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_WithKitchenRequest_TransfersCustomerDetails()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        RestaurantWebhookTestSub: Codeunit "NPR Restaurant Webhook TestSub";
        Response: JsonObject;
        Body: JsonObject;
        KitchenRequest: JsonObject;
        CustomerDetails: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        KitchenOrderNoText: Text;
        KitchenOrderNo: BigInteger;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
    begin
        // [SCENARIO] Complete sale with kitchenRequest transfers customer details to kitchen order
        InitializeRestaurant();

        // Debug assertions to verify restaurant setup
        VerifyRestaurantSetupForKitchenOrders();

        // [GIVEN] A new sale with item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [GIVEN] Webhook subscriber is bound
        RestaurantWebhookTestSub.Reset();
        BindSubscription(RestaurantWebhookTestSub);

        // [WHEN] Complete with kitchenRequest containing customer details
        Clear(Body);
        CustomerDetails.Add('name', 'John Doe');
        CustomerDetails.Add('phoneNo', '+1234567890');
        CustomerDetails.Add('email', 'john@example.com');
        KitchenRequest.Add('seatingCode', _Seating.Code);
        KitchenRequest.Add('noOfGuests', 2);
        KitchenRequest.Add('customerDetails', CustomerDetails);
        Body.Add('kitchenRequest', KitchenRequest);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale with kitchen request should succeed');

        // [THEN] Response contains kitchenOrderNo
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('entryNo', JToken), 'Response should contain entryNo');
        POSEntry.Get(JToken.AsValue().AsInteger());
        POSEntrySalesLine.SetCurrentKey("POS Entry No.", "Line No.");
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.IsTrue(POSEntrySalesLine.FindFirst(), 'POS Entry sales line should be created');
        Assert.AreEqual(SaleLineId, POSEntrySalesLine.SystemId, 'First POS Entry sales line should preserve the API sale line ID');

        AssertBillingEvent(
            POSEntry.SystemId,
            Enum::"NPR Billing Event Type"::HOSPITALITY_SELFSERVICE_ORDERS_COUNT,
            1);
        AssertAmountBillingEvent(
            POSEntrySalesLine.SystemId,
            Enum::"NPR Billing Event Type"::HOSPITALITY_SELFSERVICE_ORDERS_AMOUNT_LCY,
            POSEntry."Amount Incl. Tax & Round");

        Assert.IsTrue(ResponseBody.Get('kitchenOrderNo', JToken), 'Response should contain kitchenOrderNo');
        KitchenOrderNoText := JToken.AsValue().AsText();
        Evaluate(KitchenOrderNo, KitchenOrderNoText);
        Assert.AreNotEqual(0, KitchenOrderNo, 'Kitchen order number should not be 0');

        // [THEN] Waiter pad has customer details
        WaiterPad.SetCurrentKey(SystemCreatedAt);
        WaiterPad.Ascending(false);
        WaiterPad.SetRange("Customer Phone No.", '+1234567890');
        Assert.IsTrue(WaiterPad.FindFirst(), 'Waiter pad should be created');
        Assert.AreEqual('John Doe', WaiterPad.Description, 'Waiter pad description should have customer name');
        Assert.AreEqual('+1234567890', WaiterPad."Customer Phone No.", 'Waiter pad should have phone number');
        Assert.AreEqual('john@example.com', WaiterPad."Customer E-Mail", 'Waiter pad should have email');
        Assert.AreEqual(2, WaiterPad."Number of Guests", 'Waiter pad should have correct number of guests');

        // [WHEN] Kitchen order is finished (marked as served)
        LibraryRestaurant.FinishKitchenOrder(KitchenOrderNo);

        // [THEN] Webhook should have been invoked
        Assert.IsTrue(RestaurantWebhookTestSub.WasWebhookInvoked(), 'Webhook should be invoked when kitchen order is ready for serving');
        Assert.AreEqual(KitchenOrderNo, RestaurantWebhookTestSub.GetLastKitchenOrderId(), 'Webhook should receive correct kitchen order ID');

        UnbindSubscription(RestaurantWebhookTestSub);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CompleteSale_KitchenRequest_MissingSeatingCode_ReturnsError()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        KitchenRequest: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Complete sale with kitchenRequest missing seatingCode returns error
        InitializeRestaurant();

        // [GIVEN] A sale with item and payment
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // [WHEN] Complete with kitchenRequest but without seatingCode
        Clear(Body);
        KitchenRequest.Add('noOfGuests', 2);
        // Note: seatingCode is intentionally omitted
        Body.Add('kitchenRequest', KitchenRequest);

        // [THEN] Should throw error due to missing seatingCode
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.ExpectedError('Missing required field: seatingCode');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_DuplicateId_ShouldFail()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Creating a sale with an already-used ID should fail
        Initialize();

        // [GIVEN] A sale is created with a specific ID
        SaleId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'First create sale should succeed');

        // [WHEN] Try to create another sale with the same ID
        Clear(Body);

        // [THEN] Should fail with duplicate ID error
        asserterror Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.ExpectedError('System ID');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_NonUnattendedUnit_ShouldFail()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        NonUnattendedUnit: Record "NPR POS Unit";
        POSPostingProfile: Record "NPR POS Posting Profile";
        UserSetup: Record "User Setup";
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Creating a sale when the API user's User Setup points at a non-UNATTENDED POS unit should fail
        Initialize();

        // [GIVEN] A non-UNATTENDED (MPOS) POS Unit assigned to the API user in User Setup
        POSPostingProfile.FindFirst();
        NPRLibraryPOSMasterData.CreatePOSUnit(NonUnattendedUnit, _POSStore.Code, POSPostingProfile.Code);
        NonUnattendedUnit."POS Type" := NonUnattendedUnit."POS Type"::MPOS;
        NonUnattendedUnit.Status := NonUnattendedUnit.Status::OPEN;
        NonUnattendedUnit.Modify();
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := NonUnattendedUnit."No.";
        UserSetup.Modify();
        Commit();

        // [WHEN] Create a sale (unit resolved from User Setup)
        SaleId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [CLEANUP] Restore User Setup before asserting so later test methods are unaffected
        UserSetup.Get(UserId);
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();
        Commit();

        // [THEN] 400, because the User Setup POS Unit is not UNATTENDED
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Non-UNATTENDED unit should return 400');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddonLine_NegativeQuantity_ForIngredientRemoval_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        AddonsArray: JsonArray;
        AddonObj: JsonObject;
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        SaleId: Guid;
        SaleLineId: Guid;
        AddonLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleLinesArray: JsonArray;
        SaleLineToken: JsonToken;
        SaleLineObj: JsonObject;
        i: Integer;
        FoundNegativeAddon: Boolean;
        AddonQuantity: Decimal;
    begin
        // [SCENARIO] Negative quantity on addon is allowed for ingredient removal (e.g., "no onions")
        InitializeAddon();

        // [GIVEN] An addon line configured for ingredient removal
        LibraryRestaurant.CreateItemAddonLine(ItemAddOnLine, _ItemAddon."No.", _AddonItem."No.",
            ItemAddOnLine."Use Unit Price"::Always, 0); // Zero price for removal

        // [GIVEN] A new sale
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        AddonLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // [WHEN] Add parent item with an addon that has negative quantity (ingredient removal)
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);

        AddonObj.Add('lineId', FormatGuid(AddonLineId));
        AddonObj.Add('addonNo', _ItemAddon."No.");
        AddonObj.Add('addonLineNo', Format(ItemAddOnLine."Line No."));
        AddonObj.Add('quantity', -1); // Negative quantity for removal
        AddonsArray.Add(AddonObj);
        Body.Add('addons', AddonsArray);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);

        // [THEN] Should succeed - negative quantity is valid for ingredient removal
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line with negative addon should succeed');

        // [THEN] Verify the addon has negative quantity
        QueryParams.Add('withLines', 'true');
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get sale should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('saleLines', JToken);
        SaleLinesArray := JToken.AsArray();

        for i := 0 to SaleLinesArray.Count() - 1 do begin
            SaleLinesArray.Get(i, SaleLineToken);
            SaleLineObj := SaleLineToken.AsObject();
            if SaleLineObj.Get('isAddon', JToken) and JToken.AsValue().AsBoolean() then begin
                SaleLineObj.Get('quantity', JToken);
                AddonQuantity := JToken.AsValue().AsDecimal();
                if AddonQuantity < 0 then
                    FoundNegativeAddon := true;
            end;
        end;
        Assert.IsTrue(FoundNegativeAddon, 'Should have addon with negative quantity for ingredient removal');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteSale_WithSaleLines_Success()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] Cancelling a sale with sale lines should succeed
        Initialize();

        // [GIVEN] A sale with item lines
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 2);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Delete the sale
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('DELETE', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);

        // [THEN] Should succeed
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Delete sale with sale lines should succeed');

        // [THEN] Sale should no longer exist
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(Response.Get('statusCode', JToken), 'Response should contain statusCode');
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(404, StatusCode, 'Sale should not be found after deletion');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeleteSale_WithEFTPayment_ShouldFail()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Cancelling a sale with an EFT (approved) payment line should fail
        Initialize();

        // [GIVEN] A sale with an item and an approved EFT payment
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [GIVEN] An EFT payment is added (simulating approved card payment)
        Clear(Body);
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', _Item."Unit Price");
        Body.Add('maskedCardNo', '************1234');
        Body.Add('pspReference', 'PSP-REF-TEST');
        Body.Add('success', true);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment line should succeed');

        // [WHEN] Try to delete the sale
        Clear(Body);

        // [THEN] Should fail - cannot cancel sale with approved EFT payment
        asserterror Response := LibraryNPRetailAPI.CallApi('DELETE', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.ExpectedError('Cannot delete externally approved electronic funds transfer');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EFTPayment_BINMapping_MapsToCorrectPaymentMethod()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        // [SCENARIO] EFT payment with a VISA BIN maps to the VISA payment method via BIN range matching
        InitializeEFTMapping();

        // [GIVEN] A sale with an item
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // [WHEN] Add EFT payment with a masked VISA card number (BIN 411111 falls in 400000-499999)
        Clear(Body);
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', _Item."Unit Price");
        Body.Add('maskedCardNo', '411111******1234');
        Body.Add('pspReference', 'PSP-BIN-TEST');
        Body.Add('success', true);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment should succeed');

        // [THEN] EFT Transaction Request should be remapped from generic EFT to VISA payment method
        EFTTransactionRequest.SetRange("Register No.", _POSUnit."No.");
        EFTTransactionRequest.SetRange("Card Number", '411111******1234');
        Assert.IsTrue(EFTTransactionRequest.FindFirst(), 'EFT Transaction Request should exist');
        Assert.AreEqual(_EFTPaymentMethod.Code, EFTTransactionRequest."Original POS Payment Type Code",
            'Original payment type should be the generic EFT method');
        Assert.AreEqual(_VisaPaymentMethod.Code, EFTTransactionRequest."POS Payment Type Code",
            'Payment type should be remapped to VISA');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CleanupJob_UnpaidSales_AreDeleted()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        POSSale: Record "NPR POS Sale";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] Cleanup job deletes unpaid abandoned sales from UNATTENDED POS units
        Initialize();

        // [GIVEN] A sale with an item line but no payment (abandoned)
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');
        Commit();

        // [GIVEN] WorkDate is set 2 days ahead so the sale falls before the cutoff
        OriginalWorkDate := WorkDate();
        WorkDate(CalcDate('<+2D>', OriginalWorkDate));

        // [WHEN] Run cleanup job
        RunCleanupJob();

        // [THEN] Sale should be deleted
        Assert.IsFalse(POSSale.GetBySystemId(SaleId), 'POS Sale should be deleted by cleanup job');

        // [THEN] Sale should NOT be parked (no EFT payment)
        POSSavedSaleEntry.SetRange(SystemId, SaleId);
        Assert.IsTrue(POSSavedSaleEntry.IsEmpty(), 'Sale without EFT should not be parked');

        // Restore WorkDate
        WorkDate(OriginalWorkDate);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CleanupJob_PaidEFTSales_AreParked()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        POSSale: Record "NPR POS Sale";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
        OriginalWorkDate: Date;
    begin
        // [SCENARIO] Cleanup job parks abandoned sales that have EFT payments instead of deleting them
        Initialize();

        // [GIVEN] A sale with an item and an approved EFT payment (abandoned after payment)
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        Clear(Body);
        Body.Add('paymentMethodCode', _EFTPaymentMethod.Code);
        Body.Add('paymentType', 'EFT');
        Body.Add('amount', _Item."Unit Price");
        Body.Add('maskedCardNo', '************5678');
        Body.Add('pspReference', 'PSP-REF-CLEANUP-TEST');
        Body.Add('success', true);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create EFT payment line should succeed');
        Commit();

        // [GIVEN] WorkDate is set 2 days ahead so the sale falls before the cutoff
        OriginalWorkDate := WorkDate();
        WorkDate(CalcDate('<+2D>', OriginalWorkDate));

        // [WHEN] Run cleanup job
        RunCleanupJob();

        // [THEN] Sale should be removed from active POS Sales
        Assert.IsFalse(POSSale.GetBySystemId(SaleId), 'POS Sale should no longer exist as active sale');

        // [THEN] Sale should be parked in POS Saved Sale Entry (the SystemId is preserved by CreateSavedSaleEntry)
        Assert.IsTrue(POSSavedSaleEntry.GetBySystemId(SaleId), 'Sale with EFT should be parked in Saved Sale Entry');

        // [THEN] Saved sale should have lines
        POSSavedSaleLine.SetRange("Quote Entry No.", POSSavedSaleEntry."Entry No.");
        Assert.IsTrue(POSSavedSaleLine.Count() >= 2, 'Parked sale should have at least 2 lines (item + payment)');

        // Restore WorkDate
        WorkDate(OriginalWorkDate);
    end;

    local procedure RunCleanupJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        CleanupDeadPOSSales: Codeunit "NPR JQ Cleanup Dead POS Sales";
    begin
        JobQueueEntry.Init();
        CleanupDeadPOSSales.Run(JobQueueEntry);
    end;

    local procedure CreateCleanupJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR JQ Cleanup Dead POS Sales");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR JQ Cleanup Dead POS Sales";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(true);
    end;

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibrarySales: Codeunit "Library - Sales";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        UserSetup: Record "User Setup";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API POS');
        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Restaurant');

        NPRLibraryPOSMasterData.CreatePOSSetup(POSSetup);
        NPRLibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        NPRLibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        NPRLibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);

        _POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
        _POSUnit.Modify();

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
        _Item."Unit Price" := 100;
        _Item.Modify();

        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item2, _POSUnit, _POSStore);
        _Item2."Unit Price" := 50;
        _Item2.Modify();

        _CashPaymentMethod.SetRange("Processing Type", _CashPaymentMethod."Processing Type"::CASH);
        _CashPaymentMethod.FindFirst();

        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_EFTPaymentMethod, _EFTPaymentMethod."Processing Type"::EFT, '', false);

        LibrarySales.CreateSalesperson(_Salesperson);

        CreateCleanupJobQueueEntry();

        _Initialized := true;
        Commit();
    end;

    local procedure InitializeRestaurant()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        Initialize();

        if _RestaurantInitialized then
            exit;

        LibraryRestaurant.SetupRestaurantForKitchenOrders(_POSUnit, _Seating);
        LibraryRestaurant.SetupItemForKitchenOrders(_Item);

        _RestaurantInitialized := true;
        Commit();
    end;

    local procedure InitializeAddon()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        Initialize();

        if _AddonInitialized then
            exit;

        // Create addon item
        NPRLibraryPOSMasterData.CreateItemForPOSSaleUsage(_AddonItem, _POSUnit, _POSStore);
        _AddonItem."Unit Price" := 25;
        _AddonItem.Modify();

        // Create item addon and link to main item
        LibraryRestaurant.CreateItemAddon(_ItemAddon);
        LibraryRestaurant.LinkItemToAddon(_Item, _ItemAddon."No.");

        _AddonInitialized := true;
        Commit();
    end;

    local procedure VerifyRestaurantSetupForKitchenOrders()
    var
        Assert: Codeunit Assert;
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
        FlowStatus: Record "NPR NPRE Flow Status";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Restaurant: Record "NPR NPRE Restaurant";
    begin
        // Verify Restaurant Setup
        RestaurantSetup.Get();
        Assert.AreEqual(
            RestaurantSetup."Serving Step Discovery Method"::"Item Routing Profiles",
            RestaurantSetup."Serving Step Discovery Method",
            StrSubstNo('Restaurant Setup should use Item Routing Profiles discovery method, but has %1', RestaurantSetup."Serving Step Discovery Method"));
        Assert.IsTrue(RestaurantSetup."KDS Active", 'Restaurant Setup KDS Active should be true');

        // Verify Item has routing profile
        Item.Get(_Item."No.");
        Assert.AreNotEqual('', Item."NPR NPRE Item Routing Profile",
            StrSubstNo('Item %1 should have a routing profile assigned', Item."No."));

        // Verify routing profile exists
        Assert.IsTrue(ItemRoutingProfile.Get(Item."NPR NPRE Item Routing Profile"),
            StrSubstNo('Item Routing Profile %1 should exist', Item."NPR NPRE Item Routing Profile"));

        // Verify flow statuses are assigned to the routing profile
        AssignedFlowStatus.SetRange("Table No.", DATABASE::"NPR NPRE Item Routing Profile");
        AssignedFlowStatus.SetRange("Record ID", ItemRoutingProfile.RecordId);
        AssignedFlowStatus.SetRange("Flow Status Object", AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow);
        Assert.IsFalse(AssignedFlowStatus.IsEmpty(),
            StrSubstNo('Item Routing Profile %1 should have flow statuses assigned', ItemRoutingProfile.Code));

        // Verify meal flow statuses exist
        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPadLineMealFlow);
        Assert.IsFalse(FlowStatus.IsEmpty(), 'Meal flow statuses should exist in the database');

        // Verify seating links to a restaurant with KDS active
        SeatingLocation.Get(_Seating."Seating Location");
        Restaurant.Get(SeatingLocation."Restaurant Code");
        Assert.AreEqual(Restaurant."KDS Active"::Yes, Restaurant."KDS Active",
            StrSubstNo('Restaurant %1 should have KDS Active = Yes', Restaurant.Code));
    end;

    local procedure InitializeMenu()
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
    begin
        InitializeRestaurant();
        InitializeAddon();

        if _MenuInitialized then
            exit;

        // Get the restaurant from the POS unit's profile
        POSRestProfile.Get(_POSUnit."POS Restaurant Profile");
        Restaurant.Get(POSRestProfile."Restaurant Code");

        // Create menu and category
        LibraryRestaurant.CreateMenu(_Menu, Restaurant.Code);

        // Setup user's POS unit for menu pricing
        LibraryRestaurant.SetupUserPOSUnit(_POSUnit."No.");

        _MenuInitialized := true;
        Commit();
    end;

    local procedure InitializeEFTMapping()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryEFT: Codeunit "NPR Library - EFT";
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINRange: Record "NPR EFT BIN Range";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        Initialize();

        if _EFTMappingInitialized then
            exit;

        EFTBINGroupPaymentLink.DeleteAll();
        EFTBINRange.DeleteAll();
        EFTBINGroup.DeleteAll();

        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_VisaPaymentMethod, _VisaPaymentMethod."Processing Type"::EFT, '', false);
        NPRLibraryPOSMasterData.CreatePOSPaymentMethod(_MastercardPaymentMethod, _MastercardPaymentMethod."Processing Type"::EFT, '', false);

        LibraryEFT.CreateBINGroup(EFTBINGroup, 'VISA', 'Visa', 1);
        LibraryEFT.CreateBINRange('VISA', 400000, 499999);
        LibraryEFT.CreateBINGroupPaymentLink('VISA', _VisaPaymentMethod.Code);

        LibraryEFT.CreateBINGroup(EFTBINGroup, 'MC', 'Mastercard', 2);
        LibraryEFT.CreateBINRange('MC', 510000, 559999);
        LibraryEFT.CreateBINGroupPaymentLink('MC', _MastercardPaymentMethod.Code);

        _EFTMappingInitialized := true;
        Commit();
    end;

    local procedure AssertBillingEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; ExpectedQuantity: Decimal)
    var
        Assert: Codeunit Assert;
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.SetRange("Event ID", EventId);
        Assert.IsTrue(
            BillingQueueEntry.FindFirst(),
            StrSubstNo('Billing event %1 with ID %2 should be registered.', EventType, Format(EventId, 0, 4)));
        Assert.AreEqual(EventType.AsInteger(), BillingQueueEntry."Feature ID", 'Billing event type should match');
        Assert.AreEqual(ExpectedQuantity, BillingQueueEntry.Quantity, 'Billing event quantity should match');
    end;

    local procedure AssertAmountBillingEvent(EventId: Guid; EventType: Enum "NPR Billing Event Type"; ExpectedQuantity: Decimal)
    var
        Assert: Codeunit Assert;
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MetadataJson: JsonObject;
        CurrencyToken: JsonToken;
    begin
        AssertBillingEvent(EventId, EventType, ExpectedQuantity);

        BillingQueueEntry.SetRange("Event ID", EventId);
        BillingQueueEntry.FindFirst();
        Assert.IsTrue(MetadataJson.ReadFrom(BillingQueueEntry.GetMetadata()), 'Billing event metadata should be valid JSON');
        Assert.IsTrue(MetadataJson.Get('currency', CurrencyToken), 'Amount billing event metadata should contain currency');

        GeneralLedgerSetup.Get();
        Assert.AreEqual(GeneralLedgerSetup."LCY Code", CurrencyToken.AsValue().AsText(), 'Amount billing event currency should match LCY');
    end;

    local procedure AssertBillingEventNotRegistered(EventId: Guid)
    var
        Assert: Codeunit Assert;
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.SetRange("Event ID", EventId);
        Assert.IsTrue(
            BillingQueueEntry.IsEmpty(),
            StrSubstNo('Billing event with ID %1 should not be registered.', Format(EventId, 0, 4)));
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif

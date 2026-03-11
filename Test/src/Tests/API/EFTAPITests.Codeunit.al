#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85169 "NPR EFT API Tests"
{
    // [FEATURE] EFT API end-to-end tests (Adyen Cloud integration)

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;
        _CashPaymentMethod: Record "NPR POS Payment Method";
        _EFTPaymentMethodCode: Code[10];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrepareEFT_NonExistentSale_ReturnsNotFound()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        FakeSaleId: Guid;
    begin
        // [SCENARIO] Prepare EFT for non-existent sale returns 404
        Initialize();

        // [GIVEN] A non-existent sale ID
        FakeSaleId := CreateGuid();

        // [WHEN] POST /pos/sale/:saleId/eft/prepare
        Body.Add('amount', 100.00);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(FakeSaleId) + '/eft/prepare', Body, QueryParams, Headers);

        // [THEN] Should return not found
        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Non-existent sale should return error');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrepareEFT_ValidInputs_ReturnsTransactionId()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleId: Guid;
    begin
        // [SCENARIO] Prepare EFT with valid inputs returns transaction ID and status
        Initialize();

        // [GIVEN] A sale with line items
        SaleId := CreateTestSale();

        // [WHEN] POST /pos/sale/:saleId/eft/prepare
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare EFT should succeed');

        // [THEN] Response should contain transactionId and status
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.IsTrue(ResponseBody.Get('transactionId', JToken), 'Should have transactionId');
        Assert.AreNotEqual('', JToken.AsValue().AsText(), 'transactionId should not be empty');

        Assert.IsTrue(ResponseBody.Get('status', JToken), 'Should have status');
        Assert.AreEqual('Prepared', JToken.AsValue().AsText(), 'Status should be Prepared');

        // [THEN] Response should NOT contain deprecated fields
        Assert.IsFalse(ResponseBody.Get('transactionToken', JToken), 'Should not have transactionToken (deprecated)');
        Assert.IsFalse(ResponseBody.Get('externalTransactionId', JToken), 'Should not have externalTransactionId (removed)');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrepareEFT_NoAmount_UsesRemainingBalance()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleId: Guid;
    begin
        // [SCENARIO] Prepare EFT without amount uses sale remaining balance
        Initialize();

        // [GIVEN] A sale with line items
        SaleId := CreateTestSale();

        // [WHEN] POST /pos/sale/:saleId/eft/prepare without amount
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare EFT without amount should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('transactionId', JToken), 'Should have transactionId');
        Assert.IsTrue(ResponseBody.Get('status', JToken), 'Should have status');
        Assert.AreEqual('Prepared', JToken.AsValue().AsText(), 'Status should be Prepared');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PollEFTStatus_AfterPrepare_ReturnsPrepared()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        PrepareResponse: JsonObject;
        PollResponse: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleId: Guid;
        TransactionId: Text;
    begin
        // [SCENARIO] Polling a freshly prepared transaction returns Prepared status
        Initialize();

        // [GIVEN] A prepared EFT transaction
        SaleId := CreateTestSale();

        Body.Add('amount', _Item."Unit Price");
        PrepareResponse := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(PrepareResponse), 'Prepare should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(PrepareResponse);
        ResponseBody.Get('transactionId', JToken);
        TransactionId := JToken.AsValue().AsText();

        // [WHEN] GET /pos/sale/:saleId/eft/:transactionId/cloud/status
        Clear(Body);
        Clear(QueryParams);
        PollResponse := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);

        // [THEN] Should return OK with Prepared status
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(PollResponse), 'Poll should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(PollResponse);

        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Prepared', JToken.AsValue().AsText(), 'Status should be Prepared');

        ResponseBody.Get('successful', JToken);
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'Successful should be false for Prepared status');

        ResponseBody.Get('transactionId', JToken);
        Assert.AreEqual(TransactionId, JToken.AsValue().AsText(), 'TransactionId should match');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PollEFTStatus_InvalidId_ReturnsNotFound()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        FakeId: Guid;
    begin
        // [SCENARIO] Polling with non-existent transactionId returns 404
        Initialize();

        // [GIVEN] A sale and a non-existent transaction ID
        SaleId := CreateTestSale();
        FakeId := CreateGuid();

        // [WHEN] GET /pos/sale/:saleId/eft/:transactionId/cloud/status
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + FormatGuid(FakeId) + '/cloud/status', Body, QueryParams, Headers);

        // [THEN] Should return not found
        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Non-existent transactionId should return error');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StartEFT_InvalidId_ReturnsNotFound()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        FakeId: Guid;
    begin
        // [SCENARIO] Starting payment with non-existent transactionId returns 404
        Initialize();

        // [GIVEN] A sale and a non-existent transaction ID
        SaleId := CreateTestSale();
        FakeId := CreateGuid();

        // [WHEN] POST /pos/sale/:saleId/eft/:transactionId/cloud/start
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + FormatGuid(FakeId) + '/cloud/start', Body, QueryParams, Headers);

        // [THEN] Should return not found
        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Non-existent transactionId should return error');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelEFT_InvalidId_ReturnsNotFound()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        FakeId: Guid;
    begin
        // [SCENARIO] Cancelling with non-existent transactionId returns 404
        Initialize();

        // [GIVEN] A sale and a non-existent transaction ID
        SaleId := CreateTestSale();
        FakeId := CreateGuid();

        // [WHEN] POST /pos/sale/:saleId/eft/:transactionId/cloud/cancel
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + FormatGuid(FakeId) + '/cloud/cancel', Body, QueryParams, Headers);

        // [THEN] Should return not found
        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Non-existent transactionId should return error');
    end;

    #region Print API Tests

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrintSalesReceipt_PrinterNameOutput_ReturnsPrintJob()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        PrintsArray: JsonArray;
        PrintJob: JsonObject;
        POSEntry: Record "NPR POS Entry";
        EntryId: Text;
    begin
        // [SCENARIO] Print sales receipt via API with Printer Name output returns a windows_spooler print job
        Initialize();

        // [GIVEN] A completed sale that produced a POS Entry
        POSEntry := CreateCompletedSaleEntry();
        EntryId := Format(POSEntry.SystemId, 0, 4).ToLower();

        // [GIVEN] Report Selection for "Sales Receipt (POS Entry)" pointing to StaticSalesReceipt codeunit
        CleanupReportSelection(Enum::"NPR Report Selection Type"::"Sales Receipt (POS Entry)");
        SetupReportSelection(
            Enum::"NPR Report Selection Type"::"Sales Receipt (POS Entry)",
            '10',
            Codeunit::"NPR Static Sales Receipt",
            false);

        // [GIVEN] Object Output Selection for the codeunit with Printer Name output
        SetupObjectOutputSelection(
            Codeunit::"NPR Static Sales Receipt",
            Enum::"NPR Object Output Type"::"Printer Name",
            'TestPrinter01');
        Commit();

        // [WHEN] GET /pos/entry/:entryId/print/salesreceipt
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/entry/' + EntryId + '/print/salesreceipt', Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Print sales receipt should succeed');

        // [THEN] Response should contain entryId and prints array
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('entryId', JToken), 'Response should contain entryId');
        Assert.AreEqual(EntryId, JToken.AsValue().AsText(), 'entryId should match');

        Assert.IsTrue(ResponseBody.Get('prints', JToken), 'Response should contain prints');
        PrintsArray := JToken.AsArray();
        Assert.IsTrue(PrintsArray.Count() >= 1, 'prints array should have at least 1 entry');

        // [THEN] First print job should have type=windows_spooler, printerName=TestPrinter01, non-empty printJob
        PrintsArray.Get(0, JToken);
        PrintJob := JToken.AsObject();

        PrintJob.Get('type', JToken);
        Assert.AreEqual('windows_spooler', JToken.AsValue().AsText(), 'Print type should be windows_spooler');

        PrintJob.Get('printerName', JToken);
        Assert.AreEqual('TestPrinter01', JToken.AsValue().AsText(), 'Printer name should match');

        PrintJob.Get('printJob', JToken);
        Assert.AreNotEqual('', JToken.AsValue().AsText(), 'printJob should not be empty');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrintTerminalReceipt_HTTPOutput_ReturnsPrintJob()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        PrintsArray: JsonArray;
        PrintJob: JsonObject;
        POSEntry: Record "NPR POS Entry";
        EntryId: Text;
    begin
        // [SCENARIO] Print terminal receipt via API with HTTP output returns an http print job
        Initialize();

        // [GIVEN] A completed sale with EFT transaction data
        POSEntry := CreateCompletedSaleEntry();
        CreateEFTReceiptData(POSEntry);
        EntryId := Format(POSEntry.SystemId, 0, 4).ToLower();

        // [GIVEN] Report Selection for "Terminal Receipt" pointing to StaticEFTReceipt codeunit
        CleanupReportSelection(Enum::"NPR Report Selection Type"::"Terminal Receipt");
        SetupReportSelection(
            Enum::"NPR Report Selection Type"::"Terminal Receipt",
            '10',
            Codeunit::"NPR Static EFT Receipt",
            false);

        // [GIVEN] Object Output Selection for the codeunit with HTTP output
        SetupObjectOutputSelection(
            Codeunit::"NPR Static EFT Receipt",
            Enum::"NPR Object Output Type"::HTTP,
            'http://localhost:8080');
        Commit();

        // [WHEN] GET /pos/entry/:entryId/print/terminalreceipt
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/entry/' + EntryId + '/print/terminalreceipt', Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Print terminal receipt should succeed');

        // [THEN] Response should contain prints array with http type
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('prints', JToken), 'Response should contain prints');
        PrintsArray := JToken.AsArray();
        Assert.IsTrue(PrintsArray.Count() >= 1, 'prints array should have at least 1 entry');

        PrintsArray.Get(0, JToken);
        PrintJob := JToken.AsObject();

        PrintJob.Get('type', JToken);
        Assert.AreEqual('http', JToken.AsValue().AsText(), 'Print type should be http');

        PrintJob.Get('url', JToken);
        Assert.IsTrue(JToken.AsValue().AsText().StartsWith('http://localhost:8080'), 'URL should start with configured output path');

        PrintJob.Get('printJob', JToken);
        Assert.AreNotEqual('', JToken.AsValue().AsText(), 'printJob should not be empty');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrintSalesReceipt_MultiLine_ThreeReportSelections_ReturnsThreePrints()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        PrintsArray: JsonArray;
        POSEntry: Record "NPR POS Entry";
        EntryId: Text;
    begin
        // [SCENARIO] Multi-line report selection: 3 mandatory report selection lines = 3 print jobs returned
        Initialize();

        // [GIVEN] A completed sale that produced a POS Entry
        POSEntry := CreateCompletedSaleEntry();
        EntryId := Format(POSEntry.SystemId, 0, 4).ToLower();

        // [GIVEN] 3 mandatory report selection lines for sales receipt
        CleanupReportSelection(Enum::"NPR Report Selection Type"::"Sales Receipt (POS Entry)");
        SetupReportSelection(
            Enum::"NPR Report Selection Type"::"Sales Receipt (POS Entry)",
            '10',
            Codeunit::"NPR Static Sales Receipt",
            false);
        SetupReportSelection(
            Enum::"NPR Report Selection Type"::"Sales Receipt (POS Entry)",
            '20',
            Codeunit::"NPR Static Sales Receipt",
            false);
        SetupReportSelection(
            Enum::"NPR Report Selection Type"::"Sales Receipt (POS Entry)",
            '30',
            Codeunit::"NPR Static Sales Receipt",
            false);

        // [GIVEN] Object Output Selection for the codeunit
        SetupObjectOutputSelection(
            Codeunit::"NPR Static Sales Receipt",
            Enum::"NPR Object Output Type"::"Printer Name",
            'TestPrinter01');
        Commit();

        // [WHEN] GET /pos/entry/:entryId/print/salesreceipt
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/entry/' + EntryId + '/print/salesreceipt', Body, QueryParams, Headers);

        // [THEN] Should return OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Print multi-line sales receipt should succeed');

        // [THEN] prints array should contain exactly 3 entries (optional line skipped)
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('prints', JToken), 'Response should contain prints');
        PrintsArray := JToken.AsArray();
        Assert.AreEqual(3, PrintsArray.Count(), 'Should have exactly 3 prints from 3 report selection lines');
    end;

    #endregion

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        SSProfile: Record "NPR SS Profile";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        UserSetup: Record "User Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Seating: Record "NPR NPRE Seating";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API POS');

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

        _CashPaymentMethod.SetRange("Processing Type", _CashPaymentMethod."Processing Type"::CASH);
        _CashPaymentMethod.FindFirst();

        // Find or create an EFT payment method for selfservice card payments
        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::EFT);
        if POSPaymentMethod.FindFirst() then
            _EFTPaymentMethodCode := POSPaymentMethod.Code
        else
            _EFTPaymentMethodCode := _CashPaymentMethod.Code;

        // Setup restaurant (needed for kitchen orders, not for EFT payment method resolution)
        LibraryRestaurant.SetupRestaurantForKitchenOrders(_POSUnit, Seating);
        LibraryRestaurant.SetupItemForKitchenOrders(_Item);

        // Setup Self Service Profile with EFT payment method and link to POS Unit
        SSProfile.Init();
        SSProfile.Code := 'EFT-TEST';
        SSProfile.Description := 'EFT API Test Profile';
        SSProfile."Selfservice Card Payment Meth." := _EFTPaymentMethodCode;
        if not SSProfile.Insert() then
            SSProfile.Modify();

        _POSUnit."POS Self Service Profile" := SSProfile.Code;
        _POSUnit.Modify();

        // Create EFT Setup for Adyen Cloud
        EFTSetup.Init();
        EFTSetup."Payment Type POS" := _EFTPaymentMethodCode;
        EFTSetup."POS Unit No." := _POSUnit."No.";
        EFTSetup."EFT Integration Type" := EFTAdyenIntegration.CloudIntegrationType();
        if not EFTSetup.Insert() then
            EFTSetup.Modify();

        CreateCleanupJobQueueEntry();

        _Initialized := true;
        Commit();
    end;

    local procedure CreateTestSale() SaleId: Guid
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleLineId: Guid;
    begin
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();

        // Create sale
        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // Add sale line
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');
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

    local procedure CleanupReportSelection(ReportType: Enum "NPR Report Selection Type")
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        ReportSelectionRetail.SetRange("Report Type", ReportType);
        ReportSelectionRetail.DeleteAll();
    end;

    local procedure CreateCompletedSaleEntry() POSEntry: Record "NPR POS Entry"
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleId: Guid;
        SaleLineId: Guid;
        PaymentLineId: Guid;
        DocumentNo: Text;
    begin
        SaleId := CreateGuid();
        SaleLineId := CreateGuid();
        PaymentLineId := CreateGuid();

        // Create sale
        Body.Add('posUnit', _POSUnit."No.");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // Add sale line
        Clear(Body);
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(SaleLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale line should succeed');

        // Add cash payment line
        Clear(Body);
        Body.Add('paymentMethodCode', _CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(PaymentLineId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create payment line should succeed');

        // Complete sale
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');

        // Get the POS Entry from the response documentNo
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('documentNo', JToken), 'Response should contain documentNo');
        DocumentNo := JToken.AsValue().AsText();

        POSEntry.SetRange("Document No.", DocumentNo);
        Assert.IsTrue(POSEntry.FindFirst(), 'POS Entry should exist for completed sale');
    end;

    local procedure CreateEFTReceiptData(POSEntry: Record "NPR POS Entry")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
    begin
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Entry No." := 0;
        EFTTransactionRequest."Register No." := POSEntry."POS Unit No.";
        EFTTransactionRequest."Sales Ticket No." := POSEntry."Document No.";
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Insert();

        EFTReceipt.Init();
        EFTReceipt."Register No." := POSEntry."POS Unit No.";
        EFTReceipt."Sales Ticket No." := POSEntry."Document No.";
        EFTReceipt."EFT Trans. Request Entry No." := EFTTransactionRequest."Entry No.";
        EFTReceipt."Entry No." := 1;
        EFTReceipt.Type := 0;
        EFTReceipt.Text := 'CARD PAYMENT TEST';
        EFTReceipt.Insert();
    end;

    local procedure SetupReportSelection(ReportType: Enum "NPR Report Selection Type"; SequenceCode: Code[10]; CodeunitId: Integer; IsOptional: Boolean)
    var
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        if not ReportSelectionRetail.Get(ReportType, SequenceCode) then begin
            ReportSelectionRetail.Init();
            ReportSelectionRetail."Report Type" := ReportType;
            ReportSelectionRetail.Sequence := SequenceCode;
            ReportSelectionRetail.Insert();
        end;
        ReportSelectionRetail."Codeunit ID" := CodeunitId;
        ReportSelectionRetail.Optional := IsOptional;
        ReportSelectionRetail.Modify();
    end;

    local procedure SetupObjectOutputSelection(CodeunitId: Integer; OutputType: Enum "NPR Object Output Type"; OutputPath: Text[250])
    var
        ObjectOutputSelection: Record "NPR Object Output Selection";
    begin
        if not ObjectOutputSelection.Get(UserId, ObjectOutputSelection."Object Type"::Codeunit, CodeunitId, '') then begin
            ObjectOutputSelection.Init();
            ObjectOutputSelection."User ID" := CopyStr(UserId, 1, MaxStrLen(ObjectOutputSelection."User ID"));
            ObjectOutputSelection."Object Type" := ObjectOutputSelection."Object Type"::Codeunit;
            ObjectOutputSelection."Object ID" := CodeunitId;
            ObjectOutputSelection."Print Template" := '';
            ObjectOutputSelection.Insert();
        end;
        ObjectOutputSelection."Output Type" := OutputType;
        ObjectOutputSelection."Output Path" := OutputPath;
        ObjectOutputSelection.Modify();
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;

    // E2E tests using [HttpClientHandler] - requires test app target = OnPrem

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockAdyenCloudResponse')]
    procedure EFT_E2E_HappyPath_PrepareStartPollComplete()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSEntry: Record "NPR POS Entry";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleId: Guid;
        TransactionId: Text;
        TransactionGuid: Guid;
        DocumentNo: Text;
    begin
        // [SCENARIO] Full E2E: prepare -> start (mocked Adyen) -> poll (completed) -> complete sale -> verify POS Entry and EFT record
        Initialize();
        InitializeAdyenPaymentTypeSetup();

        // [GIVEN] A sale with one item line (100.00)
        SaleId := CreateTestSale();

        // [WHEN] POST /pos/sale/:saleId/eft/prepare
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);

        // [THEN] Prepare returns OK with transactionId and status=Prepared
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.IsTrue(ResponseBody.Get('transactionId', JToken), 'Prepare should return transactionId');
        TransactionId := JToken.AsValue().AsText();
        Assert.AreNotEqual('', TransactionId, 'transactionId should not be empty');

        Assert.IsTrue(ResponseBody.Get('status', JToken), 'Prepare should return status');
        Assert.AreEqual('Prepared', JToken.AsValue().AsText(), 'Status should be Prepared after prepare');

        // [WHEN] POST /pos/sale/:saleId/eft/:transactionId/cloud/start (HTTP call mocked by MockAdyenCloudResponse)
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);

        // [THEN] Start returns OK with processed=true
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.IsTrue(ResponseBody.Get('transactionId', JToken), 'Start should return transactionId');
        Assert.AreEqual(TransactionId, JToken.AsValue().AsText(), 'Start transactionId should match');

        Assert.IsTrue(ResponseBody.Get('processed', JToken), 'Start should return processed');
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'processed should be true');

        // [WHEN] GET /pos/sale/:saleId/eft/:transactionId/cloud/status
        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);

        // [THEN] Poll returns Completed with card details and paymentDelta
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.IsTrue(ResponseBody.Get('status', JToken), 'Poll should return status');
        Assert.AreEqual('Completed', JToken.AsValue().AsText(), 'Status should be Completed after successful start');

        Assert.IsTrue(ResponseBody.Get('successful', JToken), 'Poll should return successful');
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'successful should be true');

        Assert.IsTrue(ResponseBody.Get('resultCode', JToken), 'Poll should return resultCode');
        Assert.IsTrue(ResponseBody.Get('cardNumber', JToken), 'Poll should return cardNumber');
        Assert.IsTrue(ResponseBody.Get('authorizationNumber', JToken), 'Poll should return authorizationNumber');

        // [THEN] Successful poll should include standard delta fields
        VerifyEFTDeltaFields(ResponseBody, _Item."Unit Price");

        // [WHEN] POST /pos/sale/:saleId/complete (EFT payment line was created by ProcessResponse)
        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);

        // [THEN] Complete returns OK with documentNo and POS Entry exists
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed after EFT payment');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.IsTrue(ResponseBody.Get('documentNo', JToken), 'Complete should return documentNo');
        DocumentNo := JToken.AsValue().AsText();
        Assert.AreNotEqual('', DocumentNo, 'documentNo should not be empty');

        POSEntry.SetRange("Document No.", DocumentNo);
        Assert.IsTrue(POSEntry.FindFirst(), 'POS Entry should exist for completed sale');

        // [THEN] EFT Transaction Request lifecycle is correct
        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsTrue(EFTTransactionRequest.Started <> 0DT, 'EFT Started timestamp should be set');
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'External Result Known should be true');
        Assert.IsTrue(EFTTransactionRequest.Successful, 'EFT Transaction should be marked Successful');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockAdyenCloudResponse')]
    procedure EFT_LoggingEnabled_RequestAndResponseLogged()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionLog: Record "NPR EFT Transaction Log";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleId: Guid;
        TransactionId: Text;
        TransactionGuid: Guid;
        LogInStream: InStream;
        LogContent: Text;
    begin
        // [SCENARIO] With Adyen log level = FULL, the /cloud/start endpoint creates log entries with request/response data
        Initialize();
        InitializeAdyenPaymentTypeSetup();
        SetAdyenLogLevel(1); // FULL

        // [GIVEN] A sale with one item line
        SaleId := CreateTestSale();

        // [GIVEN] A prepared EFT transaction
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('transactionId', JToken);
        TransactionId := JToken.AsValue().AsText();

        // [WHEN] POST /pos/sale/:saleId/eft/:transactionId/cloud/start (mocked)
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed');

        // [THEN] EFT Transaction Log entries exist for this transaction
        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);

        EFTTransactionLog.SetRange("Transaction Entry No.", EFTTransactionRequest."Entry No.");
        Assert.IsTrue(EFTTransactionLog.FindFirst(), 'At least one log entry should exist after start');
        Assert.IsTrue(EFTTransactionLog.Count() >= 1, 'Should have at least 1 log entry when log level is FULL');

        // [THEN] Log BLOB contains the request/response text
        EFTTransactionLog.CalcFields(Log);
        if EFTTransactionLog.Log.HasValue() then begin
            EFTTransactionLog.Log.CreateInStream(LogInStream);
            LogInStream.Read(LogContent);
            Assert.AreNotEqual('', LogContent, 'Log BLOB content should not be empty when Log Level is FULL');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockAdyenCloudDeclinedResponse')]
    procedure EFT_E2E_FailedPayment_StatusReturnsFailed()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        SaleId: Guid;
        TransactionId: Text;
        TransactionGuid: Guid;
    begin
        // [SCENARIO] Full E2E: prepare -> start (mocked declined) -> poll (failed) -> verify no paymentDelta
        Initialize();
        InitializeAdyenPaymentTypeSetup();

        // [GIVEN] A sale with one item line (100.00)
        SaleId := CreateTestSale();

        // [WHEN] POST /pos/sale/:saleId/eft/prepare
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);

        // [THEN] Prepare returns OK
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('transactionId', JToken), 'Prepare should return transactionId');
        TransactionId := JToken.AsValue().AsText();

        // [WHEN] POST /pos/sale/:saleId/eft/:transactionId/cloud/start (mocked declined Adyen response)
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);

        // [THEN] Start still returns OK with processed=true (HTTP call itself succeeded)
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed even for declined');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('processed', JToken), 'Start should return processed');
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'processed should be true');

        // [WHEN] GET /pos/sale/:saleId/eft/:transactionId/cloud/status
        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);

        // [THEN] Poll returns Failed status
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.IsTrue(ResponseBody.Get('status', JToken), 'Poll should return status');
        Assert.AreEqual('Failed', JToken.AsValue().AsText(), 'Status should be Failed after declined payment');

        Assert.IsTrue(ResponseBody.Get('successful', JToken), 'Poll should return successful');
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'successful should be false for declined payment');

        Assert.IsTrue(ResponseBody.Get('resultCode', JToken), 'Failed poll should include resultCode');
        Assert.IsTrue(ResponseBody.Get('resultMessage', JToken), 'Failed poll should include resultMessage');

        // [THEN] Failed payment must NOT include delta fields
        Assert.IsFalse(ResponseBody.Contains('refreshedSaleLines'), 'Failed payment should NOT include refreshedSaleLines');
        Assert.IsFalse(ResponseBody.Contains('refreshedPaymentLines'), 'Failed payment should NOT include refreshedPaymentLines');
        Assert.IsFalse(ResponseBody.Contains('totalSalesAmountInclVat'), 'Failed payment should NOT include totalSalesAmountInclVat');

        // [THEN] EFT Transaction Request reflects declined state
        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'External Result Known should be true (result is known: declined)');
        Assert.IsFalse(EFTTransactionRequest.Successful, 'EFT Transaction should NOT be marked Successful');
    end;

    [HttpClientHandler]
    procedure MockAdyenCloudResponse(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        ServiceID: Text;
    begin
        // TestHttpRequestMessage doesn't expose Content (MS security restriction),
        // so we read the ServiceID from the EFT Transaction Request record instead.
        // The Adyen integration sets "Reference Number Input" = Format("Entry No.") before making the HTTP call.
        ServiceID := GetServiceIDFromLatestEFTRequest();
        Response.Content.WriteFrom(GetMockAdyenPaymentResponse(ServiceID));
        Response.HttpStatusCode := 200;
        Response.ReasonPhrase := 'OK';
        exit(false);
    end;

    [HttpClientHandler]
    procedure MockAdyenCloudDeclinedResponse(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        ServiceID: Text;
    begin
        ServiceID := GetServiceIDFromLatestEFTRequest();
        Response.Content.WriteFrom(GetMockAdyenDeclinedResponse(ServiceID));
        Response.HttpStatusCode := 200;
        Response.ReasonPhrase := 'OK';
        exit(false);
    end;

    local procedure GetServiceIDFromLatestEFTRequest(): Text
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Register No.", _POSUnit."No.");
        EFTTransactionRequest.FindLast();
        exit(EFTTransactionRequest."Reference Number Input");
    end;

    local procedure GetMockAdyenPaymentResponse(ServiceID: Text): Text
    var
        ResponseJson: TextBuilder;
    begin
        ResponseJson.Append('{');
        ResponseJson.Append('"SaleToPOIResponse":{');
        ResponseJson.Append('"MessageHeader":{');
        ResponseJson.Append('"POIID":"TEST-TERMINAL",');
        ResponseJson.Append('"ServiceID":"' + ServiceID + '",');
        ResponseJson.Append('"MessageCategory":"Payment",');
        ResponseJson.Append('"MessageType":"Response",');
        ResponseJson.Append('"MessageClass":"Service"');
        ResponseJson.Append('},');
        ResponseJson.Append('"PaymentResponse":{');
        ResponseJson.Append('"Response":{');
        ResponseJson.Append('"Result":"Success",');
        ResponseJson.Append('"AdditionalResponse":"aid=A0000000031010&cardType=visa"');
        ResponseJson.Append('},');
        ResponseJson.Append('"PaymentResult":{');
        ResponseJson.Append('"PaymentInstrumentData":{');
        ResponseJson.Append('"PaymentInstrumentType":"Card",');
        ResponseJson.Append('"CardData":{');
        ResponseJson.Append('"MaskedPan":"************1111"');
        ResponseJson.Append('}');
        ResponseJson.Append('},');
        ResponseJson.Append('"PaymentAcquirerData":{');
        ResponseJson.Append('"AcquirerID":"TestAcquirer",');
        ResponseJson.Append('"ApprovalCode":"123456",');
        ResponseJson.Append('"AcquirerPOIID":"TEST"');
        ResponseJson.Append('},');
        ResponseJson.Append('"AmountsResp":{');
        ResponseJson.Append('"AuthorizedAmount":100.00,');
        ResponseJson.Append('"Currency":"USD"');
        ResponseJson.Append('}');
        ResponseJson.Append('},');
        ResponseJson.Append('"POIData":{');
        ResponseJson.Append('"POITransactionID":{');
        ResponseJson.Append('"TransactionID":"TXN-TEST-001",');
        ResponseJson.Append('"TimeStamp":"2024-01-15T14:32:00+00:00"');
        ResponseJson.Append('},');
        ResponseJson.Append('"POIReconciliationID":"RECON-12345"');
        ResponseJson.Append('}');
        ResponseJson.Append('}');
        ResponseJson.Append('}');
        ResponseJson.Append('}');
        exit(ResponseJson.ToText());
    end;

    local procedure GetMockAdyenDeclinedResponse(ServiceID: Text): Text
    var
        ResponseJson: TextBuilder;
    begin
        ResponseJson.Append('{');
        ResponseJson.Append('"SaleToPOIResponse":{');
        ResponseJson.Append('"MessageHeader":{');
        ResponseJson.Append('"POIID":"TEST-TERMINAL",');
        ResponseJson.Append('"ServiceID":"' + ServiceID + '",');
        ResponseJson.Append('"MessageCategory":"Payment",');
        ResponseJson.Append('"MessageType":"Response",');
        ResponseJson.Append('"MessageClass":"Service"');
        ResponseJson.Append('},');
        ResponseJson.Append('"PaymentResponse":{');
        ResponseJson.Append('"Response":{');
        ResponseJson.Append('"Result":"Failure",');
        ResponseJson.Append('"ErrorCondition":"Refusal",');
        ResponseJson.Append('"AdditionalResponse":"message=DECLINED"');
        ResponseJson.Append('},');
        ResponseJson.Append('"PaymentResult":{');
        ResponseJson.Append('"PaymentInstrumentData":{');
        ResponseJson.Append('"PaymentInstrumentType":"Card",');
        ResponseJson.Append('"CardData":{');
        ResponseJson.Append('"MaskedPan":"************9999"');
        ResponseJson.Append('}');
        ResponseJson.Append('},');
        ResponseJson.Append('"AmountsResp":{');
        ResponseJson.Append('"AuthorizedAmount":0,');
        ResponseJson.Append('"Currency":"USD"');
        ResponseJson.Append('}');
        ResponseJson.Append('},');
        ResponseJson.Append('"POIData":{');
        ResponseJson.Append('"POITransactionID":{');
        ResponseJson.Append('"TransactionID":"TXN-DECLINED-001",');
        ResponseJson.Append('"TimeStamp":"2024-01-15T14:32:00+00:00"');
        ResponseJson.Append('}');
        ResponseJson.Append('}');
        ResponseJson.Append('}');
        ResponseJson.Append('}');
        ResponseJson.Append('}');
        exit(ResponseJson.ToText());
    end;

    local procedure VerifyEFTDeltaFields(ResponseBody: JsonObject; ExpectedAmount: Decimal)
    var
        Assert: Codeunit Assert;
        JToken: JsonToken;
        PaymentLinesArray: JsonArray;
        PaymentLine: JsonObject;
    begin
        // refreshedSaleLines should be empty (EFT only adds payment lines)
        Assert.IsTrue(ResponseBody.Get('refreshedSaleLines', JToken), 'Should contain refreshedSaleLines');
        Assert.AreEqual(0, JToken.AsArray().Count(), 'refreshedSaleLines should be empty for EFT');

        // refreshedPaymentLines should contain the EFT payment line
        Assert.IsTrue(ResponseBody.Get('refreshedPaymentLines', JToken), 'Should contain refreshedPaymentLines');
        PaymentLinesArray := JToken.AsArray();
        Assert.IsTrue(PaymentLinesArray.Count() > 0, 'refreshedPaymentLines should have at least one line');

        // Verify payment line has expected fields (same shape as POSPaymentLineResponse)
        PaymentLinesArray.Get(0, JToken);
        PaymentLine := JToken.AsObject();
        Assert.IsTrue(PaymentLine.Contains('id'), 'Payment line should have id');
        Assert.IsTrue(PaymentLine.Contains('sortKey'), 'Payment line should have sortKey');
        Assert.IsTrue(PaymentLine.Contains('paymentMethodCode'), 'Payment line should have paymentMethodCode');
        Assert.IsTrue(PaymentLine.Contains('amountInclVat'), 'Payment line should have amountInclVat');

        // deletedSaleLines and deletedPaymentLines should be empty
        Assert.IsTrue(ResponseBody.Get('deletedSaleLines', JToken), 'Should contain deletedSaleLines');
        Assert.AreEqual(0, JToken.AsArray().Count(), 'deletedSaleLines should be empty');
        Assert.IsTrue(ResponseBody.Get('deletedPaymentLines', JToken), 'Should contain deletedPaymentLines');
        Assert.AreEqual(0, JToken.AsArray().Count(), 'deletedPaymentLines should be empty');

        // Totals should reflect the full sale state
        Assert.IsTrue(ResponseBody.Get('totalSalesAmountInclVat', JToken), 'Should contain totalSalesAmountInclVat');
        Assert.AreEqual(ExpectedAmount, JToken.AsValue().AsDecimal(), 'totalSalesAmountInclVat should equal item price');
        Assert.IsTrue(ResponseBody.Get('totalPaymentAmount', JToken), 'Should contain totalPaymentAmount');
        Assert.AreEqual(ExpectedAmount, JToken.AsValue().AsDecimal(), 'totalPaymentAmount should equal item price');
    end;

    local procedure InitializeAdyenPaymentTypeSetup()
    var
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        if not EFTAdyenPaymTypeSetup.Get(_EFTPaymentMethodCode) then begin
            EFTAdyenPaymTypeSetup.Init();
            EFTAdyenPaymTypeSetup."Payment Type POS" := _EFTPaymentMethodCode;
            EFTAdyenPaymTypeSetup.Insert();
        end;
        EFTAdyenPaymTypeSetup.Environment := EFTAdyenPaymTypeSetup.Environment::TEST;
        EFTAdyenPaymTypeSetup."Log Level" := EFTAdyenPaymTypeSetup."Log Level"::FULL;
        EFTAdyenPaymTypeSetup.SetAPIKey('test-api-key-for-mock');
        EFTAdyenPaymTypeSetup.Modify();
        Commit();
    end;

    local procedure SetAdyenLogLevel(LogLevel: Integer)
    var
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        if EFTAdyenPaymTypeSetup.Get(_EFTPaymentMethodCode) then begin
            EFTAdyenPaymTypeSetup."Log Level" := LogLevel;
            EFTAdyenPaymTypeSetup.Modify();
            Commit();
        end;
    end;
}
#endif

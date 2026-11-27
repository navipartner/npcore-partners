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
        _MockNETSTransactionBody: Text;
        _MockNETSTransactionStatusCode: Integer;
        _MockNETSVoidBody: Text;
        _MockNETSVoidStatusCode: Integer;
        _MockNETSRequests: List of [Text];
        _MockNETSLookupBody: Text;
        _MockNETSLookupStatusCode: Integer;
        _MockNETSReversalStatusAtVoid: Integer;
        _MockNETSFinishedAtVoid: Boolean;
        _LibraryFeatureFlags: Codeunit "NPR Library - Feature Flags";

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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Prepare_UnresolvedEarlierPayment_LookupDeclinedUnblocksTerminal()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        SaleId: Guid;
        TransactionId: Text;
        EntryNo: Integer;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EntryNo := StartNETSPaymentWithoutResult(SaleId, TransactionId);
        SetMockNETSLookupResponse(200, GetMockNETSLookupResponse(EntryNo, Format(EntryNo), 2));

        Response := PrepareOnNewSale();

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare should succeed once the lookup shows the earlier payment was declined');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Get, MockNETSLookupPath()), 'Prepare should look the earlier payment up before refusing');
        EFTTransactionRequest.Get(EntryNo);
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'The earlier payment should have a known result after the lookup');
        Assert.IsFalse(EFTTransactionRequest.Successful, 'The earlier payment should be recorded as declined');
        Assert.AreNearlyEqual(0, GetSalePaymentTotal(SaleId), 0.001, 'A declined payment must not pay the earlier sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Prepare_UnresolvedAttendedPayment_DoesNotBlockTerminal()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        SaleId: Guid;
        TransactionId: Text;
        EntryNo: Integer;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EntryNo := StartNETSPaymentWithoutResult(SaleId, TransactionId);
        SetMockNETSLookupResponse(200, GetMockNETSLookupResponse(EntryNo));
        SetSelfService(EntryNo, false);

        Response := PrepareOnNewSale();

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'An unresolved attended payment on the terminal must not block self-service payments, since staff cannot resolve it from the self-service actions');
        Assert.IsFalse(MockNETSRequestWasSent(HttpRequestType::Get, MockNETSLookupPath()), 'Prepare must not look an attended payment up');
        EFTTransactionRequest.Get(EntryNo);
        Assert.IsFalse(EFTTransactionRequest."External Result Known", 'The attended payment must be left untouched');

        SetSelfService(EntryNo, true);
        ResolveTransactionAsStaff(TransactionId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler')]
    procedure NETS_Prepare_UnresolvedEarlierPayment_LookupApprovedIsVoided()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        SaleId: Guid;
        TransactionId: Text;
        EntryNo: Integer;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EntryNo := StartNETSPaymentWithoutResult(SaleId, TransactionId);
        SetMockNETSLookupResponse(200, GetMockNETSLookupResponse(EntryNo));

        Response := PrepareOnNewSale();

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare should succeed once the recovered payment has been voided');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Get, MockNETSLookupPath()), 'Prepare should look the earlier payment up before refusing');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Delete, MockNETSLookupPath()), 'An approved payment recovered on an unfinished self-service sale should be voided');
        EFTTransactionRequest.Get(EntryNo);
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'The earlier payment should have a known result after the lookup');
        Assert.IsTrue(EFTTransactionRequest.Successful, 'The earlier payment should be recorded as approved');
        Assert.IsTrue(EFTTransactionRequest.Reversed, 'The recovered payment should be reversed');
        Assert.AreEqual(EFTTransactionRequest."Selfservice Reversal Status"::Reversed, EFTTransactionRequest."Selfservice Reversal Status", 'Reversal status should be Reversed');
        Assert.AreNearlyEqual(0, GetSalePaymentTotal(SaleId), 0.001, 'The void should cancel the recovered payment line on the earlier sale');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Resolve_LookUpForOtherOrder_StaysBlocked()
    var
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIEFTNETSResolve: Codeunit "NPR API EFT NETS Resolve";
        Response: JsonObject;
        SaleId: Guid;
        TransactionId: Text;
        EntryNo: Integer;
        ResultMessage: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EntryNo := StartNETSPaymentWithoutResult(SaleId, TransactionId);
        SetMockNETSLookupResponse(200, GetMockNETSLookupResponse(EntryNo, Format(EntryNo + 1)));

        EFTTransactionRequest.Get(EntryNo);
        ResultMessage := APIEFTNETSResolve.LookUp(EFTTransactionRequest);

        Assert.IsTrue(ResultMessage.Contains('not this one'), StrSubstNo('Staff should be told the terminal reports another transaction, got: %1', ResultMessage));
        AssertEFTLogContains(EntryNo, 'API Resolve (Other Transaction)', '"orderId":"' + Format(EntryNo + 1) + '"');
        EFTTransactionRequest.Get(EntryNo);
        Assert.IsFalse(EFTTransactionRequest."External Result Known", 'A lookup for another order must leave the result unknown');
        Assert.AreNearlyEqual(0, GetSalePaymentTotal(SaleId), 0.001, 'No payment line may be created from another order');

        Response := PrepareOnNewSale();
        Assert.AreEqual(400, GetStatusCode(Response), 'The terminal must stay blocked while NETS Cloud cannot confirm the earlier payment');
        Assert.IsTrue(GetErrorMessage(Response).Contains('unknown result'), 'The error should say the earlier payment has an unknown result');
        ResolveTransactionAsStaff(TransactionId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Resolve_LookUpWithoutAnswer_StaysUnknown()
    var
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIEFTNETSResolve: Codeunit "NPR API EFT NETS Resolve";
        SaleId: Guid;
        TransactionId: Text;
        EntryNo: Integer;
        ResultMessage: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EntryNo := StartNETSPaymentWithoutResult(SaleId, TransactionId);

        EFTTransactionRequest.Get(EntryNo);
        ResultMessage := APIEFTNETSResolve.LookUp(EFTTransactionRequest);

        Assert.IsTrue(ResultMessage.Contains('did not answer'), StrSubstNo('Staff should be told NETS Cloud did not answer, got: %1', ResultMessage));
        EFTTransactionRequest.Get(EntryNo);
        Assert.IsFalse(EFTTransactionRequest."External Result Known", 'A failed lookup must leave the result unknown');
        ResolveTransactionAsStaff(TransactionId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Resolve_AttendedPayment_IsRefused()
    var
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIEFTNETSResolve: Codeunit "NPR API EFT NETS Resolve";
        SaleId: Guid;
        TransactionId: Text;
        EntryNo: Integer;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EntryNo := StartNETSPaymentWithoutResult(SaleId, TransactionId);
        SetMockNETSLookupResponse(200, GetMockNETSLookupResponse(EntryNo));
        SetSelfService(EntryNo, false);

        EFTTransactionRequest.Get(EntryNo);
        asserterror APIEFTNETSResolve.LookUp(EFTTransactionRequest);
        Assert.ExpectedError('self-service');
        Assert.IsFalse(MockNETSRequestWasSent(HttpRequestType::Get, MockNETSLookupPath()), 'An attended payment must not be looked up from the self-service actions');

        EFTTransactionRequest.Get(EntryNo);
        asserterror APIEFTNETSResolve.VoidPayment(EFTTransactionRequest);
        Assert.ExpectedError('self-service');

        EFTTransactionRequest.Get(EntryNo);
        asserterror APIEFTNETSResolve.MarkResolved(EFTTransactionRequest);
        Assert.ExpectedError('self-service');
        EFTTransactionRequest.Get(EntryNo);
        Assert.IsFalse(EFTTransactionRequest."External Result Known", 'An attended payment must not be marked as resolved from the self-service actions');

        SetSelfService(EntryNo, true);
        ResolveTransactionAsStaff(TransactionId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler,ConfirmYesHandler')]
    procedure NETS_Resolve_StaffLookUpApproved_VoidsAfterConfirm()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIEFTNETSResolve: Codeunit "NPR API EFT NETS Resolve";
        Response: JsonObject;
        SaleId: Guid;
        TransactionId: Text;
        EntryNo: Integer;
        ResultMessage: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EntryNo := StartNETSPaymentWithoutResult(SaleId, TransactionId);
        SetMockNETSLookupResponse(200, GetMockNETSLookupResponse(EntryNo));

        EFTTransactionRequest.Get(EntryNo);
        ResultMessage := APIEFTNETSResolve.LookUp(EFTTransactionRequest);

        Assert.IsTrue(ResultMessage.Contains('voided'), StrSubstNo('Staff should be told the payment was voided, got: %1', ResultMessage));
        AssertEFTLogContains(EntryNo, 'API Resolve (Lookup Complete)', '"StanAuth":"' + MockNETSLookupStan(EntryNo) + '"');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Delete, MockNETSLookupPath()), 'The approved payment should be voided after staff confirm');
        EFTTransactionRequest.Get(EntryNo);
        Assert.IsTrue(EFTTransactionRequest.Reversed, 'The recovered payment should be reversed');
        Assert.AreNearlyEqual(0, GetSalePaymentTotal(SaleId), 0.001, 'The void should cancel the recovered payment line');

        Response := PrepareOnNewSale();
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The terminal should accept new payments once the payment is resolved');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler')]
    procedure NETS_Resolve_VoidPayment_ReversesStandingPayment()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIEFTNETSResolve: Codeunit "NPR API EFT NETS Resolve";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
        ResultMessage: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 1));
        SetMockNETSVoidResponse(400, GetMockNETSFailureResponse());

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed even when the signature void is declined');
        EFTTransactionRequest.Get(GetTransactionEntryNo(TransactionId));
        Assert.IsFalse(EFTTransactionRequest.Reversed, 'Test setup: the payment should stand after the declined void');

        SetMockNETSVoidResponse(200, GetMockNETSResultResponse(0, 0));
        ResultMessage := APIEFTNETSResolve.VoidPayment(EFTTransactionRequest);

        Assert.IsTrue(ResultMessage.Contains('voided'), StrSubstNo('Staff should be told the payment was voided, got: %1', ResultMessage));
        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        Assert.IsTrue(EFTTransactionRequest.Reversed, 'The standing payment should be reversed');
        Assert.AreEqual(EFTTransactionRequest."Selfservice Reversal Status"::Reversed, EFTTransactionRequest."Selfservice Reversal Status", 'Reversal status should be Reversed');
        Assert.AreNearlyEqual(0, GetSalePaymentTotal(SaleId), 0.001, 'The void should cancel the payment line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler')]
    procedure NETS_Resolve_VoidPayment_WithoutStoredToken_LogsInAndReverses()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTSetup: Record "NPR EFT Setup";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        APIEFTNETSResolve: Codeunit "NPR API EFT NETS Resolve";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
        ResultMessage: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 1));
        SetMockNETSVoidResponse(400, GetMockNETSFailureResponse());

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed even when the signature void is declined');
        EFTTransactionRequest.Get(GetTransactionEntryNo(TransactionId));
        Assert.IsFalse(EFTTransactionRequest.Reversed, 'Test setup: the payment should stand after the declined void');

        EFTSetup.Get(_EFTPaymentMethodCode, _POSUnit."No.");
        EFTNETSCloudToken.Invalidate(EFTSetup);
        Commit();
        SetMockNETSVoidResponse(200, GetMockNETSResultResponse(0, 0));
        Clear(_MockNETSRequests);
        ResultMessage := APIEFTNETSResolve.VoidPayment(EFTTransactionRequest);

        Assert.AreEqual(1, MockNETSRequestCount('/v1/login'), 'The void should log in again when no token is stored');
        Assert.IsTrue(ResultMessage.Contains('voided'), StrSubstNo('Staff should be told the payment was voided, got: %1', ResultMessage));
        EFTTransactionRequest.Get(EFTTransactionRequest."Entry No.");
        Assert.IsTrue(EFTTransactionRequest.Reversed, 'The void sent right after a login must reverse the payment');
        VoidEFTTransactionRequest.Get(EFTTransactionRequest."Reversed by Entry No.");
        Assert.IsTrue(VoidEFTTransactionRequest.Successful, 'The void request should be successful');
        Assert.AreEqual('', VoidEFTTransactionRequest."NST Error", 'The void request should carry no error');
        Assert.AreNearlyEqual(0, GetSalePaymentTotal(SaleId), 0.001, 'The void should cancel the payment line');
    end;

    local procedure Initialize()
    var
        NPRLibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        SSProfile: Record "NPR SS Profile";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        UserSetup: Record "User Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Seating: Record "NPR NPRE Seating";
    begin
        if _Initialized then begin
            UseEFTIntegrationType(EFTAdyenIntegration.CloudIntegrationType());
            exit;
        end;

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

        UseEFTIntegrationType(EFTAdyenIntegration.CloudIntegrationType());

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
        PreviousFlagValue: Boolean;
    begin
        // [SCENARIO] Full E2E: prepare -> start (mocked Adyen) -> poll (completed) -> complete sale -> verify POS Entry and EFT record
        Initialize();
        InitializeAdyenPaymentTypeSetup();
        PreviousFlagValue := _LibraryFeatureFlags.EnableFeatureFlag('subscriptionRefundToPaymentMerchant');

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

        // [THEN] The merchant account from the terminal answer is saved on the payment
        Assert.AreEqual('TestMerchantAccount', EFTTransactionRequest."Merchant Account", 'The payment must keep the merchant account that took it, so a later refund can use it');
        _LibraryFeatureFlags.SetFeatureFlag('subscriptionRefundToPaymentMerchant', PreviousFlagValue);
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
    procedure EFT_E2E_DeclinedPayment_StatusIsCompletedWithSuccessfulFalse()
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
        // [SCENARIO] Full E2E: prepare -> start (mocked declined) -> poll (Completed + successful:false) -> verify no paymentDelta
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

        // [THEN] Poll returns Completed status with successful=false (handled decline)
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.IsTrue(ResponseBody.Get('status', JToken), 'Poll should return status');
        Assert.AreEqual('Completed', JToken.AsValue().AsText(), 'Status should be Completed for a handled decline (terminal gave a clean negative result)');

        Assert.IsTrue(ResponseBody.Get('successful', JToken), 'Poll should return successful');
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'successful should be false for a handled decline');

        Assert.IsTrue(ResponseBody.Get('resultCode', JToken), 'Declined poll should include resultCode');
        Assert.IsTrue(ResponseBody.Get('resultMessage', JToken), 'Declined poll should include resultMessage');

        // [THEN] Declined payment must NOT include delta fields
        Assert.IsFalse(ResponseBody.Contains('refreshedSaleLines'), 'Declined payment should NOT include refreshedSaleLines');
        Assert.IsFalse(ResponseBody.Contains('refreshedPaymentLines'), 'Declined payment should NOT include refreshedPaymentLines');
        Assert.IsFalse(ResponseBody.Contains('totalSalesAmountInclVat'), 'Declined payment should NOT include totalSalesAmountInclVat');

        // [THEN] EFT Transaction Request reflects declined state
        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'External Result Known should be true - terminal returned a clean decline');
        Assert.IsFalse(EFTTransactionRequest.Successful, 'EFT Transaction should NOT be marked Successful');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockAdyenCloudSystemErrorResponse')]
    procedure EFT_E2E_SystemError_StatusReturnsFailed()
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
        // [SCENARIO] Full E2E: prepare -> start (mocked HTTP 500, InvokeAPI TryFunction returns false)
        //            -> poll returns Failed (system error, External Result Known = false)
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

        // [WHEN] POST /pos/sale/:saleId/eft/:transactionId/cloud/start (mocked HTTP 500)
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);

        // [THEN] Start still returns OK with processed=true
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should respond 200 even on system error');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('processed', JToken), 'Start should return processed');
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'processed should be true');

        // [WHEN] GET /pos/sale/:saleId/eft/:transactionId/cloud/status
        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);

        // [THEN] Poll returns Failed - this is the "unknown state, lock the station" case
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        Assert.IsTrue(ResponseBody.Get('status', JToken), 'Poll should return status');
        Assert.AreEqual('Failed', JToken.AsValue().AsText(), 'Status should be Failed only for unhandled system errors');

        Assert.IsTrue(ResponseBody.Get('successful', JToken), 'Poll should return successful');
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'successful should be false');

        // [THEN] System error must NOT include delta fields
        Assert.IsFalse(ResponseBody.Contains('refreshedSaleLines'), 'System-error payment should NOT include refreshedSaleLines');
        Assert.IsFalse(ResponseBody.Contains('refreshedPaymentLines'), 'System-error payment should NOT include refreshedPaymentLines');
        Assert.IsFalse(ResponseBody.Contains('totalSalesAmountInclVat'), 'System-error payment should NOT include totalSalesAmountInclVat');

        // [THEN] EFT Transaction Request reflects unknown-outcome state
        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsFalse(EFTTransactionRequest."External Result Known", 'External Result Known should be false - HTTP failed');
        Assert.IsFalse(EFTTransactionRequest.Successful, 'EFT Transaction should NOT be marked Successful');
        Assert.AreNotEqual(0DT, EFTTransactionRequest.Finished, 'Finished should be set - system error is a terminal state');
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

    [HttpClientHandler]
    procedure MockAdyenCloudSystemErrorResponse(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        Response.Content.WriteFrom('{"error":"Adyen terminal unreachable"}');
        Response.HttpStatusCode := 500;
        Response.ReasonPhrase := 'Internal Server Error';
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
        ResponseJson.Append('"MerchantID":"TestMerchantAccount",');
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrepareEFT_UnsupportedIntegrationType_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
    begin
        Initialize();
        UseEFTIntegrationType('NETS_BAXI_NET');

        SaleId := CreateTestSale();

        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);

        Assert.AreEqual(400, GetStatusCode(Response), 'Prepare with an unsupported EFT Integration Type should return 400');
        Assert.IsTrue(GetErrorMessage(Response).Contains('NETS_BAXI_NET'), 'Error message should name the unsupported EFT Integration Type');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrepareEFT_NETSCloudWithoutTerminalId_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTNETSCloudUnitSetup: Record "NPR EFT NETSCloud Unit Setup";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EFTNETSCloudUnitSetup.Get(_POSUnit."No.");
        EFTNETSCloudUnitSetup."Terminal ID" := '';
        EFTNETSCloudUnitSetup.Modify();
        Commit();

        SaleId := CreateTestSale();

        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);

        Assert.AreEqual(400, GetStatusCode(Response), 'Prepare without a NETS Cloud Terminal ID should return 400');
        Assert.IsTrue(GetErrorMessage(Response).Contains(_POSUnit."No."), 'Error message should name the POS Unit missing the Terminal ID');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StartEFT_LocalFlowIntegrationType_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
    begin
        Initialize();
        UseEFTIntegrationType(EFTAdyenIntegration.MposTapToPayIntegrationType());

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);

        Assert.AreEqual(400, GetStatusCode(Response), 'Cloud start on a local flow integration type should return 400');
        Assert.IsTrue(GetErrorMessage(Response).Contains(EFTAdyenIntegration.MposTapToPayIntegrationType()), 'Error message should name the EFT Integration Type');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_E2E_HappyPath_PrepareStartPollComplete()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTReceipt: Record "NPR EFT Receipt";
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
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 0));

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('processed', JToken), 'Start should return processed');
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'processed should be true');
        Assert.AreEqual(1, MockNETSRequestCount('/v1/login'), 'Prepare and start should share one NETS Cloud login');
        Assert.IsTrue(MockNETSRequestWasSent('/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'Start should post the transaction to the configured terminal');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Completed', JToken.AsValue().AsText(), 'Status should be Completed after a successful NETS transaction');
        ResponseBody.Get('successful', JToken);
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'successful should be true');
        ResponseBody.Get('cardNumber', JToken);
        Assert.AreEqual('************1234', JToken.AsValue().AsText(), 'cardNumber should come from the NETS TruncatedPAN');
        ResponseBody.Get('authorizationNumber', JToken);
        Assert.AreEqual('654321', JToken.AsValue().AsText(), 'authorizationNumber should come from the NETS StanAuth');
        VerifyEFTDeltaFields(ResponseBody, _Item."Unit Price");

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed after NETS payment');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('documentNo', JToken);
        DocumentNo := JToken.AsValue().AsText();
        POSEntry.SetRange("Document No.", DocumentNo);
        Assert.IsTrue(POSEntry.FindFirst(), 'POS Entry should exist for completed sale');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsTrue(EFTTransactionRequest.Started <> 0DT, 'EFT Started timestamp should be set');
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'External Result Known should be true');
        Assert.IsTrue(EFTTransactionRequest.Successful, 'EFT Transaction should be marked Successful');
        Assert.AreEqual(MockNETSTerminalId(), EFTTransactionRequest."Hardware ID", 'Hardware ID should be the NETS Terminal ID of the POS Unit');

        EFTReceipt.SetRange("EFT Trans. Request Entry No.", EFTTransactionRequest."Entry No.");
        Assert.IsFalse(EFTReceipt.IsEmpty(), 'NETS receipts should be stored for terminal receipt printing');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_E2E_DeclinedPayment_StatusIsCompletedWithSuccessfulFalse()
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
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(400, GetMockNETSFailureResponse());

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed even for a declined payment');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Completed', JToken.AsValue().AsText(), 'Status should be Completed for a clean NETS decline');
        ResponseBody.Get('successful', JToken);
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'successful should be false for a declined payment');
        Assert.IsTrue(ResponseBody.Get('resultMessage', JToken), 'Declined poll should include resultMessage');
        Assert.IsTrue(JToken.AsValue().AsText().Contains('Transaction declined'), 'resultMessage should carry the NETS error text');
        Assert.IsFalse(ResponseBody.Contains('refreshedPaymentLines'), 'Declined payment should NOT include refreshedPaymentLines');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'External Result Known should be true for a clean decline');
        Assert.IsFalse(EFTTransactionRequest.Successful, 'EFT Transaction should NOT be marked Successful');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_E2E_SystemError_StatusReturnsFailed()
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
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(500, '{"error":"NETS Cloud unavailable"}');

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should respond 200 even on system error');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Failed', JToken.AsValue().AsText(), 'Status should be Failed when the NETS call itself fails');
        ResponseBody.Get('successful', JToken);
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'successful should be false');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsFalse(EFTTransactionRequest."External Result Known", 'External Result Known should be false when the HTTP call failed');
        Assert.AreNotEqual(0DT, EFTTransactionRequest.Finished, 'Finished should be set so the transaction is not left Initiated');
        Assert.AreNotEqual('', EFTTransactionRequest."NST Error", 'NST Error should carry the HTTP failure');
        ResolveTransactionAsStaff(TransactionId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Cancel_PreparedTransaction_IsRejectedWithoutCancelAction()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        Clear(_MockNETSRequests);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/cancel', Body, QueryParams, Headers);
        Assert.AreEqual(400, GetStatusCode(Response), 'Cancel of a transaction that was never started should be rejected');
        Assert.IsTrue(GetErrorMessage(Response).Contains('not been started'), 'The error should say the transaction has not been started');
        Assert.IsFalse(MockNETSRequestWasSent('/administration'), 'No cancelAction should reach the terminal for a transaction that was never started');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Cancel_StartedTransaction_SendsCancelAction()
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
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        SetTransactionStarted(TransactionId);
        Clear(_MockNETSRequests);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/cancel', Body, QueryParams, Headers);
        MarkTransactionFinished(TransactionId);

        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Cancel EFT should succeed for a started transaction');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('cancelRequested', JToken);
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'cancelRequested should be true');
        Assert.IsTrue(MockNETSRequestWasSent('/v1/terminal/' + MockNETSTerminalId() + '/administration'), 'Cancel should post a cancelAction to the configured terminal');
        Assert.AreEqual(0, MockNETSRequestCount('/v1/login'), 'Cancel should reuse the NETS Cloud login from prepare');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Cancel_FinishedTransaction_IsRejectedWithoutCancelAction()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 0));

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed');
        Clear(_MockNETSRequests);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/cancel', Body, QueryParams, Headers);
        Assert.AreEqual(400, GetStatusCode(Response), 'Cancel of a finished transaction should be rejected');
        Assert.IsTrue(GetErrorMessage(Response).Contains('already finished'), 'The error should say the transaction has already finished');
        Assert.IsFalse(MockNETSRequestWasSent('/administration'), 'No cancelAction should reach the terminal for a finished transaction');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Cancel_PendingReversal_IsRejectedWithoutCancelAction()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        SetTransactionStarted(TransactionId);
        SetReversalStatus(TransactionId, EFTTransactionRequest."Selfservice Reversal Status"::Pending);
        Clear(_MockNETSRequests);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/cancel', Body, QueryParams, Headers);
        SetReversalStatus(TransactionId, EFTTransactionRequest."Selfservice Reversal Status"::" ");
        MarkTransactionFinished(TransactionId);

        Assert.AreEqual(400, GetStatusCode(Response), 'Cancel should be rejected while a signature void is pending');
        Assert.IsTrue(GetErrorMessage(Response).Contains('signature void'), 'The error should say the transaction waits for its signature void');
        Assert.IsFalse(MockNETSRequestWasSent('/administration'), 'No cancelAction should reach the terminal while a signature void is pending');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler')]
    procedure NETS_E2E_SignatureRequired_PaymentIsVoided()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
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
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 1));

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Delete, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'A signature result on a self-service unit should void the payment on the terminal');
        AssertSignatureVoidCompletedWithoutError(TransactionId);

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Completed', JToken.AsValue().AsText(), 'Status should be Completed after the void');
        ResponseBody.Get('successful', JToken);
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'successful should be false once the payment has been voided');
        ResponseBody.Get('reversalStatus', JToken);
        Assert.AreEqual('reversed', JToken.AsValue().AsText(), 'reversalStatus should be reversed');
        ResponseBody.Get('resultMessage', JToken);
        Assert.IsTrue(JToken.AsValue().AsText().Contains('voided'), 'resultMessage should explain that the payment was voided');
        Assert.IsFalse(ResponseBody.Contains('refreshedPaymentLines'), 'Voided payment should NOT include refreshedPaymentLines');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsTrue(EFTTransactionRequest.Reversed, 'Original transaction should be marked Reversed');
        Assert.AreEqual(EFTTransactionRequest."Selfservice Reversal Status"::Reversed, EFTTransactionRequest."Selfservice Reversal Status", 'Reversal status should be Reversed');
        VoidEFTTransactionRequest.Get(EFTTransactionRequest."Reversed by Entry No.");
        Assert.AreEqual(VoidEFTTransactionRequest."Processing Type"::VOID, VoidEFTTransactionRequest."Processing Type", 'Reversal should be a VOID request');
        Assert.IsTrue(VoidEFTTransactionRequest.Successful, 'Void should be successful');
        Assert.AreNearlyEqual(0, GetSalePaymentTotal(SaleId), 0.001, 'Sale payment total should be zero after the void');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler')]
    procedure NETS_E2E_SignatureRequired_VoidDeclined_PaymentStands()
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
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 1));
        SetMockNETSVoidResponse(400, GetMockNETSFailureResponse());

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed even when the void is declined');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Completed', JToken.AsValue().AsText(), 'Status should be Completed once the void attempt has a result');
        ResponseBody.Get('successful', JToken);
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'The payment stands when the terminal declines the void');
        ResponseBody.Get('reversalStatus', JToken);
        Assert.AreEqual('failed', JToken.AsValue().AsText(), 'reversalStatus should be failed when the terminal declines the void');
        VerifyEFTDeltaFields(ResponseBody, _Item."Unit Price");

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'The sale can be completed when the payment stands');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsFalse(EFTTransactionRequest.Reversed, 'Original transaction should not be marked Reversed');
        Assert.AreEqual(EFTTransactionRequest."Selfservice Reversal Status"::Failed, EFTTransactionRequest."Selfservice Reversal Status", 'Reversal status should be Failed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler')]
    procedure NETS_E2E_SignatureRequired_VoidResultUnknown_NotSuccessful()
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
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 1));
        SetMockNETSVoidResponse(500, '{"error":"NETS Cloud unavailable"}');

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed even when the void result is unknown');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Completed', JToken.AsValue().AsText(), 'Status should be Completed once the void attempt has finished');
        ResponseBody.Get('successful', JToken);
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'A payment whose void result is unknown must not be reported as successful');
        ResponseBody.Get('reversalStatus', JToken);
        Assert.AreEqual('unknown', JToken.AsValue().AsText(), 'reversalStatus should be unknown');
        ResponseBody.Get('resultMessage', JToken);
        Assert.IsTrue(JToken.AsValue().AsText().Contains('unknown'), 'resultMessage should say the void result is unknown');
        Assert.IsFalse(ResponseBody.Contains('refreshedPaymentLines'), 'Unknown void result should NOT include refreshedPaymentLines');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.AreEqual(400, GetStatusCode(Response), 'The sale must not be completed while the void result is unknown');
        Assert.IsTrue(GetErrorMessage(Response).Contains('unknown void result'), 'The error should say the void result is unknown');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.AreEqual(EFTTransactionRequest."Selfservice Reversal Status"::Unknown, EFTTransactionRequest."Selfservice Reversal Status", 'Reversal status should be Unknown');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure PrepareEFT_NETSCloudTerminalBusy_ReturnsBadRequest()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        SetTransactionStarted(TransactionId);

        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);
        MarkTransactionFinished(TransactionId);

        Assert.AreEqual(400, GetStatusCode(Response), 'Prepare should be rejected while the terminal is processing an earlier payment');
        Assert.IsTrue(GetErrorMessage(Response).Contains('processing an earlier payment'), 'The error should say the terminal is still processing an earlier payment');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler')]
    procedure NETS_E2E_SignatureRequired_LaterPreparedTransaction_StillVoided()
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
        LaterTransactionId: Text;
        TransactionGuid: Guid;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 1));

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        LaterTransactionId := PrepareEFTTransaction(SaleId);
        Assert.AreNotEqual(TransactionId, LaterTransactionId, 'The later prepare should create its own transaction');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Delete, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'The signature payment must be voided even though a later transaction was prepared on the terminal');
        AssertSignatureVoidCompletedWithoutError(TransactionId);

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('successful', JToken);
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'A voided signature payment must not be reported as successful');
        ResponseBody.Get('reversalStatus', JToken);
        Assert.AreEqual('reversed', JToken.AsValue().AsText(), 'reversalStatus should be reversed');

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsTrue(EFTTransactionRequest.Reversed, 'Original transaction should be marked Reversed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud,VoidMessageHandler')]
    procedure NETS_E2E_SignatureRequired_ReversalIsPendingWhenVoidIsSent()
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
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 1));

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Delete, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'The signature payment should be voided');
        Assert.IsTrue(_MockNETSFinishedAtVoid, 'The payment must be committed as finished before the void is sent');
        Assert.IsTrue(_MockNETSReversalStatusAtVoid = EFTTransactionRequest."Selfservice Reversal Status"::Pending, 'The reversal status must be Pending from the payment commit until the void result is known');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('reversalStatus', JToken);
        Assert.AreEqual('reversed', JToken.AsValue().AsText(), 'reversalStatus should be reversed once the void has completed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure PollEFTStatus_NETSReversalPending_ReportsInitiatedWithoutResult()
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
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 0));

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should succeed');

        SetReversalStatus(TransactionId, EFTTransactionRequest."Selfservice Reversal Status"::Pending);

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Poll EFT should succeed');

        Clear(Body);
        Clear(QueryParams);
        Assert.AreEqual(400, GetStatusCode(LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers)), 'The sale must not be completed while the signature void is pending');
        SetReversalStatus(TransactionId, EFTTransactionRequest."Selfservice Reversal Status"::" ");

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Initiated', JToken.AsValue().AsText(), 'A successful payment with a pending signature void must still report Initiated');
        ResponseBody.Get('successful', JToken);
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'A payment with a pending signature void must not be reported as successful');
        ResponseBody.Get('reversalStatus', JToken);
        Assert.AreEqual('pending', JToken.AsValue().AsText(), 'reversalStatus should be pending');
        Assert.IsFalse(ResponseBody.Contains('resultCode'), 'The result must be withheld while the void is pending');
        Assert.IsFalse(ResponseBody.Contains('refreshedPaymentLines'), 'Payment lines must be withheld while the void is pending');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_E2E_SystemError_LookupRecoversResult()
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
        EntryNo: Integer;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(500, '{"error":"NETS Cloud unavailable"}');

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        EntryNo := GetTransactionEntryNo(TransactionId);
        SetMockNETSLookupResponse(200, GetMockNETSLookupResponse(EntryNo));

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should respond 200 when the result is recovered by lookup');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Get, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'A failed transaction call should be followed by a lookup of the last transaction');
        AssertEFTLogContains(EntryNo, 'API Start (Error)', '"transactionType"');
        AssertEFTLogContains(EntryNo, 'API Start (Lookup Complete)', '"StanAuth":"' + MockNETSLookupStan(EntryNo) + '"');
        AssertEFTLogDoesNotContain(EntryNo, 'API Start (Lookup Complete)', '"transactionType"');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Completed', JToken.AsValue().AsText(), 'Status should be Completed when the lookup found the approved payment');
        ResponseBody.Get('successful', JToken);
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'successful should be true when the lookup found the approved payment');
        ResponseBody.Get('authorizationNumber', JToken);
        Assert.AreEqual(MockNETSLookupStan(EntryNo), JToken.AsValue().AsText(), 'authorizationNumber should come from the lookup result');
        VerifyEFTDeltaFields(ResponseBody, _Item."Unit Price");

        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        Assert.IsTrue(EFTTransactionRequest."External Result Known", 'External Result Known should be true after a matching lookup');
        Assert.IsTrue(EFTTransactionRequest.Successful, 'The transaction should be Successful after a matching lookup');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_E2E_SystemError_ResultUnknown_StartAgainIsRejected()
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
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(500, '{"error":"NETS Cloud unavailable"}');

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should respond 200 even on system error');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Get, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'A failed transaction call should be followed by a lookup attempt');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Failed', JToken.AsValue().AsText(), 'Status should be Failed when neither the transaction nor the lookup gave a result');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.AreEqual(400, GetStatusCode(Response), 'A transaction with an unknown result must not be started again');
        Assert.IsTrue(GetErrorMessage(Response).Contains('unknown'), 'The error should say the result is unknown');
        Assert.AreEqual(1, MockNETSRequestCount(HttpRequestType::Post, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'The payment must not be posted to the terminal a second time');
        ResolveTransactionAsStaff(TransactionId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Prepare_UnresolvedEarlierPayment_IsRejectedUntilStaffResolveIt()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactReqComment: Record "NPR EFT Transact. Req. Comment";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(500, '{"error":"NETS Cloud unavailable"}');

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should respond 200 even on system error');

        Clear(Body);
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);
        Assert.AreEqual(400, GetStatusCode(Response), 'Prepare must be rejected while an earlier payment on the terminal has an unknown result');
        Assert.IsTrue(GetErrorMessage(Response).Contains('unknown result'), 'The error should say the earlier payment has an unknown result');

        ResolveTransactionAsStaff(TransactionId);

        EFTTransactReqComment.SetRange("Entry No.", GetTransactionEntryNo(TransactionId));
        Assert.IsFalse(EFTTransactReqComment.IsEmpty(), 'Marking the payment as resolved should leave a comment on the transaction request');

        Clear(Body);
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare should succeed once staff resolved the earlier payment');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_E2E_SystemError_LookupForOtherOrder_StaysUnknownWithoutPaymentLine()
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
        EntryNo: Integer;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(500, '{"error":"NETS Cloud unavailable"}');

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        EntryNo := GetTransactionEntryNo(TransactionId);
        SetMockNETSLookupResponse(200, GetMockNETSLookupResponse(EntryNo, Format(EntryNo + 1)));

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should respond 200 even when the lookup belongs to another order');
        Assert.IsTrue(MockNETSRequestWasSent(HttpRequestType::Get, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'A lookup should have been attempted');

        Clear(Body);
        Clear(QueryParams);
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/status', Body, QueryParams, Headers);
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('status', JToken);
        Assert.AreEqual('Failed', JToken.AsValue().AsText(), 'A lookup for another order must leave the transaction without a result');
        ResponseBody.Get('successful', JToken);
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'successful must be false');
        Assert.IsFalse(ResponseBody.Contains('refreshedPaymentLines'), 'No payment line may be created from another order');
        Assert.AreNearlyEqual(0, GetSalePaymentTotal(SaleId), 0.001, 'The sale must not be paid by another order');

        EFTTransactionRequest.Get(EntryNo);
        Assert.IsFalse(EFTTransactionRequest."External Result Known", 'The result must stay unknown');
        Assert.IsFalse(EFTTransactionRequest.Successful, 'The transaction must not be successful');
        ResolveTransactionAsStaff(TransactionId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Start_DeclinedTransaction_CannotBeStartedAgain()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(400, GetMockNETSFailureResponse());

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should respond 200 on a decline');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.AreEqual(400, GetStatusCode(Response), 'A declined transaction must not be started again');
        Assert.IsTrue(GetErrorMessage(Response).Contains('already been started'), 'The error should say the transaction was already started');
        Assert.AreEqual(1, MockNETSRequestCount(HttpRequestType::Post, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'The payment must not be posted to the terminal a second time');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NETS_Token_InvalidateCurrent_RemovesStoredToken()
    var
        Assert: Codeunit Assert;
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        Token: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EFTSetup.Get(_EFTPaymentMethodCode, _POSUnit."No.");

        EFTNETSCloudToken.SetToken(EFTSetup, CreateMockJwt());
        Assert.IsTrue(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'A stored token should be retrievable');

        EFTNETSCloudToken.InvalidateCurrent();
        Clear(Token);
        Assert.IsFalse(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'An invalidated token must not be retrievable');
        Assert.AreEqual('', Token, 'No token should be returned after invalidation');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NETS_Token_UnauthorizedInBackgroundSession_RemovesStoredToken()
    var
        Assert: Codeunit Assert;
        EFTSetup: Record "NPR EFT Setup";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        TaskResults: Dictionary of [Text, Text];
        Token: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EFTSetup.Get(_EFTPaymentMethodCode, _POSUnit."No.");
        EFTTransactionRequest."Register No." := _POSUnit."No.";
        EFTTransactionRequest."Original POS Payment Type Code" := _EFTPaymentMethodCode;

        EFTNETSCloudToken.SetToken(EFTSetup, CreateMockJwt());
        Assert.IsTrue(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'A stored token should be retrievable');

        EFTNETSCloudToken.AddTaskResult(TaskResults, false);
        EFTNETSCloudToken.InvalidateIfRejectedByTask(EFTTransactionRequest, TaskResults);
        Assert.IsTrue(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'A task that was not rejected must keep the stored token');

        Clear(TaskResults);
        EFTNETSCloudToken.AddTaskResult(TaskResults, true);
        EFTNETSCloudToken.InvalidateIfRejectedByTask(EFTTransactionRequest, TaskResults);
        Clear(Token);
        Assert.IsFalse(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'A token rejected in a background task must be removed from storage so no session reuses it');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NETS_Token_UsernameChangedAndRestored_OldKeyIsRemoved()
    var
        Assert: Codeunit Assert;
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        Token: Text;
        OriginalUsername: Text[250];
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EFTSetup.Get(_EFTPaymentMethodCode, _POSUnit."No.");

        EFTNETSCloudToken.SetToken(EFTSetup, CreateMockJwt());
        Assert.IsTrue(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'A stored token should be retrievable');

        EFTNETSCloudPaymentSetup.Get(_EFTPaymentMethodCode);
        OriginalUsername := EFTNETSCloudPaymentSetup."API Username";
        EFTNETSCloudPaymentSetup."API Username" := 'other-user';
        EFTNETSCloudPaymentSetup.Modify(true);
        EFTNETSCloudPaymentSetup."API Username" := OriginalUsername;
        EFTNETSCloudPaymentSetup.Modify();

        Clear(Token);
        Assert.IsFalse(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'The token stored under the old username must be gone after the username changed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NETS_Token_CredentialChange_InvalidatesStoredToken()
    var
        Assert: Codeunit Assert;
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
        Token: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        EFTSetup.Get(_EFTPaymentMethodCode, _POSUnit."No.");

        EFTNETSCloudToken.SetToken(EFTSetup, CreateMockJwt());
        Assert.IsTrue(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'A stored token should be retrievable');

        EFTNETSCloudPaymentSetup.Get(_EFTPaymentMethodCode);
        EFTNETSCloudPaymentSetup."API Password" := 'rotated-password';
        EFTNETSCloudPaymentSetup.Modify(true);

        Clear(Token);
        Assert.IsFalse(EFTNETSCloudToken.TryGetToken(EFTSetup, Token), 'A token issued for the old credentials must not be reused after the password changed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Start_LaterTransactionAlreadyStarted_IsRejected()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        TransactionId: Text;
        LaterTransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 0));

        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        LaterTransactionId := PrepareEFTTransaction(SaleId);
        SetTransactionStarted(LaterTransactionId);
        MarkTransactionFinished(LaterTransactionId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.AreEqual(400, GetStatusCode(Response), 'Start must be rejected when a later transaction on the terminal has already been started');
        Assert.IsTrue(GetErrorMessage(Response).Contains('later transaction'), 'The error should say a later transaction was started');
        Assert.IsFalse(MockNETSRequestWasSent(HttpRequestType::Post, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'The payment must not reach the terminal');

        EFTTransactionRequest.Get(GetTransactionEntryNo(TransactionId));
        Assert.AreEqual(0DT, EFTTransactionRequest.Started, 'The rejected transaction must not be marked started');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('MockNETSCloud')]
    procedure NETS_Start_TerminalBusyWithEarlierPayment_IsRejected()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
        EarlierTransactionId: Text;
        TransactionId: Text;
    begin
        Initialize();
        InitializeNETSCloudSetup();
        SetMockNETSTransactionResponse(200, GetMockNETSResultResponse(0, 0));

        SaleId := CreateTestSale();
        EarlierTransactionId := PrepareEFTTransaction(SaleId);
        TransactionId := PrepareEFTTransaction(SaleId);
        SetTransactionStarted(EarlierTransactionId);

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        MarkTransactionFinished(EarlierTransactionId);

        Assert.AreEqual(400, GetStatusCode(Response), 'Start must be rejected while the terminal is processing an earlier payment');
        Assert.IsTrue(GetErrorMessage(Response).Contains('processing an earlier payment'), 'The error should say the terminal is busy');
        Assert.IsFalse(MockNETSRequestWasSent(HttpRequestType::Post, '/v1/terminal/' + MockNETSTerminalId() + '/transaction'), 'The payment must not reach the terminal');

        EFTTransactionRequest.Get(GetTransactionEntryNo(TransactionId));
        Assert.AreEqual(0DT, EFTTransactionRequest.Started, 'The rejected transaction must not be marked started');
    end;

    [HttpClientHandler]
    procedure MockNETSCloud(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Path: Text;
    begin
        Path := Request.Path();
        _MockNETSRequests.Add(MockRequestMethodName(Request.RequestType()) + ' ' + Path);

        case true of
            Path.EndsWith('/v1/login'):
                RespondMock(Response, 200, '{"token":"' + CreateMockJwt() + '"}');
            Path.EndsWith('/transaction') and (Request.RequestType() = HttpRequestType::Delete):
                begin
                    CaptureOriginalStateAtVoid();
                    RespondMock(Response, _MockNETSVoidStatusCode, _MockNETSVoidBody);
                end;
            Path.EndsWith('/transaction') and (Request.RequestType() = HttpRequestType::Get):
                RespondMock(Response, _MockNETSLookupStatusCode, _MockNETSLookupBody);
            Path.EndsWith('/transaction'):
                RespondMock(Response, _MockNETSTransactionStatusCode, _MockNETSTransactionBody);
            Path.EndsWith('/administration'):
                RespondMock(Response, 200, '{"result":"ok"}');
            else
                RespondMock(Response, 404, '{"failure":"unexpected request ' + Path + '"}');
        end;
        exit(false);
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure VoidMessageHandler(Msg: Text[1024])
    begin
    end;

    local procedure MockRequestMethodName(RequestType: HttpRequestType): Text
    begin
        case RequestType of
            HttpRequestType::Delete:
                exit('Delete');
            HttpRequestType::Get:
                exit('Get');
            HttpRequestType::Post:
                exit('Post');
        end;
        exit('Other');
    end;

    local procedure RespondMock(var Response: TestHttpResponseMessage; StatusCode: Integer; Body: Text)
    begin
        Response.Content.WriteFrom(Body);
        Response.HttpStatusCode := StatusCode;
    end;

    local procedure SetMockNETSTransactionResponse(StatusCode: Integer; Body: Text)
    begin
        _MockNETSTransactionStatusCode := StatusCode;
        _MockNETSTransactionBody := Body;
        SetMockNETSVoidResponse(200, GetMockNETSResultResponse(0, 0));
        SetMockNETSLookupResponse(500, '{"error":"NETS Cloud unavailable"}');
        Clear(_MockNETSRequests);
        Clear(_MockNETSReversalStatusAtVoid);
        Clear(_MockNETSFinishedAtVoid);
    end;

    local procedure SetMockNETSVoidResponse(StatusCode: Integer; Body: Text)
    begin
        _MockNETSVoidStatusCode := StatusCode;
        _MockNETSVoidBody := Body;
    end;

    local procedure SetMockNETSLookupResponse(StatusCode: Integer; Body: Text)
    begin
        _MockNETSLookupStatusCode := StatusCode;
        _MockNETSLookupBody := Body;
    end;

    local procedure CaptureOriginalStateAtVoid()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Hardware ID", MockNETSTerminalId());
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        if not EFTTransactionRequest.FindLast() then
            exit;
        _MockNETSReversalStatusAtVoid := EFTTransactionRequest."Selfservice Reversal Status";
        _MockNETSFinishedAtVoid := EFTTransactionRequest.Finished <> 0DT;
    end;

    local procedure MockNETSRequestWasSent(PathFragment: Text): Boolean
    begin
        exit(MockNETSRequestCount(PathFragment) > 0);
    end;

    local procedure MockNETSRequestWasSent(RequestType: HttpRequestType; PathSuffix: Text): Boolean
    var
        LoggedRequest: Text;
    begin
        foreach LoggedRequest in _MockNETSRequests do
            if LoggedRequest.StartsWith(MockRequestMethodName(RequestType) + ' ') and LoggedRequest.EndsWith(PathSuffix) then
                exit(true);
        exit(false);
    end;

    local procedure MockNETSRequestCount(PathFragment: Text) Count: Integer
    var
        LoggedRequest: Text;
    begin
        foreach LoggedRequest in _MockNETSRequests do
            if LoggedRequest.Contains(PathFragment) then
                Count += 1;
    end;

    local procedure MockNETSRequestCount(RequestType: HttpRequestType; PathSuffix: Text) Count: Integer
    var
        LoggedRequest: Text;
    begin
        foreach LoggedRequest in _MockNETSRequests do
            if LoggedRequest.StartsWith(MockRequestMethodName(RequestType) + ' ') and LoggedRequest.EndsWith(PathSuffix) then
                Count += 1;
    end;

    local procedure GetTransactionEntryNo(TransactionId: Text): Integer
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        TransactionGuid: Guid;
    begin
        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);
        exit(EFTTransactionRequest."Entry No.");
    end;

    local procedure SetTransactionStarted(TransactionId: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(GetTransactionEntryNo(TransactionId));
        EFTTransactionRequest.Started := CurrentDateTime;
        EFTTransactionRequest.Modify();
        Commit();
    end;

    local procedure MarkTransactionFinished(TransactionId: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(GetTransactionEntryNo(TransactionId));
        EFTTransactionRequest.Finished := CurrentDateTime;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest.Modify();
        Commit();
    end;

    local procedure SetReversalStatus(TransactionId: Text; ReversalStatus: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(GetTransactionEntryNo(TransactionId));
        EFTTransactionRequest."Selfservice Reversal Status" := ReversalStatus;
        EFTTransactionRequest.Modify();
        Commit();
    end;

    local procedure MockNETSLookupStan(EntryNo: Integer): Text
    begin
        exit('9' + Format(EntryNo));
    end;

    local procedure GetMockNETSLookupResponse(EntryNo: Integer): Text
    begin
        exit(GetMockNETSLookupResponse(EntryNo, Format(EntryNo)));
    end;

    local procedure GetMockNETSLookupResponse(EntryNo: Integer; OrderId: Text): Text
    begin
        exit(GetMockNETSLookupResponse(EntryNo, OrderId, 0));
    end;

    local procedure GetMockNETSLookupResponse(EntryNo: Integer; OrderId: Text; ResultCode: Integer): Text
    var
        ResponseJson: TextBuilder;
    begin
        ResponseJson.Append('{"result":{');
        ResponseJson.Append('"latestTransactionResult":{');
        ResponseJson.Append('"Result":' + Format(ResultCode) + ',');
        ResponseJson.Append('"CVM":0,');
        ResponseJson.Append('"TruncatedPAN":"************1234",');
        ResponseJson.Append('"StanAuth":"' + MockNETSLookupStan(EntryNo) + '",');
        ResponseJson.Append('"CardIssuerName":"Visa",');
        ResponseJson.Append('"AID":"A0000000031010",');
        ResponseJson.Append('"TotalAmount":10000,');
        ResponseJson.Append('"TimeStamp":"' + Format(CurrentDateTime, 0, '<Year4><Month,2><Day,2><Hours24,2><Minutes,2><Seconds,2>') + '",');
        ResponseJson.Append('"SessionNumber":"42",');
        ResponseJson.Append('"ResponseCode":"00"');
        ResponseJson.Append('},');
        ResponseJson.Append('"orderId":"' + OrderId + '"');
        ResponseJson.Append('}}');
        exit(ResponseJson.ToText());
    end;

    local procedure ResolveTransactionAsStaff(TransactionId: Text)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        APIEFTNETSResolve: Codeunit "NPR API EFT NETS Resolve";
    begin
        EFTTransactionRequest.Get(GetTransactionEntryNo(TransactionId));
        APIEFTNETSResolve.MarkResolved(EFTTransactionRequest);
        Commit();
    end;

    local procedure SetSelfService(EntryNo: Integer; SelfService: Boolean)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);
        EFTTransactionRequest."Self Service" := SelfService;
        EFTTransactionRequest.Modify();
        Commit();
    end;

    local procedure GetEFTLogContent(EntryNo: Integer; Description: Text): Text
    var
        Assert: Codeunit Assert;
        EFTTransactionLog: Record "NPR EFT Transaction Log";
        LogInStream: InStream;
        Line: Text;
        LogContent: TextBuilder;
    begin
        EFTTransactionLog.SetRange("Transaction Entry No.", EntryNo);
        EFTTransactionLog.SetRange(Description, Description);
        Assert.IsTrue(EFTTransactionLog.FindLast(), StrSubstNo('Log entry ''%1'' should exist for transaction %2', Description, EntryNo));
        EFTTransactionLog.CalcFields(Log);
        EFTTransactionLog.Log.CreateInStream(LogInStream);
        while not LogInStream.EOS() do begin
            LogInStream.ReadText(Line);
            LogContent.Append(Line);
        end;
        exit(LogContent.ToText());
    end;

    local procedure AssertEFTLogContains(EntryNo: Integer; Description: Text; ExpectedText: Text)
    var
        Assert: Codeunit Assert;
        LogContent: Text;
    begin
        LogContent := GetEFTLogContent(EntryNo, Description);
        Assert.IsTrue(LogContent.Contains(ExpectedText), StrSubstNo('Log entry ''%1'' should contain %2, got: %3', Description, ExpectedText, LogContent));
    end;

    local procedure AssertEFTLogDoesNotContain(EntryNo: Integer; Description: Text; UnexpectedText: Text)
    var
        Assert: Codeunit Assert;
        LogContent: Text;
    begin
        LogContent := GetEFTLogContent(EntryNo, Description);
        Assert.IsFalse(LogContent.Contains(UnexpectedText), StrSubstNo('Log entry ''%1'' should not contain %2, got: %3', Description, UnexpectedText, LogContent));
    end;

    local procedure StartNETSPaymentWithoutResult(var SaleId: Guid; var TransactionId: Text) EntryNo: Integer
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        SetMockNETSTransactionResponse(500, '{"error":"NETS Cloud unavailable"}');
        SaleId := CreateTestSale();
        TransactionId := PrepareEFTTransaction(SaleId);
        EntryNo := GetTransactionEntryNo(TransactionId);

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/' + TransactionId + '/cloud/start', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Start EFT should respond 200 even on system error');

        EFTTransactionRequest.Get(EntryNo);
        Assert.IsFalse(EFTTransactionRequest."External Result Known", 'Test setup: the result must be unknown after the failed start');
        Clear(_MockNETSRequests);
    end;

    local procedure PrepareOnNewSale(): JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        NewSaleId: Guid;
    begin
        NewSaleId := CreateTestSale();
        Body.Add('amount', _Item."Unit Price");
        exit(LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(NewSaleId) + '/eft/prepare', Body, QueryParams, Headers));
    end;

    local procedure MockNETSLookupPath(): Text
    begin
        exit('/v1/terminal/' + MockNETSTerminalId() + '/transaction');
    end;

    local procedure ResolveAllUnknownMockTerminalTransactions()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.SetRange("Hardware ID", MockNETSTerminalId());
        EFTTransactionRequest.SetFilter(Started, '<>%1', 0DT);
        EFTTransactionRequest.SetRange("External Result Known", false);
        EFTTransactionRequest.SetRange(Recovered, false);
        EFTTransactionRequest.ModifyAll(Recovered, true);
    end;

    local procedure AssertSignatureVoidCompletedWithoutError(TransactionId: Text)
    var
        Assert: Codeunit Assert;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTTransactionLog: Record "NPR EFT Transaction Log";
        LogInStream: InStream;
        LogContent: Text;
        TransactionGuid: Guid;
    begin
        Evaluate(TransactionGuid, TransactionId);
        EFTTransactionRequest.GetBySystemId(TransactionGuid);

        EFTTransactionLog.SetRange("Transaction Entry No.", EFTTransactionRequest."Entry No.");
        EFTTransactionLog.SetRange(Description, 'API Signature Void (Error)');
        if EFTTransactionLog.FindFirst() then begin
            EFTTransactionLog.CalcFields(Log);
            EFTTransactionLog.Log.CreateInStream(LogInStream);
            LogInStream.Read(LogContent);
            Assert.Fail('The signature void raised an error: ' + LogContent);
        end;

        VoidEFTTransactionRequest.SetRange("Processed Entry No.", EFTTransactionRequest."Entry No.");
        VoidEFTTransactionRequest.SetRange("Processing Type", VoidEFTTransactionRequest."Processing Type"::VOID);
        Assert.IsTrue(VoidEFTTransactionRequest.FindLast(), 'A void request should exist for the original transaction');
        Assert.AreEqual('', VoidEFTTransactionRequest."NST Error", 'The void request should carry no error');
        Assert.IsTrue(VoidEFTTransactionRequest."External Result Known", 'The void result should be known');
        Assert.IsTrue(VoidEFTTransactionRequest.Successful, 'The void should be successful');
    end;

    local procedure MockNETSTerminalId(): Text
    begin
        exit('12345678');
    end;

    local procedure CreateMockJwt(): Text
    begin
        exit(ToBase64Url('{"alg":"HS256","typ":"JWT"}') + '.' + ToBase64Url('{"exp":4102444800}') + '.' + ToBase64Url('signature'));
    end;

    local procedure ToBase64Url(Value: Text): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        exit(Base64Convert.ToBase64(Value).Replace('+', '-').Replace('/', '_').TrimEnd('='));
    end;

    local procedure GetMockNETSResultResponse(ResultCode: Integer; CVM: Integer): Text
    var
        ResponseJson: TextBuilder;
    begin
        ResponseJson.Append('{"result":[{');
        ResponseJson.Append('"localModeEventArgs":{');
        ResponseJson.Append('"Result":' + Format(ResultCode) + ',');
        ResponseJson.Append('"CVM":' + Format(CVM) + ',');
        ResponseJson.Append('"TruncatedPAN":"************1234",');
        ResponseJson.Append('"StanAuth":"654321",');
        ResponseJson.Append('"CardIssuerName":"Visa",');
        ResponseJson.Append('"AID":"A0000000031010",');
        ResponseJson.Append('"TotalAmount":10000,');
        ResponseJson.Append('"TimeStamp":"20240115143200",');
        ResponseJson.Append('"SessionNumber":"42",');
        ResponseJson.Append('"ResponseCode":"00"');
        ResponseJson.Append('},');
        ResponseJson.Append('"customerReceipt":"VISA ************1234\nNOK 100,00\nAPPROVED",');
        ResponseJson.Append('"merchantReceipt":"MERCHANT COPY\nNOK 100,00"');
        ResponseJson.Append('}]}');
        exit(ResponseJson.ToText());
    end;

    local procedure GetMockNETSFailureResponse(): Text
    var
        ResponseJson: TextBuilder;
    begin
        ResponseJson.Append('{"failure":{');
        ResponseJson.Append('"error":"Transaction declined",');
        ResponseJson.Append('"localModeEventArgs":{');
        ResponseJson.Append('"Result":2,');
        ResponseJson.Append('"CVM":0,');
        ResponseJson.Append('"TruncatedPAN":"************9999",');
        ResponseJson.Append('"TimeStamp":"20240115143200",');
        ResponseJson.Append('"ResponseCode":"05"');
        ResponseJson.Append('},');
        ResponseJson.Append('"customerReceipt":"VISA ************9999\nDECLINED"');
        ResponseJson.Append('}}');
        exit(ResponseJson.ToText());
    end;

    local procedure InitializeNETSCloudSetup()
    var
        EFTSetup: Record "NPR EFT Setup";
        EFTNETSCloudPaymentSetup: Record "NPR EFT NETS Cloud Paym. Setup";
        EFTNETSCloudUnitSetup: Record "NPR EFT NETSCloud Unit Setup";
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        EFTNETSCloudToken: Codeunit "NPR EFT NETSCloud Token";
    begin
        UseEFTIntegrationType(EFTNETSCloudIntegration.IntegrationType());

        if not EFTNETSCloudPaymentSetup.Get(_EFTPaymentMethodCode) then begin
            EFTNETSCloudPaymentSetup.Init();
            EFTNETSCloudPaymentSetup."Payment Type POS" := _EFTPaymentMethodCode;
            EFTNETSCloudPaymentSetup.Insert();
        end;
        EFTNETSCloudPaymentSetup."API Username" := 'nets-test-user';
        EFTNETSCloudPaymentSetup."API Password" := 'nets-test-password';
        EFTNETSCloudPaymentSetup.Environment := EFTNETSCloudPaymentSetup.Environment::TEST;
        EFTNETSCloudPaymentSetup."Log Level" := EFTNETSCloudPaymentSetup."Log Level"::FULL;
        EFTNETSCloudPaymentSetup.Modify();

        if not EFTNETSCloudUnitSetup.Get(_POSUnit."No.") then begin
            EFTNETSCloudUnitSetup.Init();
            EFTNETSCloudUnitSetup."POS Unit No." := _POSUnit."No.";
            EFTNETSCloudUnitSetup.Insert();
        end;
        EFTNETSCloudUnitSetup."Terminal ID" := CopyStr(MockNETSTerminalId(), 1, MaxStrLen(EFTNETSCloudUnitSetup."Terminal ID"));
        EFTNETSCloudUnitSetup.Modify();

        EFTSetup.Get(_EFTPaymentMethodCode, _POSUnit."No.");
        EFTNETSCloudToken.Invalidate(EFTSetup);
        ResolveAllUnknownMockTerminalTransactions();

        Clear(_MockNETSRequests);
        Commit();
    end;

    local procedure UseEFTIntegrationType(IntegrationType: Code[20])
    var
        EFTSetup: Record "NPR EFT Setup";
    begin
        if not EFTSetup.Get(_EFTPaymentMethodCode, _POSUnit."No.") then begin
            EFTSetup.Init();
            EFTSetup."Payment Type POS" := _EFTPaymentMethodCode;
            EFTSetup."POS Unit No." := _POSUnit."No.";
            EFTSetup.Insert();
        end;
        EFTSetup."EFT Integration Type" := IntegrationType;
        EFTSetup.Modify();
        Commit();
    end;

    local procedure PrepareEFTTransaction(SaleId: Guid) TransactionId: Text
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
    begin
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/eft/prepare', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Prepare EFT should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('transactionId', JToken);
        TransactionId := JToken.AsValue().AsText();
    end;

    local procedure GetSalePaymentTotal(SaleId: Guid): Decimal
    var
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSale.GetBySystemId(SaleId);
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"POS Payment");
        POSSaleLine.CalcSums("Amount Including VAT");
        exit(POSSaleLine."Amount Including VAT");
    end;

    local procedure GetStatusCode(Response: JsonObject): Integer
    var
        JToken: JsonToken;
    begin
        Response.Get('statusCode', JToken);
        exit(JToken.AsValue().AsInteger());
    end;

    local procedure GetErrorMessage(Response: JsonObject): Text
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        JToken: JsonToken;
    begin
        if not LibraryNPRetailAPI.GetResponseBody(Response).Get('message', JToken) then
            exit('');
        exit(JToken.AsValue().AsText());
    end;
}
#endif

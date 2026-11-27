#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85222 "NPR APIPOSUnit Open"
{
    // [FEATURE] POS Unit API — POST /pos/unit/:unitId/open opens a closed POS unit, GET /pos/unit/me returns the
    //           current unit's representation, plus closed-unit guards on mutating sale endpoints

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_ClosedUnit_TransitionsToOpen_Returns200()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Happy path — POST /pos/unit/{id}/open on a CLOSED unit transitions it to OPEN and returns 200.
        //             This is the core contract of the endpoint.
        Initialize();

        _POSUnit.Find();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        _POSUnit.Status := _POSUnit.Status::CLOSED;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open on CLOSED unit should succeed');

        _POSUnit.Find();
        Assert.AreEqual(_POSUnit.Status::OPEN, _POSUnit.Status, 'POS Unit should be OPEN after the open endpoint returns 200');

        // C1: an API-driven open of a CLOSED unit now produces an OPEN period register whose Opening Entry No. points
        // at the unit-open system POS entry — the same period-register and opening-entry writes as attended START_POS.
        // The API path omits the attended UI steps (Begin Workshift print, session start) and defers the commit to the
        // API framework so open + period repair stay atomic.
        AssertOpenPeriodLinkedToUnitOpenEntry(_POSUnit."No.");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_AlreadyOpenUnit_Returns200Idempotent()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        CountBefore: Integer;
    begin
        // [SCENARIO] Opening an already-OPEN unit that already has an OPEN period register is a pure no-op:
        //            200, and NO second period register is created.
        Initialize();

        _POSUnit.Find();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        POSPeriodRegister.Init();
        POSPeriodRegister."POS Unit No." := _POSUnit."No.";
        POSPeriodRegister."POS Store Code" := _POSUnit."POS Store Code";
        POSPeriodRegister.Status := POSPeriodRegister.Status::OPEN;
        POSPeriodRegister.Insert(true);
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();

        CountBefore := POSPeriodRegister.Count();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open on already-open unit should succeed');

        POSPeriodRegister.Reset();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        Assert.AreEqual(CountBefore, POSPeriodRegister.Count(), 'Idempotent open must not create a duplicate period register');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_OpenUnitMissingPeriod_RepairsPeriod_Returns200()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Unit Status is OPEN but it has NO open period register (the QA gap).
        //            Opening it must repair the period register, not just return 200.
        Initialize();

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open on OPEN-but-period-less unit should succeed');

        AssertOpenPeriodLinkedToUnitOpenEntry(_POSUnit."No.");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_OpenUnitLastPeriodClosed_RepairsPeriod_Returns200()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Unit OPEN, last period register is CLOSED -> must create a new OPEN register.
        Initialize();

        _POSUnit.Find();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        POSPeriodRegister.Init();
        POSPeriodRegister."POS Unit No." := _POSUnit."No.";
        POSPeriodRegister."POS Store Code" := _POSUnit."POS Store Code";
        POSPeriodRegister.Status := POSPeriodRegister.Status::CLOSED;
        POSPeriodRegister.Insert(true);
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open should succeed');

        AssertOpenPeriodLinkedToUnitOpenEntry(_POSUnit."No.");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_OpenUnitLastPeriodEOD_RepairsPeriod_Returns200()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        EODPeriodRegisterNo: Integer;
    begin
        // [SCENARIO] Unit OPEN, last period register is EOD -> must close it and create a new OPEN register.
        Initialize();

        _POSUnit.Find();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        POSPeriodRegister.Init();
        POSPeriodRegister."POS Unit No." := _POSUnit."No.";
        POSPeriodRegister."POS Store Code" := _POSUnit."POS Store Code";
        POSPeriodRegister.Status := POSPeriodRegister.Status::EOD;
        POSPeriodRegister.Insert(true);
        EODPeriodRegisterNo := POSPeriodRegister."No.";
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open should succeed');

        POSPeriodRegister.Get(EODPeriodRegisterNo);
        Assert.AreEqual(POSPeriodRegister.Status::CLOSED, POSPeriodRegister.Status, 'The existing EOD POS Period Register must be CLOSED after repair');

        AssertOpenPeriodLinkedToUnitOpenEntry(_POSUnit."No.");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_UnitWithoutZReportCheckpoint_CreatesBaseline()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        // [SCENARIO] A unit that has never been balanced has no closed ZREPORT workshift checkpoint. Attended
        //            START_POS seeds one before opening, so an API open must seed it too.
        Initialize();

        _POSUnit.Find();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", _POSUnit."No.");
        POSWorkshiftCheckpoint.DeleteAll();
        _POSUnit.Status := _POSUnit.Status::CLOSED;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open should succeed');

        POSWorkshiftCheckpoint.Reset();
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", _POSUnit."No.");
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        Assert.AreEqual(1, POSWorkshiftCheckpoint.Count(), 'Opening a never-balanced unit must seed exactly one closed ZREPORT checkpoint');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_UnitWithZReportCheckpoint_KeepsExistingBaseline()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ExistingCheckpointEntryNo: Integer;
    begin
        // [SCENARIO] A unit that already has a closed ZREPORT checkpoint must not get a second one — the baseline is
        //            what Z-report aggregation measures from, so seeding a duplicate would reset the period.
        Initialize();

        _POSUnit.Find();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", _POSUnit."No.");
        POSWorkshiftCheckpoint.DeleteAll();
        POSWorkshiftCheckpoint.Init();
        POSWorkshiftCheckpoint."Entry No." := 0;
        POSWorkshiftCheckpoint."POS Unit No." := _POSUnit."No.";
        POSWorkshiftCheckpoint.Open := false;
        POSWorkshiftCheckpoint.Type := POSWorkshiftCheckpoint.Type::ZREPORT;
        POSWorkshiftCheckpoint.Insert();
        ExistingCheckpointEntryNo := POSWorkshiftCheckpoint."Entry No.";
        _POSUnit.Status := _POSUnit.Status::CLOSED;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open should succeed');

        POSWorkshiftCheckpoint.Reset();
        POSWorkshiftCheckpoint.SetRange("POS Unit No.", _POSUnit."No.");
        POSWorkshiftCheckpoint.SetRange(Open, false);
        POSWorkshiftCheckpoint.SetRange(Type, POSWorkshiftCheckpoint.Type::ZREPORT);
        Assert.AreEqual(1, POSWorkshiftCheckpoint.Count(), 'Open must not seed a second ZREPORT checkpoint');
        POSWorkshiftCheckpoint.FindFirst();
        Assert.AreEqual(ExistingCheckpointEntryNo, POSWorkshiftCheckpoint."Entry No.", 'The pre-existing ZREPORT checkpoint must be the one kept');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_OpenUnitMissingPeriod_ThenSalePosts()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
    begin
        // [SCENARIO] After repairing a period-less OPEN unit via /open, a full sale (line + cash payment + complete)
        //            posts successfully — no "No open POS Period Register" error.
        Initialize();

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        Commit();

        // Repair via the endpoint under test.
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open should succeed');

        // Create sale.
        SaleId := CreateGuid();
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');

        // Line + cash payment + complete -> triggers posting (this is where ERR_NO_OPEN_UNIT used to fire).
        AddItemLineAndCompleteWithCash(SaleId);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sale_NoUserSetupSalesperson_PostsWithoutSalesperson()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
    begin
        // [SCENARIO] A salesperson is opt-in via the API user's User Setup. Without one, the posted sale has a blank
        //            salesperson, as before.
        Initialize();
        SetUserSetupSalesperson('');

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::CLOSED;
        _POSUnit.Modify();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open should succeed');

        SaleId := CreateGuid();
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');
        AddItemLineAndCompleteWithCash(SaleId);

        POSEntry.SetRange("POS Unit No.", _POSUnit."No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.FindLast();
        Assert.AreEqual('', POSEntry."Salesperson Code", 'Posted self-service sale should have no salesperson without a User Setup salesperson');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Sale_UserSetupSalesperson_IsUsed_AndIsReusedOnLaterRequests()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Salesperson: Record "Salesperson/Purchaser";
        POSSale: Record "NPR POS Sale";
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        SaleId: Guid;
    begin
        // [SCENARIO] A salesperson on the API user's User Setup is stamped on the sale and ends up on the posted POS entry.
        //            Later requests against the sale take the salesperson from the sale header, not from User Setup.
        Initialize();
        if not Salesperson.Get('APISSOVERRIDE') then begin
            Salesperson.Init();
            Salesperson.Code := 'APISSOVERRIDE';
            Salesperson.Name := 'Override';
            Salesperson.Insert();
        end;
        SetUserSetupSalesperson(Salesperson.Code);

        // Earlier tests close the shared unit and delete its periods; posting needs an open period.
        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::CLOSED;
        _POSUnit.Modify();
        POSPeriodRegister.SetRange("POS Unit No.", _POSUnit."No.");
        POSPeriodRegister.DeleteAll();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Open should succeed');

        SaleId := CreateGuid();
        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');
        POSSale.GetBySystemId(SaleId);
        Assert.AreEqual(Salesperson.Code, POSSale."Salesperson Code", 'User Setup salesperson should be used on the sale');

        // Simulate fresh requests: drop the single-instance session state and remove the User Setup salesperson.
        SetUserSetupSalesperson('');
        POSSession.ClearAll();
        AddItemLineAndCompleteWithCash(SaleId);

        POSEntry.SetRange("POS Unit No.", _POSUnit."No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        POSEntry.FindLast();
        Assert.AreEqual(Salesperson.Code, POSEntry."Salesperson Code", 'Posted POS entry should have the salesperson from the sale header');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_BlockedUserSetupSalesperson_Fails()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Salesperson: Record "Salesperson/Purchaser";
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ErrorText: Text;
    begin
        // [SCENARIO] A blocked User Setup salesperson stops new sales, like a blocked salesperson at an attended POS.
        Initialize();
        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        if not Salesperson.Get('APISSBLOCKED') then begin
            Salesperson.Init();
            Salesperson.Code := 'APISSBLOCKED';
            Salesperson.Insert();
        end;
        Salesperson.Blocked := true;
        Salesperson.Modify();
        SetUserSetupSalesperson(Salesperson.Code);

        asserterror LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        ErrorText := GetLastErrorText();

        // Clean up before asserting: this setup is committed and would otherwise leak into later tests.
        SetUserSetupSalesperson('');
        Assert.IsTrue(ErrorText.Contains('is blocked'), ErrorText);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_InactiveUnit_Returns400()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        Initialize();

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::INACTIVE;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(_POSUnit.SystemId) + '/open', Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'INACTIVE unit should return 400');

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Open_UnknownUnit_Returns404()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        Initialize();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/unit/' + FormatGuid(CreateGuid()) + '/open', Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(404, StatusCode, 'Unknown unit should return 404');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CreateSale_OnClosedUnit_Returns400()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        StatusCode: Integer;
    begin
        // [SCENARIO] CreateSale on a closed unit returns 400 (previously a TestField-style generic error).
        Initialize();

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::INACTIVE;
        _POSUnit.Modify();
        Commit();

        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'CreateSale on closed unit should return 400');

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UpdateSale_OnClosedUnit_Returns400()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        SaleId: Guid;
        StatusCode: Integer;
    begin
        Initialize();

        SaleId := CreateActiveSale();

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::INACTIVE;
        _POSUnit.Modify();
        Commit();

        Clear(Body);
        Body.Add('customerNo', '');
        Response := LibraryNPRetailAPI.CallApi('PATCH', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'UpdateSale on closed unit should return 400');

        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_ReturnsDigitalReceiptAndEftIntegrationType()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        DigitalRcptSetup: Record "NPR Digital Rcpt. Setup";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        SelfserviceProfileJson: JsonObject;
        JToken: JsonToken;
    begin
        // [SCENARIO] GET /pos/unit/me returns digitalReceiptEnabled and the selfservice EFT Integration Type
        Initialize();

        // [GIVEN] The global Digital Receipt Setup is enabled
        DigitalRcptSetup.Get();
        DigitalRcptSetup."Enable" := true;
        DigitalRcptSetup.Modify();

        // [WHEN] GET /pos/unit/me
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/unit/me', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /pos/unit/me should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);

        // [THEN] digitalReceiptEnabled should be true
        Assert.IsTrue(ResponseBody.Get('digitalReceiptEnabled', JToken), 'Response should contain digitalReceiptEnabled');
        Assert.IsTrue(JToken.AsValue().AsBoolean(), 'digitalReceiptEnabled should be true when the receipt profile and the global setup are both enabled');

        // [THEN] selfserviceProfile should carry the EFT Integration Type of the POS Unit
        Assert.IsTrue(ResponseBody.Get('selfserviceProfile', JToken), 'Response should contain selfserviceProfile');
        SelfserviceProfileJson := JToken.AsObject();
        Assert.IsTrue(SelfserviceProfileJson.Get('selfserviceCardEftIntegrationType', JToken), 'selfserviceProfile should contain selfserviceCardEftIntegrationType');
        Assert.AreEqual(EFTAdyenIntegration.CloudIntegrationType(), JToken.AsValue().AsText(), 'selfserviceCardEftIntegrationType should match the EFT Setup of the POS Unit');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_ReturnsSelfserviceCardEftFlowPerIntegrationType()
    var
        Assert: Codeunit Assert;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        EFTNETSCloudIntegration: Codeunit "NPR EFT NETSCloud Integrat.";
        JToken: JsonToken;
    begin
        Initialize();

        SetSelfserviceEFTIntegrationType(EFTAdyenIntegration.CloudIntegrationType());
        JToken := GetCurrentPOSUnitSelfserviceCardEftFlow();
        Assert.AreEqual('cloud', JToken.AsValue().AsText(), 'Adyen Cloud should report the cloud flow');

        SetSelfserviceEFTIntegrationType(EFTNETSCloudIntegration.IntegrationType());
        JToken := GetCurrentPOSUnitSelfserviceCardEftFlow();
        Assert.AreEqual('cloud', JToken.AsValue().AsText(), 'NETS Cloud should report the cloud flow');

        SetSelfserviceEFTIntegrationType(EFTAdyenIntegration.MposTapToPayIntegrationType());
        JToken := GetCurrentPOSUnitSelfserviceCardEftFlow();
        Assert.AreEqual('local', JToken.AsValue().AsText(), 'Adyen Tap to Pay should report the local flow');

        SetSelfserviceEFTIntegrationType('NETS_BAXI_NET');
        JToken := GetCurrentPOSUnitSelfserviceCardEftFlow();
        Assert.IsTrue(JToken.AsValue().IsNull(), 'An integration type without self-service API support should report a null flow');

        SetSelfserviceEFTIntegrationType(EFTAdyenIntegration.CloudIntegrationType());
    end;

    local procedure GetCurrentPOSUnitSelfserviceCardEftFlow() JToken: JsonToken
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        SelfserviceProfileJson: JsonObject;
    begin
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/unit/me', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /pos/unit/me should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('selfserviceProfile', JToken), 'Response should contain selfserviceProfile');
        SelfserviceProfileJson := JToken.AsObject();
        Assert.IsTrue(SelfserviceProfileJson.Get('selfserviceCardEftFlow', JToken), 'selfserviceProfile should always contain selfserviceCardEftFlow');
    end;

    local procedure SetSelfserviceEFTIntegrationType(IntegrationType: Code[20])
    var
        SSProfile: Record "NPR SS Profile";
        EFTSetup: Record "NPR EFT Setup";
    begin
        SSProfile.Get(_POSUnit."POS Self Service Profile");
        EFTSetup.Get(SSProfile."Selfservice Card Payment Meth.", _POSUnit."No.");
        EFTSetup."EFT Integration Type" := IntegrationType;
        EFTSetup.Modify();
        Commit();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_GlobalDigitalReceiptDisabled_ReturnsFalse()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        DigitalRcptSetup: Record "NPR Digital Rcpt. Setup";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
    begin
        // [SCENARIO] digitalReceiptEnabled is false when the global Digital Receipt Setup is disabled
        Initialize();

        // [GIVEN] The receipt profile is enabled but the global setup is disabled
        DigitalRcptSetup.Get();
        DigitalRcptSetup."Enable" := false;
        DigitalRcptSetup.Modify();

        // [WHEN] GET /pos/unit/me
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/unit/me', Body, QueryParams, Headers);

        // [THEN] digitalReceiptEnabled should be false
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /pos/unit/me should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('digitalReceiptEnabled', JToken), 'Response should contain digitalReceiptEnabled');
        Assert.IsFalse(JToken.AsValue().AsBoolean(), 'digitalReceiptEnabled should be false when the global Digital Receipt Setup is disabled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Card_UserSetupsDisagree_ShowsVariesPerUserSetup()
    var
        Salesperson: Record "Salesperson/Purchaser";
        OtherUserSetup: Record "User Setup";
        Assert: Codeunit Assert;
        POSUnitCard: TestPage "NPR POS Unit Card";
        OtherUserId: Code[50];
    begin
        // [SCENARIO] Two API users share a self-service unit. The card shows a single salesperson only when both
        //            have the same one on User Setup; one set and one blank is "Varies".
        Initialize();
        if not Salesperson.Get('SSCARDTEST') then begin
            Salesperson.Init();
            Salesperson.Code := 'SSCARDTEST';
            Salesperson.Insert();
        end;
        SetUserSetupSalesperson('SSCARDTEST');
        OtherUserId := 'SSCARD-OTHER-API-USER';
        if OtherUserSetup.Get(OtherUserId) then
            OtherUserSetup.Delete();
        OtherUserSetup.Init();
        OtherUserSetup."User ID" := OtherUserId;
        OtherUserSetup."NPR POS Unit No." := _POSUnit."No.";
        OtherUserSetup.Insert();
        Commit();

        // [THEN] One override, one blank: the users get different salespeople
        POSUnitCard.OpenView();
        POSUnitCard.GoToRecord(_POSUnit);
        Assert.AreEqual('Varies per User Setup', POSUnitCard.SelfServiceSalesperson.Value(), 'Different effective salespeople must show as varying');
        POSUnitCard.Close();

        // [THEN] Same override on both: that code is shown
        OtherUserSetup."Salespers./Purch. Code" := 'SSCARDTEST';
        OtherUserSetup.Modify();
        Commit();
        POSUnitCard.OpenView();
        POSUnitCard.GoToRecord(_POSUnit);
        Assert.AreEqual('SSCARDTEST', POSUnitCard.SelfServiceSalesperson.Value(), 'A shared override must be shown');
        POSUnitCard.Close();

        // [THEN] No salesperson on any User Setup: shown as none
        OtherUserSetup.Delete();
        SetUserSetupSalesperson('');
        POSUnitCard.OpenView();
        POSUnitCard.GoToRecord(_POSUnit);
        Assert.AreEqual('(none)', POSUnitCard.SelfServiceSalesperson.Value(), 'No salesperson must be shown as none');
        POSUnitCard.Close();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_UnitRestaurantProfile_ReturnsRestaurantCode()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        JToken: JsonToken;
    begin
        Initialize();
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        SetRestaurantProfiles(POSRestProfile.Code, '');

        JToken := GetCurrentPOSUnitRestaurantCode();

        Assert.AreEqual(Restaurant.Code, JToken.AsValue().AsText(), 'restaurantCode should come from the POS Unit restaurant profile');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_StoreRestaurantProfile_ReturnsRestaurantCode()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        JToken: JsonToken;
    begin
        Initialize();
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        SetRestaurantProfiles('', POSRestProfile.Code);

        JToken := GetCurrentPOSUnitRestaurantCode();

        Assert.AreEqual(Restaurant.Code, JToken.AsValue().AsText(), 'restaurantCode should come from the POS Store restaurant profile');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_NoRestaurantProfile_ReturnsNull()
    var
        Assert: Codeunit Assert;
        JToken: JsonToken;
    begin
        Initialize();
        SetRestaurantProfiles('', '');

        JToken := GetCurrentPOSUnitRestaurantCode();

        Assert.IsTrue(JToken.AsValue().IsNull(), 'restaurantCode should be null when neither the unit nor the store has a restaurant profile');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_ProfileWithoutRestaurant_ReturnsNull()
    var
        Assert: Codeunit Assert;
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        StoreRestaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        StoreRestProfile: Record "NPR POS NPRE Rest. Profile";
        JToken: JsonToken;
    begin
        Initialize();
        LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, '');
        CreateRestaurantWithProfile(StoreRestaurant, StoreRestProfile);
        SetRestaurantProfiles(POSRestProfile.Code, StoreRestProfile.Code);

        JToken := GetCurrentPOSUnitRestaurantCode();

        Assert.IsTrue(JToken.AsValue().IsNull(), 'restaurantCode should be null when the unit profile has no Restaurant Code, without falling back to the store profile');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_UnitAndStoreProfiles_PrefersUnit()
    var
        Assert: Codeunit Assert;
        UnitRestaurant: Record "NPR NPRE Restaurant";
        StoreRestaurant: Record "NPR NPRE Restaurant";
        UnitRestProfile: Record "NPR POS NPRE Rest. Profile";
        StoreRestProfile: Record "NPR POS NPRE Rest. Profile";
        JToken: JsonToken;
    begin
        Initialize();
        CreateRestaurantWithProfile(UnitRestaurant, UnitRestProfile);
        CreateRestaurantWithProfile(StoreRestaurant, StoreRestProfile);
        SetRestaurantProfiles(UnitRestProfile.Code, StoreRestProfile.Code);

        JToken := GetCurrentPOSUnitRestaurantCode();

        Assert.AreEqual(UnitRestaurant.Code, JToken.AsValue().AsText(), 'restaurantCode should come from the POS Unit profile when both the unit and the store have one');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_UnitRestaurantProfile_ReturnsTakeAwayVatAndSeatingCodes()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        ResponseBody: JsonObject;
    begin
        Initialize();
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        FillSelfServiceFields(POSRestProfile);
        SetRestaurantProfiles(POSRestProfile.Code, '');

        ResponseBody := GetCurrentPOSUnitBody();

        AssertSelfServiceFields(ResponseBody, POSRestProfile);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_StoreRestaurantProfile_ReturnsTakeAwayVatAndSeatingCodes()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        ResponseBody: JsonObject;
    begin
        Initialize();
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        FillSelfServiceFields(POSRestProfile);
        SetRestaurantProfiles('', POSRestProfile.Code);

        ResponseBody := GetCurrentPOSUnitBody();

        AssertSelfServiceFields(ResponseBody, POSRestProfile);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_NoRestaurantProfile_ReturnsNullVatAndSeatingCodes()
    var
        ResponseBody: JsonObject;
    begin
        Initialize();
        SetRestaurantProfiles('', '');

        ResponseBody := GetCurrentPOSUnitBody();

        // Also dineInVatBusinessPostingGroup, although the store's POS Posting Profile has a VAT group
        AssertSelfServiceFieldsAreNull(ResponseBody);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_ProfileWithBlankFields_ReturnsNullWithoutStoreFallback()
    var
        UnitRestaurant: Record "NPR NPRE Restaurant";
        StoreRestaurant: Record "NPR NPRE Restaurant";
        UnitRestProfile: Record "NPR POS NPRE Rest. Profile";
        StoreRestProfile: Record "NPR POS NPRE Rest. Profile";
        ResponseBody: JsonObject;
    begin
        Initialize();
        CreateRestaurantWithProfile(UnitRestaurant, UnitRestProfile);
        CreateRestaurantWithProfile(StoreRestaurant, StoreRestProfile);
        FillSelfServiceFields(StoreRestProfile);
        SetRestaurantProfiles(UnitRestProfile.Code, StoreRestProfile.Code);

        ResponseBody := GetCurrentPOSUnitBody();

        AssertSelfServiceFieldsAreNull(ResponseBody);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_DineInVatGroup_ComesFromRestaurantProfileNotPostingProfile()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        JToken: JsonToken;
    begin
        Initialize();
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        FillSelfServiceFields(POSRestProfile);
        SetRestaurantProfiles(POSRestProfile.Code, '');
        _POSStore.Find();
        POSPostingProfile.Get(_POSStore."POS Posting Profile");
        Assert.AreNotEqual('', POSPostingProfile."VAT Bus. Posting Group", 'Test setup: the store''s POS Posting Profile should have a VAT Bus. Posting Group');
        Assert.AreNotEqual(POSPostingProfile."VAT Bus. Posting Group", POSRestProfile."Dine-in VAT Bus. Post. Group", 'Test setup: the two VAT groups should differ');

        JToken := GetProperty(GetCurrentPOSUnitBody(), 'dineInVatBusinessPostingGroup');

        Assert.AreEqual(POSRestProfile."Dine-in VAT Bus. Post. Group", JToken.AsValue().AsText(), 'dineInVatBusinessPostingGroup should come from the restaurant profile, not from the POS Posting Profile');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GetCurrentPOSUnit_TakeAwayOnlyProfile_ReturnsNullDineInVatGroup()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        ResponseBody: JsonObject;
    begin
        // A venue without dine-in leaves the field blank, even though the store's POS Posting Profile has a VAT group
        Initialize();
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        FillSelfServiceFields(POSRestProfile);
        POSRestProfile.Validate("Dine-in VAT Bus. Post. Group", '');
        POSRestProfile.Modify();
        SetRestaurantProfiles(POSRestProfile.Code, '');

        ResponseBody := GetCurrentPOSUnitBody();

        Assert.IsTrue(GetProperty(ResponseBody, 'dineInVatBusinessPostingGroup').AsValue().IsNull(), 'dineInVatBusinessPostingGroup should be null when the restaurant profile has no dine-in VAT group');
        Assert.AreEqual(POSRestProfile."Take-away VAT Bus. Post. Group", GetProperty(ResponseBody, 'takeAwayVatBusinessPostingGroup').AsValue().AsText(), 'takeAwayVatBusinessPostingGroup should still be returned');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantProfile_SeatingOfOtherRestaurant_CannotBeSet()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        OtherRestaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        OtherPOSRestProfile: Record "NPR POS NPRE Rest. Profile";
        Seating: Record "NPR NPRE Seating";
        OtherDineInSeatingCode: Code[20];
        OtherTakeAwaySeatingCode: Code[20];
        OtherPickUpSeatingCode: Code[20];
        SeatingOfOtherRestaurantErr: Label '%1 %2 does not belong to %3 %4.', Locked = true;
    begin
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        CreateRestaurantWithProfile(OtherRestaurant, OtherPOSRestProfile);
        // A different seating per field, so each error can only come from that field's own check
        OtherDineInSeatingCode := CreateSeatingOfRestaurant(OtherRestaurant.Code);
        OtherTakeAwaySeatingCode := CreateSeatingOfRestaurant(OtherRestaurant.Code);
        OtherPickUpSeatingCode := CreateSeatingOfRestaurant(OtherRestaurant.Code);
        Commit(); // asserterror rolls back; keep the setup for all three checks

        // asserterror does not reset the record variable, so re-read the profile before each check
        POSRestProfile.Find();
        asserterror POSRestProfile.Validate("Dine-in Seating Code", OtherDineInSeatingCode);
        Assert.ExpectedError(StrSubstNo(SeatingOfOtherRestaurantErr, Seating.TableCaption(), OtherDineInSeatingCode, Restaurant.TableCaption(), Restaurant.Code));
        POSRestProfile.Find();
        asserterror POSRestProfile.Validate("Take-away Seating Code", OtherTakeAwaySeatingCode);
        Assert.ExpectedError(StrSubstNo(SeatingOfOtherRestaurantErr, Seating.TableCaption(), OtherTakeAwaySeatingCode, Restaurant.TableCaption(), Restaurant.Code));
        POSRestProfile.Find();
        asserterror POSRestProfile.Validate("Pick-up Seating Code", OtherPickUpSeatingCode);
        Assert.ExpectedError(StrSubstNo(SeatingOfOtherRestaurantErr, Seating.TableCaption(), OtherPickUpSeatingCode, Restaurant.TableCaption(), Restaurant.Code));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantProfile_BlockedSeating_CannotBeSet()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        Seating: Record "NPR NPRE Seating";
    begin
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        Seating.Get(CreateSeatingOfRestaurant(Restaurant.Code));
        Seating.Blocked := true;
        Seating.Modify();

        asserterror POSRestProfile.Validate("Dine-in Seating Code", Seating.Code);
        Assert.ExpectedTestFieldError(Seating.FieldCaption(Blocked), Format(false));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantProfile_ChangeRestaurant_ClearsSeatingsOfOldRestaurant()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        NewRestaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        NewPOSRestProfile: Record "NPR POS NPRE Rest. Profile";
        TakeAwayVATBusPostingGroup: Code[20];
        DineInVATBusPostingGroup: Code[20];
    begin
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        CreateRestaurantWithProfile(NewRestaurant, NewPOSRestProfile);
        FillSelfServiceFields(POSRestProfile);
        TakeAwayVATBusPostingGroup := POSRestProfile."Take-away VAT Bus. Post. Group";
        DineInVATBusPostingGroup := POSRestProfile."Dine-in VAT Bus. Post. Group";

        POSRestProfile.Validate("Restaurant Code", NewRestaurant.Code);

        Assert.AreEqual('', POSRestProfile."Dine-in Seating Code", 'Dine-in Seating Code of the old restaurant should be cleared');
        Assert.AreEqual('', POSRestProfile."Take-away Seating Code", 'Take-away Seating Code of the old restaurant should be cleared');
        Assert.AreEqual('', POSRestProfile."Pick-up Seating Code", 'Pick-up Seating Code of the old restaurant should be cleared');
        Assert.AreEqual(TakeAwayVATBusPostingGroup, POSRestProfile."Take-away VAT Bus. Post. Group", 'Changing the restaurant should not change the take-away VAT group');
        Assert.AreEqual(DineInVATBusPostingGroup, POSRestProfile."Dine-in VAT Bus. Post. Group", 'Changing the restaurant should not change the dine-in VAT group');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantProfile_RestaurantSetAfterSeatings_KeepsSeatingsOfThatRestaurant()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        OtherRestaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        OtherPOSRestProfile: Record "NPR POS NPRE Rest. Profile";
        DineInSeatingCode: Code[20];
        PickUpSeatingCode: Code[20];
        OtherSeatingCode: Code[20];
    begin
        // Seatings can be set while the restaurant is blank; setting the restaurant keeps its own and clears the others
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        CreateRestaurantWithProfile(OtherRestaurant, OtherPOSRestProfile);
        DineInSeatingCode := CreateSeatingOfRestaurant(Restaurant.Code);
        PickUpSeatingCode := CreateSeatingOfRestaurant(Restaurant.Code);
        OtherSeatingCode := CreateSeatingOfRestaurant(OtherRestaurant.Code);
        POSRestProfile."Restaurant Code" := '';
        POSRestProfile.Modify();

        POSRestProfile.Validate("Dine-in Seating Code", DineInSeatingCode);
        POSRestProfile.Validate("Take-away Seating Code", OtherSeatingCode);
        POSRestProfile.Validate("Pick-up Seating Code", PickUpSeatingCode);
        POSRestProfile.Validate("Restaurant Code", Restaurant.Code);

        Assert.AreEqual(DineInSeatingCode, POSRestProfile."Dine-in Seating Code", 'A dine-in seating of the restaurant should be kept when the restaurant is set');
        Assert.AreEqual('', POSRestProfile."Take-away Seating Code", 'A take-away seating of another restaurant should be cleared when the restaurant is set');
        Assert.AreEqual(PickUpSeatingCode, POSRestProfile."Pick-up Seating Code", 'A pick-up seating of the restaurant should be kept when the restaurant is set');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantProfile_RestaurantSetAfterSeatings_KeepsTakeAwayAndClearsOthers()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        OtherRestaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        OtherPOSRestProfile: Record "NPR POS NPRE Rest. Profile";
        TakeAwaySeatingCode: Code[20];
        OtherDineInSeatingCode: Code[20];
        OtherPickUpSeatingCode: Code[20];
    begin
        // Mirror of the test above, so the keep and the clear path are each covered for every seating field
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        CreateRestaurantWithProfile(OtherRestaurant, OtherPOSRestProfile);
        TakeAwaySeatingCode := CreateSeatingOfRestaurant(Restaurant.Code);
        OtherDineInSeatingCode := CreateSeatingOfRestaurant(OtherRestaurant.Code);
        OtherPickUpSeatingCode := CreateSeatingOfRestaurant(OtherRestaurant.Code);
        POSRestProfile."Restaurant Code" := '';
        POSRestProfile.Modify();

        POSRestProfile.Validate("Dine-in Seating Code", OtherDineInSeatingCode);
        POSRestProfile.Validate("Take-away Seating Code", TakeAwaySeatingCode);
        POSRestProfile.Validate("Pick-up Seating Code", OtherPickUpSeatingCode);
        POSRestProfile.Validate("Restaurant Code", Restaurant.Code);

        Assert.AreEqual('', POSRestProfile."Dine-in Seating Code", 'A dine-in seating of another restaurant should be cleared when the restaurant is set');
        Assert.AreEqual(TakeAwaySeatingCode, POSRestProfile."Take-away Seating Code", 'A take-away seating of the restaurant should be kept when the restaurant is set');
        Assert.AreEqual('', POSRestProfile."Pick-up Seating Code", 'A pick-up seating of another restaurant should be cleared when the restaurant is set');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RestaurantProfile_ChangeRestaurantAndSeatingsInFieldOrder_Succeeds()
    var
        Assert: Codeunit Assert;
        Restaurant: Record "NPR NPRE Restaurant";
        NewRestaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        NewPOSRestProfile: Record "NPR POS NPRE Rest. Profile";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        NewValues: Dictionary of [Integer, Code[20]];
        FieldNumber: Integer;
    begin
        // An import that updates an existing profile validates the changed fields in field number order
        CreateRestaurantWithProfile(Restaurant, POSRestProfile);
        CreateRestaurantWithProfile(NewRestaurant, NewPOSRestProfile);
        FillSelfServiceFields(POSRestProfile);
        NewValues.Add(POSRestProfile.FieldNo("Restaurant Code"), NewRestaurant.Code);
        NewValues.Add(POSRestProfile.FieldNo("Dine-in Seating Code"), CreateSeatingOfRestaurant(NewRestaurant.Code));
        NewValues.Add(POSRestProfile.FieldNo("Take-away Seating Code"), CreateSeatingOfRestaurant(NewRestaurant.Code));
        NewValues.Add(POSRestProfile.FieldNo("Pick-up Seating Code"), CreateSeatingOfRestaurant(NewRestaurant.Code));

        RecRef.GetTable(POSRestProfile);
        for FieldNumber := 1 to 1000 do
            if NewValues.ContainsKey(FieldNumber) then begin
                FieldRef := RecRef.Field(FieldNumber);
                FieldRef.Validate(NewValues.Get(FieldNumber));
            end;
        RecRef.SetTable(POSRestProfile);

        Assert.AreEqual(NewRestaurant.Code, POSRestProfile."Restaurant Code", 'Restaurant Code should be updated');
        Assert.AreEqual(NewValues.Get(POSRestProfile.FieldNo("Dine-in Seating Code")), POSRestProfile."Dine-in Seating Code", 'Dine-in Seating Code should be updated to the new restaurant''s seating');
        Assert.AreEqual(NewValues.Get(POSRestProfile.FieldNo("Take-away Seating Code")), POSRestProfile."Take-away Seating Code", 'Take-away Seating Code should be updated to the new restaurant''s seating');
        Assert.AreEqual(NewValues.Get(POSRestProfile.FieldNo("Pick-up Seating Code")), POSRestProfile."Pick-up Seating Code", 'Pick-up Seating Code should be updated to the new restaurant''s seating');
    end;

    local procedure CreateSeatingOfRestaurant(RestaurantCode: Code[20]): Code[20]
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
    begin
        LibraryRestaurant.CreateSeatingLocation(SeatingLocation, RestaurantCode);
        LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        exit(Seating.Code);
    end;

    local procedure FillSelfServiceFields(var POSRestProfile: Record "NPR POS NPRE Rest. Profile")
    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        DineInVATBusPostingGroup: Record "VAT Business Posting Group";
        VATBusPostingGroup: Record "VAT Business Posting Group";
        SeatingLocation: Record "NPR NPRE Seating Location";
        DineInSeating: Record "NPR NPRE Seating";
        TakeAwaySeating: Record "NPR NPRE Seating";
        PickUpSeating: Record "NPR NPRE Seating";
    begin
        LibraryERM.CreateVATBusinessPostingGroup(DineInVATBusPostingGroup);
        LibraryERM.CreateVATBusinessPostingGroup(VATBusPostingGroup);
        LibraryRestaurant.CreateSeatingLocation(SeatingLocation, POSRestProfile."Restaurant Code");
        LibraryRestaurant.CreateSeating(DineInSeating, SeatingLocation.Code);
        LibraryRestaurant.CreateSeating(TakeAwaySeating, SeatingLocation.Code);
        LibraryRestaurant.CreateSeating(PickUpSeating, SeatingLocation.Code);

        POSRestProfile.Validate("Dine-in VAT Bus. Post. Group", DineInVATBusPostingGroup.Code);
        POSRestProfile.Validate("Take-away VAT Bus. Post. Group", VATBusPostingGroup.Code);
        POSRestProfile.Validate("Dine-in Seating Code", DineInSeating.Code);
        POSRestProfile.Validate("Take-away Seating Code", TakeAwaySeating.Code);
        POSRestProfile.Validate("Pick-up Seating Code", PickUpSeating.Code);
        POSRestProfile.Modify();
    end;

    local procedure AssertSelfServiceFields(ResponseBody: JsonObject; POSRestProfile: Record "NPR POS NPRE Rest. Profile")
    var
        Assert: Codeunit Assert;
    begin
        Assert.AreEqual(POSRestProfile."Dine-in VAT Bus. Post. Group", GetProperty(ResponseBody, 'dineInVatBusinessPostingGroup').AsValue().AsText(), 'dineInVatBusinessPostingGroup should come from the restaurant profile');
        Assert.AreEqual(POSRestProfile."Take-away VAT Bus. Post. Group", GetProperty(ResponseBody, 'takeAwayVatBusinessPostingGroup').AsValue().AsText(), 'takeAwayVatBusinessPostingGroup should come from the restaurant profile');
        Assert.AreEqual(POSRestProfile."Dine-in Seating Code", GetProperty(ResponseBody, 'dineInSeatingCode').AsValue().AsText(), 'dineInSeatingCode should come from the restaurant profile');
        Assert.AreEqual(POSRestProfile."Take-away Seating Code", GetProperty(ResponseBody, 'takeAwaySeatingCode').AsValue().AsText(), 'takeAwaySeatingCode should come from the restaurant profile');
        Assert.AreEqual(POSRestProfile."Pick-up Seating Code", GetProperty(ResponseBody, 'pickUpSeatingCode').AsValue().AsText(), 'pickUpSeatingCode should come from the restaurant profile');
    end;

    local procedure AssertSelfServiceFieldsAreNull(ResponseBody: JsonObject)
    var
        Assert: Codeunit Assert;
    begin
        Assert.IsTrue(GetProperty(ResponseBody, 'dineInVatBusinessPostingGroup').AsValue().IsNull(), 'dineInVatBusinessPostingGroup should be null');
        Assert.IsTrue(GetProperty(ResponseBody, 'takeAwayVatBusinessPostingGroup').AsValue().IsNull(), 'takeAwayVatBusinessPostingGroup should be null');
        Assert.IsTrue(GetProperty(ResponseBody, 'dineInSeatingCode').AsValue().IsNull(), 'dineInSeatingCode should be null');
        Assert.IsTrue(GetProperty(ResponseBody, 'takeAwaySeatingCode').AsValue().IsNull(), 'takeAwaySeatingCode should be null');
        Assert.IsTrue(GetProperty(ResponseBody, 'pickUpSeatingCode').AsValue().IsNull(), 'pickUpSeatingCode should be null');
    end;

    local procedure GetProperty(ResponseBody: JsonObject; PropertyName: Text) JToken: JsonToken
    var
        Assert: Codeunit Assert;
    begin
        Assert.IsTrue(ResponseBody.Get(PropertyName, JToken), StrSubstNo('Response should contain %1', PropertyName));
    end;

    local procedure GetCurrentPOSUnitBody() ResponseBody: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Response := LibraryNPRetailAPI.CallApi('GET', '/pos/unit/me', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'GET /pos/unit/me should succeed');
        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
    end;

    local procedure CreateRestaurantWithProfile(var Restaurant: Record "NPR NPRE Restaurant"; var POSRestProfile: Record "NPR POS NPRE Rest. Profile")
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, Restaurant.Code);
    end;

    local procedure SetRestaurantProfiles(UnitProfileCode: Code[20]; StoreProfileCode: Code[20])
    begin
        _POSUnit.Find();
        _POSUnit."POS Restaurant Profile" := UnitProfileCode;
        _POSUnit.Modify();
        _POSStore.Find();
        _POSStore."POS Restaurant Profile" := StoreProfileCode;
        _POSStore.Modify();
        Commit();
    end;

    local procedure GetCurrentPOSUnitRestaurantCode(): JsonToken
    begin
        exit(GetProperty(GetCurrentPOSUnitBody(), 'restaurantCode'));
    end;

    local procedure Initialize()
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        UserSetup: Record "User Setup";
        DigitalRcptSetup: Record "NPR Digital Rcpt. Setup";
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
    begin
        if _Initialized then begin
            SetSelfserviceEFTIntegrationType(EFTAdyenIntegration.CloudIntegrationType());
            exit;
        end;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API POS');

        LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        LibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        LibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        LibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);
        _POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
        _POSUnit.Modify();

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();

        LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);

        // Digital receipt enabled on both levels — the POS Unit's receipt profile and the global setup
        if not POSReceiptProfile.Get('APIUNIT') then begin
            POSReceiptProfile.Init();
            POSReceiptProfile.Code := 'APIUNIT';
            POSReceiptProfile.Description := 'POS Unit API Test Profile';
            POSReceiptProfile.Insert();
        end;
        POSReceiptProfile."Enable Digital Receipt" := true;
        POSReceiptProfile.Modify();

        _POSUnit."POS Receipt Profile" := POSReceiptProfile.Code;
        _POSUnit.Modify();

        if not DigitalRcptSetup.Get() then begin
            DigitalRcptSetup.Init();
            DigitalRcptSetup.Insert();
        end;
        DigitalRcptSetup."Enable" := true;
        DigitalRcptSetup.Modify();

        SetupSelfserviceEFTPaymentMethod();

        CreateCleanupJobQueueEntry();

        _Initialized := true;
        Commit();
    end;

    local procedure SetupSelfserviceEFTPaymentMethod()
    var
        LibraryEFT: Codeunit "NPR Library - EFT";
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        POSPaymentMethod: Record "NPR POS Payment Method";
        SSProfile: Record "NPR SS Profile";
        EFTSetup: Record "NPR EFT Setup";
    begin
        // Must be Processing Type EFT, otherwise the endpoint omits selfserviceCardEftIntegrationType
        POSPaymentMethod.SetRange("Processing Type", POSPaymentMethod."Processing Type"::EFT);
        if not POSPaymentMethod.FindFirst() then
            LibraryEFT.CreateEFTPaymentTypePOS(POSPaymentMethod, _POSUnit, _POSStore);

        if not SSProfile.Get('APIUNIT') then begin
            SSProfile.Init();
            SSProfile.Code := 'APIUNIT';
            SSProfile.Description := 'POS Unit API Test Profile';
            SSProfile.Insert();
        end;
        SSProfile."Selfservice Card Payment Meth." := POSPaymentMethod.Code;
        SSProfile.Modify();

        _POSUnit."POS Self Service Profile" := SSProfile.Code;
        _POSUnit.Modify();

        if not EFTSetup.Get(POSPaymentMethod.Code, _POSUnit."No.") then begin
            EFTSetup.Init();
            EFTSetup."Payment Type POS" := POSPaymentMethod.Code;
            EFTSetup."POS Unit No." := _POSUnit."No.";
            EFTSetup."EFT Integration Type" := EFTAdyenIntegration.CloudIntegrationType();
            EFTSetup.Insert();
        end else begin
            EFTSetup."EFT Integration Type" := EFTAdyenIntegration.CloudIntegrationType();
            EFTSetup.Modify();
        end;
    end;

    local procedure CreateActiveSale() SaleId: Guid
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        _POSUnit.Find();
        _POSUnit.Status := _POSUnit.Status::OPEN;
        _POSUnit.Modify();
        Commit();

        SaleId := CreateGuid();
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Create sale should succeed');
    end;

    local procedure AddItemLineAndCompleteWithCash(SaleId: Guid)
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        CashPaymentMethod: Record "NPR POS Payment Method";
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('type', 'Item');
        Body.Add('code', _Item."No.");
        Body.Add('quantity', 1);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/saleline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Add sale line should succeed');

        CashPaymentMethod.SetRange("Processing Type", CashPaymentMethod."Processing Type"::CASH);
        CashPaymentMethod.FindFirst();
        Clear(Body);
        Body.Add('paymentMethodCode', CashPaymentMethod.Code);
        Body.Add('paymentType', 'Cash');
        Body.Add('amount', _Item."Unit Price");
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/paymentline/' + FormatGuid(CreateGuid()), Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Add payment line should succeed');

        Clear(Body);
        Response := LibraryNPRetailAPI.CallApi('POST', '/pos/sale/' + FormatGuid(SaleId) + '/complete', Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Complete sale should succeed');
    end;

    local procedure SetUserSetupSalesperson(SalespersonCode: Code[20])
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId());
        UserSetup."Salespers./Purch. Code" := SalespersonCode;
        UserSetup.Modify();
        Commit();
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

    local procedure AssertOpenPeriodLinkedToUnitOpenEntry(POSUnitNo: Code[10])
    var
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        Assert: Codeunit Assert;
    begin
        POSPeriodRegister.SetRange("POS Unit No.", POSUnitNo);
        POSPeriodRegister.SetRange(Status, POSPeriodRegister.Status::OPEN);
        Assert.AreEqual(1, POSPeriodRegister.Count(), 'Exactly one OPEN period register expected after open');
        POSPeriodRegister.FindLast();
        Assert.AreNotEqual(0, POSPeriodRegister."Opening Entry No.", 'Opening Entry No. must be set (non-zero)');

        POSEntry.SetRange("POS Unit No.", POSUnitNo);
        POSEntry.SetRange("System Entry", true);
        POSEntry.SetRange("Entry No.", POSPeriodRegister."Opening Entry No.");
        Assert.IsFalse(POSEntry.IsEmpty(), 'Opening Entry No. must point at the unit-open system POS entry');
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif

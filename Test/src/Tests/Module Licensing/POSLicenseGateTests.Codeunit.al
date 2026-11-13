// CORE-2396: only licensed users use the POS. A seat granting the POS capability (POS or Attraction POS) is required to
// start a POS session ("NPR POS Session".OnInitialize), at every salesperson login and for every Dragonglass HTTP
// request without the user's own open sale. Nothing inside a running POS is gated. Each test binds "NPR License Enforcement Mock" in a local variable
// BEFORE the POS session is initialized, and gives the test user a seat (or none) through "NPR License User" rows.
// No test declares a MessageHandler: a licensed POS start must be silent.
codeunit 85551 "NPR POS License Gate Tests"
{
    // [FEATURE] Module licensing: only users with a POS seat can start and use the POS

    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Item: Record Item;
        _POSPaymentMethodCash: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    // ----------------------------------------------------------------- Seam

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Seam_BoundForcesEnforcement_UnboundRestoresBaseline()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
        Baseline: Boolean;
    begin
        // [SCENARIO] The mock switches enforcement on only while its binding variable lives.
        // [GIVEN] Enforcement as the environment decides it
        Initialize();
        Baseline := LicenseMgt.IsEnforcementActive();

        // [WHEN] The mock is bound inside a procedure
        // [THEN] Enforcement is on while bound
        _Assert.IsTrue(IsEnforcementActiveWhileMockBound(), 'Enforcement must be active while the mock is bound.');

        // [THEN] It is back to the baseline once the binding variable is out of scope
        _Assert.AreEqual(Baseline, LicenseMgt.IsEnforcementActive(), 'Enforcement must return to the baseline after the mock is unbound.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Seam_OnlyTestMockSubscribes()
    var
        EventSubscription: Record "Event Subscription";
    begin
        // [SCENARIO] Only the Test app's mock subscribes to the test seam; any other subscriber could force enforcement in production.
        // [GIVEN] The subscribers registered for OnForceEnforcementForTest
        EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
        EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR License Mgt.");
        EventSubscription.SetRange("Published Function", 'OnForceEnforcementForTest');

        // [WHEN] Looking for subscribers other than the mock
        EventSubscription.SetFilter("Subscriber Codeunit ID", '<>%1', Codeunit::"NPR License Enforcement Mock");

        // [THEN] There are none, and the mock itself is registered
        _Assert.RecordIsEmpty(EventSubscription);
        EventSubscription.SetRange("Subscriber Codeunit ID", Codeunit::"NPR License Enforcement Mock");
        _Assert.RecordIsNotEmpty(EventSubscription);
    end;

    // ----------------------------------------------------------------- POS session start

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSSessionStart_NoSeat_Refused()
    var
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
    begin
        // [SCENARIO] Without a seat the POS session does not start.
        // [GIVEN] Enforcement on; no seat
        Initialize();
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] Initializing the POS session
        asserterror _LibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);

        // [THEN] The no-POS-license error
        _Assert.ExpectedError(NoPOSLicenseErr());
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSSessionStart_POSSeat_Opens()
    begin
        // [SCENARIO] A POS seat starts the POS session silently, and the whole sale runs ungated.
        AssertSessionOpensAndCashSaleEndsWithSeat("NPR License Module"::POS);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSSessionStart_AttractionPOSSeat_Opens()
    begin
        // [SCENARIO] An Attraction POS seat starts the POS session silently, and the whole sale runs ungated.
        AssertSessionOpensAndCashSaleEndsWithSeat("NPR License Module"::AttractionPOS);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSSessionStart_RetailWithoutPOSSeat_Refused()
    begin
        // [SCENARIO] A Back Office-only seat (Retail without POS) does not start the POS.
        AssertSessionStartRefusedWithSeat("NPR License Module"::RetailWithoutPOS, "NPR License User Status"::Active);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSSessionStart_AutoSuspendedPOSSeat_Refused()
    begin
        // [SCENARIO] The POS gets no UI grace: an automatically suspended POS seat does not start the POS.
        AssertSessionStartRefusedWithSeat("NPR License Module"::POS, "NPR License User Status"::SuspendedAutomatically);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSSessionStart_EnforcementOff_OpensWithoutSeat()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        // [SCENARIO] Where enforcement is off (for example in CI and sandboxes) the POS starts and sells without any seat.
        // [GIVEN] No seat; the mock is not bound
        Initialize();
        _Assert.IsFalse(LicenseMgt.IsEnforcementActive(), 'Precondition: enforcement must be off without the mock. Is a MODULE_LICENSING_*_DEV symbol set?');

        // [WHEN] Starting the POS session and selling an item for cash
        // [THEN] The session starts and the sale ends with a POS entry
        AssertSessionOpensAndCashSaleEnds('Without enforcement the POS must start and the sale must end without a seat.');
    end;

    // ----------------------------------------------------------------- POS page start
    // The POS page asks IsPOSStartAllowed before it builds the session, so it can close itself before the error.

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSPageStart_RetailWithoutPOSSeat_NotAllowed()
    var
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        // [SCENARIO] The POS page asks before it builds the session: a Back Office-only seat is refused, so the page can close first.
        // [GIVEN] Enforcement on; a Back Office-only seat
        Initialize();
        SeedSeat("NPR License Module"::RetailWithoutPOS, "NPR License User Status"::Active);
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] The POS page asks whether the POS may start
        // [THEN] It may not
        _Assert.IsFalse(LicenseMgt.IsPOSStartAllowed(), 'A Back Office-only seat must not start the POS.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSPageStart_POSSeat_Allowed()
    var
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        // [SCENARIO] The POS page's start check lets an active POS seat through.
        // [GIVEN] Enforcement on; an active POS seat
        Initialize();
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] The POS page asks whether the POS may start
        // [THEN] It may
        _Assert.IsTrue(LicenseMgt.IsPOSStartAllowed(), 'A POS seat must start the POS.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure POSPageStart_EnforcementOff_Allowed()
    var
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        // [SCENARIO] Where enforcement is off, the POS page's start check allows a user without a seat.
        // [GIVEN] No seat; the mock is not bound
        Initialize();

        // [WHEN] The POS page asks whether the POS may start
        // [THEN] It may
        _Assert.IsTrue(LicenseMgt.IsPOSStartAllowed(), 'Without enforcement the POS must start without a seat.');
    end;

    // ----------------------------------------------------------------- Running POS session

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RunningSession_SeatDisabled_SaleStillEnds()
    var
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        POSSale: Codeunit "NPR POS Sale";
    begin
        // [SCENARIO] Nothing inside a running POS is gated: a seat withdrawn mid-session takes effect at the next login, not mid-sale.
        // [GIVEN] A POS seat; enforcement on; a started POS session with an open sale and an item line
        Initialize();
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);
        BindSubscription(LicenseEnforcementMock);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        // [GIVEN] The administrator disables the seat
        DisableSeat("NPR License Module"::POS);

        // [WHEN] Paying the full amount in cash
        // [THEN] The sale ends and a POS entry exists
        _Assert.IsTrue(_LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, _Item."Unit Price", ''), 'A sale in a running POS session must end after the seat is disabled.');
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        _Assert.RecordIsNotEmpty(POSEntry);
    end;

    // ----------------------------------------------------------------- Salesperson login

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalespersonLogin_SeatDisabledAfterStart_Refused()
    var
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        POSActionLogin: Codeunit "NPR POS Action - Login";
        Context: Codeunit "NPR POS JSON Helper";
        FrontEnd: Codeunit "NPR POS Front End Management";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        // [SCENARIO] A POS left open is checked again at every salesperson login: once the seat is withdrawn, the next login is refused.
        // [GIVEN] A POS seat; enforcement on; a started POS session
        Initialize();
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);
        BindSubscription(LicenseEnforcementMock);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        // [GIVEN] The administrator disables the seat
        DisableSeat("NPR License Module"::POS);

        // [WHEN] A salesperson logs in with the password: the LOGIN action's backend step, as the front end calls it
        BuildLoginContext(Context, _Salesperson."NPR Register Password");
        _POSSession.GetFrontEnd(FrontEnd, true);
        _POSSession.GetSale(POSSale);
        _POSSession.GetSaleLine(POSSaleLine);
        _POSSession.GetPaymentLine(POSPaymentLine);
        _POSSession.GetSetup(POSSetup);
        asserterror POSActionLogin.RunWorkflow('prepareWorkflow', Context, FrontEnd, POSSale, POSSaleLine, POSPaymentLine, POSSetup);

        // [THEN] The no-POS-license error
        _Assert.ExpectedError(NoPOSLicenseErr());
    end;

    // ----------------------------------------------------------------- Dragonglass HTTP requests

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DragonglassRequest_NoSeat_Refused()
    var
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        POSDragonglassAPI: Codeunit "NPR POS Dragonglass API";
    begin
        // [SCENARIO] The HTTP POS rebuilds its session for every request without OnInitialize, so every request without the user's own open sale is checked.
        // [GIVEN] Enforcement on; no seat
        Initialize();
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] The POS front end sends a request (the API procedure is called directly; no web service is involved)
        asserterror POSDragonglassAPI.InvokeMethod('AbortAllWorkflows', '{}', Format(ServiceInstanceId()));

        // [THEN] The no-POS-license error
        _Assert.ExpectedError(NoPOSLicenseErr());
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DragonglassRequest_NoSeat_OtherUsersSale_Refused()
    var
        SalePOS: Record "NPR POS Sale";
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        POSDragonglassAPI: Codeunit "NPR POS Dragonglass API";
    begin
        // [SCENARIO] Only the user's own open sale skips the check: the key of another user's sale does not.
        // [GIVEN] Enforcement on; no seat; an open sale on the unit started by another user
        Initialize();
        SalePOS."Register No." := _POSUnit."No.";
        SalePOS."Sales Ticket No." := 'LICENSE-GATE-TEST';
        SalePOS."User ID" := 'ANOTHER USER';
        SalePOS.Insert(false);
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] The POS front end sends a request with that sale's key
        asserterror POSDragonglassAPI.InvokeMethod('AbortAllWorkflows', StrSubstNo('{"context":{"parameters":{"saleSystemId":"%1"}}}', SalePOS.SystemId), Format(ServiceInstanceId()));

        // [THEN] The no-POS-license error
        // asserterror also rolled back the sale inserted above, so no cleanup is needed.
        _Assert.ExpectedError(NoPOSLicenseErr());
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DragonglassRequest_NoSeat_OwnSale_Allowed()
    var
        SalePOS: Record "NPR POS Sale";
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        POSDragonglassAPI: Codeunit "NPR POS Dragonglass API";
        JsonResponse: Text;
    begin
        // [SCENARIO] A request for the user's own open sale is not checked: a seat withdrawn mid-sale lets the HTTP POS finish that sale, as on the POS page.
        // [GIVEN] Enforcement on; no seat; an open sale on the unit started by the current user
        Initialize();
        SalePOS."Register No." := _POSUnit."No.";
        SalePOS."Sales Ticket No." := 'LICENSE-GATE-OWN';
        SalePOS."User ID" := CopyStr(UserId(), 1, MaxStrLen(SalePOS."User ID"));
        SalePOS.Insert(false);
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] The POS front end sends a request with that sale's key
        JsonResponse := POSDragonglassAPI.InvokeMethod('AbortAllWorkflows', StrSubstNo('{"context":{"parameters":{"saleSystemId":"%1"}}}', SalePOS.SystemId), Format(ServiceInstanceId()));

        // [THEN] The request is processed without the no-POS-license error
        _Assert.IsTrue(JsonResponse.Contains('"Responses"'), 'A request for the user''s own open sale must be processed without a seat.');

        // Initialize commits and the codeunit rolls back only at its end, so remove the sale before later tests start a POS on the unit.
        SalePOS.Delete(false);
    end;

    // ----------------------------------------------------------------- Last login

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LastLogin_LicensedSessionStart_StampsOnlyPOSSeat()
    var
        LicenseUser: Record "NPR License User";
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
    begin
        // [SCENARIO] A licensed POS session start stamps Last Login on the POS-granting seat only: Last Login reads as "used the POS".
        // [GIVEN] An active POS seat and an active KDS seat, neither stamped; enforcement on
        Initialize();
        SeedSeat("NPR License Module"::POS, "NPR License User Status"::Active);
        SeedSeat("NPR License Module"::KDS, "NPR License User Status"::Active);
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] Starting the POS session
        _LibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);

        // [THEN] The POS seat is stamped, the KDS seat is not
        LicenseUser.Get(UserSecurityId(), "NPR License Module"::POS);
        _Assert.AreNotEqual(0DT, LicenseUser."Last Login (DateTime)", 'A licensed POS session start must stamp the POS seat.');
        LicenseUser.Get(UserSecurityId(), "NPR License Module"::KDS);
        _Assert.AreEqual(0DT, LicenseUser."Last Login (DateTime)", 'A POS session start must not stamp a KDS seat.');
    end;

    // ----------------------------------------------------------------- Helpers

    local procedure AssertSessionOpensAndCashSaleEndsWithSeat(Module: Enum "NPR License Module")
    var
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
    begin
        // [GIVEN] An active seat of the module; enforcement on before the POS session starts
        Initialize();
        SeedSeat(Module, "NPR License User Status"::Active);
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] Starting the POS session and selling an item for cash, with enforcement on throughout
        // [THEN] The session starts without a message and the sale ends with a POS entry
        AssertSessionOpensAndCashSaleEnds(StrSubstNo('A %1 seat must start the POS and let the sale end.', Module));
    end;

    local procedure AssertSessionOpensAndCashSaleEnds(FailureMsg: Text)
    var
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _LibraryPOSMock.CreateItemLine(_POSSession, _Item."No.", 1);
        _Assert.IsTrue(_LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, _Item."Unit Price", ''), FailureMsg);
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Direct Sale");
        _Assert.RecordIsNotEmpty(POSEntry);
    end;

    local procedure AssertSessionStartRefusedWithSeat(Module: Enum "NPR License Module"; Status: Enum "NPR License User Status")
    var
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
    begin
        // [GIVEN] A seat row that does not grant the POS; enforcement on
        Initialize();
        SeedSeat(Module, Status);
        BindSubscription(LicenseEnforcementMock);

        // [WHEN] Initializing the POS session
        asserterror _LibraryPOSMock.InitializePOSSession(_POSSession, _POSUnit);

        // [THEN] The no-POS-license error
        _Assert.ExpectedError(NoPOSLicenseErr());
    end;

    local procedure IsEnforcementActiveWhileMockBound(): Boolean
    var
        LicenseEnforcementMock: Codeunit "NPR License Enforcement Mock";
        LicenseMgt: Codeunit "NPR License Mgt.";
    begin
        BindSubscription(LicenseEnforcementMock);
        exit(LicenseMgt.IsEnforcementActive());
    end;

    // The "context" the LOGIN action's front-end script sends with its prepareWorkflow step.
    local procedure BuildLoginContext(var Context: Codeunit "NPR POS JSON Helper"; Password: Text)
    var
        Parameters: JsonObject;
        Root: JsonObject;
    begin
        Root.Add('type', 'SalespersonCode');
        Root.Add('password', Password);
        Parameters.Add('SelectCustReq', false);
        Parameters.Add('SelectMemberReq', false);
        Root.Add('parameters', Parameters);
        Context.InitializeJObjectParser(Root);
    end;

    local procedure SeedSeat(Module: Enum "NPR License Module"; Status: Enum "NPR License User Status")
    var
        LicenseUser: Record "NPR License User";
    begin
        // Direct assignment + Insert(false), as in "NPR License Capability Tests".SeedUser.
        LicenseUser.Init();
        LicenseUser."User Security ID" := UserSecurityId();
        LicenseUser.Module := Module;
        LicenseUser."License Term" := "NPR License Term"::months12;
        LicenseUser.Status := Status;
        LicenseUser."Status Changed At" := CurrentDateTime();
        LicenseUser.Insert(false);
    end;

    local procedure DisableSeat(Module: Enum "NPR License Module")
    var
        LicenseUser: Record "NPR License User";
    begin
        // Direct assignment + Modify(false): the administrator's deactivation without DeactivateUser's portal round-trip.
        LicenseUser.Get(UserSecurityId(), Module);
        LicenseUser.Status := LicenseUser.Status::DisabledManually;
        LicenseUser."Status Changed At" := CurrentDateTime();
        LicenseUser.Modify(false);
    end;

    local procedure NoPOSLicenseErr(): Text
    begin
        // Part of the "NPR License Mgt." error raised by RaisePOSNotLicensedError.
        exit('has no POS license');
    end;

    local procedure Initialize()
    var
        LicenseUser: Record "NPR License User";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
    begin
        // Clean any previous mock session
        _POSSession.ClearAll();
        Clear(_POSSession);
        // Every test starts without a seat; the table is per database, the codeunit rollback restores it.
        LicenseUser.DeleteAll(false);

        if not _Initialized then begin
            LibraryPOSMasterData.CreatePOSSetup(POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            LibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.DontPrintReceiptOnSaleEnd(_POSUnit);
            LibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethodCash, _POSPaymentMethodCash."Processing Type"::CASH, '', false);
            _POSPaymentMethodCash."Rounding Precision" := 0.01;
            _POSPaymentMethodCash.Modify();
            LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);
            _Item."Unit Price" := 10;
            _Item.Modify();
            LibraryPOSMasterData.CreateSalespersonForPOSUsage(_Salesperson);
            _Initialized := true;
        end;

        LibraryPOSMasterData.ItemReferenceCleanup();
        LibraryPOSMasterData.OpenPOSUnit(_POSUnit);
        Commit();
    end;
}

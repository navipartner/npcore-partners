#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85251 "NPR EOD Waiter Pad Block"
{
    Subtype = Test;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _ConfirmCallCount: Integer;
        _ConfirmReplies: array[2] of Boolean;
        _POSInitialized: Boolean;
        _WaiterPadNoToClose: Code[20];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistForRestaurantEmptyCodeReturnsFalse()
    var
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Empty restaurant code → no seating locations can match → returns false
        Assert.IsFalse(WaiterPadMgt.OpenWaiterPadsExistForRestaurant('', SeatingWPLinkQry), 'Empty restaurant code must return false.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistForRestaurantNoSeatingLocationsReturnsFalse()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Restaurant exists but has no seating locations → filter yields no rows → returns false
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        Assert.IsFalse(WaiterPadMgt.OpenWaiterPadsExistForRestaurant(Restaurant.Code, SeatingWPLinkQry), 'Restaurant with no seating locations must return false.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistForRestaurantOpenWaiterPadReturnsTrue()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
        Assert: Codeunit Assert;
    begin
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        // [Scenario] Restaurant has a seating with an open waiter pad → returns true
        CreateWaiterPadWithSeatingLink(Seating.Code, false);
        Assert.IsTrue(WaiterPadMgt.OpenWaiterPadsExistForRestaurant(Restaurant.Code, SeatingWPLinkQry), 'Restaurant with an open waiter pad must return true.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistForRestaurantAllPadsClosedReturnsFalse()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
        Assert: Codeunit Assert;
    begin
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        // [Scenario] All waiter pads for the restaurant are closed → returns false
        CreateWaiterPadWithSeatingLink(Seating.Code, true);
        Assert.IsFalse(WaiterPadMgt.OpenWaiterPadsExistForRestaurant(Restaurant.Code, SeatingWPLinkQry), 'Restaurant with only closed waiter pads must return false.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistForRestaurantOtherRestaurantPadsReturnsFalse()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        OtherRestaurant: Record "NPR NPRE Restaurant";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SeatingWPLinkQry: Query "NPR NPRE Seating - W/Pad Link";
        Assert: Codeunit Assert;
    begin
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreateRestaurant(OtherRestaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreateSeatingLocation(SeatingLocation, OtherRestaurant.Code);
        LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        // [Scenario] Open waiter pad exists only in another restaurant → returns false for the queried restaurant
        CreateWaiterPadWithSeatingLink(Seating.Code, false);
        Assert.IsFalse(WaiterPadMgt.OpenWaiterPadsExistForRestaurant(Restaurant.Code, SeatingWPLinkQry), 'Open waiter pads in another restaurant must not affect this restaurant.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CleanupInteractiveNoPadsReturnsTrue()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Assert: Codeunit Assert;
    begin
        // [Scenario] No open pads → exits before any UI, returns true
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        Assert.IsTrue(WaiterPadMgt.CleanupWaiterPadsInteractive(Restaurant.Code), 'No open pads must return true without any UI.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler')]
    procedure CleanupInteractiveFirstConfirmDeclinedReturnsFalse()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Assert: Codeunit Assert;
    begin
        // [Scenario] User declines first "there are open pads" confirm → EOD is blocked
        CreateRestaurantWithOpenWaiterPad(Restaurant);
        _ConfirmCallCount := 0;
        _ConfirmReplies[1] := false;
        Assert.IsFalse(WaiterPadMgt.CleanupWaiterPadsInteractive(Restaurant.Code), 'Declining first confirm must return false.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler,WaiterPadListHandlerCancel')]
    procedure CleanupInteractiveModalCancelledReturnsFalse()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Assert: Codeunit Assert;
    begin
        // [Scenario] User accepts first confirm but then cancels the waiter pad list → EOD is blocked
        CreateRestaurantWithOpenWaiterPad(Restaurant);
        _ConfirmCallCount := 0;
        _ConfirmReplies[1] := true;
        Assert.IsFalse(WaiterPadMgt.CleanupWaiterPadsInteractive(Restaurant.Code), 'Cancelling the waiter pad modal must return false.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler,WaiterPadListHandlerClosePadAndLookupOK')]
    procedure CleanupInteractiveModalOKPadClosedReturnsTrue()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Assert: Codeunit Assert;
    begin
        // [Scenario] User closes all pads inside the modal → recheck finds none open → returns true
        _WaiterPadNoToClose := CreateRestaurantWithOpenWaiterPad(Restaurant);
        _ConfirmCallCount := 0;
        _ConfirmReplies[1] := true;
        Assert.IsTrue(WaiterPadMgt.CleanupWaiterPadsInteractive(Restaurant.Code), 'All pads closed in modal must return true.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler,WaiterPadListHandlerLookupOK')]
    procedure CleanupInteractiveModalOKPadsStillOpenSecondConfirmDeclinedReturnsFalse()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Modal closed without closing pads → second confirm shown → user declines → false
        CreateRestaurantWithOpenWaiterPad(Restaurant);
        _ConfirmCallCount := 0;
        _ConfirmReplies[1] := true;
        _ConfirmReplies[2] := false;
        Assert.IsFalse(WaiterPadMgt.CleanupWaiterPadsInteractive(Restaurant.Code), 'Declining second confirm with open pads must return false.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler,WaiterPadListHandlerLookupOK')]
    procedure CleanupInteractiveModalOKPadsStillOpenSecondConfirmAcceptedReturnsTrue()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Modal closed without closing pads → second confirm shown → user accepts → true
        CreateRestaurantWithOpenWaiterPad(Restaurant);
        _ConfirmCallCount := 0;
        _ConfirmReplies[1] := true;
        _ConfirmReplies[2] := true;
        Assert.IsTrue(WaiterPadMgt.CleanupWaiterPadsInteractive(Restaurant.Code), 'Accepting second confirm with open pads must return true.');
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        _ConfirmCallCount += 1;
        Reply := _ConfirmReplies[_ConfirmCallCount];
    end;

    [ModalPageHandler]
    procedure WaiterPadListHandlerLookupOK(var WaiterPadList: TestPage "NPR NPRE Waiter Pad List")
    begin
        WaiterPadList.OK.Invoke();
    end;

    [ModalPageHandler]
    procedure WaiterPadListHandlerCancel(var WaiterPadList: TestPage "NPR NPRE Waiter Pad List")
    begin
        WaiterPadList.Cancel.Invoke();
    end;

    [ModalPageHandler]
    procedure WaiterPadListHandlerClosePadAndLookupOK(var WaiterPadList: TestPage "NPR NPRE Waiter Pad List")
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        if WaiterPad.Get(_WaiterPadNoToClose) then
            WaiterPadMgt.TryCloseWaiterPad(WaiterPad, true, "NPR NPRE W/Pad Closing Reason"::"Manually Closed");
        WaiterPadList.OK.Invoke();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BalancingCleanupNoRestaurantProfileReturnsTrue()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Assert: Codeunit Assert;
    begin
        // [Scenario] A POS unit that is not a restaurant POS never blocks end of day, whatever open pads exist elsewhere
        //
        // The open pad in another restaurant is what makes the scenario real rather than an empty company answering
        // true by default. It is also the assertion: this test declares no ConfirmHandler, so a balancing that stopped
        // resolving the restaurant from the POS unit's own profile and looked company-wide instead would raise the
        // unfinished-pads confirm and fail here as unhandled UI.
        //
        // What no test can catch is deleting the blank-restaurant-code guard in CleanupWaiterPadsBeforeBalancing. That
        // guard is an early exit, not a decision: falling through calls CleanupWaiterPadsInteractive(''), whose
        // OpenWaiterPadsExistForRestaurant('') gets an empty seating location filter and answers false, so the routine
        // returns true either way. Worth knowing before someone tries to write the test that pins it.
        CreateRestaurantWithOpenWaiterPad(Restaurant);
        InitializePOSUnitWithRestaurantProfile('', POSSession, POSSetup);
        Assert.IsTrue(
            WaiterPadMgt.CleanupWaiterPadsBeforeBalancing(POSSetup), 'A POS unit with no restaurant profile must not block balancing.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmHandler')]
    procedure BalancingCleanupRestaurantWithOpenPadFirstConfirmDeclinedReturnsFalse()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Assert: Codeunit Assert;
    begin
        // [Scenario] Balancing resolves the restaurant from the POS unit's profile and hands over to the interactive
        // cleanup, so an open pad there can still block end of day.
        //
        // This is also what proves the test above is not passing vacuously: CleanupWaiterPadsBeforeBalancing exits
        // true immediately when GuiAllowed() is false, so a run without a UI would return true here as well.
        CreateRestaurantWithOpenWaiterPad(Restaurant);
        LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, Restaurant.Code);
        InitializePOSUnitWithRestaurantProfile(POSRestProfile.Code, POSSession, POSSetup);

        _ConfirmCallCount := 0;
        _ConfirmReplies[1] := false;
        Assert.IsFalse(
            WaiterPadMgt.CleanupWaiterPadsBeforeBalancing(POSSetup),
            'An open pad in the POS unit''s restaurant must be able to block balancing.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RetentionPoliciesDisabled_EnablersRun_PoliciesReEnabled()
    var
        Restaurant: Record "NPR NPRE Restaurant";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [Scenario] A tenant that switched restaurant retention off gets it back when the enablers run, so a
        // long-running company does not accumulate waiter pads, print log entries and kitchen orders forever.
        //
        // [Given] The fixture is built here rather than inherited. The retention subscribers all bail on an empty
        // company - the waiter pad and print log ones on `RestaurantSetup.IsEmpty()`, the kitchen order one unless
        // KDS is active somewhere - so run alone against a fresh company this test would previously have failed on
        // the first Get(). And discovery alone inserts rows with Enabled already true, so asserting Enabled straight
        // after discovery cannot fail either: the rows have to be forced off first for the enablers to have work.
        LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.SetRestaurantKDSActive(Restaurant, true);
        Commit();

        DiscoverAndDisableRetentionPolicy(Database::"NPR NPRE Waiter Pad");
        DiscoverAndDisableRetentionPolicy(Database::"NPR NPRE W.Pad Prnt LogEntry");
        DiscoverAndDisableRetentionPolicy(Database::"NPR NPRE Kitchen Order");

        // [When] The enablers run
        WaiterPadMgt.EnableWaiterPadRetentionPolicies();
        KitchenOrderMgt.EnableKitchenOrderRetentionPolicy();

        // [Then] All three are enabled again
        AssertRetentionPolicyEnabled(Database::"NPR NPRE Waiter Pad", 'Waiter pads');
        AssertRetentionPolicyEnabled(Database::"NPR NPRE W.Pad Prnt LogEntry", 'Waiter pad print log entries');
        AssertRetentionPolicyEnabled(Database::"NPR NPRE Kitchen Order", 'Kitchen orders');
    end;

    local procedure DiscoverAndDisableRetentionPolicy(TableId: Integer)
    var
        RetentionPolicy: Record "NPR Retention Policy";
        Assert: Codeunit Assert;
    begin
        RetentionPolicy.DiscoverRetentionPolicyTables();
        Assert.IsTrue(RetentionPolicy.Get(TableId), 'The retention policy row should exist before it can be disabled.');
        RetentionPolicy.Enabled := false;
        RetentionPolicy.Modify();
    end;

    local procedure AssertRetentionPolicyEnabled(TableId: Integer; TableDescription: Text)
    var
        RetentionPolicy: Record "NPR Retention Policy";
        Assert: Codeunit Assert;
    begin
        Assert.IsTrue(
            RetentionPolicy.Get(TableId), StrSubstNo('%1 should have a retention policy row.', TableDescription));
        Assert.IsTrue(RetentionPolicy.Enabled, StrSubstNo('%1 retention should be enabled.', TableDescription));
    end;

    local procedure InitializePOSUnitWithRestaurantProfile(POSRestProfileCode: Code[20]; var POSSession: Codeunit "NPR POS Session"; var POSSetup: Codeunit "NPR POS Setup")
    begin
        _LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore);
        _POSUnit."POS Restaurant Profile" := POSRestProfileCode;
        _POSUnit.Modify();

        // The POS store carries a fallback profile the setup falls back to, so it has to be cleared for the
        // no-profile case to be the no-profile case.
        _POSStore.Get(_POSUnit."POS Store Code");
        _POSStore."POS Restaurant Profile" := '';
        _POSStore.Modify();
        Commit();

        // Going through the session rather than POSSetup.SetPOSUnit: the session is what a real end-of-day runs
        // inside, and it is the path the other POS suites already prove works headless.
        _LibraryPOSMock.InitializePOSSession(POSSession, _POSUnit);
        POSSession.GetSetup(POSSetup);
    end;

    local procedure CreateRestaurantWithOpenWaiterPad(var Restaurant: Record "NPR NPRE Restaurant"): Code[20]
    var
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        SeatingLocation: Record "NPR NPRE Seating Location";
        Seating: Record "NPR NPRE Seating";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        LibraryRestaurant.CreateSeating(Seating, SeatingLocation.Code);
        exit(CreateWaiterPadWithSeatingLink(Seating.Code, false));
    end;

    local procedure CreateWaiterPadWithSeatingLink(SeatingCode: Code[20]; Closed: Boolean): Code[20]
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        LibraryRestaurant.CreateWaiterPadForSeating(SeatingCode, WaiterPad);
        if Closed then
            WaiterPadMgt.TryCloseWaiterPad(WaiterPad, true, "NPR NPRE W/Pad Closing Reason"::"Manually Closed");
        exit(WaiterPad."No.");
    end;
}
#endif

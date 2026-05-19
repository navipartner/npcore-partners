#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85251 "NPR EOD Waiter Pad Block"
{
    Subtype = Test;

    var
        _ConfirmCallCount: Integer;
        _ConfirmReplies: array[2] of Boolean;
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

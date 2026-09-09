codeunit 85411 "NPR NPRE Kitchen Print Tests"
{
    // [FEATURE] Which waiter pad lines are eligible to be sent to the kitchen, and what sending records
    Subtype = Test;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        _Assert: Codeunit Assert;
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        MainCourseStepTok: Label 'MAIN', Locked = true;
        StarterStepTok: Label 'STARTER', Locked = true;

    // SCOPE. These scenarios run once, with the feature flag left as the company has it - so they cover whichever
    // implementation that happens to be, not both. The two are copy-pasted rather than shared at this point in the
    // stack, and their eligibility bodies already differ in one respect: the legacy one dedupes through the buffer's
    // natural key, the new one assigns a surrogate "Entry No." and inserts unconditionally. A divergence there is
    // exactly what TwoEligibleLines_Sent_EachLogged would catch, on whichever copy the run reaches.
    //
    // Running each scenario twice was weighed against CORE-1940, which merges the two bodies into one shortly after
    // this PR and makes the question moot. Each test body is a flag-agnostic local procedure with a single wrapper,
    // so promoting one to run under both states is a second wrapper rather than a rewrite if that changes.

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnsentLineEligible_SentLineNot()
    begin
        UnsentLineEligible_SentLineNotImpl();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ForceResend_AlreadySentLineIncluded()
    begin
        ForceResend_AlreadySentLineIncludedImpl();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ServingStepFiltered_OnlyThatStepSent()
    begin
        ServingStepFiltered_OnlyThatStepSentImpl();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoEligibleLines_Sent_EachLogged()
    begin
        TwoEligibleLines_Sent_EachLoggedImpl();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NothingEligible_SendRequested_NothingToSendReported()
    begin
        NothingEligible_SendRequested_NothingToSendReportedImpl();
    end;

    #region Scenario bodies

    local procedure UnsentLineEligible_SentLineNotImpl()
    var
        FirstItem: Record Item;
        SecondItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A resend only takes what the kitchen has not already been told about
        // [GIVEN] A pad with one line already sent, and a second line added afterwards
        Initialize();
        CreatePadWithRoutedLine(WaiterPad, FirstItem, FirstLine, MainCourseStepTok);
        SendToKitchen(WaiterPad, '', false, false);
        AddRoutedLine(WaiterPad, SecondItem, SecondLine, MainCourseStepTok);

        // [WHEN] The pad is sent again without forcing
        SendToKitchen(WaiterPad, '', false, false);

        // [THEN] Each line has been sent exactly once
        _Assert.AreEqual(1, KdsLogCount(WaiterPad."No.", FirstLine."Line No."), 'A line already sent should not be sent a second time.');
        _Assert.AreEqual(1, KdsLogCount(WaiterPad."No.", SecondLine."Line No."), 'The newly added line should have been sent.');
    end;

    local procedure ForceResend_AlreadySentLineIncludedImpl()
    var
        Item: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Forcing a resend puts the whole bill in front of the kitchen again
        // [GIVEN] A pad whose only line has already been sent
        Initialize();
        CreatePadWithRoutedLine(WaiterPad, Item, WaiterPadLine, MainCourseStepTok);
        SendToKitchen(WaiterPad, '', false, false);
        _Assert.AreEqual(1, KdsLogCount(WaiterPad."No.", WaiterPadLine."Line No."), 'The line should have been sent once to begin with.');

        // [WHEN] The pad is sent again with resend forced
        SendToKitchen(WaiterPad, '', true, false);

        // [THEN] The line was sent again
        _Assert.AreEqual(2, KdsLogCount(WaiterPad."No.", WaiterPadLine."Line No."), 'Forcing a resend should send an already sent line again.');
    end;

    local procedure ServingStepFiltered_OnlyThatStepSentImpl()
    var
        MainItem: Record Item;
        StarterItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        StarterLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Firing one course does not send the rest of the meal with it
        // [GIVEN] A pad with a starter and a main, each routed to its own serving step
        Initialize();
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, StarterStepTok, 0);
        CreatePadWithRoutedLine(WaiterPad, StarterItem, StarterLine, StarterStepTok);
        AddRoutedLine(WaiterPad, MainItem, MainLine, MainCourseStepTok);

        // [WHEN] Only the main course step is sent
        SendToKitchen(WaiterPad, MainCourseStepTok, false, false);

        // [THEN] The main went and the starter stayed
        _Assert.AreEqual(1, KdsLogCount(WaiterPad."No.", MainLine."Line No."), 'The line on the requested serving step should have been sent.');
        _Assert.AreEqual(0, KdsLogCount(WaiterPad."No.", StarterLine."Line No."), 'A line on another serving step should not be sent.');
    end;

    local procedure TwoEligibleLines_Sent_EachLoggedImpl()
    var
        FirstItem: Record Item;
        SecondItem: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        FirstLine: Record "NPR NPRE Waiter Pad Line";
        SecondLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Every dish sent is recorded, not just the first
        // [GIVEN] A pad with two unsent routed lines
        Initialize();
        CreatePadWithRoutedLine(WaiterPad, FirstItem, FirstLine, MainCourseStepTok);
        AddRoutedLine(WaiterPad, SecondItem, SecondLine, MainCourseStepTok);

        // [WHEN] The pad is sent
        SendToKitchen(WaiterPad, '', false, false);

        // [THEN] Both lines are recorded as sent, against the order they went to
        _Assert.AreEqual(1, KdsLogCount(WaiterPad."No.", FirstLine."Line No."), 'The first line should be recorded as sent.');
        _Assert.AreEqual(1, KdsLogCount(WaiterPad."No.", SecondLine."Line No."), 'The second line should be recorded as sent.');
        _Assert.AreNotEqual(0, LoggedOrderId(WaiterPad."No.", FirstLine."Line No."), 'The log entry should name the kitchen order the line went to.');
    end;

    local procedure NothingEligible_SendRequested_NothingToSendReportedImpl()
    var
        Item: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Asking to send a bill the kitchen already has says so rather than sending nothing silently
        // [GIVEN] A pad whose only line has already been sent
        Initialize();
        CreatePadWithRoutedLine(WaiterPad, Item, WaiterPadLine, MainCourseStepTok);
        SendToKitchen(WaiterPad, '', false, false);

        // [WHEN] The pad is sent again the way the POS action does, asking to be told if there is nothing to send
        asserterror SendToKitchen(WaiterPad, '', false, true);

        // [THEN] The caller is told there was nothing to send, and nothing further was logged
        _Assert.ExpectedError('Nothing to send.');
        _Assert.AreEqual(1, KdsLogCount(WaiterPad."No.", WaiterPadLine."Line No."), 'A refused send should not add a log entry.');
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        KitchenStationSelectionAll: Record "NPR NPRE Kitchen Station Slct.";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        _LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore);
        if not _RestaurantInitialized then begin
            _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
            _LibraryRestaurant.CreateMealFlowStatuses();
            _LibraryRestaurant.CreateSeatingFlowStatuses();
            _LibraryRestaurant.CreateWaiterPadFlowStatuses();
            _LibraryRestaurant.CreateServiceFlowProfile(_ServFlowProfile);
            _LibraryRestaurant.CreateRestaurant(_Restaurant, _ServFlowProfile.Code);
            _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);
            _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
            _POSUnit.Modify();
            _RestaurantInitialized := true;
        end;

        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);

        // No print template is configured anywhere in this codeunit, so the only output is KDS. That keeps these
        // scenarios about which lines are eligible, and leaves template resolution and dispatch to the dispatch suite.
        KitchenStationSelectionAll.DeleteAll();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        Commit();
    end;

    local procedure CreatePadWithRoutedLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ServingStep: Code[10])
    var
        Seating: Record "NPR NPRE Seating";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        AddRoutedLine(WaiterPad, Item, WaiterPadLine, ServingStep);
    end;

    local procedure AddRoutedLine(WaiterPad: Record "NPR NPRE Waiter Pad"; var Item: Record Item; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ServingStep: Code[10])
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, ServingStep);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", 1, 0, WaiterPadLine);
    end;

    local procedure SendToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad"; ServingStep: Code[10]; ForceResend: Boolean; ShowNothingToSendErr: Boolean)
    var
        PrintTemplate: Record "NPR NPRE Print Templ.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        RestaurantPrint.PrintWaiterPadLinesToKitchen(
            WaiterPad, WaiterPadLine, PrintTemplate."Print Type"::"Kitchen Order", ServingStep, ForceResend, ShowNothingToSendErr);
    end;

    local procedure KdsLogCount(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Integer
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        FilterKdsLog(WaiterPadNo, WaiterPadLineNo, WPadLinePrintLogEntry);
        exit(WPadLinePrintLogEntry.Count());
    end;

    local procedure LoggedOrderId(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): BigInteger
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        FilterKdsLog(WaiterPadNo, WaiterPadLineNo, WPadLinePrintLogEntry);
        _Assert.IsTrue(WPadLinePrintLogEntry.FindFirst(), 'The line should have a KDS log entry.');
        exit(WPadLinePrintLogEntry."Kitchen Order ID");
    end;

    local procedure FilterKdsLog(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; var WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry")
    begin
        WPadLinePrintLogEntry.Reset();
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WaiterPadNo);
        WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", WaiterPadLineNo);
        WPadLinePrintLogEntry.SetRange("Output Type", WPadLinePrintLogEntry."Output Type"::KDS);
    end;

    #endregion
}

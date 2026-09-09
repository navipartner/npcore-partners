codeunit 85409 "NPR NPRE W/Pad SplitMergeTests"
{
    // [FEATURE] Splitting and merging waiter pad lines: quantity, kitchen request source links and print log entries
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialSplit_QuantityAndBilledQuantityDivided()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Moving part of a dish to another bill divides both what is owed and what is already paid
        // [GIVEN] A line of four with one already billed and a priced amount on it, and a second pad to move part of it to
        //         The amount has to be set explicitly. Only the POS save-back path ever writes "Amount Incl. VAT", so a
        //         hand-built line carries zero and the amount assertions below would be 0 = 0 whatever the split did.
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 4, false);
        _LibraryRestaurant.SetWaiterPadLineBilledQuantity(SourceLine, 1);
        SourceLine.Find();
        SourceLine."Amount Incl. VAT" := 400;
        SourceLine."Amount Excl. VAT" := 320;
        SourceLine.Modify();
        CreatePad(TargetPad);

        // [WHEN] Three of the four are split onto the other pad
        SplitLine(SourcePad, SourceLine, 3, TargetPad);

        // [THEN] The new line carries three unbilled, and the source keeps one billed one
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(3, NewLine.Quantity, 'The moved line should carry the split quantity.');
        _Assert.AreEqual(0, NewLine."Billed Quantity", 'The moved line should carry none of the billed quantity while an unbilled remainder exists.');
        SourceLine.Find();
        _Assert.AreEqual(1, SourceLine.Quantity, 'The source line should keep what was not moved.');
        _Assert.AreEqual(1, SourceLine."Billed Quantity", 'The already billed quantity should stay with the source line.');

        // [THEN] Amounts are cleared on both, to be recalculated when each bill is next priced
        _Assert.AreEqual(0, NewLine."Amount Incl. VAT", 'A split should clear the amount on the moved line.');
        _Assert.AreEqual(0, SourceLine."Amount Incl. VAT", 'A split should clear the amount on the source line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullSplitOfUntouchedLine_SourceLineDeleted()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Moving a whole dish nobody has started leaves nothing behind
        // [GIVEN] A line of two, never sent and unbilled
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 2, false);
        CreatePad(TargetPad);

        // [WHEN] The whole quantity is split onto the other pad
        SplitLine(SourcePad, SourceLine, 2, TargetPad);

        // [THEN] The target holds it and the source line is gone
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(2, NewLine.Quantity, 'The whole quantity should have moved.');
        _Assert.IsFalse(SourceLine.Find(), 'A fully moved line with nothing sent and nothing billed should be removed from the source pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullSplitOfSentLine_SendingEvidenceMovesWithIt()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Moving a whole dish the kitchen already has takes its history to the new bill
        // [GIVEN] A line of two already sent to the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 2, true);
        CreatePad(TargetPad);
        _Assert.AreEqual(1, PrintLogCount(SourcePad."No.", SourceLine."Line No."), 'The sent line should have a print log entry before the split.');

        // [WHEN] The whole quantity is split onto the other pad
        SplitLine(SourcePad, SourceLine, 2, TargetPad);

        // [THEN] The print log moved with the line, and the source line went with it
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(1, PrintLogCount(TargetPad."No.", NewLine."Line No."), 'The print log entry should now sit against the moved line.');
        _Assert.AreEqual(0, PrintLogCount(SourcePad."No.", SourceLine."Line No."), 'No print log entry should be left on the source line.');
        _Assert.IsFalse(SourceLine.Find(), 'The source line is removed on a full transfer: its sending evidence moved to the target, so nothing marks it as sent.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure FullSplit_KitchenSourceLinksMoved()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] The kitchen's work follows the dish to whichever bill now owns it
        // [GIVEN] A line of two already sent to the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 2, true);
        CreatePad(TargetPad);

        // [WHEN] The whole quantity is split onto the other pad
        SplitLine(SourcePad, SourceLine, 2, TargetPad);

        // [THEN] The kitchen request now names the target pad as its source
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(2, SourceLinkQuantity(TargetPad."No.", NewLine."Line No."), 'The kitchen request source links should point at the moved line.');
        _Assert.AreEqual(0, SourceLinkCount(SourcePad."No.", SourceLine."Line No."), 'No kitchen request source link should be left on the source line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialSplit_KitchenSourceLinksDivided()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] Splitting part of a dish splits the kitchen's work to match
        // [GIVEN] A line of four already sent to the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 4, true);
        CreatePad(TargetPad);
        _Assert.AreEqual(4, SourceLinkQuantity(SourcePad."No.", SourceLine."Line No."), 'The whole quantity should be with the kitchen before the split.');

        // [WHEN] Three of the four are split onto the other pad
        SplitLine(SourcePad, SourceLine, 3, TargetPad);

        // [THEN] Each pad line's source links add up to the quantity that pad now owes
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(3, SourceLinkQuantity(TargetPad."No.", NewLine."Line No."), 'The moved line should own three of the kitchen quantity.');
        _Assert.AreEqual(1, SourceLinkQuantity(SourcePad."No.", SourceLine."Line No."), 'The source line should be left owning one.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Split_PrintCategoriesAndFlowStatusesCopied()
    var
        PrintCategory: Record "NPR NPRE Print/Prod. Cat.";
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A moved dish keeps the routing that decides which station cooks it
        // [GIVEN] A line carrying an assigned print category and meal flow status
        Initialize();
        _LibraryRestaurant.CreatePrintCategory(PrintCategory);
        CreatePadWithLine(SourcePad, SourceLine, 2, false, PrintCategory.Code);
        CreatePad(TargetPad);
        _Assert.IsTrue(HasAssignedPrintCategory(SourceLine, PrintCategory.Code), 'The source line should carry the print category before the split.');

        // [WHEN] Part of the line is split onto the other pad
        SplitLine(SourcePad, SourceLine, 1, TargetPad);

        // [THEN] The moved line carries the same print category and serving step
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.IsTrue(HasAssignedPrintCategory(NewLine, PrintCategory.Code), 'The moved line should carry the print category across.');
        _Assert.IsTrue(HasAssignedFlowStatus(NewLine, MainCourseStepTok), 'The moved line should carry its serving step across.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PartialSplit_PrintLogEntriesDivided()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] The record of what was sent is divided too, so a later resend knows what each bill still owes
        // [GIVEN] A line of four already sent to the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 4, true);
        CreatePad(TargetPad);

        // [WHEN] Three of the four are split onto the other pad
        SplitLine(SourcePad, SourceLine, 3, TargetPad);

        // [THEN] Both lines carry print log entries, and the sent quantities net out to what each pad owes
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreNotEqual(0, PrintLogCount(TargetPad."No.", NewLine."Line No."), 'The moved line should carry print log entries.');
        _Assert.AreEqual(3, PrintLogSentQuantity(TargetPad."No.", NewLine."Line No."), 'The moved line should be recorded as having three sent.');
        _Assert.AreEqual(1, PrintLogSentQuantity(SourcePad."No.", SourceLine."Line No."), 'The source line should be left recorded as having one sent.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MergeOfSentPad_KitchenLinksFollowToTarget()
    var
        SourcePad: Record "NPR NPRE Waiter Pad";
        TargetPad: Record "NPR NPRE Waiter Pad";
        SourceLine: Record "NPR NPRE Waiter Pad Line";
        NewLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Joining two tables' bills keeps the kitchen pointed at the surviving one
        // [GIVEN] A source pad whose only line is already with the kitchen
        Initialize();
        CreatePadWithLine(SourcePad, SourceLine, 2, true);
        CreatePad(TargetPad);

        // [WHEN] The source pad is merged into the target
        WaiterPadMgt.MergeWaiterPad(SourcePad, TargetPad);

        // [THEN] The kitchen work now hangs off the target pad and none is orphaned on the source
        FindOnlyLine(TargetPad."No.", NewLine);
        _Assert.AreEqual(2, SourceLinkQuantity(TargetPad."No.", NewLine."Line No."), 'The kitchen work should follow the merged line to the target pad.');
        _Assert.AreEqual(0, SourceLinkCount(SourcePad."No.", SourceLine."Line No."), 'No kitchen work should be left pointing at the emptied source pad.');
    end;

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

        // Manual close keeps the emptied source pad in the merge scenario from disappearing before it is asserted on.
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);

        // Routing selections with a blank seating location or serving step outrank the narrower ones a test builds, so the
        // table is wiped per test. Spelled out in full at NPREKitchenSendTests.Codeunit.al, in its Initialize.
        KitchenStationSelectionAll.DeleteAll();
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.AddKitchenStationAtStep(_Restaurant.Code, _SeatingLocation.Code, MainCourseStepTok, 0);
        Commit();
    end;

    local procedure CreatePad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Seating: Record "NPR NPRE Seating";
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
    end;

    local procedure CreatePadWithLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; Quantity: Decimal; SendToKitchen: Boolean)
    begin
        CreatePadWithLine(WaiterPad, WaiterPadLine, Quantity, SendToKitchen, '');
    end;

    local procedure CreatePadWithLine(var WaiterPad: Record "NPR NPRE Waiter Pad"; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; Quantity: Decimal; SendToKitchen: Boolean; PrintCategoryCode: Code[20])
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        CreatePad(WaiterPad);
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        if PrintCategoryCode <> '' then
            _LibraryRestaurant.AssignPrintCategoryToRoutingProfile(ItemRoutingProfile, PrintCategoryCode);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, 0, WaiterPadLine);
        if SendToKitchen then
            _LibraryRestaurant.SendWaiterPadToKitchen(WaiterPad);
        WaiterPadLine.Find();
    end;

    local procedure SplitLine(var SourcePad: Record "NPR NPRE Waiter Pad"; var SourceLine: Record "NPR NPRE Waiter Pad Line"; MoveQuantity: Decimal; TargetPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // The moved-line map has to be cleared at the start of an operation and the same codeunit instance kept
        // for its duration, which is how an add-on line finds its dish's new line number on the target pad.
        WaiterPadPOSMgt.ClearMovedWaiterPadLineMap();
        WaiterPadPOSMgt.SplitWaiterPadLine(SourcePad, SourceLine, MoveQuantity, TargetPad);
    end;

    local procedure FindOnlyLine(WaiterPadNo: Code[20]; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPadNo);
        _Assert.AreEqual(1, WaiterPadLine.Count(), 'The pad should hold exactly one line at this point.');
        WaiterPadLine.FindFirst();
    end;

    local procedure SourceLinkCount(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Integer
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        FilterSourceLinks(WaiterPadNo, WaiterPadLineNo, KitchenReqSourceLink);
        exit(KitchenReqSourceLink.Count());
    end;

    local procedure SourceLinkQuantity(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Decimal
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        // Splitting records the transfer as offsetting entries rather than editing the originals, so the quantity a
        // line currently owes the kitchen is the sum of its links, not the value on any single one.
        FilterSourceLinks(WaiterPadNo, WaiterPadLineNo, KitchenReqSourceLink);
        KitchenReqSourceLink.CalcSums(Quantity);
        exit(KitchenReqSourceLink.Quantity);
    end;

    local procedure FilterSourceLinks(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; var KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link")
    begin
        KitchenReqSourceLink.Reset();
        KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
        KitchenReqSourceLink.SetRange("Source Document No.", WaiterPadNo);
        KitchenReqSourceLink.SetRange("Source Document Line No.", WaiterPadLineNo);
    end;

    local procedure PrintLogCount(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Integer
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        FilterPrintLog(WaiterPadNo, WaiterPadLineNo, WPadLinePrintLogEntry);
        exit(WPadLinePrintLogEntry.Count());
    end;

    local procedure PrintLogSentQuantity(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): Decimal
    var
        WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry";
    begin
        FilterPrintLog(WaiterPadNo, WaiterPadLineNo, WPadLinePrintLogEntry);
        WPadLinePrintLogEntry.CalcSums("Sent Quanity (Base)");
        exit(WPadLinePrintLogEntry."Sent Quanity (Base)");
    end;

    local procedure FilterPrintLog(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer; var WPadLinePrintLogEntry: Record "NPR NPRE W.Pad Prnt LogEntry")
    begin
        WPadLinePrintLogEntry.Reset();
        WPadLinePrintLogEntry.SetRange("Waiter Pad No.", WaiterPadNo);
        WPadLinePrintLogEntry.SetRange("Waiter Pad Line No.", WaiterPadLineNo);
    end;

    local procedure HasAssignedPrintCategory(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; PrintCategoryCode: Code[20]): Boolean
    var
        AssignedPrintCategory: Record "NPR NPRE Assign. Print Cat.";
    begin
        AssignedPrintCategory.SetRange("Table No.", Database::"NPR NPRE Waiter Pad Line");
        AssignedPrintCategory.SetRange("Record ID", WaiterPadLine.RecordId);
        AssignedPrintCategory.SetRange("Print/Prod. Category Code", PrintCategoryCode);
        exit(not AssignedPrintCategory.IsEmpty());
    end;

    local procedure HasAssignedFlowStatus(WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; FlowStatusCode: Code[10]): Boolean
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        AssignedFlowStatus.SetRange("Table No.", Database::"NPR NPRE Waiter Pad Line");
        AssignedFlowStatus.SetRange("Record ID", WaiterPadLine.RecordId);
        AssignedFlowStatus.SetRange("Flow Status Object", AssignedFlowStatus."Flow Status Object"::WaiterPadLineMealFlow);
        AssignedFlowStatus.SetRange("Flow Status Code", FlowStatusCode);
        exit(not AssignedFlowStatus.IsEmpty());
    end;

    #endregion
}

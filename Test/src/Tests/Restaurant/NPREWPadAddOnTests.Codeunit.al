codeunit 85326 "NPR NPRE W/Pad AddOn Tests"
{
    // [FEATURE] Restaurant waiter pad <-> POS roundtrip of item add-on lines

    Subtype = Test;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Seating: Record "NPR NPRE Seating";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaveToWaiterPad_AddOnAddedToFirstMainItem_KeepsItUnderThatMainItem()
    var
        AddOn1WPLine: Record "NPR NPRE Waiter Pad Line";
        AddOnItem1: Record Item;
        AddOnItem2: Record Item;
        LateAddOnItem: Record Item;
        LateAddOnWPLine: Record "NPR NPRE Waiter Pad Line";
        Main1WPLine: Record "NPR NPRE Waiter Pad Line";
        Main2WPLine: Record "NPR NPRE Waiter Pad Line";
        MainItem1: Record Item;
        MainItem2: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        LateAddOnNo: Code[20];
        Main1LineNo: Integer;
    begin
        // [SCENARIO] An add-on added on POS to the first of two main items must be stored in the waiter pad between
        // that main item's existing add-ons and the second main item, not appended after the second main item.

        // [GIVEN] A restaurant POS sale with two main items, each carrying one add-on line
        Initialize(POSSession);
        CreateWaiterPad(WaiterPad);
        Main1LineNo := AddMainItemWithAddOn(POSSession, MainItem1, AddOnItem1);
        AddMainItemWithAddOn(POSSession, MainItem2, AddOnItem2);

        // [GIVEN] The sale has already been saved to the waiter pad once
        SaveSaleToWaiterPad(POSSession, WaiterPad, false);

        // [WHEN] Another add-on is added to the first main item and the sale is saved again
        LateAddOnNo := CreateAddOnWithOneItem(LateAddOnItem);
        RunItemAddOns(Main1LineNo, LateAddOnNo);
        VerifyPOSAddOnPrecedesLine(POSSession, LateAddOnItem."No.", MainItem2."No.");
        SaveSaleToWaiterPad(POSSession, WaiterPad, false);

        // [THEN] The new waiter pad line is positioned after its sibling add-on and before the second main item
        GetWaiterPadLine(WaiterPad, MainItem1."No.", Main1WPLine);
        GetWaiterPadLine(WaiterPad, AddOnItem1."No.", AddOn1WPLine);
        GetWaiterPadLine(WaiterPad, MainItem2."No.", Main2WPLine);
        GetWaiterPadLine(WaiterPad, LateAddOnItem."No.", LateAddOnWPLine);

        Assert.IsTrue(
            LateAddOnWPLine."Line No." > AddOn1WPLine."Line No.",
            'The new add-on must be positioned after the existing add-on of the same main item.');
        Assert.IsTrue(
            LateAddOnWPLine."Line No." < Main2WPLine."Line No.",
            'The new add-on must be positioned before the second main item, so that it is grouped under the first one.');

        // [THEN] It remains linked and indented under the first main item
        Assert.AreEqual(
            Main1WPLine."Line No.", LateAddOnWPLine."Attached to Line No.",
            'The new add-on must stay attached to the first main item.');
        Assert.AreEqual(
            Main1WPLine.Indentation + 1, LateAddOnWPLine.Indentation,
            'The new add-on must be indented one level below its main item.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RecallWaiterPad_TwoMainItemsWithAddOns_RebuildsPOSHierarchy()
    var
        AddOnItem1: Record Item;
        AddOnItem2: Record Item;
        LateAddOnItem: Record Item;
        MainItem1: Record Item;
        MainItem2: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        LateAddOnNo: Code[20];
        ExpectedItemNo: array[5] of Code[20];
        ExpectedIndentation: array[5] of Integer;
        Main1LineNo: Integer;
    begin
        // [SCENARIO] Recalling a waiter pad rebuilds the POS sale with every add-on directly below its own main
        // item and indented one level, also for add-ons that were added after the first save.

        // [GIVEN] A waiter pad holding two main items with add-ons, one of them added after the first save
        Initialize(POSSession);
        CreateWaiterPad(WaiterPad);
        Main1LineNo := AddMainItemWithAddOn(POSSession, MainItem1, AddOnItem1);
        AddMainItemWithAddOn(POSSession, MainItem2, AddOnItem2);
        SaveSaleToWaiterPad(POSSession, WaiterPad, false);
        LateAddOnNo := CreateAddOnWithOneItem(LateAddOnItem);
        RunItemAddOns(Main1LineNo, LateAddOnNo);

        // [GIVEN] The sale has been saved to the waiter pad and cleared from the POS
        SaveSaleToWaiterPad(POSSession, WaiterPad, true);

        // [WHEN] The waiter pad is recalled to the POS
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);

        // [THEN] The POS sale lines are in hierarchy order, with the add-ons indented below their main items
        ExpectedItemNo[1] := MainItem1."No.";
        ExpectedIndentation[1] := 0;
        ExpectedItemNo[2] := AddOnItem1."No.";
        ExpectedIndentation[2] := 1;
        ExpectedItemNo[3] := LateAddOnItem."No.";
        ExpectedIndentation[3] := 1;
        ExpectedItemNo[4] := MainItem2."No.";
        ExpectedIndentation[4] := 0;
        ExpectedItemNo[5] := AddOnItem2."No.";
        ExpectedIndentation[5] := 1;
        VerifyPOSSaleLineSequence(POSSession, ExpectedItemNo, ExpectedIndentation);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaveToWaiterPad_TwoAddOnsAddedToFirstMainItem_KeepsBothUnderThatMainItem()
    var
        AddOn1WPLine: Record "NPR NPRE Waiter Pad Line";
        AddOnItem1: Record Item;
        AddOnItem2: Record Item;
        LateAddOnItemA: Record Item;
        LateAddOnItemB: Record Item;
        LateAddOnWPLineA: Record "NPR NPRE Waiter Pad Line";
        LateAddOnWPLineB: Record "NPR NPRE Waiter Pad Line";
        Main2WPLine: Record "NPR NPRE Waiter Pad Line";
        MainItem1: Record Item;
        MainItem2: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Main1LineNo: Integer;
    begin
        // [SCENARIO] Several add-ons added to the same main item in one go must all end up between that main
        // item and the next one, in the order in which the POS holds them.

        // [GIVEN] A waiter pad already holding two main items with one add-on each
        Initialize(POSSession);
        CreateWaiterPad(WaiterPad);
        Main1LineNo := AddMainItemWithAddOn(POSSession, MainItem1, AddOnItem1);
        AddMainItemWithAddOn(POSSession, MainItem2, AddOnItem2);
        SaveSaleToWaiterPad(POSSession, WaiterPad, false);

        // [WHEN] Two more add-ons are added to the first main item and the sale is saved again
        RunItemAddOns(Main1LineNo, CreateAddOnWithOneItem(LateAddOnItemA));
        RunItemAddOns(Main1LineNo, CreateAddOnWithOneItem(LateAddOnItemB));
        SaveSaleToWaiterPad(POSSession, WaiterPad, false);

        // [THEN] Both are positioned after the original add-on and before the second main item, in POS order
        GetWaiterPadLine(WaiterPad, AddOnItem1."No.", AddOn1WPLine);
        GetWaiterPadLine(WaiterPad, MainItem2."No.", Main2WPLine);
        GetWaiterPadLine(WaiterPad, LateAddOnItemA."No.", LateAddOnWPLineA);
        GetWaiterPadLine(WaiterPad, LateAddOnItemB."No.", LateAddOnWPLineB);

        Assert.IsTrue(
            LateAddOnWPLineA."Line No." > AddOn1WPLine."Line No.",
            'The first new add-on must be positioned after the original add-on of the same main item.');
        Assert.IsTrue(
            LateAddOnWPLineB."Line No." > LateAddOnWPLineA."Line No.",
            'The second new add-on must be positioned after the first new add-on.');
        Assert.IsTrue(
            LateAddOnWPLineB."Line No." < Main2WPLine."Line No.",
            'Both new add-ons must be positioned before the second main item.');
    end;

    local procedure Initialize(var POSSession: Codeunit "NPR POS Session")
    var
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        Restaurant: Record "NPR NPRE Restaurant";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        SeatingLocation: Record "NPR NPRE Seating Location";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        POSSale: Codeunit "NPR POS Sale";
    begin
        LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore);

        LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        LibraryRestaurant.CreateMealFlowStatuses();
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, Restaurant.Code);
        LibraryRestaurant.CreateSeatingLocation(SeatingLocation, Restaurant.Code);
        // Kitchen orders are irrelevant here and would drag the print/KDS machinery into the test
        SeatingLocation."Auto Send Kitchen Order" := SeatingLocation."Auto Send Kitchen Order"::No;
        SeatingLocation.Modify();
        LibraryRestaurant.CreateSeating(_Seating, SeatingLocation.Code);

        _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
        _POSUnit.Modify();

        LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
    end;

    local procedure CreateWaiterPad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
    end;

    local procedure AddMainItemWithAddOn(POSSession: Codeunit "NPR POS Session"; var MainItem: Record Item; var AddOnItem: Record Item) MainLineNo: Integer
    var
        ItemReference: Record "Item Reference";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        POSActionInsertItem: Codeunit "NPR POS Action: Insert Item B";
        FrontEnd: Codeunit "NPR POS Front End Management";
        AddOnNo: Code[20];
    begin
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(MainItem, _POSUnit, _POSStore);
        POSActionInsertItem.AddItemLine(MainItem, ItemReference, 0, 1, 0, '', '', '', POSSession, FrontEnd, '');
        MainLineNo := POSActionInsertItem.GetLineNo();

        AddOnNo := CreateAddOnWithOneItem(AddOnItem);
        RunItemAddOns(MainLineNo, AddOnNo);
    end;

    local procedure CreateAddOnWithOneItem(var AddOnItem: Record Item) AddOnNo: Code[20]
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
    begin
        LibraryRestaurant.CreateItemAddon(ItemAddOn);
        LibraryPOSMasterData.CreateItemForPOSSaleUsage(AddOnItem, _POSUnit, _POSStore);

        // Mandatory + fixed quantity, so that the add-on line is inserted without any front-end interaction
        ItemAddOnLine.Init();
        ItemAddOnLine."AddOn No." := ItemAddOn."No.";
        ItemAddOnLine."Line No." := 10000;
        ItemAddOnLine.Type := ItemAddOnLine.Type::Quantity;
        ItemAddOnLine."Item No." := AddOnItem."No.";
        ItemAddOnLine.Description := AddOnItem.Description;
        ItemAddOnLine.Quantity := 1;
        ItemAddOnLine."Fixed Quantity" := true;
        ItemAddOnLine.Mandatory := true;
        ItemAddOnLine.Insert(true);

        exit(ItemAddOn."No.");
    end;

    local procedure RunItemAddOns(BaseLineNo: Integer; AddOnNo: Code[20])
    var
        POSActionRunItemAddOnB: Codeunit "NPR POS Action: RunItemAddOn B";
        UserSelectionJToken: JsonToken;
    begin
        POSActionRunItemAddOnB.RunItemAddOns(BaseLineNo, AddOnNo, false, true, false, UserSelectionJToken);
    end;

    local procedure SaveSaleToWaiterPad(POSSession: Codeunit "NPR POS Session"; var WaiterPad: Record "NPR NPRE Waiter Pad"; CleanupSale: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, CleanupSale);
        Commit();
    end;

    local procedure GetWaiterPadLine(WaiterPad: Record "NPR NPRE Waiter Pad"; ItemNo: Code[20]; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        Assert: Codeunit Assert;
    begin
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetRange("No.", ItemNo);
        Assert.IsTrue(WaiterPadLine.FindFirst(), StrSubstNo('No waiter pad line found for item %1.', ItemNo));
    end;

    local procedure VerifyPOSAddOnPrecedesLine(POSSession: Codeunit "NPR POS Session"; AddOnItemNo: Code[20]; NextMainItemNo: Code[20])
    var
        AddOnSaleLinePOS: Record "NPR POS Sale Line";
        MainSaleLinePOS: Record "NPR POS Sale Line";
        Assert: Codeunit Assert;
    begin
        // Guards the test's own premise: the POS puts a new add-on right below its main item, before the next one
        GetPOSSaleLine(POSSession, AddOnItemNo, AddOnSaleLinePOS);
        GetPOSSaleLine(POSSession, NextMainItemNo, MainSaleLinePOS);
        Assert.IsTrue(
            AddOnSaleLinePOS."Line No." < MainSaleLinePOS."Line No.",
            'Test prerequisite: on the POS the new add-on must be positioned before the second main item.');
    end;

    local procedure GetPOSSaleLine(POSSession: Codeunit "NPR POS Session"; ItemNo: Code[20]; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit Assert;
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", ItemNo);
        Assert.IsTrue(SaleLinePOS.FindFirst(), StrSubstNo('No POS sale line found for item %1.', ItemNo));
    end;

    local procedure VerifyPOSSaleLineSequence(POSSession: Codeunit "NPR POS Session"; ExpectedItemNo: array[5] of Code[20]; ExpectedIndentation: array[5] of Integer)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        Assert: Codeunit Assert;
        POSSale: Codeunit "NPR POS Sale";
        Position: Integer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SaleLinePOS.Reset();
        SaleLinePOS.SetCurrentKey("Register No.", "Sales Ticket No.", "Line No.");
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        Assert.AreEqual(ArrayLen(ExpectedItemNo), SaleLinePOS.Count(), 'Unexpected number of POS sale lines after recall.');

        SaleLinePOS.FindSet();
        repeat
            Position += 1;
            Assert.AreEqual(
                ExpectedItemNo[Position], SaleLinePOS."No.",
                StrSubstNo('Unexpected item on POS sale line no. %1 after recall.', Position));
            Assert.AreEqual(
                ExpectedIndentation[Position], SaleLinePOS.Indentation,
                StrSubstNo('Unexpected indentation on POS sale line no. %1 after recall.', Position));
        until SaleLinePOS.Next() = 0;
    end;
}

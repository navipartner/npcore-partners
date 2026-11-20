#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85347 "NPR NPRE Kitchen Modif. Tests"
{
    // [FEATURE] Kitchen request modifiers (item add-on lines shown to the kitchen)
    Subtype = Test;

    var
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Restaurant: Record "NPR NPRE Restaurant";
        _Seating: Record "NPR NPRE Seating";
        _SeatingLocation: Record "NPR NPRE Seating Location";
        _Assert: Codeunit Assert;
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _POSInitialized: Boolean;
        _RestaurantInitialized: Boolean;
        MainCourseStepTok: Label 'MAIN', Locked = true;
        FlaggedTok: Label 'flagged', Locked = true;
        ModifierQuantityTxt: Label 'quantity %1, quantity (base) %2', Locked = true, Comment = '%1 = quantity, %2 = quantity (base)';
        ModifierRowTxt: Label '%1|%2|%3|%4|%5', Locked = true, Comment = '%1 = description, %2 = line type, %3 = indentation, %4 = No., %5 = quantity';
        NotAttachedTok: Label 'nothing', Locked = true;
        NotFlaggedTok: Label 'not flagged', Locked = true;
        NotInTheSaleTok: Label 'not in the sale', Locked = true;
        RecalledCommentTxt: Label 'No. "%1", attached to %2', Locked = true, Comment = '%1 = No. of the comment line, %2 = No. of the line it is attached to';
        RowMismatchTxt: Label '%1: expected <%2>, actual <%3>. ', Locked = true, Comment = '%1 = scenario row, %2 = expected value, %3 = actual value';

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnSwappedAfterSending_WaiterPadSentAgain_ModifiersMatchWaiterPad()
    var
        NewAddOnItem: Record Item;
        OriginalAddOnItem: Record Item;
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        OriginalAddOnLine: Record "NPR NPRE Waiter Pad Line";
        NewAddOnLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        MainItem: Record Item;
        RequestNo: BigInteger;
    begin
        // [SCENARIO] A dish is sent to the kitchen, then its add-on lines are replaced on the waiter pad and the pad is sent again
        // [GIVEN] A dish with one add-on line, already sent to the kitchen
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(OriginalAddOnItem);
        CreateAddOnItem(NewAddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", OriginalAddOnItem."No.", 1, MainWaiterPadLine."Line No.", OriginalAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        _Assert.AreEqual(
            OriginalAddOnItem."No.", GetOnlyModifierItemNo(RequestNo),
            'The kitchen request should have been created with the add-on line that was on the waiter pad.');

        // [WHEN] The add-on line is replaced with a different one and the waiter pad is sent again
        OriginalAddOnLine.Delete(true);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", NewAddOnItem."No.", 1, MainWaiterPadLine."Line No.", NewAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The kitchen sees the add-on line that is now on the waiter pad
        _Assert.AreEqual(
            NewAddOnItem."No.", GetOnlyModifierItemNo(RequestNo),
            'The kitchen request modifiers should reflect the add-on lines currently on the waiter pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnSwappedAfterSending_WaiterPadSentAgain_KitchenStationsFlaggedAsChanged()
    var
        NewAddOnItem: Record Item;
        OriginalAddOnItem: Record Item;
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        OriginalAddOnLine: Record "NPR NPRE Waiter Pad Line";
        NewAddOnLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        MainItem: Record Item;
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Kitchen staff must be told that a dish they may already be preparing has been modified
        // [GIVEN] A dish with one add-on line, already sent to the kitchen and accepted by the station
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(OriginalAddOnItem);
        CreateAddOnItem(NewAddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", OriginalAddOnItem."No.", 1, MainWaiterPadLine."Line No.", OriginalAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        _Assert.RecordIsNotEmpty(KitchenRequestStation);
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", false);

        // [WHEN] The add-on line is replaced with a different one and the waiter pad is sent again
        OriginalAddOnLine.Delete(true);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", NewAddOnItem."No.", 1, MainWaiterPadLine."Line No.", NewAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The station requests are flagged as changed, the same way a quantity change flags them
        KitchenRequestStation.SetRange("Qty. Change Not Accepted", false);
        _Assert.RecordIsEmpty(KitchenRequestStation);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OnlyAddOnRemovedInPOS_SaleSavedBackToWaiterPad_ModifiersMatchWaiterPad()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] A waiter recalls a waiter pad, removes the only add-on line of a dish and saves the pad back.
        // Nothing is left to send to the kitchen, so the kitchen is only told about the change if the save itself reconciles it.
        // [GIVEN] A dish with one add-on line, on a waiter pad and already sent to the kitchen
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        _Assert.AreEqual(
            AddOnItem."No.", GetOnlyModifierItemNo(RequestNo),
            'The kitchen request should have been created with the add-on line that was on the waiter pad.');

        // [WHEN] The pad is recalled to the POS, the add-on line is removed and the sale is saved back to the pad
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        POSSale.GetCurrentSale(SalePOS);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("No.", AddOnItem."No.");
        SaleLinePOS.FindFirst();
        SaleLinePOS.Delete(true);
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);

        // [THEN] The add-on line is gone from the waiter pad
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetRange("No.", AddOnItem."No.");
        _Assert.RecordIsEmpty(WaiterPadLine);

        // [THEN] The kitchen no longer sees the removed add-on line either
        _Assert.AreEqual('', GetOnlyModifierItemNo(RequestNo), 'The removed add-on line should no longer be shown to the kitchen.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnLineHasVariant_SentToKitchen_ModifierCarriesVariantCode()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        ItemVariant: Record "Item Variant";
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] The kitchen has to be told which variant of an add-on item was ordered
        // [GIVEN] A dish with an add-on line of a specific item variant
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        CreateItemVariant(AddOnItem, ItemVariant);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        AddOnWaiterPadLine."Variant Code" := ItemVariant.Code;
        AddOnWaiterPadLine.Modify(true);

        // [WHEN] The waiter pad is sent to the kitchen
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The modifier line shown to the kitchen carries the variant of the add-on line
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        KitchenRequestModifier.FindFirst();
        _Assert.AreEqual(ItemVariant.Code, KitchenRequestModifier."Variant Code", 'The modifier line should carry the variant code of the add-on line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KitchenOrderDeleted_ModifierLinesOfItsRequestsDeletedToo()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Finished kitchen orders are removed by the retention policy and must not leave modifier lines behind
        // [GIVEN] A dish with an add-on line, sent to the kitchen
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        _Assert.AreEqual(AddOnItem."No.", GetOnlyModifierItemNo(RequestNo), 'The kitchen request should have been created with a modifier line.');

        // [WHEN] The kitchen order is deleted
        KitchenRequest.Get(RequestNo);
        KitchenOrder.Get(KitchenRequest."Order ID");
        KitchenOrder.Delete(true);

        // [THEN] No modifier lines are left behind
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        _Assert.RecordIsEmpty(KitchenRequestModifier);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaiterPadMerged_AddOnLineRelinkedToItsDishInTargetPad()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        OtherItem: Record Item;
        MergedAddOnLine: Record "NPR NPRE Waiter Pad Line";
        MergedMainLine: Record "NPR NPRE Waiter Pad Line";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        OtherWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MergeToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Merging one waiter pad into another renumbers its lines, so an add-on line must be relinked to its own dish
        // [GIVEN] A waiter pad holding a dish with an add-on line, and a second waiter pad that already holds a line of its own
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        CreateDishItem(OtherItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, MergeToWaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(MergeToWaiterPad."No.", OtherItem."No.", 1, 0, OtherWaiterPadLine);

        // [WHEN] The first waiter pad is merged into the second one
        WaiterPadMgt.MergeWaiterPad(WaiterPad, MergeToWaiterPad);

        // [THEN] The add-on line points at its own dish in the target waiter pad, not at the line number it had in the source pad
        MergedMainLine.SetRange("Waiter Pad No.", MergeToWaiterPad."No.");
        MergedMainLine.SetRange("No.", MainItem."No.");
        MergedMainLine.FindFirst();
        MergedAddOnLine.SetRange("Waiter Pad No.", MergeToWaiterPad."No.");
        MergedAddOnLine.SetRange("No.", AddOnItem."No.");
        MergedAddOnLine.FindFirst();
        _Assert.AreEqual(
            MergedMainLine."Line No.", MergedAddOnLine."Attached to Line No.",
            'The merged add-on line should be attached to its own dish in the target waiter pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaiterPadMerged_TargetPadSentToKitchen_ModifiersStillShowTheAddOn()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        OtherItem: Record Item;
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        OtherWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MergeToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Merging waiter pads must not make the kitchen lose the add-ons of a dish that is already being prepared
        // [GIVEN] A dish with an add-on line, sent to the kitchen, on a waiter pad that is then merged into another one
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        CreateDishItem(OtherItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad, false);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        _Assert.RecordIsNotEmpty(KitchenRequestStation);
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", false);

        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, MergeToWaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(MergeToWaiterPad."No.", OtherItem."No.", 1, 0, OtherWaiterPadLine);
        WaiterPadMgt.MergeWaiterPad(WaiterPad, MergeToWaiterPad);

        // [WHEN] The merged waiter pad is sent to the kitchen
        SendWaiterPadToKitchen(MergeToWaiterPad, false);

        // [THEN] The kitchen still sees the add-on line of the dish
        _Assert.AreEqual(AddOnItem."No.", GetOnlyModifierItemNo(RequestNo), 'The merge should not remove the add-on lines the kitchen was told about.');

        // [THEN] Nothing changed for the dish, so the station is not asked to accept a change
        KitchenRequestStation.SetRange("Qty. Change Not Accepted", true);
        _Assert.RecordIsEmpty(KitchenRequestStation);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OnlyAddOnRemoved_WaiterPadSentManually_ModifiersUpdatedWithoutNothingToSendError()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] A waiter removes the only add-on of a dish on the waiter pad and presses "send to kitchen".
        // Nothing is eligible for sending, so the send routine would report "nothing to send" and roll back the reconcile.
        // [GIVEN] A dish with one add-on line, already sent to the kitchen
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad, false);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");

        // [WHEN] The add-on line is removed and the waiter pad is sent to the kitchen the way the POS action sends it
        AddOnWaiterPadLine.Delete(true);
        SendWaiterPadToKitchen(WaiterPad, true);

        // [THEN] The send is not reported as "nothing to send", and the kitchen no longer shows the removed add-on
        _Assert.AreEqual('', GetOnlyModifierItemNo(RequestNo), 'The removed add-on line should no longer be shown to the kitchen.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnchangedWaiterPadSentAgain_KitchenNotAskedToAcceptAChange()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Routine sends of an unchanged waiter pad must not nag the kitchen to re-accept every dish
        // [GIVEN] A dish with an add-on line, sent to the kitchen and accepted by the station
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad, false);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        _Assert.RecordIsNotEmpty(KitchenRequestStation);
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", false);

        // [WHEN] The waiter pad is sent again with nothing changed
        SendWaiterPadToKitchen(WaiterPad, false);

        // [THEN] The station is not flagged, and the add-on line the kitchen holds is left as it was
        KitchenRequestStation.SetRange("Qty. Change Not Accepted", true);
        _Assert.RecordIsEmpty(KitchenRequestStation);
        _Assert.AreEqual(AddOnItem."No.", GetOnlyModifierItemNo(RequestNo), 'The modifier line should be left untouched when nothing changed.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnAddedAfterSending_NextServingRequested_ServingRequestReachesTheKitchen()
    var
        AddOnItem: Record Item;
        LateAddOnItem: Record Item;
        MainItem: Record Item;
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        LateAddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Requesting the next serving step must fire the serving request, not stop at the first step
        // just because the kitchen's copy of some dish's add-on lines happened to need reconciling
        // [GIVEN] A dish sent to the kitchen for the main course step, whose add-on lines have changed since
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        CreateAddOnItem(LateAddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", LateAddOnItem."No.", 1, MainWaiterPadLine."Line No.", LateAddOnWaiterPadLine);

        // [WHEN] The waiter requests the next serving step, which auto-advances until a step actually has something to send
        RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, true, '', true);

        // [THEN] The serving request reached the dish, rather than being reported as sent while stopping at an earlier step
        KitchenRequest.Get(RequestNo);
        _Assert.AreNotEqual(0DT, KitchenRequest."Serving Requested Date-Time", 'The serving request should have been sent for the dish.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBillListsAddOnBeforeItsDish_BillMoved_AddOnStaysAttachedToItsDish()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        MovedAddOnLine: Record "NPR NPRE Waiter Pad Line";
        MovedMainLine: Record "NPR NPRE Waiter Pad Line";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SplitToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        WaiterPadNo: Code[20];
    begin
        // [SCENARIO] The split bill dialog lists a dish and its add-ons as independently movable rows, in whatever order
        // the front end sends them. Moving both to the same bill must keep them together.
        // [GIVEN] A waiter pad with a dish and its add-on line, and a bill listing the add-on before the dish
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, SplitToWaiterPad);

        AddBillLine(BillLines, AddOnWaiterPadLine);
        AddBillLine(BillLines, MainWaiterPadLine);

        // [WHEN] The bill is moved to the other waiter pad
        WaiterPadNo := WaiterPad."No.";
        SplitBillToWaiterPad(WaiterPadNo, BillLines, SplitToWaiterPad);

        // [THEN] The add-on line is attached to its own dish on the target waiter pad
        MovedMainLine.SetRange("Waiter Pad No.", SplitToWaiterPad."No.");
        MovedMainLine.SetRange("No.", MainItem."No.");
        MovedMainLine.FindFirst();
        MovedAddOnLine.SetRange("Waiter Pad No.", SplitToWaiterPad."No.");
        MovedAddOnLine.SetRange("No.", AddOnItem."No.");
        MovedAddOnLine.FindFirst();
        _Assert.AreEqual(
            MovedMainLine."Line No.", MovedAddOnLine."Attached to Line No.",
            'The add-on line should stay attached to its dish even when the bill lists it first.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishPartlySplitAndMergedBack_SentToKitchen_ModifiersStillShowTheAddOn()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SplitToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Splitting part of a dish onto another bill and merging it back leaves the kitchen request sourced from
        // two lines of the same waiter pad, only one of which carries the add-on lines
        // [GIVEN] A dish of quantity 2 with an add-on line, sent to the kitchen
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 2, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");

        // [GIVEN] Half of the dish and its add-on are split onto a second waiter pad, which is then merged back
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, SplitToWaiterPad);
        MainWaiterPadLine.Find();
        WaiterPadPOSMgt.SplitWaiterPadLine(WaiterPad, MainWaiterPadLine, 1, SplitToWaiterPad);
        AddOnWaiterPadLine.Find();
        WaiterPadPOSMgt.SplitWaiterPadLine(WaiterPad, AddOnWaiterPadLine, 1, SplitToWaiterPad);
        WaiterPadMgt.MergeWaiterPad(SplitToWaiterPad, WaiterPad);

        // [WHEN] The waiter pad is sent to the kitchen
        WaiterPad.Find();
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The kitchen still shows the add-on line, which is now justified by the second source line of the request
        _Assert.AreEqual(
            AddOnItem."No.", GetOnlyModifierItemNo(RequestNo),
            'A request sourced from two lines of the same waiter pad should not lose its add-on lines.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DishPartlySplitToAnotherBill_SentToKitchen_ModifiersNotOverwrittenWithOneBillsShare()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SplitToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Half of a dish and half of its add-on move to another bill. The kitchen request now spans both bills, so
        // neither of them alone describes what was ordered and neither may overwrite the kitchen's copy with its own share.
        // [GIVEN] A dish of quantity 2 with an add-on line of quantity 2, sent to the kitchen
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 2, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 2, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");

        // [GIVEN] Half of the dish and half of its add-on are moved to a second bill
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, SplitToWaiterPad);
        MainWaiterPadLine.Find();
        WaiterPadPOSMgt.SplitWaiterPadLine(WaiterPad, MainWaiterPadLine, 1, SplitToWaiterPad);
        AddOnWaiterPadLine.Find();
        WaiterPadPOSMgt.SplitWaiterPadLine(WaiterPad, AddOnWaiterPadLine, 1, SplitToWaiterPad);

        // [WHEN] The second bill is sent to the kitchen
        SplitToWaiterPad.Find();
        SendWaiterPadToKitchen(SplitToWaiterPad);

        // [THEN] The kitchen still holds what was ordered, not the half that happens to sit on the bill that was sent
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        KitchenRequestModifier.FindFirst();
        _Assert.AreEqual(
            2, KitchenRequestModifier.Quantity,
            'A kitchen request shared by two bills should keep its modifier lines rather than take one bill''s share.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SplitBillListsAddOnChainOutOfOrder_BillMoved_AddOnChainStaysIntact()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        SubAddOnItem: Record Item;
        MovedAddOnLine: Record "NPR NPRE Waiter Pad Line";
        MovedSubAddOnLine: Record "NPR NPRE Waiter Pad Line";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SubAddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        SplitToWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        BillLines: JsonArray;
        WaiterPadNo: Code[20];
    begin
        // [SCENARIO] An add-on can itself carry an add-on. Moving such a chain to another bill must keep the whole chain
        // together, whatever order the front end lists the lines in.
        // [GIVEN] A dish with an add-on line that has an add-on line of its own, and a bill listing the chain bottom-up
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        CreateAddOnItem(SubAddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", SubAddOnItem."No.", 1, AddOnWaiterPadLine."Line No.", SubAddOnWaiterPadLine);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, SplitToWaiterPad);

        AddBillLine(BillLines, SubAddOnWaiterPadLine);
        AddBillLine(BillLines, AddOnWaiterPadLine);
        AddBillLine(BillLines, MainWaiterPadLine);

        // [WHEN] The bill is moved to the other waiter pad
        WaiterPadNo := WaiterPad."No.";
        SplitBillToWaiterPad(WaiterPadNo, BillLines, SplitToWaiterPad);

        // [THEN] The add-on of the add-on is still attached to the add-on it belongs to
        MovedAddOnLine.SetRange("Waiter Pad No.", SplitToWaiterPad."No.");
        MovedAddOnLine.SetRange("No.", AddOnItem."No.");
        MovedAddOnLine.FindFirst();
        MovedSubAddOnLine.SetRange("Waiter Pad No.", SplitToWaiterPad."No.");
        MovedSubAddOnLine.SetRange("No.", SubAddOnItem."No.");
        MovedSubAddOnLine.FindFirst();
        _Assert.AreEqual(
            MovedAddOnLine."Line No.", MovedSubAddOnLine."Attached to Line No.",
            'The add-on of the add-on should stay attached to it, whatever order the bill lists the chain in.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OneOfTwoAddOnsSwapped_WaiterPadSentAgain_BothModifiersMatchAndResendChangesNothing()
    var
        FirstAddOnItem: Record Item;
        MainItem: Record Item;
        NewAddOnItem: Record Item;
        SecondAddOnItem: Record Item;
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        FirstAddOnLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        NewAddOnLine: Record "NPR NPRE Waiter Pad Line";
        SecondAddOnLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] A dish usually carries several add-on lines, and replacing one of them must leave the others alone
        // [GIVEN] A dish with two add-on lines, sent to the kitchen
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(FirstAddOnItem);
        CreateAddOnItem(SecondAddOnItem);
        CreateAddOnItem(NewAddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", FirstAddOnItem."No.", 1, MainWaiterPadLine."Line No.", FirstAddOnLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", SecondAddOnItem."No.", 1, MainWaiterPadLine."Line No.", SecondAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");

        // [WHEN] The second add-on line is replaced and the waiter pad is sent again
        SecondAddOnLine.Delete(true);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", NewAddOnItem."No.", 1, MainWaiterPadLine."Line No.", NewAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The kitchen holds both add-on lines, the untouched one first
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        _Assert.AreEqual(2, KitchenRequestModifier.Count(), 'The kitchen request should hold both add-on lines.');
        KitchenRequestModifier.FindFirst();
        _Assert.AreEqual(FirstAddOnItem."No.", KitchenRequestModifier."No.", 'The untouched add-on line should still be the first one.');
        KitchenRequestModifier.FindLast();
        _Assert.AreEqual(NewAddOnItem."No.", KitchenRequestModifier."No.", 'The replaced add-on line should be the second one.');

        // [WHEN] The waiter pad is sent once more with nothing changed
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        _Assert.RecordIsNotEmpty(KitchenRequestStation);
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", false);
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] Nothing is rewritten and the kitchen is not asked to accept anything
        KitchenRequestStation.SetRange("Qty. Change Not Accepted", true);
        _Assert.RecordIsEmpty(KitchenRequestStation);
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        _Assert.AreEqual(2, KitchenRequestModifier.Count(), 'Sending an unchanged waiter pad should leave both add-on lines as they are.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AddOnQuantityChangedAfterSending_WaiterPadSentAgain_ModifierCarriesNewQuantity()
    var
        AddOnItem: Record Item;
        MainItem: Record Item;
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        AddOnWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Ordering one more of the same add-on is a change to the quantity alone, with the add-on lines otherwise
        // identical, and the kitchen has to be told
        // [GIVEN] A dish with one of an add-on line, sent to the kitchen
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");

        // [WHEN] The add-on line quantity is raised and the waiter pad is sent again
        AddOnWaiterPadLine.Find();
        AddOnWaiterPadLine.Validate(Quantity, 2);
        AddOnWaiterPadLine.Modify(true);
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The kitchen sees the new quantity
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        KitchenRequestModifier.FindFirst();
        _Assert.AreEqual(2, KitchenRequestModifier.Quantity, 'The modifier line should carry the quantity now on the waiter pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommentLineAttachedToDish_SentToKitchen_ModifierCarriesTheComment()
    var
        MainItem: Record Item;
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        CommentWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RequestNo: BigInteger;
        NoOnionsTok: Label 'No onions', Locked = true;
    begin
        // [SCENARIO] A comment on a dish is the plainest kind of modification there is. Comment lines are never sent to the
        // kitchen on their own, so they reach it only as a modifier of the dish they are attached to.
        // [GIVEN] A dish with a comment line attached to it
        Initialize();
        CreateDishItem(MainItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", NoOnionsTok, MainWaiterPadLine."Line No.", CommentWaiterPadLine);

        // [WHEN] The waiter pad is sent to the kitchen
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The kitchen sees the comment as a modification of the dish
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        KitchenRequestModifier.FindFirst();
        _Assert.AreEqual(
            KitchenRequestModifier."Line Type"::Comment, KitchenRequestModifier."Line Type", 'The modifier line should be a comment.');
        _Assert.AreEqual(NoOnionsTok, KitchenRequestModifier.Description, 'The modifier line should carry the comment text.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StarCommentAttachedToDish_SentToKitchen_ModifierIsACommentRowWithItsIndentation()
    var
        MainItem: Record Item;
        CommentWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A comment attached to a dish reaches the dish request as a Comment modifier with quantity 0, No. "*" and the comment's indentation
        // [GIVEN] A pad with DISH 10000 and "No onions" attached to it, saved from the POS with No. "*"
        Initialize();
        CreateDishItem(MainItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', MainWaiterPadLine, CommentWaiterPadLine);

        // [WHEN] The waiter pad is sent to the kitchen
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The DISH request has the single modifier "No onions", type Comment, indentation 1, No. "*", quantity 0
        _Assert.AreEqual(
            ModifierRow('No onions', Enum::"NPR POS Sale Line Type"::Comment, 1, '*', 0),
            ModifierRows(GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.")),
            'S12.a: the DISH request should list "No onions" as its only modifier, a Comment with indentation 1.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommentsOfAddOns_SentToKitchen_ListedAfterTheirAddOnInTheDishModifiers()
    var
        AddOnKItem: Record Item;
        AddOnMItem: Record Item;
        MainItem: Record Item;
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        AddOnKRow: Text;
        AddOnMRow: Text;
        Mismatches: Text;
    begin
        // [SCENARIO] The dish request lists its direct children in line order, each followed by the comments attached to it; an add-on request lists its own comments as today
        Initialize();

        // [GIVEN] Per row, a pad with DISH, ADDON-K (its own request) and ADDON-M attached to DISH, and the row's comments
        // [WHEN] The waiter pad is sent to the kitchen
        // [THEN] The DISH request and the ADDON-K request list the row's modifiers in the row's order
        CreateDishWithBothAddOns(WaiterPad, MainItem, AddOnKItem, AddOnMItem, MainLine, AddOnKLine, AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'extra hot', AddOnMLine, CommentLine);
        SendWaiterPadToKitchen(WaiterPad);
        AddOnKRow := ModifierRow(AddOnKLine.Description, Enum::"NPR POS Sale Line Type"::Item, 1, AddOnKItem."No.", 1);
        AddOnMRow := ModifierRow(AddOnMLine.Description, Enum::"NPR POS Sale Line Type"::Item, 1, AddOnMItem."No.", 1);
        CheckRow(
            'S12.b DISH', AddOnKRow + '; ' + AddOnMRow + '; ' + ModifierRow('extra hot', Enum::"NPR POS Sale Line Type"::Comment, 2, '*', 0),
            ModifierRows(GetKitchenRequestNo(WaiterPad."No.", MainLine."Line No.")), Mismatches);
        CheckRow('S12.b ADDON-K', '', ModifierRows(GetKitchenRequestNo(WaiterPad."No.", AddOnKLine."Line No.")), Mismatches);

        CreateDishWithBothAddOns(WaiterPad, MainItem, AddOnKItem, AddOnMItem, MainLine, AddOnKLine, AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'well done', AddOnKLine, CommentLine);
        SendWaiterPadToKitchen(WaiterPad);
        AddOnKRow := ModifierRow(AddOnKLine.Description, Enum::"NPR POS Sale Line Type"::Item, 1, AddOnKItem."No.", 1);
        AddOnMRow := ModifierRow(AddOnMLine.Description, Enum::"NPR POS Sale Line Type"::Item, 1, AddOnMItem."No.", 1);
        CheckRow(
            'S12.c DISH', AddOnKRow + '; ' + ModifierRow('well done', Enum::"NPR POS Sale Line Type"::Comment, 2, '*', 0) + '; ' + AddOnMRow,
            ModifierRows(GetKitchenRequestNo(WaiterPad."No.", MainLine."Line No.")), Mismatches);
        CheckRow(
            'S12.c ADDON-K', ModifierRow('well done', Enum::"NPR POS Sale Line Type"::Comment, 2, '*', 0),
            ModifierRows(GetKitchenRequestNo(WaiterPad."No.", AddOnKLine."Line No.")), Mismatches);

        CreateDishItem(MainItem);
        CreateDishItem(AddOnKItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnKItem."No.", 1, MainLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'well done', AddOnKLine, CommentLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', MainLine, CommentLine);
        SendWaiterPadToKitchen(WaiterPad);
        AddOnKRow := ModifierRow(AddOnKLine.Description, Enum::"NPR POS Sale Line Type"::Item, 1, AddOnKItem."No.", 1);
        CheckRow(
            'S12.d DISH',
            AddOnKRow + '; ' + ModifierRow('well done', Enum::"NPR POS Sale Line Type"::Comment, 2, '*', 0) + '; ' + ModifierRow('No onions', Enum::"NPR POS Sale Line Type"::Comment, 1, '*', 0),
            ModifierRows(GetKitchenRequestNo(WaiterPad."No.", MainLine."Line No.")), Mismatches);
        CheckRow(
            'S12.d ADDON-K', ModifierRow('well done', Enum::"NPR POS Sale Line Type"::Comment, 2, '*', 0),
            ModifierRows(GetKitchenRequestNo(WaiterPad."No.", AddOnKLine."Line No.")), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S12.b, S12.c and S12.d: the kitchen request modifiers of DISH and ADDON-K.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommentOfAnAddOnWithAQuantityOnItsLine_SentToKitchen_CommentModifierHasQuantityZero()
    var
        AddOnMItem: Record Item;
        MainItem: Record Item;
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A comment modifier has quantity 0, also when the waiter pad line of the comment carries a quantity
        // [GIVEN] A pad with DISH, ADDON-M attached to DISH and "extra hot" attached to ADDON-M, with quantity 2 on the line of "extra hot"
        Initialize();
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnMItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnMItem."No.", 1, MainLine."Line No.", AddOnMLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'extra hot', AddOnMLine, CommentLine);
        CommentLine.Quantity := 2;
        CommentLine."Quantity (Base)" := 2;
        CommentLine.Modify();

        // [WHEN] The waiter pad is sent to the kitchen
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The "extra hot" modifier of the DISH request has quantity 0 and quantity (base) 0
        KitchenRequestModifier.SetRange("Request No.", GetKitchenRequestNo(WaiterPad."No.", MainLine."Line No."));
        KitchenRequestModifier.SetRange(Description, 'extra hot');
        _Assert.IsTrue(KitchenRequestModifier.FindFirst(), 'S12.b-qty: "extra hot" should be a modifier of the DISH request.');
        _Assert.AreEqual(
            StrSubstNo(ModifierQuantityTxt, 0, 0), StrSubstNo(ModifierQuantityTxt, KitchenRequestModifier.Quantity, KitchenRequestModifier."Quantity (Base)"),
            'S12.b-qty: the "extra hot" modifier of the DISH request should have quantity 0 and quantity (base) 0, whatever quantity its waiter pad line has.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OrdinaryCommentAfterADish_SentToKitchen_NotAModifierOfTheDish()
    var
        MainItem: Record Item;
        CommentWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        MainWaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A comment that is not attached is not a modifier of the dish it follows
        // [GIVEN] A pad with DISH 10000 and the ordinary "Table 6 VIP" 20000
        Initialize();
        CreateDishItem(MainItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Table 6 VIP', 0, CommentWaiterPadLine);

        // [WHEN] The waiter pad is sent to the kitchen
        SendWaiterPadToKitchen(WaiterPad);

        // [THEN] The DISH request has no modifiers
        _Assert.AreEqual(
            '', ModifierRows(GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.")), 'S12.e: "Table 6 VIP" should not be a modifier of DISH.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommentOfADishChangedAfterSending_PadSentAgain_StationsFlaggedOnlyWhenTheCommentChanged()
    var
        MainItem: Record Item;
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RequestNo: BigInteger;
        Mismatches: Text;
    begin
        // [SCENARIO] Adding or deleting a comment of a dish after sending flags the dish stations; sending again with no change does not
        Initialize();

        // [GIVEN] Per row, the row's pad sent to the kitchen and accepted by the stations
        // [WHEN] The row's change is made and the pad is sent again
        // [THEN] The DISH stations are flagged as the row says
        CreateDishItem(MainItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainLine);
        RequestNo := SendAndAcceptRequest(WaiterPad, MainLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', MainLine, CommentLine);
        SendWaiterPadToKitchen(WaiterPad);
        CheckRow('S13.a DISH stations', FlaggedTok, StationsFlagged(RequestNo), Mismatches);

        CreatePadWithCommentedDish(WaiterPad, MainLine, CommentLine);
        RequestNo := SendAndAcceptRequest(WaiterPad, MainLine);
        SendWaiterPadToKitchen(WaiterPad);
        CheckRow('S13.c DISH stations', NotFlaggedTok, StationsFlagged(RequestNo), Mismatches);

        CreatePadWithCommentedDish(WaiterPad, MainLine, CommentLine);
        RequestNo := SendAndAcceptRequest(WaiterPad, MainLine);
        CommentLine.Find();
        CommentLine.Delete(true);
        SendWaiterPadToKitchen(WaiterPad);
        CheckRow('S13.f DISH stations', FlaggedTok, StationsFlagged(RequestNo), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S13.a, S13.c and S13.f: only a changed comment of DISH flags its stations.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommentAddedToAnAddOnAfterSending_PadSentAgain_DishStationsFlagged()
    var
        AddOnKItem: Record Item;
        AddOnMItem: Record Item;
        MainItem: Record Item;
        AddOnKLine: Record "NPR NPRE Waiter Pad Line";
        AddOnMLine: Record "NPR NPRE Waiter Pad Line";
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        AddOnKRequestNo: BigInteger;
        DishRequestNo: BigInteger;
        Mismatches: Text;
    begin
        // [SCENARIO] A comment added to an add-on after sending changes the dish modifiers, so the dish stations are flagged as for an add-on change
        Initialize();

        // [GIVEN] Per row, a pad with DISH and the row's add-on, sent to the kitchen and accepted by the stations
        // [WHEN] The row's comment is attached to the add-on and the pad is sent again
        // [THEN] The DISH stations, and the ADDON-K stations when ADDON-K has a request, are flagged
        CreateDishItem(MainItem);
        CreateAddOnItem(AddOnMItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnMItem."No.", 1, MainLine."Line No.", AddOnMLine);
        DishRequestNo := SendAndAcceptRequest(WaiterPad, MainLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'extra hot', AddOnMLine, CommentLine);
        SendWaiterPadToKitchen(WaiterPad);
        CheckRow('S13.b DISH stations', FlaggedTok, StationsFlagged(DishRequestNo), Mismatches);

        CreateDishItem(MainItem);
        CreateDishItem(AddOnKItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnKItem."No.", 1, MainLine."Line No.", AddOnKLine);
        DishRequestNo := SendAndAcceptRequest(WaiterPad, MainLine);
        AddOnKRequestNo := GetKitchenRequestNo(WaiterPad."No.", AddOnKLine."Line No.");
        AcceptRequest(AddOnKRequestNo);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'well done', AddOnKLine, CommentLine);
        SendWaiterPadToKitchen(WaiterPad);
        CheckRow('S13.g DISH stations', FlaggedTok, StationsFlagged(DishRequestNo), Mismatches);
        CheckRow('S13.g ADDON-K stations', FlaggedTok, StationsFlagged(AddOnKRequestNo), Mismatches);
        _Assert.AreEqual('', Mismatches, 'Rows S13.b and S13.g: a comment added to an add-on after sending flags the stations of DISH.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadWithAttachedComment_RecalledAndSavedWithoutAChange_NoStationFlagged()
    var
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Recalling a sent pad with an attached comment and saving it back unchanged does not ask the kitchen to accept a change
        // [GIVEN] A pad with DISH and "No onions" attached, sent to the kitchen and accepted by the stations
        Initialize();
        CreatePadWithCommentedDish(WaiterPad, MainLine, CommentLine);
        RequestNo := SendAndAcceptRequest(WaiterPad, MainLine);

        // [WHEN] The pad is recalled to the POS
        RecallPad(WaiterPad, POSSession, SalePOS);

        // [THEN] "No onions" is back in the sale with No. "*", attached to DISH
        _Assert.AreEqual(
            StrSubstNo(RecalledCommentTxt, '*', MainLine."No."), RecalledComment(SalePOS, 'No onions'),
            'S13.d: after the recall "No onions" should be in the sale with No. "*", attached to DISH, as on the pad.');

        // [WHEN] The sale is saved back to the pad without changes
        SaveSaleToPad(SalePOS, WaiterPad);

        // [THEN] No DISH station is flagged
        _Assert.AreEqual(NotFlaggedTok, StationsFlagged(RequestNo), 'S13.d: recalling and saving again without a change should not flag the DISH stations.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AttachedCommentTextChangedInPOS_SavedBack_DishModifierChangedAndStationsFlagged()
    var
        MainItem: Record Item;
        CommentLine: Record "NPR NPRE Waiter Pad Line";
        MainLine: Record "NPR NPRE Waiter Pad Line";
        CommentSaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        RequestNo: BigInteger;
    begin
        // [SCENARIO] Changing the text of an attached comment after sending reaches the dish request on the next save and flags its stations
        // [GIVEN] A pad with DISH and "No onions" attached, sent to the kitchen and accepted by the stations, recalled to the POS
        Initialize();
        CreateDishItem(MainItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainLine);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'No onions', MainLine."Line No.", CommentLine);
        RequestNo := SendAndAcceptRequest(WaiterPad, MainLine);
        RecallPad(WaiterPad, POSSession, SalePOS);

        // [WHEN] The text of "No onions" is changed to "No onions, no garlic" in the POS and the sale is saved back
        CommentSaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        CommentSaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        CommentSaleLinePOS.SetRange(Description, 'No onions');
        CommentSaleLinePOS.FindFirst();
        CommentSaleLinePOS.Description := 'No onions, no garlic';
        CommentSaleLinePOS.Modify();
        SaveSaleToPad(SalePOS, WaiterPad);

        // [THEN] The DISH request modifier carries the new text and the DISH stations are flagged
        _Assert.AreEqual(
            ModifierRow('No onions, no garlic', Enum::"NPR POS Sale Line Type"::Comment, 1, '', 0), ModifierRows(RequestNo),
            'S13.e: the DISH request modifier should carry the changed text "No onions, no garlic".');
        _Assert.AreEqual(FlaggedTok, StationsFlagged(RequestNo), 'S13.e: changing the comment text should flag the DISH stations.');
    end;

    local procedure Initialize()
    var
        KitchenStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
    begin
        _LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore);
        if _RestaurantInitialized then
            exit;

        _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        _LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        _LibraryRestaurant.CreateMealFlowStatuses();
        _LibraryRestaurant.CreateRestaurant(_Restaurant, ServFlowProfile.Code);
        _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);
        _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
        _LibraryRestaurant.CreateSeating(_Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateKitchenStation(KitchenStation, _Restaurant.Code);

        // Route the main course step to a kitchen station. Add-on items carry no routing profile, so they
        // produce no kitchen request of their own and reach the kitchen only as request modifiers.
        KitchenStationSelection.Init();
        KitchenStationSelection."Restaurant Code" := _Restaurant.Code;
        KitchenStationSelection."Seating Location" := _SeatingLocation.Code;
        KitchenStationSelection."Serving Step" := MainCourseStepTok;
        KitchenStationSelection."Production Restaurant Code" := _Restaurant.Code;
        KitchenStationSelection."Kitchen Station" := KitchenStation.Code;
        KitchenStationSelection."Production Step" := 1;
        KitchenStationSelection.Insert(true);

        _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
        _POSUnit.Modify();

        _RestaurantInitialized := true;
        Commit();
    end;

    local procedure CreateDishItem(var Item: Record Item)
    var
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
    end;

    local procedure CreateAddOnItem(var Item: Record Item)
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
    end;

    local procedure CreateItemVariant(Item: Record Item; var ItemVariant: Record "Item Variant")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        ItemVariant.Init();
        ItemVariant."Item No." := Item."No.";
        ItemVariant.Code := CopyStr(LibraryUtility.GenerateRandomCode(ItemVariant.FieldNo(Code), Database::"Item Variant"), 1, MaxStrLen(ItemVariant.Code));
        ItemVariant.Description := 'Test Item Variant';
        ItemVariant.Insert(true);
    end;

    local procedure AddBillLine(var BillLines: JsonArray; WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        BillLine: JsonObject;
    begin
        BillLine.Add('key', WaiterPadLine.GetPosition());
        BillLine.Add('qty', WaiterPadLine.Quantity);
        BillLines.Add(BillLine);
    end;

    local procedure SplitLinesToWaiterPad(var WaiterPadNo: Code[20]; WaiterPadLine: Record "NPR NPRE Waiter Pad Line"; ToWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        BillLines: JsonArray;
    begin
        AddBillLine(BillLines, WaiterPadLine);
        SplitBillToWaiterPad(WaiterPadNo, BillLines, ToWaiterPad);
    end;

    local procedure SplitBillToWaiterPad(var WaiterPadNo: Code[20]; BillLines: JsonArray; ToWaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SplitBill: Codeunit "NPR POSAction Split Bill-B";
        Bills: JsonArray;
        Bill: JsonObject;
        BillsToken: JsonToken;
    begin
        //One call is one split operation, the way the POS action runs it, each with its own instance of the split routine
        Bill.Add('id', ToWaiterPad."No.");
        Bill.Add('items', BillLines);
        Bills.Add(Bill);
        BillsToken := Bills.AsToken();
        SplitBill.ProcessWaiterPadSplit(WaiterPadNo, BillsToken, 0);
    end;

    local procedure SendWaiterPadToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        SendWaiterPadToKitchen(WaiterPad, false);
    end;

    local procedure SendWaiterPadToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad"; ShowNothingToSendErr: Boolean)
    var
        PrintTemplate: Record "NPR NPRE Print Templ.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        //ShowNothingToSendErr = true is how the POS "Send Kitchen Order" action sends a waiter pad
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        RestaurantPrint.PrintWaiterPadLinesToKitchen(WaiterPad, WaiterPadLine, PrintTemplate."Print Type"::"Kitchen Order", '', false, ShowNothingToSendErr);
    end;

    local procedure GetKitchenRequestNo(WaiterPadNo: Code[20]; WaiterPadLineNo: Integer): BigInteger
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
    begin
        KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
        KitchenReqSourceLink.SetRange("Source Document No.", WaiterPadNo);
        KitchenReqSourceLink.SetRange("Source Document Line No.", WaiterPadLineNo);
        _Assert.AreEqual(1, KitchenReqSourceLink.Count(), 'The waiter pad line should have exactly one kitchen request.');
        KitchenReqSourceLink.FindFirst();
        exit(KitchenReqSourceLink."Request No.");
    end;

    local procedure GetOnlyModifierItemNo(RequestNo: BigInteger): Code[20]
    var
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
    begin
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        if KitchenRequestModifier.IsEmpty() then
            exit('');
        _Assert.AreEqual(1, KitchenRequestModifier.Count(), 'The kitchen request should have exactly one modifier line.');
        KitchenRequestModifier.FindFirst();
        exit(KitchenRequestModifier."No.");
    end;

    local procedure CreateDishWithBothAddOns(var WaiterPad: Record "NPR NPRE Waiter Pad"; var MainItem: Record Item; var AddOnKItem: Record Item; var AddOnMItem: Record Item; var MainLine: Record "NPR NPRE Waiter Pad Line"; var AddOnKLine: Record "NPR NPRE Waiter Pad Line"; var AddOnMLine: Record "NPR NPRE Waiter Pad Line")
    begin
        CreateDishItem(MainItem);
        CreateDishItem(AddOnKItem);
        CreateAddOnItem(AddOnMItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnKItem."No.", 1, MainLine."Line No.", AddOnKLine);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", AddOnMItem."No.", 1, MainLine."Line No.", AddOnMLine);
    end;

    local procedure CreatePadWithCommentedDish(var WaiterPad: Record "NPR NPRE Waiter Pad"; var MainLine: Record "NPR NPRE Waiter Pad Line"; var CommentLine: Record "NPR NPRE Waiter Pad Line")
    var
        MainItem: Record Item;
    begin
        CreateDishItem(MainItem);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, WaiterPad);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainLine);
        _LibraryRestaurant.AddWaiterPadAttachedComment(WaiterPad."No.", 'No onions', MainLine, CommentLine);
    end;

    local procedure SendAndAcceptRequest(WaiterPad: Record "NPR NPRE Waiter Pad"; WaiterPadLine: Record "NPR NPRE Waiter Pad Line") RequestNo: BigInteger
    begin
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", WaiterPadLine."Line No.");
        AcceptRequest(RequestNo);
    end;

    local procedure AcceptRequest(RequestNo: BigInteger)
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        _Assert.RecordIsNotEmpty(KitchenRequestStation);
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", false);
    end;

    local procedure StationsFlagged(RequestNo: BigInteger): Text
    var
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
    begin
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        if KitchenRequestStation.IsEmpty() then
            exit(NotFlaggedTok);
        KitchenRequestStation.SetRange("Qty. Change Not Accepted", false);
        if KitchenRequestStation.IsEmpty() then
            exit(FlaggedTok);
        exit(NotFlaggedTok);
    end;

    local procedure ModifierRows(RequestNo: BigInteger) Rows: Text
    var
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
    begin
        KitchenRequestModifier.SetRange("Request No.", RequestNo);
        if KitchenRequestModifier.FindSet() then
            repeat
                if Rows <> '' then
                    Rows += '; ';
                Rows += ModifierRow(
                    KitchenRequestModifier.Description, KitchenRequestModifier."Line Type", KitchenRequestModifier.Indentation,
                    KitchenRequestModifier."No.", KitchenRequestModifier.Quantity);
            until KitchenRequestModifier.Next() = 0;
    end;

    local procedure ModifierRow(Description: Text; LineType: Enum "NPR POS Sale Line Type"; Indentation: Integer; No: Text; Quantity: Decimal): Text
    begin
        exit(StrSubstNo(ModifierRowTxt, Description, LineType, Indentation, No, Quantity));
    end;

    local procedure RecallPad(WaiterPad: Record "NPR NPRE Waiter Pad"; var POSSession: Codeunit "NPR POS Session"; var SalePOS: Record "NPR POS Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
        POSSale.GetCurrentSale(SalePOS);
    end;

    local procedure RecalledComment(SalePOS: Record "NPR POS Sale"; CommentText: Text): Text
    var
        CommentSaleLinePOS: Record "NPR POS Sale Line";
        ParentSaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        AttachedTo: Text;
    begin
        CommentSaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        CommentSaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        CommentSaleLinePOS.SetRange(Description, CommentText);
        if not CommentSaleLinePOS.FindFirst() then
            exit(NotInTheSaleTok);

        AttachedTo := NotAttachedTok;
        SaleLinePOSAddOn.SetRange("Register No.", CommentSaleLinePOS."Register No.");
        SaleLinePOSAddOn.SetRange("Sales Ticket No.", CommentSaleLinePOS."Sales Ticket No.");
        SaleLinePOSAddOn.SetRange("Sale Date", CommentSaleLinePOS.Date);
        SaleLinePOSAddOn.SetRange("Sale Line No.", CommentSaleLinePOS."Line No.");
        SaleLinePOSAddOn.SetFilter("Applies-to Line No.", '<>%1', 0);
        if SaleLinePOSAddOn.FindFirst() then
            if ParentSaleLinePOS.Get(
                CommentSaleLinePOS."Register No.", CommentSaleLinePOS."Sales Ticket No.", CommentSaleLinePOS.Date,
                CommentSaleLinePOS."Sale Type", SaleLinePOSAddOn."Applies-to Line No.")
            then
                AttachedTo := ParentSaleLinePOS."No.";
        exit(StrSubstNo(RecalledCommentTxt, CommentSaleLinePOS."No.", AttachedTo));
    end;

    local procedure SaveSaleToPad(var SalePOS: Record "NPR POS Sale"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        SalePOS.Find();
        WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);
    end;

    local procedure CheckRow(RowId: Text; Expected: Text; Actual: Text; var Mismatches: Text)
    begin
        if Expected <> Actual then
            Mismatches += StrSubstNo(RowMismatchTxt, RowId, Expected, Actual);
    end;
}
#endif

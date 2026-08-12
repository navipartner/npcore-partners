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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", OriginalAddOnItem."No.", 1, MainWaiterPadLine."Line No.", OriginalAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        _Assert.AreEqual(
            OriginalAddOnItem."No.", GetOnlyModifierItemNo(RequestNo),
            'The kitchen request should have been created with the add-on line that was on the waiter pad.');

        // [WHEN] The add-on line is replaced with a different one and the waiter pad is sent again
        OriginalAddOnLine.Delete(true);
        AddWaiterPadLine(WaiterPad."No.", NewAddOnItem."No.", 1, MainWaiterPadLine."Line No.", NewAddOnLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", OriginalAddOnItem."No.", 1, MainWaiterPadLine."Line No.", OriginalAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        _Assert.RecordIsNotEmpty(KitchenRequestStation);
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", false);

        // [WHEN] The add-on line is replaced with a different one and the waiter pad is sent again
        OriginalAddOnLine.Delete(true);
        AddWaiterPadLine(WaiterPad."No.", NewAddOnItem."No.", 1, MainWaiterPadLine."Line No.", NewAddOnLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, MergeToWaiterPad);
        AddWaiterPadLine(MergeToWaiterPad."No.", OtherItem."No.", 1, 0, OtherWaiterPadLine);

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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad, false);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        KitchenRequestStation.SetRange("Request No.", RequestNo);
        _Assert.RecordIsNotEmpty(KitchenRequestStation);
        KitchenRequestStation.ModifyAll("Qty. Change Not Accepted", false);

        _LibraryRestaurant.CreateWaiterPadForSeating(_Seating.Code, MergeToWaiterPad);
        AddWaiterPadLine(MergeToWaiterPad."No.", OtherItem."No.", 1, 0, OtherWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");
        AddWaiterPadLine(WaiterPad."No.", LateAddOnItem."No.", 1, MainWaiterPadLine."Line No.", LateAddOnWaiterPadLine);

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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 2, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 2, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 2, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", SubAddOnItem."No.", 1, AddOnWaiterPadLine."Line No.", SubAddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", FirstAddOnItem."No.", 1, MainWaiterPadLine."Line No.", FirstAddOnLine);
        AddWaiterPadLine(WaiterPad."No.", SecondAddOnItem."No.", 1, MainWaiterPadLine."Line No.", SecondAddOnLine);
        SendWaiterPadToKitchen(WaiterPad);
        RequestNo := GetKitchenRequestNo(WaiterPad."No.", MainWaiterPadLine."Line No.");

        // [WHEN] The second add-on line is replaced and the waiter pad is sent again
        SecondAddOnLine.Delete(true);
        AddWaiterPadLine(WaiterPad."No.", NewAddOnItem."No.", 1, MainWaiterPadLine."Line No.", NewAddOnLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadLine(WaiterPad."No.", AddOnItem."No.", 1, MainWaiterPadLine."Line No.", AddOnWaiterPadLine);
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
        AddWaiterPadLine(WaiterPad."No.", MainItem."No.", 1, 0, MainWaiterPadLine);
        AddWaiterPadCommentLine(WaiterPad."No.", NoOnionsTok, MainWaiterPadLine."Line No.", CommentWaiterPadLine);

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

    local procedure AddWaiterPadLine(WaiterPadNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; AttachedToLineNo: Integer; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    var
        Item: Record Item;
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        Item.Get(ItemNo);

        WaiterPadLine.Init();
        WaiterPadLine."Waiter Pad No." := WaiterPadNo;
        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::Item;
        WaiterPadLine."No." := ItemNo;
        WaiterPadLine.Description := Item.Description;
        WaiterPadLine."Attached to Line No." := AttachedToLineNo;
        if AttachedToLineNo <> 0 then
            WaiterPadLine.Indentation := 1;
        WaiterPadLine.Insert(true);

        if Item."Sales Unit of Measure" <> '' then
            WaiterPadLine.Validate("Unit of Measure Code", Item."Sales Unit of Measure")
        else
            WaiterPadLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
        WaiterPadLine.Validate(Quantity, Quantity);
        WaiterPadLine.Modify(true);

        WaiterPadMgt.AssignWPadLinePrintCategories(WaiterPadLine, true);
    end;

    local procedure AddWaiterPadCommentLine(WaiterPadNo: Code[20]; CommentText: Text; AttachedToLineNo: Integer; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        WaiterPadLine.Init();
        WaiterPadLine."Waiter Pad No." := WaiterPadNo;
        WaiterPadLine."Line Type" := WaiterPadLine."Line Type"::Comment;
        WaiterPadLine.Description := CopyStr(CommentText, 1, MaxStrLen(WaiterPadLine.Description));
        WaiterPadLine."Attached to Line No." := AttachedToLineNo;
        WaiterPadLine.Indentation := 1;
        WaiterPadLine.Insert(true);
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
}
#endif

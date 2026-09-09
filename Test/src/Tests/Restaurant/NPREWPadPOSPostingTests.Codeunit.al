codeunit 85406 "NPR NPRE W/Pad Posting Tests"
{
    // [FEATURE] Waiter pad against a finished POS sale: billed quantity, closing on finish, cancelling and parking
    Subtype = Test;

    var
        _POSPaymentMethod: Record "NPR POS Payment Method";
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

    #region Posting a sale recalled from a waiter pad

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RecalledPadPosted_LineBilledAndEntryLinked()
    var
        Item: Record Item;
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        // [SCENARIO] Paying the bill records how much of the pad has been settled and ties it to the posted entry
        // [GIVEN] A pad with one line of quantity 2, recalled into a sale
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual);
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 2, WaiterPadLine);
        RecallPadIntoNewSale(WaiterPad, POSSession);

        // [WHEN] The sale is paid and posted
        PayAndPost(POSSession);

        // [THEN] The pad line is billed in full and linked to the posted entry sales line
        WaiterPadLine.Find();
        _Assert.AreEqual(2, WaiterPadLine."Billed Quantity", 'Posting should bill the pad line for the quantity that was sold.');
        POSEntryWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        POSEntryWaiterPadLink.SetRange("Waiter Pad Line No.", WaiterPadLine."Line No.");
        _Assert.IsFalse(POSEntryWaiterPadLink.IsEmpty(), 'Posting should link the POS entry sales line to the pad line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RecalledPadPostedInOtherUnitOfMeasure_BaseQuantityBilled()
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        // [SCENARIO] Paying for a bill written in bottles, but rung up in glasses, settles the right number of glasses
        // [GIVEN] A pad line of one bottle in a six-to-one unit of measure, recalled and then rung up as six glasses
        //         The sale line has to be switched to the base unit after the recall. Recall copies the pad line's unit
        //         onto the sale line, and the POS entry line copies it again, so without this both sides carry the same
        //         Qty. per Unit of Measure and the equal-units branch of UpdateBilledQtyOnPOSSalePost runs. Both branches
        //         happen to compute 6 on that fixture, so the differing-units arm could be deleted and this stay green.
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual);
        CreateItem(Item);
        _LibraryRestaurant.CreateItemUnitOfMeasure(Item, ItemUnitOfMeasure, 6);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        WaiterPadLine.Validate("Unit of Measure Code", ItemUnitOfMeasure.Code);
        WaiterPadLine.Validate(Quantity, 1);
        WaiterPadLine.Modify(true);
        RecallPadIntoNewSale(WaiterPad, POSSession);
        SellRecalledLineInBaseUnit(POSSession, Item, 6);

        // [WHEN] The sale is paid and posted
        PayAndPost(POSSession);

        // [THEN] The pad line is settled in base quantity, not in raw units
        WaiterPadLine.Find();
        _Assert.AreEqual(6, WaiterPadLine."Billed Qty. (Base)", 'Posting should settle the pad line in base quantity when the units of measure differ.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RecalledPadPostedUnderPaymentProfile_PadClosed()
    var
        Item: Record Item;
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        // [SCENARIO] Settling the bill frees the table without anyone closing it by hand
        // [GIVEN] A profile that closes on payment and a pad recalled into a sale
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment);
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        RecallPadIntoNewSale(WaiterPad, POSSession);

        // [WHEN] The sale is paid and posted
        PayAndPost(POSSession);

        // [THEN] The pad closed and recorded that a finished sale did it
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'Posting a fully settled pad should close it under a Payment profile.');
        _Assert.AreEqual(WaiterPad."Close Reason"::"Finished Sale", WaiterPad."Close Reason", 'The pad should record that it closed because the sale finished.');
    end;

    #endregion

    #region Cancelling a sale

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleCancelled_ItsUnsentPadLinesRemoved()
    var
        Item: Record Item;
        OtherSaleLine: Record "NPR NPRE Waiter Pad Line";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] Abandoning a sale takes back what it put on the bill, and leaves what another register put there
        // [GIVEN] A pad holding one line from the sale being cancelled and one that belongs to a different sale
        //         The second line is what makes the per-sale scoping observable. With only the cancelled sale's own
        //         line on the pad, dropping the "Sale Retail ID" filter from CleanupWaiterPadOnSaleCancel changes
        //         nothing - the loop just walks the same single line.
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual);
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        RecallPadIntoNewSale(WaiterPad, POSSession);
        GetCurrentSale(POSSession, SalePOS);
        AddPadLine(WaiterPad, Item."No.", 1, OtherSaleLine);
        ClaimPadLineForAnotherSale(OtherSaleLine);

        // [WHEN] The sale is cancelled
        WaiterPadPOSMgt.CleanupWaiterPadOnSaleCancel(SalePOS, WaiterPad);

        // [THEN] Its own line is off the pad, and the other register's line is untouched
        _Assert.IsFalse(WaiterPadLine.Find(), 'Cancelling the sale should take its own unsent line back off the pad.');
        _Assert.IsTrue(OtherSaleLine.Find(), 'Cancelling one sale should leave a line another sale put on the pad.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleCancelledOnEmptyPad_PadClosed()
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] Abandoning a sale on a bill with nothing on it closes the bill rather than leaving the table busy
        // [GIVEN] A pad with no lines at all
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual);
        CreatePad(WaiterPad);
        StartEmptySale(POSSession, SalePOS);

        // [WHEN] A sale against it is cancelled
        WaiterPadPOSMgt.CleanupWaiterPadOnSaleCancel(SalePOS, WaiterPad);

        // [THEN] The pad is closed and records the cancellation as the reason
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'Cancelling a sale on an empty pad should close the pad.');
        _Assert.AreEqual(WaiterPad."Close Reason"::"Cancelled Sale", WaiterPad."Close Reason", 'The pad should record that a cancelled sale closed it.');
    end;

    #endregion

    #region Parking a sale recalled from a waiter pad

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadLinkedSaleParked_LinksSurvive()
    var
        Item: Record Item;
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        // [SCENARIO] A waiter parks a table's bill to serve someone else, and the bill stays attached to the table
        // [GIVEN] A pad recalled into a sale
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual);
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        RecallPadIntoNewSale(WaiterPad, POSSession);

        // [WHEN] The sale is parked
        ParkSale(POSSavedSaleEntry);

        // [THEN] The pad line still points at the now parked sale
        WaiterPadLine.Find();
        _Assert.AreEqual(POSSavedSaleEntry.SystemId, WaiterPadLine."Sale Retail ID", 'The pad line should still reference the sale after it is parked.');
        _Assert.IsTrue(WaiterPadPOSMgt.IsParkedSale(WaiterPadLine."Sale Retail ID"), 'The sale the pad line points at should be recognised as parked.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ParkedSaleDeleted_PadLinesReleased()
    var
        Item: Record Item;
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        // [SCENARIO] Throwing away a parked bill hands the lines back to the table rather than stranding them
        // [GIVEN] A pad recalled into a sale which is then parked
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual);
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        RecallPadIntoNewSale(WaiterPad, POSSession);
        ParkSale(POSSavedSaleEntry);

        // [WHEN] The parked sale entry is deleted
        POSSavedSaleEntry.Delete(true);

        // [THEN] The pad line is free to be recalled again
        WaiterPadLine.Find();
        _Assert.IsTrue(IsNullGuid(WaiterPadLine."Sale Retail ID"), 'Deleting the parked sale should release the pad line.');
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        _LibraryPOSMock.InitializeData(_POSInitialized, _POSUnit, _POSStore, _POSPaymentMethod);
        if not _RestaurantInitialized then begin
            _LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
            _LibraryRestaurant.CreateMealFlowStatuses();
            _LibraryRestaurant.CreateSeatingFlowStatuses();
            _LibraryRestaurant.CreateWaiterPadFlowStatuses();
            _LibraryRestaurant.CreateServiceFlowProfile(_ServFlowProfile);
            _LibraryRestaurant.CreateRestaurant(_Restaurant, _ServFlowProfile.Code);
            _LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);
            _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);

            _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
            _POSUnit.Modify();

            // No kitchen station is routed here: these scenarios are about the money, not the kitchen.
            _RestaurantInitialized := true;
        end;
        Commit();
    end;

    local procedure ConfigureProfile(CloseWaiterPadOn: Enum "NPR NPRE Serv.Flow Close W/Pad")
    begin
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, CloseWaiterPadOn, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        Commit();
    end;

    local procedure CreateItem(var Item: Record Item)
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
    end;

    local procedure CreatePad(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Seating: Record "NPR NPRE Seating";
    begin
        // A seating per test as hygiene. Nothing in this suite asserts on seating status or links - the close decisions
        // here come from the pad's own lines and the service flow profile - but a shared seating would couple these
        // fixtures to each other for no benefit.
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
    end;

    local procedure AddPadLine(WaiterPad: Record "NPR NPRE Waiter Pad"; ItemNo: Code[20]; Quantity: Decimal; var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", ItemNo, Quantity, 0, WaiterPadLine);
    end;

    local procedure StartEmptySale(var POSSession: Codeunit "NPR POS Session"; var SalePOS: Record "NPR POS Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, _POSUnit, POSSale);
        POSSale.GetCurrentSale(SalePOS);
    end;

    local procedure GetCurrentSale(POSSession: Codeunit "NPR POS Session"; var SalePOS: Record "NPR POS Sale")
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
    end;

    local procedure SellRecalledLineInBaseUnit(POSSession: Codeunit "NPR POS Session"; Item: Record Item; Quantity: Decimal)
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        GetCurrentSale(POSSession, SalePOS);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Line Type", SaleLinePOS."Line Type"::Item);
        SaleLinePOS.SetRange("No.", Item."No.");
        SaleLinePOS.FindFirst();
        SaleLinePOS.Validate("Unit of Measure Code", Item."Base Unit of Measure");
        SaleLinePOS.Validate(Quantity, Quantity);
        SaleLinePOS.Modify(true);
    end;

    local procedure ClaimPadLineForAnotherSale(var WaiterPadLine: Record "NPR NPRE Waiter Pad Line")
    begin
        // Stands in for a line another register saved onto the same pad: MoveSaleFromPOSToWaiterPad stamps its own sale
        // id on the lines it writes, which is what the cancel path filters on.
        WaiterPadLine."Sale Retail ID" := CreateGuid();
        WaiterPadLine.Modify();
    end;

    local procedure RecallPadIntoNewSale(WaiterPad: Record "NPR NPRE Waiter Pad"; var POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        StartEmptySale(POSSession, SalePOS);
        WaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(WaiterPad, POSSession);
    end;

    local procedure PayAndPost(POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
    begin
        GetCurrentSale(POSSession, SalePOS);
        SalePOS.CalcFields("Amount Including VAT");
        // Asserted rather than discarded: a false return means the sale never ended, so POSPost is never reached and
        // nothing is posted at all. Every downstream assertion would then fail pointing at the waiter pad billing code
        // rather than at the sale that did not end.
        _Assert.IsTrue(
            _LibraryPOSMock.PayAndTryEndSaleAndStartNew(POSSession, _POSPaymentMethod.Code, SalePOS."Amount Including VAT", '', true),
            'The sale should have been paid and ended before anything is asserted about posting.');
    end;

    local procedure ParkSale(var POSSavedSaleEntry: Record "NPR POS Saved Sale Entry")
    var
        POSActionSavePOSSvSlB: Codeunit "NPR POS Action: SavePOSSvSl B";
    begin
        POSActionSavePOSSvSlB.SaveSale(POSSavedSaleEntry);
    end;

    #endregion
}

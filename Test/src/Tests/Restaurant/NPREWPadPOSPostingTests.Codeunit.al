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

    #region Posting without an initialized POS session

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OfflineSaleWithoutPOSSession_CreatesEntryAndLines()
    var
        Item: Record Item;
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        // [SCENARIO] An offline sale can be recorded without opening a POS session.
        // [GIVEN] A paid sale with no waiter-pad links and no initialized POS session.
        Initialize();
        // Keep the shared restaurant unit intact for the other tests in this codeunit.
        CreateUnitWithoutRestaurantProfile(POSUnit);
        POSStore.Get(POSUnit."POS Store Code");
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        _LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 2);
        PreparePaymentForEntryCreation(POSSession, SalePOS);
        WaiterPadLine.SetRange("Sale Retail ID", SalePOS.SystemId);
        _Assert.IsTrue(WaiterPadLine.IsEmpty(), 'The offline sale must have no linked waiter-pad lines.');
        POSSession.ClearAll();
        SetUserPOSUnit('');
        _Assert.IsFalse(POSSession.IsInitialized(), 'Posting must start without an initialized POS session.');

        // [WHEN] The importer creates the POS entry directly.
        // Before the fix this raises the missing-session error in the waiter-pad subscriber.
        POSCreateEntry.Run(SalePOS);
        _Assert.IsFalse(POSSession.IsInitialized(), 'Posting must not initialize a POS session.');
        UserSetup.Get(UserId());
        _Assert.AreEqual('', UserSetup."NPR POS Unit No.", 'Posting must not assign a POS unit to the user.');

        // [THEN] The entry, item quantity and payment are recorded successfully.
        _Assert.IsTrue(POSEntry.GetBySystemId(SalePOS.SystemId), 'The offline sale must create a POS entry.');
        _Assert.AreEqual(SalePOS."Register No.", POSEntry."POS Unit No.", 'The entry must use the imported sale register.');
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("No.", Item."No.");
        _Assert.AreEqual(1, POSEntrySalesLine.Count(), 'The entry must contain the imported item once.');
        POSEntrySalesLine.FindFirst();
        _Assert.AreEqual(2, POSEntrySalesLine.Quantity, 'The imported quantity must be preserved.');
        POSEntryPaymentLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryPaymentLine.SetRange("POS Payment Method Code", _POSPaymentMethod.Code);
        _Assert.AreEqual(1, POSEntryPaymentLine.Count(), 'The entry must contain the imported payment once.');
        POSEntryPaymentLine.FindFirst();
        _Assert.AreEqual(SalePOS."Amount Including VAT", POSEntryPaymentLine.Amount, 'The full payment must be preserved.');
        POSEntryWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        _Assert.IsTrue(POSEntryWaiterPadLink.IsEmpty(), 'An offline sale without a waiter pad must not create waiter-pad links.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LinkedPadWithoutPOSSession_CreatesEntryAndBillsLine()
    var
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        // [SCENARIO] Posting without a POS session still bills linked waiter-pad lines.
        // [GIVEN] An unbilled pad line recalled into a paid sale, then the POS session is cleared.
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual);
        CreateItem(Item);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, Item."No.", 2, WaiterPadLine);
        RecallPadIntoNewSale(WaiterPad, POSSession);
        PreparePaymentForEntryCreation(POSSession, SalePOS);
        WaiterPadLine.Find();
        _Assert.AreEqual(SalePOS.SystemId, WaiterPadLine."Sale Retail ID", 'The waiter-pad line must belong to the sale being posted.');
        _Assert.AreEqual(0, WaiterPadLine."Billed Quantity", 'The waiter-pad line must not already be billed.');
        POSSession.ClearAll();
        _Assert.IsFalse(POSSession.IsInitialized(), 'Posting must start without an initialized POS session.');

        // [WHEN] The POS entry is created directly, expecting successful posting rather than an error.
        POSCreateEntry.Run(SalePOS);
        _Assert.IsFalse(POSSession.IsInitialized(), 'Billing linked pad lines must not initialize a POS session.');

        // [THEN] The pad line is billed and linked to the actual entry sales line.
        _Assert.IsTrue(POSEntry.GetBySystemId(SalePOS.SystemId), 'The linked sale must create a POS entry.');
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange("No.", Item."No.");
        _Assert.AreEqual(1, POSEntrySalesLine.Count(), 'The entry must contain the recalled item once.');
        POSEntrySalesLine.FindFirst();
        _Assert.AreEqual(2, POSEntrySalesLine.Quantity, 'The recalled quantity must be preserved.');
        WaiterPadLine.Find();
        _Assert.AreEqual(2, WaiterPadLine."Billed Quantity", 'Posting must bill the linked line even without a POS session.');
        POSEntryWaiterPadLink.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntryWaiterPadLink.SetRange("POS Entry Sales Line No.", POSEntrySalesLine."Line No.");
        POSEntryWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        POSEntryWaiterPadLink.SetRange("Waiter Pad Line No.", WaiterPadLine."Line No.");
        _Assert.AreEqual(1, POSEntryWaiterPadLink.Count(), 'The billed line must link to the created entry sales line.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleUnitDiffersFromUserUnit_PreSetPadClosed()
    begin
        // [SCENARIO] Posting without a session uses the restaurant profile of the sale's own POS unit, not the user's unit.
        VerifyPreSetPadPostingWithDifferentUserUnit(false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SaleUnitUsesStoreRestaurantProfile_PreSetPadClosed()
    begin
        VerifyPreSetPadPostingWithDifferentUserUnit(true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DifferentUnitsPostedInOneSession_ProfilesNotReused()
    var
        OtherPOSUnit: Record "NPR POS Unit";
        SaleA: Record "NPR POS Sale";
        SaleB: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        POSSession: Codeunit "NPR POS Session";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        // [SCENARIO] Sales from different POS units posted in one session each use their own unit's restaurant profile.
        // [GIVEN] Two prepared sales: A has no restaurant profile, B has a pre-set empty pad.
        Initialize();
        _POSUnit.Find();
        _POSUnit.TestField("POS Restaurant Profile");
        CreateUnitWithoutRestaurantProfile(OtherPOSUnit);
        PreparePaidSaleForUnit(OtherPOSUnit, SaleA);
        PreparePaidSaleWithPreSetPad(_POSUnit, SaleB, WaiterPad);
        POSSession.ClearAll();
        SetUserPOSUnit(OtherPOSUnit."No.");

        // [WHEN] Both entries are created in the same session, without resetting it between calls.
        POSCreateEntry.Run(SaleA);
        POSCreateEntry.Run(SaleB);

        // [THEN] Both entries exist and B's own profile allows the pre-set pad to close.
        _Assert.IsTrue(POSEntry.GetBySystemId(SaleA.SystemId), 'The first sale must create an entry.');
        _Assert.IsTrue(POSEntry.GetBySystemId(SaleB.SystemId), 'The second sale must create an entry.');
        AssertPreSetPadClosed(WaiterPad);
        _Assert.IsFalse(POSSession.IsInitialized(), 'Batch posting must not leave a POS session initialized.');
    end;

    #endregion

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
        //         Qty. per Unit of Measure and the equal-units billing branch runs. Both branches
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RecalledPadWithRemovedDish_Paid_NoZeroLinePostedAndLinksReleased()
    var
        Item: Record Item;
        RemovedItem: Record Item;
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryWaiterPadLink: Record "NPR POS Entry Waiter Pad Link";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RemovedLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        // [SCENARIO] Paying a table posts what was paid, without a 0 line for a dish removed from the table
        // [GIVEN] A pad with a removed dish at 0 and a dish to pay, recalled into a sale
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual);
        CreateItem(Item);
        CreateItem(RemovedItem);
        CreatePad(WaiterPad);
        AddPadLine(WaiterPad, RemovedItem."No.", 0, RemovedLine);
        AddPadLine(WaiterPad, Item."No.", 1, WaiterPadLine);
        RecallPadIntoNewSale(WaiterPad, POSSession);

        // [WHEN] The sale is paid and posted
        PayAndPost(POSSession);

        // [THEN] The dish to pay is billed, and the posted entry has no line for the removed dish
        WaiterPadLine.Find();
        _Assert.AreEqual(1, WaiterPadLine."Billed Quantity", 'The dish that was paid should be billed.');
        POSEntryWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        POSEntryWaiterPadLink.SetRange("Waiter Pad Line No.", WaiterPadLine."Line No.");
        _Assert.IsTrue(POSEntryWaiterPadLink.FindFirst(), 'The paid dish should be linked to the posted entry.');
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntryWaiterPadLink."POS Entry No.");
        POSEntrySalesLine.SetRange("No.", RemovedItem."No.");
        _Assert.IsTrue(POSEntrySalesLine.IsEmpty(), 'The posted entry should not carry a 0 line for the removed dish.');

        // [THEN] The removed dish has no link to the posted entry and is released when the sale ends
        POSEntryWaiterPadLink.SetRange("Waiter Pad Line No.", RemovedLine."Line No.");
        _Assert.IsTrue(POSEntryWaiterPadLink.IsEmpty(), 'The removed dish should not be linked to the posted entry.');
        RemovedLine.Find();
        _Assert.AreEqual(0, RemovedLine."Billed Quantity", 'The removed dish should not be billed.');
        _Assert.IsTrue(IsNullGuid(RemovedLine."Sale Retail ID"), 'The removed dish should be released when the sale ends.');
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

    local procedure SetUserPOSUnit(POSUnitNo: Code[10])
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId());
        UserSetup."NPR POS Unit No." := POSUnitNo;
        UserSetup.Modify();
    end;

    local procedure CreateUnitWithoutRestaurantProfile(var POSUnit: Record "NPR POS Unit")
    var
        POSStore: Record "NPR POS Store";
    begin
        _LibraryPOSMasterData.CreatePOSStore(POSStore, _POSStore."POS Posting Profile");
        _LibraryPOSMasterData.CreatePOSUnit(POSUnit, POSStore.Code, POSStore."POS Posting Profile");
        POSUnit."POS Audit Profile" := _POSUnit."POS Audit Profile";
        POSUnit.Modify();
        POSUnit.TestField("POS Restaurant Profile", '');
        POSStore.TestField("POS Restaurant Profile", '');
    end;

    local procedure PreparePaidSaleForUnit(POSUnit: Record "NPR POS Unit"; var SalePOS: Record "NPR POS Sale")
    var
        Item: Record Item;
        POSStore: Record "NPR POS Store";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSStore.Get(POSUnit."POS Store Code");
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(POSSession, POSUnit, POSSale);
        _LibraryPOSMock.CreateItemLine(POSSession, Item."No.", 1);
        PreparePaymentForEntryCreation(POSSession, SalePOS);
    end;

    local procedure PreparePaidSaleWithPreSetPad(POSUnit: Record "NPR POS Unit"; var SalePOS: Record "NPR POS Sale"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        PreparePaidSaleForUnit(POSUnit, SalePOS);
        CreatePad(WaiterPad);
        _Assert.IsFalse(WaiterPad.Closed, 'The pre-set pad must start open.');
        SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
        SalePOS.Modify();
        WaiterPadLine.SetRange("Sale Retail ID", SalePOS.SystemId);
        _Assert.IsTrue(WaiterPadLine.IsEmpty(), 'No linked lines may bypass the restaurant-profile check.');
    end;

    local procedure VerifyPreSetPadPostingWithDifferentUserUnit(UseStoreProfile: Boolean)
    var
        OtherPOSUnit: Record "NPR POS Unit";
        POSUnit: Record "NPR POS Unit";
        POSStore: Record "NPR POS Store";
        SalePOS: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        UserSetup: Record "User Setup";
        POSSession: Codeunit "NPR POS Session";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        // [GIVEN] The user's unit has no profile; the sale's unit or store does.
        Initialize();
        _POSUnit.Find();
        _POSUnit.TestField("POS Restaurant Profile");
        CreateUnitWithoutRestaurantProfile(OtherPOSUnit);
        // Use a separate unit and store so the fallback scenario cannot change the shared fixture.
        CreateUnitWithoutRestaurantProfile(POSUnit);
        if UseStoreProfile then begin
            POSStore.Get(POSUnit."POS Store Code");
            POSStore."POS Restaurant Profile" := _POSUnit."POS Restaurant Profile";
            POSStore.Modify();
            POSStore.TestField("POS Restaurant Profile");
            POSUnit.TestField("POS Restaurant Profile", '');
        end else begin
            POSUnit."POS Restaurant Profile" := _POSUnit."POS Restaurant Profile";
            POSUnit.Modify();
            POSUnit.TestField("POS Restaurant Profile");
        end;
        PreparePaidSaleWithPreSetPad(POSUnit, SalePOS, WaiterPad);
        POSSession.ClearAll();
        SetUserPOSUnit(OtherPOSUnit."No.");

        // [WHEN] Posting without a POS session.
        POSCreateEntry.Run(SalePOS);

        // [THEN] The sale's profile is used without changing the user's setup or session.
        _Assert.IsTrue(POSEntry.GetBySystemId(SalePOS.SystemId), 'The sale must create an entry.');
        AssertPreSetPadClosed(WaiterPad);
        _Assert.IsFalse(POSSession.IsInitialized(), 'Posting must not initialize a POS session.');
        UserSetup.Get(UserId());
        _Assert.AreEqual(OtherPOSUnit."No.", UserSetup."NPR POS Unit No.", 'Posting must preserve the user''s assigned POS unit.');
    end;

    local procedure AssertPreSetPadClosed(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'The sale''s restaurant profile must allow its empty pre-set pad to close.');
        _Assert.AreEqual(WaiterPad."Close Reason"::"Finished Sale", WaiterPad."Close Reason", 'The pad must close because the sale finished.');
    end;

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

    local procedure PreparePaymentForEntryCreation(POSSession: Codeunit "NPR POS Session"; var SalePOS: Record "NPR POS Sale")
    var
        PaymentSaleLine: Record "NPR POS Sale Line";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        GetCurrentSale(POSSession, SalePOS);
        SalePOS.CalcFields("Amount Including VAT");
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(PaymentSaleLine);
        PaymentSaleLine."No." := _POSPaymentMethod.Code;
        PaymentSaleLine."Amount Including VAT" := SalePOS."Amount Including VAT";
        PaymentSaleLine.Amount := SalePOS."Amount Including VAT";
        _Assert.IsTrue(POSPaymentLine.InsertPaymentLine(PaymentSaleLine, 0), 'The fixture payment must be inserted before clearing the POS session.');
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

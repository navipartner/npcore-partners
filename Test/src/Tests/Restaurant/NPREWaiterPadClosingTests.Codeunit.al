codeunit 85385 "NPR NPRE W/Pad Closing Tests"
{
    // [FEATURE] Waiter pad closing rules of the service flow profile

    Subtype = Test;

    var
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _Assert: Codeunit "Assert";
        _LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        _LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        _LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_CloseOnPayment_ClosesThePadAndReleasesTheSeating()
    var
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Paying a table in full closes its waiter pad and frees the table for the next guests

        // [GIVEN] A restaurant that closes waiter pads on payment, and a table with a fully billed order
        ArrangeBilledWaiterPad("NPR NPRE Serv.Flow Close W/Pad"::Payment, false, 3, 3, Seating, WaiterPad);

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter pad is closed as a finished sale
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsTrue(WaiterPad.Closed, 'The waiter pad must be closed when the service flow closes it on payment.');
        _Assert.AreEqual("NPR NPRE W/Pad Closing Reason"::"Finished Sale", WaiterPad."Close Reason", 'The waiter pad close reason is incorrect.');

        // [THEN] The seating is released together with the waiter pad
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsTrue(SeatingWaiterPadLink.Closed, 'The seating must be released when its waiter pad closes.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_CloseOnAnyPayment_PartialBill_StillClosesThePad()
    var
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] When full payment is not demanded, the first payment against a waiter pad closes it

        // [GIVEN] A restaurant that closes on payment without demanding full payment, and 1 of 3 ordered units on the bill
        ArrangeBilledWaiterPad("NPR NPRE Serv.Flow Close W/Pad"::Payment, false, 3, 1, Seating, WaiterPad);

        // [WHEN] The partial bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter pad is closed even though units remain unbilled
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsTrue(WaiterPad.Closed, 'A partly paid waiter pad must close when full payment is not required.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_CloseOnFullPaymentOnly_PartialBill_LeavesThePadOpen()
    var
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] When full payment is demanded, a partial bill leaves the table open for the rest of the order

        // [GIVEN] A restaurant that only closes on full payment, and 1 of 3 ordered units on the bill
        ArrangeBilledWaiterPad("NPR NPRE Serv.Flow Close W/Pad"::Payment, true, 3, 1, Seating, WaiterPad);

        // [WHEN] The partial bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter pad stays open and the seating stays occupied
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'A partly paid waiter pad must stay open when full payment is required.');
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsFalse(SeatingWaiterPadLink.Closed, 'The seating must stay occupied while its waiter pad is open.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_CloseOnFullPaymentOnly_FinalBill_ClosesThePad()
    var
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] When full payment is demanded, the waiter pad closes on the bill that settles the last unit

        // [GIVEN] A restaurant that only closes on full payment, with the whole order on the bill
        ArrangeBilledWaiterPad("NPR NPRE Serv.Flow Close W/Pad"::Payment, true, 3, 3, Seating, WaiterPad);

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter pad is closed
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsTrue(WaiterPad.Closed, 'A fully paid waiter pad must close when full payment is required.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_ClosingSetToManual_LeavesThePadOpenAfterFullPayment()
    var
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // [SCENARIO] A restaurant that closes waiter pads by hand keeps the table open even after it has been paid

        // [GIVEN] A restaurant with manual waiter pad closing, and a fully billed order
        ArrangeBilledWaiterPad("NPR NPRE Serv.Flow Close W/Pad"::Manual, false, 3, 3, Seating, WaiterPad);

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The order is billed, but the waiter pad and its seating stay open for a waiter to close by hand
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        WaiterPadLine.SetRange("Line Type", WaiterPadLine."Line Type"::Item);
        WaiterPadLine.FindFirst();
        _Assert.AreEqual(3, WaiterPadLine."Billed Quantity", 'The waiter-pad line must still be billed when closing is manual.');
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'A waiter pad must not close on payment when closing is manual.');
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsFalse(SeatingWaiterPadLink.Closed, 'The seating must stay occupied while its waiter pad is open.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_CloseOnPreReceipt_WithoutAPreReceipt_LeavesThePadOpen()
    var
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A restaurant that closes waiter pads on the pre-receipt does not close them on payment alone

        // [GIVEN] A restaurant that closes on pre-receipt, and a fully billed order with no pre-receipt printed
        ArrangeBilledWaiterPad("NPR NPRE Serv.Flow Close W/Pad"::"Pre-Receipt", false, 3, 3, Seating, WaiterPad);
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad."Pre-receipt Printed", 'Test prerequisite: no pre-receipt may have been printed.');

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter pad stays open because the pre-receipt was never printed
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'A waiter pad must not close on payment when it closes on the pre-receipt.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_CloseOnPreReceipt_AfterThePreReceipt_ClosesThePad()
    var
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] Once the guests have had their pre-receipt, paying the bill closes the waiter pad

        // [GIVEN] A restaurant that closes on pre-receipt, a fully billed order, and a printed pre-receipt
        ArrangeBilledWaiterPad("NPR NPRE Serv.Flow Close W/Pad"::"Pre-Receipt", false, 3, 3, Seating, WaiterPad);
        _LibraryRestaurant.MarkWaiterPadPreReceiptPrinted(WaiterPad);

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The waiter pad is closed and its seating released
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsTrue(WaiterPad.Closed, 'A waiter pad with a printed pre-receipt must close.');
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsTrue(SeatingWaiterPadLink.Closed, 'The seating must be released when its waiter pad closes.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure EndSale_ClearSeatingOnPreReceipt_FreesTheTableWhileThePadStaysOpen()
    var
        POSEntry: Record "NPR POS Entry";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        WaiterPad: Record "NPR NPRE Waiter Pad";
    begin
        // [SCENARIO] A restaurant can hand the table to the next guests as soon as the pre-receipt is out, while the waiter pad itself is closed by hand later

        // [GIVEN] Manual pad closing, seating cleared on the pre-receipt, and a printed pre-receipt
        ArrangeBilledWaiterPad("NPR NPRE Serv.Flow Close W/Pad"::Manual, false, 3, 3, Seating, WaiterPad);
        _LibraryRestaurant.GetPOSUnitServiceFlowProfile(_POSUnit, ServiceFlowProfile);
        _LibraryRestaurant.SetServiceFlowSeatingClearing(ServiceFlowProfile.Code, ServiceFlowProfile."Clear Seating On"::"Pre-Receipt");
        _LibraryRestaurant.MarkWaiterPadPreReceiptPrinted(WaiterPad);

        // [WHEN] The bill is paid
        EndCurrentSale(POSEntry);

        // [THEN] The table is free again even though the waiter pad is still open
        SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.");
        _Assert.IsTrue(SeatingWaiterPadLink.Closed, 'The seating must be released on the pre-receipt.');
        WaiterPad.Get(WaiterPad."No.");
        _Assert.IsFalse(WaiterPad.Closed, 'The waiter pad must stay open when closing is manual.');
    end;

    local procedure ArrangeBilledWaiterPad(CloseWaiterPadOn: Enum "NPR NPRE Serv.Flow Close W/Pad"; OnlyIfFullyPaid: Boolean; OrderedQuantity: Decimal; BilledQuantity: Decimal; var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        Item: Record Item;
        SaleLine: Record "NPR POS Sale Line";
        ServiceFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _LibraryPOSMock.InitializeData(_Initialized, _POSUnit, _POSStore, _POSPaymentMethod);
        _LibraryRestaurant.SetupTableServiceRestaurant(_POSUnit, Seating, ServiceFlowProfile);
        _LibraryRestaurant.SetAutoSaveToWaiterPadOnSaleEnd(ServiceFlowProfile.Code, true);
        _LibraryRestaurant.SetServiceFlowWaiterPadClosing(ServiceFlowProfile.Code, CloseWaiterPadOn, OnlyIfFullyPaid);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);

        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        Item."Unit Price" := 10;
        Item.Modify();
        _LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", OrderedQuantity);

        SaveAndStartNewSale(WaiterPad);
        _LibraryRestaurant.LoadWaiterPadIntoCurrentPOSSale(_POSSession, WaiterPad);

        if BilledQuantity = OrderedQuantity then
            exit;

        FindCurrentItemSaleLine(Item."No.", SaleLine);
        SaleLine.Validate(Quantity, BilledQuantity);
        SaleLine.Modify(true);
    end;

    local procedure SaveAndStartNewSale(var WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _Assert.IsTrue(
          _LibraryRestaurant.SaveCurrentPOSSaleToWaiterPad(_POSSession, WaiterPad, true),
          'The POS sale was not cleared after being saved to the waiter pad.');
        SalePOS.Find();
        SalePOS.Delete(true);

        _POSSession.ClearAll();
        Clear(_POSSession);
        _LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, POSSale);
    end;

    local procedure FindCurrentItemSaleLine(ItemNo: Code[20]; var SaleLine: Record "NPR POS Sale Line")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SaleLine.Reset();
        SaleLine.SetRange("Register No.", SalePOS."Register No.");
        SaleLine.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLine.SetRange("Line Type", SaleLine."Line Type"::Item);
        SaleLine.SetRange("No.", ItemNo);
        SaleLine.FindFirst();
    end;

    local procedure EndCurrentSale(var POSEntry: Record "NPR POS Entry")
    var
        SalePOS: Record "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSale: Codeunit "NPR POS Sale";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SalesAmount: Decimal;
        SubTotal: Decimal;
    begin
        _POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        _POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        _Assert.IsTrue(
          _LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, SalesAmount, ''),
          'The restaurant sale did not end.');
        POSEntry.GetBySystemId(SalePOS.SystemId);
    end;
}

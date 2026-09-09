codeunit 85403 "NPR NPRE W/Pad Serv.Flow Tests"
{
    // [FEATURE] Restaurant service flow profile: when a waiter pad closes, when its seatings clear, when it becomes ready for payment
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

    #region Closing a waiter pad

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ManualProfile_CloseAttempted_PadStaysOpen()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A profile that never closes automatically leaves the pad open
        // [GIVEN] Close Waiter Pad On = Manual and a pad with one unbilled line
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithPlainLine(Seating, WaiterPad, 1, 0);

        // [WHEN] A close is attempted without forcing
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is still open and no close reason was recorded
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'A Manual profile should never close the waiter pad on its own.');
        _Assert.AreEqual(WaiterPad."Close Reason"::Undefined, WaiterPad."Close Reason", 'A pad that did not close should carry no close reason.');
        // The ready-for-payment column needs an off case somewhere, and this test already lands in the else branch of
        // TryCloseWaiterPad with Set W/Pad Ready for Pmt. On = Manual. Without it, making WaiterPadIsReadyForPayment
        // return true unconditionally stamps every non-closing pad as awaiting payment and no test notices.
        _Assert.AreEqual('', WaiterPad.Status, 'A Manual ready-for-payment rule should not flag the pad as awaiting payment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreReceiptProfile_PreReceiptNotPrinted_PadStaysOpen()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] The pad waits for the pre-receipt before it may close
        // [GIVEN] Close Waiter Pad On = Pre-Receipt and a pad whose pre-receipt has not been printed
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::"Pre-Receipt", "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithPlainLine(Seating, WaiterPad, 1, 0);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is still open
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'The pad should stay open until the pre-receipt has been printed.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreReceiptProfile_PreReceiptPrinted_PadCloses()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Printing the pre-receipt lets the pad close
        // [GIVEN] Close Waiter Pad On = Pre-Receipt and a pad whose pre-receipt has been printed
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::"Pre-Receipt", "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithPlainLine(Seating, WaiterPad, 1, 0);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted with the reason Finished Sale
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is closed, carries that reason and is stamped with a close date and time
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'A printed pre-receipt should allow the pad to close.');
        _Assert.AreEqual(WaiterPad."Close Reason"::"Finished Sale", WaiterPad."Close Reason", 'The pad should record the close reason it was closed with.');
        _Assert.AreNotEqual(0D, WaiterPad."Close Date", 'A closed pad should be stamped with a close date.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentProfile_PartlyBilledAndPartialAllowed_PadCloses()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Any payment closes the pad when full payment is not required
        // [GIVEN] Close Waiter Pad On = Payment, Only if Fully Paid = false, and a pad with one of two lines partly billed
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithPlainLine(Seating, WaiterPad, 2, 1);
        AddPlainLine(WaiterPad, 2, 0);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is closed
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'A partly billed pad should close when full payment is not required.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentProfile_PartlyBilledAndFullPaymentRequired_PadStaysOpen()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A partly paid pad stays open when the profile demands full payment
        // [GIVEN] Close Waiter Pad On = Payment, Only if Fully Paid = true, and a line billed for less than its quantity
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithPlainLine(Seating, WaiterPad, 2, 1);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is still open
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'A pad with an unpaid remainder should stay open when full payment is required.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentProfile_FullyBilledAndFullPaymentRequired_PadCloses()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A fully paid pad closes when the profile demands full payment
        // [GIVEN] Close Waiter Pad On = Payment, Only if Fully Paid = true, and every line billed in full
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithPlainLine(Seating, WaiterPad, 2, 2);
        AddPlainLine(WaiterPad, 3, 3);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is closed
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'A fully billed pad should close when full payment is required.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentIfServedProfile_KitchenStillWorking_PadStaysOpen()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A fully paid pad waits for the kitchen when the profile also requires serving
        // [GIVEN] Close Waiter Pad On = Payment if Served, KDS active, a fully billed pad whose kitchen request is not served
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::"Payment if Served", "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithRoutedLine(Seating, WaiterPad, 1, 1);
        SendPadToKitchen(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is still open
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'A pad with unserved kitchen requests should stay open under a Payment if Served profile.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentIfServedProfile_EverythingServed_PadCloses()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A fully paid pad closes once the kitchen has served everything
        // [GIVEN] Close Waiter Pad On = Payment if Served, KDS active, a fully billed pad whose kitchen requests are all served
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::"Payment if Served", "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        //         The line is billed after serving on purpose. Serving runs AttemptToCloseSourceDocument, which calls
        //         TryCloseWaiterPad itself - so on a pad that is already fully billed the close happens during the
        //         GIVEN and the WHEN below re-stamps an already closed pad instead of being the act under test.
        CreatePadWithRoutedLine(Seating, WaiterPad, 1, 0);
        SendPadToKitchen(WaiterPad);
        ServeEverythingOnPad(WaiterPad);
        BillWholePad(WaiterPad);
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'The pad should still be open when the close is attempted.');

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is closed
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'A fully billed pad whose kitchen requests are all served should close.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreReceiptIfServedProfile_KDSInactive_PadCloses()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Without a KDS there is nothing to wait for, so the served condition is satisfied
        // [GIVEN] Close Waiter Pad On = Pre-Receipt if Served, KDS switched off, pre-receipt printed, and a line the
        //         kitchen has been asked for but has not served
        //         The line has to be routed and sent. An unrouted line resolves no kitchen station, so the served
        //         check would return true whatever the KDS flag said and this test would pass with KDS on as well.
        //         PreReceiptIfServedProfile_KitchenStillWorking_PadStaysOpen below is the KDS-on contrast on this same
        //         profile value - PaymentIfServed is a different case arm and cannot fail for a mutation in this one.
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::"Pre-Receipt if Served", "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithRoutedLine(Seating, WaiterPad, 1, 0);
        SendPadToKitchen(WaiterPad);
        SetKDSActive(false);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is closed - the served check short-circuits when no KDS is active
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'With no KDS active the served condition should be treated as satisfied.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PreReceiptIfServedProfile_KitchenStillWorking_PadStaysOpen()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A printed pre-receipt is not enough while the kitchen still owes the guest food
        //
        // The served half of this profile value. Without it the whole arm collapses to "pre-receipt printed" - deleting
        // the served requirement, or replacing the arm with exit(true), survives the suite, and a restaurant on this
        // profile frees tables while the kitchen is still cooking.
        // [GIVEN] Close Waiter Pad On = Pre-Receipt if Served, KDS active, pre-receipt printed, one unserved request
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::"Pre-Receipt if Served", "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithRoutedLine(Seating, WaiterPad, 1, 0);
        SendPadToKitchen(WaiterPad);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad stays open
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'A printed pre-receipt should not close the pad while a kitchen request is unserved.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ZeroQuantityLinesOnly_CloseAttempted_PadCloses()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A pad with nothing outstanding closes whatever the profile says
        // [GIVEN] Close Waiter Pad On = Payment, nothing billed, and a pad whose only line has zero quantity
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithPlainLine(Seating, WaiterPad, 0, 0);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is closed even though nothing was paid
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'A pad carrying no outstanding quantity should close regardless of the profile.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ManualProfile_ForceClose_PadCloses()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Forcing a close overrides the profile
        // [GIVEN] Close Waiter Pad On = Manual and an unbilled pad
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithPlainLine(Seating, WaiterPad, 1, 0);

        // [WHEN] The pad is force closed
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, true, "NPR NPRE W/Pad Closing Reason"::"Manually Closed");

        // [THEN] The pad is closed with the reason it was forced with
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'Forcing a close should override the profile.');
        _Assert.AreEqual(WaiterPad."Close Reason"::"Manually Closed", WaiterPad."Close Reason", 'A forced close should record the reason it was given.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosedPad_CloseAttemptedAgain_NothingChanges()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        CloseDate: Date;
        CloseTime: Time;
    begin
        // [SCENARIO] Closing an already closed pad is a no-op rather than a restamp
        // [GIVEN] A pad already closed with the reason Finished Sale
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadWithPlainLine(Seating, WaiterPad, 1, 0);
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, true, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");
        WaiterPad.Find();
        CloseDate := WaiterPad."Close Date";
        CloseTime := WaiterPad."Close Time";

        // [WHEN] A close is attempted again with a different reason
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, true, "NPR NPRE W/Pad Closing Reason"::"Cancelled Sale");

        // [THEN] The original reason and close date are untouched
        WaiterPad.Find();
        _Assert.AreEqual(WaiterPad."Close Reason"::"Finished Sale", WaiterPad."Close Reason", 'Closing an already closed pad should not overwrite its close reason.');
        _Assert.AreEqual(CloseDate, WaiterPad."Close Date", 'Closing an already closed pad should not restamp its close date.');
        // Close Time is the field that actually moves on a re-stamp: Close Date is WorkDate(), which is constant for the
        // session, so the date assertion above holds even with the already-closed guard removed.
        _Assert.AreEqual(CloseTime, WaiterPad."Close Time", 'Closing an already closed pad should not restamp its close time.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CommentLinesOnly_CloseAttempted_CommentLinesRemoved()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Comment lines left behind on an otherwise empty pad are cleaned up on close
        // [GIVEN] A pad whose only lines are comments
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        CreatePadOnNewSeating(Seating, WaiterPad);
        _LibraryRestaurant.AddWaiterPadCommentLine(WaiterPad."No.", 'Allergy: nuts', 0, WaiterPadLine);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The orphan comment lines are gone and the pad is closed
        WaiterPadLine.Reset();
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        _Assert.IsTrue(WaiterPadLine.IsEmpty(), 'Comment lines left on an otherwise empty pad should be removed when it closes.');
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'A pad holding only comment lines should close.');
    end;

    #endregion

    #region Clearing seatings and ready for payment

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClearOnWaiterPadClose_PadCloses_SeatingCleared()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Closing the pad frees its table
        //            This covers the closing path, not the setting: once a pad closes, CloseWaiterPadSeatings runs
        //            unconditionally and Clear Seating On is never read. The setting itself is pinned by
        //            ClearOnWaiterPadClose_PadCannotClose_SeatingStaysOccupied below.
        // [GIVEN] Clear Seating On = Waiter Pad Close and a fully billed pad that satisfies its close rule
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithPlainLine(Seating, WaiterPad, 2, 2);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad closed, its seating link is closed and the table is back to its cleared status
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'The pad should have closed.');
        _Assert.IsTrue(SeatingLinkIsClosed(WaiterPad."No.", Seating.Code), 'Closing the pad should close its seating link.');
        Seating.Find();
        _Assert.AreEqual(_LibraryRestaurant.SeatingStatusReady(), Seating.Status, 'A cleared seating should take the status configured on the profile.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClearOnWaiterPadClose_PadCannotClose_SeatingStaysOccupied()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A table tied to Waiter Pad Close is not freed while the pad is still open
        //            This is where the setting is actually read: with the pad still open the close path is skipped and
        //            WaiterPadSeatingsCanBeClosed decides, which for Waiter Pad Close returns the pad's own Closed flag.
        //            Contrast ClearOnPreReceipt_PadCannotClose_SeatingClearedAnyway, which clears on the same fixture.
        // [GIVEN] Clear Seating On = Waiter Pad Close and an unpaid pad that cannot satisfy its close rule
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithPlainLine(Seating, WaiterPad, 2, 0);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad stayed open and its table is still taken
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'An unpaid pad should not close under the Payment rule.');
        _Assert.IsFalse(
            SeatingLinkIsClosed(WaiterPad."No.", Seating.Code),
            'With Clear Seating On = Waiter Pad Close, an open pad should keep its table.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClearOnPreReceipt_PadCannotClose_SeatingClearedAnyway()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] The table is freed at pre-receipt time even though the bill is still open
        // [GIVEN] Close Waiter Pad On = Payment with nothing paid, Clear Seating On = Pre-Receipt, pre-receipt printed
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Pre-Receipt", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithPlainLine(Seating, WaiterPad, 2, 0);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is still open but its seating has been cleared
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'An unpaid pad should stay open under this profile.');
        _Assert.IsTrue(SeatingLinkIsClosed(WaiterPad."No.", Seating.Code), 'A printed pre-receipt should clear the seating even while the pad stays open.');
        Seating.Find();
        _Assert.AreEqual(_LibraryRestaurant.SeatingStatusReady(), Seating.Status, 'The cleared seating should take the configured status.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClearOnPreReceipt_PreReceiptNotPrinted_SeatingStaysOccupied()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A table tied to the pre-receipt is not freed before one has been printed
        //
        // The negative direction of this rule. Its sibling above has the pre-receipt printed, so mutating this arm to
        // always clear survives it - the two together are what pin the setting rather than the act of closing.
        // [GIVEN] Clear Seating On = Pre-Receipt on an unpaid pad whose pre-receipt has not been printed
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Pre-Receipt", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithPlainLine(Seating, WaiterPad, 2, 0);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad stayed open and its table is still taken
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'An unpaid pad should not close under the Payment rule.');
        _Assert.IsFalse(
            SeatingLinkIsClosed(WaiterPad."No.", Seating.Code),
            'Without a printed pre-receipt the seating should stay taken.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReadyForPaymentOnPreReceiptIfServed_KitchenStillWorking_PadStatusUnchanged()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A pad is not flagged ready for payment while the kitchen still owes the guest food
        //
        // The only coverage of the Pre-Receipt if Served value of this column: without it that arm of
        // WaiterPadIsReadyForPayment can be deleted outright and no test notices.
        // [GIVEN] Set W/Pad Ready for Pmt. On = Pre-Receipt if Served, pre-receipt printed, one unserved request
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::"Pre-Receipt if Served", false);
        CreatePadWithRoutedLine(Seating, WaiterPad, 1, 0);
        SendPadToKitchen(WaiterPad);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is not flagged as awaiting payment
        WaiterPad.Find();
        _Assert.AreEqual(
            '', WaiterPad.Status, 'An unserved pad should not be flagged ready for payment under a served rule.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReadyForPaymentOnPreReceiptIfServed_EverythingServed_PadStatusSet()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Once the kitchen is done, the pad is flagged so the till knows it is ready to be paid
        // [GIVEN] The same profile with every kitchen request served
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::"Pre-Receipt if Served", false);
        CreatePadWithRoutedLine(Seating, WaiterPad, 1, 0);
        SendPadToKitchen(WaiterPad);
        ServeEverythingOnPad(WaiterPad);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad carries the ready for payment status
        WaiterPad.Find();
        _Assert.AreEqual(
            _LibraryRestaurant.WaiterPadStatusReadyForPmt(), WaiterPad.Status,
            'A served pad with a printed pre-receipt should be flagged ready for payment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClearOnPreReceiptIfServed_KitchenStillWorking_SeatingStaysOccupied()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] The table is not freed while the kitchen still owes the guest food
        // [GIVEN] Clear Seating On = Pre-Receipt if Served, KDS active, pre-receipt printed, one unserved kitchen request
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Pre-Receipt if Served", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithRoutedLine(Seating, WaiterPad, 1, 0);
        SendPadToKitchen(WaiterPad);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The seating link is still open, and the table still reads as occupied
        _Assert.IsFalse(SeatingLinkIsClosed(WaiterPad."No.", Seating.Code), 'The seating should stay occupied while a kitchen request is unserved.');
        Seating.Find();
        _Assert.AreNotEqual(
            _LibraryRestaurant.SeatingStatusReady(), Seating.Status,
            'A seating whose kitchen work is unfinished should not be handed back as ready.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClearOnPreReceiptIfServed_EverythingServed_SeatingCleared()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] The table is freed once the kitchen has served everything, even though the bill is unpaid
        //
        // The positive direction of this rule. Without it, mutating the Pre-Receipt if Served arm of
        // WaiterPadSeatingsCanBeClosed to always refuse survives the whole suite - tables never freeing up, which is
        // the symptom this coverage exists to catch.
        // [GIVEN] Clear Seating On = Pre-Receipt if Served, pre-receipt printed, and every kitchen request served
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Pre-Receipt if Served", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithRoutedLine(Seating, WaiterPad, 1, 0);
        SendPadToKitchen(WaiterPad);
        ServeEverythingOnPad(WaiterPad);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad stayed open on its unpaid line, but the table was handed back
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'An unpaid pad should not close under the Payment rule.');
        _Assert.IsTrue(
            SeatingLinkIsClosed(WaiterPad."No.", Seating.Code),
            'With everything served and the pre-receipt printed, the seating link should close even though the pad stays open.');
        Seating.Find();
        _Assert.AreEqual(
            _LibraryRestaurant.SeatingStatusReady(), Seating.Status, 'A cleared seating should take the status configured on the profile.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SeatingSharedByASecondOpenPad_OnePadCloses_SeatingNotCleared()
    var
        Seating: Record "NPR NPRE Seating";
        FirstWaiterPad: Record "NPR NPRE Waiter Pad";
        SecondWaiterPad: Record "NPR NPRE Waiter Pad";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A table with another open bill on it is not freed
        // [GIVEN] One seating carrying two open waiter pads, the first fully billed
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithPlainLine(Seating, FirstWaiterPad, 2, 2);
        WaiterPadMgt.AddNewWaiterPadForSeating(Seating.Code, SecondWaiterPad, SeatingWaiterPadLink);

        // [WHEN] The first pad closes
        WaiterPadMgt.TryCloseWaiterPad(FirstWaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] Its own link closed, but the seating is still occupied by the second pad
        _Assert.IsTrue(SeatingLinkIsClosed(FirstWaiterPad."No.", Seating.Code), 'The closing pad should close its own seating link.');
        Seating.Find();
        _Assert.AreNotEqual(_LibraryRestaurant.SeatingStatusReady(), Seating.Status, 'A seating still carrying an open waiter pad should not be cleared.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReadyForPaymentOnPreReceipt_PreReceiptPrinted_PadStatusSet()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] A pad that cannot close yet is flagged as awaiting payment
        // [GIVEN] Close Waiter Pad On = Manual, Set W/Pad Ready for Pmt. On = Pre-Receipt, pre-receipt printed
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::"Pre-Receipt", false);
        CreatePadWithPlainLine(Seating, WaiterPad, 1, 0);
        SetPreReceiptPrinted(WaiterPad);

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad is still open and now carries the ready for payment status
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'A Manual profile should not close the pad.');
        _Assert.AreEqual(_LibraryRestaurant.WaiterPadStatusReadyForPmt(), WaiterPad.Status, 'The pad should be flagged with the ready for payment status.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ReadyForPaymentStatusBlank_PreReceiptPrinted_PadStatusUnchanged()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        StatusBefore: Code[10];
    begin
        // [SCENARIO] Leaving the ready for payment status blank turns the flagging off
        // [GIVEN] Set W/Pad Ready for Pmt. On = Pre-Receipt but no status code configured, on a pad already carrying
        //         a status
        //         The pad has to start with a non-blank status. A new pad's Status is '', and with the guard removed
        //         the code would reach SetWaiterPadStatus(pad, '') and return early on '' = '' without writing - so a
        //         blank-to-blank fixture passes whether the guard is there or not.
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Manual, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::"Pre-Receipt", false);
        _ServFlowProfile."W/Pad Ready for Pmt. Status" := '';
        _ServFlowProfile.Modify();
        CreatePadWithPlainLine(Seating, WaiterPad, 1, 0);
        if WaiterPadMgt.SetWaiterPadStatus(WaiterPad, _LibraryRestaurant.WaiterPadStatusReadyForPmt()) then
            WaiterPad.Modify();
        SetPreReceiptPrinted(WaiterPad);
        WaiterPad.Find();
        StatusBefore := WaiterPad.Status;
        _Assert.AreNotEqual('', StatusBefore, 'The fixture should start from a pad that carries a status.');

        // [WHEN] A close is attempted
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");

        // [THEN] The pad status is untouched
        WaiterPad.Find();
        _Assert.AreEqual(StatusBefore, WaiterPad.Status, 'With no ready for payment status configured the pad status should not change.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ClosedPad_Reopened_PadAndSeatingRestored()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Reopening a pad puts the table back into service
        // [GIVEN] A closed pad whose seating link was closed with it
        Initialize();
        ConfigureProfile("NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close", "NPR NPRE W/Pad Status Pmt. On"::Manual, true);
        CreatePadWithPlainLine(Seating, WaiterPad, 2, 2);
        WaiterPadMgt.TryCloseWaiterPad(WaiterPad, false, "NPR NPRE W/Pad Closing Reason"::"Finished Sale");
        WaiterPad.Find();
        _Assert.IsTrue(WaiterPad.Closed, 'The pad should be closed before the reopen is exercised.');

        // [WHEN] The pad is reopened
        WaiterPadMgt.ReopenWaiterPad(WaiterPad);

        // [THEN] The pad is open again, unstamped, and the seating is occupied
        WaiterPad.Find();
        _Assert.IsFalse(WaiterPad.Closed, 'The reopened pad should no longer be closed.');
        _Assert.AreEqual(0D, WaiterPad."Close Date", 'Reopening should clear the close date.');
        _Assert.AreEqual(WaiterPad."Close Reason"::Undefined, WaiterPad."Close Reason", 'Reopening should clear the close reason.');
        _Assert.IsFalse(SeatingLinkIsClosed(WaiterPad."No.", Seating.Code), 'Reopening should reopen the seating link.');
        Seating.Find();
        _Assert.AreEqual(_LibraryRestaurant.SeatingStatusOccupied(), Seating.Status, 'A reoccupied seating should carry the occupied status.');
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        KitchenStation: Record "NPR NPRE Kitchen Station";
        KitchenStationSelection: Record "NPR NPRE Kitchen Station Slct.";
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
            _LibraryRestaurant.CreateSeatingLocation(_SeatingLocation, _Restaurant.Code);
            _LibraryRestaurant.CreateKitchenStation(KitchenStation, _Restaurant.Code);

            // Route the main course step so the served-condition scenarios have a kitchen request to wait on.
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
        end;

        // Each test states its own matrix cell, and KDS is left on unless a test switches it off.
        SetKDSActive(true);

        // ReadyForPaymentStatusBlank_PreReceiptPrinted_PadStatusUnchanged blanks this on the shared profile and cannot
        // restore it itself, so it is restored here. Every test in the codeunit today calls ConfigureProfile, which
        // overwrites it anyway - this is for any future test that does not, which would otherwise inherit a blank
        // status without saying so.
        _ServFlowProfile.Find();
        _ServFlowProfile."W/Pad Ready for Pmt. Status" := _LibraryRestaurant.WaiterPadStatusReadyForPmt();
        _ServFlowProfile.Modify();
        Commit();
    end;

    local procedure ConfigureProfile(CloseWaiterPadOn: Enum "NPR NPRE Serv.Flow Close W/Pad"; ClearSeatingOn: Enum "NPR NPRE Serv.Flow Clear Seat."; SetReadyForPmtOn: Enum "NPR NPRE W/Pad Status Pmt. On"; OnlyIfFullyPaid: Boolean)
    begin
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(_ServFlowProfile, CloseWaiterPadOn, ClearSeatingOn, SetReadyForPmtOn, OnlyIfFullyPaid);
    end;

    local procedure SetKDSActive(Active: Boolean)
    begin
        _Restaurant.Find();
        _LibraryRestaurant.SetRestaurantKDSActive(_Restaurant, Active);
    end;

    local procedure CreatePadOnNewSeating(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        // A seating per test keeps the seating status and link assertions independent of the tests before them.
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
    end;

    local procedure CreatePadWithPlainLine(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad"; Quantity: Decimal; BilledQuantity: Decimal)
    begin
        CreatePadOnNewSeating(Seating, WaiterPad);
        AddPlainLine(WaiterPad, Quantity, BilledQuantity);
    end;

    local procedure AddPlainLine(WaiterPad: Record "NPR NPRE Waiter Pad"; Quantity: Decimal; BilledQuantity: Decimal)
    var
        Item: Record Item;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        // No routing profile, so this line never reaches a kitchen station and the served condition ignores it.
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, 0, WaiterPadLine);
        if BilledQuantity <> 0 then
            _LibraryRestaurant.SetWaiterPadLineBilledQuantity(WaiterPadLine, BilledQuantity);
    end;

    local procedure CreatePadWithRoutedLine(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad"; Quantity: Decimal; BilledQuantity: Decimal)
    var
        Item: Record Item;
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        CreatePadOnNewSeating(Seating, WaiterPad);
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        _LibraryRestaurant.AssignFlowStatusToRoutingProfile(ItemRoutingProfile, MainCourseStepTok);
        _LibraryRestaurant.LinkItemToRoutingProfile(Item, ItemRoutingProfile.Code);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, 0, WaiterPadLine);
        if BilledQuantity <> 0 then
            _LibraryRestaurant.SetWaiterPadLineBilledQuantity(WaiterPadLine, BilledQuantity);
    end;

    local procedure SendPadToKitchen(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        PrintTemplate: Record "NPR NPRE Print Templ.";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        RestaurantPrint.PrintWaiterPadLinesToKitchen(WaiterPad, WaiterPadLine, PrintTemplate."Print Type"::"Kitchen Order", '', false, false);
    end;

    local procedure BillWholePad(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        WaiterPadLine.SetRange("Waiter Pad No.", WaiterPad."No.");
        if WaiterPadLine.FindSet() then
            repeat
                _LibraryRestaurant.SetWaiterPadLineBilledQuantity(WaiterPadLine, WaiterPadLine.Quantity);
            until WaiterPadLine.Next() = 0;
    end;

    local procedure ServeEverythingOnPad(WaiterPad: Record "NPR NPRE Waiter Pad")
    var
        KitchenReqSourceLink: Record "NPR NPRE Kitchen Req.Src. Link";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        HandledOrders: List of [BigInteger];
    begin
        KitchenReqSourceLink.SetRange("Source Document Type", KitchenReqSourceLink."Source Document Type"::"Waiter Pad");
        KitchenReqSourceLink.SetRange("Source Document No.", WaiterPad."No.");
        _Assert.IsFalse(KitchenReqSourceLink.IsEmpty(), 'The pad should have reached the kitchen before its requests can be served.');
        KitchenReqSourceLink.FindSet();
        repeat
            KitchenRequest.Get(KitchenReqSourceLink."Request No.");
            if not HandledOrders.Contains(KitchenRequest."Order ID") then begin
                HandledOrders.Add(KitchenRequest."Order ID");
                _LibraryRestaurant.FinishKitchenOrder(KitchenRequest."Order ID");
            end;
        until KitchenReqSourceLink.Next() = 0;
    end;

    local procedure SetPreReceiptPrinted(var WaiterPad: Record "NPR NPRE Waiter Pad")
    begin
        WaiterPad.Find();
        WaiterPad."Pre-receipt Printed" := true;
        WaiterPad.Modify();
    end;

    local procedure SeatingLinkIsClosed(WaiterPadNo: Code[20]; SeatingCode: Code[20]): Boolean
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
    begin
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPadNo);
        SeatingWaiterPadLink.SetRange("Seating Code", SeatingCode);
        _Assert.IsTrue(SeatingWaiterPadLink.FindFirst(), 'The waiter pad should be linked to the seating it was created on.');
        exit(SeatingWaiterPadLink.Closed);
    end;

    #endregion
}

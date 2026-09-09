codeunit 85404 "NPR NPRE W/Pad Lifecycle Tests"
{
    // [FEATURE] Waiter pad lifecycle: creation, seating links, party size, merge and header duplication
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NewPadForSeating_Created_SeatingOccupied()
    var
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Seating a party marks the table as taken
        // [GIVEN] A free seating
        Initialize();
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);

        // [WHEN] A waiter pad is opened on it
        WaiterPadMgt.AddNewWaiterPadForSeating(Seating.Code, WaiterPad, SeatingWaiterPadLink);

        // [THEN] The pad exists, is linked to the seating by an open link, and the seating is occupied
        _Assert.AreNotEqual('', WaiterPad."No.", 'Opening a pad should assign it a number from the no. series.');
        _Assert.IsFalse(SeatingWaiterPadLink.Closed, 'A newly created seating link should be open.');
        _Assert.IsTrue(SeatingWaiterPadLink.Primary, 'The first seating on a pad should be its primary seating.');
        Seating.Find();
        _Assert.AreEqual(_LibraryRestaurant.SeatingStatusOccupied(), Seating.Status, 'Opening a pad on a seating should mark it occupied.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NewPadWithCustomerDetails_Created_DetailsOnHeader()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        CustomerDetails: Dictionary of [Text, Text];
        CustomerEmailTok: Label 'guest@example.com', Locked = true;
        CustomerNameTok: Label 'Table for Ada', Locked = true;
        CustomerPhoneTok: Label '+4512345678', Locked = true;
        WaiterCodeTok: Label 'WAITER1', Locked = true;
    begin
        // [SCENARIO] Customer details captured on the new pad dialog land on the header
        // [GIVEN] A seating and a set of customer details keyed by waiter pad field name
        Initialize();
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        CustomerDetails.Add(WaiterPad.FieldName(Description), CustomerNameTok);
        CustomerDetails.Add(WaiterPad.FieldName("Customer Phone No."), CustomerPhoneTok);
        CustomerDetails.Add(WaiterPad.FieldName("Customer E-Mail"), CustomerEmailTok);

        // [WHEN] A pad is created for four guests with those details
        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, 4, WaiterCodeTok, CustomerDetails, WaiterPad);

        // [THEN] Party size, waiter and all three customer details are stored on the pad
        WaiterPad.Find();
        _Assert.AreEqual(4, WaiterPad."Number of Guests", 'The pad should carry the requested party size.');
        _Assert.AreEqual(WaiterCodeTok, WaiterPad."Assigned Waiter Code", 'The pad should carry the assigned waiter.');
        _Assert.AreEqual(CustomerNameTok, WaiterPad.Description, 'The pad should carry the customer name.');
        _Assert.AreEqual(CustomerPhoneTok, WaiterPad."Customer Phone No.", 'The pad should carry the customer phone number.');
        _Assert.AreEqual(CustomerEmailTok, WaiterPad."Customer E-Mail", 'The pad should carry the customer e-mail.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DefaultGuestCount_ConfiguredOnRestaurant_ResolvedThroughHierarchy()
    var
        Seating: Record "NPR NPRE Seating";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
        DefaultNumberOfGuests: Integer;
    begin
        // [SCENARIO] The default party size is inherited from the restaurant when the seating location does not override it
        // [GIVEN] Default Number of Guests = Min Party Size on the restaurant, and a seating with a minimum party size of 3
        Initialize();
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        // Max Party Size has to clear Capacity before Min Party Size can be raised to meet it.
        Seating.Validate("Max Party Size", Seating.Capacity);
        Seating.Validate("Min Party Size", 3);
        Seating.Modify(true);
        _Restaurant.Find();
        _Restaurant."Default Number of Guests" := _Restaurant."Default Number of Guests"::"Min Party Size";
        _Restaurant.Modify();

        // [WHEN] The default number of guests is resolved for that seating
        DefaultNumberOfGuests := WaiterPadPOSMgt.GetDefaultNumberOfGuests(Seating.Code);

        // [THEN] The restaurant level setting wins over the built-in fallback of one guest
        _Assert.AreEqual(3, DefaultNumberOfGuests, 'The seating location should inherit the restaurant''s default guest count rule.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SameSeatingLinkedTwice_SecondAttempt_SingleLinkKept()
    var
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        Linked: Boolean;
    begin
        // [SCENARIO] Linking a pad to a seating it already occupies does not duplicate the link
        // [GIVEN] A pad already linked to a seating
        Initialize();
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);

        // [WHEN] The same seating is linked again
        Linked := WaiterPadMgt.LinkSeatingToWaiterPad(WaiterPad, Seating.Code, SeatingWaiterPadLink);

        // [THEN] The call reports no new link and exactly one link exists
        _Assert.IsFalse(Linked, 'Linking a seating that is already linked should report that nothing was added.');
        SeatingWaiterPadLink.Reset();
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        _Assert.AreEqual(1, SeatingWaiterPadLink.Count(), 'A pad should hold only one link per seating.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadMovedToAnotherSeating_SeatingChanged_BothTablesUpdated()
    var
        FromSeating: Record "NPR NPRE Seating";
        ToSeating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Moving a party to another table frees the old one and takes the new one
        // [GIVEN] A pad seated at table A, and a free table B
        Initialize();
        _LibraryRestaurant.CreateSeating(FromSeating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateSeating(ToSeating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(FromSeating.Code, WaiterPad);

        // [WHEN] The pad is moved from A to B
        WaiterPadMgt.ChangeSeating(WaiterPad, FromSeating.Code, ToSeating.Code);

        // [THEN] Only table B holds a link, A is cleared and B is occupied
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", WaiterPad."No.");
        SeatingWaiterPadLink.SetRange("Seating Code", FromSeating.Code);
        _Assert.IsTrue(SeatingWaiterPadLink.IsEmpty(), 'The link to the old seating should be removed.');
        SeatingWaiterPadLink.SetRange("Seating Code", ToSeating.Code);
        _Assert.AreEqual(1, SeatingWaiterPadLink.Count(), 'The pad should be linked to the new seating.');
        FromSeating.Find();
        _Assert.AreEqual(_LibraryRestaurant.SeatingStatusReady(), FromSeating.Status, 'The vacated seating should be cleared.');
        ToSeating.Find();
        _Assert.AreEqual(_LibraryRestaurant.SeatingStatusOccupied(), ToSeating.Status, 'The new seating should be occupied.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoPadsMerged_HeaderDataCombined_SourceClosed()
    var
        SourceSeating: Record "NPR NPRE Seating";
        TargetSeating: Record "NPR NPRE Seating";
        SourceWaiterPad: Record "NPR NPRE Waiter Pad";
        TargetWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        SourceCustomerTok: Label 'Party of Ada', Locked = true;
    begin
        // [SCENARIO] Merging two bills combines their guests and fills blanks from the source
        // [GIVEN] A source pad with 2 guests and a customer name, and a target pad with 3 guests and none, both pre-receipted
        Initialize();

        CreatePadWithLine(SourceSeating, SourceWaiterPad, 1);
        CreatePadWithLine(TargetSeating, TargetWaiterPad, 1);
        SetHeader(SourceWaiterPad, 2, SourceCustomerTok, true);
        SetHeader(TargetWaiterPad, 3, '', true);

        // [WHEN] The source pad is merged into the target
        WaiterPadMgt.MergeWaiterPad(SourceWaiterPad, TargetWaiterPad);

        // [THEN] Guests are summed, the blank customer name is filled from the source and both pre-receipt flags are cleared
        TargetWaiterPad.Find();
        _Assert.AreEqual(5, TargetWaiterPad."Number of Guests", 'Merging should add the source party to the target party.');
        _Assert.AreEqual(SourceCustomerTok, TargetWaiterPad.Description, 'A blank customer name on the target should be filled from the source.');
        _Assert.IsFalse(TargetWaiterPad."Pre-receipt Printed", 'A merged target pad needs a fresh pre-receipt.');

        // [THEN] The source pad is closed and records that it was merged
        SourceWaiterPad.Find();
        _Assert.IsTrue(SourceWaiterPad.Closed, 'The emptied source pad should close.');
        _Assert.AreEqual(SourceWaiterPad."Close Reason"::"Split/Merge Waiter Pad", SourceWaiterPad."Close Reason", 'The source pad should record that it closed because of a merge.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoPadsMerged_AllLinesMoved_SourceEmptied()
    var
        SourceSeating: Record "NPR NPRE Seating";
        TargetSeating: Record "NPR NPRE Seating";
        SourceWaiterPad: Record "NPR NPRE Waiter Pad";
        TargetWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Merging moves the whole bill, leaving nothing behind
        // [GIVEN] A source pad with three lines and a target pad with one
        Initialize();

        CreatePadWithLine(SourceSeating, SourceWaiterPad, 1);
        AddLine(SourceWaiterPad, 1);
        AddLine(SourceWaiterPad, 1);
        CreatePadWithLine(TargetSeating, TargetWaiterPad, 1);

        // [WHEN] The source pad is merged into the target
        WaiterPadMgt.MergeWaiterPad(SourceWaiterPad, TargetWaiterPad);

        // [THEN] The source holds no lines and the target holds all four
        WaiterPadLine.SetRange("Waiter Pad No.", SourceWaiterPad."No.");
        _Assert.IsTrue(WaiterPadLine.IsEmpty(), 'A merged source pad should have no lines left.');
        WaiterPadLine.SetRange("Waiter Pad No.", TargetWaiterPad."No.");
        _Assert.AreEqual(4, WaiterPadLine.Count(), 'The target pad should hold its own line plus the three merged in.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GuestsMovedBetweenPads_SourceNeverBilled_BilledGuestsNotNegative()
    var
        SourceSeating: Record "NPR NPRE Seating";
        TargetSeating: Record "NPR NPRE Seating";
        SourceWaiterPad: Record "NPR NPRE Waiter Pad";
        TargetWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Splitting guests off an unbilled pad cannot drive the billed guest count below zero
        // [GIVEN] A source pad with 2 guests, none of them billed
        //         Moving a subset rather than all of them is what drives the clamp. Move all 2 and the target computes
        //         0 - 2 + 2 = 0, which is not negative, so both guards are no-ops and deleting them from the product
        //         leaves this test green. Moving 1 computes 0 - 2 + 1 = -1 and the clamp has to fire.
        Initialize();
        CreatePadWithLine(SourceSeating, SourceWaiterPad, 1);
        CreatePadWithLine(TargetSeating, TargetWaiterPad, 1);
        SetHeader(SourceWaiterPad, 2, '', false);
        SetHeader(TargetWaiterPad, 0, '', false);

        // [WHEN] One of the two guests is moved to the target pad
        WaiterPadMgt.MoveNumberOfGuests(SourceWaiterPad, TargetWaiterPad, 1);

        // [THEN] The target's billed count was clamped, and the source's was never driven negative to begin with
        SourceWaiterPad.Find();
        TargetWaiterPad.Find();
        _Assert.AreEqual(0, TargetWaiterPad."Billed Number of Guests", 'The target pad''s billed guest count should be clamped at zero.');
        _Assert.AreEqual(0, SourceWaiterPad."Billed Number of Guests", 'The source pad''s billed guest count should be unchanged.');
        _Assert.AreEqual(1, TargetWaiterPad."Number of Guests", 'The moved guest should land on the target pad.');
        _Assert.AreEqual(1, SourceWaiterPad."Number of Guests", 'The source pad should keep the guest that was not moved.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MoreGuestsMovedThanSourceHas_BilledGuestsClampedOnSource()
    var
        SourceSeating: Record "NPR NPRE Seating";
        TargetSeating: Record "NPR NPRE Seating";
        SourceWaiterPad: Record "NPR NPRE Waiter Pad";
        TargetWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Moving more guests than a pad has cannot leave it owing a negative number of billed guests
        // [GIVEN] A source pad with 2 guests, both already billed
        //         This is the only shape that reaches the source clamp. It needs the target to end up with more billed
        //         guests than the source had, which means moving more guests than the source holds: the sibling test
        //         above moves a subset, which drives the target negative but leaves the source at zero by subtraction.
        Initialize();
        CreatePadWithLine(SourceSeating, SourceWaiterPad, 1);
        CreatePadWithLine(TargetSeating, TargetWaiterPad, 1);
        SetHeader(SourceWaiterPad, 2, '', false);
        SetBilledNumberOfGuests(SourceWaiterPad, 2);
        SetHeader(TargetWaiterPad, 0, '', false);

        // [WHEN] Three guests are moved off a pad that has two
        WaiterPadMgt.MoveNumberOfGuests(SourceWaiterPad, TargetWaiterPad, 3);

        // [THEN] The source is left at zero rather than negative
        SourceWaiterPad.Find();
        TargetWaiterPad.Find();
        _Assert.AreEqual(0, SourceWaiterPad."Billed Number of Guests", 'The source pad''s billed guest count should be clamped at zero.');
        _Assert.AreEqual(0, SourceWaiterPad."Number of Guests", 'The source pad should be left with no guests.');
        _Assert.AreEqual(3, TargetWaiterPad."Billed Number of Guests", 'The target pad should carry the billed guests that moved.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PadHeaderDuplicated_NewPadCreated_TransientStateReset()
    var
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        SourceWaiterPad: Record "NPR NPRE Waiter Pad";
        NewWaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
    begin
        // [SCENARIO] Duplicating a pad header copies the party's details but none of its progress
        // [GIVEN] A closed pad with 4 guests, 2 of them billed, and a printed pre-receipt
        //         The billed count has to be set explicitly - nothing in the lifecycle writes it - otherwise the
        //         assertion that the duplicate starts with nothing billed is 0 = 0 and would survive deleting the reset.
        Initialize();
        CreatePadWithLine(Seating, SourceWaiterPad, 1);
        SetHeader(SourceWaiterPad, 4, '', true);
        SetBilledNumberOfGuests(SourceWaiterPad, 2);
        WaiterPadMgt.TryCloseWaiterPad(SourceWaiterPad, true, "NPR NPRE W/Pad Closing Reason"::"Manually Closed");
        SourceWaiterPad.Find();

        // [WHEN] Its header is duplicated
        WaiterPadMgt.DuplicateWaiterPadHdr(SourceWaiterPad, NewWaiterPad);

        // [THEN] The new pad is open, unstamped, has no guests and no pre-receipt
        NewWaiterPad.Find();
        _Assert.AreNotEqual(SourceWaiterPad."No.", NewWaiterPad."No.", 'The duplicate should be a new waiter pad.');
        _Assert.IsFalse(NewWaiterPad.Closed, 'A duplicated pad should start open.');
        _Assert.AreEqual(0D, NewWaiterPad."Close Date", 'A duplicated pad should not carry the source pad''s close date.');
        _Assert.AreEqual(0T, NewWaiterPad."Close Time", 'A duplicated pad should not carry the source pad''s close time.');
        _Assert.AreEqual(0, NewWaiterPad."Number of Guests", 'A duplicated pad should start with no guests.');
        _Assert.AreEqual(0, NewWaiterPad."Billed Number of Guests", 'A duplicated pad should start with nothing billed.');
        _Assert.IsFalse(NewWaiterPad."Pre-receipt Printed", 'A duplicated pad should need its own pre-receipt.');

        // [THEN] The seating link came across
        SeatingWaiterPadLink.SetRange("Waiter Pad No.", NewWaiterPad."No.");
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        _Assert.AreEqual(1, SeatingWaiterPadLink.Count(), 'The duplicated pad should be linked to the same seating.');
        // The link's Closed flag is reset from the new pad, and the source pad here is closed - so without that reset
        // the duplicate would be born open on a seating whose link reads closed: a table showing free with a live pad.
        SeatingWaiterPadLink.FindFirst();
        _Assert.IsFalse(
            SeatingWaiterPadLink.Closed, 'An open duplicate should hold an open seating link, not the source pad''s closed one.');
    end;

    #region Setup helpers

    local procedure Initialize()
    var
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

            _POSUnit."POS Restaurant Profile" := POSRestProfile.Code;
            _POSUnit.Modify();

            // No kitchen station is routed here, so no line ever produces a kitchen request and the
            // served condition is vacuously satisfied. These scenarios are about the pad, not the kitchen.
            _RestaurantInitialized := true;
        end;

        // Restored per test: DefaultGuestCount_ConfiguredOnRestaurant_ResolvedThroughHierarchy writes this to the shared
        // restaurant, and with codeunit-level isolation it would otherwise persist for every test declared after it.
        _Restaurant.Find();
        _Restaurant."Default Number of Guests" := _Restaurant."Default Number of Guests"::Default;
        _Restaurant.Modify();

        // Configured for every test because clearing a seating is a silent no-op unless "Seating Status after
        // Clearing" holds a status code, which the plain CreateServiceFlowProfile leaves blank.
        //
        // The close rule itself is not load-bearing here. Merge moves every line off the source pad, so by the time
        // TryCloseWaiterPad runs, WaiterPadCanBeClosed takes its empty-pad fast path and returns true before
        // "Close Waiter Pad On" is read at all. Under the Payment rule configured below, WPIsPaid would in fact
        // return false on an empty pad - it is simply never reached. Switching this to Manual would not break the
        // merge tests.
        _ServFlowProfile.Find();
        _LibraryRestaurant.ConfigureServiceFlowProfile(
            _ServFlowProfile, "NPR NPRE Serv.Flow Close W/Pad"::Payment, "NPR NPRE Serv.Flow Clear Seat."::"Waiter Pad Close",
            "NPR NPRE W/Pad Status Pmt. On"::Manual, false);
        Commit();
    end;

    local procedure CreatePadWithLine(var Seating: Record "NPR NPRE Seating"; var WaiterPad: Record "NPR NPRE Waiter Pad"; Quantity: Decimal)
    begin
        _LibraryRestaurant.CreateSeating(Seating, _SeatingLocation.Code);
        _LibraryRestaurant.CreateWaiterPadForSeating(Seating.Code, WaiterPad);
        AddLine(WaiterPad, Quantity);
    end;

    local procedure AddLine(WaiterPad: Record "NPR NPRE Waiter Pad"; Quantity: Decimal)
    var
        Item: Record Item;
        WaiterPadLine: Record "NPR NPRE Waiter Pad Line";
    begin
        _LibraryPOSMasterData.CreateItemForPOSSaleUsage(Item, _POSUnit, _POSStore);
        _LibraryRestaurant.AddWaiterPadLine(WaiterPad."No.", Item."No.", Quantity, 0, WaiterPadLine);
    end;

    local procedure SetHeader(var WaiterPad: Record "NPR NPRE Waiter Pad"; NumberOfGuests: Integer; CustomerName: Text; PreReceiptPrinted: Boolean)
    begin
        WaiterPad.Find();
        WaiterPad."Number of Guests" := NumberOfGuests;
        WaiterPad.Description := CopyStr(CustomerName, 1, MaxStrLen(WaiterPad.Description));
        WaiterPad."Pre-receipt Printed" := PreReceiptPrinted;
        WaiterPad.Modify();
    end;

    local procedure SetBilledNumberOfGuests(var WaiterPad: Record "NPR NPRE Waiter Pad"; BilledNumberOfGuests: Integer)
    begin
        // Only NPREWaiterPadMgt writes this field, and only on duplicate, merge, split and guest-move. Nothing on the POS
        // or posting path touches it - the posting hook updates the *line's* "Billed Quantity", a different field on a
        // different table - so fixtures that need a non-zero value have to state it.
        WaiterPad.Find();
        WaiterPad."Billed Number of Guests" := BilledNumberOfGuests;
        WaiterPad.Modify();
    end;

    #endregion
}

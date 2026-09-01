codeunit 85392 "NPR TM TicketExpiryTest"
{
    Subtype = Test;

    var
        _Initialized: Boolean;
        _ItemNo: Code[20];
        _SlotItemNo: Code[20];
        _NextRideItemNo: Code[20];
        _EntryAndRideItemNo: Code[20];
        CutOffMode: Option None,Minutes,DateOnlyYesterday,BlankDate;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TwoPhaseSweep_ReleasesThenDeletes()
    var
        Assert: Codeunit Assert;
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
        BeforeSweep: DateTime;
    begin
        // [SCENARIO] Phase 1 expires a lapsed token (tickets deleted, capacity released, rows retained for inspection); phase 2 deletes the retained rows once their retention lapses.
        Initialize();

        Token := CreateRegisteredToken();
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));
        Assert.IsFalse(Ticket.IsEmpty(), 'Registered token must have issued tickets before expiry.');

        AgeToken(Token);
        BeforeSweep := CurrentDateTime();
        RunExpiry();

        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'after phase 1');
        Assert.IsTrue(Ticket.IsEmpty(), 'Phase 1 must delete the tickets (capacity release).');
        AssertRetentionStampBetween(Token, BeforeSweep + (50 * 60 * 1000), CurrentDateTime() + (70 * 60 * 1000), 'phase 1 must retain rows for one hour');

        AgeToken(Token);
        RunExpiry();
        Assert.IsFalse(TokenRowsExist(Token), 'Phase 2 must delete retained rows once retention has lapsed.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenPosSale_KeepsReservationAlive()
    var
        Assert: Codeunit Assert;
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] A lapsed reservation whose receipt is still an open POS sale is live demand: phase 1 keeps
        // it REGISTERED (tickets and capacity intact) and pushes its expiry to end of day. Once the sale is gone
        // the normal two-phase teardown applies.
        Initialize();

        Token := CreateRegisteredToken();
        ReceiptNo := 'EXPTEST-01';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));

        AgeToken(Token);
        RunExpiry();
        AssertKeptAlive(Token, 'an in-POS reservation must not expire while its sale is open');
        Assert.IsFalse(Ticket.IsEmpty(), 'The tickets must survive - capacity stays deliberately blocked for an open sale.');

        RemoveOpenSale(ReceiptNo);
        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'once the sale is gone the reservation expires normally');
        Assert.IsTrue(Ticket.IsEmpty(), 'Expiry must release the capacity once the sale is gone.');

        AgeToken(Token);
        RunExpiry();
        Assert.IsFalse(TokenRowsExist(Token), 'Rows must be deleted on the first sweep cycle after retention lapses.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenPosSale_SelectedSlot_KeepAliveEndsWithSlot()
    var
        Assert: Codeunit Assert;
        TimeHelper: Codeunit "NPR TM TimeHelper";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
        ReceiptNo: Code[20];
        LocalNow: DateTime;
    begin
        // [SCENARIO] A reservation with an explicitly selected time slot is held for its open POS sale as long as the slot
        // is open for entry with the pre-payment floor to spare: a far-off slot and a slot closing in 30 minutes are held,
        // a slot closing within the 5-minute floor is not retained at all - it expires and releases its capacity even
        // though the sale is still open.
        Initialize();

        Token := CreateRegisteredSlotToken(AdmissionScheduleEntry);
        ReceiptNo := 'EXPTEST-06';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));

        // Slot ends tomorrow: held
        AgeToken(Token);
        RunExpiry();
        AssertKeptAlive(Token, 'a far-off selected slot must be held like any in-POS reservation');

        // Slot ends in 30 minutes (admission end, no arrival window): still held
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, LocalNow + (30 * 60 * 1000), 0T);

        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'a selected slot that has not ended yet must be kept alive');
        Assert.IsFalse(Ticket.IsEmpty(), 'The tickets must survive while the selected slot is still open.');
        AssertKeptAlive(Token, 'a selected slot still open for entry must be held');

        // Slot ends in 3 minutes - inside the 5-minute margin: the payment floor could carry the sale past the slot, so no retention
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, LocalNow + (3 * 60 * 1000), 0T);

        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'a selected slot closing inside the payment-floor margin must expire despite the open POS sale');
        Assert.IsTrue(Ticket.IsEmpty(), 'Expiry must release the capacity of the closing slot.');

        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OpenPosSale_NextRide_KeepAliveEndsWithMintedSlot()
    var
        Assert: Codeunit Assert;
        TimeHelper: Codeunit "NPR TM TimeHelper";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
        ReceiptNo: Code[20];
        LocalNow: DateTime;
    begin
        // [SCENARIO] A "next ride" ticket (NEXT_AVAILABLE on a prebook-required admission) is minted for a concrete ride
        // although the cashier never picked one. The gate admits against the ride on the ticket's reservation entry, so
        // the hold follows that ride - a ride on a later date and a ride closing in 30 minutes are held, a ride whose
        // arrival window has closed is not retained at all (re-adding the line mints the next ride).
        // (The request line may also carry an entry: pricing resolves and stores the current slot at issuance for
        // BC-priced sales. The cap is read from the minted reservation regardless.)
        Initialize();

        Token := CreateRegisteredNextRideToken();
        ReceiptNo := 'EXPTEST-07';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));
        GetMintedScheduleEntry(Token, AdmissionScheduleEntry);

        // Ride moved to tomorrow: held
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, CreateDateTime(CalcDate('<+1D>', DT2Date(LocalNow)), 235959T), 0T);

        AgeToken(Token);
        RunExpiry();
        AssertKeptAlive(Token, 'a next-ride ticket for a future ride must be held');

        // Ride closes in 30 minutes: still held
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, LocalNow + (30 * 60 * 1000), 0T);

        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'a next-ride ticket must be kept alive while its ride is still boarding');
        Assert.IsFalse(Ticket.IsEmpty(), 'The ticket must survive while its ride is still boarding.');
        AssertKeptAlive(Token, 'a next-ride ticket must be held while its ride is boarding');

        // Boarding closed a minute ago (ride itself still running): the gate would refuse the ticket, so it is released
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, CreateDateTime(DT2Date(LocalNow), 235959T), DT2Time(LocalNow - 60000));

        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'a next-ride ticket whose boarding has closed must expire despite the open POS sale');
        Assert.IsTrue(Ticket.IsEmpty(), 'Expiry must release the departed ride so re-adding the line mints the next one.');

        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrePayment_RefusesPassedSlotAndNamesTheLine()
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        SalePOS: Record "NPR POS Sale";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Token: Text[100];
        ReceiptNo: Code[20];
        LineDescription: Text;
        LocalNow: DateTime;
    begin
        // [SCENARIO] The pre-payment check floors a live reservation, refuses a line whose binding time slot has passed
        // even before the expiry sweep has caught up with it, keeps refusing once the sweep has released it or its rows
        // are gone - and every refusal names the sale line the way the cashier sees it.
        Initialize();

        Token := CreateRegisteredSlotToken(AdmissionScheduleEntry);
        ReceiptNo := 'EXPTEST-08';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        LineDescription := 'Expiry test slot ticket';
        StampSaleLine(ReceiptNo, _SlotItemNo, LineDescription, Token);
        SalePOS.Get('EXPTEST', ReceiptNo);

        // Live reservation, slot still open: accepted, expiry floored ahead of payment
        AgeToken(Token);
        TicketManagement.CheckAndExtendTicketReservationsBeforePayment(SalePOS);
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'an open slot must pass the pre-payment check');
        AssertRetentionStampBetween(Token, CurrentDateTime() + (4 * 60 * 1000), CurrentDateTime() + (6 * 60 * 1000), 'a live reservation must be floored ahead of payment');

        // Slot closes in 3 minutes: still payable (no margin at the till), but the floor is capped at the slot end
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, LocalNow + (3 * 60 * 1000), 0T);
        AgeToken(Token);
        TicketManagement.CheckAndExtendTicketReservationsBeforePayment(SalePOS);
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'a slot that is still open must pass the pre-payment check right up to its close');
        AssertRetentionStampBetween(Token, CurrentDateTime() + (2 * 60 * 1000), CurrentDateTime() + (4 * 60 * 1000), 'the pre-payment floor must be capped at the slot end');

        // Slot passed but the sweep has not run yet: refused, and the message names the line
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, LocalNow - 60000, 0T);
        AssertNotExtendable(Token, AdmissionScheduleEntry, 'entry closed a minute ago');
        AssertPrePaymentRefuses(SalePOS, LineDescription, AdmissionScheduleEntry."Admission Code", 'entry closed before the sweep ran');
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'the pre-payment check itself must not expire the reservation');

        // The sweep catches up and releases the slot: still refused
        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'the sweep must release a passed slot');
        AssertPrePaymentRefuses(SalePOS, LineDescription, '', 'sweep released the reservation');

        // Rows gone entirely: still refused
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.DeleteAll();
        AssertPrePaymentRefuses(SalePOS, LineDescription, '', 'reservation rows deleted');

        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KeepAlive_ArrivalAndSalesWindowMatrix()
    var
        SlotClosedReason: Label 'can no longer be sold for that time', Locked = true;
    begin
        // [SCENARIO] The hold and payability of a gate-enforced slot across the arrival-window / sales-cut-off combinations
        // found in real setups. Minutes are relative to venue-local now; hold 0 = not retained by the sweep.
        //   entry = arrival-until (blank -> slot end), end = admission end, cut-off = Sales Until, flag = BOM enforces limits
        Initialize();

        //                 case  entry  end  cut-off mode                 cut-off  flag   held   payable  refusal reason
        RunKeepAliveCase('M01', 60, 60, CutOffMode::None, 0, false, true, true, '');    // no cut-off, entry open
        RunKeepAliveCase('M02', 60, 60, CutOffMode::Minutes, 30, true, true, true, '');    // cut-off ahead: still held
        RunKeepAliveCase('M03', 60, 60, CutOffMode::Minutes, 30, false, true, true, '');    // same, flag off
        RunKeepAliveCase('M04', 60, 60, CutOffMode::Minutes, 90, true, true, true, '');    // cut-off after entry close
        RunKeepAliveCase('M05', 60, 60, CutOffMode::Minutes, 60, true, true, true, '');    // cut-off = entry close
        RunKeepAliveCase('M06', 60, 60, CutOffMode::Minutes, -10, true, false, true, '');   // cut-off passed: released, still payable
        RunKeepAliveCase('M07', 60, 60, CutOffMode::DateOnlyYesterday, 0, true, false, true, '');   // "-7D" style date-only cut-off long passed
        RunKeepAliveCase('M08', 60, 60, CutOffMode::BlankDate, 0, true, false, true, '');   // blank date: cut-off resolves to the slot's end date (today), already passed
        RunKeepAliveCase('M09', 60, 120, CutOffMode::None, 0, false, true, true, '');    // arrival closes before the slot ends, still open
        RunKeepAliveCase('M10', 3, 3, CutOffMode::None, 0, false, false, true, '');   // inside the 5-minute margin: released, still payable
        RunKeepAliveCase('M11', -1, -1, CutOffMode::None, 0, false, false, false, SlotClosedReason);  // entry closed: released, refused
        RunKeepAliveCase('M12', -1, 60, CutOffMode::Minutes, 30, true, false, false, SlotClosedReason);  // arrival closed although slot and sales run on: refused
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure KeepAlive_MultiAdmissionTicket_EarliestBoundWins()
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        RideEntry: Record "NPR TM Admis. Schedule Entry";
        EntryAdmissionEntry: Record "NPR TM Admis. Schedule Entry";
        Token: Text[100];
        ReceiptNo: Code[20];
        LocalNow: DateTime;
    begin
        // [SCENARIO] A ticket with an all-day entry admission (non-binding) and a next-ride admission (gate-enforced) is
        // held only as long as the tightest of its lines allows: the ride's boarding minus the margin, or the entry
        // admission's sales cut-off when that comes first.
        Initialize();

        Token := CreateRegisteredEntryAndRideToken();
        ReceiptNo := 'EXPTEST-13';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        GetMintedScheduleEntry(Token, RideEntry);
        GetMintedEntryForAdmission(Token, GetAdmissionCodeOfBomRow(_EntryAndRideItemNo, false), EntryAdmissionEntry);

        // Ride boards for 30 more minutes, entry admission open all day: the ride bounds the hold (30 - 5)
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(RideEntry."Admission Code");
        SetSlotEnd(RideEntry, LocalNow + (30 * 60 * 1000), 0T);
        AgeToken(Token);
        RunExpiry();
        AssertKeptAlive(Token, 'the ticket must be held while its ride is boarding');

        // Entry admission's sales closed a minute ago (flag on): the non-binding entry line alone releases the whole ticket
        TicketBom.Get(_EntryAndRideItemNo, '', EntryAdmissionEntry."Admission Code");
        TicketBom."Enforce Schedule Sales Limits" := true;
        TicketBom.Modify();
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(EntryAdmissionEntry."Admission Code");
        SetSalesCutOff(EntryAdmissionEntry, LocalNow - 60000);
        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'a passed sales cut-off on any of the ticket''s admissions must release the ticket');

        TicketBom."Enforce Schedule Sales Limits" := false;
        TicketBom.Modify();
        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRide_TodaySoldOut_RollsToNextAvailable()
    var
        Assert: Codeunit Assert;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        RideEntry: Record "NPR TM Admis. Schedule Entry";
        MintedRide: Record "NPR TM Admis. Schedule Entry";
        ResponseToken: Text;
        ResponseMessage: Text;
        Token: Text[100];
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        LocalNow: DateTime;
        LocalToday: Date;
        Registered: Boolean;
    begin
        // [SCENARIO] When every ride left today is past its sales cut-off, a next-ride ticket still registers - NEXT_AVAILABLE
        // issuance rolls forward past the closed rides to the next sellable one (tomorrow) rather than refusing the sale.
        Initialize();
        if (_NextRideItemNo = '') then
            _NextRideItemNo := CreateNextRideScenario(false);

        TicketBom.SetFilter("Item No.", '=%1', _NextRideItemNo);
        TicketBom.FindFirst();
        SetEnforceSalesLimits(_NextRideItemNo, TicketBom."Admission Code", true);

        // Close sales for TODAY's rides only, leaving later days sellable so issuance has somewhere to roll to
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(TicketBom."Admission Code");
        LocalToday := DT2Date(LocalNow);
        RideEntry.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
        RideEntry.SetFilter("Admission Start Date", '=%1', LocalToday);
        RideEntry.SetFilter(Cancelled, '=%1', false);
        if (RideEntry.FindSet()) then
            repeat
                SetSalesCutOff(RideEntry, LocalNow - 60000);
            until (RideEntry.Next() = 0);

        Registered := TicketApiLibrary.MakeReservation(1, _NextRideItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage);

        // Restore before asserting - a failed assertion must not leave today's rides of the shared scenario closed
        if (RideEntry.FindSet()) then
            repeat
                SetSalesCutOffRaw(RideEntry, 0D, 0T);
            until (RideEntry.Next() = 0);
        SetEnforceSalesLimits(_NextRideItemNo, TicketBom."Admission Code", false);

        Assert.IsTrue(Registered, 'Registering must succeed by rolling to the next sellable ride. Got: ' + ResponseMessage);
        Token := CopyStr(ResponseToken, 1, MaxStrLen(Token));
        GetMintedScheduleEntry(Token, MintedRide);
        Assert.IsTrue(MintedRide."Admission Start Date" > LocalToday,
            StrSubstNo('The minted ride must be a later, still-sellable day, not a closed one today. Got start date %1 (today %2).', MintedRide."Admission Start Date", LocalToday));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PrePayment_ExplicitSlotOnNonPrebookAdmission_NeverRefused()
    var
        Assert: Codeunit Assert;
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        SalePOS: Record "NPR POS Sale";
        Admission: Record "NPR TM Admission";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Ticket: Record "NPR TM Ticket";
        ItemNo: Code[20];
        Token: Text[100];
        ReceiptNo: Code[20];
        ResponseToken: Text;
        ResponseMessage: Text;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
        LocalNow: DateTime;
    begin
        // [SCENARIO] A slot chosen explicitly on an admission WITHOUT prebooking bounds the idle hold, but the gate admits
        // a paid ticket regardless of it - so the till never refuses the payment when that slot's entry has closed.
        Initialize();

        ItemNo := LibraryTicketModule.CreateScenario_ImportTicketTest_FutureSchedule(Admission."Default Schedule"::SCHEDULE_ENTRY);
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.FindFirst();
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', CalcDate('<+1D>', Today()));
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        Assert.IsTrue(AdmissionScheduleEntry.FindFirst(), 'The future-schedule scenario generated no entry for tomorrow.');
        Assert.IsTrue(TicketApiLibrary.MakeReservation(1, ItemNo, 1, AdmissionScheduleEntry."External Schedule Entry No.", MemberNumber, ScannerStation, ResponseToken, ResponseMessage), ResponseMessage);
        Token := CopyStr(ResponseToken, 1, MaxStrLen(Token));

        ReceiptNo := 'EXPTEST-12';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        StampSaleLine(ReceiptNo, ItemNo, 'Expiry test non-prebook slot ticket', Token);
        SalePOS.Get('EXPTEST', ReceiptNo);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));

        // Entry to the chosen slot closed a minute ago: still payable
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, LocalNow - 60000, 0T);
        AgeToken(Token);
        TicketManagement.CheckAndExtendTicketReservationsBeforePayment(SalePOS);
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'a closed slot on a non-prebook admission must not refuse payment - the gate admits the ticket anyway');

        // ...but an idle basket is no longer held for it
        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'an idle reservation for a closed explicit slot must not be kept alive');
        Assert.IsTrue(Ticket.IsEmpty(), 'Expiry must release the ticket.');

        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalesCutOff_BoundsKeepAliveAndPayment()
    var
        Assert: Codeunit Assert;
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        SalePOS: Record "NPR POS Sale";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
        ReceiptNo: Code[20];
        LineDescription: Text;
        LocalNow: DateTime;
    begin
        // [SCENARIO] When the ticket BOM enforces schedule sales limits and the slot carries a "Sales Until", that
        // cut-off - not the arrival window minus the margin - is how long an idle reservation is kept alive. It does
        // NOT refuse payment: real setups close sales at the slot start while admitting for another 90 minutes, so a
        // live reservation across the cut-off must still be payable, floored towards the entry closing.
        Initialize();

        Token := CreateRegisteredSlotToken(AdmissionScheduleEntry);
        ReceiptNo := 'EXPTEST-09';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        LineDescription := 'Expiry test cut-off ticket';
        StampSaleLine(ReceiptNo, _SlotItemNo, LineDescription, Token);
        SalePOS.Get('EXPTEST', ReceiptNo);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));
        SetEnforceSalesLimits(_SlotItemNo, AdmissionScheduleEntry."Admission Code", true);

        // Entry closes in 60 minutes, sales close in 30: keep-alive runs to the sales cut-off, with no margin
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, LocalNow + (60 * 60 * 1000), 0T);
        SetSalesCutOff(AdmissionScheduleEntry, LocalNow + (30 * 60 * 1000));

        AgeToken(Token);
        RunExpiry();
        AssertKeptAlive(Token, 'a slot still on sale must be held');

        // Entry closes in 20 minutes while sales nominally run to +30 (a blank "Sales Until Time" defaults to the slot
        // end, which can lie after arrival closes): the hold is capped at the entry closing - with no margin, since a
        // configured cut-off means operations sized the gap themselves
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSlotEnd(AdmissionScheduleEntry, LocalNow + (20 * 60 * 1000), 0T);

        AgeToken(Token);
        RunExpiry();
        AssertKeptAlive(Token, 'a sales cut-off after the entry closing must not shorten the hold while entry is open');
        SetSlotEnd(AdmissionScheduleEntry, LocalNow + (60 * 60 * 1000), 0T);

        // Paying before the cut-off: floored towards the entry closing (5 min), not clipped at the cut-off
        AgeToken(Token);
        TicketManagement.CheckAndExtendTicketReservationsBeforePayment(SalePOS);
        AssertRetentionStampBetween(Token, CurrentDateTime() + (4 * 60 * 1000), CurrentDateTime() + (6 * 60 * 1000), 'a payment started while on sale must get the full floor');

        // Sales closed a minute ago, entry still open for an hour: a live reservation is still payable (floored)
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSalesCutOff(AdmissionScheduleEntry, LocalNow - 60000);
        AgeToken(Token);
        TicketManagement.CheckAndExtendTicketReservationsBeforePayment(SalePOS);
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'a passed sales cut-off must not refuse payment while entry is still open');
        AssertRetentionStampBetween(Token, CurrentDateTime() + (4 * 60 * 1000), CurrentDateTime() + (6 * 60 * 1000), 'a live reservation across the sales cut-off must still be floored');

        // ...but once idle it is not kept alive any longer: the sweep releases it
        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'an idle reservation past its sales cut-off must expire despite the open POS sale');
        Assert.IsTrue(Ticket.IsEmpty(), 'Expiry must release the capacity of the slot that is off sale.');

        SetEnforceSalesLimits(_SlotItemNo, AdmissionScheduleEntry."Admission Code", false);
        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SalesCutOff_ReleasesIdleAllDayTicket()
    var
        Assert: Codeunit Assert;
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        SalePOS: Record "NPR POS Sale";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
        ReceiptNo: Code[20];
        LocalNow: DateTime;
    begin
        // [SCENARIO] An all-day TODAY ticket (no prebook, no explicit slot) is not slot-bound: entry stays open, payment
        // stays possible. But when the BOM enforces sales limits and the day's slot carries a "Sales Until" (an entry
        // that stops selling at 16:30), an idle basket is kept alive only until that cut-off and released after it.
        Initialize();

        Token := CreateRegisteredToken();
        ReceiptNo := 'EXPTEST-10';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        StampSaleLine(ReceiptNo, _ItemNo, 'Expiry test all-day ticket', Token);
        SalePOS.Get('EXPTEST', ReceiptNo);
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));
        GetMintedScheduleEntry(Token, AdmissionScheduleEntry);

        TicketBom.SetFilter("Item No.", '=%1', _ItemNo);
        TicketBom.FindFirst();
        SetEnforceSalesLimits(_ItemNo, TicketBom."Admission Code", true);

        // Sales close in 30 minutes: the idle hold ends there instead of at end of day
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSalesCutOff(AdmissionScheduleEntry, LocalNow + (30 * 60 * 1000));

        AgeToken(Token);
        RunExpiry();
        AssertKeptAlive(Token, 'an all-day ticket still on sale must be held');

        // Sales closed a minute ago: a live reservation is still payable, an idle one is released
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        SetSalesCutOff(AdmissionScheduleEntry, LocalNow - 60000);
        AgeToken(Token);
        TicketManagement.CheckAndExtendTicketReservationsBeforePayment(SalePOS);
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'a passed sales cut-off must not refuse payment of an all-day ticket');

        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'an idle all-day ticket past its sales cut-off must expire despite the open POS sale');
        Assert.IsTrue(Ticket.IsEmpty(), 'Expiry must release the ticket that is off sale.');

        SetEnforceSalesLimits(_ItemNo, TicketBom."Admission Code", false);
        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRide_MintingSkipsRidePastSalesCutOff()
    var
        Assert: Codeunit Assert;
        TimeHelper: Codeunit "NPR TM TimeHelper";
        FirstRide: Record "NPR TM Admis. Schedule Entry";
        SecondRide: Record "NPR TM Admis. Schedule Entry";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        FirstToken: Text[100];
        SecondToken: Text[100];
        LocalNow: DateTime;
    begin
        // [SCENARIO] A next-ride ticket is minted for the ride that is boarding now. Once that ride's sales cut-off has
        // passed (BOM enforces schedule sales limits), the next ticket is minted for a later ride instead - so a ticket
        // never lands in the basket already off sale. The gate is untouched: only issuance honours the cut-off.
        Initialize();

        FirstToken := CreateRegisteredNextRideToken();
        GetMintedScheduleEntry(FirstToken, FirstRide);

        TicketBom.SetFilter("Item No.", '=%1', _NextRideItemNo);
        TicketBom.FindFirst();
        SetEnforceSalesLimits(_NextRideItemNo, TicketBom."Admission Code", true);
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(FirstRide."Admission Code");
        SetSalesCutOff(FirstRide, LocalNow - 60000);

        SecondToken := CreateRegisteredNextRideToken();
        GetMintedScheduleEntry(SecondToken, SecondRide);
        Assert.AreNotEqual(FirstRide."External Schedule Entry No.", SecondRide."External Schedule Entry No.",
            StrSubstNo('Minting must skip the ride whose sales have closed. First ride %1 (entry %2, sales until %3), second ride %4 (entry %5, sales until %6), local now %7.',
                CreateDateTime(FirstRide."Admission Start Date", FirstRide."Admission Start Time"), FirstRide."Entry No.", CreateDateTime(FirstRide."Sales Until Date", FirstRide."Sales Until Time"),
                CreateDateTime(SecondRide."Admission Start Date", SecondRide."Admission Start Time"), SecondRide."Entry No.", CreateDateTime(SecondRide."Sales Until Date", SecondRide."Sales Until Time"), LocalNow));
        Assert.IsTrue(CreateDateTime(SecondRide."Admission Start Date", SecondRide."Admission Start Time") > CreateDateTime(FirstRide."Admission Start Date", FirstRide."Admission Start Time"), 'The ticket must be minted for a later ride.');

        SetEnforceSalesLimits(_NextRideItemNo, TicketBom."Admission Code", false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnattendedPosSale_ExpiresOnTtl()
    var
        Token: Text[100];
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] A lapsed reservation in a sale on an UNATTENDED unit is anonymous abandonment - the
        // keep-alive does not apply and the reservation expires on the TTL as it always has (the kiosk
        // dead-sale cleanup job only removes sales from before yesterday, so the sweep cannot rely on it).
        Initialize();

        Token := CreateRegisteredToken();
        ReceiptNo := 'EXPTEST-05';
        StampReceiptWithOpenSale(Token, ReceiptNo, true);

        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'a kiosk basket must expire on the TTL despite the open sale');

        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MaxRetention_DeletesDespiteOpenSale()
    var
        Assert: Codeunit Assert;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Token: Text[100];
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] The 24 hour ceiling overrules the open POS sale on both phases: a reservation past the
        // ceiling expires despite its open sale (abandoned attended-unit sales are never cleaned up, and a
        // day-old basket holds stale slot resolutions), and its retained rows are likewise deleted.
        Initialize();

        Token := CreateRegisteredToken();
        ReceiptNo := 'EXPTEST-02';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.ModifyAll("Created Date Time", CurrentDateTime() - (25 * 60 * 60 * 1000));

        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'phase 1 must expire a reservation past the ceiling despite the open POS sale');

        AgeToken(Token);
        RunExpiry();
        Assert.IsFalse(TokenRowsExist(Token), 'Phase 2 must delete rows past the retention ceiling despite the open POS sale.');

        RemoveOpenSale(ReceiptNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RevokeRequests_NeverRetained()
    var
        Assert: Codeunit Assert;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Token: Text[100];
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] Revoke requests are past-dated at expiry and deleted on the next sweep, even when the return sale is still open - a retained revoke row would block refunding the ticket on all registers.
        Initialize();

        Token := CreateRegisteredToken();
        ReceiptNo := 'EXPTEST-03';
        StampReceiptWithOpenSale(Token, ReceiptNo);
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.ModifyAll("Revoke Ticket Request", true);

        AgeToken(Token);
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'phase 1');
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime());
        Assert.IsFalse(TicketReservationRequest.IsEmpty(), 'Expired revoke rows must be past-dated, not granted the retention window.');
        TicketReservationRequest.SetRange("Expires Date Time");

        RunExpiry();
        Assert.IsFalse(TokenRowsExist(Token), 'Expired revoke rows must be deleted on the next sweep despite the open POS sale.');

        RemoveOpenSale(ReceiptNo);
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Mutex_BlocksSweepUntilReleased()
    var
        Assert: Codeunit Assert;
        RequestMutex: Record "NPR TM TicketRequestMutex";
        Token: Text[100];
    begin
        // [SCENARIO] A held mutex row blocks the sweep from touching the token (Acquire is a bare Insert - the primary key collision fails it regardless of session). Releasing the mutex lets the next sweep proceed.
        Initialize();

        Token := CreateRegisteredToken();
        AgeToken(Token);

        RequestMutex.SessionTokenId := Token;
        RequestMutex.BusinessCentralSessionId := SessionId();
        RequestMutex.Insert();

        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'REGISTERED', 'sweep must skip a token whose mutex is held');
        Assert.IsTrue(RequestMutex.Get(Token), 'The sweep must not release a mutex it did not acquire.');

        RequestMutex.Delete();
        RunExpiry();
        AssertAllRowsHaveStatus(Token, 'EXPIRED', 'sweep must process the token once the mutex is released');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WorkloadCount_ReportsExpiredDeletedAndSkipped()
    var
        Assert: Codeunit Assert;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Token1: Text[100];
        Token2: Text[100];
        ReceiptNo: Code[20];
    begin
        // [SCENARIO] The V2 worker's return value counts all handled tokens - expired, deleted and retained-for-open-sale - so the job queue loop and telemetry see the actual workload.
        Initialize();

        Token1 := CreateRegisteredToken();
        Token2 := CreateRegisteredToken();
        AgeToken(Token1);
        AgeToken(Token2);

        Assert.AreEqual(2, TicketRequestManager.ExpireReservationRequestsV2_Inline(), 'Phase 1 must report both expired tokens.');

        ReceiptNo := 'EXPTEST-04';
        StampReceiptWithOpenSale(Token1, ReceiptNo);
        AgeToken(Token1);
        AgeToken(Token2);

        Assert.AreEqual(2, TicketRequestManager.ExpireReservationRequestsV2_Inline(), 'Phase 2 must count the deleted and the retained token alike.');
        Assert.IsTrue(TokenRowsExist(Token1), 'The open-sale token must be retained.');
        Assert.IsFalse(TokenRowsExist(Token2), 'The token without a sale must be deleted.');

        Assert.AreEqual(0, TicketRequestManager.ExpireReservationRequestsV2_Inline(), 'A retained token must not re-enter the sweep before its retention lapses.');

        RemoveOpenSale(ReceiptNo);
    end;
#endif

    // Resolve the current ride against the same clock that validates it. GetLocalTimeAtAdmission reads
    // TicketSetup.ServiceTimeZoneNo - 0 in a bare test company, which sends it down the DST-free user-offset
    // fallback and drifts an hour from Today()/Time() on a DST-applying runner (the CI flake). Point the service
    // timezone at the session user's own zone so resolver and validator agree in any runner TZ - the config a real
    // tenant always has. Left unchanged (still 0) when the user has no personal zone, so nothing breaks locally.
    local procedure AlignServiceTimeZoneToSession(var TicketSetup: Record "NPR TM Ticket Setup")
    var
        UserPersonalization: Record "User Personalization";
        TimeZone: Record "Time Zone";
    begin
        if (not UserPersonalization.Get(UserSecurityId())) then
            exit;
        if (UserPersonalization."Time Zone" = '') then
            exit;
        TimeZone.SetRange(ID, UserPersonalization."Time Zone");
        if (TimeZone.FindFirst()) then
            TicketSetup.ServiceTimeZoneNo := TimeZone."No.";
    end;

    local procedure Initialize()
    var
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        if (not _Initialized) then begin
            LibraryTicketModule.CreateMinimalSetup();

            if (not TicketSetup.Get()) then begin
                TicketSetup.Init();
                TicketSetup.Insert();
            end;
            TicketSetup.ExpireReservationWithJobQueue := false;
            AlignServiceTimeZoneToSession(TicketSetup);
            TicketSetup.Modify();

            _ItemNo := LibraryTicketModule.CreateScenario_SmokeTest();
            _Initialized := true;
        end;

        // Fresh NextRide / EntryAndRide scenario per test. Several of these tests mint a ride and mangle its slot
        // (moving arrival into the past) without restoring it; the shared cache would carry that wreckage into the
        // next test - fatal near midnight, where the mangled ride is a future slot the resolver still picks. A rebuild
        // is fully isolated: CreateNextRideScenario generates new admission/item codes each call, so the stale slots
        // belong to an admission the fresh item never references.
        _NextRideItemNo := '';
        _EntryAndRideItemNo := '';

        // The refusal tests assume enforce mode; the observe-mode test switches it off and back on itself
        SetPrePaymentEnforcement(true);
        DrainExpiryBacklog();
        Commit();
    end;

    local procedure SetPrePaymentEnforcement(Enforce: Boolean)
    var
        FeatureFlag: Record "NPR Feature Flag";
    begin
        if (not FeatureFlag.Get('enforceTicketPrePaymentReservationCheck')) then begin
            FeatureFlag.Name := 'enforceTicketPrePaymentReservationCheck';
            FeatureFlag.Value := Format(Enforce);
            FeatureFlag.Insert();
            exit;
        end;
        FeatureFlag.Value := Format(Enforce);
        FeatureFlag.Modify();
    end;

    // The sweep caps its work per call, so leftovers from earlier tests could otherwise consume the
    // budget and starve this test's tokens out of a pass.
    local procedure DrainExpiryBacklog()
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        i: Integer;
    begin
        TicketReservationRequest.SetFilter("Request Status", '=%1|=%2', TicketReservationRequest."Request Status"::REGISTERED, TicketReservationRequest."Request Status"::EXPIRED);
        TicketReservationRequest.SetFilter("Expires Date Time", '>%1 & <%2', CreateDateTime(0D, 0T), CurrentDateTime());
        for i := 1 to 20 do begin
            if (TicketReservationRequest.IsEmpty()) then
                exit;
            RunExpiry();
        end;
    end;

    local procedure RunExpiry()
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequestManager.ExpireReservationRequests();
    end;

    local procedure CreateRegisteredToken() Token: Text[100]
    var
        Assert: Codeunit Assert;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ResponseToken: Text;
        ResponseMessage: Text;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
    begin
        Assert.IsTrue(
            TicketApiLibrary.MakeReservation(1, _ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage),
            ResponseMessage);
        Token := CopyStr(ResponseToken, 1, MaxStrLen(Token));
    end;

    // A reservation-required admission (SCHEDULE_ENTRY) reserved into tomorrow's single all-day slot, so the request
    // line carries the external schedule entry the sweep bounds the keep-alive by. Tomorrow keeps the slot clear of
    // the venue-local "already passed" sales check regardless of the test runner's time zone.
    local procedure CreateRegisteredSlotToken(var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry") Token: Text[100]
    var
        Assert: Codeunit Assert;
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ResponseToken: Text;
        ResponseMessage: Text;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
    begin
        if (_SlotItemNo = '') then
            _SlotItemNo := LibraryTicketModule.CreateScenario_ReservationRequired(1, CalcDate('<+1D>', Today()));

        TicketBom.SetFilter("Item No.", '=%1', _SlotItemNo);
        TicketBom.FindFirst();

        AdmissionScheduleEntry.Reset();
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', CalcDate('<+1D>', Today()));
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        Assert.IsTrue(AdmissionScheduleEntry.FindFirst(), 'The reservation-required scenario generated no schedule entry for tomorrow.');

        // The entry is shared by every test using this item and each test bends its times: start from a sellable slot
        AdmissionScheduleEntry."Admission End Date" := AdmissionScheduleEntry."Admission Start Date";
        AdmissionScheduleEntry."Admission End Time" := 235959T;
        AdmissionScheduleEntry."Event Arrival Until Time" := 0T;
        AdmissionScheduleEntry.Modify();
        SetSalesCutOffRaw(AdmissionScheduleEntry, 0D, 0T);
        SetEnforceSalesLimits(_SlotItemNo, TicketBom."Admission Code", false);

        Assert.IsTrue(
            TicketApiLibrary.MakeReservation(1, _SlotItemNo, 1, AdmissionScheduleEntry."External Schedule Entry No.", MemberNumber, ScannerStation, ResponseToken, ResponseMessage),
            ResponseMessage);
        Token := CopyStr(ResponseToken, 1, MaxStrLen(Token));
    end;

    // A "next ride" admission: prebook-required OCCASION with NEXT_AVAILABLE selection and 24 hourly rides on the venue-local
    // day, so a reservation without a slot is minted for the ride that is boarding right now. The minted ride lives only on
    // the ticket's reservation detail entry; the request line stays at 0.
    local procedure CreateRegisteredNextRideToken() Token: Text[100]
    begin
        if (_NextRideItemNo = '') then
            _NextRideItemNo := CreateNextRideScenario(false);
        Token := RegisterToken(_NextRideItemNo);
    end;

    // Next-ride admission plus an all-day, non-prebook entry admission on the same ticket (the demo 31050 shape)
    local procedure CreateRegisteredEntryAndRideToken() Token: Text[100]
    begin
        if (_EntryAndRideItemNo = '') then
            _EntryAndRideItemNo := CreateNextRideScenario(true);
        Token := RegisterToken(_EntryAndRideItemNo);
    end;

    local procedure RegisterToken(ItemNo: Code[20]) Token: Text[100]
    var
        Assert: Codeunit Assert;
        TicketApiLibrary: Codeunit "NPR Library - Ticket XML API";
        ResponseToken: Text;
        ResponseMessage: Text;
        MemberNumber: Code[20];
        ScannerStation: Code[10];
    begin
        Assert.IsTrue(
            TicketApiLibrary.MakeReservation(1, ItemNo, 1, MemberNumber, ScannerStation, ResponseToken, ResponseMessage),
            ResponseMessage);
        Token := CopyStr(ResponseToken, 1, MaxStrLen(Token));
    end;

    local procedure GetAdmissionCodeOfBomRow(ItemNo: Code[20]; DefaultRow: Boolean): Code[20]
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.SetFilter("Item No.", '=%1', ItemNo);
        TicketBom.SetFilter(Default, '=%1', DefaultRow);
        TicketBom.FindFirst();
        exit(TicketBom."Admission Code");
    end;

    // The slot a specific admission of the token's ticket was minted for (initial entry - the admission may not be prebook)
    local procedure GetMintedEntryForAdmission(Token: Text[100]; AdmissionCode: Code[20]; var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    var
        Assert: Codeunit Assert;
        Ticket: Record "NPR TM Ticket";
        AccessEntry: Record "NPR TM Ticket Access Entry";
        DetailedEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));
        Assert.IsTrue(Ticket.FindFirst(), 'The registered token must have minted a ticket.');
        AccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        AccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        Assert.IsTrue(AccessEntry.FindFirst(), 'The ticket must hold an access entry for admission ' + AdmissionCode);
        DetailedEntry.SetFilter("Ticket Access Entry No.", '=%1', AccessEntry."Entry No.");
        DetailedEntry.SetFilter(Quantity, '>%1', 0);
        Assert.IsTrue(DetailedEntry.FindLast(), 'The access entry must hold a detail entry.');
        AdmissionScheduleEntry.Reset();
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedEntry."External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        Assert.IsTrue(AdmissionScheduleEntry.FindFirst(), 'The minted detail entry must point at a schedule entry.');
    end;

    // One matrix row: a fresh prebook slot token, the slot shaped as given, then payability at the till and whether the
    // sweep holds or releases it. Minutes are relative to venue-local now.
    local procedure RunKeepAliveCase(CaseNo: Code[10]; ArrivalUntilInMinutes: Integer; AdmissionEndInMinutes: Integer; CutOff: Option None,Minutes,DateOnlyYesterday,BlankDate; CutOffInMinutes: Integer; EnforceLimits: Boolean; ExpectHeld: Boolean; ExpectPayable: Boolean; ExpectedReason: Text)
    var
        Assert: Codeunit Assert;
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        SalePOS: Record "NPR POS Sale";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Token: Text[100];
        ReceiptNo: Code[20];
        Context: Text;
        LocalNow: DateTime;
        GoverningInstant: DateTime;
    begin
        Context := StrSubstNo('case %1', CaseNo);
        Token := CreateRegisteredSlotToken(AdmissionScheduleEntry);
        ReceiptNo := CopyStr('EXPTEST-' + CaseNo, 1, MaxStrLen(ReceiptNo));
        StampReceiptWithOpenSale(Token, ReceiptNo);
        StampSaleLine(ReceiptNo, _SlotItemNo, 'Expiry matrix ' + CaseNo, Token);
        SalePOS.Get('EXPTEST', ReceiptNo);
        SetEnforceSalesLimits(_SlotItemNo, AdmissionScheduleEntry."Admission Code", EnforceLimits);

        // Shape the slot relative to venue-local now. The keep-alive rebuilds the closing instant as
        // CreateDateTime("Admission End Date", governing time), so the End Date must come from the SAME instant the
        // governing time does (the arrival-until when it governs, else the slot end). Deriving the date and the time
        // from different LocalNow offsets desyncs them by ~24h whenever one straddles venue-local midnight.
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(AdmissionScheduleEntry."Admission Code");
        GoverningInstant := LocalNow + (ArrivalUntilInMinutes * 60 * 1000);
        AdmissionScheduleEntry."Admission End Date" := DT2Date(GoverningInstant);
        AdmissionScheduleEntry."Admission End Time" := DT2Time(LocalNow + (AdmissionEndInMinutes * 60 * 1000));
        AdmissionScheduleEntry."Event Arrival Until Time" := DT2Time(GoverningInstant);
        if (ArrivalUntilInMinutes = AdmissionEndInMinutes) then
            AdmissionScheduleEntry."Event Arrival Until Time" := 0T; // blank arrival window: the slot end governs
        if (CutOff = CutOff::BlankDate) then begin
            // The blank-date cut-off resolves against "Admission End Date". Pin the slot to end of today so the
            // start-of-day cut-off time (set below) stays passed, instead of the End Date rolling to tomorrow -
            // and the cut-off with it - when venue-local now is near midnight.
            AdmissionScheduleEntry."Admission End Date" := DT2Date(LocalNow);
            AdmissionScheduleEntry."Admission End Time" := 235959T;
        end;
        AdmissionScheduleEntry.Modify();
        case CutOff of
            CutOff::None:
                SetSalesCutOffRaw(AdmissionScheduleEntry, 0D, 0T);
            CutOff::Minutes:
                SetSalesCutOff(AdmissionScheduleEntry, LocalNow + (CutOffInMinutes * 60 * 1000));
            CutOff::DateOnlyYesterday:
                SetSalesCutOffRaw(AdmissionScheduleEntry, CalcDate('<-1D>', DT2Date(LocalNow)), 0T);
            CutOff::BlankDate:
                // Blank date + a start-of-today time: GetSalesCutOff assumes the slot's end date (pinned to today
                // above), so the cut-off is a hair past midnight today - reliably passed regardless of the clock.
                SetSalesCutOffRaw(AdmissionScheduleEntry, 0D, 000001T);
        end;

        // Till first - the sweep would otherwise turn a released token into a plain "expired" refusal
        AgeToken(Token);
        if (ExpectPayable) then begin
            TicketManagement.CheckAndExtendTicketReservationsBeforePayment(SalePOS);
            AssertAllRowsHaveStatus(Token, 'REGISTERED', Context + ': the sale must be payable');
        end else begin
            ClearLastError();
            Assert.IsFalse(TryCheckReservationsBeforePayment(SalePOS), Context + ': the sale must be refused');
            Assert.IsTrue(StrPos(GetLastErrorText(), ExpectedReason) > 0,
                StrSubstNo('%1: refusal must state ''%2''. Got: %3', Context, ExpectedReason, GetLastErrorText()));
        end;

        // Then the sweep
        AgeToken(Token);
        RunExpiry();
        if (ExpectHeld) then
            AssertKeptAlive(Token, Context + ': the sweep must hold the token')
        else
            AssertAllRowsHaveStatus(Token, 'EXPIRED', Context + ': the sweep must release the token');

        // Leave the shared slot sellable for the next case
        AdmissionScheduleEntry."Admission End Date" := CalcDate('<+1D>', DT2Date(LocalNow));
        AdmissionScheduleEntry."Admission End Time" := 235959T;
        AdmissionScheduleEntry."Event Arrival Until Time" := 0T;
        AdmissionScheduleEntry.Modify();
        SetSalesCutOffRaw(AdmissionScheduleEntry, 0D, 0T);
        SetEnforceSalesLimits(_SlotItemNo, AdmissionScheduleEntry."Admission Code", false);
        RemoveOpenSale(ReceiptNo);
    end;

    local procedure CreateNextRideScenario(WithAllDayEntry: Boolean) ItemNo: Code[20]
    var
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        AdmissionCode: Code[20];
        EntryAdmissionCode: Code[20];
        ScheduleCode: Code[20];
        TicketTypeCode: Code[10];
        LocalDate: Date;
        StartTime: Time;
        EndTime: Time;
        i: Integer;
    begin
        TicketTypeCode := LibraryTicketModule.CreateTicketType(LibraryTicketModule.GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := LibraryTicketModule.CreateAdmissionCodeReservation(LibraryTicketModule.GenerateCode20(), Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::NEXT_AVAILABLE, '', '', '<+5D>');
        LocalDate := DT2Date(TimeHelper.GetLocalTimeAtAdmission(AdmissionCode));

        for i := 1 to 24 do begin
            StartTime := 000001T + ((i - 1) * 3600 * 1000);
            EndTime := StartTime + (3600 * 1000) - 2000;
            if (i = 24) then
                EndTime := 235959T;

            ScheduleCode := LibraryTicketModule.CreateSchedule(LibraryTicketModule.GenerateCode20(), AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, LocalDate, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, StartTime, EndTime, true, true, true, true, true, true, true, '');
            LibraryTicketModule.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, true, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0, '');
        end;

        ItemNo := LibraryTicketModule.CreateItem('', TicketTypeCode, 100);
        LibraryTicketModule.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, true, LocalDate, LocalDate);

        if (not WithAllDayEntry) then
            exit;

        // Second, non-default admission: all-day entry, no prebook, resolved as TODAY - not slot-bound at the gate
        EntryAdmissionCode := LibraryTicketModule.CreateAdmissionCode(LibraryTicketModule.GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', '');
        ScheduleCode := LibraryTicketModule.CreateSchedule(LibraryTicketModule.GenerateCode20(), AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, LocalDate, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000001T, 235959T, true, true, true, true, true, true, true, '');
        LibraryTicketModule.CreateScheduleLine(EntryAdmissionCode, ScheduleCode, 1, false, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0, '');
        LibraryTicketModule.CreateTicketBOM(ItemNo, '', EntryAdmissionCode, '', 1, false, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
        ScheduleManager.CreateAdmissionScheduleTestFramework(EntryAdmissionCode, true, LocalDate, LocalDate);
    end;

    // The ride the ticket was minted for: the reservation detail entry the gate checks at arrival.
    local procedure GetMintedScheduleEntry(Token: Text[100]; var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    var
        Assert: Codeunit Assert;
        Ticket: Record "NPR TM Ticket";
        DetailedEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', GetPrimaryEntryNo(Token));
        Assert.IsTrue(Ticket.FindFirst(), 'The registered token must have minted a ticket.');

        DetailedEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetailedEntry.SetFilter(Type, '=%1', DetailedEntry.Type::RESERVATION);
        DetailedEntry.SetFilter(Quantity, '>%1', 0);
        if (not DetailedEntry.FindLast()) then
            DetailedEntry.SetFilter(Type, '=%1', DetailedEntry.Type::INITIAL_ENTRY);
        Assert.IsTrue(DetailedEntry.FindLast(), 'The minted ticket must hold a reservation or initial detail entry.');

        AdmissionScheduleEntry.Reset();
        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedEntry."External Adm. Sch. Entry No.");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        Assert.IsTrue(AdmissionScheduleEntry.FindFirst(), 'The minted reservation must point at a schedule entry.');
    end;

    // A ticket sale line for the receipt, linked to the token's request rows the way the POS does it (Receipt No. + Line No.).
    local procedure StampSaleLine(ReceiptNo: Code[20]; ItemNo: Code[20]; LineDescription: Text; Token: Text[100])
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        SaleLinePOS.Init();
        SaleLinePOS."Register No." := 'EXPTEST';
        SaleLinePOS."Sales Ticket No." := ReceiptNo;
        SaleLinePOS.Date := Today();
        SaleLinePOS."Line No." := 10000;
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Item;
        SaleLinePOS."No." := ItemNo;
        SaleLinePOS.Quantity := 1;
        SaleLinePOS.Description := CopyStr(LineDescription, 1, MaxStrLen(SaleLinePOS.Description));
        SaleLinePOS.Insert();

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.ModifyAll("Line No.", SaleLinePOS."Line No.");
    end;

    // Sales cut-off of the slot, venue-local, configured the way operations do it: on the schedule LINE (relative date
    // formula + time) and mirrored onto the entry as the generator would - so a regeneration during the test reproduces
    // it instead of wiping it.
    local procedure SetSalesCutOff(var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; SalesCloseAt: DateTime)
    begin
        SetSalesCutOffRaw(AdmissionScheduleEntry, DT2Date(SalesCloseAt), DT2Time(SalesCloseAt));
    end;

    local procedure SetSalesCutOffRaw(var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; SalesUntilDate: Date; SalesUntilTime: Time)
    var
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        RelativeDate: DateFormula;
        DayOffsetLbl: Label '<%1D>', Locked = true;
    begin
        AdmissionScheduleEntry."Sales Until Date" := SalesUntilDate;
        AdmissionScheduleEntry."Sales Until Time" := SalesUntilTime;
        AdmissionScheduleEntry.Modify();

        if (ScheduleLine.Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code")) then begin
            Clear(RelativeDate);
            if (SalesUntilDate <> 0D) then
                Evaluate(RelativeDate, StrSubstNo(DayOffsetLbl, SalesUntilDate - AdmissionScheduleEntry."Admission End Date"));
            ScheduleLine."Sales Until Date (Rel.)" := RelativeDate;
            ScheduleLine."Sales Until Time" := SalesUntilTime;
            ScheduleLine.Modify();
        end;
    end;

    local procedure SetEnforceSalesLimits(ItemNo: Code[20]; AdmissionCode: Code[20]; Enforce: Boolean)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom."Enforce Schedule Sales Limits" := Enforce;
        TicketBom.Modify();
    end;

    // Slot times are venue-local wall clock: AdmissionEndsAt is expected in the admission's local time.
    local procedure SetSlotEnd(var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; AdmissionEndsAt: DateTime; ArrivalUntilTime: Time)
    begin
        AdmissionScheduleEntry."Admission End Date" := DT2Date(AdmissionEndsAt);
        AdmissionScheduleEntry."Admission End Time" := DT2Time(AdmissionEndsAt);
        AdmissionScheduleEntry."Event Arrival Until Time" := ArrivalUntilTime;
        AdmissionScheduleEntry.Modify();
    end;

    local procedure AgeToken(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.ModifyAll("Expires Date Time", CurrentDateTime() - 60000);
    end;

    local procedure GetPrimaryEntryNo(Token: Text[100]): Integer
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();
        exit(TicketReservationRequest."Entry No.");
    end;

    local procedure TokenRowsExist(Token: Text[100]): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        exit(not TicketReservationRequest.IsEmpty());
    end;

    local procedure AssertAllRowsHaveStatus(Token: Text[100]; StatusName: Text; Context: Text)
    var
        Assert: Codeunit Assert;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        Assert.IsFalse(TicketReservationRequest.IsEmpty(), StrSubstNo('Token rows must exist (%1).', Context));

        case StatusName of
            'REGISTERED':
                TicketReservationRequest.SetFilter("Request Status", '<>%1', TicketReservationRequest."Request Status"::REGISTERED);
            'EXPIRED':
                TicketReservationRequest.SetFilter("Request Status", '<>%1', TicketReservationRequest."Request Status"::EXPIRED);
        end;
        // Build the keep-alive diagnostic only on failure (it re-runs CanExtendReservation, the actual hold/expire decision).
        if (not TicketReservationRequest.IsEmpty()) then
            Assert.IsTrue(false, StrSubstNo('All token rows must have status %1 (%2). %3', StatusName, Context, DumpKeepAliveDecision(Token)));
    end;

    // Diagnostic: re-ask the exact predicate the sweep used (CanExtendReservation) and print its verdict + the clocks, so
    // a boundary/night failure shows WHY a token was held or expired instead of leaving us to guess.
    local procedure DumpKeepAliveDecision(Token: Text[100]) Dump: Text
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Req: Record "NPR TM Ticket Reservation Req.";
        PaymentUntil: DateTime;
        EndedSlotText: Text;
        EndedSlotClosedAt: Text;
        EndedAdmissionCode: Code[20];
        EndedScheduleEntryNo: Integer;
        HoldHasLapsed: Boolean;
        CanExtend: Boolean;
        LocalNow: DateTime;
        Lbl: Label 'DIAG canExtend=%1 holdLapsed=%2 endedAdm=%3 endedSchedEntry=%4 endedText=''%5'' closedAt=''%6''; reqExtSched=%7 reqExpires=%8; localNow=%9 currentDT=%10 today=%11', Locked = true;
    begin
        Req.SetFilter("Session Token ID", '=%1', Token);
        Req.SetFilter("Admission Created", '=%1', true);
        if (not Req.FindFirst()) then
            exit('DIAG no Admission-Created request row for token');
        LocalNow := TimeHelper.GetLocalTimeAtAdmission(Req."Admission Code");
        CanExtend := TicketRequestManager.CanExtendReservation(Token, 5 * 60 * 1000, PaymentUntil, EndedSlotText, EndedSlotClosedAt, HoldHasLapsed, EndedAdmissionCode, EndedScheduleEntryNo);
        Dump := StrSubstNo(Lbl, CanExtend, HoldHasLapsed, EndedAdmissionCode, EndedScheduleEntryNo, EndedSlotText, EndedSlotClosedAt,
            Req."External Adm. Sch. Entry No.", Req."Expires Date Time", LocalNow, CurrentDateTime(), Today());
    end;

    local procedure AssertRetentionStampBetween(Token: Text[100]; MinDT: DateTime; MaxDT: DateTime; Context: Text)
    var
        Assert: Codeunit Assert;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Expires Date Time", '<%1|>%2', MinDT, MaxDT);
        Assert.IsTrue(TicketReservationRequest.IsEmpty(), StrSubstNo('Retention stamp outside expected window: %1.', Context));
    end;

    // Runs the pre-payment check expecting it to refuse. On no error, dumps what the till saw for the receipt's
    // ticket lines so the cause is visible instead of a bare "an error was expected".
    local procedure AssertPrePaymentRefuses(SalePOS: Record "NPR POS Sale"; ExpectInText: Text; ExpectInText2: Text; Context: Text)
    var
        Assert: Codeunit Assert;
        FeatureFlagManagement: Codeunit "NPR Feature Flags Management";
        Refused: Boolean;
        ErrorText: Text;
    begin
        ClearLastError();
        Refused := not TryCheckReservationsBeforePayment(SalePOS);
        ErrorText := GetLastErrorText();
        if (not Refused) then
            Error('%1: expected a refusal but the pre-payment check passed. Flag on: %2. %3',
                Context, FeatureFlagManagement.IsEnabled('enforceTicketPrePaymentReservationCheck'), DumpReceiptTicketLines(SalePOS));
        Assert.IsTrue(StrPos(ErrorText, ExpectInText) > 0, StrSubstNo('%1: refusal must name the sale line. Got: %2', Context, ErrorText));
        if (ExpectInText2 <> '') then
            Assert.IsTrue(StrPos(ErrorText, ExpectInText2) > 0, StrSubstNo('%1: refusal must name the admission. Got: %2', Context, ErrorText));
    end;

    [TryFunction]
    local procedure TryCheckReservationsBeforePayment(SalePOS: Record "NPR POS Sale")
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TicketManagement.CheckAndExtendTicketReservationsBeforePayment(SalePOS);
    end;

    local procedure DumpReceiptTicketLines(SalePOS: Record "NPR POS Sale") Dump: Text
    var
        TicketRetailManager: Codeunit "NPR TM Ticket Retail Mgt.";
        SaleLinePOS: Record "NPR POS Sale Line";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        LineLbl: Label 'saleline %1 (type %2, item %3, qty %4, isTicket %5); ', Locked = true;
        ReqLbl: Label 'req %1 (line %2, status %3, admCreated %4, extSch %5); ', Locked = true;
    begin
        SaleLinePOS.SetFilter("Register No.", '=%1', SalePOS."Register No.");
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', SalePOS."Sales Ticket No.");
        if (SaleLinePOS.FindSet()) then
            repeat
                Dump += StrSubstNo(LineLbl, SaleLinePOS."Line No.", SaleLinePOS."Line Type", SaleLinePOS."No.", SaleLinePOS.Quantity, TicketRetailManager.IsTicketSalesLine(SaleLinePOS));
            until (SaleLinePOS.Next() = 0);

        TicketReservationRequest.SetFilter("Receipt No.", '=%1', SalePOS."Sales Ticket No.");
        if (TicketReservationRequest.FindSet()) then
            repeat
                Dump += StrSubstNo(ReqLbl, TicketReservationRequest."Entry No.", TicketReservationRequest."Line No.", TicketReservationRequest."Request Status", TicketReservationRequest."Admission Created", TicketReservationRequest."External Adm. Sch. Entry No.");
            until (TicketReservationRequest.Next() = 0);
    end;

    // Asks the predicate the till and the sweep use, with everything it looked at in the failure text
    local procedure AssertNotExtendable(Token: Text[100]; AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; Context: Text)
    var
        Assert: Codeunit Assert;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Admission: Record "NPR TM Admission";
        LiveEntry: Record "NPR TM Admis. Schedule Entry";
        PaymentUntil: DateTime;
        EndedSlotText: Text;
        EndedSlotClosedAt: Text;
        EndedAdmissionCode: Code[20];
        EndedScheduleEntryNo: Integer;
        HoldHasLapsed: Boolean;
        CanExtend: Boolean;
    begin
        CanExtend := TicketRequestManager.CanExtendReservation(Token, 0, PaymentUntil, EndedSlotText, EndedSlotClosedAt, HoldHasLapsed, EndedAdmissionCode, EndedScheduleEntryNo);
        Admission.Get(AdmissionScheduleEntry."Admission Code");
        LiveEntry.Get(AdmissionScheduleEntry."Entry No.");
        Assert.IsFalse(CanExtend, StrSubstNo('%1: expected the reservation not to be extendable. Entry %2 ends %3 %4, arrival until %5, cancelled %6, prebook %7, local now %8, ended text ''%9''.',
            Context, LiveEntry."Entry No.", LiveEntry."Admission End Date", LiveEntry."Admission End Time", LiveEntry."Event Arrival Until Time", LiveEntry.Cancelled,
            Admission."Prebook Is Required", TimeHelper.GetLocalTimeAtAdmission(Admission."Admission Code"), EndedSlotText));
    end;

    // The sweep pushes a held token a plain interval ahead (25 minutes, capped at end of day) - it does not compute
    // the instant the slot stops being sellable, it simply looks again next time.
    local procedure AssertKeptAlive(Token: Text[100]; Context: Text)
    var
        EndOfDay: DateTime;
        MinDT: DateTime;
        MaxDT: DateTime;
    begin
        AssertAllRowsHaveStatus(Token, 'REGISTERED', Context);
        EndOfDay := CreateDateTime(CalcDate('<+1D>', Today()), 0T);
        MinDT := CurrentDateTime() + (20 * 60 * 1000);
        MaxDT := CurrentDateTime() + (30 * 60 * 1000);
        if (MaxDT > EndOfDay) then
            MaxDT := EndOfDay;
        if (MinDT > EndOfDay) then
            MinDT := EndOfDay - 60000;
        AssertRetentionStampBetween(Token, MinDT, MaxDT, Context);
    end;

    local procedure StampReceiptWithOpenSale(Token: Text[100]; ReceiptNo: Code[20])
    begin
        StampReceiptWithOpenSale(Token, ReceiptNo, false);
    end;

    local procedure StampReceiptWithOpenSale(Token: Text[100]; ReceiptNo: Code[20]; Unattended: Boolean)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        SalePOS: Record "NPR POS Sale";
        RegisterNo: Code[10];
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.ModifyAll("Receipt No.", ReceiptNo);

        if (Unattended) then
            RegisterNo := 'EXPKIOSK'
        else
            RegisterNo := 'EXPTEST';
        EnsurePosUnit(RegisterNo, Unattended);

        SalePOS.SetFilter("Sales Ticket No.", '=%1', ReceiptNo);
        if (not SalePOS.IsEmpty()) then
            exit;

        SalePOS.Init();
        SalePOS."Register No." := RegisterNo;
        SalePOS."Sales Ticket No." := ReceiptNo;
        SalePOS.Insert();
    end;

    local procedure EnsurePosUnit(RegisterNo: Code[10]; Unattended: Boolean)
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if (POSUnit.Get(RegisterNo)) then
            exit;

        POSUnit.Init();
        POSUnit."No." := RegisterNo;
        if (Unattended) then
            POSUnit."POS Type" := POSUnit."POS Type"::UNATTENDED
        else
            POSUnit."POS Type" := POSUnit."POS Type"::"FULL/FIXED";
        POSUnit.Insert();
    end;

    local procedure RemoveOpenSale(ReceiptNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetFilter("Sales Ticket No.", '=%1', ReceiptNo);
        SaleLinePOS.DeleteAll();

        SalePOS.SetFilter("Sales Ticket No.", '=%1', ReceiptNo);
        SalePOS.DeleteAll();
    end;
}

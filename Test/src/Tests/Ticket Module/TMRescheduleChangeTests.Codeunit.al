codeunit 85512 "NPR TM Reschedule Change Tests"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _NpPassMode: Option Refuses,Unreachable,AcceptsPutBreaksGet,AcceptsFirstPassBreaksSecondGet;
        _NpPassRowId: Text;
        _NpPassPutCount: Integer;
        _NpPassGetCount: Integer;
        NpPassRefusalTok: Label 'NP Pass refuses the pass update', Locked = true;
        MalformedPassJsonTok: Label '{"public_url": ', Locked = true;
        ETicketMessageErr: Label '%1: the only message a change may raise is the failure text of the e-ticket update that just failed.', Locked = true;

    #region Moves
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoLineReservation_WhenChangeFirstLine_ThenMovedOnceAndChainsOnNextChange()
    var
        FirstChangeRow: Record "NPR TM Ticket Reservation Req.";
        Lib: Codeunit "NPR Library - TM Reschedule";
        WebhookSub: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
        Lines: JsonArray;
        RepeatedLines: JsonArray;
        FirstChange: JsonObject;
        RepeatedChange: JsonObject;
        StaleChange: JsonObject;
        FindAfterChange: JsonObject;
        ChainedChange: JsonObject;
        FormerSystemId: Guid;
        NewSystemId: Guid;
        ChainedSystemId: Guid;
        FirstTicket: Text;
        SecondTicket: Text;
        SecondLineTicket: Text;
        PinCode: Text;
    begin
        // [SCENARIO] A change moves the first line with both its tickets to the middle slot once and leaves the second line alone; the same request and the line's former systemId are refused afterwards, and a change of the new systemId chains on the first change.
        Initialize();

        // [GIVEN] A confirmed reservation with a line of two places and a line of one place on the early slot of the event day, every slot under Admitted control
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        PinCode := Lib.GetPin();
        FirstTicket := Lib.TicketNo(1, 1);
        SecondTicket := Lib.TicketNo(1, 2);
        SecondLineTicket := Lib.TicketNo(2, 1);
        FormerSystemId := Lib.LineSystemId(1);
        Lib.SnapshotLines();
        CapacityWebHook.ClearTouchedEntries();
        BindSubscription(WebhookSub);

        // [WHEN] The guest changes the first line to the middle slot
        Lib.AddChangeLine(Lines, FormerSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        FirstChange := Lib.Change(Lines);
        UnbindSubscription(WebhookSub);

        // [THEN] HTTP 200 with one result line of quantity 2 under a new systemId, its only admission on the middle slot of the event day
        Lib.AssertStatus(FirstChange, 200, 'S7.a: Change of the first line to the middle slot');
        Lib.AssertChangedLineCount(FirstChange, 1, 'S7.a: Change of the first line to the middle slot');
        Lib.AssertChangedAdmissionCount(FirstChange, 1, 1, 'S7.a: Change of the first line to the middle slot');

        // [THEN] Stored: one CONFIRMED CHANGE row superseding the unchanged row of the first line, both tickets relinked to it, each moved with a new initial entry that keeps the payment link and a reversal on the early slot
        NewSystemId := Lib.AssertLineMoved(FirstChange, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S7.a: Change of the first line to the middle slot');

        // [THEN] The second line and its ticket are untouched, and the capacity webhook stayed silent because the slots are under Admitted control
        Lib.AssertLineUntouched(2, 'S7.a: Change of the first line to the middle slot');
        Assert.AreEqual(0, WebhookSub.EventCount(), 'S7.a: A change between slots under Admitted control must not emit a capacity webhook event.');

        // [THEN] The body contains none of the pin, the address, the holder name and the three ticket numbers
        Lib.AssertBodyOmits(FirstChange, PinCode, 'pin', 'S17.b: Change of the first line for the leak check');
        Lib.AssertBodyOmits(FirstChange, Lib.NotificationAddress(), 'notification address', 'S17.b: Change of the first line for the leak check');
        Lib.AssertBodyOmits(FirstChange, Lib.TicketHolderName(), 'ticket holder name', 'S17.b: Change of the first line for the leak check');
        Lib.AssertBodyOmits(FirstChange, FirstTicket, 'first ticket number of the first line', 'S17.b: Change of the first line for the leak check');
        Lib.AssertBodyOmits(FirstChange, SecondTicket, 'second ticket number of the first line', 'S17.b: Change of the first line for the leak check');
        Lib.AssertBodyOmits(FirstChange, SecondLineTicket, 'ticket number of the second line', 'S17.b: Change of the first line for the leak check');

        // [WHEN] The guest sends the same request again
        Lib.MarkStoredState();
        Lib.AddChangeLine(RepeatedLines, FormerSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        RepeatedChange := Lib.Change(RepeatedLines);

        // [THEN] HTTP 400 invalid_reference naming the former systemId and the admission; nothing is stored and the first line stays on the middle slot once
        Lib.AssertInvalidReference(RepeatedChange, FormerSystemId, Lib.GetAdmissionCode(), 'S14.b: The same change request sent a second time');
        Lib.AssertNothingStoredSinceMark('S14.b: The same change request sent a second time');
        Lib.AssertLineOnSlot(1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S14.b: The same change request sent a second time');

        // [WHEN] The guest changes the first line by its former systemId to the late slot
        StaleChange := Lib.ChangeLine(FormerSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));

        // [THEN] HTTP 400 invalid_reference naming the former systemId and the admission; nothing is stored and the first line stays on the middle slot
        Lib.AssertInvalidReference(StaleChange, FormerSystemId, Lib.GetAdmissionCode(), 'S14.a: Change by the former systemId of the first line to the late slot');
        Lib.AssertNothingStoredSinceMark('S14.a: Change by the former systemId of the first line to the late slot');
        Lib.AssertLineOnSlot(1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S14.a: Change by the former systemId of the first line to the late slot');

        // [WHEN] The guest calls find with the first ticket and the pin
        FindAfterChange := Lib.FindByTicketNumber(FirstTicket, PinCode);

        // [THEN] The first line has the middle slot and the second line the early slot as current slot
        Lib.AssertStatus(FindAfterChange, 200, 'S7.c: Find by the first ticket after the change');
        Lib.AssertCurrentSchedule(FindAfterChange, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S7.c: Find by the first ticket after the change');
        Lib.AssertCurrentSchedule(FindAfterChange, 2, Lib.GetAdmissionCode(), Lib.SlotNo(1), 'S7.c: Find by the first ticket after the change');

        // [WHEN] The guest changes the first line by its new systemId to the late slot
        Assert.IsTrue(FirstChangeRow.GetBySystemId(NewSystemId), 'S7.d: Setup: the first change must have stored the row of its new systemId.');
        ChainedChange := Lib.ChangeLine(NewSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));

        // [THEN] HTTP 200; the newest CHANGE row supersedes the first CHANGE row and both tickets stand on the late slot, linked to the newest row
        Lib.AssertStatus(ChainedChange, 200, 'S7.d: Second change of the first line by its new systemId');
        ChainedSystemId := Lib.AssertChangedLine(ChainedChange, 1, NewSystemId, 2, 'S7.d: Second change of the first line by its new systemId');
        Lib.AssertChangedAdmission(ChainedChange, 1, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'S7.d: Second change of the first line by its new systemId');
        Lib.AssertChangeRows(ChainedSystemId, FirstChangeRow, 1, 'S7.d: Second change of the first line by its new systemId');
        Lib.AssertTicketOnRow(FirstTicket, ChainedSystemId, 'S7.d: Second change of the first line by its new systemId');
        Lib.AssertTicketOnRow(SecondTicket, ChainedSystemId, 'S7.d: Second change of the first line by its new systemId');
        Lib.AssertTicketOnSlot(FirstTicket, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'S7.d: Second change of the first line by its new systemId');
        Lib.AssertTicketOnSlot(SecondTicket, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'S7.d: Second change of the first line by its new systemId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoLines_WhenChangeBothInOneCall_ThenBothMoved()
    var
        FirstLineRow: Record "NPR TM Ticket Reservation Req.";
        SecondLineRow: Record "NPR TM Ticket Reservation Req.";
        Lib: Codeunit "NPR Library - TM Reschedule";
        ConfirmSub: Codeunit "NPR TM Change Confirm Sub";
        Assert: Codeunit Assert;
        Lines: JsonArray;
        Response: JsonObject;
    begin
        // [SCENARIO] One call moves the first line to the middle slot and the second line to the late slot, and both lines are moved and confirmed before the confirm event of the first line fires.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot and a subscriber that records, at the first confirm event of a change request, which of the three tickets already stand on their target slot and how many of the two lines already have a CONFIRMED change row
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SnapshotLines();
        Lib.GetSnapshotRow(1, FirstLineRow);
        Lib.GetSnapshotRow(2, SecondLineRow);
        ConfirmSub.WatchTicket(Lib.TicketNo(1, 1), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        ConfirmSub.WatchTicket(Lib.TicketNo(1, 2), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        ConfirmSub.WatchTicket(Lib.TicketNo(2, 1), Lib.GetAdmissionCode(), Lib.SlotNo(3));
        ConfirmSub.WatchLineRow(FirstLineRow."Entry No.");
        ConfirmSub.WatchLineRow(SecondLineRow."Entry No.");
        BindSubscription(ConfirmSub);

        // [WHEN] The guest changes the first line to the middle slot and the second line to the late slot in one call
        Lib.AddChangeLine(Lines, FirstLineRow.SystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(Lines, SecondLineRow.SystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));
        Response := Lib.Change(Lines);
        UnbindSubscription(ConfirmSub);

        // [THEN] HTTP 200 with two result lines in request order, and both lines moved
        Lib.AssertStatus(Response, 200, 'S7.b: Change of both lines in one call');
        Lib.AssertChangedLineCount(Response, 2, 'S7.b: Change of both lines in one call');
        Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S7.b: Change of both lines in one call, first line');
        Lib.AssertLineMoved(Response, 2, 2, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'S7.b: Change of both lines in one call, second line');

        // [THEN] One confirm event per line, and when the first fired all three tickets were already moved and both lines already confirmed
        Assert.AreEqual(2, ConfirmSub.CallCount(), 'S7.b: The change of two lines must raise one confirm event per line.');
        Assert.AreEqual(3, ConfirmSub.TicketsOnTargetAtFirstCall(), 'S7.b: Every ticket of both lines must stand on its new slot before the first confirm event fires.');
        Assert.AreEqual(2, ConfirmSub.ConfirmedChangeRowsAtFirstCall(), 'S7.b: Both lines must have their CONFIRMED change row before the first confirm event fires.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSalesSlotsWithNotifyThreshold_WhenChange_ThenWebhookEmitsBothSnapshots()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        WebhookSub: Codeunit "NPR TM Capacity WebhookSub";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
        Assert: Codeunit Assert;
        Response: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] When both slots of a move are under Sales control with a notify threshold, the change emits one remaining-capacity snapshot for the new slot and one for the old slot, as a back-office change does.
        Initialize();

        // [GIVEN] The early and middle slots under Sales control with capacity 10 and notify threshold 10, and a confirmed two-line reservation of 3 places on the early slot
        Lib.CreateEventScenario();
        Lib.SetSlotSalesCapacity(1, 10);
        Lib.SetSlotSalesCapacity(2, 10);
        Lib.SetSlotNotifyThreshold(1, 10);
        Lib.SetSlotNotifyThreshold(2, 10);
        Lib.CreateTwoLineReservation(1, 1);
        FirstLineSystemId := Lib.LineSystemId(1);
        CapacityWebHook.ClearTouchedEntries();
        BindSubscription(WebhookSub);

        // [WHEN] The guest changes the first line of 2 places to the middle slot
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        UnbindSubscription(WebhookSub);

        // [THEN] HTTP 200, one snapshot for the middle slot with 8 places left and one for the early slot with 9 left, and no other event
        Lib.AssertStatus(Response, 200, 'S7.f: Change between Sales slots with a notify threshold');
        Assert.AreEqual(1, WebhookSub.EventCountFor(Lib.SlotNo(2)), 'S7.f: The change must emit exactly one capacity snapshot for the middle slot.');
        Assert.AreEqual(8, WebhookSub.RemainingCapacityFor(Lib.SlotNo(2)), 'S7.f: The snapshot of the middle slot must report 8 places left (10 minus the 2 moved in).');
        Assert.AreEqual(1, WebhookSub.EventCountFor(Lib.SlotNo(1)), 'S7.f: The change must emit exactly one capacity snapshot for the early slot.');
        Assert.AreEqual(9, WebhookSub.RemainingCapacityFor(Lib.SlotNo(1)), 'S7.f: The snapshot of the early slot must report 9 places left, because the second line stays on it.');
        Assert.AreEqual(2, WebhookSub.EventCount(), 'S7.f: The change must emit the two snapshots of the old and the new slot and nothing else.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSalesSlot_WhenTwoLinesMoveIntoIt_ThenCapacityExceededAtTwoAndBothFitAtThree()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        RefusedLines: JsonArray;
        RetryLines: JsonArray;
        RefusedResponse: JsonObject;
        RetryResponse: JsonObject;
        FirstLineSystemId: Guid;
        SecondLineSystemId: Guid;
    begin
        // [SCENARIO] Two lines of 2 and 1 places moving into a Sales slot of capacity 2 are refused at the second line and nothing moves; with capacity 3 the same request moves both.
        Initialize();

        // [GIVEN] A confirmed two-line reservation of 3 places on the early slot and the middle slot under Sales control with capacity 2 and nothing sold
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetSlotSalesCapacity(2, 2);
        FirstLineSystemId := Lib.LineSystemId(1);
        SecondLineSystemId := Lib.LineSystemId(2);
        Lib.SnapshotLines();
        Lib.MarkStoredState();

        // [WHEN] The guest changes both lines to the middle slot in one call
        Lib.AddChangeLine(RefusedLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(RefusedLines, SecondLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        RefusedResponse := Lib.Change(RefusedLines);

        // [THEN] HTTP 400 capacity_exceeded naming the second line and the admission, and nothing moves, not even the first line that fits alone
        Lib.AssertCapacityExceeded(RefusedResponse, SecondLineSystemId, Lib.GetAdmissionCode(), 'S8.a: Change of 3 places into a Sales slot of capacity 2');
        Lib.AssertNothingStoredSinceMark('S8.a: Change of 3 places into a Sales slot of capacity 2');

        // [GIVEN] The capacity of the middle slot raised to 3
        Lib.SetSlotSalesCapacity(2, 3);

        // [WHEN] The guest sends the same request
        Lib.AddChangeLine(RetryLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(RetryLines, SecondLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        RetryResponse := Lib.Change(RetryLines);

        // [THEN] HTTP 200 and both lines moved to the middle slot
        Lib.AssertStatus(RetryResponse, 200, 'S7.e: Change of 3 places into a Sales slot of capacity 3');
        Lib.AssertChangedLineCount(RetryResponse, 2, 'S7.e: Change of 3 places into a Sales slot of capacity 3');
        Lib.AssertLineMoved(RetryResponse, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S7.e: Change of 3 places into a Sales slot of capacity 3, first line');
        Lib.AssertLineMoved(RetryResponse, 2, 2, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S7.e: Change of 3 places into a Sales slot of capacity 3, second line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTicketOfTwoPlacesLeavingFullSalesSlot_WhenOtherLineMovesInInSameCall_ThenBothMoved()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        ReserveLines: JsonArray;
        ChangeLines: JsonArray;
        Response: JsonObject;
        OnePlaceItemNo: Code[20];
    begin
        // [SCENARIO] One call moves a line of one ticket that holds 2 places out of a full Sales slot and then a line of two one-place tickets of another item into it, and both lines move because the 2 places freed first cover the 2 taken.
        Initialize();

        // [GIVEN] The scenario item with 2 places per ticket and another item with 1 place per ticket on the same admission; a confirmed reservation of a line of one ticket of the scenario item on the middle slot and a line of two tickets of the other item on the early slot; 4 tickets of the scenario item sold on the middle slot by another sale; the middle slot under Sales control with capacity 10, which its 10 places sold fill
        Lib.CreateEventScenario();
        Lib.SetBomQuantity(2);
        OnePlaceItemNo := Lib.CreateItemOnAdmission(1);
        Lib.AddReserveLineTo(ReserveLines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddReserveLineTo(ReserveLines, OnePlaceItemNo, 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(ReserveLines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.SellPlaces(2, 4);
        Lib.SetSlotSalesCapacity(2, 10);
        Assert.AreEqual(10, Lib.PlacesSoldOnSlot(2), 'F3.a: Setup: the middle slot must count 10 places sold, 2 of them held by the ticket of the first line.');
        Lib.SnapshotLines();

        // [WHEN] The guest changes, in one call, the first line to the late slot and the second line to the middle slot
        Lib.AddChangeLine(ChangeLines, Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(3));
        Lib.AddChangeLine(ChangeLines, Lib.LineSystemId(2), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Response := Lib.Change(ChangeLines);

        // [THEN] HTTP 200 with two result lines; the first line moved to the late slot and the second line to the middle slot
        Lib.AssertStatus(Response, 200, 'F3.a: Change of a 2-place ticket out of a full Sales slot and two 1-place tickets into it in one call');
        Lib.AssertChangedLineCount(Response, 2, 'F3.a: Change of a 2-place ticket out of a full Sales slot and two 1-place tickets into it in one call');
        Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'F3.a: Change of a 2-place ticket out of a full Sales slot and two 1-place tickets into it in one call, first line');
        Lib.AssertChangedAdmission(Response, 2, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F3.a: Change of a 2-place ticket out of a full Sales slot and two 1-place tickets into it in one call, second line');
        Lib.AssertLineOnSlot(2, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F3.a: Change of a 2-place ticket out of a full Sales slot and two 1-place tickets into it in one call, second line');
    end;
    #endregion

    #region Refusals
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPolicyNotAllowed_WhenChange_ThenNotAllowed()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] A reservation where no admission can move because the policy is Not Allowed is refused as not allowed naming the line, the admission and the reason NOT_ALLOWED, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose item has the reschedule policy Not Allowed
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetPolicy(TicketBom."Reschedule Policy"::NOT_ALLOWED, 0);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 reschedule_not_allowed naming the first line, the admission and the reason NOT_ALLOWED, and nothing moves
        Lib.AssertNotAllowed(Response, FirstLineSystemId, Lib.GetAdmissionCode(), 'NOT_ALLOWED', 'F7: S8.b: Change when the policy does not allow a move');
        Lib.AssertNothingStoredSinceMark('F7: S8.b: Change when the policy does not allow a move');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOneTicketOfFirstLineAdmitted_WhenChangeIt_ThenNotAllowed()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] A line with one admitted ticket cannot move, so its change is refused as not allowed while the other line could still move, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first ticket of the first line was admitted and the second was not
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.MarkAdmitted(Lib.TicketNo(1, 1));
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 reschedule_not_allowed naming the first line, the admission and the reason ALREADY_ADMITTED, and nothing moves
        Lib.AssertNotAllowed(Response, FirstLineSystemId, Lib.GetAdmissionCode(), 'ALREADY_ADMITTED', 'F7: S8.c: Change of a line with one admitted ticket');
        Lib.AssertNothingStoredSinceMark('F7: S8.c: Change of a line with one admitted ticket');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSecondLineAdmitted_WhenChangeBoth_ThenNotAllowedNamingSecondLine()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Lines: JsonArray;
        Response: JsonObject;
        FirstLineSystemId: Guid;
        SecondLineSystemId: Guid;
    begin
        // [SCENARIO] When the second of two requested lines has an admitted ticket, the request is refused naming the second line, and the first line does not move either.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose ticket of the second line was admitted
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.MarkAdmitted(Lib.TicketNo(2, 1));
        FirstLineSystemId := Lib.LineSystemId(1);
        SecondLineSystemId := Lib.LineSystemId(2);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot and the second line to the late slot in one call
        Lib.AddChangeLine(Lines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(Lines, SecondLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));
        Response := Lib.Change(Lines);

        // [THEN] HTTP 400 reschedule_not_allowed naming the second line, the admission and the reason ALREADY_ADMITTED, and nothing moves
        Lib.AssertNotAllowed(Response, SecondLineSystemId, Lib.GetAdmissionCode(), 'ALREADY_ADMITTED', 'F7: S8.k: Change of both lines with the ticket of the second line admitted');
        Lib.AssertNothingStoredSinceMark('F7: S8.k: Change of both lines with the ticket of the second line admitted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenInvalidTargets_WhenChange_ThenInvalidReferenceAndNothingMoves()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        OtherReservation: Codeunit "NPR Library - TM Reschedule";
        FindBeforeCancel: JsonObject;
        OtherAdmissionSlotResponse: JsonObject;
        AfterValidityResponse: JsonObject;
        UnknownSlotResponse: JsonObject;
        UnheldAdmissionResponse: JsonObject;
        OtherReservationLineResponse: JsonObject;
        WaitingListResponse: JsonObject;
        CancelledSlotResponse: JsonObject;
        FirstLineSystemId: Guid;
        AfterValiditySlotNo: Integer;
        WaitingListSlotIndex: Integer;
    begin
        // [SCENARIO] A change to a slot of another admission, after the ticket validity, unknown, on a waiting list or cancelled after find, for an admission the line does not hold, or of a line of another reservation, is refused as an invalid reference naming the requested line and admission, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed two-line reservation of another item; a confirmed two-line reservation on the early slot valid through today plus 7 days; copies of the middle slot on today plus 8 days and, on a waiting list, on the day after the event day; the guest's find offering the middle slot; the middle slot then cancelled
        OtherReservation.CreateEventScenario();
        OtherReservation.CreateTwoLineReservation(1, 1);
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstLineSystemId := Lib.LineSystemId(1);
        AfterValiditySlotNo := Lib.CopySlotToDate(2, Today() + 8);
        WaitingListSlotIndex := Lib.AddSlotCopy(2, Lib.GetEventDate() + 1);
        Lib.PutSlotOnWaitingList(WaitingListSlotIndex);
        FindBeforeCancel := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());
        Lib.AssertAdmission(FindBeforeCancel, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S8.j: Setup: the find before the cancellation must offer the middle and late slots');
        Lib.CancelSlot(2);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot of another admission
        OtherAdmissionSlotResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), OtherReservation.SlotNo(2));

        // [THEN] HTTP 400 invalid_reference naming the first line and the admission, and nothing moves
        Lib.AssertInvalidReference(OtherAdmissionSlotResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'S8.d: Change to a slot of another admission');
        Lib.AssertNothingStoredSinceMark('S8.d: Change to a slot of another admission');

        // [WHEN] The guest changes the first line to the copy of the middle slot on today plus 8 days
        AfterValidityResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), AfterValiditySlotNo);

        // [THEN] HTTP 400 invalid_reference naming the first line and the admission, and nothing moves
        Lib.AssertInvalidReference(AfterValidityResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'S8.e: Change to a slot after the ticket validity');
        Lib.AssertNothingStoredSinceMark('S8.e: Change to a slot after the ticket validity');

        // [WHEN] The guest changes the first line to the unknown schedule id 999999
        UnknownSlotResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), 999999);

        // [THEN] HTTP 400 invalid_reference naming the first line and the admission, and nothing moves
        Lib.AssertInvalidReference(UnknownSlotResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'S8.f: Change to the unknown schedule id 999999');
        Lib.AssertNothingStoredSinceMark('S8.f: Change to the unknown schedule id 999999');

        // [WHEN] The guest changes the admission OTHER, which the tickets of the first line do not hold, to the late slot
        UnheldAdmissionResponse := Lib.ChangeLine(FirstLineSystemId, 'OTHER', Lib.SlotNo(3));

        // [THEN] HTTP 400 invalid_reference naming the first line and the admission OTHER, and nothing moves
        Lib.AssertInvalidReference(UnheldAdmissionResponse, FirstLineSystemId, 'OTHER', 'S8.g: Change of an admission the line does not hold');
        Lib.AssertNothingStoredSinceMark('S8.g: Change of an admission the line does not hold');

        // [WHEN] The guest changes, under the token of this reservation, the first line of the other reservation to the late slot
        OtherReservationLineResponse := Lib.ChangeLine(OtherReservation.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(3));

        // [THEN] HTTP 400 invalid_reference naming the line of the other reservation and the admission, and nothing moves in either reservation
        Lib.AssertInvalidReference(OtherReservationLineResponse, OtherReservation.LineSystemId(1), Lib.GetAdmissionCode(), 'S8.h: Change of a line of another reservation');
        Lib.AssertNothingStoredSinceMark('S8.h: Change of a line of another reservation');

        // [WHEN] The guest changes the first line to the slot on the waiting list
        WaitingListResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(WaitingListSlotIndex));

        // [THEN] HTTP 400 invalid_reference naming the first line and the admission, and nothing moves
        Lib.AssertInvalidReference(WaitingListResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'S8.i: Change to a slot on a waiting list');
        Lib.AssertNothingStoredSinceMark('S8.i: Change to a slot on a waiting list');

        // [WHEN] The guest changes the first line to the middle slot that was cancelled after the find
        CancelledSlotResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 invalid_reference naming the first line and the admission, and nothing moves
        Lib.AssertInvalidReference(CancelledSlotResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'S8.j: Change to the middle slot cancelled between find and change');
        Lib.AssertNothingStoredSinceMark('S8.j: Change to the middle slot cancelled between find and change');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenCurrentSlotCancelled_WhenChange_ThenNotAllowed()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] A line whose current slot is cancelled cannot move away from it, so its change is refused as not allowed, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed reservation with the first line on the early slot and the second on the late slot; the early slot is then cancelled
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 3);
        Lib.CancelSlot(1);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 reschedule_not_allowed naming the first line, the admission and the reason SLOT_CANCELLED, and nothing moves
        Lib.AssertNotAllowed(Response, FirstLineSystemId, Lib.GetAdmissionCode(), 'SLOT_CANCELLED', 'F7: S8.l: Change of a line whose current slot is cancelled');
        Lib.AssertNothingStoredSinceMark('F7: S8.l: Change of a line whose current slot is cancelled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOccasionSlotWithOnePlaceLeft_WhenChangeTwoPlaces_ThenCapacityExceeded()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        ChangeResponse: JsonObject;
        FindResponse: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] An occasion slot under Admitted control with capacity 1000 and 999 open reservations accepts one more place, so a line of 2 places is refused for capacity, nothing moves, and find offers that slot only to a line of one place.
        Initialize();

        // [GIVEN] A confirmed two-line reservation of 2 and 1 places on the early slot, and 999 open reservations on the middle slot, held by one group ticket of another sale
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SellPlacesOnOneTicket(2, 999);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line of 2 places to the middle slot
        ChangeResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 capacity_exceeded naming the first line and the admission, and nothing moves
        Lib.AssertCapacityExceeded(ChangeResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'S8.m: Change of 2 places into an occasion slot with 1 place left');
        Lib.AssertNothingStoredSinceMark('S8.m: Change of 2 places into an occasion slot with 1 place left');

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        FindResponse := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line is offered only the late slot, and the second line of one place sees the middle slot with remaining capacity 1
        Lib.AssertStatus(FindResponse, 200, 'S8.m: Find with 1 place left on the middle occasion slot');
        Lib.AssertAdmission(FindResponse, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(3)), 'S8.m: Find with 1 place left on the middle occasion slot');
        Lib.AssertSlotCapacity(FindResponse, 2, Lib.SlotNo(2), 1, 'S8.m: Find with 1 place left on the middle occasion slot');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSalesGroupWithOnePlaceLeft_WhenChange_ThenCapacityExceeded()
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        ChangeResponse: JsonObject;
        FindResponse: JsonObject;
        FirstLineSystemId: Guid;
        GroupCode: Code[20];
    begin
        // [SCENARIO] A Sales slot in a Sales concurrency group of limit 10 with 9 places in use on the event day by other lines has room for 1 place, so a line of 2 places is refused for capacity, nothing moves, and find does not offer the slot either.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot; the middle slot under Sales control with capacity 1000 and alone in a concurrency group by concurrency code with Sales control and limit 10; 9 places sold on the middle slot by another sale
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetSlotSalesCapacity(2, 1000);
        GroupCode := Lib.CreateConcurrencyGroup(10, GroupSetup."Capacity Control"::SALES, GroupSetup."Concurrency Type"::CONCURRENCY_CODE);
        Lib.JoinConcurrencyGroup(2, GroupCode);
        Lib.SellPlaces(2, 9);
        Assert.AreEqual(9, Lib.GroupPlacesInUseOnEventDate(2), 'S8.n: Setup: the concurrency group must count 9 places in use on the event day.');
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line of 2 places to the middle slot
        ChangeResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 capacity_exceeded naming the first line and the admission, and nothing moves
        Lib.AssertCapacityExceeded(ChangeResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'S8.n: Change of 2 places into a Sales group with 1 place left');
        Lib.AssertNothingStoredSinceMark('S8.n: Change of 2 places into a Sales group with 1 place left');

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        FindResponse := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line is offered only the late slot, which is outside the group
        Lib.AssertStatus(FindResponse, 200, 'S8.n: Find with 1 place left in the Sales group of the middle slot');
        Lib.AssertAdmission(FindResponse, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(3)), 'S8.n: Find with 1 place left in the Sales group of the middle slot');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSalesGroupWithTwoLeft_WhenTwoLinesMoveIntoIt_ThenCapacityExceededNamingSecondLine()
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        Lines: JsonArray;
        Response: JsonObject;
        FirstLineSystemId: Guid;
        SecondLineSystemId: Guid;
        GroupCode: Code[20];
    begin
        // [SCENARIO] Two lines of 2 and 1 places moving into two slots of one Sales concurrency group with 2 places left are refused at the second line, counting the first line's move as made, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot; the middle and late slots under Sales control with capacity 1000 in one concurrency group by concurrency code with Sales control and limit 10; 8 places sold on the middle slot by another sale
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetSlotSalesCapacity(2, 1000);
        Lib.SetSlotSalesCapacity(3, 1000);
        GroupCode := Lib.CreateConcurrencyGroup(10, GroupSetup."Capacity Control"::SALES, GroupSetup."Concurrency Type"::CONCURRENCY_CODE);
        Lib.JoinConcurrencyGroup(2, GroupCode);
        Lib.JoinConcurrencyGroup(3, GroupCode);
        Lib.SellPlaces(2, 8);
        Assert.AreEqual(8, Lib.GroupPlacesInUseOnEventDate(2), 'S8.o: Setup: the concurrency group must count 8 places in use on the event day.');
        FirstLineSystemId := Lib.LineSystemId(1);
        SecondLineSystemId := Lib.LineSystemId(2);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot and the second line to the late slot in one call
        Lib.AddChangeLine(Lines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(Lines, SecondLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));
        Response := Lib.Change(Lines);

        // [THEN] HTTP 400 capacity_exceeded naming the second line and the admission, and nothing moves, not even the first line
        Lib.AssertCapacityExceeded(Response, SecondLineSystemId, Lib.GetAdmissionCode(), 'S8.o: Change of 3 places into a Sales group with 2 places left');
        Lib.AssertNothingStoredSinceMark('S8.o: Change of 3 places into a Sales group with 2 places left');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoAdmissionsMovingIntoOneGroup_WhenChange_ThenCapacityExceededNamingSecondAdmission()
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        Lib: Codeunit "NPR Library - TM Reschedule";
        SecondAdmission: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        ReserveLines: JsonArray;
        ChangeLines: JsonArray;
        Response: JsonObject;
        FirstLineSystemId: Guid;
        GroupCode: Code[20];
    begin
        // [SCENARIO] A line of 2 places moving both its admissions into Sales slots of one Sales concurrency group with 3 places left fits for the first admission and is refused for capacity at the second, and nothing moves.
        Initialize();

        // [GIVEN] An item with a second admission; the middle slots of both admissions under Sales control with capacity 1000 in one concurrency group by concurrency code with Sales control and limit 10; 7 places of the second admission sold on its middle slot by another sale; a confirmed reservation of one line of 2 places on the early slots of both admissions
        Lib.CreateEventScenario();
        SecondAdmission.CreateEventScenario();
        Lib.AddAdmission(SecondAdmission.GetAdmissionCode(), false);
        Lib.SetSlotSalesCapacity(2, 1000);
        SecondAdmission.SetSlotSalesCapacity(2, 1000);
        GroupCode := Lib.CreateConcurrencyGroup(10, GroupSetup."Capacity Control"::SALES, GroupSetup."Concurrency Type"::CONCURRENCY_CODE);
        Lib.JoinConcurrencyGroup(2, GroupCode);
        SecondAdmission.JoinConcurrencyGroup(2, GroupCode);
        SecondAdmission.SellPlaces(2, 7);
        Assert.AreEqual(7, Lib.GroupPlacesInUseOnEventDate(2), 'S8.p: Setup: the concurrency group must count 7 places in use on the event day.');
        Lib.AddReserveLineTo(ReserveLines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddAdmissionToLastReserveLine(ReserveLines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1));
        Lib.CreateReservation(ReserveLines);
        Lib.ConfirmReservation(Lib.GetToken());
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();

        // [WHEN] The guest moves both admissions of the line into their middle slots in one call
        Lib.AddChangeLine(ChangeLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddAdmissionToLastChangeLine(ChangeLines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(2));
        Response := Lib.Change(ChangeLines);

        // [THEN] HTTP 400 capacity_exceeded naming the line and the second admission, and nothing moves
        Lib.AssertCapacityExceeded(Response, FirstLineSystemId, SecondAdmission.GetAdmissionCode(), 'S8.p: Change of both admissions of a line into one Sales group with 3 places left');
        Lib.AssertNothingStoredSinceMark('S8.p: Change of both admissions of a line into one Sales group with 3 places left');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenAdmittedCountingGroupFull_WhenChangeUnadmittedLine_ThenMoved()
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        FindResponse: JsonObject;
        ChangeResponse: JsonObject;
        GroupCode: Code[20];
    begin
        // [SCENARIO] A concurrency group that counts admitted places counts nothing for tickets that are not admitted, so a line moves into a Sales slot of that group with 9 of 10 places admitted, and find offers the slot bounded only by its own capacity.
        Initialize();

        // [GIVEN] The middle slot under Sales control with capacity 1000 and nothing sold; the middle and late slots in a concurrency group by concurrency code with Admitted control and limit 10; 9 places admitted on the late slot; a confirmed two-line reservation on the early slot whose tickets are not admitted
        Lib.CreateEventScenario();
        Lib.SetSlotSalesCapacity(2, 1000);
        GroupCode := Lib.CreateConcurrencyGroup(10, GroupSetup."Capacity Control"::ADMITTED, GroupSetup."Concurrency Type"::CONCURRENCY_CODE);
        Lib.JoinConcurrencyGroup(2, GroupCode);
        Lib.JoinConcurrencyGroup(3, GroupCode);
        Lib.RecordAdmittedPlaces(3, 9);
        Assert.AreEqual(9, Lib.GroupPlacesInUseOnEventDate(2), 'S8.q: Setup: the Admitted concurrency group must count 9 admitted places on the event day.');
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SnapshotLines();

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        FindResponse := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The middle slot is offered to the first line with remaining capacity 1000
        Lib.AssertStatus(FindResponse, 200, 'S8.q: Find with 9 of 10 places admitted in the Admitted group of the middle slot');
        Lib.AssertSlotCapacity(FindResponse, 1, Lib.SlotNo(2), 1000, 'S8.q: Find with 9 of 10 places admitted in the Admitted group of the middle slot');

        // [WHEN] The guest changes the first line of 2 places to the middle slot
        ChangeResponse := Lib.ChangeLine(Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200 and the first line moved to the middle slot
        Lib.AssertStatus(ChangeResponse, 200, 'S8.q: Change into the Admitted group with 9 of 10 places admitted');
        Lib.AssertLineMoved(ChangeResponse, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S8.q: Change into the Admitted group with 9 of 10 places admitted');
    end;
    #endregion

    #region Identity and input
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenWrongPinUnknownTokenOrTicketNumber_WhenChange_ThenUniformNotFoundOrInvalidInput()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        WrongPinLines: JsonArray;
        UnknownTokenLines: JsonArray;
        TicketNumberLines: JsonArray;
        TicketNumberBody: JsonObject;
        WrongPinResponse: JsonObject;
        UnknownTokenResponse: JsonObject;
        TicketNumberResponse: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] A change with a wrong pin or an unknown token gets the uniform not-found error for a token, a change identified by a ticket number instead of a token is invalid input, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot with the original token and the pin with its last character changed
        Lib.AddChangeLine(WrongPinLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        WrongPinResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), Lib.WrongPin(), WrongPinLines));

        // [THEN] HTTP 404 resource_not_found with the reservation token message, and nothing moves
        Lib.AssertUniformNotFound(WrongPinResponse, Lib.TokenNotFoundMessage(), 'S9.a: Change with the original token and a wrong pin');
        Lib.AssertNothingStoredSinceMark('S9.a: Change with the original token and a wrong pin');

        // [WHEN] The guest changes the first line to the middle slot with a token of 32 zeros and the pin
        Lib.AddChangeLine(UnknownTokenLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        UnknownTokenResponse := Lib.CallChange(Lib.ChangeBody('00000000000000000000000000000000', Lib.GetPin(), UnknownTokenLines));

        // [THEN] HTTP 404 resource_not_found with the reservation token message, and nothing moves
        Lib.AssertUniformNotFound(UnknownTokenResponse, Lib.TokenNotFoundMessage(), 'S9.b: Change with a token of 32 zeros');
        Lib.AssertNothingStoredSinceMark('S9.b: Change with a token of 32 zeros');

        // [WHEN] The guest changes the first line to the middle slot with the first ticket number and the pin instead of a token
        Lib.AddChangeLine(TicketNumberLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        TicketNumberBody.Add('ticketNumber', Lib.TicketNo(1, 1));
        TicketNumberBody.Add('pinCode', Lib.GetPin());
        TicketNumberBody.Add('reservationLines', TicketNumberLines);
        TicketNumberResponse := Lib.CallChange(TicketNumberBody);

        // [THEN] HTTP 400 invalid_input naming reservationToken, and nothing moves
        Lib.AssertInvalidInputNaming(TicketNumberResponse, 'reservationToken', 'S9.c: Change with a ticket number instead of a token');
        Lib.AssertNothingStoredSinceMark('S9.c: Change with a ticket number instead of a token');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUnconfirmedReservation_WhenChange_ThenUniformNotFound()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Lines: JsonArray;
        Response: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] A reservation that was registered but not confirmed is refused with the uniform not-found error for a token, and nothing moves.
        Initialize();

        // [GIVEN] A two-line reservation on the early slot that is registered but not confirmed
        Lib.CreateEventScenario();
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(Lines);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot with the token and the pin of that reservation
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 404 resource_not_found with the reservation token message, and nothing moves
        Lib.AssertUniformNotFound(Response, Lib.TokenNotFoundMessage(), 'S9.e: Change of an unconfirmed reservation');
        Lib.AssertNothingStoredSinceMark('S9.e: Change of an unconfirmed reservation');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFirstLineRevoked_WhenChangeEitherLine_ThenOtherLineMovesAndRevokedLineNotAllowed()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        SecondLineResponse: JsonObject;
        RevokedLineResponse: JsonObject;
        RevokedLineSystemId: Guid;
    begin
        // [SCENARIO] After the first line of a reservation was revoked on the Ticket Request page, the guest still changes the second line, while a change of the revoked first line is refused as not allowed naming that line, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first line was revoked on the Ticket Request page, which blocked its tickets and set its primary row to CANCELED
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.RevokeLine(1);
        RevokedLineSystemId := Lib.LineSystemId(1);
        Lib.SnapshotLines();

        // [WHEN] The guest changes the second line to the middle slot with the original token and the pin
        SecondLineResponse := Lib.ChangeLine(Lib.LineSystemId(2), Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200 with the second line under a new systemId, moved to the middle slot
        Lib.AssertStatus(SecondLineResponse, 200, 'F5.a: Change of the second line after the first line was revoked');
        Lib.AssertLineMoved(SecondLineResponse, 1, 2, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F5.a: Change of the second line after the first line was revoked');

        // [WHEN] The guest changes the revoked first line to the middle slot
        Lib.MarkStoredState();
        RevokedLineResponse := Lib.ChangeLine(RevokedLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 reschedule_not_allowed naming the first line, and nothing moves
        Lib.AssertNotAllowedNamingLine(RevokedLineResponse, RevokedLineSystemId, 'F5.b: Change of the revoked first line');
        Lib.AssertNothingStoredSinceMark('F5.b: Change of the revoked first line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineChangedBefore_WhenChangeWithItsChangeToken_ThenOtherLineMoves()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Lines: JsonArray;
        Response: JsonObject;
        ChangeToken: Text[100];
    begin
        // [SCENARIO] The token of an earlier change of one line identifies the whole reservation, so a change under that token moves the other line.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first line was moved to the middle slot under a change token
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        ChangeToken := Lib.MoveLineToSlot(Lib.TicketNo(1, 1), 2);
        Lib.SnapshotLines();

        // [WHEN] The guest changes the second line to the late slot with the change token of the first line and the pin
        Lib.AddChangeLine(Lines, Lib.LineSystemId(2), Lib.GetAdmissionCode(), Lib.SlotNo(3));
        Response := Lib.CallChange(Lib.ChangeBody(ChangeToken, Lib.GetPin(), Lines));

        // [THEN] HTTP 200 and the second line moved to the late slot
        Lib.AssertStatus(Response, 200, 'S9.d: Change of the second line with the change token of the first line');
        Lib.AssertChangedLineCount(Response, 1, 'S9.d: Change of the second line with the change token of the first line');
        Lib.AssertLineMoved(Response, 1, 2, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'S9.d: Change of the second line with the change token of the first line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenMalformedChangeBodies_WhenChange_ThenInvalidInputNamingTheProperty()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        EmptyLines: JsonArray;
        DuplicateLines: JsonArray;
        NotGuidLines: JsonArray;
        ZeroSlotLines: JsonArray;
        TooManyLines: JsonArray;
        LongCodeLines: JsonArray;
        TextSlotLines: JsonArray;
        FractionSlotLines: JsonArray;
        LongCodeAdmission: JsonObject;
        TextSlotAdmission: JsonObject;
        FractionSlotAdmission: JsonObject;
        EmptyResponse: JsonObject;
        DuplicateResponse: JsonObject;
        NotGuidResponse: JsonObject;
        ZeroSlotResponse: JsonObject;
        TooManyResponse: JsonObject;
        LongCodeResponse: JsonObject;
        TextSlotResponse: JsonObject;
        FractionSlotResponse: JsonObject;
        FirstLineSystemId: Guid;
        WrongPin: Text;
        LineNo: Integer;
    begin
        // [SCENARIO] Change bodies with an empty or too long reservationLines, a repeated or malformed systemId, a scheduleNumber that is not a positive JSON integer, or an admission code longer than 20 characters are refused as invalid input naming the property, before any pin is checked and without any side effect.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, and the pin with its last character changed so a pin check would answer not-found
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstLineSystemId := Lib.LineSystemId(1);
        WrongPin := Lib.WrongPin();
        Lib.MarkStoredState();

        // [WHEN] The guest sends a change with an empty reservationLines
        EmptyResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), WrongPin, EmptyLines));

        // [THEN] HTTP 400 invalid_input naming reservationLines
        Lib.AssertInvalidInputNaming(EmptyResponse, 'reservationLines', 'S10.d: Change with an empty reservationLines');

        // [WHEN] The guest sends a change naming the systemId of the first line twice
        Lib.AddChangeLine(DuplicateLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(DuplicateLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));
        DuplicateResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), WrongPin, DuplicateLines));

        // [THEN] HTTP 400 invalid_input naming the systemId of the second element
        Lib.AssertInvalidInputNaming(DuplicateResponse, 'reservationLines[1].systemId', 'S10.e: Change with the same systemId twice');

        // [WHEN] The guest sends a change with the systemId abc
        Lib.AddRawChangeLine(NotGuidLines, 'abc', Lib.ChangeAdmission(Lib.GetAdmissionCode(), Lib.SlotNo(2)));
        NotGuidResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), WrongPin, NotGuidLines));

        // [THEN] HTTP 400 invalid_input naming the systemId of the first element
        Lib.AssertInvalidInputNaming(NotGuidResponse, 'reservationLines[0].systemId', 'S10.f: Change with the systemId abc');

        // [WHEN] The guest sends a change with scheduleNumber 0
        Lib.AddChangeLine(ZeroSlotLines, FirstLineSystemId, Lib.GetAdmissionCode(), 0);
        ZeroSlotResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), WrongPin, ZeroSlotLines));

        // [THEN] HTTP 400 invalid_input naming the scheduleNumber
        Lib.AssertInvalidInputNaming(ZeroSlotResponse, 'reservationLines[0].admissions[0].scheduleNumber', 'S10.g: Change with scheduleNumber 0');

        // [WHEN] The guest sends a change with 101 lines
        for LineNo := 1 to 101 do
            Lib.AddChangeLine(TooManyLines, CreateGuid(), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        TooManyResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), WrongPin, TooManyLines));

        // [THEN] HTTP 400 invalid_input naming reservationLines
        Lib.AssertInvalidInputNaming(TooManyResponse, 'reservationLines', 'S10.h: Change with 101 lines');

        // [WHEN] The guest sends a change with an admission code of 33 characters
        LongCodeAdmission.Add('admissionCode', 'ADMISSION-CODE-LONGER-THAN-TWENTY');
        LongCodeAdmission.Add('scheduleNumber', Lib.SlotNo(2));
        Lib.AddRawChangeLine(LongCodeLines, Format(FirstLineSystemId), LongCodeAdmission);
        LongCodeResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), WrongPin, LongCodeLines));

        // [THEN] HTTP 400 invalid_input naming the admissionCode
        Lib.AssertInvalidInputNaming(LongCodeResponse, 'reservationLines[0].admissions[0].admissionCode', 'RF5: Change with an admission code longer than 20 characters');

        // [WHEN] The guest sends a change with the scheduleNumber as the JSON string "5"
        TextSlotAdmission.Add('admissionCode', Lib.GetAdmissionCode());
        TextSlotAdmission.Add('scheduleNumber', '5');
        Lib.AddRawChangeLine(TextSlotLines, Format(FirstLineSystemId), TextSlotAdmission);
        TextSlotResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), WrongPin, TextSlotLines));

        // [THEN] HTTP 400 invalid_input naming the scheduleNumber
        Lib.AssertInvalidInputNaming(TextSlotResponse, 'reservationLines[0].admissions[0].scheduleNumber', 'RF5: Change with the scheduleNumber as the JSON string "5"');

        // [WHEN] The guest sends a change with the scheduleNumber 5.5
        FractionSlotAdmission.Add('admissionCode', Lib.GetAdmissionCode());
        FractionSlotAdmission.Add('scheduleNumber', 5.5);
        Lib.AddRawChangeLine(FractionSlotLines, Format(FirstLineSystemId), FractionSlotAdmission);
        FractionSlotResponse := Lib.CallChange(Lib.ChangeBody(Lib.GetToken(), WrongPin, FractionSlotLines));

        // [THEN] HTTP 400 invalid_input naming the scheduleNumber, and none of the calls stored anything
        Lib.AssertInvalidInputNaming(FractionSlotResponse, 'reservationLines[0].admissions[0].scheduleNumber', 'RF5: Change with the scheduleNumber 5.5');
        Lib.AssertNothingStoredSinceMark('S10.d, S10.e, S10.f, S10.g, S10.h, RF5: Malformed change bodies');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenHundredLineReservation_WhenChangeAllLines_ThenAllMoved()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        ReserveLines: JsonArray;
        ChangeLines: JsonArray;
        Response: JsonObject;
        LineNo: Integer;
        LineContextTxt: Label 'S10.k: Change of all 100 lines, line %1', Locked = true;
    begin
        // [SCENARIO] A change of 100 distinct lines, the maximum, is accepted and moves every line.
        Initialize();

        // [GIVEN] A confirmed reservation of 100 lines of one place each on the early slot
        Lib.CreateEventScenario();
        for LineNo := 1 to 100 do
            Lib.AddReserveLineTo(ReserveLines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(ReserveLines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.SnapshotLines();
        for LineNo := 1 to 100 do
            Lib.AddChangeLine(ChangeLines, Lib.LineSystemId(LineNo), Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [WHEN] The guest changes all 100 lines to the middle slot in one call
        Response := Lib.Change(ChangeLines);

        // [THEN] HTTP 200 with 100 result lines, and every line moved to the middle slot
        Lib.AssertStatus(Response, 200, 'S10.k: Change of all 100 lines');
        Lib.AssertChangedLineCount(Response, 100, 'S10.k: Change of all 100 lines');
        for LineNo := 1 to 100 do
            Lib.AssertLineMoved(Response, LineNo, LineNo, Lib.GetAdmissionCode(), Lib.SlotNo(2), StrSubstNo(LineContextTxt, LineNo));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineWithTwoAdmissions_WhenChangeNoneOrOne_ThenInvalidInputOrOnlyNamedAdmissionMoves()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        SecondAdmission: Codeunit "NPR Library - TM Reschedule";
        MixedLines: JsonArray;
        BothAdmissionsLines: JsonArray;
        NothingChangedResponse: JsonObject;
        MixedResponse: JsonObject;
        OneAdmissionResponse: JsonObject;
        BothAdmissionsResponse: JsonObject;
        FirstLineSystemId: Guid;
        SecondLineSystemId: Guid;
    begin
        // [SCENARIO] A line that changes no admission is refused as invalid input and stops the whole request; a line that names one of its two admissions, or both with the second on its current slot, moves only that admission and lists both with their resulting slots.
        Initialize();

        // [GIVEN] An item with a second admission, and a confirmed reservation of a line of two places and a line of one place on the early slots of both admissions
        Lib.CreateEventScenario();
        SecondAdmission.CreateEventScenario();
        Lib.AddAdmission(SecondAdmission.GetAdmissionCode(), false);
        CreateReservationOnBothAdmissions(Lib, SecondAdmission);
        FirstLineSystemId := Lib.LineSystemId(1);
        SecondLineSystemId := Lib.LineSystemId(2);
        Lib.SnapshotLines();
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line naming only its first admission with its current early slot
        NothingChangedResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(1));

        // [THEN] HTTP 400 invalid_input naming the first line, and nothing moves
        Lib.AssertChangesNothing(NothingChangedResponse, FirstLineSystemId, 'S13.c: Change of the first line to its current slot only');
        Lib.AssertNothingStoredSinceMark('S13.c: Change of the first line to its current slot only');

        // [WHEN] The guest changes the first line to its current early slot and the second line to the middle slot in one call
        Lib.AddChangeLine(MixedLines, FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddChangeLine(MixedLines, SecondLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        MixedResponse := Lib.Change(MixedLines);

        // [THEN] HTTP 400 invalid_input naming the first line, and the second line does not move either
        Lib.AssertChangesNothing(MixedResponse, FirstLineSystemId, 'S13.d: Change of a line that changes nothing with a line that moves');
        Lib.AssertNothingStoredSinceMark('S13.d: Change of a line that changes nothing with a line that moves');

        // [WHEN] The guest changes only the first admission of the first line to the middle slot
        OneAdmissionResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200; the result line lists both admissions, the first moved to the middle slot and the second still on its early slot, which its tickets keep
        Lib.AssertStatus(OneAdmissionResponse, 200, 'S13.a: Change of the first admission of the line only');
        Lib.AssertChangedAdmissionCount(OneAdmissionResponse, 1, 2, 'S13.a: Change of the first admission of the line only');
        Lib.AssertLineMoved(OneAdmissionResponse, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S13.a: Change of the first admission of the line only');
        Lib.AssertChangedAdmission(OneAdmissionResponse, 1, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1), 'S13.a: Change of the first admission of the line only');
        Lib.AssertLineOnSlot(1, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1), 'S13.a: Change of the first admission of the line only');

        // [GIVEN] A second confirmed reservation of the same two lines on the early slots of both admissions
        CreateReservationOnBothAdmissions(Lib, SecondAdmission);
        Lib.SnapshotLines();

        // [WHEN] The guest changes the first admission of the first line to the middle slot and names the second admission with its current early slot
        Lib.AddChangeLine(BothAdmissionsLines, Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddAdmissionToLastChangeLine(BothAdmissionsLines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1));
        BothAdmissionsResponse := Lib.Change(BothAdmissionsLines);

        // [THEN] HTTP 200 with the same result as when only the first admission is named
        Lib.AssertStatus(BothAdmissionsResponse, 200, 'S13.b: Change of the first admission with the second admission on its current slot');
        Lib.AssertChangedAdmissionCount(BothAdmissionsResponse, 1, 2, 'S13.b: Change of the first admission with the second admission on its current slot');
        Lib.AssertLineMoved(BothAdmissionsResponse, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S13.b: Change of the first admission with the second admission on its current slot');
        Lib.AssertChangedAdmission(BothAdmissionsResponse, 1, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1), 'S13.b: Change of the first admission with the second admission on its current slot');
        Lib.AssertLineOnSlot(1, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1), 'S13.b: Change of the first admission with the second admission on its current slot');
    end;
    #endregion

    #region E-tickets and internal errors
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('NpPassHandler,ETicketFailureMessageHandler')]
    procedure GivenNpPassFailsOrIsUnreachable_WhenChange_ThenChangeIsStored()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        RefusedResponse: JsonObject;
        UnreachableResponse: JsonObject;
    begin
        // [SCENARIO] When NP Pass refuses the e-ticket update or cannot be reached, the change is still stored as without e-tickets and answered HTTP 200, without a word about the e-tickets.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose tickets have e-tickets in NP Pass, and NP Pass answering every call with an error
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.IssueETickets();
        Lib.SnapshotLines();
        UseNpPass(_NpPassMode::Refuses, 'S15.a');

        // [WHEN] The guest changes the first line to the middle slot
        RefusedResponse := Lib.ChangeLine(Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200 with only the result lines; the change is stored as without e-tickets, and the e-ticket update reached NP Pass
        Lib.AssertStatus(RefusedResponse, 200, 'S15.a: Change while NP Pass refuses the e-ticket update');
        Lib.AssertBodyHoldsOnlyReservationLines(RefusedResponse, 'S15.a: Change while NP Pass refuses the e-ticket update');
        Lib.AssertBodyOmits(RefusedResponse, NpPassRefusalTok, 'NP Pass error', 'S15.a: Change while NP Pass refuses the e-ticket update');
        Lib.AssertLineMoved(RefusedResponse, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S15.a: Change while NP Pass refuses the e-ticket update');
        Lib.AssertLineUntouched(2, 'S15.a: Change while NP Pass refuses the e-ticket update');
        Assert.AreNotEqual(0, _NpPassPutCount, 'S15.a: The change must have sent the e-ticket update to NP Pass, but the HTTP handler saw no PUT.');

        // [GIVEN] A second confirmed two-line reservation of the same item with e-tickets, and NP Pass unreachable
        Lib.CreateTwoLineReservation(1, 1);
        Lib.IssueETickets();
        Lib.SnapshotLines();
        UseNpPass(_NpPassMode::Unreachable, 'S15.b');

        // [WHEN] The guest changes the first line to the middle slot
        UnreachableResponse := Lib.ChangeLine(Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200 with only the result lines; the change is stored as without e-tickets, and the e-ticket update was attempted
        Lib.AssertStatus(UnreachableResponse, 200, 'S15.b: Change while NP Pass is unreachable');
        Lib.AssertBodyHoldsOnlyReservationLines(UnreachableResponse, 'S15.b: Change while NP Pass is unreachable');
        Lib.AssertLineMoved(UnreachableResponse, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S15.b: Change while NP Pass is unreachable');
        Lib.AssertLineUntouched(2, 'S15.b: Change while NP Pass is unreachable');
        Assert.AreNotEqual(0, _NpPassPutCount, 'S15.b: The change must have tried to send the e-ticket update to NP Pass, but the HTTP handler saw no PUT.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineWithoutAdmissionRows_WhenChange_ThenInternalErrorAndNothingWritten()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        Response: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] A line with no required or selected admission row is an internal inconsistency, so change answers with the fixed internal error, logs one programming-bug event that names the integrity problem, and writes nothing.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose every row of the first line is set to Not Selected
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.DeselectLineAdmissions(1);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();
        SentryCapture.Start();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        SentryCapture.Stop();

        // [THEN] HTTP 400 generic_error with the message "An internal error occurred. The request was logged."
        Lib.AssertInternalError(Response, 'S16.a: Change of a line without admission rows');

        // [THEN] Exactly one Sentry event holds the Houston integrity text, and it is marked as a programming bug
        Assert.AreEqual(1, SentryCapture.Count('Houston', 'Houston'), 'S16.a: Change of a line without admission rows must log exactly one Sentry event with the Houston integrity text.');
        Assert.AreEqual(1, SentryCapture.Count('Houston', 'This is a programming bug'), 'S16.a: The Sentry event with the Houston integrity text must be marked as a programming bug.');

        // [THEN] Nothing was written and the reservation mutex is free
        Lib.AssertNothingStoredSinceMark('S16.a: Change of a line without admission rows');
        Lib.AssertNoMutexLeft('S16.a: Change of a line without admission rows');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenErrorOnSecondConfirmEvent_WhenChangeTwoLines_ThenChangeStoredAndErrorLogged()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        ConfirmSub: Codeunit "NPR TM Change Confirm Sub";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        Lines: JsonArray;
        Response: JsonObject;
        FirstLineSystemId: Guid;
        SecondLineSystemId: Guid;
    begin
        // [SCENARIO] An error raised by a subscriber of the second confirm event of a two-line change comes after the change is stored, so the change is answered HTTP 200 with both lines moved and confirmed, and the error is logged once as a programming bug.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, and a subscriber that raises an error on the second confirm event of a change request
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SnapshotLines();
        Lib.AddChangeLine(Lines, Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(Lines, Lib.LineSystemId(2), Lib.GetAdmissionCode(), Lib.SlotNo(3));
        ConfirmSub.ThrowOnCall(2);
        BindSubscription(ConfirmSub);
        SentryCapture.Start();

        // [WHEN] The guest changes the first line to the middle slot and the second line to the late slot in one call
        Response := Lib.Change(Lines);
        SentryCapture.Stop();
        UnbindSubscription(ConfirmSub);

        // [THEN] HTTP 200; the error came from the second confirm event
        Lib.AssertStatus(Response, 200, 'F1: S16.b: Change of two lines with an error on the second confirm event');
        Assert.AreEqual(2, ConfirmSub.CallCount(), 'F1: S16.b: The error must come from the second confirm event, after the first one fired.');

        // [THEN] Both lines moved, the first to the middle slot and the second to the late slot, with CONFIRMED change rows, and the reservation mutex is free
        FirstLineSystemId := Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F1: S16.b: Change of two lines with an error on the second confirm event, first line');
        SecondLineSystemId := Lib.AssertLineMoved(Response, 2, 2, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'F1: S16.b: Change of two lines with an error on the second confirm event, second line');
        Lib.AssertNoMutexLeft('F1: S16.b: Change of two lines with an error on the second confirm event');

        // [THEN] Each confirm event carried the token of its own line's change request, in line order
        AssertTokenOfCall(ConfirmSub, 1, FirstLineSystemId, 'F1: S16.b');
        AssertTokenOfCall(ConfirmSub, 2, SecondLineSystemId, 'F1: S16.b');

        // [THEN] One Sentry event holds the subscriber's error, marked as a programming bug
        Assert.AreEqual(1, SentryCapture.Count(ConfirmSub.RefusalText(2), 'This is a programming bug'), 'F1: S16.b: The error of the second confirm event must be logged once to Sentry as a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenErrorOnFirstConfirmEvent_WhenChangeThreeLines_ThenOtherLinesStillPublished()
    var
        FirstChangeRow: Record "NPR TM Ticket Reservation Req.";
        Lib: Codeunit "NPR Library - TM Reschedule";
        ConfirmSub: Codeunit "NPR TM Change Confirm Sub";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        ReserveLines: JsonArray;
        ChangeLines: JsonArray;
        Response: JsonObject;
        FirstLineSystemId: Guid;
        SecondLineSystemId: Guid;
        ThirdLineSystemId: Guid;
        FailedTokenNamedErr: Label 'B1: The programming-bug event must name the token %1 of the change request of the first line, whose confirm event failed.', Locked = true;
    begin
        // [SCENARIO] When the confirm event of the first of three changed lines fails, the confirm event still fires for the other two lines, the change is answered HTTP 200 with all three lines moved and confirmed, and the error is logged once as a programming bug that names the token of the first line's change request.
        Initialize();

        // [GIVEN] A confirmed reservation of three lines of one place each on the early slot, and a subscriber that raises an error on the first confirm event of a change request
        Lib.CreateEventScenario();
        Lib.AddReserveLineTo(ReserveLines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(ReserveLines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(ReserveLines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(ReserveLines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.SnapshotLines();
        Lib.AddChangeLine(ChangeLines, Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(ChangeLines, Lib.LineSystemId(2), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(ChangeLines, Lib.LineSystemId(3), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        ConfirmSub.ThrowOnCall(1);
        BindSubscription(ConfirmSub);
        SentryCapture.Start();

        // [WHEN] The guest changes all three lines to the middle slot in one call
        Response := Lib.Change(ChangeLines);
        SentryCapture.Stop();
        UnbindSubscription(ConfirmSub);

        // [THEN] HTTP 200, and one confirm event per line, the two after the failed first one included
        Lib.AssertStatus(Response, 200, 'B1: Change of three lines with an error on the first confirm event');
        Assert.AreEqual(3, ConfirmSub.CallCount(), 'B1: The change of three lines must raise one confirm event per line, also after the confirm event of the first line failed.');

        // [THEN] All three lines moved to the middle slot with CONFIRMED change rows
        FirstLineSystemId := Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'B1: Change of three lines with an error on the first confirm event, first line');
        SecondLineSystemId := Lib.AssertLineMoved(Response, 2, 2, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'B1: Change of three lines with an error on the first confirm event, second line');
        ThirdLineSystemId := Lib.AssertLineMoved(Response, 3, 3, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'B1: Change of three lines with an error on the first confirm event, third line');

        // [THEN] Each confirm event carried the token of its own line's change request, in line order
        AssertTokenOfCall(ConfirmSub, 1, FirstLineSystemId, 'B1');
        AssertTokenOfCall(ConfirmSub, 2, SecondLineSystemId, 'B1');
        AssertTokenOfCall(ConfirmSub, 3, ThirdLineSystemId, 'B1');

        // [THEN] Exactly one Sentry event is marked as a programming bug, and it names the token of the first line's change request
        Assert.AreEqual(1, SentryCapture.Count('This is a programming bug', 'This is a programming bug'), 'B1: The error of the first confirm event must be the only Sentry event marked as a programming bug.');
        FirstChangeRow.GetBySystemId(FirstLineSystemId);
        Assert.AreEqual(1, SentryCapture.Count(FirstChangeRow."Session Token ID", 'This is a programming bug'), StrSubstNo(FailedTokenNamedErr, FirstChangeRow."Session Token ID"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('NpPassHandler')]
    procedure GivenETicketUpdateThrowsBeforeCommit_WhenChange_ThenChangeStoredAndErrorLogged()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        Response: JsonObject;
    begin
        // [SCENARIO] When the first e-ticket update throws before it commits, because NP Pass accepts the pass and then answers its address with malformed JSON, the change is already stored in BC, so it is answered HTTP 200 with the line moved and confirmed, and the error is logged once as a programming bug.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose tickets have e-tickets in NP Pass, and NP Pass accepting the PUT of a pass and answering the GET of its address with malformed JSON
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.IssueETickets();
        Lib.SnapshotLines();
        UseNpPass(_NpPassMode::AcceptsPutBreaksGet, 'S16.c');
        SentryCapture.Start();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        SentryCapture.Stop();

        // [THEN] HTTP 200, and the thrown e-ticket error logged once as a programming bug
        Lib.AssertStatus(Response, 200, 'F1: S16.c: Change whose first e-ticket update throws before its commit');
        Assert.AreEqual(1, SentryCapture.Count('This is a programming bug', 'This is a programming bug'), 'F1: S16.c: The thrown e-ticket error must be logged once to Sentry as a programming bug.');

        // [THEN] Stored in BC: the first line moved to the middle slot with CONFIRMED change rows, the second line untouched, and the reservation mutex is free
        Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F1: S16.c: Change whose first e-ticket update throws before its commit');
        Lib.AssertLineUntouched(2, 'F1: S16.c: Change whose first e-ticket update throws before its commit');
        Lib.AssertNoMutexLeft('F1: S16.c: Change whose first e-ticket update throws before its commit');

        // [THEN] NP Pass accepted exactly the one PUT of the first e-ticket update
        Assert.AreEqual(1, _NpPassPutCount, 'F1: S16.c: NP Pass must have accepted exactly one PUT, the first e-ticket update, before its address request threw.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('NpPassHandler')]
    procedure GivenSecondETicketUpdateThrowsAfterFirstCommitted_WhenChange_ThenLineMovedAndErrorLogged()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        Response: JsonObject;
        FirstTicket: Text;
    begin
        // [SCENARIO] When the e-ticket update of the first ticket of a line succeeds and commits and the update of its second ticket throws, the change is answered HTTP 200 with the line moved and confirmed, the first ticket's update is stored as sent, and the error is logged once as a programming bug.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, the first line of two tickets, whose tickets have e-tickets in NP Pass; NP Pass answering the calls of the first ticket of that line correctly and the address request of its second ticket with malformed JSON
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.IssueETickets();
        Lib.SnapshotLines();
        FirstTicket := Lib.TicketNo(1, 1);
        UseNpPass(_NpPassMode::AcceptsFirstPassBreaksSecondGet, 'F1.a');
        SentryCapture.Start();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        SentryCapture.Stop();

        // [THEN] HTTP 200 with the first line under a new systemId on the middle slot, both its tickets moved there and its change rows CONFIRMED
        Lib.AssertStatus(Response, 200, 'F1.a: Change whose second e-ticket update throws after the first one committed');
        Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F1.a: Change whose second e-ticket update throws after the first one committed');
        Lib.AssertLineOnSlot(1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F1.a: Change whose second e-ticket update throws after the first one committed');

        // [THEN] The first ticket has an e-ticket update notification entry with status SENT
        Lib.AssertETicketUpdateSent(FirstTicket, 'F1.a: Change whose second e-ticket update throws after the first one committed');

        // [THEN] Exactly one Sentry event is marked as a programming bug, and the reservation mutex is free
        Assert.AreEqual(1, SentryCapture.Count('This is a programming bug', 'This is a programming bug'), 'F1.a: The thrown e-ticket error must be the only Sentry event marked as a programming bug.');
        Lib.AssertNoMutexLeft('F1.a: Change whose second e-ticket update throws after the first one committed');
    end;
    #endregion

    #region Existing requests and data
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenAbandonedBackOfficeAttempt_WhenGuestChanges_ThenNoRegisteredRowAndOldTokenCannotConfirm()
    var
        FirstLineRow: Record "NPR TM Ticket Reservation Req.";
        Lib: Codeunit "NPR Library - TM Reschedule";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        Assert: Codeunit Assert;
        Response: JsonObject;
        NewSystemId: Guid;
        AttemptToken: Text[100];
    begin
        // [SCENARIO] A change request left REGISTERED by an aborted back-office attempt does not block the guest's change, no REGISTERED row of the line remains afterwards, and a later confirm of the attempt's token fails without touching the guest's change.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot and a back-office change request for the first line that the user aborted, so its rows stay REGISTERED
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        AttemptToken := Lib.CreateAbandonedChangeRequest(Lib.TicketNo(1, 1));
        Lib.SnapshotLines();
        Lib.GetSnapshotRow(1, FirstLineRow);

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(FirstLineRow.SystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200, the first line moved to the middle slot, and no REGISTERED row supersedes the row of the first line
        Lib.AssertStatus(Response, 200, 'S18.a: Change of a line with an abandoned back-office change request');
        NewSystemId := Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S18.a: Change of a line with an abandoned back-office change request');
        Lib.AssertNoRegisteredRowSuperseding(FirstLineRow, 'S18.a: Change of a line with an abandoned back-office change request');

        // [WHEN] The back-office page that is still open confirms its change request by the old token
        asserterror TicketRequestManager.ConfirmChangeRequest(AttemptToken);

        // [THEN] The confirm fails, and the guest's change stays as stored
        Assert.ExpectedErrorCode('DB:NothingInsideFilter');
        Lib.AssertChangeRows(NewSystemId, FirstLineRow, 1, 'S18.a: Confirm of the abandoned change request after the guest changed the line');
        Lib.AssertLineOnSlot(1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S18.a: Confirm of the abandoned change request after the guest changed the line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenAbandonedAttemptAndReplannedSecondAdmission_WhenGuestMovesFirstAdmission_ThenSecondRowHoldsReplannedSlot()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        SecondAdmission: Codeunit "NPR Library - TM Reschedule";
        ReserveLines: JsonArray;
        Response: JsonObject;
        FormerSystemId: Guid;
        NewSystemId: Guid;
    begin
        // [SCENARIO] A guest change that reuses the change request an aborted back-office attempt left REGISTERED stores, on the change row of the admission that does not move, the slot its ticket was replanned to after the attempt, and on the row of the moved admission its new slot.
        Initialize();

        // [GIVEN] An item with a second admission; a confirmed reservation of a line of one place on the early slots of both admissions; a back-office change request for the line that the user aborted while both admissions stood on their early slots; then the second admission of the ticket replanned to its middle slot
        Lib.CreateEventScenario();
        SecondAdmission.CreateEventScenario();
        Lib.AddAdmission(SecondAdmission.GetAdmissionCode(), false);
        Lib.AddReserveLineTo(ReserveLines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddAdmissionToLastReserveLine(ReserveLines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1));
        Lib.CreateReservation(ReserveLines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.CreateAbandonedChangeRequest(Lib.TicketNo(1, 1));
        Lib.ReplanTicketAdmission(Lib.TicketNo(1, 1), SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(2));
        Lib.AssertTicketOnSlot(Lib.TicketNo(1, 1), SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(2), 'F1: Setup: the replan of the second admission to its middle slot');
        FormerSystemId := Lib.LineSystemId(1);

        // [WHEN] The guest changes only the first admission of the line to its middle slot
        Response := Lib.ChangeLine(FormerSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200 with the line under a new systemId
        Lib.AssertStatus(Response, 200, 'F1: Change of the first admission after an aborted back-office attempt and a replan of the second admission');
        NewSystemId := Lib.AssertChangedLine(Response, 1, FormerSystemId, 1, 'F1: Change of the first admission after an aborted back-office attempt and a replan of the second admission');

        // [THEN] The CONFIRMED CHANGE row of the first admission holds its new middle slot, and the one of the second admission holds the middle slot it was replanned to, each with that slot's start as scheduled time
        Lib.AssertChangeRowOnSlot(NewSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F1: Change of the first admission after an aborted back-office attempt and a replan of the second admission');
        Lib.AssertChangeRowOnSlot(NewSystemId, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(2), 'F1: Change of the first admission after an aborted back-office attempt and a replan of the second admission');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSharedLineReference_WhenChangeSharedEntry_ThenInvalidReference()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Lines: JsonArray;
        Response: JsonObject;
        SharedEntrySystemId: Guid;
    begin
        // [SCENARIO] A change of the entry that two lines sharing one line reference make up is refused as an invalid reference naming that entry, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed three-line reservation on the early slot whose first two lines were rewritten to share line reference 0 with a single primary row
        Lib.CreateEventScenario();
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(Lines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.ShareLineReference(1, 2);
        SharedEntrySystemId := Lib.LineSystemId(0);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the shared entry to the middle slot
        Response := Lib.ChangeLine(SharedEntrySystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 invalid_reference naming the shared entry and the admission, and nothing moves
        Lib.AssertInvalidReference(Response, SharedEntrySystemId, Lib.GetAdmissionCode(), 'S19.b: Change of the entry of a shared line reference');
        Lib.AssertNothingStoredSinceMark('S19.b: Change of the entry of a shared line reference');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenEveryLineAmbiguous_WhenChangeSharedEntry_ThenInvalidReference()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        SharedEntrySystemId: Guid;
    begin
        // [SCENARIO] A change of the shared entry of a reservation whose every line is ambiguous is refused as an invalid reference naming that entry, as when another line could move, and nothing moves.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose two lines were rewritten to share line reference 0 with a single primary row
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.ShareLineReference(1, 2);
        SharedEntrySystemId := Lib.LineSystemId(0);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the shared entry to the middle slot
        Response := Lib.ChangeLine(SharedEntrySystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 invalid_reference naming the shared entry and the admission, and nothing moves
        Lib.AssertInvalidReference(Response, SharedEntrySystemId, Lib.GetAdmissionCode(), 'F7.c: Change of the shared entry of a reservation whose every line is ambiguous');
        Lib.AssertNothingStoredSinceMark('F7.c: Change of the shared entry of a reservation whose every line is ambiguous');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenReservationMutexHeld_WhenChange_ThenInvalidReferenceAndRowKept()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        Response: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] While another request holds the reservation mutex, a change is refused as an invalid reference telling the guest to call find again, nothing moves, and the other request's mutex row stays.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose reservation mutex is held for the original token
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.HoldReservationMutex();
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 invalid_reference with the message that another request is changing the reservation, nothing moves, and the mutex row is still there
        Lib.AssertBusy(Response, 'RF1: Change while another request holds the reservation mutex');
        Lib.AssertNothingStoredSinceMark('RF1: Change while another request holds the reservation mutex');
        Assert.IsTrue(Lib.IsReservationMutexHeld(), 'RF1: The refused change must not delete the mutex row of the other request.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenExpiredAttemptChild_WhenGuestChanges_ThenChangeSucceedsAndExpiredRowsStay()
    var
        TempExpiredRows: Record "NPR TM Ticket Reservation Req." temporary;
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        Response: JsonObject;
        AttemptToken: Text[100];
    begin
        // [SCENARIO] A back-office change attempt that the expiry job set to EXPIRED and has not removed yet does not block the guest's change, and its rows stay as they are.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot and a back-office change request for the first line that the user aborted and the expiry job then set to EXPIRED
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        AttemptToken := Lib.CreateAbandonedChangeRequest(Lib.TicketNo(1, 1));
        Lib.ExpireRequest(AttemptToken);
        Lib.SnapshotTokenRows(AttemptToken, TempExpiredRows);
        TempExpiredRows.SetFilter("Request Status", '<>%1', TempExpiredRows."Request Status"::EXPIRED);
        Assert.IsTrue(TempExpiredRows.IsEmpty(), 'S18.b: Setup: every row of the abandoned change request must be EXPIRED.');
        TempExpiredRows.SetRange("Request Status");
        Lib.SnapshotLines();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200, the first line moved to the middle slot with its tickets on the row of this change, and the EXPIRED rows unchanged
        Lib.AssertStatus(Response, 200, 'S18.b: Change of a line with an expired back-office change request');
        Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S18.b: Change of a line with an expired back-office change request');
        Lib.AssertRowsUnchanged(TempExpiredRows, 'S18.b: Change of a line with an expired back-office change request');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenRefundInProgress_WhenChange_ThenNotAllowedAndRevokeRowsKept()
    var
        TempRefundRows: Record "NPR TM Ticket Reservation Req." temporary;
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        FirstLineSystemId: Guid;
        RefundToken: Text[100];
    begin
        // [SCENARIO] A line with a refund in progress at the POS cannot be changed, so its change is refused as not allowed while the other line could move, nothing moves, and the refund request rows stay as they are.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first ticket has a refund request that the POS registered and has not confirmed
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstLineSystemId := Lib.LineSystemId(1);
        RefundToken := Lib.CreateRefundRequest(Lib.TicketNo(1, 1));
        Lib.SnapshotTokenRows(RefundToken, TempRefundRows);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line to the middle slot
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 reschedule_not_allowed naming the first line, the admission and the reason LINE_NOT_CHANGEABLE, nothing moves, and the refund request rows are unchanged
        Lib.AssertNotAllowed(Response, FirstLineSystemId, Lib.GetAdmissionCode(), 'LINE_NOT_CHANGEABLE', 'F7: S8.r: Change of a line with a refund request in progress');
        Lib.AssertNothingStoredSinceMark('F7: S8.r: Change of a line with a refund request in progress');
        Lib.AssertRowsUnchanged(TempRefundRows, 'F7: S8.r: Change of a line with a refund request in progress');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFullGroupWithOccasionAndOtherAdmission_WhenBothMoveIn_ThenOtherAdmissionIsNotCounted()
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        Lib: Codeunit "NPR Library - TM Reschedule";
        SecondAdmission: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        ReserveLines: JsonArray;
        ChangeLines: JsonArray;
        Response: JsonObject;
        GroupCode: Code[20];
    begin
        // [SCENARIO] In a concurrency group that counts open reservations and admitted places, with 9 of 10 places in use, one call moves a line of one place with a non-occasion admission first and an occasion admission second into the group, because only the occasion admission's place counts and 10 fits.
        Initialize();

        // [GIVEN] An item whose default admission is not an occasion and whose second admission is an occasion; the middle slots of both under Sales control with capacity 1000 in one concurrency group by concurrency code with control FULL and limit 10; 9 places of the occasion admission reserved on its middle slot by another sale; a confirmed reservation of one line of one place on the early slots of both admissions
        Lib.CreateEventScenario();
        SecondAdmission.CreateEventScenario();
        Lib.UseLocationAdmission();
        Lib.AddAdmission(SecondAdmission.GetAdmissionCode(), false);
        Lib.SetSlotSalesCapacity(2, 1000);
        SecondAdmission.SetSlotSalesCapacity(2, 1000);
        GroupCode := Lib.CreateConcurrencyGroup(10, GroupSetup."Capacity Control"::FULL, GroupSetup."Concurrency Type"::CONCURRENCY_CODE);
        Lib.JoinConcurrencyGroup(2, GroupCode);
        SecondAdmission.JoinConcurrencyGroup(2, GroupCode);
        SecondAdmission.SellPlaces(2, 9);
        Assert.AreEqual(9, Lib.GroupPlacesInUseOnEventDate(2), 'RF7: Setup: the FULL concurrency group must count 9 places in use on the event day.');
        Lib.AddReserveLineTo(ReserveLines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddAdmissionToLastReserveLine(ReserveLines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1));
        Lib.CreateReservation(ReserveLines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.SnapshotLines();

        // [WHEN] The guest moves the non-occasion admission and then the occasion admission of the line to their middle slots in one call
        Lib.AddChangeLine(ChangeLines, Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddAdmissionToLastChangeLine(ChangeLines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(2));
        Response := Lib.Change(ChangeLines);

        // [THEN] HTTP 200 and both admissions moved to their middle slots
        Lib.AssertStatus(Response, 200, 'RF7: Change of a non-occasion and an occasion admission into a FULL group with 9 of 10 places in use');
        Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'RF7: Change of a non-occasion and an occasion admission into a FULL group with 9 of 10 places in use');
        Lib.AssertChangedAdmission(Response, 1, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(2), 'RF7: Change of a non-occasion and an occasion admission into a FULL group with 9 of 10 places in use');
        Lib.AssertLineOnSlot(1, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(2), 'RF7: Change of a non-occasion and an occasion admission into a FULL group with 9 of 10 places in use');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFullGroupOverItsLimit_WhenOccasionLineLeavesAndLocationLineEnters_ThenBothMoved()
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        Lib: Codeunit "NPR Library - TM Reschedule";
        LocationItem: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        Lines: JsonArray;
        Response: JsonObject;
        GroupCode: Code[20];
    begin
        // [SCENARIO] In a concurrency group with control FULL that counts 11 places against its limit of 10, one call that moves an occasion line of 2 places out of the group and then a location line of one place into it moves both lines, because the group stands at 9 when the location line moves in.
        Initialize();

        // [GIVEN] An item with an occasion admission and an item with a location admission; the early slot of the occasion admission and the middle slot of the location admission, the latter under Sales control with capacity 1000, in one concurrency group by concurrency code with control FULL and limit 12; a confirmed reservation of a line of two places of the occasion item and a line of one place of the location item, both on their early slots; 9 places of the occasion admission sold on its early slot by another sale; the group limit then lowered to 10
        Lib.CreateEventScenario();
        LocationItem.CreateEventScenario();
        LocationItem.UseLocationAdmission();
        LocationItem.SetSlotSalesCapacity(2, 1000);
        GroupCode := Lib.CreateConcurrencyGroup(12, GroupSetup."Capacity Control"::FULL, GroupSetup."Concurrency Type"::CONCURRENCY_CODE);
        Lib.JoinConcurrencyGroup(1, GroupCode);
        LocationItem.JoinConcurrencyGroup(2, GroupCode);
        Lib.CreateReservationWithOtherItemLine('', 0, LocationItem);
        Lib.SellPlaces(1, 9);
        GroupSetup.Get(GroupCode);
        GroupSetup."Total Capacity" := 10;
        GroupSetup.Modify();
        Assert.AreEqual(11, Lib.GroupPlacesInUseOnEventDate(1), 'F2: Setup: the FULL concurrency group must count 11 places in use on the event day against its limit of 10.');
        Lib.SnapshotLines();

        // [WHEN] The guest moves, in one call, the occasion line to the middle slot of its admission outside the group and the location line to the middle slot of its admission inside the group
        Lib.AddChangeLine(Lines, Lib.LineSystemId(1), Lib.GetAdmissionCode(), Lib.SlotNo(2));
        Lib.AddChangeLine(Lines, Lib.LineSystemId(2), LocationItem.GetAdmissionCode(), LocationItem.SlotNo(2));
        Response := Lib.Change(Lines);

        // [THEN] HTTP 200 with two result lines; the occasion line moved to the middle slot of its admission and the location line to the middle slot of its admission
        Lib.AssertStatus(Response, 200, 'F2: Change of an occasion line out of and a location line into a FULL group with 11 of 10 places in use');
        Lib.AssertChangedLineCount(Response, 2, 'F2: Change of an occasion line out of and a location line into a FULL group with 11 of 10 places in use');
        Lib.AssertLineMoved(Response, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'F2: Change of an occasion line out of and a location line into a FULL group with 11 of 10 places in use, occasion line');
        Lib.AssertChangedAdmission(Response, 2, LocationItem.GetAdmissionCode(), LocationItem.SlotNo(2), 'F2: Change of an occasion line out of and a location line into a FULL group with 11 of 10 places in use, location line');
        Lib.AssertLineOnSlot(2, LocationItem.GetAdmissionCode(), LocationItem.SlotNo(2), 'F2: Change of an occasion line out of and a location line into a FULL group with 11 of 10 places in use, location line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUnmovedAdmissionOnCancelledSlotOrWithoutBomLine_WhenOtherAdmissionMoves_ThenNotAllowed()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        SecondAdmission: Codeunit "NPR Library - TM Reschedule";
        OtherItem: Codeunit "NPR Library - TM Reschedule";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        CancelledSlotResponse: JsonObject;
        DeletedSetupResponse: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] A line whose unmoved second admission stands on a cancelled slot, or lost its admission setup line, cannot be changed, so a move of its first admission is refused as not allowed while the line of another item could move, nothing moves, and no programming bug is logged.
        Initialize();

        // [GIVEN] An item with a second admission; another item; a confirmed reservation of a line of two places on the early slots of both admissions and a line of the other item; the current slot of the second admission then cancelled
        OtherItem.CreateEventScenario();
        Lib.CreateEventScenario();
        SecondAdmission.CreateEventScenario();
        Lib.AddAdmission(SecondAdmission.GetAdmissionCode(), false);
        Lib.CreateReservationWithOtherItemLine(SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1), OtherItem);
        SecondAdmission.CancelSlot(1);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();
        SentryCapture.Start();

        // [WHEN] The guest changes only the first admission of the first line to the middle slot
        CancelledSlotResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        SentryCapture.Stop();

        // [THEN] HTTP 400 reschedule_not_allowed naming the first line, the first admission and the reason LINE_NOT_CHANGEABLE, nothing moves, and no programming-bug event
        Lib.AssertNotAllowed(CancelledSlotResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'LINE_NOT_CHANGEABLE', 'F7: S8.s: Change of the first admission while the second stands on a cancelled slot');
        Lib.AssertNothingStoredSinceMark('F7: S8.s: Change of the first admission while the second stands on a cancelled slot');
        Assert.AreEqual(0, SentryCapture.Count('This is a programming bug', 'This is a programming bug'), 'F7: S8.s: The refused change must not log any Sentry event marked as a programming bug.');

        // [GIVEN] A second confirmed reservation of such a line, with the second admission on its middle slot, and a line of the other item; the admission setup line of the second admission then deleted
        Lib.CreateReservationWithOtherItemLine(SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(2), OtherItem);
        Lib.DeleteAdmissionSetupLine(SecondAdmission.GetAdmissionCode());
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();
        SentryCapture.Start();

        // [WHEN] The guest changes only the first admission of the first line to the middle slot
        DeletedSetupResponse := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        SentryCapture.Stop();

        // [THEN] HTTP 400 reschedule_not_allowed naming the first line, the first admission and the reason LINE_NOT_CHANGEABLE, nothing moves, and no programming-bug event
        Lib.AssertNotAllowed(DeletedSetupResponse, FirstLineSystemId, Lib.GetAdmissionCode(), 'LINE_NOT_CHANGEABLE', 'F7: S8.t: Change of the first admission while the second lost its admission setup line');
        Lib.AssertNothingStoredSinceMark('F7: S8.t: Change of the first admission while the second lost its admission setup line');
        Assert.AreEqual(0, SentryCapture.Count('This is a programming bug', 'This is a programming bug'), 'F7: S8.t: The refused change must not log any Sentry event marked as a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenItemWithNoScheduleAdmission_WhenScheduledAdmissionMoves_ThenNotAllowed()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        OtherItem: Codeunit "NPR Library - TM Reschedule";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        Response: JsonObject;
        FirstLineSystemId: Guid;
    begin
        // [SCENARIO] A line whose tickets also hold an admission without a schedule cannot be changed, so a move of its scheduled admission is refused as not allowed while the line of another item could move, nothing moves, and no programming bug is logged.
        Initialize();

        // [GIVEN] An item with a second admission that has no schedule; another item; a confirmed reservation of a line of two places of the item on the early slot and a line of the other item
        OtherItem.CreateEventScenario();
        Lib.CreateEventScenario();
        Lib.AddAdmissionWithoutSchedule();
        Lib.CreateReservationWithOtherItemLine('', 0, OtherItem);
        FirstLineSystemId := Lib.LineSystemId(1);
        Lib.MarkStoredState();
        SentryCapture.Start();

        // [WHEN] The guest changes the scheduled admission of the first line to the middle slot
        Response := Lib.ChangeLine(FirstLineSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));
        SentryCapture.Stop();

        // [THEN] HTTP 400 reschedule_not_allowed naming the first line, the scheduled admission and the reason LINE_NOT_CHANGEABLE, nothing moves, and no programming-bug event
        Lib.AssertNotAllowed(Response, FirstLineSystemId, Lib.GetAdmissionCode(), 'LINE_NOT_CHANGEABLE', 'F7: RF9: Change of the scheduled admission of a line that also holds an admission without a schedule');
        Lib.AssertNothingStoredSinceMark('F7: RF9: Change of the scheduled admission of a line that also holds an admission without a schedule');
        Assert.AreEqual(0, SentryCapture.Count('This is a programming bug', 'This is a programming bug'), 'F7: RF9: The refused change must not log any Sentry event marked as a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenItemWithTwoDefaultAdmissions_WhenChange_ThenTicketsFollowTheCurrentAdmissionRow()
    var
        FirstLineRow: Record "NPR TM Ticket Reservation Req.";
        NewRow: Record "NPR TM Ticket Reservation Req.";
        Lib: Codeunit "NPR Library - TM Reschedule";
        SecondAdmission: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        ChangeResponse: JsonObject;
        FindResponse: JsonObject;
        ChainedResponse: JsonObject;
        NewSystemId: Guid;
        FirstTicket: Text;
        SecondTicket: Text;
    begin
        // [SCENARIO] For an item whose ticket setup has two default admissions, a change gives the line exactly one new systemId, on the change row of the admission of the line's former primary row; find then shows the line once and movable, and a second change by that systemId succeeds.
        Initialize();

        // [GIVEN] An item with two default admissions, and a confirmed reservation of a line of two places and a line of one place on the early slots of both admissions
        Lib.CreateEventScenario();
        SecondAdmission.CreateEventScenario();
        Lib.AddAdmission(SecondAdmission.GetAdmissionCode(), true);
        CreateReservationOnBothAdmissions(Lib, SecondAdmission);
        Lib.SnapshotLines();
        Lib.GetSnapshotRow(1, FirstLineRow);
        FirstTicket := Lib.TicketNo(1, 1);
        SecondTicket := Lib.TicketNo(1, 2);

        // [WHEN] The guest changes the first admission of the first line to the middle slot
        ChangeResponse := Lib.ChangeLine(FirstLineRow.SystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200 with exactly one result line under one new systemId; the tickets point at the change row of the admission of the line's former primary row
        Lib.AssertStatus(ChangeResponse, 200, 'S7.g: Change of a line whose item has two default admissions');
        Lib.AssertChangedLineCount(ChangeResponse, 1, 'S7.g: Change of a line whose item has two default admissions');
        NewSystemId := Lib.AssertLineMoved(ChangeResponse, 1, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'S7.g: Change of a line whose item has two default admissions');
        Assert.IsTrue(NewRow.GetBySystemId(NewSystemId), 'S7.g: The systemId of the result line must be the systemId of a stored change row.');
        Assert.AreEqual(FirstLineRow."Admission Code", NewRow."Admission Code", 'S7.g: The tickets must point at the change row of the admission of the line''s former primary row.');

        // [WHEN] The guest calls find with the first ticket and the pin right after the change
        FindResponse := Lib.FindByTicketNumber(FirstTicket, Lib.GetPin());

        // [THEN] HTTP 200 with two entries; the first line appears once, with the new systemId, and its first admission can move
        Lib.AssertStatus(FindResponse, 200, 'S7.g: Find right after the change of a line with two default admissions');
        Lib.AssertLineCount(FindResponse, 2, 'S7.g: Find right after the change of a line with two default admissions');
        Lib.AssertLineSystemId(FindResponse, 1, NewSystemId, 'S7.g: Find right after the change of a line with two default admissions');
        Lib.AssertAdmissionAllowed(FindResponse, 1, Lib.GetAdmissionCode(), true, 'S7.g: Find right after the change of a line with two default admissions');

        // [WHEN] The guest changes the first admission of the first line by the new systemId to the late slot
        ChainedResponse := Lib.ChangeLine(NewSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));

        // [THEN] HTTP 200 and both tickets of the first line on the late slot
        Lib.AssertStatus(ChainedResponse, 200, 'S7.g: Second change of the line by its new systemId');
        Lib.AssertTicketOnSlot(FirstTicket, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'S7.g: Second change of the line by its new systemId');
        Lib.AssertTicketOnSlot(SecondTicket, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'S7.g: Second change of the line by its new systemId');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenMovedLineRevokedOnItsChangeRow_WhenChangeEitherLine_ThenMovedLineNotAllowedAndOtherLineMoves()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        MovedLineResponse: JsonObject;
        OtherLineResponse: JsonObject;
        ChangeRowSystemId: Guid;
        FirstTicket: Text;
        ChangeToken: Text[100];
    begin
        // [SCENARIO] After the first line moved to the middle slot and its change row was revoked on the Ticket Request page, a change of that line is refused as not allowed with reason TICKET_BLOCKED and writes nothing, while the second line still moves to the late slot.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first line was moved to the middle slot through the SOAP change, and whose change row was then revoked on the Ticket Request page, which blocked both its tickets and set the change row to CANCELED
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstTicket := Lib.TicketNo(1, 1);
        ChangeToken := Lib.MoveLineToSlot(FirstTicket, 2);
        Lib.RevokeCurrentLineRow(FirstTicket, 'KF2.b: Change of the moved first line after its change row was revoked');
        ChangeRowSystemId := Lib.LineSystemId(ChangeToken, 1);
        Lib.SnapshotLines();
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line, by the systemId of its change row, to the late slot with the original token and the pin
        MovedLineResponse := Lib.ChangeLine(ChangeRowSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));

        // [THEN] HTTP 400 reschedule_not_allowed naming the change row, the admission and the reason TICKET_BLOCKED, and nothing is written
        Lib.AssertNotAllowed(MovedLineResponse, ChangeRowSystemId, Lib.GetAdmissionCode(), 'TICKET_BLOCKED', 'KF2.b: Change of the moved first line after its change row was revoked');
        Lib.AssertNothingStoredSinceMark('KF2.b: Change of the moved first line after its change row was revoked');

        // [WHEN] The guest changes the second line to the late slot with the original token and the pin
        OtherLineResponse := Lib.ChangeLine(Lib.LineSystemId(2), Lib.GetAdmissionCode(), Lib.SlotNo(3));

        // [THEN] HTTP 200 with the second line under a new systemId, moved to the late slot
        Lib.AssertStatus(OtherLineResponse, 200, 'KF2.a: Change of the second line after the change row of the moved first line was revoked');
        Lib.AssertLineMoved(OtherLineResponse, 1, 2, Lib.GetAdmissionCode(), Lib.SlotNo(3), 'KF2.a: Change of the second line after the change row of the moved first line was revoked');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenMovedLineRevokedAndUnblocked_WhenChangeIt_ThenNotAllowedAsLineNotChangeable()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        ChangeRowSystemId: Guid;
        FirstTicket: Text;
        SecondTicket: Text;
        ChangeToken: Text[100];
    begin
        // [SCENARIO] A moved line whose change row was revoked still cannot be changed once both its tickets are unblocked again, so its change is refused as not allowed with reason LINE_NOT_CHANGEABLE and writes nothing.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first line was moved to the middle slot through the SOAP change and whose change row was then revoked on the Ticket Request page; both tickets of the first line then unblocked
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstTicket := Lib.TicketNo(1, 1);
        SecondTicket := Lib.TicketNo(1, 2);
        ChangeToken := Lib.MoveLineToSlot(FirstTicket, 2);
        Lib.RevokeCurrentLineRow(FirstTicket, 'KF2.c: Change of the moved first line after its change row was revoked and both tickets unblocked');
        Lib.UnblockTicket(FirstTicket);
        Lib.UnblockTicket(SecondTicket);
        ChangeRowSystemId := Lib.LineSystemId(ChangeToken, 1);
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line, by the systemId of its change row, to the late slot with the original token and the pin
        Response := Lib.ChangeLine(ChangeRowSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(3));

        // [THEN] HTTP 400 reschedule_not_allowed naming the change row, the admission and the reason LINE_NOT_CHANGEABLE, and nothing is written
        Lib.AssertNotAllowed(Response, ChangeRowSystemId, Lib.GetAdmissionCode(), 'LINE_NOT_CHANGEABLE', 'KF2.c: Change of the moved first line after its change row was revoked and both tickets unblocked');
        Lib.AssertNothingStoredSinceMark('KF2.c: Change of the moved first line after its change row was revoked and both tickets unblocked');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenWaitingListLineWithoutTickets_WhenChangeEitherLine_ThenWaitingListLineInvalidAndOtherLineMoves()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        WaitingListLineResponse: JsonObject;
        OtherLineResponse: JsonObject;
        WaitingListRowSystemId: Guid;
    begin
        // [SCENARIO] A line whose primary row is on the waiting list and holds no ticket cannot be changed, so a change of it is refused as an invalid reference naming its primary row and the admission and writes nothing, while the other line still moves to the middle slot.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first line became a waiting-list line, with its primary row set to WAITINGLIST and both its tickets deleted
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.PutLineOnWaitingListWithoutTickets(1, 'KF4.b: Change of the waiting-list first line by the systemId of its primary row');
        WaitingListRowSystemId := Lib.LineSystemId(1);
        Lib.SnapshotLines();
        Lib.MarkStoredState();

        // [WHEN] The guest changes the first line, by the systemId of its primary row, to the middle slot with the original token and the pin
        WaitingListLineResponse := Lib.ChangeLine(WaitingListRowSystemId, Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 400 invalid_reference naming the primary row of the first line and the admission, and nothing is written
        Lib.AssertInvalidReference(WaitingListLineResponse, WaitingListRowSystemId, Lib.GetAdmissionCode(), 'KF4.b: Change of the waiting-list first line by the systemId of its primary row');
        Lib.AssertNothingStoredSinceMark('KF4.b: Change of the waiting-list first line by the systemId of its primary row');

        // [WHEN] The guest changes the second line to the middle slot with the original token and the pin
        OtherLineResponse := Lib.ChangeLine(Lib.LineSystemId(2), Lib.GetAdmissionCode(), Lib.SlotNo(2));

        // [THEN] HTTP 200 with the second line under a new systemId, moved to the middle slot
        Lib.AssertStatus(OtherLineResponse, 200, 'KF4.a: Change of the second line to the middle slot while the first line is on the waiting list without tickets');
        Lib.AssertLineMoved(OtherLineResponse, 1, 2, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'KF4.a: Change of the second line to the middle slot while the first line is on the waiting list without tickets');
    end;
    #endregion

    [HttpClientHandler]
    procedure NpPassHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    begin
        if (Request.RequestType = HttpRequestType::Put) then
            _NpPassPutCount += 1;
        if (Request.RequestType = HttpRequestType::Get) then
            _NpPassGetCount += 1;
        case _NpPassMode of
            _NpPassMode::Refuses:
                begin
                    Response.HttpStatusCode := 500;
                    Response.Content.WriteFrom(NpPassRefusalTok);
                end;
            _NpPassMode::Unreachable:
                Response.IsSuccessfulRequest := false;
            _NpPassMode::AcceptsPutBreaksGet:
                begin
                    Response.HttpStatusCode := 200;
                    if (Request.RequestType = HttpRequestType::Put) then
                        Response.Content.WriteFrom('{}')
                    else
                        Response.Content.WriteFrom(MalformedPassJsonTok);
                end;
            _NpPassMode::AcceptsFirstPassBreaksSecondGet:
                begin
                    Response.HttpStatusCode := 200;
                    if ((Request.RequestType = HttpRequestType::Get) and (_NpPassGetCount > 1)) then
                        Response.Content.WriteFrom(MalformedPassJsonTok)
                    else
                        Response.Content.WriteFrom('{}');
                end;
        end;
        exit(false);
    end;

    // The e-ticket subscriber shows the failure of each e-ticket update as a message; the latest failed update must carry the same text.
    [MessageHandler]
    procedure ETicketFailureMessageHandler(Message: Text)
    var
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        Assert: Codeunit Assert;
    begin
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::FAILED);
        Assert.IsTrue(NotificationEntry.FindLast(), StrSubstNo(ETicketMessageErr, _NpPassRowId));
        Assert.AreEqual(NotificationEntry."Failed With Message", CopyStr(Message, 1, MaxStrLen(NotificationEntry."Failed With Message")), StrSubstNo(ETicketMessageErr, _NpPassRowId));
    end;

    local procedure UseNpPass(Mode: Option Refuses,Unreachable,AcceptsPutBreaksGet,AcceptsFirstPassBreaksSecondGet; RowId: Text)
    begin
        _NpPassMode := Mode;
        _NpPassRowId := RowId;
        _NpPassPutCount := 0;
        _NpPassGetCount := 0;
    end;

    local procedure CreateReservationOnBothAdmissions(var Lib: Codeunit "NPR Library - TM Reschedule"; var SecondAdmission: Codeunit "NPR Library - TM Reschedule")
    var
        Lines: JsonArray;
    begin
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddAdmissionToLastReserveLine(Lines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1));
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddAdmissionToLastReserveLine(Lines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1));
        Lib.CreateReservation(Lines);
        Lib.ConfirmReservation(Lib.GetToken());
    end;

    local procedure AssertTokenOfCall(var ConfirmSub: Codeunit "NPR TM Change Confirm Sub"; CallNo: Integer; LineSystemId: Guid; Context: Text)
    var
        ChangeRow: Record "NPR TM Ticket Reservation Req.";
        Assert: Codeunit Assert;
        TokenOfCallErr: Label '%1: Confirm event %2 must carry the token %3 of the change request of line %2.', Locked = true;
    begin
        ChangeRow.GetBySystemId(LineSystemId);
        Assert.AreEqual(ChangeRow."Session Token ID", ConfirmSub.TokenOfCall(CallNo), StrSubstNo(TokenOfCallErr, Context, CallNo, ChangeRow."Session Token ID"));
    end;

    local procedure Initialize()
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
    begin
        if (_IsInitialized) then
            exit;
        LibraryAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Ticketing');
        _IsInitialized := true;
    end;
}

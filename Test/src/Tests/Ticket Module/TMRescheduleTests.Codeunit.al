codeunit 85501 "NPR TM Reschedule Tests"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;

    #region Lookup
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoLineReservation_WhenFindByAnyTicketOrTheToken_ThenWholeReservationIsReturned()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        FirstTicketResponse: JsonObject;
        SecondLineResponse: JsonObject;
        LowerCaseResponse: JsonObject;
        TokenResponse: JsonObject;
        PinCode: Text;
    begin
        // [SCENARIO] Find by a ticket of either line, by a ticket number in lower case or by the original token returns the same whole reservation, each line movable to the other slots of the day, with nothing secret or personal in the body.
        Initialize();

        // [GIVEN] A confirmed reservation with a line of two places and a line of one place, both on the early slot of the event day, confirmed with a notification address and a ticket holder name
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        PinCode := Lib.GetPin();

        // [WHEN] The guest calls find with the first ticket of the first line, the ticket of the second line, the first ticket number in lower case and the original token, each with the pin
        FirstTicketResponse := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), PinCode);
        SecondLineResponse := Lib.FindByTicketNumber(Lib.TicketNo(2, 1), PinCode);
        LowerCaseResponse := Lib.FindByTicketNumber(LowerCase(Lib.TicketNo(1, 1)), PinCode);
        TokenResponse := Lib.FindByToken(Lib.GetToken(), PinCode);

        // [THEN] The find by the first ticket answers HTTP 200 with the original token and both lines, each movable to the middle and late slots
        AssertBothLinesOnEarlySlot(Lib, FirstTicketResponse, 'S1.a: Find by the first ticket of the first line');

        // [THEN] The admission of the first line can move, has no reason code and offers the middle and late slots
        Lib.AssertStatus(FirstTicketResponse, 200, 'S4.a: Find with nothing admitted');
        Lib.AssertAdmission(FirstTicketResponse, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S4.a: Find with nothing admitted');

        // [THEN] The middle slot carries its schedule id, dates on the event day, start and end times, and remaining capacity 1000
        Lib.AssertStatus(FirstTicketResponse, 200, 'S5.a: Find with an open middle slot');
        Lib.AssertAdmission(FirstTicketResponse, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S5.a: Find with an open middle slot');
        Lib.AssertSlotShape(FirstTicketResponse, 1, Lib.SlotNo(2), Lib.GetEventDate(), 'S5.a: Find with an open middle slot');
        Lib.AssertSlotCapacity(FirstTicketResponse, 1, Lib.SlotNo(2), 1000, 'S5.a: Find with an open middle slot');

        // [THEN] The early slot the first line is on is not offered to that line
        Lib.AssertStatus(FirstTicketResponse, 200, 'S5.b: Find for a line on the early slot');
        Lib.AssertAdmission(FirstTicketResponse, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S5.b: Find for a line on the early slot');

        // [THEN] The body contains none of the pin, the address, the holder name and the three ticket numbers
        Lib.AssertStatus(FirstTicketResponse, 200, 'S17.a: Find for the leak check');
        Lib.AssertBodyOmits(FirstTicketResponse, PinCode, 'pin', 'S17.a: Find for the leak check');
        Lib.AssertBodyOmits(FirstTicketResponse, Lib.NotificationAddress(), 'notification address', 'S17.a: Find for the leak check');
        Lib.AssertBodyOmits(FirstTicketResponse, Lib.TicketHolderName(), 'ticket holder name', 'S17.a: Find for the leak check');
        Lib.AssertBodyOmits(FirstTicketResponse, Lib.TicketNo(1, 1), 'first ticket number of the first line', 'S17.a: Find for the leak check');
        Lib.AssertBodyOmits(FirstTicketResponse, Lib.TicketNo(1, 2), 'second ticket number of the first line', 'S17.a: Find for the leak check');
        Lib.AssertBodyOmits(FirstTicketResponse, Lib.TicketNo(2, 1), 'ticket number of the second line', 'S17.a: Find for the leak check');

        // [THEN] The finds by the ticket of the second line, by the lower-case ticket number and by the original token answer with the same body
        AssertBothLinesOnEarlySlot(Lib, SecondLineResponse, 'S1.b: Find by the ticket of the second line');
        AssertBothLinesOnEarlySlot(Lib, LowerCaseResponse, 'S1.c: Find by the first ticket number in lower case');
        AssertBothLinesOnEarlySlot(Lib, TokenResponse, 'S2.a: Find by the original token');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFirstLineMoved_WhenFindByTicketOrEitherToken_ThenMovedLineShowsNewRowAndFormerSlot()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        TicketResponse: JsonObject;
        OriginalTokenResponse: JsonObject;
        ChangeTokenResponse: JsonObject;
        FirstTicket: Text;
        PinCode: Text;
        ChangeToken: Text[100];
    begin
        // [SCENARIO] After the first line moved to the middle slot, find by its ticket, by the original token or by the change token returns the original token, the moved line on its new primary row with its former slot offered again, and the second line unchanged.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first line was moved to the middle slot under a change token
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstTicket := Lib.TicketNo(1, 1);
        ChangeToken := Lib.MoveLineToSlot(FirstTicket, 2);
        PinCode := Lib.GetPin();

        // [WHEN] The guest calls find with the first ticket of the moved line, with the original token and with the change token, each with the pin
        TicketResponse := Lib.FindByTicketNumber(FirstTicket, PinCode);
        OriginalTokenResponse := Lib.FindByToken(Lib.GetToken(), PinCode);
        ChangeTokenResponse := Lib.FindByToken(ChangeToken, PinCode);

        // [THEN] The find by the ticket answers HTTP 200 with the original token, the first line on the middle slot and the second line still on the early slot
        AssertFirstLineOnMiddleSlot(Lib, TicketResponse, FirstTicket, ChangeToken, 'S1.d: Find by a ticket of the moved line');

        // [THEN] The moved line offers the early slot it left and the late slot
        Lib.AssertStatus(TicketResponse, 200, 'S5.o: Find after the first line moved to the middle slot');
        Lib.AssertAdmission(TicketResponse, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(1), Lib.SlotNo(3)), 'S5.o: Find after the first line moved to the middle slot');

        // [THEN] The finds by the original token and by the change token answer with the same body, including the original token
        AssertFirstLineOnMiddleSlot(Lib, OriginalTokenResponse, FirstTicket, ChangeToken, 'S2.b: Find by the original token after the move');
        AssertFirstLineOnMiddleSlot(Lib, ChangeTokenResponse, FirstTicket, ChangeToken, 'S2.c: Find by the change token of the moved line');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineChangedTwice_WhenFindByTicket_ThenLineShowsTheRowAndSlotOfTheLastChange()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        FirstTicket: Text;
        SecondChangeToken: Text[100];
    begin
        // [SCENARIO] A line moved from the early to the middle slot and then to the late slot is shown on the row of the second change, which holds its tickets, with the late slot as current slot and both former slots offered.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first line was moved to the middle slot and then to the late slot through two SOAP changes
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstTicket := Lib.TicketNo(1, 1);
        Lib.MoveLineToSlot(FirstTicket, 2);
        SecondChangeToken := Lib.MoveLineToSlot(FirstTicket, 3);

        // [WHEN] The guest calls find with the first ticket of the moved line and the pin
        Response := Lib.FindByTicketNumber(FirstTicket, Lib.GetPin());

        // [THEN] HTTP 200 with the original token and both lines
        Lib.AssertStatus(Response, 200, 'A4a: Find after the first line was changed twice');
        Lib.AssertReservationToken(Response, Lib.GetToken(), 'A4a: Find after the first line was changed twice');
        Lib.AssertLineCount(Response, 2, 'A4a: Find after the first line was changed twice');

        // [THEN] The moved line carries the row of the second change and the late slot as current slot, and offers the early and middle slots
        Lib.AssertMovableLine(Response, 1, FirstTicket, 2, Lib.LineSystemId(SecondChangeToken, 1), Lib.SlotNo(3), Lib.SlotIds(Lib.SlotNo(1), Lib.SlotNo(2)), 'A4a: Find after the first line was changed twice');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenItemWithTwoDefaultAdmissionsChangedOnce_WhenFind_ThenMovedSlotIsCurrent()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Lib: Codeunit "NPR Library - TM Reschedule";
        SecondAdmission: Codeunit "NPR Library - TM Reschedule";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        Response: JsonObject;
        Lines: JsonArray;
        FirstTicket: Text;
        ChangeToken: Text[100];
    begin
        // [SCENARIO] After a SOAP change of a line whose item has two default admissions, find shows the line on the change row that holds its tickets, with the moved slot as the current slot of the moved admission, instead of an internal error.
        Initialize();

        // [GIVEN] An item with a second default admission, a confirmed reservation of one line of two places on the early slot of the first admission and the early slot of the second, and the first admission of the line then moved to the middle slot through the SOAP change
        Lib.CreateEventScenario();
        SecondAdmission.CreateEventScenario();
        LibraryTicketModule.CreateTicketBOM(Lib.GetItemNo(), '', SecondAdmission.GetAdmissionCode(), '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddAdmissionToLastReserveLine(Lines, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1));
        Lib.CreateReservation(Lines);
        Lib.ConfirmReservation(Lib.GetToken());
        FirstTicket := Lib.TicketNo(1, 1);
        ChangeToken := Lib.MoveLineToSlot(FirstTicket, 2);

        // [WHEN] The guest calls find with the first ticket of the line and the pin
        Response := Lib.FindByTicketNumber(FirstTicket, Lib.GetPin());

        // [THEN] HTTP 200 with the line on the change row that holds its tickets
        Lib.AssertStatus(Response, 200, 'A4b: Find after a change of an item with two default admissions');
        Lib.AssertLineSystemId(Response, 1, Lib.LineSystemId(ChangeToken, 1), 'A4b: Find after a change of an item with two default admissions');

        // [THEN] The first admission has the middle slot as current slot and offers the early and late slots
        Lib.AssertCurrentSchedule(Response, 1, Lib.GetAdmissionCode(), Lib.SlotNo(2), 'A4b: Find after a change of an item with two default admissions');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(1), Lib.SlotNo(3)), 'A4b: Find after a change of an item with two default admissions');

        // [THEN] The second admission keeps its early slot as current slot
        Lib.AssertCurrentSchedule(Response, 1, SecondAdmission.GetAdmissionCode(), SecondAdmission.SlotNo(1), 'A4b: Find after a change of an item with two default admissions');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUnconfirmedChangeRequest_WhenFind_ThenLineStaysOnItsSlot()
    var
        TempChangeRequest: Record "NPR TM Ticket Reservation Req." temporary;
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A change request that was registered but never confirmed does not move the line, so find still shows the line on its original row and slot.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot and a SOAP change request for the first line that was never confirmed
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.RequestLineChange(Lib.TicketNo(1, 1), TempChangeRequest);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] Both lines stay on their original rows on the early slot and offer the middle and late slots
        AssertBothLinesOnEarlySlot(Lib, Response, 'A4c: Find after a change request that was never confirmed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenGroupLineOfTenPlaces_WhenFind_ThenQuantityIsTenAndSlotWithNineLeftIsNotOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Lines: JsonArray;
    begin
        // [SCENARIO] A group line of ten places held by one ticket reports quantity 10, and capacity is checked for those ten places, so a Sales slot of capacity 12 with 3 sold, which has 9 places left, is not offered.
        Initialize();

        // [GIVEN] A confirmed reservation with one group-registration line of ten places on the early slot, the middle slot under Sales control with capacity 12, and 3 places sold on it
        Lib.CreateEventScenario();
        Lib.UseGroupRegistration();
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 10, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(Lines);
        Lib.ConfirmReservation(Lib.GetToken());
        Assert.AreEqual(1, Lib.TicketCount(1), 'S1.e: Setup: group registration must issue one ticket for the whole line of ten places.');
        Lib.SetSlotSalesCapacity(2, 12);
        Lib.SellPlaces(2, 3);

        // [WHEN] The guest calls find with the single ticket of the group line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] HTTP 200 with the group line and quantity 10
        Lib.AssertStatus(Response, 200, 'S1.e: Find by the ticket of a group line');
        Lib.AssertLineCount(Response, 1, 'S1.e: Find by the ticket of a group line');
        Lib.AssertLineQuantity(Response, 1, 10, 'S1.e: Find by the ticket of a group line');

        // [THEN] The group line offers only the late slot
        Lib.AssertStatus(Response, 200, 'S5.p: Find for a group line of 10 places with 9 left on the middle slot');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(3)), 'S5.p: Find for a group line of 10 places with 9 left on the middle slot');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenWrongPinUnknownIdentifierOrLongPin_WhenFind_ThenUniformNotFoundPerIdentifierKind()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        WrongPinResponse: JsonObject;
        UnknownTicketResponse: JsonObject;
        LongPinResponse: JsonObject;
        TokenWrongPinResponse: JsonObject;
        UnknownTokenResponse: JsonObject;
    begin
        // [SCENARIO] A wrong pin, an unknown ticket number or token, and a pin longer than ten characters all get the same uniform not-found error for their identifier kind.
        Initialize();

        // [GIVEN] A confirmed reservation with a line of two places and a line of one place on the early slot
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);

        // [WHEN] The guest calls find with the first ticket and the pin with its last digit changed, with the ticket number NOPE-1, with the first ticket and the pin 1234-5678-9, with the original token and the changed pin, and with a token of 32 zeros
        WrongPinResponse := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), WithLastDigitChanged(Lib.GetPin()));
        UnknownTicketResponse := Lib.FindByTicketNumber('NOPE-1', Lib.GetPin());
        LongPinResponse := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), '1234-5678-9');
        TokenWrongPinResponse := Lib.FindByToken(Lib.GetToken(), WithLastDigitChanged(Lib.GetPin()));
        UnknownTokenResponse := Lib.FindByToken('00000000000000000000000000000000', Lib.GetPin());

        // [THEN] Each ticket number call answers HTTP 404 resource_not_found with the ticket number message
        Lib.AssertUniformNotFound(WrongPinResponse, Lib.TicketNotFoundMessage(), 'S3.a: Find by ticket number with a wrong pin');
        Lib.AssertUniformNotFound(UnknownTicketResponse, Lib.TicketNotFoundMessage(), 'S3.b: Find by an unknown ticket number');
        Lib.AssertUniformNotFound(LongPinResponse, Lib.TicketNotFoundMessage(), 'S3.i: Find with a pin of eleven characters');

        // [THEN] Each token call answers HTTP 404 resource_not_found with the reservation token message
        Lib.AssertUniformNotFound(TokenWrongPinResponse, Lib.TokenNotFoundMessage(), 'S3.g: Find by token with a wrong pin');
        Lib.AssertUniformNotFound(UnknownTokenResponse, Lib.TokenNotFoundMessage(), 'S3.h: Find by an unknown token');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenWildcardTicketNumberOrToken_WhenFind_ThenUniformNotFound()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        AnyTicketResponse: JsonObject;
        OneCharacterTicketResponse: JsonObject;
        AnyTokenResponse: JsonObject;
        SecondTicket: Text;
    begin
        // [SCENARIO] A ticket number or token holding a filter wildcard is compared as a literal value, so * and ? never find a reservation, even with its right pin.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose first ticket number and token were rewritten to sort before every other ticket number and token, so a wildcard in either identifier would land on this reservation
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SortIdentifiersFirst();
        SecondTicket := Lib.TicketNo(1, 2);

        // [WHEN] The guest calls find with the ticket number *, with the second ticket number whose last character is replaced by ?, and with the token *, each with the pin of the reservation
        AnyTicketResponse := Lib.FindByTicketNumber('*', Lib.GetPin());
        OneCharacterTicketResponse := Lib.FindByTicketNumber(CopyStr(SecondTicket, 1, StrLen(SecondTicket) - 1) + '?', Lib.GetPin());
        AnyTokenResponse := Lib.FindByToken('*', Lib.GetPin());

        // [THEN] Each ticket number call answers HTTP 404 resource_not_found with the ticket number message
        Lib.AssertUniformNotFound(AnyTicketResponse, Lib.TicketNotFoundMessage(), 'A3: Find by the ticket number *');
        Lib.AssertUniformNotFound(OneCharacterTicketResponse, Lib.TicketNotFoundMessage(), 'A3: Find by the second ticket number with ? as its last character');

        // [THEN] The token call answers HTTP 404 resource_not_found with the reservation token message
        Lib.AssertUniformNotFound(AnyTokenResponse, Lib.TokenNotFoundMessage(), 'A3: Find by the token *');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenBlockedTicket_WhenFindByIt_ThenUniformNotFound()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        FirstTicket: Text;
    begin
        // [SCENARIO] A blocked ticket cannot be used to find its reservation, even with the right pin.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose first ticket is blocked
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstTicket := Lib.TicketNo(1, 1);
        Lib.BlockTicket(FirstTicket);

        // [WHEN] The guest calls find with the blocked ticket and the pin
        Response := Lib.FindByTicketNumber(FirstTicket, Lib.GetPin());

        // [THEN] HTTP 404 resource_not_found with the ticket number message
        Lib.AssertUniformNotFound(Response, Lib.TicketNotFoundMessage(), 'S3.c: Find by a blocked ticket');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUnconfirmedReservation_WhenFind_ThenUniformNotFound()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        Lines: JsonArray;
    begin
        // [SCENARIO] A reservation that was registered but not confirmed is refused with the uniform not-found error.
        Initialize();

        // [GIVEN] A two-line reservation on the early slot that is registered but not confirmed
        Lib.CreateEventScenario();
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(Lines);

        // [WHEN] The guest calls find with the first ticket and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] HTTP 404 resource_not_found with the ticket number message
        Lib.AssertUniformNotFound(Response, Lib.TicketNotFoundMessage(), 'S3.d: Find on an unconfirmed reservation');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenPolicyNotAllowed_WhenFind_ThenUniformNotFound()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A reservation where no admission can move because the policy is Not Allowed is refused with the uniform not-found error.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose item has the reschedule policy Not Allowed
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetPolicy(TicketBom."Reschedule Policy"::NOT_ALLOWED, 0);

        // [WHEN] The guest calls find with the first ticket and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] HTTP 404 resource_not_found with the ticket number message
        Lib.AssertUniformNotFound(Response, Lib.TicketNotFoundMessage(), 'S3.e: Find when the policy does not allow a move');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTicketsValidUntilYesterday_WhenFind_ThenUniformNotFound()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A reservation whose tickets' validity ended before the reference date is refused with the uniform not-found error.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose tickets were valid until yesterday
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetTicketValidity(Lib.LocalToday() - 8, Lib.LocalToday() - 1);

        // [WHEN] The guest calls find with the first ticket and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] HTTP 404 resource_not_found with the ticket number message
        Lib.AssertUniformNotFound(Response, Lib.TicketNotFoundMessage(), 'S3.f: Find when every ticket has expired');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLetterPinInLowerCase_WhenFind_ThenReservationIsReturned()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        Response: JsonObject;
        PinCode: Text;
        LetterPinSetupErr: Label 'S3.j: Setup: the letter pin scheme must give a pin with letters, got %1.', Locked = true;
    begin
        // [SCENARIO] A pin with letters is compared case-insensitively, so the lower-case pin finds the reservation.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose pin scheme produces letters
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservationWithLetterPin();
        PinCode := Lib.GetPin();
        Assert.AreNotEqual(LowerCase(PinCode), UpperCase(PinCode), StrSubstNo(LetterPinSetupErr, PinCode));

        // [WHEN] The guest calls find with the first ticket and the pin in lower case
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), LowerCase(PinCode));

        // [THEN] HTTP 200 with the reservation of the original token
        Lib.AssertStatus(Response, 200, 'S3.j: Find with a letter pin in lower case');
        Lib.AssertReservationToken(Response, Lib.GetToken(), 'S3.j: Find with a letter pin in lower case');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenWrongPinAndNoPinFindsBefore_WhenFindWithTheRightPin_ThenReservationIsReturned()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        NoPinBody: JsonObject;
        Response: JsonObject;
        FirstTicket: Text;
        Attempt: Integer;
    begin
        // [SCENARIO] Failed find calls leave no record, so the right pin still finds the reservation after six calls with a wrong pin and six calls refused for a missing pinCode.
        Initialize();

        // [GIVEN] A confirmed two-line reservation, six find calls with a wrong pin for its first ticket and six find calls without pinCode for the same ticket
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        FirstTicket := Lib.TicketNo(1, 1);
        for Attempt := 1 to 6 do begin
            Lib.FindByTicketNumber(FirstTicket, WithLastDigitChanged(Lib.GetPin()));
            Clear(NoPinBody);
            NoPinBody.Add('ticketNumber', FirstTicket);
            Lib.CallFind(NoPinBody);
        end;

        // [WHEN] The guest calls find with the first ticket and the right pin
        Response := Lib.FindByTicketNumber(FirstTicket, Lib.GetPin());

        // [THEN] HTTP 200 with the reservation of the original token
        Lib.AssertStatus(Response, 200, 'S3.k, S10.j: Find with the right pin after six wrong pins and six finds without pinCode');
        Lib.AssertReservationToken(Response, Lib.GetToken(), 'S3.k, S10.j: Find with the right pin after six wrong pins and six finds without pinCode');
    end;
    #endregion

    #region Input
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenNoDatesOrSixtyTwoDayWindow_WhenFind_ThenWindowEndsAtOneMonthOrSixtyTwoDays()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        DefaultWindowResponse: JsonObject;
        LongWindowResponse: JsonObject;
        LastWindowDaySlotNo: Integer;
        DayAfterWindowSlotNo: Integer;
    begin
        // [SCENARIO] Without fromDate and toDate the window runs from today through today plus one month, and a window of exactly 62 days is accepted and reaches past that month.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose tickets stay valid for 62 days, with the middle slot copied to today plus one month and to the day after it
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetTicketValidity(Today(), Today() + 62);
        LastWindowDaySlotNo := Lib.CopySlotToDate(2, CalcDate('<+1M>', Today()));
        DayAfterWindowSlotNo := Lib.CopySlotToDate(2, CalcDate('<+1M>', Today()) + 1);

        // [WHEN] The guest calls find without fromDate and toDate, and with fromDate today and toDate today plus 62 days
        DefaultWindowResponse := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());
        LongWindowResponse := Lib.FindByTicketNumberInWindow(Lib.TicketNo(1, 1), Lib.GetPin(), Format(Today(), 0, 9), Format(Today() + 62, 0, 9));

        // [THEN] Without dates, the first line offers the middle and late slots of the event day and the copy on today plus one month, not the copy on the day after
        Lib.AssertStatus(DefaultWindowResponse, 200, 'S6.a: Find without a window');
        Lib.AssertAdmission(DefaultWindowResponse, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3), LastWindowDaySlotNo), 'S6.a: Find without a window');

        // [THEN] With the 62-day window, HTTP 200 and the first line offers both copies as well
        Lib.AssertStatus(LongWindowResponse, 200, 'S6.g: Find with a window of 62 days');
        Lib.AssertAdmission(LongWindowResponse, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)) + ',' + Lib.SlotIds(LastWindowDaySlotNo, DayAfterWindowSlotNo), 'S6.g: Find with a window of 62 days');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenWindowOfTheEventDayOnly_WhenFind_ThenOnlySlotsOfThatDayAreOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        EventDayText: Text;
    begin
        // [SCENARIO] A window from the event day to the event day offers only the slots of that day.
        Initialize();

        // [GIVEN] A confirmed two-line reservation and a copy of the middle slot on the day after the event day, inside the ticket validity
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.CopySlotToDate(2, Lib.GetEventDate() + 1);
        EventDayText := Format(Lib.GetEventDate(), 0, 9);

        // [WHEN] The guest calls find with fromDate and toDate both set to the event day
        Response := Lib.FindByTicketNumberInWindow(Lib.TicketNo(1, 1), Lib.GetPin(), EventDayText, EventDayText);

        // [THEN] The first line offers only the middle and late slots of the event day
        Lib.AssertStatus(Response, 200, 'S6.b: Find with a one-day window');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S6.b: Find with a one-day window');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenFromDateAfterTicketValidity_WhenFind_ThenAdmissionCanMoveButNoSlotIsOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A fromDate of today plus 10 days opens a one-month window that starts after the tickets' validity, so no slot is offered while the admission can still move.
        Initialize();

        // [GIVEN] A confirmed two-line reservation valid through today plus 7 days, and a copy of the middle slot on today plus 12 days
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.CopySlotToDate(2, Today() + 12);

        // [WHEN] The guest calls find with fromDate today plus 10 days and no toDate
        Response := Lib.FindByTicketNumberInWindow(Lib.TicketNo(1, 1), Lib.GetPin(), Format(Today() + 10, 0, 9), '');

        // [THEN] HTTP 200, the first line can move and its slot list is empty
        Lib.AssertStatus(Response, 200, 'S6.f: Find with fromDate after the ticket validity');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', '', 'S6.f: Find with fromDate after the ticket validity');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenInvalidWindowOrBody_WhenFind_ThenEachIsRefusedAsInvalidInput()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        NoPinBody: JsonObject;
        BothIdentifiersBody: JsonObject;
        NoIdentifierBody: JsonObject;
        Identity: JsonObject;
        ArrayBody: JsonArray;
        FromAfterToResponse: JsonObject;
        LongWindowResponse: JsonObject;
        BadDateResponse: JsonObject;
        NoPinResponse: JsonObject;
        BothIdentifiersResponse: JsonObject;
        NoIdentifierResponse: JsonObject;
        ArrayResponse: JsonObject;
    begin
        // [SCENARIO] A find whose window is reversed, longer than 62 days or not in yyyy-mm-dd form, or whose body lacks pinCode, has both or neither identifier, or is a JSON array, is refused as invalid input.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose ticket and pin are valid, and find bodies without pinCode, with both ticketNumber and reservationToken, with only pinCode, and a JSON array holding an otherwise valid find object
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        NoPinBody.Add('ticketNumber', Lib.TicketNo(1, 1));
        BothIdentifiersBody.Add('ticketNumber', Lib.TicketNo(1, 1));
        BothIdentifiersBody.Add('reservationToken', Lib.GetToken());
        BothIdentifiersBody.Add('pinCode', Lib.GetPin());
        NoIdentifierBody.Add('pinCode', Lib.GetPin());
        Identity.Add('ticketNumber', Lib.TicketNo(1, 1));
        Identity.Add('pinCode', Lib.GetPin());
        ArrayBody.Add(Identity);

        // [WHEN] The guest calls find with fromDate after toDate, with a window of 63 days, with fromDate 2026-13-01, and with each of the four bodies
        FromAfterToResponse := Lib.FindByTicketNumberInWindow(Lib.TicketNo(1, 1), Lib.GetPin(), Format(Lib.GetEventDate(), 0, 9), Format(Lib.GetEventDate() - 1, 0, 9));
        LongWindowResponse := Lib.FindByTicketNumberInWindow(Lib.TicketNo(1, 1), Lib.GetPin(), Format(Today(), 0, 9), Format(Today() + 63, 0, 9));
        BadDateResponse := Lib.FindByTicketNumberInWindow(Lib.TicketNo(1, 1), Lib.GetPin(), '2026-13-01', '');
        NoPinResponse := Lib.CallFind(NoPinBody);
        BothIdentifiersResponse := Lib.CallFind(BothIdentifiersBody);
        NoIdentifierResponse := Lib.CallFind(NoIdentifierBody);
        ArrayResponse := CallFindWithArrayBody(ArrayBody);

        // [THEN] Each window defect answers HTTP 400 invalid_input
        Lib.AssertInvalidInput(FromAfterToResponse, 'S6.c: Find with fromDate after toDate');
        Lib.AssertInvalidInput(LongWindowResponse, 'S6.d: Find with a window of 63 days');
        Lib.AssertInvalidInput(BadDateResponse, 'S6.e: Find with fromDate 2026-13-01');

        // [THEN] The body without pinCode answers HTTP 400 invalid_input naming pinCode
        Lib.AssertInvalidInputNaming(NoPinResponse, 'pinCode', 'S10.a: Find without pinCode');

        // [THEN] Each other body defect answers HTTP 400 invalid_input
        Lib.AssertInvalidInput(BothIdentifiersResponse, 'S10.b: Find with both ticketNumber and reservationToken');
        Lib.AssertInvalidInput(NoIdentifierResponse, 'S10.c: Find with neither ticketNumber nor reservationToken');
        Lib.AssertInvalidInput(ArrayResponse, 'S10.i: Find with a JSON array body');
    end;
    #endregion

    #region Reason
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOneTicketOfTheLineAdmitted_WhenFind_ThenAlreadyAdmitted()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] Under Until Admitted or Expired, one admitted ticket of the line stops the admission from moving for the whole line.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first ticket of the first line was admitted and the second was not
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.MarkAdmitted(Lib.TicketNo(1, 1));

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line cannot move, reason ALREADY_ADMITTED, and no slot is offered
        Lib.AssertStatus(Response, 200, 'S4.b: Find with one ticket of the line admitted');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'ALREADY_ADMITTED', '', 'S4.b: Find with one ticket of the line admitted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenCurrentSlotEnded_WhenFind_ThenSlotPassed()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] Under Until Admitted or Expired, an admission whose current slot has ended cannot move, reason SLOT_PASSED.
        Initialize();

        // [GIVEN] A confirmed reservation with the first line on the early slot and the second on the late slot; the early slot then ended yesterday without an arrival-until time
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 3);
        Lib.MoveSlotToYesterday(1);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line cannot move, reason SLOT_PASSED, and no slot is offered
        Lib.AssertStatus(Response, 200, 'S4.c: Find with the current slot ended');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'SLOT_PASSED', '', 'S4.c: Find with the current slot ended');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenArrivalUntilPassedBeforeSlotEnd_WhenFind_ThenSlotPassed()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] Under Until Admitted or Expired, the arrival-until time closes the slot, so an admission whose slot ends in two hours but whose arrival-until passed an hour ago cannot move.
        Initialize();

        // [GIVEN] A confirmed reservation with the first line on the early slot and the second on the late slot; the early slot now ends in 2 hours and its arrival-until time passed 1 hour ago
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 3);
        Lib.PlaceSlotTodayAroundNow(1, 120, -60);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line cannot move, reason SLOT_PASSED, and no slot is offered
        Lib.AssertStatus(Response, 200, 'S4.k: Find with the arrival-until time passed');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'SLOT_PASSED', '', 'S4.k: Find with the arrival-until time passed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSlotEndedButArrivalStillOpen_WhenFind_ThenAdmissionCanMove()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] Under Until Admitted or Expired, a slot whose end time passed but whose arrival-until time lies ahead is still open, so the admission can move.
        Initialize();

        // [GIVEN] A confirmed reservation with the first line on the early slot and the second on the late slot; the early slot ended 1 hour ago and its arrival-until time is 1 hour ahead
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 3);
        Lib.PlaceSlotTodayAroundNow(1, -60, 60);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line can move, has no reason code and offers the slots after now within the validity
        Lib.AssertStatus(Response, 200, 'S4.l: Find with the arrival-until time ahead');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S4.l: Find with the arrival-until time ahead');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenCurrentSlotCancelled_WhenFind_ThenSlotCancelled()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] An admission whose current slot is cancelled cannot move under any policy, reason SLOT_CANCELLED.
        Initialize();

        // [GIVEN] A confirmed reservation with the first line on the early slot and the second on the late slot; the early slot is then cancelled
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 3);
        Lib.CancelSlot(1);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line cannot move, reason SLOT_CANCELLED, and no slot is offered
        Lib.AssertStatus(Response, 200, 'S4.j: Find with the current slot cancelled');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'SLOT_CANCELLED', '', 'S4.j: Find with the current slot cancelled');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenCutOffBeforeSlotCloses_WhenFind_ThenAdmissionCanMove()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] Under Cut-Off (Hours) 24, a current slot that closes in 30 hours is still beyond the cut-off, so the admission can move.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, policy Cut-Off (Hours) 24, and the early slot closing in 30 hours without an arrival-until time
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetPolicy(TicketBom."Reschedule Policy"::CUTOFF_HOUR, 24);
        Lib.SetSlotClosingInHours(1, 30);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line can move, has no reason code and offers the middle and late slots
        Lib.AssertStatus(Response, 200, 'S4.d: Find with the cut-off before the slot closes');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S4.d: Find with the cut-off before the slot closes');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenCutOffPastSlotClose_WhenFind_ThenCutoffPassed()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] Under Cut-Off (Hours) 24, a current slot that closes in 20 hours is inside the cut-off, so the admission cannot move, reason CUTOFF_PASSED.
        Initialize();

        // [GIVEN] A confirmed reservation with the first line on the early slot and the second on the late slot, policy Cut-Off (Hours) 24, and the early slot closing in 20 hours
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 3);
        Lib.SetPolicy(TicketBom."Reschedule Policy"::CUTOFF_HOUR, 24);
        Lib.SetSlotClosingInHours(1, 20);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line cannot move, reason CUTOFF_PASSED, and no slot is offered
        Lib.AssertStatus(Response, 200, 'S4.e: Find with the cut-off past the slot close');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'CUTOFF_PASSED', '', 'S4.e: Find with the cut-off past the slot close');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUntilAdmittedAndOneTicketAdmitted_WhenFind_ThenAlreadyAdmitted()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] Under Until Admitted, one admitted ticket of the line stops the admission from moving, reason ALREADY_ADMITTED.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, policy Until Admitted, whose second ticket of the first line was admitted
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetPolicy(TicketBom."Reschedule Policy"::UNTIL_ADMITTED, 0);
        Lib.MarkAdmitted(Lib.TicketNo(1, 2));

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line cannot move, reason ALREADY_ADMITTED, and no slot is offered
        Lib.AssertStatus(Response, 200, 'S4.f: Find under Until Admitted with one ticket admitted');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'ALREADY_ADMITTED', '', 'S4.f: Find under Until Admitted with one ticket admitted');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenUntilAdmittedAndSlotEnded_WhenFind_ThenAdmissionCanMove()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] Under Until Admitted, an ended current slot does not stop the move when no ticket was admitted.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, policy Until Admitted, and the early slot ended yesterday
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetPolicy(TicketBom."Reschedule Policy"::UNTIL_ADMITTED, 0);
        Lib.MoveSlotToYesterday(1);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The admission of the first line can move, has no reason code and offers the slots after now within the validity
        Lib.AssertStatus(Response, 200, 'S4.g: Find under Until Admitted with the slot ended');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S4.g: Find under Until Admitted with the slot ended');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLinePolicyNotAllowed_WhenFind_ThenNotAllowedAndOtherLineStillOffered()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Lib: Codeunit "NPR Library - TM Reschedule";
        OtherItem: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        Lines: JsonArray;
    begin
        // [SCENARIO] A line whose item has policy Not Allowed reports NOT_ALLOWED, and the reservation is still returned because another line can move.
        Initialize();

        // [GIVEN] A confirmed reservation with a first line of an item with policy Not Allowed and a second line of another item on another admission with policy Until Admitted or Expired
        Lib.CreateEventScenario();
        OtherItem.CreateEventScenario();
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, OtherItem.GetItemNo(), 1, OtherItem.GetAdmissionCode(), OtherItem.SlotNo(1));
        Lib.CreateReservation(Lines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.SetPolicy(TicketBom."Reschedule Policy"::NOT_ALLOWED, 0);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] HTTP 200; the first line cannot move, reason NOT_ALLOWED, no slot offered
        Lib.AssertStatus(Response, 200, 'S4.h: Find with the first line Not Allowed');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'NOT_ALLOWED', '', 'S4.h: Find with the first line Not Allowed');

        // [THEN] The second line can move and offers the middle and late slots of its own admission
        Lib.AssertAdmission(Response, 2, OtherItem.GetAdmissionCode(), true, '', OtherItem.SlotIds(OtherItem.SlotNo(2), OtherItem.SlotNo(3)), 'S4.h: Find with the first line Not Allowed');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenAdmissionSetupLineDeletedAfterSale_WhenFind_ThenNotConfiguredAndOtherLineStillOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        OtherItem: Codeunit "NPR Library - TM Reschedule";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Lines: JsonArray;
    begin
        // [SCENARIO] A line whose admission setup line was deleted after the sale reports NOT_CONFIGURED for that admission, the reservation is still returned because another line can move, and nothing is logged as a programming bug.
        Initialize();

        // [GIVEN] A confirmed reservation with a first line of an item on its admission and a second line of another item on another admission with policy Until Admitted or Expired; the admission setup line of the first item was then deleted
        Lib.CreateEventScenario();
        OtherItem.CreateEventScenario();
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, OtherItem.GetItemNo(), 1, OtherItem.GetAdmissionCode(), OtherItem.SlotNo(1));
        Lib.CreateReservation(Lines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.DeleteAdmissionSetupLine();
        SentryCapture.Start();

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());
        SentryCapture.Stop();

        // [THEN] HTTP 200; the first line cannot move, reason NOT_CONFIGURED, no slot offered
        Lib.AssertStatus(Response, 200, 'S4.m: Find with the admission setup line of the first line deleted');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'NOT_CONFIGURED', '', 'S4.m: Find with the admission setup line of the first line deleted');

        // [THEN] The second line can move and offers the middle and late slots of its own admission
        Lib.AssertAdmission(Response, 2, OtherItem.GetAdmissionCode(), true, '', OtherItem.SlotIds(OtherItem.SlotNo(2), OtherItem.SlotNo(3)), 'S4.m: Find with the admission setup line of the first line deleted');

        // [THEN] No Sentry event is marked as a programming bug
        Assert.IsFalse(SentryCapture.Contains('This is a programming bug'), 'S4.m: Find with a deleted admission setup line must not log any Sentry event marked as a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOneTicketOfTheLineBlocked_WhenFindByOtherLine_ThenTicketBlocked()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] One blocked ticket stops its whole line from moving, reason TICKET_BLOCKED, while the other line stays movable.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot whose first ticket of the first line is blocked and the second is not
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.BlockTicket(Lib.TicketNo(1, 1));

        // [WHEN] The guest calls find with the ticket of the second line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(2, 1), Lib.GetPin());

        // [THEN] HTTP 200; the first line cannot move, reason TICKET_BLOCKED, no slot offered
        Lib.AssertStatus(Response, 200, 'S4.i: Find by the second line with a blocked ticket in the first');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), false, 'TICKET_BLOCKED', '', 'S4.i: Find by the second line with a blocked ticket in the first');

        // [THEN] The second line can move and offers the middle and late slots
        Lib.AssertAdmission(Response, 2, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S4.i: Find by the second line with a blocked ticket in the first');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoLinesShareOneReference_WhenFind_ThenOneAmbiguousEntryAndOtherLineMovable()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        Lines: JsonArray;
        SharedPrimaryRowId: Guid;
    begin
        // [SCENARIO] Two lines that share line reference 0 appear as one entry with the primary row's values that cannot move, reason LINE_AMBIGUOUS, while the third line can move.
        Initialize();

        // [GIVEN] A confirmed three-line reservation on the early slot whose first two lines were rewritten to share line reference 0 with a single primary row
        Lib.CreateEventScenario();
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(Lines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.ShareLineReference(1, 2);
        SharedPrimaryRowId := Lib.LineSystemId(0);

        // [WHEN] The guest calls find with a ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(0, 1), Lib.GetPin());

        // [THEN] HTTP 200 with two entries
        Lib.AssertStatus(Response, 200, 'S19.a: Find on a reservation with a shared line reference');
        Lib.AssertLineCount(Response, 2, 'S19.a: Find on a reservation with a shared line reference');

        // [THEN] The shared reference is one entry with the primary row's systemId and quantity that cannot move, reason LINE_AMBIGUOUS, no slot offered
        Lib.AssertLineSystemId(Response, 0, SharedPrimaryRowId, 'S19.a: Find on a reservation with a shared line reference');
        Lib.AssertLineQuantity(Response, 0, 2, 'S19.a: Find on a reservation with a shared line reference');
        Lib.AssertAdmission(Response, 0, Lib.GetAdmissionCode(), false, 'LINE_AMBIGUOUS', '', 'S19.a: Find on a reservation with a shared line reference');

        // [THEN] The third line can move and offers the middle and late slots
        Lib.AssertAdmission(Response, 3, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S19.a: Find on a reservation with a shared line reference');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenTwoItemsShareOneReference_WhenFind_ThenEveryAdmissionAmbiguousAndOtherLineMovable()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        OtherItem: Codeunit "NPR Library - TM Reschedule";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        MovableLineResponse: JsonObject;
        SharedLineResponse: JsonObject;
        Lines: JsonArray;
        SharedPrimaryRowId: Guid;
        PinCode: Text;
    begin
        // [SCENARIO] Two lines of different items on different admissions that share line reference 0 appear as one entry whose every admission cannot move, reason LINE_AMBIGUOUS, while the third line can move, and nothing is logged as a programming bug.
        Initialize();

        // [GIVEN] A confirmed three-line reservation on the early slots: a first line of the scenario item, a second line of another item on another admission and a third line of the scenario item; the first two lines were then rewritten to share line reference 0 with a single primary row
        Lib.CreateEventScenario();
        OtherItem.CreateEventScenario();
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 2, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.AddReserveLineTo(Lines, OtherItem.GetItemNo(), 1, OtherItem.GetAdmissionCode(), OtherItem.SlotNo(1));
        Lib.AddReserveLineTo(Lines, Lib.GetItemNo(), 1, Lib.GetAdmissionCode(), Lib.SlotNo(1));
        Lib.CreateReservation(Lines);
        Lib.ConfirmReservation(Lib.GetToken());
        Lib.ShareLineReference(1, 2);
        SharedPrimaryRowId := Lib.LineSystemId(0);
        PinCode := Lib.GetPin();
        SentryCapture.Start();

        // [WHEN] The guest calls find with the ticket of the third line and with a ticket of the shared entry, each with the pin
        MovableLineResponse := Lib.FindByTicketNumber(Lib.TicketNo(3, 1), PinCode);
        SharedLineResponse := Lib.FindByTicketNumber(Lib.TicketNo(0, 1), PinCode);
        SentryCapture.Stop();

        // [THEN] The find by the ticket of the third line answers HTTP 200 with two entries: the shared entry with the primary row's systemId and quantity, ambiguous on both admissions with no slot offered, and the third line movable to the middle and late slots
        AssertSharedEntryOfTwoItemsAmbiguous(Lib, MovableLineResponse, OtherItem.GetAdmissionCode(), SharedPrimaryRowId, 'S19.a-mixed: Find by the ticket of the movable line');

        // [THEN] The find by a ticket of the shared entry answers with the same entries
        AssertSharedEntryOfTwoItemsAmbiguous(Lib, SharedLineResponse, OtherItem.GetAdmissionCode(), SharedPrimaryRowId, 'S19.a-mixed: Find by a ticket of the shared line reference');

        // [THEN] No Sentry event is marked as a programming bug
        Assert.AreEqual(0, SentryCapture.Count('This is a programming bug', 'This is a programming bug'), 'S19.a-mixed: Find on a line reference shared by two items on two admissions must not log any Sentry event marked as a programming bug.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenEveryLineAmbiguous_WhenFind_ThenUniformNotFound()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A reservation whose every line is ambiguous has nothing that can move and gets the uniform not-found error.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose two lines were rewritten to share line reference 0 with a single primary row
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.ShareLineReference(1, 2);

        // [WHEN] The guest calls find with a ticket of the shared entry and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(0, 1), Lib.GetPin());

        // [THEN] HTTP 404 resource_not_found with the ticket number message
        Lib.AssertUniformNotFound(Response, Lib.TicketNotFoundMessage(), 'S19.c: Find on a reservation whose every line is ambiguous');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenLineWithoutAdmissionRows_WhenFind_ThenInternalErrorLoggedAsProgrammingBug()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        Assert: Codeunit Assert;
        Response: JsonObject;
        RequestEntryNoBefore: Integer;
        AccessDetailEntryNoBefore: Integer;
    begin
        // [SCENARIO] A line with no required or selected admission row is an internal inconsistency, so find answers with the fixed internal error, logs one programming-bug event that names the integrity problem and writes nothing.
        Initialize();

        // [GIVEN] A confirmed two-line reservation whose every row of the first line is set to Not Selected
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.DeselectLineAdmissions(1);
        RequestEntryNoBefore := Lib.LastRequestEntryNo();
        AccessDetailEntryNoBefore := Lib.LastAccessDetailEntryNo();
        SentryCapture.Start();

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());
        SentryCapture.Stop();

        // [THEN] HTTP 400 generic_error with the message "An internal error occurred. The request was logged."
        Lib.AssertInternalError(Response, 'S16.a: Find on a line without admission rows');

        // [THEN] Exactly one Sentry event holds the Houston integrity text, and it is marked as a programming bug
        Assert.AreEqual(1, SentryCapture.Count('Houston', 'Houston'), 'S16.a: Find on a line without admission rows must log exactly one Sentry event with the Houston integrity text.');
        Assert.AreEqual(1, SentryCapture.Count('Houston', 'This is a programming bug'), 'S16.a: The Sentry event with the Houston integrity text must be marked as a programming bug.');

        // [THEN] Nothing was written, so no new request row and no new detailed ticket access entry exist
        Assert.AreEqual(RequestEntryNoBefore, Lib.LastRequestEntryNo(), 'S16.a: Find must not write any ticket reservation request row.');
        Assert.AreEqual(AccessDetailEntryNoBefore, Lib.LastAccessDetailEntryNo(), 'S16.a: Find must not write any detailed ticket access entry.');
    end;
    #endregion

    #region Slots
    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSlotsCancelledHiddenWaitingListOrClosed_WhenFind_ThenOnlyCleanSlotIsOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        HiddenSlotIndex: Integer;
        WaitingListSlotIndex: Integer;
        ClosedSlotIndex: Integer;
        Context: Text;
        FlaggedSlotsContextTxt: Label 'S5.c, S5.d, S5.g, S5.l: Find with the middle slot %1 cancelled and its copies %2 hidden on web, %3 on a waiting list and %4 closed', Locked = true;
    begin
        // [SCENARIO] A slot that is cancelled, hidden on web, on a waiting list or closed is not offered, while a clean slot of the same admission is.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot; copies of the middle slot on the three days after the event day; the middle slot cancelled, the first copy hidden on web, the second on a waiting list and the third closed; the late slot left clean
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        HiddenSlotIndex := Lib.AddSlotCopy(2, Lib.GetEventDate() + 1);
        WaitingListSlotIndex := Lib.AddSlotCopy(2, Lib.GetEventDate() + 2);
        ClosedSlotIndex := Lib.AddSlotCopy(2, Lib.GetEventDate() + 3);
        Lib.CancelSlot(2);
        Lib.HideSlotOnWeb(HiddenSlotIndex);
        Lib.PutSlotOnWaitingList(WaitingListSlotIndex);
        Lib.CloseSlot(ClosedSlotIndex);
        Context := StrSubstNo(FlaggedSlotsContextTxt, Lib.SlotNo(2), Lib.SlotNo(HiddenSlotIndex), Lib.SlotNo(WaitingListSlotIndex), Lib.SlotNo(ClosedSlotIndex));

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] HTTP 200 and the first line offers only the clean late slot, none of the four flagged slots
        Lib.AssertStatus(Response, 200, Context);
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(3)), Context);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSlotAfterTicketValidity_WhenFind_ThenItIsNotOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        LastValidDaySlotNo: Integer;
    begin
        // [SCENARIO] A slot on today plus 8 days lies after the tickets' valid-to date of today plus 7 days and is not offered, while a slot on the valid-to date is.
        Initialize();

        // [GIVEN] A confirmed two-line reservation valid through today plus 7 days, with the middle slot copied to today plus 7 days and to today plus 8 days
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        LastValidDaySlotNo := Lib.CopySlotToDate(2, Today() + 7);
        Lib.CopySlotToDate(2, Today() + 8);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers the middle and late slots of the event day and the copy on the valid-to date, not the copy after it
        Lib.AssertStatus(Response, 200, 'S5.e: Find with a slot after the ticket validity');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3), LastValidDaySlotNo), 'S5.e: Find with a slot after the ticket validity');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenEventDayClosedOnTicketCalendar_WhenFind_ThenItsSlotsAreNotOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        NextDaySlotNo: Integer;
    begin
        // [SCENARIO] A slot on a day the ticket's base calendar marks non-working is not offered, while a slot on a working day is.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, the event day then marked non-working on the ticket base calendar, and the middle slot copied to the day after
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.CloseEventDateOnTicketCalendar();
        NextDaySlotNo := Lib.CopySlotToDate(2, Lib.GetEventDate() + 1);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers only the copy on the working day after the event day
        Lib.AssertStatus(Response, 200, 'S5.f: Find with the event day non-working');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(NextDaySlotNo), 'S5.f: Find with the event day non-working');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSlotThatStartedToday_WhenFind_ThenItIsNotOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A slot whose start time has already passed today in the admission's time zone is not offered.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot and a copy of the middle slot on today that started at 00:00:01
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.CopySlotStartedToday(2);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers only the middle and late slots of the event day
        Lib.AssertStatus(Response, 200, 'S5.h: Find with a slot that already started today');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S5.h: Find with a slot that already started today');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSalesSlotWithOnePlaceLeft_WhenFindForTwoPlaces_ThenItIsNotOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A Sales-controlled slot of capacity 3 with 2 places sold has 1 place left, fewer than the 2 places of the line, and is not offered.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, the middle slot under Sales control with capacity 3, and 2 places sold on it
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetSlotSalesCapacity(2, 3);
        Lib.SellPlaces(2, 2);

        // [WHEN] The guest calls find with the first ticket of the first line, which holds 2 places, and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers only the late slot
        Lib.AssertStatus(Response, 200, 'S5.i: Find with one place left on the middle slot');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(3)), 'S5.i: Find with one place left on the middle slot');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSalesSlotWithTwoPlacesLeft_WhenFindForTwoPlaces_ThenOfferedWithTwo()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A Sales-controlled slot of capacity 4 with 2 places sold has exactly the 2 places of the line left and is offered with remaining capacity 2.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, the middle slot under Sales control with capacity 4, and 2 places sold on it
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetSlotSalesCapacity(2, 4);
        Lib.SellPlaces(2, 2);

        // [WHEN] The guest calls find with the first ticket of the first line, which holds 2 places, and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers the middle and late slots
        Lib.AssertStatus(Response, 200, 'S5.j: Find with two places left on the middle slot');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S5.j: Find with two places left on the middle slot');

        // [THEN] The middle slot reports remaining capacity 2
        Lib.AssertSlotCapacity(Response, 1, Lib.SlotNo(2), 2, 'S5.j: Find with two places left on the middle slot');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSlotWithoutCapacityControl_WhenFind_ThenOfferedWithNullCapacity()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] A slot under capacity control None is unlimited, so it is offered with remaining capacity null.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot and the middle slot under capacity control None
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.RemoveSlotCapacityControl(2);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers the middle and late slots
        Lib.AssertStatus(Response, 200, 'S5.k: Find with the middle slot without capacity control');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S5.k: Find with the middle slot without capacity control');

        // [THEN] The middle slot reports remaining capacity null
        Lib.AssertSlotCapacityIsNull(Response, 1, Lib.SlotNo(2), 'S5.k: Find with the middle slot without capacity control');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenSalesWindowEndedYesterday_WhenFind_ThenSlotIsNotOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] When the BOM enforces sales limits, a slot whose sales ended yesterday is not offered.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot, a BOM that enforces sales limits and a middle slot whose sales until date is yesterday
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.EnforceSalesLimitsAndEndSlotSalesYesterday(2);

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers only the late slot
        Lib.AssertStatus(Response, 200, 'S5.m: Find with the sales window of the middle slot ended');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(3)), 'S5.m: Find with the sales window of the middle slot ended');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenActivationOnSaleAndZeroDuration_WhenFind_ThenSlotIsStillOffered()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
    begin
        // [SCENARIO] The duration-formula and activation-on-sale rules of the sales check do not apply to a move, so a slot they would hide is still offered.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot and a BOM that activates the ticket on sale with duration formula <0D>
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.ActivateOnSaleWithZeroDuration();

        // [WHEN] The guest calls find with the first ticket of the first line and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line still offers the middle and late slots
        Lib.AssertStatus(Response, 200, 'S5.n: Find with activation on sale and duration <0D>');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S5.n: Find with activation on sale and duration <0D>');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenOwnPlacesInSalesConcurrencyGroup_WhenFind_ThenTheyCountAsFree()
    var
        Lib: Codeunit "NPR Library - TM Reschedule";
        Assert: Codeunit Assert;
        Response: JsonObject;
    begin
        // [SCENARIO] In a Sales concurrency group of limit 10 with 9 places in use, the 2 places the line frees on its own slot count as free, so the other slot of the group is offered with 3 places left.
        Initialize();

        // [GIVEN] A confirmed two-line reservation of 3 places on the early slot; early and middle slot in one concurrency group (by concurrency code, Sales control, limit 10); the middle slot under Sales control; 6 places sold on it
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.AddSlotsToSalesConcurrencyGroup(1, 2, 10);
        Lib.SetSlotSalesCapacity(2, 1000);
        Lib.SellPlaces(2, 6);
        Assert.AreEqual(9, Lib.GroupPlacesInUseOnEventDate(2), 'S5.q: Setup: the concurrency group must count 9 places in use on the event day, 2 of them the first line''s own on the early slot.');

        // [WHEN] The guest calls find with the first ticket of the first line, which holds 2 places, and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers the middle and late slots
        Lib.AssertStatus(Response, 200, 'S5.q: Find with the own places in a concurrency group');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), 'S5.q: Find with the own places in a concurrency group');

        // [THEN] The middle slot reports remaining capacity 3, the group limit minus the places of others
        Lib.AssertSlotCapacity(Response, 1, Lib.SlotNo(2), 3, 'S5.q: Find with the own places in a concurrency group');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenScheduleConcurrencyGroupOverTwoDays_WhenFind_ThenEachSlotCountsItsOwnScheduleAndDay()
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        Lib: Codeunit "NPR Library - TM Reschedule";
        Response: JsonObject;
        NextDayMiddleSlotIndex: Integer;
        NextDayLateSlotIndex: Integer;
    begin
        // [SCENARIO] In a Sales concurrency group by schedule with limit 10, each offered slot reports the limit minus the places sold on its own schedule on its own day.
        Initialize();

        // [GIVEN] A confirmed two-line reservation on the early slot; the middle and late slots under Sales control with capacity 1000 and copied to the day after the event day; 1 place sold on the middle slot and 3 on the late slot of the event day and 5 on the middle slot of the day after; the middle and late schedules in one concurrency group by schedule (Sales control, limit 10)
        Lib.CreateEventScenario();
        Lib.CreateTwoLineReservation(1, 1);
        Lib.SetSlotSalesCapacity(2, 1000);
        Lib.SetSlotSalesCapacity(3, 1000);
        NextDayMiddleSlotIndex := Lib.AddSlotCopy(2, Lib.GetEventDate() + 1);
        NextDayLateSlotIndex := Lib.AddSlotCopy(3, Lib.GetEventDate() + 1);
        Lib.SellPlaces(2, 1);
        Lib.SellPlaces(3, 3);
        Lib.SellPlaces(NextDayMiddleSlotIndex, 5);
        Lib.AddSlotsToSalesConcurrencyGroup(2, 3, 10, GroupSetup."Concurrency Type"::SCHEDULE);

        // [WHEN] The guest calls find with the first ticket of the first line, which holds 2 places, and the pin
        Response := Lib.FindByTicketNumber(Lib.TicketNo(1, 1), Lib.GetPin());

        // [THEN] The first line offers the middle and late slots of both days
        Lib.AssertStatus(Response, 200, 'A5: Find with a concurrency group by schedule over two days');
        Lib.AssertAdmission(Response, 1, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)) + ',' + Lib.SlotIds(Lib.SlotNo(NextDayMiddleSlotIndex), Lib.SlotNo(NextDayLateSlotIndex)), 'A5: Find with a concurrency group by schedule over two days');

        // [THEN] The slots report remaining capacity 9 and 7 on the event day and 5 and 10 on the day after
        Lib.AssertSlotCapacity(Response, 1, Lib.SlotNo(2), 9, 'A5: Find with a concurrency group by schedule over two days');
        Lib.AssertSlotCapacity(Response, 1, Lib.SlotNo(3), 7, 'A5: Find with a concurrency group by schedule over two days');
        Lib.AssertSlotCapacity(Response, 1, Lib.SlotNo(NextDayMiddleSlotIndex), 5, 'A5: Find with a concurrency group by schedule over two days');
        Lib.AssertSlotCapacity(Response, 1, Lib.SlotNo(NextDayLateSlotIndex), 10, 'A5: Find with a concurrency group by schedule over two days');
    end;
    #endregion

    local procedure AssertBothLinesOnEarlySlot(var Lib: Codeunit "NPR Library - TM Reschedule"; Response: JsonObject; Context: Text)
    var
        OtherSlots: Text;
    begin
        OtherSlots := Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3));
        Lib.AssertStatus(Response, 200, Context);
        Lib.AssertReservationToken(Response, Lib.GetToken(), Context);
        Lib.AssertLineCount(Response, 2, Context);
        Lib.AssertMovableLine(Response, 1, Lib.TicketNo(1, 1), 2, Lib.LineSystemId(1), Lib.SlotNo(1), OtherSlots, Context);
        Lib.AssertMovableLine(Response, 2, Lib.TicketNo(2, 1), 1, Lib.LineSystemId(2), Lib.SlotNo(1), OtherSlots, Context);
    end;

    local procedure AssertFirstLineOnMiddleSlot(var Lib: Codeunit "NPR Library - TM Reschedule"; Response: JsonObject; FirstTicket: Text; ChangeToken: Text[100]; Context: Text)
    begin
        Lib.AssertStatus(Response, 200, Context);
        Lib.AssertReservationToken(Response, Lib.GetToken(), Context);
        Lib.AssertLineCount(Response, 2, Context);
        Lib.AssertMovableLine(Response, 1, FirstTicket, 2, Lib.LineSystemId(ChangeToken, 1), Lib.SlotNo(2), Lib.SlotIds(Lib.SlotNo(1), Lib.SlotNo(3)), Context);
        Lib.AssertMovableLine(Response, 2, Lib.TicketNo(2, 1), 1, Lib.LineSystemId(2), Lib.SlotNo(1), Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), Context);
    end;

    local procedure AssertSharedEntryOfTwoItemsAmbiguous(var Lib: Codeunit "NPR Library - TM Reschedule"; Response: JsonObject; OtherAdmissionCode: Code[20]; SharedPrimaryRowId: Guid; Context: Text)
    begin
        Lib.AssertStatus(Response, 200, Context);
        Lib.AssertLineCount(Response, 2, Context);
        Lib.AssertLineSystemId(Response, 0, SharedPrimaryRowId, Context);
        Lib.AssertLineQuantity(Response, 0, 2, Context);
        Lib.AssertAdmission(Response, 0, Lib.GetAdmissionCode(), false, 'LINE_AMBIGUOUS', '', Context);
        Lib.AssertAdmission(Response, 0, OtherAdmissionCode, false, 'LINE_AMBIGUOUS', '', Context);
        Lib.AssertAdmission(Response, 3, Lib.GetAdmissionCode(), true, '', Lib.SlotIds(Lib.SlotNo(2), Lib.SlotNo(3)), Context);
    end;

    // CallApi sends only an object body, so the array body goes through a request built the same way.
    local procedure CallFindWithArrayBody(Body: JsonArray) Response: JsonObject
    var
        APIRequestProcessor: Codeunit "NPR API Request Processor";
        Request: JsonObject;
        PathSegments: JsonArray;
        QueryParameters: JsonObject;
        Headers: JsonObject;
        Path: Text;
        Segment: Text;
        RequestText: Text;
        FindPathTok: Label 'ticket/reschedule/find', Locked = true;
        UrlTok: Label 'https://api.npretail.app/%1/%2', Locked = true;
        PrefixedPathTok: Label '%1/%2', Locked = true;
        TenantEnvCompanyTok: Label 'Tenant/Environment/Company', Locked = true;
    begin
        Path := FindPathTok;
        foreach Segment in Path.Split('/') do
            PathSegments.Add(Segment);
        Request.Add('url', StrSubstNo(UrlTok, TenantEnvCompanyTok, Path));
        Request.Add('httpMethod', 'POST');
        Request.Add('path', StrSubstNo(PrefixedPathTok, TenantEnvCompanyTok, Path));
        Request.Add('relativePathSegments', PathSegments);
        Request.Add('queryParams', QueryParameters);
        Request.Add('body', Body);
        Request.Add('headers', Headers);
        Request.WriteTo(RequestText);
        Response.ReadFrom(APIRequestProcessor.httpmethod(RequestText));
    end;

    local procedure WithLastDigitChanged(PinCode: Text): Text
    var
        LastCharacter: Char;
    begin
        LastCharacter := PinCode[StrLen(PinCode)];
        if (LastCharacter = '9') then
            LastCharacter := '0'
        else
            LastCharacter := LastCharacter + 1;
        exit(CopyStr(PinCode, 1, StrLen(PinCode) - 1) + Format(LastCharacter));
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

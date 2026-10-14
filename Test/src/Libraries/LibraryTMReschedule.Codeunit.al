codeunit 85500 "NPR Library - TM Reschedule"
{
    Access = Internal;

    var
        _Assert: Codeunit Assert;
        _ItemNo: Code[20];
        _AdmissionCode: Code[20];
        _EventDate: Date;
        _Token: Text[100];
        _SlotEntryNos: List of [Integer];
        TicketNotFoundTxt: Label 'The combination of ticket number and pin code is not valid.', Locked = true;
        TokenNotFoundTxt: Label 'The combination of reservation token and pin code is not valid.', Locked = true;
        InternalErrorTxt: Label 'An internal error occurred. The request was logged.', Locked = true;
        NotificationAddressTok: Label 'reschedule.guest%1example.com', Locked = true;
        TicketHolderNameTok: Label 'Rescheduling Guest Holder', Locked = true;
        LetterPinSchemeTok: Label '[A*4]-[N*4]', Locked = true;
        AdmissionDescriptionTok: Label 'Reschedule test admission %1', Locked = true;
        ReservationPathTok: Label '/ticket/reservation', Locked = true;
        ConfirmPathTok: Label '/ticket/reservation/%1/confirm', Locked = true;
        FindPathTok: Label '/ticket/reschedule/find', Locked = true;
        ResponseDescriptionTok: Label 'HTTP %1, body %2', Locked = true;
        LineContextTok: Label '%1, line with externalLineReference %2', Locked = true;
        AdmissionContextTok: Label '%1, line with externalLineReference %2, admission %3', Locked = true;
        EventDaySlotsErr: Label 'Setup: admission %1 must have exactly three open slots on %2.', Locked = true;
        ReservationSetupErr: Label 'Setup: POST /ticket/reservation must succeed. Response body: %1', Locked = true;
        ConfirmSetupErr: Label 'Setup: confirming reservation %1 must succeed. Response body: %2', Locked = true;
        ChangeSetupErr: Label 'Setup: moving the line of ticket %1 to another slot through the SOAP change must succeed: %2', Locked = true;
        PrimaryRowMissingErr: Label 'Setup: token %1 has no primary request row for line reference %2.', Locked = true;
        TokenRowsMissingErr: Label 'Setup: token %1 has no request rows.', Locked = true;
        TicketMissingErr: Label 'Setup: line reference %1 of token %2 has no ticket at position %3.', Locked = true;
        TicketNumberMissingErr: Label 'Setup: no ticket has the external ticket number %1.', Locked = true;
        StatusErr: Label '%1: expected HTTP %2 from POST /ticket/reschedule/find. Got %3', Locked = true;
        ErrorCodeErr: Label '%1: expected error code %2. Got %3', Locked = true;
        ErrorMessageErr: Label '%1: expected the error message to be exactly "%2".', Locked = true;
        MessageNamesPropertyErr: Label '%1: expected the error message to name the property %2. Message: %3', Locked = true;
        PropertyMissingErr: Label '%1: expected the property %2 in %3', Locked = true;
        PropertyTypeErr: Label '%1: expected the property %2 to be a JSON %3. Value: %4', Locked = true;
        LineMissingErr: Label '%1: expected a reservation line with externalLineReference %2 in %3', Locked = true;
        AdmissionMissingErr: Label '%1: expected an admission with admissionCode %2 in %3', Locked = true;
        SlotMissingErr: Label '%1: expected slot %2 in %3', Locked = true;
        TokenErr: Label '%1: reservationToken must be the original token of the reservation.', Locked = true;
        LineCountErr: Label '%1: expected %2 entries in reservationLines.', Locked = true;
        SystemIdErr: Label '%1: systemId must be the id of the current primary row of the line (%2).', Locked = true;
        LineValueErr: Label '%1: unexpected value of %2.', Locked = true;
        AdmissionCountErr: Label '%1: expected exactly one admission.', Locked = true;
        CurrentScheduleErr: Label '%1: currentSchedule.scheduleNumber must be the current slot %2.', Locked = true;
        AllowedErr: Label '%1: rescheduleAllowed must be %2.', Locked = true;
        ReasonErr: Label '%1: reasonCode must be "%2".', Locked = true;
        SlotsErr: Label '%1: slots[] must list exactly the schedule ids [%2] in start order.', Locked = true;
        RemainingErr: Label '%1: remainingCapacity of slot %2 must be %3.', Locked = true;
        RemainingNullErr: Label '%1: remainingCapacity of slot %2 must be JSON null because no capacity check bounds the line.', Locked = true;
        SlotDateErr: Label '%1: %2 of slot %3 must be %4.', Locked = true;
        BodyLeakErr: Label '%1: the response body must not contain the %2 (%3).', Locked = true;

    #region Scenario

    // One occasion admission whose three slots split the event day (today plus 3 days) into early, middle and late.
    procedure CreateEventScenario()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
        EntryNo: Integer;
    begin
        _EventDate := Today() + 3;
        _ItemNo := LibraryTicketModule.CreateScenario_ReservationRequired(3, _EventDate);
        TicketBom.SetFilter("Item No.", '=%1', _ItemNo);
        TicketBom.FindFirst();
        _AdmissionCode := TicketBom."Admission Code";

        // The generator names the admission after its code, so the description is made distinct from the code.
        Admission.Get(_AdmissionCode);
        Admission.Description := CopyStr(StrSubstNo(AdmissionDescriptionTok, _AdmissionCode), 1, MaxStrLen(Admission.Description));
        Admission.Modify();

        // The scenario is defined with slots on the event day only, so any slot the generator added on other dates is cancelled.
        ScheduleEntry.SetFilter("Admission Code", '=%1', _AdmissionCode);
        ScheduleEntry.SetFilter("Admission Start Date", '<>%1', _EventDate);
        if (not ScheduleEntry.IsEmpty()) then
            ScheduleEntry.ModifyAll(Cancelled, true);

        ScheduleEntry.Reset();
        ScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
        ScheduleEntry.SetFilter("Admission Code", '=%1', _AdmissionCode);
        ScheduleEntry.SetFilter("Admission Start Date", '=%1', _EventDate);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        _Assert.AreEqual(3, ScheduleEntry.Count(), StrSubstNo(EventDaySlotsErr, _AdmissionCode, _EventDate));
        Clear(_SlotEntryNos);
        ScheduleEntry.FindSet();
        repeat
            _SlotEntryNos.Add(ScheduleEntry."Entry No.");
        until (ScheduleEntry.Next() = 0);

        // The generator copies the slot times into the arrival times, so these are moved one minute inside the slot to keep the four times distinct.
        foreach EntryNo in _SlotEntryNos do begin
            ScheduleEntry.Get(EntryNo);
            ScheduleEntry."Event Arrival From Time" := ScheduleEntry."Admission Start Time" + 60000;
            ScheduleEntry."Event Arrival Until Time" := ScheduleEntry."Admission End Time" - 60000;
            ScheduleEntry.Modify();
        end;

        SetPolicy(TicketBom."Reschedule Policy"::UNTIL_USED, 0);
        _Token := '';
    end;

    procedure GetItemNo(): Code[20]
    begin
        exit(_ItemNo);
    end;

    procedure GetAdmissionCode(): Code[20]
    begin
        exit(_AdmissionCode);
    end;

    procedure GetEventDate(): Date
    begin
        exit(_EventDate);
    end;

    procedure LocalNow(): DateTime
    var
        TimeHelper: Codeunit "NPR TM TimeHelper";
    begin
        exit(TimeHelper.GetLocalTimeAtAdmission(_AdmissionCode));
    end;

    procedure LocalToday(): Date
    begin
        exit(DT2Date(LocalNow()));
    end;

    procedure SetPolicy(Policy: Option NOT_ALLOWED,UNTIL_USED,CUTOFF_HOUR,UNTIL_ADMITTED; CutOffHours: Decimal)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        GetBom(TicketBom);
        TicketBom."Reschedule Policy" := Policy;
        TicketBom."Reschedule Cut-Off (Hours)" := CutOffHours;
        TicketBom.Modify();
    end;

    procedure DeleteAdmissionSetupLine()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        GetBom(TicketBom);
        TicketBom.Delete();
    end;

    procedure EnforceSalesLimitsAndEndSlotSalesYesterday(SlotIndex: Integer)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        GetBom(TicketBom);
        TicketBom."Enforce Schedule Sales Limits" := true;
        TicketBom.Modify();
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleEntry."Sales Until Date" := LocalToday() - 1;
        ScheduleEntry.Modify();
    end;

    procedure ActivateOnSaleWithZeroDuration()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        GetBom(TicketBom);
        TicketBom."Activation Method" := "NPR TM ActivationMethod_Bom"::POS;
        Evaluate(TicketBom."Duration Formula", '<0D>');
        TicketBom.Modify();
    end;

    procedure CloseEventDateOnTicketCalendar()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        CustomizedCalendarChange: Record "Customized Calendar Change";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
    begin
        GetBom(TicketBom);
        TicketBom."Ticket Base Calendar Code" := LibraryTicketModule.CreateBaseCalendar('');
        TicketBom.Modify();
        CustomizedCalendarChange.SetSource(CustomizedCalendarChange."Source Type"::NPR_TM_BOM_Admission, _AdmissionCode, '', TicketBom."Ticket Base Calendar Code");
        CustomizedCalendarChange.Date := _EventDate;
        CustomizedCalendarChange.Nonworking := true;
        CustomizedCalendarChange.Insert();
    end;

    procedure UseGroupRegistration()
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
    begin
        Item.Get(_ItemNo);
        TicketType.Get(Item."NPR Ticket Type");
        TicketType."Admission Registration" := TicketType."Admission Registration"::GROUP;
        TicketType.Modify();
    end;

    local procedure GetBom(var TicketBom: Record "NPR TM Ticket Admission BOM")
    begin
        TicketBom.Get(_ItemNo, '', _AdmissionCode);
    end;

    #endregion

    #region Slots

    procedure GetSlot(SlotIndex: Integer; var ScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    begin
        ScheduleEntry.Get(_SlotEntryNos.Get(SlotIndex));
    end;

    procedure SlotNo(SlotIndex: Integer): Integer
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        exit(ScheduleEntry."External Schedule Entry No.");
    end;

    procedure SlotIds(FirstSlotNo: Integer): Text
    begin
        exit(Format(FirstSlotNo, 0, 9));
    end;

    procedure SlotIds(FirstSlotNo: Integer; SecondSlotNo: Integer): Text
    begin
        exit(SlotIds(FirstSlotNo) + ',' + SlotIds(SecondSlotNo));
    end;

    procedure SlotIds(FirstSlotNo: Integer; SecondSlotNo: Integer; ThirdSlotNo: Integer): Text
    begin
        exit(SlotIds(FirstSlotNo, SecondSlotNo) + ',' + SlotIds(ThirdSlotNo));
    end;

    procedure CopySlotToDate(SlotIndex: Integer; NewDate: Date): Integer
    var
        SourceEntry: Record "NPR TM Admis. Schedule Entry";
        NewEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        GetSlot(SlotIndex, SourceEntry);
        NewEntry := SourceEntry;
        NewEntry."Entry No." := 0;
        NewEntry."Admission Start Date" := NewDate;
        NewEntry."Admission End Date" := NewDate;
        NewEntry.Insert();
        NewEntry."External Schedule Entry No." := NewEntry."Entry No.";
        NewEntry.Modify();
        exit(NewEntry."External Schedule Entry No.");
    end;

    // A copy's schedule id is its entry number, so the returned index addresses the copy in every slot helper.
    procedure AddSlotCopy(SlotIndex: Integer; NewDate: Date): Integer
    begin
        _SlotEntryNos.Add(CopySlotToDate(SlotIndex, NewDate));
        exit(_SlotEntryNos.Count());
    end;

    procedure CopySlotStartedToday(SlotIndex: Integer): Integer
    var
        NewEntry: Record "NPR TM Admis. Schedule Entry";
        ExternalScheduleEntryNo: Integer;
    begin
        ExternalScheduleEntryNo := CopySlotToDate(SlotIndex, LocalToday());
        NewEntry.SetFilter("External Schedule Entry No.", '=%1', ExternalScheduleEntryNo);
        NewEntry.FindFirst();
        NewEntry."Admission Start Time" := 000001T;
        NewEntry.Modify();
        exit(ExternalScheduleEntryNo);
    end;

    procedure CancelSlot(SlotIndex: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleEntry.Cancelled := true;
        ScheduleEntry.Modify();
    end;

    procedure HideSlotOnWeb(SlotIndex: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleEntry."Visibility On Web" := ScheduleEntry."Visibility On Web"::HIDDEN;
        ScheduleEntry.Modify();
    end;

    procedure PutSlotOnWaitingList(SlotIndex: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleEntry."Allocation By" := ScheduleEntry."Allocation By"::WAITINGLIST;
        ScheduleEntry.Modify();
    end;

    procedure CloseSlot(SlotIndex: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleEntry."Admission Is" := ScheduleEntry."Admission Is"::CLOSED;
        ScheduleEntry.Modify();
    end;

    procedure MoveSlotToYesterday(SlotIndex: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleEntry."Admission Start Date" := LocalToday() - 1;
        ScheduleEntry."Admission Start Time" := 100000T;
        ScheduleEntry."Admission End Date" := LocalToday() - 1;
        ScheduleEntry."Admission End Time" := 110000T;
        ScheduleEntry."Event Arrival Until Time" := 0T;
        ScheduleEntry.Modify();
    end;

    procedure SetSlotClosingInHours(SlotIndex: Integer; Hours: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ClosesAt: DateTime;
    begin
        ClosesAt := LocalNow() + Hours * 3600000;
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleEntry."Admission Start Date" := DT2Date(ClosesAt - 3600000);
        ScheduleEntry."Admission Start Time" := DT2Time(ClosesAt - 3600000);
        ScheduleEntry."Admission End Date" := DT2Date(ClosesAt);
        ScheduleEntry."Admission End Time" := DT2Time(ClosesAt);
        ScheduleEntry."Event Arrival Until Time" := 0T;
        ScheduleEntry.Modify();
    end;

    procedure PlaceSlotTodayAroundNow(SlotIndex: Integer; EndOffsetMinutes: Integer; ArrivalUntilOffsetMinutes: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Moment: DateTime;
    begin
        Moment := LocalNow();
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleEntry."Admission Start Date" := DT2Date(Moment);
        ScheduleEntry."Admission Start Time" := 000001T;
        ScheduleEntry."Admission End Date" := DT2Date(Moment);
        ScheduleEntry."Admission End Time" := TimeToday(Moment, EndOffsetMinutes);
        ScheduleEntry."Event Arrival Until Time" := TimeToday(Moment, ArrivalUntilOffsetMinutes);
        ScheduleEntry.Modify();
    end;

    // Clamped to the same day, because the closing rule compares times only on the slot's own end date.
    local procedure TimeToday(Moment: DateTime; OffsetMinutes: Integer): Time
    var
        Milliseconds: Integer;
    begin
        Milliseconds := (DT2Time(Moment) - 000000T) + OffsetMinutes * 60000;
        if (Milliseconds < 1000) then
            Milliseconds := 1000;
        if (Milliseconds > 86399000) then
            Milliseconds := 86399000;
        exit(000000T + Milliseconds);
    end;

    procedure SetSlotSalesCapacity(SlotIndex: Integer; MaxCapacity: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleLine.Get(_AdmissionCode, ScheduleEntry."Schedule Code");
        ScheduleLine."Capacity Control" := ScheduleLine."Capacity Control"::SALES;
        ScheduleLine."Max Capacity Per Sch. Entry" := MaxCapacity;
        ScheduleLine.Modify();
        ScheduleEntry."Max Capacity Per Sch. Entry" := MaxCapacity;
        ScheduleEntry.Modify();
    end;

    procedure RemoveSlotCapacityControl(SlotIndex: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleLine.Get(_AdmissionCode, ScheduleEntry."Schedule Code");
        ScheduleLine."Capacity Control" := ScheduleLine."Capacity Control"::"NONE";
        ScheduleLine.Modify();
    end;

    procedure AddSlotsToSalesConcurrencyGroup(FirstSlotIndex: Integer; SecondSlotIndex: Integer; TotalCapacity: Integer)
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
    begin
        AddSlotsToSalesConcurrencyGroup(FirstSlotIndex, SecondSlotIndex, TotalCapacity, GroupSetup."Concurrency Type"::CONCURRENCY_CODE);
    end;

    procedure AddSlotsToSalesConcurrencyGroup(FirstSlotIndex: Integer; SecondSlotIndex: Integer; TotalCapacity: Integer; ConcurrencyType: Option NA,ADMISSION,SCHEDULE,CONCURRENCY_CODE)
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
    begin
        GroupSetup.Init();
        GroupSetup.Code := LibraryTicketModule.GenerateCode20();
        GroupSetup."Total Capacity" := TotalCapacity;
        GroupSetup."Capacity Control" := GroupSetup."Capacity Control"::SALES;
        GroupSetup."Concurrency Type" := ConcurrencyType;
        GroupSetup.Insert();
        JoinConcurrencyGroup(FirstSlotIndex, GroupSetup.Code);
        JoinConcurrencyGroup(SecondSlotIndex, GroupSetup.Code);
    end;

    procedure GroupPlacesInUseOnEventDate(SlotIndex: Integer): Integer
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        PlacesInUse: Integer;
        GroupLimit: Integer;
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        TicketManagement.CalculateConcurrentCapacity(_AdmissionCode, ScheduleEntry."Schedule Code", _EventDate, PlacesInUse, GroupLimit);
        exit(PlacesInUse);
    end;

    local procedure JoinConcurrencyGroup(SlotIndex: Integer; ConcurrencyCode: Code[20])
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleLine.Get(_AdmissionCode, ScheduleEntry."Schedule Code");
        ScheduleLine."Concurrency Code" := ConcurrencyCode;
        ScheduleLine.Modify();
    end;

    #endregion

    #region Reservations

    procedure CreateReservation(Lines: JsonArray)
    begin
        _Token := PostReservation(Lines);
    end;

    // A line of two places and a line of one place of the scenario item, confirmed with a notification address and a ticket holder.
    procedure CreateTwoLineReservation(LineOneSlotIndex: Integer; LineTwoSlotIndex: Integer)
    var
        Lines: JsonArray;
    begin
        AddReserveLineTo(Lines, _ItemNo, 2, _AdmissionCode, SlotNo(LineOneSlotIndex));
        AddReserveLineTo(Lines, _ItemNo, 1, _AdmissionCode, SlotNo(LineTwoSlotIndex));
        CreateReservation(Lines);
        ConfirmReservation(_Token);
    end;

    procedure CreateTwoLineReservationWithLetterPin()
    var
        TicketSetup: Record "NPR TM Ticket Setup";
        PreviousScheme: Code[20];
    begin
        TicketSetup.Get();
        PreviousScheme := TicketSetup."Authorization Code Scheme";
        TicketSetup."Authorization Code Scheme" := CopyStr(LetterPinSchemeTok, 1, MaxStrLen(TicketSetup."Authorization Code Scheme"));
        TicketSetup.Modify();
        CreateTwoLineReservation(1, 1);
        TicketSetup.Get();
        TicketSetup."Authorization Code Scheme" := PreviousScheme;
        TicketSetup.Modify();
    end;

    procedure SellPlaces(SlotIndex: Integer; Quantity: Integer)
    var
        Lines: JsonArray;
    begin
        AddReserveLineTo(Lines, _ItemNo, Quantity, _AdmissionCode, SlotNo(SlotIndex));
        ConfirmReservation(PostReservation(Lines));
    end;

    // Moves the scenario admission of the ticket's line through the existing SOAP change and returns the token of the change rows; other admissions keep their slot.
    procedure MoveLineToSlot(TicketNumber: Text; SlotIndex: Integer) ChangeToken: Text[100]
    var
        TempCurrentRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TempTargetRequest: Record "NPR TM Ticket Reservation Req." temporary;
        TempReservationResponse: Record "NPR TM Ticket Reserv. Resp." temporary;
        TicketXmlApi: Codeunit "NPR Library - Ticket XML API";
        ResponseMessage: Text;
    begin
        ChangeToken := RequestLineChange(TicketNumber, TempCurrentRequest);
        TempCurrentRequest.FindSet();
        repeat
            TempTargetRequest.TransferFields(TempCurrentRequest, true);
            if (TempTargetRequest."Admission Code" = _AdmissionCode) then
                TempTargetRequest."External Adm. Sch. Entry No." := SlotNo(SlotIndex);
            TempTargetRequest.Insert();
        until (TempCurrentRequest.Next() = 0);
        _Assert.IsTrue(TicketXmlApi.ConfirmChangeTicketReservation(ChangeToken, TempCurrentRequest, TempTargetRequest, TempReservationResponse, ResponseMessage),
            StrSubstNo(ChangeSetupErr, TicketNumber, ResponseMessage));
    end;

    // Registers the SOAP change request for the ticket's line without confirming it, and returns the token of the change rows.
    procedure RequestLineChange(TicketNumber: Text; var TempCurrentRequest: Record "NPR TM Ticket Reservation Req." temporary) ChangeToken: Text[100]
    var
        TicketXmlApi: Codeunit "NPR Library - Ticket XML API";
        ResponseMessage: Text;
    begin
        _Assert.IsTrue(TicketXmlApi.GetTicketChangeRequest(CopyStr(TicketNumber, 1, 20), CopyStr(GetPin(), 1, 10), ChangeToken, TempCurrentRequest, ResponseMessage),
            StrSubstNo(ChangeSetupErr, TicketNumber, ResponseMessage));
    end;

    // Prefixes the first ticket number and the token with '!', so both sort before every other ticket number and token in their lookup keys.
    procedure SortIdentifiersFirst()
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        NewToken: Text[100];
    begin
        GetTicket(TicketNo(1, 1), Ticket);
        Ticket."External Ticket No." := CopyStr('!' + Ticket."External Ticket No.", 1, MaxStrLen(Ticket."External Ticket No."));
        Ticket.Modify();
        NewToken := CopyStr('!' + _Token, 1, MaxStrLen(NewToken));
        TicketReservationRequest.SetRange("Session Token ID", _Token);
        TicketReservationRequest.ModifyAll("Session Token ID", NewToken);
        _Token := NewToken;
    end;

    // Rewrites two lines the way old SOAP data stores them, with line reference 0 and a single primary row for both.
    procedure ShareLineReference(FirstLineReference: Integer; SecondLineReference: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        EntryNos: List of [Integer];
        EntryNo: Integer;
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', _Token);
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '%1|%2', FirstLineReference, SecondLineReference);
        TicketReservationRequest.FindSet();
        repeat
            EntryNos.Add(TicketReservationRequest."Entry No.");
        until (TicketReservationRequest.Next() = 0);

        foreach EntryNo in EntryNos do begin
            TicketReservationRequest.Get(EntryNo);
            if (TicketReservationRequest."Ext. Line Reference No." = SecondLineReference) then
                TicketReservationRequest."Primary Request Line" := false;
            TicketReservationRequest."Ext. Line Reference No." := 0;
            TicketReservationRequest.Modify();
        end;
    end;

    procedure DeselectLineAdmissions(LineReference: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', _Token);
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', LineReference);
        TicketReservationRequest.ModifyAll("Admission Inclusion", TicketReservationRequest."Admission Inclusion"::NOT_SELECTED);
    end;

    // Sets the access date directly, because ValidateTicketArrival refuses an arrival while the reserved slot is still in the future.
    procedure MarkAdmitted(TicketNumber: Text)
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        GetTicket(TicketNumber, Ticket);
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        TicketAccessEntry.SetFilter("Admission Code", '=%1', _AdmissionCode);
        TicketAccessEntry.FindFirst();
        TicketAccessEntry."Access Date" := LocalToday();
        TicketAccessEntry."Access Time" := DT2Time(LocalNow());
        TicketAccessEntry.Modify();
    end;

    procedure BlockTicket(TicketNumber: Text)
    var
        Ticket: Record "NPR TM Ticket";
    begin
        GetTicket(TicketNumber, Ticket);
        Ticket.Blocked := true;
        Ticket.Modify();
    end;

    procedure SetTicketValidity(ValidFromDate: Date; ValidToDate: Date)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', _Token);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindSet();
        repeat
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            Ticket.ModifyAll("Valid From Date", ValidFromDate);
            Ticket.ModifyAll("Valid To Date", ValidToDate);
        until (TicketReservationRequest.Next() = 0);
    end;

    procedure GetToken(): Text[100]
    begin
        exit(_Token);
    end;

    procedure GetPin(): Text
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', _Token);
        _Assert.IsTrue(TicketReservationRequest.FindFirst(), StrSubstNo(TokenRowsMissingErr, _Token));
        exit(TicketReservationRequest."Authorization Code");
    end;

    procedure TicketNo(LineReference: Integer; Position: Integer): Text
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Counter: Integer;
    begin
        GetPrimaryRow(_Token, LineReference, TicketReservationRequest);
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        if (Ticket.FindSet()) then
            repeat
                Counter += 1;
                if (Counter = Position) then
                    exit(Ticket."External Ticket No.");
            until (Ticket.Next() = 0);
        _Assert.Fail(StrSubstNo(TicketMissingErr, LineReference, _Token, Position));
    end;

    procedure TicketCount(LineReference: Integer): Integer
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        GetPrimaryRow(_Token, LineReference, TicketReservationRequest);
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        exit(Ticket.Count());
    end;

    procedure LineSystemId(LineReference: Integer): Guid
    begin
        exit(LineSystemId(_Token, LineReference));
    end;

    procedure LineSystemId(Token: Text[100]; LineReference: Integer): Guid
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        GetPrimaryRow(Token, LineReference, TicketReservationRequest);
        exit(TicketReservationRequest.SystemId);
    end;

    // Assembled at run time so the source holds no literal address (AA0240).
    procedure NotificationAddress(): Text
    begin
        exit(StrSubstNo(NotificationAddressTok, '@'));
    end;

    procedure TicketHolderName(): Text
    begin
        exit(TicketHolderNameTok);
    end;

    procedure LastRequestEntryNo(): Integer
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        if (TicketReservationRequest.FindLast()) then
            exit(TicketReservationRequest."Entry No.");
    end;

    procedure LastAccessDetailEntryNo(): Integer
    var
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        if (DetTicketAccessEntry.FindLast()) then
            exit(DetTicketAccessEntry."Entry No.");
    end;

    procedure AddReserveLineTo(var Lines: JsonArray; ItemNo: Code[20]; Quantity: Integer; AdmissionCode: Code[20]; ScheduleId: Integer)
    var
        Line: JsonObject;
        Content: JsonArray;
        ContentLine: JsonObject;
    begin
        ContentLine.Add('admissionCode', AdmissionCode);
        ContentLine.Add('scheduleId', ScheduleId);
        Content.Add(ContentLine);
        Line.Add('itemNumber', ItemNo);
        Line.Add('quantity', Quantity);
        Line.Add('content', Content);
        Lines.Add(Line);
    end;

    procedure AddAdmissionToLastReserveLine(var Lines: JsonArray; AdmissionCode: Code[20]; ScheduleId: Integer)
    var
        LineToken: JsonToken;
        ContentToken: JsonToken;
        ContentLine: JsonObject;
    begin
        Lines.Get(Lines.Count() - 1, LineToken);
        LineToken.AsObject().Get('content', ContentToken);
        ContentLine.Add('admissionCode', AdmissionCode);
        ContentLine.Add('scheduleId', ScheduleId);
        ContentToken.AsArray().Add(ContentLine);
    end;

    // Reserves through REST /ticket/reservation, because the SOAP MakeReservation helper gives every line of a token the same item, quantity and slot.
    local procedure PostReservation(Lines: JsonArray) ReservationToken: Text[100]
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        JToken: JsonToken;
        BodyText: Text;
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('reserve', Lines);
        Response := LibraryAPI.CallApi('POST', ReservationPathTok, Body, QueryParameters, Headers);
        ResponseBody := LibraryAPI.GetResponseBody(Response);
        ResponseBody.WriteTo(BodyText);
        _Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo(ReservationSetupErr, BodyText));
        _Assert.IsTrue(ResponseBody.Get('token', JToken), StrSubstNo(ReservationSetupErr, BodyText));
        ReservationToken := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ReservationToken));
    end;

    procedure ConfirmReservation(ReservationToken: Text[100])
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        Response: JsonObject;
        BodyText: Text;
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Body.Add('notificationAddress', NotificationAddress());
        Body.Add('ticketHolder', TicketHolderNameTok);
        Response := LibraryAPI.CallApi('POST', StrSubstNo(ConfirmPathTok, ReservationToken), Body, QueryParameters, Headers);
        LibraryAPI.GetResponseBody(Response).WriteTo(BodyText);
        _Assert.IsTrue(LibraryAPI.IsSuccessStatusCode(Response), StrSubstNo(ConfirmSetupErr, ReservationToken, BodyText));
    end;

    local procedure GetPrimaryRow(Token: Text[100]; LineReference: Integer; var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', LineReference);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        _Assert.IsTrue(TicketReservationRequest.FindFirst(), StrSubstNo(PrimaryRowMissingErr, Token, LineReference));
    end;

    local procedure GetTicket(TicketNumber: Text; var Ticket: Record "NPR TM Ticket")
    begin
        Ticket.SetCurrentKey("External Ticket No.");
        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketNumber, 1, MaxStrLen(Ticket."External Ticket No.")));
        _Assert.IsTrue(Ticket.FindFirst(), StrSubstNo(TicketNumberMissingErr, TicketNumber));
    end;

    #endregion

    #region Find calls

    procedure FindByTicketNumber(TicketNumber: Text; PinCode: Text): JsonObject
    var
        Body: JsonObject;
    begin
        Body.Add('ticketNumber', TicketNumber);
        Body.Add('pinCode', PinCode);
        exit(CallFind(Body));
    end;

    procedure FindByToken(ReservationToken: Text; PinCode: Text): JsonObject
    var
        Body: JsonObject;
    begin
        Body.Add('reservationToken', ReservationToken);
        Body.Add('pinCode', PinCode);
        exit(CallFind(Body));
    end;

    // An empty date text leaves the property out of the body.
    procedure FindByTicketNumberInWindow(TicketNumber: Text; PinCode: Text; FromDateText: Text; ToDateText: Text): JsonObject
    var
        Body: JsonObject;
    begin
        Body.Add('ticketNumber', TicketNumber);
        Body.Add('pinCode', PinCode);
        if (FromDateText <> '') then
            Body.Add('fromDate', FromDateText);
        if (ToDateText <> '') then
            Body.Add('toDate', ToDateText);
        exit(CallFind(Body));
    end;

    procedure CallFind(Body: JsonObject): JsonObject
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        exit(LibraryAPI.CallApi('POST', FindPathTok, Body, QueryParameters, Headers));
    end;

    #endregion

    #region Response assertions

    procedure TicketNotFoundMessage(): Text
    begin
        exit(TicketNotFoundTxt);
    end;

    procedure TokenNotFoundMessage(): Text
    begin
        exit(TokenNotFoundTxt);
    end;

    procedure AssertStatus(Response: JsonObject; ExpectedStatus: Integer; Context: Text)
    var
        LibraryAPIBI: Codeunit "NPR Library - API BI";
    begin
        _Assert.AreEqual(ExpectedStatus, LibraryAPIBI.GetStatusCode(Response), StrSubstNo(StatusErr, Context, ExpectedStatus, DescribeResponse(Response)));
    end;

    procedure AssertUniformNotFound(Response: JsonObject; ExpectedMessage: Text; Context: Text)
    var
        ActualMessage: Text;
    begin
        ActualMessage := AssertErrorResponse(Response, 404, 'resource_not_found', Context);
        _Assert.AreEqual(ExpectedMessage, ActualMessage, StrSubstNo(ErrorMessageErr, Context, ExpectedMessage));
    end;

    procedure AssertInvalidInput(Response: JsonObject; Context: Text)
    begin
        AssertErrorResponse(Response, 400, 'invalid_input', Context);
    end;

    procedure AssertInvalidInputNaming(Response: JsonObject; PropertyName: Text; Context: Text)
    var
        ActualMessage: Text;
    begin
        ActualMessage := AssertErrorResponse(Response, 400, 'invalid_input', Context);
        _Assert.IsTrue(ActualMessage.Contains(PropertyName), StrSubstNo(MessageNamesPropertyErr, Context, PropertyName, ActualMessage));
    end;

    procedure AssertInternalError(Response: JsonObject; Context: Text)
    var
        ActualMessage: Text;
    begin
        ActualMessage := AssertErrorResponse(Response, 400, 'generic_error', Context);
        _Assert.AreEqual(Format(InternalErrorTxt), ActualMessage, StrSubstNo(ErrorMessageErr, Context, InternalErrorTxt));
    end;

    procedure AssertReservationToken(Response: JsonObject; ExpectedToken: Text; Context: Text)
    begin
        _Assert.AreEqual(ExpectedToken, TextProperty(ReservationObject(Response, Context), 'reservationToken', Context), StrSubstNo(TokenErr, Context));
    end;

    procedure AssertLineCount(Response: JsonObject; ExpectedCount: Integer; Context: Text)
    var
        Lines: JsonArray;
    begin
        Lines := ArrayProperty(ReservationObject(Response, Context), 'reservationLines', Context);
        _Assert.AreEqual(ExpectedCount, Lines.Count(), StrSubstNo(LineCountErr, Context, ExpectedCount));
    end;

    procedure AssertLineQuantity(Response: JsonObject; LineReference: Integer; ExpectedQuantity: Integer; Context: Text)
    var
        LineContext: Text;
    begin
        LineContext := StrSubstNo(LineContextTok, Context, LineReference);
        _Assert.AreEqual(ExpectedQuantity, IntegerProperty(LineObject(Response, LineReference, Context), 'quantity', LineContext), StrSubstNo(LineValueErr, LineContext, 'quantity'));
    end;

    procedure AssertLineSystemId(Response: JsonObject; LineReference: Integer; ExpectedSystemId: Guid; Context: Text)
    var
        LineContext: Text;
    begin
        LineContext := StrSubstNo(LineContextTok, Context, LineReference);
        AssertSameGuid(ExpectedSystemId, TextProperty(LineObject(Response, LineReference, Context), 'systemId', LineContext), LineContext);
    end;

    // The full line shape of a line whose only admission can move: identity, ticket validity, current slot and slot list.
    procedure AssertMovableLine(Response: JsonObject; LineReference: Integer; TicketNumber: Text; ExpectedQuantity: Integer; ExpectedSystemId: Guid; CurrentSlotNo: Integer; ExpectedSlots: Text; Context: Text)
    var
        Ticket: Record "NPR TM Ticket";
        TMAdmission: Record "NPR TM Admission";
        Line: JsonObject;
        Admission: JsonObject;
        LineContext: Text;
    begin
        LineContext := StrSubstNo(LineContextTok, Context, LineReference);
        Line := LineObject(Response, LineReference, Context);
        GetTicket(TicketNumber, Ticket);
        AssertSameGuid(ExpectedSystemId, TextProperty(Line, 'systemId', LineContext), LineContext);
        _Assert.AreEqual(Format(Ticket."Item No."), TextProperty(Line, 'itemNumber', LineContext), StrSubstNo(LineValueErr, LineContext, 'itemNumber'));
        _Assert.AreEqual(Format(Ticket."Variant Code"), TextProperty(Line, 'variantCode', LineContext), StrSubstNo(LineValueErr, LineContext, 'variantCode'));
        _Assert.AreEqual(ExpectedQuantity, IntegerProperty(Line, 'quantity', LineContext), StrSubstNo(LineValueErr, LineContext, 'quantity'));
        _Assert.AreEqual(Format(Ticket."Valid From Date", 0, 9), TextProperty(Line, 'validFromDate', LineContext), StrSubstNo(LineValueErr, LineContext, 'validFromDate'));
        _Assert.AreEqual(Format(Ticket."Valid To Date", 0, 9), TextProperty(Line, 'validToDate', LineContext), StrSubstNo(LineValueErr, LineContext, 'validToDate'));
        _Assert.AreEqual(1, ArrayProperty(Line, 'admissions', LineContext).Count(), StrSubstNo(AdmissionCountErr, LineContext));
        Admission := AdmissionObject(Line, _AdmissionCode, LineContext);
        TMAdmission.Get(_AdmissionCode);
        _Assert.AreEqual(Format(TMAdmission.Description), TextProperty(Admission, 'description', LineContext), StrSubstNo(LineValueErr, LineContext, 'description'));
        _Assert.AreEqual(CurrentSlotNo, IntegerProperty(ObjectProperty(Admission, 'currentSchedule', LineContext), 'scheduleNumber', LineContext), StrSubstNo(CurrentScheduleErr, LineContext, CurrentSlotNo));
        AssertSlotTimes(ObjectProperty(Admission, 'currentSchedule', LineContext), CurrentSlotNo, LineContext);
        AssertAdmission(Response, LineReference, _AdmissionCode, true, '', ExpectedSlots, Context);
    end;

    procedure AssertCurrentSchedule(Response: JsonObject; LineReference: Integer; AdmissionCode: Code[20]; ExpectedScheduleId: Integer; Context: Text)
    var
        CurrentSchedule: JsonObject;
        AdmissionContext: Text;
    begin
        AdmissionContext := StrSubstNo(AdmissionContextTok, Context, LineReference, AdmissionCode);
        CurrentSchedule := ObjectProperty(AdmissionObject(LineObject(Response, LineReference, Context), AdmissionCode, AdmissionContext), 'currentSchedule', AdmissionContext);
        _Assert.AreEqual(ExpectedScheduleId, IntegerProperty(CurrentSchedule, 'scheduleNumber', AdmissionContext), StrSubstNo(CurrentScheduleErr, AdmissionContext, ExpectedScheduleId));
        AssertSlotTimes(CurrentSchedule, ExpectedScheduleId, AdmissionContext);
    end;

    procedure AssertAdmission(Response: JsonObject; LineReference: Integer; AdmissionCode: Code[20]; ExpectedAllowed: Boolean; ExpectedReason: Text; ExpectedSlots: Text; Context: Text)
    var
        Admission: JsonObject;
        AdmissionContext: Text;
    begin
        AdmissionContext := StrSubstNo(AdmissionContextTok, Context, LineReference, AdmissionCode);
        Admission := AdmissionObject(LineObject(Response, LineReference, Context), AdmissionCode, AdmissionContext);
        _Assert.AreEqual(ExpectedAllowed, BooleanProperty(Admission, 'rescheduleAllowed', AdmissionContext), StrSubstNo(AllowedErr, AdmissionContext, ExpectedAllowed));
        _Assert.AreEqual(ExpectedReason, TextProperty(Admission, 'reasonCode', AdmissionContext), StrSubstNo(ReasonErr, AdmissionContext, ExpectedReason));
        _Assert.AreEqual(ExpectedSlots, SlotList(Admission, AdmissionContext), StrSubstNo(SlotsErr, AdmissionContext, ExpectedSlots));
    end;

    procedure AssertSlotShape(Response: JsonObject; LineReference: Integer; ScheduleId: Integer; ExpectedDate: Date; Context: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Slot: JsonObject;
        SlotText: Text;
    begin
        Slot := SlotObject(Response, LineReference, ScheduleId, Context);
        _Assert.AreEqual(ScheduleId, IntegerProperty(Slot, 'scheduleNumber', Context), StrSubstNo(LineValueErr, Context, 'scheduleNumber'));
        _Assert.AreEqual(Format(ExpectedDate, 0, 9), TextProperty(Slot, 'startDate', Context), StrSubstNo(SlotDateErr, Context, 'startDate', ScheduleId, ExpectedDate));
        _Assert.AreEqual(Format(ExpectedDate, 0, 9), TextProperty(Slot, 'endDate', Context), StrSubstNo(SlotDateErr, Context, 'endDate', ScheduleId, ExpectedDate));
        AssertSlotTimes(Slot, ScheduleId, Context);
        Slot.WriteTo(SlotText);
        _Assert.IsTrue(JsonHelper.TokenExists(Slot.AsToken(), 'remainingCapacity'), StrSubstNo(PropertyMissingErr, Context, 'remainingCapacity', SlotText));
    end;

    // The expected values are the entry's admission times; CreateEventScenario moves the arrival times one minute inside the slot, so the two pairs differ.
    local procedure AssertSlotTimes(Slot: JsonObject; ScheduleId: Integer; Context: Text)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        ScheduleEntry.SetRange("External Schedule Entry No.", ScheduleId);
        ScheduleEntry.SetRange(Cancelled, false);
        ScheduleEntry.FindLast();
        _Assert.AreEqual(Format(ScheduleEntry."Admission Start Time", 0, 9), TextProperty(Slot, 'startTime', Context), StrSubstNo(SlotDateErr, Context, 'startTime', ScheduleId, Format(ScheduleEntry."Admission Start Time", 0, 9)));
        _Assert.AreEqual(Format(ScheduleEntry."Admission End Time", 0, 9), TextProperty(Slot, 'endTime', Context), StrSubstNo(SlotDateErr, Context, 'endTime', ScheduleId, Format(ScheduleEntry."Admission End Time", 0, 9)));
    end;

    procedure AssertSlotCapacity(Response: JsonObject; LineReference: Integer; ScheduleId: Integer; ExpectedRemaining: Integer; Context: Text)
    var
        JToken: JsonToken;
    begin
        PropertyValue(SlotObject(Response, LineReference, ScheduleId, Context), 'remainingCapacity', Context, JToken);
        _Assert.IsFalse(JToken.AsValue().IsNull(), StrSubstNo(RemainingErr, Context, ScheduleId, ExpectedRemaining));
        _Assert.AreEqual(ExpectedRemaining, JToken.AsValue().AsInteger(), StrSubstNo(RemainingErr, Context, ScheduleId, ExpectedRemaining));
    end;

    procedure AssertSlotCapacityIsNull(Response: JsonObject; LineReference: Integer; ScheduleId: Integer; Context: Text)
    var
        JToken: JsonToken;
    begin
        PropertyValue(SlotObject(Response, LineReference, ScheduleId, Context), 'remainingCapacity', Context, JToken);
        _Assert.IsTrue(JToken.IsValue(), StrSubstNo(RemainingNullErr, Context, ScheduleId));
        _Assert.IsTrue(JToken.AsValue().IsNull(), StrSubstNo(RemainingNullErr, Context, ScheduleId));
    end;

    procedure AssertBodyOmits(Response: JsonObject; Value: Text; WhatItIs: Text; Context: Text)
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        BodyText: Text;
    begin
        LibraryAPI.GetResponseBody(Response).WriteTo(BodyText);
        _Assert.IsFalse(LowerCase(BodyText).Contains(LowerCase(Value)), StrSubstNo(BodyLeakErr, Context, WhatItIs, Value));
    end;

    local procedure AssertErrorResponse(Response: JsonObject; ExpectedStatus: Integer; ExpectedCode: Text; Context: Text): Text
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        LibraryAPIBI: Codeunit "NPR Library - API BI";
    begin
        AssertStatus(Response, ExpectedStatus, Context);
        _Assert.AreEqual(ExpectedCode, LibraryAPIBI.GetErrorCode(Response), StrSubstNo(ErrorCodeErr, Context, ExpectedCode, DescribeResponse(Response)));
        exit(TextProperty(LibraryAPI.GetResponseBody(Response), 'message', Context));
    end;

    local procedure AssertSameGuid(Expected: Guid; ActualText: Text; Context: Text)
    begin
        _Assert.AreEqual(NormalizedGuid(Format(Expected)), NormalizedGuid(ActualText), StrSubstNo(SystemIdErr, Context, Expected));
    end;

    local procedure NormalizedGuid(GuidText: Text): Text
    begin
        exit(LowerCase(DelChr(GuidText, '=', '{}')));
    end;

    local procedure DescribeResponse(Response: JsonObject): Text
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        LibraryAPIBI: Codeunit "NPR Library - API BI";
        BodyText: Text;
    begin
        LibraryAPI.GetResponseBody(Response).WriteTo(BodyText);
        exit(StrSubstNo(ResponseDescriptionTok, LibraryAPIBI.GetStatusCode(Response), BodyText));
    end;

    local procedure ReservationObject(Response: JsonObject; Context: Text): JsonObject
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
    begin
        exit(ObjectProperty(LibraryAPI.GetResponseBody(Response), 'reservation', Context));
    end;

    local procedure LineObject(Response: JsonObject; LineReference: Integer; Context: Text): JsonObject
    var
        Lines: JsonArray;
        LineToken: JsonToken;
        LinesText: Text;
    begin
        Lines := ArrayProperty(ReservationObject(Response, Context), 'reservationLines', Context);
        foreach LineToken in Lines do
            if (LineToken.IsObject()) then
                if (IntegerProperty(LineToken.AsObject(), 'externalLineReference', Context) = LineReference) then
                    exit(LineToken.AsObject());
        Lines.WriteTo(LinesText);
        _Assert.Fail(StrSubstNo(LineMissingErr, Context, LineReference, LinesText));
    end;

    local procedure AdmissionObject(Line: JsonObject; AdmissionCode: Code[20]; Context: Text): JsonObject
    var
        Admissions: JsonArray;
        AdmissionToken: JsonToken;
        AdmissionsText: Text;
    begin
        Admissions := ArrayProperty(Line, 'admissions', Context);
        foreach AdmissionToken in Admissions do
            if (AdmissionToken.IsObject()) then
                if (TextProperty(AdmissionToken.AsObject(), 'admissionCode', Context) = AdmissionCode) then
                    exit(AdmissionToken.AsObject());
        Admissions.WriteTo(AdmissionsText);
        _Assert.Fail(StrSubstNo(AdmissionMissingErr, Context, AdmissionCode, AdmissionsText));
    end;

    local procedure SlotObject(Response: JsonObject; LineReference: Integer; ScheduleId: Integer; Context: Text): JsonObject
    var
        Slots: JsonArray;
        SlotToken: JsonToken;
        SlotsText: Text;
    begin
        Slots := ArrayProperty(AdmissionObject(LineObject(Response, LineReference, Context), _AdmissionCode, Context), 'slots', Context);
        foreach SlotToken in Slots do
            if (SlotToken.IsObject()) then
                if (IntegerProperty(SlotToken.AsObject(), 'scheduleNumber', Context) = ScheduleId) then
                    exit(SlotToken.AsObject());
        Slots.WriteTo(SlotsText);
        _Assert.Fail(StrSubstNo(SlotMissingErr, Context, ScheduleId, SlotsText));
    end;

    local procedure SlotList(Admission: JsonObject; Context: Text) SlotIdList: Text
    var
        Slots: JsonArray;
        SlotToken: JsonToken;
    begin
        Slots := ArrayProperty(Admission, 'slots', Context);
        foreach SlotToken in Slots do begin
            if (SlotIdList <> '') then
                SlotIdList += ',';
            SlotIdList += Format(IntegerProperty(ObjectValue(SlotToken, 'slots[]', Context), 'scheduleNumber', Context), 0, 9);
        end;
    end;

    local procedure ObjectProperty(Container: JsonObject; PropertyName: Text; Context: Text): JsonObject
    var
        JToken: JsonToken;
    begin
        PropertyValue(Container, PropertyName, Context, JToken);
        exit(ObjectValue(JToken, PropertyName, Context));
    end;

    local procedure ObjectValue(JToken: JsonToken; PropertyName: Text; Context: Text): JsonObject
    var
        ValueText: Text;
    begin
        if (JToken.IsObject()) then
            exit(JToken.AsObject());
        JToken.WriteTo(ValueText);
        _Assert.Fail(StrSubstNo(PropertyTypeErr, Context, PropertyName, 'object', ValueText));
    end;

    local procedure ArrayProperty(Container: JsonObject; PropertyName: Text; Context: Text): JsonArray
    var
        JToken: JsonToken;
        ValueText: Text;
    begin
        PropertyValue(Container, PropertyName, Context, JToken);
        if (JToken.IsArray()) then
            exit(JToken.AsArray());
        JToken.WriteTo(ValueText);
        _Assert.Fail(StrSubstNo(PropertyTypeErr, Context, PropertyName, 'array', ValueText));
    end;

    local procedure TextProperty(Container: JsonObject; PropertyName: Text; Context: Text): Text
    var
        JToken: JsonToken;
        ValueText: Text;
    begin
        PropertyValue(Container, PropertyName, Context, JToken);
        if (JToken.IsValue()) then begin
            if (JToken.AsValue().IsNull()) then
                exit('<null>');
            exit(JToken.AsValue().AsText());
        end;
        JToken.WriteTo(ValueText);
        _Assert.Fail(StrSubstNo(PropertyTypeErr, Context, PropertyName, 'value', ValueText));
    end;

    local procedure IntegerProperty(Container: JsonObject; PropertyName: Text; Context: Text): Integer
    var
        JToken: JsonToken;
        ValueText: Text;
    begin
        PropertyValue(Container, PropertyName, Context, JToken);
        if (JToken.IsValue()) then
            if (not JToken.AsValue().IsNull()) then
                exit(JToken.AsValue().AsInteger());
        JToken.WriteTo(ValueText);
        _Assert.Fail(StrSubstNo(PropertyTypeErr, Context, PropertyName, 'number', ValueText));
    end;

    local procedure BooleanProperty(Container: JsonObject; PropertyName: Text; Context: Text): Boolean
    var
        JToken: JsonToken;
        ValueText: Text;
    begin
        PropertyValue(Container, PropertyName, Context, JToken);
        if (JToken.IsValue()) then
            if (not JToken.AsValue().IsNull()) then
                exit(JToken.AsValue().AsBoolean());
        JToken.WriteTo(ValueText);
        _Assert.Fail(StrSubstNo(PropertyTypeErr, Context, PropertyName, 'boolean', ValueText));
    end;

    local procedure PropertyValue(Container: JsonObject; PropertyName: Text; Context: Text; var JToken: JsonToken)
    var
        ContainerText: Text;
    begin
        if (Container.Get(PropertyName, JToken)) then
            exit;
        Container.WriteTo(ContainerText);
        _Assert.Fail(StrSubstNo(PropertyMissingErr, Context, PropertyName, ContainerText));
    end;

    #endregion
}

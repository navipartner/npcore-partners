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
        _MarkedRequestEntryNo: Integer;
        _MarkedAccessDetailEntryNo: Integer;
        _MarkedNotificationEntryNo: Integer;
        _TempSnapshotRows: Record "NPR TM Ticket Reservation Req." temporary;
        _TempSnapshotTickets: Record "NPR TM Ticket" temporary;
        _TempSnapshotEntries: Record "NPR TM Det. Ticket AccessEntry" temporary;
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
        ChangePathTok: Label '/ticket/reschedule/change', Locked = true;
        InvalidReferenceTxt: Label '[RSC020] Line %1, admission %2: the line, the admission or the slot is not valid for this reservation now. Call find again.', Locked = true;
        NotAllowedTxt: Label '[RSC021] Line %1, admission %2: the admission cannot be rescheduled now (%3).', Locked = true;
        NoAdmissionCanMoveTxt: Label '[RSF010] No admission of this reservation can be rescheduled now. Reasons: %1.', Locked = true;
        NoTimeSlotTxt: Label '[RSF011] No admission of this reservation has a time slot that can be rescheduled.', Locked = true;
        CapacityExceededTxt: Label '[RSC022] Line %1, admission %2: the slot does not have capacity for the line.', Locked = true;
        ChangesNothingTxt: Label '[RSC023] Line %1 changes no admission.', Locked = true;
        BusyTxt: Label '[RSC024] The reservation is being changed by another request. Call find again.', Locked = true;
        ETicketTypeTok: Label 'RESCHEDULE-TEST', Locked = true;
        NpPassBaseUrlTok: Label 'https://np-pass.invalid/api/v1', Locked = true;
        NpPassApiTok: Label '/passes/%1/%2', Locked = true;
        NpPassTokenTok: Label 'reschedule-test-token', Locked = true;
        ResponseDescriptionTok: Label 'HTTP %1, body %2', Locked = true;
        ChangedLineContextTok: Label '%1, reservationLines[%2]', Locked = true;
        ChangedAdmissionContextTok: Label '%1, reservationLines[%2], admission %3', Locked = true;
        TicketContextTok: Label '%1, ticket %2, admission %3', Locked = true;
        TicketRowContextTok: Label '%1, ticket %2', Locked = true;
        LineContextTok: Label '%1, line with externalLineReference %2', Locked = true;
        AdmissionContextTok: Label '%1, line with externalLineReference %2, admission %3', Locked = true;
        EventDaySlotsErr: Label 'Setup: admission %1 must have exactly three open slots on %2.', Locked = true;
        ReservationSetupErr: Label 'Setup: POST /ticket/reservation must succeed. Response body: %1', Locked = true;
        ConfirmSetupErr: Label 'Setup: confirming reservation %1 must succeed. Response body: %2', Locked = true;
        ChangeSetupErr: Label 'Setup: moving the line of ticket %1 to another slot through the SOAP change must succeed: %2', Locked = true;
        AbandonedChangeSetupErr: Label 'Setup: the back-office change request for the line of ticket %1 must be registered: %2', Locked = true;
        ReservationEntryMissingErr: Label 'Setup: ticket %1 has no open reservation entry for admission %2.', Locked = true;
        ReplanSetupErr: Label 'Setup: the back-office replan of ticket %1, admission %2, to slot %3 must succeed.', Locked = true;
        PrimaryRowMissingErr: Label 'Setup: token %1 has no primary request row for line reference %2.', Locked = true;
        TokenRowsMissingErr: Label 'Setup: token %1 has no request rows.', Locked = true;
        TicketMissingErr: Label 'Setup: line reference %1 of token %2 has no ticket at position %3.', Locked = true;
        TicketNumberMissingErr: Label 'Setup: no ticket has the external ticket number %1.', Locked = true;
        AccessEntryMissingErr: Label 'Setup: ticket %1 has no access entry for admission %2.', Locked = true;
        InitialEntryMissingErr: Label 'Ticket %1 has no initial entry with a quantity for admission %2.', Locked = true;
        RefundSetupErr: Label 'Setup: the POS refund request for ticket %1 must be registered.', Locked = true;
        LineRevokeContextTxt: Label 'RevokeLine(%1)', Locked = true;
        CurrentRowRevokeSetupErr: Label '%1: Setup: the revoke request of the Ticket Request page for ticket %2 on the current row of its line must be registered.', Locked = true;
        LineTicketsLeftErr: Label '%1: Setup: no ticket may point at the primary row of line reference %2 of token %3 any more.', Locked = true;
        NoScheduleRowErr: Label '%1: Setup: the request row of admission %2, which has no schedule, must hold no slot.', Locked = true;
        MutexSetupErr: Label 'Setup: the reservation mutex for token %1 must be free before the test holds it.', Locked = true;
        ETicketSetupErr: Label 'Setup: the e-ticket of ticket %1 must be created: %2', Locked = true;
        StatusErr: Label '%1: expected HTTP %2. Got %3', Locked = true;
        ErrorCodeErr: Label '%1: expected error code %2. Got %3', Locked = true;
        ErrorMessageErr: Label '%1: expected the error message to be exactly "%2".', Locked = true;
        MessageNamesPropertyErr: Label '%1: expected the error message to name the property %2. Message: %3', Locked = true;
        MessageNamesLineErr: Label '%1: expected the error message to name the line %2. Message: %3', Locked = true;
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
        BodyKeysErr: Label '%1: the response body must hold reservationLines and nothing else. Body: %2', Locked = true;
        ChangedLineMissingErr: Label '%1: expected an entry at position %2 of reservationLines in %3', Locked = true;
        NewSystemIdErr: Label '%1: systemId must be a new GUID, not the systemId %2 of the line before the change. Got %3', Locked = true;
        AdmissionCountOfLineErr: Label '%1: expected %2 entries in admissions.', Locked = true;
        TicketSlotErr: Label '%1: the ticket must stand on slot %2.', Locked = true;
        TicketRowErr: Label '%1: the ticket must point at the request row with systemId %2.', Locked = true;
        TicketRowMissingErr: Label '%1: the request row the ticket points at does not exist.', Locked = true;
        NewInitialEntryErr: Label '%1: the move must write a new initial entry instead of reusing the old one.', Locked = true;
        NewInitialSlotErr: Label '%1: the new initial entry must be on slot %2.', Locked = true;
        PaymentLinkErr: Label '%1: the new initial entry must keep the payment link (closed by entry %2) of the old initial entry.', Locked = true;
        OldInitialOpenErr: Label '%1: the old initial entry must be closed.', Locked = true;
        ReversalMissingErr: Label '%1: the old initial entry must be closed by a reversal entry, but entry %2 does not exist.', Locked = true;
        ReversalQuantityErr: Label '%1: the reversal must hold quantity %2.', Locked = true;
        ReversalSlotErr: Label '%1: the reversal must be on the old slot %2.', Locked = true;
        ChangeRowMissingErr: Label '%1: no request row has the systemId %2 returned by the change.', Locked = true;
        ChangeRowValueErr: Label '%1: the primary row of the change must have %2 %3.', Locked = true;
        ChangeRowCountErr: Label '%1: the change token must hold %2 rows for the line, one per admission.', Locked = true;
        ChangeRowStatusErr: Label '%1: every row of the change must be CONFIRMED, none left REGISTERED.', Locked = true;
        ChangeRowParentErr: Label '%1: every row of the change must supersede request row %2.', Locked = true;
        ConfirmedChangeRowMissingErr: Label '%1: the change must hold a CONFIRMED CHANGE row for admission %2.', Locked = true;
        ChangeRowSlotErr: Label '%1: the CONFIRMED CHANGE row of admission %2 must hold slot %3.', Locked = true;
        ChangeRowScheduledTimeErr: Label '%1: the CONFIRMED CHANGE row of admission %2 must hold the start of slot %3 as its scheduled time.', Locked = true;
        ScheduledTimeTok: Label '%1 - %2', Locked = true;
        RowGoneErr: Label '%1: request row %2 must still exist.', Locked = true;
        RowChangedErr: Label '%1: %2 of request row %3 must be unchanged.', Locked = true;
        RowSupersededErr: Label '%1: no request row may supersede request row %2, so its line did not change.', Locked = true;
        RegisteredRowLeftErr: Label '%1: no REGISTERED request row may supersede request row %2.', Locked = true;
        RequestRowWrittenErr: Label '%1: no ticket reservation request row may be written, so no line moves.', Locked = true;
        AccessDetailWrittenErr: Label '%1: no detailed ticket access entry may be written, so no ticket moves.', Locked = true;
        NotificationWrittenErr: Label '%1: no ticket notification entry may be written.', Locked = true;
        ETicketUpdateNotSentErr: Label '%1: ticket %2 must have an e-ticket update notification entry with status SENT.', Locked = true;
        MutexLeftErr: Label '%1: the reservation mutex of token %2 must not be left behind.', Locked = true;
        SnapshotLineMissingErr: Label 'The snapshot holds no line with line reference %1 of token %2.', Locked = true;
        SnapshotTicketMissingErr: Label 'The snapshot holds no ticket at position %1 of the line with line reference %2.', Locked = true;
        SnapshotEntryMissingErr: Label 'The snapshot holds no initial entry of ticket %1 for admission %2.', Locked = true;
        InitialEntryChangedErr: Label '%1: the ticket must still stand on its initial entry %2.', Locked = true;
        ValidityChangedErr: Label '%1: %2 of the ticket must be unchanged.', Locked = true;

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

    // Tickets issued afterwards hold Quantity places of the scenario admission per ticket unit.
    procedure SetBomQuantity(Quantity: Integer)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        GetBom(TicketBom);
        TicketBom.Quantity := Quantity;
        TicketBom.Modify();
    end;

    // Another ticket item of the scenario's ticket type whose only admission is the scenario admission, under the reschedule policy of the scenario.
    procedure CreateItemOnAdmission(BomQuantity: Integer) ItemNo: Code[20]
    var
        Item: Record Item;
        TicketBom: Record "NPR TM Ticket Admission BOM";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
    begin
        Item.Get(_ItemNo);
        ItemNo := LibraryTicketModule.CreateItem('', Item."NPR Ticket Type", Item."Unit Price");
        LibraryTicketModule.CreateTicketBOM(ItemNo, '', _AdmissionCode, '', BomQuantity, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
        TicketBom.Get(ItemNo, '', _AdmissionCode);
        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::UNTIL_USED;
        TicketBom.Modify();
    end;

    // A further admission of the scenario item, under the reschedule policy of the scenario.
    procedure AddAdmission(AdmissionCode: Code[20]; IsDefault: Boolean)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
    begin
        LibraryTicketModule.CreateTicketBOM(_ItemNo, '', AdmissionCode, '', 1, IsDefault, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
        TicketBom.Get(_ItemNo, '', AdmissionCode);
        TicketBom."Reschedule Policy" := TicketBom."Reschedule Policy"::UNTIL_USED;
        TicketBom.Modify();
    end;

    // An admission with Default Schedule NONE, so its tickets hold it without a slot.
    procedure AddAdmissionWithoutSchedule() AdmissionCode: Code[20]
    var
        Admission: Record "NPR TM Admission";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
    begin
        AdmissionCode := LibraryTicketModule.CreateAdmissionCode(LibraryTicketModule.GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::NONE, '', '');
        AddAdmission(AdmissionCode, false);
    end;

    procedure DeleteAdmissionSetupLine(AdmissionCode: Code[20])
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        TicketBom.Get(_ItemNo, '', AdmissionCode);
        TicketBom.Delete();
    end;

    procedure ClearDefaultAdmission()
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
    begin
        GetBom(TicketBom);
        TicketBom.Default := false;
        TicketBom.Modify();
    end;

    procedure UseLocationAdmission()
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.Get(_AdmissionCode);
        Admission.Type := Admission.Type::LOCATION;
        Admission.Modify();
    end;

    // The scenario admission is published as e-ticket, NP Pass is set up at an address that never resolves,
    // and every ticket of the current reservation holds an e-ticket NP Pass already received.
    procedure IssueETickets()
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
        TempCreatedNotificationEntry: Record "NPR TM Ticket Notif. Entry" temporary;
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ReasonText: Text;
    begin
        TicketSetup.Get();
        TicketSetup."NP-Pass Server Base URL" := NpPassBaseUrlTok;
        TicketSetup."NP-Pass API" := NpPassApiTok;
        TicketSetup."NP-Pass Token" := NpPassTokenTok;
        TicketSetup.Modify();

        Item.Get(_ItemNo);
        TicketType.Get(Item."NPR Ticket Type");
        TicketType."eTicket Type Code" := ETicketTypeTok;
        TicketType."eTicket Activated" := true;
        TicketType.Modify();
        GetBom(TicketBom);
        TicketBom.Validate("Publish As eTicket", true);
        TicketBom.Modify();

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', _Token);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindSet();
        repeat
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            Ticket.FindSet();
            repeat
                _Assert.IsTrue(TicketRequestManager.CreateETicketNotificationEntry(Ticket, TempCreatedNotificationEntry, CopyStr(NotificationAddress(), 1, 100), false, true, ReasonText),
                    StrSubstNo(ETicketSetupErr, Ticket."External Ticket No.", ReasonText));
            until (Ticket.Next() = 0);
        until (TicketReservationRequest.Next() = 0);

        TempCreatedNotificationEntry.Reset();
        TempCreatedNotificationEntry.FindSet();
        repeat
            NotificationEntry.Get(TempCreatedNotificationEntry."Entry No.");
            NotificationEntry."Notification Send Status" := NotificationEntry."Notification Send Status"::SENT;
            NotificationEntry.Modify();
        until (TempCreatedNotificationEntry.Next() = 0);
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

    procedure SetSlotNotifyThreshold(SlotIndex: Integer; NotifyAtRemainingQuantity: Integer)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        ScheduleLine.Get(_AdmissionCode, ScheduleEntry."Schedule Code");
        ScheduleLine."Notify At Remaining Qty." := NotifyAtRemainingQuantity;
        ScheduleLine.Modify();
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
        ConcurrencyCode: Code[20];
    begin
        ConcurrencyCode := CreateConcurrencyGroup(TotalCapacity, GroupSetup."Capacity Control"::SALES, ConcurrencyType);
        JoinConcurrencyGroup(FirstSlotIndex, ConcurrencyCode);
        JoinConcurrencyGroup(SecondSlotIndex, ConcurrencyCode);
    end;

    procedure CreateConcurrencyGroup(TotalCapacity: Integer; CapacityControl: Option NA,SALES,ADMITTED,FULL,SEATING; ConcurrencyType: Option NA,ADMISSION,SCHEDULE,CONCURRENCY_CODE): Code[20]
    var
        GroupSetup: Record "NPR TM Concurrent Admis. Setup";
        LibraryTicketModule: Codeunit "NPR Library - Ticket Module";
    begin
        GroupSetup.Init();
        GroupSetup.Code := LibraryTicketModule.GenerateCode20();
        GroupSetup."Total Capacity" := TotalCapacity;
        GroupSetup."Capacity Control" := CapacityControl;
        GroupSetup."Concurrency Type" := ConcurrencyType;
        GroupSetup.Insert();
        exit(GroupSetup.Code);
    end;

    // The places the Sales capacity check counts on the slot: the quantity of the initial entries on it.
    procedure PlacesSoldOnSlot(SlotIndex: Integer): Integer
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        TicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        GetSlot(SlotIndex, ScheduleEntry);
        exit(TicketManagement.CalculateCurrentCapacity(Admission."Capacity Control"::SALES, ScheduleEntry."Entry No."));
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

    procedure JoinConcurrencyGroup(SlotIndex: Integer; ConcurrencyCode: Code[20])
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

    // One group ticket holds all the places of the sale, so a large sale costs a single ticket.
    procedure SellPlacesOnOneTicket(SlotIndex: Integer; Quantity: Integer)
    var
        Item: Record Item;
        TicketType: Record "NPR TM Ticket Type";
        PreviousRegistration: Option;
    begin
        Item.Get(_ItemNo);
        TicketType.Get(Item."NPR Ticket Type");
        PreviousRegistration := TicketType."Admission Registration";
        TicketType."Admission Registration" := TicketType."Admission Registration"::GROUP;
        TicketType.Modify();
        SellPlaces(SlotIndex, Quantity);
        TicketType.Get(Item."NPR Ticket Type");
        TicketType."Admission Registration" := PreviousRegistration;
        TicketType.Modify();
    end;

    // ValidateTicketArrival refuses an arrival while the slot lies ahead, so the open admitted entries of the sold tickets are written directly.
    procedure RecordAdmittedPlaces(SlotIndex: Integer; Quantity: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        Lines: JsonArray;
        SaleToken: Text[100];
    begin
        AddReserveLineTo(Lines, _ItemNo, Quantity, _AdmissionCode, SlotNo(SlotIndex));
        SaleToken := PostReservation(Lines);
        ConfirmReservation(SaleToken);
        GetPrimaryRow(SaleToken, 1, TicketReservationRequest);
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        Ticket.FindSet();
        repeat
            GetAccessEntry(Ticket."No.", _AdmissionCode, TicketAccessEntry);
            DetTicketAccessEntry.Init();
            DetTicketAccessEntry."Entry No." := 0;
            DetTicketAccessEntry."Ticket No." := Ticket."No.";
            DetTicketAccessEntry."Ticket Access Entry No." := TicketAccessEntry."Entry No.";
            DetTicketAccessEntry.Type := DetTicketAccessEntry.Type::ADMITTED;
            DetTicketAccessEntry."External Adm. Sch. Entry No." := SlotNo(SlotIndex);
            DetTicketAccessEntry.Quantity := TicketAccessEntry.Quantity;
            DetTicketAccessEntry.Open := true;
            DetTicketAccessEntry.Insert();
        until (Ticket.Next() = 0);
    end;

    // A line of two places of the scenario item and a line of one place of the other item, on the early slots, confirmed.
    // A second admission of the scenario item is reserved on the given slot when its code is given.
    procedure CreateReservationWithOtherItemLine(SecondAdmissionCode: Code[20]; SecondSlotNo: Integer; var OtherItem: Codeunit "NPR Library - TM Reschedule")
    var
        Lines: JsonArray;
    begin
        AddReserveLineTo(Lines, _ItemNo, 2, _AdmissionCode, SlotNo(1));
        if (SecondAdmissionCode <> '') then
            AddAdmissionToLastReserveLine(Lines, SecondAdmissionCode, SecondSlotNo);
        AddReserveLineTo(Lines, OtherItem.GetItemNo(), 1, OtherItem.GetAdmissionCode(), OtherItem.SlotNo(1));
        CreateReservation(Lines);
        ConfirmReservation(_Token);
    end;

    // A confirmed line of one place of the scenario item whose only admission, its default, has no schedule, so the request row holds no slot.
    procedure CreateOneLineReservationWithoutSchedule(Context: Text)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Lines: JsonArray;
        AdmissionCode: Code[20];
    begin
        AdmissionCode := AddAdmissionWithoutSchedule();
        DeleteAdmissionSetupLine();
        TicketBom.Get(_ItemNo, '', AdmissionCode);
        TicketBom.Default := true;
        TicketBom.Modify();
        AddReserveLineTo(Lines, _ItemNo, 1, AdmissionCode, 0);
        CreateReservation(Lines);
        ConfirmReservation(_Token);
        GetPrimaryRow(_Token, 1, TicketReservationRequest);
        _Assert.AreEqual(0, TicketReservationRequest."External Adm. Sch. Entry No.", StrSubstNo(NoScheduleRowErr, Context, AdmissionCode));
    end;

    // A refund the POS registered for the ticket and has not confirmed yet; the amount 0 keeps the prepaid refund prompts away.
    procedure CreateRefundRequest(TicketNumber: Text) RefundToken: Text[100]
    var
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        RefundAmount: Decimal;
    begin
        GetTicket(TicketNumber, Ticket);
        _Assert.IsTrue(TicketRequestManager.POS_CreateRevokeRequest(RefundToken, Ticket."No.", '', 0, RefundAmount), StrSubstNo(RefundSetupErr, TicketNumber));
    end;

    procedure CarryOutRefundRequest(RefundToken: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequestManager.RevokeReservationTokenRequest(RefundToken, false);
    end;

    // What the Revoke action of the Ticket Request page does to the line's primary row: its tickets revoked and blocked, the row set to CANCELED.
    procedure RevokeLine(LineReference: Integer)
    begin
        RevokeCurrentLineRow(TicketNo(LineReference, 1), StrSubstNo(LineRevokeContextTxt, LineReference));
    end;

    // The line's primary row set to CANCELED without a revoke, so its tickets stay unblocked.
    procedure CancelLineRow(LineReference: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        GetPrimaryRow(_Token, LineReference, TicketReservationRequest);
        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::CANCELED;
        TicketReservationRequest.Modify();
    end;

    // What the Revoke action of the Ticket Request page does to the row the ticket points at, the change row once its line moved: its tickets revoked and blocked, the row set to CANCELED.
    procedure RevokeCurrentLineRow(TicketNumber: Text; Context: Text)
    var
        Ticket: Record "NPR TM Ticket";
        RowTicket: Record "NPR TM Ticket";
        CurrentRow: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        RevokeToken: Text[100];
        AmountToReverse: Decimal;
    begin
        GetTicket(TicketNumber, Ticket);
        RevokeToken := TicketRequestManager.GetNewToken();
        RowTicket.SetCurrentKey("Ticket Reservation Entry No.");
        RowTicket.SetFilter("Ticket Reservation Entry No.", '=%1', Ticket."Ticket Reservation Entry No.");
        RowTicket.FindSet();
        repeat
            AmountToReverse := 0;
            _Assert.IsTrue(TicketRequestManager.POS_CreateRevokeRequest(RevokeToken, RowTicket."No.", CopyStr(UserId(), 1, 20), 0, AmountToReverse), StrSubstNo(CurrentRowRevokeSetupErr, Context, RowTicket."External Ticket No."));
        until (RowTicket.Next() = 0);
        TicketRequestManager.RevokeReservationTokenRequest(RevokeToken, false);
        CurrentRow.Get(Ticket."Ticket Reservation Entry No.");
        CurrentRow."Request Status" := CurrentRow."Request Status"::CANCELED;
        CurrentRow.Modify();
    end;

    // What the legacy XML web service leaves for a line the guest opted into the waiting list for: its primary row WAITINGLIST and no ticket pointing at it.
    procedure PutLineOnWaitingListWithoutTickets(LineReference: Integer; Context: Text)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        GetPrimaryRow(_Token, LineReference, TicketReservationRequest);
        TicketReservationRequest."Request Status" := TicketReservationRequest."Request Status"::WAITINGLIST;
        TicketReservationRequest.Modify();
        DeleteLineTickets(LineReference, Context);
    end;

    // Every ticket that points at the line's primary row is deleted; the row keeps its status.
    procedure DeleteLineTickets(LineReference: Integer; Context: Text)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        GetPrimaryRow(_Token, LineReference, TicketReservationRequest);
        Ticket.SetCurrentKey("Ticket Reservation Entry No.");
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        if (not Ticket.IsEmpty()) then
            Ticket.DeleteAll();
        _Assert.AreEqual(0, TicketCount(LineReference), StrSubstNo(LineTicketsLeftErr, Context, LineReference, _Token));
    end;

    // What the expiry job does to a token it expires: the rows stay, set to EXPIRED.
    procedure ExpireRequest(Token: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequestManager.DeleteReservationRequestV2(Token, false);
    end;

    // What the expiry job does to an expired token on a later run: the rows are removed.
    procedure RemoveExpiredRequest(Token: Text[100])
    var
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        TicketRequestManager.DeleteReservationRequestV2(Token, true);
    end;

    procedure HoldReservationMutex()
    var
        RequestMutex: Record "NPR TM TicketRequestMutex";
    begin
        _Assert.IsTrue(RequestMutex.Acquire(_Token, SessionId()), StrSubstNo(MutexSetupErr, _Token));
    end;

    procedure IsReservationMutexHeld(): Boolean
    var
        RequestMutex: Record "NPR TM TicketRequestMutex";
    begin
        exit(RequestMutex.Get(_Token));
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

    // What the back-office change page leaves behind when the user aborts it: the change request of the ticket's line, REGISTERED and never confirmed.
    procedure CreateAbandonedChangeRequest(TicketNumber: Text) ChangeToken: Text[100]
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ResponseMessage: Text;
    begin
        GetTicket(TicketNumber, Ticket);
        TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.");
        _Assert.IsTrue(TicketRequestManager.CreateChangeRequest(Ticket."External Ticket No.", TicketReservationRequest."Authorization Code", ChangeToken, ResponseMessage),
            StrSubstNo(AbandonedChangeSetupErr, TicketNumber, ResponseMessage));
    end;

    // What the back-office replan page does to the ticket's admission: its open reservation and its initial entry move to the slot, its request rows stay.
    procedure ReplanTicketAdmission(TicketNumber: Text; AdmissionCode: Code[20]; NewSlotNo: Integer)
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        CapacityWebHook: Codeunit "NPR TM CapacityWebHook";
    begin
        GetTicket(TicketNumber, Ticket);
        GetAccessEntry(Ticket."No.", AdmissionCode, TicketAccessEntry);
        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
        DetTicketAccessEntry.SetFilter(Open, '=%1', true);
        _Assert.IsTrue(DetTicketAccessEntry.FindLast(), StrSubstNo(ReservationEntryMissingErr, TicketNumber, AdmissionCode));
        _Assert.IsTrue(TicketManagement.ReplanReservation(DetTicketAccessEntry."Entry No.", NewSlotNo, true), StrSubstNo(ReplanSetupErr, TicketNumber, AdmissionCode, NewSlotNo));
        CapacityWebHook.EmitTouchedEntries();
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

    procedure UnblockTicket(TicketNumber: Text)
    var
        Ticket: Record "NPR TM Ticket";
    begin
        GetTicket(TicketNumber, Ticket);
        Ticket.Blocked := false;
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

    procedure WrongPin(): Text
    var
        PinCode: Text;
        LastCharacter: Char;
    begin
        PinCode := GetPin();
        LastCharacter := PinCode[StrLen(PinCode)];
        if (LastCharacter = '9') then
            LastCharacter := '0'
        else
            LastCharacter := LastCharacter + 1;
        exit(CopyStr(PinCode, 1, StrLen(PinCode) - 1) + Format(LastCharacter));
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

    procedure GetLineRow(LineReference: Integer; var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    begin
        GetPrimaryRow(_Token, LineReference, TicketReservationRequest);
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

    local procedure GetAccessEntry(InternalTicketNo: Code[20]; AdmissionCode: Code[20]; var TicketAccessEntry: Record "NPR TM Ticket Access Entry")
    begin
        TicketAccessEntry.SetCurrentKey("Ticket No.", "Admission Code");
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', InternalTicketNo);
        TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        _Assert.IsTrue(TicketAccessEntry.FindFirst(), StrSubstNo(AccessEntryMissingErr, InternalTicketNo, AdmissionCode));
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

    #region Change calls

    procedure AddChangeLine(var Lines: JsonArray; LineId: Guid; AdmissionCode: Code[20]; ScheduleId: Integer)
    begin
        AddRawChangeLine(Lines, ApiGuidText(LineId), ChangeAdmission(AdmissionCode, ScheduleId));
    end;

    procedure AddRawChangeLine(var Lines: JsonArray; SystemIdText: Text; Admission: JsonObject)
    var
        Line: JsonObject;
        Admissions: JsonArray;
    begin
        Admissions.Add(Admission);
        Line.Add('systemId', SystemIdText);
        Line.Add('admissions', Admissions);
        Lines.Add(Line);
    end;

    procedure AddAdmissionToLastChangeLine(var Lines: JsonArray; AdmissionCode: Code[20]; ScheduleId: Integer)
    var
        LineToken: JsonToken;
        AdmissionsToken: JsonToken;
    begin
        Lines.Get(Lines.Count() - 1, LineToken);
        LineToken.AsObject().Get('admissions', AdmissionsToken);
        AdmissionsToken.AsArray().Add(ChangeAdmission(AdmissionCode, ScheduleId));
    end;

    procedure ChangeAdmission(AdmissionCode: Text; ScheduleId: Integer) Admission: JsonObject
    begin
        Admission.Add('admissionCode', AdmissionCode);
        Admission.Add('scheduleNumber', ScheduleId);
    end;

    procedure ChangeBody(ReservationToken: Text; PinCode: Text; Lines: JsonArray) Body: JsonObject
    begin
        Body.Add('reservationToken', ReservationToken);
        Body.Add('pinCode', PinCode);
        Body.Add('reservationLines', Lines);
    end;

    procedure Change(Lines: JsonArray): JsonObject
    begin
        exit(CallChange(ChangeBody(_Token, GetPin(), Lines)));
    end;

    procedure ChangeLine(LineId: Guid; AdmissionCode: Code[20]; ScheduleId: Integer): JsonObject
    var
        Lines: JsonArray;
    begin
        AddChangeLine(Lines, LineId, AdmissionCode, ScheduleId);
        exit(Change(Lines));
    end;

    procedure CallChange(Body: JsonObject): JsonObject
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        exit(LibraryAPI.CallApi('POST', ChangePathTok, Body, QueryParameters, Headers));
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

    // Reasons is the list of reason codes as the message lists them, for example 'ALREADY_ADMITTED, NOT_ALLOWED'.
    procedure AssertNoAdmissionCanMove(Response: JsonObject; Reasons: Text; Context: Text)
    begin
        AssertExactError(Response, 400, 'reschedule_not_allowed', StrSubstNo(NoAdmissionCanMoveTxt, Reasons), Context);
    end;

    procedure AssertNoTimeSlotToReschedule(Response: JsonObject; Context: Text)
    begin
        AssertExactError(Response, 400, 'reschedule_not_allowed', NoTimeSlotTxt, Context);
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

    procedure ResponseBodyText(Response: JsonObject) BodyText: Text
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
    begin
        LibraryAPI.GetResponseBody(Response).WriteTo(BodyText);
    end;

    procedure AssertAdmissionCount(Response: JsonObject; LineReference: Integer; ExpectedCount: Integer; Context: Text)
    var
        LineContext: Text;
    begin
        LineContext := StrSubstNo(LineContextTok, Context, LineReference);
        _Assert.AreEqual(ExpectedCount, ArrayProperty(LineObject(Response, LineReference, Context), 'admissions', LineContext).Count(), StrSubstNo(AdmissionCountOfLineErr, LineContext, ExpectedCount));
    end;

    procedure AssertAdmissionAllowed(Response: JsonObject; LineReference: Integer; AdmissionCode: Code[20]; ExpectedAllowed: Boolean; Context: Text)
    var
        AdmissionContext: Text;
    begin
        AdmissionContext := StrSubstNo(AdmissionContextTok, Context, LineReference, AdmissionCode);
        _Assert.AreEqual(ExpectedAllowed, BooleanProperty(AdmissionObject(LineObject(Response, LineReference, Context), AdmissionCode, AdmissionContext), 'rescheduleAllowed', AdmissionContext), StrSubstNo(AllowedErr, AdmissionContext, ExpectedAllowed));
    end;

    #endregion

    #region Change response assertions

    procedure AssertBodyHoldsOnlyReservationLines(Response: JsonObject; Context: Text)
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
        Body: JsonObject;
        BodyText: Text;
    begin
        Body := LibraryAPI.GetResponseBody(Response);
        Body.WriteTo(BodyText);
        _Assert.AreEqual(1, Body.Keys().Count(), StrSubstNo(BodyKeysErr, Context, BodyText));
        _Assert.IsTrue(Body.Contains('reservationLines'), StrSubstNo(BodyKeysErr, Context, BodyText));
    end;

    procedure AssertChangedLineCount(Response: JsonObject; ExpectedCount: Integer; Context: Text)
    begin
        _Assert.AreEqual(ExpectedCount, ChangedLines(Response, Context).Count(), StrSubstNo(LineCountErr, Context, ExpectedCount));
    end;

    // Position counts from 1 in request order. Returns the new systemId of the line.
    procedure AssertChangedLine(Response: JsonObject; Position: Integer; FormerSystemId: Guid; ExpectedQuantity: Integer; Context: Text) NewSystemId: Guid
    var
        Line: JsonObject;
        LineContext: Text;
        SystemIdText: Text;
    begin
        LineContext := StrSubstNo(ChangedLineContextTok, Context, Position - 1);
        Line := ChangedLineObject(Response, Position, Context);
        SystemIdText := TextProperty(Line, 'systemId', LineContext);
        _Assert.IsTrue(Evaluate(NewSystemId, SystemIdText), StrSubstNo(NewSystemIdErr, LineContext, ApiGuidText(FormerSystemId), SystemIdText));
        _Assert.AreNotEqual(ApiGuidText(FormerSystemId), ApiGuidText(NewSystemId), StrSubstNo(NewSystemIdErr, LineContext, ApiGuidText(FormerSystemId), SystemIdText));
        _Assert.AreEqual(Format(_ItemNo), TextProperty(Line, 'itemNumber', LineContext), StrSubstNo(LineValueErr, LineContext, 'itemNumber'));
        _Assert.AreEqual('', TextProperty(Line, 'variantCode', LineContext), StrSubstNo(LineValueErr, LineContext, 'variantCode'));
        _Assert.AreEqual(ExpectedQuantity, IntegerProperty(Line, 'quantity', LineContext), StrSubstNo(LineValueErr, LineContext, 'quantity'));
    end;

    procedure AssertChangedAdmissionCount(Response: JsonObject; Position: Integer; ExpectedCount: Integer; Context: Text)
    var
        LineContext: Text;
    begin
        LineContext := StrSubstNo(ChangedLineContextTok, Context, Position - 1);
        _Assert.AreEqual(ExpectedCount, ArrayProperty(ChangedLineObject(Response, Position, Context), 'admissions', LineContext).Count(), StrSubstNo(AdmissionCountOfLineErr, LineContext, ExpectedCount));
    end;

    // The admission carries the resulting slot with the dates and times of its schedule entry.
    procedure AssertChangedAdmission(Response: JsonObject; Position: Integer; AdmissionCode: Code[20]; ExpectedScheduleId: Integer; Context: Text)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: JsonObject;
        AdmissionContext: Text;
    begin
        AdmissionContext := StrSubstNo(ChangedAdmissionContextTok, Context, Position - 1, AdmissionCode);
        Admission := AdmissionObject(ChangedLineObject(Response, Position, Context), AdmissionCode, AdmissionContext);
        _Assert.AreEqual(ExpectedScheduleId, IntegerProperty(Admission, 'scheduleNumber', AdmissionContext), StrSubstNo(CurrentScheduleErr, AdmissionContext, ExpectedScheduleId));
        ScheduleEntry.SetRange("External Schedule Entry No.", ExpectedScheduleId);
        ScheduleEntry.SetRange(Cancelled, false);
        ScheduleEntry.FindLast();
        _Assert.AreEqual(Format(ScheduleEntry."Admission Start Date", 0, 9), TextProperty(Admission, 'startDate', AdmissionContext), StrSubstNo(SlotDateErr, AdmissionContext, 'startDate', ExpectedScheduleId, ScheduleEntry."Admission Start Date"));
        _Assert.AreEqual(Format(ScheduleEntry."Admission End Date", 0, 9), TextProperty(Admission, 'endDate', AdmissionContext), StrSubstNo(SlotDateErr, AdmissionContext, 'endDate', ExpectedScheduleId, ScheduleEntry."Admission End Date"));
        AssertSlotTimes(Admission, ExpectedScheduleId, AdmissionContext);
    end;

    procedure AssertInvalidReference(Response: JsonObject; LineId: Guid; AdmissionCode: Code[20]; Context: Text)
    begin
        AssertExactError(Response, 400, 'invalid_reference', StrSubstNo(InvalidReferenceTxt, ApiGuidText(LineId), AdmissionCode), Context);
    end;

    procedure AssertNotAllowed(Response: JsonObject; LineId: Guid; AdmissionCode: Code[20]; ReasonCode: Text; Context: Text)
    begin
        AssertExactError(Response, 400, 'reschedule_not_allowed', StrSubstNo(NotAllowedTxt, ApiGuidText(LineId), AdmissionCode, ReasonCode), Context);
    end;

    // The refusal code and the line it names, without the rest of the message text.
    procedure AssertNotAllowedNamingLine(Response: JsonObject; LineId: Guid; Context: Text)
    var
        ActualMessage: Text;
    begin
        ActualMessage := AssertErrorResponse(Response, 400, 'reschedule_not_allowed', Context);
        _Assert.IsTrue(ActualMessage.Contains(ApiGuidText(LineId)), StrSubstNo(MessageNamesLineErr, Context, ApiGuidText(LineId), ActualMessage));
    end;

    procedure AssertCapacityExceeded(Response: JsonObject; LineId: Guid; AdmissionCode: Code[20]; Context: Text)
    begin
        AssertExactError(Response, 400, 'capacity_exceeded', StrSubstNo(CapacityExceededTxt, ApiGuidText(LineId), AdmissionCode), Context);
    end;

    procedure AssertChangesNothing(Response: JsonObject; LineId: Guid; Context: Text)
    begin
        AssertExactError(Response, 400, 'invalid_input', StrSubstNo(ChangesNothingTxt, ApiGuidText(LineId)), Context);
    end;

    procedure AssertBusy(Response: JsonObject; Context: Text)
    begin
        AssertExactError(Response, 400, 'invalid_reference', BusyTxt, Context);
    end;

    local procedure AssertExactError(Response: JsonObject; ExpectedStatus: Integer; ExpectedCode: Text; ExpectedMessage: Text; Context: Text)
    begin
        _Assert.AreEqual(ExpectedMessage, AssertErrorResponse(Response, ExpectedStatus, ExpectedCode, Context), StrSubstNo(ErrorMessageErr, Context, ExpectedMessage));
    end;

    local procedure ChangedLines(Response: JsonObject; Context: Text): JsonArray
    var
        LibraryAPI: Codeunit "NPR Library - NPRetail API";
    begin
        exit(ArrayProperty(LibraryAPI.GetResponseBody(Response), 'reservationLines', Context));
    end;

    local procedure ChangedLineObject(Response: JsonObject; Position: Integer; Context: Text): JsonObject
    var
        Lines: JsonArray;
        LineToken: JsonToken;
        LinesText: Text;
    begin
        Lines := ChangedLines(Response, Context);
        if (Lines.Get(Position - 1, LineToken)) then
            exit(ObjectValue(LineToken, 'reservationLines[]', Context));
        Lines.WriteTo(LinesText);
        _Assert.Fail(StrSubstNo(ChangedLineMissingErr, Context, Position - 1, LinesText));
    end;

    // The format the API writes a systemId in: lower case, no braces.
    local procedure ApiGuidText(Value: Guid): Text
    begin
        exit(NormalizedGuid(Format(Value)));
    end;

    #endregion

    #region Stored state

    // The slot the ticket stands on for the admission, read the way the change request reads it.
    procedure CurrentSlotOfTicket(TicketNumber: Text; AdmissionCode: Code[20]) CurrentSlot: Integer
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        GetTicket(TicketNumber, Ticket);
        GetAccessEntry(Ticket."No.", AdmissionCode, TicketAccessEntry);
        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        if (DetTicketAccessEntry.FindLast()) then
            CurrentSlot := DetTicketAccessEntry."External Adm. Sch. Entry No.";
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
        if (DetTicketAccessEntry.FindLast()) then
            CurrentSlot := DetTicketAccessEntry."External Adm. Sch. Entry No.";
    end;

    procedure AssertTicketOnSlot(TicketNumber: Text; AdmissionCode: Code[20]; ExpectedSlotNo: Integer; Context: Text)
    begin
        _Assert.AreEqual(ExpectedSlotNo, CurrentSlotOfTicket(TicketNumber, AdmissionCode), StrSubstNo(TicketSlotErr, StrSubstNo(TicketContextTok, Context, TicketNumber, AdmissionCode), ExpectedSlotNo));
    end;

    procedure AssertTicketOnRow(TicketNumber: Text; ExpectedRowSystemId: Guid; Context: Text)
    var
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketRowContext: Text;
    begin
        TicketRowContext := StrSubstNo(TicketRowContextTok, Context, TicketNumber);
        GetTicket(TicketNumber, Ticket);
        _Assert.IsTrue(TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No."), StrSubstNo(TicketRowMissingErr, TicketRowContext));
        _Assert.AreEqual(ApiGuidText(ExpectedRowSystemId), ApiGuidText(TicketReservationRequest.SystemId), StrSubstNo(TicketRowErr, TicketRowContext, ApiGuidText(ExpectedRowSystemId)));
    end;

    procedure GetInitialEntry(TicketNumber: Text; AdmissionCode: Code[20]; var DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    var
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        GetTicket(TicketNumber, Ticket);
        GetAccessEntry(Ticket."No.", AdmissionCode, TicketAccessEntry);
        DetTicketAccessEntry.Reset();
        DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
        DetTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
        _Assert.IsTrue(DetTicketAccessEntry.FindLast(), StrSubstNo(InitialEntryMissingErr, TicketNumber, AdmissionCode));
    end;

    // The stored result of the move of one ticket's admission: a new initial entry on the new slot that keeps the payment link,
    // and the old initial entry closed by a reversal of its quantity on the old slot.
    procedure AssertTicketMoved(TicketNumber: Text; AdmissionCode: Code[20]; OldInitialEntry: Record "NPR TM Det. Ticket AccessEntry"; NewSlotNo: Integer; Context: Text)
    var
        NewInitialEntry: Record "NPR TM Det. Ticket AccessEntry";
        ClosedInitialEntry: Record "NPR TM Det. Ticket AccessEntry";
        ReversalEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketContext: Text;
    begin
        TicketContext := StrSubstNo(TicketContextTok, Context, TicketNumber, AdmissionCode);
        GetInitialEntry(TicketNumber, AdmissionCode, NewInitialEntry);
        _Assert.AreNotEqual(OldInitialEntry."Entry No.", NewInitialEntry."Entry No.", StrSubstNo(NewInitialEntryErr, TicketContext));
        _Assert.AreEqual(NewSlotNo, NewInitialEntry."External Adm. Sch. Entry No.", StrSubstNo(NewInitialSlotErr, TicketContext, NewSlotNo));
        _Assert.AreEqual(OldInitialEntry."Closed By Entry No.", NewInitialEntry."Closed By Entry No.", StrSubstNo(PaymentLinkErr, TicketContext, OldInitialEntry."Closed By Entry No."));
        _Assert.IsTrue(ClosedInitialEntry.Get(OldInitialEntry."Entry No."), StrSubstNo(ReversalMissingErr, TicketContext, OldInitialEntry."Entry No."));
        _Assert.IsFalse(ClosedInitialEntry.Open, StrSubstNo(OldInitialOpenErr, TicketContext));
        _Assert.IsTrue(ReversalEntry.Get(ClosedInitialEntry."Closed By Entry No."), StrSubstNo(ReversalMissingErr, TicketContext, ClosedInitialEntry."Closed By Entry No."));
        _Assert.AreEqual(-OldInitialEntry.Quantity, ReversalEntry.Quantity, StrSubstNo(ReversalQuantityErr, TicketContext, -OldInitialEntry.Quantity));
        _Assert.AreEqual(OldInitialEntry."External Adm. Sch. Entry No.", ReversalEntry."External Adm. Sch. Entry No.", StrSubstNo(ReversalSlotErr, TicketContext, OldInitialEntry."External Adm. Sch. Entry No."));
    end;

    // The rows of the change: its primary row carries the returned systemId and supersedes the line's former row,
    // one CONFIRMED row per admission, and the pin, address and holder name of the former row.
    procedure AssertChangeRows(NewSystemId: Guid; FormerRow: Record "NPR TM Ticket Reservation Req."; ExpectedAdmissionCount: Integer; Context: Text)
    var
        PrimaryChangeRow: Record "NPR TM Ticket Reservation Req.";
        ChangeRow: Record "NPR TM Ticket Reservation Req.";
    begin
        _Assert.IsTrue(PrimaryChangeRow.GetBySystemId(NewSystemId), StrSubstNo(ChangeRowMissingErr, Context, ApiGuidText(NewSystemId)));
        _Assert.IsTrue(PrimaryChangeRow."Entry Type" = PrimaryChangeRow."Entry Type"::CHANGE, StrSubstNo(ChangeRowValueErr, Context, PrimaryChangeRow.FieldCaption("Entry Type"), 'CHANGE'));
        _Assert.IsTrue(PrimaryChangeRow."Primary Request Line", StrSubstNo(ChangeRowValueErr, Context, PrimaryChangeRow.FieldCaption("Primary Request Line"), true));
        _Assert.AreEqual(FormerRow."Entry No.", PrimaryChangeRow."Superseeds Entry No.", StrSubstNo(ChangeRowValueErr, Context, PrimaryChangeRow.FieldCaption("Superseeds Entry No."), FormerRow."Entry No."));
        _Assert.AreEqual(FormerRow."Authorization Code", PrimaryChangeRow."Authorization Code", StrSubstNo(ChangeRowValueErr, Context, PrimaryChangeRow.FieldCaption("Authorization Code"), 'of the former row'));
        _Assert.AreEqual(FormerRow."Notification Address", PrimaryChangeRow."Notification Address", StrSubstNo(ChangeRowValueErr, Context, PrimaryChangeRow.FieldCaption("Notification Address"), 'of the former row'));
        _Assert.AreEqual(FormerRow.TicketHolderName, PrimaryChangeRow.TicketHolderName, StrSubstNo(ChangeRowValueErr, Context, PrimaryChangeRow.FieldCaption(TicketHolderName), 'of the former row'));

        ChangeRow.SetFilter("Session Token ID", '=%1', PrimaryChangeRow."Session Token ID");
        ChangeRow.SetFilter("Ext. Line Reference No.", '=%1', PrimaryChangeRow."Ext. Line Reference No.");
        _Assert.AreEqual(ExpectedAdmissionCount, ChangeRow.Count(), StrSubstNo(ChangeRowCountErr, Context, ExpectedAdmissionCount));
        ChangeRow.SetFilter("Request Status", '<>%1', ChangeRow."Request Status"::CONFIRMED);
        _Assert.IsTrue(ChangeRow.IsEmpty(), StrSubstNo(ChangeRowStatusErr, Context));
        ChangeRow.SetRange("Request Status");
        ChangeRow.SetFilter("Superseeds Entry No.", '<>%1', FormerRow."Entry No.");
        _Assert.IsTrue(ChangeRow.IsEmpty(), StrSubstNo(ChangeRowParentErr, Context, FormerRow."Entry No."));
    end;

    // The CONFIRMED CHANGE row of the admission among the rows of the change holds the slot and, as its scheduled time, the start of that slot.
    procedure AssertChangeRowOnSlot(NewSystemId: Guid; AdmissionCode: Code[20]; ExpectedSlotNo: Integer; Context: Text)
    var
        PrimaryChangeRow: Record "NPR TM Ticket Reservation Req.";
        ChangeRow: Record "NPR TM Ticket Reservation Req.";
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        _Assert.IsTrue(PrimaryChangeRow.GetBySystemId(NewSystemId), StrSubstNo(ChangeRowMissingErr, Context, ApiGuidText(NewSystemId)));
        ChangeRow.SetFilter("Session Token ID", '=%1', PrimaryChangeRow."Session Token ID");
        ChangeRow.SetFilter("Ext. Line Reference No.", '=%1', PrimaryChangeRow."Ext. Line Reference No.");
        ChangeRow.SetFilter("Admission Code", '=%1', AdmissionCode);
        ChangeRow.SetFilter("Entry Type", '=%1', ChangeRow."Entry Type"::CHANGE);
        ChangeRow.SetFilter("Request Status", '=%1', ChangeRow."Request Status"::CONFIRMED);
        _Assert.IsTrue(ChangeRow.FindFirst(), StrSubstNo(ConfirmedChangeRowMissingErr, Context, AdmissionCode));
        _Assert.AreEqual(ExpectedSlotNo, ChangeRow."External Adm. Sch. Entry No.", StrSubstNo(ChangeRowSlotErr, Context, AdmissionCode, ExpectedSlotNo));
        ScheduleEntry.SetRange("External Schedule Entry No.", ExpectedSlotNo);
        ScheduleEntry.SetRange(Cancelled, false);
        ScheduleEntry.FindLast();
        _Assert.AreEqual(StrSubstNo(ScheduledTimeTok, ScheduleEntry."Admission Start Date", ScheduleEntry."Admission Start Time"), ChangeRow."Scheduled Time Description",
            StrSubstNo(ChangeRowScheduledTimeErr, Context, AdmissionCode, ExpectedSlotNo));
    end;

    procedure AssertRowUnchanged(RowBefore: Record "NPR TM Ticket Reservation Req."; Context: Text)
    var
        RowNow: Record "NPR TM Ticket Reservation Req.";
    begin
        _Assert.IsTrue(RowNow.Get(RowBefore."Entry No."), StrSubstNo(RowGoneErr, Context, RowBefore."Entry No."));
        _Assert.AreEqual(RowBefore."Session Token ID", RowNow."Session Token ID", StrSubstNo(RowChangedErr, Context, RowNow.FieldCaption("Session Token ID"), RowBefore."Entry No."));
        _Assert.IsTrue(RowBefore."Request Status" = RowNow."Request Status", StrSubstNo(RowChangedErr, Context, RowNow.FieldCaption("Request Status"), RowBefore."Entry No."));
        _Assert.IsTrue(RowBefore."Entry Type" = RowNow."Entry Type", StrSubstNo(RowChangedErr, Context, RowNow.FieldCaption("Entry Type"), RowBefore."Entry No."));
        _Assert.AreEqual(RowBefore."External Adm. Sch. Entry No.", RowNow."External Adm. Sch. Entry No.", StrSubstNo(RowChangedErr, Context, RowNow.FieldCaption("External Adm. Sch. Entry No."), RowBefore."Entry No."));
        _Assert.AreEqual(RowBefore."Primary Request Line", RowNow."Primary Request Line", StrSubstNo(RowChangedErr, Context, RowNow.FieldCaption("Primary Request Line"), RowBefore."Entry No."));
        _Assert.AreEqual(RowBefore."Superseeds Entry No.", RowNow."Superseeds Entry No.", StrSubstNo(RowChangedErr, Context, RowNow.FieldCaption("Superseeds Entry No."), RowBefore."Entry No."));
    end;

    procedure AssertNotSuperseded(Row: Record "NPR TM Ticket Reservation Req."; Context: Text)
    var
        ChildRow: Record "NPR TM Ticket Reservation Req.";
    begin
        ChildRow.SetCurrentKey("Superseeds Entry No.");
        ChildRow.SetFilter("Superseeds Entry No.", '=%1', Row."Entry No.");
        _Assert.IsTrue(ChildRow.IsEmpty(), StrSubstNo(RowSupersededErr, Context, Row."Entry No."));
    end;

    procedure AssertNoRegisteredRowSuperseding(Row: Record "NPR TM Ticket Reservation Req."; Context: Text)
    var
        ChildRow: Record "NPR TM Ticket Reservation Req.";
    begin
        ChildRow.SetCurrentKey("Superseeds Entry No.");
        ChildRow.SetFilter("Superseeds Entry No.", '=%1', Row."Entry No.");
        ChildRow.SetFilter("Request Status", '=%1', ChildRow."Request Status"::REGISTERED);
        _Assert.IsTrue(ChildRow.IsEmpty(), StrSubstNo(RegisteredRowLeftErr, Context, Row."Entry No."));
    end;

    procedure SnapshotTokenRows(Token: Text[100]; var TempRows: Record "NPR TM Ticket Reservation Req." temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        _Assert.IsTrue(TicketReservationRequest.FindSet(), StrSubstNo(TokenRowsMissingErr, Token));
        repeat
            TempRows := TicketReservationRequest;
            TempRows.Insert();
        until (TicketReservationRequest.Next() = 0);
    end;

    procedure AssertRowsUnchanged(var TempRows: Record "NPR TM Ticket Reservation Req." temporary; Context: Text)
    begin
        TempRows.Reset();
        TempRows.FindSet();
        repeat
            AssertRowUnchanged(TempRows, Context);
        until (TempRows.Next() = 0);
    end;

    // Remembers every line of the current reservation as it stands before a change: its primary row, its tickets,
    // and the initial entry each ticket stands on per admission.
    procedure SnapshotLines()
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        _TempSnapshotRows.Reset();
        _TempSnapshotRows.DeleteAll();
        _TempSnapshotTickets.Reset();
        _TempSnapshotTickets.DeleteAll();
        _TempSnapshotEntries.Reset();
        _TempSnapshotEntries.DeleteAll();

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', _Token);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindSet();
        repeat
            _TempSnapshotRows := TicketReservationRequest;
            _TempSnapshotRows.Insert();
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then
                repeat
                    _TempSnapshotTickets := Ticket;
                    _TempSnapshotTickets.Insert();
                    TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                    if (TicketAccessEntry.FindSet()) then
                        repeat
                            DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                            DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::INITIAL_ENTRY);
                            DetTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
                            if (DetTicketAccessEntry.FindLast()) then begin
                                _TempSnapshotEntries := DetTicketAccessEntry;
                                _TempSnapshotEntries.Insert();
                            end;
                        until (TicketAccessEntry.Next() = 0);
                until (Ticket.Next() = 0);
        until (TicketReservationRequest.Next() = 0);
    end;

    procedure GetSnapshotRow(LineReference: Integer; var TicketReservationRequest: Record "NPR TM Ticket Reservation Req.")
    begin
        _TempSnapshotRows.Reset();
        _TempSnapshotRows.SetFilter("Ext. Line Reference No.", '=%1', LineReference);
        _Assert.IsTrue(_TempSnapshotRows.FindFirst(), StrSubstNo(SnapshotLineMissingErr, LineReference, _Token));
        TicketReservationRequest := _TempSnapshotRows;
    end;

    // The ticket numbers of a line as they were at the snapshot, also after a change moved the tickets to another row.
    procedure SnapshotTicketNo(LineReference: Integer; Position: Integer): Text
    var
        FormerRow: Record "NPR TM Ticket Reservation Req.";
        Counter: Integer;
    begin
        GetSnapshotRow(LineReference, FormerRow);
        _TempSnapshotTickets.Reset();
        _TempSnapshotTickets.SetFilter("Ticket Reservation Entry No.", '=%1', FormerRow."Entry No.");
        if (_TempSnapshotTickets.FindSet()) then
            repeat
                Counter += 1;
                if (Counter = Position) then
                    exit(_TempSnapshotTickets."External Ticket No.");
            until (_TempSnapshotTickets.Next() = 0);
        _Assert.Fail(StrSubstNo(SnapshotTicketMissingErr, Position, LineReference));
    end;

    // The full stored result of the first change of a line, the result line at the given position of the response included:
    // a new systemId on CHANGE rows that supersede the unchanged former row, every ticket relinked to it with its validity
    // unchanged, and the admission moved for every ticket with a reversal on the old slot.
    procedure AssertLineMoved(Response: JsonObject; Position: Integer; LineReference: Integer; AdmissionCode: Code[20]; NewSlotNo: Integer; Context: Text) NewSystemId: Guid
    var
        FormerRow: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        OldInitialEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketContext: Text;
    begin
        GetSnapshotRow(LineReference, FormerRow);
        NewSystemId := AssertChangedLine(Response, Position, FormerRow.SystemId, FormerRow.Quantity, Context);
        AssertChangedAdmission(Response, Position, AdmissionCode, NewSlotNo, Context);
        AssertRowUnchanged(FormerRow, Context);

        _TempSnapshotTickets.Reset();
        _TempSnapshotTickets.SetFilter("Ticket Reservation Entry No.", '=%1', FormerRow."Entry No.");
        _TempSnapshotTickets.FindSet();
        TicketAccessEntry.SetFilter("Ticket No.", '=%1', _TempSnapshotTickets."No.");
        AssertChangeRows(NewSystemId, FormerRow, TicketAccessEntry.Count(), Context);
        repeat
            TicketContext := StrSubstNo(TicketRowContextTok, Context, _TempSnapshotTickets."External Ticket No.");
            AssertTicketOnRow(_TempSnapshotTickets."External Ticket No.", NewSystemId, Context);
            GetSnapshotEntry(_TempSnapshotTickets."No.", AdmissionCode, OldInitialEntry);
            AssertTicketMoved(_TempSnapshotTickets."External Ticket No.", AdmissionCode, OldInitialEntry, NewSlotNo, Context);
            Ticket.Get(_TempSnapshotTickets."No.");
            _Assert.AreEqual(_TempSnapshotTickets."Valid From Date", Ticket."Valid From Date", StrSubstNo(ValidityChangedErr, TicketContext, Ticket.FieldCaption("Valid From Date")));
            _Assert.AreEqual(_TempSnapshotTickets."Valid To Date", Ticket."Valid To Date", StrSubstNo(ValidityChangedErr, TicketContext, Ticket.FieldCaption("Valid To Date")));
        until (_TempSnapshotTickets.Next() = 0);
    end;

    // The line kept its row, nothing supersedes it, and its tickets still point at it and stand on the initial entries of the snapshot.
    procedure AssertLineUntouched(LineReference: Integer; Context: Text)
    var
        FormerRow: Record "NPR TM Ticket Reservation Req.";
        CurrentInitialEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketContext: Text;
    begin
        GetSnapshotRow(LineReference, FormerRow);
        AssertRowUnchanged(FormerRow, Context);
        AssertNotSuperseded(FormerRow, Context);
        _TempSnapshotTickets.Reset();
        _TempSnapshotTickets.SetFilter("Ticket Reservation Entry No.", '=%1', FormerRow."Entry No.");
        _TempSnapshotTickets.FindSet();
        repeat
            AssertTicketOnRow(_TempSnapshotTickets."External Ticket No.", FormerRow.SystemId, Context);
            _TempSnapshotEntries.Reset();
            _TempSnapshotEntries.SetFilter("Ticket No.", '=%1', _TempSnapshotTickets."No.");
            _TempSnapshotEntries.FindSet();
            repeat
                TicketContext := StrSubstNo(TicketRowContextTok, Context, _TempSnapshotTickets."External Ticket No.");
                CurrentInitialEntry.Reset();
                CurrentInitialEntry.SetFilter("Ticket Access Entry No.", '=%1', _TempSnapshotEntries."Ticket Access Entry No.");
                CurrentInitialEntry.SetFilter(Type, '=%1', CurrentInitialEntry.Type::INITIAL_ENTRY);
                CurrentInitialEntry.SetFilter(Quantity, '>%1', 0);
                if (not CurrentInitialEntry.FindLast()) then
                    Clear(CurrentInitialEntry);
                _Assert.AreEqual(_TempSnapshotEntries."Entry No.", CurrentInitialEntry."Entry No.", StrSubstNo(InitialEntryChangedErr, TicketContext, _TempSnapshotEntries."Entry No."));
            until (_TempSnapshotEntries.Next() = 0);
        until (_TempSnapshotTickets.Next() = 0);
    end;

    // Every ticket the line held at the snapshot stands on the slot for the admission.
    procedure AssertLineOnSlot(LineReference: Integer; AdmissionCode: Code[20]; ExpectedSlotNo: Integer; Context: Text)
    var
        FormerRow: Record "NPR TM Ticket Reservation Req.";
    begin
        GetSnapshotRow(LineReference, FormerRow);
        _TempSnapshotTickets.Reset();
        _TempSnapshotTickets.SetFilter("Ticket Reservation Entry No.", '=%1', FormerRow."Entry No.");
        _TempSnapshotTickets.FindSet();
        repeat
            AssertTicketOnSlot(_TempSnapshotTickets."External Ticket No.", AdmissionCode, ExpectedSlotNo, Context);
        until (_TempSnapshotTickets.Next() = 0);
    end;

    local procedure GetSnapshotEntry(InternalTicketNo: Code[20]; AdmissionCode: Code[20]; var DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry")
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
    begin
        GetAccessEntry(InternalTicketNo, AdmissionCode, TicketAccessEntry);
        _TempSnapshotEntries.Reset();
        _TempSnapshotEntries.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
        _Assert.IsTrue(_TempSnapshotEntries.FindFirst(), StrSubstNo(SnapshotEntryMissingErr, InternalTicketNo, AdmissionCode));
        DetTicketAccessEntry := _TempSnapshotEntries;
    end;

    // Remembers the newest request row, detailed access entry and notification entry, so a later check can prove nothing was stored.
    procedure MarkStoredState()
    begin
        _MarkedRequestEntryNo := LastRequestEntryNo();
        _MarkedAccessDetailEntryNo := LastAccessDetailEntryNo();
        _MarkedNotificationEntryNo := LastNotificationEntryNo();
    end;

    procedure AssertNothingStoredSinceMark(Context: Text)
    begin
        _Assert.AreEqual(_MarkedRequestEntryNo, LastRequestEntryNo(), StrSubstNo(RequestRowWrittenErr, Context));
        _Assert.AreEqual(_MarkedAccessDetailEntryNo, LastAccessDetailEntryNo(), StrSubstNo(AccessDetailWrittenErr, Context));
        _Assert.AreEqual(_MarkedNotificationEntryNo, LastNotificationEntryNo(), StrSubstNo(NotificationWrittenErr, Context));
    end;

    procedure AssertNoMutexLeft(Context: Text)
    begin
        _Assert.IsFalse(IsReservationMutexHeld(), StrSubstNo(MutexLeftErr, Context, _Token));
    end;

    procedure AssertETicketUpdateSent(TicketNumber: Text; Context: Text)
    var
        Ticket: Record "NPR TM Ticket";
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        GetTicket(TicketNumber, Ticket);
        NotificationEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        NotificationEntry.SetFilter("Notification Trigger", '=%1', NotificationEntry."Notification Trigger"::ETICKET_UPDATE);
        NotificationEntry.SetFilter("Notification Send Status", '=%1', NotificationEntry."Notification Send Status"::SENT);
        _Assert.IsFalse(NotificationEntry.IsEmpty(), StrSubstNo(ETicketUpdateNotSentErr, Context, TicketNumber));
    end;

    procedure LastNotificationEntryNo(): Integer
    var
        NotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin
        if (NotificationEntry.FindLast()) then
            exit(NotificationEntry."Entry No.");
    end;

    #endregion

    #region Response reading

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

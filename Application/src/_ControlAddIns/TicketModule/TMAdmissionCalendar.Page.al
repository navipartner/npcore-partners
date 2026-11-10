page 6150994 "NPR TM Admission Calendar"
{
    Extensible = false;
    Caption = 'Admission Calendar';
    PageType = Card;
    UsageCategory = Lists;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
    ContextSensitiveHelpPage = 'docs/entertainment/ticket/intro/';

    layout
    {
        area(content)
        {
            usercontrol(Calendar; "NPR TMAdmissionCalendar")
            {
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

                trigger OnControlReady()
                begin
                    _ControlReady := true;
                    SendContext();
                end;

                trigger OnRequestData(FromDate: Text; ToDate: Text)
                begin
                    SendCalendarData(FromDate, ToDate);
                end;

                trigger OnToggleSlotField(EntryNo: Integer; FieldName: Text; NewValue: Boolean)
                begin
                    ToggleSlotField(EntryNo, FieldName, NewValue);
                end;

                trigger OnSelectAdmission(AdmissionCode: Text)
                begin
                    SetAdmission(CopyStr(AdmissionCode, 1, MaxStrLen(_AdmissionCode)));
                end;
            }
        }
    }

    internal procedure SetAdmission(AdmissionCode: Code[20])
    begin
        _AdmissionCode := AdmissionCode;
        if (_ControlReady) then
            SendContext();
    end;

    local procedure SendContext()
    var
        Admission: Record "NPR TM Admission";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Json: Codeunit "NPR Json Builder";
        VenueNow: DateTime;
    begin
        if (not _ControlReady) then
            exit;

        // No admission selected is a valid state - the addin renders its own admission picker from
        // the list below, so there is no BC lookup dialog anywhere in the flow.
        if (not Admission.Get(_AdmissionCode)) then
            Admission.Init()
        else
            CurrPage.Caption(StrSubstNo(PageCaptionLbl, Admission."Admission Code"));

        // The calendar's "today" is the venue's clock, not the operator's - the slot times it frames
        // are venue wall clock.
        VenueNow := TimeHelper.GetLocalTimeAtAdmission(_AdmissionCode);

        Json.Initialize();
        Json.StartObject()
            .AddProperty('admissionCode', Admission."Admission Code")
            .AddProperty('admissionDescription', Admission.Description)
            .AddProperty('today', DT2Date(VenueNow))
            .AddProperty('nowTime', DT2Time(VenueNow));

        EmitAdmissionList(Json);

        Json.StartObject('captions')
            .AddProperty('day', DayLbl)
            .AddProperty('week', WeekLbl)
            .AddProperty('month', MonthLbl)
            .AddProperty('year', YearLbl)
            .AddProperty('today', TodayLbl)
            .AddProperty('refresh', RefreshLbl)
            .AddProperty('open', OpenLbl)
            .AddProperty('closed', ClosedLbl)
            .AddProperty('sold', SoldLbl)
            .AddProperty('admitted', AdmittedLbl)
            .AddProperty('departed', DepartedLbl)
            .AddProperty('maxCapacity', MaxCapacityLbl)
            .AddProperty('slots', SlotsLbl)
            .AddProperty('noSlots', NoSlotsLbl)
            .AddProperty('loading', LoadingLbl)
            .AddProperty('schedule', ScheduleLbl)
            .AddProperty('entryNo', EntryNoLbl)
            .AddProperty('externalEntryNo', ExternalEntryNoLbl)
            .AddProperty('duration', DurationLbl)
            .AddProperty('allocationBy', AllocationByLbl)
            .AddProperty('priceProfile', PriceProfileLbl)
            .AddProperty('waitingListQueue', WaitingListQueueLbl)
            .AddProperty('visibleOnWeb', VisibleOnWebLbl)
            .AddProperty('hiddenOnWeb', HiddenOnWebLbl)
            .AddProperty('noWeb', NoWebLbl)
            .AddProperty('arrivalWindow', ArrivalWindowLbl)
            .AddProperty('salesWindow', SalesWindowLbl)
            .AddProperty('capacity', CapacityLbl)
            .AddProperty('selectAdmission', SelectAdmissionLbl)
            .AddProperty('filterAdmissions', FilterAdmissionsLbl)
            .AddProperty('admission', AdmissionColLbl)
            .AddProperty('description', DescriptionColLbl)
            .AddProperty('type', TypeColLbl)
            .AddProperty('noAdmissions', NoAdmissionsLbl);
        Json.EndObject();

        Json.EndObject();
        CurrPage.Calendar.SetContext(Json.BuildAsText());
    end;

    local procedure EmitAdmissionList(var Json: Codeunit "NPR Json Builder")
    var
        Admission: Record "NPR TM Admission";
    begin
        Json.StartArray('admissions');
        if (Admission.FindSet()) then
            repeat
                Json.StartObject()
                    .AddProperty('code', Admission."Admission Code")
                    .AddProperty('description', Admission.Description)
                    .AddProperty('typeText', Format(Admission.Type));
                Json.EndObject();
            until (Admission.Next() = 0);
        Json.EndArray();
    end;

    local procedure SendCalendarData(FromDateText: Text; ToDateText: Text)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        Json: Codeunit "NPR Json Builder";
        VenueNow: DateTime;
        FromDate: Date;
        ToDate: Date;
        ScheduleControl: Dictionary of [Code[20], Integer];
        ScheduleBaseCapacity: Dictionary of [Code[20], Integer];
        AdmittedExcess: Dictionary of [Integer, Decimal];
        InsideExcess: Dictionary of [Integer, Decimal];
        Excess: Decimal;
        Admitted: Decimal;
        Inside: Decimal;
        EffectiveMaxCapacity: Integer;
        ResolvedControl: Integer;
        CapacityControl: Option;
        UnlimitedCapacity: Boolean;
        CapacityControlText: Text;
    begin
        if (_AdmissionCode = '') then
            exit;
        if (not Evaluate(FromDate, FromDateText, 9)) then
            exit;
        if (not Evaluate(ToDate, ToDateText, 9)) then
            exit;
        if ((FromDate > ToDate) or ((ToDate - FromDate) > 120)) then
            exit;
        if (not Admission.Get(_AdmissionCode)) then
            exit;

        // Every payload carries the venue clock, so the now-line and past-slot greying move with each refresh.
        VenueNow := TimeHelper.GetLocalTimeAtAdmission(_AdmissionCode);

        Json.Initialize();
        Json.StartObject()
            .AddProperty('fromDate', FromDate)
            .AddProperty('toDate', ToDate)
            .AddProperty('today', DT2Date(VenueNow))
            .AddProperty('nowTime', DT2Time(VenueNow));
        Json.StartArray('slots');

        // Every scan inserts its own admission row, so a ticket that re-enters is counted once per scan.
        // Admitted and departed are shown once per ticket per slot.
        CalcReEntryExcess(FromDate, ToDate, false, AdmittedExcess);
        CalcReEntryExcess(FromDate, ToDate, true, InsideExcess);

        // Sold is "Initial Entry (All)", which includes unpaid tickets (tour, Channel Manager, postpaid, pending web). That is the
        // number the sales capacity check counts against the max.
        ScheduleEntry.SetAutoCalcFields("Initial Entry (All)", "Open Admitted", Departed);
        ScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        ScheduleEntry.SetFilter("Admission Code", '=%1', _AdmissionCode);
        ScheduleEntry.SetFilter(Cancelled, '=%1', false);
        ScheduleEntry.SetFilter("Admission Start Date", '%1..%2', FromDate, ToDate);
        if (ScheduleEntry.FindSet()) then
            repeat
                // The entry's own Max Capacity field is only authoritative when Capacity Limits By is
                // OVERRIDE - resolve the effective control and max so the addin never renders an
                // unenforced number as a ceiling. Control and base max are a function of the schedule
                // alone, so resolve each schedule once per payload; only the OVERRIDE per-entry max
                // (already on the record in hand) is applied per row.
                if (not ScheduleControl.ContainsKey(ScheduleEntry."Schedule Code")) then begin
                    EffectiveMaxCapacity := 0;
                    CapacityControl := 0;
                    if (TicketManagement.GetAdmissionCapacity(ScheduleEntry."Admission Code", ScheduleEntry."Schedule Code", 0, EffectiveMaxCapacity, CapacityControl)) then
                        ScheduleControl.Add(ScheduleEntry."Schedule Code", CapacityControl)
                    else begin
                        ScheduleControl.Add(ScheduleEntry."Schedule Code", -1);
                        EffectiveMaxCapacity := 0;
                    end;
                    ScheduleBaseCapacity.Add(ScheduleEntry."Schedule Code", EffectiveMaxCapacity);
                end;

                ResolvedControl := ScheduleControl.Get(ScheduleEntry."Schedule Code");
                EffectiveMaxCapacity := ScheduleBaseCapacity.Get(ScheduleEntry."Schedule Code");
                UnlimitedCapacity := false;
                CapacityControlText := '';
                if (ResolvedControl >= 0) then begin
                    Admission."Capacity Control" := ResolvedControl;
                    UnlimitedCapacity := (Admission."Capacity Control" = Admission."Capacity Control"::NONE);
                    CapacityControlText := Format(Admission."Capacity Control");
                    if ((Admission."Capacity Limits By" = Admission."Capacity Limits By"::OVERRIDE) and (ScheduleEntry."Max Capacity Per Sch. Entry" <> 0) and
                        (Admission."Capacity Control" <> Admission."Capacity Control"::SEATING)) then
                        EffectiveMaxCapacity := ScheduleEntry."Max Capacity Per Sch. Entry";
                end else
                    EffectiveMaxCapacity := 0;

                Admitted := ScheduleEntry."Open Admitted" + ScheduleEntry.Departed;
                if (AdmittedExcess.Get(ScheduleEntry."External Schedule Entry No.", Excess)) then
                    Admitted -= Excess;
                Inside := ScheduleEntry."Open Admitted";
                if (InsideExcess.Get(ScheduleEntry."External Schedule Entry No.", Excess)) then
                    Inside -= Excess;
                // A ticket revoked after re-entering still counts as excess, but its revoked rows are no longer in the base.
                if (Admitted < Inside) then
                    Admitted := Inside;

                Json.StartObject()
                    .AddProperty('entryNo', ScheduleEntry."Entry No.")
                    .AddProperty('externalEntryNo', ScheduleEntry."External Schedule Entry No.")
                    .AddProperty('scheduleCode', ScheduleEntry."Schedule Code")
                    .AddProperty('startDate', ScheduleEntry."Admission Start Date")
                    .AddProperty('startTime', ScheduleEntry."Admission Start Time")
                    .AddProperty('endDate', ScheduleEntry."Admission End Date")
                    .AddProperty('endTime', ScheduleEntry."Admission End Time")
                    .AddProperty('durationText', Format(ScheduleEntry."Event Duration"))
                    .AddProperty('open', (ScheduleEntry."Admission Is" = ScheduleEntry."Admission Is"::OPEN))
                    .AddProperty('visibleOnWeb', (ScheduleEntry."Visibility On Web" = ScheduleEntry."Visibility On Web"::VISIBLE))
                    .AddProperty('initialEntryAll', ScheduleEntry."Initial Entry (All)")
                    .AddProperty('admitted', Admitted)
                    .AddProperty('departed', Admitted - Inside)
                    .AddProperty('maxCapacity', EffectiveMaxCapacity)
                    .AddProperty('unlimitedCapacity', UnlimitedCapacity)
                    .AddProperty('capacityControlText', CapacityControlText)
                    .AddProperty('allocationBy', Format(ScheduleEntry."Allocation By"))
                    .AddProperty('priceProfileCode', ScheduleEntry."Dynamic Price Profile Code")
                    .AddProperty('waitingListQueue', ScheduleEntry."Waiting List Queue")
                    .AddProperty('arrivalFromTime', ScheduleEntry."Event Arrival From Time")
                    .AddProperty('arrivalUntilTime', ScheduleEntry."Event Arrival Until Time")
                    .AddProperty('salesFromDate', ScheduleEntry."Sales From Date")
                    .AddProperty('salesFromTime', ScheduleEntry."Sales From Time")
                    .AddProperty('salesUntilDate', ScheduleEntry."Sales Until Date")
                    .AddProperty('salesUntilTime', ScheduleEntry."Sales Until Time");
                Json.EndObject();
            until (ScheduleEntry.Next() = 0);

        Json.EndArray();
        Json.EndObject();

        CurrPage.Calendar.SetCalendarData(Json.BuildAsText());
    end;

    local procedure CalcReEntryExcess(FromDate: Date; ToDate: Date; OpenOnly: Boolean; var ExcessBySlot: Dictionary of [Integer, Decimal])
    var
        ReEntries: Query "NPR TM Adm. Sch. Re-Entries";
        Excess: Decimal;
    begin
        ReEntries.SetFilter(AdmissionCode, '=%1', _AdmissionCode);
        ReEntries.SetFilter(Cancelled, '=%1', false);
        ReEntries.SetFilter(AdmissionStartDate, '%1..%2', FromDate, ToDate);
        if (OpenOnly) then
            ReEntries.SetFilter(OpenEntry, '=%1', true);
        ReEntries.Open();
        while (ReEntries.Read()) do begin
            // Each row carries the ticket's full quantity, so everything beyond one row is excess.
            Excess := ReEntries.QuantitySum - ReEntries.QuantityMax;
            if (ExcessBySlot.ContainsKey(ReEntries.ExternalScheduleEntryNo)) then
                Excess += ExcessBySlot.Get(ReEntries.ExternalScheduleEntryNo);
            ExcessBySlot.Set(ReEntries.ExternalScheduleEntryNo, Excess);
        end;
        ReEntries.Close();
    end;

    local procedure ToggleSlotField(EntryNo: Integer; FieldName: Text; NewValue: Boolean)
    var
        ScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (not ScheduleEntry.Get(EntryNo)) then
            exit;
        if (ScheduleEntry."Admission Code" <> _AdmissionCode) then
            exit;
        if (ScheduleEntry.Cancelled) then
            if (not FindLiveScheduleEntry(ScheduleEntry)) then begin
                SendCalendarData(Format(ScheduleEntry."Admission Start Date", 0, 9), Format(ScheduleEntry."Admission Start Date", 0, 9));
                Message(SlotCancelledMsg);
                exit;
            end;

        case FieldName of
            'open':
                if (NewValue) then
                    ScheduleEntry.Validate("Admission Is", ScheduleEntry."Admission Is"::OPEN)
                else
                    ScheduleEntry.Validate("Admission Is", ScheduleEntry."Admission Is"::CLOSED);
            'visibleOnWeb':
                if (NewValue) then
                    ScheduleEntry.Validate("Visibility On Web", ScheduleEntry."Visibility On Web"::VISIBLE)
                else
                    ScheduleEntry.Validate("Visibility On Web", ScheduleEntry."Visibility On Web"::HIDDEN);
            else
                exit;
        end;

        ScheduleEntry.Modify(true);

        // Refreshing the whole day keeps the addin on the single SetCalendarData path - the card,
        // the week block and the month aggregate all update from the same payload.
        SendCalendarData(Format(ScheduleEntry."Admission Start Date", 0, 9), Format(ScheduleEntry."Admission Start Date", 0, 9));
    end;

    // The scheduler replaces a changed slot with a new row that keeps the External Schedule Entry No.
    local procedure FindLiveScheduleEntry(var ScheduleEntry: Record "NPR TM Admis. Schedule Entry"): Boolean
    var
        LiveScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        LiveScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        LiveScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', ScheduleEntry."External Schedule Entry No.");
        LiveScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not LiveScheduleEntry.FindLast()) then
            exit(false);

        ScheduleEntry := LiveScheduleEntry;
        exit(true);
    end;

    var
        _AdmissionCode: Code[20];
        _ControlReady: Boolean;
        PageCaptionLbl: Label 'Admission Calendar - %1', Comment = '%1 = Admission Code';
        DayLbl: Label 'Day';
        WeekLbl: Label '7 days', Comment = 'View toggle for the rolling seven-day calendar view. It is deliberately not named Week because the window starts today, not Monday.';
        MonthLbl: Label 'Month';
        YearLbl: Label 'Year';
        TodayLbl: Label 'Today';
        RefreshLbl: Label 'Refresh';
        OpenLbl: Label 'Open';
        ClosedLbl: Label 'Closed';
        SoldLbl: Label 'Sold';
        AdmittedLbl: Label 'Admitted';
        DepartedLbl: Label 'Departed';
        MaxCapacityLbl: Label 'Max Capacity';
        SlotsLbl: Label 'slots';
        NoSlotsLbl: Label 'No time slots in this period.';
        LoadingLbl: Label 'Loading...';
        ScheduleLbl: Label 'Schedule';
        EntryNoLbl: Label 'Entry No.';
        ExternalEntryNoLbl: Label 'External Entry No.';
        DurationLbl: Label 'Duration';
        AllocationByLbl: Label 'Allocation By';
        PriceProfileLbl: Label 'Price Profile';
        WaitingListQueueLbl: Label 'Waiting List Queue';
        VisibleOnWebLbl: Label 'Visible on web';
        HiddenOnWebLbl: Label 'Hidden on web';
        NoWebLbl: Label 'No web', Comment = 'Very short badge inside a calendar block marking a time slot hidden from the web shop. Keep it compact.';
        ArrivalWindowLbl: Label 'Arrival Window';
        SalesWindowLbl: Label 'Sales Window';
        CapacityLbl: Label 'Capacity';
        SelectAdmissionLbl: Label 'Select admission';
        FilterAdmissionsLbl: Label 'Type to filter...';
        AdmissionColLbl: Label 'Admission';
        DescriptionColLbl: Label 'Description';
        TypeColLbl: Label 'Type';
        NoAdmissionsLbl: Label 'No admissions have been created yet. Set up an admission on the Ticket Admissions page to use the calendar.';
        SlotCancelledMsg: Label 'The time slot was cancelled by a schedule update. Your change was not saved.';
}

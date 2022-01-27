codeunit 6060118 "NPR TM Admission Sch. Mgt."
{
    Access = Internal;

    trigger OnRun()
    var
        Admission: Record "NPR TM Admission";
    begin

        if (Admission.FindSet()) then begin
            repeat
                Commit();
                CreateAdmissionSchedule(Admission."Admission Code", false, Today);
            until (Admission.Next() = 0);
        end;
    end;

    var
        APPEND_LIST_CONFIRM: Label 'There is already a list created for this schedule.\Do you want to append to it?';
        RECREATE_LIST_CONFIRM: Label 'Warning.\The list will be recreated and the current notification status will set to pending.';

    procedure CreateAdmissionSchedule(AdmissionCode: Code[20]; Regenerate: Boolean; ReferenceDate: Date)
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        DateRecord: Record Date;
        TempAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary;
        ScheduleStartDate: Date;
        ScheduleEndDate: Date;
        GenerateFromDate: Date;
        GenerateUntilDate: Date;
        AreEqual: Boolean;
    begin

        AdmissionScheduleLines.SetCurrentKey("Admission Code", "Process Order");
        AdmissionScheduleLines.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (AdmissionScheduleLines.FindSet()) then begin
            GenerateFromDate := Today();
            GenerateUntilDate := 0D;

            // find the low / high dates for all schedules for this admission
            repeat
                CalculateScheduleDateRange(AdmissionScheduleLines, ReferenceDate, 0D, Regenerate, ScheduleStartDate, ScheduleEndDate);
                if (GenerateFromDate > ScheduleStartDate) then
                    GenerateFromDate := ScheduleStartDate;

                if (GenerateUntilDate < ScheduleEndDate) then
                    GenerateUntilDate := ScheduleEndDate;
            until (AdmissionScheduleLines.Next() = 0);

            if (Regenerate) then begin
                AdmissionScheduleLines.FindSet();
                repeat
                    CancelTimeEntry(AdmissionScheduleLines."Admission Code", AdmissionScheduleLines."Schedule Code", GenerateFromDate, GenerateUntilDate);
                until (AdmissionScheduleLines.Next() = 0);
            end;

            if (not Regenerate) then begin
                if ((GenerateUntilDate > AdmissionScheduleLines."Schedule Generated Until") and
                    (AdmissionScheduleLines."Schedule Generated Until" > Today)) then
                    GenerateFromDate := AdmissionScheduleLines."Schedule Generated Until";
            end;
            //MESSAGE ('%1 from %2 until %3', AdmissionScheduleLines."Schedule Code", GenerateFromDate, GenerateUntilDate);

            // Start generating entries
            DateRecord.Reset();
            DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
            DateRecord.SetFilter("Period Start", '%1..%2', GenerateFromDate, GenerateUntilDate);
            if (DateRecord.FindSet()) then begin
                repeat
                    AdmissionScheduleLines.FindSet();
                    repeat
                        GenerateScheduleEntry(AdmissionScheduleLines, DateRecord."Period Start", TempAdmissionScheduleEntry);

                    until (AdmissionScheduleLines.Next() = 0);

                    if (not TempAdmissionScheduleEntry.IsEmpty) then begin
                        AreEqual := CompareScheduleEntries(AdmissionCode, DateRecord."Period Start", TempAdmissionScheduleEntry);
                        if (not AreEqual) then
                            StoreScheduleEntries(TempAdmissionScheduleEntry);
                    end;

                    TempAdmissionScheduleEntry.Reset();
                    if (TempAdmissionScheduleEntry.IsTemporary) then
                        TempAdmissionScheduleEntry.DeleteAll();

                until (DateRecord.Next() = 0);
            end;
        end;
    end;

    procedure IsUpdateScheduleEntryRequired(AdmissionCode: Code[20]; ReferenceDate: Date): Boolean
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        if (ReferenceDate = 0D) then
            ReferenceDate := Today();

        AdmissionScheduleLines.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleLines.SetFilter(Blocked, '=%1', false);
        AdmissionScheduleLines.SetFilter("Schedule Generated At", '<%1', ReferenceDate);
        exit(not AdmissionScheduleLines.IsEmpty());
    end;

    procedure GetRecurrenceEndDate(StartDate: Date; Occurences: Integer; RecurrencePattern: Option WEEKLY,DAILY) EndDate: Date
    var
        Pattern: Code[20];
        PatternLbl: Label '<+%1D>', Locked = true;
        Pattern2Lbl: Label '<CW+%1D>', Locked = true;
    begin

        if (Occurences = 0) then
            Occurences := 1;

        Pattern := StrSubstNo(PatternLbl, Occurences - 1);
        if (RecurrencePattern = RecurrencePattern::WEEKLY) then
            Pattern := StrSubstNo(Pattern2Lbl, 7 * (Occurences - 1));

        EndDate := CalcDate(Pattern, StartDate);

    end;

    local procedure GenerateScheduleEntry(AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines"; GenerateForDate: Date; var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary)
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        DateRecord: Record Date;
        DateRecordPeriod: Record Date;
        HighestEntryDate: Date;
        PeriodCount: Integer;
        CreateEntryThisPeriod: Boolean;
        ScheduleStartDate: Date;
        ScheduleEndDate: Date;
    begin

        // Revalidate that this general date is valid for this specific schedule
        if (AdmissionScheduleLines.Blocked) then
            exit;

        if (not CalculateScheduleDateRange(AdmissionScheduleLines, GenerateForDate, 0D, true, ScheduleStartDate, ScheduleEndDate)) then begin
            // This schedule has expired in some way
            if (AdmissionScheduleLines."Schedule Generated At" <> Today) then begin
                AdmissionScheduleLines."Schedule Generated At" := Today();
                AdmissionScheduleLines.Modify();
            end;
            exit;
        end;

        Admission.Get(AdmissionScheduleLines."Admission Code");
        Schedule.Get(AdmissionScheduleLines."Schedule Code");

        if (Schedule."Recur Every N On" = 0) then begin
            Schedule."Recur Every N On" := 1;
            Schedule.Modify();
        end;

        CreateEntryThisPeriod := true;

        if (Schedule."Recurrence Pattern" = Schedule."Recurrence Pattern"::WEEKLY) then begin
            DateRecordPeriod.SetFilter("Period Type", '=%1', DateRecordPeriod."Period Type"::Week);
            if (not CreateEntryThisPeriod) then
                HighestEntryDate := CalcDate('<CW-1W+1D>', HighestEntryDate); // align with periods first date
        end;

        if (Schedule."Recurrence Pattern" = Schedule."Recurrence Pattern"::DAILY) then
            DateRecordPeriod.SetFilter("Period Type", '=%1', DateRecordPeriod."Period Type"::Date);

        if ((not CreateEntryThisPeriod) and (HighestEntryDate < GenerateForDate)) then begin
            DateRecordPeriod.SetFilter("Period Start", '%1..%2', HighestEntryDate, GenerateForDate);
            PeriodCount := DateRecordPeriod.Count() - 1;
            CreateEntryThisPeriod := ((PeriodCount mod Schedule."Recur Every N On") = 0);
        end;

        if (CreateEntryThisPeriod) then begin

            DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
            DateRecord.SetFilter("Period Start", '=%1', GenerateForDate);
            DateRecord.FindFirst();

            case (DateRecord."Period No.") of
                1:
                    if (Schedule.Monday) then
                        AddTimeEntry(GenerateForDate, Admission, Schedule, TmpAdmissionScheduleEntry);
                2:
                    if (Schedule.Tuesday) then
                        AddTimeEntry(GenerateForDate, Admission, Schedule, TmpAdmissionScheduleEntry);
                3:
                    if (Schedule.Wednesday) then
                        AddTimeEntry(GenerateForDate, Admission, Schedule, TmpAdmissionScheduleEntry);
                4:
                    if (Schedule.Thursday) then
                        AddTimeEntry(GenerateForDate, Admission, Schedule, TmpAdmissionScheduleEntry);
                5:
                    if (Schedule.Friday) then
                        AddTimeEntry(GenerateForDate, Admission, Schedule, TmpAdmissionScheduleEntry);
                6:
                    if (Schedule.Saturday) then
                        AddTimeEntry(GenerateForDate, Admission, Schedule, TmpAdmissionScheduleEntry);
                7:
                    if (Schedule.Sunday) then
                        AddTimeEntry(GenerateForDate, Admission, Schedule, TmpAdmissionScheduleEntry);
            end;
        end;

        AdmissionScheduleLines."Schedule Generated Until" := DateRecord."Period Start";
        AdmissionScheduleLines."Schedule Generated At" := Today();
        AdmissionScheduleLines.Modify();
    end;

    local procedure CalculateScheduleDateRange(AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines"; ReferenceDate: Date; MaxEndDate: Date; IgnoreGenerationDate: Boolean; var GenerateFromDate: Date; var GenerateUntilDate: Date) RefDateIsInRange: Boolean
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        StartDate: Date;
        EndDate: Date;
    begin

        GenerateFromDate := DMY2Date(31, 12, 9999); //31129999D;
        GenerateUntilDate := 0D;

        if (AdmissionScheduleLines.Blocked) then
            exit(false);

        // nothing to do in soft mode
        if (not IgnoreGenerationDate) then
            if (AdmissionScheduleLines."Schedule Generated At" = Today) then
                exit(false);

        Admission.Get(AdmissionScheduleLines."Admission Code");
        Schedule.Get(AdmissionScheduleLines."Schedule Code");

        // setup start and enddate
        StartDate := ReferenceDate;
        if (Schedule."Start From" > StartDate) then
            StartDate := Schedule."Start From";

        if (Format(AdmissionScheduleLines."Prebook From") = '') then
            Evaluate(AdmissionScheduleLines."Prebook From", '<+0D>');

        EndDate := CalcDate(AdmissionScheduleLines."Prebook From", StartDate);

        if ((Schedule."Recurrence Until Pattern" = Schedule."Recurrence Until Pattern"::END_DATE) and
            (EndDate > Schedule."End After Date")) then
            EndDate := Schedule."End After Date";

        if (Schedule."Recurrence Until Pattern" = Schedule."Recurrence Until Pattern"::AFTER_X_OCCURENCES) then
            EndDate := GetRecurrenceEndDate(Schedule."Start From", Schedule."End After Occurrence Count", Schedule."Recurrence Pattern");

        if Schedule."Recurrence Pattern" = Schedule."Recurrence Pattern"::ONCE then begin
            StartDate := Schedule."Start From";
            EndDate := Schedule."Start From";
        end;

        // Are we allowed to create this period?
        if (CalcDate(AdmissionScheduleLines."Prebook From", ReferenceDate) < StartDate) then
            exit(false);

        if (EndDate > CalcDate(AdmissionScheduleLines."Prebook From", CalcDate('<CW>', ReferenceDate))) then
            EndDate := CalcDate(AdmissionScheduleLines."Prebook From", CalcDate('<CW>', ReferenceDate));

        if (MaxEndDate <> 0D) and (EndDate > MaxEndDate) then
            EndDate := MaxEndDate;

        GenerateFromDate := StartDate;
        GenerateUntilDate := EndDate;

        RefDateIsInRange := (ReferenceDate >= GenerateFromDate) and (ReferenceDate <= GenerateUntilDate);
    end;

    local procedure AddTimeEntry(StartFromDate: Date; Admission: Record "NPR TM Admission"; Schedule: Record "NPR TM Admis. Schedule"; var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary)
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        CalendarManagement: Codeunit "Calendar Management";
        TempCustomizedCalendarChange: Record "Customized Calendar Change" temporary;
        EndDateTime: DateTime;
        EntryNo: Integer;
        CalendarDesc: Text;
    begin

        // we are not creating historical entries
        if (StartFromDate < WorkDate()) then
            exit;

        AdmissionScheduleLines.Get(Admission."Admission Code", Schedule."Schedule Code");

        TmpAdmissionScheduleEntry.Reset();
        EntryNo := 1;

        // the new entry
        TmpAdmissionScheduleEntry.Reset();
        if (TmpAdmissionScheduleEntry.FindLast()) then
            EntryNo := TmpAdmissionScheduleEntry."Entry No.";

        EntryNo += 1;
        TmpAdmissionScheduleEntry.Init();
        TmpAdmissionScheduleEntry."Entry No." := EntryNo;
        TmpAdmissionScheduleEntry.Insert();

        TmpAdmissionScheduleEntry."Admission Code" := Admission."Admission Code";
        TmpAdmissionScheduleEntry."Schedule Code" := Schedule."Schedule Code";
        TmpAdmissionScheduleEntry."Admission Start Date" := StartFromDate;
        TmpAdmissionScheduleEntry."Admission Start Time" := Schedule."Start Time";

        TmpAdmissionScheduleEntry."Admission End Date" := StartFromDate;
        TmpAdmissionScheduleEntry."Admission End Time" := Schedule."Stop Time";
        if (Schedule."Event Duration" > 0) then begin
            EndDateTime := CreateDateTime(StartFromDate, Schedule."Start Time") + Schedule."Event Duration";
            TmpAdmissionScheduleEntry."Admission End Date" := DT2Date(EndDateTime);
            TmpAdmissionScheduleEntry."Admission End Time" := DT2Time(EndDateTime);
            TmpAdmissionScheduleEntry."Event Duration" := Schedule."Event Duration";
        end;

        // will be deprecated
        TmpAdmissionScheduleEntry."Unbookable Before Start (Secs)" := AdmissionScheduleLines."Unbookable Before Start (Secs)";
        TmpAdmissionScheduleEntry."Bookable Passed Start (Secs)" := AdmissionScheduleLines."Bookable Passed Start (Secs)";
        // new fields
        TmpAdmissionScheduleEntry."Event Arrival From Time" := AdmissionScheduleLines."Event Arrival From Time";
        TmpAdmissionScheduleEntry."Event Arrival Until Time" := AdmissionScheduleLines."Event Arrival Until Time";

        if (Format(AdmissionScheduleLines."Sales From Date (Rel.)") <> '') then
            TmpAdmissionScheduleEntry."Sales From Date" := CalcDate(AdmissionScheduleLines."Sales From Date (Rel.)", TmpAdmissionScheduleEntry."Admission Start Date");

        TmpAdmissionScheduleEntry."Sales From Time" := AdmissionScheduleLines."Sales From Time";
        if ((TmpAdmissionScheduleEntry."Sales From Time" <> 0T) and (TmpAdmissionScheduleEntry."Sales From Date" = 0D)) then
            TmpAdmissionScheduleEntry."Sales From Date" := TmpAdmissionScheduleEntry."Admission Start Date";

        if (Format(AdmissionScheduleLines."Sales Until Date (Rel.)") <> '') then
            TmpAdmissionScheduleEntry."Sales Until Date" := CalcDate(AdmissionScheduleLines."Sales Until Date (Rel.)", TmpAdmissionScheduleEntry."Admission End Date");

        TmpAdmissionScheduleEntry."Sales Until Time" := AdmissionScheduleLines."Sales Until Time";
        if ((TmpAdmissionScheduleEntry."Sales Until Time" <> 0T) and (TmpAdmissionScheduleEntry."Sales Until Date" = 0D)) then
            TmpAdmissionScheduleEntry."Sales Until Date" := TmpAdmissionScheduleEntry."Admission End Date";

        if ((TmpAdmissionScheduleEntry."Sales Until Time" = 0T) and (TmpAdmissionScheduleEntry."Sales Until Date" = TmpAdmissionScheduleEntry."Admission End Date")) then
            TmpAdmissionScheduleEntry."Sales Until Time" := TmpAdmissionScheduleEntry."Admission End Time";

        if ((TmpAdmissionScheduleEntry."Sales From Date" = TmpAdmissionScheduleEntry."Admission Start Date") and (TmpAdmissionScheduleEntry."Sales From Time" > TmpAdmissionScheduleEntry."Admission End Time")) then
            TmpAdmissionScheduleEntry."Sales From Time" := TmpAdmissionScheduleEntry."Admission Start Time";


        TmpAdmissionScheduleEntry."Max Capacity Per Sch. Entry" := AdmissionScheduleLines."Max Capacity Per Sch. Entry";

        TmpAdmissionScheduleEntry."Admission Is" := Schedule."Admission Is";

        TmpAdmissionScheduleEntry."Visibility On Web" := AdmissionScheduleLines."Visibility On Web";

        if ((Admission."Admission Base Calendar Code" <> '') and (TmpAdmissionScheduleEntry."Admission Is" = TmpAdmissionScheduleEntry."Admission Is"::OPEN)) then begin
            TempCustomizedCalendarChange.Init();
            TempCustomizedCalendarChange."Source Type" := TempCustomizedCalendarChange."Source Type"::Location;
            TempCustomizedCalendarChange."Base Calendar Code" := Admission."Admission Base Calendar Code";
            TempCustomizedCalendarChange."Date" := StartFromDate;
            TempCustomizedCalendarChange.Description := CopyStr(CalendarDesc, 1, MaxStrLen(TempCustomizedCalendarChange.Description));
            TempCustomizedCalendarChange."Source Code" := TmpAdmissionScheduleEntry."Admission Code";
            TempCustomizedCalendarChange.Insert();

            CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
            if (TempCustomizedCalendarChange.Nonworking) then
                TmpAdmissionScheduleEntry."Admission Is" := Schedule."Admission Is"::CLOSED;
        end;

        if ((Schedule."Admission Base Calendar Code" <> '') and (TmpAdmissionScheduleEntry."Admission Is" = TmpAdmissionScheduleEntry."Admission Is"::OPEN)) then begin
            TempCustomizedCalendarChange.DeleteAll();
            TempCustomizedCalendarChange.Init();
            TempCustomizedCalendarChange."Source Type" := TempCustomizedCalendarChange."Source Type"::Location;
            TempCustomizedCalendarChange."Base Calendar Code" := Admission."Admission Base Calendar Code";
            TempCustomizedCalendarChange."Date" := StartFromDate;
            TempCustomizedCalendarChange.Description := CopyStr(CalendarDesc, 1, MaxStrLen(TempCustomizedCalendarChange.Description));
            TempCustomizedCalendarChange."Additional Source Code" := TmpAdmissionScheduleEntry."Schedule Code";
            TempCustomizedCalendarChange.Insert();

            CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
            if (TempCustomizedCalendarChange.Nonworking) then
                TmpAdmissionScheduleEntry."Admission Is" := Schedule."Admission Is"::CLOSED;
        end;

        if ((AdmissionScheduleLines."Admission Base Calendar Code" <> '') and (TmpAdmissionScheduleEntry."Admission Is" = TmpAdmissionScheduleEntry."Admission Is"::OPEN)) then begin
            TempCustomizedCalendarChange.DeleteAll();
            TempCustomizedCalendarChange.Init();
            TempCustomizedCalendarChange."Source Type" := TempCustomizedCalendarChange."Source Type"::Location;
            TempCustomizedCalendarChange."Base Calendar Code" := Admission."Admission Base Calendar Code";
            TempCustomizedCalendarChange."Date" := StartFromDate;
            TempCustomizedCalendarChange.Description := CopyStr(CalendarDesc, 1, MaxStrLen(TempCustomizedCalendarChange.Description));
            TempCustomizedCalendarChange."Source Code" := TmpAdmissionScheduleEntry."Admission Code";
            TempCustomizedCalendarChange."Additional Source Code" := TmpAdmissionScheduleEntry."Schedule Code";
            TempCustomizedCalendarChange.Insert();

            CalendarManagement.CheckDateStatus(TempCustomizedCalendarChange);
            if (TempCustomizedCalendarChange.Nonworking) then
                TmpAdmissionScheduleEntry."Admission Is" := Schedule."Admission Is"::CLOSED;
        end;

        TmpAdmissionScheduleEntry.Cancelled := false;
        TmpAdmissionScheduleEntry."Reason Code" := 'NTE'; // New Time Entry

        TmpAdmissionScheduleEntry.Modify();
    end;

    local procedure CompareScheduleEntries(AdmissionCode: Code[20]; ReferenceDate: Date; var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        UniqKey: Text;
    begin

        // is there a manual override?
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
        AdmissionScheduleEntry.SetFilter("Regenerate With", '=%1', AdmissionScheduleEntry."Regenerate With"::MANUAL);
        AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', TmpAdmissionScheduleEntry."Schedule Code");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (not AdmissionScheduleEntry.IsEmpty()) then
            exit(true); // Ignore this line by saying a idenical line exist.

        AdmissionScheduleEntry.Reset();

        if (TmpAdmissionScheduleEntry.IsEmpty()) then begin
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
            if (AdmissionScheduleEntry.IsEmpty()) then
                exit(true);

            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false); // Entries with cancelled FALSE must me cancelled
            exit(not AdmissionScheduleEntry.IsEmpty());
        end;

        if (TmpAdmissionScheduleEntry.Count() = 1) then begin
            TmpAdmissionScheduleEntry.FindFirst();

            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
            AdmissionScheduleEntry.SetFilter("Admission Start Time", '=%1', TmpAdmissionScheduleEntry."Admission Start Time");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmissionScheduleEntry.Count() <> 1) then
                exit(false);

            AdmissionScheduleEntry.FindFirst();
            exit(IsIdentical(TmpAdmissionScheduleEntry, AdmissionScheduleEntry));
        end;

        // multiple schedules group them per start time
        // TODO add a horizontal group code
        TmpAdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
        TmpAdmissionScheduleEntry.FindSet();
        UniqKey := '';
        repeat

            if (UniqKey = '') then
                if (not CheckExists(TmpAdmissionScheduleEntry)) then
                    exit(false);

            if (UniqKey <> '') and (UniqKey <> GetIdentifyingString(TmpAdmissionScheduleEntry)) then
                if (not CheckExists(TmpAdmissionScheduleEntry)) then
                    exit(false);

            UniqKey := GetIdentifyingString(TmpAdmissionScheduleEntry);

        until (TmpAdmissionScheduleEntry.Next() = 0);

        exit(CheckExists(TmpAdmissionScheduleEntry));
    end;

    local procedure StoreScheduleEntries(var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        PreviousAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        UniqKey: Text;
    begin

        TmpAdmissionScheduleEntry.FindSet();

        UniqKey := '';
        repeat
            if (UniqKey <> '') and (UniqKey <> GetIdentifyingString(TmpAdmissionScheduleEntry)) then begin
                PreviousAdmissionScheduleEntry."External Schedule Entry No." := CancelExisting(PreviousAdmissionScheduleEntry);
                Clear(AdmissionScheduleEntry);
                AdmissionScheduleEntry.TransferFields(PreviousAdmissionScheduleEntry, false);
                AdmissionScheduleEntry."Entry No." := 0;
                AdmissionScheduleEntry.Insert();
                if (AdmissionScheduleEntry."External Schedule Entry No." = 0) then begin
                    AdmissionScheduleEntry."External Schedule Entry No." := AdmissionScheduleEntry."Entry No.";
                    AdmissionScheduleEntry.Modify();
                end;
            end;

            UniqKey := GetIdentifyingString(TmpAdmissionScheduleEntry);
            PreviousAdmissionScheduleEntry.Copy(TmpAdmissionScheduleEntry);

        until (TmpAdmissionScheduleEntry.Next() = 0);

        TmpAdmissionScheduleEntry."External Schedule Entry No." := CancelExisting(TmpAdmissionScheduleEntry);
        Clear(AdmissionScheduleEntry);
        AdmissionScheduleEntry.TransferFields(TmpAdmissionScheduleEntry, false);
        AdmissionScheduleEntry."Entry No." := 0;
        AdmissionScheduleEntry.Insert();

        if (AdmissionScheduleEntry."External Schedule Entry No." = 0) then begin
            AdmissionScheduleEntry."External Schedule Entry No." := AdmissionScheduleEntry."Entry No.";
            AdmissionScheduleEntry.Modify();
        end;
    end;

    local procedure GetIdentifyingString(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"): Text
    var
        AdmissionScheduleEntryLbl: Label '%1;%2;%3', Locked = true;
    begin
        exit(
          StrSubstNo(AdmissionScheduleEntryLbl,
            AdmissionScheduleEntry."Admission Code",
            AdmissionScheduleEntry."Admission Start Date",
            AdmissionScheduleEntry."Admission Start Time")
          );
    end;

    local procedure CheckExists(TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TmpAdmissionScheduleEntry."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', TmpAdmissionScheduleEntry."Admission Start Date");
        AdmissionScheduleEntry.SetFilter("Admission Start Time", '=%1', TmpAdmissionScheduleEntry."Admission Start Time");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionScheduleEntry.FindSet()) then
            exit(false);

        if (AdmissionScheduleEntry.Next() <> 0) then
            exit(false);

        exit(AdmissionScheduleEntry."Admission Is" = TmpAdmissionScheduleEntry."Admission Is");
    end;

    local procedure CancelExisting(TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary) ExternalEntryNo: Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TmpAdmissionScheduleEntry."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', TmpAdmissionScheduleEntry."Admission Start Date");
        AdmissionScheduleEntry.SetFilter("Admission Start Time", '=%1', TmpAdmissionScheduleEntry."Admission Start Time");

        if (AdmissionScheduleEntry.FindFirst()) then begin
            ExternalEntryNo := AdmissionScheduleEntry."External Schedule Entry No.";

            AdmissionScheduleEntry.ModifyAll(Cancelled, true);
            AdmissionScheduleEntry.ModifyAll("Reason Code", 'CTE04');

        end;
    end;

    local procedure CancelTimeEntry(AdmissionCode: Code[20]; ScheduleCode: Code[20]; FromDate: Date; ToDate: Date)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '%1..%2', FromDate, ToDate);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        AdmissionScheduleEntry.ModifyAll("Reason Code", 'CTE01');
        AdmissionScheduleEntry.ModifyAll(Cancelled, true);

        AdmissionScheduleEntry.SetFilter("Admission Start Date", '>%1', ToDate);
        AdmissionScheduleEntry.ModifyALL("Reason Code", 'CTE01B');
        AdmissionScheduleEntry.ModifyALL(Cancelled, TRUE);
    end;

    local procedure IsIdentical(AdmissionScheduleEntry1: Record "NPR TM Admis. Schedule Entry"; AdmissionScheduleEntry2: Record "NPR TM Admis. Schedule Entry"): Boolean
    begin

        if (AdmissionScheduleEntry1."Admission Start Date" <> AdmissionScheduleEntry2."Admission Start Date") then exit(false);
        if (AdmissionScheduleEntry1."Admission Start Time" <> AdmissionScheduleEntry2."Admission Start Time") then exit(false);
        if (AdmissionScheduleEntry1."Event Duration" <> AdmissionScheduleEntry2."Event Duration") then exit(false);
        if (AdmissionScheduleEntry1.Cancelled <> AdmissionScheduleEntry2.Cancelled) then exit(false);

        exit(true);
    end;

    procedure CreateNotificationList(ScheduleEntryNo: Integer)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        OriginalScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        RescheduleToScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        Ticket: Record "NPR TM Ticket";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketParticipantWks: Record "NPR TM Ticket Particpt. Wks.";
        TempTicketParticipantWks: Record "NPR TM Ticket Particpt. Wks." temporary;
        TempTicketParticipantWks2: Record "NPR TM Ticket Particpt. Wks." temporary;
        Admission: Record "NPR TM Admission";
        PendingCount: Integer;
        EntryCount: Integer;
        DuplicateNotificationAddress: Boolean;
    begin

        AdmissionScheduleEntry.Get(ScheduleEntryNo);

        OriginalScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        OriginalScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
        OriginalScheduleEntry.FindFirst();

        RescheduleToScheduleEntry.SetCurrentKey("External Schedule Entry No.");
        RescheduleToScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
        RescheduleToScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (not RescheduleToScheduleEntry.FindLast()) then
            RescheduleToScheduleEntry.Copy(OriginalScheduleEntry);

        DetTicketAccessEntry.SetCurrentKey("External Adm. Sch. Entry No.", "Entry No.");
        DetTicketAccessEntry.SetFilter("External Adm. Sch. Entry No.", '=%1', AdmissionScheduleEntry."External Schedule Entry No.");
        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
        if (not DetTicketAccessEntry.FindSet()) then
            exit;

        TicketParticipantWks.SetCurrentKey("Applies To Schedule Entry No.");
        TicketParticipantWks.SetFilter("Applies To Schedule Entry No.", '=%1', ScheduleEntryNo);
        PendingCount := TicketParticipantWks.Count();
        if (PendingCount > 0) then begin
            if (not (Confirm(APPEND_LIST_CONFIRM, true))) then begin
                if not (Confirm(RECREATE_LIST_CONFIRM, false)) then begin
                    Error('');
                end else begin
                    TicketParticipantWks.DeleteAll();
                end;
            end else begin
                TicketParticipantWks.FindLast();
                DetTicketAccessEntry.SetFilter("Entry No.", '>%1', TicketParticipantWks."Det. Ticket Access Entry No.");
                if (not DetTicketAccessEntry.FindSet()) then
                    exit;
            end;
        end;

        TicketParticipantWks.Reset();

        repeat

            TicketAccessEntry.Get(DetTicketAccessEntry."Ticket Access Entry No.");
            Ticket.Get(DetTicketAccessEntry."Ticket No.");
            Admission.Get(TicketAccessEntry."Admission Code");

            if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
                Clear(TicketReservationRequest);

            TempTicketParticipantWks.Init();
            EntryCount += 1;
            TempTicketParticipantWks."Entry No." := EntryCount;
            TempTicketParticipantWks."Applies To Schedule Entry No." := ScheduleEntryNo;
            TempTicketParticipantWks."Notification Send Status" := TempTicketParticipantWks."Notification Send Status"::PENDING;

            TempTicketParticipantWks."Ticket No." := DetTicketAccessEntry."Ticket No.";
            TempTicketParticipantWks."Admission Code" := TicketAccessEntry."Admission Code";
            TempTicketParticipantWks."Admission Description" := Admission.Description;

            TempTicketParticipantWks."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";

            /// the source is the last schedule entry and its not canceled - reminder
            // Default is reminder
            TempTicketParticipantWks."Notification Type" := TempTicketParticipantWks."Notification Type"::REMINDER;

            // multiple entires, first is canceled, last is not - reschedule
            if (not RescheduleToScheduleEntry.Cancelled) and (OriginalScheduleEntry.Cancelled) then
                TempTicketParticipantWks."Notification Type" := TempTicketParticipantWks."Notification Type"::RESCHEDULE;

            // the source is the last schedule entry and its canceled - cancellation
            if (RescheduleToScheduleEntry.Cancelled) and (ScheduleEntryNo = RescheduleToScheduleEntry."Entry No.") then
                TempTicketParticipantWks."Notification Type" := TempTicketParticipantWks."Notification Type"::CANCELATION;

            TempTicketParticipantWks."Original Schedule Entry No." := OriginalScheduleEntry."Entry No.";
            TempTicketParticipantWks."Original Start Date" := OriginalScheduleEntry."Admission Start Date";
            TempTicketParticipantWks."Original Start Time" := OriginalScheduleEntry."Admission Start Time";
            TempTicketParticipantWks."Original End Date" := OriginalScheduleEntry."Admission End Date";
            TempTicketParticipantWks."Original End Time" := OriginalScheduleEntry."Admission End Time";

            TempTicketParticipantWks."New Schedule Entry No." := RescheduleToScheduleEntry."Entry No.";
            TempTicketParticipantWks."New Start Date" := RescheduleToScheduleEntry."Admission Start Date";
            TempTicketParticipantWks."New Start Time" := RescheduleToScheduleEntry."Admission Start Time";
            TempTicketParticipantWks."New End Date" := RescheduleToScheduleEntry."Admission End Date";
            TempTicketParticipantWks."New End Time" := RescheduleToScheduleEntry."Admission End Time";

            TempTicketParticipantWks."Notification Method" := TicketReservationRequest."Notification Method";
            TempTicketParticipantWks."Notification Address" := TicketReservationRequest."Notification Address";

            TempTicketParticipantWks."Notifcation Created At" := CurrentDateTime();

            if (TicketAccessEntry.Status = TicketAccessEntry.Status::ACCESS) then
                TempTicketParticipantWks.Insert();

        until (DetTicketAccessEntry.Next() = 0);

        /// Mark duplicate notification address as duplicate
        TempTicketParticipantWks.Reset();
        TempTicketParticipantWks.FindSet();
        repeat
            TempTicketParticipantWks2.SetFilter("Notification Address", '=%1', TempTicketParticipantWks."Notification Address");
            DuplicateNotificationAddress := TempTicketParticipantWks2.FindFirst();

            TempTicketParticipantWks2.TransferFields(TempTicketParticipantWks, true);
            if (DuplicateNotificationAddress) then
                TempTicketParticipantWks2."Notification Send Status" := TempTicketParticipantWks2."Notification Send Status"::DUPLICATE;

            TempTicketParticipantWks2.Insert();
        until (TempTicketParticipantWks.Next() = 0);

        TempTicketParticipantWks2.Reset();
        TempTicketParticipantWks2.FindSet();
        repeat
            TicketParticipantWks.TransferFields(TempTicketParticipantWks2);
            TicketParticipantWks."Entry No." := 0;
            TicketParticipantWks.Insert();
        until (TempTicketParticipantWks2.Next() = 0);
    end;
}


codeunit 6060118 "NPR TM Admission Sch. Mgt."
{
    // NPR4.16/TSA/20151026 CASE 219658 Initial Version
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.11/TSA/20160325  CASE 237486 Added hard enddate endtime
    // TM1.11/BR/20160331   CASE 237850 Changed recurrance calculation, added support for ONCE
    // TM1.11/TSA/20160404  CASE 232250 Populate new field 47 and 48
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.16/TSA/20160714  CASE 245004 Added function to create the notification list
    // TM1.17/TSA/20160916  CASE 245004 Added admission description to worksheet entry
    // TM1.17/TSA/20161025  CASE 256205 Changed the isIdentical to not include bookable before/after to make it overrideable
    // TM1.19/TSA/20170213  CASE 265771 Refactored
    // TM1.21/TSA/20170505  CASE 271405 Schedule Entries can now own its open/close status will be lost on force generate from RTC page
    // TM1.21/TSA/20170504  CASE 274828 Added some robustness to handle data integrity failure
    // TM1.21/TSA/20170515  CASE 267611 Added a new date field "Schedule Generated At" determin when the schedule line was last examined for an entry
    // TM1.21/TSA/20170515  CASE 267611 New function IsUpdateScheduleEntryRequired ()
    // TM1.23/TSA/20170623  CASE 280612 Ignore lines with "Regenerate With" Manual
    // TM1.25/TSA /20170824 CASE 288396 Added a conditional modify, added a filter on Cancel
    // TM1.28/TSA /20180131 CASE 303925 Added Base Calendar from Admission to manage non-working (closed) days
    // TM1.28/TSA /20180221 CASE 306039 Added "Visibility On Web" field
    // #308299/TSA /20180315 CASE 308299 I18 hardcoded date
    // TM1.37/TSA /20180905 CASE 327324 Added fields for better control of arrival window
    // TM1.45/TSA /20191120 CASE 378212 Added the sales cut-off date
    // TM1.47/TSA /20200508 CASE 403559 Added possibility to schedule the schedule creation by task queue


    trigger OnRun()
    var
        Admission: Record "NPR TM Admission";
    begin

        //-TM1.47 [403559]
        if (Admission.FindSet()) then begin
            repeat
                Commit;
                CreateAdmissionSchedule(Admission."Admission Code", false, Today);
            until (Admission.Next() = 0);
        end;
        //+TM1.47 [403559]
    end;

    var
        APPEND_LIST_CONFIRM: Label 'There is already a list created for this schedule.\Do you want to append to it?';
        RECREATE_LIST_CONFIRM: Label 'Warning.\The list will be recreated and the current notification status will set to pending.';

    procedure CreateAdmissionSchedule(AdmissionCode: Code[20]; Regenerate: Boolean; ReferenceDate: Date)
    var
        Admission: Record "NPR TM Admission";
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        DateRecord: Record Date;
        TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary;
        ScheduleStartDate: Date;
        ScheduleEndDate: Date;
        GenerateFromDate: Date;
        GenerateUntilDate: Date;
        AreEqual: Boolean;
    begin

        AdmissionScheduleLines.SetCurrentKey("Admission Code", "Process Order");
        AdmissionScheduleLines.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (AdmissionScheduleLines.FindSet()) then begin
            GenerateFromDate := Today;
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

            //-TM1.21 [267611]
            if (not Regenerate) then begin
                if ((GenerateUntilDate > AdmissionScheduleLines."Schedule Generated Until") and
                    (AdmissionScheduleLines."Schedule Generated Until" > Today)) then
                    GenerateFromDate := AdmissionScheduleLines."Schedule Generated Until";
            end;
            //MESSAGE ('%1 from %2 until %3', AdmissionScheduleLines."Schedule Code", GenerateFromDate, GenerateUntilDate);
            //+TM1.21 [267611]

            // Start generating entries
            DateRecord.Reset();
            DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
            DateRecord.SetFilter("Period Start", '%1..%2', GenerateFromDate, GenerateUntilDate);
            if (DateRecord.FindSet()) then begin
                repeat
                    AdmissionScheduleLines.FindSet();
                    repeat
                        GenerateScheduleEntry(AdmissionScheduleLines, Regenerate, DateRecord."Period Start", TmpAdmissionScheduleEntry);

                    until (AdmissionScheduleLines.Next() = 0);

                    if (not TmpAdmissionScheduleEntry.IsEmpty) then begin
                        AreEqual := CompareScheduleEntries(AdmissionCode, DateRecord."Period Start", TmpAdmissionScheduleEntry);
                        if (not AreEqual) then
                            StoreScheduleEntries(AdmissionScheduleLines."Admission Code", DateRecord."Period Start", TmpAdmissionScheduleEntry);
                    end;

                    TmpAdmissionScheduleEntry.Reset;
                    if (TmpAdmissionScheduleEntry.IsTemporary) then
                        TmpAdmissionScheduleEntry.DeleteAll;

                until (DateRecord.Next() = 0);
            end;
        end;
    end;

    procedure IsUpdateScheduleEntryRequired(AdmissionCode: Code[20]; ReferenceDate: Date): Boolean
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        //-TM1.21
        if (ReferenceDate = 0D) then
            ReferenceDate := Today;

        AdmissionScheduleLines.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleLines.SetFilter(Blocked, '=%1', false);
        AdmissionScheduleLines.SetFilter("Schedule Generated At", '<%1', ReferenceDate);
        exit(not AdmissionScheduleLines.IsEmpty());
        //+TM1.21
    end;

    procedure GetRecurrenceEndDate(StartDate: Date; Occurences: Integer; RecurrencePattern: Option WEEKLY,DAILY) EndDate: Date
    var
        Pattern: Code[20];
    begin
        //-TM1.11
        if (Occurences = 0) then
            Occurences := 1;

        Pattern := StrSubstNo('<+%1D>', Occurences - 1);
        if (RecurrencePattern = RecurrencePattern::WEEKLY) then
            Pattern := StrSubstNo('<CW+%1D>', 7 * (Occurences - 1));

        EndDate := CalcDate(Pattern, StartDate);
        //+TM1.11
    end;

    local procedure GenerateScheduleEntry(AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines"; Regenerate: Boolean; GenerateForDate: Date; var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary)
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
            //-TM1.25 [288396]
            // AdmissionScheduleLines."Schedule Generated At" := TODAY;
            // AdmissionScheduleLines.MODIFY ();
            if (AdmissionScheduleLines."Schedule Generated At" <> Today) then begin
                AdmissionScheduleLines."Schedule Generated At" := Today;
                AdmissionScheduleLines.Modify();
            end;
            //+TM1.25 [288396]

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
        AdmissionScheduleLines."Schedule Generated At" := Today;
        AdmissionScheduleLines.Modify();
    end;

    local procedure CalculateScheduleDateRange(AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines"; ReferenceDate: Date; MaxEndDate: Date; IgnoreGenerationDate: Boolean; var GenerateFromDate: Date; var GenerateUntilDate: Date) RefDateIsInRange: Boolean
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
        DateRecord: Record Date;
        DateRecordPeriod: Record Date;
        StartDate: Date;
        EndDate: Date;
        HighestEntryDate: Date;
        PeriodCount: Integer;
        CreateEntryThisPeriod: Boolean;
        ScheduleForDate: Date;
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

        //AdmissionScheduleLines."Schedule Generated Until"

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

    local procedure DeterminePeriod()
    begin
    end;

    local procedure AddTimeEntry(StartFromDate: Date; Admission: Record "NPR TM Admission"; Schedule: Record "NPR TM Admis. Schedule"; var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary)
    var
        ExistingAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        NewAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        DuplicateAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        CalendarManagement: Codeunit "Calendar Management";
        CustomizedCalendarChangeTemp: Record "Customized Calendar Change" temporary;
        ExternalEntryNo: Integer;
        HaveExisting: Boolean;
        EndDateTime: DateTime;
        EntryModified: Boolean;
        EntryCreated: Boolean;
        IsEqual: Boolean;
        EntryNo: Integer;
        CalendarDesc: Text;
        NonWorking: Boolean;
    begin

        // we are not creating historical entries
        if (StartFromDate < WorkDate) then
            exit;

        AdmissionScheduleLines.Get(Admission."Admission Code", Schedule."Schedule Code");

        TmpAdmissionScheduleEntry.Reset();
        EntryNo := 1;

        // the new entry
        with TmpAdmissionScheduleEntry do begin

            Reset();
            if (FindLast()) then
                EntryNo := "Entry No.";

            EntryNo += 1;
            Init();
            "Entry No." := EntryNo;
            Insert();

            "Admission Code" := Admission."Admission Code";
            "Schedule Code" := Schedule."Schedule Code";
            "Admission Start Date" := StartFromDate;
            "Admission Start Time" := Schedule."Start Time";

            "Admission End Date" := StartFromDate;
            "Admission End Time" := Schedule."Stop Time";
            if (Schedule."Event Duration" > 0) then begin
                EndDateTime := CreateDateTime(StartFromDate, Schedule."Start Time") + Schedule."Event Duration";
                "Admission End Date" := DT2Date(EndDateTime);
                "Admission End Time" := DT2Time(EndDateTime);
                "Event Duration" := Schedule."Event Duration";
            end;

            //-TM1.37 [327324]
            // will be deprecated
            "Unbookable Before Start (Secs)" := AdmissionScheduleLines."Unbookable Before Start (Secs)";
            "Bookable Passed Start (Secs)" := AdmissionScheduleLines."Bookable Passed Start (Secs)";
            // new fields
            "Event Arrival From Time" := AdmissionScheduleLines."Event Arrival From Time";
            "Event Arrival Until Time" := AdmissionScheduleLines."Event Arrival Until Time";
            //+TM1.37 [327324]

            //-TM1.45 [378212]
            if (Format(AdmissionScheduleLines."Sales From Date (Rel.)") <> '') then
                "Sales From Date" := CalcDate(AdmissionScheduleLines."Sales From Date (Rel.)", "Admission Start Date");

            "Sales From Time" := AdmissionScheduleLines."Sales From Time";
            if (("Sales From Time" <> 0T) and ("Sales From Date" = 0D)) then
                "Sales From Date" := "Admission Start Date";

            if (Format(AdmissionScheduleLines."Sales Until Date (Rel.)") <> '') then
                "Sales Until Date" := CalcDate(AdmissionScheduleLines."Sales Until Date (Rel.)", "Admission End Date");

            "Sales Until Time" := AdmissionScheduleLines."Sales Until Time";
            if (("Sales Until Time" <> 0T) and ("Sales Until Date" = 0D)) then
                "Sales Until Date" := "Admission End Date";

            if (("Sales Until Time" = 0T) and ("Sales Until Date" = "Admission End Date")) then
                "Sales Until Time" := "Admission End Time";

            if (("Sales From Date" = "Admission Start Date") and ("Sales From Time" > "Admission End Time")) then
                "Sales From Time" := "Admission Start Time";

            //+TM1.45 [378212]

            "Max Capacity Per Sch. Entry" := AdmissionScheduleLines."Max Capacity Per Sch. Entry";

            "Admission Is" := Schedule."Admission Is";

            //-TM1.28 [306039]
            "Visibility On Web" := AdmissionScheduleLines."Visibility On Web";
            //+TM1.28 [306039]

            //-TM1.28 [303925]
            if ((Admission."Admission Base Calendar Code" <> '') and ("Admission Is" = "Admission Is"::OPEN)) then begin
                CustomizedCalendarChangeTemp.Init();
                CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Location;
                CustomizedCalendarChangeTemp."Base Calendar Code" := Admission."Admission Base Calendar Code";
                CustomizedCalendarChangeTemp."Date" := StartFromDate;
                CustomizedCalendarChangeTemp.Description := CalendarDesc;
                CustomizedCalendarChangeTemp."Source Code" := "Admission Code";
                CustomizedCalendarChangeTemp.Insert();

                CalendarManagement.CheckDateStatus(CustomizedCalendarChangeTemp);
                if (CustomizedCalendarChangeTemp.Nonworking) then
                    "Admission Is" := Schedule."Admission Is"::CLOSED;
            end;

            if ((Schedule."Admission Base Calendar Code" <> '') and ("Admission Is" = "Admission Is"::OPEN)) then begin
                CustomizedCalendarChangeTemp.DeleteAll();
                CustomizedCalendarChangeTemp.Init();
                CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Location;
                CustomizedCalendarChangeTemp."Base Calendar Code" := Admission."Admission Base Calendar Code";
                CustomizedCalendarChangeTemp."Date" := StartFromDate;
                CustomizedCalendarChangeTemp.Description := CalendarDesc;
                CustomizedCalendarChangeTemp."Additional Source Code" := "Schedule Code";
                CustomizedCalendarChangeTemp.Insert();

                CalendarManagement.CheckDateStatus(CustomizedCalendarChangeTemp);
                if (CustomizedCalendarChangeTemp.Nonworking) then
                    "Admission Is" := Schedule."Admission Is"::CLOSED;
            end;

            if ((AdmissionScheduleLines."Admission Base Calendar Code" <> '') and ("Admission Is" = "Admission Is"::OPEN)) then begin
                CustomizedCalendarChangeTemp.DeleteAll();
                CustomizedCalendarChangeTemp.Init();
                CustomizedCalendarChangeTemp."Source Type" := CustomizedCalendarChangeTemp."Source Type"::Location;
                CustomizedCalendarChangeTemp."Base Calendar Code" := Admission."Admission Base Calendar Code";
                CustomizedCalendarChangeTemp."Date" := StartFromDate;
                CustomizedCalendarChangeTemp.Description := CalendarDesc;
                CustomizedCalendarChangeTemp."Source Code" := "Admission Code";
                CustomizedCalendarChangeTemp."Additional Source Code" := "Schedule Code";
                CustomizedCalendarChangeTemp.Insert();

                CalendarManagement.CheckDateStatus(CustomizedCalendarChangeTemp);
                if (CustomizedCalendarChangeTemp.Nonworking) then
                    "Admission Is" := Schedule."Admission Is"::CLOSED;
            end;
            //+TM1.28 [303925]

            Cancelled := false;
            "Reason Code" := 'NTE'; // New Time Entry

            Modify();
        end;
    end;

    local procedure CompareScheduleEntries(AdmissionCode: Code[20]; ReferenceDate: Date; var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary): Boolean
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        PreviousAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        UniqKey: Text;
    begin

        //-#260812 [260812]
        // is there a manual override?
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
        AdmissionScheduleEntry.SetFilter("Regenerate With", '=%1', AdmissionScheduleEntry."Regenerate With"::MANUAL);
        AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', TmpAdmissionScheduleEntry."Schedule Code");
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (not AdmissionScheduleEntry.IsEmpty()) then
            exit(true); // Ignore this line by saying a idenical line exist.

        AdmissionScheduleEntry.Reset();
        //+#260812 [260812]

        if (TmpAdmissionScheduleEntry.IsEmpty()) then begin
            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
            if (AdmissionScheduleEntry.IsEmpty()) then
                exit(true);

            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false); // Entries with cancelled FALSE must me cancelled
            exit(not AdmissionScheduleEntry.IsEmpty());
        end;

        if (TmpAdmissionScheduleEntry.Count = 1) then begin
            TmpAdmissionScheduleEntry.FindFirst();

            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
            AdmissionScheduleEntry.SetFilter("Admission Start Time", '=%1', TmpAdmissionScheduleEntry."Admission Start Time");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmissionScheduleEntry.Count <> 1) then
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

            if (UniqKey <> '') and (UniqKey <> GetIdentifyingString(TmpAdmissionScheduleEntry)) then
                if (not CheckExists(TmpAdmissionScheduleEntry)) then
                    exit(false);

            UniqKey := GetIdentifyingString(TmpAdmissionScheduleEntry);
        // PreviousAdmissionScheduleEntry.COPY (TmpAdmissionScheduleEntry);

        until (TmpAdmissionScheduleEntry.Next() = 0);

        exit(CheckExists(TmpAdmissionScheduleEntry));
    end;

    local procedure StoreScheduleEntries(AdmissionCode: Code[20]; ReferenceDate: Date; var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary)
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
    begin

        exit(
          StrSubstNo('%1;%2;%3',
            AdmissionScheduleEntry."Admission Code",
            AdmissionScheduleEntry."Admission Start Date",
            AdmissionScheduleEntry."Admission Start Time")
          //AdmissionScheduleEntry."Admission Is")
          //AdmissionScheduleEntry.Cancelled)
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
        //AdmissionScheduleEntry.SETFILTER ("Schedule Code", '=%1', TmpAdmissionScheduleEntry."Schedule Code"); //267611
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
    end;

    local procedure GetHighestDateEntry(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ReferenceDate: Date): Date
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin

        AdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', ScheduleCode);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

        if (AdmissionScheduleEntry.FindLast()) then
            exit(AdmissionScheduleEntry."Admission Start Date");

        exit(ReferenceDate);
    end;

    local procedure IsIdentical(AdmissionScheduleEntry1: Record "NPR TM Admis. Schedule Entry"; AdmissionScheduleEntry2: Record "NPR TM Admis. Schedule Entry"): Boolean
    begin

        if (AdmissionScheduleEntry1."Admission Start Date" <> AdmissionScheduleEntry2."Admission Start Date") then exit(false);
        if (AdmissionScheduleEntry1."Admission Start Time" <> AdmissionScheduleEntry2."Admission Start Time") then exit(false);
        if (AdmissionScheduleEntry1."Event Duration" <> AdmissionScheduleEntry2."Event Duration") then exit(false);
        if (AdmissionScheduleEntry1.Cancelled <> AdmissionScheduleEntry2.Cancelled) then exit(false);

        exit(true);
    end;

    local procedure "--"()
    begin
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
        TmpTicketParticipantWks: Record "NPR TM Ticket Particpt. Wks." temporary;
        TmpTicketParticipantWks2: Record "NPR TM Ticket Particpt. Wks." temporary;
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
        PendingCount := TicketParticipantWks.Count;
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

            //-TM1.21 [274828]
            //TicketReservationRequest.GET (Ticket."Ticket Reservation Entry No.");
            if (not TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then
                Clear(TicketReservationRequest);
            //-TM1.21 [274828]

            TmpTicketParticipantWks.Init;
            EntryCount += 1;
            TmpTicketParticipantWks."Entry No." := EntryCount;
            TmpTicketParticipantWks."Applies To Schedule Entry No." := ScheduleEntryNo;
            TmpTicketParticipantWks."Notification Send Status" := TmpTicketParticipantWks."Notification Send Status"::PENDING;

            TmpTicketParticipantWks."Ticket No." := DetTicketAccessEntry."Ticket No.";
            TmpTicketParticipantWks."Admission Code" := TicketAccessEntry."Admission Code";
            TmpTicketParticipantWks."Admission Description" := Admission.Description;

            TmpTicketParticipantWks."Det. Ticket Access Entry No." := DetTicketAccessEntry."Entry No.";

            /// the source is the last schedule entry and its not canceled - reminder
            ///if (RescheduleToScheduleEntry.Cancelled = false) and (ScheduleEntryNo = RescheduleToScheduleEntry."Entry No.") then
            // Default is reminder
            TmpTicketParticipantWks."Notification Type" := TmpTicketParticipantWks."Notification Type"::REMINDER;

            // multiple entires, first is canceled, last is not - reschedule
            if (not RescheduleToScheduleEntry.Cancelled) and (OriginalScheduleEntry.Cancelled) then
                TmpTicketParticipantWks."Notification Type" := TmpTicketParticipantWks."Notification Type"::RESCHEDULE;

            // the source is the last schedule entry and its canceled - cancellation
            if (RescheduleToScheduleEntry.Cancelled) and (ScheduleEntryNo = RescheduleToScheduleEntry."Entry No.") then
                TmpTicketParticipantWks."Notification Type" := TmpTicketParticipantWks."Notification Type"::CANCELATION;

            TmpTicketParticipantWks."Original Schedule Entry No." := OriginalScheduleEntry."Entry No.";
            TmpTicketParticipantWks."Original Start Date" := OriginalScheduleEntry."Admission Start Date";
            TmpTicketParticipantWks."Original Start Time" := OriginalScheduleEntry."Admission Start Time";
            TmpTicketParticipantWks."Original End Date" := OriginalScheduleEntry."Admission End Date";
            TmpTicketParticipantWks."Original End Time" := OriginalScheduleEntry."Admission End Time";

            TmpTicketParticipantWks."New Schedule Entry No." := RescheduleToScheduleEntry."Entry No.";
            TmpTicketParticipantWks."New Start Date" := RescheduleToScheduleEntry."Admission Start Date";
            TmpTicketParticipantWks."New Start Time" := RescheduleToScheduleEntry."Admission Start Time";
            TmpTicketParticipantWks."New End Date" := RescheduleToScheduleEntry."Admission End Date";
            TmpTicketParticipantWks."New End Time" := RescheduleToScheduleEntry."Admission End Time";

            TmpTicketParticipantWks."Notification Method" := TicketReservationRequest."Notification Method";
            TmpTicketParticipantWks."Notification Address" := TicketReservationRequest."Notification Address";

            TmpTicketParticipantWks."Notifcation Created At" := CurrentDateTime();

            //-TM1.21 [274828]
            if (TicketAccessEntry.Status = TicketAccessEntry.Status::ACCESS) then
                TmpTicketParticipantWks.Insert();
        //+TM1.21 [274828]

        until (DetTicketAccessEntry.Next() = 0);


        /// Mark duplicate notification address as duplicate
        TmpTicketParticipantWks.Reset();
        TmpTicketParticipantWks.FindSet();
        repeat
            TmpTicketParticipantWks2.SetFilter("Notification Address", '=%1', TmpTicketParticipantWks."Notification Address");
            DuplicateNotificationAddress := TmpTicketParticipantWks2.FindFirst();

            TmpTicketParticipantWks2.TransferFields(TmpTicketParticipantWks, true);
            if (DuplicateNotificationAddress) then
                TmpTicketParticipantWks2."Notification Send Status" := TmpTicketParticipantWks2."Notification Send Status"::DUPLICATE;

            TmpTicketParticipantWks2.Insert();
        until (TmpTicketParticipantWks.Next() = 0);

        TmpTicketParticipantWks2.Reset();
        TmpTicketParticipantWks2.FindSet();
        repeat
            TicketParticipantWks.TransferFields(TmpTicketParticipantWks2);
            TicketParticipantWks."Entry No." := 0;
            TicketParticipantWks.Insert();
        until (TmpTicketParticipantWks2.Next() = 0);
    end;
}


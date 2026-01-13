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
                CreateAdmissionSchedule(Admission."Admission Code", false, Today(), 'NPRTMAdmissionSchMgt.OnRun()');
            until (Admission.Next() = 0);
        end;
    end;

    var
        APPEND_LIST_CONFIRM: Label 'There is already a list created for this schedule.\Do you want to append to it?';
        RECREATE_LIST_CONFIRM: Label 'Warning.\The list will be recreated and the current notification status will set to pending.';
        _TodaysDate: Date;


    // This API is intended for the test framework to use - there is no spamming telemetry
    internal procedure CreateAdmissionScheduleTestFramework(AdmissionCode: Code[20]; Regenerate: Boolean; ReferenceDate: Date)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        _TodaysDate := Today();
        CreateAdmissionScheduleWorker(AdmissionCode, Regenerate, ReferenceDate, CustomDimensions);
    end;

    internal procedure CreateAdmissionScheduleTestFramework(AdmissionCode: Code[20]; Regenerate: Boolean; ReferenceDate: Date; SimulationForDate: Date)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        _TodaysDate := SimulationForDate;
        CreateAdmissionScheduleWorker(AdmissionCode, Regenerate, ReferenceDate, CustomDimensions);
    end;

    procedure CreateAdmissionSchedule(AdmissionCode: Code[20]; Regenerate: Boolean; ReferenceDate: Date; SourceTag: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        ActiveSession: Record "Active Session";
        VerbosityLevel: Verbosity;
        StartTime: Time;
    begin

        if (not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId())) then
            Clear(ActiveSession);

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_UserID', ActiveSession."User ID");
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");
        CustomDimensions.Add('NPR_SessionUniqId', ActiveSession."Session Unique ID");

        CustomDimensions.Add('NPR_AdmissionCode', AdmissionCode);
        CustomDimensions.Add('NPR_Regenerate', Format(Regenerate, 0, 9));
        CustomDimensions.Add('NPR_ReferenceDate', Format(ReferenceDate, 0, 9));
        CustomDimensions.Add('NPR_SourceTag', SourceTag);
        CustomDimensions.Add('NPR_SchedularVersion', '3');

        VerbosityLevel := Verbosity::Normal;
        Session.LogMessage('NPR_CreateAdmissionSchedule', 'CreateAdmissionSchedule Started', VerbosityLevel, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);

        StartTime := Time();
        _TodaysDate := Today();
        CreateAdmissionScheduleWorker(AdmissionCode, Regenerate, ReferenceDate, CustomDimensions);

        CustomDimensions.Add('NPR_DurationMs', format((Time() - StartTime), 0, 9));
        Session.LogMessage('NPR_CreateAdmissionSchedule', 'CreateAdmissionSchedule Completed', VerbosityLevel, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    local procedure CreateAdmissionScheduleWorker(AdmissionCode: Code[20]; Regenerate: Boolean; ReferenceDate: Date; CustomDimensions: Dictionary of [Text, Text])
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        DateRecord: Record Date;
        TempTargetAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary;

        ScheduleGeneratedAt: Dictionary of [Guid, Date];
        ScheduleGeneratedUntil: Dictionary of [Guid, Date];
        ScheduleLineSystemId: Guid;

        ScheduleStartDate: Date;
        ScheduleEndDate: Date;
        GenerateFromDate: Date;
        GenerateUntilDate: Date;
        EntryCounter: Integer;

        FullReplaceDict: Dictionary of [Integer, Integer];
        PartialUpdateDict: Dictionary of [Integer, Integer];
        InsertNewList: List of [Integer];
        CancelExistingList: List of [Integer];
        CountFullReplace, CountUpdated, CountNew, CountCanceled : Integer;
    begin
        AdmissionScheduleLines.SetCurrentKey("Admission Code", "Process Order");
        AdmissionScheduleLines.SetFilter("Admission Code", '=%1', AdmissionCode);
        if (AdmissionScheduleLines.FindSet()) then begin

            GenerateFromDate := _TodaysDate;
            if ((ReferenceDate > _TodaysDate) and (Regenerate)) then
                GenerateFromDate := ReferenceDate;
            GenerateUntilDate := 0D;

            // find the low / high dates for all schedules for this admission
            repeat
                CalculateScheduleDateRange(AdmissionScheduleLines, ReferenceDate, 0D, Regenerate, ScheduleStartDate, ScheduleEndDate);
                if (GenerateFromDate > ScheduleStartDate) then
                    GenerateFromDate := ScheduleStartDate;

                if (GenerateUntilDate < ScheduleEndDate) then
                    GenerateUntilDate := ScheduleEndDate;

            until (AdmissionScheduleLines.Next() = 0);

            if (GenerateFromDate < _TodaysDate) then
                GenerateFromDate := _TodaysDate;

            if (GenerateUntilDate < GenerateFromDate) then
                exit;

            if (Regenerate) then begin
                AdmissionScheduleLines.FindSet();
                repeat
                    CancelTimeEntry(AdmissionScheduleLines."Admission Code", AdmissionScheduleLines."Schedule Code", GenerateFromDate, GenerateUntilDate);
                until (AdmissionScheduleLines.Next() = 0);
            end;

            CustomDimensions.Add('NPR_GenerateFromDate', Format(GenerateFromDate, 0, 9));
            CustomDimensions.Add('NPR_GenerateUntilDate', Format(GenerateUntilDate, 0, 9));

            // Start generating entries
            DateRecord.Reset();
            DateRecord.SetFilter("Period Type", '=%1', DateRecord."Period Type"::Date);
            DateRecord.SetFilter("Period Start", '%1..%2', GenerateFromDate, GenerateUntilDate);
            if (DateRecord.FindSet()) then begin
                repeat

                    Clear(FullReplaceDict);
                    Clear(PartialUpdateDict);
                    Clear(InsertNewList);
                    Clear(CancelExistingList);

                    if (TempTargetAdmissionScheduleEntry.IsTemporary) then
                        TempTargetAdmissionScheduleEntry.DeleteAll();

                    AdmissionScheduleLines.FindSet();
                    repeat
                        GenerateScheduleEntryV3(AdmissionScheduleLines, DateRecord."Period Start", TempTargetAdmissionScheduleEntry, ScheduleGeneratedAt, ScheduleGeneratedUntil);
                    until (AdmissionScheduleLines.Next() = 0);

                    CompareScheduleEntriesV3(AdmissionCode,
                        DateRecord."Period Start",
                        TempTargetAdmissionScheduleEntry,
                        FullReplaceDict, PartialUpdateDict, InsertNewList, CancelExistingList,
                        Regenerate);

                    CountFullReplace += FullReplaceEntry(FullReplaceDict, TempTargetAdmissionScheduleEntry);
                    CountUpdated += PartialUpdateEntry(PartialUpdateDict, TempTargetAdmissionScheduleEntry);
                    CountNew += InsertNewEntry(InsertNewList, TempTargetAdmissionScheduleEntry);
                    CountCanceled += CancelExistingEntry(CancelExistingList);

                    TempTargetAdmissionScheduleEntry.Reset();
                    EntryCounter += TempTargetAdmissionScheduleEntry.Count();

                until (DateRecord.Next() = 0);

                // Update the schedule lines with the new generated dates
                foreach ScheduleLineSystemId in ScheduleGeneratedAt.Keys do begin
                    AdmissionScheduleLines.GetBySystemId(ScheduleLineSystemId);
                    if (AdmissionScheduleLines."Schedule Generated At" <> ScheduleGeneratedAt.Get(ScheduleLineSystemId)) then begin
                        AdmissionScheduleLines."Schedule Generated At" := ScheduleGeneratedAt.Get(ScheduleLineSystemId);
                        AdmissionScheduleLines.Modify();
                    end;
                end;

                foreach ScheduleLineSystemId in ScheduleGeneratedUntil.Keys do begin
                    AdmissionScheduleLines.GetBySystemId(ScheduleLineSystemId);
                    if (AdmissionScheduleLines."Schedule Generated Until" <> ScheduleGeneratedUntil.Get(ScheduleLineSystemId)) then begin
                        AdmissionScheduleLines."Schedule Generated Until" := ScheduleGeneratedUntil.Get(ScheduleLineSystemId);
                        AdmissionScheduleLines.Modify();
                    end;
                end;
            end;

            CustomDimensions.Add('NPR_EntriesAffected', Format(EntryCounter, 0, 9));
            CustomDimensions.Add('NPR_EntriesAffectedDetailed', StrSubstNo('%1/%2/%3/%4', CountNew, CountFullReplace, CountUpdated, CountCanceled));
        end;
    end;

    procedure IsUpdateScheduleEntryRequired(AdmissionCode: Code[20]; ReferenceDate: Date): Boolean
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        if (ReferenceDate = 0D) then
            ReferenceDate := _TodaysDate;

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

    local procedure GenerateScheduleEntryV3(AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines"; GenerateForDate: Date; var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary; var ScheduleGeneratedAt: Dictionary of [Guid, Date]; var ScheduleGeneratedUntil: Dictionary of [Guid, Date])
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
            if (AdmissionScheduleLines."Schedule Generated At" <> _TodaysDate) then
                PutScheduleGeneratedDate(ScheduleGeneratedAt, AdmissionScheduleLines.SystemId, _TodaysDate);
            exit;
        end;
        Admission.SetLoadFields("Admission Code", "Admission Base Calendar Code");
        Admission.Get(AdmissionScheduleLines."Admission Code");

        Schedule.Get(AdmissionScheduleLines."Schedule Code");

        if (Schedule."Recur Every N On" = 0) then begin
            Schedule."Recur Every N On" := 1;
            Schedule.Modify();
        end;

        HighestEntryDate := AdmissionScheduleLines."Schedule Generated Until";
        if HighestEntryDate = 0D then
            HighestEntryDate := Schedule."Start From";

        CreateEntryThisPeriod := (GenerateForDate <= HighestEntryDate); // already generated or first day

        if (not CreateEntryThisPeriod) and (HighestEntryDate < GenerateForDate) then begin
            // set DateRecordPeriod filter based on recurrence pattern
            if (Schedule."Recurrence Pattern" = Schedule."Recurrence Pattern"::WEEKLY) then
                DateRecordPeriod.SetFilter("Period Type", '=%1', DateRecordPeriod."Period Type"::Week);

            if (Schedule."Recurrence Pattern" = Schedule."Recurrence Pattern"::DAILY) then
                DateRecordPeriod.SetFilter("Period Type", '=%1', DateRecordPeriod."Period Type"::Date);

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

            PutScheduleGeneratedDate(ScheduleGeneratedUntil, AdmissionScheduleLines.SystemId, GenerateForDate);
        end;

        PutScheduleGeneratedDate(ScheduleGeneratedAt, AdmissionScheduleLines.SystemId, _TodaysDate);
    end;

    local procedure PutScheduleGeneratedDate(var ScheduleGeneratedDict: Dictionary of [Guid, Date]; SystemId: Guid; NewDate: Date)
    begin
        if ScheduleGeneratedDict.ContainsKey(SystemId) then
            ScheduleGeneratedDict.Remove(SystemId);

        ScheduleGeneratedDict.Add(SystemId, NewDate);
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
            if (AdmissionScheduleLines."Schedule Generated At" = _TodaysDate) then
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
        AdmissionScheduleLines2: Record "NPR TM Admis. Schedule Lines";
        TicketCalendarManagement: Codeunit "NPR TMBaseCalendarManager";
        EndDateTime: DateTime;
    begin

        // we are not creating historical entries
        if (StartFromDate < _TodaysDate) then
            exit;

        AdmissionScheduleLines.Get(Admission."Admission Code", Schedule."Schedule Code");

        // Prevent duplicate same time entries
        TmpAdmissionScheduleEntry.Reset();
        TmpAdmissionScheduleEntry.SetCurrentKey("Admission Start Date", "Admission Start Time");
        TmpAdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', StartFromDate);
        TmpAdmissionScheduleEntry.SetFilter("Admission Start Time", '=%1', Schedule."Start Time");
        if (TmpAdmissionScheduleEntry.FindFirst()) then begin
            AdmissionScheduleLines2.Get(TmpAdmissionScheduleEntry."Admission Code", TmpAdmissionScheduleEntry."Schedule Code");
            if (AdmissionScheduleLines2."Process Order" > AdmissionScheduleLines."Process Order") then
                exit;
            TmpAdmissionScheduleEntry.Delete();
        end;

        // the new entry
        TmpAdmissionScheduleEntry.Reset();
        TmpAdmissionScheduleEntry.SetCurrentKey("Entry No.");
        if (not TmpAdmissionScheduleEntry.FindLast()) then
            TmpAdmissionScheduleEntry."Entry No." := 0;

        TmpAdmissionScheduleEntry.Init();
        TmpAdmissionScheduleEntry."Entry No." += 1;
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
        TmpAdmissionScheduleEntry."Dynamic Price Profile Code" := AdmissionScheduleLines."Dynamic Price Profile Code";

        if ((Admission."Admission Base Calendar Code" <> '') and (TmpAdmissionScheduleEntry."Admission Is" = TmpAdmissionScheduleEntry."Admission Is"::OPEN)) then
            if (TicketCalendarManagement.CheckAdmissionIsNonWorking(Admission, StartFromDate)) then
                TmpAdmissionScheduleEntry."Admission Is" := Schedule."Admission Is"::CLOSED;

        if ((Schedule."Admission Base Calendar Code" <> '') and (TmpAdmissionScheduleEntry."Admission Is" = TmpAdmissionScheduleEntry."Admission Is"::OPEN)) then
            if (TicketCalendarManagement.CheckScheduleIsNonWorking(Schedule, StartFromDate)) then
                TmpAdmissionScheduleEntry."Admission Is" := Schedule."Admission Is"::CLOSED;

        if ((AdmissionScheduleLines."Admission Base Calendar Code" <> '') and (TmpAdmissionScheduleEntry."Admission Is" = TmpAdmissionScheduleEntry."Admission Is"::OPEN)) then
            if (TicketCalendarManagement.CheckAdmissionScheduleIsNonWorking(AdmissionScheduleLines, StartFromDate)) then
                TmpAdmissionScheduleEntry."Admission Is" := Schedule."Admission Is"::CLOSED;

        TmpAdmissionScheduleEntry.Cancelled := false;
        TmpAdmissionScheduleEntry."Reason Code" := 'NTE'; // New Time Entry

        TmpAdmissionScheduleEntry.Modify();
    end;

    local procedure CompareScheduleEntriesV3(
        AdmissionCode: Code[20];
        ReferenceDate: Date;
        var TempTargetAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary;
        var FullReplace: Dictionary of [Integer, Integer];
        var PartialUpdate: Dictionary of [Integer, Integer];
        var InsertNewList: List of [Integer];
        var CancelExistingList: List of [Integer];
        Regenerate: Boolean)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TempExistingAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary;
        IsDifferent: Boolean;
        PreviousExternalEntryNo: Integer;
    begin

        // Get the last existing time slots for each schedule on reference date
        // NOTE: In BC, the primary key ("Entry No.") is appended to any secondary key.
        // With current key ("Admission Code","Schedule Code","Admission Start Date"), iteration
        // is deterministic and Entry No is ascending, so the last seen row per group is the newest.
        // Do not use SetLoadFields here, as we need all fields for comparison.
        AdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);

        // Single pass to get the latest entry for each admission and schedule code 
        if (AdmissionScheduleEntry.FindSet()) then begin
            PreviousExternalEntryNo := -1; // invalid value
            repeat
                if (PreviousExternalEntryNo <> AdmissionScheduleEntry."External Schedule Entry No.") and (PreviousExternalEntryNo <> -1) then begin
                    TempExistingAdmissionScheduleEntry.Insert();
                    CancelExistingList.Add(TempExistingAdmissionScheduleEntry."Entry No.");
                end;
                PreviousExternalEntryNo := AdmissionScheduleEntry."External Schedule Entry No.";
                TempExistingAdmissionScheduleEntry.TransferFields(AdmissionScheduleEntry, true);

            until (AdmissionScheduleEntry.Next() = 0);
            TempExistingAdmissionScheduleEntry.Insert();
            CancelExistingList.Add(TempExistingAdmissionScheduleEntry."Entry No.");
        end;

        // Verify target exists
        TempTargetAdmissionScheduleEntry.Reset();

        TempExistingAdmissionScheduleEntry.Reset();
        TempExistingAdmissionScheduleEntry.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        if (TempTargetAdmissionScheduleEntry.FindSet()) then begin
            repeat
                InsertNewList.Add(TempTargetAdmissionScheduleEntry."Entry No.");

                TempExistingAdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TempTargetAdmissionScheduleEntry."Admission Code");
                TempExistingAdmissionScheduleEntry.SetFilter("Schedule Code", '=%1', TempTargetAdmissionScheduleEntry."Schedule Code");
                TempExistingAdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
                if (TempExistingAdmissionScheduleEntry.FindFirst()) then begin
                    IsDifferent := not AreEqual(TempExistingAdmissionScheduleEntry, TempTargetAdmissionScheduleEntry);

                    if (Regenerate) then begin
                        if (IsDifferent) then
                            FullReplace.Add(TempExistingAdmissionScheduleEntry."Entry No.", TempTargetAdmissionScheduleEntry."Entry No.");
                    end else begin
                        if (TempExistingAdmissionScheduleEntry."Regenerate With" = TempExistingAdmissionScheduleEntry."Regenerate With"::SCHEDULER) then
                            if (IsDifferent) then
                                FullReplace.Add(TempExistingAdmissionScheduleEntry."Entry No.", TempTargetAdmissionScheduleEntry."Entry No.");

                        if (TempExistingAdmissionScheduleEntry."Regenerate With" = TempExistingAdmissionScheduleEntry."Regenerate With"::MANUAL) then
                            if (IsDifferent) then
                                PartialUpdate.Add(TempExistingAdmissionScheduleEntry."Entry No.", TempTargetAdmissionScheduleEntry."Entry No.");
                    end;

                    InsertNewList.Remove(TempTargetAdmissionScheduleEntry."Entry No.");
                    CancelExistingList.Remove(TempExistingAdmissionScheduleEntry."Entry No.");

                end;
            until (TempTargetAdmissionScheduleEntry.Next() = 0);
        end;
    end;

    local procedure AreEqual(var TmpExistingAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary; var TmpTargetAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary): Boolean
    begin
        if (TmpExistingAdmissionScheduleEntry."Regenerate With" = TmpExistingAdmissionScheduleEntry."Regenerate With"::SCHEDULER) then
            exit(
                (TmpExistingAdmissionScheduleEntry."Event Arrival From Time" = TmpTargetAdmissionScheduleEntry."Event Arrival From Time")
                and (TmpExistingAdmissionScheduleEntry."Event Arrival Until Time" = TmpTargetAdmissionScheduleEntry."Event Arrival Until Time")
                and (TmpExistingAdmissionScheduleEntry."Max Capacity Per Sch. Entry" = TmpTargetAdmissionScheduleEntry."Max Capacity Per Sch. Entry")
                and (TmpExistingAdmissionScheduleEntry."Sales From Date" = TmpTargetAdmissionScheduleEntry."Sales From Date")
                and (TmpExistingAdmissionScheduleEntry."Sales From Time" = TmpTargetAdmissionScheduleEntry."Sales From Time")
                and (TmpExistingAdmissionScheduleEntry."Sales Until Date" = TmpTargetAdmissionScheduleEntry."Sales Until Date")
                and (TmpExistingAdmissionScheduleEntry."Sales Until Time" = TmpTargetAdmissionScheduleEntry."Sales Until Time")
                and (TmpExistingAdmissionScheduleEntry."Visibility On Web" = TmpTargetAdmissionScheduleEntry."Visibility On Web")
                and (TmpExistingAdmissionScheduleEntry."Admission Start Time" = TmpTargetAdmissionScheduleEntry."Admission Start Time")
                and (TmpExistingAdmissionScheduleEntry."Admission End Date" = TmpTargetAdmissionScheduleEntry."Admission End Date")
                and (TmpExistingAdmissionScheduleEntry."Admission End Time" = TmpTargetAdmissionScheduleEntry."Admission End Time")
                and (TmpExistingAdmissionScheduleEntry."Admission Is" = TmpTargetAdmissionScheduleEntry."Admission Is")
                and (TmpExistingAdmissionScheduleEntry.Cancelled = TmpTargetAdmissionScheduleEntry.Cancelled)
                and (TmpExistingAdmissionScheduleEntry."Dynamic Price Profile Code" = TmpTargetAdmissionScheduleEntry."Dynamic Price Profile Code")
            );

        if (TmpExistingAdmissionScheduleEntry."Regenerate With" = TmpExistingAdmissionScheduleEntry."Regenerate With"::MANUAL) then
            exit(
                (TmpExistingAdmissionScheduleEntry."Admission Start Time" = TmpTargetAdmissionScheduleEntry."Admission Start Time")
                and (TmpExistingAdmissionScheduleEntry."Admission End Date" = TmpTargetAdmissionScheduleEntry."Admission End Date")
                and (TmpExistingAdmissionScheduleEntry."Admission End Time" = TmpTargetAdmissionScheduleEntry."Admission End Time")
                and (TmpExistingAdmissionScheduleEntry.Cancelled = TmpTargetAdmissionScheduleEntry.Cancelled)
            );
    end;

    local procedure FullReplaceEntry(FullReplaceDict: Dictionary of [Integer, Integer]; var TempTargetAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary): Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TargetEntryNo: Integer;
        ExistingEntryNo: Integer;
        OriginalEntryNo: Integer;
    begin
        foreach ExistingEntryNo in FullReplaceDict.Keys() do begin
            TargetEntryNo := FullReplaceDict.Get(ExistingEntryNo);
            AdmissionScheduleEntry.Get(ExistingEntryNo);
            OriginalEntryNo := AdmissionScheduleEntry."External Schedule Entry No.";

            AdmissionScheduleEntry.Cancelled := true;
            AdmissionScheduleEntry."Reason Code" := 'REPLACED';
            AdmissionScheduleEntry.Modify();

            TempTargetAdmissionScheduleEntry.Get(TargetEntryNo);
            AdmissionScheduleEntry.TransferFields(TempTargetAdmissionScheduleEntry, false);
            AdmissionScheduleEntry."External Schedule Entry No." := OriginalEntryNo;
            AdmissionScheduleEntry."Entry No." := 0;
            AdmissionScheduleEntry.Insert();
        end;

        exit(FullReplaceDict.Count());
    end;

    local procedure PartialUpdateEntry(PartialUpdateDict: Dictionary of [Integer, Integer]; var TempTargetAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary): Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TargetEntryNo: Integer;
        ExistingEntryNo: Integer;
    begin
        foreach ExistingEntryNo in PartialUpdateDict.Keys() do begin
            TargetEntryNo := PartialUpdateDict.Get(ExistingEntryNo);
            AdmissionScheduleEntry.Get(ExistingEntryNo);
            TempTargetAdmissionScheduleEntry.Get(TargetEntryNo);

            AdmissionScheduleEntry."Admission Start Time" := TempTargetAdmissionScheduleEntry."Admission Start Time";
            AdmissionScheduleEntry."Admission End Date" := TempTargetAdmissionScheduleEntry."Admission End Date";
            AdmissionScheduleEntry."Admission End Time" := TempTargetAdmissionScheduleEntry."Admission End Time";
            AdmissionScheduleEntry."Event Duration" := TempTargetAdmissionScheduleEntry."Event Duration";
            AdmissionScheduleEntry."Reason Code" := 'UPDATED';
            AdmissionScheduleEntry.Modify();
        end;

        exit(PartialUpdateDict.Count());
    end;

    local procedure InsertNewEntry(InsertNewList: List of [Integer]; var TempTargetAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary): Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TargetEntryNo: Integer;
    begin
        foreach TargetEntryNo in InsertNewList do begin
            TempTargetAdmissionScheduleEntry.Get(TargetEntryNo);
            AdmissionScheduleEntry.TransferFields(TempTargetAdmissionScheduleEntry, false);
            AdmissionScheduleEntry."Entry No." := 0;
            AdmissionScheduleEntry."Reason Code" := 'NEW';
            AdmissionScheduleEntry.Cancelled := false;
            AdmissionScheduleEntry.Insert();

            AdmissionScheduleEntry."External Schedule Entry No." := AdmissionScheduleEntry."Entry No.";
            AdmissionScheduleEntry.Modify();
        end;

        exit(InsertNewList.Count());
    end;

    local procedure CancelExistingEntry(CancelList: List of [Integer]): Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        ExistingEntryNo: Integer;
    begin
        foreach ExistingEntryNo in CancelList do begin
            AdmissionScheduleEntry.Get(ExistingEntryNo);
            AdmissionScheduleEntry."Reason Code" := 'CANCELED';
            AdmissionScheduleEntry.Cancelled := true;
            AdmissionScheduleEntry.Modify();
        end;

        exit(CancelList.Count());
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


codeunit 6014663 "NPR Job Queue Management"
{
    Access = Public;

    Permissions =
        tabledata "Error Message" = rimd,
        tabledata "Error Message Register" = rimd,
        tabledata "Job Queue Entry" = rimd;

    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        JobTimeout: Duration;
        NotifProfileCodeOnError: Code[20];
        StoreCode: Code[20];
        AutoRescheduleOnErrorDelaySec: Integer;
        MaxNoOfAttemptsToRun: Integer;
        RerunDelaySec: Integer;
        AutoRescheduleOnError: Boolean;
        ShowAutoCreatedClause: Boolean;
        ParamNameAndValueLbl: Label '%1=%2', Locked = true;

    procedure ScheduleNcTaskProcessing(TaskProcessorCode: Code[20]; EnableTaskListUpdate: Boolean; JobQueueCatagoryCode: Code[10])
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        ScheduleNcTaskProcessing(JobQueueEntry, TaskProcessorCode, EnableTaskListUpdate, JobQueueCatagoryCode, 0);
    end;

    procedure ScheduleNcTaskProcessing(var JobQueueEntry: Record "Job Queue Entry"; TaskProcessorCode: Code[20]; EnableTaskListUpdate: Boolean; JobQueueCatagoryCode: Code[10])
    begin
        ScheduleNcTaskProcessing(JobQueueEntry, TaskProcessorCode, EnableTaskListUpdate, JobQueueCatagoryCode, 0);
    end;

    procedure ScheduleNcTaskProcessing(var JobQueueEntry: Record "Job Queue Entry"; TaskProcessorCode: Code[20]; EnableTaskListUpdate: Boolean; JobQueueCatagoryCode: Code[10]; NoOfMinutesBetweenRuns: Integer)
    var
        NcTaskListProcessing: Codeunit "NPR Nc Task List Processing";
        NotBeforeDateTime: DateTime;
        JobQueueDescription: Text;
        Handled: Boolean;
        JobQueueDescrLbl: Label '%1 Task List processing';
        JobQueueDescrWithStoreLbl: Label '%1 (%2) Task List processing';
    begin
        if JobQueueCatagoryCode = '' then
            JobQueueCatagoryCode := NcSetupMgt.DefaultNCJQCategoryCode(NcSetupMgt.TaskListProcessingCodeunit());

        Clear(JobQueueEntry);
        OnBeforeScheduleNcTaskProcessing(JobQueueEntry, TaskProcessorCode, EnableTaskListUpdate, JobQueueCatagoryCode, Handled);
        if Handled then
            exit;

        NotBeforeDateTime := NowWithDelayInSeconds(5);
        if NoOfMinutesBetweenRuns <= 0 then
            NoOfMinutesBetweenRuns := 2;

        Clear(JQParamStrMgt);
        JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, NcTaskListProcessing.ParamProcessor(), TaskProcessorCode));
        if StoreCode <> '' then begin
            JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, NcTaskListProcessing.ParamStoreCode(), StoreCode));
            JobQueueDescription := StrSubstNo(JobQueueDescrWithStoreLbl, TaskProcessorCode, StoreCode);
            Clear(StoreCode);
        end else
            JobQueueDescription := StrSubstNo(JobQueueDescrLbl, TaskProcessorCode);
        if EnableTaskListUpdate then
            JQParamStrMgt.AddToParamDict(NcTaskListProcessing.ParamUpdateTaskList());
        JQParamStrMgt.AddToParamDict(NcTaskListProcessing.ParamProcessTaskList());
        JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, NcTaskListProcessing.ParamMaxRetry(), 3));
        OnScheduleNcTaskProcessing_OnAfterInitParameterList(TaskProcessorCode, JobQueueCatagoryCode, JQParamStrMgt);

        if ShowAutoCreatedClause then
            JobQueueDescription := StrSubstNo(GetAutoRecreateNoteTxt(), JobQueueDescription);

        SetJobTimeout(4, 0);  //4 hours

        if InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            NcSetupMgt.TaskListProcessingCodeunit(),
            JQParamStrMgt.GetParamListAsCSString(),
            JobQueueDescription,
            NotBeforeDateTime,
            NoOfMinutesBetweenRuns,
            JobQueueCatagoryCode,
            JobQueueEntry)
        then
            StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure ScheduleNcTaskCountResetJob(var JobQueueEntry: Record "Job Queue Entry"; TaskProcessorCode: Code[20]; JobQueueCatagoryCode: Code[10])
    var
        NcTaskListProcessing: Codeunit "NPR Nc Task List Processing";
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
        JobQueueDescription: Text;
        JobQueueDescrLbl: Label '%1 reset task retry count';
    begin
        if JobQueueCatagoryCode = '' then
            JobQueueCatagoryCode := NcSetupMgt.DefaultNCJQCategoryCode(NcSetupMgt.TaskListProcessingCodeunit());

        Clear(JobQueueEntry);

        NotBeforeDateTime := NowWithDelayInSeconds(60);
        Evaluate(NextRunDateFormula, '<1D>');

        Clear(JQParamStrMgt);
        JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, NcTaskListProcessing.ParamProcessor(), TaskProcessorCode));
        JQParamStrMgt.AddToParamDict(NcTaskListProcessing.ParamResetRetryCount());

        JobQueueDescription := StrSubstNo(JobQueueDescrLbl, TaskProcessorCode);
        if ShowAutoCreatedClause then
            JobQueueDescription := StrSubstNo(GetAutoRecreateNoteTxt(), JobQueueDescription);
        if InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            NcSetupMgt.TaskListProcessingCodeunit(),
            JQParamStrMgt.GetParamListAsCSString(),
            JobQueueDescription,
            NotBeforeDateTime,
            010000T,
            015959T,
            NextRunDateFormula,
            JobQueueCatagoryCode,
            JobQueueEntry)
        then
            StartJobQueueEntry(JobQueueEntry);
    end;

    procedure ScheduleNcImportListProcessing(ImportTypeCode: Code[20]; JobQueueCatagoryCode: Code[10])
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        ScheduleNcImportListProcessing(JobQueueEntry, ImportTypeCode, JobQueueCatagoryCode, 0);
    end;

    procedure ScheduleNcImportListProcessing(var JobQueueEntry: Record "Job Queue Entry"; ImportTypeCode: Code[20]; JobQueueCatagoryCode: Code[10])
    begin
        ScheduleNcImportListProcessing(JobQueueEntry, ImportTypeCode, JobQueueCatagoryCode, 0);
    end;

    procedure ScheduleNcImportListProcessing(var JobQueueEntry: Record "Job Queue Entry"; ImportTypeCode: Code[20]; JobQueueCatagoryCode: Code[10]; NoOfMinutesBetweenRuns: Integer)
    var
        NcImportListProcessing: Codeunit "NPR Nc Import List Processing";
        JobQueueDescription: Text;
        NotBeforeDateTime: DateTime;
        Handled: Boolean;
        JobQueueDescrLbl: Label 'Import List entry processing';
    begin
        if JobQueueCatagoryCode = '' then
            JobQueueCatagoryCode := NcSetupMgt.DefaultNCJQCategoryCode(NcSetupMgt.ImportListProcessingCodeunit());

        OnBeforeScheduleNcImportListProcessing(JobQueueEntry, ImportTypeCode, JobQueueCatagoryCode, Handled);
        if Handled then
            exit;

        NotBeforeDateTime := NowWithDelayInSeconds(5);
        if NoOfMinutesBetweenRuns <= 0 then
            NoOfMinutesBetweenRuns := 2;

        Clear(JQParamStrMgt);
        if ImportTypeCode <> '' then
            JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, NcImportListProcessing.ParamImportType(), ImportTypeCode));
        JQParamStrMgt.AddToParamDict(NcImportListProcessing.ParamProcessImport());
        OnScheduleNcImportListProcessing_OnAfterInitParameterList(ImportTypeCode, JobQueueCatagoryCode, JQParamStrMgt);

        JobQueueDescription := JobQueueDescrLbl;
        if ImportTypeCode <> '' then
            JobQueueDescription := ImportTypeCode + ' ' + JobQueueDescription;
        if ShowAutoCreatedClause then
            JobQueueDescription := StrSubstNo(GetAutoRecreateNoteTxt(), JobQueueDescription);

        if InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            NcSetupMgt.ImportListProcessingCodeunit(),
            JQParamStrMgt.GetParamListAsCSString(),
            JobQueueDescription,
            NotBeforeDateTime,
            NoOfMinutesBetweenRuns,
            JobQueueCatagoryCode,
            JobQueueEntry)
        then
            StartJobQueueEntry(JobQueueEntry);
    end;

    procedure InitRecurringJobQueueEntry(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; ParameterString: Text; JobDescription: Text; EarliestStartDateTime: DateTime; NoOfMinutesBetweenRuns: Integer; JobQueueCatagoryCode: Code[10]; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        RecordIdToProcess: RecordId;
        BlankDateFormula: DateFormula;
    begin
        exit(InitRecurringJobQueueEntry(ObjectTypeToRun, ObjectIdToRun, ParameterString, JobDescription, EarliestStartDateTime, 0T, 0T, NoOfMinutesBetweenRuns, BlankDateFormula, JobQueueCatagoryCode, RecordIdToProcess, JobQueueEntryOut));
    end;

    procedure InitRecurringJobQueueEntry(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; ParameterString: Text; JobDescription: Text; EarliestStartDateTime: DateTime; NoOfMinutesBetweenRuns: Integer; JobQueueCatagoryCode: Code[10]; RecordIdToProcess: RecordId; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        BlankDateFormula: DateFormula;
    begin
        exit(InitRecurringJobQueueEntry(ObjectTypeToRun, ObjectIdToRun, ParameterString, JobDescription, EarliestStartDateTime, 0T, 0T, NoOfMinutesBetweenRuns, BlankDateFormula, JobQueueCatagoryCode, RecordIdToProcess, JobQueueEntryOut));
    end;

    procedure InitRecurringJobQueueEntry(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; ParameterString: Text; JobDescription: Text; EarliestStartDateTime: DateTime; StartingTime: Time; EndingTime: Time; NoOfMinutesBetweenRuns: Integer; JobQueueCatagoryCode: Code[10]; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        RecordIdToProcess: RecordId;
        BlankDateFormula: DateFormula;
    begin
        exit(InitRecurringJobQueueEntry(ObjectTypeToRun, ObjectIdToRun, ParameterString, JobDescription, EarliestStartDateTime, StartingTime, EndingTime, NoOfMinutesBetweenRuns, BlankDateFormula, JobQueueCatagoryCode, RecordIdToProcess, JobQueueEntryOut));
    end;

    procedure InitRecurringJobQueueEntry(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; ParameterString: Text; JobDescription: Text; EarliestStartDateTime: DateTime; StartingTime: Time; EndingTime: Time; NoOfMinutesBetweenRuns: Integer; JobQueueCatagoryCode: Code[10]; RecordIdToProcess: RecordId; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        BlankDateFormula: DateFormula;
    begin
        exit(InitRecurringJobQueueEntry(ObjectTypeToRun, ObjectIdToRun, ParameterString, JobDescription, EarliestStartDateTime, StartingTime, EndingTime, NoOfMinutesBetweenRuns, BlankDateFormula, JobQueueCatagoryCode, RecordIdToProcess, JobQueueEntryOut));
    end;

    procedure InitRecurringJobQueueEntry(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; ParameterString: Text; JobDescription: Text; EarliestStartDateTime: DateTime; StartingTime: Time; EndingTime: Time; NextRunDateFormula: DateFormula; JobQueueCatagoryCode: Code[10]; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        RecordIdToProcess: RecordId;
    begin
        exit(InitRecurringJobQueueEntry(ObjectTypeToRun, ObjectIdToRun, ParameterString, JobDescription, EarliestStartDateTime, StartingTime, EndingTime, 0, NextRunDateFormula, JobQueueCatagoryCode, RecordIdToProcess, JobQueueEntryOut));
    end;

    procedure InitRecurringJobQueueEntry(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; ParameterString: Text; JobDescription: Text; EarliestStartDateTime: DateTime; StartingTime: Time; EndingTime: Time; NextRunDateFormula: DateFormula; JobQueueCatagoryCode: Code[10]; RecordIdToProcess: RecordId; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    begin
        exit(InitRecurringJobQueueEntry(ObjectTypeToRun, ObjectIdToRun, ParameterString, JobDescription, EarliestStartDateTime, StartingTime, EndingTime, 0, NextRunDateFormula, JobQueueCatagoryCode, RecordIdToProcess, JobQueueEntryOut));
    end;

    local procedure InitRecurringJobQueueEntry(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; ParameterString: Text; JobDescription: Text; EarliestStartDateTime: DateTime; StartingTime: Time; EndingTime: Time; NoOfMinutesBetweenRuns: Integer; NextRunDateFormula: DateFormula; JobQueueCatagoryCode: Code[10]; RecordIdToProcess: RecordId; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        Parameters: Record "Job Queue Entry";
    begin
        clear(Parameters);
        Parameters."Object Type to Run" := ObjectTypeToRun;
        Parameters."Object ID to Run" := ObjectIdToRun;
        Parameters."Record ID to Process" := RecordIdToProcess;
        Parameters."Earliest Start Date/Time" := EarliestStartDateTime;
        Parameters."Starting Time" := StartingTime;
        Parameters."Ending Time" := GetEndingTime(StartingTime, EndingTime);
        if Format(NextRunDateFormula) <> '' then
            Parameters."Next Run Date Formula" := NextRunDateFormula
        else begin
            Parameters."Run on Mondays" := true;
            Parameters."Run on Tuesdays" := true;
            Parameters."Run on Wednesdays" := true;
            Parameters."Run on Thursdays" := true;
            Parameters."Run on Fridays" := true;
            Parameters."Run on Saturdays" := true;
            Parameters."Run on Sundays" := true;
            Parameters."No. of Minutes between Runs" := NoOfMinutesBetweenRuns;
        end;
        Parameters."Notify On Success" := false;
        Parameters."Parameter String" := CopyStr(ParameterString, 1, MaxStrLen(Parameters."Parameter String"));
        Parameters.Description := CopyStr(JobDescription, 1, MaxStrLen(Parameters.Description));
        Parameters."Job Queue Category Code" := JobQueueCatagoryCode;
#IF NOT BC17
        if JobTimeout <> 0 then
            Parameters."Job Timeout" := JobTimeout;
#ENDIF
        Parameters."NPR Auto-Resched. after Error" := AutoRescheduleOnError;
        Parameters."NPR Auto-Resched. Delay (sec.)" := AutoRescheduleOnErrorDelaySec;
        Parameters."NPR Notif. Profile on Error" := NotifProfileCodeOnError;
        Parameters."Maximum No. of Attempts to Run" := MaxNoOfAttemptsToRun;
        Parameters."Rerun Delay (sec.)" := RerunDelaySec;
        ClearAdditionalParams();

        exit(InitRecurringJobQueueEntry(Parameters, JobQueueEntryOut));
    end;

    procedure InitRecurringJobQueueEntry(Parameters: Record "Job Queue Entry"; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        Handled: Boolean;
        Success: Boolean;
        MonitoredJobRefreshActive: Boolean;
    begin
        MonitoredJobRefreshActive := IsMonitoredJobRefreshRoutineActive();
        if not MonitoredJobRefreshActive then begin
            CheckRequiredPermissions();
            Clear(JobQueueEntryOut);
            OnBeforeInitRecurringJobQueueEntry(Parameters, JobQueueEntryOut, Success, Handled);
            if Handled then
                exit(Success);

            if JobQueueEntryExists(Parameters, JobQueueEntryOut) then begin
                UpdateJobQueueEntry(Parameters, JobQueueEntryOut);
                exit(true);
            end;
        end;

        JobQueueEntry.Init();
        JobQueueEntry.Validate("Object Type to Run", Parameters."Object Type to Run");
        JobQueueEntry.Validate("Object ID to Run", Parameters."Object ID to Run");
        JobQueueEntry."Record ID to Process" := Parameters."Record ID to Process";
        JobQueueEntry."Earliest Start Date/Time" := Parameters."Earliest Start Date/Time";
        SetJobQueueEntryParams(Parameters, JobQueueEntry);
        JobQueueEntry."Notify On Success" := Parameters."Notify On Success";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        if Parameters.Description <> '' then
            JobQueueEntry.Description := Parameters.Description;
        JobQueueEntry."Job Queue Category Code" := Parameters."Job Queue Category Code";
        JobQueueEntry."NPR Auto-Resched. after Error" := Parameters."NPR Auto-Resched. after Error";
        JobQueueEntry."NPR Auto-Resched. Delay (sec.)" := Parameters."NPR Auto-Resched. Delay (sec.)";
        JobQueueEntry."NPR Notif. Profile on Error" := Parameters."NPR Notif. Profile on Error";

        OnBeforeInsertRecurringJobQueueEntry(JobQueueEntry);
        if not MonitoredJobRefreshActive then
            JobQueueEntry.Insert(true);

        JobQueueEntryOut := JobQueueEntry;
        exit(true);
    end;

    local procedure UpdateJobQueueEntry(Parameters: Record "Job Queue Entry"; var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        xJobQueueEntry: Record "Job Queue Entry";
    begin
        xJobQueueEntry := JobQueueEntry;
        SetJobQueueEntryParams(Parameters, JobQueueEntry);
        OnBeforeModifyUpdatedJobQueueEntry(JobQueueEntry);
        if Format(xJobQueueEntry) = Format(JobQueueEntry) then
            exit(false);
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Modify(true);
        exit(true);
    end;

    local procedure SetJobQueueEntryParams(Parameters: Record "Job Queue Entry"; var JobQueueEntry: Record "Job Queue Entry")
    begin
        if Format(Parameters."Next Run Date Formula") <> '' then
            JobQueueEntry.Validate("Next Run Date Formula", Parameters."Next Run Date Formula")
        else begin
            JobQueueEntry."Run on Mondays" := Parameters."Run on Mondays";
            JobQueueEntry."Run on Tuesdays" := Parameters."Run on Tuesdays";
            JobQueueEntry."Run on Wednesdays" := Parameters."Run on Wednesdays";
            JobQueueEntry."Run on Thursdays" := Parameters."Run on Thursdays";
            JobQueueEntry."Run on Fridays" := Parameters."Run on Fridays";
            JobQueueEntry."Run on Saturdays" := Parameters."Run on Saturdays";
            JobQueueEntry."Run on Sundays" := Parameters."Run on Sundays";
            JobQueueEntry.Validate("No. of Minutes between Runs", Parameters."No. of Minutes between Runs");
        end;
        if JobQueueEntry."Recurring Job" then begin
            if (Parameters."Starting Time" <> 0T) and (JobQueueEntry."Starting Time" <> Parameters."Starting Time") then
                JobQueueEntry.Validate("Starting Time", Parameters."Starting Time");
            if (Parameters."Ending Time" <> 0T) and (JobQueueEntry."Ending Time" <> Parameters."Ending Time") then
                JobQueueEntry."Ending Time" := Parameters."Ending Time";
        end;
        JobQueueEntry."Maximum No. of Attempts to Run" := Parameters."Maximum No. of Attempts to Run";
        if JobQueueEntry."Maximum No. of Attempts to Run" <= 0 then
            JobQueueEntry."Maximum No. of Attempts to Run" := 5;
        JobQueueEntry."Rerun Delay (sec.)" := Parameters."Rerun Delay (sec.)";
        if JobQueueEntry."Rerun Delay (sec.)" <= 0 then
            JobQueueEntry."Rerun Delay (sec.)" := 180;
        if JobQueueEntry."Parameter String" <> Parameters."Parameter String" then
            JobQueueEntry.Validate("Parameter String", Parameters."Parameter String");
#IF NOT BC17
        if Parameters."Job Timeout" <> 0 then
            JobQueueEntry."Job Timeout" := Parameters."Job Timeout";
#ENDIF
    end;

    procedure JobQueueEntryExists(Parameters: Record "Job Queue Entry"; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SelectLatestVersion();
        JobQueueEntry.LockTable(true);
        JobQueueEntry.SetRange("Object Type to Run", Parameters."Object Type to Run");
        JobQueueEntry.SetRange("Object ID to Run", Parameters."Object ID to Run");
        JobQueueEntry.SetRange("Parameter String", Parameters."Parameter String");
        JobQueueEntry.SetRange("Job Queue Category Code", Parameters."Job Queue Category Code");
        if Format(Parameters."Record ID to Process") <> '' then
            JobQueueEntry.SetFilter("Record ID to Process", Format(Parameters."Record ID to Process"));
        if JobQueueEntry.IsEmpty() then begin
            JobQueueEntry.SetRange("Job Queue Category Code");
            if JobQueueEntry.IsEmpty() then
                exit(false);
        end;
        JobQueueEntry.Find('-');
        repeat
            if not JobQueueEntry.IsExpired(Parameters."Earliest Start Date/Time") then begin
                JobQueueEntryOut := JobQueueEntry;
                JobQueueEntryOut.Mark(true);
                exit(true);
            end;
        until JobQueueEntry.Next() = 0;
        exit(false);
    end;

    procedure StartJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        ActivateJobQueueEntry(JobQueueEntry);
    end;

    procedure StartJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; NotBeforeDateTime: DateTime)
    begin
        ActivateJobQueueEntry(JobQueueEntry, NotBeforeDateTime);
    end;

    internal procedure ActivateJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        exit(ActivateJobQueueEntry(JobQueueEntry, NextDueRunDateTime(JobQueueEntry)));
    end;

    internal procedure ActivateJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; NotBeforeDateTime: DateTime) Activated: Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        ValidStartDT: Boolean;
    begin
        if IsMonitoredJobRefreshRoutineActive() then begin
            MonitoredJobQueueMgt.AddMonitoredJobQueueEntry(JobQueueEntry);
            exit;
        end;

        Activated := false;
        if not TaskScheduler.CanCreateTask() then
            exit;
        case JobQueueEntry.Status of
            JobQueueEntry.Status::"In Process":
                if not IsStale(JobQueueEntry) then
                    exit;
            JobQueueEntry.Status::"On Hold":
                if JobQueueEntry."NPR Manually Set On Hold" then
                    exit;
        end;
        if EnvironmentInformation.IsSaaS() then
            if GetCurrentModuleExecutionContext() <> ExecutionContext::Normal then
                exit;

        ValidStartDT := HasValidStartDT(JobQueueEntry, NotBeforeDateTime);
        if ValidStartDT and (JobQueueEntry.Status = JobQueueEntry.Status::Ready) then
            if not IsStale(JobQueueEntry) then
                exit;

        if not ValidStartDT then begin
            JobQueueEntry.LockTable();
            JobQueueEntry.Get(JobQueueEntry.ID);
            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
            JobQueueEntry."Earliest Start Date/Time" := NotBeforeDateTime;
            JobQueueEntry.Modify();
        end;
        JobQueueEntry.Restart();
        Activated := true;
    end;

    internal procedure CancelNpManagedJobs(ObjectTypeToRun: Option; ObjectIdToRun: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not JobQueueEntry.FindJobQueueEntry(ObjectTypeToRun, ObjectIdToRun) then
            exit;
        CancelNpManagedJobs(JobQueueEntry);
    end;

    internal procedure CancelNpManagedJobs(ObjectTypeToRun: Option; ObjectIdToRun: Integer; RecID: RecordId)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", ObjectTypeToRun);
        JobQueueEntry.SetRange("Object ID to Run", ObjectIdToRun);
        JobQueueEntry.SetRange("Record ID to Process", RecID);
        if JobQueueEntry.IsEmpty() then
            exit;
        CancelNpManagedJobs(JobQueueEntry);
    end;

    internal procedure CancelNpManagedJobs(var JobQueueEntry: Record "Job Queue Entry")
    var
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        JobQueueEntry.FindSet(true);
        repeat
            JobQueueEntry.Cancel();
            MonitoredJobQueueMgt.RemoveMonitoredJobQueueEntry(JobQueueEntry);
        until JobQueueEntry.Next() = 0;
    end;

    local procedure HasValidStartDT(JobQueueEntry: Record "Job Queue Entry"; NotBeforeDateTime: DateTime): Boolean
    var
        NextRunDateTimeIfFinishedNow: DateTime;
    begin
        NextRunDateTimeIfFinishedNow := RoundDateTime(CalcNextRunDateTimeForNPRecurringJob(JobQueueEntry, CurrentDateTime(), false), 60000, '>');
        if NotBeforeDateTime > NextRunDateTimeIfFinishedNow then
            NextRunDateTimeIfFinishedNow := RoundDateTime(NotBeforeDateTime, 60000, '>');

        exit(
            (JobQueueEntry."Earliest Start Date/Time" <> 0DT) and
            (JobQueueEntry."Earliest Start Date/Time" <= NextRunDateTimeIfFinishedNow) and
            (JobQueueEntry."Earliest Start Date/Time" >= RoundDateTime(NotBeforeDateTime, 60000, '<')));
    end;

    local procedure CheckRequiredPermissions()
    var
        ErrorMessage: Record "Error Message";
        ErrorMessageRegister: Record "Error Message Register";
        JobQueueLogEntry: Record "Job Queue Log Entry";
        NoPermissionsErr: Label 'You are not allowed to schedule background tasks. Ask your system administrator to give you permission to do so. Specifically, you need at least indirect Insert, Modify and Delete Permissions for the %1 table.', Comment = '%1 Table Name';
    begin
        if not JobQueueLogEntry.WritePermission() then
            Error(NoPermissionsErr, JobQueueLogEntry.TableName());

        if not ErrorMessageRegister.WritePermission() then
            Error(NoPermissionsErr, ErrorMessageRegister.TableName());

        if not ErrorMessage.WritePermission() then
            Error(NoPermissionsErr, ErrorMessage.TableName());
    end;

    procedure NowWithDelayInSeconds(NoOfSeconds: Integer): DateTime
    begin
        exit(CurrentDateTime() + NoOfSeconds * 1000);
    end;

    procedure DaysToDuration(NoOfDays: Integer): Duration
    begin
        exit(NoOfDays * 86400000);
    end;

    internal procedure HoursToDuration(NoOfHours: Integer): Duration
    begin
        exit(MinutesToDuration(NoOfHours * 60));
    end;

    internal procedure MinutesToDuration(NoOfMinutes: Integer): Duration
    begin
        exit(NoOfMinutes * 60000);
    end;

    internal procedure GetAutoRecreateNoteTxt(): Text
    var
        AutoRecreateNoteLbl: Label 'Auto-created for %1. Can be deleted if not used. Will be recreated when the feature is activated.', Comment = '%1 = initial description of Job Queue Entry';
    begin
        exit(AutoRecreateNoteLbl);
    end;

    internal procedure SetShowAutoCreatedClause(Set: Boolean)
    begin
        ShowAutoCreatedClause := Set;
    end;

    internal procedure AddPosItemPostingJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDescrLbl: Label 'POS Item posting', MaxLength = 250;
    begin
        SetJobTimeout(4, 0);  //4 hours

        if InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR POS Post Item Entries JQ",
            '',
            JobQueueDescrLbl,
            NowWithDelayInSeconds(360),
            1,
            CreateAndAssignJobQueueCategory(),
            JobQueueEntry)
        then
            StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure AddPosPostingJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NextRunDateFormula: DateFormula;
        JobQueueDescrLbl: Label 'POS posting', MaxLength = 250;
    begin
        Evaluate(NextRunDateFormula, '<1D>');
        SetJobTimeout(4, 0);  //4 hours
        SetAutoRescheduleAndNotifyOnError(true, 2700, '');  //Reschedule to run again in 45 minutes on error

        if InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::codeunit,
            Codeunit::"NPR POS Post GL Entries JQ",
            '',
            JobQueueDescrLbl,
            NowWithDelayInSeconds(360),
            230000T,
            235959T,
            NextRunDateFormula,
            CreateAndAssignJobQueueCategory(),
            JobQueueEntry)
        then
            StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure AddPosSaleDocumentPostingJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDescrLbl: Label 'POS Sale Document posting', MaxLength = 250;
    begin
        SetJobTimeout(4, 0);  //4 hours

        if InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Post Sales Documents JQ",
            '',
            JobQueueDescrLbl,
            NowWithDelayInSeconds(360),
            1,
            CreateAndAssignJobQueueCategory(),
            JobQueueEntry)
        then
            StartJobQueueEntry(JobQueueEntry);
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    internal procedure AddEventBillingSenderJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueDescrLbl: Label 'Transfer Billing Events', MaxLength = 250;
    begin
        SetJobTimeout(0, 15);

        if InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Billing Data Sender JQ",
            '',
            JobQueueDescrLbl,
            NowWithDelayInSeconds(360),
            60,
            CreateAndAssignEventBillingJobQueueCategory(),
            JobQueueEntry)
        then
            StartJobQueueEntry(JobQueueEntry);
    end;
#endif

    local procedure RefreshRetentionPolicyJQ()
    var
        JobQueueEntry: Record "Job Queue Entry";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
        RetentionPolicySetup: Codeunit "Retention Policy Setup";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
        NextRunDateFormula: DateFormula;
#ENDIF
        AlreadyExists: Boolean;
        ReadyToStart: Boolean;
        JobQueueActivatedNotificationTxt: Label 'A Job Queue Entry to apply the retention policies has been scheduled to run.';
        JobQueueDeactivatedNotificationTxt: Label 'A Job Queue Entry to apply the retention policies was set to On-Hold state.';
        JobQueueReadyNotificationTxt: Label 'A Job Queue Entry to apply the retention policies was set to Ready state.';
    begin
        AlreadyExists := JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, 3997);  //3997 = Codeunit::"Retention Policy JQ"

        if not RetentionPolicySetup.IsRetentionPolicyEnabled() then begin
            if AlreadyExists then
                if JobQueueEntry.Status <> JobQueueEntry.Status::"On Hold" then begin
                    JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
                    JobQueueEntry.Modify();
                    RetentionPolicyLog.LogInfo(RetentionPolicyLogCategory::"Retention Policy - Schedule", JobQueueDeactivatedNotificationTxt);
                end;
            exit;
        end;

        if AlreadyExists then
            ReadyToStart := JobQueueEntry.IsReadyToStart();

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
        Evaluate(NextRunDateFormula, '<1D>');
#ENDIF
        SetJobTimeout(6, 0); // 6hr timeout
        if InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            3997,  //Codeunit::"Retention Policy JQ"
            '',
            '',
            NowWithDelayInSeconds(360),
            000000T,
            060000T,
#IF BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22
            2,
#ELSE
            NextRunDateFormula,
#ENDIF
            CreateAndAssignRetentionPolicyJobQueueCategory(),
            JobQueueEntry)
        then
            if ActivateJobQueueEntry(JobQueueEntry) then
                if AlreadyExists then begin
                    if not ReadyToStart then
                        RetentionPolicyLog.LogInfo(RetentionPolicyLogCategory::"Retention Policy - Schedule", JobQueueReadyNotificationTxt);
                end else
                    RetentionPolicyLog.LogInfo(RetentionPolicyLogCategory::"Retention Policy - Schedule", JobQueueActivatedNotificationTxt);
    end;

    internal procedure ScheduleFeatureFlagReport()
    var
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if FeatureFlagsManagement.GetFeatureFlagsJobQueueEntry(JobQueueEntry, '') then begin
            StartJobQueueEntry(JobQueueEntry);
            exit;
        end;

        FeatureFlagsManagement.ScheduleGetFeatureFlagsIntegration();
    end;

    internal procedure RefreshNPRJobQueueList(CallRefreshProcedure: Boolean; SetUserFilter: Boolean)
    var
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        if not SkipUpdateNPManagedMonitoredJobs() then begin
            BindSubscription(MonitoredJobQueueMgt);
            OnRefreshNPRJobQueueList();  //update monitored jobs
            if UnBindSubscription(MonitoredJobQueueMgt) then;
        end;
        if CallRefreshProcedure then
            RefreshJobQueues(SetUserFilter);  //loop through monitored jobs and create job queue entries if needed
    end;

    internal procedure SkipUpdateNPManagedMonitoredJobs() Skip: Boolean
    var
        Handled: Boolean;
    begin
        OnBeforeUpdateNPMonitoredJobs(Skip, Handled);
    end;

    internal procedure CreateAndAssignJobQueueCategory(): Code[10]
    var
        SalesSetup: Record "Sales & Receivables Setup";
        JobQueueCategory: Record "Job Queue Category";
        JobQueueCatDescrLbl: Label 'Posting related tasks', MaxLength = 30;
    begin
        if not SalesSetup.Get() then begin
            SalesSetup.Init();
            SalesSetup.Insert();
        end;
        if SalesSetup."Job Queue Category Code" = '' then begin
            JobQueueCategory.InsertRec('NPR-POST', JobQueueCatDescrLbl);
            SalesSetup."Job Queue Category Code" := JobQueueCategory.Code;
            SalesSetup.Modify();
        end;
        exit(SalesSetup."Job Queue Category Code");
    end;

    local procedure CreateAndAssignRetentionPolicyJobQueueCategory(): Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueCategoryDescTxt: Label 'Retention Policies', MaxLength = 30;
        JobQueueCategoryTok: Label 'RETENTION', Locked = true, MaxLength = 10;
    begin
        if not JobQueueCategory.Get(JobQueueCategoryTok) then
            JobQueueCategory.InsertRec(JobQueueCategoryTok, JobQueueCategoryDescTxt);
        exit(JobQueueCategory.Code);
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    internal procedure CreateAndAssignEventBillingJobQueueCategory(): Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueCategoryDescTxt: Label 'Event billing related tasks', MaxLength = 30;
        JobQueueCategoryTok: Label 'NPR-BILL', Locked = true, MaxLength = 10;
    begin
        if not JobQueueCategory.Get(JobQueueCategoryTok) then
            JobQueueCategory.InsertRec(JobQueueCategoryTok, JobQueueCategoryDescTxt);
        exit(JobQueueCategory.Code);
    end;
#endif

    local procedure EmitTelemetryDataOnError(JobQueueLogEntry: Record "Job Queue Log Entry")
    var
        ActiveSession: Record "Active Session";
        ErrorMessage: Record "Error Message";
        NprEnvironment: Record "NPR Environment Information";
        EnvTypeOrdinalValue, EnvTypeIndex : Integer;
        EnvTypeName: Text;
        TypeHelper: Codeunit "Type Helper";
        CustomDimensions: Dictionary of [Text, Text];
        ErrorMessageText: Text;
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        if (not (NprEnvironment.Get())) then
            NprEnvironment.Init();

        EnvTypeOrdinalValue := NprEnvironment."Environment Type".AsInteger();
        EnvTypeIndex := NprEnvironment."Environment Type".Ordinals.IndexOf(EnvTypeOrdinalValue);
        EnvTypeName := NprEnvironment."Environment Type".Names.Get(EnvTypeIndex);

        JobQueueLogEntry.CalcFields("Object Caption to Run");
        ErrorMessage.SetRange("Register ID", JobQueueLogEntry."Error Message Register Id");
        if not ErrorMessage.FindSet() then
            ErrorMessageText := JobQueueLogEntry."Error Message"
        else
            repeat
                if ErrorMessageText <> '' then
                    ErrorMessageText := ErrorMessageText + TypeHelper.CRLFSeparator();
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
                ErrorMessageText := ErrorMessageText + ErrorMessage.Message;
#ELSE
                ErrorMessageText := ErrorMessageText + ErrorMessage.Description;
#ENDIF
            until ErrorMessage.Next() = 0;

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
        CustomDimensions.Add('NPR_EnvironmentType', EnvTypeName);
        CustomDimensions.Add('NPR_UserID', UserId);
        CustomDimensions.Add('NPR_ClientComputerName', ActiveSession."Client Computer Name");

        CustomDimensions.Add('NPR_JQ_Id', JobQueueLogEntry.ID);
        CustomDimensions.Add('NPR_JQ_LogEntrySystemId', JobQueueLogEntry.SystemId);
        CustomDimensions.Add('NPR_JQ_ObjectType', Format(JobQueueLogEntry."Object Type to Run"));
        CustomDimensions.Add('NPR_JQ_ObjectId', Format(JobQueueLogEntry."Object ID to Run"));
        CustomDimensions.Add('NPR_JQ_ObjectCaption', JobQueueLogEntry."Object Caption to Run");
        CustomDimensions.Add('NPR_JQ_Parameters', JobQueueLogEntry."Parameter String");
        CustomDimensions.Add('NPR_JQ_CategoryCode', JobQueueLogEntry."Job Queue Category Code");
        CustomDimensions.Add('NPR_JQ_ErrorText', ErrorMessageText);
        CustomDimensions.Add('NPR_JQ_CallStack', JobQueueLogEntry.GetErrorCallStack());
        CustomDimensions.Add('NPR_JQ_ExecutionStartedAt', Format(JobQueueLogEntry."Start Date/Time", 0, 9));
        CustomDimensions.Add('NPR_JQ_ExecutionEndedAt', Format(JobQueueLogEntry."End Date/Time", 0, 9));
        CustomDimensions.Add('NPR_JQ_ExecutionDuration', Format(JobQueueLogEntry.Duration(), 0, 9));
        CustomDimensions.Add('NPR_JQ_ExecutionStartedBy', JobQueueLogEntry."User ID");

        Session.LogMessage('NPR_JobQueue', 'Job Queue Error', Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    internal procedure AutoRestartRetentionPolicyJQ(var JobQueueEntry: Record "Job Queue Entry")
    begin
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = 3997)  //Codeunit::"Retention Policy JQ"
        then begin
            JobQueueEntry."NPR Auto-Resched. after Error" := true;
            JobQueueEntry."Maximum No. of Attempts to Run" := 1000;
            JobQueueEntry."Rerun Delay (sec.)" := 60;
            if JobQueueEntry."NPR Auto-Resched. Delay (sec.)" < 60 then
                JobQueueEntry."NPR Auto-Resched. Delay (sec.)" := 60;
        end;
    end;

    internal procedure UpdateRetentionPolicyJQRecurrence(var JobQueueEntry: Record "Job Queue Entry")
    var
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22)
        NextRunDateFormula: DateFormula;
#ENDIF
    begin
        if JobQueueEntry."Recurring Job" and
           (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and (JobQueueEntry."Object ID to Run" = 3997)  //Codeunit::"Retention Policy JQ"
        then begin
#IF NOT BC17
            JobQueueEntry."Job Timeout" := 6 * 60 * 60 * 1000;  //6 hours
#ENDIF
#IF BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22
            Clear(JobQueueEntry."Next Run Date Formula");
            JobQueueEntry."Run on Mondays" := true;
            JobQueueEntry."Run on Tuesdays" := true;
            JobQueueEntry."Run on Wednesdays" := true;
            JobQueueEntry."Run on Thursdays" := true;
            JobQueueEntry."Run on Fridays" := true;
            JobQueueEntry."Run on Saturdays" := true;
            JobQueueEntry."Run on Sundays" := true;
            JobQueueEntry.Validate("No. of Minutes between Runs", 2);
            JobQueueEntry.Validate("Starting Time", 000000T);
            JobQueueEntry."Ending Time" := 060000T;
#ELSE
            Evaluate(NextRunDateFormula, '<1D>');
            JobQueueEntry.Validate("Starting Time", 000000T);
            JobQueueEntry."Ending Time" := 060000T;
            JobQueueEntry.Validate("Next Run Date Formula", NextRunDateFormula);
#ENDIF
        end;
    end;

    local procedure GetEndingTime(StartTime: Time; EndTime: Time): Time
    begin
        if EndTime <> 0T then
            exit(EndTime);

        if StartTime <> 0T then
            exit(StartTime + 2 * 60 * 60 * 1000);   //2 hours

        exit(0T);
    end;

    procedure SetJobTimeout(NoOfHours: Integer; NoOfMinutes: Integer)
    begin
        SetJobTimeout(NoOfHours * 60 * 60 * 1000 + NoOfMinutes * 60 * 1000);
    end;

    procedure SetJobTimeout(NewTimeout: Duration)
    begin
        JobTimeout := NewTimeout;
    end;

    procedure SetAutoRescheduleAndNotifyOnError(AutoReschedule: Boolean; AutoRescheduleDelaySec: Integer; NotifProfileCode: Code[20])
    begin
        AutoRescheduleOnError := AutoReschedule;
        AutoRescheduleOnErrorDelaySec := AutoRescheduleDelaySec;
        NotifProfileCodeOnError := NotifProfileCode;
    end;

    procedure SetMaxNoOfAttemptsToRun(NoOfAttempts: Integer)
    begin
        MaxNoOfAttemptsToRun := NoOfAttempts;
    end;

    procedure SetRerunDelay(DelaySec: Integer)
    begin
        RerunDelaySec := DelaySec;
    end;

    [TryFunction]
    internal procedure SendHeartbeat(JobQueueEntry: Record "Job Queue Entry")
    var
        HttpClient: HttpClient;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
    begin
        HttpRequestMessage.SetRequestUri(JobQueueEntry."NPR Heartbeat URL");
        HttpRequestMessage.Method := 'POST';
        HttpClient.Timeout(5000);
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
    end;

    local procedure ClearAdditionalParams()
    begin
        Clear(JobTimeout);
        Clear(AutoRescheduleOnError);
        Clear(AutoRescheduleOnErrorDelaySec);
        Clear(NotifProfileCodeOnError);
        Clear(MaxNoOfAttemptsToRun);
        Clear(RerunDelaySec);
    end;

    local procedure NextDueRunDateTime(JobQueueEntry: Record "Job Queue Entry"): DateTime
    var
        JobQueueDispatcher: Codeunit "Job Queue Dispatcher";
    begin
        if not JobQueueEntry."Recurring Job" then begin
            if JobQueueEntry."Earliest Start Date/Time" <> 0DT then
                exit(JobQueueEntry."Earliest Start Date/Time");
            exit(CurrentDateTime());
        end;
        exit(JobQueueDispatcher.CalcNextRunTimeForRecurringJob(JobQueueEntry, LastSuccessfulRunDateTime(JobQueueEntry)));
    end;

    local procedure LastSuccessfulRunDateTime(JobQueueEntry: Record "Job Queue Entry"): DateTime
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        JobQueueLogEntry.SetCurrentKey(ID, Status);
        JobQueueLogEntry.SetRange(ID, JobQueueEntry.ID);
        JobQueueLogEntry.SetRange(Status, JobQueueLogEntry.Status::Success);
        JobQueueLogEntry.SetLoadFields("Start Date/Time", "End Date/Time");
        if JobQueueLogEntry.FindLast() then
            if JobQueueLogEntry."End Date/Time" <> 0DT then
                exit(JobQueueLogEntry."End Date/Time")
            else
                exit(JobQueueLogEntry."Start Date/Time");

        exit(HasNeverBeenRunDT());
    end;

    local procedure CalcNextRunDateTimeForNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; StartingDateTime: DateTime; AdjustForRunWindowOnly: Boolean) NewRunDateTime: DateTime
    var
        RunWindowDate: Date;
        RunWindowStartDT: DateTime;
        RunWindowEndDT: DateTime;
        TimeZoneAdjmt: Duration;
    begin
        if StartingDateTime in [0DT, HasNeverBeenRunDT()] then begin
            if JobQueueEntry."Earliest Start Date/Time" <> 0DT then
                StartingDateTime := JobQueueEntry."Earliest Start Date/Time"
            else
                StartingDateTime := CurrentDateTime();
            AdjustForRunWindowOnly := true;
        end;
        NewRunDateTime := StartingDateTime;
        if not JobQueueEntry."Recurring Job" then
            exit;

        if JobQueueEntry."Starting Time" <> 0T then begin
            if JobQueueEntry."Reference Starting Time" = 0DT then
                JobQueueEntry.Validate("Starting Time");
            if JobQueueEntry."Reference Starting Time" <> 0DT then
                TimeZoneAdjmt := CreateDateTime(DMY2Date(1, 1, 2000), JobQueueEntry."Starting Time") - JobQueueEntry."Reference Starting Time";
        end;

        if not AdjustForRunWindowOnly then
            case true of
                Format(JobQueueEntry."Next Run Date Formula") <> '':
                    NewRunDateTime := CreateDateTime(CalcDate(JobQueueEntry."Next Run Date Formula", DT2Date(StartingDateTime)), DT2Time(JobQueueEntry."Reference Starting Time"));
                JobQueueEntry."No. of Minutes between Runs" > 0:
                    NewRunDateTime := StartingDateTime + MinutesToDuration(JobQueueEntry."No. of Minutes between Runs");
                else
                    NewRunDateTime := CreateDateTime(DT2Date(StartingDateTime) + 1, DT2Time(JobQueueEntry."Reference Starting Time"));
            end;

        if NewRunDateTime > CurrentDateTime() then
            RunWindowDate := DT2Date(NewRunDateTime)
        else
            RunWindowDate := Today();

        RunWindowStartDT := CreateDateTime(RunWindowDate, DT2Time(JobQueueEntry."Reference Starting Time"));
        if (JobQueueEntry."Starting Time" <> 0T) and (JobQueueEntry."Ending Time" <> 0T) and (JobQueueEntry."Ending Time" < JobQueueEntry."Starting Time") then
            RunWindowStartDT := RunWindowStartDT - DaysToDuration(1);

        if JobQueueEntry."Ending Time" <> 0T then
            RunWindowEndDT := CreateDateTime(RunWindowDate, JobQueueEntry."Ending Time") - TimeZoneAdjmt;
        if (RunWindowEndDT <> 0DT) and (NewRunDateTime > RunWindowEndDT) then begin
            RunWindowStartDT := RunWindowStartDT + DaysToDuration(1);
            RunWindowEndDT := RunWindowEndDT + DaysToDuration(1);
        end;

        if NewRunDateTime < RunWindowStartDT then
            NewRunDateTime := RunWindowStartDT;

        if Format(JobQueueEntry."Next Run Date Formula") <> '' then
            exit;
        NewRunDateTime := CalcRunTimeForRecurringJob(JobQueueEntry, NewRunDateTime);
    end;

    local procedure CalcRunTimeForRecurringJob(JobQueueEntry: Record "Job Queue Entry"; StartingDateTime: DateTime) NewRunDateTime: DateTime
    var
        RunOnDate: array[7] of Boolean;
        NoOfDays: Integer;
        StartingWeekDay: Integer;
        Found: Boolean;
    begin
        JobQueueEntry.TestField("Recurring Job");
        RunOnDate[1] := JobQueueEntry."Run on Mondays";
        RunOnDate[2] := JobQueueEntry."Run on Tuesdays";
        RunOnDate[3] := JobQueueEntry."Run on Wednesdays";
        RunOnDate[4] := JobQueueEntry."Run on Thursdays";
        RunOnDate[5] := JobQueueEntry."Run on Fridays";
        RunOnDate[6] := JobQueueEntry."Run on Saturdays";
        RunOnDate[7] := JobQueueEntry."Run on Sundays";
        NewRunDateTime := StartingDateTime;
        NoOfDays := 0;

        StartingWeekDay := Date2DWY(DT2Date(StartingDateTime), 1);
        Found := RunOnDate[(StartingWeekDay - 1 + NoOfDays) mod 7 + 1];
        while not Found and (NoOfDays < 7) do begin
            NoOfDays := NoOfDays + 1;
            Found := RunOnDate[(StartingWeekDay - 1 + NoOfDays) mod 7 + 1];
        end;
        if Found then
            NewRunDateTime := NewRunDateTime + DaysToDuration(NoOfDays);
    end;

    internal procedure IsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        IsNpJob: Boolean;
        Handled: Boolean;
    begin
        OnCheckIfIsNPRecurringJob(JobQueueEntry, IsNpJob, Handled);
        exit(IsNpJob);
    end;

    local procedure HasNeverBeenRunDT(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(1, 1, 2000), 0T));
    end;

    local procedure IsStale(JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        exit(not TaskScheduler.TaskExists(JobQueueEntry."System Task ID"));
    end;

    internal procedure SetStoreCode(NewStoreCode: Code[20])
    begin
        StoreCode := NewStoreCode;
    end;

    internal procedure JobQueueIsManagedByApp(JobQueueEntry: Record "Job Queue Entry"; var RefreshingCanBeToggled: Boolean) Managed: Boolean
    var
        ManagedByAppJQ: Record "NPR Managed By App Job Queue";
        Handled: Boolean;
    begin
        OnBeforeJobQueueIsManagedByApp(JobQueueEntry, Managed, Handled);
        if Handled then begin
            RefreshingCanBeToggled := false;
            exit;
        end;

        if not SkipUpdateNPManagedMonitoredJobs() then begin
            OnCheckIfIsNPRecurringJob(JobQueueEntry, Managed, Handled);
            RefreshingCanBeToggled := not Handled;
            if Handled then
                exit;
        end;

        RefreshingCanBeToggled := true;
        Managed := ManagedByAppJQ.Get(JobQueueEntry.ID) and ManagedByAppJQ."Managed by App";
    end;

    local procedure IsMonitoredJobRefreshRoutineActive() Result: Boolean
    var
        Handled: Boolean;
    begin
        IsInMonitoredJobUpdate(Result, Handled);
    end;

    local procedure RefreshJobQueues(SetUserFilter: Boolean)
    var
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        MonitoredJobQueueMgt.RefreshJobQueueEntries(SetUserFilter);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", 'OnBeforeCalcNextRunTimeForRecurringJob', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", OnBeforeCalcNextRunTimeForRecurringJob, '', true, false)]
#endif
    local procedure NPCalcNextRunDateTimeForRecurringJob(JobQueueEntry: Record "Job Queue Entry"; StartingDateTime: DateTime; var NewRunDateTime: DateTime; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        If not IsNPRecurringJob(JobQueueEntry) then
            exit;
        IsHandled := true;
        NewRunDateTime := CalcNextRunDateTimeForNPRecurringJob(JobQueueEntry, StartingDateTime, false);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", 'OnCalcInitialRunTimeOnAfterCalcEarliestPossibleRunTime', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", OnCalcInitialRunTimeOnAfterCalcEarliestPossibleRunTime, '', true, false)]
#endif
    local procedure NPCalcInitialRunTimeOnAfterCalcEarliestPossibleRunTime(var JobQueueEntry: Record "Job Queue Entry"; var EarliestPossibleRunTime: DateTime; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        If not IsNPRecurringJob(JobQueueEntry) then
            exit;
        IsHandled := true;
        EarliestPossibleRunTime := CalcNextRunDateTimeForNPRecurringJob(JobQueueEntry, EarliestPossibleRunTime, true);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", 'OnBeforeEnqueueJobQueueEntry', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", OnBeforeEnqueueJobQueueEntry, '', true, false)]
#endif
    local procedure SetDefaultValues(var JobQueueEntry: Record "Job Queue Entry")
    begin
        if JobQueueEntry."Maximum No. of Attempts to Run" = 3 then  //3 - default value in MS standard application
            JobQueueEntry."Maximum No. of Attempts to Run" := 5;
        if (JobQueueEntry."Rerun Delay (sec.)" <= 0) or (JobQueueEntry."Rerun Delay (sec.)" = 60) then  //60 - default value in MS standard application
            JobQueueEntry."Rerun Delay (sec.)" := 180;

        AutoRestartRetentionPolicyJQ(JobQueueEntry);
        UpdateRetentionPolicyJQRecurrence(JobQueueEntry);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnBeforeModifyUpdatedJobQueueEntry', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeModifyUpdatedJobQueueEntry, '', true, false)]
#endif
    local procedure SetDefaultValuesOnBeforeModifyUpdatedJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        AutoRestartRetentionPolicyJQ(JobQueueEntry);
        UpdateRetentionPolicyJQRecurrence(JobQueueEntry);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterFinalizeRun', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", OnAfterFinalizeRun, '', true, false)]
#endif
    local procedure RescheduleAfterError(JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueSendNotif: Codeunit "NPR Job Queue - Send Notif.";
    begin
        if JobQueueEntry.IsTemporary() then
            exit;
        if JobQueueEntry.Status <> JobQueueEntry.Status::Error then
            exit;

        if (JobQueueEntry."NPR Notif. Profile on Error" = '') and not JobQueueEntry."NPR Auto-Resched. after Error" then
            exit;

        Commit();

        if JobQueueEntry."NPR Notif. Profile on Error" <> '' then
            JobQueueSendNotif.SendNotifications(JobQueueEntry, JobQueueSendNotif);

        if JobQueueEntry."NPR Auto-Resched. after Error" then begin
            JobQueueEntry."Earliest Start Date/Time" := CalcNextRunDateTimeForNPRecurringJob(JobQueueEntry, NowWithDelayInSeconds(JobQueueEntry."NPR Auto-Resched. Delay (sec.)"), true);
            JobQueueEntry.Modify();
            JobQueueEntry.Restart();
        end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", 'OnBeforeEnqueueJobQueueEntry', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", OnBeforeEnqueueJobQueueEntry, '', true, false)]
#endif
    local procedure CheckScheduledStartDateTimeIsNotOutsideOfAllowedRunWindow(var JobQueueEntry: Record "Job Queue Entry")
    begin
        if not JobQueueEntry."Recurring Job" then
            exit;
        If not IsNPRecurringJob(JobQueueEntry) then
            exit;
        JobQueueEntry."Earliest Start Date/Time" := CalcNextRunDateTimeForNPRecurringJob(JobQueueEntry, JobQueueEntry."Earliest Start Date/Time", true);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyLogEntry', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", OnBeforeModifyLogEntry, '', true, false)]
#endif
    local procedure EmitTelemetry(var JobQueueLogEntry: Record "Job Queue Log Entry")
    begin
        if JobQueueLogEntry.IsTemporary() or (JobQueueLogEntry.Status <> JobQueueLogEntry.Status::Error) then
            exit;

        EmitTelemetryDataOnError(JobQueueLogEntry);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RunAddPosItemPostingJobQueue()
    begin
        AddPosItemPostingJobQueue();
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RunAddPosPostingJobQueue()
    begin
        AddPosPostingJobQueue();
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RunAddPosSaleDocumentPostingJobQueue()
    begin
        AddPosSaleDocumentPostingJobQueue();
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RunRefreshRetentionPolicyJQ()
    begin
        RefreshRetentionPolicyJQ();
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
    local procedure AddEventBillingSenderJobQueueOnRefresh()
    begin
        AddEventBillingSenderJobQueue();
    end;
#endif    

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RunScheduleFeatureFlagReport()
    begin
        ScheduleFeatureFlagReport();
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnCheckIfIsNPRecurringJob, '', false, false)]
#endif
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" in
               [Codeunit::"NPR POS Post Item Entries JQ",
                Codeunit::"NPR POS Post GL Entries JQ",
                Codeunit::"NPR Get Feature Flags JQ",
                Codeunit::"NPR Post Sales Documents JQ",
                3997  //3997 = Codeunit::"Retention Policy JQ"
               ])
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
    local procedure RunScheduleEventBillingSenderJQ()
    begin
        AddEventBillingSenderJobQueue();
    end;
#endif

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", OnCompanyInitialize, '', true, false)]
#endif
    local procedure HandleOnCompanyInitialize()
    begin
        InitJobQueueRefreshSetup();
    end;

    internal procedure InitJobQueueRefreshSetup()
    var
        JobQueueRefreshSetup: Record "NPR Job Queue Refresh Setup";
    begin
        if not JobQueueRefreshSetup.Get() then begin
            JobQueueRefreshSetup.Init();
            JobQueueRefreshSetup.Insert();
        end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeSetStatusValue', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", OnBeforeSetStatusValue, '', false, false)]
#endif
    local procedure HandleOnBeforeSetStatusValue(var JobQueueEntry: Record "Job Queue Entry"; var xJobQueueEntry: Record "Job Queue Entry"; var NewStatus: Option)
    begin
        if NewStatus <> JobQueueEntry.Status::"On Hold" then
            JobQueueEntry."NPR Manually Set On Hold" := false;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", 'OnAfterExecuteJob', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", OnAfterSuccessExecuteJob, '', false, false)]
#endif
    local procedure SendHeartbeatOnAfterSuccessExecuteJob(var JobQueueEntry: Record "Job Queue Entry")
    begin
        if (JobQueueEntry.Status <> JobQueueEntry.Status::Error) and (JobQueueEntry."NPR Heartbeat URL" <> '') then
            SendHeartbeat(JobQueueEntry);
    end;


    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleNcTaskProcessing(var JobQueueEntry: Record "Job Queue Entry"; TaskProcessorCode: Code[20]; var EnableTaskListUpdate: Boolean; var JobQueueCatagoryCode: Code[10]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnScheduleNcTaskProcessing_OnAfterInitParameterList(TaskProcessorCode: Code[20]; JobQueueCatagoryCode: Code[10]; var JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeScheduleNcImportListProcessing(var JobQueueEntry: Record "Job Queue Entry"; ImportTypeCode: Code[20]; var JobQueueCatagoryCode: Code[10]; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnScheduleNcImportListProcessing_OnAfterInitParameterList(ImportTypeCode: Code[20]; JobQueueCatagoryCode: Code[10]; var JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRecurringJobQueueEntry(Parameters: Record "Job Queue Entry"; var JobQueueEntryOut: Record "Job Queue Entry"; var Success: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertRecurringJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyUpdatedJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
    end;

#if (BC17 or BC18 or BC19)
    [IntegrationEvent(false, false)]
#else
    [IntegrationEvent(false, false, true)]  //isolated event
#endif
    local procedure OnRefreshNPRJobQueueList()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeJobQueueIsManagedByApp(JobQueueEntry: Record "Job Queue Entry"; var Managed: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure IsInMonitoredJobUpdate(var Result: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateNPMonitoredJobs(var Skip: Boolean; var Handled: Boolean)
    begin
    end;
}

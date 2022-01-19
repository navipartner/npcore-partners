codeunit 6014663 "NPR Job Queue Management"
{
    Permissions =
        tabledata "Error Message" = rimd,
        tabledata "Error Message Register" = rimd,
        tabledata "Job Queue Entry" = rimd;

    var
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
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
        if EnableTaskListUpdate then
            JQParamStrMgt.AddToParamDict(NcTaskListProcessing.ParamUpdateTaskList());
        JQParamStrMgt.AddToParamDict(NcTaskListProcessing.ParamProcessTaskList());
        JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, NcTaskListProcessing.ParamMaxRetry(), 3));
        OnScheduleNcTaskProcessing_OnAfterInitParameterList(TaskProcessorCode, JobQueueCatagoryCode, JQParamStrMgt);

        JobQueueDescription := StrSubstNo(JobQueueDescrLbl, TaskProcessorCode);
        if ShowAutoCreatedClause then
            JobQueueDescription := StrSubstNo(GetAutoRecreateNoteTxt(), JobQueueDescription);

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
            StartJobQueueEntry(JobQueueEntry, NotBeforeDateTime);
    end;

    procedure ScheduleNcTaskCountResetJob(var JobQueueEntry: Record "Job Queue Entry"; TaskProcessorCode: Code[20]; JobQueueCatagoryCode: Code[10])
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
            StartJobQueueEntry(JobQueueEntry, NotBeforeDateTime);
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
        Parameters."Ending Time" := EndingTime;
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
        Parameters."Notify On Success" := true;
        Parameters."Parameter String" := CopyStr(ParameterString, 1, MaxStrLen(Parameters."Parameter String"));
        Parameters.Description := CopyStr(JobDescription, 1, MaxStrLen(Parameters.Description));
        Parameters."Job Queue Category Code" := JobQueueCatagoryCode;

        exit(InitRecurringJobQueueEntry(Parameters, JobQueueEntryOut));
    end;

    procedure InitRecurringJobQueueEntry(Parameters: Record "Job Queue Entry"; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        Handled: Boolean;
        Success: Boolean;
    begin
        if not TaskScheduler.CanCreateTask() then
            exit;
        CheckRequiredPermissions();

        Clear(JobQueueEntryOut);
        OnBeforeInitRecurringJobQueueEntry(Parameters, JobQueueEntryOut, Success, Handled);
        if Handled then
            exit(Success);

        JobQueueEntry.LockTable(true);
        JobQueueEntry.SetRange("Object Type to Run", Parameters."Object Type to Run");
        JobQueueEntry.SetRange("Object ID to Run", Parameters."Object ID to Run");
        JobQueueEntry.SetRange("Parameter String", Parameters."Parameter String");
        JobQueueEntry.SetRange("Job Queue Category Code", Parameters."Job Queue Category Code");
        if Format(Parameters."Record ID to Process") <> '' then
            JobQueueEntry.SetFilter("Record ID to Process", Format(Parameters."Record ID to Process"));
        if JobQueueEntry.FindSet() then
            repeat
                if not JobQueueEntry.IsExpired(Parameters."Earliest Start Date/Time") then begin
                    JobQueueEntryOut := JobQueueEntry;
                    exit(true);
                end;
            until JobQueueEntry.Next() = 0;

        JobQueueEntry.Init();
        JobQueueEntry.Validate("Object Type to Run", Parameters."Object Type to Run");
        JobQueueEntry.Validate("Object ID to Run", Parameters."Object ID to Run");
        JobQueueEntry."Record ID to Process" := Parameters."Record ID to Process";
        JobQueueEntry."Earliest Start Date/Time" := Parameters."Earliest Start Date/Time";
        if Format(Parameters."Next Run Date Formula") <> '' then
            JobQueueEntry.Validate("Next Run Date Formula", Parameters."Next Run Date Formula")
        else
            if Parameters."No. of Minutes between Runs" <> 0 then begin
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
            if Parameters."Starting Time" <> 0T then
                JobQueueEntry.Validate("Starting Time", Parameters."Starting Time");
            if Parameters."Ending Time" <> 0T then
                JobQueueEntry."Ending Time" := Parameters."Ending Time";
        end;
        JobQueueEntry."Maximum No. of Attempts to Run" := Parameters."Maximum No. of Attempts to Run";
        if JobQueueEntry."Maximum No. of Attempts to Run" <= 0 then
            JobQueueEntry."Maximum No. of Attempts to Run" := 5;
        JobQueueEntry."Rerun Delay (sec.)" := Parameters."Rerun Delay (sec.)";
        if JobQueueEntry."Rerun Delay (sec.)" <= 0 then
            JobQueueEntry."Rerun Delay (sec.)" := 180;
        JobQueueEntry."Notify On Success" := Parameters."Notify On Success";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        if Parameters."Parameter String" <> '' then
            JobQueueEntry.Validate("Parameter String", Parameters."Parameter String");
        if Parameters.Description <> '' then
            JobQueueEntry.Description := Parameters.Description;
        JobQueueEntry."Job Queue Category Code" := Parameters."Job Queue Category Code";
        OnBeforeInsertRecurringJobQueueEntry(JobQueueEntry);
        JobQueueEntry.Insert(true);

        JobQueueEntryOut := JobQueueEntry;
        exit(true);
    end;

    procedure StartJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        StartJobQueueEntry(JobQueueEntry, JobQueueEntry."Earliest Start Date/Time");
    end;

    procedure StartJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"; NotBeforeDateTime: DateTime)
    var
        HasStartDT: Boolean;
    begin
        if JobQueueEntry.Status = JobQueueEntry.Status::"In Process" then
            exit;

        HasStartDT := (JobQueueEntry."Earliest Start Date/Time" <> 0DT) and (JobQueueEntry."Earliest Start Date/Time" <= NotBeforeDateTime);
        if (JobQueueEntry.Status = JobQueueEntry.Status::Ready) and HasStartDT then
            exit;

        if not HasStartDT then begin
            JobQueueEntry.LockTable();
            JobQueueEntry.Get(JobQueueEntry.ID);
            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
            JobQueueEntry."Earliest Start Date/Time" := NotBeforeDateTime;
            JobQueueEntry.Modify();
        end;
        JobQueueEntry.Restart();
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

    procedure GetAutoRecreateNoteTxt(): Text
    var
        AutoRecreateNoteLbl: Label 'Auto-created for %1. Can be deleted if not used. Will be recreated when the feature is activated.', Comment = '%1 = initial description of Job Queue Entry';
    begin
        exit(AutoRecreateNoteLbl);
    end;

    procedure SetShowAutoCreatedClause(Set: Boolean)
    begin
        ShowAutoCreatedClause := Set;
    end;

    procedure AddPosItemPostingJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategoryCode: Code[10];
        JobQueueDescrLbl: Label 'POS Item posting', MaxLength = 250;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR POS Post Item Entries JQ");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueCategoryCode := CreateAndAssignJobQueueCategory();
        JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"NPR POS Post Item Entries JQ", CurrentDateTime() + 360 * 1000, JobQueueCategoryCode, '');

        JobQueueEntry.Validate(Description, JobQueueDescrLbl);
        JobQueueEntry.Validate("Run on Mondays", true);
        JobQueueEntry.Validate("Run on Tuesdays", true);
        JobQueueEntry.Validate("Run on Wednesdays", true);
        JobQueueEntry.Validate("Run on Thursdays", true);
        JobQueueEntry.Validate("Run on Fridays", true);
        JobQueueEntry.Validate("Run on Saturdays", true);
        JobQueueEntry.Validate("Run on Sundays", true);
        JobQueueEntry.Validate("No. of Minutes between Runs", 1);
        JobQueueEntry.Validate(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.Modify();
    end;

    procedure AddPosPostingJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        DF: DateFormula;
        ParamString: Text[250];
        JobQueueCategoryCode: Code[10];
        JobQueueDescrLbl: Label 'POS posting', MaxLength = 250;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR POS Post GL Entries JQ");
        if not JobQueueEntry.IsEmpty() then
            exit;

        JobQueueCategoryCode := CreateAndAssignJobQueueCategory();
        JobQueueEntry.ScheduleJobQueueEntryForLater(Codeunit::"NPR POS Post GL Entries JQ", CurrentDateTime() + 360 * 1000, JobQueueCategoryCode, ParamString);

        JobQueueEntry.Validate("Job Queue Category Code", JobQueueCategoryCode);
        JobQueueEntry.Validate(Description, JobQueueDescrLbl);
        evaluate(DF, '<+1D>');
        JobQueueEntry.Validate("Next Run Date Formula", DF);
        JobQueueEntry.Validate("Starting Time", 230000T);
        JobQueueEntry.Validate(Status, JobQueueEntry.Status::Ready);
        JobQueueEntry.Modify(true);
    end;

    procedure CreateAndAssignJobQueueCategory(): Code[10]
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

    local procedure EmitTelemetryDataOnError(JobQueueLogEntry: Record "Job Queue Log Entry")
    var
        ActiveSession: Record "Active Session";
        ErrorMessage: Record "Error Message";
        TypeHelper: Codeunit "Type Helper";
        CustomDimensions: Dictionary of [Text, Text];
        ErrorMessageText: Text;
    begin
        if not ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(ActiveSession);

        JobQueueLogEntry.CalcFields("Object Caption to Run");
        ErrorMessage.SetRange("Register ID", JobQueueLogEntry."Error Message Register Id");
        if not ErrorMessage.FindSet() then
            ErrorMessageText := JobQueueLogEntry."Error Message"
        else
            repeat
                if ErrorMessageText <> '' then
                    ErrorMessageText := ErrorMessageText + TypeHelper.CRLFSeparator();
                ErrorMessageText := ErrorMessageText + ErrorMessage.Description;
            until ErrorMessage.Next() = 0;

        CustomDimensions.Add('NPR_Server', ActiveSession."Server Computer Name");
        CustomDimensions.Add('NPR_Instance', ActiveSession."Server Instance Name");
        CustomDimensions.Add('NPR_TenantId', Database.TenantId());
        CustomDimensions.Add('NPR_CompanyName', CompanyName());
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", 'OnBeforeEnqueueJobQueueEntry', '', true, false)]
    local procedure SetDefaultValues(var JobQueueEntry: Record "Job Queue Entry")
    begin
        if (JobQueueEntry."Maximum No. of Attempts to Run" <= 0) or (JobQueueEntry."Maximum No. of Attempts to Run" = 3) then  //3 - default value in MS standard application
            JobQueueEntry."Maximum No. of Attempts to Run" := 5;
        if (JobQueueEntry."Rerun Delay (sec.)" <= 0) or (JobQueueEntry."Rerun Delay (sec.)" = 60) then  //60 - default value in MS standard application
            JobQueueEntry."Rerun Delay (sec.)" := 180;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterFinalizeRun', '', true, false)]
    local procedure RescheduleAfterError(JobQueueEntry: Record "Job Queue Entry")
    var
        JobQueueSendNotif: Codeunit "NPR Job Queue - Send Notif.";
    begin
        if JobQueueEntry.IsTemporary then
            exit;
        if JobQueueEntry.Status <> JobQueueEntry.Status::Error then
            exit;

        if (JobQueueEntry."NPR Notif. Profile on Error" = '') and not JobQueueEntry."NPR Auto-Resched. after Error" then
            exit;

        Commit();

        if JobQueueEntry."NPR Notif. Profile on Error" <> '' then
            JobQueueSendNotif.SendNotifications(JobQueueEntry, JobQueueSendNotif);

        if JobQueueEntry."NPR Auto-Resched. after Error" then begin
            JobQueueEntry."Earliest Start Date/Time" := NowWithDelayInSeconds(JobQueueEntry."NPR Auto-Resched. Delay (sec.)");
            JobQueueEntry.Modify();
            JobQueueEntry.Restart();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnBeforeModifyLogEntry', '', true, false)]
    local procedure EmitTelemetry(var JobQueueLogEntry: Record "Job Queue Log Entry")
    begin
        if JobQueueLogEntry.IsTemporary or (JobQueueLogEntry.Status <> JobQueueLogEntry.Status::Error) then
            exit;

        EmitTelemetryDataOnError(JobQueueLogEntry);
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
}
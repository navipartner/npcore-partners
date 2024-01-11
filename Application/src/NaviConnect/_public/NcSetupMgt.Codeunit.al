codeunit 6151500 "NPR Nc Setup Mgt."
{
    var
        NaviConnectSetup: Record "NPR Nc Setup";

    procedure InitNaviConnectSetup()
    begin
        if NaviConnectSetup.Get() then
            exit;

        NaviConnectSetup.Init();
        NaviConnectSetup."Keep Tasks for" := CreateDateTime(Today, 000000T) - CreateDateTime(CalcDate('<-7D>', Today), 000000T);
        NaviConnectSetup."Task Worker Group" := NaviConnectDefaultTaskProcessorCode();
        NaviConnectSetup.Insert();
    end;
#pragma warning disable AA0139
    procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[20]
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', CopyStr('@' + WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));
        if ImportType.FindFirst() then
            exit(ImportType.Code);

        exit('');
    end;
#pragma warning restore AA0139

    internal procedure SetupTaskProcessingJobQueue(var JobQueueEntry: Record "Job Queue Entry"; Autocreated: Boolean)
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        NcTaskProcessor.Code := NaviConnectDefaultTaskProcessorCode();
        if not NcTaskProcessor.Find() then begin
            NcSyncMgt.UpdateTaskProcessor(NcTaskProcessor);
            Commit();
        end;
        JobQueueMgt.SetShowAutoCreatedClause(Autocreated);
        JobQueueMgt.ScheduleNcTaskProcessing(JobQueueEntry, NcTaskProcessor.Code, true, '');
    end;

    internal procedure SetupTaskCountResetJobQueue(var JobQueueEntry: Record "Job Queue Entry"; Autocreated: Boolean)
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        NcTaskProcessor.Code := NaviConnectDefaultTaskProcessorCode();
        if not NcTaskProcessor.Find() then begin
            NcSyncMgt.UpdateTaskProcessor(NcTaskProcessor);
            Commit();
        end;
        JobQueueMgt.SetShowAutoCreatedClause(Autocreated);
        JobQueueMgt.ScheduleNcTaskCountResetJob(JobQueueEntry, NcTaskProcessor.Code, '');
    end;

    internal procedure SetupDefaultNcImportListProcessingJobQueue(Autocreated: Boolean)
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        JobQueueMgt.SetShowAutoCreatedClause(Autocreated);
        JobQueueMgt.ScheduleNcImportListProcessing('', '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, false)]
    local procedure AddDefaultNCJobQueues_OnCompanyInitialize()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SetupTaskProcessingJobQueue(JobQueueEntry, true);
        SetupTaskCountResetJobQueue(JobQueueEntry, true);
        SetupDefaultNcImportListProcessingJobQueue(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure AddDefaultNCJobQueues_OnRefreshNPRJobQueueList()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SetupTaskProcessingJobQueue(JobQueueEntry, true);
        SetupTaskCountResetJobQueue(JobQueueEntry, true);
        SetupDefaultNcImportListProcessingJobQueue(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" in [ImportListProcessingCodeunit(), TaskListProcessingCodeunit()])
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

    internal procedure NaviConnectDefaultTaskProcessorCode(): Code[10]
    begin
        exit('NC');
    end;

    internal procedure DefaultNCJQCategoryCode(CodeunitID: Integer): Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        ImportListJQCategoryCode: Label 'NPR-NC-IMP', MaxLength = 10, Locked = true;
        ImportListJQCategoryDescrLbl: Label 'NaviConnect import list proc.', MaxLength = 30;
        TaskListJQCategoryCode: Label 'NPR-NC-TSK', MaxLength = 10, Locked = true;
        TaskListJQCategoryDescrLbl: Label 'NaviConnect task list proc.', MaxLength = 30;
    begin
        case CodeunitID of
            TaskListProcessingCodeunit():
                begin
                    JobQueueCategory.InsertRec(TaskListJQCategoryCode, TaskListJQCategoryDescrLbl);
                    exit(JobQueueCategory.Code);
                end;
            ImportListProcessingCodeunit():
                begin
                    JobQueueCategory.InsertRec(ImportListJQCategoryCode, ImportListJQCategoryDescrLbl);
                    exit(JobQueueCategory.Code);
                end;
        end;
    end;

    procedure ImportListProcessingCodeunit(): Integer
    begin
        exit(Codeunit::"NPR Nc Import List Processing");
    end;

    internal procedure TaskListProcessingCodeunit(): Integer
    begin
        exit(Codeunit::"NPR Nc Task List Processing");
    end;
}

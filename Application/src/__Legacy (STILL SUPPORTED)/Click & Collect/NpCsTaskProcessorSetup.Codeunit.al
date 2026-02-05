codeunit 6150811 "NPR NpCs Task Processor Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;

    procedure ScheduleRunWorkflow(NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        NpCsTaskProcessorSetup: Record "NPR NpCs Task Processor Setup";
    begin
        NpCsTaskProcessorSetup.SetLoadFields("Run Workflow Code");
        if not NpCsTaskProcessorSetup.Get() then
            exit(false);
        if NpCsTaskProcessorSetup."Run Workflow Code" = '' then
            exit(false);
        InsertNcTask(NpCsDocument, NpCsTaskProcessorSetup."Run Workflow Code");
        exit(true);
    end;

    procedure ScheduleDocumentPosting(NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        NpCsTaskProcessorSetup: Record "NPR NpCs Task Processor Setup";
    begin
        NpCsTaskProcessorSetup.SetLoadFields("Document Posting Code");
        if not NpCsTaskProcessorSetup.Get() then
            exit(false);
        if NpCsTaskProcessorSetup."Document Posting Code" = '' then
            exit(false);
        InsertNcTask(NpCsDocument, NpCsTaskProcessorSetup."Document Posting Code");
        exit(true);
    end;

    procedure ScheduleUpdateExpirationStatus(NpCsDocument: Record "NPR NpCs Document"): Boolean
    var
        NpCsTaskProcessorSetup: Record "NPR NpCs Task Processor Setup";
    begin
        NpCsTaskProcessorSetup.SetLoadFields("Expiration Code");
        if not NpCsTaskProcessorSetup.Get() then
            exit(false);
        if NpCsTaskProcessorSetup."Expiration Code" = '' then
            exit(false);
        InsertNcTask(NpCsDocument, NpCsTaskProcessorSetup."Expiration Code");
        exit(true);
    end;


    procedure InitializeTaskProcessors(var NpCsTaskProcessorSetup: Record "NPR NpCs Task Processor Setup")
    var
        ClickCollect: Codeunit "NPR Click & Collect";
        CollectRunWorkflowLbl: Label 'Process Run workflow on Collect Dosuments';
        CollectDocumentPostLbl: Label 'Process Document posting  on Collect Documents';
        CollectExpirationLbl: Label 'Updates expiration time on Collect Documents';
    begin
        if not NpCsTaskProcessorSetup.Get() then begin
            NpCsTaskProcessorSetup.Init();
            NpCsTaskProcessorSetup.Insert(true);
        end;
        if NpCsTaskProcessorSetup."Run Workflow Code" = '' then
            NpCsTaskProcessorSetup."Run Workflow Code" := 'COLLECT RUN WORKFLOW';
        InitNcTaskProcessor(NpCsTaskProcessorSetup."Run Workflow Code", CollectRunWorkflowLbl);
        if NpCsTaskProcessorSetup."Document Posting Code" = '' then
            NpCsTaskProcessorSetup."Document Posting Code" := 'COLLECT POST';
        InitNcTaskProcessor(NpCsTaskProcessorSetup."Document Posting Code", CollectDocumentPostLbl);
        if NpCsTaskProcessorSetup."Expiration Code" = '' then
            NpCsTaskProcessorSetup."Expiration Code" := 'COLLECT EXPIRATION';
        InitNcTaskProcessor(NpCsTaskProcessorSetup."Expiration Code", CollectExpirationLbl);
        ClickCollect.OnAfterInitializeTaskProcessors(NpCsTaskProcessorSetup);
        NpCsTaskProcessorSetup.Modify(true);
    end;

    local procedure InsertNcTask(NpCsDocument: Record "NPR NpCs Document"; TaskProcessorCode: Code[20]);
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask.Type := NcTask.Type::Modify;
        NcTask."Table No." := Database::"NPR NpCs Document";
        NcTask."Record Position" := CopyStr(NpCsDocument.GetPosition(false), 1, MaxStrLen(NcTask."Record Position"));
        NcTask."Log Date" := CurrentDateTime();
        NcTask."Record Value" := CopyStr(Format(NpCsDocument.RecordId), 1, MaxStrLen(NcTask."Record Value"));
        NcTask."Task Processor Code" := TaskProcessorCode;
        NcTask.Insert(true);
    end;


    local procedure InitNcTaskProcessor(TaskProcessorCode: Code[20]; TaskProcessorDescription: Text[50]);
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        NcTaskSetup: Record "NPR Nc Task Setup";
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if NcTaskProcessor.Get(TaskProcessorCode) then
            exit;

        NcTaskProcessor.Init();
        NcTaskProcessor.Code := TaskProcessorCode;
        NcTaskProcessor.Description := TaskProcessorDescription;
        NcTaskProcessor.Insert(true);

        NcTaskSetup.SetRange("Task Processor Code", TaskProcessorCode);
        NcTaskSetup.SetRange("Table No.", Database::"NPR NpCs Document");
        NcTaskSetup.SetRange("Codeunit ID", Codeunit::"NPR NpCs Task Processor");
        if not NcTaskSetup.FindFirst() then begin
            NcTaskSetup.Init();
            NcTaskSetup."Entry No." := 0;
            NcTaskSetup."Task Processor Code" := NcTaskProcessor.Code;
            NcTaskSetup."Table No." := Database::"NPR NpCs Document";
            NcTaskSetup."Codeunit ID" := Codeunit::"NPR NpCs Task Processor";
            NcTaskSetup.Insert(true);
        end;
        if not JobQueueEntryExists(TaskProcessorCode) then begin
            JobQueueManagement.SetProtected(true);
            JobQueueManagement.ScheduleNcTaskProcessing(JobQueueEntry, TaskProcessorCode, false, 'NPCSUPDATE', 5);
        end;
    end;

    local procedure JobQueueEntryExists(TaskProcessorCode: Code[20]): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcTaskListProcessing: Codeunit "NPR Nc Task List Processing";
        JQTaskProcessorCode: Text;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", NcSetupMgt.TaskListProcessingCodeunit());
        if JobQueueEntry.FindSet() then
            repeat
                if JobQueueEntry."Parameter String" <> '' then begin
                    JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
                    if JQParamStrMgt.ContainsParam(NcTaskListProcessing.ParamProcessTaskList()) then begin
                        JQTaskProcessorCode := JQParamStrMgt.GetParamValueAsText(NcTaskListProcessing.ParamProcessor());
                        if JQTaskProcessorCode = TaskProcessorCode then
                            exit(true);
                    end;
                end;
            until JobQueueEntry.Next() = 0;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        NpCsTaskProcessorSetup: Record "NPR NpCs Task Processor Setup";
    begin
        if not NpCsTaskProcessorSetup.Get() then
            exit;
        InitializeTaskProcessors(NpCsTaskProcessorSetup);
    end;
}

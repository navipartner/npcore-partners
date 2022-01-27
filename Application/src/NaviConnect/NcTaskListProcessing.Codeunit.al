codeunit 6151508 "NPR Nc Task List Processing"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        MaxRetry: Integer;
    begin
        JQParamStrMgt.Parse(Rec."Parameter String");
        FindTaskProcessorCode(Rec, JQParamStrMgt, NcTaskProcessor);

        if JQParamStrMgt.ContainsParam(ParamResetRetryCount()) then begin
            NcTaskMgt.TaskResetCount(NcTaskProcessor);
            Commit();
        end;

        if JQParamStrMgt.ContainsParam(ParamUpdateTaskList()) then begin
            NcTaskMgt.UpdateTasks(NcTaskProcessor);
            Commit();
        end;

        if JQParamStrMgt.ContainsParam(ParamProcessTaskList()) then begin
            MaxRetry := FindMaxRetry(Rec, JQParamStrMgt);
            NcSyncMgt.ProcessTasks(NcTaskProcessor, MaxRetry);
        end;
    end;

    var
        UpdateTaskListTxt: Label 'Update Task List';
        ProcessTaskListTxt: Label 'Process Task List';
        ParamNameAndValueLbl: Label '%1=%2', locked = true;
        ParameterStringTooLongErr: Label 'Parameter string "%1" is too long for %2', Comment = '%1 - parameter string, %2 - Job Queue Entry record id';

    local procedure FindTaskProcessorCode(var JobQueueEntry: Record "Job Queue Entry"; JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt."; var NcTaskProcessor: Record "NPR Nc Task Processor")
    var
        TaskProcessorCode: Text;
        ParameterString: Text;
    begin
        Clear(NcTaskProcessor);

        if not JQParamStrMgt.ContainsParam(ParamProcessor()) then begin
            NcTaskProcessor.FindFirst();
            JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, ParamProcessor(), NcTaskProcessor.Code));
            ParameterString := JQParamStrMgt.GetParamListAsCSString();
            if StrLen(ParameterString) > MaxStrLen(JobQueueEntry."Parameter String") then
                Error(ParameterStringTooLongErr, ParameterString, JobQueueEntry.RecordId());
            JobQueueEntry.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(JobQueueEntry."Parameter String")));
            JobQueueEntry.Modify(true);
            Commit();
        end;

        TaskProcessorCode := JQParamStrMgt.GetParamValueAsText(ParamProcessor());
        NcTaskProcessor.Get(UpperCase(TaskProcessorCode));
    end;

    local procedure FindMaxRetry(var JobQueueEntry: Record "Job Queue Entry"; JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.") MaxRetry: Integer
    var
        ParameterValue: Text;
        ParameterString: Text;
    begin
        if not JQParamStrMgt.ContainsParam(ParamMaxRetry()) then begin
            JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, ParamMaxRetry(), 3));
            ParameterString := JQParamStrMgt.GetParamListAsCSString();
            if StrLen(ParameterString) > MaxStrLen(JobQueueEntry."Parameter String") then
                Error(ParameterStringTooLongErr, ParameterString, JobQueueEntry.RecordId());
            JobQueueEntry.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(JobQueueEntry."Parameter String")));
            JobQueueEntry.Modify(true);
            Commit();
        end;

        ParameterValue := JQParamStrMgt.GetParamValueAsText(ParamMaxRetry());
        if Evaluate(MaxRetry, ParameterValue) then;

        exit(MaxRetry);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        if NcTaskProcessor.FindFirst() then;

        JQParamStrMgt.ClearParamDict();
        JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, ParamProcessor(), NcTaskProcessor.Code));
        JQParamStrMgt.AddToParamDict(ParamUpdateTaskList());
        JQParamStrMgt.AddToParamDict(ParamProcessTaskList());
        JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, ParamMaxRetry(), 3));

        Rec.Validate("Parameter String", CopyStr(JQParamStrMgt.GetParamListAsCSString(), 1, MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Job Queue Entry", 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        Description: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        JQParamStrMgt.Parse(Rec."Parameter String");
        FindTaskProcessorCode(Rec, JQParamStrMgt, NcTaskProcessor);
        Description := NcTaskProcessor.Code;
        if JQParamStrMgt.ContainsParam(ParamUpdateTaskList()) then
            Description += ' | ' + UpdateTaskListTxt;

        if JQParamStrMgt.ContainsParam(ParamProcessTaskList()) then
            Description += ' | ' + ProcessTaskListTxt;

        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Nc Task List Processing");
    end;

    procedure ParamProcessor(): Text
    begin
        exit('processor');
    end;

    procedure ParamMaxRetry(): Text
    begin
        exit('max_retry');
    end;

    procedure ParamUpdateTaskList(): Text
    begin
        exit('update_task_list');
    end;

    procedure ParamProcessTaskList(): Text
    begin
        exit('process_task_list');
    end;

    procedure ParamResetRetryCount(): Text
    begin
        exit('reset_retry_count');
    end;
}

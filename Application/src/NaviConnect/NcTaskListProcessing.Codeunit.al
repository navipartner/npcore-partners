codeunit 6151508 "NPR Nc Task List Processing"
{
    // NC2.23/MHA /20191018  CASE 358499 Object created - Process Nc Task List via Job Queue

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        NcTaskMgt: Codeunit "NPR Nc Task Mgt.";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        MaxRetry: Integer;
    begin
        FindTaskProcessorCode(Rec, NcTaskProcessor);

        if HasParameter(Rec, ParamUpdateTaskList()) then begin
            NcTaskMgt.UpdateTasks(NcTaskProcessor);
            Commit;
        end;

        if HasParameter(Rec, ParamProcessTaskList()) then begin
            MaxRetry := FindMaxRetry(Rec);
            NcSyncMgt.ProcessTasks(NcTaskProcessor, MaxRetry);
        end;
    end;

    var
        Text000: Label 'Update Task List';
        Text001: Label 'Process Task List';

    local procedure FindTaskProcessorCode(var JobQueueEntry: Record "Job Queue Entry"; var NcTaskProcessor: Record "NPR Nc Task Processor")
    var
        TaskProcessorCode: Text;
        Position: Integer;
        ParameterString: Text;
    begin
        Clear(NcTaskProcessor);
        NcTaskProcessor.FindFirst;

        if not HasParameter(JobQueueEntry, ParamProcessor()) then begin
            ParameterString := ParamProcessor() + '=' + NcTaskProcessor.Code;
            if JobQueueEntry."Parameter String" <> '' then
                ParameterString += ',' + JobQueueEntry."Parameter String";

            JobQueueEntry.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(JobQueueEntry."Parameter String")));
            JobQueueEntry.Modify(true);
            Commit;
        end;

        TaskProcessorCode := GetParameterValue(JobQueueEntry, ParamProcessor());
        NcTaskProcessor.Get(UpperCase(TaskProcessorCode));
    end;

    local procedure FindMaxRetry(var JobQueueEntry: Record "Job Queue Entry") MaxRetry: Integer
    var
        ParameterValue: Text;
        ParameterString: Text;
    begin
        if not HasParameter(JobQueueEntry, ParamMaxRetry()) then begin
            ParameterString := JobQueueEntry."Parameter String";
            if ParameterString <> '' then
                ParameterString += ',';

            ParameterString += ParamMaxRetry() + '=3';
            JobQueueEntry.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(JobQueueEntry."Parameter String")));
            JobQueueEntry.Modify(true);
            Commit;
        end;

        ParameterValue := GetParameterValue(JobQueueEntry, ParamMaxRetry());
        if Evaluate(MaxRetry, ParameterValue) then;

        exit(MaxRetry);
    end;

    local procedure GetParameterValue(JobQueueEntry: Record "Job Queue Entry"; ParameterName: Text) ParameterValue: Text
    var
        Position: Integer;
    begin
        if ParameterName = '' then
            exit('');

        ParameterValue := JobQueueEntry."Parameter String";
        Position := StrPos(LowerCase(ParameterValue), LowerCase(ParameterName));
        if Position = 0 then
            exit('');

        if Position > 1 then
            ParameterValue := DelStr(ParameterValue, 1, Position - 1);

        ParameterValue := DelStr(ParameterValue, 1, StrLen(ParameterName));
        if ParameterValue = '' then
            exit('');
        if ParameterValue[1] = '=' then
            ParameterValue := DelStr(ParameterValue, 1, 1);

        Position := FindDelimiterPosition(ParameterValue);
        if Position > 0 then
            ParameterValue := DelStr(ParameterValue, Position);

        exit(ParameterValue);
    end;

    local procedure HasParameter(JobQueueEntry: Record "Job Queue Entry"; ParameterName: Text): Boolean
    var
        Position: Integer;
    begin
        Position := StrPos(LowerCase(JobQueueEntry."Parameter String"), LowerCase(ParameterName));
        exit(Position > 0);
    end;

    local procedure FindDelimiterPosition(ParameterString: Text) Position: Integer
    var
        NewPosition: Integer;
    begin
        if ParameterString = '' then
            exit(0);

        Position := StrPos(ParameterString, ',');

        NewPosition := StrPos(ParameterString, ';');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
            Position := NewPosition;

        NewPosition := StrPos(ParameterString, '|');
        if (NewPosition > 0) and ((Position = 0) or (NewPosition < Position)) then
            Position := NewPosition;

        exit(Position);
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Object ID to Run', true, true)]
    local procedure OnValidateJobQueueEntryObjectIDtoRun(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        ParameterString: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        if NcTaskProcessor.FindFirst then;

        ParameterString := ParamProcessor() + '=' + NcTaskProcessor.Code;
        ParameterString += ',' + ParamUpdateTaskList();
        ParameterString += ',' + ParamProcessTaskList();
        ParameterString += ',' + ParamMaxRetry() + '=3';

        Rec.Validate("Parameter String", CopyStr(ParameterString, 1, MaxStrLen(Rec."Parameter String")));
    end;

    [EventSubscriber(ObjectType::Table, 472, 'OnAfterValidateEvent', 'Parameter String', true, true)]
    local procedure OnValidateJobQueueEntryParameterString(var Rec: Record "Job Queue Entry"; var xRec: Record "Job Queue Entry"; CurrFieldNo: Integer)
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
        ParameterString: Text;
        Description: Text;
    begin
        if Rec."Object Type to Run" <> Rec."Object Type to Run"::Codeunit then
            exit;
        if Rec."Object ID to Run" <> CurrCodeunitId() then
            exit;

        FindTaskProcessorCode(Rec, NcTaskProcessor);
        Description := NcTaskProcessor.Code;
        if HasParameter(Rec, ParamUpdateTaskList()) then
            Description += ' | ' + Text000;

        if HasParameter(Rec, ParamProcessTaskList()) then
            Description += ' | ' + Text001;

        Rec.Description := CopyStr(Description, 1, MaxStrLen(Rec.Description));
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR Nc Task List Processing");
    end;

    local procedure ParamProcessor(): Text
    begin
        exit('processor');
    end;

    local procedure ParamMaxRetry(): Text
    begin
        exit('max_retry');
    end;

    local procedure ParamUpdateTaskList(): Text
    begin
        exit('update_task_list');
    end;

    local procedure ParamProcessTaskList(): Text
    begin
        exit('process_task_list');
    end;
}


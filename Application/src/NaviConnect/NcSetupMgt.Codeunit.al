codeunit 6151500 "NPR Nc Setup Mgt."
{
    var
        NaviConnectSetup: Record "NPR Nc Setup";

    procedure InitNaviConnectSetup()
    begin
        if not NaviConnectSetup.Get() then begin
            NaviConnectSetup.Init();
            NaviConnectSetup.Insert();
        end;

        NaviConnectSetup."Keep Tasks for" := CreateDateTime(Today, 000000T) - CreateDateTime(CalcDate('<-7D>', Today), 000000T);
        NaviConnectSetup."Task Worker Group" := 'NC';
        NaviConnectSetup.Modify(true);
    end;

    procedure SetupTaskQueue()
    var
        SyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        TaskCode: Code[10];
        TaskDescription: Text[50];
        TaskLineNo: Integer;
    begin
        NaviConnectSetup.Get();
        if not NaviConnectSetup."Task Queue Enabled" then
            exit;
        TaskCode := NaviConnectSetup."Task Worker Group";
        TaskDescription := 'NaviConnect';

        SetupTaskWorkerGroup(TaskCode, TaskDescription);
        SetupTaskTemplate(TaskCode, TaskDescription, TaskCode);
        SetupTaskBatch(TaskCode, TaskCode, TaskDescription, TaskCode);

        FindLineNo(TaskCode, TaskCode, TaskDescription + ' Process Tasks', TaskLineNo);
        SetupTaskLineMinute(TaskCode, TaskCode, TaskLineNo, TaskDescription + ' Process Tasks', TaskCode);
        SetupTaskLineParameterBool(TaskCode, TaskCode, TaskLineNo, SyncMgt."Parameter.ProcessTasks"(), true);
        SetupTaskLineParameterInt(TaskCode, TaskCode, TaskLineNo, SyncMgt."Parameter.TaskRetryCount"(), 3);
        SetupTaskLineParameterBool(TaskCode, TaskCode, TaskLineNo, SyncMgt."Parameter.ImportNewTasks"(), true);
        SetTaskLineEnabled(TaskCode, TaskCode, TaskLineNo, NaviConnectSetup."Task Queue Enabled");

        FindLineNo(TaskCode, TaskCode, TaskDescription + ' Reset Task Count', TaskLineNo);
        SetupTaskLineDay(TaskCode, TaskCode, TaskLineNo, TaskDescription + ' Reset Task Count', TaskCode);
        SetupTaskLineParameterBool(TaskCode, TaskCode, TaskLineNo, SyncMgt."Parameter.ResetTaskCount"(), true);
        SetTaskLineEnabled(TaskCode, TaskCode, TaskLineNo, NaviConnectSetup."Task Queue Enabled");

        FindLineNo(TaskCode, TaskCode, TaskDescription + ' Delete Old Entries', TaskLineNo);
        SetupCleanUpTask(TaskCode, TaskCode, TaskLineNo, TaskDescription + ' Delete Old Entries', TaskCode);
        SetupTaskLineParameterBool(TaskCode, TaskCode, TaskLineNo, 'DEL DATA LOG', true);
        SetTaskLineEnabled(TaskCode, TaskCode, TaskLineNo, NaviConnectSetup."Task Queue Enabled");
    end;

    local procedure SetTaskLineEnabled(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; Enabled: Boolean)
    var
        TaskLine: Record "NPR Task Line";
        TaskQueue: Record "NPR Task Queue";
    begin
        if TaskLine.Get(TemplateName, BatchName, LineNo) and (TaskLine.Enabled <> Enabled) then begin
            if Enabled then
                if not TaskQueue.Get(CompanyName, TemplateName, BatchName, LineNo) then begin
                    TaskQueue.SetupNewLine(TaskLine, false);
                    TaskQueue."Next Run time" := CurrentDateTime;
                    TaskQueue.Insert();
                end else begin
                    TaskQueue."Next Run time" := CurrentDateTime;
                    TaskQueue.Modify();
                end;
            TaskLine.Validate(Enabled, Enabled);
            TaskLine.Modify(true);
        end;
    end;

    local procedure SetupTaskWorkerGroup(GroupCode: Code[10]; GroupDescription: Text[50])
    var
        TaskWorkerGroup: Record "NPR Task Worker Group";
    begin
        if not TaskWorkerGroup.Get(GroupCode) then begin
            TaskWorkerGroup.Init();
            TaskWorkerGroup.Code := GroupCode;
            TaskWorkerGroup.Description := GroupDescription;
            TaskWorkerGroup.Validate("Language ID", 1033);
            TaskWorkerGroup."Min Interval Between Check" := 10 * 1000;
            TaskWorkerGroup."Max Interval Between Check" := 60 * 1000;
            TaskWorkerGroup."Max. Concurrent Threads" := 1;
            TaskWorkerGroup.Insert(true);
        end;
    end;

    local procedure SetupTaskTemplate(TemplateName: Code[10]; TemplateDescription: Text[50]; GroupCode: Code[10])
    var
        TaskTemplate: Record "NPR Task Template";
    begin
        if not TaskTemplate.Get(TemplateName) then begin
            TaskTemplate.Init();
            TaskTemplate.Name := TemplateName;
            TaskTemplate.Description := TemplateDescription;
            TaskTemplate."Page ID" := PAGE::"NPR Task Journal";
            TaskTemplate.Type := TaskTemplate.Type::General;
            TaskTemplate."Task Worker Group" := GroupCode;
            TaskTemplate.Insert(true);
        end;
    end;

    local procedure SetupTaskBatch(TemplateName: Code[10]; BatchName: Code[10]; BatchDescription: Text[50]; GroupCode: Code[10])
    var
        TaskBatch: Record "NPR Task Batch";
    begin
        if not TaskBatch.Get(TemplateName, BatchName) then begin
            TaskBatch.Init();
            TaskBatch."Journal Template Name" := TemplateName;
            TaskBatch.Name := BatchName;
            TaskBatch.Description := BatchDescription;
            TaskBatch."Task Worker Group" := GroupCode;
            TaskBatch."Template Type" := TaskBatch."Template Type"::General;
            TaskBatch.Insert(true);
        end;
    end;

    local procedure SetupTaskLineMinute(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; TaskDescription: Text[50]; GroupCode: Code[10])
    var
        TaskLine: Record "NPR Task Line";
    begin
        if not TaskLine.Get(TemplateName, BatchName, LineNo) then begin
            TaskLine.Init();
            TaskLine."Journal Template Name" := TemplateName;
            TaskLine."Journal Batch Name" := BatchName;
            TaskLine."Line No." := LineNo;
            TaskLine.Description := TaskDescription;
            TaskLine.Enabled := false;
            TaskLine."Object Type" := TaskLine."Object Type"::Codeunit;
            TaskLine."Object No." := CODEUNIT::"NPR Nc Sync. Mgt.";
            TaskLine."Call Object With Task Record" := true;
            TaskLine.Priority := TaskLine.Priority::Medium;
            TaskLine."Task Worker Group" := GroupCode;
            TaskLine.Recurrence := TaskLine.Recurrence::Custom;
            TaskLine."Recurrence Interval" := 60 * 1000;
            TaskLine."Recurrence Method" := TaskLine."Recurrence Method"::Static;
            TaskLine."Recurrence Calc. Interval" := 0;
            TaskLine."Run on Monday" := true;
            TaskLine."Run on Tuesday" := true;
            TaskLine."Run on Wednesday" := true;
            TaskLine."Run on Thursday" := true;
            TaskLine."Run on Friday" := true;
            TaskLine."Run on Saturday" := true;
            TaskLine."Run on Sunday" := true;
            TaskLine.Insert(true);
        end;
    end;

    local procedure SetupTaskLineDay(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; TaskDescription: Text[50]; GroupCode: Code[10])
    var
        TaskLine: Record "NPR Task Line";
    begin
        if not TaskLine.Get(TemplateName, BatchName, LineNo) then begin
            TaskLine.Init();
            TaskLine."Journal Template Name" := TemplateName;
            TaskLine."Journal Batch Name" := BatchName;
            TaskLine."Line No." := LineNo;
            TaskLine.Description := TaskDescription;
            TaskLine.Enabled := false;
            TaskLine."Object Type" := TaskLine."Object Type"::Codeunit;
            TaskLine."Object No." := CODEUNIT::"NPR Nc Sync. Mgt.";
            TaskLine."Call Object With Task Record" := true;
            TaskLine.Priority := TaskLine.Priority::Medium;
            TaskLine."Task Worker Group" := GroupCode;
            TaskLine.Recurrence := TaskLine.Recurrence::Daily;
            TaskLine."Recurrence Interval" := CreateDateTime(Today, 000000T) - CreateDateTime(CalcDate('<-1D>', Today), 000000T);
            TaskLine."Recurrence Calc. Interval" := 1000 * 60 * 60;
            TaskLine."Valid After" := 235900T;
            TaskLine."Valid Until" := 060000T;
            TaskLine."Run on Monday" := true;
            TaskLine."Run on Tuesday" := true;
            TaskLine."Run on Wednesday" := true;
            TaskLine."Run on Thursday" := true;
            TaskLine."Run on Friday" := true;
            TaskLine."Run on Saturday" := true;
            TaskLine."Run on Sunday" := true;
            TaskLine.Insert(true);
        end;
    end;

    local procedure SetupTaskLineParameterBool(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; ParameterName: Code[20]; ParameterValue: Boolean)
    var
        TaskLine: Record "NPR Task Line";
    begin
        if TaskLine.Get(TemplateName, BatchName, LineNo) then begin
            TaskLine.GetParameterBool(ParameterName);
            TaskLine.SetParameterBool(ParameterName, ParameterValue);
        end;
    end;

    local procedure SetupTaskLineParameterInt(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; ParameterName: Code[20]; ParameterValue: Integer)
    var
        TaskLine: Record "NPR Task Line";
    begin
        if TaskLine.Get(TemplateName, BatchName, LineNo) then begin
            TaskLine.GetParameterInt(ParameterName);
            TaskLine.SetParameterInt(ParameterName, ParameterValue);
        end;
    end;

    local procedure SetupCleanUpTask(TemplateName: Code[10]; BatchName: Code[10]; LineNo: Integer; TaskDescription: Text[50]; GroupCode: Code[10])
    var
        TaskLine: Record "NPR Task Line";
    begin
        if not TaskLine.Get(TemplateName, BatchName, LineNo) then begin
            TaskLine.Init();
            TaskLine."Journal Template Name" := TemplateName;
            TaskLine."Journal Batch Name" := BatchName;
            TaskLine."Line No." := LineNo;
            TaskLine.Description := TaskDescription;
            TaskLine.Enabled := false;
            TaskLine."Object Type" := TaskLine."Object Type"::Codeunit;
            TaskLine."Call Object With Task Record" := true;
            TaskLine.Priority := TaskLine.Priority::Medium;
            TaskLine."Task Worker Group" := GroupCode;
            TaskLine.Recurrence := TaskLine.Recurrence::Custom;
            TaskLine."Recurrence Interval" := CreateDateTime(Today, 000000T) - CreateDateTime(CalcDate('<-7D>', Today), 000000T);
            TaskLine."Recurrence Calc. Interval" := 1000 * 60 * 60;
            TaskLine."Valid After" := 235900T;
            TaskLine."Valid Until" := 060000T;
            TaskLine."Run on Monday" := true;
            TaskLine."Run on Tuesday" := true;
            TaskLine."Run on Wednesday" := true;
            TaskLine."Run on Thursday" := true;
            TaskLine."Run on Friday" := true;
            TaskLine."Run on Saturday" := true;
            TaskLine."Run on Sunday" := true;
            TaskLine.Insert(true);
        end;
    end;

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

    local procedure FindLineNo(TemplateName: Code[10]; BatchName: Code[10]; TaskDescription: Text; var LineNo: Integer)
    var
        TaskLine: Record "NPR Task Line";
    begin
        TaskLine.SetRange("Journal Template Name", TemplateName);
        TaskLine.SetRange("Journal Batch Name", BatchName);
        TaskLine.SetRange(Description, TaskDescription);
        if TaskLine.FindLast() then;
        LineNo := TaskLine."Line No." + 10000;
    end;
}


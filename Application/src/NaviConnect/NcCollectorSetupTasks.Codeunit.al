codeunit 6151531 "NPR Nc Collector Setup Tasks"
{
    Access = Internal;

    var
        NaviConnectSetup: Record "NPR Nc Setup";

    procedure SetupTaskQueue()
    var
        TaskCode: Code[10];
        TaskDescription: Text[50];
        TaskLineNo: Integer;
    begin
        NaviConnectSetup.Get();
        if not NaviConnectSetup."Task Queue Enabled" then
            exit;
        TaskCode := NaviConnectSetup."Task Worker Group";
        TaskDescription := 'NaviConnect';


        TaskLineNo := 50000;
        SetupTaskLineMinute(TaskCode, TaskCode, TaskLineNo, TaskDescription + ' Collection Send', TaskCode);
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
            TaskLine."Object No." := CODEUNIT::"NPR Nc Collector Send Collect.";
            TaskLine."Call Object With Task Record" := false;
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
}


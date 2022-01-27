codeunit 6014679 "NPR Setup Endpoint Req Tasks"
{
    Access = Internal;
    // NPR5.23/BR/20160609      CASE 237658 Setup Task Queue taken from Codeunit 6059800 NaviConnect Setup Mgt.
    // NPR5.23.03/MHA/20160726  CASE 242557 Magento reference updated according to NC2.00


    trigger OnRun()
    begin
    end;

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
        SetupTaskLineMinute(TaskCode, TaskCode, TaskLineNo, CopyStr(TaskDescription + ' Endpoint Send Req. Batch', 1, MaxStrLen(TaskDescription)), TaskCode);
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
            TaskLine."Object No." := CODEUNIT::"NPR Endpoint Send Req. Batch";
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


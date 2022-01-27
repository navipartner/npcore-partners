codeunit 6059901 "NPR Task Queue Manager"
{
    Access = Internal;
    // This CU will be executed until there are no Jobs that will fullfull the requirements for being executed now
    // This means that when CU is runned the first time, it will try to find a task that "Needs to be executed now" (Next Execution time" has passed)
    // when this task is finished, the CU will try to see if there is a New task that "Needs to be executed now".
    // This will continue until there is no more tasks that "Needs to be executed now"
    // then this CU will exit.
    // In above example this will result in this:
    //  - Login
    //  - Execute a Task
    //  - Execute a Task
    //  - Logout
    // 

    TableNo = "NPR Task Queue";

    trigger OnRun()
    begin
        LoginTaskWorker(Rec."Task Worker Group");
        ExecuteTasks(Rec);
        LogoutAuto();
    end;

    var
        ActiveSession: Record "Active Session";

    local procedure ExecuteTasks(TaskQueue: Record "NPR Task Queue")
    var
        TaskQueueProcessor: Codeunit "NPR Task Queue Processor";
        TaskWorker: Record "NPR Task Worker";
        NextTaskQueue: Record "NPR Task Queue";
    begin
        GetMySession();
        NextTaskQueue := TaskQueue;
        repeat
            TaskQueueProcessor.Run(NextTaskQueue);
            HeartBeat(0);//Has a COMMIT
            TaskWorker.Get(ActiveSession."Server Instance ID", ActiveSession."Session ID");
        until (not TaskWorker.Active) or (not GetNextTask(TaskWorker, NextTaskQueue));
    end;

    procedure LoginTaskWorker(TaskWorkerGroupCode: Code[10])
    var
        TaskWorker: Record "NPR Task Worker";
        TaskWorkerGroup: Record "NPR Task Worker Group";
    begin
        if not TaskWorker.Get(ServiceInstanceId(), SessionId()) then begin
            GetMySession();

            TaskWorkerGroup.Get(TaskWorkerGroupCode);

            if TaskWorkerGroup."Language ID" <> 0 then
                GlobalLanguage(TaskWorkerGroup."Language ID");

            TaskWorker.Init();
            TaskWorker."Server Instance ID" := ActiveSession."Server Instance ID";
            TaskWorker."User ID" := CopyStr(ActiveSession."User ID", 1, MaxStrLen(TaskWorker."User ID"));
            TaskWorker."Session ID" := ActiveSession."Session ID";
            TaskWorker."Login Time" := ActiveSession."Login Datetime";
            TaskWorker."Current Company" := CopyStr(CompanyName, 1, MaxStrLen(TaskWorker."Current Company"));
            TaskWorker."Host Name" := CopyStr(ActiveSession."Client Computer Name", 1, MaxStrLen(TaskWorker."Host Name"));
            TaskWorker."Task Worker Group" := TaskWorkerGroupCode;
            TaskWorker."Current Check Interval" := TaskWorkerGroup."Min Interval Between Check";
            TaskWorker."Current Language ID" := GlobalLanguage;
            TaskWorker.Active := true;
            TaskWorker."Last HeartBeat (When Idle)" := CurrentDateTime;
            TaskWorker.Insert();
        end;
        Commit();
    end;

    procedure LogoutAuto()
    begin
        GetMySession();
        Logout(ActiveSession."Server Instance ID", ActiveSession."Session ID");
    end;

    procedure Logout(ServerInstanceID: Integer; SessionID: Integer)
    var
        TaskQueue2: Record "NPR Task Queue";
        TaskWorker: Record "NPR Task Worker";
    begin
        TaskWorker.LockTable();
        if not TaskWorker.Get(ServerInstanceID, SessionID) then
            exit;

        TaskQueue2.LockTable();
        TaskQueue2.SetCurrentKey("Assigned to Service Inst.ID", "Assigned to Session ID", Enabled, "Task Worker Group", Company, "Next Run time");

        TaskQueue2.SetRange("Assigned to Service Inst.ID", ServerInstanceID);
        TaskQueue2.SetRange("Assigned to Session ID", SessionID);
        if TaskQueue2.FindFirst() then begin
            TaskQueue2.Validate(Status, TaskQueue2.Status::Awaiting);
            TaskQueue2.Modify();
        end;
        TaskWorker.Delete();
        Commit();
    end;

    local procedure GetMySession()
    begin
        if ActiveSession."Server Instance ID" <> 0 then
            exit;

        ActiveSession.Get(ServiceInstanceId(), SessionId());
    end;

    procedure HeartBeat(CurrentCheckInterval: Integer)
    var
        TaskWorker: Record "NPR Task Worker";
    begin
        TaskWorker.LockTable();
        GetMySession();

        TaskWorker.Get(ActiveSession."Server Instance ID", ActiveSession."Session ID");
        TaskWorker."Last HeartBeat (When Idle)" := CurrentDateTime;
        TaskWorker."Current Check Interval" := CurrentCheckInterval;
        TaskWorker.Modify();

        Commit();
    end;

    local procedure GetNextTask(TaskWorker: Record "NPR Task Worker"; var TaskQueue: Record "NPR Task Queue"): Boolean
    var
        TaskQueue2: Record "NPR Task Queue";
    begin
        if not TaskWorker.Active then
            exit(false);

        TaskQueue2.SetCurrentKey("Assigned to Service Inst.ID", "Assigned to Session ID", Enabled, "Task Worker Group", Company, "Next Run time");
        TaskQueue2.SetRange(Company, TaskWorker."Current Company");
        TaskQueue2.SetRange("Assigned to Service Inst.ID", ServiceInstanceId());
        TaskQueue2.SetRange("Assigned to Session ID", SessionId());
        if TaskQueue2.FindFirst() then begin
            TaskQueue := TaskQueue2;
            exit(true);
        end;

        exit(false);
    end;

    procedure CodeManualRun(TaskLineParm: Record "NPR Task Line")
    var
        TaskQueueProcessor: Codeunit "NPR Task Queue Processor";
        TaskLine: Record "NPR Task Line";
    begin
        TaskLine.Get(TaskLineParm."Journal Template Name", TaskLineParm."Journal Batch Name", TaskLineParm."Line No.");
        TaskQueueProcessor.CodeManualRun(TaskLine);
    end;
}


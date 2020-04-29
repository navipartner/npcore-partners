codeunit 6059901 "Task Queue Manager"
{
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
    // TQ1.15/JDH/20140908 CASE 179044
    // TQ1.18/JDH/20141126 CASE 198170 MASTER Task worker group discontinued - handling of max threads moved to individual Worker Group
    // TQ1.18.01/JDH/20141124 CASE 198851 Task Line not set correctly when running task manually (printer not found correct)
    // TQ1.24/JDH/20150317 CASE 209090 Function Logout made global
    // TQ1.25/MH/20150410  CASE 210797 A Task Worker (Session) only performs the first task and Children Tasks, if any
    //                                 Removed Keep Alive functionality
    //                                 Renamed function Code() to ExecuteTasks() and update functionality to only execute directly assigned tasks
    // TQ1.28/RMT/20150807 CASE 219795 Added explicit locking and release for tables to reduce dealocks
    //                                 No global record variables for better scoping
    //                                 Removed function "GetTaskWorkerGroup"
    //                                 Function LoginService moved to Master (codeunit 6059904)
    // TQ1.29/JDH/20160729 CASE 242044 Changed CU to NOT beeing single instance + restructured code for better performance
    // TQ1.29/BR /20161031 CASE 256917 Set Heartbeat when inserting Task Worker
    // TQ1.31/JDH /20180116 CASE 301695 Removed a findlast, since it could cause a deadlock with another process that used findset
    // NPR5.45/JDH /20180508 CASE 313269 SELECTLATESTVERSION removed, since its only possible to have 1 Master Thread (and thereby everything is on 1 NST)
    // NPR5.45/MHA /20180829 CASE 326707 Removed unnecessary LOCKTABLE in LoginTaskWorker()
    // TQ1.34/JDH /20181011 CASE 326930 New key for better performance

    TableNo = "Task Queue";

    trigger OnRun()
    begin
        LoginTaskWorker("Task Worker Group");
        ExecuteTasks(Rec);
        LogoutAuto;
    end;

    var
        CurrentLogEntryNo: Integer;
        ActiveSession: Record "Active Session";

    local procedure ExecuteTasks(TaskQueue: Record "Task Queue")
    var
        TaskQueueProcessor: Codeunit "Task Queue Processor";
        TaskWorker: Record "Task Worker";
        NextTaskQueue: Record "Task Queue";
    begin
        GetMySession;
        //-TQ1.29
        //TaskWorker.GET(ActiveSession."Server Instance ID", ActiveSession."Session ID");
        //+TQ1.29

        NextTaskQueue := TaskQueue;
        repeat
          //-TQ1.29
          //SELECTLATESTVERSION;
          //TaskLine.GET(NextTaskQueue."Task Template", NextTaskQueue."Task Batch", NextTaskQueue."Task Line No.");
          //+TQ1.29
          TaskQueueProcessor.Run(NextTaskQueue);
          //-TQ1.34 [326930]
          //HeartBeat;//Has a COMMIT
          HeartBeat(0);//Has a COMMIT
          //+TQ1.34 [326930]
          TaskWorker.Get(ActiveSession."Server Instance ID", ActiveSession."Session ID");
        until (not TaskWorker.Active) or (not GetNextTask(TaskWorker, NextTaskQueue));
    end;

    procedure LoginTaskWorker(TaskWorkerGroupCode: Code[20])
    var
        TaskWorker: Record "Task Worker";
        TaskWorkerGroup: Record "Task Worker Group";
    begin
        with TaskWorker do begin
          if not Get(ServiceInstanceId, SessionId) then begin
            //-NPR5.45 [326707]
            // LOCKTABLE;
            // IF FINDLAST THEN; //force a read lock
            //+NPR5.45 [326707]

            GetMySession;

            TaskWorkerGroup.Get(TaskWorkerGroupCode);

            if TaskWorkerGroup."Language ID" <> 0 then
              GlobalLanguage(TaskWorkerGroup."Language ID");

            Init;
            "Server Instance ID" := ActiveSession."Server Instance ID";
            "User ID" := ActiveSession."User ID";
            "Session ID" := ActiveSession."Session ID";
            "Login Time" := ActiveSession."Login Datetime";
            "Current Company" := CompanyName;
            "Host Name" := ActiveSession."Client Computer Name";
            "Task Worker Group" := TaskWorkerGroupCode;
            "Current Check Interval" := TaskWorkerGroup."Min Interval Between Check";
            "Current Language ID"    := GlobalLanguage;
            Active := true;
            //-TQ1.29 [256917]
            "Last HeartBeat (When Idle)" := CurrentDateTime;
            //+TQ1.29 [256917]
            Insert;
          end;
        end;

        //-TQ1.28
        //TaskLog.AddLoginThread(TaskWorker);
        //-TQ1.29
        //TaskLogMaster.AddLoginThread(TaskWorker);
        //+TQ1.29
        //-TQ1.28

        Commit;
    end;

    procedure LogoutAuto()
    begin
        //-TQ1.29
        //IF NOT ActiveSession.READPERMISSION THEN
        //  EXIT;
        //+TQ1.29

        GetMySession;
        Logout(ActiveSession."Server Instance ID", ActiveSession."Session ID");
    end;

    procedure Logout(ServerInstanceID: Integer;SessionID: Integer)
    var
        TaskQueue2: Record "Task Queue";
        TaskWorker: Record "Task Worker";
    begin
        //-TQ1.29
        TaskWorker.LockTable;
        //+TQ1.29
        if not TaskWorker.Get(ServerInstanceID, SessionID) then
          exit;

        TaskQueue2.LockTable;

        //-NPR5.45 [313269]
        //-TQ1.34 [326930]
        //TaskQueue2.SETCURRENTKEY("Task Worker Group","Assigned to Service Inst.ID","Assigned to Session ID",Enabled,Company,"Next Run time");
        TaskQueue2.SetCurrentKey("Assigned to Service Inst.ID","Assigned to Session ID",Enabled,"Task Worker Group", Company,"Next Run time");
        //+TQ1.34 [326930]
        //+NPR5.45 [313269]

        TaskQueue2.SetRange("Assigned to Service Inst.ID", ServerInstanceID);
        TaskQueue2.SetRange("Assigned to Session ID", SessionID);
        if TaskQueue2.FindFirst then begin
          TaskQueue2.Validate(Status, TaskQueue2.Status::Awaiting);
          TaskQueue2.Modify;
        end;

        //-TQ1.29
        //-TQ1.28
        //TaskLog.AddLogout(TaskWorker);
        //TaskLogMaster.AddLogout(TaskWorker);
        //+TQ1.28
        //+TQ1.29

        TaskWorker.Delete;
        //-TQ1.29
        //CLEAR(TaskLine);
        //+TQ1.29

        Commit;
    end;

    local procedure GetMySession()
    begin
        if ActiveSession."Server Instance ID" <> 0 then
          exit;

        ActiveSession.Get(ServiceInstanceId, SessionId);
    end;

    procedure HeartBeat(CurrentCheckInterval: Integer)
    var
        TaskWorker: Record "Task Worker";
    begin
        //-TQ1.28
        TaskWorker.LockTable;
        //-TQ1.31 [301695]
        //IF TaskWorker.FINDLAST THEN;
        //+TQ1.31 [301695]
        //+TQ1.28
        GetMySession;

        TaskWorker.Get(ActiveSession."Server Instance ID", ActiveSession."Session ID");
        TaskWorker."Last HeartBeat (When Idle)" := CurrentDateTime;
        //-TQ1.34 [326930]
        TaskWorker."Current Check Interval" := CurrentCheckInterval;
        //+TQ1.34 [326930]
        TaskWorker.Modify;

        Commit;
    end;

    local procedure GetNextTask(TaskWorker: Record "Task Worker";var TaskQueue: Record "Task Queue"): Boolean
    var
        TaskQueue2: Record "Task Queue";
    begin
        if not TaskWorker.Active then
          exit(false);

        //-NPR5.45 [313269]
        //SELECTLATESTVERSION;
        //CLEAR(TaskQueue);
        //-TQ1.34 [326930]
        //TaskQueue2.SETCURRENTKEY("Task Worker Group","Assigned to Service Inst.ID","Assigned to Session ID",Enabled,Company,"Next Run time");
        TaskQueue2.SetCurrentKey("Assigned to Service Inst.ID","Assigned to Session ID",Enabled,"Task Worker Group", Company,"Next Run time");
        //+TQ1.34 [326930]
        //+NPR5.45 [313269]

        TaskQueue2.SetRange(Company, TaskWorker."Current Company");
        TaskQueue2.SetRange("Assigned to Service Inst.ID", ServiceInstanceId);
        TaskQueue2.SetRange("Assigned to Session ID", SessionId);
        if TaskQueue2.FindFirst then begin
          TaskQueue := TaskQueue2;
          exit(true);
        end;

        exit(false);
    end;

    procedure CodeManualRun(TaskLineParm: Record "Task Line")
    var
        TaskQueueProcessor: Codeunit "Task Queue Processor";
        TaskLine: Record "Task Line";
    begin
        //-TQ1.18.01
        TaskLine.Get(TaskLineParm."Journal Template Name", TaskLineParm."Journal Batch Name", TaskLineParm."Line No.");
        TaskQueueProcessor.CodeManualRun(TaskLine);
        //+TQ1.18.01
    end;
}


codeunit 6059904 "NPR Task Queue NAS Login"
{
    // TQ1.18/MH  /20141110 CASE 198170 Max No. Of Active Task Workers is managed by each Group instead of only the Master Group.
    // TQ1.24/JDH /20150317 CASE 209090 added function CheckHeartBeatForSessions
    // TQ1.25/MH  /20150410 CASE 210797 Changed sequence of Task Queue:
    //                                  - Oldest Tasks are started first
    //                                  - The age of a task is calculated in the function CalcExpectedRuntime()
    //                                  - At most 1 Task Worker per group is started in each company
    // TQ1.27/MH  /20150727 CASE 219301 Wait time is always initialized to 1 sec
    // TQ1.28/RMT /20150807 CASE 219795 Added function LoginService (moved from codeunit 6059901)
    // TQ1.29/MHA /20160923 CASE 253201 Deleted function CalcExpectedRuntime(), thus disabling Priority Management
    // TQ1.29/JDH /20161101 CASE 242044 Restructured code to gain better performance and to seperate functionality more clearly
    // TQ1.30/MHA /20170420 CASE 272741 Prevent 0ms Sleep interval
    // TQ1.31/BR  /20171109  CASE 295987 Retry if session cannot be started
    // TQ1.31/MHA /20170912  CASE 298741 If NAS Nst restarts then SERVICEINSTANCEID is different from dead Task Workers and they may still exist in Active Session
    // TQ1.31/MMV /20180119  CASE 300683 Skip webservice clienttype in subscriber.
    // NPR5.38/LS  /20171218 CASE 300124 Set property OnMissingLicense to Skip for function OnCompanyCloseSubscriber
    // NPR5.38/MMV /20180119 CASE 300683 Skip subscriber when installing extension
    // TQ1.32/TJ  /20180305 CASE 305190 Commented usage of codeunit 6014425
    // TQ1.32/MHA /20180405  CASE 310092 Added Try-function TryStartSession() to avoid crash when STARTSESSION fails
    // NPR5.45/JDH /20180508 CASE 313269 SELECTLATESTVERSION removed, since its only possible to have 1 Master Thread (and thereby everything is on 1 NST)
    // NPR5.45/MHA /20180829  CASE 326707 Replaced outer LOCKTABLE with inner to reduce the number of locked records in CheckHeartBeatForWorkers()
    // TQ1.34/JDH /20181011 CASE 326930  Restructured code, and made several new support functions for better readability
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit
    // TQ1.35/MHA /20190613  CASE 358261 Adjusted Loop in StartTaskWorkers() as first Task would be skipped for all companies after first company


    trigger OnRun()
    begin
        //-TQ1.34 [326930]
        //MasterThreadLoop('');
        MaxMilisecondsSleep := 10000;
        MinSleepTime := 1000 * 10; //min 10 sec between master check
        MaxSleepTime := 1000 * 60; //max 1 min between master check
        HeartBeatCheckInterval := 1000 * 60 * 5; //check every 5 min
        LastCheckTime := CurrentDateTime;

        LoginMaster(MinSleepTime); //has COMMIT

        MasterThreadLoop2();
        //+TQ1.34 [326930]
    end;

    var
        LastCheckTime: DateTime;
        HeartBeatCheckInterval: Duration;
        TaskWorker2: Record "NPR Task Worker";
        TextErrorStartingSession: Label 'Error starting session (%1 attempts).';
        TextLastError: Label 'Last error: %2';
        TextNoLastError: Label 'No cause could be determined. Please check the logs on NST server %2';
        TextUnknown: Label 'Unknown. Error in callstack: %1';
        MaxMilisecondsSleep: Integer;
        MinSleepTime: Integer;
        MaxSleepTime: Integer;

    procedure MasterThreadLoop(NasID: Text[250])
    begin
        //-TQ1.34 [326930]
        // MilisecondsBetweenPolls := 1000;
        //
        // LoginMaster(MilisecondsBetweenPolls); //has COMMIT
        //
        // //-TQ1.29
        // HeartBeatCheckInterval := 1000 * 60 * 5; //check every 5 min
        // //+TQ1.29
        //
        // WHILE TRUE DO BEGIN
        //  taskQueueMgt.HeartBeat; //has COMMIT
        //
        //  //-TQ1.29
        //  //CheckHeartBeatForSessions;
        //  CheckWorkers;
        //  //+TQ1.29
        //
        //  TaskWorker2.GET(SERVICEINSTANCEID, SESSIONID);
        //  IF TaskWorker2.Active THEN BEGIN
        //    TaskWorkerGroup.SETFILTER("Max. Concurrent Threads",'>%1',0);
        //    IF TaskWorkerGroup.FindSet() THEN REPEAT
        //      TaskWorkerGroup.CALCFIELDS("No. of Active Threads");
        //      AvailableWorkers := TaskWorkerGroup."Max. Concurrent Threads" - TaskWorkerGroup."No. of Active Threads";
        //      IF AvailableWorkers > 0 THEN
        //        IF FindPendingTasks(TaskWorkerGroup.Code,TempTaskQueue) THEN
        //          StartTaskWorkers(AvailableWorkers,TempTaskQueue);
        //    UNTIL TaskWorkerGroup.Next() = 0;
        //  END;
        //  //-TQ1.29
        //  //CLEARALL;
        //  //+TQ1.29
        //  MaxMilisecondsSleep := 10000;
        //  MilisecondsBetweenPolls := (MilisecondsBetweenPolls * 2) MOD (1000 * 60);
        //  //-TQ1.30 [272741]
        //  IF MilisecondsBetweenPolls = 0 THEN
        //    MilisecondsBetweenPolls := 1000 * 60;
        //  //+TQ1.30 [272741]
        //  IF TempTaskQueue.FindFirst() THEN
        //    MilisecondsBetweenPolls := 1000;
        //  FOR Count := 1 TO MilisecondsBetweenPolls DIV MaxMilisecondsSleep DO
        //    SLEEP(MaxMilisecondsSleep);
        //  SLEEP(MilisecondsBetweenPolls MOD MaxMilisecondsSleep);
        // END;
        //+TQ1.34 [326930]
    end;

    procedure MasterThreadLoop2()
    var
        TaskWorkerGroup: Record "NPR Task Worker Group";
        TempTaskQueue: Record "NPR Task Queue" temporary;
        taskQueueMgt: Codeunit "NPR Task Queue Manager";
        AvailableWorkers: Integer;
        "Count": Integer;
        MilisecondsBetweenPolls: Integer;
    begin
        //-TQ1.34 [326930]
        MilisecondsBetweenPolls := MinSleepTime;
        while true do begin
            CheckWorkers();

            TaskWorker2.Get(ServiceInstanceId(), SessionId());
            if TaskWorker2.Active then begin
                TaskWorkerGroup.SetFilter("Max. Concurrent Threads", '>%1', 0);
                if TaskWorkerGroup.FindSet() then
                    repeat
                        TaskWorkerGroup.CalcFields("No. of Active Threads");
                        AvailableWorkers := TaskWorkerGroup."Max. Concurrent Threads" - TaskWorkerGroup."No. of Active Threads";
                        if AvailableWorkers > 0 then
                            if FindPendingTasks(TaskWorkerGroup.Code, TempTaskQueue) then
                                StartTaskWorkers(AvailableWorkers, TempTaskQueue);
                    until TaskWorkerGroup.Next() = 0;
            end;
            CalcSleepTime(MilisecondsBetweenPolls);

            //making sure that any table locks are removed before sleeping, and update the interval between cheks
            taskQueueMgt.HeartBeat(MilisecondsBetweenPolls); //has COMMIT

            for Count := 1 to MilisecondsBetweenPolls div MaxMilisecondsSleep do
                Sleep(MaxMilisecondsSleep);
            Sleep(MilisecondsBetweenPolls mod MaxMilisecondsSleep);
        end;
        //+TQ1.34 [326930]
    end;

    local procedure StartTaskWorkers(var AvailableWorkers: Integer; var TempTaskQueue: Record "NPR Task Queue" temporary)
    begin
        if AvailableWorkers < 0 then
            exit;
        Clear(TempTaskQueue);
        if not TempTaskQueue.FindSet() then
            exit;

        TempTaskQueue.SetCurrentKey("Next Run time");
        //-TQ1.35 [358261]
        while TempTaskQueue.FindFirst() and (AvailableWorkers >= 1) do begin
            if StartTaskWorker(TempTaskQueue) then
                AvailableWorkers -= 1;

            TempTaskQueue.SetRange(Company, TempTaskQueue.Company);
            TempTaskQueue.DeleteAll();
            TempTaskQueue.SetRange(Company);
        end;
        //+TQ1.35 [358261]
    end;

    procedure StartTaskWorker(TaskQueue: Record "NPR Task Queue"): Boolean
    var
        Company: Record Company;
        TaskWorker: Record "NPR Task Worker";
        TaskLogMaster: Record "NPR Session Log";
        StartAttempt: Integer;
        Started: Boolean;
        ErrorMessage: Text;
        ActiveSession: Record "Active Session";
    begin
        if not Company.Get(TaskQueue.Company) then begin
            TaskQueue.Delete();
            exit;
        end;

        //check if a thread is already started from this session in Task Worker
        //-NPR5.45 [313269]
        //SELECTLATESTVERSION;
        //+NPR5.45 [313269]

        TaskWorker.Reset();
        TaskWorker.SetRange("Current Company", TaskQueue.Company);
        TaskWorker.SetRange("Task Worker Group", TaskQueue."Task Worker Group");
        if TaskWorker.FindLast() then //force read lock
            exit;

        //-TQ1.29
        TaskLogMaster.LogStartSession(TaskWorker2, TaskQueue);
        //+TQ1.29
        //Start a task Manager thread
        //-TQ1.31 [295987]
        //STARTSESSION(Session ,CODEUNIT::"Task Queue Manager", TaskQueue.Company, TaskQueue);
        StartAttempt := 0;
        repeat
            StartAttempt := StartAttempt + 1;
            if StartAttempt > 1 then
                Sleep(10000);
            //-TQ1.32 [310092]
            //Started := STARTSESSION(Session ,CODEUNIT::"Task Queue Manager", TaskQueue.Company, TaskQueue);
            Started := TryStartSession(TaskQueue);
        //+TQ1.32 [310092]
        until Started or (StartAttempt >= 3);
        if not Started then begin
            TaskLogMaster.Get(TaskLogMaster.LogStartSession(TaskWorker2, TaskQueue));
            TaskLogMaster."Log Type" := TaskLogMaster."Log Type"::ErrorStartingTread;
            ErrorMessage := GetLastErrorText;
            if ErrorMessage = '' then begin
                ErrorMessage := GetLastErrorCallstack;
                if ErrorMessage <> '' then
                    ErrorMessage := StrSubstNo(TextUnknown, ErrorMessage);
            end;
            if ErrorMessage = '' then begin
                ActiveSession.Get(ServiceInstanceId(), SessionId());
                TaskLogMaster."Error Message" := CopyStr(StrSubstNo(TextErrorStartingSession + ' ' + TextNoLastError, StartAttempt, ActiveSession."Server Computer Name"), 1, MaxStrLen(TaskLogMaster."Error Message"));
            end else
                TaskLogMaster."Error Message" := CopyStr(StrSubstNo(TextErrorStartingSession + ' ' + TextLastError, StartAttempt, ErrorMessage), 1, MaxStrLen(TaskLogMaster."Error Message"));
            TaskLogMaster.Modify();
            Commit();
            //-TQ1.32 [310092]
            //STARTSESSION(Session ,CODEUNIT::"Task Queue Manager", TaskQueue.Company, TaskQueue);
            if TryStartSession(TaskQueue) then;
            //+TQ1.32 [310092]
        end;
        //+TQ1.31 [295987]
        //SLEEP(1000);
        //SLEEP(50);
        exit(true);
    end;

    [TryFunction]
    local procedure TryStartSession(TaskQueue: Record "NPR Task Queue")
    var
        NewSessionId: Integer;
    begin
        //-TQ1.32 [310092]
        if not StartSession(NewSessionId, CODEUNIT::"NPR Task Queue Manager", TaskQueue.Company, TaskQueue) then
            Error('TryStartSession() failed in Codeunit 6059904');
        //+TQ1.32 [310092]
    end;

    local procedure FindPendingTasks(TaskWorkerGroupCode: Code[10]; var TempTaskQueue: Record "NPR Task Queue" temporary): Boolean
    var
        TaskQueue: Record "NPR Task Queue";
        RecRef: RecordRef;
        Timestamp: DateTime;
    begin
        RecRef.GetTable(TempTaskQueue);
        if not RecRef.IsTemporary then
            exit(false);

        TempTaskQueue.DeleteAll();

        Timestamp := CurrentDateTime;
        //-TQ1.34 [326930]
        //TaskQueue.SETCURRENTKEY("Task Worker Group","Assigned to Service Inst.ID","Assigned to Session ID",Enabled,Company,"Next Run time");
        TaskQueue.SetCurrentKey("Assigned to Service Inst.ID", "Assigned to Session ID", Enabled, "Task Worker Group", Company, "Next Run time");
        //+TQ1.34 [326930]
        TaskQueue.SetRange("Assigned to Service Inst.ID", 0);
        TaskQueue.SetRange("Assigned to Session ID", 0);
        TaskQueue.SetRange(Enabled, true);
        TaskQueue.SetRange("Task Worker Group", TaskWorkerGroupCode);
        TaskQueue.SetRange("Next Run time", 0DT, Timestamp);
        if TaskQueue.FindSet() then
            repeat
                TempTaskQueue.Init();
                TempTaskQueue := TaskQueue;
                //-TQ1.29 [253201]
                //TempTaskQueue."Next Run time" := CalcExpectedRuntime(Timestamp,TaskQueue);
                //-TQ1.29 [253201]
                TempTaskQueue.Insert();
            until TaskQueue.Next() = 0;

        exit(TempTaskQueue.FindSet());
    end;

    procedure LoginMaster(MilisecondsBetweenPolls: Integer)
    var
        TaskWorker: Record "NPR Task Worker";
        ActiveSession: Record "Active Session";
        TaskLogMaster: Record "NPR Session Log";
    begin
        if not TaskWorker.Get(ServiceInstanceId(), SessionId()) then begin
            TaskWorker.LockTable();
            if TaskWorker.FindLast() then; //force a read lock

            ActiveSession.Get(ServiceInstanceId(), SessionId());

            TaskWorker.Init();
            TaskWorker."Server Instance ID" := ActiveSession."Server Instance ID";
            TaskWorker."User ID" := ActiveSession."User ID";
            TaskWorker."Session ID" := ActiveSession."Session ID";
            TaskWorker."Login Time" := ActiveSession."Login Datetime";
            TaskWorker."Current Company" := CompanyName;
            TaskWorker."Application Name" := ActiveSession."Server Computer Name";
            TaskWorker."DB Name" := ActiveSession."Database Name";
            TaskWorker."Host Name" := ActiveSession."Client Computer Name";
            TaskWorker."Task Worker Group" := 'MASTER';
            TaskWorker."Current Check Interval" := MilisecondsBetweenPolls;
            TaskWorker."Current Language ID" := GlobalLanguage;
            TaskWorker.Active := true;
            TaskWorker.Insert();
        end;

        TaskLogMaster.AddLogin(TaskWorker);
        Commit();
    end;

    local procedure CheckWorkers()
    var
        ActiveSession: Record "Active Session";
    begin
        //-TQ1.29
        if not ActiveSession.ReadPermission then
            exit;

        //-TQ1.34 [326930]
        //IF (LastCheckTime > (CURRENTDATETIME - HeartBeatCheckInterval)) THEN
        //  EXIT;

        //LastCheckTime := CURRENTDATETIME;
        if CheckIfWorkerUpdateIsUnnecessary(LastCheckTime) then
            exit;
        //+TQ1.34 [326930]

        CleanUpDeadWorkers();
        CheckHeartBeatForWorkers();
        //+TQ1.29
    end;

    local procedure CheckIfWorkerUpdateIsUnnecessary(var LastCheckTime: DateTime): Boolean
    var
        NPRTaskWorker2: Record "NPR Task Worker";
    begin
        //-TQ1.34 [326930]
        if (LastCheckTime > (CurrentDateTime - HeartBeatCheckInterval)) then
            exit(true);


        NPRTaskWorker2.SetCurrentKey("Last HeartBeat (When Idle)");
        NPRTaskWorker2.SetRange("Last HeartBeat (When Idle)", 0DT, LastCheckTime);

        LastCheckTime := CurrentDateTime;

        exit(NPRTaskWorker2.IsEmpty());
        //+TQ1.34 [326930]
    end;

    procedure CheckHeartBeatForWorkers()
    var
        TaskWorker: Record "NPR Task Worker";
        ActiveSession: Record "Active Session";
    begin
        //-TQ1.29
        //HeartBeatCheckInterval := 1000 * 60 * 5; //check every 5 min

        //TaskWorker.SETRANGE("Last HeartBeat (When Idle)", CREATEDATETIME(010101D,0T), CURRENTDATETIME - HeartBeatCheckInterval);
        //-NPR5.45 [326707]
        // TaskWorker.LockTable();
        //+NPR5.45 [326707]
        //+TQ1.29

        if TaskWorker.FindSet() then
            repeat
                if ActiveSession.Get(TaskWorker."Server Instance ID", TaskWorker."Session ID") then begin
                    //-NPR5.45 [326707]
                    // TaskWorker."Last HeartBeat (When Idle)" := CURRENTDATETIME;
                    // TaskWorker.Modify();
                    TaskWorker.LockTable();
                    if TaskWorker.Get(TaskWorker."Server Instance ID", TaskWorker."Session ID") then begin
                        TaskWorker."Last HeartBeat (When Idle)" := CurrentDateTime;
                        TaskWorker.Modify();
                    end;
                    Commit()
                    //+NPR5.45 [326707]
                    //-TQ1.29
                    //  Commit();
                    //END ELSE
                end;
            //  taskQueueMgt.Logout(TaskWorker."Server Instance ID", TaskWorker."Session ID");
            //+TQ1.29
            until TaskWorker.Next() = 0;
        //-TQ1.29
        Commit();
        //+TQ1.29
    end;

    local procedure CleanUpDeadWorkers()
    var
        TaskWorker: Record "NPR Task Worker";
        ActiveSession: Record "Active Session";
        taskQueueMgt: Codeunit "NPR Task Queue Manager";
    begin
        //-TQ1.29
        if TaskWorker.FindSet() then
            repeat
                if (not ActiveSession.Get(TaskWorker."Server Instance ID", TaskWorker."Session ID")) or (ActiveSession."User ID" <> TaskWorker."User ID") or
                  //-TQ1.31 [298741]
                  (TaskWorker."Server Instance ID" <> ServiceInstanceId()) then
                    //+TQ1.31 [298741]
                    //the session doesnt exists any more -> delete it
                    taskQueueMgt.Logout(TaskWorker."Server Instance ID", TaskWorker."Session ID");
            until TaskWorker.Next() = 0;
        //+TQ1.29
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterCompanyClose', '', true, false)]
    local procedure OnCompanyCloseSubscriber()
    var
        TaskWorker: Record "NPR Task Worker";
        TaskLogMaster: Record "NPR Session Log";
    begin
        //-TQ1.29
        //Only NAS needs to be logged
        //-TQ1.31 [300683]
        // IF GUIALLOWED THEN
        //  EXIT;

        //-NPR5.45 [305190]
        /*
        //-NPR5.38 [300683]
        IF NavAppMgt.NavAPP_IsInstalling THEN
          EXIT;
        //+NPR5.38 [300683]
        */
        //+NPR5.45 [305190]

        if not (CurrentClientType in [CLIENTTYPE::NAS, CLIENTTYPE::Background]) then
            exit;
        //+TQ1.31 [300683]

        if TaskWorker.Get(ServiceInstanceId(), SessionId()) then begin
            if TaskWorker."Task Worker Group" <> 'MASTER' then
                exit;

            TaskLogMaster.AddLogout(TaskWorker);
            TaskWorker.Delete();
        end;
        //+TQ1.29

    end;

    local procedure CalcSleepTime(var MilisecondsBetweenPolls: Integer)
    var
        TaskQueue: Record "NPR Task Queue";
    begin
        //-TQ1.34 [326930]
        MilisecondsBetweenPolls := (MilisecondsBetweenPolls * 2);

        TaskQueue.SetCurrentKey("Next Run time");
        TaskQueue.SetRange("Next Run time", 0DT, CurrentDateTime);
        if not TaskQueue.IsEmpty then
            MilisecondsBetweenPolls := MinSleepTime;

        if MilisecondsBetweenPolls > MaxSleepTime then
            MilisecondsBetweenPolls := MaxSleepTime;
        //+TQ1.34 [326930]
    end;
}


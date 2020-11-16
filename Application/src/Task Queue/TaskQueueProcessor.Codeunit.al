codeunit 6059902 "NPR Task Queue Processor"
{
    // TQ1.16/JDH /20140916 CASE 179044 Alignment of code for 2013 upgrade
    // TQ1.17/JDH /20141015 CASE 179044 New function to execute a task manually - used to log which user that has executed it
    // TQ1.19/JDH /20141201 CASE 199884 Bugfix in the calculation of a task beeing valid, if it crosses midnight
    // TQ1.21/JDH /20141218 CASE 200355 Calculation of next runtime after an error recovery changed to find next runtime correct
    // TQ1.24/JDH /20150320 CASE 209090 Possible to set the language on the task line
    // TQ1.25/JDH /20150504 CASE 210797 Changed function call parameters to set the next runtime
    // TQ1.28/RMT /20150807 CASE 219795 Added explicit locking and release for tables to ensure no deadlock or mutable updates
    //                                  scope of record variables changed to reduce lock times and update fails
    //                                  removed function InsertNextRunTime - code inlined in "Code" function
    // TQ1.29/JDH /20161101 CASE 242044 Deleted old outcommented code + Restructured functions a bit
    // NPR5.45/JDH /20180508 CASE 314491 Task Queue failure if "Next run time" is blank
    // TQ1.33/MHA /20180917 CASE 327207 "Recurrence Calc. Interval" = 0 results in infinite loop
    // TQ1.34/JDH /20181011 CASE 326930 Locking of Task Queue

    TableNo = "NPR Task Queue";

    trigger OnRun()
    var
        TaskQueue: Record "NPR Task Queue";
    begin
        TaskQueue := Rec;
        Code(TaskQueue);
        Rec := TaskQueue;
    end;

    var
        Text001: Label 'This task is not scheduled to run at this time. Do You wish to run it anyway?';
        TaskLogEntryNo: Integer;

    procedure "Code"(TaskQueue: Record "NPR Task Queue")
    var
        TaskLine: Record "NPR Task Line";
        TaskLog: Record "NPR Task Log (Task)";
        TaskQueueExecute: Codeunit "NPR Task Queue Execute";
        TaskQueueAdd2Log: Codeunit "NPR Task Queue: SingleInstance";
        MailTaskStatus: Codeunit "NPR Mail Task Status";
        CurrExecRunTime: DateTime;
        NextRunTime: DateTime;
        TaskExecuted: Boolean;
        NewEnabled: Boolean;
        Success: Boolean;
        LastCheckInterval: Integer;
        CurrLangID: Integer;
    begin
        TaskLine.Get(TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");

        if not CheckValid2RunNow(TaskLine, TaskQueue) then begin
            //Calculate a new runtime and stop executing the task now
            NextRunTime := CalculateNextRunTime(TaskLine, false, NewEnabled);
            TaskLine.Enabled := NewEnabled;
            TaskLine.Modify;

            //-TQ1.34 [326930]
            TaskQueue.LockTable;
            //+TQ1.34 [326930]
            TaskQueue.Get(TaskQueue.Company, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
            TaskQueue."Next Run time" := NextRunTime;
            TaskQueue."Estimated Duration" := TaskLine.GetExpectedDuration;
            TaskQueue.Validate(Status, TaskQueue.Status::Awaiting);
            TaskQueue.Modify;

            TaskLog.AddMovedTask(TaskQueue, TaskLine);
            Commit;
            exit;
        end;

        StartTask(TaskQueue, TaskLine);  //Has a COMMIT

        if not MailTaskStatus.Run(TaskLine) then begin
            TaskLog.AddLogOtherFailure(TaskQueue, TaskLine);
            Commit;
        end;

        if (TaskLine."Language ID" <> 0) and (TaskLine."Language ID" <> GlobalLanguage) then
            CurrLangID := GlobalLanguage;

        Success := TaskQueueExecute.Run(TaskLine);

        //(If the task is failing - how would the language react? -> safety precaution to set the language Back to std
        if (CurrLangID <> 0) and (CurrLangID <> GlobalLanguage) then
            GlobalLanguage := CurrLangID;

        //force an update of TaskQueue and TaskLine record - if somebody else have changed them during execution
        TaskQueue.Get(TaskQueue.Company, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
        TaskLine.Get(TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
        CurrExecRunTime := TaskQueue."Next Run time";

        NextRunTime := CalculateNextRunTime(TaskLine, Success, NewEnabled);
        if TaskLine.Enabled <> NewEnabled then begin
            TaskLine.Validate(Enabled, NewEnabled); //Update Task Queue line
            TaskLine.Modify;
            //-TQ1.29
            TaskQueue.Get(TaskQueue.Company, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
            //+TQ1.29
        end;

        //-TQ1.34 [326930]
        TaskQueue.LockTable;
        TaskQueue.Get(TaskQueue.Company, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
        //+TQ1.34 [326930]
        TaskQueue."Next Run time" := NextRunTime;
        TaskQueue."Estimated Duration" := TaskLine.GetExpectedDuration;
        TaskQueue.Modify;
        //-TQ1.34 [326930]
        Commit;
        //+TQ1.34 [326930]
        InsertChildrensInTaskQueue(TaskLine, Success);

        EndTask(TaskLine, TaskQueue, Success, CurrExecRunTime); //Has a COMMIT

        if not MailTaskStatus.Run(TaskLine) then begin
            TaskLog.AddLogOtherFailure(TaskQueue, TaskLine);
            Commit;
        end;

        if Success then begin
            if TaskLine."Error Counter" <> 0 then begin
                TaskLine."Error Counter" := 0;
                TaskLine.Modify;
            end;
        end else begin
            TaskLine."Error Counter" += 1;
            TaskLine.Modify;
        end;

        //-TQ1.29
        TaskQueueAdd2Log.SetCurrentLogEntryNo(0);
        //+TQ1.29
    end;

    procedure CodeManualRun(TaskLineParm: Record "NPR Task Line")
    var
        TaskQueue: Record "NPR Task Queue";
        TaskLine: Record "NPR Task Line";
        TaskLog: Record "NPR Task Log (Task)";
        TaskQueueExecute: Codeunit "NPR Task Queue Execute";
        TaskQueueAdd2Log: Codeunit "NPR Task Queue: SingleInstance";
        CurrExecRunTime: DateTime;
        Success: Boolean;
    begin
        TaskQueue.Get(CompanyName, TaskLineParm."Journal Template Name", TaskLineParm."Journal Batch Name",
                      TaskLineParm."Line No.");
        TaskQueue.TestField(Status, TaskQueue.Status::Awaiting);
        TaskLine.Get(TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");

        if not CheckValid2RunNow(TaskLine, TaskQueue) then begin
            if not Confirm(Text001) then
                exit;
        end;

        StartTask(TaskQueue, TaskLine);  //Has a COMMIT

        Success := TaskQueueExecute.Run(TaskLine);

        //force an update of TaskQueue and TaskLine record - if somebody else have changed them during execution
        TaskQueue.Get(TaskQueue.Company, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
        TaskLine.Get(TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
        CurrExecRunTime := TaskQueue."Next Run time";

        EndTask(TaskLine, TaskQueue, Success, CurrExecRunTime); //Has a COMMIT

        if not Success then
            if TaskLog.Get(TaskQueue."Last Task Log Entry No.") then
                Error(TaskLog."Last Error Message");

        //-TQ1.29
        TaskQueueAdd2Log.SetCurrentLogEntryNo(0);
        //+TQ1.29
    end;

    procedure StartTask(var TaskQueue: Record "NPR Task Queue"; TaskLine: Record "NPR Task Line")
    var
        TaskLog: Record "NPR Task Log (Task)";
        TaskQueueManager: Codeunit "NPR Task Queue Manager";
    begin
        TaskQueue.LockTable;
        TaskQueue.Get(TaskQueue.Company, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
        TaskQueue.Validate(Status, TaskQueue.Status::Started);
        TaskQueue.Modify;

        TaskLogEntryNo := TaskLog.AddLogInit(TaskQueue, TaskLine);
        //-TQ1.29
        //TaskQueueManager.SetCurrentLogEntryNo(TaskLogEntryNo);
        //+TQ1.29

        Commit;
    end;

    procedure EndTask(TaskLine: Record "NPR Task Line"; TaskQueue: Record "NPR Task Queue"; Success: Boolean; CurrExecRunTime: DateTime)
    var
        TaskLog: Record "NPR Task Log (Task)";
        TaskQueueAdd2Log: Codeunit "NPR Task Queue: SingleInstance";
    begin
        TaskQueue.LockTable;
        if (TaskLine.Recurrence = TaskLine.Recurrence::None) or (TaskQueue."Next Run time" = 0DT) then
            TaskQueue.Delete(true)
        else begin
            TaskQueue.Validate(Status, TaskQueue.Status::Awaiting);
            //-TQ1.29
            TaskQueue."Last Task Log Entry No." := TaskQueueAdd2Log.GetCurrentLogEntryNo;
            //+TQ1.29

            if Success then begin
                TaskQueue."Last Successfull Run" := CurrExecRunTime;
                TaskQueue."Last Execution Status" := TaskQueue."Last Execution Status"::Succes;
            end else
                TaskQueue."Last Execution Status" := TaskQueue."Last Execution Status"::Error;
            TaskQueue.Modify;
        end;
        TaskLog.AddLogFinal(TaskQueue, Success, TaskLogEntryNo);
        Commit;
    end;

    procedure CheckValid2RunNow(TaskLine: Record "NPR Task Line"; TaskQueue: Record "NPR Task Queue"): Boolean
    var
        ProposedTime: Time;
    begin
        with TaskLine do begin
            if Indentation > 0 then
                exit(true);
            //-NPR5.45 [314491]
            if TaskQueue."Next Run time" <> 0DT then
                //+NPR5.45 [314491]
                //weekday check
                case Date2DWY(DT2Date(TaskQueue."Next Run time"), 1) of
                    1:
                        if not "Run on Monday" then
                            exit(false);
                    2:
                        if not "Run on Tuesday" then
                            exit(false);
                    3:
                        if not "Run on Wednesday" then
                            exit(false);
                    4:
                        if not "Run on Thursday" then
                            exit(false);
                    5:
                        if not "Run on Friday" then
                            exit(false);
                    6:
                        if not "Run on Saturday" then
                            exit(false);
                    7:
                        if not "Run on Sunday" then
                            exit(false);
                end;

            //time check
            if ("Valid After" <> 0T) and ("Valid Until" <> 0T) then begin
                if "Valid After" < "Valid Until" then begin
                    //not crossing midnight
                    if (Time < "Valid After") or
                       (Time > "Valid Until") then
                        exit(false);
                end else begin
                    //crossing midnight
                    if (Time < "Valid After") and
                       (Time > "Valid Until") then
                        exit(false);
                end;
            end;

        end;
        exit(true);
    end;

    procedure CalculateNextRunTime(TaskLine: Record "NPR Task Line"; Succesfull: Boolean; var NewEnabled: Boolean): DateTime
    var
        TaskQueue: Record "NPR Task Queue";
        CurrDate: Date;
        CurrTime: Time;
        NextDateTime: DateTime;
        NoOfPassedIntervals: Integer;
    begin
        //use currtaskqueue to get starting time.
        //calculate the new starting time based upon this info
        //check if new date is valid according to setup
        //repeat until a valid date
        //save to log

        NewEnabled := true;
        TaskQueue.Get(CompanyName, TaskLine."Journal Template Name", TaskLine."Journal Batch Name", TaskLine."Line No.");

        with TaskLine do begin
            if Indentation > 0 then
                exit;

            //temp fix to update existing cust
            if "Recurrence Calc. Interval" = 0 then
                "Recurrence Calc. Interval" := "Recurrence Interval";
            //-TQ1.33 [327207]
            if "Recurrence Calc. Interval" = 0 then
                "Recurrence Calc. Interval" := 1000 * 60;
            //+TQ1.33 [327207]

            if Succesfull or ("Retry Interval (On Error)" = 0) then begin
                case "Recurrence Method" of
                    "Recurrence Method"::Static:
                        begin
                            case Recurrence of
                                Recurrence::" ":
                                    begin
                                        NewEnabled := false;
                                        TaskQueue.Get(CompanyName, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
                                    end;
                                Recurrence::Hourly,
                                Recurrence::Daily,
                                Recurrence::Weekly,
                                Recurrence::Custom:
                                    begin
                                        if Succesfull and (TaskLine."Error Counter" <> 0) and (TaskQueue."Last Successfull Run" <> 0DT) then begin
                                            //calculate how many recurrence Intervals that have passed since last syccesfull run
                                            NoOfPassedIntervals := Round((CurrentDateTime - TaskQueue."Last Successfull Run") / "Recurrence Interval", 1, '<');
                                            NextDateTime := TaskQueue."Last Successfull Run" + ("Recurrence Interval" * (NoOfPassedIntervals + 1));
                                        end else
                                            NextDateTime := TaskQueue."Next Run time" + "Recurrence Interval";
                                        while not IsValidDate(TaskLine, NextDateTime, true) do begin
                                            NextDateTime := NextDateTime + "Recurrence Calc. Interval";
                                        end;
                                    end;
                                Recurrence::DateFormula:
                                    begin
                                        CurrDate := Today;
                                        repeat
                                            CurrDate := CalcDate(TaskLine."Recurrence Formula", CurrDate);
                                            NextDateTime := CreateDateTime(CurrDate, TaskLine."Recurrence Time");
                                        until IsValidDate(TaskLine, NextDateTime, true);
                                    end;
                                Recurrence::None:
                                    begin
                                        //not needed - will be deleted after job is finished
                                    end;
                            end;
                        end;
                    "Recurrence Method"::Dynamic:
                        begin
                            case Recurrence of
                                Recurrence::" ":
                                    begin
                                        NewEnabled := false;
                                        TaskQueue.Get(CompanyName, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
                                    end;
                                Recurrence::Hourly,
                                Recurrence::Daily,
                                Recurrence::Weekly,
                                Recurrence::Custom:
                                    begin
                                        NextDateTime := CurrentDateTime;
                                        repeat
                                            NextDateTime := NextDateTime + "Recurrence Calc. Interval";
                                        until IsValidDate(TaskLine, NextDateTime, true);
                                    end;
                                Recurrence::DateFormula:
                                    begin
                                        CurrDate := Today;
                                        repeat
                                            CurrDate := CalcDate(TaskLine."Recurrence Formula", CurrDate);
                                            NextDateTime := CreateDateTime(CurrDate, TaskLine."Recurrence Time");
                                        until IsValidDate(TaskLine, NextDateTime, true);
                                    end;
                                Recurrence::None:
                                    begin
                                        //not needed - will be deleted after job is finished
                                    end;
                            end;
                        end;
                end;
            end else begin
                if "Max No. Of Retries (On Error)" <> 0 then begin
                    if "Error Counter" < "Max No. Of Retries (On Error)" then begin
                        if "Recurrence Method" = "Recurrence Method"::Static then
                            NextDateTime := TaskQueue."Next Run time"
                        else
                            NextDateTime := CurrentDateTime;
                        repeat
                            NextDateTime := NextDateTime + "Retry Interval (On Error)";
                        until IsValidDate(TaskLine, NextDateTime, true);
                    end else begin
                        case "Action After Max. No. of Retri" of
                            "Action After Max. No. of Retri"::Reschedule2NextRuntime:
                                begin
                                    exit(CalculateNextRunTime(TaskLine, true, NewEnabled));
                                end;
                            "Action After Max. No. of Retri"::StopTask:
                                begin
                                    NewEnabled := false;
                                    TaskQueue.Get(CompanyName, TaskQueue."Task Template", TaskQueue."Task Batch", TaskQueue."Task Line No.");
                                end;
                        end;
                    end;
                end else begin
                    if "Recurrence Method" = "Recurrence Method"::Static then
                        NextDateTime := TaskQueue."Next Run time"
                    else
                        NextDateTime := CurrentDateTime;
                    if not IsValidDate(TaskLine, NextDateTime + "Retry Interval (On Error)", true) then
                        TestField("Retry Interval (On Error)");
                    repeat
                        NextDateTime := NextDateTime + "Retry Interval (On Error)";
                    until IsValidDate(TaskLine, NextDateTime, true);
                end;
            end;
        end;

        if NextDateTime = 0DT then
            NewEnabled := false;

        exit(NextDateTime);
    end;

    procedure IsValidDate(TaskLine: Record "NPR Task Line"; ProposedDateTime: DateTime; CheckTime: Boolean): Boolean
    var
        WeekdayNo: Integer;
        MonthNo: Integer;
        ProposedTime: Time;
    begin
        if ProposedDateTime = 0DT then
            exit(false);

        if ProposedDateTime < CurrentDateTime then
            exit(false);

        if ProposedDateTime > CreateDateTime(CalcDate('<+1Y+1D>'), 0T) then begin
            if GuiAllowed then
                Message('Cant Calculate a new date');
            exit(true); //make it stop
        end;

        with TaskLine do begin
            //weekday check
            case Date2DWY(DT2Date(ProposedDateTime), 1) of
                1:
                    if not "Run on Monday" then
                        exit(false);
                2:
                    if not "Run on Tuesday" then
                        exit(false);
                3:
                    if not "Run on Wednesday" then
                        exit(false);
                4:
                    if not "Run on Thursday" then
                        exit(false);
                5:
                    if not "Run on Friday" then
                        exit(false);
                6:
                    if not "Run on Saturday" then
                        exit(false);
                7:
                    if not "Run on Sunday" then
                        exit(false);
            end;

            //time check
            if (CheckTime) and ("Valid After" <> 0T) and ("Valid Until" <> 0T) then begin
                ProposedTime := DT2Time(ProposedDateTime);
                if "Valid After" < "Valid Until" then begin
                    //not crossing midnight
                    if (ProposedTime < "Valid After") or
                       (ProposedTime > "Valid Until") then
                        exit(false);

                end else begin
                    //crossing midnight
                    if (ProposedTime < "Valid After") and
                       (ProposedTime > "Valid Until") then
                        exit(false);
                end;
            end;

        end;
        exit(true);
    end;

    procedure InsertChildrensInTaskQueue(TaskLine: Record "NPR Task Line"; Success: Boolean)
    var
        TaskLine2: Record "NPR Task Line";
        MaxLineNo: Integer;
    begin
        TaskLine2.SetRange("Journal Template Name", TaskLine."Journal Template Name");
        TaskLine2.SetRange("Journal Batch Name", TaskLine."Journal Batch Name");
        TaskLine2.SetFilter("Line No.", '>%1', TaskLine."Line No.");
        TaskLine2.SetRange(Indentation, TaskLine.Indentation);
        if TaskLine2.FindFirst then
            MaxLineNo := TaskLine2."Line No."
        else begin
            TaskLine2.SetRange("Line No.");
            TaskLine2.SetRange(Indentation);
            TaskLine2.FindLast;
            MaxLineNo := TaskLine2."Line No.";
        end;
        TaskLine2.SetRange("Line No.", TaskLine."Line No." + 1, MaxLineNo);
        TaskLine2.SetRange(Indentation, TaskLine.Indentation + 1);
        if Success then
            TaskLine2.SetRange("Dependence Type", TaskLine2."Dependence Type"::Succes)
        else
            TaskLine2.SetRange("Dependence Type", TaskLine2."Dependence Type"::Error);

        if TaskLine2.FindSet then
            repeat
                if TaskLine2.Enabled then
                    TaskLine2.SetNextRuntime(CurrentDateTime, true);
            until TaskLine2.Next = 0;
    end;
}


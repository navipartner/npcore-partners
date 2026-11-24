codeunit 85565 "NPR JQ Run Window Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure AlignToRunWindow_NoWindow_Unchanged()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        AssertAligned(JobQueueEntry, 030000T, 0, 030000T);
        AssertAligned(JobQueueEntry, 235959T, 0, 235959T);
    end;

    [Test]
    procedure AlignToRunWindow_DayWindow()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SetWindow(JobQueueEntry, 040000T, 060000T);
        AssertAligned(JobQueueEntry, 020000T, 0, 040000T);
        AssertAligned(JobQueueEntry, 040000T, 0, 040000T);
        AssertAligned(JobQueueEntry, 050000T, 0, 050000T);
        AssertAligned(JobQueueEntry, 060000T, 0, 060000T);
        AssertAligned(JobQueueEntry, 060001T, 1, 040000T);
        AssertAligned(JobQueueEntry, 235959T, 1, 040000T);
    end;

    [Test]
    procedure AlignToRunWindow_WindowAcrossMidnight()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SetWindow(JobQueueEntry, 220000T, 020000T);
        AssertAligned(JobQueueEntry, 230000T, 0, 230000T);
        AssertAligned(JobQueueEntry, 010000T, 0, 010000T);
        AssertAligned(JobQueueEntry, 020001T, 0, 220000T);
        AssertAligned(JobQueueEntry, 120000T, 0, 220000T);
    end;

    [Test]
    procedure AlignToRunWindow_StartingTimeOnly()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SetWindow(JobQueueEntry, 080000T, 0T);
        AssertAligned(JobQueueEntry, 075959T, 0, 080000T);
        AssertAligned(JobQueueEntry, 200000T, 0, 200000T);

        SetWindow(JobQueueEntry, 080000T, 080000T);
        AssertAligned(JobQueueEntry, 075959T, 0, 080000T);
        AssertAligned(JobQueueEntry, 200000T, 0, 200000T);
    end;

    [Test]
    procedure AlignToRunWindow_EndingTimeOnly()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        SetWindow(JobQueueEntry, 0T, 180000T);
        AssertAligned(JobQueueEntry, 100000T, 0, 100000T);
        AssertAligned(JobQueueEntry, 190000T, 1, 000000T);
    end;

    [Test]
    procedure CalcInitialRunTime_ProtectedFormulaJobOutsideWindow_MovesToNextWindowStart()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        InitFormulaJob(TempJobQueueEntry, 040000T, 060000T);
        TempJobQueueEntry."NPR NP Protected Job" := true;
        // A PTE can switch NP protection off. The job is then not monitored and keeps the base scheduling.
        if JobQueueMgt.SkipUpdateNPManagedMonitoredJobs() then begin
            _Assert.AreEqual(At(0, 100000T), CalcInitialRunTime(TempJobQueueEntry, At(0, 100000T)), 'Without NP protection the job must keep the base scheduling.');
            exit;
        end;

        _Assert.AreEqual(At(1, 040000T), CalcInitialRunTime(TempJobQueueEntry, At(0, 100000T)), 'A protected daily job started after its window must wait for the next window.');
        _Assert.AreEqual(At(0, 040000T), CalcInitialRunTime(TempJobQueueEntry, At(0, 010000T)), 'A protected daily job started before its window must wait for the window to open.');
        _Assert.AreEqual(At(0, 050000T), CalcInitialRunTime(TempJobQueueEntry, At(0, 050000T)), 'A protected daily job started inside its window must keep its time.');
    end;

    [Test]
    procedure CalcInitialRunTime_ManagedByAppFormulaJobOutsideWindow_MovesToNextWindowStart()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
    begin
        InitFormulaJob(TempJobQueueEntry, 040000T, 060000T);
        TempJobQueueEntry.ID := CreateGuid();
        ManagedByAppJobQueue.ID := TempJobQueueEntry.ID;
        ManagedByAppJobQueue."Managed by App" := true;
        ManagedByAppJobQueue.Insert();

        _Assert.AreEqual(At(1, 040000T), CalcInitialRunTime(TempJobQueueEntry, At(0, 100000T)), 'A monitored custom daily job started after its window must wait for the next window.');
    end;

    [Test]
    procedure CalcInitialRunTime_UnmonitoredFormulaJob_KeepsBaseBehaviour()
    var
        TempJobQueueEntry: Record "Job Queue Entry" temporary;
    begin
        InitFormulaJob(TempJobQueueEntry, 040000T, 060000T);
        TempJobQueueEntry.ID := CreateGuid();

        _Assert.AreEqual(At(0, 100000T), CalcInitialRunTime(TempJobQueueEntry, At(0, 100000T)), 'Jobs that NP does not manage must keep the base scheduling.');
    end;

    [Test]
    procedure Restart_MonitoredFormulaJobOutsideWindow_IsScheduledAtNextWindowStart()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NextRunDateFormula: DateFormula;
        StartingTime: Time;
        ExpectedStart: DateTime;
    begin
        if Time() < 120000T then begin
            StartingTime := 180000T;
            ExpectedStart := CreateDateTime(Today(), StartingTime);
        end else begin
            StartingTime := 060000T;
            ExpectedStart := CreateDateTime(Today() + 1, StartingTime);
        end;
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR JQ Refresher Test Helper", UniqueParameterString(), '',
            CurrentDateTime(), StartingTime, StartingTime + 3600000, NextRunDateFormula, '', JobQueueEntry);
        ManagedByAppJobQueue.ID := JobQueueEntry.ID;
        ManagedByAppJobQueue."Managed by App" := true;
        ManagedByAppJobQueue.Insert();

        JobQueueEntry.Restart();

        JobQueueEntry.Find();
        _Assert.AreEqual(ExpectedStart, JobQueueEntry."Earliest Start Date/Time", 'A daily job restarted outside its window must be scheduled at the next window start instead of now.');
        TaskScheduler.CancelTask(JobQueueEntry."System Task ID");
    end;

    local procedure AssertAligned(JobQueueEntry: Record "Job Queue Entry"; RunTime: Time; ExpectedDayOffset: Integer; ExpectedTime: Time)
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        _Assert.AreEqual(At(ExpectedDayOffset, ExpectedTime), JobQueueMgt.AlignToRunWindow(JobQueueEntry, At(0, RunTime)),
            StrSubstNo('Run time %1 with window %2-%3', RunTime, JobQueueEntry."Starting Time", JobQueueEntry."Ending Time"));
    end;

    local procedure SetWindow(var JobQueueEntry: Record "Job Queue Entry"; StartingTime: Time; EndingTime: Time)
    begin
        JobQueueEntry."Starting Time" := StartingTime;
        JobQueueEntry."Ending Time" := EndingTime;
    end;

    local procedure InitFormulaJob(var TempJobQueueEntry: Record "Job Queue Entry" temporary; StartingTime: Time; EndingTime: Time)
    begin
        TempJobQueueEntry.Init();
        TempJobQueueEntry."Object Type to Run" := TempJobQueueEntry."Object Type to Run"::Codeunit;
        TempJobQueueEntry."Object ID to Run" := Codeunit::"NPR JQ Refresher Test Helper";
        TempJobQueueEntry."Recurring Job" := true;
        Evaluate(TempJobQueueEntry."Next Run Date Formula", '<1D>');
        SetWindow(TempJobQueueEntry, StartingTime, EndingTime);
    end;

    local procedure CalcInitialRunTime(var TempJobQueueEntry: Record "Job Queue Entry" temporary; StartingDateTime: DateTime): DateTime
    var
        JobQueueDispatcher: Codeunit "Job Queue Dispatcher";
    begin
        TempJobQueueEntry."Earliest Start Date/Time" := 0DT;
        exit(JobQueueDispatcher.CalcInitialRunTime(TempJobQueueEntry, StartingDateTime));
    end;

    local procedure At(DayOffset: Integer; TimeOfDay: Time): DateTime
    begin
        exit(CreateDateTime(DMY2Date(15, 1, 2030) + DayOffset, TimeOfDay));
    end;

    local procedure UniqueParameterString(): Text[250]
    begin
        exit(CopyStr('NPR-JQR-WIN-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 250));
    end;
}

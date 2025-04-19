codeunit 6014684 "NPR Schedule Invt. Cost Adj."
{
    Access = Internal;
    trigger OnRun()
    begin
        Schedule(true);
        //ScheduleBC18();
    end;

    local procedure Schedule(WithCheck: Boolean)
    var
        InventorySetup: Record "Inventory Setup";
        xInventorySetup: Record "Inventory Setup";
    begin
        if WithCheck then begin
            if not InventorySetup.Get() then
                InventorySetup.Init();
            xInventorySetup := InventorySetup;
            xInventorySetup."Automatic Cost Adjustment" := xInventorySetup."Automatic Cost Adjustment"::Always;
            xInventorySetup."Automatic Cost Posting" := true;
            if not ShouldBeScheduled(InventorySetup, xInventorySetup) then
                exit;
        end;
        SalesSetup.Get();
        JobQueueEntryGlobal.Reset();
        CreateAdjCostJobQueue();
        CreatePostInvCostToGLJobQueue();
    end;

    local procedure CreateAdjCostJobQueue()
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
    begin
        GetTimingParameters(NotBeforeDateTime, NextRunDateFormula);
        JobQueueMgt.SetJobTimeout(4, 0);  //4 hours
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntryGlobal."Object Type to Run"::Report,
            Report::"Adjust Cost - Item Entries",
            '',
            JobQueueDescription(JobQueueEntryGlobal."Object Type to Run"::Report, Report::"Adjust Cost - Item Entries"),
            NotBeforeDateTime,
            010000T,
            030000T,
            NextRunDateFormula,
            SalesSetup."Job Queue Category Code",
            JobQueueEntryGlobal)
        then begin
            JobQueueEntryGlobal.Mark(true);
            JobQueueMgt.StartJobQueueEntry(JobQueueEntryGlobal);
        end;
    end;

    local procedure CreatePostInvCostToGLJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        PostInventoryCosttoGL: Codeunit "NPR Post Inventory Cost to G/L";
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
        FoundExisting: Boolean;
        NoMoreEntries: Boolean;
    begin
        GetTimingParameters(NotBeforeDateTime, NextRunDateFormula);
        RemovedUnmanagedPostInvCostToGLJobQueues(NotBeforeDateTime);

        if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Post Inventory Cost to G/L") then
            repeat
                FoundExisting := not JobQueueEntry.IsExpired(NotBeforeDateTime);
                if not FoundExisting then
                    NoMoreEntries := JobQueueEntry.Next() = 0;
            until FoundExisting or NoMoreEntries;
        if not FoundExisting then
            JobQueueEntry."Parameter String" := CopyStr(PostInventoryCosttoGL.ParamSaveToReportInbox(), 1, MaxStrLen(JobQueueEntry."Parameter String"));

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Post Inventory Cost to G/L",
            JobQueueEntry."Parameter String",
            JobQueueDescription(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Post Inventory Cost to G/L"),
            NotBeforeDateTime,
            020000T,
            040000T,
            NextRunDateFormula,
            SalesSetup."Job Queue Category Code",
            JobQueueEntryGlobal)
        then begin
            JobQueueEntryGlobal.Mark(true);
            JobQueueMgt.StartJobQueueEntry(JobQueueEntryGlobal);
        end;
    end;

    local procedure AdjCostJobQueueExists(AtDateTime: DateTime): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        exit(JobQueueEntryExists(JobQueueEntryGlobal."Object Type to Run"::Report, Report::"Adjust Cost - Item Entries", AtDateTime, JobQueueEntry));
    end;

    local procedure RemovedUnmanagedPostInvCostToGLJobQueues(AtDateTime: DateTime)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntryExists(JobQueueEntryGlobal."Object Type to Run"::Report, Report::"Post Inventory Cost to G/L", AtDateTime, JobQueueEntry) then
            JobQueueEntry.Cancel();
#if not BC17
        if JobQueueEntryExists(JobQueueEntryGlobal."Object Type to Run"::Codeunit, Codeunit::"Post Inventory Cost to G/L", AtDateTime, JobQueueEntry) then
            JobQueueEntry.Cancel();
#endif
    end;

    local procedure JobQueueEntryExists(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; AtDateTime: DateTime; var JobQueueEntryOut: Record "Job Queue Entry"): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        Clear(JobQueueEntryOut);
        JobQueueEntry."Object Type to Run" := ObjectTypeToRun;
        JobQueueEntry.Validate("Object ID to Run", ObjectIdToRun);
        JobQueueEntry."Earliest Start Date/Time" := AtDateTime;
        if not JobQueueMgt.JobQueueEntryExists(JobQueueEntry, JobQueueEntryGlobal) then
            exit(false);
        JobQueueEntryOut := JobQueueEntryGlobal;

        exit(not (JobQueueEntryOut.Status in [JobQueueEntryOut.Status::"On Hold", JobQueueEntryOut.Status::Error]));
    end;

    local procedure GetTimingParameters(var NotBeforeDateTime: DateTime; var NextRunDateFormula: DateFormula)
    var
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        NotBeforeDateTime := JobQueueMgt.NowWithDelayInSeconds(600);
        Evaluate(NextRunDateFormula, '<1D>');
    end;

    [EventSubscriber(ObjectType::Page, Page::"Inventory Setup", 'OnAfterValidateEvent', 'Automatic Cost Posting', false, false)]
    local procedure OnAfterValidateAutomaticCostPosting(var Rec: Record "Inventory Setup"; var xRec: Record "Inventory Setup")
    begin
        ConfirmAndSchedule(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Inventory Setup", 'OnAfterValidateEvent', 'Automatic Cost Adjustment', false, false)]
    local procedure OnAfterValidateAutomaticCostAdjustment(var Rec: Record "Inventory Setup"; var xRec: Record "Inventory Setup")
    begin
        ConfirmAndSchedule(Rec, xRec);
    end;

    local procedure ConfirmAndSchedule(Rec: Record "Inventory Setup"; xRec: Record "Inventory Setup")
    var
        ScheduleJobQueuesConfLbl: Label 'If you turn off automatic cost adjustments or posting, you must do those tasks manually or schedule job queue entries to run in the background.\Do you want to get the job queue entries created by the system now?';
    begin
        if not ShouldBeScheduled(Rec, xRec) then
            exit;
        if AdjCostJobQueueExists(CurrentDateTime()) then
            exit;

        Commit();
        if not Confirm(ScheduleJobQueuesConfLbl, true) then
            exit;

        Schedule(false);
        JobQueueEntryGlobal.MarkedOnly(true);
        Page.Run(Page::"Job Queue Entries", JobQueueEntryGlobal);
    end;

    local procedure ShouldBeScheduled(Rec: Record "Inventory Setup"; xRec: Record "Inventory Setup"): Boolean
    begin
        exit(
            not Rec."Automatic Cost Posting" and (Rec."Automatic Cost Adjustment" = Rec."Automatic Cost Adjustment"::Never) and
            (xRec."Automatic Cost Posting" or (xRec."Automatic Cost Adjustment" <> xRec."Automatic Cost Adjustment"::Never)));
    end;

#if not BC17
    /*
    local procedure ScheduleBC18()
    var
        SchedulingManager: Codeunit "Cost Adj. Scheduling Manager";
    begin
        SchedulingManager.CreateAdjCostJobQueue();
        SchedulingManager.CreatePostInvCostToGLJobQueue();
    end;
     */
#endif

    local procedure JobQueueDescription(ObjectTypeToRun: Integer; ObjectIdToRun: Integer): Text
    var
        CostAdjmtLbl: Label 'Item cost adjustment';
        PostCostToGlLbl: Label 'Reconcile inventory with the general ledger';
    begin
        case true of
            (ObjectTypeToRun = JobQueueEntryGlobal."Object Type to Run"::Report) and (ObjectIdToRun = Report::"Adjust Cost - Item Entries"):
                exit(CostAdjmtLbl);

            (ObjectTypeToRun = JobQueueEntryGlobal."Object Type to Run"::Codeunit) and (ObjectIdToRun = Codeunit::"NPR Post Inventory Cost to G/L"),
#if not BC17
            (ObjectTypeToRun = JobQueueEntryGlobal."Object Type to Run"::Codeunit) and (ObjectIdToRun = Codeunit::"Post Inventory Cost to G/L"),
#endif
            (ObjectTypeToRun = JobQueueEntryGlobal."Object Type to Run"::Report) and (ObjectIdToRun = Report::"Post Inventory Cost to G/L"):
                exit(PostCostToGlLbl);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", 'OnBeforeEnqueueJobQueueEntry', '', true, false)]
    local procedure AdjustJobQueue(var JobQueueEntry: Record "Job Queue Entry")
    begin
        if ((JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Report) and
            (JobQueueEntry."Object ID to Run" in [Report::"Adjust Cost - Item Entries", Report::"Post Inventory Cost to G/L"])) or
           ((JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
#if BC17
            (JobQueueEntry."Object ID to Run" = Codeunit::"NPR Post Inventory Cost to G/L"))
#else
            (JobQueueEntry."Object ID to Run" in [Codeunit::"Post Inventory Cost to G/L", Codeunit::"NPR Post Inventory Cost to G/L"]))
#endif
        then begin
            if JobQueueEntry.Description = '' then
                JobQueueEntry.Description := CopyStr(JobQueueDescription(JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run"), 1, MaxStrLen(JobQueueEntry.Description));
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshJobQueueEntry()
    begin
        Schedule(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if ((JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Report) and
            (JobQueueEntry."Object ID to Run" in [Report::"Adjust Cost - Item Entries", Report::"Post Inventory Cost to G/L"]))
           or
           ((JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
            (JobQueueEntry."Object ID to Run" = Codeunit::"NPR Post Inventory Cost to G/L"))
#if not BC17
           or
           ((JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
            (JobQueueEntry."Object ID to Run" = Codeunit::"Post Inventory Cost to G/L"))
#endif
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

    var
        JobQueueEntryGlobal: Record "Job Queue Entry";
        SalesSetup: Record "Sales & Receivables Setup";
}

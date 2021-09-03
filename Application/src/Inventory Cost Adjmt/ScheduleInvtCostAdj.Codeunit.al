codeunit 6014684 "NPR Schedule Invt. Cost Adj."
{
    trigger OnRun()
    begin
#if BC17
        ScheduleBC17(true);
#else
        ScheduleBC18();
#endif
    end;

#if BC17
    local procedure ScheduleBC17(WithCheck: Boolean)
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

        JobQueueEntryGlobal.Reset();
        POSPostViaJobQueue.AddJobQueueCategory();
        CreateAdjCostJobQueue();
        CreatePostInvCostToGLJobQueue();
    end;

    local procedure CreateAdjCostJobQueue()
    var
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
    begin
        GetTimingParameters(NotBeforeDateTime, NextRunDateFormula);
        if AdjCostJobQueueExists(NotBeforeDateTime) then
            exit;

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntryGlobal."Object Type to Run"::Report,
            Report::"Adjust Cost - Item Entries",
            '',
            JobQueueDescription(JobQueueEntryGlobal."Object Type to Run"::Report, Report::"Adjust Cost - Item Entries"),
            NotBeforeDateTime,
            010000T,
            0T,
            NextRunDateFormula,
            POSPostViaJobQueue.JQCategoryCode(),
            JobQueueEntryGlobal)
        then begin
            JobQueueEntryGlobal."Report Output Type" := JobQueueEntryGlobal."Report Output Type"::"None (Processing only)";
            JobQueueEntryGlobal.Modify();
            JobQueueEntryGlobal.Mark(true);
            JobQueueMgt.StartJobQueueEntry(JobQueueEntryGlobal);
        end;
    end;

    local procedure CreatePostInvCostToGLJobQueue()
    var
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
    begin
        GetTimingParameters(NotBeforeDateTime, NextRunDateFormula);
        if PostInvCostToGLJobQueueExists(NotBeforeDateTime) then
            exit;

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntryGlobal."Object Type to Run"::Codeunit,
            Codeunit::"NPR Post Inventory Cost to G/L",
            '',
            JobQueueDescription(JobQueueEntryGlobal."Object Type to Run"::Codeunit, Codeunit::"NPR Post Inventory Cost to G/L"),
            NotBeforeDateTime,
            020000T,
            040000T,
            NextRunDateFormula,
            POSPostViaJobQueue.JQCategoryCode(),
            JobQueueEntryGlobal)
        then begin
            JobQueueEntryGlobal.Mark(true);
            JobQueueMgt.StartJobQueueEntry(JobQueueEntryGlobal);
        end;
    end;

    local procedure AdjCostJobQueueExists(AtDateTime: DateTime): Boolean
    begin
        exit(JobQueueEntryExists(JobQueueEntryGlobal."Object Type to Run"::Report, Report::"Adjust Cost - Item Entries", AtDateTime));
    end;

    local procedure PostInvCostToGLJobQueueExists(AtDateTime: DateTime): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntryExists(JobQueueEntryGlobal."Object Type to Run"::Report, Report::"Post Inventory Cost to G/L", AtDateTime) then
            exit(true);
        exit(JobQueueEntryExists(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Post Inventory Cost to G/L", AtDateTime));
    end;

    local procedure JobQueueEntryExists(ObjectTypeToRun: Integer; ObjectIdToRun: Integer; AtDateTime: DateTime): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        Found: Boolean;
    begin
        JobQueueEntry.SetRange("Object Type to Run", ObjectTypeToRun);
        JobQueueEntry.SetRange("Object ID to Run", ObjectIdToRun);
        if JobQueueEntry.IsEmpty() then
            exit(false);
        JobQueueEntry.FindSet();
        Repeat
            Found := not JobQueueEntry.IsExpired(AtDateTime);
            if Found then begin
                JobQueueEntryGlobal := JobQueueEntry;
                JobQueueEntryGlobal.Mark(true);
            end;
        until Found or (JobQueueEntry.Next() = 0);
        exit(Found);
    end;

    local procedure GetTimingParameters(var NotBeforeDateTime: DateTime; var NextRunDateFormula: DateFormula)
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

        Commit();
        if not Confirm(ScheduleJobQueuesConfLbl, true) then
            exit;

        ScheduleBC17(false);
        JobQueueEntryGlobal.MarkedOnly(true);
        Page.Run(Page::"Job Queue Entries", JobQueueEntryGlobal);
    end;

    local procedure ShouldBeScheduled(Rec: Record "Inventory Setup"; xRec: Record "Inventory Setup"): Boolean
    var
        AtDateTime: DateTime;
    begin
        if (not xRec."Automatic Cost Posting" or Rec."Automatic Cost Posting") and
           ((xRec."Automatic Cost Adjustment" = Rec."Automatic Cost Adjustment"::Never) or (Rec."Automatic Cost Adjustment" <> Rec."Automatic Cost Adjustment"::Never))
        then
            exit(false);

        AtDateTime := CurrentDateTime();
        if AdjCostJobQueueExists(AtDateTime) and PostInvCostToGLJobQueueExists(AtDateTime) then
            exit(false);

        exit(true);
    end;
#else

    local procedure ScheduleBC18()
    var
        SchedulingManager: Codeunit "Cost Adj. Scheduling Manager";
    begin
        SchedulingManager.CreateAdjCostJobQueue();
        SchedulingManager.CreatePostInvCostToGLJobQueue();
    end;
#endif

    local procedure JobQueueDescription(ObjectTypeToRun: Integer; ObjectIdToRun: Integer): Text
    var
        CostAdjmtLbl: Label 'Item cost adjustment';
        PostCostToGlLbl: Label 'Reconcile inventory with the general ledger';
    begin
        case true of
            (ObjectTypeToRun = JobQueueEntryGlobal."Object Type to Run"::Report) and (ObjectIdToRun = Report::"Adjust Cost - Item Entries"):
                exit(CostAdjmtLbl);

#if BC17
            (ObjectTypeToRun = JobQueueEntryGlobal."Object Type to Run"::Codeunit) and (ObjectIdToRun = Codeunit::"NPR Post Inventory Cost to G/L"),
#else
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
            (JobQueueEntry."Object ID to Run" = Codeunit::"Post Inventory Cost to G/L"))
#endif
        then begin
            if JobQueueEntry.Description = '' then
                JobQueueEntry.Description := CopyStr(JobQueueDescription(JobQueueEntry."Object Type to Run", JobQueueEntry."Object ID to Run"), 1, MaxStrLen(JobQueueEntry.Description));
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeInsertEvent', '', true, false)]
    local procedure SetJobQueueCategory(var Rec: Record "Sales & Receivables Setup")
    begin
        POSPostViaJobQueue.AddJobQueueCategory();
        Rec."Job Queue Category Code" := POSPostViaJobQueue.JQCategoryCode();
    end;

    var
        JobQueueEntryGlobal: Record "Job Queue Entry";
#if BC17
        JobQueueMgt: Codeunit "NPR Job Queue Management";
#endif
        POSPostViaJobQueue: Codeunit "NPR POS Post via Task Queue";
}
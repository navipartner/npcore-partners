codeunit 6151243 "NPR Spfy Task JQ Setup"
{
    Access = Internal;

    procedure SetupTaskProcessingJobQueues()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if not SpfyIntegrationSetup.Get() then
            exit;
        if SpfyIntegrationSetup."Task List Migration Status" <> SpfyIntegrationSetup."Task List Migration Status"::Completed then
            exit;
        SetupTaskProcessingJobQueuesForEnabledStores(false);
    end;

    // Bypasses the migration-status guard: the migration schedules the jobs while its own status is still Migrating.
    internal procedure SetupTaskProcessingJobQueuesForMigration()
    begin
        SetupTaskProcessingJobQueuesForEnabledStores(true);
    end;

    internal procedure CancelTaskProcessingJobQueue(ShopifyStoreCode: Code[20])
    begin
        SetupTaskProcessingJobQueue(ShopifyStoreCode, false, false);
    end;

    local procedure SetupTaskProcessingJobQueuesForEnabledStores(FailOnDeclinedActivation: Boolean)
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        if not ShopifyStore.FindSet() then
            exit;
        repeat
            SetupTaskProcessingJobQueue(ShopifyStore.Code, SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::" ", ShopifyStore), FailOnDeclinedActivation);
        until ShopifyStore.Next() = 0;
    end;

    local procedure SetupTaskProcessingJobQueue(ShopifyStoreCode: Code[20]; Enable: Boolean; FailOnDeclinedActivation: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JobQueueDescrLbl: Label 'Shopify task list processing (%1)', Comment = '%1 = Shopify store code';
        CouldNotActivateErr: Label 'The task processing job queue entry for Shopify store %1 could not be scheduled or activated. Make sure the entry has not been set on hold manually, then run the migration again.', Comment = '%1 = Shopify store code';
    begin
        if not Enable then begin
            FilterTaskProcessingJobQueues(JobQueueEntry, ShopifyStoreCode);
            if not JobQueueEntry.IsEmpty() then
                JobQueueMgt.CancelNpManagedJobs(JobQueueEntry);
            exit;
        end;

        JobQueueMgt.SetProtected(true);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, TaskProcessorCodeunitId(),
            ShopifyStoreCode, StrSubstNo(JobQueueDescrLbl, ShopifyStoreCode),
            JobQueueMgt.NowWithDelayInSeconds(60), 1,
            TaskProcessingJQCategoryCode(), JobQueueEntry)
        then
            if JobQueueMgt.ActivateJobQueueEntry(JobQueueEntry) then
                exit;
        if not FailOnDeclinedActivation then
            exit;
        // A declined activation self-heals via the job queue refresher unless the entry is missing or an operator parked it.
        if JobQueueEntry.Get(JobQueueEntry.ID) and not JobQueueEntry."NPR Manually Set On Hold" then
            exit;
        Error(CouldNotActivateErr, ShopifyStoreCode);
    end;

    // Empty unless there is something to say, so a caller needs no second question. The delegated admin this warning
    // exists for is exactly the user who may not read Job Queue Entry, and an unguarded probe would error their page open.
    internal procedure ProcessorOnHoldWarning(): Text
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        ProcessorOnHoldTxt: Label 'A Shopify task processing job queue entry is on hold. Shopify updates are collected but not sent until an administrator sets it to Ready on the Job Queue Entries page.';
    begin
        if not SpfyIntegrationSetup.Get() then
            exit('');
        if SpfyIntegrationSetup."Task List Migration Status" <> SpfyIntegrationSetup."Task List Migration Status"::Completed then
            exit('');
        if not JobQueueEntry.ReadPermission() then
            exit('');
        if not AnyTaskProcessorOnHold() then
            exit('');
        exit(ProcessorOnHoldTxt);
    end;

    // Any store, so the migration can tell the operator that sending stays parked until someone activates the job.
    internal procedure AnyTaskProcessorOnHold(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", TaskProcessorCodeunitId());
        JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"On Hold");
        exit(not JobQueueEntry.IsEmpty());
    end;

    // Zero when there is no entry. The two scheduling fields are mutually exclusive; whichever drives the entry answers.
    internal procedure ScheduledIntervalMinutes(ShopifyStoreCode: Code[20]): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
        NextRunDate: Date;
        DayCount: Integer;
    begin
        FilterTaskProcessingJobQueues(JobQueueEntry, ShopifyStoreCode);
        // Only a running entry defines the cadence, and the entry asking this question is itself In Process.
        JobQueueEntry.SetFilter(Status, '%1|%2', JobQueueEntry.Status::Ready, JobQueueEntry.Status::"In Process");
        JobQueueEntry.SetLoadFields("No. of Minutes between Runs", "Next Run Date Formula");
        if not JobQueueEntry.FindFirst() then
            exit(0);
        if JobQueueEntry."No. of Minutes between Runs" > 0 then
            exit(JobQueueEntry."No. of Minutes between Runs");
        if Format(JobQueueEntry."Next Run Date Formula") = '' then
            exit(0);
        NextRunDate := CalcDate(JobQueueEntry."Next Run Date Formula", Today());
        if NextRunDate <= Today() then
            exit(0);
        // Clamped before the multiply: an absurd formula would otherwise overflow the minute count and kill the cycle.
        DayCount := NextRunDate - Today();
        if DayCount > MaxIntervalDays() then
            DayCount := MaxIntervalDays();
        exit(DayCount * 24 * 60);
    end;

    local procedure MaxIntervalDays(): Integer
    begin
        exit(365);
    end;

    local procedure FilterTaskProcessingJobQueues(var JobQueueEntry: Record "Job Queue Entry"; ShopifyStoreCode: Code[20])
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", TaskProcessorCodeunitId());
        JobQueueEntry.SetRange("Parameter String", ShopifyStoreCode);
    end;

    local procedure TaskProcessorCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Spfy Task Processor");
    end;

    // One category shared by every store, so the per-store processors take turns instead of exhausting the
    // background-session cap and racing each other in RecoverNcResiduals; Shopify-specific so they are not also
    // serialized behind the unrelated NaviConnect processors. The code is at the Code[10] limit of the category table.
    local procedure TaskProcessingJQCategoryCode(): Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        TaskListJQCategoryCode: Label 'NPR-SPFY', MaxLength = 10, Locked = true;
        TaskListJQCategoryDescrLbl: Label 'Shopify task list proc.', MaxLength = 30;
    begin
        JobQueueCategory.InsertRec(TaskListJQCategoryCode, TaskListJQCategoryDescrLbl);
        exit(JobQueueCategory.Code);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
    local procedure RefreshJobQueueEntry()
    begin
        SetupTaskProcessingJobQueues();
    end;
}

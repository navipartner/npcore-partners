#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
codeunit 6184701 "NPR Inv. Items Changed JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        CheckAndNotify();
    end;

    internal procedure CheckAndNotify(): Boolean
    var
        ChangeTracker: Record "NPR Change Tracker";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        InventoryWebhooks: Codeunit "NPR Inventory Webhooks";
        Boundary: BigInteger;
    begin
        // Read the boundary once, before any write, and compare it with the mark only, never with table maxima:
        // rows above the boundary may belong to open transactions and are announced by a later run.
        // A concurrent run can send a duplicate hint. No change is lost.
        Boundary := ChangeTrackerMgt.CommittedBoundary();
        ChangeTracker.ReadIsolation := IsolationLevel::ReadCommitted;
        if not ChangeTracker.Get("NPR Integration Type"::"Inventory Items Changed", Database::Item) then begin
            ChangeTrackerMgt.EnsureTracker("NPR Integration Type"::"Inventory Items Changed", Database::Item, ChangeTracker);
            ChangeTrackerMgt.SeedToCurrentMax(ChangeTracker, Boundary);
            InventoryWebhooks.RaiseItemsChanged();
            exit(true);
        end;
        if Boundary <= ChangeTracker."Last Row Version" then
            exit(false);
        if not HasChangeInWindow(ChangeTracker."Last Row Version", Boundary) then
            exit(false);
        if not ChangeTrackerMgt.AdvanceMark(ChangeTracker, Boundary) then
            exit(false);
        InventoryWebhooks.RaiseItemsChanged();
        exit(true);
    end;

    local procedure HasChangeInWindow(AfterRowVersion: BigInteger; UpToRowVersion: BigInteger): Boolean
    var
        Item: Record Item;
        ItemChange: Record "NPR Inventory Item Change";
    begin
        Item.ReadIsolation := IsolationLevel::ReadCommitted;
        Item.SetFilter(SystemRowVersion, '>%1&<=%2', AfterRowVersion, UpToRowVersion);
        if not Item.IsEmpty() then
            exit(true);
        ItemChange.ReadIsolation := IsolationLevel::ReadCommitted;
        ItemChange.SetFilter(SystemRowVersion, '>%1&<=%2', AfterRowVersion, UpToRowVersion);
        exit(not ItemChange.IsEmpty());
    end;

    internal procedure SetupJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        JobDescriptionLbl: Label 'Notify subscribers of item changes';
    begin
        RemoveOrphanedMonitoredJQEntries();

        JobQueueMgt.SetJobTimeout(1, 0);
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"NPR Inv. Items Changed JQ", '', JobDescriptionLbl,
            JobQueueMgt.NowWithDelayInSeconds(60), 1, '', JobQueueEntry)
        then begin
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
            if not IsNullGuid(JobQueueEntry.ID) then
                MonitoredJQMgt.AssignJobQueueEntryToManagedAndMonitored(false, true, JobQueueEntry);
        end;
    end;

    // Removes monitored rows of this job whose job queue entry is gone, so they do not sit next to the new row.
    local procedure RemoveOrphanedMonitoredJQEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        MonitoredJQEntry.SetCurrentKey("Object ID to Run", "Object Type to Run");
        MonitoredJQEntry.SetRange("Object ID to Run", Codeunit::"NPR Inv. Items Changed JQ");
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        if not MonitoredJQEntry.FindSet(true) then
            exit;
        repeat
            if not JobQueueEntry.Get(MonitoredJQEntry."Job Queue Entry ID") then
                MonitoredJQEntry.Delete(true);
        until MonitoredJQEntry.Next() = 0;
    end;

    // Keeps one row of this job, preferring a row that still carries an entry ID. With several rows left,
    // phase 2 binds all of them to the one entry it recreates, and each row applies its own settings to it on every pass.
    local procedure KeepOneMonitoredJQEntry()
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        NullJobQueueEntryId: Guid;
    begin
        MonitoredJQEntry.SetRange("Object ID to Run", Codeunit::"NPR Inv. Items Changed JQ");
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        MonitoredJQEntry.SetFilter("Job Queue Entry ID", '<>%1', NullJobQueueEntryId);
        if not MonitoredJQEntry.FindFirst() then begin
            MonitoredJQEntry.SetRange("Job Queue Entry ID");
            if not MonitoredJQEntry.FindFirst() then
                exit;
        end;
        MonitoredJQEntry.SetRange("Job Queue Entry ID");
        MonitoredJQEntry.SetFilter("Entry No.", '<>%1', MonitoredJQEntry."Entry No.");
        MonitoredJQEntry.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
    local procedure RefreshJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueEntryParameters: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        // The refresher only registers the job when it has no row. Running SetupJobQueue on an existing row would overwrite
        // admin-edited settings with the code defaults. The refresher recreates a missing entry from the kept row.
        MonitoredJQEntry.SetCurrentKey("Object ID to Run", "Object Type to Run");
        MonitoredJQEntry.SetRange("Object ID to Run", Codeunit::"NPR Inv. Items Changed JQ");
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        if not MonitoredJQEntry.FindSet() then begin
            // Recreate Monitored Jobs, or an admin deleting the row, leaves the entry without a row.
            // Register that entry, so the new row carries its ID.
            JobQueueEntryParameters."Object Type to Run" := JobQueueEntryParameters."Object Type to Run"::Codeunit;
            JobQueueEntryParameters."Object ID to Run" := Codeunit::"NPR Inv. Items Changed JQ";
            if JobQueueMgt.JQEntryExists(JobQueueEntryParameters, JobQueueEntry) then
                MonitoredJQMgt.AssignJobQueueEntryToManagedAndMonitored(false, true, JobQueueEntry)
            else
                SetupJobQueue();
            exit;
        end;
        // With a live row, rows next to it that have no live entry are removed.
        repeat
            if JobQueueEntry.Get(MonitoredJQEntry."Job Queue Entry ID") then begin
                RemoveOrphanedMonitoredJQEntries();
                exit;
            end;
        until MonitoredJQEntry.Next() = 0;
        KeepOneMonitoredJQEntry();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeValidateCreateMissingCustomJQs, '', false, false)]
    local procedure SkipValidateCreateMissingCustomJQs(JobQueueEntry: Record "Job Queue Entry"; var SkipValidation: Boolean)
    begin
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit;
        if JobQueueEntry."Object ID to Run" <> Codeunit::"NPR Inv. Items Changed JQ" then
            exit;
        // The job always exists, so the refresher may recreate a missing entry.
        SkipValidation := true;
    end;
}
#endif

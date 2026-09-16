codeunit 6151218 "NPR Spfy Change Detection"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        RunDetection();
    end;

    procedure RunDetection()
    var
        ChangeTracker: Record "NPR Change Tracker";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        EnabledTables: List of [Integer];
    begin
        if not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        // Skip the whole cycle while a re-sync is active; an in-flight poll self-aborts on its first AdvanceMark.
        if SpfyResyncMgt.IsResyncActive() then
            exit;
        SpfyChangeTrackerMgt.RegisterEnabledTables(EnabledTables);
        ChangeTracker.SetCurrentKey("Integration Type", "Processing Order", "Table No.");   // source tables (order 0) before derived/send tables (order 1000) → same-cycle send
        ChangeTracker.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        if ChangeTracker.FindSet() then
            repeat
                // Skip disabled-area tables without advancing the mark, so their backlog survives re-enable (legacy SkipProcessing parity).
                if EnabledTables.Contains(ChangeTracker."Table No.") then
                    PollSourceTable(ChangeTracker);
            until ChangeTracker.Next() = 0;

        // Drained LAST, after the whole poll loop, so a same-cycle modify is dispatched before the entity's delete.
        DrainDeletionLog();
    end;

    local procedure DrainDeletionLog()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        EntryNo: BigInteger;
        RowsThisCycle: Integer;
    begin
        // Defer (never drop): rows stay Pending and drain next cycle after the re-sync completes.
        if SpfyResyncMgt.IsResyncActive() then
            exit;
        DeletionLog.SetCurrentKey(Status, "Entry No.");
        DeletionLog.SetRange(Status, DeletionLog.Status::Pending);
        if not DeletionLog.FindSet() then
            exit;
        repeat
            EntryNo := DeletionLog."Entry No.";
            DrainDeletionLogRow(EntryNo);
            RowsThisCycle += 1;
        until (DeletionLog.Next() = 0) or (RowsThisCycle >= MaxRows());
    end;

    local procedure DrainDeletionLogRow(EntryNo: BigInteger)
    var
        LockedRow: Record "NPR Spfy Deletion Log";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfyChangeDispatcher: Codeunit "NPR Spfy Change Dispatcher";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        DetectedChange: Codeunit "NPR Spfy Detected Change";
    begin
        // Re-Get under UpdLock so a reactivation that Cancelled this row mid-drain wins: if no longer Pending, do not dispatch or MarkProcessed.
        LockedRow.ReadIsolation(IsolationLevel::UpdLock);
        if not LockedRow.Get(EntryNo) then
            exit;
        if LockedRow.Status <> LockedRow.Status::Pending then
            exit;

        DetectedChange.Init(SpfyChangeTrackerMgt.IntegrationAreaForTable(LockedRow."Table No."), "NPR Spfy Change Type"::Delete, LockedRow."Table No.", LockedRow."Record ID", LockedRow."Entity System Id");
        DetectedChange.SetTombstone(LockedRow."Shopify Store Code", LockedRow."Shopify ID Type", LockedRow."Shopify ID");
        DetectedChange.SetDeleteRouting(LockedRow."Item No.", LockedRow."Variant Code", LockedRow."Customer No.", LockedRow."Entry No.");

        if SpfyChangeDispatcher.Dispatch(DetectedChange) and (DetectedChange.CreatedNcTaskEntryNo() <> 0) then
            SpfyDeletionLogMgt.MarkProcessed(LockedRow."Entry No.", DetectedChange.CreatedNcTaskEntryNo());

        // Per-row commit: a later-row failure must not roll back rows already drained this cycle.
        Commit();
    end;

    local procedure PollSourceTable(var ChangeTracker: Record "NPR Change Tracker")
    var
        LockedTracker: Record "NPR Change Tracker";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfyChangeDispatcher: Codeunit "NPR Spfy Change Dispatcher";
        DetectedChange: Codeunit "NPR Spfy Detected Change";
        RecRef: RecordRef;
        Mark: BigInteger;
        RowVer: BigInteger;
        RowVerFieldNo: Integer;
        RowsThisCycle: Integer;
        AbortPoll: Boolean;
    begin
        // Separate local record so we do NOT disturb the RunDetection FindSet cursor; UpdLock so concurrent job instances don't race the mark.
        LockedTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not LockedTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit;
        Mark := LockedTracker."Last Row Version";
        RecRef.Open(LockedTracker."Table No.");
        RecRef.ReadIsolation(IsolationLevel::ReadCommitted);
        ChangeTrackerMgt.SetFilterOnRowVersion(RecRef, Mark);
        RowVerFieldNo := ChangeTrackerMgt.RowVersionFieldNo(RecRef);
        // Advance + commit the mark PER ROW, not once post-loop: else a later-row error re-dispatches already-committed rows next cycle → duplicate NC tasks.
        if RecRef.FindSet() then
            repeat
                RowVer := RecRef.Field(RowVerFieldNo).Value();
                DetectedChange.Init(SpfyChangeTrackerMgt.IntegrationAreaForTable(LockedTracker."Table No."), "NPR Spfy Change Type"::Modify, LockedTracker."Table No.", RecRef.RecordId(), ChangeTrackerMgt.SystemIdOf(RecRef));
                SpfyChangeDispatcher.Dispatch(DetectedChange);
                // false = mark concurrently lowered (re-sync): abort without re-raising; the dispatched row
                // re-dispatches on the forced re-scan.
                AbortPoll := not ChangeTrackerMgt.AdvanceMark(LockedTracker, RowVer);
                Commit();
                RowsThisCycle += 1;
            until (RecRef.Next() = 0) or (RowsThisCycle >= MaxRows()) or AbortPoll;
        RecRef.Close();
    end;

    local procedure MaxRows(): Integer
    begin
        exit(100000);
    end;
}

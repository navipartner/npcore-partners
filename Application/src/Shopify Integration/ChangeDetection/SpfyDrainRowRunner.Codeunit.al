codeunit 6151276 "NPR Spfy Drain Row Runner"
{
    Access = Internal;
    TableNo = "NPR Spfy Deletion Log";

    trigger OnRun()
    var
        LockedRow: Record "NPR Spfy Deletion Log";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfyChangeDispatcher: Codeunit "NPR Spfy Change Dispatcher";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        DetectedChange: Codeunit "NPR Spfy Detected Change";
    begin
        // Re-Get under UpdLock so a reactivation that Cancelled this row mid-drain wins: if no longer Pending, do not dispatch or MarkProcessed.
        LockedRow.ReadIsolation(IsolationLevel::UpdLock);
        if not LockedRow.Get(Rec."Entry No.") then
            exit;
        if LockedRow.Status <> LockedRow.Status::Pending then
            exit;

        DetectedChange.Init(SpfyChangeTrackerMgt.IntegrationAreaForTable(LockedRow."Table No."), "NPR Spfy Change Type"::Delete, LockedRow."Table No.", LockedRow."Record ID", LockedRow."Entity System Id");
        DetectedChange.SetTombstone(LockedRow."Shopify Store Code", LockedRow."Shopify ID Type", LockedRow."Shopify ID");
        DetectedChange.SetDeleteRouting(LockedRow."Item No.", LockedRow."Variant Code", LockedRow."Customer No.", LockedRow."Entry No.");

        if SpfyChangeDispatcher.Dispatch(DetectedChange) and (DetectedChange.CreatedNcTaskEntryNo() <> 0) then
            SpfyDeletionLogMgt.MarkProcessed(LockedRow."Entry No.", DetectedChange.CreatedNcTaskEntryNo(), DetectedChange.CreatedTaskQueue());

        // Per-row commit: a later-row failure must not roll back rows already drained this cycle.
        Commit();
    end;
}

codeunit 6151266 "NPR Spfy Resync Worker"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        RunPendingResync(Rec);
    end;

    local procedure RunPendingResync(JobQueueEntry: Record "Job Queue Entry")
    var
        ResyncRun: Record "NPR Spfy Resync Run";
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        RecRef: RecordRef;
    begin
        // Claim exactly the run stamped on this JQ entry; heartbeat+Commit FIRST so the detection marker is
        // fresh before any baseline work. Exit silently on any mismatch — a reaped/completed/foreground run
        // must not be re-run.
        if JobQueueEntry."Record ID to Process".TableNo() <> Database::"NPR Spfy Resync Run" then
            exit;
        // RecRef.Get verifies the row still exists; RecordId.GetRecord() never reads the DB, so it would validate nothing.
        if not RecRef.Get(JobQueueEntry."Record ID to Process") then
            exit;
        RecRef.SetTable(ResyncRun);
        ResyncRun.ReadIsolation(IsolationLevel::UpdLock);
        if not ResyncRun.Get(ResyncRun."Entry No.") then
            exit;
        if ResyncRun.Status <> ResyncRun.Status::Running then
            exit;
        if ResyncRun."Launch Mode" <> ResyncRun."Launch Mode"::Background then
            exit;
        SpfyResyncMgt.RefreshHeartbeat(ResyncRun);
        Commit();
        SpfyResyncMgt.ExecuteRun(ResyncRun);
    end;
}

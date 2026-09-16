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
        PollTables: List of [Integer];
        TableNo: Integer;
        FirstErrorText: Text;
    begin
        if not SpfyRowVersionFeature.IsFeatureEnabled() then
            exit;
        // Skip the whole cycle while a re-sync is active; an in-flight poll self-aborts on its first AdvanceMark.
        if SpfyResyncMgt.IsResyncActive() then
            exit;
        SpfyChangeTrackerMgt.RegisterEnabledTables(EnabledTables);
        ChangeTracker.SetCurrentKey("Integration Type", "Processing Order", "Table No.");   // source tables (order 0) before derived/send tables (order 1000) → same-cycle send
        ChangeTracker.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        // Two passes: a record cursor must not span the per-table Codeunit.Run shells (a caught failure rolls
        // the transaction back under the cursor).
        if ChangeTracker.FindSet() then
            repeat
                // Skip disabled-area tables without advancing the mark, so their backlog survives re-enable (legacy SkipProcessing parity).
                if EnabledTables.Contains(ChangeTracker."Table No.") then
                    PollTables.Add(ChangeTracker."Table No.");
            until ChangeTracker.Next() = 0;
        foreach TableNo in PollTables do
            if ChangeTracker.Get("NPR Integration Type"::Shopify, TableNo) then
                PollTableIsolated(ChangeTracker, FirstErrorText);

        // Drained LAST, after the whole poll loop, so a same-cycle modify is dispatched before the entity's delete.
        DrainDeletionLog(FirstErrorText);

        // Everything is committed by now; this only flips the JQ run to Error so a not-yet-quarantined
        // poison row stays visible in the job queue log.
        if FirstErrorText <> '' then
            Error('%1', FirstErrorText);
    end;

    local procedure PollTableIsolated(var ChangeTracker: Record "NPR Change Tracker"; var FirstErrorText: Text)
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        PinpointRunner: Codeunit "NPR Spfy Pinpoint Runner";
        PollTableRunner: Codeunit "NPR Spfy Poll Table Runner";
        RowCallStack: Text;
        RowErrorText: Text;
    begin
        // A failure recorded on an earlier cycle: attribute row-precisely before any fast batching.
        if ChangeTracker."Consecutive Failures" > 0 then begin
            if not RunPinpointShielded(ChangeTracker, FirstErrorText) then
                exit;
            // The var copy-back through Codeunit.Run is unreliable: re-read what the pinpoint walk persisted.
            if not ChangeTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
                exit;
        end;
        // Codeunit.Run with a handled return value requires no uncommitted writes; this also fixes the
        // rollback boundary at the table border.
        Commit();
        ClearLastError();
        if PollTableRunner.Run(ChangeTracker) then
            exit;
        CaptureRowError(RowErrorText, RowCallStack);
        CaptureFirstError(FirstErrorText);
        if SpfyChangeTrackerMgt.BatchSizeForTable(ChangeTracker."Table No.") = 1 then begin
            // Per-row tables commit inside their dispatch: a same-cycle second attempt could repeat the
            // committed prefix, and the failing row is already the first row past the mark - record only.
            // Shielded like the walk below: a failure while recording must not skip the later tables or the drain.
            PinpointRunner.SetRecordFailureStep(ChangeTracker."Integration Type", ChangeTracker."Table No.", RowErrorText, RowCallStack);
            Commit();
            ClearLastError();
            if not PinpointRunner.Run() then
                CaptureFirstError(FirstErrorText);
        end else
            // The failed Run rolled back its unflushed suffix (batched tables commit nothing internally),
            // so the failure lies within one flush window of the persisted mark: re-walk it row by row, same cycle.
            RunPinpointShielded(ChangeTracker, FirstErrorText);
    end;

    // Shielded like the batched poll: a pinpoint failure must not skip the later tables or the delete drain.
    local procedure RunPinpointShielded(var ChangeTracker: Record "NPR Change Tracker"; var FirstErrorText: Text): Boolean
    var
        PinpointRunner: Codeunit "NPR Spfy Pinpoint Runner";
    begin
        PinpointRunner.SetTracker(ChangeTracker."Integration Type", ChangeTracker."Table No.", FirstErrorText);
        Commit();
        ClearLastError();
        if not PinpointRunner.Run() then begin
            // The failed Run leaves the SingleInstance globals intact, so the walk's own first error still wins over this secondary one.
            if PinpointRunner.FirstErrorText() <> '' then
                FirstErrorText := PinpointRunner.FirstErrorText();
            CaptureFirstError(FirstErrorText);
            exit(false);
        end;
        // The runner was seeded with this text, so a non-empty result is either that seed or the walk's first error.
        if PinpointRunner.FirstErrorText() <> '' then
            FirstErrorText := PinpointRunner.FirstErrorText();
        exit(PinpointRunner.ShouldContinue());
    end;

    internal procedure RecordFailedRowWithoutRedispatch(var ChangeTracker: Record "NPR Change Tracker"; RowErrorText: Text; RowCallStack: Text)
    var
        LockedTracker: Record "NPR Change Tracker";
        TempStagedRow: Record "NPR Change Quarantine" temporary;
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
    begin
        LockedTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not LockedTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit;
        StageChunk(LockedTracker."Table No.", LockedTracker."Last Row Version", 1, TempStagedRow);
        if not TempStagedRow.FindFirst() then begin
            // The failing row vanished (entity deleted / re-sync consumed it): forget the streak and release the lock.
            ChangeTrackerMgt.ClearRowFailure(LockedTracker);
            Commit();
            ChangeTracker := LockedTracker;
            exit;
        end;
        if ChangeTrackerMgt.RecordRowFailure(LockedTracker, TempStagedRow."Row Version") >= SpfyChangeTrackerMgt.QuarantineThreshold() then begin
            ChangeTrackerMgt.QuarantineRow(LockedTracker, TempStagedRow."Row Version", TempStagedRow."Record ID", TempStagedRow."Entity System Id", RowErrorText);
            EmitQuarantineSentry(LockedTracker."Table No.", TempStagedRow."Record ID", TempStagedRow."Row Version", RowErrorText, RowCallStack);
        end;
        Commit();
        ChangeTracker := LockedTracker;
    end;

    local procedure EmitQuarantineSentry(TableNo: Integer; QuarRecordId: RecordId; RowVersion: BigInteger; ErrorText: Text; CallStack: Text)
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        Sentry: Codeunit "NPR Sentry";
        QuarantinedRowLbl: Label 'Shopify change detection quarantined a row after %1 consecutive dispatch failures and advanced past it. Table %2, record %3, row version %4. Last error: %5 This is a programming bug.', Locked = true;
    begin
        Sentry.InitScopeAndTransaction('Shopify change-detection quarantine', 'bc.spfy.change_detection.quarantine');
        Sentry.AddError(StrSubstNo(QuarantinedRowLbl, SpfyChangeTrackerMgt.QuarantineThreshold(), TableNo, Format(QuarRecordId), RowVersion, ErrorText), CallStack);
        Sentry.FinalizeScope();
    end;

    // English text and callstack of the failed dispatch: the JQ session's language must not reach Sentry.
    local procedure CaptureRowError(var RowErrorText: Text; var RowCallStack: Text)
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        Sentry.GetLastErrorInEnglish(RowErrorText, RowCallStack);
        RowErrorText := NonEmptyError(RowErrorText);
    end;

    local procedure CaptureFirstError(var FirstErrorText: Text)
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        if FirstErrorText = '' then begin
            FirstErrorText := NonEmptyError(GetLastErrorText());
            Sentry.InitScopeAndTransaction('Shopify change-detection failure', 'bc.spfy.change_detection.failure', 0.0);   // Unsampled: nothing is sent unless a programming-bug error is added; then the error event goes out with its transaction envelope.
            Sentry.AddLastErrorIfProgrammingBug();
            Sentry.FinalizeScope();
        end;
    end;

    local procedure NonEmptyError(ErrorText: Text): Text
    var
        UnknownErrorLbl: Label 'The change dispatch failed without a specific error message.', Locked = true;
    begin
        // An Error('') leaves GetLastErrorText() empty - avoid a blank quarantine/JQ error text.
        if ErrorText = '' then
            exit(UnknownErrorLbl);
        exit(ErrorText);
    end;

    local procedure DrainDeletionLog(var FirstErrorText: Text)
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        DrainRowRunner: Codeunit "NPR Spfy Drain Row Runner";
        PinpointRunner: Codeunit "NPR Spfy Pinpoint Runner";
        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        LastEntryNo: BigInteger;
        RowsThisCycle: Integer;
        RowCallStack: Text;
        RowErrorText: Text;
    begin
        // Defer (never drop): rows stay Pending and drain next cycle after the re-sync completes.
        if SpfyResyncMgt.IsResyncActive() then
            exit;
        DeletionLog.SetCurrentKey(Status, "Entry No.");
        DeletionLog.SetRange(Status, DeletionLog.Status::Pending);
        repeat
            DeletionLog.SetFilter("Entry No.", '>%1', LastEntryNo);
            if not DeletionLog.FindFirst() then
                exit;
            LastEntryNo := DeletionLog."Entry No.";
            ClearLastError();
            // Entry state is committed here (the poll ended on a commit; each drained row commits itself),
            // so a failure rolls back exactly this row's partial writes.
            if DrainRowRunner.Run(DeletionLog) then
                // A success that leaves the row Pending (dispatch created no task) forgets the failure streak.
                PinpointRunner.SetDrainStep(LastEntryNo, true, RowErrorText, RowCallStack)
            else begin
                CaptureRowError(RowErrorText, RowCallStack);
                CaptureFirstError(FirstErrorText);
                PinpointRunner.SetDrainStep(LastEntryNo, false, RowErrorText, RowCallStack);
            end;
            // Shielded like the poll: a lock timeout while updating this log row must not skip the remaining Pending rows.
            Commit();
            ClearLastError();
            if not PinpointRunner.Run() then
                CaptureFirstError(FirstErrorText);
            Commit();
            RowsThisCycle += 1;
        until RowsThisCycle >= MaxRows();
    end;

    internal procedure PollSourceTable(var ChangeTracker: Record "NPR Change Tracker")
    var
        LockedTracker: Record "NPR Change Tracker";
        TempStagedRow: Record "NPR Change Quarantine" temporary;
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        SpfyChangeDispatcher: Codeunit "NPR Spfy Change Dispatcher";
        DetectedChange: Codeunit "NPR Spfy Detected Change";
        StagingMark: BigInteger;
        BatchSize: Integer;
        ChunkSize: Integer;
        StagedCount: Integer;
        RowsThisCycle: Integer;
        AbortPoll: Boolean;
    begin
        // Separate local record so we do NOT disturb the caller's state; UpdLock so concurrent job instances don't race the mark.
        LockedTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not LockedTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit;
        BatchSize := SpfyChangeTrackerMgt.BatchSizeForTable(LockedTracker."Table No.");
        // Local staging cursor: tracks the last staged rowversion so each chunk resumes where the previous ended.
        StagingMark := LockedTracker."Last Row Version";
        repeat
            // Clamp the chunk to the remaining cycle budget so the per-table cap is exact (E1).
            ChunkSize := BatchSize;
            if MaxRows() - RowsThisCycle < ChunkSize then
                ChunkSize := MaxRows() - RowsThisCycle;
            StagedCount := StageChunk(LockedTracker."Table No.", StagingMark, ChunkSize, TempStagedRow);
            if StagedCount = 0 then
                exit;
            TempStagedRow.FindSet();
            repeat
                DetectedChange.Init(SpfyChangeTrackerMgt.IntegrationAreaForTable(LockedTracker."Table No."), "NPR Spfy Change Type"::Modify, LockedTracker."Table No.", TempStagedRow."Record ID", TempStagedRow."Entity System Id");
                SpfyChangeDispatcher.Dispatch(DetectedChange);
                StagingMark := TempStagedRow."Row Version";
                RowsThisCycle += 1;
            until TempStagedRow.Next() = 0;
            // false = mark concurrently lowered (re-sync): abort without re-raising; the dispatched rows
            // re-dispatch on the forced re-scan.
            AbortPoll := not ChangeTrackerMgt.AdvanceMark(LockedTracker, StagingMark);
            Commit();
        until (StagedCount < ChunkSize) or (RowsThisCycle >= MaxRows()) or AbortPoll;
    end;

    local procedure StageChunk(TableNo: Integer; FromMark: BigInteger; MaxStageCount: Integer; var TempStagedRow: Record "NPR Change Quarantine" temporary) StagedCount: Integer
    var
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        RecRef: RecordRef;
        RowVerFieldNo: Integer;
    begin
        // Stage identities and close the cursor BEFORE anything commits (BatchSize-1 dispatches commit internally).
        TempStagedRow.Reset();
        TempStagedRow.DeleteAll();
        RecRef.Open(TableNo);
        RecRef.ReadIsolation(IsolationLevel::ReadCommitted);
        ChangeTrackerMgt.SetFilterOnRowVersion(RecRef, FromMark);
        RowVerFieldNo := ChangeTrackerMgt.RowVersionFieldNo(RecRef);
        if RecRef.FindSet() then
            repeat
                StagedCount += 1;
                TempStagedRow.Init();
                TempStagedRow."Entry No." := StagedCount;
                TempStagedRow."Table No." := TableNo;
                TempStagedRow."Row Version" := RecRef.Field(RowVerFieldNo).Value();
                TempStagedRow."Record ID" := RecRef.RecordId();
                TempStagedRow."Entity System Id" := ChangeTrackerMgt.SystemIdOf(RecRef);
                TempStagedRow.Insert();
            until (StagedCount >= MaxStageCount) or (RecRef.Next() = 0);
        RecRef.Close();
    end;

    internal procedure RunPinpointWindow(var ChangeTracker: Record "NPR Change Tracker"; var FirstErrorText: Text): Boolean
    var
        LockedTracker: Record "NPR Change Tracker";
        TempStagedRow: Record "NPR Change Quarantine" temporary;
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        PollRowRunner: Codeunit "NPR Spfy Poll Row Runner";
        RowCallStack: Text;
        RowErrorText: Text;
    begin
        LockedTracker.ReadIsolation(IsolationLevel::UpdLock);
        if not LockedTracker.Get(ChangeTracker."Integration Type", ChangeTracker."Table No.") then
            exit(false);
        StageChunk(LockedTracker."Table No.", LockedTracker."Last Row Version", SpfyChangeTrackerMgt.BatchSizeForTable(LockedTracker."Table No."), TempStagedRow);
        if not TempStagedRow.FindSet() then begin
            // The failing row vanished (entity deleted / re-sync consumed it): forget the streak.
            ChangeTrackerMgt.ClearRowFailure(LockedTracker);
            Commit();
            ChangeTracker := LockedTracker;
            exit(true);
        end;
        repeat
            PollRowRunner.SetStagedRow(LockedTracker."Table No.", TempStagedRow."Record ID", TempStagedRow."Entity System Id");
            // Per-row commit: the previous row's writes must survive this row's rollback, and Codeunit.Run
            // with a handled return value requires it.
            Commit();
            ClearLastError();
            if PollRowRunner.Run() then begin
                if not ChangeTrackerMgt.AdvanceMark(LockedTracker, TempStagedRow."Row Version") then begin
                    // Concurrent re-sync lowered the mark: stop without recording a failure.
                    Commit();
                    ChangeTracker := LockedTracker;
                    exit(false);
                end;
            end else begin
                CaptureRowError(RowErrorText, RowCallStack);
                CaptureFirstError(FirstErrorText);
                if ChangeTrackerMgt.RecordRowFailure(LockedTracker, TempStagedRow."Row Version") >= SpfyChangeTrackerMgt.QuarantineThreshold() then begin
                    ChangeTrackerMgt.QuarantineRow(LockedTracker, TempStagedRow."Row Version", TempStagedRow."Record ID", TempStagedRow."Entity System Id", RowErrorText);
                    EmitQuarantineSentry(LockedTracker."Table No.", TempStagedRow."Record ID", TempStagedRow."Row Version", RowErrorText, RowCallStack);
                end;
                Commit();
                ChangeTracker := LockedTracker;
                exit(false);
            end;
        until TempStagedRow.Next() = 0;
        ChangeTrackerMgt.ClearRowFailure(LockedTracker);
        Commit();
        ChangeTracker := LockedTracker;
        exit(true);
    end;

    local procedure MaxRows(): Integer
    begin
        exit(100000);
    end;
}

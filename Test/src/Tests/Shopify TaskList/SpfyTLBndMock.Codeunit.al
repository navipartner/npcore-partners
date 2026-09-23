codeunit 85317 "NPR Spfy TL Bnd Mock" implements "NPR Spfy Task Send Boundary"
{
    // Scriptable stand-in for the Shopify send boundary: no HTTP, never raises for a dispatch outcome, and touches real rows only through the queue facade.
    // Also holds the migration suite's scripted interleaves: the legacy hand-over seam and the creation of the migration's own background entry.
    Access = Internal;
    SingleInstance = true;

    var
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _OutcomeSucceeds: Dictionary of [BigInteger, Boolean];
        _OutcomeErrors: Dictionary of [BigInteger, Text];
        _DispatchedEntryNos: List of [BigInteger];
        _DispatchTableNos: List of [Integer];
        _DispatchRowCounts: List of [Integer];
        _DispatchTemporary: List of [Boolean];
        _FailureErrorText: Text;
        _HandOverFailureText: Text;
        _HandOverLeaseTakeover: Guid;
        _SchedulingLeaseTakeover: Guid;
        _WaitingRoundTripEntryNo: BigInteger;
        _SilentDropAfterNRows: Integer;
        _ThrowAfterNRows: Integer;
        _DispatchCount: Integer;
        _LastRowCount: Integer;
        _LastTableNo: Integer;
        _ExpireRunDeadlineOnTaskWrite: Boolean;
        _LastWasTemporary: Boolean;
        _WholeCallFailure: Boolean;
        _ParkMigrationEntry: Boolean;
        _ParkedEntryIsManuallyHeld: Boolean;

    procedure Dispatch(var SpfyTaskWork: Record "NPR Spfy Task"; var ErrorText: Text): Boolean
    begin
        Clear(ErrorText);
        _DispatchCount += 1;
        _LastWasTemporary := SpfyTaskWork.IsTemporary();
        _LastTableNo := SpfyTaskWork."Table No.";
        _DispatchTemporary.Add(_LastWasTemporary);
        _DispatchTableNos.Add(_LastTableNo);
        if _LastWasTemporary then begin
            _DispatchRowCounts.Add(SpfyTaskWork.Count());
            exit(DispatchWorkList(SpfyTaskWork, ErrorText));
        end;
        _DispatchRowCounts.Add(1);
        exit(DispatchRealRow(SpfyTaskWork, ErrorText));
    end;

    procedure QueueOutcome(EntryNo: BigInteger; Succeed: Boolean; ErrorText: Text)
    begin
        if _OutcomeSucceeds.ContainsKey(EntryNo) then begin
            _OutcomeSucceeds.Remove(EntryNo);
            _OutcomeErrors.Remove(EntryNo);
        end;
        _OutcomeSucceeds.Add(EntryNo, Succeed);
        _OutcomeErrors.Add(EntryNo, ErrorText);
    end;

    procedure SetWholeCallFailure(ErrorText: Text)
    begin
        _WholeCallFailure := true;
        _FailureErrorText := ErrorText;
    end;

    procedure SetHandOverFailure(ErrorText: Text)
    begin
        _HandOverFailureText := ErrorText;
    end;

    // Simulates another run taking the migration lease over while this one is inside the legacy hand-over.
    procedure SetHandOverLeaseTakeover(RunId: Guid)
    begin
        _HandOverLeaseTakeover := RunId;
    end;

    // Simulates a user who cannot start scheduled tasks: the migration's background entry is created and left parked.
    // Manually held is the variant the production code re-reads and turns into a scheduling error.
    procedure SetParkMigrationEntry(ManuallyHeld: Boolean)
    begin
        _ParkMigrationEntry := true;
        _ParkedEntryIsManuallyHeld := ManuallyHeld;
    end;

    // Simulates another administrator taking the migration lease over while this run is still scheduling its entry.
    procedure SetSchedulingLeaseTakeover(RunId: Guid)
    begin
        _SchedulingLeaseTakeover := RunId;
    end;

    procedure SetThrowMidBatch(AfterNRows: Integer; ErrorText: Text)
    begin
        _ThrowAfterNRows := AfterNRows;
        _FailureErrorText := ErrorText;
    end;

    // Simulates a send that presents only the first N rows: the rest are never claimed, yet the call reports success.
    procedure SetSilentDropAfterNRows(AfterNRows: Integer)
    begin
        _SilentDropAfterNRows := AfterNRows;
    end;

    // Simulates a concurrent session parking the row Waiting mid-dispatch (claim declined) and releasing it after the send.
    procedure SetWaitingRoundTripForEntry(EntryNo: BigInteger)
    begin
        _WaitingRoundTripEntryNo := EntryNo;
    end;

    // Simulates a run whose budget runs out mid-run: the deadline is spent the moment the run writes its first row outcome.
    procedure SetExpireRunDeadlineOnTaskWrite(Expire: Boolean)
    begin
        _ExpireRunDeadlineOnTaskWrite := Expire;
    end;

    procedure Reset()
    begin
        Clear(_OutcomeSucceeds);
        Clear(_OutcomeErrors);
        Clear(_DispatchedEntryNos);
        Clear(_DispatchTableNos);
        Clear(_DispatchRowCounts);
        Clear(_DispatchTemporary);
        _FailureErrorText := '';
        _HandOverFailureText := '';
        Clear(_HandOverLeaseTakeover);
        Clear(_SchedulingLeaseTakeover);
        _ParkMigrationEntry := false;
        _ParkedEntryIsManuallyHeld := false;
        _WaitingRoundTripEntryNo := 0;
        _SilentDropAfterNRows := 0;
        _ThrowAfterNRows := 0;
        _DispatchCount := 0;
        _LastRowCount := 0;
        _LastTableNo := 0;
        _LastWasTemporary := false;
        _WholeCallFailure := false;
        _ExpireRunDeadlineOnTaskWrite := false;
    end;

    procedure DispatchCount(): Integer
    begin
        exit(_DispatchCount);
    end;

    procedure LastDispatchWasTemporary(): Boolean
    begin
        exit(_LastWasTemporary);
    end;

    procedure LastDispatchRowCount(): Integer
    begin
        exit(_LastRowCount);
    end;

    procedure LastDispatchTableNo(): Integer
    begin
        exit(_LastTableNo);
    end;

    procedure DispatchedEntryNo(Index: Integer): BigInteger
    begin
        if (Index < 1) or (Index > _DispatchedEntryNos.Count()) then
            exit(0);
        exit(_DispatchedEntryNos.Get(Index));
    end;

    procedure DispatchedRowCount(): Integer
    begin
        exit(_DispatchedEntryNos.Count());
    end;

    procedure DispatchTableNoAt(Index: Integer): Integer
    begin
        if (Index < 1) or (Index > _DispatchTableNos.Count()) then
            exit(0);
        exit(_DispatchTableNos.Get(Index));
    end;

    procedure DispatchWasTemporaryAt(Index: Integer): Boolean
    begin
        if (Index < 1) or (Index > _DispatchTemporary.Count()) then
            exit(false);
        exit(_DispatchTemporary.Get(Index));
    end;

    procedure DispatchRowCountAt(Index: Integer): Integer
    begin
        if (Index < 1) or (Index > _DispatchRowCounts.Count()) then
            exit(0);
        exit(_DispatchRowCounts.Get(Index));
    end;

    local procedure DispatchWorkList(var SpfyTaskGroup: Record "NPR Spfy Task"; var ErrorText: Text): Boolean
    var
        CompletedSpfyTask: Record "NPR Spfy Task";
        ResponseJObject: JsonObject;
        ResponseJson: JsonToken;
        ClaimedRows: Integer;
        RowErrorText: Text;
        RowSucceeded: Boolean;
    begin
        _LastRowCount := SpfyTaskGroup.Count();
        if not SpfyTaskGroup.FindSet() then
            exit(true);
        ResponseJson := ResponseJObject.AsToken();
        repeat
            if (_SilentDropAfterNRows > 0) and (ClaimedRows >= _SilentDropAfterNRows) then
                exit(true);
            if (_WaitingRoundTripEntryNo <> 0) and (SpfyTaskGroup."Entry No." = _WaitingRoundTripEntryNo) then
                ParkRealRowAsWaiting(_WaitingRoundTripEntryNo);
            _DispatchedEntryNos.Add(SpfyTaskGroup."Entry No.");
            SpfyTaskGroup."Last Processing Started at" := CurrentDateTime();
            if _SpfyTaskQueue.ClaimForBatch(SpfyTaskGroup) then begin
                ClaimedRows += 1;
                if (_ThrowAfterNRows > 0) and (ClaimedRows >= _ThrowAfterNRows) then begin
                    ErrorText := _FailureErrorText;
                    exit(false);
                end;
                if _WholeCallFailure then
                    _SpfyTaskQueue.CompleteFromBatch(SpfyTaskGroup."Entry No.", ResponseJson, false, _FailureErrorText, CompletedSpfyTask)
                else begin
                    RowSucceeded := OutcomeFor(SpfyTaskGroup."Entry No.", RowErrorText);
                    _SpfyTaskQueue.CompleteFromBatch(SpfyTaskGroup."Entry No.", ResponseJson, RowSucceeded, RowErrorText, CompletedSpfyTask);
                end;
            end;
        until SpfyTaskGroup.Next() = 0;

        if _WaitingRoundTripEntryNo <> 0 then
            ReleaseRealRow(_WaitingRoundTripEntryNo);
        if _WholeCallFailure then begin
            ErrorText := _FailureErrorText;
            exit(false);
        end;
        exit(true);
    end;

    local procedure ParkRealRowAsWaiting(EntryNo: BigInteger)
    var
        SpfyTask: Record "NPR Spfy Task";
        ParkedByConcurrentSessionLbl: Label 'Parked by a concurrent session during dispatch', Locked = true;
    begin
        if SpfyTask.Get(EntryNo) then
            _SpfyTaskQueue.SetWaiting(SpfyTask, ParkedByConcurrentSessionLbl, CurrentDateTime());
    end;

    local procedure ReleaseRealRow(EntryNo: BigInteger)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if SpfyTask.Get(EntryNo) then
            _SpfyTaskQueue.ReleaseWaiting(SpfyTask);
    end;

    local procedure DispatchRealRow(var SpfyTask: Record "NPR Spfy Task"; var ErrorText: Text): Boolean
    begin
        _LastRowCount := 1;
        _DispatchedEntryNos.Add(SpfyTask."Entry No.");
        if _WholeCallFailure then begin
            ErrorText := _FailureErrorText;
            exit(false);
        end;
        exit(OutcomeFor(SpfyTask."Entry No.", ErrorText));
    end;

    local procedure OutcomeFor(EntryNo: BigInteger; var ErrorText: Text): Boolean
    var
        Succeeded: Boolean;
    begin
        Clear(ErrorText);
        if not _OutcomeSucceeds.ContainsKey(EntryNo) then
            exit(true);
        _OutcomeErrors.Get(EntryNo, ErrorText);
        _OutcomeSucceeds.Get(EntryNo, Succeeded);
        exit(Succeeded);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Spfy Task", 'OnAfterModifyEvent', '', false, false)]
    local procedure ExpireRunDeadlineOnTaskWrite()
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        if not _ExpireRunDeadlineOnTaskWrite then
            exit;
        SpfyTaskRunContext.SetRunDeadline(CurrentDateTime() - 1000);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Task List Migration", OnBeforeHandOverLegacyQueue, '', false, false)]
    local procedure OnBeforeHandOverLegacyQueue(var FailWithErrorText: Text)
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        // Committed so the take-over outlives the cutover's rollback, exactly as a real superseding run's would.
        if not IsNullGuid(_HandOverLeaseTakeover) then begin
            SpfyIntegrationSetup.Get();
            SpfyIntegrationSetup."Task List Migration Run ID" := _HandOverLeaseTakeover;
            SpfyIntegrationSetup.Modify(false);
            Commit();
            Clear(_HandOverLeaseTakeover);
        end;
        if _HandOverFailureText <> '' then
            FailWithErrorText := _HandOverFailureText;
    end;

    // Inert unless a test asks for it, and never reaches any job but the migration's own.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnBeforeInitRecurringJobQueueEntry', '', false, false)]
    local procedure ScriptMigrationEntryCreation(Parameters: Record "Job Queue Entry"; var JobQueueEntryOut: Record "Job Queue Entry"; var Success: Boolean; var Handled: Boolean)
    begin
        if Parameters."Object Type to Run" <> Parameters."Object Type to Run"::Codeunit then
            exit;
        if Parameters."Object ID to Run" <> Codeunit::"NPR Spfy Task List Migration" then
            exit;
        if not IsNullGuid(_SchedulingLeaseTakeover) then
            TakeMigrationLeaseOver();
        if not _ParkMigrationEntry then
            exit;
        ParkMigrationEntry(Parameters, JobQueueEntryOut);
        _ParkMigrationEntry := false;
        _ParkedEntryIsManuallyHeld := false;
        Success := true;
        Handled := true;
    end;

    // Committed so the take-over outlives the scheduling failure, exactly as a real superseding run's would.
    local procedure TakeMigrationLeaseOver()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        SpfyIntegrationSetup.Get();
        SpfyIntegrationSetup."Task List Migration Run ID" := _SchedulingLeaseTakeover;
        SpfyIntegrationSetup."Task List Migr. Started At" := CurrentDateTime();
        SpfyIntegrationSetup.Modify(false);
        Commit();
        Clear(_SchedulingLeaseTakeover);
    end;

    // The row is committed so the half-created entry outlives the scheduling error, and the copy handed back reports the
    // declined activation the production code then re-reads the row to classify.
    local procedure ParkMigrationEntry(Parameters: Record "Job Queue Entry"; var JobQueueEntryOut: Record "Job Queue Entry")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := Parameters."Object Type to Run";
        JobQueueEntry."Object ID to Run" := Parameters."Object ID to Run";
        JobQueueEntry."Parameter String" := Parameters."Parameter String";
        JobQueueEntry.Description := Parameters.Description;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR Manually Set On Hold" := _ParkedEntryIsManuallyHeld;
        JobQueueEntry.Insert(false);
        Commit();
        JobQueueEntryOut := JobQueueEntry;
        JobQueueEntryOut."NPR Manually Set On Hold" := true;
    end;

    // The injected boundary is session-lived state: without this, sending from the same session after a test run would dispatch into the mock instead of Shopify.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", OnAfterTestMethodRun, '', false, false)]
    local procedure ClearInjectedBoundaryAfterTestMethodRun(var CurrentTestMethodLine: Record "Test Method Line"; CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean)
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        SpfyTaskRunContext.ClearSendBoundary();
    end;
}

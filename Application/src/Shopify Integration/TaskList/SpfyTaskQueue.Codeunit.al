codeunit 6151183 "NPR Spfy Task Queue"
{
    Access = Internal;

    internal procedure Enqueue(ShopifyStoreCode: Code[20]; RecRef: RecordRef; RecID: RecordId; TaskRecordValue: Text; TaskType: Enum "NPR Spfy Task Op"; LogDateTime: DateTime; NotBeforeDateTime: DateTime; ReuseExistingDelayed: Enum "NPR Spfy Reuse Delayed NC Task"; AtDateTime: DateTime; var SpfyTask: Record "NPR Spfy Task"): Boolean
    var
        SpfyTask2: Record "NPR Spfy Task";
    begin
        if AtDateTime = 0DT then
            AtDateTime := Now();

        SpfyTask.Init();
        SpfyTask."Entry No." := 0;
        SpfyTask.Type := TaskType;
        SpfyTask."Table No." := RecRef.Number();
        SpfyTask."Record ID" := RecID;
        SpfyTask."Record Value" := CopyStr(TaskRecordValue, 1, MaxStrLen(SpfyTask."Record Value"));
        SpfyTask."Store Code" := ShopifyStoreCode;
        SpfyTask."Not Before Date-Time" := NotBeforeDateTime;

        // The reusable task is picked in Dedup key order (State last), not by highest entry no.
        SpfyTask2.SetCurrentKey("Table No.", "Store Code", "Record Value", State);
        if SpfyTask.Type = SpfyTask.Type::Modify then
            SpfyTask2.SetRange(Type, SpfyTask.Type::Insert, SpfyTask.Type::Modify)
        else
            SpfyTask2.SetRange(Type, SpfyTask.Type);
        SpfyTask2.SetRange("Table No.", SpfyTask."Table No.");
        SpfyTask2.SetRange("Store Code", SpfyTask."Store Code");
        SpfyTask2.SetRange("Record Value", SpfyTask."Record Value");
        SpfyTask2.SetFilter(State, '%1|%2', SpfyTask2.State::Pending, SpfyTask2.State::Waiting);
        SpfyTask2.SetRange("Record ID", RecID);
        case ReuseExistingDelayed of
            ReuseExistingDelayed::No:
                SpfyTask2.SetRange("Not Before Date-Time", SpfyTask."Not Before Date-Time");
            ReuseExistingDelayed::Later:
                if SpfyTask."Not Before Date-Time" <> 0DT then
                    SpfyTask2.SetFilter("Not Before Date-Time", '%1..', SpfyTask."Not Before Date-Time");
            ReuseExistingDelayed::Any:
                ;
        end;
        SpfyTask2.SetFilter("Log Date", '%1..', CreateDateTime(DT2Date(AtDateTime) - 1, 0T));
        if SpfyTask2.FindLast() then begin
            SpfyTask := SpfyTask2;
            exit(false);
        end;

        if LogDateTime <> 0DT then
            SpfyTask."Log Date" := LogDateTime
        else
            SpfyTask."Log Date" := AtDateTime;
        SpfyTask.State := SpfyTask.State::Pending;
        SpfyTask."Dispatch Id" := CreateGuid();
        SpfyTask.Insert(true);
        exit(true);
    end;

    internal procedure CancelUnsentTask(SpfyTaskEntryNo: BigInteger; CancellationReasonTxt: Text): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTaskEntryNo) then
            exit(false);
        if not (SpfyTask.State in [SpfyTask.State::Pending, SpfyTask.State::Waiting, SpfyTask.State::Quarantined]) then
            exit(false);

        WriteResponse(SpfyTask, CancellationReasonTxt);
        SetCompleted(SpfyTask);
        SpfyTask.Modify();
        exit(true);
    end;

    internal procedure TaskIsUnprocessed(SpfyTaskEntryNo: BigInteger): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetLoadFields(State);
        if not SpfyTask.Get(SpfyTaskEntryNo) then
            exit(false);
        exit(SpfyTask.State <> SpfyTask.State::Completed);
    end;

    internal procedure TaskExists(SpfyTaskEntryNo: BigInteger): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Entry No.", SpfyTaskEntryNo);
        exit(not SpfyTask.IsEmpty());
    end;

    internal procedure ClaimForBatch(var SpfyTaskWork: Record "NPR Spfy Task"): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        if (SpfyTaskRunContext.RunDeadline() <> 0DT) and (CurrentDateTime() > SpfyTaskRunContext.RunDeadline()) then
            exit(false);

        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTaskWork."Entry No.") then
            exit(false);
        if SpfyTask.State <> SpfyTask.State::Pending then
            exit(false);

        SpfyTask.Type := SpfyTaskWork.Type;
        SpfyTask.State := SpfyTask.State::"In Flight";
        SpfyTask.Attempts += 1;
        SpfyTaskWork.CalcFields("Data Output");
        SpfyTask."Data Output" := SpfyTaskWork."Data Output";
        StampClaim(SpfyTask);
        SpfyTask."Last Processing Started at" := SpfyTaskWork."Last Processing Started at";
        SpfyTask."Last Processing Completed at" := 0DT;
        SpfyTask."Last Processing Duration" := 0;
        SpfyTask.Modify();
        Commit();
        exit(true);
    end;

    internal procedure CompleteFromBatch(SpfyTaskEntryNo: BigInteger; ResponseJson: JsonToken; Success: Boolean; ErrorText: Text; var CompletedTask: Record "NPR Spfy Task"): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        OStream: OutStream;
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTaskEntryNo) then
            exit(false);
        // A reclaimed zombie session must not overwrite the outcome of whoever re-claimed and sent the task.
        if SpfyTask.State <> SpfyTask.State::"In Flight" then
            exit(false);
        if (SpfyTask."Claimed By Server Instance" <> ServiceInstanceId()) or (SpfyTask."Claimed By Session" <> SessionId()) then
            exit(false);

        StampCompletion(SpfyTask);
        SpfyTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
        if ErrorText = '' then
            ResponseJson.WriteTo(OStream)
        else
            OStream.WriteText(ErrorText);
        if Success then
            SetCompleted(SpfyTask)
        else
            RecordFailure(SpfyTask, ErrorText);
        SpfyTask.Modify(true);
        CompletedTask := SpfyTask;
        exit(true);
    end;

    internal procedure TransferPrestagedOutcome(SpfyTaskEntryNo: BigInteger; var ResponseBlobTask: Record "NPR Spfy Task"; PrestagedState: Enum "NPR Spfy Task State"; var RealTask: Record "NPR Spfy Task"): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
        TransferredText: Text;
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTaskEntryNo) then
            exit(false);
        if SpfyTask.State <> SpfyTask.State::Pending then
            exit(false);

        ResponseBlobTask.CalcFields(Response);
        SpfyTask.Response := ResponseBlobTask.Response;
        SpfyTask.Type := ResponseBlobTask.Type;
        SpfyTask.Attempts += 1;
        SpfyTask."Last Processing Started at" := ResponseBlobTask."Last Processing Started at";
        StampCompletion(SpfyTask);
        if PrestagedState = PrestagedState::Completed then
            SetCompleted(SpfyTask)
        else begin
            ResponseBlobTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
            TransferredText := TypeHelper.ReadAsTextWithSeparator(IStream, TypeHelper.LFSeparator());
            RecordFailure(SpfyTask, TransferredText);
        end;
        SpfyTask.Modify(true);
        RealTask := SpfyTask;
        exit(true);
    end;

    internal procedure CompleteAsDuplicate(var SpfyTaskWork: Record "NPR Spfy Task"; SentTaskEntryNo: BigInteger): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
        DuplicateTaskLbl: Label 'This task is a duplicate of another task (%1 %2). The requested update will be handled there.', Comment = '%1 = the Entry No. field caption, %2 - Shopify Task Entry No.';
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTaskWork."Entry No.") then
            exit(false);
        if SpfyTask.State <> SpfyTask.State::Pending then
            exit(false);

        SpfyTask.Type := SpfyTaskWork.Type;
        SpfyTask.Attempts += 1;
        SpfyTask."Last Processing Started at" := SpfyTaskWork."Last Processing Started at";
        StampCompletion(SpfyTask);
        WriteResponse(SpfyTask, StrSubstNo(DuplicateTaskLbl, SpfyTask.FieldCaption("Entry No."), SentTaskEntryNo));
        SetCompleted(SpfyTask);
        SpfyTask.Modify(true);
        exit(true);
    end;

    internal procedure ClaimSingle(var SpfyTask: Record "NPR Spfy Task"): Boolean
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit(false);
        if SpfyTask.State <> SpfyTask.State::Pending then
            exit(false);

        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        SpfyTask.State := SpfyTask.State::"In Flight";
        SpfyTask.Attempts += 1;
        StampClaim(SpfyTask);
        SpfyTask."Last Processing Started at" := CurrentDateTime();
        SpfyTask."Last Processing Completed at" := 0DT;
        SpfyTask."Last Processing Duration" := 0;
        SpfyTask."Completed At" := 0DT;
        SpfyTask.Modify(true);
        Commit();
        exit(true);
    end;

    internal procedure CompleteSingle(var SpfyTask: Record "NPR Spfy Task"; Success: Boolean; ErrorText: Text)
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit;
        // A reclaimed zombie session must not overwrite the outcome of whoever re-claimed and sent the task.
        if SpfyTask.State <> SpfyTask.State::"In Flight" then
            exit;
        if (SpfyTask."Claimed By Server Instance" <> ServiceInstanceId()) or (SpfyTask."Claimed By Session" <> SessionId()) then
            exit;

        StampCompletion(SpfyTask);
        if Success then
            SetCompleted(SpfyTask)
        else begin
            if ErrorText <> '' then
                WriteResponse(SpfyTask, ErrorText);
            RecordFailure(SpfyTask, ErrorText);
        end;
        SpfyTask.Modify(true);
        Commit();
    end;

    internal procedure AttemptCap(): Integer
    begin
        exit(3);
    end;

    internal procedure ReclaimDeadClaim(var SpfyTask: Record "NPR Spfy Task"; AtDateTime: DateTime): Boolean
    var
        ReclaimedClaimLbl: Label 'The processing session that claimed this task is no longer active. The task has been released for another attempt.';
        ReclaimedQuarantinedLbl: Label 'The processing session that claimed this task is no longer active and the task has no attempts left. It has been quarantined.';
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit(false);
        if SpfyTask.State <> SpfyTask.State::"In Flight" then
            exit(false);
        if ClaimingSessionIsActive(SpfyTask) and not ClaimIsBeyondCeiling(SpfyTask, AtDateTime) then
            exit(false);

        if SpfyTask.Attempts >= AttemptCap() then begin
            WriteResponse(SpfyTask, ReclaimedQuarantinedLbl);
            RecordFailure(SpfyTask, ReclaimedQuarantinedLbl);
        end else begin
            WriteResponse(SpfyTask, ReclaimedClaimLbl);
            RecordFailure(SpfyTask, ReclaimedClaimLbl);
        end;
        SpfyTask.Modify(true);
        Commit();
        exit(true);
    end;

    local procedure ClaimingSessionIsActive(SpfyTask: Record "NPR Spfy Task"): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        if SpfyTask."Claimed By Server Instance" <= 0 then
            exit(false);
        ActiveSession.SetRange("Server Instance ID", SpfyTask."Claimed By Server Instance");
        ActiveSession.SetRange("Session ID", SpfyTask."Claimed By Session");
        exit(not ActiveSession.IsEmpty());
    end;

    local procedure ClaimIsBeyondCeiling(SpfyTask: Record "NPR Spfy Task"; AtDateTime: DateTime): Boolean
    begin
        if SpfyTask."Claimed At" = 0DT then
            exit(true);
        exit((AtDateTime - SpfyTask."Claimed At") >= ReclaimCeilingMs());
    end;

    local procedure ReclaimCeilingMs(): Integer
    begin
        exit(2 * 60 * 60 * 1000);
    end;

    internal procedure Requeue(var SpfyTask: Record "NPR Spfy Task"): Boolean
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit(false);
        if not (SpfyTask.State in [SpfyTask.State::Pending, SpfyTask.State::Quarantined]) then
            exit(false);

        SpfyTask.Attempts := 0;
        SpfyTask.State := SpfyTask.State::Pending;
        ClearClaim(SpfyTask);
        ClearWaiting(SpfyTask);
        SpfyTask.Modify(true);
        exit(true);
    end;

    internal procedure Resend(var SpfyTask: Record "NPR Spfy Task"): Boolean
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit(false);
        if SpfyTask.State <> SpfyTask.State::Completed then
            exit(false);

        SpfyTask.State := SpfyTask.State::Pending;
        SpfyTask.Attempts := 0;
        SpfyTask."Dispatch Id" := CreateGuid();
        SpfyTask."Completed At" := 0DT;
        SpfyTask.Modify(true);
        exit(true);
    end;

    internal procedure SetWaiting(var SpfyTask: Record "NPR Spfy Task"; WaitingReasonTxt: Text; AtDateTime: DateTime)
    begin
        SetWaiting(SpfyTask, WaitingReasonTxt, AtDateTime, '');
    end;

    internal procedure SetWaiting(var SpfyTask: Record "NPR Spfy Task"; WaitingReasonTxt: Text; AtDateTime: DateTime; FullErrorText: Text)
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit;
        if SpfyTask.State <> SpfyTask.State::Pending then
            exit;

        SpfyTask.State := SpfyTask.State::Waiting;
        if SpfyTask."Waiting Since" = 0DT then begin
            if AtDateTime = 0DT then
                AtDateTime := Now();
            SpfyTask."Waiting Since" := AtDateTime;
        end;
        SpfyTask."Waiting Reason" := CopyStr(WaitingReasonTxt, 1, MaxStrLen(SpfyTask."Waiting Reason"));
        if FullErrorText <> '' then
            WriteResponse(SpfyTask, FullErrorText);
        SpfyTask.Modify(true);
        Commit();
    end;

    internal procedure ReleaseWaiting(var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit;
        if SpfyTask.State <> SpfyTask.State::Waiting then
            exit;

        SpfyTask.State := SpfyTask.State::Pending;
        ClearWaiting(SpfyTask);
        SpfyTask.Modify(true);
    end;

    internal procedure RestartWaitingSince(var SpfyTask: Record "NPR Spfy Task"; AtDateTime: DateTime)
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit;
        if SpfyTask.State <> SpfyTask.State::Waiting then
            exit;
        if SpfyTask."Waiting Since" = 0DT then
            exit;
        if SpfyTask."Waiting Since" >= AtDateTime then
            exit;

        SpfyTask."Waiting Since" := AtDateTime;
        SpfyTask.Modify(true);
    end;

    internal procedure UpdateWaitingReason(var SpfyTask: Record "NPR Spfy Task"; WaitingReasonTxt: Text)
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit;
        if SpfyTask.State <> SpfyTask.State::Waiting then
            exit;

        // No commit: the waiting pass commits once when it ends.
        SpfyTask."Waiting Reason" := CopyStr(WaitingReasonTxt, 1, MaxStrLen(SpfyTask."Waiting Reason"));
        SpfyTask.Modify(true);
    end;

    internal procedure RefreshWaiting(var SpfyTask: Record "NPR Spfy Task"; WaitingReasonTxt: Text; FullErrorText: Text)
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit;
        if SpfyTask.State <> SpfyTask.State::Waiting then
            exit;

        SpfyTask."Waiting Reason" := CopyStr(WaitingReasonTxt, 1, MaxStrLen(SpfyTask."Waiting Reason"));
        if FullErrorText <> '' then
            WriteResponse(SpfyTask, FullErrorText);
        SpfyTask.Modify(true);
        Commit();
    end;

    internal procedure ShiftWaitingSince(var SpfyTask: Record "NPR Spfy Task"; GapDuration: Duration; AtDateTime: DateTime)
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit;
        if SpfyTask.State <> SpfyTask.State::Waiting then
            exit;
        if SpfyTask."Waiting Since" = 0DT then
            exit;
        if SpfyTask."Waiting Since" >= AtDateTime then
            exit;

        // A task parked mid-outage must never end up with a clock in the future.
        if SpfyTask."Waiting Since" + GapDuration >= AtDateTime then
            SpfyTask."Waiting Since" := AtDateTime
        else
            SpfyTask."Waiting Since" += GapDuration;
        SpfyTask.Modify(true);
    end;

    // Same In Flight re-check under the lock as the deletion-log path, for kinds that own no delete intent.
    internal procedure DeleteUnsentTask(SpfyTaskEntryNo: BigInteger): Boolean
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTaskEntryNo) then
            exit(false);
        if SpfyTask.State = SpfyTask.State::"In Flight" then
            exit(false);

        SpfyTask.Delete(true);
        exit(true);
    end;

    internal procedure DeleteAllForStore(StoreCode: Code[20])
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.SetRange("Store Code", StoreCode);
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(true);
    end;

    // Terminal, not cancelled: cancel would complete the task while detection has already moved its hash baseline.
    internal procedure QuarantineAgedWaiting(var SpfyTask: Record "NPR Spfy Task"; ReasonTxt: Text; LookupErrorText: Text; ThresholdHours: Integer): Boolean
    var
        AgedParkQuarantinedLbl: Label 'The task waited %1 hours or more (engine downtime not counted) for a related update to reach Shopify first and was quarantined: %2', Comment = '%1 = the aging threshold in hours, %2 = what the task was waiting for';
        ResponseDetail: Text;
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit(false);
        if SpfyTask.State <> SpfyTask.State::Waiting then
            exit(false);

        SpfyTask."Waiting Reason" := CopyStr(ReasonTxt, 1, MaxStrLen(SpfyTask."Waiting Reason"));
        ResponseDetail := LookupErrorText;
        if ResponseDetail = '' then
            ResponseDetail := ReasonTxt;
        WriteResponse(SpfyTask, StrSubstNo(AgedParkQuarantinedLbl, ThresholdHours, ResponseDetail));
        SpfyTask.State := SpfyTask.State::Quarantined;
        ClearClaim(SpfyTask);
        // Attempts and the downtime-discounted clock are kept: the park never spent an attempt.
        SpfyTask.Modify(true);
        Commit();
        exit(true);
    end;

    internal procedure CompleteNoLongerApplicable(var SpfyTask: Record "NPR Spfy Task"; ReasonTxt: Text)
    begin
        SpfyTask.ReadIsolation(IsolationLevel::UpdLock);
        if not SpfyTask.Get(SpfyTask."Entry No.") then
            exit;
        if not (SpfyTask.State in [SpfyTask.State::Pending, SpfyTask.State::Waiting]) then
            exit;

        WriteResponse(SpfyTask, ReasonTxt);
        SetCompleted(SpfyTask);
        SpfyTask.Modify(true);
        Commit();
    end;

    local procedure SetCompleted(var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask.State := SpfyTask.State::Completed;
        SpfyTask."Completed At" := CurrentDateTime();
        ClearClaim(SpfyTask);
        ClearWaiting(SpfyTask);
    end;

    local procedure RecordFailure(var SpfyTask: Record "NPR Spfy Task"; ErrorText: Text)
    begin
        ClearClaim(SpfyTask);
        if SpfyTask.Attempts >= AttemptCap() then begin
            SpfyTask.State := SpfyTask.State::Quarantined;
            EmitQuarantineAlert(SpfyTask, ErrorText);
        end else
            SpfyTask.State := SpfyTask.State::Pending;
    end;

    local procedure EmitQuarantineAlert(SpfyTask: Record "NPR Spfy Task"; ErrorText: Text)
    var
        Sentry: Codeunit "NPR Sentry";
        TaskTypeName: Text;
        QuarantinedTaskLbl: Label 'Shopify task %1 was quarantined after %2 failed dispatch attempts; the update will not be sent without manual action. Type %3, table %4, record value %5, store %6. Last error: %7', Locked = true;
        NoStoredErrorTextLbl: Label 'The task failed without an error message from Shopify.', Locked = true;
    begin
        if ErrorText = '' then begin
            ErrorText := StoredResponseText(SpfyTask);
            if ErrorText = '' then
                ErrorText := NoStoredErrorTextLbl;
        end;
        SpfyTask.Type.Names().Get(SpfyTask.Type.Ordinals().IndexOf(SpfyTask.Type.AsInteger()), TaskTypeName);
        Sentry.InitScopeAndTransaction('Shopify task quarantine', 'bc.spfy.task_list.quarantine');
        Sentry.AddError(StrSubstNo(QuarantinedTaskLbl, SpfyTask."Entry No.", SpfyTask.Attempts, TaskTypeName, SpfyTask."Table No.", SpfyTask."Record Value", SpfyTask."Store Code", ErrorText));
        Sentry.FinalizeScope();
    end;

    local procedure StoredResponseText(SpfyTask: Record "NPR Spfy Task"): Text
    var
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
    begin
        // In-memory blob first: on the batch path the outcome was just written and is newer than the persisted row.
        if not SpfyTask.Response.HasValue() then
            SpfyTask.CalcFields(Response);
        if not SpfyTask.Response.HasValue() then
            exit('');
        SpfyTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(IStream, ' '));
    end;

    local procedure StampClaim(var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask."Claimed At" := Now();
        SpfyTask."Claimed By Server Instance" := ServiceInstanceId();
        SpfyTask."Claimed By Session" := SessionId();
    end;

    local procedure StampCompletion(var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask."Last Processing Completed at" := CurrentDateTime();
        if SpfyTask."Last Processing Started at" = 0DT then
            SpfyTask."Last Processing Duration" := 0
        else
            SpfyTask."Last Processing Duration" := (SpfyTask."Last Processing Completed at" - SpfyTask."Last Processing Started at") / 1000;
    end;

    local procedure ClearClaim(var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask."Claimed At" := 0DT;
        SpfyTask."Claimed By Server Instance" := 0;
        SpfyTask."Claimed By Session" := 0;
    end;

    local procedure ClearWaiting(var SpfyTask: Record "NPR Spfy Task")
    begin
        SpfyTask."Waiting Since" := 0DT;
        SpfyTask."Waiting Reason" := '';
    end;

    local procedure WriteResponse(var SpfyTask: Record "NPR Spfy Task"; ResponseText: Text)
    var
        OStream: OutStream;
    begin
        Clear(SpfyTask.Response);
        SpfyTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(ResponseText);
    end;

    local procedure Now(): DateTime
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        if SpfyTaskRunContext.CycleTime() <> 0DT then
            exit(SpfyTaskRunContext.CycleTime());
        exit(CurrentDateTime());
    end;
}

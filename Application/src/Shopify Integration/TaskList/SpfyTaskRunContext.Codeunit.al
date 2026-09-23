codeunit 6151226 "NPR Spfy Task Run Context"
{
    Access = Internal;
    SingleInstance = true;

    var
        _SendBoundary: Interface "NPR Spfy Task Send Boundary";
        _KindIsBatched: Dictionary of [Integer, Boolean];
        _BatchClaimEntryNos: List of [BigInteger];
        _CycleTime: DateTime;
        _RunDeadline: DateTime;
        _PTEHandled: Boolean;
        _SendBoundarySet: Boolean;

    internal procedure SetRunDeadline(DeadlineDT: DateTime)
    begin
        _RunDeadline := DeadlineDT;
    end;

    internal procedure RunDeadline(): DateTime
    begin
        exit(_RunDeadline);
    end;

    internal procedure DeadlineExpired(): Boolean
    begin
        exit((_RunDeadline <> 0DT) and (CurrentDateTime() > _RunDeadline));
    end;

    internal procedure ClearRunDeadline()
    begin
        _RunDeadline := 0DT;
    end;

    internal procedure SetCycleTime(AtDateTime: DateTime)
    begin
        _CycleTime := AtDateTime;
    end;

    internal procedure CycleTime(): DateTime
    begin
        exit(_CycleTime);
    end;

    internal procedure ClearCycleTime()
    begin
        _CycleTime := 0DT;
    end;

    internal procedure SetSendBoundary(NewBoundary: Interface "NPR Spfy Task Send Boundary")
    begin
        _SendBoundary := NewBoundary;
        _SendBoundarySet := true;
    end;

    internal procedure HasSendBoundary(): Boolean
    begin
        exit(_SendBoundarySet);
    end;

    internal procedure SendBoundary(): Interface "NPR Spfy Task Send Boundary"
    begin
        exit(_SendBoundary);
    end;

    internal procedure ClearSendBoundary()
    begin
        _SendBoundarySet := false;
    end;

    // Codeunit.Run cannot return the flag a subscriber set, so the isolated dispatch runner hands it over here.
    internal procedure SetPTEHandled(Handled: Boolean)
    begin
        _PTEHandled := Handled;
    end;

    internal procedure GetPTEHandled(): Boolean
    begin
        exit(_PTEHandled);
    end;

    internal procedure ClearPTEHandled()
    begin
        _PTEHandled := false;
    end;

    // Dispatch-local evidence of what this session claimed for the group being sent: an Attempts comparison cannot tell
    // our own claim from a concurrent one or from an operator requeue.
    internal procedure ClearBatchClaims()
    begin
        Clear(_BatchClaimEntryNos);
    end;

    internal procedure RecordBatchClaim(EntryNo: BigInteger)
    begin
        _BatchClaimEntryNos.Add(EntryNo);
    end;

    // Per entry rather than a plain flag: the public claim facade takes any task, so a subscriber claiming a row it was
    // never handed must not count as having claimed the group it abandoned.
    internal procedure AnyBatchClaimIn(var TempSpfyTaskGroup: Record "NPR Spfy Task" temporary): Boolean
    begin
        if not TempSpfyTaskGroup.FindSet() then
            exit(false);
        repeat
            if _BatchClaimEntryNos.Contains(TempSpfyTaskGroup."Entry No.") then
                exit(true);
        until TempSpfyTaskGroup.Next() = 0;
        exit(false);
    end;

    // Memoized per cycle: the batch/single answer decides the claim handshake at several points, and a subscriber
    // answering differently mid-row would dispatch an unclaimed task as single and resend it every cycle.
    internal procedure SetKindIsBatched(TableNo: Integer; IsBatch: Boolean)
    begin
        _KindIsBatched.Set(TableNo, IsBatch);
    end;

    internal procedure TryGetKindIsBatched(TableNo: Integer; var IsBatch: Boolean): Boolean
    begin
        Clear(IsBatch);
        exit(_KindIsBatched.Get(TableNo, IsBatch));
    end;

    internal procedure ClearKindIsBatched()
    begin
        Clear(_KindIsBatched);
    end;
}

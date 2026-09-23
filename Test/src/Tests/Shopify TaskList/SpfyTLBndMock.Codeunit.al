codeunit 85317 "NPR Spfy TL Bnd Mock" implements "NPR Spfy Task Send Boundary"
{
    // Scriptable stand-in for the Shopify send boundary: no HTTP, never raises for a dispatch outcome, and touches real rows only through the queue facade.
    Access = Internal;
    SingleInstance = true;

    var
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _OutcomeSucceeds: Dictionary of [BigInteger, Boolean];
        _OutcomeErrors: Dictionary of [BigInteger, Text];
        _DispatchedEntryNos: List of [BigInteger];
        _FailureErrorText: Text;
        _HandOverFailureText: Text;
        _ThrowAfterNRows: Integer;
        _DispatchCount: Integer;
        _LastRowCount: Integer;
        _LastTableNo: Integer;
        _LastWasTemporary: Boolean;
        _WholeCallFailure: Boolean;

    procedure Dispatch(var SpfyTaskWork: Record "NPR Spfy Task"; var ErrorText: Text): Boolean
    begin
        Clear(ErrorText);
        _DispatchCount += 1;
        _LastWasTemporary := SpfyTaskWork.IsTemporary();
        _LastTableNo := SpfyTaskWork."Table No.";
        if _LastWasTemporary then
            exit(DispatchWorkList(SpfyTaskWork, ErrorText));
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

    procedure SetThrowMidBatch(AfterNRows: Integer; ErrorText: Text)
    begin
        _ThrowAfterNRows := AfterNRows;
        _FailureErrorText := ErrorText;
    end;

    procedure Reset()
    begin
        Clear(_OutcomeSucceeds);
        Clear(_OutcomeErrors);
        Clear(_DispatchedEntryNos);
        _FailureErrorText := '';
        _HandOverFailureText := '';
        _ThrowAfterNRows := 0;
        _DispatchCount := 0;
        _LastRowCount := 0;
        _LastTableNo := 0;
        _LastWasTemporary := false;
        _WholeCallFailure := false;
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

        if _WholeCallFailure then begin
            ErrorText := _FailureErrorText;
            exit(false);
        end;
        exit(true);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Task List Migration", OnBeforeHandOverLegacyQueue, '', false, false)]
    local procedure OnBeforeHandOverLegacyQueue(var FailWithErrorText: Text)
    begin
        if _HandOverFailureText <> '' then
            FailWithErrorText := _HandOverFailureText;
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

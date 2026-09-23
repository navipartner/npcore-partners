codeunit 85402 "NPR Spfy TL PTE Dispatch Sub"
{
    // Scriptable stand-in for a customer extension on the Shopify task dispatch seam: handles, passes, errors,
    // or claims and completes a batch group through the public write facade. Also answers the batch-kind question.
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _SpfyIntegrationPublic: Codeunit "NPR Spfy Integration Public";
        _BatchedTableNos: List of [Integer];
        _NotBatchedTableNos: List of [Integer];
        _ClassifiedTableNos: List of [Integer];
        _DispatchedEntryNos: List of [BigInteger];
        _DispatchedMigratedFrom: List of [BigInteger];
        _GroupSizes: List of [Integer];
        _ResponseText: Text;
        _ErrorText: Text;
        _ClassifyErrorText: Text;
        _ClaimRows: Integer;
        _CompleteRows: Integer;
        _DispatchCount: Integer;
        _ClassifyCount: Integer;
        _LastGroupSize: Integer;
        _ClaimedRows: Integer;
        _CompletedRows: Integer;
        _Handle: Boolean;
        _LastWasTemporary: Boolean;
        _ExpireRunDeadline: Boolean;
        _ForeignClaimEntryNo: BigInteger;
        _ForeignClaimSucceeded: Boolean;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnBeforeDispatchShopifyTask', '', false, false)]
    local procedure DispatchShopifyTask(var SpfyTask: Record "NPR Spfy Task"; var Handled: Boolean)
    begin
        _DispatchCount += 1;
        _LastWasTemporary := SpfyTask.IsTemporary();
        if _LastWasTemporary then
            DispatchGroup(SpfyTask, Handled)
        else
            DispatchSingle(SpfyTask, Handled);
    end;

    local procedure DispatchSingle(var SpfyTask: Record "NPR Spfy Task"; var Handled: Boolean)
    var
        OStream: OutStream;
    begin
        _LastGroupSize := 1;
        _GroupSizes.Add(1);
        _DispatchedEntryNos.Add(SpfyTask."Entry No.");
        _DispatchedMigratedFrom.Add(SpfyTask."Migrated From NC Entry No.");
        if _ErrorText <> '' then
            Error(_ErrorText);
        if not _Handle then
            exit;
        if _ResponseText <> '' then begin
            SpfyTask.Response.CreateOutStream(OStream, TextEncoding::UTF8);
            OStream.WriteText(_ResponseText);
            SpfyTask.Modify();
        end;
        Handled := true;
    end;

    local procedure DispatchGroup(var SpfyTaskGroup: Record "NPR Spfy Task"; var Handled: Boolean)
    var
        ClaimedSpfyTask: Record "NPR Spfy Task";
        ForeignSpfyTask: Record "NPR Spfy Task";
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        ResponseJObject: JsonObject;
        ResponseJson: JsonToken;
    begin
        _LastGroupSize := SpfyTaskGroup.Count();
        _GroupSizes.Add(_LastGroupSize);
        if _ExpireRunDeadline then
            SpfyTaskRunContext.SetRunDeadline(CurrentDateTime() - 1000);
        if _ForeignClaimEntryNo <> 0 then begin
            ForeignSpfyTask.Get(_ForeignClaimEntryNo);
            ForeignSpfyTask."Last Processing Started at" := CurrentDateTime();
            _ForeignClaimSucceeded := _SpfyIntegrationPublic.ClaimShopifyTaskForBatch(ForeignSpfyTask);
        end;
        if _ErrorText <> '' then
            Error(_ErrorText);
        if not _Handle then
            exit;

        ResponseJson := ResponseJObject.AsToken();
        if SpfyTaskGroup.FindSet() then
            repeat
                _DispatchedEntryNos.Add(SpfyTaskGroup."Entry No.");
                _DispatchedMigratedFrom.Add(SpfyTaskGroup."Migrated From NC Entry No.");
                if _ClaimedRows < _ClaimRows then begin
                    // A copy is claimed so the facade cannot disturb the work list this loop reads.
                    ClaimedSpfyTask := SpfyTaskGroup;
                    ClaimedSpfyTask."Last Processing Started at" := CurrentDateTime();
                    if _SpfyIntegrationPublic.ClaimShopifyTaskForBatch(ClaimedSpfyTask) then begin
                        _ClaimedRows += 1;
                        if _CompletedRows < _CompleteRows then
                            if _SpfyIntegrationPublic.CompleteShopifyTaskFromBatch(SpfyTaskGroup."Entry No.", ResponseJson, true, '') then
                                _CompletedRows += 1;
                    end;
                end;
            until SpfyTaskGroup.Next() = 0;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Spfy Integration Events", 'OnCheckIfTaskKindIsBatched', '', false, false)]
    local procedure CheckIfTaskKindIsBatched(TaskTableNo: Integer; var IsBatch: Boolean; var Handled: Boolean)
    begin
        _ClassifyCount += 1;
        _ClassifiedTableNos.Add(TaskTableNo);
        if _ClassifyErrorText <> '' then
            Error(_ClassifyErrorText);
        if _BatchedTableNos.Contains(TaskTableNo) then begin
            IsBatch := true;
            Handled := true;
            exit;
        end;
        if _NotBatchedTableNos.Contains(TaskTableNo) then begin
            IsBatch := false;
            Handled := true;
        end;
    end;

    internal procedure Reset()
    begin
        Clear(_BatchedTableNos);
        Clear(_NotBatchedTableNos);
        Clear(_ClassifiedTableNos);
        Clear(_DispatchedEntryNos);
        Clear(_DispatchedMigratedFrom);
        Clear(_GroupSizes);
        _ResponseText := '';
        _ErrorText := '';
        _ClassifyErrorText := '';
        _ClaimRows := 0;
        _CompleteRows := 0;
        _DispatchCount := 0;
        _ClassifyCount := 0;
        _LastGroupSize := 0;
        _ClaimedRows := 0;
        _CompletedRows := 0;
        _Handle := false;
        _LastWasTemporary := false;
        _ExpireRunDeadline := false;
        _ForeignClaimEntryNo := 0;
        _ForeignClaimSucceeded := false;
    end;

    // Handles the dispatch and writes ResponseTxt onto the task record before setting Handled.
    internal procedure SetHandleWithResponse(ResponseTxt: Text)
    begin
        _Handle := true;
        _ResponseText := ResponseTxt;
    end;

    // Handles a group, claiming ClaimCount rows and completing CompleteCount of those claims.
    internal procedure SetHandleGroup(ClaimCount: Integer; CompleteCount: Integer)
    begin
        _Handle := true;
        _ClaimRows := ClaimCount;
        _CompleteRows := CompleteCount;
    end;

    internal procedure SetRaiseError(ErrorTxt: Text)
    begin
        _ErrorText := ErrorTxt;
    end;

    // Simulates a subscriber that claims a task it was never handed: the claim facade accepts any entry number.
    internal procedure SetClaimForeignEntry(EntryNo: BigInteger)
    begin
        _ForeignClaimEntryNo := EntryNo;
    end;

    internal procedure ForeignClaimSucceeded(): Boolean
    begin
        exit(_ForeignClaimSucceeded);
    end;

    // Simulates the run budget running out while the subscriber works: every claim it then attempts is refused.
    internal procedure SetExpireRunDeadlineOnDispatch()
    begin
        _ExpireRunDeadline := true;
    end;

    internal procedure SetBatchedTable(TableNo: Integer)
    begin
        _BatchedTableNos.Add(TableNo);
    end;

    internal procedure SetNotBatchedTable(TableNo: Integer)
    begin
        _NotBatchedTableNos.Add(TableNo);
    end;

    internal procedure SetClassifyError(ErrorTxt: Text)
    begin
        _ClassifyErrorText := ErrorTxt;
    end;

    internal procedure DispatchCount(): Integer
    begin
        exit(_DispatchCount);
    end;

    internal procedure LastGroupSize(): Integer
    begin
        exit(_LastGroupSize);
    end;

    internal procedure GroupSizeAt(Index: Integer): Integer
    begin
        if (Index < 1) or (Index > _GroupSizes.Count()) then
            exit(0);
        exit(_GroupSizes.Get(Index));
    end;

    internal procedure LastDispatchWasTemporary(): Boolean
    begin
        exit(_LastWasTemporary);
    end;

    internal procedure DispatchedEntryNo(Index: Integer): BigInteger
    begin
        if (Index < 1) or (Index > _DispatchedEntryNos.Count()) then
            exit(0);
        exit(_DispatchedEntryNos.Get(Index));
    end;

    internal procedure DispatchedMigratedFrom(Index: Integer): BigInteger
    begin
        if (Index < 1) or (Index > _DispatchedMigratedFrom.Count()) then
            exit(0);
        exit(_DispatchedMigratedFrom.Get(Index));
    end;

    internal procedure DispatchedRowCount(): Integer
    begin
        exit(_DispatchedEntryNos.Count());
    end;

    internal procedure WasDispatched(SpfyTaskEntryNo: BigInteger): Boolean
    begin
        exit(_DispatchedEntryNos.Contains(SpfyTaskEntryNo));
    end;

    internal procedure ClassifyCount(): Integer
    begin
        exit(_ClassifyCount);
    end;

    internal procedure WasClassified(TableNo: Integer): Boolean
    begin
        exit(_ClassifiedTableNos.Contains(TableNo));
    end;

    internal procedure ClaimedRows(): Integer
    begin
        exit(_ClaimedRows);
    end;

    internal procedure CompletedRows(): Integer
    begin
        exit(_CompletedRows);
    end;
}

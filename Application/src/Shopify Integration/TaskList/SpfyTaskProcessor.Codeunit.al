codeunit 6151214 "NPR Spfy Task Processor"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        RunStoreCycle(CopyStr(Rec."Parameter String", 1, 20), CurrentDateTime());
    end;

    var
        _DefaultSendBoundary: Codeunit "NPR Spfy Task Send Bnd Impl";
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _SpfySendItemsInv: Codeunit "NPR Spfy Task Send Items&Inv";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        _LookupFailedNoTextLbl: Label 'The Shopify lookup for this task''s precondition failed without an error message.';
        _SourceGoneLbl: Label 'The source record no longer exists. The request is no longer applicable.';
        _WaitingForParentLbl: Label 'Awaiting parent product sync';
        _WaitingForInventoryItemLbl: Label 'Awaiting inventory item sync';
        _WaitingForLocationActivationLbl: Label 'Awaiting Shopify location activation';
        _WaitingForVariantLbl: Label 'Awaiting variant sync';

    internal procedure SetSendBoundary(NewBoundary: Interface "NPR Spfy Task Send Boundary")
    begin
        _SpfyTaskRunContext.SetSendBoundary(NewBoundary);
    end;

    local procedure SendBoundary(): Interface "NPR Spfy Task Send Boundary"
    begin
        if _SpfyTaskRunContext.HasSendBoundary() then
            exit(_SpfyTaskRunContext.SendBoundary());
        exit(_DefaultSendBoundary);
    end;

    internal procedure RunStoreCycle(StoreCode: Code[20]; AtDateTime: DateTime)
    var
        TempSpfyTaskBatch: Record "NPR Spfy Task" temporary;
        Deadline: DateTime;
    begin
        ClearRunContext();
        if not ProcessingIsAllowed() then
            exit;
        if not IntegrationIsEnabledForStore(StoreCode) then
            exit;

        Deadline := AtDateTime + RunBudgetMs();
        _SpfyTaskRunContext.SetRunDeadline(Deadline);
        _SpfyTaskRunContext.SetCycleTime(AtDateTime);

        ApplyDowntimeDiscount(StoreCode, AtDateTime);

        RecoverNcResiduals(Deadline);

        RecoverStaleClaims(StoreCode, AtDateTime, Deadline);
        ReevaluateWaitingTasks(StoreCode, AtDateTime, Deadline);
        // Proof the waiting machinery ran, so a store whose dispatch phase keeps dying is never read as downtime.
        StampCycleRun(StoreCode, CurrentDateTime());
        Commit();
        ProcessReadyTasks(StoreCode, AtDateTime, Deadline, TempSpfyTaskBatch);
        DispatchBatchGroups(TempSpfyTaskBatch, Deadline);

        StampCycleRun(StoreCode, CurrentDateTime());
        ClearRunContext();
    end;

    local procedure ApplyDowntimeDiscount(StoreCode: Code[20]; AtDateTime: DateTime)
    var
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskToUpdate: Record "NPR Spfy Task";
        CycleGap: Duration;
        EffectiveGrace: Integer;
        NeverCycled: Boolean;
    begin
        // Read before the pointer lock: it reaches another table and nothing needs it while the lock is held.
        EffectiveGrace := EffectiveGraceMs(StoreCode);
        // Unlocked probe: a healthy cycle must not hold the pointer row across the waiting pass and its HTTP calls.
        if not DiscountIsDue(StoreCode, AtDateTime, EffectiveGrace) then
            exit;

        // The deciding read repeats under the lock, so no concurrent stamp can slip in and double-discount the rows.
        SpfyDataSyncPointer.LockTable();
        // No stamp means no evidence the engine was ever alive for this store, which is not the same as no downtime.
        NeverCycled := true;
        if SpfyDataSyncPointer.Get(StoreCode) then
            if SpfyDataSyncPointer."Last Task List Cycle At" <> 0DT then begin
                NeverCycled := false;
                CycleGap := AtDateTime - SpfyDataSyncPointer."Last Task List Cycle At";
            end;
        if not NeverCycled and (CycleGap <= EffectiveGrace) then begin
            // A concurrent cycle stamped first: commit so the lock is not carried into the rest of the run.
            Commit();
            exit;
        end;

        SpfyTask.SetCurrentKey("Store Code", State, "Not Before Date-Time");
        SpfyTask.SetRange("Store Code", StoreCode);
        SpfyTask.SetRange(State, SpfyTask.State::Waiting);
        AlertOnOversizedSweep(StoreCode, SpfyTask.Count());
        SpfyTask.SetLoadFields("Entry No.");
        if SpfyTask.FindSet() then
            repeat
                Clear(SpfyTaskToUpdate);
                SpfyTaskToUpdate."Entry No." := SpfyTask."Entry No.";
                if NeverCycled then
                    _SpfyTaskQueue.RestartWaitingSince(SpfyTaskToUpdate, AtDateTime)
                else
                    _SpfyTaskQueue.ShiftWaitingSince(SpfyTaskToUpdate, CycleGap, AtDateTime);
            until SpfyTask.Next() = 0;
        // One transaction, no deadline bail: the discount and its stamp land together or the error retries them whole.
        StampCycleRun(StoreCode, AtDateTime);
        Commit();
    end;

    local procedure AlertOnOversizedSweep(StoreCode: Code[20]; WaitingRowCount: Integer)
    var
        Sentry: Codeunit "NPR Sentry";
        OversizedSweepLbl: Label 'The Shopify task list downtime sweep for store %1 covers %2 waiting task(s) in a single transaction. If cycles for this store keep failing without completing, the sweep may be too large to finish and the store will stop sending until the waiting backlog is reduced.', Locked = true;
    begin
        if WaitingRowCount < SweepAlertThreshold() then
            exit;
        Sentry.InitScopeAndTransaction('Shopify task list oversized sweep', 'bc.spfy.task_list.oversized_sweep');
        Sentry.AddError(StrSubstNo(OversizedSweepLbl, StoreCode, WaitingRowCount));
        Sentry.FinalizeScope();
    end;

    local procedure StampCycleRun(StoreCode: Code[20]; StampAt: DateTime)
    var
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
    begin
        SpfyDataSyncPointer.LockTable();
        if not SpfyDataSyncPointer.Get(StoreCode) then begin
            SpfyDataSyncPointer.Init();
            SpfyDataSyncPointer."Shopify Store Code" := StoreCode;
            SpfyDataSyncPointer.Insert(true);
        end;
        // Monotonic: a wall-clock stamp must never pull the pointer back behind a later logical cycle time.
        if SpfyDataSyncPointer."Last Task List Cycle At" >= StampAt then
            exit;
        SpfyDataSyncPointer."Last Task List Cycle At" := StampAt;
        SpfyDataSyncPointer.Modify(true);
    end;

    internal procedure ProcessTaskManually(var SpfyTask: Record "NPR Spfy Task")
    begin
        ProcessTaskManually(SpfyTask, true);
    end;

    internal procedure ProcessTaskManually(var SpfyTask: Record "NPR Spfy Task"; ShowWaitingMessage: Boolean)
    var
        SpfyTaskToProcess: Record "NPR Spfy Task";
        TempSpfyTaskBatch: Record "NPR Spfy Task" temporary;
        StillWaitingMsg: Label 'The task is waiting for another update to complete first: %1', Comment = '%1 = the reason the task is waiting';
    begin
        ClearRunContext();
        // The new queue only accumulates until the migration completes; sending now could overtake a draining legacy task.
        if not ProcessingIsAllowed() then
            exit;
        if not SpfyTaskToProcess.Get(SpfyTask."Entry No.") then
            exit;
        if not (SpfyTaskToProcess.State in [SpfyTaskToProcess.State::Pending, SpfyTaskToProcess.State::Waiting]) then
            exit;

        if not EvaluateAndClaimOrDefer(SpfyTaskToProcess, CurrentDateTime()) then begin
            if SpfyTaskToProcess.Get(SpfyTask."Entry No.") then
                if (SpfyTaskToProcess.State = SpfyTaskToProcess.State::Waiting) and ShowWaitingMessage and GuiAllowed() then
                    Message(StillWaitingMsg, SpfyTaskToProcess."Waiting Reason");
            exit;
        end;

        if IsBatchKind(SpfyTaskToProcess."Table No.") then begin
            CopyToWorkList(SpfyTaskToProcess, TempSpfyTaskBatch);
            DispatchBatchGroupWithSweep(TempSpfyTaskBatch);
        end else
            DispatchSingle(SpfyTaskToProcess);
    end;

    internal procedure ProcessingIsAllowed(): Boolean
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        SpfyIntegrationSetup.GetRecordOnce(false);
        exit(SpfyIntegrationSetup."Task List Migration Status" = SpfyIntegrationSetup."Task List Migration Status"::Completed);
    end;

    local procedure RecoverNcResiduals(Deadline: DateTime)
    var
        NcTask: Record "NPR Nc Task";
        SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        ShopifyTaskProcessorCode: Code[20];
        ResidualCount: Integer;
    begin
        ShopifyTaskProcessorCode := SpfyScheduleSendTasks.GetShopifyTaskProcessorCode(false);
        if ShopifyTaskProcessorCode = '' then
            exit;

        SpfyTaskListMigration.FilterUnprocessedLegacyRows(NcTask);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        NcTask.SetLoadFields("Entry No.");
        if not NcTask.FindSet() then
            exit;
        repeat
            SpfyTaskListMigration.RecreateLegacyRowInNewQueue(NcTask);
            ResidualCount += 1;
        until (NcTask.Next() = 0) or (CurrentDateTime() > Deadline);
        AlertOnNcResiduals(ResidualCount);
    end;

    local procedure AlertOnNcResiduals(ResidualCount: Integer)
    var
        Sentry: Codeunit "NPR Sentry";
        ResidualAlertLbl: Label 'The Shopify task list processor found %1 actionable NaviConnect task(s) after the migration completed and re-created them in the Shopify task list. Something is still writing to the NaviConnect queue for Shopify. This is a programming bug.', Locked = true;
    begin
        Sentry.InitScopeAndTransaction('Shopify task list migration residual', 'bc.spfy.task_list.migration_residual');
        Sentry.AddError(StrSubstNo(ResidualAlertLbl, ResidualCount));
        Sentry.FinalizeScope();
    end;

    local procedure RecoverStaleClaims(StoreCode: Code[20]; AtDateTime: DateTime; Deadline: DateTime)
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskToRecover: Record "NPR Spfy Task";
    begin
        SpfyTask.SetCurrentKey("Store Code", State, "Not Before Date-Time");
        SpfyTask.SetRange("Store Code", StoreCode);
        SpfyTask.SetRange(State, SpfyTask.State::"In Flight");
        SpfyTask.SetLoadFields("Entry No.");
        if not SpfyTask.FindSet() then
            exit;
        repeat
            Clear(SpfyTaskToRecover);
            SpfyTaskToRecover."Entry No." := SpfyTask."Entry No.";
            _SpfyTaskQueue.ReclaimDeadClaim(SpfyTaskToRecover, AtDateTime);
        until (SpfyTask.Next() = 0) or (CurrentDateTime() > Deadline);
    end;

    local procedure ReevaluateWaitingTasks(StoreCode: Code[20]; AtDateTime: DateTime; Deadline: DateTime)
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskToUpdate: Record "NPR Spfy Task";
        AgedQuarantineCounts: Dictionary of [Text, Integer];
        AgedQuarantineSamples: Dictionary of [Text, BigInteger];
    begin
        SpfyTask.SetCurrentKey("Store Code", State, "Not Before Date-Time");
        SpfyTask.SetRange("Store Code", StoreCode);
        SpfyTask.SetRange(State, SpfyTask.State::Waiting);
        SpfyTask.SetLoadFields("Entry No.");
        if not SpfyTask.FindSet() then
            exit;
        repeat
            if CurrentDateTime() > Deadline then begin
                Commit();
                AlertOnAgedQuarantines(StoreCode, AgedQuarantineCounts, AgedQuarantineSamples);
                exit;
            end;
            if SpfyTaskToUpdate.Get(SpfyTask."Entry No.") then
                ReevaluateWaitingTask(SpfyTaskToUpdate, AtDateTime, AgedQuarantineCounts, AgedQuarantineSamples);
        until SpfyTask.Next() = 0;
        Commit();
        AlertOnAgedQuarantines(StoreCode, AgedQuarantineCounts, AgedQuarantineSamples);
    end;

    local procedure ReevaluateWaitingTask(var SpfyTask: Record "NPR Spfy Task"; AtDateTime: DateTime; var AgedQuarantineCounts: Dictionary of [Text, Integer]; var AgedQuarantineSamples: Dictionary of [Text, BigInteger])
    var
        SourceRecRef: RecordRef;
        AgeIsUp: Boolean;
        LookupErrorText: Text;
        StableReason: Text;
        WaitingReasonTxt: Text;
    begin
        AgeIsUp := (SpfyTask."Waiting Since" <> 0DT) and ((AtDateTime - SpfyTask."Waiting Since") >= AgingThresholdMs());
        if SourceHasVanished(SpfyTask, SourceRecRef) then begin
            _SpfyTaskQueue.CompleteNoLongerApplicable(SpfyTask, _SourceGoneLbl);
            exit;
        end;
        // Still a one-shot: a task that reaches the threshold unmet leaves Waiting at once, so it cannot re-query.
        if PreconditionIsMet(SpfyTask, AgeIsUp, false, SourceRecRef, WaitingReasonTxt, LookupErrorText) then begin
            _SpfyTaskQueue.ReleaseWaiting(SpfyTask);
            exit;
        end;
        if (WaitingReasonTxt <> '') and (WaitingReasonTxt <> SpfyTask."Waiting Reason") then
            _SpfyTaskQueue.UpdateWaitingReason(SpfyTask, WaitingReasonTxt);
        if AgeIsUp then begin
            // The stable blocker label stays the reason; a failed one-shot re-check goes into the response text.
            StableReason := WaitingReasonTxt;
            if StableReason = '' then
                StableReason := SpfyTask."Waiting Reason";
            if _SpfyTaskQueue.QuarantineAgedWaiting(SpfyTask, StableReason, LookupErrorText, AgingThresholdHours()) then
                RecordAgedQuarantine(SpfyTask, StableReason, AgedQuarantineCounts, AgedQuarantineSamples);
        end;
    end;

    local procedure RecordAgedQuarantine(var SpfyTask: Record "NPR Spfy Task"; EffectiveReason: Text; var AgedQuarantineCounts: Dictionary of [Text, Integer]; var AgedQuarantineSamples: Dictionary of [Text, BigInteger])
    var
        GroupCount: Integer;
    begin
        if AgedQuarantineCounts.Get(EffectiveReason, GroupCount) then
            AgedQuarantineCounts.Set(EffectiveReason, GroupCount + 1)
        else begin
            AgedQuarantineCounts.Add(EffectiveReason, 1);
            AgedQuarantineSamples.Add(EffectiveReason, SpfyTask."Entry No.");
        end;
    end;

    local procedure AlertOnAgedQuarantines(StoreCode: Code[20]; var AgedQuarantineCounts: Dictionary of [Text, Integer]; var AgedQuarantineSamples: Dictionary of [Text, BigInteger])
    var
        Sentry: Codeunit "NPR Sentry";
        EffectiveReason: Text;
        AggregatedAgedLbl: Label '%1 Shopify task(s) of store %2 were quarantined after waiting %3 hours or more (engine downtime not counted) for a related update to reach Shopify first and will not be sent without manual action. Reason: %4. Sample task %5.', Locked = true;
    begin
        // One event per store cycle, one error line per reason: a broken store must not emit thousands of alerts.
        if AgedQuarantineCounts.Count() = 0 then
            exit;
        Sentry.InitScopeAndTransaction('Shopify task aged waiting', 'bc.spfy.task_list.aged_waiting');
        foreach EffectiveReason in AgedQuarantineCounts.Keys() do
            Sentry.AddError(
                StrSubstNo(
                    AggregatedAgedLbl, AgedQuarantineCounts.Get(EffectiveReason), StoreCode, AgingThresholdHours(),
                    EffectiveReason, AgedQuarantineSamples.Get(EffectiveReason)));
        Sentry.FinalizeScope();
    end;

    local procedure ProcessReadyTasks(StoreCode: Code[20]; AtDateTime: DateTime; Deadline: DateTime; var TempSpfyTaskBatch: Record "NPR Spfy Task" temporary)
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskToProcess: Record "NPR Spfy Task";
    begin
        SpfyTask.SetCurrentKey("Store Code", State, "Not Before Date-Time");
        SpfyTask.SetRange("Store Code", StoreCode);
        SpfyTask.SetRange(State, SpfyTask.State::Pending);
        SpfyTask.SetFilter("Not Before Date-Time", '%1|..%2', 0DT, AtDateTime);
        if not SpfyTask.FindSet() then
            exit;
        repeat
            if CurrentDateTime() > Deadline then
                exit;
            SpfyTaskToProcess := SpfyTask;
            if EvaluateAndClaimOrDefer(SpfyTaskToProcess, AtDateTime) then
                if IsBatchKind(SpfyTaskToProcess."Table No.") then
                    CopyToWorkList(SpfyTaskToProcess, TempSpfyTaskBatch)
                else
                    DispatchSingle(SpfyTaskToProcess);
        until SpfyTask.Next() = 0;
    end;

    local procedure EvaluateAndClaimOrDefer(var SpfyTask: Record "NPR Spfy Task"; AtDateTime: DateTime): Boolean
    var
        SourceRecRef: RecordRef;
        LookupErrorText: Text;
        WaitingReasonTxt: Text;
    begin
        if not IntegrationIsEnabledForStore(SpfyTask."Store Code") then
            exit(false);
        if SourceHasVanished(SpfyTask, SourceRecRef) then begin
            _SpfyTaskQueue.CompleteNoLongerApplicable(SpfyTask, _SourceGoneLbl);
            exit(false);
        end;
        if not PreconditionIsMet(SpfyTask, true, true, SourceRecRef, WaitingReasonTxt, LookupErrorText) then begin
            case SpfyTask.State of
                SpfyTask.State::Pending:
                    _SpfyTaskQueue.SetWaiting(SpfyTask, WaitingReasonTxt, AtDateTime, LookupErrorText);
                SpfyTask.State::Waiting:
                    _SpfyTaskQueue.RefreshWaiting(SpfyTask, WaitingReasonTxt, LookupErrorText);
            end;
            exit(false);
        end;
        if SpfyTask.State = SpfyTask.State::Waiting then
            _SpfyTaskQueue.ReleaseWaiting(SpfyTask);
        if IsBatchKind(SpfyTask."Table No.") then
            exit(true);
        exit(_SpfyTaskQueue.ClaimSingle(SpfyTask));
    end;

    local procedure DispatchSingle(var SpfyTask: Record "NPR Spfy Task")
    var
        ErrorText: Text;
    begin
        if SendBoundary().Dispatch(SpfyTask, ErrorText) then
            _SpfyTaskQueue.CompleteSingle(SpfyTask, true, '')
        else
            _SpfyTaskQueue.CompleteSingle(SpfyTask, false, ErrorText);
    end;

    local procedure DispatchBatchGroups(var TempSpfyTaskBatch: Record "NPR Spfy Task" temporary; Deadline: DateTime)
    begin
        TempSpfyTaskBatch.Reset();
        if not TempSpfyTaskBatch.FindSet() then
            exit;
        repeat
            TempSpfyTaskBatch.SetRange("Table No.", TempSpfyTaskBatch."Table No.");
            TempSpfyTaskBatch.SetRange("Store Code", TempSpfyTaskBatch."Store Code");
            DispatchBatchGroupWithSweep(TempSpfyTaskBatch);
            TempSpfyTaskBatch.DeleteAll();
            TempSpfyTaskBatch.SetRange("Table No.");
            TempSpfyTaskBatch.SetRange("Store Code");
            if CurrentDateTime() > Deadline then
                exit;
        until not TempSpfyTaskBatch.FindSet();
    end;

    local procedure DispatchBatchGroupWithSweep(var TempSpfyTaskGroup: Record "NPR Spfy Task" temporary)
    var
        ClaimFloor: DateTime;
        ErrorText: Text;
        DispatchFailedLbl: Label 'The task could not be sent to Shopify. See the Shopify task list for the response of the other tasks sent in the same request.';
    begin
        ClaimFloor := _SpfyTaskRunContext.CycleTime();
        if ClaimFloor = 0DT then
            ClaimFloor := CurrentDateTime();

        // A batch dispatch runs through Codeunit.Run, which raises at the call site if the ambient transaction has pending writes.
        Commit();
        // The send codeunit charges the row whose preparation aborted, so a successful dispatch leaves nothing to sweep.
        if SendBoundary().Dispatch(TempSpfyTaskGroup, ErrorText) then
            exit;
        if ErrorText = '' then
            ErrorText := DispatchFailedLbl;
        SweepUnfinishedClaims(TempSpfyTaskGroup, ClaimFloor, ErrorText);
    end;

    local procedure SweepUnfinishedClaims(var TempSpfyTaskGroup: Record "NPR Spfy Task" temporary; ClaimFloor: DateTime; ErrorText: Text)
    var
        CompletedSpfyTask: Record "NPR Spfy Task";
        SpfyTask: Record "NPR Spfy Task";
        ResponseJson: JsonToken;
    begin
        if not TempSpfyTaskGroup.FindFirst() then
            exit;
        SpfyTask.SetCurrentKey("Store Code", State, "Not Before Date-Time");
        SpfyTask.SetRange("Store Code", TempSpfyTaskGroup."Store Code");
        SpfyTask.SetRange(State, SpfyTask.State::"In Flight");
        SpfyTask.SetRange("Claimed By Server Instance", ServiceInstanceId());
        SpfyTask.SetRange("Claimed By Session", SessionId());
        SpfyTask.SetFilter("Claimed At", '>=%1', ClaimFloor);
        SpfyTask.SetLoadFields("Entry No.");
        if not SpfyTask.FindSet() then
            exit;
        repeat
            if _SpfyTaskQueue.CompleteFromBatch(SpfyTask."Entry No.", ResponseJson, false, ErrorText, CompletedSpfyTask) then
                Commit();
        until SpfyTask.Next() = 0;
    end;

    local procedure CopyToWorkList(var SpfyTask: Record "NPR Spfy Task"; var TempSpfyTaskBatch: Record "NPR Spfy Task" temporary)
    begin
        TempSpfyTaskBatch.Init();
        TempSpfyTaskBatch."Entry No." := SpfyTask."Entry No.";
        TempSpfyTaskBatch.Type := SpfyTask.Type;
        TempSpfyTaskBatch."Table No." := SpfyTask."Table No.";
        TempSpfyTaskBatch."Record ID" := SpfyTask."Record ID";
        TempSpfyTaskBatch."Record Value" := SpfyTask."Record Value";
        TempSpfyTaskBatch."Store Code" := SpfyTask."Store Code";
        TempSpfyTaskBatch."Not Before Date-Time" := SpfyTask."Not Before Date-Time";
        TempSpfyTaskBatch."Log Date" := SpfyTask."Log Date";
        TempSpfyTaskBatch.Attempts := SpfyTask.Attempts;
        TempSpfyTaskBatch."Dispatch Id" := SpfyTask."Dispatch Id";
        TempSpfyTaskBatch.Insert();
    end;

    local procedure SourceHasVanished(var SpfyTask: Record "NPR Spfy Task"; var SourceRecRef: RecordRef): Boolean
    var
        InventoryBuffer: Record "Inventory Buffer";
        Item: Record Item;
        RecRef: RecordRef;
    begin
        Clear(SourceRecRef);
        if SpfyTask.Type = SpfyTask.Type::Delete then
            exit(false);
        case SpfyTask."Table No." of
            // The cost carrier is a synthetic RecordId over a buffer row that is never persisted; only its Item No. is real.
            Database::"Inventory Buffer":
                begin
                    RecRef := SpfyTask."Record ID".GetRecord();
                    RecRef.SetTable(InventoryBuffer);
                    exit(not Item.Get(InventoryBuffer."Item No."));
                end;
            Database::Item,
            Database::"Item Variant",
            Database::"NPR Spfy Tag Update Request",
            Database::"NPR Spfy Inventory Level",
            Database::"NPR Spfy Item Price",
            Database::"NPR Spfy Inv Item Location":
                begin
                    if not RecRef.Get(SpfyTask."Record ID") then
                        exit(true);
                    SourceRecRef := RecRef;
                    exit(false);
                end;
        end;
        exit(false);
    end;

    local procedure PreconditionIsMet(var SpfyTask: Record "NPR Spfy Task"; AllowLiveLookup: Boolean; EnqueueActivation: Boolean; var SourceRecRef: RecordRef; var WaitingReasonTxt: Text; var LookupErrorText: Text): Boolean
    begin
        WaitingReasonTxt := '';
        LookupErrorText := '';
        if SpfyTask.Type = SpfyTask.Type::Delete then
            exit(true);
        case SpfyTask."Table No." of
            Database::"Item Variant",
            Database::"Inventory Buffer",
            Database::"NPR Spfy Tag Update Request":
                begin
                    WaitingReasonTxt := _WaitingForParentLbl;
                    exit(ParentProductExistsInShopify(SpfyTask, AllowLiveLookup, LookupErrorText));
                end;
            Database::"NPR Spfy Inventory Level":
                exit(InventoryLevelPreconditionIsMet(AllowLiveLookup, EnqueueActivation, SourceRecRef, WaitingReasonTxt, LookupErrorText));
            Database::"NPR Spfy Inv Item Location":
                exit(InvItemLocationPreconditionIsMet(AllowLiveLookup, SourceRecRef, WaitingReasonTxt, LookupErrorText));
            Database::"NPR Spfy Item Price":
                exit(ItemPricePreconditionIsMet(AllowLiveLookup, SourceRecRef, WaitingReasonTxt, LookupErrorText));
        end;
        exit(true);
    end;

    local procedure ParentProductExistsInShopify(var SpfyTask: Record "NPR Spfy Task"; AllowLiveLookup: Boolean; var LookupErrorText: Text): Boolean
    var
        SpfyItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifyProductID: Text[30];
    begin
        if not ParentStoreItemLink(SpfyTask, SpfyStoreItemLink) then
            exit(false);
        if _SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '' then
            exit(true);
        if not AllowLiveLookup then
            exit(false);
        // A disabled or missing item link must not cost a Shopify call: dispatch, and the send fails it fast with its own reason.
        if not _SpfySendItemsInv.GetStoreItemLink(SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Shopify Store Code", false, SpfyItemLink) then
            exit(true);
        ClearLastError();
        if not TryFindParentProductInShopify(SpfyStoreItemLink, ShopifyProductID) then begin
            LookupErrorText := GetLastErrorText();
            if LookupErrorText = '' then
                LookupErrorText := _LookupFailedNoTextLbl;
            exit(false);
        end;
        if ShopifyProductID = '' then
            exit(false);
        // The lookup stays a pure read inside the try scope; the assignment is persisted here, where a failure rolls back.
        _SpfySendItemsInv.AssignShopifyProductID(SpfyStoreItemLink, ShopifyProductID);
        exit(true);
    end;

    [TryFunction]
    local procedure TryFindParentProductInShopify(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var ShopifyProductID: Text[30])
    begin
        if not _SpfySendItemsInv.TryFindShopifyProductID(SpfyStoreItemLink, ShopifyProductID) then
            ShopifyProductID := '';
    end;

    local procedure InventoryLevelPreconditionIsMet(AllowLiveLookup: Boolean; EnqueueActivation: Boolean; var SourceRecRef: RecordRef; var WaitingReasonTxt: Text; var LookupErrorText: Text): Boolean
    var
        InventoryLevel: Record "NPR Spfy Inventory Level";
        LocationInvItem: Record "NPR Spfy Inv Item Location";
        SpfyInvLocationAct: Codeunit "NPR Spfy Inv. Location Act.";
    begin
        // The caller always runs SourceHasVanished first, which either exits or leaves the ref set.
        SourceRecRef.SetTable(InventoryLevel);
        if not InventoryItemExistsInShopify(InventoryLevel."Item No.", InventoryLevel."Variant Code", InventoryLevel."Shopify Store Code", AllowLiveLookup, LookupErrorText) then begin
            WaitingReasonTxt := _WaitingForInventoryItemLbl;
            exit(false);
        end;
        if SpfyInvLocationAct.FindLocationRecord(LocationInvItem, InventoryLevel) then
            if LocationInvItem."Auto-Activation Disabled" or LocationInvItem.Activated then
                exit(true);
        // Only the dispatch-side evaluation may queue the activation: re-evaluation runs every minute, and its aged one-shot quarantines the level in the same pass, so a task queued there would be an orphan.
        if EnqueueActivation then
            SpfyInvLocationAct.CreateNcTaskActivateInvLocation(InventoryLevel, false);
        WaitingReasonTxt := _WaitingForLocationActivationLbl;
        exit(false);
    end;

    local procedure InvItemLocationPreconditionIsMet(AllowLiveLookup: Boolean; var SourceRecRef: RecordRef; var WaitingReasonTxt: Text; var LookupErrorText: Text): Boolean
    var
        LocationInvItem: Record "NPR Spfy Inv Item Location";
    begin
        // The caller always runs SourceHasVanished first, which either exits or leaves the ref set.
        SourceRecRef.SetTable(LocationInvItem);
        if InventoryItemExistsInShopify(LocationInvItem."Item No.", LocationInvItem."Variant Code", LocationInvItem."Shopify Store Code", AllowLiveLookup, LookupErrorText) then
            exit(true);
        WaitingReasonTxt := _WaitingForInventoryItemLbl;
        exit(false);
    end;

    local procedure ItemPricePreconditionIsMet(AllowLiveLookup: Boolean; var SourceRecRef: RecordRef; var WaitingReasonTxt: Text; var LookupErrorText: Text): Boolean
    var
        ItemPrice: Record "NPR Spfy Item Price";
    begin
        // The caller always runs SourceHasVanished first, which either exits or leaves the ref set.
        SourceRecRef.SetTable(ItemPrice);
        if VariantExistsInShopify(ItemPrice."Item No.", ItemPrice."Variant Code", ItemPrice."Shopify Store Code", AllowLiveLookup, LookupErrorText) then
            exit(true);
        WaitingReasonTxt := _WaitingForVariantLbl;
        exit(false);
    end;

    local procedure VariantExistsInShopify(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]; AllowLiveLookup: Boolean; var LookupErrorText: Text): Boolean
    var
        SpfyItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifyVariantID: Text[30];
    begin
        SetVariantLink(SpfyStoreItemLink, ItemNo, VariantCode, StoreCode);
        if _SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID") <> '' then
            exit(true);
        if not AllowLiveLookup then
            exit(false);
        // A disabled or missing item link must not cost a Shopify call: dispatch, and the send fails it fast with its own reason.
        if not _SpfySendItemsInv.GetStoreItemLink(ItemNo, StoreCode, false, SpfyItemLink) then
            exit(true);
        ClearLastError();
        if not TryFindVariantInShopify(SpfyStoreItemLink, ShopifyVariantID) then begin
            LookupErrorText := GetLastErrorText();
            if LookupErrorText = '' then
                LookupErrorText := _LookupFailedNoTextLbl;
            exit(false);
        end;
        if ShopifyVariantID = '' then
            exit(false);
        // The lookup stays a pure read inside the try scope; the assignment is persisted here, where a failure rolls back.
        _SpfySendItemsInv.AssignShopifyVariantID(SpfyStoreItemLink, ShopifyVariantID);
        exit(true);
    end;

    [TryFunction]
    local procedure TryFindVariantInShopify(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var ShopifyVariantID: Text[30])
    begin
        if not _SpfySendItemsInv.TryFindShopifyVariantID(SpfyStoreItemLink, ShopifyVariantID) then
            ShopifyVariantID := '';
    end;

    local procedure InventoryItemExistsInShopify(ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20]; AllowLiveLookup: Boolean; var LookupErrorText: Text): Boolean
    var
        SpfyItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifyInventoryItemID: Text[30];
    begin
        SetVariantLink(SpfyStoreItemLink, ItemNo, VariantCode, StoreCode);
        if _SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Inventory Item ID") <> '' then
            exit(true);
        if not AllowLiveLookup then
            exit(false);
        // A disabled or missing item link must not cost a Shopify call: dispatch, and the send fails it fast with its own reason.
        if not _SpfySendItemsInv.GetStoreItemLink(ItemNo, StoreCode, false, SpfyItemLink) then
            exit(true);
        ClearLastError();
        if not TryFindInventoryItemInShopify(SpfyStoreItemLink, ShopifyInventoryItemID) then begin
            LookupErrorText := GetLastErrorText();
            if LookupErrorText = '' then
                LookupErrorText := _LookupFailedNoTextLbl;
            exit(false);
        end;
        if ShopifyInventoryItemID = '' then
            exit(false);
        // The lookup stays a pure read inside the try scope; the assignment is persisted here, where a failure rolls back.
        _SpfySendItemsInv.AssignShopifyInventoryItemID(SpfyStoreItemLink, ShopifyInventoryItemID);
        exit(true);
    end;

    local procedure SetVariantLink(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; ItemNo: Code[20]; VariantCode: Code[10]; StoreCode: Code[20])
    begin
        Clear(SpfyStoreItemLink);
        SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Variant;
        SpfyStoreItemLink."Item No." := ItemNo;
        SpfyStoreItemLink."Variant Code" := VariantCode;
        SpfyStoreItemLink."Shopify Store Code" := StoreCode;
    end;

    [TryFunction]
    local procedure TryFindInventoryItemInShopify(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"; var ShopifyInventoryItemID: Text[30])
    begin
        if not _SpfySendItemsInv.TryFindShopifyInventoryItemID(SpfyStoreItemLink, ShopifyInventoryItemID) then
            ShopifyInventoryItemID := '';
    end;

    local procedure ParentStoreItemLink(var SpfyTask: Record "NPR Spfy Task"; var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Boolean
    var
        InventoryBuffer: Record "Inventory Buffer";
        ItemVariant: Record "Item Variant";
        RecRef: RecordRef;
    begin
        Clear(SpfyStoreItemLink);
        RecRef := SpfyTask."Record ID".GetRecord();
        case SpfyTask."Table No." of
            // The cost carrier is a synthetic RecordId over a buffer row that is never persisted; only its Item No. is real.
            Database::"Inventory Buffer":
                begin
                    RecRef.SetTable(InventoryBuffer);
                    SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
                    SpfyStoreItemLink."Item No." := InventoryBuffer."Item No.";
                    SpfyStoreItemLink."Shopify Store Code" := SpfyTask."Store Code";
                end;
            Database::"Item Variant":
                begin
                    RecRef.SetTable(ItemVariant);
                    SpfyStoreItemLink.Type := SpfyStoreItemLink.Type::Item;
                    SpfyStoreItemLink."Item No." := ItemVariant."Item No.";
                    SpfyStoreItemLink."Shopify Store Code" := SpfyTask."Store Code";
                end;
            Database::"NPR Spfy Tag Update Request":
                RecRef.SetTable(SpfyStoreItemLink);
        end;
        exit((SpfyStoreItemLink."Item No." <> '') and (SpfyStoreItemLink."Shopify Store Code" <> ''));
    end;

    local procedure IntegrationIsEnabledForStore(StoreCode: Code[20]): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if StoreCode = '' then
            exit(false);
        if not ShopifyStore.Get(StoreCode) then
            exit(false);
        exit(_SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::" ", ShopifyStore));
    end;

    local procedure IsBatchKind(TableNo: Integer): Boolean
    begin
        exit(TableNo in [Database::"Item Variant", Database::"NPR Spfy Inventory Level", Database::"NPR Spfy Item Price"]);
    end;

    local procedure ClearRunContext()
    begin
        _SpfyTaskRunContext.ClearRunDeadline();
        _SpfyTaskRunContext.ClearCycleTime();
    end;

    local procedure RunBudgetMs(): Integer
    begin
        exit(30 * 60 * 1000);
    end;

    local procedure AgingThresholdHours(): Integer
    begin
        exit(24);
    end;

    local procedure AgingThresholdMs(): Integer
    begin
        exit(24 * 60 * 60 * 1000);
    end;

    local procedure GraceMs(): Integer
    begin
        exit(5 * 60 * 1000);
    end;

    local procedure DiscountIsDue(StoreCode: Code[20]; AtDateTime: DateTime; EffectiveGrace: Integer): Boolean
    var
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
    begin
        SpfyDataSyncPointer.SetLoadFields("Last Task List Cycle At");
        if not SpfyDataSyncPointer.Get(StoreCode) then
            exit(true);
        if SpfyDataSyncPointer."Last Task List Cycle At" = 0DT then
            exit(true);
        exit((AtDateTime - SpfyDataSyncPointer."Last Task List Cycle At") > EffectiveGrace);
    end;

    // A store scheduled slower than the fixed floor must not read its own cadence as engine downtime.
    local procedure EffectiveGraceMs(StoreCode: Code[20]): Integer
    var
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
        IntervalMinutes: Integer;
        ScheduledGrace: Integer;
    begin
        IntervalMinutes := SpfyTaskJQSetup.ScheduledIntervalMinutes(StoreCode);
        // Capped on the grace, never the interval: clamping the interval makes a slow store read its own cadence as downtime.
        if IntervalMinutes > MaxGraceMinutes() div 2 then
            IntervalMinutes := MaxGraceMinutes() div 2;
        // Two intervals: a single missed run is still normal scheduling, not an outage.
        ScheduledGrace := IntervalMinutes * 2 * 60 * 1000;
        if ScheduledGrace > GraceMs() then
            exit(ScheduledGrace);
        exit(GraceMs());
    end;

    // Two weeks; doubled and converted to milliseconds this stays well inside Integer.
    local procedure MaxGraceMinutes(): Integer
    begin
        exit(14 * 24 * 60);
    end;

    local procedure SweepAlertThreshold(): Integer
    begin
        exit(10000);
    end;

    local procedure LegacyAttemptCap(): Integer
    begin
        exit(3);
    end;
}

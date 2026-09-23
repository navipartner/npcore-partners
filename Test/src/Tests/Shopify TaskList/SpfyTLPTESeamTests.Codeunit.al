codeunit 85401 "NPR Spfy TL PTE Seam Tests"
{
    // [FEATURE] Shopify Task List - the public dispatch-override seam: a customer extension replaces or augments a send, defines its own task kinds, opts them into batching, and drives them through the public write facade
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _Sub: Codeunit "NPR Spfy TL PTE Dispatch Sub";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        _SpfyIntegrationPublic: Codeunit "NPR Spfy Integration Public";
        _SubscriberResponseLbl: Label 'Sent by the subscriber extension', Locked = true;
        _SubscriberRefusedLbl: Label 'The subscriber extension refused the send.', Locked = true;
        _ClassifierRefusedLbl: Label 'The subscriber extension could not classify the kind.', Locked = true;
        _UnfinishedClaimLbl: Label 'The task was claimed by a subscriber extension but never completed. It has been failed so the standard retry handling applies.', Locked = true;
        _HandledWithoutClaimLbl: Label 'A subscriber extension reported the task group as handled but claimed none of its tasks.', Locked = true;
        _UnmappedKindTok: Label 'no send codeunit mapped', Locked = true;
        _CancelledByExtensionLbl: Label 'Cancelled by the subscriber extension', Locked = true;

    local procedure Initialize()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        if not SpfyTask.IsEmpty() then
            SpfyTask.DeleteAll(false);
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        // The engine refuses to run below Completed, and the raw enable stamps both the feature and the migration status.
        _Lib.SetTaskListFeatureEnabled(true);
        ClearRunContext();
        // The return value is consumed on purpose: an unbind of a subscriber that is not bound is an error otherwise,
        // and a test that fails before its own unbind would leave the instance bound for every test after it.
        if UnbindSubscription(_Sub) then;
        _Sub.Reset();
    end;

    local procedure ClearRunContext()
    var
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
    begin
        SpfyTaskRunContext.ClearCycleTime();
        SpfyTaskRunContext.ClearRunDeadline();
        SpfyTaskRunContext.ClearBatchClaims();
        // No send boundary is injected anywhere in this suite: the seam lives inside the real boundary.
        SpfyTaskRunContext.ClearSendBoundary();
        SpfyTaskRunContext.ClearPTEHandled();
        SpfyTaskRunContext.ClearKindIsBatched();
    end;

    local procedure Minutes(MinuteCount: Integer): Duration
    begin
        exit(MinuteCount * 60 * 1000);
    end;

    local procedure StoreRecordId(StoreCode: Code[20]): RecordId
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        ShopifyStore.Get(StoreCode);
        exit(ShopifyStore.RecordId());
    end;

    // A metafield owned by the store row itself: the engine has no precondition for that owner, and the standard
    // sibling resolves no Shopify owner id for it, so it completes the task without ever contacting Shopify.
    local procedure EnqueueStoreOwnedMetafieldTask(StoreCode: Code[20]; AtDateTime: DateTime): BigInteger
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
    begin
        _Lib.CreateMetafield(SpfyEntityMetafield, Database::"NPR Spfy Store", StoreRecordId(StoreCode), 'extension owned value');
        RecRef.GetTable(SpfyEntityMetafield);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, SpfyEntityMetafield."BC Record ID", StoreCode, "NPR Spfy Task Op"::Modify, 0DT, 0DT,
            "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueVariantTask(StoreCode: Code[20]; ItemVariant: Record "Item Variant"; AtDateTime: DateTime): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ItemVariant);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, ItemVariant.RecordId(), SpfyItemMgt.GetProductVariantSku(ItemVariant."Item No.", ItemVariant.Code),
            "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure CreateSyncedItemWithVariants(StoreCode: Code[20]; VariantCount: Integer; var Item: Record Item; var TaskEntryNos: List of [BigInteger]; AtDateTime: DateTime)
    var
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        Index: Integer;
    begin
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), CopyStr('gid://p/' + Item."No.", 1, 30));
        for Index := 1 to VariantCount do begin
            _Lib.CreateItemVariant(ItemVariant, Item."No.");
            TaskEntryNos.Add(EnqueueVariantTask(StoreCode, ItemVariant, AtDateTime));
        end;
    end;

    // A currency carries no Shopify meaning at all, so the standard boundary has no send codeunit for it:
    // exactly the shape of a task kind a customer extension defines for itself.
    local procedure CreateCurrency(): Code[10]
    var
        Currency: Record Currency;
    begin
        Currency.Init();
        Currency.Code := CopyStr(_Lib.NextCode('CR', MaxStrLen(Currency.Code)), 1, MaxStrLen(Currency.Code));
        Currency.Insert(false);
        exit(Currency.Code);
    end;

    // The dispatch and batching scenarios queue their fixture rows through the engine's own queue, so a gap in the
    // public facade cannot mask what they are about. The facade's own enqueue contract is asserted where it is the subject.
    local procedure EnqueueCurrencyTask(StoreCode: Code[20]; CurrencyCode: Code[10]; AtDateTime: DateTime): BigInteger
    var
        Currency: Record Currency;
        SpfyTask: Record "NPR Spfy Task";
        RecRef: RecordRef;
    begin
        Currency.Get(CurrencyCode);
        RecRef.GetTable(Currency);
        _SpfyTaskQueue.Enqueue(
            StoreCode, RecRef, Currency.RecordId(), CurrencyCode, "NPR Spfy Task Op"::Modify, 0DT, 0DT,
            "NPR Spfy Reuse Delayed NC Task"::Any, AtDateTime, SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure EnqueueCurrencyTaskViaFacade(StoreCode: Code[20]; CurrencyCode: Code[10]; NotBeforeDateTime: DateTime; ReuseExistingDelayed: Boolean; var Enqueued: Boolean) SpfyTaskEntryNo: BigInteger
    var
        Currency: Record Currency;
    begin
        Currency.Get(CurrencyCode);
        Enqueued := _SpfyIntegrationPublic.EnqueueShopifyTask(
            StoreCode, Currency.RecordId(), CurrencyCode, "NPR Spfy Task Op"::Modify, NotBeforeDateTime, ReuseExistingDelayed, SpfyTaskEntryNo);
    end;

    local procedure AssertTask(EntryNo: BigInteger; ExpectedState: Enum "NPR Spfy Task State"; ExpectedAttempts: Integer; FailureMsg: Text)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        _Assert.IsTrue(SpfyTask.State = ExpectedState, StrSubstNo('%1: expected state %2 but found %3 with %4 attempt(s)', FailureMsg, ExpectedState, SpfyTask.State, SpfyTask.Attempts));
        _Assert.AreEqual(ExpectedAttempts, SpfyTask.Attempts, StrSubstNo('%1: attempts', FailureMsg));
    end;

    local procedure ResponseText(EntryNo: BigInteger): Text
    var
        SpfyTask: Record "NPR Spfy Task";
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
    begin
        SpfyTask.Get(EntryNo);
        SpfyTask.CalcFields(Response);
        if not SpfyTask.Response.HasValue() then
            exit('');
        SpfyTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(IStream, ' '));
    end;

    #region Single-task dispatch override
    [Test]
    procedure GivenSubscriberHandlesSingleTask_WhenCycleRuns_ThenCompletesWithTheSubscriberResponseAndNoSiblingSend()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A subscriber that handles a single task keeps its own response on the task and the standard sibling never sends.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        TaskEntryNo := EnqueueStoreOwnedMetafieldTask(StoreCode, AtDateTime);

        // [GIVEN] A subscriber that writes its own response onto the task and claims the dispatch.
        _Sub.SetHandleWithResponse(_SubscriberResponseLbl);
        BindSubscription(_Sub);

        // [WHEN] The cycle dispatches the task.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] The subscriber ran before the standard sibling and the engine completed the task as successful.
        _Assert.AreEqual(1, _Sub.DispatchCount(), 'The subscriber must be handed the dispatch exactly once');
        _Assert.IsFalse(_Sub.LastDispatchWasTemporary(), 'A single-record kind must reach the subscriber as the real row');
        _Assert.IsTrue(_Sub.WasDispatched(TaskEntryNo), 'The subscriber must be handed the task that was queued');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A handled single task must be completed as successful');

        // [THEN] The response the subscriber wrote survives the engine's completion, so no sibling send overwrote it.
        _Assert.AreEqual(_SubscriberResponseLbl, ResponseText(TaskEntryNo), 'The response the subscriber wrote on the task must survive engine completion');
    end;

    [Test]
    procedure GivenErroringSubscriber_WhenCyclesRun_ThenTheSubscriberErrorIsRecordedAndTheTaskQuarantinesAtCap()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An erroring subscriber has its error recorded on the task, which then retries and quarantines at the attempt cap.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        TaskEntryNo := EnqueueStoreOwnedMetafieldTask(StoreCode, AtDateTime);

        // [GIVEN] A subscriber that refuses the send by raising an error.
        _Sub.SetRaiseError(_SubscriberRefusedLbl);
        BindSubscription(_Sub);

        // [WHEN] The first cycle dispatches the task.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The task carries the subscriber's own message and stays retryable, and no sibling send took over.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A subscriber error must fail the attempt and leave the task retryable');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), _SubscriberRefusedLbl) > 0, StrSubstNo('The task must record the subscriber error but recorded: %1', ResponseText(TaskEntryNo)));

        // [WHEN] The remaining attempts are spent.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 2, 'A subscriber error must still be retryable after two attempts');
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(20));
        UnbindSubscription(_Sub);

        // [THEN] The standard retry ladder quarantines it at the cap, with the subscriber error still visible.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'A subscriber error must quarantine the task at the attempt cap');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), _SubscriberRefusedLbl) > 0, StrSubstNo('A quarantined task must keep the subscriber error visible but recorded: %1', ResponseText(TaskEntryNo)));
        _Assert.AreEqual(3, _Sub.DispatchCount(), 'The subscriber must be asked once per attempt and never bypassed');
    end;

    [Test]
    procedure GivenPassiveSubscriber_WhenCycleRuns_ThenTheStandardSiblingRunsAndOwnsTheOutcome()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A subscriber that does not claim the dispatch leaves the standard sibling to run and own the outcome.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        TaskEntryNo := EnqueueStoreOwnedMetafieldTask(StoreCode, AtDateTime);

        // [GIVEN] A subscriber that only observes and never sets Handled, the legacy additive-sender case.
        BindSubscription(_Sub);

        // [WHEN] The cycle dispatches the task.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] The subscriber was still offered the dispatch, and the standard sibling ran and owns the row.
        _Assert.AreEqual(1, _Sub.DispatchCount(), 'A passive subscriber must still be offered the dispatch');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A passive subscriber must leave the standard sibling to send the task');
        _Assert.AreEqual('', ResponseText(TaskEntryNo), 'The standard sibling owns the response of a task no subscriber handled');
    end;
    #endregion

    #region Batch-group dispatch override
    [Test]
    procedure GivenSubscriberHandlesBatchGroupPartially_WhenCycleRuns_ThenTheUnfinishedClaimIsSweptAndTheUnclaimedRowStaysPending()
    var
        Item: Record Item;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNos: List of [BigInteger];
    begin
        // [SCENARIO] A subscriber that claims part of a batch group has its unfinished claim swept, while a row it never claimed stays pending without spending an attempt.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItemWithVariants(StoreCode, 3, Item, TaskEntryNos, AtDateTime);

        // [GIVEN] A subscriber that claims two of the three rows of the group but only completes one of them.
        _Sub.SetHandleGroup(2, 1);
        BindSubscription(_Sub);

        // [WHEN] The cycle dispatches the group.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] The whole group reached the subscriber as one work list, and the facade let it claim and complete rows.
        _Assert.IsTrue(_Sub.LastDispatchWasTemporary(), 'A batch group must reach the subscriber as a temporary work list');
        _Assert.AreEqual(3, _Sub.LastGroupSize(), 'The work list must carry every row of the group');
        _Assert.AreEqual(2, _Sub.ClaimedRows(), 'The subscriber must have been able to claim two rows through the facade');
        _Assert.AreEqual(1, _Sub.CompletedRows(), 'The subscriber must have been able to complete one claim through the facade');

        // [THEN] The completed claim finishes, the unfinished claim is charged with the group error, and the unclaimed row is untouched.
        AssertTask(TaskEntryNos.Get(1), "NPR Spfy Task State"::Completed, 1, 'The claim the subscriber completed must finish as successful');
        AssertTask(TaskEntryNos.Get(2), "NPR Spfy Task State"::Pending, 1, 'A claim the subscriber never completed must be failed so the standard retry handling applies');
        _Assert.AreEqual(_UnfinishedClaimLbl, ResponseText(TaskEntryNos.Get(2)), 'The swept claim must carry the unfinished-claim diagnostic');
        AssertTask(TaskEntryNos.Get(3), "NPR Spfy Task State"::Pending, 0, 'A row the subscriber never claimed must stay pending without spending an attempt');
    end;

    [Test]
    procedure GivenSubscriberDeclaresAStandardBatchKindNotBatched_WhenCycleRuns_ThenTheHardcodedListWins()
    var
        Item: Record Item;
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNos: List of [BigInteger];
    begin
        // [SCENARIO] A subscriber cannot declare a standard batch kind unbatched: the hardcoded list wins.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CreateSyncedItemWithVariants(StoreCode, 2, Item, TaskEntryNos, AtDateTime);

        // [GIVEN] A subscriber that would answer that item variants are not a batch kind, and handles whatever it gets.
        _Sub.SetNotBatchedTable(Database::"Item Variant");
        _Sub.SetHandleGroup(2, 2);
        BindSubscription(_Sub);

        // [WHEN] The cycle dispatches the variants.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] A standard Shopify batch kind is never offered to a subscriber: the hardcoded list decides it.
        _Assert.IsFalse(_Sub.WasClassified(Database::"Item Variant"), 'A standard batch kind must not be offered to the batch-kind subscriber at all');
        _Assert.AreEqual(1, _Sub.DispatchCount(), 'Both variants must arrive as one group dispatch');
        _Assert.IsTrue(_Sub.LastDispatchWasTemporary(), 'A standard batch kind must stay batched however a subscriber answers');
        _Assert.AreEqual(2, _Sub.LastGroupSize(), 'Both variants must be grouped into the one dispatch');
        AssertTask(TaskEntryNos.Get(1), "NPR Spfy Task State"::Completed, 1, 'The first variant of the group must complete');
        AssertTask(TaskEntryNos.Get(2), "NPR Spfy Task State"::Completed, 1, 'The second variant of the group must complete');
    end;
    #endregion

    #region Task kinds the extension defines itself
    [Test]
    procedure GivenPTEDefinedKind_WhenSubscriberHandlesIt_ThenDispatchedAheadOfTheMappingAndCompleted()
    var
        StoreCode: Code[20];
        CurrencyCode: Code[10];
        TaskEntryNo: BigInteger;
        AtDateTime: DateTime;
    begin
        // [SCENARIO] A task kind an extension defined for itself is dispatched ahead of the standard mapping and completed by the subscriber.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CurrencyCode := CreateCurrency();

        // [GIVEN] A task for a table the standard boundary has no send codeunit for, enqueued through the public facade.
        TaskEntryNo := EnqueueCurrencyTask(StoreCode, CurrencyCode, AtDateTime);
        _Sub.SetHandleWithResponse(_SubscriberResponseLbl);
        BindSubscription(_Sub);

        // [WHEN] The cycle dispatches it.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] The subscriber was asked before the standard mapping was consulted, so its own kind never reads as unmapped.
        _Assert.AreEqual(1, _Sub.DispatchCount(), 'A kind the extension defines must still be dispatched to the subscriber');
        _Assert.IsTrue(_Sub.WasDispatched(TaskEntryNo), 'The subscriber must be handed its own task kind');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'A handled extension-defined kind must complete');
        _Assert.AreEqual(_SubscriberResponseLbl, ResponseText(TaskEntryNo), 'The response the subscriber wrote must survive engine completion');
    end;

    [Test]
    procedure GivenPTEDefinedKindWithNoSubscriber_WhenCyclesRun_ThenItQuarantinesVisiblyAsUnmapped()
    var
        StoreCode: Code[20];
        CurrencyCode: Code[10];
        TaskEntryNo: BigInteger;
        AtDateTime: DateTime;
    begin
        // [SCENARIO] An extension-defined kind with no subscriber quarantines visibly as unmapped rather than failing silently.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CurrencyCode := CreateCurrency();

        // [GIVEN] The same extension-defined kind with nothing subscribed to the seam.
        TaskEntryNo := EnqueueCurrencyTask(StoreCode, CurrencyCode, AtDateTime);

        // [WHEN] The attempts are spent.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'An unmapped kind must burn an attempt rather than be dropped');
        _Assert.IsTrue(StrPos(ResponseText(TaskEntryNo), _UnmappedKindTok) > 0, StrSubstNo('The task must record that no send codeunit is mapped but recorded: %1', ResponseText(TaskEntryNo)));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(20));

        // [THEN] It ends up quarantined and visible rather than silently looping.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'An unmapped kind must quarantine at the attempt cap');
    end;

    [Test]
    procedure GivenPTEBatchedKind_WhenCycleRuns_ThenTheRowsArriveAsOneGroupAndTheUnfinishedClaimIsSwept()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTaskEntryNo: BigInteger;
        SecondTaskEntryNo: BigInteger;
        ThirdTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] An extension kind opted into batching arrives as one group and its claims are settled by the same sweep the standard batch kinds use.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        FirstTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);
        SecondTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);
        ThirdTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);

        // [GIVEN] A subscriber that opts its own kind into batching and claims two of the three rows, completing one.
        _Sub.SetBatchedTable(Database::Currency);
        _Sub.SetHandleGroup(2, 1);
        BindSubscription(_Sub);

        // [WHEN] The cycle dispatches the store's pending rows of that kind.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] All three rows arrive in a single work-list dispatch, exactly as a standard batch kind would.
        _Assert.IsTrue(_Sub.WasClassified(Database::Currency), 'An unmapped kind must be offered to the batch-kind subscriber');
        _Assert.AreEqual(1, _Sub.DispatchCount(), 'A batched extension kind must be dispatched once for the whole group');
        _Assert.IsTrue(_Sub.LastDispatchWasTemporary(), 'A batched extension kind must arrive as a temporary work list');
        _Assert.AreEqual(3, _Sub.LastGroupSize(), 'Every pending row of the kind for the store must join the group');

        // [THEN] The claims are settled by the same sweep the standard batch kinds use.
        AssertTask(FirstTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'The claim the subscriber completed must finish as successful');
        AssertTask(SecondTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A claim the subscriber never completed must be swept and failed');
        _Assert.AreEqual(_UnfinishedClaimLbl, ResponseText(SecondTaskEntryNo), 'The swept claim must carry the unfinished-claim diagnostic');
        AssertTask(ThirdTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A row the subscriber never claimed must stay pending without spending an attempt');
    end;

    [Test]
    procedure GivenABatchGroupRowCarryingMigrationProvenance_WhenTheGroupIsDispatched_ThenTheWorkListCarriesTheWholeRow()
    var
        StoreCode: Code[20];
        CurrencyCode: Code[10];
        AtDateTime: DateTime;
        ProvenanceEntryNo: BigInteger;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A batch group work list carries the whole row, migration provenance included, so a subscriber sees every field the engine read.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CurrencyCode := CreateCurrency();
        ProvenanceEntryNo := 4242;
        TaskEntryNo := EnqueueCurrencyTask(StoreCode, CurrencyCode, AtDateTime);

        // [GIVEN] A task carrying a field the engine's own send codeunits never read, on a kind the subscriber batches.
        StampMigratedFrom(TaskEntryNo, ProvenanceEntryNo);
        _Sub.SetBatchedTable(Database::Currency);
        _Sub.SetHandleGroup(1, 1);
        BindSubscription(_Sub);

        // [WHEN] The cycle hands the group to the subscriber.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] The work list is a copy of the whole row, so a subscriber sees every field the engine read - standard
        // and extension alike - instead of a hand-picked subset a later field would have to be added to.
        _Assert.IsTrue(_Sub.LastDispatchWasTemporary(), 'A batched extension kind must arrive as a temporary work list');
        _Assert.AreEqual(ProvenanceEntryNo, _Sub.DispatchedMigratedFrom(1), 'The work-list copy must carry every field of the stored task row');
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'The row the subscriber claimed and completed must finish as successful');
    end;

    local procedure StampMigratedFrom(SpfyTaskEntryNo: BigInteger; NcEntryNo: BigInteger)
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(SpfyTaskEntryNo);
        SpfyTask."Migrated From NC Entry No." := NcEntryNo;
        SpfyTask.Modify(false);
    end;

    [Test]
    procedure GivenErroringBatchClassifier_WhenCycleRuns_ThenTheKindResolvesSingleAndTheCycleSurvives()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTaskEntryNo: BigInteger;
        SecondTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A batch classifier that errors leaves the kind resolving as single and the cycle still completes.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        FirstTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);
        SecondTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);

        // [GIVEN] A subscriber whose batch-kind answer raises an error, while its dispatch handler still works.
        _Sub.SetClassifyError(_ClassifierRefusedLbl);
        _Sub.SetHandleWithResponse(_SubscriberResponseLbl);
        BindSubscription(_Sub);

        // [WHEN] The cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] The failed classification does not abort the store's cycle: the kind resolves as not batched for it.
        _Assert.IsTrue(_Sub.ClassifyCount() > 0, 'The batch-kind question must have been put to the subscriber');
        _Assert.AreEqual(2, _Sub.DispatchCount(), 'Each row must be dispatched on its own once the classification failed');
        _Assert.AreEqual(1, _Sub.GroupSizeAt(1), 'A row processed single must arrive alone');
        _Assert.AreEqual(1, _Sub.GroupSizeAt(2), 'A row processed single must arrive alone');
        AssertTask(FirstTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'The first row must still be processed after a failed classification');
        AssertTask(SecondTaskEntryNo, "NPR Spfy Task State"::Completed, 1, 'The second row must still be processed after a failed classification');
    end;

    [Test]
    procedure GivenPTEBatchedKindLeftEntirelyUnclaimed_WhenCyclesRun_ThenEveryRowBurnsAnAttemptAndQuarantines()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTaskEntryNo: BigInteger;
        SecondTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A batched extension kind that no subscriber handles burns an attempt per cycle and quarantines at the cap.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        FirstTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);
        SecondTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);

        // [GIVEN] A subscriber that opts its kind into batching but never handles the dispatch nor claims a row.
        _Sub.SetBatchedTable(Database::Currency);
        BindSubscription(_Sub);

        // [WHEN] The first cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The rows really did arrive as one abandoned group, rather than being processed one by one.
        _Assert.AreEqual(1, _Sub.DispatchCount(), 'A batched extension kind must be dispatched once for the whole group');
        _Assert.IsTrue(_Sub.LastDispatchWasTemporary(), 'A batched extension kind must arrive as a temporary work list');
        _Assert.AreEqual(2, _Sub.LastGroupSize(), 'Both rows must join the one group dispatch');

        // [THEN] Every row of the abandoned group is charged an attempt, so the group can never re-dispatch in silence.
        AssertTask(FirstTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'An unclaimed row of an unhandled batch group must be charged an attempt');
        AssertTask(SecondTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'An unclaimed row of an unhandled batch group must be charged an attempt');

        // [WHEN] The remaining attempts are spent.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(20));
        UnbindSubscription(_Sub);

        // [THEN] The rows quarantine at the cap instead of looping forever.
        AssertTask(FirstTaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'An abandoned batch row must quarantine at the attempt cap');
        AssertTask(SecondTaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'An abandoned batch row must quarantine at the attempt cap');
    end;

    [Test]
    procedure GivenPTEBatchedKindHandledWithoutAnyClaim_WhenCyclesRun_ThenEveryRowBurnsAnAttemptAndQuarantines()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTaskEntryNo: BigInteger;
        SecondTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A subscriber that reports a batch group as handled but claims none of its rows is charged, so the group can never re-dispatch in silence.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        FirstTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);
        SecondTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);

        // [GIVEN] A subscriber that opts its kind into batching, reports the group as handled, and claims no row at all.
        _Sub.SetBatchedTable(Database::Currency);
        _Sub.SetHandleGroup(0, 0);
        BindSubscription(_Sub);

        // [WHEN] The first cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The group really was reported as handled, and every row still carries the diagnostic and one attempt.
        _Assert.AreEqual(1, _Sub.DispatchCount(), 'A batched extension kind must be dispatched once for the whole group');
        _Assert.AreEqual(0, _Sub.ClaimedRows(), 'The scenario requires a subscriber that claims nothing');
        AssertTask(FirstTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A row of a handled group nobody claimed must be charged an attempt');
        AssertTask(SecondTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A row of a handled group nobody claimed must be charged an attempt');
        _Assert.AreEqual(
            _HandledWithoutClaimLbl, ResponseText(FirstTaskEntryNo), 'A charged row must carry the handled-without-claim diagnostic');

        // [WHEN] The remaining attempts are spent.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(10));
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime + Minutes(20));
        UnbindSubscription(_Sub);

        // [THEN] The rows quarantine at the cap instead of looping forever.
        AssertTask(FirstTaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'A handled group nobody claimed must quarantine at the attempt cap');
        AssertTask(SecondTaskEntryNo, "NPR Spfy Task State"::Quarantined, 3, 'A handled group nobody claimed must quarantine at the attempt cap');
    end;

    [Test]
    procedure GivenSubscriberClaimsARowOutsideTheGroup_WhenItAbandonsTheGroupItWasHanded_ThenTheGroupIsStillCharged()
    var
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTaskEntryNo: BigInteger;
        SecondTaskEntryNo: BigInteger;
        ForeignTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A claim of a task outside the dispatched group does not count as having claimed that group, because the claim facade accepts any entry number.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        OtherStoreCode := _Lib.CreateStore(true, false, false, false, false);
        FirstTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);
        SecondTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);

        // [GIVEN] A task of another store, which this cycle never dispatches.
        ForeignTaskEntryNo := EnqueueCurrencyTask(OtherStoreCode, CreateCurrency(), AtDateTime);

        // [GIVEN] A subscriber that reports the group as handled, claims none of its rows, and claims that unrelated task instead.
        _Sub.SetBatchedTable(Database::Currency);
        _Sub.SetHandleGroup(0, 0);
        _Sub.SetClaimForeignEntry(ForeignTaskEntryNo);
        BindSubscription(_Sub);

        // [WHEN] The cycle dispatches the store's group.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] The unrelated claim really did succeed, so the scenario is the one it claims to be.
        _Assert.IsTrue(_Sub.ForeignClaimSucceeded(), 'The facade must accept a claim of a task outside the dispatched group, or this scenario proves nothing');

        // [THEN] The group it was handed and abandoned is still charged: an unrelated claim is not evidence about this group.
        AssertTask(FirstTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A row of a handled group nobody claimed must be charged even when the subscriber claimed something else');
        AssertTask(SecondTaskEntryNo, "NPR Spfy Task State"::Pending, 1, 'A row of a handled group nobody claimed must be charged even when the subscriber claimed something else');
    end;

    [Test]
    procedure GivenTheRunDeadlinePassesDuringDispatch_WhenTheGroupIsReportedHandledWithoutAClaim_ThenNothingIsCharged()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        FirstTaskEntryNo: BigInteger;
        SecondTaskEntryNo: BigInteger;
    begin
        // [SCENARIO] Once the run deadline has passed the engine itself refuses every claim, so a subscriber that then reports the group as handled must not be charged for it.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        FirstTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);
        SecondTaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);

        // [GIVEN] A subscriber whose kind is batched, whose claims are all refused because the run budget ran out while it worked, and which still reports the group as handled.
        _Sub.SetBatchedTable(Database::Currency);
        _Sub.SetHandleGroup(2, 2);
        _Sub.SetExpireRunDeadlineOnDispatch();
        BindSubscription(_Sub);

        // [WHEN] The cycle dispatches the group.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);
        UnbindSubscription(_Sub);

        // [THEN] Every claim really was refused by the deadline, not skipped by the subscriber.
        _Assert.AreEqual(1, _Sub.DispatchCount(), 'A batched extension kind must be dispatched once for the whole group');
        _Assert.AreEqual(0, _Sub.ClaimedRows(), 'The engine must refuse every claim once the run deadline has passed');

        // [THEN] The rows wait for the next cycle with their attempts intact: the refusal was the engine's, not the subscriber's.
        AssertTask(FirstTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A row the engine itself refused to claim must not spend an attempt');
        AssertTask(SecondTaskEntryNo, "NPR Spfy Task State"::Pending, 0, 'A row the engine itself refused to claim must not spend an attempt');
        _Assert.AreEqual('', ResponseText(FirstTaskEntryNo), 'A row nothing was charged for must carry no diagnostic');
    end;
    #endregion

    #region Public write facade
    [Test]
    procedure GivenFacadeEnqueue_WhenTheReuseFlagVaries_ThenLaterMergesWhileNoCreatesAFreshRow()
    var
        StoreCode: Code[20];
        CurrencyCode: Code[10];
        ScheduledDateTime: DateTime;
        ScheduledTaskEntryNo: BigInteger;
        MergedTaskEntryNo: BigInteger;
        FreshTaskEntryNo: BigInteger;
        Enqueued: Boolean;
    begin
        // [SCENARIO] The facade's reuse flag decides the outcome: Later merges into an existing future-scheduled task, No creates a fresh row.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CurrencyCode := CreateCurrency();
        ScheduledDateTime := CurrentDateTime() + Minutes(60);

        // [WHEN] An extension enqueues a future-scheduled task for a kind of its own through the facade.
        ScheduledTaskEntryNo := EnqueueCurrencyTaskViaFacade(StoreCode, CurrencyCode, ScheduledDateTime, false, Enqueued);

        // [THEN] The facade reports success and hands back the entry number of the task it created.
        _Assert.IsTrue(Enqueued, 'The facade must report success when it creates a task');
        _Assert.AreNotEqual(0, ScheduledTaskEntryNo, 'The facade must hand back the entry number of the task it created');

        // [WHEN] The same record is enqueued again asking to reuse an existing delayed task.
        MergedTaskEntryNo := EnqueueCurrencyTaskViaFacade(StoreCode, CurrencyCode, 0DT, true, Enqueued);

        // [THEN] The request merges into the future-scheduled task, and the facade still reports success.
        _Assert.IsTrue(Enqueued, 'The facade must report success when a task it reused already covers the request');
        _Assert.AreEqual(ScheduledTaskEntryNo, MergedTaskEntryNo, 'A reuse request must merge into the existing future-scheduled task');

        // [WHEN] The same record is enqueued again refusing to reuse a delayed task.
        FreshTaskEntryNo := EnqueueCurrencyTaskViaFacade(StoreCode, CurrencyCode, 0DT, false, Enqueued);

        // [THEN] A fresh row is created instead, so the caller's own schedule is never silently absorbed.
        _Assert.IsTrue(Enqueued, 'The facade must report success when it creates a fresh task');
        _Assert.AreNotEqual(ScheduledTaskEntryNo, FreshTaskEntryNo, 'A no-reuse request must not merge into the future-scheduled task');
        _Assert.AreNotEqual(0, FreshTaskEntryNo, 'A no-reuse request must create a task of its own');
    end;

    [Test]
    procedure GivenTheTaskListIsNotTheActiveQueue_WhenAnExtensionEnqueuesThroughTheFacade_ThenRefusedAndNothingIsQueued()
    var
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        CurrencyCode: Code[10];
        TaskEntryNo: BigInteger;
        Enqueued: Boolean;
    begin
        // [SCENARIO] The facade refuses to enqueue while the task list is not the active send queue, and leaves no row behind.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CurrencyCode := CreateCurrency();

        // [GIVEN] An environment that still sends through NaviConnect, where nothing drains the new queue.
        _Lib.SetTaskListFeatureEnabled(false);

        // [WHEN] An extension enqueues a task of its own through the facade.
        TaskEntryNo := EnqueueCurrencyTaskViaFacade(StoreCode, CurrencyCode, 0DT, false, Enqueued);

        // [THEN] It is refused rather than stranding a row no processor will ever pick up.
        _Assert.IsFalse(Enqueued, 'The facade must refuse to enqueue while the task list is not the active send queue');
        _Assert.IsTrue(TaskEntryNo = 0, StrSubstNo('A refused enqueue must not hand back an entry number but returned %1', TaskEntryNo));
        _Assert.IsTrue(SpfyTask.IsEmpty(), 'A refused enqueue must leave no task row behind');
    end;

    [Test]
    procedure GivenFacadeCancel_WhenTheTaskIsStillUnsent_ThenCompletedWithTheReasonAndASecondCancelIsRefused()
    var
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] The facade cancels an unsent task with the reason the extension gave, and refuses a second cancel of the same task.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        TaskEntryNo := EnqueueCurrencyTask(StoreCode, CreateCurrency(), AtDateTime);

        // [WHEN] The extension cancels its own unsent task.
        _Assert.IsTrue(_SpfyIntegrationPublic.CancelShopifyTask(TaskEntryNo, _CancelledByExtensionLbl), 'An unsent task must be cancellable through the facade');

        // [THEN] The task is closed carrying the reason the extension gave.
        AssertTask(TaskEntryNo, "NPR Spfy Task State"::Completed, 0, 'A cancelled task must be closed without spending an attempt');
        _Assert.AreEqual(_CancelledByExtensionLbl, ResponseText(TaskEntryNo), 'The cancelled task must record the reason the extension gave');

        // [WHEN] The same task is cancelled again. [THEN] It is refused, because it has already been closed.
        _Assert.IsFalse(_SpfyIntegrationPublic.CancelShopifyTask(TaskEntryNo, _CancelledByExtensionLbl), 'A task that has already been closed must not be cancellable again');
    end;

    [Test]
    procedure GivenFacadeEnqueueWithABlankRecordId_WhenTheExtensionEnqueues_ThenRefusedWithoutAnError()
    var
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        BlankRecordId: RecordId;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] A blank source RecordId is refused like every other precondition of the facade, rather than raising out of a boolean API.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [WHEN] An extension enqueues with a RecordId it never assigned.
        // [THEN] The facade answers false instead of raising, and hands back no entry number.
        _Assert.IsFalse(
            _SpfyIntegrationPublic.EnqueueShopifyTask(
                StoreCode, BlankRecordId, 'BLANK', "NPR Spfy Task Op"::Modify, 0DT, false, TaskEntryNo),
            'A blank source RecordId must be refused rather than raise out of the facade');
        _Assert.IsTrue(TaskEntryNo = 0, StrSubstNo('A refused enqueue must not hand back an entry number but returned %1', TaskEntryNo));
        _Assert.IsTrue(SpfyTask.IsEmpty(), 'A refused enqueue must leave no task row behind');
    end;
    #endregion
}

codeunit 85277 "NPR Spfy RowVer Deletion Tests"
{
    // [FEATURE] Shopify RowVersion change detection - delete-intent outbox: state-machine contract, retention, capture/cancel/drain lifecycle (real DB)
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";

    local procedure Initialize()
    begin
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetFeatureEnabled(true);
    end;

    local procedure InsertPending(ShopifyId: Text[30]): BigInteger
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        DeletionLog.Init();
        DeletionLog."Table No." := Database::"NPR Spfy Store-Item Link";
        DeletionLog."Entity System Id" := CreateGuid();
        DeletionLog."Shopify Store Code" := 'S';
        DeletionLog."Shopify ID Type" := "NPR Spfy ID Type"::"Entry ID";
        DeletionLog."Shopify ID" := ShopifyId;
        DeletionLog.Status := DeletionLog.Status::Pending;
        DeletionLog.Insert(true);
        exit(DeletionLog."Entry No.");
    end;

    local procedure InsertNcTask(Processed: Boolean): BigInteger
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.Init();
        NcTask.Type := NcTask.Type::Delete;
        NcTask.Processed := Processed;
        NcTask.Insert(true);
        exit(NcTask."Entry No.");
    end;

    local procedure SetStatus(EntryNo: BigInteger; NewStatus: Integer)
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        DeletionLog.Get(EntryNo);
        DeletionLog.Status := NewStatus;
        DeletionLog.Modify(false);
    end;

    #region Outbox Contract
    [Test]
    procedure LogDelete_DedupsAndSkipsBlankId()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        RecId: RecordId;
    begin
        // [SCENARIO] Logging the same delete intent twice leaves one Pending row, and logging one without a Shopify id records nothing.
        Initialize();
        // [WHEN] The same (table, id type, id, store) delete is logged twice. [THEN] only one Pending row.
        SpfyDeletionLogMgt.LogDelete(Database::"NPR Spfy Store-Item Link", 'ITM', '', '', RecId, CreateGuid(), 'S', "NPR Spfy ID Type"::"Entry ID", 'gid://1');
        SpfyDeletionLogMgt.LogDelete(Database::"NPR Spfy Store-Item Link", 'ITM', '', '', RecId, CreateGuid(), 'S', "NPR Spfy ID Type"::"Entry ID", 'gid://1');
        _Assert.AreEqual(1, DeletionLog.Count(), 'Duplicate delete intent must dedup to one Pending row');
        // [WHEN] A blank Shopify ID is logged. [THEN] it is a no-op.
        SpfyDeletionLogMgt.LogDelete(Database::"NPR Spfy Store-Item Link", 'ITM', '', '', RecId, CreateGuid(), 'S', "NPR Spfy ID Type"::"Entry ID", '');
        _Assert.AreEqual(1, DeletionLog.Count(), 'A blank Shopify ID must not insert a row');
    end;

    [Test]
    procedure CancelDelete_PendingBecomesCancelled()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        EntryNo: BigInteger;
    begin
        // [SCENARIO] Reactivating an entity cancels the delete intent that is still pending for it.
        Initialize();
        EntryNo := InsertPending('gid://1');
        DeletionLog.Get(EntryNo);
        // [WHEN] The entity is reactivated. [THEN] the Pending delete flips to Cancelled.
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::"NPR Spfy Store-Item Link", 'S', DeletionLog."Entity System Id");
        DeletionLog.Get(EntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'A Pending delete must be cancelled on reactivation');
    end;

    [Test]
    procedure MarkProcessed_SetsStatusAndTaskNo()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        PendingEntryNo: BigInteger;
        CancelledEntryNo: BigInteger;
        QuarantinedEntryNo: BigInteger;
    begin
        // [SCENARIO] Draining a pending delete marks it Processed and stores the task number it produced, while Cancelled and Quarantined intents are left untouched.
        Initialize();
        PendingEntryNo := InsertPending('gid://1');
        // [WHEN] The drain creates an NC delete task. [THEN] status -> Processed with the task no. stored.
        SpfyDeletionLogMgt.MarkProcessed(PendingEntryNo, 4242);
        DeletionLog.Get(PendingEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'MarkProcessed must set Processed');
        _Assert.IsTrue(DeletionLog."NC Task Entry No." = 4242, 'MarkProcessed must store the NC task entry no.');

        // [GIVEN] A Cancelled and a Quarantined row. [WHEN] MarkProcessed runs. [THEN] both are left untouched (Pending-only guard).
        CancelledEntryNo := InsertPending('gid://c');
        SetStatus(CancelledEntryNo, DeletionLog.Status::Cancelled);
        SpfyDeletionLogMgt.MarkProcessed(CancelledEntryNo, 5000);
        DeletionLog.Get(CancelledEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'MarkProcessed must not touch a Cancelled row');
        _Assert.IsTrue(DeletionLog."NC Task Entry No." = 0, 'MarkProcessed must not stamp a task no. on a Cancelled row');

        QuarantinedEntryNo := InsertPending('gid://q');
        SetStatus(QuarantinedEntryNo, DeletionLog.Status::Quarantined);
        SpfyDeletionLogMgt.MarkProcessed(QuarantinedEntryNo, 6000);
        DeletionLog.Get(QuarantinedEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Quarantined, 'MarkProcessed must not touch a Quarantined row');
    end;

    [Test]
    procedure CancelDelete_ProcessedCancelsUnsentTaskButLeavesSent()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        NcTask: Record "NPR Nc Task";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        UnsentTaskNo: BigInteger;
        SentTaskNo: BigInteger;
        UnsentEntryNo: BigInteger;
        SentEntryNo: BigInteger;
    begin
        // [SCENARIO] Reactivating an entity cancels a drained delete whose task has not been sent yet and defuses that task, but leaves an already-sent delete Processed.
        Initialize();
        // [GIVEN] A drained (Processed) delete whose NC task has NOT run yet.
        UnsentTaskNo := InsertNcTask(false);
        UnsentEntryNo := InsertPending('gid://unsent');
        SpfyDeletionLogMgt.MarkProcessed(UnsentEntryNo, UnsentTaskNo);
        // [GIVEN] A drained delete whose NC task ALREADY ran.
        SentTaskNo := InsertNcTask(true);
        SentEntryNo := InsertPending('gid://sent');
        SpfyDeletionLogMgt.MarkProcessed(SentEntryNo, SentTaskNo);

        // [WHEN] The entity is reactivated for the unsent case.
        DeletionLog.Get(UnsentEntryNo);
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::"NPR Spfy Store-Item Link", 'S', DeletionLog."Entity System Id");
        DeletionLog.Get(UnsentEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'An unsent Processed delete must be cancelled');
        NcTask.Get(UnsentTaskNo);
        _Assert.IsTrue(NcTask.Processed, 'The outstanding NC delete task must be cancelled (marked Processed)');

        // [WHEN] The entity is reactivated for the already-sent case. [THEN] it is left; poll-Insert re-creates it.
        DeletionLog.Get(SentEntryNo);
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::"NPR Spfy Store-Item Link", 'S', DeletionLog."Entity System Id");
        DeletionLog.Get(SentEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'An already-sent delete must be left Processed');
    end;

    [Test]
    procedure CancelDelete_QuarantinedBecomesCancelled()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        EntryNo: BigInteger;
    begin
        // [SCENARIO] Reactivating an entity also cancels a delete intent that had been parked in quarantine.
        Initialize();
        EntryNo := InsertPending('gid://1');
        DeletionLog.Get(EntryNo);
        DeletionLog.Status := DeletionLog.Status::Quarantined;
        DeletionLog.Modify(false);
        // [WHEN] The entity is reactivated. [THEN] a parked (Quarantined) delete is cancelled too.
        SpfyDeletionLogMgt.CancelDeleteForEntity(Database::"NPR Spfy Store-Item Link", 'S', DeletionLog."Entity System Id");
        DeletionLog.Get(EntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'A Quarantined delete must be cancellable on reactivation');
    end;

    [Test]
    procedure DrainFailure_QuarantinesAtThresholdAndClears()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDeletionLogMgt: Codeunit "NPR Spfy Deletion Log Mgt";
        QuarantineEntryNo: BigInteger;
        ClearEntryNo: BigInteger;
    begin
        // [SCENARIO] A delete intent is quarantined on its third consecutive drain failure, while a later success resets an accrued failure streak and leaves the intent Pending.
        Initialize();
        QuarantineEntryNo := InsertPending('gid://poison');
        // [WHEN] The drain dispatch fails three consecutive cycles.
        SpfyDeletionLogMgt.RecordDrainFailure(QuarantineEntryNo, 'boom', '');
        SpfyDeletionLogMgt.RecordDrainFailure(QuarantineEntryNo, 'boom', '');
        SpfyDeletionLogMgt.RecordDrainFailure(QuarantineEntryNo, 'boom', '');
        DeletionLog.Get(QuarantineEntryNo);
        _Assert.AreEqual(3, DeletionLog."Dispatch Failure Count", 'Failure count must reach the threshold');
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Quarantined, 'The delete must be quarantined on the third strike');

        // [GIVEN] A separate Pending delete with one accrued failure.
        ClearEntryNo := InsertPending('gid://transient');
        SpfyDeletionLogMgt.RecordDrainFailure(ClearEntryNo, 'boom', '');
        // [WHEN] A no-op success clears the streak (consecutive semantics).
        SpfyDeletionLogMgt.ClearDrainFailure(ClearEntryNo);
        DeletionLog.Get(ClearEntryNo);
        _Assert.AreEqual(0, DeletionLog."Dispatch Failure Count", 'ClearDrainFailure must reset the streak to 0');
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Pending, 'A cleared row stays Pending, not quarantined');
    end;
    #endregion

    #region Retention
    [Test]
    procedure Retention_PrunesTerminalKeepsPendingAndQuarantined()
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
        RetentionPolicy: Record "NPR Retention Policy";
        IRetentionPolicy: Interface "NPR IRetention Policy V2";
        ReferenceDateTime: DateTime;
    begin
        // [SCENARIO] Retention keeps every delete-log row inside the retention window and, once it has elapsed, prunes only the Processed and Cancelled rows while Pending and Quarantined survive.
        Initialize();
        RetentionPolicy.DeleteAll();
        RetentionPolicy.Init();
        RetentionPolicy."Table Id" := Database::"NPR Spfy Deletion Log";
        RetentionPolicy."Implementation V2" := RetentionPolicy."Implementation V2"::"NPR Spfy Deletion Log";
        RetentionPolicy.Insert();
        // [GIVEN] One row in each status (SystemModifiedAt = now).
        SeedStatus(DeletionLog.Status::Pending, 'gid://p');
        SeedStatus(DeletionLog.Status::Cancelled, 'gid://c');
        SeedStatus(DeletionLog.Status::Processed, 'gid://x');
        SeedStatus(DeletionLog.Status::Quarantined, 'gid://q');
        // [WHEN] Retention runs while the rows are still inside the -3M window. [THEN] nothing is pruned, any status.
        IRetentionPolicy := RetentionPolicy."Implementation V2";
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, CurrentDateTime());
        _Assert.AreEqual(4, DeletionLog.Count(), 'Rows inside the retention window must survive regardless of status');
        // [WHEN] Retention is applied far enough in the future that the default -3M window has elapsed.
        ReferenceDateTime := CreateDateTime(CalcDate('<+7M>', DT2Date(CurrentDateTime())), DT2Time(CurrentDateTime()));
        IRetentionPolicy.DeleteExpiredRecords(RetentionPolicy, ReferenceDateTime);
        // [THEN] terminal Processed/Cancelled pruned; Pending and Quarantined survive.
        DeletionLog.SetRange(Status, DeletionLog.Status::Pending);
        _Assert.AreEqual(1, DeletionLog.Count(), 'Pending must never be pruned');
        DeletionLog.SetRange(Status, DeletionLog.Status::Quarantined);
        _Assert.AreEqual(1, DeletionLog.Count(), 'Quarantined must not be auto-pruned');
        DeletionLog.SetRange(Status, DeletionLog.Status::Processed);
        _Assert.AreEqual(0, DeletionLog.Count(), 'Processed must be pruned');
        DeletionLog.SetRange(Status, DeletionLog.Status::Cancelled);
        _Assert.AreEqual(0, DeletionLog.Count(), 'Cancelled must be pruned');
    end;

    local procedure SeedStatus(NewStatus: Integer; ShopifyId: Text[30])
    var
        DeletionLog: Record "NPR Spfy Deletion Log";
    begin
        DeletionLog.Init();
        DeletionLog."Table No." := Database::"NPR Spfy Store-Item Link";
        DeletionLog."Shopify Store Code" := 'S';
        DeletionLog."Shopify ID Type" := "NPR Spfy ID Type"::"Entry ID";
        DeletionLog."Shopify ID" := ShopifyId;
        DeletionLog.Status := NewStatus;
        DeletionLog.Insert(true);
    end;
    #endregion

    #region Delete Lifecycle
    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GivenSyncedLinkUnsync_ThenIntentCapturedBeforeCleanup_AndPhysicalDeleteOnlyCleansBaseline()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Unsyncing a synced item captures one pending delete intent carrying the live Shopify id and store routing key while the feature is on and nothing while it is off, and physically deleting the link afterwards only cleans its baseline.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), 'gid://prod/1');

        // [WHEN] The unsync transition happens with the feature OFF. [THEN] the capture stays dormant.
        _Lib.SetFeatureEnabled(false);
        SpfyStoreItemLink.Validate("Sync. to this Store", false);
        SpfyStoreItemLink.Modify(true);
        _Assert.AreEqual(0, _Lib.TotalDeletionRowCount(), 'Feature off: the delete capture must not fire');
        SpfyStoreItemLink.Validate("Sync. to this Store", true);
        SpfyStoreItemLink.Modify(true);

        // [WHEN] The unsync transition happens with the feature ON.
        _Lib.SetFeatureEnabled(true);
        SpfyStoreItemLink.Validate("Sync. to this Store", false);
        SpfyStoreItemLink.Modify(true);

        // [THEN] One Pending row captures the live Shopify ID + routing keys before any cleanup wipes them.
        DeletionLog.SetRange("Table No.", Database::Item);
        DeletionLog.SetRange("Item No.", Item."No.");
        _Assert.IsTrue(DeletionLog.FindFirst(), 'The unsync must capture a delete intent');
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Pending, 'The captured intent must be Pending');
        _Assert.AreEqual('gid://prod/1', DeletionLog."Shopify ID", 'The tombstone must hold the live Shopify ID');
        _Assert.AreEqual(StoreCode, DeletionLog."Shopify Store Code", 'The tombstone must carry the store routing key');

        // [WHEN] The (already unsynced) link row is physically deleted.
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(SpfyStoreItemLink);
        SpfyStoreItemLink.Delete(true);

        // [THEN] Only the Sync State baseline is GC'ed; the captured intent survives and no second capture fires.
        _Assert.IsFalse(_Lib.HasBaseline(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.SystemId, StoreCode), 'The physical delete must clean the entity baseline');
        _Assert.AreEqual(1, _Lib.TotalDeletionRowCount(), 'The physical link delete itself must not log a second intent (capture is transition-gated)');
        DeletionLog.Find();
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Pending, 'The captured intent must survive the physical delete');

        _Lib.ConsumeConfirm();   // the unsync Confirms above fire only when GuiAllowed() is true
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GivenPendingIntent_WhenIdClearedBeforeResync_ThenResyncCancelsIt()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyDeletionLog: Record "NPR Spfy Deletion Log";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Syncing an item again cancels its pending delete intent even when the Shopify id it was captured with has been cleared in the meantime.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), 'gid://prod/11');

        // [GIVEN] The item is unsynced while it still has a Shopify id: a delete intent is captured.
        SpfyStoreItemLink.Validate("Sync. to this Store", false);
        SpfyStoreItemLink.Modify(true);
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::Item, DummyDeletionLog.Status::Pending), 'Unsync with a Shopify id must capture a delete intent');

        // [GIVEN] An operator clears the Shopify id before the item is synced again.
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");

        // [WHEN] The item is synced again.
        SpfyStoreItemLink.Validate("Sync. to this Store", true);
        SpfyStoreItemLink.Modify(true);

        // [THEN] The intent is cancelled even though the id it was captured with is gone.
        _Assert.AreEqual(0, _Lib.DeletionRowCount(Database::Item, DummyDeletionLog.Status::Pending), 'Re-sync must cancel the pending delete intent of the entity regardless of its current Shopify id');
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::Item, DummyDeletionLog.Status::Cancelled), 'The cancelled intent must remain as history');
        _Lib.ConsumeConfirm();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GivenPendingIntent_WhenIdCleared_ThenIntentCancelled()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyDeletionLog: Record "NPR Spfy Deletion Log";
        SpfyDelCaptureSubscr: Codeunit "NPR Spfy Del. Capture Subscr.";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Clearing an entity's Shopify id cancels its pending delete intent, which could never be sent without an id, and keeps the cancelled row as history.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), 'gid://prod/12');
        SpfyStoreItemLink.Validate("Sync. to this Store", false);
        SpfyStoreItemLink.Modify(true);
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::Item, DummyDeletionLog.Status::Pending), 'Unsync with a Shopify id must capture a delete intent');

        // [WHEN] An operator clears the entity's Shopify id (the Set Shopify ID dialog path).
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        SpfyDelCaptureSubscr.OnShopifyIDCleared(SpfyStoreItemLink.RecordId(), "NPR Spfy ID Type"::"Entry ID");

        // [THEN] The intent is cancelled: without an id it could never be sent.
        _Assert.AreEqual(0, _Lib.DeletionRowCount(Database::Item, DummyDeletionLog.Status::Pending), 'Clearing the Shopify id must cancel the pending delete intent');
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::Item, DummyDeletionLog.Status::Cancelled), 'The cancelled intent must remain as history');
        _Lib.ConsumeConfirm();
    end;

    [Test]
    procedure GivenBlockedVariantIntent_WhenIdClearedBeforeUnblock_ThenUnblockCancelsIt()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DummyDeletionLog: Record "NPR Spfy Deletion Log";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Unblocking a variant cancels the delete intent captured when it was blocked, even after its Shopify id was cleared.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", ItemVariant.Code, StoreCode), 'gid://var/21');

        // [GIVEN] The variant is blocked while it still has a Shopify id: a delete intent is captured.
        ItemVariant.Blocked := true;
        ItemVariant.Modify(true);
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'Blocking a synced variant must capture a delete intent');

        // [GIVEN] An operator clears the variant's Shopify id before it is unblocked.
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(_Lib.VariantLinkRecordId(Item."No.", ItemVariant.Code, StoreCode), "NPR Spfy ID Type"::"Entry ID");

        // [WHEN] The variant is unblocked.
        ItemVariant.Blocked := false;
        ItemVariant.Modify(true);

        // [THEN] The intent is cancelled even though the id it was captured with is gone.
        _Assert.AreEqual(0, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'Unblocking must cancel the pending delete intent regardless of the variant''s current Shopify id');
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Cancelled), 'The cancelled intent must remain as history');
    end;

    [Test]
    procedure GivenVariantDeactivations_ThenIntentsCaptureAndCancel_AndReemitOnlyWhenPayloadChanged()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        DummyDeletionLog: Record "NPR Spfy Deletion Log";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Every variant deactivation captures a delete intent and every reactivation cancels it, and the variant is only re-sent afterwards when its payload changed while it was deactivated.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", ItemVariant.Code, StoreCode), 'gid://var/1');
        SpfySyncStateMgt.SeedItemVariantBaseline(ItemVariant);

        // [WHEN] A modif row arrives already flagged Not Available. [THEN] the insert path captures too.
        _Lib.CreateVariantModif(SpfyItemVariantModif, Item."No.", ItemVariant.Code, StoreCode, true);
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'Insert-as-not-available must capture a delete intent');

        // [WHEN] The variant becomes available again. [THEN] the intent is cancelled.
        SpfyItemVariantModif."Not Available" := false;
        SpfyItemVariantModif.Modify(true);
        _Assert.AreEqual(0, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'Reactivation must cancel the pending intent');
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Cancelled), 'The cancelled intent must remain auditable');

        // [WHEN] The variant is blocked. [THEN] a fresh Pending intent (dedup is Pending-only).
        ItemVariant.Blocked := true;
        ItemVariant.Modify(true);
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'Blocking a synced variant must capture a delete intent');

        // [WHEN] It is unblocked with NO other deactivation cause and NO payload change.
        ItemVariant.Blocked := false;
        ItemVariant.Modify(true);
        _Assert.AreEqual(0, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'Unblocking must cancel the queued delete');
        // [THEN] The cancel alone suffices: the variant re-poll is hash-suppressed (nothing changed while blocked).
        _Lib.DispatchModify(ItemVariant);
        _Assert.AreEqual(0, _Lib.TaskCount(Database::"Item Variant"), 'An unchanged unblocked variant must not be re-emitted');

        // [WHEN] It is blocked, EDITED while blocked, then unblocked.
        ItemVariant.Blocked := true;
        ItemVariant.Modify(true);
        ItemVariant.Description := 'Edited while blocked';
        ItemVariant.Modify(true);
        ItemVariant.Blocked := false;
        ItemVariant.Modify(true);
        _Lib.DispatchModify(ItemVariant);
        // [THEN] The delete is cancelled and exactly one variant update carries the current payload.
        _Assert.AreEqual(0, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'The re-block/unblock cycle must end cancelled');
        _Assert.AreEqual(1, _Lib.TaskCount(Database::"Item Variant"), 'A variant edited while blocked must be re-emitted once with its current payload');
    end;

    [Test]
    procedure GivenModifyAndPendingDelete_WhenCycleRuns_ThenModifyDispatchedBeforeTombstoneDelete()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        ModifyTask: Record "NPR Nc Task";
        DeleteTask: Record "NPR Nc Task";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        StoreCode: Code[20];
        DeleteEntryNo: BigInteger;
    begin
        // [SCENARIO] A detection cycle enqueues a same-cycle modify before it drains a pending delete, and the delete is sent from the captured tombstone keys even though the BC record is gone.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        SpfySyncStateMgt.SeedStoreItemLinkBaseline(SpfyStoreItemLink);
        _Lib.RegisterTable(Database::"NPR Spfy Store-Item Link");

        // [GIVEN] A same-cycle modify signal plus a pending delete whose BC record no longer exists.
        SpfyStoreItemLink."Shopify Name" := 'Same-cycle modify';
        SpfyStoreItemLink.Modify(false);
        DeleteEntryNo := _Lib.InsertPendingDelete(Database::"Item Variant", Item."No.", 'VGONE', '', StoreCode, 'gid://var/gone');

        // [WHEN] One detection cycle runs.
        _Lib.RunDetection();

        // [THEN] The modify is dispatched by the poll loop FIRST; deletes drain last.
        _Assert.IsTrue(_Lib.FindLastTask(Database::Item, ModifyTask), 'The modify task must exist');
        _Assert.IsTrue(_Lib.FindLastTask(Database::"Item Variant", DeleteTask), 'The delete task must exist');
        _Assert.IsTrue(DeleteTask."Entry No." > ModifyTask."Entry No.", 'A same-cycle modify must be enqueued before the entity''s delete');

        // [THEN] The tombstone alone drives the delete - no live BC record was needed.
        _Assert.IsTrue(DeleteTask.Type = DeleteTask.Type::Delete, 'The drained task must be a Delete');
        _Assert.AreEqual(Item."No." + '_VGONE', DeleteTask."Record Value", 'The delete must be keyed from the captured routing keys');
        DeletionLog.Get(DeleteEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'The drained intent must be marked Processed');
        _Assert.IsTrue(DeletionLog."NC Task Entry No." = DeleteTask."Entry No.", 'The intent must reference the NC task it produced');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GivenFourTransitionEdge_WhenParentLinkResyncs_ThenStaleVariantDeleteNeverExecutes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        NcTask: Record "NPR Nc Task";
        DummyDeletionLog: Record "NPR Spfy Deletion Log";
        DummyNcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        DrainedEntryNo: BigInteger;
    begin
        // [SCENARIO] Re-syncing a parent item cancels the stale variant and product delete intents left behind by a block, unsync and unblock race, including one already drained into an unsent task, so no delete ever reaches Shopify.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.AssignEntryID(SpfyStoreItemLink.RecordId(), 'gid://prod/blue');
        _Lib.CreateItemVariant(ItemVariant, Item."No.");
        _Lib.AssignEntryID(_Lib.VariantLinkRecordId(Item."No.", ItemVariant.Code, StoreCode), 'gid://var/blue');

        // [WHEN] Within one poll window: block -> parent unsync -> unblock (cancel suppressed) -> parent re-sync.
        ItemVariant.Blocked := true;
        ItemVariant.Modify(true);
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'The block must queue the variant delete');
        SpfyStoreItemLink.Validate("Sync. to this Store", false);
        SpfyStoreItemLink.Modify(true);
        ItemVariant.Blocked := false;
        ItemVariant.Modify(true);
        _Assert.AreEqual(1, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'The unblock cancel must be suppressed while the link unsync is active');
        SpfyStoreItemLink.Validate("Sync. to this Store", true);
        SpfyStoreItemLink.Modify(true);

        // [THEN] The parent re-sync defuses the stale variant delete (and its own product delete).
        _Assert.AreEqual(0, _Lib.DeletionRowCount(Database::"Item Variant", DummyDeletionLog.Status::Pending), 'The stale variant delete must be cancelled on parent re-sync');
        _Assert.AreEqual(0, _Lib.DeletionRowCount(Database::Item, DummyDeletionLog.Status::Pending), 'The product delete must be cancelled on parent re-sync');
        _Lib.RunDetection();
        _Assert.AreEqual(0, _Lib.TaskCountTyped(Database::"Item Variant", DummyNcTask.Type::Delete), 'No variant delete may reach Shopify');
        _Assert.AreEqual(0, _Lib.TaskCountTyped(Database::Item, DummyNcTask.Type::Delete), 'No product delete may reach Shopify');

        // [WHEN] The same race happens but a drain cycle already turned the intent into an UNSENT NC task.
        ItemVariant.Blocked := true;
        ItemVariant.Modify(true);
        DeletionLog.SetRange("Table No.", Database::"Item Variant");
        DeletionLog.SetRange(Status, DeletionLog.Status::Pending);
        DeletionLog.FindFirst();
        DrainedEntryNo := DeletionLog."Entry No.";
        _Lib.DrainDeleteRow(DrainedEntryNo);
        // Re-read by key: the record variable still filters on Pending, which the drain just left behind.
        DeletionLog.Get(DrainedEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Processed, 'The drain must process the queued delete');

        SpfyStoreItemLink.Validate("Sync. to this Store", false);
        SpfyStoreItemLink.Modify(true);
        ItemVariant.Blocked := false;
        ItemVariant.Modify(true);
        SpfyStoreItemLink.Validate("Sync. to this Store", true);
        SpfyStoreItemLink.Modify(true);

        // [THEN] The drain-raced Processed row is STILL cancelled and its unsent NC task is defused.
        DeletionLog.Get(DrainedEntryNo);
        _Assert.IsTrue(DeletionLog.Status = DeletionLog.Status::Cancelled, 'A drained-but-unsent delete must still be cancelled by the parent re-sync');
        NcTask.Get(DeletionLog."NC Task Entry No.");
        _Assert.IsTrue(NcTask.Processed, 'The outstanding NC delete task must be cancelled, never sent');
        _Assert.IsFalse(NcTask."Process Error", 'The cancelled task must not be flagged as an error');

        _Lib.ConsumeConfirm();   // the unsync Confirms above fire only when GuiAllowed() is true
    end;
    #endregion

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}

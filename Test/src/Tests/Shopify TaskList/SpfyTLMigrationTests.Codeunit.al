codeunit 85316 "NPR Spfy TL Migration Tests"
{
    // [FEATURE] Shopify Task List - the one-way environment cutover: the activation gate, the legacy hand-over and the post-migration job queues
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Spfy RowVer Test Lib";
        _BndMock: Codeunit "NPR Spfy TL Bnd Mock";
        _SpfyTaskProcessor: Codeunit "NPR Spfy Task Processor";
        _DeadRemainderMessage: Text[1024];
        _ResidualNotificationMessage: Text[1024];
        _ResidualNotificationCount: Integer;
        _NotYetAvailableErr: Label '%1 ships across several releases and cannot be activated yet.', Locked = true;
        _CannotDisableErr: Label 'The %1 feature is one-way and cannot be disabled once enabled.', Locked = true;
        _MigrationInProgressErr: Label 'A Shopify task list migration is already in progress.', Locked = true;
        _SimulatedHandOverErr: Label 'Simulated hand-over failure.', Locked = true;
        _ResidualMsg: Label '%1 NaviConnect task(s) could not be processed because they had already exhausted their processing attempts. They were left untouched and the updates they carry have not been sent to Shopify. Use a re-sync to recover the affected records.', Locked = true;

    local procedure Initialize()
    begin
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetFeatureEnabled(true);
        _BndMock.Reset();
        _SpfyTaskProcessor.SetSendBoundary(_BndMock);
        Clear(_DeadRemainderMessage);
    end;

    local procedure FeatureDescription(): Text
    var
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
    begin
        exit(SpfyTaskListFeature.GetFeatureDescription());
    end;

    local procedure TaskListFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(_Lib.TaskListFeatureId()) then
            exit(false);
        exit(Feature.Enabled);
    end;

    local procedure SetStatus(NewStatus: Option)
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.Get();
        ShopifySetup."Task List Migration Status" := NewStatus;
        ShopifySetup.Modify(false);
    end;

    local procedure MigrationStatus(): Integer
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.Get();
        exit(ShopifySetup."Task List Migration Status");
    end;

    local procedure ShopifyTaskProcessorCode(): Code[20]
    var
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
    begin
        exit(SpfyScheduleSend.GetShopifyTaskProcessorCode(true));
    end;

    local procedure SeedLegacyTask(StoreCode: Code[20]; Item: Record Item; TaskType: Option; NotBeforeDateTime: DateTime; LogDateTime: DateTime): BigInteger
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask."Task Processor Code" := ShopifyTaskProcessorCode();
        NcTask.Type := TaskType;
        NcTask."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NcTask."Company Name"));
        NcTask."Table No." := Database::Item;
        NcTask."Record ID" := Item.RecordId();
        NcTask."Record Value" := Item."No.";
        NcTask."Store Code" := StoreCode;
        NcTask."Not Before Date-Time" := NotBeforeDateTime;
        NcTask."Log Date" := LogDateTime;
        NcTask.Insert(true);
        exit(NcTask."Entry No.");
    end;

    // A variant request whose item does not exist is completed by the legacy engine in a single pass, without any Shopify request.
    local procedure SeedSettlingLegacyVariantTask(StoreCode: Code[20]): BigInteger
    var
        ItemVariant: Record "Item Variant";
        NcTask: Record "NPR Nc Task";
    begin
        _Lib.CreateItemVariant(ItemVariant, _Lib.NextCode('IT', MaxStrLen(ItemVariant."Item No.")));
        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask."Task Processor Code" := ShopifyTaskProcessorCode();
        NcTask.Type := NcTask.Type::Modify;
        NcTask."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NcTask."Company Name"));
        NcTask."Table No." := Database::"Item Variant";
        NcTask."Record ID" := ItemVariant.RecordId();
        NcTask."Record Value" := CopyStr(ItemVariant."Item No." + '_' + ItemVariant.Code, 1, MaxStrLen(NcTask."Record Value"));
        NcTask."Store Code" := StoreCode;
        NcTask."Log Date" := CurrentDateTime();
        NcTask.Insert(true);
        exit(NcTask."Entry No.");
    end;

    // An item with no store link at all fails the legacy send on every pass, again without any Shopify request.
    local procedure SeedBurningLegacyItemTask(StoreCode: Code[20]): BigInteger
    var
        Item: Record Item;
        NcTask: Record "NPR Nc Task";
    begin
        _Lib.CreateItem(Item);
        exit(SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime()));
    end;

    local procedure PostponeLegacyTask(NcTaskEntryNo: BigInteger)
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.Get(NcTaskEntryNo);
        NcTask.Postponed := true;
        NcTask."Postponed At" := CurrentDateTime();
        NcTask.Modify(false);
    end;

    local procedure ExhaustLegacyTask(NcTaskEntryNo: BigInteger)
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.Get(NcTaskEntryNo);
        NcTask."Process Count" := LegacyAttemptCap();
        NcTask.Modify(false);
    end;

    local procedure LegacyAttemptCap(): Integer
    begin
        exit(3);
    end;

    local procedure ReadyLegacyPoolCount(): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Task Processor Code", ShopifyTaskProcessorCode());
        NcTask.SetRange(Processed, false);
        NcTask.SetFilter("Process Count", '<%1', LegacyAttemptCap());
        exit(NcTask.Count());
    end;

    local procedure LegacyTask(NcTaskEntryNo: BigInteger; var NcTask: Record "NPR Nc Task")
    begin
        NcTask.Get(NcTaskEntryNo);
    end;

    // The availability gate also blocks the enable inside the cutover, so the feature is raw-enabled first and the cutover's own enable becomes a no-op.
    // The fixture writes are committed because the cutover commits as it goes, and the setup row is then re-read fresh: the cutover modifies it, and a cached image fails the concurrency check.
    local procedure ArmCutover(var ShopifySetup: Record "NPR Spfy Integration Setup")
    begin
        _Lib.SetTaskListFeatureEnabled(true);
        Commit();
        SelectLatestVersion();
        ShopifySetup.Get();
    end;

    local procedure MarkMigrating(StartedAt: DateTime)
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.Get();
        ShopifySetup."Task List Migration Status" := ShopifySetup."Task List Migration Status"::Migrating;
        ShopifySetup."Task List Migr. Started At" := StartedAt;
        ShopifySetup.Modify(false);
        Commit();
    end;

    local procedure RecreateLegacyTask(NcTaskEntryNo: BigInteger): BigInteger
    var
        NcTask: Record "NPR Nc Task";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
    begin
        NcTask.Get(NcTaskEntryNo);
        exit(SpfyTaskListMigration.RecreateLegacyRowInNewQueue(NcTask));
    end;

    local procedure ReopenLegacyTask(NcTaskEntryNo: BigInteger)
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.Get(NcTaskEntryNo);
        NcTask.Processed := false;
        NcTask.Modify(false);
    end;

    local procedure LegacyResponseText(NcTaskEntryNo: BigInteger): Text
    var
        NcTask: Record "NPR Nc Task";
        TypeHelper: Codeunit "Type Helper";
        IStream: InStream;
    begin
        NcTask.Get(NcTaskEntryNo);
        NcTask.CalcFields(Response);
        if not NcTask.Response.HasValue() then
            exit('');
        NcTask.Response.CreateInStream(IStream, TextEncoding::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(IStream, ' '));
    end;

    local procedure NewQueueCount(): Integer
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        exit(SpfyTask.Count());
    end;

    local procedure EnqueueNewQueueTask(StoreCode: Code[20]; Item: Record Item): BigInteger
    var
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskQueue: Codeunit "NPR Spfy Task Queue";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Item);
        SpfyTaskQueue.Enqueue(StoreCode, RecRef, Item.RecordId(), Item."No.", "NPR Spfy Task Op"::Modify, 0DT, 0DT, "NPR Spfy Reuse Delayed NC Task"::Any, CurrentDateTime(), SpfyTask);
        exit(SpfyTask."Entry No.");
    end;

    local procedure NewQueueTaskState(EntryNo: BigInteger): Enum "NPR Spfy Task State"
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Get(EntryNo);
        exit(SpfyTask.State);
    end;

    local procedure TaskProcessingJobQueueCount(StoreCode: Code[20]): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Task Processor");
        JobQueueEntry.SetRange("Parameter String", StoreCode);
        exit(JobQueueEntry.Count());
    end;

    local procedure LegacyProcessingJobQueueCount(StoreCode: Code[20]) JobCount: Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // Scanned rather than filtered: the store code sits inside a delimited parameter string, so a wildcard filter on it is unreliable.
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", LegacyProcessingCodeunitId());
        if not JobQueueEntry.FindSet() then
            exit(0);
        repeat
            if StrPos(JobQueueEntry."Parameter String", StoreCode) > 0 then
                JobCount += 1;
        until JobQueueEntry.Next() = 0;
    end;

    local procedure RunMigrationInBackground(var ErrorText: Text): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        Succeeded: Boolean;
    begin
        Clear(ErrorText);
        // The migration commits as it goes, which a savepoint from the fixture writes would otherwise invalidate.
        Commit();
        Succeeded := Codeunit.Run(Codeunit::"NPR Spfy Task List Migration", JobQueueEntry);
        if not Succeeded then
            ErrorText := GetLastErrorText();
        exit(Succeeded);
    end;

    local procedure OpenTaskListFeature(var FeatureManagement: TestPage "NPR Feature Management")
    begin
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(Id, _Lib.TaskListFeatureId());
        FeatureManagement.First();
    end;

    #region Activation gate
    [Test]
    procedure GivenGateDown_WhenFeatureIsEnabledByAnAdministrator_ThenActivationIsRefused()
    var
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] Turning the task list on before it has fully shipped is refused and leaves the feature off.
        Initialize();

        // [WHEN] An administrator turns the task list on while it has not fully shipped.
        OpenTaskListFeature(FeatureManagement);
        asserterror FeatureManagement.Enabled.SetValue(true);

        // [THEN] The activation is refused and the feature stays off.
        _Assert.ExpectedError(StrSubstNo(_NotYetAvailableErr, FeatureDescription()));
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A refused activation must leave the feature off');
    end;

    [Test]
    procedure GivenFeatureEnabled_WhenAnAdministratorTurnsItOff_ThenOneWayRefusal()
    var
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] Turning an enabled task list back off is refused because the switch is one way.
        Initialize();
        _Lib.SetTaskListFeatureEnabled(true);
        // Committed on purpose: the refused change rolls the transaction back, and the given has to survive that.
        Commit();

        // [WHEN] An administrator turns an enabled task list back off.
        OpenTaskListFeature(FeatureManagement);
        asserterror FeatureManagement.Enabled.SetValue(false);

        // [THEN] The switch is one way and the feature stays on.
        _Assert.ExpectedError(StrSubstNo(_CannotDisableErr, FeatureDescription()));
        _Assert.IsTrue(TaskListFeatureEnabled(), 'A refused deactivation must leave the feature on');
    end;

    [Test]
    procedure GivenGateDown_WhenShopifyFeatureIsEnabled_ThenTaskListIsNotAutoAdopted()
    var
        ShopifyFeature: Record "NPR Feature";
        WasEnabled: Boolean;
    begin
        // [SCENARIO] Enabling the Shopify integration adopts neither the task list nor a migration status while the task list has not shipped.
        Initialize();
        ShopifyFeature.SetRange(Feature, Enum::"NPR Feature"::Shopify);
        _Assert.IsTrue(ShopifyFeature.FindFirst(), 'The Shopify feature row must exist');
        WasEnabled := ShopifyFeature.Enabled;
        ShopifyFeature.Enabled := false;
        ShopifyFeature.Modify(false);

        // [WHEN] The Shopify integration feature is turned on, which is what a fresh environment adopts from.
        ShopifyFeature.Validate(Enabled, true);
        ShopifyFeature.Modify(true);

        // [THEN] The task list is not adopted while it has not fully shipped.
        _Assert.IsFalse(TaskListFeatureEnabled(), 'Enabling the Shopify feature must not auto-adopt the task list while the gate is down');
        _Assert.AreEqual(0, MigrationStatus(), 'An auto-adopt that did not happen must not stamp a migration status');

        ShopifyFeature.Get(ShopifyFeature.Id);
        ShopifyFeature.Enabled := WasEnabled;
        ShopifyFeature.Modify(false);
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenGateDown_WhenMigrationActionRuns_ThenRefusedBeforeAnyPrompt()
    var
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
    begin
        // [SCENARIO] Starting the migration from the setup page is refused before any prompt, leaving the feature off and no migration status stamped.
        Initialize();

        // [WHEN] An administrator starts the migration from the setup page.
        asserterror SpfyTaskListMigration.MigrateAndEnable();

        // [THEN] It is refused before the run-mode prompt and before any state is touched.
        _Assert.ExpectedError(StrSubstNo(_NotYetAvailableErr, FeatureDescription()));
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A refused migration must leave the feature off');
        _Assert.AreEqual(0, MigrationStatus(), 'A refused migration must not stamp a migration status');
    end;

    [Test]
    procedure GivenGateDown_WhenTheBackgroundMigrationRuns_ThenRefusedBeforeAnyStateChange()
    var
        ErrorText: Text;
    begin
        // [SCENARIO] The queued background migration is refused before the feature is enabled or the migration lease is taken.
        Initialize();

        // [WHEN] The queued background migration reaches the cutover.
        _Assert.IsFalse(RunMigrationInBackground(ErrorText), 'A gate-down migration must not be allowed to run');

        // [THEN] It is refused before the feature is enabled or the lease is taken.
        _Assert.IsTrue(StrPos(ErrorText, StrSubstNo(_NotYetAvailableErr, FeatureDescription())) > 0, StrSubstNo('The refusal must carry the gate error: %1', ErrorText));
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A refused cutover must leave the feature off');
        _Assert.AreEqual(0, MigrationStatus(), 'A refused cutover must not take the migration lease');
    end;
    #endregion

    #region Migration lease and status
    [Test]
    procedure GivenTrappedCutoverFailure_ThenStatusFailedAndRerunNotBlocked()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
    begin
        // [SCENARIO] A cutover failure surfaces to the caller, is recorded as Failed, and leaves the migration free to be started again.
        Initialize();

        // [GIVEN] A cutover armed to fail after it has taken the lease and enabled the feature.
        ArmCutover(ShopifySetup);
        _BndMock.SetHandOverFailure(_SimulatedHandOverErr);

        // [WHEN] The migration runs and its cutover fails.
        asserterror SpfyTaskListMigration.RunCutoverIsolated();

        // [THEN] The failure is trapped, surfaces to the caller, and the status records it.
        _Assert.ExpectedError(_SimulatedHandOverErr);
        SelectLatestVersion();
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Failed, StrSubstNo('A trapped cutover failure must set the migration status to Failed but it was %1', MigrationStatus()));

        // [WHEN] The migration is started again after the failure.
        ShopifySetup.Get();

        // [THEN] It was allowed to try again rather than being refused as already in progress.
        // Direct call: LOCKTABLE is forbidden inside a [TryFunction] under the test runner, so a raised error fails the test naturally.
        SpfyTaskListMigration.AcquireLock(ShopifySetup);
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenMigrationCompleted_WhenBackgroundRunStarts_ThenItShortCircuits()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        ErrorText: Text;
    begin
        // [SCENARIO] A background migration on an already migrated environment short circuits, leaving the completed status and the feature as they are.
        Initialize();
        _Lib.SetTaskListFeatureEnabled(true);

        // [WHEN] A queued background migration starts on an already migrated environment.
        _Assert.IsTrue(RunMigrationInBackground(ErrorText), StrSubstNo('A completed migration must short circuit instead of failing: %1', ErrorText));

        // [THEN] Nothing is re-run and the completed state stands.
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A completed migration must stay completed but the status was %1', MigrationStatus()));
        _Assert.IsTrue(TaskListFeatureEnabled(), 'A completed migration must leave the feature on');
    end;

    [Test]
    procedure GivenLiveMigrationLease_WhenASecondMigrationStarts_ThenBlockedUntilTheLeaseGoesStale()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
    begin
        // [SCENARIO] A second migration is refused while the lease is live and takes it over once the lease has gone stale.
        Initialize();

        // [GIVEN] A migration that started moments ago still holds the lease.
        MarkMigrating(CurrentDateTime());

        // [WHEN] A second administrator starts the migration.
        ShopifySetup.Get();
        asserterror SpfyTaskListMigration.AcquireLock(ShopifySetup);

        // [THEN] It is refused rather than allowed to run concurrently.
        _Assert.ExpectedError(_MigrationInProgressErr);

        // [WHEN] The holder has been gone for longer than an hour, so the lease has gone stale.
        MarkMigrating(CurrentDateTime() - 90 * 60 * 1000);
        ShopifySetup.Get();

        // [THEN] The stale lease is taken over instead of blocking the environment for good.
        // Direct call: LOCKTABLE is forbidden inside a [TryFunction] under the test runner, so a raised error fails the test naturally.
        SpfyTaskListMigration.AcquireLock(ShopifySetup);
    end;
    #endregion

    #region Legacy row hand-over
    [Test]
    procedure GivenFutureScheduledLegacyRow_WhenRecreated_ThenTwinKeepsScheduleAndProvenance()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        NotBeforeDateTime: DateTime;
        LogDateTime: DateTime;
        LegacyEntryNo: BigInteger;
        NewEntryNo: BigInteger;
    begin
        // [SCENARIO] A handed-over legacy row produces a pending twin that keeps its op, identity, schedule and log date, and the two rows reference each other.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LogDateTime := CreateDateTime(WorkDate(), 090000T);
        NotBeforeDateTime := CreateDateTime(CalcDate('<+2D>', WorkDate()), 233000T);
        LegacyEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Insert, NotBeforeDateTime, LogDateTime);

        // [WHEN] The cutover hands the still-scheduled legacy row over to the new queue.
        NewEntryNo := RecreateLegacyTask(LegacyEntryNo);

        // [THEN] The twin carries the same intent and schedule, and points back at the row it replaced.
        _Assert.IsTrue(NewEntryNo <> 0, 'The hand-over must create a new-queue task');
        _Assert.IsTrue(SpfyTask.Get(NewEntryNo), 'The new-queue twin must exist');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Insert, 'The twin must keep the legacy op');
        _Assert.AreEqual(Database::Item, SpfyTask."Table No.", 'The twin must keep the source table');
        _Assert.AreEqual(Item.RecordId(), SpfyTask."Record ID", 'The twin must keep the source record id');
        _Assert.AreEqual(Item."No.", SpfyTask."Record Value", 'The twin must keep the record value');
        _Assert.AreEqual(StoreCode, SpfyTask."Store Code", 'The twin must keep the store');
        _Assert.AreEqual(NotBeforeDateTime, SpfyTask."Not Before Date-Time", 'The twin must keep the scheduled start time');
        _Assert.AreEqual(LogDateTime, SpfyTask."Log Date", 'The twin must keep the original log date');
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, 'The twin must be waiting to be sent');
        _Assert.AreEqual(0, SpfyTask.Attempts, 'The twin must start with no attempts');
        _Assert.IsFalse(IsNullGuid(SpfyTask."Dispatch Id"), 'The twin must get its own dispatch id');
        _Assert.IsTrue(SpfyTask."Migrated From NC Entry No." = LegacyEntryNo, 'The twin must reference the legacy row it came from');

        // [THEN] The legacy row is closed with a reference to its successor.
        NcTask.Get(LegacyEntryNo);
        _Assert.IsTrue(NcTask.Processed, 'The migrated legacy row must be closed');
        _Assert.IsTrue(StrPos(LegacyResponseText(LegacyEntryNo), Format(NewEntryNo)) > 0, StrSubstNo('The legacy row must name its successor: %1', LegacyResponseText(LegacyEntryNo)));
    end;

    [Test]
    procedure GivenRecreatedRow_WhenRecreateRunsAgain_ThenNothingIsDuplicated()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        LegacyEntryNo: BigInteger;
        FirstEntryNo: BigInteger;
        SecondEntryNo: BigInteger;
    begin
        // [SCENARIO] Handing a legacy row over a second time creates nothing new and reuses the twin it was already migrated into.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LegacyEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime());
        FirstEntryNo := RecreateLegacyTask(LegacyEntryNo);
        _Assert.AreEqual(1, NewQueueCount(), 'The first hand-over must create exactly one task');

        // [WHEN] The migration is re-run over a legacy row it already closed.
        SecondEntryNo := RecreateLegacyTask(LegacyEntryNo);

        // [THEN] Nothing further happens.
        _Assert.IsTrue(SecondEntryNo = 0, 'A closed legacy row must not be handed over again');
        _Assert.AreEqual(1, NewQueueCount(), 'A re-run must not duplicate the new-queue task');

        // [WHEN] The legacy row is still open on a re-run, so only the successor link can prevent a duplicate.
        ReopenLegacyTask(LegacyEntryNo);
        SecondEntryNo := RecreateLegacyTask(LegacyEntryNo);

        // [THEN] The existing twin is reused.
        _Assert.IsTrue(SecondEntryNo = FirstEntryNo, 'A re-run must reuse the twin the legacy row was already migrated into');
        _Assert.AreEqual(1, NewQueueCount(), 'A re-run must never create a second twin for one legacy row');
    end;

    [Test]
    procedure GivenProcessedOrRenameLegacyRow_WhenRecreated_ThenSkipped()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        RenameEntryNo: BigInteger;
        ProcessedEntryNo: BigInteger;
    begin
        // [SCENARIO] Neither an already sent legacy row nor a rename is handed over, and the rename is left open for a human to deal with.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        RenameEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Rename, 0DT, CurrentDateTime());
        ProcessedEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime());
        NcTask.Get(ProcessedEntryNo);
        NcTask.Processed := true;
        NcTask.Modify(false);

        // [WHEN] The hand-over meets a legacy op the new queue has no counterpart for, and an already sent row.
        _Assert.IsTrue(RecreateLegacyTask(RenameEntryNo) = 0, 'A rename must not be mapped into the new queue');
        _Assert.IsTrue(RecreateLegacyTask(ProcessedEntryNo) = 0, 'An already sent legacy row must not be handed over');

        // [THEN] Neither produces a task and the rename row is left open for a human to deal with.
        _Assert.AreEqual(0, NewQueueCount(), 'No new-queue task may be created for a rename or a sent row');
        NcTask.Get(RenameEntryNo);
        _Assert.IsFalse(NcTask.Processed, 'A rename that could not be migrated must not be silently closed');
    end;

    [Test]
    procedure GivenMigratedDeleteTask_ThenDeletionLogFollowsIntoTheNewQueue()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DeletionLog: Record "NPR Spfy Deletion Log";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        LegacyEntryNo: BigInteger;
        NewEntryNo: BigInteger;
    begin
        // [SCENARIO] A deletion log entry follows its task into the new queue and stops pointing at the dead legacy row.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LegacyEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Delete, 0DT, CurrentDateTime());

        // [GIVEN] A deletion log entry whose queued task is the legacy row.
        DeletionLog.Init();
        DeletionLog."Table No." := Database::Item;
        DeletionLog."Shopify Store Code" := StoreCode;
        DeletionLog."Shopify ID" := 'REPOINT-TEST';
        DeletionLog.Status := DeletionLog.Status::Processed;
        DeletionLog."NC Task Entry No." := LegacyEntryNo;
        DeletionLog.Insert(true);

        // [WHEN] The legacy row is handed over to the new queue.
        NewEntryNo := RecreateLegacyTask(LegacyEntryNo);

        // [THEN] The deletion log follows the task: the new-queue field is the only one set.
        DeletionLog.Get(DeletionLog."Entry No.");
        _Assert.AreEqual(NewEntryNo, DeletionLog."Spfy Task Entry No.", 'The deletion log must point at the migrated task in the new queue');
        _Assert.IsTrue(DeletionLog."NC Task Entry No." = 0, 'The deletion log must no longer point at the dead legacy row');
    end;

    [Test]
    procedure GivenMigratedTagTask_ThenTagUpdateRequestFollowsIntoTheNewQueue()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        TagUpdateRequest: Record "NPR Spfy Tag Update Request";
        NcTask: Record "NPR Nc Task";
        StoreCode: Code[20];
        LegacyEntryNo: BigInteger;
        NewEntryNo: BigInteger;
    begin
        // [SCENARIO] A tag update request follows its task into the new queue and stops pointing at the dead legacy row.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        LegacyEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime());

        // [GIVEN] A tag update request whose queued task is the legacy row.
        TagUpdateRequest.Init();
        TagUpdateRequest."Entry No." := 0;
        TagUpdateRequest."Tag Value" := 'REPOINT-TEST';
        TagUpdateRequest."Nc Task Entry No." := LegacyEntryNo;
        TagUpdateRequest.Insert(true);

        // [WHEN] The legacy row is handed over to the new queue.
        NewEntryNo := RecreateLegacyTask(LegacyEntryNo);

        // [THEN] The request follows the task: the new-queue field is the only one set.
        TagUpdateRequest.Get(TagUpdateRequest."Entry No.");
        _Assert.AreEqual(NewEntryNo, TagUpdateRequest."Spfy Task Entry No.", 'The tag update request must point at the migrated task in the new queue');
        _Assert.IsTrue(TagUpdateRequest."Nc Task Entry No." = 0, 'The tag update request must no longer point at the dead legacy row');
    end;

    [Test]
    procedure GivenLegacyResidualAfterMigration_WhenStoreCycleRuns_ThenItIsRecreatedInNewQueue()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        LegacyEntryNo: BigInteger;
    begin
        // [SCENARIO] A legacy row written after the migration is rescued into the new queue by a processing cycle, and the legacy row is closed.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.SetTaskListFeatureEnabled(true);

        // [GIVEN] Something wrote to the legacy queue after the environment had already migrated.
        LegacyEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, AtDateTime);

        // [WHEN] A processing cycle runs.
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The residual is rescued into the new queue and the legacy row is closed.
        SpfyTask.SetRange("Migrated From NC Entry No.", LegacyEntryNo);
        _Assert.AreEqual(1, SpfyTask.Count(), 'A legacy residual must be re-created in the new queue');
        NcTask.Get(LegacyEntryNo);
        _Assert.IsTrue(NcTask.Processed, 'The rescued legacy row must be closed');
    end;
    #endregion

    #region Legacy queue drain
    [Test]
    [HandlerFunctions('DeadRemainderMessageHandler')]
    procedure GivenReadyLegacyPool_WhenCutoverRuns_ThenPoolIsDrainedAndDeadRemainderReported()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SettlingTask: Record "NPR Nc Task";
        BurningTask: Record "NPR Nc Task";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        SettlingEntryNo: BigInteger;
        BurningEntryNo: BigInteger;
    begin
        // [SCENARIO] The cutover drains the legacy queue until nothing processable is left, hands nothing over to the new queue, completes, and tells the operator what it had to leave behind.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        SettlingEntryNo := SeedSettlingLegacyVariantTask(StoreCode);
        BurningEntryNo := SeedBurningLegacyItemTask(StoreCode);
        _Assert.AreEqual(2, ReadyLegacyPoolCount(), 'Both seeded rows must be processable before the cutover');
        ArmCutover(ShopifySetup);

        // [WHEN] The cutover hands the legacy queue over.
        SpfyTaskListMigration.RunEnvironmentCutover(ShopifySetup);

        // [THEN] The drain kept working until nothing processable was left.
        _Assert.AreEqual(0, ReadyLegacyPoolCount(), 'The cutover must leave no processable legacy task behind');
        LegacyTask(SettlingEntryNo, SettlingTask);
        _Assert.IsTrue(SettlingTask.Processed, 'The drain must close the legacy row it can settle');
        LegacyTask(BurningEntryNo, BurningTask);
        _Assert.IsFalse(BurningTask.Processed, 'The drain must not close a legacy row it never managed to send');
        _Assert.AreEqual(LegacyAttemptCap(), BurningTask."Process Count", 'The drain must retry a failing legacy row until its attempts are exhausted');

        // [THEN] Nothing had to be handed to the new queue, and the operator was told what was left behind.
        _Assert.AreEqual(0, NewQueueCount(), 'A drained legacy pool leaves nothing to re-create in the new queue');
        _Assert.AreEqual(StrSubstNo(_ResidualMsg, 1), _DeadRemainderMessage, 'The operator must be told how many legacy tasks were left behind');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A drained queue must complete the migration but the status was %1', MigrationStatus()));
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    [HandlerFunctions('DeadRemainderMessageHandler')]
    procedure GivenExhaustedLegacyRow_WhenCutoverRuns_ThenLeftBehindAndCountReported()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        NcTask: Record "NPR Nc Task";
        DeadTask: Record "NPR Nc Task";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        DeadEntryNo: BigInteger;
    begin
        // [SCENARIO] A legacy row that had already used up its attempts is left exactly as found and not handed over, while the migration still completes and reports it.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);

        // [GIVEN] A legacy row that had already used up its processing attempts before the migration started.
        DeadEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime());
        ExhaustLegacyTask(DeadEntryNo);
        ArmCutover(ShopifySetup);

        // [WHEN] The cutover hands the legacy queue over.
        SpfyTaskListMigration.RunEnvironmentCutover(ShopifySetup);

        // [THEN] The dead row is left exactly as it was found.
        LegacyTask(DeadEntryNo, DeadTask);
        _Assert.IsFalse(DeadTask.Processed, 'An exhausted legacy row must not be closed by the migration');
        _Assert.AreEqual(LegacyAttemptCap(), DeadTask."Process Count", 'An exhausted legacy row must not be retried by the migration');
        _Assert.AreEqual(0, NewQueueCount(), 'An exhausted legacy row must not be handed over to the new queue');

        // [THEN] The migration still completes, and the operator is told how much was abandoned.
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A dead remainder must not fail the migration but the status was %1', MigrationStatus()));
        _Assert.AreEqual(StrSubstNo(_ResidualMsg, 1), _DeadRemainderMessage, 'The operator must be told how many legacy tasks were abandoned');
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenRenameLegacyRow_WhenCutoverRuns_ThenItIsIgnoredAndTheMigrationCompletes()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        NcTask: Record "NPR Nc Task";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        RenameEntryNo: BigInteger;
    begin
        // [SCENARIO] A rename neither blocks the cutover nor reaches the new queue, and is left untouched.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);

        // [GIVEN] A rename the new queue has no counterpart for.
        RenameEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Rename, CurrentDateTime() + 60 * 60 * 1000, CurrentDateTime());
        ArmCutover(ShopifySetup);

        // [WHEN] The cutover hands the legacy queue over.
        SpfyTaskListMigration.RunEnvironmentCutover(ShopifySetup);

        // [THEN] The rename is invisible to the hand-over: the migration completes and the row is left for a human.
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A rename row must not block the cutover but the status was %1', MigrationStatus()));
        _Assert.AreEqual(0, NewQueueCount(), 'A rename must not be handed over to the new queue');
        NcTask.Get(RenameEntryNo);
        _Assert.IsFalse(NcTask.Processed, 'A rename must be left untouched by the migration');
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenPostponedLegacyRow_WhenCutoverRuns_ThenUnpostponedAndSettled()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        StuckTask: Record "NPR Nc Task";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        StuckEntryNo: BigInteger;
    begin
        // [SCENARIO] A postponed legacy row is rescued out of that state, settled by the drain, and not also re-created in the new queue.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A legacy row the frozen batch processor left postponed, which no drain pass would pick up on its own.
        StuckEntryNo := SeedSettlingLegacyVariantTask(StoreCode);
        PostponeLegacyTask(StuckEntryNo);
        ArmCutover(ShopifySetup);

        // [WHEN] The cutover hands the legacy queue over.
        SpfyTaskListMigration.RunEnvironmentCutover(ShopifySetup);

        // [THEN] The migration rescued it out of the postponed state and let the drain settle it.
        LegacyTask(StuckEntryNo, StuckTask);
        _Assert.IsFalse(StuckTask.Postponed, 'The migration must un-postpone a stuck legacy row');
        _Assert.IsTrue(StuckTask.Processed, 'An un-postponed legacy row must settle through the drain');
        _Assert.AreEqual(0, ReadyLegacyPoolCount(), 'A settled legacy row must leave the ready pool empty');
        _Assert.AreEqual(0, NewQueueCount(), 'A legacy row the drain settled must not also be re-created in the new queue');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A settled postponed row must complete the migration but the status was %1', MigrationStatus()));
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    [HandlerFunctions('ResidualNotificationHandler')]
    procedure GivenResidualLegacyRowsAfterMigration_WhenSetupIsOpened_ThenTheReSyncNeedIsSurfaced()
    var
        Item: Record Item;
        ShopifySetup: Record "NPR Spfy Integration Setup";
        NcTask: Record "NPR Nc Task";
        SpfyIntegrationSetup: TestPage "NPR Spfy Integration Setup";
        StoreCode: Code[20];
        LegacyEntryNo: BigInteger;
    begin
        // [SCENARIO] Opening the Shopify setup after the migration reports the unsent updates left behind exactly once, and reports nothing after they are cleaned up.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);

        // [GIVEN] A completed migration that left one exhausted legacy row behind.
        LegacyEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime());
        ExhaustLegacyTask(LegacyEntryNo);
        SetStatus(ShopifySetup."Task List Migration Status"::Completed);

        // [WHEN] An operator opens the Shopify setup.
        Clear(_ResidualNotificationCount);
        Clear(_ResidualNotificationMessage);
        SpfyIntegrationSetup.OpenView();
        SpfyIntegrationSetup.Close();

        // [THEN] The unsent updates are surfaced where the operator who has to run the re-sync will see them.
        _Assert.AreEqual(1, _ResidualNotificationCount, 'A residual legacy row must raise exactly one notification on the setup page');
        _Assert.IsTrue(StrPos(_ResidualNotificationMessage, 'have not been sent to Shopify') > 0, StrSubstNo('The notification must state that the updates are unsent but was: %1', _ResidualNotificationMessage));

        // [WHEN] The residual row is cleaned up and the page is opened again.
        NcTask.Get(LegacyEntryNo);
        NcTask.Processed := true;
        NcTask.Modify(false);
        Clear(_ResidualNotificationCount);
        SpfyIntegrationSetup.OpenView();
        SpfyIntegrationSetup.Close();

        // [THEN] Nothing is reported.
        _Assert.AreEqual(0, _ResidualNotificationCount, 'A cleaned-up queue must not raise the residual notification');
    end;

    [Test]
    [HandlerFunctions('ResidualNotificationHandler')]
    procedure GivenLegacyRowWithAttemptsLeftAfterMigration_WhenSetupIsOpened_ThenItIsStillSurfaced()
    var
        Item: Record Item;
        ShopifySetup: Record "NPR Spfy Integration Setup";
        NcTask: Record "NPR Nc Task";
        SpfyIntegrationSetup: TestPage "NPR Spfy Integration Setup";
        StoreCode: Code[20];
    begin
        // [SCENARIO] An unprocessed legacy row is surfaced on the setup page whatever its attempt count.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateItem(Item);

        // [GIVEN] A completed migration and an unprocessed legacy row that still has attempts left. A completed
        // migration verifies none of these survive, so one appearing later means something is still writing to the
        // NaviConnect queue - which is a residual the operator has to know about just as much as an exhausted row.
        SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime());
        SetStatus(ShopifySetup."Task List Migration Status"::Completed);
        Clear(_ResidualNotificationCount);

        // [WHEN] An operator opens the Shopify setup.
        SpfyIntegrationSetup.OpenView();
        SpfyIntegrationSetup.Close();

        // [THEN] It is surfaced, not filtered out by an attempt count the page must not depend on.
        _Assert.AreEqual(1, _ResidualNotificationCount, 'An unprocessed legacy row must be surfaced whatever its attempt count');
    end;

    [SendNotificationHandler]
    procedure ResidualNotificationHandler(var ResidualNotification: Notification): Boolean
    begin
        _ResidualNotificationCount += 1;
        _ResidualNotificationMessage := CopyStr(ResidualNotification.Message(), 1, MaxStrLen(_ResidualNotificationMessage));
        exit(true);
    end;

    [MessageHandler]
    procedure DeadRemainderMessageHandler(Message: Text[1024])
    begin
        _DeadRemainderMessage := Message;
    end;
    #endregion

    #region Post-migration eligibility and job queues
    [Test]
    procedure GivenMigrationNotCompleted_WhenStoreCycleRuns_ThenNothingIsProcessed()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        StoreCode: Code[20];
        AtDateTime: DateTime;
        TaskEntryNo: BigInteger;
    begin
        // [SCENARIO] Nothing is sent while the migration is still under way, and the backlog is processed once it has completed.
        Initialize();
        AtDateTime := CurrentDateTime();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.SetTaskListFeatureEnabled(true);
        TaskEntryNo := EnqueueNewQueueTask(StoreCode, Item);

        // [WHEN] A cycle runs while the migration is still under way.
        SetStatus(ShopifySetup."Task List Migration Status"::Migrating);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] Nothing is sent and the task waits.
        _Assert.AreEqual(0, _BndMock.DispatchCount(), 'No task may be sent before the migration has completed');
        _Assert.IsTrue(NewQueueTaskState(TaskEntryNo) = "NPR Spfy Task State"::Pending, 'The task must be left waiting while the migration is under way');

        // [WHEN] The migration completes and a cycle runs again.
        SetStatus(ShopifySetup."Task List Migration Status"::Completed);
        _SpfyTaskProcessor.RunStoreCycle(StoreCode, AtDateTime);

        // [THEN] The backlog is processed.
        _Assert.AreEqual(1, _BndMock.DispatchCount(), 'The task must be sent once the migration has completed');
        _Assert.IsTrue(NewQueueTaskState(TaskEntryNo) = "NPR Spfy Task State"::Completed, 'The task must be completed once the migration has completed');
    end;

    [Test]
    procedure GivenMigrationCompleted_WhenJobQueuesAreEnsured_ThenOnePerEnabledStore()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Processing jobs are scheduled only by the migration itself or after it has completed, and exactly one exists per enabled store however often they are ensured.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [WHEN] The job queues are ensured before the migration has completed.
        SpfyTaskJQSetup.SetupTaskProcessingJobQueues();

        // [THEN] Nothing is scheduled, so a half-migrated environment never starts processing.
        _Assert.AreEqual(0, TaskProcessingJobQueueCount(StoreCode), 'No processing job may be scheduled before the migration has completed');

        // [WHEN] The migration is under way and the migration ensures the jobs itself.
        SetStatus(ShopifySetup."Task List Migration Status"::Migrating);
        SpfyTaskJQSetup.SetupTaskProcessingJobQueues();
        _Assert.AreEqual(0, TaskProcessingJobQueueCount(StoreCode), 'The login refresher must not schedule the job while the migration is under way');
        SpfyTaskJQSetup.SetupTaskProcessingJobQueuesForMigration();
        _Assert.AreEqual(1, TaskProcessingJobQueueCount(StoreCode), 'The migration itself must schedule the processing job for the store');

        // [WHEN] The environment has migrated and the jobs are ensured again.
        _Lib.DeleteDetectionJobQueueEntries();
        SetStatus(ShopifySetup."Task List Migration Status"::Completed);
        SpfyTaskJQSetup.SetupTaskProcessingJobQueues();

        // [THEN] Exactly one processing job exists for the store.
        _Assert.AreEqual(1, TaskProcessingJobQueueCount(StoreCode), 'One processing job must be scheduled per enabled store');
        SpfyTaskJQSetup.SetupTaskProcessingJobQueues();
        _Assert.AreEqual(1, TaskProcessingJobQueueCount(StoreCode), 'Ensuring the jobs twice must not duplicate them');
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenAProcessorJobOnManualHold_WhenTheCutoverRuns_ThenTheMigrationFailsInsteadOfReportingSuccess()
    var
        Item: Record Item;
        JobQueueEntry: Record "Job Queue Entry";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A processor job an operator put on hold makes the cutover fail and record the migration as Failed instead of reporting success.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);

        // [GIVEN] A processor job queue entry for the store that an operator has set on hold manually.
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR Spfy Task Processor";
        JobQueueEntry."Parameter String" := StoreCode;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR Manually Set On Hold" := true;
        JobQueueEntry.Insert(false);
        ArmCutover(ShopifySetup);

        // [WHEN] The cutover runs through the wrapper that owns the failure handling.
        asserterror SpfyTaskListMigration.RunCutoverIsolated();

        // [THEN] The declined activation is recorded as a failure, not left mid-run.
        SelectLatestVersion();
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Failed, StrSubstNo('A declined job queue activation must set the migration status to Failed but it was %1', MigrationStatus()));
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenFreshEnvironment_WhenTaskListIsAdopted_ThenMigrationCompletedAndJobQueuesEnsured()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A fresh environment adopting the task list is immediately declared migrated and gets its per-store processing job.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Assert.IsFalse(TaskListFeatureEnabled(), 'The feature must be off before the adoption');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::NotStarted, StrSubstNo('The migration status must be Not Started before the adoption but was %1', MigrationStatus()));
        _Assert.AreEqual(0, TaskProcessingJobQueueCount(StoreCode), 'No processing job may exist before the adoption');

        // [WHEN] A fresh environment adopts the task list without going through a migration.
        SpfyTaskListFeature.EnableFeatureChecked();

        // [THEN] The environment is immediately declared migrated and the per-store processors are scheduled.
        _Assert.IsTrue(TaskListFeatureEnabled(), 'The adoption must enable the feature');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A fresh adoption must stamp the migration as completed but the status was %1', MigrationStatus()));
        _Assert.AreEqual(1, TaskProcessingJobQueueCount(StoreCode), 'A fresh adoption must schedule the processing job for the store');

        _Lib.DeleteDetectionJobQueueEntries();
        _Lib.SetTaskListFeatureEnabled(false);
    end;

    [Test]
    procedure GivenMigrationCompleted_WhenLegacyTaskIsProcessed_ThenTaskSetupIsNotRecreated()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        StoreCode: Code[20];
        CompletedEntryNo: BigInteger;
        MigratingEntryNo: BigInteger;
    begin
        // [SCENARIO] A migrated environment never rebuilds the legacy send setup, while a migration still under way still can.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        CompletedEntryNo := SeedBurningLegacyItemTask(StoreCode);
        MigratingEntryNo := SeedBurningLegacyItemTask(StoreCode);
        ClearShopifyTaskSetup();

        // [WHEN] A resurrected legacy row is processed after the environment has migrated.
        SetStatus(ShopifySetup."Task List Migration Status"::Completed);
        ProcessLegacyTask(CompletedEntryNo);

        // [THEN] The legacy send path is not rebuilt, so the row cannot be sent through the retired queue.
        _Assert.AreEqual(0, ShopifyTaskSetupCount(), 'A migrated environment must not recreate the legacy task setup');

        // [WHEN] The same happens while the migration is still under way.
        SetStatus(ShopifySetup."Task List Migration Status"::Migrating);
        ProcessLegacyTask(MigratingEntryNo);

        // [THEN] The setup is created, so the guard above was really the thing that stopped it.
        _Assert.AreEqual(1, ShopifyTaskSetupCount(), 'The migration itself must still be able to build the legacy task setup it drains through');
        ClearShopifyTaskSetup();
    end;

    local procedure ShopifyTaskSetupCount(): Integer
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
    begin
        NcTaskSetup.SetRange("Task Processor Code", ShopifyTaskProcessorCode());
        NcTaskSetup.SetRange("Table No.", Database::Item);
        exit(NcTaskSetup.Count());
    end;

    local procedure ClearShopifyTaskSetup()
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
    begin
        NcTaskSetup.SetRange("Task Processor Code", ShopifyTaskProcessorCode());
        NcTaskSetup.SetRange("Table No.", Database::Item);
        if not NcTaskSetup.IsEmpty() then
            NcTaskSetup.DeleteAll(false);
    end;

    local procedure ProcessLegacyTask(NcTaskEntryNo: BigInteger)
    var
        NcTask: Record "NPR Nc Task";
        NcSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
    begin
        // The frozen legacy engine is the only caller that reaches the task setup guard, through its OnBeforeProcessTask publisher.
        NcTask.Get(NcTaskEntryNo);
        if NcSyncMgt.ProcessTask(NcTask) then;
    end;

    [Test]
    procedure GivenMigrationStarted_WhenLegacyJobQueuesRefresh_ThenTheyAreNotRecreated()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        StoreCode: Code[20];
    begin
        // [SCENARIO] The legacy processing job is never re-created once the migration has started, nor after it has completed.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A legacy processing job for the store, proving the readback would see one if it were re-created.
        SeedLegacyProcessingJobQueue(StoreCode);
        _Assert.AreEqual(1, LegacyProcessingJobQueueCount(StoreCode), StrSubstNo('The seeded legacy processing job must be visible to the readback. Store %1, legacy codeunit %2, rows: %3', StoreCode, LegacyProcessingCodeunitId(), DumpLegacyJobQueues()));
        RemoveLegacyProcessingJobQueues(StoreCode);
        _Assert.AreEqual(0, LegacyProcessingJobQueueCount(StoreCode), 'The legacy processing job must be gone before the migration case');

        // [WHEN] The refresher runs once the migration has started.
        SetStatus(ShopifySetup."Task List Migration Status"::Migrating);
        SpfyScheduleSend.SetupTaskProcessingJobQueues();
        _Assert.AreEqual(0, LegacyProcessingJobQueueCount(StoreCode), 'The legacy processing job must not be re-created once the migration has started');

        // [WHEN] The refresher runs after the migration completed.
        SetStatus(ShopifySetup."Task List Migration Status"::Completed);
        SpfyScheduleSend.SetupTaskProcessingJobQueues();

        // [THEN] The legacy processor stays gone for good.
        _Assert.AreEqual(0, LegacyProcessingJobQueueCount(StoreCode), 'The legacy processing job must never come back after the migration');
        RemoveLegacyProcessingJobQueues(StoreCode);
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    local procedure SeedLegacyProcessingJobQueue(StoreCode: Code[20])
    var
        JobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        NcTaskListProcessing: Codeunit "NPR Nc Task List Processing";
    begin
        // On hold on purpose: the row only has to be visible to the readback, never to run.
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := NcSetupMgt.TaskListProcessingCodeunit();
        JobQueueEntry."Parameter String" := CopyStr(StrSubstNo('%1?%2;%3?%4', NcTaskListProcessing.ParamProcessor(), ShopifyTaskProcessorCode(), NcTaskListProcessing.ParamStoreCode(), StoreCode), 1, MaxStrLen(JobQueueEntry."Parameter String"));
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(false);
    end;

    local procedure LegacyProcessingCodeunitId(): Integer
    var
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        exit(NcSetupMgt.TaskListProcessingCodeunit());
    end;

    local procedure DumpLegacyJobQueues(): Text
    var
        JobQueueEntry: Record "Job Queue Entry";
        Builder: TextBuilder;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", LegacyProcessingCodeunitId());
        if not JobQueueEntry.FindSet() then
            exit('<none>');
        repeat
            Builder.Append(StrSubstNo('[status=%1 param=%2]', JobQueueEntry.Status, JobQueueEntry."Parameter String"));
        until JobQueueEntry.Next() = 0;
        exit(Builder.ToText());
    end;

    local procedure RemoveLegacyProcessingJobQueues(StoreCode: Code[20])
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", LegacyProcessingCodeunitId());
        if not JobQueueEntry.FindSet() then
            exit;
        repeat
            if StrPos(JobQueueEntry."Parameter String", StoreCode) > 0 then
                JobQueueEntry.Delete(false);
        until JobQueueEntry.Next() = 0;
    end;
    #endregion
}

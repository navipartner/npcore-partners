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
        _CannotDisableErr: Label 'The %1 feature can no longer be disabled: this environment already runs Shopify sends through the task list, and switching it off would strand that work.', Locked = true;
        _ExistingIntegrationErr: Label 'Enabling %1 on an environment that already synchronizes Shopify data requires running the task list migration. Use the "Migrate to Shopify Task List" action on the Shopify Integration Setup page.', Locked = true;
        _RowVersionMigrationActionTok: Label 'Migrate to RowVersion detection', Locked = true;
        _MigrationInProgressErr: Label 'A Shopify task list migration is already in progress.', Locked = true;
        _SimulatedHandOverErr: Label 'Simulated hand-over failure.', Locked = true;
        _CouldNotScheduleErr: Label 'The background migration could not be scheduled.', Locked = true;
        _NeedsActivationTok: Label 'your user cannot start scheduled tasks', Locked = true;
        _ProcessorOnHoldTok: Label 'the Shopify task processing job could not be started and is on hold', Locked = true;
        _ParkedStoreTok: Label 'ZZPARKED', Locked = true;
        _OverridesNotConfirmedTok: Label 'did not confirm their removal', Locked = true;
        _RunModeOptionsTok: Label 'Run in foreground,Run in background', Locked = true;
        _ResidualMsg: Label '%1 NaviConnect task(s) could not be processed because they had already exhausted their processing attempts. They were left untouched and the updates they carry have not been sent to Shopify. Use a re-sync to recover the affected records.', Locked = true;

    local procedure Initialize()
    begin
        _Lib.ResetState();
        _Lib.EnsureIntegrationEnabled();
        _Lib.SetFeatureEnabled(true);
        _BndMock.Reset();
        _SpfyTaskProcessor.SetSendBoundary(_BndMock);
        Clear(_DeadRemainderMessage);
        // The migration refuses an environment that still detects Shopify changes on the Data Log, and the shared
        // container carries subscriber rows from other suites: the suite starts from a RowVersion-detecting state.
        DeleteSpfyDataLogSubscribers();
        // The activation gate now has a Shopify Integration precondition ahead of its own message.
        SetShopifyIntegrationFeatureEnabled(true);
        // ResetState does not clear item/customer links or assigned IDs, and the first test in this codeunit commits a
        // synced item link it never removes. The disable predicate reads exactly those tables, so without this every
        // later test inherits a non-pristine environment and fails on run order rather than on its own subject.
        NeutralizeSyncedArtifacts();
    end;

    // The cheapest artifact that proves the task list has already carried work.
    local procedure InsertSpfyTaskRow()
    var
        SpfyTask: Record "NPR Spfy Task";
    begin
        SpfyTask.Init();
        SpfyTask."Entry No." := 0;
        SpfyTask."Table No." := Database::Item;
        SpfyTask."Log Date" := CurrentDateTime();
        SpfyTask.Insert(true);
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

    local procedure RowVersionMigrationStatus(): Integer
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.Get();
        exit(ShopifySetup."RowVersion Migration Status");
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
        // The cutover executes at Migrating: at Completed the legacy send path counts as retired and the drain's task setup is never rebuilt.
        SetStatus(ShopifySetup."Task List Migration Status"::Migrating);
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

    local procedure LegacyQueueCount(TableNo: Integer): Integer
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.SetRange("Table No.", TableNo);
        exit(NcTask.Count());
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

    #region Activation
    [Test]
    procedure GivenExistingIntegration_WhenFeatureIsEnabledByAnAdministrator_ThenDirectedToTheMigrationAction()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        FeatureManagement: TestPage "NPR Feature Management";
        StoreCode: Code[20];
    begin
        // [SCENARIO] Turning the task list on before it has fully shipped is refused and leaves the feature off.
        Initialize();

        // [GIVEN] An environment that already synchronizes Shopify data.
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        Commit();

        // [WHEN] An administrator turns the task list on directly on the features page.
        OpenTaskListFeature(FeatureManagement);
        asserterror FeatureManagement.Enabled.SetValue(true);

        // [THEN] The enable is refused with a message pointing at the migration action, and the feature stays off.
        _Assert.ExpectedError(StrSubstNo(_ExistingIntegrationErr, FeatureDescription()));
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A refused activation must leave the feature off');
        _Assert.AreEqual(0, MigrationStatus(), 'A refused activation must not stamp a migration status');
    end;

    [Test]
    procedure GivenTaskListHasCarriedWork_WhenAnAdministratorTurnsItOff_ThenRefused()
    var
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] Turning the task list back off is refused once it has carried work, because the legacy queue no longer covers that work.
        Initialize();
        _Lib.SetTaskListFeatureEnabled(true);
        // One task is enough: the adoption is no longer pristine.
        InsertSpfyTaskRow();
        // Committed on purpose: the refused change rolls the transaction back, and the given has to survive that.
        Commit();

        // [WHEN] An administrator turns the task list back off.
        OpenTaskListFeature(FeatureManagement);
        asserterror FeatureManagement.Enabled.SetValue(false);

        // [THEN] The switch is closed for good and the feature stays on.
        _Assert.ExpectedError(StrSubstNo(_CannotDisableErr, FeatureDescription()));
        _Assert.IsTrue(TaskListFeatureEnabled(), 'A refused deactivation must leave the feature on');
    end;

    [Test]
    procedure GivenPristineTaskListAdoption_WhenAnAdministratorTurnsItOff_ThenItIsOffAndTheLegacySenderIsBack()
    var
        JobQueueEntry: Record "Job Queue Entry";
        NcSetupMgt: Codeunit "NPR Nc Setup Mgt.";
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] A task list adoption that nothing has gone through yet can be undone, and the undo hands sending back to the legacy engine it displaced.
        Initialize();
        // [GIVEN] One enabled store, and a pristine adoption through the app's own enable, which stamps the migration Completed.
        _Lib.CreateStore(true, false, false, false, false);
        SpfyTaskListFeature.SetFeatureEnabled(true);
        _Assert.AreEqual(2, MigrationStatus(), 'The adoption must stamp the migration Completed');
        // No arrange assertion on the legacy sender: this fixture creates the store with a direct Insert, so no legacy
        // entry ever exists here and asserting it is empty would hold whether or not the suppression works. The
        // suppression has its own coverage in GivenMigrationStarted_WhenLegacyJobQueuesRefresh_ThenTheyAreNotRecreated.
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", NcSetupMgt.TaskListProcessingCodeunit());
        Commit();

        // [WHEN] An administrator turns it back off. The Modify - and the side effects - run when the page closes, not on SetValue.
        OpenTaskListFeature(FeatureManagement);
        FeatureManagement.Enabled.SetValue(false);
        FeatureManagement.Close();

        // [THEN] The feature is off and the stamp it wrote is rolled back, so the Setup page offers the migration again.
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A pristine adoption must be undoable');
        _Assert.AreEqual(0, MigrationStatus(), 'The disable must reset the migration status');
        // [THEN] The enabled store has a sender again. Without the re-arm it would have neither engine.
        _Assert.IsFalse(JobQueueEntry.IsEmpty(), 'The disable must re-arm the legacy sender for the enabled store');
    end;

    [Test]
    procedure GivenRowVersionOff_WhenTheTaskListIsEnabledFromThePage_ThenItIsRefused()
    var
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] The task list rides on RowVersion detection, so it cannot be switched on before RowVersion is - the same precondition the migration enforces.
        Initialize();
        // [GIVEN] An environment that does not detect Shopify changes with RowVersion.
        _Lib.SetFeatureEnabled(false);
        Commit();

        // [WHEN] An administrator ticks the task list on the page. [THEN] the enable is refused.
        OpenTaskListFeature(FeatureManagement);
        asserterror FeatureManagement.Enabled.SetValue(true);
        _Assert.ExpectedError('requires this environment to detect Shopify changes with RowVersion');
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A refused activation must leave the feature off');
    end;

    [Test]
    procedure GivenShopifyFeatureOff_WhenTheTaskListIsEnabledFromThePage_ThenItIsRefused()
    var
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] The task list is a Shopify feature: it cannot be switched on before the Shopify integration itself is.
        Initialize();
        // [GIVEN] The Shopify Integration feature off.
        SetShopifyIntegrationFeatureEnabled(false);
        Commit();

        // [WHEN] An administrator ticks the task list on the page. [THEN] the enable is refused.
        OpenTaskListFeature(FeatureManagement);
        asserterror FeatureManagement.Enabled.SetValue(true);
        _Assert.ExpectedError('before enabling');
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A refused activation must leave the feature off');
    end;

    [Test]
    procedure GivenFreshEnvironment_WhenShopifyFeatureIsEnabled_ThenNeitherSwitchIsAutoAdopted()
    var
        ShopifyFeature: Record "NPR Feature";
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        WasEnabled: Boolean;
    begin
        // [SCENARIO] Enabling the Shopify integration on a fresh environment adopts neither one-way switch and stamps neither migration, because adoption is operator-triggered.
        Initialize();
        NeutralizeSyncedArtifacts();
        // Both one-way switches start unadopted: the coordinator would adopt RowVersion first and the task list only after it completed.
        _Lib.SetFeatureEnabled(false);
        ShopifySetup.Get();
        ShopifySetup."RowVersion Migration Status" := ShopifySetup."RowVersion Migration Status"::NotStarted;
        ShopifySetup.Modify(false);
        ShopifyFeature.SetRange(Feature, Enum::"NPR Feature"::Shopify);
        _Assert.IsTrue(ShopifyFeature.FindFirst(), 'The Shopify feature row must exist');
        WasEnabled := ShopifyFeature.Enabled;
        ShopifyFeature.Enabled := false;
        ShopifyFeature.Modify(false);

        // [WHEN] The Shopify integration feature is turned on, which is the entry point a fresh environment would adopt from.
        ShopifyFeature.Validate(Enabled, true);
        ShopifyFeature.Modify(true);

        // [THEN] The environment stays on the legacy queue: RowVersion detection is left off and unmigrated.
        _Assert.IsFalse(SpfyRowVersionFeature.IsFeatureEnabled(), 'Enabling the Shopify feature must not auto-adopt RowVersion detection');
        _Assert.IsTrue(RowVersionMigrationStatus() = ShopifySetup."RowVersion Migration Status"::NotStarted, StrSubstNo('A suspended auto-adoption must leave the RowVersion migration unstarted but the status was %1', RowVersionMigrationStatus()));

        // [THEN] The task list is left to the operator-run migration, with nothing stamped on its behalf.
        _Assert.IsFalse(TaskListFeatureEnabled(), 'Enabling the Shopify feature must not auto-adopt the task list');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::NotStarted, StrSubstNo('A suspended auto-adoption must leave the task list migration unstarted but the status was %1', MigrationStatus()));

        ShopifyFeature.Get(ShopifyFeature.Id);
        ShopifyFeature.Enabled := WasEnabled;
        ShopifyFeature.Modify(false);
        _Lib.DeleteDetectionJobQueueEntries();
        _Lib.SetTaskListFeatureEnabled(false);
    end;

    [Test]
    procedure GivenCompletedRowVersionMigration_WhenAnIntegrationAreaIsEnabled_ThenTaskListIsNotAutoAdopted()
    var
        Item: Record Item;
        ShopifySetup: Record "NPR Spfy Integration Setup";
        ShopifyStore: Record "NPR Spfy Store";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
        StoreCode: Code[20];
        WasEnabled: Boolean;
    begin
        // [SCENARIO] An environment that has completed the RowVersion migration on its own does not pick up the task list when a further integration area is switched on.
        Initialize();
        NeutralizeSyncedArtifacts();

        // [GIVEN] A completed RowVersion migration, the Shopify integration on, and a task list that is still off and still a fresh candidate.
        WasEnabled := SetShopifyIntegrationFeatureEnabled(true);
        _Lib.SetFeatureEnabled(true);
        ShopifySetup.Get();
        ShopifySetup."RowVersion Migration Status" := ShopifySetup."RowVersion Migration Status"::Completed;
        ShopifySetup.Modify(false);
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Assert.IsFalse(TaskListFeatureEnabled(), 'The task list must start off');
        _Assert.IsTrue(SpfyTaskListFeature.IsFreshTaskListCandidate(), 'The environment must still qualify as a fresh task list candidate, or the decline proves nothing');

        // [WHEN] A further integration area is switched on for the store, and a synced item changes afterwards.
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Validate("Retail Voucher Integration", true);
        ShopifyStore.Modify(true);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);
        _Lib.DispatchModify(SpfyStoreItemLink);

        // [THEN] A completed RowVersion migration does not carry the task list into adoption.
        _Assert.IsFalse(SpfyTaskListFeature.IsFeatureEnabled(), 'Enabling an integration area after the RowVersion migration must not auto-adopt the task list');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::NotStarted, StrSubstNo('A declined adoption must leave the task list migration unstarted but the status was %1', MigrationStatus()));

        // [THEN] The NaviConnect send path is still the one that carries the change.
        _Assert.AreEqual(1, LegacyQueueCount(Database::Item), 'The change must still be sent over the NaviConnect queue');
        _Assert.AreEqual(0, NewQueueCount(), 'No change may reach the task list queue while the task list is unadopted');

        SetShopifyIntegrationFeatureEnabled(WasEnabled);
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenEveryAdoptionPreconditionMet_WhenTheCoordinatorRuns_ThenTheSuspendedSwitchDeclines()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
        WasEnabled: Boolean;
    begin
        // [SCENARIO] The suspended adoption switch declines even when every other precondition for a fresh-environment adoption is met, so restoring it cannot pass unnoticed.
        Initialize();
        NeutralizeSyncedArtifacts();

        // [GIVEN] The Shopify integration on, both one-way switches off, neither migration started and both freshness tests satisfied.
        WasEnabled := SetShopifyIntegrationFeatureEnabled(true);
        _Lib.SetFeatureEnabled(false);
        ShopifySetup.Get();
        ShopifySetup."RowVersion Migration Status" := ShopifySetup."RowVersion Migration Status"::NotStarted;
        ShopifySetup.Modify(false);
        _Assert.IsTrue(SpfyRowVersionFeature.IsFreshRowVersionCandidate(''), 'The environment must qualify as a fresh RowVersion candidate');
        _Assert.IsTrue(SpfyTaskListFeature.IsFreshTaskListCandidate(), 'The environment must qualify as a fresh task list candidate');

        // [WHEN] The shared adoption coordinator runs on it.
        SpfyTaskListFeature.MaybeAutoAdoptFreshEnvironment('');

        // [THEN] Nothing is adopted: the go-live switch is the only thing standing between this environment and both migrations.
        _Assert.IsFalse(SpfyRowVersionFeature.IsFeatureEnabled(), 'The suspended coordinator must not adopt RowVersion detection');
        _Assert.IsFalse(SpfyTaskListFeature.IsFeatureEnabled(), 'The suspended coordinator must not adopt the task list');
        _Assert.IsTrue(RowVersionMigrationStatus() = ShopifySetup."RowVersion Migration Status"::NotStarted, StrSubstNo('The suspended coordinator must leave the RowVersion migration unstarted but the status was %1', RowVersionMigrationStatus()));
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::NotStarted, StrSubstNo('The suspended coordinator must leave the task list migration unstarted but the status was %1', MigrationStatus()));

        SetShopifyIntegrationFeatureEnabled(WasEnabled);
    end;

    // Raw write: the enable subscriber routes into the adoption coordinator, and these tests own when that runs.
    local procedure SetShopifyIntegrationFeatureEnabled(NewEnabled: Boolean) WasEnabled: Boolean
    var
        ShopifyFeature: Record "NPR Feature";
    begin
        ShopifyFeature.SetRange(Feature, Enum::"NPR Feature"::Shopify);
        _Assert.IsTrue(ShopifyFeature.FindFirst(), 'The Shopify feature row must exist');
        WasEnabled := ShopifyFeature.Enabled;
        if WasEnabled = NewEnabled then
            exit;
        ShopifyFeature.Enabled := NewEnabled;
        ShopifyFeature.Modify(false);
    end;

    local procedure NeutralizeSyncedArtifacts()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyAssignedID: Record "NPR Spfy Assigned ID";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        // The shared container carries synced leftovers from other suites; per-codeunit isolation rolls these writes back.
        // Any other enabled store disqualifies the RowVersion freshness test the adoption now also has to pass.
        ShopifyStore.SetRange(Enabled, true);
        if not ShopifyStore.IsEmpty() then
            ShopifyStore.ModifyAll(Enabled, false, false);
        if not SpfyAssignedID.IsEmpty() then
            SpfyAssignedID.DeleteAll(false);
        SpfyStoreItemLink.SetRange("Synchronization Is Enabled", true);
        if not SpfyStoreItemLink.IsEmpty() then
            SpfyStoreItemLink.ModifyAll("Synchronization Is Enabled", false, false);
        SpfyStoreCustomerLink.SetRange("Synchronization Is Enabled", true);
        if not SpfyStoreCustomerLink.IsEmpty() then
            SpfyStoreCustomerLink.ModifyAll("Synchronization Is Enabled", false, false);
        DeleteSpfyDataLogSubscribers();
    end;

    local procedure InsertSpfyDataLogSubscriber(TableNo: Integer)
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        DataLogSubscriber.Init();
        DataLogSubscriber.Code := SpfyIntegrationMgt.DataProcessingHandlerID(true);
        DataLogSubscriber."Table ID" := TableNo;
        DataLogSubscriber."Company Name" := '';
        DataLogSubscriber.Insert(false);
    end;

    local procedure DeleteSpfyDataLogSubscribers()
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        DataLogSubscriber.SetRange(Code, SpfyIntegrationMgt.DataProcessingHandlerID(false));
        if not DataLogSubscriber.IsEmpty() then
            DataLogSubscriber.DeleteAll(false);
    end;
    #endregion

    #region Migration prerequisites
    [Test]
    procedure GivenShopifyStillDetectingOnTheDataLog_WhenMigrationRuns_ThenRefusedBeforeAnyStateChange()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        ErrorText: Text;
        RunId: Guid;
    begin
        // [SCENARIO] A migration on an environment that still detects Shopify changes on the Data Log is refused before it changes any state.
        Initialize();

        // [GIVEN] An environment whose Shopify change detection still runs on the Data Log, with its legacy processing registered.
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        InsertSpfyDataLogSubscriber(Database::Item);
        SeedShopifyTaskSetupEntry(Database::Item);
        SeedLegacyProcessingJobQueue(StoreCode);
        Commit();

        // [WHEN] An administrator starts the migration from the setup page.
        asserterror SpfyTaskListMigration.MigrateAndEnable();

        // [THEN] It is refused before the run-mode prompt, and the message sends the administrator to the RowVersion migration first.
        _Assert.ExpectedError(_RowVersionMigrationActionTok);
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A refused migration must leave the feature off');
        _Assert.AreEqual(0, MigrationStatus(), 'A refused migration must not stamp a migration status');

        // [WHEN] A background entry that owns the run reaches the cutover instead.
        RunId := CreateGuid();
        StampMigrationRunId(RunId);
        _Assert.IsFalse(RunMigrationInBackgroundWithParameter(SpfyTaskListMigration.RunParameterString(RunId, false), ErrorText), 'A Data-Log environment must not be allowed to cut over in the background either');

        // [THEN] The refusal is trapped inside the cutover, so the run is recorded as failed instead of wedging the entry.
        _Assert.IsTrue(StrPos(ErrorText, _RowVersionMigrationActionTok) > 0, StrSubstNo('The refusal must direct the administrator to the RowVersion migration: %1', ErrorText));
        SelectLatestVersion();
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Failed, StrSubstNo('A cutover refused by its prerequisites must be recorded as failed but the status was %1', MigrationStatus()));

        // [THEN] Failed means the legacy path is intact: the feature is left off and nothing was deregistered.
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A failed cutover must leave the task list feature off');
        _Assert.IsTrue(ShopifyTaskProcessorExists(), 'A failed cutover must leave the legacy Shopify task processor registered');
        _Assert.AreEqual(1, ShopifyTaskSetupCount(), 'A failed cutover must leave the legacy Shopify send registration in place');
        _Assert.AreEqual(1, LegacyProcessingJobQueueCount(StoreCode), 'A failed cutover must leave the legacy Shopify processing job in place');
        RemoveLegacyProcessingJobQueues(StoreCode);
        ClearShopifyTaskSetup();
        DeleteSpfyDataLogSubscribers();
        // The background leg commits its Failed status, so the cleanup has to be committed too or it leaks into every later test.
        SetStatus(ShopifySetup."Task List Migration Status"::NotStarted);
        Commit();
    end;

    [Test]
    procedure GivenRowVersionDetectionNotEnabled_WhenMigrationRuns_ThenRefusedBeforeAnyStateChange()
    var
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
    begin
        // [SCENARIO] Starting the migration from the setup page is refused before any prompt, leaving the feature off and no migration status stamped.
        Initialize();

        // [GIVEN] An environment where nothing detects Shopify changes: the RowVersion feature is off and no Data Log wiring is left.
        DeleteSpfyDataLogSubscribers();
        _Lib.SetFeatureEnabled(false);

        // [WHEN] An administrator starts the migration from the setup page.
        asserterror SpfyTaskListMigration.MigrateAndEnable();

        // [THEN] The half-state is refused too, and the administrator is sent to the RowVersion migration that repairs it.
        _Assert.ExpectedError(_RowVersionMigrationActionTok);
        _Assert.IsFalse(TaskListFeatureEnabled(), 'A refused migration must leave the feature off');
        _Assert.AreEqual(0, MigrationStatus(), 'A refused migration must not stamp a migration status');
        _Lib.SetFeatureEnabled(true);
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

    [Test]
    [HandlerFunctions('BackgroundRunModeStrMenuHandler')]
    procedure GivenTaskSchedulingUnavailable_WhenTheBackgroundMigrationIsStarted_ThenTheLeaseIsReleasedForTheNextAttempt()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
    begin
        // [SCENARIO] A background migration that could not be scheduled at all releases its lease, so a run that never started cannot block the next attempt.
        Initialize();
        DeleteMigrationJobQueueEntries();

        // [GIVEN] A run resuming past the legacy hand-over whose holder has been gone for longer than an hour.
        MarkStatus(ShopifySetup."Task List Migration Status"::Finalizing, CurrentDateTime() - 90 * 60 * 1000);

        // [GIVEN] An environment whose background entry is created but cannot be started, and is left manually on hold.
        _BndMock.SetParkMigrationEntry(true);

        // [WHEN] An administrator starts the migration in the background.
        asserterror SpfyTaskListMigration.MigrateAndEnable();

        // [THEN] The refusal surfaces instead of reporting a migration that never started.
        _Assert.ExpectedError(_CouldNotScheduleErr);

        SelectLatestVersion();
        ShopifySetup.Get();
        // [THEN] The lease taken moments earlier is released, because nothing is running to hold it.
        _Assert.AreEqual(0DT, ShopifySetup."Task List Migr. Started At", 'A migration that never started must not leave a live heartbeat behind');
        _Assert.IsTrue(ShopifySetup."Task List Migration Status" = ShopifySetup."Task List Migration Status"::Finalizing, StrSubstNo('A scheduling refusal must leave the status as it found it but it was %1', ShopifySetup."Task List Migration Status"));
        _Assert.AreEqual(0, MigrationJobQueueEntryCount(), 'A migration that never started must leave no background entry behind');

        // [THEN] The next attempt is admitted at once rather than waiting an hour for the lease to go stale.
        // Direct call: LOCKTABLE is forbidden inside a [TryFunction] under the test runner, so a raised error fails the test naturally.
        SpfyTaskListMigration.AcquireLock(ShopifySetup);
        ResetCommittedMigrationState();
    end;

    [Test]
    [HandlerFunctions('BackgroundRunModeStrMenuHandler,BackgroundNeedsActivationHandler')]
    procedure GivenTheBackgroundEntryIsLeftOnHold_WhenTheBackgroundMigrationIsStarted_ThenTheLeaseIsReleasedForTheNextAttempt()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        ParkedRunId: Guid;
    begin
        // [SCENARIO] A background migration whose job queue entry is left on hold releases its lease and tells the operator the migration has not started.
        Initialize();
        DeleteMigrationJobQueueEntries();

        // [GIVEN] A run resuming past the legacy hand-over whose holder has been gone for longer than an hour.
        MarkStatus(ShopifySetup."Task List Migration Status"::Finalizing, CurrentDateTime() - 90 * 60 * 1000);

        // [GIVEN] A delegated administrator: the background entry is created and left parked rather than refused.
        _BndMock.SetParkMigrationEntry(false);

        // [WHEN] An administrator starts the migration in the background.
        SpfyTaskListMigration.MigrateAndEnable();

        SelectLatestVersion();
        ShopifySetup.Get();
        // [THEN] Nothing is running, so the heartbeat must not hold the environment against the next attempt.
        _Assert.AreEqual(0DT, ShopifySetup."Task List Migr. Started At", 'A parked background entry must not leave a live heartbeat behind');
        _Assert.IsTrue(ShopifySetup."Task List Migration Status" = ShopifySetup."Task List Migration Status"::Finalizing, StrSubstNo('A parked background entry must leave the status as it found it but it was %1', ShopifySetup."Task List Migration Status"));

        // [THEN] The parked entry is kept: it is what an administrator sets to Ready, and the next run cancels it first.
        _Assert.AreEqual(1, MigrationJobQueueEntryCount(), 'The parked background entry must be left for an administrator to start');

        // [THEN] It carries the run id of the lease that dispatched it, so the run an administrator starts later can
        // still prove it owns the cutover instead of standing down as a hand-made entry.
        ParkedRunId := ShopifySetup."Task List Migration Run ID";
        _Assert.IsFalse(IsNullGuid(ParkedRunId), 'The dispatching run must have stamped a run id to hand over');
        _Assert.AreEqual(SpfyTaskListMigration.RunParameterString(ParkedRunId, false), MigrationJobQueueEntryParameterString(), 'The parked background entry must carry the run id and override decision of the run that dispatched it');

        // [THEN] The next attempt is admitted at once rather than waiting an hour for the lease to go stale.
        // Direct call: LOCKTABLE is forbidden inside a [TryFunction] under the test runner, so a raised error fails the test naturally.
        SpfyTaskListMigration.AcquireLock(ShopifySetup);
        ResetCommittedMigrationState();
    end;

    [MessageHandler]
    procedure BackgroundNeedsActivationHandler(Message: Text[1024])
    begin
        _Assert.IsTrue(StrPos(Message, _NeedsActivationTok) > 0, StrSubstNo('The operator must be told the migration has not started: %1', Message));
    end;

    [StrMenuHandler]
    procedure BackgroundRunModeStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        _Assert.AreEqual(_RunModeOptionsTok, Options, 'The migration must offer exactly the foreground and background run modes');
        _Assert.AreNotEqual('', Instruction, 'The run mode prompt must explain the choice');
        Choice := 2;
    end;

    local procedure MarkStatus(NewStatus: Option; StartedAt: DateTime)
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.Get();
        ShopifySetup."Task List Migration Status" := NewStatus;
        ShopifySetup."Task List Migr. Started At" := StartedAt;
        ShopifySetup.Modify(false);
        Commit();
    end;

    local procedure MigrationJobQueueEntryCount(): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        FilterMigrationJobQueueEntries(JobQueueEntry);
        exit(JobQueueEntry.Count());
    end;

    local procedure MigrationJobQueueEntryParameterString(): Text
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        FilterMigrationJobQueueEntries(JobQueueEntry);
        if not JobQueueEntry.FindFirst() then
            exit('<no migration entry>');
        exit(JobQueueEntry."Parameter String");
    end;

    local procedure DeleteMigrationJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        FilterMigrationJobQueueEntries(JobQueueEntry);
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(false);
    end;

    local procedure FilterMigrationJobQueueEntries(var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Task List Migration");
    end;

    // These tests commit the state the migration commits, so the reset has to be committed too or it leaks into every later test.
    local procedure ResetCommittedMigrationState()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        _Lib.SetTaskListFeatureEnabled(false);
        ShopifySetup.Get();
        Clear(ShopifySetup."Task List Migration Run ID");
        ShopifySetup.Modify(false);
        Commit();
        _Lib.DeleteDetectionJobQueueEntries();
        DeleteMigrationJobQueueEntries();
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

    [Test]
    procedure GivenFutureScheduledPriceNcTask_WhenRecreated_ThenScheduleAndKindKept()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        ItemPrice: Record "NPR Spfy Item Price";
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        StoreCode: Code[20];
        NotBeforeDateTime: DateTime;
        LegacyEntryNo: BigInteger;
        NewEntryNo: BigInteger;
    begin
        // [SCENARIO] A legacy price task that only starts next month is handed over as a new-queue twin keeping its kind, source row and start time, closes the legacy row with a reference to its successor, and is not duplicated by a re-run.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, true, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);

        // [GIVEN] A legacy price task that only starts next month.
        _Lib.CreateItemPrice(ItemPrice, Item."No.", StoreCode, 100, CalcDate('<+1M>', Today()));
        NotBeforeDateTime := CreateDateTime(ItemPrice."Starting Date", 0T);
        LegacyEntryNo := SeedLegacyPriceTask(StoreCode, ItemPrice, NotBeforeDateTime);

        // [WHEN] The cutover hands the still-scheduled price row over to the new queue.
        NewEntryNo := RecreateLegacyTask(LegacyEntryNo);

        // [THEN] The twin keeps the price kind and its start time, and points back at the row it replaced.
        _Assert.IsTrue(NewEntryNo <> 0, 'The hand-over must create a new-queue task');
        _Assert.IsTrue(SpfyTask.Get(NewEntryNo), 'The new-queue twin must exist');
        _Assert.IsTrue(SpfyTask.Type = SpfyTask.Type::Modify, 'The twin must keep the legacy op');
        _Assert.AreEqual(Database::"NPR Spfy Item Price", SpfyTask."Table No.", 'The twin must keep the price table');
        _Assert.AreEqual(ItemPrice.RecordId(), SpfyTask."Record ID", 'The twin must keep the source record id');
        _Assert.AreEqual(Item."No.", SpfyTask."Record Value", 'The twin must keep the record value');
        _Assert.AreEqual(StoreCode, SpfyTask."Store Code", 'The twin must keep the store');
        _Assert.AreEqual(NotBeforeDateTime, SpfyTask."Not Before Date-Time", 'The twin must keep the price start time');
        _Assert.IsTrue(SpfyTask.State = SpfyTask.State::Pending, 'The twin must be waiting to be sent');
        _Assert.AreEqual(0, SpfyTask.Attempts, 'The twin must start with no attempts');
        _Assert.IsTrue(SpfyTask."Migrated From NC Entry No." = LegacyEntryNo, 'The twin must reference the legacy row it came from');

        // [THEN] The legacy row is closed with a reference to its successor.
        NcTask.Get(LegacyEntryNo);
        _Assert.IsTrue(NcTask.Processed, 'The migrated legacy row must be closed');
        _Assert.IsTrue(StrPos(LegacyResponseText(LegacyEntryNo), Format(NewEntryNo)) > 0, StrSubstNo('The legacy row must name its successor: %1', LegacyResponseText(LegacyEntryNo)));

        // [WHEN] The migration is re-run over the same legacy row. [THEN] nothing is duplicated.
        _Assert.IsTrue(RecreateLegacyTask(LegacyEntryNo) = 0, 'A closed legacy price row must not be handed over again');
        _Assert.AreEqual(1, NewQueueCount(), 'A re-run must not duplicate the new-queue price task');
    end;

    local procedure SeedLegacyPriceTask(StoreCode: Code[20]; ItemPrice: Record "NPR Spfy Item Price"; NotBeforeDateTime: DateTime): BigInteger
    var
        NcTask: Record "NPR Nc Task";
    begin
        NcTask.Init();
        NcTask."Entry No." := 0;
        NcTask."Task Processor Code" := ShopifyTaskProcessorCode();
        NcTask.Type := NcTask.Type::Modify;
        NcTask."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(NcTask."Company Name"));
        NcTask."Table No." := Database::"NPR Spfy Item Price";
        NcTask."Record ID" := ItemPrice.RecordId();
        NcTask."Record Value" := ItemPrice."Item No.";
        NcTask."Store Code" := StoreCode;
        NcTask."Not Before Date-Time" := NotBeforeDateTime;
        NcTask."Log Date" := CurrentDateTime();
        NcTask.Insert(true);
        exit(NcTask."Entry No.");
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

    [Test]
    procedure GivenACompletedMigrationWhoseProcessorIsOnHold_WhenTheSetupWarningIsEvaluated_ThenTheParkedProcessingIsReported()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskJQSetup: Codeunit "NPR Spfy Task JQ Setup";
    begin
        // [SCENARIO] A migration that completed while its task processing job is parked reports a warning for the setup page, and stops reporting it once the job is started.
        Initialize();

        // [GIVEN] A task processing job queue entry left on hold while the migration is still under way.
        ParkTaskProcessorJobQueueEntry(_ParkedStoreTok);
        SetStatus(ShopifySetup."Task List Migration Status"::Migrating);

        // [THEN] Nothing is reported yet: until the migration has completed it owns its own reporting.
        _Assert.AreEqual('', SpfyTaskJQSetup.ProcessorOnHoldWarning(), 'A migration that has not completed must not raise the parked-processor warning');

        // [WHEN] The migration completes with the job still parked.
        SetStatus(ShopifySetup."Task List Migration Status"::Completed);

        // [THEN] The warning is reported, and it tells the operator what to do about it.
        _Assert.AreNotEqual('', SpfyTaskJQSetup.ProcessorOnHoldWarning(), 'A completed migration whose processing job is parked must raise the warning');
        _Assert.IsTrue(StrPos(SpfyTaskJQSetup.ProcessorOnHoldWarning(), 'Ready on the Job Queue Entries page') > 0, 'The warning must tell the operator how to start the job');

        // [WHEN] An administrator starts the job.
        ReadyTaskProcessorJobQueueEntries();

        // [THEN] The warning stops, so it can never outlive the condition it reports.
        _Assert.AreEqual('', SpfyTaskJQSetup.ProcessorOnHoldWarning(), 'A started processing job must raise no warning');
    end;

    // A store code no cutover manages, so the entry survives the run and the warning is arranged
    // rather than inherited from whatever the test session's task-scheduler rights happen to be.
    local procedure ParkTaskProcessorJobQueueEntry(StoreCode: Code[20])
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR Spfy Task Processor";
        JobQueueEntry."Parameter String" := StoreCode;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR Manually Set On Hold" := true;
        JobQueueEntry.Insert(false);
    end;

    local procedure ReadyTaskProcessorJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Task Processor");
        if JobQueueEntry.FindSet() then
            repeat
                JobQueueEntry.Status := JobQueueEntry.Status::Ready;
                JobQueueEntry.Modify(false);
            until JobQueueEntry.Next() = 0;
    end;

    [MessageHandler]
    procedure ProcessorOnHoldMessageHandler(Message: Text[1024])
    begin
        _Assert.IsTrue(StrPos(Message, _ProcessorOnHoldTok) > 0, StrSubstNo('The only message a completed cutover may raise here is the parked-processor warning: %1', Message));
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
    [HandlerFunctions('ProcessorOnHoldMessageHandler')]
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

        // [THEN] The declined activation is not reported as success, and because the legacy hand-over is already done the run stays Finalizing rather than claiming the legacy path is back.
        SelectLatestVersion();
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Finalizing, StrSubstNo('A job queue activation declined after the legacy hand-over must leave the migration Finalizing but it was %1', MigrationStatus()));

        // [WHEN] The held job is released and the migration is run again, with a processor for another store left parked.
        _Lib.DeleteDetectionJobQueueEntries();
        ParkTaskProcessorJobQueueEntry(_ParkedStoreTok);
        Commit();
        SpfyTaskListMigration.RunCutoverIsolated();

        // [THEN] The re-run resumes from Finalizing and finishes, so a failure past the hand-over stays recoverable.
        SelectLatestVersion();
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A re-run after a failure past the hand-over must complete the migration but the status was %1', MigrationStatus()));
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

    #region Legacy processing deregistration
    [Test]
    procedure GivenLegacyShopifyRegistration_WhenCutoverRuns_ThenItIsRemovedAndTheHandlerIdIsKept()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        HandlerIdBefore: Code[20];
    begin
        // [SCENARIO] The cutover removes the legacy Shopify registration while keeping its handler id.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A registered Shopify legacy processor with its send registrations, a legacy job, and a drainable task.
        SeedSettlingLegacyVariantTask(StoreCode);
        SeedShopifyTaskSetupEntry(Database::Item);
        SeedLegacyProcessingJobQueue(StoreCode);
        HandlerIdBefore := ShopifyDataProcessingHandlerId();
        _Assert.AreNotEqual('', HandlerIdBefore, 'The environment must have a Shopify data processing handler before the cutover');
        _Assert.IsTrue(ShopifyTaskProcessorExists(), 'The Shopify legacy task processor must exist before the cutover');
        // The task-setup insert re-registers a Data Log subscriber for the handler, which the cutover's prerequisite reads as "still detecting on the Data Log".
        DeleteSpfyDataLogSubscribers();
        ArmCutover(ShopifySetup);

        // [WHEN] The cutover runs.
        SpfyTaskListMigration.RunEnvironmentCutover(ShopifySetup);

        // [THEN] The environment's Shopify legacy processing registration is gone, so no legacy Shopify send can run again.
        _Assert.AreEqual(0, AllShopifyTaskSetupCount(), 'The cutover must delete every Shopify legacy send registration');
        _Assert.IsFalse(ShopifyTaskProcessorExists(), 'The cutover must delete the Shopify legacy task processor');
        _Assert.AreEqual(0, LegacyProcessingJobQueueCount(StoreCode), 'The cutover must leave no legacy Shopify processing job behind');

        // [THEN] The handler id itself is kept: the residual watch and the fresh-environment check still resolve it.
        _Assert.AreEqual(HandlerIdBefore, ShopifyDataProcessingHandlerId(), 'The cutover must not clear the Shopify data processing handler id');

        // [THEN] Only then does the new queue start processing, and the migration is complete.
        _Assert.AreEqual(1, TaskProcessingJobQueueCount(StoreCode), 'The cutover must schedule the new queue processor for the store');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A deregistered environment must complete the migration but the status was %1', MigrationStatus()));
        RemoveLegacyProcessingJobQueues(StoreCode);
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenAShopifyDataLogSubscription_WhenCutoverRunsPastThePrerequisite_ThenTheSubscriptionIsRemoved()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A cutover that gets past its prerequisite removes the Shopify Data Log subscription rows.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A registered Shopify legacy processor with its send registration.
        SeedShopifyTaskSetupEntry(Database::Item);
        DeleteSpfyDataLogSubscribers();

        // [GIVEN] A run resuming past the legacy hand-over, which is where the Data Log prerequisite is asked, so the
        // cutover reaches the deregistration with the subscription still in place.
        _Lib.SetTaskListFeatureEnabled(true);
        MarkStatus(ShopifySetup."Task List Migration Status"::Finalizing, CurrentDateTime());
        SelectLatestVersion();
        ShopifySetup.Get();
        InsertSpfyDataLogSubscriber(Database::Item);
        Commit();
        _Assert.AreEqual(1, SpfyDataLogSubscriberCount(), 'The environment must still detect Shopify changes on the Data Log before the cutover');

        // [WHEN] The cutover runs.
        SpfyTaskListMigration.RunEnvironmentCutover(ShopifySetup);

        // [THEN] The Shopify Data Log subscription is gone: the pump that fills the legacy queue must not outlive the
        // processing job that drains it, or every logged change would pile up unsent.
        _Assert.AreEqual(0, SpfyDataLogSubscriberCount(), 'The cutover must remove every Shopify Data Log subscription');
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('A deregistered environment must complete the migration but the status was %1', MigrationStatus()));
        RemoveLegacyProcessingJobQueues(StoreCode);
        ClearShopifyTaskSetup();
        DeleteSpfyDataLogSubscribers();
        _Lib.DeleteDetectionJobQueueEntries();
        ResetCommittedMigrationState();
    end;

    local procedure SpfyDataLogSubscriberCount(): Integer
    var
        DataLogSubscriber: Record "NPR Data Log Subscriber";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        DataLogSubscriber.SetRange(Code, SpfyIntegrationMgt.DataProcessingHandlerID(false));
        exit(DataLogSubscriber.Count());
    end;

    [Test]
    procedure GivenActionableStragglerAfterDeregistration_WhenTheReverifyPassRuns_ThenItIsRecreatedAndTheDeadRemainderIsLeft()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        NcTask: Record "NPR Nc Task";
        StragglerTask: Record "NPR Nc Task";
        DeadTask: Record "NPR Nc Task";
        RenameTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        StragglerEntryNo: BigInteger;
        DeadEntryNo: BigInteger;
        RenameEntryNo: BigInteger;
    begin
        // [SCENARIO] The re-verify pass recreates a still-actionable legacy straggler in the new queue and leaves an exhausted one alone.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        _Lib.CreateSyncedItemWithLink(Item, SpfyStoreItemLink, StoreCode);

        // [GIVEN] A legacy row that committed after the drain had already verified the queue, plus rows the verify must ignore.
        StragglerEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime());
        DeadEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Modify, 0DT, CurrentDateTime());
        ExhaustLegacyTask(DeadEntryNo);
        RenameEntryNo := SeedLegacyTask(StoreCode, Item, NcTask.Type::Rename, 0DT, CurrentDateTime());

        // [WHEN] The migration re-verifies after removing the legacy processing registration.
        SpfyTaskListMigration.ReverifyAndResolveStragglers();

        // [THEN] The straggler is rescued into the new queue rather than left stranded with no legacy job to drain it.
        SpfyTask.SetRange("Migrated From NC Entry No.", StragglerEntryNo);
        _Assert.AreEqual(1, SpfyTask.Count(), 'An actionable straggler must be re-created in the new queue');
        LegacyTask(StragglerEntryNo, StragglerTask);
        _Assert.IsTrue(StragglerTask.Processed, 'The rescued straggler must be closed');

        // [THEN] The reported dead remainder is exempt, and a rename still has no counterpart to be re-created into.
        LegacyTask(DeadEntryNo, DeadTask);
        _Assert.IsFalse(DeadTask.Processed, 'An exhausted legacy row must be left exactly as it was found');
        SpfyTask.SetRange("Migrated From NC Entry No.", DeadEntryNo);
        _Assert.AreEqual(0, SpfyTask.Count(), 'An exhausted legacy row must not be re-created in the new queue');
        LegacyTask(RenameEntryNo, RenameTask);
        _Assert.IsFalse(RenameTask.Processed, 'A rename must be left untouched by the re-verify pass');
        SpfyTask.SetRange("Migrated From NC Entry No.", RenameEntryNo);
        _Assert.AreEqual(0, SpfyTask.Count(), 'A rename must not be re-created in the new queue');
    end;

    [Test]
    procedure GivenMigrationFailed_WhenLegacyTaskIsProcessed_ThenTaskSetupIsRecreated()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        StoreCode: Code[20];
        FailedEntryNo: BigInteger;
    begin
        // [SCENARIO] A failed migration leaves the legacy path running: processing a legacy task recreates its task setup.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        FailedEntryNo := SeedBurningLegacyItemTask(StoreCode);
        ClearShopifyTaskSetup();

        // [WHEN] An operator manually processes a legacy row while a crashed migration sits at Failed.
        SetStatus(ShopifySetup."Task List Migration Status"::Failed);
        ProcessLegacyTask(FailedEntryNo);

        // [THEN] Failed means the cutover stopped before the hand-over, so the legacy send path is intact and rebuilt on demand.
        _Assert.AreEqual(1, ShopifyTaskSetupCount(), 'A failed migration must leave the legacy send path usable, so processing a legacy row rebuilds its task setup');
        ClearShopifyTaskSetup();
    end;

    local procedure SeedShopifyTaskSetupEntry(TableNo: Integer)
    begin
        SeedShopifyTaskSetupEntry(TableNo, Codeunit::"NPR Spfy Send Items&Inventory");
    end;

    local procedure SeedShopifyTaskSetupEntry(TableNo: Integer; SendCodeunitId: Integer)
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
    begin
        NcTaskSetup.SetRange("Task Processor Code", ShopifyTaskProcessorCode());
        NcTaskSetup.SetRange("Table No.", TableNo);
        if not NcTaskSetup.IsEmpty() then
            exit;
        NcTaskSetup.Init();
        NcTaskSetup."Entry No." := 0;
        NcTaskSetup."Task Processor Code" := ShopifyTaskProcessorCode();
        NcTaskSetup."Table No." := TableNo;
        NcTaskSetup."Codeunit ID" := SendCodeunitId;
        NcTaskSetup.Insert(true);
    end;

    local procedure AllShopifyTaskSetupCount(): Integer
    var
        NcTaskSetup: Record "NPR Nc Task Setup";
    begin
        NcTaskSetup.SetRange("Task Processor Code", ShopifyDataProcessingHandlerId());
        exit(NcTaskSetup.Count());
    end;

    local procedure ShopifyTaskProcessorExists(): Boolean
    var
        NcTaskProcessor: Record "NPR Nc Task Processor";
    begin
        exit(NcTaskProcessor.Get(ShopifyDataProcessingHandlerId()));
    end;

    // Read only: the auto-creating overload would put back the very processor row the deregistration deleted.
    local procedure ShopifyDataProcessingHandlerId(): Code[20]
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        exit(SpfyIntegrationMgt.DataProcessingHandlerID(false));
    end;
    #endregion

    #region Migration lease ownership
    [Test]
    procedure GivenAForeignRunIdAndAFreshLease_WhenTheBackgroundMigrationRuns_ThenItDoesNotCutOver()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        ErrorText: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A background run carrying another run's id stands down while that lease is still fresh, instead of cutting over beside it.
        Initialize();

        // [GIVEN] A live migration run owns the lease, and another entry that carries a run id of its own is dispatched.
        StampMigrationRunId(CreateGuid());
        MarkMigrating(CurrentDateTime());

        // [WHEN] That entry reaches the cutover.
        Succeeded := RunMigrationInBackgroundWithParameter(SpfyTaskListMigration.RunParameterString(CreateGuid(), false), ErrorText);

        // [THEN] It stands down quietly instead of failing, so the platform does not keep retrying a run it does not own.
        _Assert.IsTrue(Succeeded, StrSubstNo('An entry that does not own the lease must stand down without failing: %1', ErrorText));

        // [THEN] It leaves the live run's lease and the feature alone rather than cutting the environment over twice.
        SelectLatestVersion();
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Migrating, StrSubstNo('An entry that does not own the lease must leave it untouched but the status was %1', MigrationStatus()));
        _Assert.IsFalse(TaskListFeatureEnabled(), 'An entry that does not own the lease must not enable the feature');
    end;

    [Test]
    procedure GivenAnEntryWithoutARunId_WhenTheBackgroundMigrationRuns_ThenItDoesNotCutOver()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        ErrorText: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A hand-made background entry that carries no run id never cuts the environment over.
        Initialize();

        // [GIVEN] A live migration run owns the lease, and a hand-made entry carrying no run token at all is dispatched.
        StampMigrationRunId(CreateGuid());
        MarkMigrating(CurrentDateTime());

        // [WHEN] That entry reaches the cutover.
        Succeeded := RunMigrationInBackgroundWithParameter('', ErrorText);

        // [THEN] A tokenless entry can neither own nor adopt a run, so it stands down without failing the platform retry.
        _Assert.IsTrue(Succeeded, StrSubstNo('An entry carrying no run token must stand down without failing: %1', ErrorText));

        // [THEN] It leaves the live run's lease and the feature alone rather than cutting the environment over twice.
        SelectLatestVersion();
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Migrating, StrSubstNo('An entry carrying no run token must leave the lease untouched but the status was %1', MigrationStatus()));
        _Assert.IsFalse(TaskListFeatureEnabled(), 'An entry carrying no run token must not enable the feature');
    end;

    [Test]
    [HandlerFunctions('ProcessorOnHoldMessageHandler')]
    procedure GivenAForeignRunIdAndAStaleLease_WhenTheBackgroundMigrationRuns_ThenItAdoptsTheRunAndCompletes()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        ErrorText: Text;
    begin
        // [SCENARIO] A stale lease is adopted by the next background run and the migration completes, so a crashed run cannot block the environment for good.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);

        // [GIVEN] A lease whose holder has been gone for longer than an hour, stamped with a run id nobody carries, and a processor for another store left parked.
        StampMigrationRunId(CreateGuid());
        MarkMigrating(CurrentDateTime() - 90 * 60 * 1000);
        ParkTaskProcessorJobQueueEntry(_ParkedStoreTok);

        // [WHEN] A dispatched entry carrying a run id of its own, rather than the stamped one, reaches the cutover.
        _Assert.IsTrue(RunMigrationInBackgroundWithParameter(SpfyTaskListMigration.RunParameterString(CreateGuid(), false), ErrorText), StrSubstNo('A stale lease must be adopted rather than blocking the environment for good: %1', ErrorText));

        // [THEN] The run is adopted and carried through, so a crashed migration is never stuck at Migrating.
        SelectLatestVersion();
        _Assert.IsTrue(MigrationStatus() = ShopifySetup."Task List Migration Status"::Completed, StrSubstNo('An adopted stale run must complete the migration but the status was %1', MigrationStatus()));
        _Assert.IsTrue(TaskListFeatureEnabled(), 'An adopted stale run must enable the feature');
        _Assert.AreEqual(1, TaskProcessingJobQueueCount(StoreCode), 'An adopted stale run must schedule the new queue processor for the store');
        _Lib.DeleteDetectionJobQueueEntries();
    end;

    [Test]
    procedure GivenTheLeaseTakenOverMidCutover_WhenTheSupersededRunFails_ThenItLeavesTheEnvironmentUntouched()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        StoreCode: Code[20];
        ErrorText: Text;
        LeaseHolderRunId: Guid;
        SupersededRunId: Guid;
    begin
        // [SCENARIO] A run whose lease was taken over mid-cutover writes nothing when it fails, leaving the environment to the run that now holds it.
        Initialize();
        StoreCode := _Lib.CreateStore(true, false, false, false, false);
        LeaseHolderRunId := CreateGuid();
        SupersededRunId := CreateGuid();

        // [GIVEN] A legacy processing job for the store and a send registration this run may not remove, so the cutover
        // quiesces and cancels the legacy senders and only then fails, with the re-creation branch in reach.
        ClearShopifyTaskSetup();
        SeedShopifyTaskSetupEntry(Database::Item, Codeunit::"NPR Spfy Send Customers");
        DeleteSpfyDataLogSubscribers();
        SeedLegacyProcessingJobQueue(StoreCode);
        _Assert.AreEqual(1, LegacyProcessingJobQueueCount(StoreCode), 'The legacy processing job must exist before the cutover cancels it');

        // [GIVEN] A live migration that owns the lease when it starts.
        ArmCutover(ShopifySetup);
        StampMigrationRunId(SupersededRunId);

        // [GIVEN] Another run takes the lease over while the failing one is inside the hand-over.
        _BndMock.SetHandOverLeaseTakeover(LeaseHolderRunId);

        // [WHEN] The superseded run reaches its failure handler.
        _Assert.IsFalse(RunMigrationInBackgroundWithParameter(SpfyTaskListMigration.RunParameterString(SupersededRunId, false), ErrorText), 'A failing cutover must surface its error to the caller');
        _Assert.IsTrue(StrPos(ErrorText, _OverridesNotConfirmedTok) > 0, StrSubstNo('The unconfirmed custom send registration must be the error that surfaces: %1', ErrorText));

        SelectLatestVersion();
        ShopifySetup.Get();
        // [THEN] Only the run that owns the lease may write: no status, no heartbeat, no compensation, no sender re-creation.
        _Assert.IsTrue(ShopifySetup."Task List Migration Status" = ShopifySetup."Task List Migration Status"::Migrating, StrSubstNo('A superseded run must leave the owning run''s status alone but it was %1', ShopifySetup."Task List Migration Status"));
        _Assert.AreNotEqual(0DT, ShopifySetup."Task List Migr. Started At", 'A superseded run must leave the owning run''s heartbeat alone');
        _Assert.IsTrue(TaskListFeatureEnabled(), 'A superseded run must not switch the feature off under the run that owns the lease');
        _Assert.AreEqual(0, LegacyProcessingJobQueueCount(StoreCode), 'A superseded run must leave the legacy processing jobs it cancelled cancelled');

        // [THEN] The lease belongs to the run that took it, which is what made the failing run a non-owner.
        _Assert.AreEqual(LeaseHolderRunId, ShopifySetup."Task List Migration Run ID", 'The take-over must leave the lease with the run that claimed it');
        RemoveLegacyProcessingJobQueues(StoreCode);
        ClearShopifyTaskSetup();
        DeleteSpfyDataLogSubscribers();
        ResetCommittedMigrationState();
    end;

    [Test]
    [HandlerFunctions('BackgroundRunModeStrMenuHandler')]
    procedure GivenTheLeaseTakenOverBeforeScheduling_WhenTheBackgroundStartFails_ThenTheNewHolderIsLeftAlone()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        LeaseHolderRunId: Guid;
    begin
        // [SCENARIO] A run that lost its lease before scheduling leaves the new holder's state alone when its own start then fails.
        Initialize();
        DeleteMigrationJobQueueEntries();
        LeaseHolderRunId := CreateGuid();

        // [GIVEN] A second administrator takes the lease over and leaves a background entry of their own behind while
        // the first run is still scheduling, and the first run's own scheduling then fails.
        _BndMock.SetSchedulingLeaseTakeover(LeaseHolderRunId);
        _BndMock.SetParkMigrationEntry(true);

        // [WHEN] The first run reaches its scheduling-failure branch.
        asserterror SpfyTaskListMigration.MigrateAndEnable();

        // [THEN] The refusal surfaces instead of reporting a migration that never started.
        _Assert.ExpectedError(_CouldNotScheduleErr);

        SelectLatestVersion();
        ShopifySetup.Get();
        // [THEN] A run whose lease was taken cancels and clears nothing: the new holder's lease, heartbeat and entry stand.
        _Assert.AreEqual(LeaseHolderRunId, ShopifySetup."Task List Migration Run ID", 'A superseded run must leave the lease with the run that claimed it');
        _Assert.AreNotEqual(0DT, ShopifySetup."Task List Migr. Started At", 'A superseded run must not clear the new lease holder''s heartbeat');
        _Assert.AreEqual(1, MigrationJobQueueEntryCount(), 'A superseded run must not cancel the new lease holder''s pending entry');
        ResetCommittedMigrationState();
    end;

    local procedure StampMigrationRunId(RunId: Guid)
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        ShopifySetup.Get();
        ShopifySetup."Task List Migration Run ID" := RunId;
        ShopifySetup.Modify(false);
        Commit();
    end;

    local procedure RunMigrationInBackgroundWithParameter(ParameterString: Text; var ErrorText: Text) Succeeded: Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Clear(ErrorText);
        // The migration commits as it goes, which a savepoint from the fixture writes would otherwise invalidate.
        Commit();
        JobQueueEntry."Parameter String" := CopyStr(ParameterString, 1, MaxStrLen(JobQueueEntry."Parameter String"));
        Succeeded := Codeunit.Run(Codeunit::"NPR Spfy Task List Migration", JobQueueEntry);
        if not Succeeded then
            ErrorText := GetLastErrorText();
    end;

    #endregion
}

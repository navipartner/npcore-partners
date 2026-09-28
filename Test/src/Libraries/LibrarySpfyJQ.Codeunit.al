#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85387 "NPR Library - Spfy JQ"
{
    // Test fixtures for the Shopify ecommerce-order-experience job queue lifecycle (CORE-2178). Two groups
    // live here: the Shopify feature + setup + store fixture the OrderImport and EventDocProcessor JQs read,
    // and the job queue hold subscribers + query/state helpers those tests build on.
    //
    // Modelled on "NPR Library - Entria". Same rationale for EventSubscriberInstance = Manual: the hold
    // subscribers must be inert unless a test explicitly binds them. Callers are expected to bracket each
    // production call that reaches SetupJobQueue with BindSubscription/UnbindSubscription, which the
    // Run* helpers here do. The plain fixture setters need no binding.
    //
    // Direct assignment on the setup and store records rather than Validate: the "Enabled" and
    // "Sales Order Integration" OnValidate triggers reach SetupJobQueues() (and its subscribers), which
    // itself reaches StartJobQueueEntry and would push the importer at the platform scheduler unless the
    // hold subscribers were bound - and the tests need to drive that path themselves. The store's OnDelete
    // trigger reaches SetupJobQueuesOnStoreDeletion(); the store-Delete helper below brackets that too.
    //
    // NPR Feature row is written the same way, bypassing the Validate cascade in
    // SpfyEcommerceOrderExp.NPRFeatureOnBeforeValidateEnabled -> HandleJobQueues so a fixture toggle does
    // not tear down or rebuild the very JQ the test is about to configure.

    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        _DisabledStoresSnapshot: Record "NPR Spfy Store" temporary;

    #region Job queue hold subscribers

    // The two subscribers cover both InitRecurringJobQueueEntry paths: insert of a fresh entry, and
    // in-place update of an existing one. Either way the JQ is stamped Manually Set On Hold, and
    // ActivateJobQueueEntry exits before Restart() when that flag is set - so StartJobQueueEntry does
    // not reach TaskScheduler.CreateTask and no platform task is created.
    //
    // Narrowed to the Shopify order jobs on purpose: the two ecommerce JQs and the legacy "NPR Spfy Order Mgt."
    // import job. An error inside the BindSubscription bracket skips the unbind, so a leaked binding must be
    // incapable of holding some unrelated tenant's job.

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeInsertRecurringJobQueueEntry, '', false, false)]
    local procedure HoldNewSpfyJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        SetManualHold(JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeModifyUpdatedJobQueueEntry, '', false, false)]
    local procedure HoldUpdatedSpfyJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        SetManualHold(JobQueueEntry);
    end;

    local procedure SetManualHold(var JobQueueEntry: Record "Job Queue Entry")
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit;
        if not (JobQueueEntry."Object ID to Run" in [SpfyOrderImportJQ.CurrCodeunitId(), SpfyEventDocProcessorJQ.CurrCodeunitId(), Codeunit::"NPR Spfy Order Mgt."]) then
            exit;
        JobQueueEntry."NPR Manually Set On Hold" := true;
    end;

    // Keeps these jobs off the platform scheduler on paths that reach EnqueueTask, which SetManualHold does not cover.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", OnBeforeJobQueueScheduleTask, '', false, false)]
    local procedure DoNotScheduleSpfyOrderJobs(var JobQueueEntry: Record "Job Queue Entry"; var DoNotScheduleTask: Boolean)
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
    begin
        if JobQueueEntry."Object Type to Run" <> JobQueueEntry."Object Type to Run"::Codeunit then
            exit;
        if not (JobQueueEntry."Object ID to Run" in [SpfyOrderImportJQ.CurrCodeunitId(), SpfyEventDocProcessorJQ.CurrCodeunitId(), Codeunit::"NPR Spfy Order Mgt."]) then
            exit;
        DoNotScheduleTask := true;
    end;

    #endregion

    #region Setup helpers

    /// <summary>
    /// Flips the integration-level switch by direct assignment, creating the setup record if the tenant has
    /// none, and invalidates the SingleInstance setup cache so a subsequent read returns the new value.
    /// </summary>
    procedure SetEnableIntegration(Enabled: Boolean)
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        if not SpfyIntegrationSetup.Get() then begin
            SpfyIntegrationSetup.Init();
            SpfyIntegrationSetup.Insert();
        end;
        SpfyIntegrationSetup."Enable Integration" := Enabled;
        SpfyIntegrationSetup.Modify();

        SpfyIntegrationMgt.SetRereadSetup();
    end;

    /// <summary>
    /// Writes "Enable Integration" WITHOUT invalidating the SingleInstance setup cache, so a caller can put
    /// the session in the state a cross-session write leaves it in.
    /// </summary>
    procedure SetEnableIntegrationLeavingCacheStale(Enabled: Boolean)
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
    begin
        if not SpfyIntegrationSetup.Get() then begin
            SpfyIntegrationSetup.Init();
            SpfyIntegrationSetup.Insert();
        end;
        SpfyIntegrationSetup."Enable Integration" := Enabled;
        SpfyIntegrationSetup.Modify();
    end;

    /// <summary>
    /// Sets the "Shopify Ecommerce Order Experience" feature Enabled flag by direct assignment, bypassing the
    /// NPRFeatureOnBeforeValidateEnabled -> HandleJobQueues cascade so this fixture toggle cannot tear down
    /// or rebuild the very job queues the test is about to configure. Inserts the row if the framework has
    /// not seeded it on this tenant yet.
    /// </summary>
    procedure SetFeatureEnabled(Enabled: Boolean)
    var
        Feature: Record "NPR Feature";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        FeatureId: Text[50];
    begin
        FeatureId := ShopifyEcommOrderExp.GetFeatureId();
        if not Feature.Get(FeatureId) then begin
            Feature.Init();
            Feature.Id := FeatureId;
            Feature.Description := ShopifyEcommOrderExp.GetFeatureDescription();
            Feature.Enabled := Enabled;
            Feature.Insert();
            exit;
        end;
        Feature.Enabled := Enabled;
        Feature.Modify();
    end;

    /// <summary>
    /// Creates the given Shopify store if it is missing and sets exactly the two flags that decide the sales
    /// order integration master switch - Enabled and Sales Order Integration - by direct assignment. Sales
    /// Return Order Integration is out of CORE-2178 scope and is deliberately not written here.
    /// </summary>
    /// <remarks>
    /// Direct assignment is needed. NPR Spfy Store.Enabled's OnValidate calls SpfyScheduleSend.SetupTask...
    /// and SpfyEcomSalesDocPrcssr.SetupJobQueues(), and "Sales Order Integration" has similar side effects;
    /// both would run production job setup outside the BindSubscription bracket that keeps the platform
    /// scheduler out. Also TestField("Shopify Url") fires when Enabled is validated, so the URL is set first.
    /// </remarks>
    procedure SetStore(StoreCode: Code[20]; StoreEnabled: Boolean; SalesOrderIntegration: Boolean)
    var
        SpfyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        // A reserved-TLD URL and no access token, on purpose: if this store ever did get scheduled despite
        // the hold subscribers, a real Shopify HTTP call would fail deterministically before reaching a
        // live backend.
        SpfyStore."Shopify Url" := 'https://spfy.invalid';
        SpfyStore.Description := StoreCode;
        SpfyStore.Enabled := StoreEnabled;
        SpfyStore."Sales Order Integration" := SalesOrderIntegration;
        SpfyStore.Modify(false);
    end;

    /// <summary>
    /// Flips the store's "Sales Return Order Integration" flag by direct assignment. Same discipline as SetStore -
    /// the field's OnValidate cascades through prerequisites like "Get Returns Starting From" and reaches the JQ
    /// setup path, so a fixture toggle would tear down or rebuild the very job the test is about to configure.
    /// </summary>
    procedure SetSalesReturnIntegration(StoreCode: Code[20]; Enabled: Boolean)
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        SpfyStore.Get(StoreCode);
        SpfyStore."Sales Return Order Integration" := Enabled;
        SpfyStore.Modify(false);
    end;

    /// <summary>
    /// Switches off every enabled Shopify store except the one the caller owns, so the caller's own fixture
    /// decides the sales-order-integration master switch rather than whatever else exists on the tenant.
    /// Direct assignment for the same reasons as SetStore.
    /// </summary>
    procedure DisableStoresExcept(KeepStoreCode: Code[20])
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        SpfyStore.SetFilter(Code, '<>%1', KeepStoreCode);
        if SpfyStore.IsEmpty() then
            exit;
        // Snapshot every foreign store this call is about to clear so RestoreDisabledStores can put
        // Enabled and "Sales Order Integration" back. TestIsolation = Codeunit rolls back uncommitted
        // writes at case boundaries, but tests that Commit() inside their body after InitializeJQ
        // defeat that boundary - so this snapshot is the only thing standing between a foreign
        // developer store on the tenant and a leaked disable.
        if SpfyStore.FindSet() then
            repeat
                if SpfyStore.Enabled or SpfyStore."Sales Order Integration" then begin
                    _DisabledStoresSnapshot.Init();
                    _DisabledStoresSnapshot.Code := SpfyStore.Code;
                    _DisabledStoresSnapshot.Enabled := SpfyStore.Enabled;
                    _DisabledStoresSnapshot."Sales Order Integration" := SpfyStore."Sales Order Integration";
                    _DisabledStoresSnapshot.Insert(false);
                end;
            until SpfyStore.Next() = 0;
        SpfyStore.ModifyAll(Enabled, false, false);
        SpfyStore.ModifyAll("Sales Order Integration", false, false);
    end;

    /// <summary>
    /// Restores Enabled and "Sales Order Integration" on every foreign store a prior DisableStoresExcept
    /// call switched off, then clears the snapshot. Fixture teardown must call this before its own
    /// per-store restore work so the two fixture stores overwrite whatever this restored for them.
    /// </summary>
    procedure RestoreDisabledStores()
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        if _DisabledStoresSnapshot.IsEmpty() then
            exit;
        if _DisabledStoresSnapshot.FindSet() then
            repeat
                if SpfyStore.Get(_DisabledStoresSnapshot.Code) then begin
                    SpfyStore.Enabled := _DisabledStoresSnapshot.Enabled;
                    SpfyStore."Sales Order Integration" := _DisabledStoresSnapshot."Sales Order Integration";
                    SpfyStore.Modify(false);
                end;
            until _DisabledStoresSnapshot.Next() = 0;
        _DisabledStoresSnapshot.DeleteAll();
    end;

    #endregion

    #region Run helpers

    /// <summary>
    /// Runs the OrderImport SetupJobQueues() with the hold subscribers bound for the duration of the call.
    /// The entry is stamped Manually Set On Hold by SetManualHold, so ActivateJobQueueEntry exits before
    /// TaskScheduler.CreateTask is reached and no platform task is ever created.
    /// </summary>
    procedure RunOrderImportSetupJobQueues()
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        LibrarySpfyJQ: Codeunit "NPR Library - Spfy JQ";
    begin
        BindSubscription(LibrarySpfyJQ);
        SpfyOrderImportJQ.SetupJobQueues();
        UnbindSubscription(LibrarySpfyJQ);
    end;

    /// <summary>
    /// Runs the EventDocProcessor SetupJobQueues() with the hold subscribers bound. Kept here so both
    /// Shopify JQ test codeunits share the same bracket.
    /// </summary>
    procedure RunEventDocProcessorSetupJobQueues()
    var
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        LibrarySpfyJQ: Codeunit "NPR Library - Spfy JQ";
    begin
        BindSubscription(LibrarySpfyJQ);
        SpfyEventDocProcessorJQ.SetupJobQueues();
        UnbindSubscription(LibrarySpfyJQ);
    end;

    /// <summary>
    /// Runs SetupJobQueue(Enable) for whichever of the two Shopify ecommerce JQs matches JQCodeunitId, with
    /// the hold subscribers bound. Lets a test drive the disable branch (Enable = false) without a full
    /// SetupJobQueues() master-switch dance.
    /// </summary>
    procedure RunSetupJobQueue(JQCodeunitId: Integer; Enable: Boolean)
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SpfyEventDocProcessorJQ: Codeunit "NPR Spfy Event Doc ProcessorJQ";
        LibrarySpfyJQ: Codeunit "NPR Library - Spfy JQ";
    begin
        BindSubscription(LibrarySpfyJQ);
        case JQCodeunitId of
            SpfyOrderImportJQ.CurrCodeunitId():
                SpfyOrderImportJQ.SetupJobQueue(Enable);
            SpfyEventDocProcessorJQ.CurrCodeunitId():
                SpfyEventDocProcessorJQ.SetupJobQueue(Enable);
        end;
        UnbindSubscription(LibrarySpfyJQ);
    end;

    /// <summary>
    /// Deletes the given Shopify store with the hold subscribers bound for the duration of the delete, so the
    /// job queue setup that the OnDelete trigger reaches (via SpfyIntegrationMgt.SetupJobQueuesOnStoreDeletion)
    /// cannot get to the platform scheduler. Uses Delete(true) so the OnDelete cascade in "NPR Spfy Store" runs.
    /// </summary>
    procedure DeleteStore(StoreCode: Code[20])
    var
        SpfyStore: Record "NPR Spfy Store";
        LibrarySpfyJQ: Codeunit "NPR Library - Spfy JQ";
    begin
        SpfyStore.Get(StoreCode);
        BindSubscription(LibrarySpfyJQ);
        SpfyStore.Delete(true);
        UnbindSubscription(LibrarySpfyJQ);
    end;

    #endregion

    #region State clearing

    /// <summary>
    /// Wipes every job queue, monitored, and managed-by-app row for the given codeunit id. Monitored rows
    /// first, so their OnDelete cascade removes the companion Managed-By-App rows while the referenced job
    /// queue entry IDs are still resolvable.
    /// </summary>
    procedure ClearJobQueueState(JQCodeunitId: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
    begin
        FilterMonitoredEntries(JQCodeunitId, MonitoredJQEntry);
        if not MonitoredJQEntry.IsEmpty() then
            MonitoredJQEntry.DeleteAll(true);

        FilterJobQueueEntries(JQCodeunitId, JobQueueEntry);
        while JobQueueEntry.FindFirst() do begin
            // An In Process entry cannot be deleted, and a dev tenant may well have one running.
            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
            if ManagedByApp.Get(JobQueueEntry.ID) then
                ManagedByApp.Delete();
            JobQueueEntry.Delete(true);
        end;
    end;

    #endregion

    #region Query helpers

    procedure FilterJobQueueEntries(JQCodeunitId: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", JQCodeunitId);
    end;

    procedure CountJobQueueEntries(JQCodeunitId: Integer): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        FilterJobQueueEntries(JQCodeunitId, JobQueueEntry);
        exit(JobQueueEntry.Count());
    end;

    procedure FilterMonitoredEntries(JQCodeunitId: Integer; var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    begin
        MonitoredJQEntry.Reset();
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        MonitoredJQEntry.SetRange("Object ID to Run", JQCodeunitId);
    end;

    procedure CountMonitoredEntries(JQCodeunitId: Integer): Integer
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        FilterMonitoredEntries(JQCodeunitId, MonitoredJQEntry);
        exit(MonitoredJQEntry.Count());
    end;

    procedure CountManagedByAppEntries(JQCodeunitId: Integer): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByApp: Record "NPR Managed By App Job Queue";
        Count: Integer;
    begin
        FilterJobQueueEntries(JQCodeunitId, JobQueueEntry);
        if not JobQueueEntry.FindSet() then
            exit(0);
        repeat
            if ManagedByApp.Get(JobQueueEntry.ID) and ManagedByApp."Managed by App" then
                Count += 1;
        until JobQueueEntry.Next() = 0;
        exit(Count);
    end;

    #endregion

    #region Fixture builders

    /// <summary>
    /// Inserts the legacy shape of the given Shopify JQ: NP-protected, recurring, no monitored row.
    /// Manually Set On Hold keeps the platform scheduler away from it before the hold subscribers are even
    /// bound. Simulates a pre-CORE-2178 row for the transition test.
    /// </summary>
    procedure CreateLegacyProtectedJob(JQCodeunitId: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := JQCodeunitId;
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."No. of Minutes between Runs" := 1;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR NP Protected Job" := true;
        JobQueueEntry."NPR Manually Set On Hold" := true;
        JobQueueEntry.Insert(false);
    end;

    /// <summary>
    /// Inserts the legacy shape of the given Shopify JQ like CreateLegacyProtectedJob, but Ready and not
    /// manually held, with no platform task.
    /// </summary>
    procedure CreateLegacyProtectedJobNotManuallyHeld(JQCodeunitId: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := JQCodeunitId;
        JobQueueEntry."Recurring Job" := true;
        JobQueueEntry."No. of Minutes between Runs" := 1;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry."NPR NP Protected Job" := true;
        JobQueueEntry."NPR Manually Set On Hold" := false;
        JobQueueEntry.Insert(false);
    end;

    /// <summary>
    /// Inserts a non-recurring, NP-protected entry for the given codeunit, held the same way as
    /// CreateLegacyProtectedJob. The upgrade conversion filters on "Recurring Job", so it must leave this entry alone.
    /// </summary>
    procedure CreateLegacyProtectedOneOffJob(JQCodeunitId: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := JQCodeunitId;
        JobQueueEntry."Recurring Job" := false;
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry."NPR NP Protected Job" := true;
        JobQueueEntry."NPR Manually Set On Hold" := true;
        JobQueueEntry.Insert(false);
    end;

    /// <summary>
    /// Inserts an NP-protected monitored row for the given codeunit whose "Job Queue Entry ID" points to no job
    /// queue entry, the state a row is left in after support deletes its job.
    /// </summary>
    procedure CreateProtectedMonitoredRow(JQCodeunitId: Integer; var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry")
    begin
        MonitoredJQEntry.Init();
        MonitoredJQEntry."Entry No." := 0;
        MonitoredJQEntry."Object Type to Run" := MonitoredJQEntry."Object Type to Run"::Codeunit;
        MonitoredJQEntry."Object ID to Run" := JQCodeunitId;
        MonitoredJQEntry."NP Protected Job" := true;
        MonitoredJQEntry."Job Queue Entry ID" := CreateGuid();
        MonitoredJQEntry."Recurring Job" := true;
        MonitoredJQEntry."No. of Minutes between Runs" := 1;
        MonitoredJQEntry.Insert(false);
    end;

    /// <summary>
    /// Returns the highest monitored "Entry No." on the tenant, or 0 when there are none. Refresh tests take it
    /// before the refresh so they can find the rows the refresh added.
    /// </summary>
    procedure GetLastMonitoredEntryNo(): BigInteger
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        if MonitoredJQEntry.FindLast() then
            exit(MonitoredJQEntry."Entry No.");
        exit(0);
    end;

    /// <summary>
    /// Deletes every monitored row above LastEntryNo that runs a Shopify codeunit ('NPR Spfy*'). Removes what
    /// the OnRefreshNPRJobQueueList subscribers of the other Shopify jobs added during a refresh test.
    /// </summary>
    procedure DeleteShopifyMonitoredEntriesAfter(LastEntryNo: BigInteger)
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        AllObj: Record AllObj;
    begin
        MonitoredJQEntry.SetFilter("Entry No.", '>%1', LastEntryNo);
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        if not MonitoredJQEntry.FindSet(true) then
            exit;
        repeat
            AllObj.SetRange("Object Type", AllObj."Object Type"::Codeunit);
            AllObj.SetRange("Object ID", MonitoredJQEntry."Object ID to Run");
            AllObj.SetFilter("Object Name", 'NPR Spfy*');
            if not AllObj.IsEmpty() then
                MonitoredJQEntry.Delete(false);
        until MonitoredJQEntry.Next() = 0;
    end;

    /// <summary>
    /// Deletes the monitored row with the given "Entry No." if it still exists.
    /// </summary>
    procedure DeleteMonitoredEntry(EntryNo: BigInteger)
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        if MonitoredJQEntry.Get(EntryNo) then
            MonitoredJQEntry.Delete(true);
    end;

    /// <summary>
    /// Builds an uninserted job queue entry for the given codeunit. Deliberately not inserted: the
    /// refresher-gate predicate only inspects the record it is handed.
    /// </summary>
    procedure BuildJobQueueEntryFor(JQCodeunitId: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        Clear(JobQueueEntry);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := JQCodeunitId;
    end;

    /// <summary>
    /// Builds an uninserted job queue entry whose "Object Type to Run" is Report rather than Codeunit, so a
    /// caller can exercise the object-type half of a subscriber guard independently of the object-id half.
    /// </summary>
    procedure BuildReportJobQueueEntryFor(ObjectIdToRun: Integer; var JobQueueEntry: Record "Job Queue Entry")
    begin
        Clear(JobQueueEntry);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Report;
        JobQueueEntry."Object ID to Run" := ObjectIdToRun;
    end;

    /// <summary>
    /// Deletes a job queue entry the way support does when a job is stuck, leaving its monitored row orphaned.
    /// </summary>
    procedure DeleteJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
        JobQueueEntry.Delete(true);
    end;

    /// <summary>
    /// Overwrites "No. of Minutes between Runs" on the given job queue entry by direct assignment. No Validate,
    /// no cascade - the point of the helper is to prove that an admin edit stored this way survives the
    /// production refresh cycle rather than being clobbered by the Shopify refresher.
    /// </summary>
    internal procedure SetJQMinutesBetweenRuns(var JobQueueEntry: Record "Job Queue Entry"; Minutes: Integer)
    begin
        JobQueueEntry."No. of Minutes between Runs" := Minutes;
        JobQueueEntry.Modify(false);
    end;

    /// <summary>
    /// Overwrites "No. of Minutes between Runs" on the given monitored job queue row by direct assignment.
    /// Simulates the Monitored JQ Entry card edit path: the admin's value lands on the monitored row, and
    /// the OnRefreshNPRJobQueueList publisher chain plus RefreshJobQueueEntry are what propagate it onto
    /// the underlying JQ entry. The test asserts the monitored value survives the refresh cycle rather
    /// than being clobbered by an OnRefreshNPRJobQueueList subscriber calling SetupJobQueues.
    /// </summary>
    internal procedure SetMonitoredJQMinutesBetweenRuns(var MonitoredJQEntry: Record "NPR Monitored Job Queue Entry"; Minutes: Integer)
    begin
        MonitoredJQEntry."No. of Minutes between Runs" := Minutes;
        MonitoredJQEntry.Modify(false);
    end;

    #endregion

    #region Upgrade helpers

    /// <summary>
    /// Runs the ecom job queue conversion of the upgrade step through ConvertEcomJQs, which skips the upgrade
    /// tag check, so every test can run it. The hold subscribers stay bound as a safety bracket.
    /// </summary>
    internal procedure RunUpgradeStep_ConvertLegacyProtected()
    var
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        LibrarySpfyJQ: Codeunit "NPR Library - Spfy JQ";
    begin
        BindSubscription(LibrarySpfyJQ);
        SpfyAppUpgrade.ConvertEcomJQs();
        UnbindSubscription(LibrarySpfyJQ);
    end;

    #endregion
}
#endif

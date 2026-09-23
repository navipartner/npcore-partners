codeunit 6151446 "NPR Spfy Resync Mgt"
{
    Access = Internal;

    internal procedure IsResyncActive(): Boolean
    var
        ResyncRun: Record "NPR Spfy Resync Run";
    begin
        // Stale Running rows are ignored so a crashed run can't block detection; the next StartRun reaps them.
        ResyncRun.SetRange(Status, ResyncRun.Status::Running);
        ResyncRun.SetFilter("Heartbeat At", '>%1', CurrentDateTime() - StalenessThresholdMs());
        exit(not ResyncRun.IsEmpty());
    end;

    internal procedure StartRun(var ResyncRun: Record "NPR Spfy Resync Run")
    var
        ResyncAlreadyRunningErr: Label 'Another Shopify re-sync run is already in progress (started %1 by %2). Wait for it to complete, or wait 15 minutes for a crashed run to be reaped.', Comment = '%1 = started at datetime, %2 = user id';
        ActiveRun: Record "NPR Spfy Resync Run";
        ShopifySetup: Record "NPR Spfy Integration Setup";
    begin
        FailStaleRuns();
        // BC takes no locks on an empty range, so probing Running rows can't serialize concurrent StartRuns.
        // UpdLock the setup singleton instead: the second session blocks here until the first commits its Running row.
        ShopifySetup.ReadIsolation(IsolationLevel::UpdLock);
        ShopifySetup.Get();
        ActiveRun.SetRange(Status, ActiveRun.Status::Running);
        if ActiveRun.FindFirst() then
            Error(ResyncAlreadyRunningErr, ActiveRun."Started At", ActiveRun."Run By");
        ResyncRun."Entry No." := 0;
        ResyncRun.Status := ResyncRun.Status::Running;
        ResyncRun."Started At" := CurrentDateTime();
        ResyncRun."Heartbeat At" := ResyncRun."Started At";
        ResyncRun."Run By" := CopyStr(UserId(), 1, MaxStrLen(ResyncRun."Run By"));
        ResyncRun.Insert(true);
        // The marker must be durable before any baseline delete.
        Commit();
    end;

    internal procedure RefreshHeartbeat(var ResyncRun: Record "NPR Spfy Resync Run")
    var
        FreshRun: Record "NPR Spfy Resync Run";
        RunSupersededErr: Label 'This Shopify re-sync run was marked as failed by the stale-run reaper (no heartbeat for over 15 minutes) and may have been superseded by another run. It has been stopped to prevent two concurrent re-syncs from corrupting each other. Re-run the re-sync once no other run is in progress.';
    begin
        // Confirm still Running under UpdLock: a blind Modify would resurrect a reaped row and run two re-syncs in parallel.
        FreshRun.ReadIsolation(IsolationLevel::UpdLock);
        if (not FreshRun.Get(ResyncRun."Entry No.")) or (FreshRun.Status <> FreshRun.Status::Running) then
            Error(RunSupersededErr);
        ResyncRun."Heartbeat At" := CurrentDateTime();
        ResyncRun.Modify();
    end;

    internal procedure RefreshRunHeartbeat(EntryNo: BigInteger)
    var
        ResyncRun: Record "NPR Spfy Resync Run";
    begin
        // Heartbeat only THIS run's row — a reaped quiet-seed must fail, not latch onto a newer run's row.
        if EntryNo = 0 then   // seed worker running outside a re-sync (migration path)
            exit;
        ResyncRun.Get(EntryNo);
        RefreshHeartbeat(ResyncRun);
    end;

    internal procedure CompleteRun(var ResyncRun: Record "NPR Spfy Resync Run")
    begin
        ResyncRun.Status := ResyncRun.Status::Completed;
        ResyncRun."Completed At" := CurrentDateTime();
        ResyncRun."Heartbeat At" := ResyncRun."Completed At";
        ResyncRun.Modify();
        Commit();
    end;

    internal procedure FailRun(var ResyncRun: Record "NPR Spfy Resync Run"; ErrorText: Text)
    begin
        ResyncRun.Status := ResyncRun.Status::Failed;
        ResyncRun."Error Text" := CopyStr(ErrorText, 1, MaxStrLen(ResyncRun."Error Text"));
        ResyncRun."Completed At" := CurrentDateTime();
        ResyncRun.Modify();
        Commit();
    end;

    internal procedure ReapStaleRuns()
    begin
        FailStaleRuns();
    end;

    local procedure FailStaleRuns()
    var
        ResyncRun: Record "NPR Spfy Resync Run";
        ReapedEntryNos: List of [BigInteger];
        EntryNo: BigInteger;
        StaleRunLbl: Label 'Marked as failed: no heartbeat for over 15 minutes (crashed or killed run).';
    begin
        ResyncRun.SetRange(Status, ResyncRun.Status::Running);
        ResyncRun.SetFilter("Heartbeat At", '<=%1', CurrentDateTime() - StalenessThresholdMs());
        if not ResyncRun.FindSet() then
            exit;
        repeat
            ResyncRun.Status := ResyncRun.Status::Failed;
            ResyncRun."Error Text" := CopyStr(StaleRunLbl, 1, MaxStrLen(ResyncRun."Error Text"));
            ResyncRun."Completed At" := CurrentDateTime();
            ResyncRun.Modify();
            ReapedEntryNos.Add(ResyncRun."Entry No.");
        until ResyncRun.Next() = 0;
        // Commit the reap BEFORE telemetry: FailStaleRuns runs inside StartRun ahead of its own commit/abort,
        // so a non-transactional 'failed' event emitted first could contradict a row a later error rolls back
        // to Running. Committing also keeps a genuinely-crashed run Failed even if this StartRun then aborts.
        Commit();
        foreach EntryNo in ReapedEntryNos do
            if ResyncRun.Get(EntryNo) then
                LogRunTelemetry('failed', ResyncRun, StaleRunLbl);   // crashed/killed run — surface it to telemetry, not just the Runs page
    end;

    local procedure StalenessThresholdMs(): Integer
    begin
        exit(15 * 60 * 1000);
    end;

    internal procedure UpdateSystemRowVersion(var RecRef: RecordRef; BumpFieldNo: Integer)
    var
        Sentry: Codeunit "NPR Sentry";
        FRef: FieldRef;
        OriginalValue: Text;
        OriginalBool: Boolean;
        UnsupportedBumpFieldErr: Label 'UpdateSystemRowVersion cannot bump field %1 of type %2: only Text, Code and Boolean are supported. This is a programming bug.', Locked = true;
    begin
        // Toggle + restore forces a real SQL UPDATE (a no-change Modify may not move SystemRowVersion).
        // OnAfterModify subscribers still fire — callers must pass a field whose momentary flip is harmless.
        FRef := RecRef.Field(BumpFieldNo);
        case FRef.Type of
            FRef.Type::Text, FRef.Type::Code:
                begin
                    OriginalValue := Format(FRef.Value());
                    FRef.Value(ToggledValue(OriginalValue));
                    RecRef.Modify(false);
                    FRef.Value(OriginalValue);
                    RecRef.Modify(false);
                end;
            FRef.Type::Boolean:
                begin
                    OriginalBool := FRef.Value();
                    FRef.Value(not OriginalBool);
                    RecRef.Modify(false);
                    FRef.Value(OriginalBool);
                    RecRef.Modify(false);
                end;
            else begin
                // Fail loud: an unhandled type would silently NOT bump, leaving the entity un-resynced. The
                // single-entity re-push callers have no catch, so emit the Sentry event here before the rollback.
                Sentry.InitScopeAndTransaction('Shopify re-sync row-version bump', 'bc.shopify.resync.bump');
                Sentry.AddError(StrSubstNo(UnsupportedBumpFieldErr, FRef.Name(), FRef.Type()));
                Sentry.FinalizeScope();
                Error(UnsupportedBumpFieldErr, FRef.Name(), FRef.Type());
            end;
        end;
    end;

    local procedure ToggledValue(Value: Text): Text
    begin
        if Value = '~' then
            exit('^');
        exit('~');
    end;

    local procedure BumpInventoryLevel(var SpfyInventoryLevel: Record "NPR Spfy Inventory Level")
    var
        NewLastUpdatedAt: DateTime;
    begin
        // "Last Updated at" is the NC-task log date — set it with a monotonic guard, not a char-toggle.
        NewLastUpdatedAt := CurrentDateTime();
        if SpfyInventoryLevel."Last Updated at" >= NewLastUpdatedAt then
            NewLastUpdatedAt := SpfyInventoryLevel."Last Updated at" + 1;
        SpfyInventoryLevel."Last Updated at" := NewLastUpdatedAt;
        SpfyInventoryLevel.Modify(false);
    end;

    internal procedure GetTablePolicy(TableNo: Integer): Enum "NPR Spfy Resync Table Policy"
    begin
        case TableNo of
            Database::Item,
            Database::"Item Variant",
            Database::"NPR Spfy Store-Item Link",
            Database::"NPR Spfy Item Variant Modif.",
            Database::"NPR Spfy Entity Metafield",
            Database::"NPR Spfy Store-Customer Link":
                exit("NPR Spfy Resync Table Policy"::"Baseline Reset");
            Database::"Sales Line",
            Database::"Transfer Line",
            Database::"Stockkeeping Unit",
            Database::"Item Reference",
            Database::"NPR Spfy Inventory Level":
                // Mark-only: reset the mark, never delete a baseline. Sales/Transfer/SKU DO have a baseline (the
                // line's last inventory key) that must be KEPT — a re-scan then detects a moved key (old<>new) and
                // recalcs both locations (deleting it strands the abandoned one). Item Reference / Inventory Level
                // have NO baseline (re-scan re-sends unconditionally).
                exit("NPR Spfy Resync Table Policy"::"Mark-Only Requeue");
            Database::"Item Ledger Entry":
                // ILE: zeroing a multi-million-row append-only ledger mark = days of recompute churn.
                exit("NPR Spfy Resync Table Policy"::"Fast-Forward Only");
            Database::"NPR NpRv Voucher",
            Database::"NPR NpRv Voucher Entry",
            Database::"NPR NpRv Arch. Voucher",
            Database::"NPR Spfy Item Price":
                // Wiping voucher baselines breaks detection; Item Price has no baseline to un-drift.
                exit("NPR Spfy Resync Table Policy"::Blocked);
        end;
        // Unknown/future tracker table: mark-only requeue is the safe default (re-scan; hash-matched rows no-op).
        exit("NPR Spfy Resync Table Policy"::"Mark-Only Requeue");
    end;

    internal procedure ResyncStoreItemLink(SpfyStoreItemLink: Record "NPR Spfy Store-Item Link")
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
        SpfyInventoryLevel: Record "NPR Spfy Inventory Level";
        ItemStoreLink: Record "NPR Spfy Store-Item Link";
        VariantStoreLink: Record "NPR Spfy Store-Item Link";
        SpfyItemTaskBuilder: Codeunit "NPR Spfy Item Task Builder";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        RecRef: RecordRef;
        BaselinesCleared: Integer;
        RowsBumped: Integer;
        RowsSkipped: Integer;
        ConfirmRepushQst: Label 'Re-push item %1 and its variants to Shopify store %2?\\This clears the stored sync baselines and re-sends the current BC state on the next detection cycle (typically within a minute).', Comment = '%1 = item no., %2 = Shopify store code';
        NotSyncedErr: Label 'Item %1 is not synchronized to Shopify store %2. Enable %3 first, or use the Update Sync. Status action to adopt an existing Shopify product.', Comment = '%1 = item no., %2 = store code, %3 = caption of the Sync. to this Store field';
        AreaDisabledErr: Label 'The %1 integration area is not enabled for Shopify store %2. Enable it on the Shopify Integration Setup page first.', Comment = '%1 = integration area caption, %2 = Shopify store code';
        DoneMsg: Label 'Re-push queued for item %1 to store %2: %3 baseline(s) cleared, %4 row(s) bumped, %5 skipped (blocked/ineligible/unassigned/not available). The detection job sends the data within its next cycle.', Comment = '%1 = item no., %2 = store code, %3, %4, %5 = counts';
    begin
        CheckFeatureEnabled();
        SpfyStoreItemLink.TestField(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.TestField("Item No.");
        SpfyStoreItemLink.TestField("Shopify Store Code");
        // Error, not silent no-op: handlers would skip every row while the operator thinks the re-push worked.
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::Items, SpfyStoreItemLink."Shopify Store Code") then
            Error(AreaDisabledErr, Format("NPR Spfy Integration Area"::Items), SpfyStoreItemLink."Shopify Store Code");
        // Sync=false + SyncEnabled=true is a pending delete: handlers would no-op the cascade while the ungated
        // inventory bump still re-sends.
        if not SpfyStoreItemLink."Sync. to this Store" then
            Error(NotSyncedErr, SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Shopify Store Code", SpfyStoreItemLink.FieldCaption("Sync. to this Store"));
        Item.Get(SpfyStoreItemLink."Item No.");
        // The poll handler silently skips a failing Item — validate up front instead of showing a false 'queued'.
        SpfyItemTaskBuilder.TestRequiredFields(Item, true);
        if GuiAllowed() then
            if not Confirm(ConfirmRepushQst, false, SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Shopify Store Code") then
                exit;

        // 1) Item-level facets (cost / category / safety stock): bump Item once — only the cleared store's
        //    compare fires. Other integrations' Item subscribers tolerate the bump (xRec = Rec on a code Modify).
        ClearBaselineCounted(Database::Item, Item.SystemId, SpfyStoreItemLink."Shopify Store Code", BaselinesCleared);
        RecRef.GetTable(Item);
        UpdateSystemRowVersion(RecRef, Item.FieldNo("Description 2"));
        RowsBumped += 1;

        // 2) Product payload for this store (storeItemLinkHash) — re-Get from the DB; never bump the page's copy.
        ItemStoreLink.Get(SpfyStoreItemLink.Type, SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Variant Code", SpfyStoreItemLink."Shopify Store Code");
        ClearBaselineCounted(Database::"NPR Spfy Store-Item Link", ItemStoreLink.SystemId, ItemStoreLink."Shopify Store Code", BaselinesCleared);
        RecRef.GetTable(ItemStoreLink);
        UpdateSystemRowVersion(RecRef, ItemStoreLink.FieldNo(Vendor));
        RowsBumped += 1;

        // 3) Metafields owned by the item-type link row (store-blank baselines, owner-scoped).
        ResyncMetafieldsForOwner(Database::"NPR Spfy Store-Item Link", ItemStoreLink.RecordId(), BaselinesCleared, RowsBumped);

        // 3b) Default-variant metafields hang off a Type=Variant link with a BLANK Variant Code — a key
        //     construct with no physical row, so RecordId() without Get.
        VariantStoreLink := ItemStoreLink;
        VariantStoreLink.Type := VariantStoreLink.Type::Variant;
        ResyncMetafieldsForOwner(Database::"NPR Spfy Store-Item Link", VariantStoreLink.RecordId(), BaselinesCleared, RowsBumped);

        // 4) Variants: re-send fans out to ALL stores (accepted over-send). The bump fires ItemVariantOnAfterModify
        //    with Blocked unchanged, and its CancelDelete is gated so a Pending deletion-log row survives.
        ItemVariant.SetRange("Item No.", Item."No.");
        if ItemVariant.FindSet() then
            repeat
                // Same gate as the poll handler (blocked/varieties): an ineligible variant would be silently
                // dropped there, so clearing+bumping it here would fake a 'queued'.
                if not SpfyItemTaskBuilder.TestRequiredFields(ItemVariant) then
                    RowsSkipped += 1
                else
                    if SpfyItemTaskBuilder.GetAssignedShopifyVariantID(Item."No.", ItemVariant.Code, SpfyStoreItemLink."Shopify Store Code", false) <> '' then begin
                        ClearBaselineCounted(Database::"Item Variant", ItemVariant.SystemId, '', BaselinesCleared);
                        RecRef.GetTable(ItemVariant);
                        UpdateSystemRowVersion(RecRef, ItemVariant.FieldNo("Description 2"));
                        RowsBumped += 1;
                        if VariantStoreLink.Get(VariantStoreLink.Type::Variant, Item."No.", ItemVariant.Code, SpfyStoreItemLink."Shopify Store Code") then
                            ResyncMetafieldsForOwner(Database::"NPR Spfy Store-Item Link", VariantStoreLink.RecordId(), BaselinesCleared, RowsBumped);
                    end else
                        RowsSkipped += 1;
            until ItemVariant.Next() = 0;

        // 5) Per-store variant data. Skip "Not Available" rows: the handler no-ops on them.
        SpfyItemVariantModif.SetRange("Item No.", Item."No.");
        SpfyItemVariantModif.SetRange("Shopify Store Code", SpfyStoreItemLink."Shopify Store Code");
        if SpfyItemVariantModif.FindSet() then
            repeat
                if SpfyItemVariantModif."Not Available" then
                    RowsSkipped += 1
                else begin
                    ClearBaselineCounted(Database::"NPR Spfy Item Variant Modif.", SpfyItemVariantModif.SystemId, SpfyItemVariantModif."Shopify Store Code", BaselinesCleared);
                    // Bump a boolean the delete-intent subscriber ignores; "Not Available" would flip delete intent.
                    RecRef.GetTable(SpfyItemVariantModif);
                    UpdateSystemRowVersion(RecRef, SpfyItemVariantModif.FieldNo("Allow Backorder"));
                    RowsBumped += 1;
                end;
            until SpfyItemVariantModif.Next() = 0;

        // 6) Inventory levels: no baseline — the bump alone re-sends. ByItemAtLocation makes store+item a
        //    contiguous key prefix (the clustered PK does not).
        SpfyInventoryLevel.SetCurrentKey("Shopify Store Code", "Item No.", "Shopify Location ID", "Variant Code");
        SpfyInventoryLevel.SetRange("Shopify Store Code", SpfyStoreItemLink."Shopify Store Code");
        SpfyInventoryLevel.SetRange("Item No.", Item."No.");
        if SpfyInventoryLevel.FindSet() then
            repeat
                BumpInventoryLevel(SpfyInventoryLevel);
                RowsBumped += 1;
            until SpfyInventoryLevel.Next() = 0;

        LogEntityResyncTelemetry('item-store-link', SpfyStoreItemLink."Shopify Store Code", BaselinesCleared, RowsBumped, RowsSkipped);
        if GuiAllowed() then
            Message(DoneMsg, SpfyStoreItemLink."Item No.", SpfyStoreItemLink."Shopify Store Code", BaselinesCleared, RowsBumped, RowsSkipped);
    end;

    internal procedure ResyncStoreCustomerLink(SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link")
    var
        CustomerStoreLink: Record "NPR Spfy Store-Customer Link";
        Customer: Record Customer;
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
        RecRef: RecordRef;
        BaselinesCleared: Integer;
        RowsBumped: Integer;
        ConfirmRepushQst: Label 'Re-push customer %1 to Shopify store %2?\\This clears the stored sync baselines and re-sends the current BC state on the next detection cycle (typically within a minute).', Comment = '%1 = customer no., %2 = Shopify store code';
        NotSyncedErr: Label 'Customer %1 is not synchronized to Shopify store %2. Enable %3 first.', Comment = '%1 = customer no., %2 = store code, %3 = caption of the Sync. to this Store field';
        AreaDisabledErr: Label 'The %1 integration area is not enabled for Shopify store %2. Enable it on the Shopify Integration Setup page first.', Comment = '%1 = integration area caption, %2 = Shopify store code';
        DoneMsg: Label 'Re-push queued for customer %1 to store %2: %3 baseline(s) cleared, %4 row(s) bumped. The detection job sends the data within its next cycle.', Comment = '%1 = customer no., %2 = store code, %3, %4 = counts';
    begin
        CheckFeatureEnabled();
        SpfyStoreCustomerLink.TestField("No.");
        SpfyStoreCustomerLink.TestField("Shopify Store Code");
        // Same guards as the item cascade: error on disabled area; Sync=false = pending delete.
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink."Shopify Store Code") then
            Error(AreaDisabledErr, Format("NPR Spfy Integration Area"::"Sales Orders"), SpfyStoreCustomerLink."Shopify Store Code");
        if not SpfyStoreCustomerLink."Sync. to this Store" then
            Error(NotSyncedErr, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code", SpfyStoreCustomerLink.FieldCaption("Sync. to this Store"));
        Customer.Get(SpfyStoreCustomerLink."No.");
        // The Customer table is NOT polled (only the link is): a failing customer would show a false 'queued'
        // and never re-send even after being fixed — validate up front.
        SpfyCustomerMgt.TestRequiredFields(Customer, true);
        if GuiAllowed() then
            if not Confirm(ConfirmRepushQst, false, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code") then
                exit;
        CustomerStoreLink.Get(SpfyStoreCustomerLink.Type, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code");
        ClearBaselineCounted(Database::"NPR Spfy Store-Customer Link", CustomerStoreLink.SystemId, CustomerStoreLink."Shopify Store Code", BaselinesCleared);
        RecRef.GetTable(CustomerStoreLink);
        UpdateSystemRowVersion(RecRef, CustomerStoreLink.FieldNo("Last Name"));
        RowsBumped += 1;
        ResyncMetafieldsForOwner(Database::"NPR Spfy Store-Customer Link", CustomerStoreLink.RecordId(), BaselinesCleared, RowsBumped);
        LogEntityResyncTelemetry('customer-store-link', SpfyStoreCustomerLink."Shopify Store Code", BaselinesCleared, RowsBumped, 0);
        if GuiAllowed() then
            Message(DoneMsg, SpfyStoreCustomerLink."No.", SpfyStoreCustomerLink."Shopify Store Code", BaselinesCleared, RowsBumped);
    end;

    local procedure ClearBaselineCounted(TableNo: Integer; EntitySystemId: Guid; StoreCode: Code[20]; var BaselinesCleared: Integer)
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
    begin
        if not SpfySyncStateMgt.HasBaseline(TableNo, EntitySystemId, StoreCode) then
            exit;
        SpfySyncStateMgt.RemoveBaseline(TableNo, EntitySystemId, StoreCode);
        BaselinesCleared += 1;
    end;

    local procedure ResyncMetafieldsForOwner(OwnerTableNo: Integer; OwnerRecordId: RecordId; var BaselinesCleared: Integer; var RowsBumped: Integer)
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
        RecRef: RecordRef;
    begin
        SpfyEntityMetafield.SetRange("Table No.", OwnerTableNo);
        SpfyEntityMetafield.SetRange("BC Record ID", OwnerRecordId);
        if SpfyEntityMetafield.FindSet() then
            repeat
                ClearBaselineCounted(Database::"NPR Spfy Entity Metafield", SpfyEntityMetafield.SystemId, '', BaselinesCleared);
                RecRef.GetTable(SpfyEntityMetafield);
                UpdateSystemRowVersion(RecRef, SpfyEntityMetafield.FieldNo("Metafield Value Version ID"));
                RowsBumped += 1;
            until SpfyEntityMetafield.Next() = 0;
    end;

    local procedure CheckFeatureEnabled()
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        FeatureNotEnabledErr: Label 'RowVersion change detection is not enabled for this Shopify integration. Re-sync tooling applies only after the migration to RowVersion detection.';
    begin
        if not SpfyRowVersionFeature.IsFeatureEnabled() then
            Error(FeatureNotEnabledErr);
    end;

    local procedure NonEmptyError(ErrorText: Text): Text
    var
        UnknownErrorLbl: Label 'The re-sync failed without a specific error message.';
    begin
        // A Codeunit.Run aborted via Error('') leaves GetLastErrorText() empty — avoid a blank run Error Text / silent re-raise.
        if ErrorText = '' then
            exit(UnknownErrorLbl);
        exit(ErrorText);
    end;

    local procedure HeartbeatEvery(var ResyncRun: Record "NPR Spfy Resync Run"; var RowsSinceCommit: Integer)
    begin
        // Bound the long per-link loops: an uncommitted loop over a large catalog can outrun the 15-min heartbeat
        // and get reaped as crashed. Commit every N rows to keep the heartbeat fresh and the transaction short.
        RowsSinceCommit += 1;
        if RowsSinceCommit < 100 then
            exit;
        RefreshHeartbeat(ResyncRun);
        Commit();
        RowsSinceCommit := 0;
    end;

    local procedure LogEntityResyncTelemetry(EntityKind: Text; StoreCode: Code[20]; BaselinesCleared: Integer; RowsBumped: Integer; RowsSkipped: Integer)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('NPR_EntityKind', EntityKind);
        CustomDimensions.Add('NPR_StoreCode', StoreCode);
        CustomDimensions.Add('NPR_BaselinesCleared', Format(BaselinesCleared));
        CustomDimensions.Add('NPR_RowsBumped', Format(RowsBumped));
        CustomDimensions.Add('NPR_RowsSkipped', Format(RowsSkipped));
        Session.LogMessage('Shopify_Resync', StrSubstNo('Shopify single-entity re-push (%1)', EntityKind),
            Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    internal procedure ExecuteRun(var ResyncRun: Record "NPR Spfy Resync Run")
    var
        SpfyResyncScopeRunner: Codeunit "NPR Spfy Resync Scope Runner";
        Sentry: Codeunit "NPR Sentry";
        Span: Codeunit "NPR Sentry Span";
        LastError: Text;
    begin
        Sentry.StartSpan(Span, StrSubstNo('bc.shopify.resync.%1', ScopeSlug(ResyncRun.Scope)));
        LogRunTelemetry('started', ResyncRun, '');
        // Codeunit.Run, not [TryFunction]: try-method DB writes are not rolled back on error.
        ClearLastError();
        if SpfyResyncScopeRunner.Run(ResyncRun) then begin
            // Counts were written inside the runner — var copy-back through Codeunit.Run is unreliable.
            ResyncRun.Find();
            LogRunTelemetry('completed', ResyncRun, '');
            Span.Finish();
            exit;
        end;
        LastError := NonEmptyError(GetLastErrorText());
        Sentry.AddLastErrorIfProgrammingBug();
        if ResyncRun.Find() and (ResyncRun.Status = ResyncRun.Status::Running) then
            FailRun(ResyncRun, LastError);
        LogRunTelemetry('failed', ResyncRun, LastError);
        Span.Finish("NPR Sentry Span Status"::InternalError);   // default status is Ok — mark the caught failure
        Error('%1', LastError);
    end;

    internal procedure DispatchScope(var ResyncRun: Record "NPR Spfy Resync Run")
    var
        TableNos: List of [Integer];
        UnhandledScopeErr: Label 'Unhandled Shopify re-sync scope %1. This is a programming bug.', Comment = '%1 = scope option value';
    begin
        case ResyncRun.Scope of
            ResyncRun.Scope::"Full Resync":
                begin
                    AllRegisteredShopifyTables(TableNos);
                    ExecuteBulk(ResyncRun, TableNos);
                end;
            ResyncRun.Scope::Area:
                begin
                    ResolveAreaTables(ResyncRun."Integration Area", TableNos);
                    ExecuteBulk(ResyncRun, TableNos);
                end;
            ResyncRun.Scope::"Table":
                begin
                    TableNos.Add(ResyncRun."Table No.");
                    ExecuteBulk(ResyncRun, TableNos);
                end;
            ResyncRun.Scope::Store:
                ExecuteStoreResync(ResyncRun);
            ResyncRun.Scope::"Quiet Seed":
                ExecuteQuietSeed(ResyncRun);   // completes/fails the row itself; on re-raise FailRun above is skipped
            else
                Error(UnhandledScopeErr, Format(ResyncRun.Scope));
        end;
    end;

    local procedure ScopeSlug(Scope: Option "Full Resync","Area",Store,"Table","Quiet Seed"): Text
    begin
        case Scope of
            Scope::"Full Resync":
                exit('full');
            Scope::"Area":
                exit('area');
            Scope::Store:
                exit('store');
            Scope::"Table":
                exit('table');
            Scope::"Quiet Seed":
                exit('quiet-seed');
            else
                exit('unknown');   // telemetry slug only — never throw here
        end;
    end;

    local procedure AllRegisteredShopifyTables(var TableNos: List of [Integer])
    var
        ChangeTracker: Record "NPR Change Tracker";
    begin
        ChangeTracker.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        if ChangeTracker.FindSet() then
            repeat
                TableNos.Add(ChangeTracker."Table No.");
            until ChangeTracker.Next() = 0;
    end;

    local procedure ResolveAreaTables(IntegrationArea: Enum "NPR Spfy Integration Area"; var TableNos: List of [Integer])
    var
        ChangeTracker: Record "NPR Change Tracker";
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
    begin
        // Resolve from the live tracker registration, not a hardcoded list.
        ChangeTracker.SetRange("Integration Type", "NPR Integration Type"::Shopify);
        if ChangeTracker.FindSet() then
            repeat
                if SpfyChangeTrackerMgt.IntegrationAreaForTable(ChangeTracker."Table No.") = IntegrationArea then
                    TableNos.Add(ChangeTracker."Table No.");
            until ChangeTracker.Next() = 0;
    end;

    local procedure ExecuteBulk(var ResyncRun: Record "NPR Spfy Resync Run"; TableNos: List of [Integer])
    var
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        TableNo: Integer;
    begin
        // Phase 1 — baselines first, so even an in-flight poll re-detects.
        foreach TableNo in TableNos do
            if GetTablePolicy(TableNo) = "NPR Spfy Resync Table Policy"::"Baseline Reset" then begin
                ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteBaselinesForTable(TableNo);
                RefreshHeartbeat(ResyncRun);
                Commit();   // each table's delete durable before the next
            end;
        // Phase 2 — marks last, only after every baseline delete is durable.
        foreach TableNo in TableNos do
            case GetTablePolicy(TableNo) of
                "NPR Spfy Resync Table Policy"::"Baseline Reset", "NPR Spfy Resync Table Policy"::"Mark-Only Requeue":
                    begin
                        ChangeTrackerMgt.ResetTracking("NPR Integration Type"::Shopify, TableNo);
                        ResyncRun."Marks Reset" += 1;
                        RefreshHeartbeat(ResyncRun);
                        Commit();
                    end;
                "NPR Spfy Resync Table Policy"::"Fast-Forward Only",
                "NPR Spfy Resync Table Policy"::Blocked:
                    // Mark left untouched in bulk: ILE drains its backlog next cycle (recalcs inventory before the
                    // re-send — fast-forwarding would strand stale qty); vouchers ×3 + Item Price are excluded.
                    ;
            end;
        CompleteRun(ResyncRun);
    end;

    local procedure ExecuteStoreResync(var ResyncRun: Record "NPR Spfy Resync Run")
    var
        ChangeTracker: Record "NPR Change Tracker";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DefaultVariantStoreLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
        MarkTableNos: List of [Integer];
        TableNo: Integer;
        RowsSinceCommit: Integer;
    begin
        // Phase 1 — store-coded baselines. Heartbeat + commit per table: each delete is durable before the next and the transaction stays short.
        ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteBaselinesForTableAndStore(Database::Item, ResyncRun."Store Code");
        RefreshHeartbeat(ResyncRun);
        Commit();
        ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteBaselinesForTableAndStore(Database::"NPR Spfy Store-Item Link", ResyncRun."Store Code");
        RefreshHeartbeat(ResyncRun);
        Commit();
        ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteBaselinesForTableAndStore(Database::"NPR Spfy Item Variant Modif.", ResyncRun."Store Code");
        RefreshHeartbeat(ResyncRun);
        Commit();
        ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteBaselinesForTableAndStore(Database::"NPR Spfy Store-Customer Link", ResyncRun."Store Code");
        RefreshHeartbeat(ResyncRun);
        Commit();
        // Store-link-owned metafield baselines (store-blank rows, scoped via the OWNER links)
        SpfyStoreItemLink.SetRange("Shopify Store Code", ResyncRun."Store Code");
        if SpfyStoreItemLink.FindSet() then
            repeat
                ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteMetafieldBaselinesForOwner(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId());
                // Synthesized default-variant owner (blank Variant Code, physical row may not exist); the Get
                // guard skips rows already enumerated and keeps this 1:1 with PreviewRunCounts.
                if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Item then begin
                    DefaultVariantStoreLink := SpfyStoreItemLink;
                    DefaultVariantStoreLink.Type := DefaultVariantStoreLink.Type::Variant;
                    if not DefaultVariantStoreLink.Get(DefaultVariantStoreLink.Type, DefaultVariantStoreLink."Item No.", DefaultVariantStoreLink."Variant Code", DefaultVariantStoreLink."Shopify Store Code") then
                        ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteMetafieldBaselinesForOwner(Database::"NPR Spfy Store-Item Link", DefaultVariantStoreLink.RecordId());
                end;
                HeartbeatEvery(ResyncRun, RowsSinceCommit);
            until SpfyStoreItemLink.Next() = 0;
        SpfyStoreCustomerLink.SetRange("Shopify Store Code", ResyncRun."Store Code");
        if SpfyStoreCustomerLink.FindSet() then
            repeat
                ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteMetafieldBaselinesForOwner(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.RecordId());
                HeartbeatEvery(ResyncRun, RowsSinceCommit);
            until SpfyStoreCustomerLink.Next() = 0;
        RefreshHeartbeat(ResyncRun);
        Commit();
        if ResyncRun."Include Store-Agnostic" then begin
            // Store-blank baselines affect ALL stores — explicit opt-in only. Clear only Item Variant's
            // structural baseline; Sales/Transfer/SKU are mark-only (their move-key baselines stay — GetTablePolicy),
            // so their store-agnostic marks are reset in phase 2 without deleting the baselines.
            ResyncRun."Baselines Cleared" += SpfySyncStateMgt.DeleteBaselinesForTable(Database::"Item Variant");
            RefreshHeartbeat(ResyncRun);
            Commit();
        end;
        // Phase 2 — marks LAST
        BuildStoreMarkTableList(ResyncRun."Include Store-Agnostic", MarkTableNos);
        foreach TableNo in MarkTableNos do begin
            // ResetTracking exits silently on a missing tracker row — count only what exists, matching the preview.
            if ChangeTracker.Get("NPR Integration Type"::Shopify, TableNo) then begin
                ChangeTrackerMgt.ResetTracking("NPR Integration Type"::Shopify, TableNo);
                ResyncRun."Marks Reset" += 1;
            end;
            RefreshHeartbeat(ResyncRun);
            Commit();
        end;
        // ILE mark untouched: a fast-forward here would discard the pending backlog for ALL stores.
        CompleteRun(ResyncRun);
    end;

    local procedure BuildStoreMarkTableList(IncludeStoreAgnostic: Boolean; var MarkTableNos: List of [Integer])
    begin
        // Shared by ExecuteStoreResync and PreviewRunCounts so executed resets always match the preview.
        Clear(MarkTableNos);
        MarkTableNos.Add(Database::Item);
        MarkTableNos.Add(Database::"NPR Spfy Store-Item Link");
        MarkTableNos.Add(Database::"NPR Spfy Item Variant Modif.");
        MarkTableNos.Add(Database::"NPR Spfy Entity Metafield");
        MarkTableNos.Add(Database::"NPR Spfy Store-Customer Link");
        MarkTableNos.Add(Database::"NPR Spfy Inventory Level");
        if IncludeStoreAgnostic then begin
            MarkTableNos.Add(Database::"Item Variant");
            MarkTableNos.Add(Database::"Sales Line");
            MarkTableNos.Add(Database::"Transfer Line");
            MarkTableNos.Add(Database::"Stockkeeping Unit");
        end;
    end;

    internal procedure PreviewRunCounts(var ResyncRun: Record "NPR Spfy Resync Run"; var BaselineCount: Integer; var MarkCount: Integer)
    var
        ChangeTracker: Record "NPR Change Tracker";
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        DefaultVariantStoreLink: Record "NPR Spfy Store-Item Link";
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
        SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        MarkTableNos: List of [Integer];
        TableNos: List of [Integer];
        TableNo: Integer;
    begin
        BaselineCount := 0;
        MarkCount := 0;
        case ResyncRun.Scope of
            ResyncRun.Scope::"Full Resync":
                AllRegisteredShopifyTables(TableNos);
            ResyncRun.Scope::Area:
                ResolveAreaTables(ResyncRun."Integration Area", TableNos);
            ResyncRun.Scope::"Table":
                TableNos.Add(ResyncRun."Table No.");
            ResyncRun.Scope::Store:
                begin
                    BaselineCount += SpfySyncStateMgt.CountBaselinesForTableAndStore(Database::Item, ResyncRun."Store Code");
                    BaselineCount += SpfySyncStateMgt.CountBaselinesForTableAndStore(Database::"NPR Spfy Store-Item Link", ResyncRun."Store Code");
                    BaselineCount += SpfySyncStateMgt.CountBaselinesForTableAndStore(Database::"NPR Spfy Item Variant Modif.", ResyncRun."Store Code");
                    BaselineCount += SpfySyncStateMgt.CountBaselinesForTableAndStore(Database::"NPR Spfy Store-Customer Link", ResyncRun."Store Code");
                    SpfyStoreItemLink.SetRange("Shopify Store Code", ResyncRun."Store Code");
                    if SpfyStoreItemLink.FindSet() then
                        repeat
                            BaselineCount += SpfySyncStateMgt.CountMetafieldBaselinesForOwner(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId());
                            // Mirrors ExecuteStoreResync's synthesized owner; the Get guard prevents double-counting.
                            if SpfyStoreItemLink.Type = SpfyStoreItemLink.Type::Item then begin
                                DefaultVariantStoreLink := SpfyStoreItemLink;
                                DefaultVariantStoreLink.Type := DefaultVariantStoreLink.Type::Variant;
                                if not DefaultVariantStoreLink.Get(DefaultVariantStoreLink.Type, DefaultVariantStoreLink."Item No.", DefaultVariantStoreLink."Variant Code", DefaultVariantStoreLink."Shopify Store Code") then
                                    BaselineCount += SpfySyncStateMgt.CountMetafieldBaselinesForOwner(Database::"NPR Spfy Store-Item Link", DefaultVariantStoreLink.RecordId());
                            end;
                        until SpfyStoreItemLink.Next() = 0;
                    SpfyStoreCustomerLink.SetRange("Shopify Store Code", ResyncRun."Store Code");
                    if SpfyStoreCustomerLink.FindSet() then
                        repeat
                            BaselineCount += SpfySyncStateMgt.CountMetafieldBaselinesForOwner(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.RecordId());
                        until SpfyStoreCustomerLink.Next() = 0;
                    if ResyncRun."Include Store-Agnostic" then
                        // Only Item Variant's baseline is cleared store-agnostic; Sales/Transfer/SKU are mark-only.
                        BaselineCount += SpfySyncStateMgt.CountBaselinesForTable(Database::"Item Variant");
                    // Same list + existence gate as ExecuteStoreResync so the counters can't diverge.
                    BuildStoreMarkTableList(ResyncRun."Include Store-Agnostic", MarkTableNos);
                    foreach TableNo in MarkTableNos do
                        if ChangeTracker.Get("NPR Integration Type"::Shopify, TableNo) then
                            MarkCount += 1;
                    exit;
                end;
        end;
        foreach TableNo in TableNos do
            case GetTablePolicy(TableNo) of
                "NPR Spfy Resync Table Policy"::"Baseline Reset":
                    begin
                        BaselineCount += SpfySyncStateMgt.CountBaselinesForTable(TableNo);
                        MarkCount += 1;
                    end;
                "NPR Spfy Resync Table Policy"::"Mark-Only Requeue":
                    MarkCount += 1;
                "NPR Spfy Resync Table Policy"::"Fast-Forward Only",
                "NPR Spfy Resync Table Policy"::Blocked:
                    ;   // ILE left untouched; vouchers/prices blocked — neither contributes to the preview counts
            end;
    end;

    local procedure LogRunTelemetry(Stage: Text; ResyncRun: Record "NPR Spfy Resync Run"; ErrorText: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
        LogVerbosity: Verbosity;
    begin
        CustomDimensions.Add('NPR_Stage', Stage);
        CustomDimensions.Add('NPR_Scope', ScopeSlug(ResyncRun.Scope));
        CustomDimensions.Add('NPR_StoreCode', ResyncRun."Store Code");
        CustomDimensions.Add('NPR_TableNo', Format(ResyncRun."Table No."));
        CustomDimensions.Add('NPR_IntegrationArea', Format(ResyncRun."Integration Area"));
        CustomDimensions.Add('NPR_IncludeStoreAgnostic', Format(ResyncRun."Include Store-Agnostic"));
        CustomDimensions.Add('NPR_BaselinesCleared', Format(ResyncRun."Baselines Cleared"));
        CustomDimensions.Add('NPR_MarksReset', Format(ResyncRun."Marks Reset"));
        LogVerbosity := Verbosity::Normal;
        if ErrorText <> '' then begin
            CustomDimensions.Add('NPR_ErrorText', ErrorText);
            LogVerbosity := Verbosity::Error;
        end;
        Session.LogMessage('Shopify_Resync', StrSubstNo('Shopify re-sync run %1 (%2)', Stage, ScopeSlug(ResyncRun.Scope)),
            LogVerbosity, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;

    internal procedure StartQuietSeed()
    var
        ResyncRun: Record "NPR Spfy Resync Run";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        RunForeground: Boolean;
        QuietSeedQst: Label 'Quiet-seed overwrites ALL Shopify sync baselines with the current computed BC state WITHOUT sending anything to Shopify. Use it when the baselines are wrong but Shopify is already correct.\\WARNING: any genuinely pending, un-sent change to a baseline-tracked value is absorbed and will NOT be sent.\\Continue?';
        PreCutoverErr: Label 'The quiet-seed is only available once Shopify runs fully on RowVersion detection. Before cut-over, use the "Seed RowVersion Baselines" migration action instead.';
    begin
        CheckFeatureEnabled();
        // Post-cutover gate: feature ON and Shopify no longer on Data Log (also holds for born-on-RowVersion).
        if not (SpfyRowVersionFeature.IsFeatureEnabled() and not SpfyIntegrationMgt.RunsShopifyOnDataLog()) then
            Error(PreCutoverErr);
        if not Confirm(QuietSeedQst, false) then
            exit;
        if not PromptRunMode(RunForeground) then
            exit;
        ResyncRun.Scope := ResyncRun.Scope::"Quiet Seed";
        LaunchRun(ResyncRun, RunForeground);
    end;

    local procedure ExecuteQuietSeed(var ResyncRun: Record "NPR Spfy Resync Run")
    var
        SeedWorker: Codeunit "NPR Spfy Sync St. Seed Worker";
        LastError: Text;
    begin
        // Bypasses RunSeedingSweep: its Mark* wrappers would regress the Migration Status.
        SeedWorker.SetBaselinesOnly(true);
        SeedWorker.SetShowProgress(GuiAllowed());
        SeedWorker.SetResyncRunEntryNo(ResyncRun."Entry No.");
        ClearLastError();
        if SeedWorker.Run() then begin
            // The worker heartbeated this row via another instance — re-read or the Modify below throws.
            ResyncRun.Get(ResyncRun."Entry No.");
            ResyncRun."Entities Processed" := SeedWorker.GetProcessedCount();
            CompleteRun(ResyncRun);
            exit;
        end;
        // Partial adoption on failure is expected (batched commits) — re-running is idempotent.
        LastError := NonEmptyError(GetLastErrorText());
        if ResyncRun.Get(ResyncRun."Entry No.") then begin
            ResyncRun."Entities Processed" := SeedWorker.GetProcessedCount();
            FailRun(ResyncRun, LastError);
        end;
        Error('%1', LastError);
    end;

    local procedure PromptRunMode(var RunForeground: Boolean): Boolean
    var
        ModeInstructionLbl: Label 'How should the re-sync run?\\Run in foreground = run now in this session (blocking) — fine for a small scope.\Run in background = run as a Job Queue task (recommended for full / large scopes); progress is visible on the Shopify Re-sync Runs page.';
        ModeOptionsLbl: Label 'Run in foreground,Run in background';
    begin
        case StrMenu(ModeOptionsLbl, 2, ModeInstructionLbl) of
            1:
                RunForeground := true;
            2:
                RunForeground := false;
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure LaunchRun(var ResyncRun: Record "NPR Spfy Resync Run"; RunForeground: Boolean)
    var
        SpfyScheduleResyncJQ: Codeunit "NPR Spfy Schedule Resync JQ";
        LastError: Text;
        ScheduledMsg: Label 'The re-sync was scheduled as a background job. Follow its progress on the Shopify Re-sync Runs page.';
        CompletedMsg: Label 'Re-sync completed: %1 baseline(s) cleared, %2 tracker mark(s) reset. The detection job re-sends the data over its next cycles.', Comment = '%1, %2 = counts';
        QuietSeedCompletedMsg: Label 'Quiet-seed completed: %1 entities re-baselined. Nothing was sent to Shopify.', Comment = '%1 = number of entities processed';
    begin
        // Launch mode recorded on the row: the worker refuses runs not launched as Background.
        if RunForeground then
            ResyncRun."Launch Mode" := ResyncRun."Launch Mode"::Foreground
        else
            ResyncRun."Launch Mode" := ResyncRun."Launch Mode"::Background;
        StartRun(ResyncRun);   // marker committed from here
        if RunForeground then begin
            ExecuteRun(ResyncRun);   // re-Finds the row, so the counts below are DB-fresh
            if GuiAllowed() then
                // Quiet Seed clears nothing — the generic '0 baseline(s) cleared' text would read as a failure.
                if ResyncRun.Scope = ResyncRun.Scope::"Quiet Seed" then
                    Message(QuietSeedCompletedMsg, ResyncRun."Entities Processed")
                else
                    Message(CompletedMsg, ResyncRun."Baselines Cleared", ResyncRun."Marks Reset");
        end else begin
            // On scheduling failure, fail the row immediately — release the detection-pause marker instead of
            // waiting for the 15-min reap.
            ClearLastError();
            if not SpfyScheduleResyncJQ.Run(ResyncRun) then begin
                LastError := NonEmptyError(GetLastErrorText());
                FailRun(ResyncRun, LastError);
                LogRunTelemetry('failed', ResyncRun, LastError);
                Error('%1', LastError);
            end;
            if GuiAllowed() then
                Message(ScheduledMsg);
        end;
    end;

    internal procedure StartFullResync()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ResyncRun: Record "NPR Spfy Resync Run";
        BaselineCount: Integer;
        MarkCount: Integer;
        RunForeground: Boolean;
        FullResyncQst: Label 'A FULL re-sync clears all Shopify sync baselines and re-scans every tracked table. Every synced product, variant, customer, metafield and inventory level will be re-sent to Shopify. %1 and %2 are excluded.\\Continue?', Comment = '%1, %2 = excluded integration area captions';
        FullResyncCountsQst: Label 'This will clear %1 stored baseline(s) and reset %2 tracker mark(s). The %3 mark is left untouched — its pending inventory backlog re-syncs over the next detection cycles.\\Are you sure you want to run the full re-sync?', Comment = '%1 = baseline row count, %2 = reset tracker mark count, %3 = Item Ledger Entry table caption';
    begin
        CheckFeatureEnabled();
        if not Confirm(FullResyncQst, false, Format("NPR Spfy Integration Area"::"Retail Vouchers"), Format("NPR Spfy Integration Area"::"Item Prices")) then
            exit;
        ResyncRun.Scope := ResyncRun.Scope::"Full Resync";
        PreviewRunCounts(ResyncRun, BaselineCount, MarkCount);
        if not Confirm(FullResyncCountsQst, false, BaselineCount, MarkCount, ItemLedgerEntry.TableCaption()) then
            exit;
        if not PromptRunMode(RunForeground) then
            exit;
        LaunchRun(ResyncRun, RunForeground);
    end;

    internal procedure StartStoreResync()
    var
        ShopifyStore: Record "NPR Spfy Store";
        ResyncRun: Record "NPR Spfy Resync Run";
        BaselineCount: Integer;
        MarkCount: Integer;
        RunForeground: Boolean;
        IncludeAgnosticQst: Label 'Also clear store-agnostic baselines (variant structural data and inventory move-keys)?\\WARNING: these are shared — clearing them re-sends variants and recomputes inventory for ALL stores, not only %1.', Comment = '%1 = store code';
        StoreResyncQst: Label 'Re-sync Shopify store %1: this clears %2 stored baseline(s), resets %3 tracker mark(s) and re-sends the store''s synced data. Inventory levels are re-sent for all stores (shared tracker). %4 and %5 are excluded.\\Continue?', Comment = '%1 = store code, %2 = baseline count, %3 = mark count, %4, %5 = excluded integration area captions';
    begin
        CheckFeatureEnabled();
        if not SelectShopifyStore(ShopifyStore) then
            exit;
        ResyncRun.Scope := ResyncRun.Scope::Store;
        ResyncRun."Store Code" := ShopifyStore.Code;
        ResyncRun."Include Store-Agnostic" := Confirm(IncludeAgnosticQst, false, ShopifyStore.Code);
        PreviewRunCounts(ResyncRun, BaselineCount, MarkCount);
        if not Confirm(StoreResyncQst, false, ShopifyStore.Code, BaselineCount, MarkCount, Format("NPR Spfy Integration Area"::"Retail Vouchers"), Format("NPR Spfy Integration Area"::"Item Prices")) then
            exit;
        if not PromptRunMode(RunForeground) then
            exit;
        LaunchRun(ResyncRun, RunForeground);
    end;

    internal procedure StartAreaResync()
    var
        ResyncRun: Record "NPR Spfy Resync Run";
        BaselineCount: Integer;
        MarkCount: Integer;
        RunForeground: Boolean;
        Selected: Integer;
        AreaOptionsLbl: Label 'Item List,Inventory,Sales Orders (Customers),Metafields,Item Prices';
        AreaInstructionLbl: Label 'Select the integration area to re-sync. Its baselines are cleared and its tracked tables re-scanned.';
        AreaResyncQst: Label 'Re-sync the %1 area: this clears %2 stored baseline(s) and resets %3 tracker mark(s). Metafields are their own area; run the Metafields area, a store re-sync, or a full re-sync to re-push metafields.\\Continue?', Comment = '%1 = area caption, %2 = baseline count, %3 = reset mark count';
        PricesNotResyncableErr: Label '%1 cannot be re-synced this way: price suppression is a value-gate with no stored baseline, so there is no drift to recover. A price re-push is separate price tooling.', Comment = '%1 = integration area caption';
    begin
        CheckFeatureEnabled();
        Selected := StrMenu(AreaOptionsLbl, 0, AreaInstructionLbl);
        case Selected of
            0:
                exit;
            1:
                ResyncRun."Integration Area" := "NPR Spfy Integration Area"::Items;
            2:
                ResyncRun."Integration Area" := "NPR Spfy Integration Area"::"Inventory Levels";
            3:
                ResyncRun."Integration Area" := "NPR Spfy Integration Area"::"Sales Orders";
            4:
                ResyncRun."Integration Area" := "NPR Spfy Integration Area"::Metafields;
            5:
                Error(PricesNotResyncableErr, Format("NPR Spfy Integration Area"::"Item Prices"));   // listed so the exclusion is discoverable
        end;
        ResyncRun.Scope := ResyncRun.Scope::Area;
        PreviewRunCounts(ResyncRun, BaselineCount, MarkCount);
        if not Confirm(AreaResyncQst, false, Format(ResyncRun."Integration Area"), BaselineCount, MarkCount) then
            exit;
        if not PromptRunMode(RunForeground) then
            exit;
        LaunchRun(ResyncRun, RunForeground);
    end;

    internal procedure StartTableResync(TableNo: Integer)
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        ResyncRun: Record "NPR Spfy Resync Run";
        RecRef: RecordRef;
        TableCaptionText: Text;
        BaselineCount: Integer;
        MarkCount: Integer;
        RunForeground: Boolean;
        TableResyncQst: Label 'Reset tracking for table %1: this clears %2 stored baseline(s), resets the mark to 0 and re-scans the whole table. For inventory trigger tables (Sales/Transfer/SKU) this recomputes open-line inventory and rebuilds move-key tracking; only changed quantities are re-sent.\\Continue?', Comment = '%1 = table caption, %2 = baseline count';
        VoucherBlockedErr: Label 'Tracking for %1 cannot be reset: wiping voucher baselines would make the next real Ending Date change re-adopt silently WITHOUT a send (a one-shot missed change per voucher). Voucher re-push is driven by the voucher''s own issue/top-up/archive lifecycle.', Comment = '%1 = integration area caption';
        PriceBlockedErr: Label 'Tracking for %1 cannot be reset: price suppression is a value-gate with no stored baseline, so a reset recovers nothing.', Comment = '%1 = integration area caption';
        IleBlockedErr: Label 'The %1 mark cannot be reset to 0: re-scanning a multi-million-row ledger recomputes inventory for days. Use "Fast-forward Mark to Current Max" instead; a true full inventory recompute is the Update Inventory job''s task.', Comment = '%1 = Item Ledger Entry table caption';
    begin
        CheckFeatureEnabled();
        case GetTablePolicy(TableNo) of
            "NPR Spfy Resync Table Policy"::Blocked:
                if TableNo = Database::"NPR Spfy Item Price" then
                    Error(PriceBlockedErr, Format("NPR Spfy Integration Area"::"Item Prices"))
                else
                    Error(VoucherBlockedErr, Format("NPR Spfy Integration Area"::"Retail Vouchers"));
            "NPR Spfy Resync Table Policy"::"Fast-Forward Only":
                Error(IleBlockedErr, ItemLedgerEntry.TableCaption());
        end;
        ResyncRun.Scope := ResyncRun.Scope::"Table";
        ResyncRun."Table No." := TableNo;
        PreviewRunCounts(ResyncRun, BaselineCount, MarkCount);
        RecRef.Open(TableNo);
        TableCaptionText := RecRef.Caption();
        RecRef.Close();
        if not Confirm(TableResyncQst, false, TableCaptionText, BaselineCount) then
            exit;
        if not PromptRunMode(RunForeground) then
            exit;
        LaunchRun(ResyncRun, RunForeground);
    end;

    local procedure SelectShopifyStore(var ShopifyStore: Record "NPR Spfy Store"): Boolean
    begin
        if ShopifyStore.Count() = 1 then
            exit(ShopifyStore.FindFirst());
        exit(Page.RunModal(0, ShopifyStore) = Action::LookupOK);
    end;
}

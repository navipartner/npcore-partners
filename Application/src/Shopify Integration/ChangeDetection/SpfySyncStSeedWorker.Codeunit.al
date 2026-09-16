codeunit 6151239 "NPR Spfy Sync St. Seed Worker"
{
    Access = Internal;

    // Uses only UNGATED builders — writes baselines while the feature is still OFF.
    var
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _SpfySyncStateMgt: Codeunit "NPR Spfy Sync State Mgt";
        _SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        _SpfyItemTaskBuilder: Codeunit "NPR Spfy Item Task Builder";
        _SpfyInventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
        _SpfyRetailVoucherMgt: Codeunit "NPR Spfy Retail Voucher Mgt.";
        _SpfyRowVersionMigration: Codeunit "NPR Spfy RowVersion Migration";
        _SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
        _ShowProgress: Boolean;
        _BaselinesOnly: Boolean;
        _ResyncRunEntryNo: BigInteger;
        _Window: Dialog;
        _ProcessedCount: Integer;
        _StartedAt: DateTime;
        _LastHeartbeatAt: DateTime;
        _CommitBatchSize: Integer;
        _UncommittedCount: Integer;
        ProgressMsg: Label 'Seeding Shopify RowVersion baselines...\\Processed: #1######### entities\Elapsed: #2######### s', Comment = '#1 = processed count, #2 = elapsed seconds';

    trigger OnRun()
    begin
        RunSweepWork();
    end;

    internal procedure SetShowProgress(NewShowProgress: Boolean)
    begin
        _ShowProgress := NewShowProgress;
    end;

    internal procedure SetBaselinesOnly(NewBaselinesOnly: Boolean)
    begin
        _BaselinesOnly := NewBaselinesOnly;
    end;

    internal procedure SetResyncRunEntryNo(NewResyncRunEntryNo: BigInteger)
    begin
        // Quiet-seed sets this so the heartbeat targets its own run row; left 0 by the migration path (no-op there).
        _ResyncRunEntryNo := NewResyncRunEntryNo;
    end;

    internal procedure GetProcessedCount(): Integer
    begin
        // Variable state survives a failed Codeunit.Run, so the count is available on the failure path too.
        exit(_ProcessedCount);
    end;

    local procedure RunSweepWork()
    begin
        _ShowProgress := _ShowProgress and GuiAllowed();
        _CommitBatchSize := 200;
        _ProcessedCount := 0;
        _UncommittedCount := 0;
        _StartedAt := CurrentDateTime();
        _LastHeartbeatAt := _StartedAt;
        LogTelemetry('started', '');

        if _ShowProgress then
            _Window.Open(ProgressMsg);

        SeedItemAndVariantBaselines();
        SeedInventoryTriggerBaselines();
        SeedCustomerBaselines();
        SeedVoucherBaselines();
        CommitBatch(true);

        if not _BaselinesOnly then begin
            // After baseline seeding, so the marks sit at the cut-over high-water mark. The quiet-seed leaves
            // marks untouched (pending backlog keeps processing).
            SeedTrackerMarks();
            CommitBatch(true);
        end;

        if _ShowProgress then
            _Window.Close();
        LogTelemetry('completed', '');
    end;

    local procedure SeedItemAndVariantBaselines()
    var
        Item: Record Item;
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
        LastItemNo: Code[20];
        ItemFound: Boolean;
    begin
        if not FilterAllSyncedProductLinks(SpfyStoreItemLink) then
            exit;
        if not SpfyStoreItemLink.FindSet() then
            exit;
        repeat
            ScanHeartbeat();   // orphaned links skip CountOne — a long skip stretch must still heartbeat
            if SpfyStoreItemLink."Item No." <> LastItemNo then
                ItemFound := Item.Get(SpfyStoreItemLink."Item No.");
            if ItemFound then begin
                // The product-payload hash is load-bearing: without it the first poll re-sends the whole product.
                _SpfySyncStateMgt.SeedItemBaseline(Item, SpfyStoreItemLink."Shopify Store Code");
                _SpfySyncStateMgt.SeedStoreItemLinkBaseline(SpfyStoreItemLink);
                CountOne();
                SeedMetafieldBaselinesForOwner(Database::"NPR Spfy Store-Item Link", SpfyStoreItemLink.RecordId());
                if SpfyStoreItemLink."Item No." <> LastItemNo then begin
                    SeedVariantBaselinesForItem(SpfyStoreItemLink."Item No.");
                    SeedItemVariantModifBaselinesForItem(SpfyStoreItemLink."Item No.");
                end;
            end;
            LastItemNo := SpfyStoreItemLink."Item No.";
        until SpfyStoreItemLink.Next() = 0;
    end;

    local procedure FilterAllSyncedProductLinks(var SpfyStoreItemLink: Record "NPR Spfy Store-Item Link"): Boolean
    begin
        Clear(SpfyStoreItemLink);
        SpfyStoreItemLink.SetAutoCalcFields("Store Integration Is Enabled");
        SpfyStoreItemLink.SetRange(Type, SpfyStoreItemLink.Type::Item);
        SpfyStoreItemLink.SetRange("Variant Code", '');
        SpfyStoreItemLink.SetFilter("Shopify Store Code", '<>%1', '');
        SpfyStoreItemLink.SetRange("Sync. to this Store", true);
        SpfyStoreItemLink.SetRange("Store Integration Is Enabled", true);
        exit(true);
    end;

    local procedure SeedVariantBaselinesForItem(ItemNo: Code[20])
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.SetRange("Item No.", ItemNo);
        if ItemVariant.FindSet() then
            repeat
                ScanHeartbeat();   // unassigned variants skip CountOne
                if SeedVariantIfAssigned(ItemVariant) then
                    CountOne();
            until ItemVariant.Next() = 0;
    end;

    local procedure SeedVariantIfAssigned(var ItemVariant: Record "Item Variant"): Boolean
    var
        SpfyStoreItemLink: Record "NPR Spfy Store-Item Link";
    begin
        if not _SpfyStoreLinkMgt.FilterStoreItemLinksToSync(ItemVariant."Item No.", SpfyStoreItemLink) then
            exit(false);
        if SpfyStoreItemLink.FindSet() then
            repeat
                if _SpfyItemTaskBuilder.GetAssignedShopifyVariantID(ItemVariant."Item No.", ItemVariant.Code, SpfyStoreItemLink."Shopify Store Code", false) <> '' then begin
                    _SpfySyncStateMgt.SeedItemVariantBaseline(ItemVariant);
                    exit(true);
                end;
            until SpfyStoreItemLink.Next() = 0;
        exit(false);
    end;

    local procedure SeedItemVariantModifBaselinesForItem(ItemNo: Code[20])
    var
        SpfyItemVariantModif: Record "NPR Spfy Item Variant Modif.";
    begin
        SpfyItemVariantModif.SetRange("Item No.", ItemNo);
        if SpfyItemVariantModif.FindSet() then
            repeat
                ScanHeartbeat();
                if SpfyItemVariantModif."Shopify Store Code" <> '' then begin
                    _SpfySyncStateMgt.SeedItemVariantModifBaseline(SpfyItemVariantModif);
                    CountOne();
                end;
            until SpfyItemVariantModif.Next() = 0;
    end;

    local procedure SeedMetafieldBaselinesForOwner(OwnerTableNo: Integer; OwnerRecordId: RecordId)
    var
        SpfyEntityMetafield: Record "NPR Spfy Entity Metafield";
    begin
        SpfyEntityMetafield.SetRange("Table No.", OwnerTableNo);
        SpfyEntityMetafield.SetRange("BC Record ID", OwnerRecordId);
        if SpfyEntityMetafield.FindSet() then
            repeat
                _SpfySyncStateMgt.SeedEntityMetafieldBaseline(SpfyEntityMetafield);
                CountOne();
            until SpfyEntityMetafield.Next() = 0;
    end;

    local procedure SeedInventoryTriggerBaselines()
    var
        SKU: Record "Stockkeeping Unit";
        SalesLine: Record "Sales Line";
        TransferLine: Record "Transfer Line";
    begin
        if not _SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Inventory Levels") then
            exit;

        SKU.SetLoadFields("Item No.", "Variant Code", "Location Code", "NPR Spfy Safety Stock Quantity");
        if SKU.FindSet() then
            repeat
                ScanHeartbeat();
                if _SpfyInventoryLevelMgt.IsShopifyInventoryItem(SKU."Item No.") then begin
                    _SpfySyncStateMgt.SetSkuInvKey(SKU);
                    CountOne();
                end;
            until SKU.Next() = 0;

        SalesLine.SetRange("Document Type", SalesLine."Document Type"::Order);
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.FindSet() then
            repeat
                ScanHeartbeat();
                if _SpfyInventoryLevelMgt.SalesLineInScope(SalesLine) then
                    if _SpfyInventoryLevelMgt.IsShopifyInventoryItem(SalesLine."No.") then begin
                        _SpfySyncStateMgt.SetSalesLineInvKey(SalesLine);
                        CountOne();
                    end;
            until SalesLine.Next() = 0;

        if _SpfyIntegrationMgt.IncludeTrasferOrdersAnyStore() then begin
            TransferLine.SetFilter("Item No.", '<>%1', '');
            if TransferLine.FindSet() then
                repeat
                    ScanHeartbeat();
                    if _SpfyInventoryLevelMgt.TransferLineInScope(TransferLine) then
                        if _SpfyInventoryLevelMgt.IsShopifyInventoryItem(TransferLine."Item No.") then begin
                            _SpfySyncStateMgt.SetTransferLineInvKey(TransferLine);
                            CountOne();
                        end;
                until TransferLine.Next() = 0;
        end;
    end;

    local procedure SeedCustomerBaselines()
    var
        SpfyStoreCustomerLink: Record "NPR Spfy Store-Customer Link";
    begin
        if not _SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders") then
            exit;

        SpfyStoreCustomerLink.SetRange("Sync. to this Store", true);
        if SpfyStoreCustomerLink.FindSet() then
            repeat
                ScanHeartbeat();   // disabled-area links skip CountOne
                if _SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", SpfyStoreCustomerLink."Shopify Store Code") then begin
                    _SpfySyncStateMgt.SeedStoreCustomerLinkBaseline(SpfyStoreCustomerLink);
                    CountOne();
                    SeedMetafieldBaselinesForOwner(Database::"NPR Spfy Store-Customer Link", SpfyStoreCustomerLink.RecordId());
                end;
            until SpfyStoreCustomerLink.Next() = 0;
    end;

    local procedure SeedVoucherBaselines()
    var
        Voucher: Record "NPR NpRv Voucher";
        StoreCode: Code[20];
    begin
        if not _SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Retail Vouchers") then
            exit;

        if Voucher.FindSet() then
            repeat
                ScanHeartbeat();
                if ResolveVoucherStore(Voucher, StoreCode) then
                    if _SpfyRetailVoucherMgt.IsShopifySyncedVoucher(Voucher.RecordId()) then begin
                        _SpfySyncStateMgt.SeedVoucherBaseline(Voucher, StoreCode);
                        CountOne();
                    end;
            until Voucher.Next() = 0;
    end;

    local procedure ResolveVoucherStore(Voucher: Record "NPR NpRv Voucher"; var StoreCode: Code[20]): Boolean
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        StoreCode := '';
        if Voucher."No." = '' then
            exit(false);
        if not _SpfyRetailVoucherMgt.IsShopifyIntegratedVoucherType(Voucher."Voucher Type") then
            exit(false);
        if not VoucherType.Get(Voucher."Voucher Type") then
            exit(false);
        StoreCode := VoucherType.GetStoreCode();
        exit(_SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Retail Vouchers", StoreCode));
    end;

    local procedure SeedTrackerMarks()
    var
        SpfyChangeTrackerMgt: Codeunit "NPR Spfy Change Tracker Mgt.";
        ChangeTrackerMgt: Codeunit "NPR Change Tracker Mgt";
    begin
        SpfyChangeTrackerMgt.RegisterEnabledTables();
        ChangeTrackerMgt.ReseedAllMarksToCurrentMax("NPR Integration Type"::Shopify);
    end;

    local procedure CountOne()
    begin
        _ProcessedCount += 1;
        _UncommittedCount += 1;
        if _UncommittedCount >= _CommitBatchSize then
            CommitBatch(false);
        if _ShowProgress and (_ProcessedCount mod 50 = 0) then
            UpdateProgress();
    end;

    local procedure CommitBatch(Force: Boolean)
    begin
        if (_UncommittedCount = 0) and not Force then
            exit;
        _SpfyRowVersionMigration.RefreshRunHeartbeat();
        _SpfyResyncMgt.RefreshRunHeartbeat(_ResyncRunEntryNo);   // no-op (EntryNo 0) on the migration path
        Commit();
        _UncommittedCount := 0;
        _LastHeartbeatAt := CurrentDateTime();
    end;

    // Heartbeat on sparse scans so a huge low-hit table isn't misclassified as a crashed (stale) run.
    local procedure ScanHeartbeat()
    begin
        if (CurrentDateTime() - _LastHeartbeatAt) < 60000 then
            exit;
        CommitBatch(true);
    end;

    local procedure UpdateProgress()
    begin
        _Window.Update(1, _ProcessedCount);
        _Window.Update(2, ElapsedSeconds());
    end;

    local procedure ElapsedSeconds(): Integer
    begin
        exit((CurrentDateTime() - _StartedAt) div 1000);
    end;

    local procedure LogTelemetry(Stage: Text; Detail: Text)
    var
        CustomDimensions: Dictionary of [Text, Text];
    begin
        CustomDimensions.Add('NPR_Stage', Stage);
        CustomDimensions.Add('NPR_ProcessedCount', Format(_ProcessedCount));
        CustomDimensions.Add('NPR_ElapsedSeconds', Format(ElapsedSeconds()));
        if Detail <> '' then
            CustomDimensions.Add('NPR_Detail', CopyStr(Detail, 1, 250));
        Session.LogMessage('Shopify_RowVersionSeeding', StrSubstNo('RowVersion seeding %1 (%2 entities)', Stage, _ProcessedCount),
            Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, CustomDimensions);
    end;
}

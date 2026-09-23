#if not BC17
page 6184553 "NPR Spfy Integration Setup"
{
    Extensible = false;
    Caption = 'Shopify Integration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR Spfy Integration Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRShopify;
    ContextSensitiveHelpPage = 'shopifyintegration.html';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Enable Integration"; Rec."Enable Integration")
                {
                    ToolTip = 'Specifies whether the integration is enabled. This is the master on/off switch for the integration.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Api Version"; Rec."Shopify Api Version")
                {
                    ToolTip = 'Specifies the Shopify API version used when exchanging data with Shopify. Leave this at the recommended version, which the integration has been tested against, unless you have a specific reason to change it.';
                    ApplicationArea = NPRShopify;
                }
                field("Data Processing Handler ID"; Rec."Data Processing Handler ID")
                {
                    ToolTip = 'Specifies a code used by the system to identify the import types, task processor and data log subscribers associated with the Shopify integration.';
                    ApplicationArea = NPRShopify;
                }
                field("Enable Product Variant Sorting"; Rec."Enable Product Variant Sorting")
                {
                    ToolTip = 'Specifies whether the system re-sequences the product variant options in Shopify to match the variety value sort order defined in Business Central. When enabled, the order is applied automatically after products and variants are synced, and the manual "Update Variant Sorting Order" action becomes available on the item. When disabled, no reordering is performed.';
                    ApplicationArea = NPRShopify;
                }
            }
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
            group(Processing)
            {
                Caption = 'Document Processing';
                field("Max Doc Process Retry Count"; Rec."Max Doc Process Retry Count")
                {
                    ToolTip = 'Specifies the maximum number of times the system will attempt to process a sales order document from Shopify if an error occurs during processing. When this limit is reached, no further retries will be made, and the document will be marked as failed.';
                    ApplicationArea = NPRShopifyEcommerce;
                }
            }
#endif
            group(RowVersionSeeding)
            {
                Caption = 'RowVersion Change Detection';
                Visible = ShowRowVersionMigrationUI;
                field("RowVersion Migration Status"; Rec."RowVersion Migration Status")
                {
                    ToolTip = 'Specifies the status of the RowVersion change-detection migration (CORE-433): the baseline seeding sweep and the one-way cutover from the Data Log. Cutover runs once the status shows Seeded.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("RowVersion Seeding Started At"; Rec."RowVersion Seeding Started At")
                {
                    ToolTip = 'Specifies when the RowVersion baseline seeding sweep started.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("RowVersion Seeding Compl. At"; Rec."RowVersion Seeding Compl. At")
                {
                    ToolTip = 'Specifies when the RowVersion baseline seeding sweep completed.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("RowVersion Seeding Error Text"; Rec."RowVersion Seeding Error Text")
                {
                    ToolTip = 'Specifies the error text of the most recent failed step of the RowVersion migration: the baseline seeding sweep, the scheduling of its background job, or the cutover itself.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
            }
            group(TaskListMigration)
            {
                Caption = 'Shopify Task List Migration';
                Visible = _ShowTaskListMigrationUI;
                field("Task List Migration Status"; Rec."Task List Migration Status")
                {
                    ToolTip = 'Specifies the status of the one-way migration from the NaviConnect task list to the Shopify task list. A failed migration can be run again with the "Migrate to Shopify Task List" action.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Task List Migr. Started At"; Rec."Task List Migr. Started At")
                {
                    ToolTip = 'Specifies when the most recent Shopify task list migration run started.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
            }
            part(ShopifyStores; "NPR Spfy Stores Subpage")
            {
                ApplicationArea = NPRShopify;
            }
        }

        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = NPRShopify;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = NPRShopify;
                Visible = false;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            group(InitialSetup)
            {
                Caption = 'Initial Setup';
                action(SyncItems)
                {
                    Caption = 'Sync. Items';
                    ToolTip = 'Executes initial item synchronization between BC and Shopify. The system will iterate through items in BC and identify those that already exist in Shopify. The system will also update item statuses, names, descriptions and metafields from Shopify and create requests to assign product tags in Shopify based on the item categories selected for the items in BC.';
                    ApplicationArea = NPRShopify;
                    Image = CheckList;

                    trigger OnAction()
                    var
                        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
                    begin
                        CurrPage.SaveRecord();
                        SendItemAndInventory.EnableIntegrationForItemsAlreadyOnShopify(SelectShopifyStore(), true);
                    end;
                }
                action(SyncCustomers)
                {
                    Caption = 'Sync. Customers';
                    ToolTip = 'Executes initial customer synchronization between BC and Shopify. The system will iterate through customers in BC and identify those that already exist in Shopify. The system will also update customer information from Shopify.';
                    ApplicationArea = NPRShopify;
                    Image = CheckList;

                    trigger OnAction()
                    var
                        SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
                    begin
                        CurrPage.SaveRecord();
                        SpfySendCustomers.EnableIntegrationForCustomersAlreadyOnShopify(SelectShopifyStore(), true);
                    end;
                }
                action(SyncRetailVouchers)
                {
                    Caption = 'Sync. Vouchers';
                    ToolTip = 'Executes intial retail voucher migration from BC to Shopify. System will go through retail vouchers in BC and create those marked as synchronizable with your selected Shopify Store as gift cards at the store. System will also update gift cards balances at Shopify, if needed.';
                    ApplicationArea = NPRShopify;
                    Image = Migration;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        Report.Run(Report::"NPR Spfy Initial Voucher Sync", true);
                    end;
                }
                group(ItemCategory)
                {
                    Caption = 'Item Categories';
                    Image = ItemGroup;

                    action(SyncItemCategories)
                    {
                        Caption = 'Sync. Item Categories';
                        ToolTip = 'Executes the initial migration of item categories from Business Central to Shopify. The system will iterate through the item categories in Business Central and create any that do not already exist in your selected Shopify store.';
                        ApplicationArea = NPRShopify;
                        Image = LinkAccount;

                        trigger OnAction()
                        begin
                            CurrPage.SaveRecord();
                            Report.Run(Report::"NPR Spfy Item Category Sync", true);
                        end;
                    }
                    action(InitItemCatMetafieldVals)
                    {
                        Caption = 'Init Item Metafield values';
                        ToolTip = 'Updates item metafield values based on the item categories currently assigned to items in Business Central.';
                        ApplicationArea = NPRShopify;
                        Image = CalculateLines;

                        trigger OnAction()
                        begin
                            CurrPage.SaveRecord();
                            Report.Run(Report::"NPR Spfy Init Item Cat.MF Vals", true);
                        end;
                    }
                }
                action(SeedRowVersionBaselines)
                {
                    Caption = 'Seed RowVersion Baselines';
                    ToolTip = 'Runs the initial RowVersion baseline seeding sweep for already-synced Shopify entities. Choose foreground (blocking, with progress) or a background Job Queue entry. This does NOT enable the RowVersion change-detection feature; it only warms up the baselines so the first poll after go-live is a clean no-op. This is a pre-cutover migration tool only: it fast-forwards ALL tracker marks and rewinds the migration status. After cut-over, use Quiet-Seed Baselines instead.';
                    ApplicationArea = NPRShopify;
                    Image = Migration;
                    Visible = ShowRowVersionSeedingUI;

                    trigger OnAction()
                    var
                        SpfySyncStateSeeding: Codeunit "NPR Spfy Sync State Seeding";
                    begin
                        CurrPage.SaveRecord();
                        SpfySyncStateSeeding.SeedSyncState();
                        CurrPage.Update(false);
                    end;
                }
                action(MigrateToRowVersionDetection)
                {
                    Caption = 'Migrate to RowVersion detection';
                    ToolTip = 'Runs the one-way CORE-433 migration from the Data Log to RowVersion change detection, in a single step. Choose foreground (runs now, blocking) or background (recommended for a large integration). It seeds the RowVersion baselines, enables the feature alongside the live Data Log, drains the remaining Data Log backlog, and finally removes the Shopify Data Log setup. The background option completes automatically with no second run. Safe to re-run if interrupted.';
                    ApplicationArea = NPRShopify;
                    Image = Migration;
                    Visible = ShowRowVersionMigrationUI;

                    trigger OnAction()
                    var
                        SpfyRowVersionMigration: Codeunit "NPR Spfy RowVersion Migration";
                    begin
                        CurrPage.SaveRecord();
                        SpfyRowVersionMigration.MigrateAndEnable();
                        CurrPage.Update(false);
                    end;
                }
                action(MigrateToShopifyTaskList)
                {
                    Caption = 'Migrate to Shopify Task List';
                    ToolTip = 'Runs the one-way migration of this environment from the NaviConnect task list to the Shopify task list, in a single step. Choose foreground (runs now, blocking) or background (recommended when there is a large backlog of unprocessed tasks). It switches every Shopify store in this environment over to the new queue, stops the NaviConnect task processing jobs, processes the remaining NaviConnect tasks, re-creates the ones scheduled for a later time in the new queue, and finally schedules the new task processing jobs. Safe to re-run if interrupted.';
                    ApplicationArea = NPRShopify;
                    Image = Migration;
                    Visible = _ShowTaskListMigrationUI;

                    trigger OnAction()
                    var
                        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
                    begin
                        CurrPage.SaveRecord();
                        SpfyTaskListMigration.MigrateAndEnable();
                        CurrPage.Update(false);
                    end;
                }
                group("Azure Active Directory OAuth")
                {
                    Caption = 'Microsoft Entra ID OAuth';
                    Image = XMLSetup;
                    Visible = HasAzureADConnection;

                    action("Register Webhook Handler App")
                    {
                        Caption = 'Register Webhook Handler App';
                        ToolTip = 'Running this action will register the NaviPartner Shopify webhook handler Entra app and ask for an admin consent. The action must be run by a user who is both a Microsoft Entra ID administrator and a BC administrator. You won’t be able to use Shopify webhooks until this action is completed.';
                        ApplicationArea = NPRShopify;
                        Image = Setup;

                        trigger OnAction()
                        var
                            SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
                        begin
                            SpfyIntegrationMgt.RegisterWebhookHandlingAzureEntraApp();
                        end;
                    }
                }
            }
            group(Resync)
            {
                Caption = 'Re-sync to Shopify';
                Image = Refresh;

                action(FullResync)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Full Re-sync…';
                    Image = RefreshLines;
                    Visible = RowVersionFeatureEnabled;
                    ToolTip = 'Clears all Shopify sync baselines and re-scans every tracked table, re-sending the current BC state of every synced product, variant, customer, metafield and inventory level to Shopify. Retail Vouchers and Item Prices are excluded, and the Item Ledger Entry mark is left untouched (its pending backlog drains over the next detection cycles). Use after data loss on the Shopify side or a payload version change you want to force-push. Values equal to their default (for example a zero cost) are not re-pushed. You will be asked to confirm the affected row counts.';

                    trigger OnAction()
                    var
                        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
                    begin
                        SpfyResyncMgt.StartFullResync();
                    end;
                }
                action(ResyncStore)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Re-sync Store…';
                    Image = Refresh;
                    Visible = RowVersionFeatureEnabled;
                    ToolTip = 'Re-sends one Shopify store''s synced data: clears the store''s baselines (products, per-store variant data, customers and their metafields) and re-scans the affected tables. Store-agnostic baselines (variant structural data, inventory move-keys) are only cleared if you opt in — clearing them affects ALL stores. Retail Vouchers and Item Prices are excluded.';

                    trigger OnAction()
                    var
                        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
                    begin
                        SpfyResyncMgt.StartStoreResync();
                    end;
                }
                action(ResyncArea)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Re-sync Area…';
                    Image = Refresh;
                    Visible = RowVersionFeatureEnabled;
                    ToolTip = 'Re-sends one integration area (Item List, Inventory, Sales Orders/Customers or Metafields): clears the area''s baselines and re-scans its tracked tables. Retail Vouchers are excluded; Item Prices have no baselines and cannot be re-synced this way. Metafields are their own area; run the Metafields area, a store re-sync, or a full re-sync to re-push metafields.';

                    trigger OnAction()
                    var
                        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
                    begin
                        SpfyResyncMgt.StartAreaResync();
                    end;
                }
                action(QuietSeedBaselines)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Quiet-Seed Baselines…';
                    Image = Approve;
                    Visible = RowVersionFeatureEnabled;
                    ToolTip = 'Overwrites all Shopify sync baselines with the current computed BC state WITHOUT sending anything to Shopify. Use when the baselines are wrong but Shopify is already correct (partial seed, aborted migration, payload version bump). WARNING: any genuinely pending, un-sent change to a baseline-tracked value is absorbed and will not be sent. Tracker marks and the migration status are left untouched. Only available after the RowVersion migration has completed; re-running after a failure is safe.';

                    trigger OnAction()
                    var
                        SpfyResyncMgt: Codeunit "NPR Spfy Resync Mgt";
                    begin
                        SpfyResyncMgt.StartQuietSeed();
                    end;
                }
            }
        }
        area(Navigation)
        {
            group(ChangeDetection)
            {
                Caption = 'Change Detection';
                Image = List;
                action(ShopifyChangeTracker)
                {
                    Caption = 'Change Tracker';
                    ToolTip = 'Opens the RowVersion change tracker for the Shopify integration. Each row is one polled table with its last processed SystemRowVersion high-water mark; from here you can inspect a mark or reset it to force a full re-sync of that table.';
                    ApplicationArea = NPRShopify;
                    Image = List;
                    Visible = RowVersionFeatureEnabled;
                    RunObject = page "NPR Spfy Change Tracker";
                }
                action(ShopifyDeletionLog)
                {
                    Caption = 'Deletion Log';
                    ToolTip = 'Opens the RowVersion deletion log for the Shopify integration. Each row is a captured delete of a synced entity, drained last each cycle so it is sent to Shopify after any pending modifications. Use it to inspect pending, processed, and cancelled deletes.';
                    ApplicationArea = NPRShopify;
                    Image = Log;
                    Visible = RowVersionFeatureEnabled;
                    RunObject = page "NPR Spfy Deletion Log";
                }
                action(ShopifyResyncRuns)
                {
                    ApplicationArea = NPRShopify;
                    Caption = 'Re-sync Runs';
                    Image = History;
                    Visible = RowVersionFeatureEnabled;
                    RunObject = page "NPR Spfy Resync Runs";
                    ToolTip = 'Shows the audit trail of Shopify re-sync and quiet-seed runs: scope, status, progress heartbeat, affected row counts and errors.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
        PreparexDataSet();
        HasAzureADConnection := AzureADTenant.GetAadTenantId() <> '';
        NotifyOfTaskListResiduals();
    end;

    // A completed migration leaves no legacy row with attempts still to spend, so any unprocessed row left is a residual.
    local procedure NotifyOfTaskListResiduals()
    var
        NcTask: Record "NPR Nc Task";
        SpfyTaskListMigration: Codeunit "NPR Spfy Task List Migration";
        ResidualNotification: Notification;
        ResidualNotificationMsg: Label 'Some NaviConnect task(s) were left behind by the Shopify task list migration. The updates they carry have not been sent to Shopify. Use a re-sync to recover the affected records.';
    begin
        if Rec."Task List Migration Status" <> Rec."Task List Migration Status"::Completed then
            exit;
        if not NcTask.ReadPermission() then
            exit;
        SpfyTaskListMigration.FilterUnprocessedLegacyRows(NcTask);
        if NcTask.IsEmpty() then
            exit;
        ResidualNotification.Message(ResidualNotificationMsg);
        ResidualNotification.Send();
    end;

    trigger OnAfterGetCurrRecord()
    var
        SpfyRowVersionFeature: Codeunit "NPR Spfy RowVersion Feature";
        SpfyTaskListFeature: Codeunit "NPR Spfy Task List Feature";
    begin
        RowVersionFeatureEnabled := SpfyRowVersionFeature.IsFeatureEnabled();
        // Seeding fast-forwards every tracker mark, so it stays on the pre-cutover predicate and unreachable once the Data Log wiring is gone.
        ShowRowVersionSeedingUI :=
            SpfyRowVersionFeature.RunsShopifyOnDataLog() and
            (Rec."RowVersion Migration Status" <> Rec."RowVersion Migration Status"::Completed);
        // A started migration stays offered once its Data Log wiring is gone, or a run that failed mid-cutover would have no action left to finish it.
        ShowRowVersionMigrationUI :=
            ShowRowVersionSeedingUI or
            ((Rec."RowVersion Migration Status" <> Rec."RowVersion Migration Status"::Completed) and
            (Rec."RowVersion Migration Status" <> Rec."RowVersion Migration Status"::NotStarted));
        _ShowTaskListMigrationUI :=
            SpfyTaskListFeature.AllPhasesShipped() and
            (Rec."Task List Migration Status" <> Rec."Task List Migration Status"::Completed);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SessionSetting: SessionSettings;
        ReloginRequiredMsg: Label 'You have changed %1. All active users will have to restart their sessions for the changes to take effect.\Do you want to restart your session now?', Comment = '%1 - tablecaption';
    begin
        if DataChanged() then
            if Confirm(ReloginRequiredMsg, true, Rec.TableCaption) then
                SessionSetting.RequestSessionUpdate(false);
    end;

    local procedure SelectShopifyStore() StoreCode: Code[20]
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if ShopifyStore.Count() = 1 then begin
            ShopifyStore.FindFirst();
            StoreCode := ShopifyStore.Code;
            exit;
        end;

        if Page.RunModal(0, ShopifyStore) <> "Action"::LookupOK then
            Error('');
        StoreCode := ShopifyStore.Code;
    end;

    local procedure PreparexDataSet()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        xSetup := Rec;
        if ShopifyStore.FindSet() then
            repeat
                TempxShopifyStore := ShopifyStore;
                TempxShopifyStore.Insert()
            until ShopifyStore.Next() = 0;
    end;

    local procedure DataChanged(): Boolean
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        if Format(Rec) <> Format(xSetup) then
            exit(true);
        if ShopifyStore.FindSet() then
            repeat
                if not TempxShopifyStore.Get(ShopifyStore.Code) then
                    exit(true);
                if Format(ShopifyStore) <> Format(TempxShopifyStore) then
                    exit(true);
                TempxShopifyStore.Delete();
            until ShopifyStore.Next() = 0;
        exit(not TempxShopifyStore.IsEmpty());
    end;

    var
        xSetup: Record "NPR Spfy Integration Setup";
        TempxShopifyStore: Record "NPR Spfy Store" temporary;
        HasAzureADConnection: Boolean;
        RowVersionFeatureEnabled: Boolean;
        ShowRowVersionMigrationUI: Boolean;
        ShowRowVersionSeedingUI: Boolean;
        _ShowTaskListMigrationUI: Boolean;
}
#endif
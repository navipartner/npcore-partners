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
    PromotedActionCategories = 'New,Process,Report,Initial Setup';

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

                    trigger OnValidate()
                    begin
                        UpdateControlVisibility();
                    end;
                }
                field("Shopify Api Version"; Rec."Shopify Api Version")
                {
                    ToolTip = 'Specifies the Shopify Api version. Default value is "2024-01"';
                    ApplicationArea = NPRShopify;
                }
                group(ItemListIntegrationArea)
                {
                    Caption = 'Item List Integration Area';
                    field("Item List Integration"; Rec."Item List Integration")
                    {
                        ToolTip = 'Specifies whether the item list integration is enabled. This will enable item information sending to Shopify';
                        ApplicationArea = NPRShopify;
                        Enabled = IntegrationIsEnabled;

                        trigger OnValidate()
                        begin
                            UpdateControlVisibility();
                        end;
                    }
                    field("Set Shopify Name/Descr. in BC"; Rec."Set Shopify Name/Descr. in BC")
                    {
                        ToolTip = 'Specifies whether you want to be able to update Shopify item names and descriptions from within BC';
                        ApplicationArea = NPRShopify;
                        Enabled = ItemListIntegrationIsEnabled;
                    }
                    field("Do Not Sync. Sales Prices"; Rec."Do Not Sync. Sales Prices")
                    {
                        ToolTip = 'Specifies whether you want to disable item sales price sending to Shopify';
                        ApplicationArea = NPRShopify;
                        Enabled = ItemListIntegrationIsEnabled;
                    }
                }
                group(InventoryIntegrationArea)
                {
                    Caption = 'Inventory Integration Area';
                    field("Send Inventory Updates"; Rec."Send Inventory Updates")
                    {
                        ToolTip = 'Specifies whether available-to-sell inventory (stock balances) is to be sent to Shopify';
                        ApplicationArea = NPRShopify;
                        Enabled = IntegrationIsEnabled;

                        trigger OnValidate()
                        begin
                            UpdateControlVisibility();
                        end;
                    }
                    field("Include Transfer Orders"; Rec."Include Transfer Orders")
                    {
                        ToolTip = 'Specifies whether outstanding transfer order lines should be taken into account, when calculating available-to-sell inventory.';
                        ApplicationArea = NPRShopify;
                        Enabled = InventoryIntegrationIsEnabled;
                    }
                    field("Send Negative Inventory"; Rec."Send Negative Inventory")
                    {
                        ToolTip = 'Specifies whether negative inventory should be sent to Shopify. If disabled, zero is sent instead.';
                        ApplicationArea = NPRShopify;
                        Enabled = InventoryIntegrationIsEnabled;
                    }
                }
                group(RetailVoucherIntegrationArea)
                {
                    Caption = 'Retail Voucher Integration Area';
                    field("Retail Voucher Integration"; Rec."Retail Voucher Integration")
                    {
                        ToolTip = 'Specifies whether the retail voucher integration is enabled. Retail vouchers will be created as Shopify gift cards';
                        ApplicationArea = NPRShopify;
                        Enabled = IntegrationIsEnabled;
                    }
                }
                group(SalesOrderIntegrationArea)
                {
                    Caption = 'Sales Order Integration Area';
                    field("Sales Order Integration"; Rec."Sales Order Integration")
                    {
                        ToolTip = 'Specifies whether sales order integration is enabled. If enabled, system will use a periodic process to download new and updated orders from Shopify';
                        ApplicationArea = NPRShopify;
                        Enabled = IntegrationIsEnabled;

                        trigger OnValidate()
                        begin
                            UpdateControlVisibility();
                        end;
                    }
                    field("Allowed Payment Statuses"; Rec."Allowed Payment Statuses")
                    {
                        ToolTip = 'Specifies allowed Shopify payment statuses. New order will only be imported from Shopify, if the order has been assigned an allowed payment status.';
                        ApplicationArea = NPRShopify;
                        Enabled = SalesOrderIntegrationIsEnabled;
                        Importance = Additional;
                    }
                    field("Get Payment Lines From Shopify"; Rec."Get Payment Lines From Shopify")
                    {
                        ToolTip = 'Specifies when the system should retrieve order payment information from Shopify and create sales order payment lines in BC. This can be when the order is first imported or just before the payment capture requests are sent to Shopify.';
                        ApplicationArea = NPRShopify;
                        Enabled = SalesOrderIntegrationIsEnabled;
                        Importance = Additional;
                    }
                    field("Post on Completion"; Rec."Post on Completion")
                    {
                        ToolTip = 'Specifies whether the system should automatically post the sales order in BC when the associated Shopify order is marked as closed in Shopify.';
                        ApplicationArea = NPRShopify;
                        Enabled = SalesOrderIntegrationIsEnabled;
                        Importance = Additional;
                    }
                    field("Delete on Cancellation"; Rec."Delete on Cancellation")
                    {
                        ToolTip = 'Specifies whether the system should automatically delete the sales order in BC when the associated Shopify order is cancelled in Shopify.';
                        ApplicationArea = NPRShopify;
                        Enabled = SalesOrderIntegrationIsEnabled;
                        Importance = Additional;
                    }
                    field("Send Order Fulfillments"; Rec."Send Order Fulfillments")
                    {
                        ToolTip = 'Specifies whether order fulfillment requests are to be sent from BC to Shopify. Order fulfillment requests are sent for sales orders posted as shipped.';
                        ApplicationArea = NPRShopify;
                        Enabled = SalesOrderIntegrationIsEnabled;
                    }
                    field("Send Payment Capture Requests"; Rec."Send Payment Capture Requests")
                    {
                        ToolTip = 'Specifies whether payment capture requests are to be sent from BC to Shopify. Payment capture requests are sent for sales orders posted as invoiced.';
                        ApplicationArea = NPRShopify;
                        Enabled = SalesOrderIntegrationIsEnabled;
                    }
                    field("Send Close Order Requets"; Rec."Send Close Order Requets")
                    {
                        ToolTip = 'Specifies whether close order requests are to be sent from BC to Shopify. Close order requests are sent for sales orders posted as invoiced';
                        ApplicationArea = NPRShopify;
                        Enabled = IntegrationIsEnabled;
                    }
                }
                group(CCOrderIntegrationArea)
                {
                    Caption = 'Click && Collect Order Integration Area';
                    field("C&C Order Integration"; Rec."C&C Order Integration")
                    {
                        ToolTip = 'Specifies whether click & collect order integration is enabled. If enabled, system will accept and process incoming Shopify CC orders, received through dedicated BC webservice.';
                        ApplicationArea = NPRShopify;
                        Enabled = IntegrationIsEnabled;

                        trigger OnValidate()
                        begin
                            UpdateControlVisibility();
                        end;
                    }
                    field("C&C Order Workflow Code"; Rec."C&C Order Workflow Code")
                    {
                        ToolTip = 'Specifies the Collect in Store Workflow Code to be used by the order handling engine.';
                        ApplicationArea = NPRShopify;
                        Enabled = CCOrderIntegrationIsEnabled;
                    }
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
                action(EnableIntegrationForMagentoItems)
                {
                    Caption = 'Enable Integr. for Magento Items';
                    ToolTip = 'Enables Shopify integration for all existing Magento items.';
                    ApplicationArea = NPRShopify;
                    Image = CheckDuplicates;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
                    begin
                        SendItemAndInventory.EnableIntegrationForMagentoItems(SelectShopifyStore(), true);
                    end;
                }
                action(SyncItems)
                {
                    Caption = 'Sync. Items';
                    ToolTip = 'Executes intial item synchronization between BC and Shopify. System will go through items in BC and mark those already existing in Shopify as ''Shopify Items''';
                    ApplicationArea = NPRShopify;
                    Image = CheckList;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
                    begin
                        CurrPage.SaveRecord();
                        SendItemAndInventory.EnableIntegrationForItemsAlreadyOnShopify(SelectShopifyStore(), true);
                    end;
                }
                action(SyncRetailVouchers)
                {
                    Caption = 'Sync. Vouchers';
                    ToolTip = 'Executes intial retail voucher migration from BC to Shopify. System will go through retail vouchers in BC and create those marked as synchronizable with your selected Shopify Store as gift cards at the store. System will also update gift cards balances at Shopify, if needed.';
                    ApplicationArea = NPRShopify;
                    Image = Migration;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        Report.Run(Report::"NPR Spfy Initial Voucher Sync", true);
                    end;
                }
                group("Azure Active Directory OAuth")
                {
                    Caption = 'Azure Active Directory OAuth';
                    Image = XMLSetup;
                    Visible = HasAzureADConnection;
                    action("Create Azure AD App")
                    {
                        Caption = 'Create Azure AD App';
                        ToolTip = 'Running this action will create an Azure AD App and a accompaning client secret.';
                        ApplicationArea = NPRShopify;
                        Image = Setup;

                        trigger OnAction()
                        var
                            SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
                        begin
                            SpfyIntegrationMgt.CreateAzureADApplication();
                        end;
                    }
                    action("Create Azure AD App Secret")
                    {
                        Caption = 'Create Azure AD App Secret';
                        ToolTip = 'Running this action will create a client secret for an existing Azure AD App.';
                        ApplicationArea = NPRShopify;
                        Image = Setup;

                        trigger OnAction()
                        var
                            SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
                        begin
                            SpfyIntegrationMgt.CreateAzureADApplicationSecret();
                        end;
                    }
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
            Rec.Insert();
        end;
        PreparexDataSet();
        UpdateControlVisibility();
        HasAzureADConnection := AzureADTenant.GetAadTenantId() <> '';
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

    local procedure UpdateControlVisibility()
    begin
        IntegrationIsEnabled := Rec."Enable Integration";
        ItemListIntegrationIsEnabled := Rec."Enable Integration" and Rec."Item List Integration";
        InventoryIntegrationIsEnabled := Rec."Enable Integration" and Rec."Send Inventory Updates";
        SalesOrderIntegrationIsEnabled := Rec."Enable Integration" and Rec."Sales Order Integration";
        CCOrderIntegrationIsEnabled := Rec."Enable Integration" and Rec."C&C Order Integration";
    end;

    local procedure SelectShopifyStore() StoreCode: Code[20]
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
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
                TempxShopifyStore."Last Orders Imported At" := ShopifyStore."Last Orders Imported At";
                if Format(ShopifyStore) <> Format(TempxShopifyStore) then
                    exit(true);
                TempxShopifyStore.Delete();
            until ShopifyStore.Next() = 0;
        exit(not TempxShopifyStore.IsEmpty());
    end;

    var
        xSetup: Record "NPR Spfy Integration Setup";
        TempxShopifyStore: Record "NPR Spfy Store" temporary;
        CCOrderIntegrationIsEnabled: Boolean;
        HasAzureADConnection: Boolean;
        IntegrationIsEnabled: Boolean;
        InventoryIntegrationIsEnabled: Boolean;
        ItemListIntegrationIsEnabled: Boolean;
        SalesOrderIntegrationIsEnabled: Boolean;
}
#endif
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
                    ToolTip = 'Specifies the Shopify Api version. Default value is "2024-07"';
                    ApplicationArea = NPRShopify;
                }
                field("Data Processing Handler ID"; Rec."Data Processing Handler ID")
                {
                    ToolTip = 'Specifies a code used by the system to identify the import types, task processor and data log subscribers associated with the Shopify integration.';
                    ApplicationArea = NPRShopify;
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
        HasAzureADConnection: Boolean;
}
#endif
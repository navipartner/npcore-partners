#if not BC17
page 6184704 "NPR Spfy Store Card"
{
    Extensible = false;
    Caption = 'Shopify Store';
    PageType = Card;
    SourceTable = "NPR Spfy Store";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies a unique internal Shopify store ID.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether the integration with this Shopify store is enabled.';
                    ApplicationArea = NPRShopify;
                }
                group(ItemListIntegrationArea)
                {
                    Caption = 'Item List Integration Area';
                    AboutTitle = 'Set up your item flow';
                    AboutText = 'Control how items/products are synchronised between Shopify and Business Central.';

                    group(ItemWebhooks)
                    {
                        ShowCaption = false;
                        Visible = _HasAzureADConnection;
                        field(AutoSyncItemChanges; _AutoSyncItemChanges)
                        {
                            Caption = 'Auto Sync Item Changes from Shopify';
                            ToolTip = 'Specifies whether product changes made directly in Shopify should be automatically synced to Business Central. Note that this option is only available in BC Saas environments.';
                            ApplicationArea = NPRShopify;
                            Enabled = (_AutoSetAsShopifyItem = _AutoUpdateItemInfo);

                            trigger OnValidate()
                            begin
                                _AutoSetAsShopifyItem := _AutoSyncItemChanges;
                                _AutoUpdateItemInfo := _AutoSyncItemChanges;
                                UpdateItemWebhookRegistration(true, true);
                            end;
                        }

                        field(AutoSetAsShopifyItem; _AutoSetAsShopifyItem)
                        {
                            Caption = 'Auto Enable Item Integration';
                            ToolTip = 'Specifies whether the system should automatically mark/unmark items as Shopify items in Business Central when related products are created/deleted in Shopify. Note that this option is only available in BC Saas environments.';
                            ApplicationArea = NPRShopify;
                            Importance = Additional;
                            Visible = false;

                            trigger OnValidate()
                            begin
                                UpdateItemWebhookRegistration(true, false);
                            end;
                        }
                        field(AutoUpdateItems; _AutoUpdateItemInfo)
                        {
                            Caption = 'Auto Sync Item Info';
                            ToolTip = 'Specifies whether to automatically update item information in Business Central when related product information is changed in Shopify. Note that this option is only available in BC Saas environments.';
                            ApplicationArea = NPRShopify;
                            Importance = Additional;
                            Visible = false;

                            trigger OnValidate()
                            begin
                                UpdateItemWebhookRegistration(false, true);
                            end;
                        }
                    }
                }
                group(SalesOrderIntegrationArea)
                {
                    Caption = 'Sales Order Integration Area';
                    field("Currency Code"; Rec."Currency Code")
                    {
                        ToolTip = 'Specifies the currency code of the Shopify Store. Orders imported from Shopify will be created in Business Central with this currency code.';
                        ApplicationArea = NPRShopify;
                        ShowMandatory = true;
                    }
                    field("Get Orders Starting From"; Rec."Get Orders Starting From")
                    {
                        ToolTip = 'Specifies the date and time from which Shopify orders should be downloaded from the store on the first run. Thereafter, the system will only download new or updated orders since the last time the process was run.';
                        ApplicationArea = NPRShopify;
                        Importance = Additional;
                    }
                    field("Last Orders Imported At"; Rec."Last Orders Imported At")
                    {
                        ToolTip = 'Specifies the date and time Shopify orders were last imported. The next time, the system will only import orders created or updated after this time.';
                        ApplicationArea = NPRShopify;
                        Importance = Additional;
                    }
                }
            }
            group(Connection)
            {
                Caption = 'Connection Parameters';

                field("Shopify Url"; Rec."Shopify Url")
                {
                    ToolTip = 'Specifies the Url to your Shopify store. Enter the URL that people will use to access your store. For example, *https://navipartner.myshopify.com*.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field("Shopify Access Token"; Rec."Shopify Access Token")
                {
                    ToolTip = 'Specifies the Shopify access token, which is the _Admin API access token_ from the Shopify private app setup.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
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

    trigger OnOpenPage()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        _HasAzureADConnection := AzureADTenant.GetAadTenantId() <> '';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        _AutoSetAsShopifyItem := Rec."Auto Set as Shopify Item";
        _AutoUpdateItemInfo := Rec."Auto Update Items from Shopify";
        _AutoSyncItemChanges := Rec."Auto Set as Shopify Item" or Rec."Auto Update Items from Shopify";
    end;

    local procedure UpdateItemWebhookRegistration(Update1st: Boolean; Update2nd: Boolean)
    var
        Window: Dialog;
        ApplyingChangesLbl: Label 'Applying changes. Please wait...';
    begin
        Window.Open(ApplyingChangesLbl);
        if Update1st then
            Rec.Validate("Auto Set as Shopify Item", _AutoSetAsShopifyItem);
        if Update2nd then
            Rec.Validate("Auto Update Items from Shopify", _AutoUpdateItemInfo);
        Window.Close();
        CurrPage.Update(false);
    end;

    var
        _AutoSetAsShopifyItem: Boolean;
        _AutoSyncItemChanges: Boolean;
        _AutoUpdateItemInfo: Boolean;
        _HasAzureADConnection: Boolean;
}
#endif
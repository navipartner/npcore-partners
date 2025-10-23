#if not BC17
page 6184704 "NPR Spfy Store Card"
{
    Extensible = true;
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
                    ToolTip = 'Specifies a unique ID that will be used by Business Central to refer to this store.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field("Language Code"; Rec."Language Code")
                {
                    ToolTip = 'Specifies the language code of the Shopify store. The system will use this to select appropriate master data translations, if available.';
                    ApplicationArea = NPRShopify;
                }
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether the integration with this Shopify store is enabled.';
                    ApplicationArea = NPRShopify;
                }
            }
            group(ItemListIntegrationArea)
            {
                Caption = 'Item List Integration';
                AboutTitle = 'Set up your item flow';
                AboutText = 'Control how items/products are synched between Shopify and Business Central.';

                field("Item List Integration"; Rec."Item List Integration")
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies whether item list integration is enabled. This allows item information to be sent to Shopify.';
                    ApplicationArea = NPRShopify;

                    trigger OnValidate()
                    begin
                        UpdateControlVisibility();
                    end;
                }
                field("New Product Status"; Rec."New Product Status")
                {
                    ToolTip = 'Specifies the status that will be assigned by default to new products created in Shopify from Business Central.';
                    ApplicationArea = NPRShopify;
                    Enabled = _ItemListIntegrationIsEnabled;
                }
                field("Set Shopify Name/Descr. in BC"; Rec."Set Shopify Name/Descr. in BC")
                {
                    ToolTip = 'Specifies whether you want to be able to update Shopify item names and descriptions from within Business Central.';
                    ApplicationArea = NPRShopify;
                    Enabled = _ItemListIntegrationIsEnabled;
                }
                field("Item Category as Metafield"; Rec."Item Category as Metafield")
                {
                    ToolTip = 'Specifies whether the item category should be sent to Shopify as a product metafield. If enabled, the system will create a metaobject definition in Shopify to store the BC item category metafield entries. Please note that enabling this option will deactivate sending the item categories as Shopify product tags.';
                    ApplicationArea = NPRShopify;
                    Enabled = _ItemListIntegrationIsEnabled;

                    trigger OnValidate()
                    var
                        ConfirmManagement: Codeunit "Confirm Management";
                        ConfirmMetafieldCreationQst: Label 'This option requires a Shopify product metafield linked to a metaobject. Would you like the system to create the new entities now? If a metafield and metaobject definitions of the same type already exist, the system will use those instead.';
                    begin
                        if Rec."Item Category as Metafield" then
                            if ConfirmManagement.GetResponseOrDefault(ConfirmMetafieldCreationQst, true) then begin
                                Rec.SetItemCategoryMetafieldID(_ItemCategoryMetafieldID);
                                CurrPage.Update(true);
                            end;
                    end;
                }
                group(ItemCategoryMetafield)
                {
                    ShowCaption = false;
                    Visible = Rec."Item Category as Metafield";
                    field("Item Category Metafield ID"; _ItemCategoryMetafieldID)
                    {
                        Caption = 'Item Category Metafield ID';
                        ToolTip = 'Specifies the ID of the metafield that will be used to store the BC item category in Shopify.';
                        ApplicationArea = NPRShopify;
                        Editable = false;
                        Enabled = _ItemListIntegrationIsEnabled;

                        trigger OnAssistEdit()
                        var
                            SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
                        begin
                            Rec.TestField("Code");
                            if SpfyMetafieldMgt.SelectShopifyMetafield(Rec."Code", Enum::"NPR Spfy Metafield Owner Type"::PRODUCT, SpfyMetafieldMgt.MetaobjectReferenceShopifyMetafieldType(), _ItemCategoryMetafieldID) then begin
                                CurrPage.SaveRecord();
                                Rec.SaveItemCategoryMetafieldID(_ItemCategoryMetafieldID);
                                CurrPage.Update(false);
                            end;
                        end;
                    }
                }
                group(SalesPrices)
                {
                    Caption = 'Sales Prices';
                    field("Do Not Sync. Sales Prices"; Rec."Do Not Sync. Sales Prices")
                    {
                        ToolTip = 'Specifies whether you want to disable sending the item sales prices to Shopify.';
                        ApplicationArea = NPRShopify;
                        Enabled = _ItemListIntegrationIsEnabled;
                    }
                    field("Customer No. (Price)"; Rec."Customer No. (Price)")
                    {
                        ToolTip = 'Specifies the customer that will be used to calculate the prices of Shopify synchronisable items.';
                        ApplicationArea = NPRShopify;
                        Enabled = _ItemListIntegrationIsEnabled;
                    }
                    field("No. of Prices per Request"; Rec."No. of Prices per Request")
                    {
                        ToolTip = 'Specifies the number of item prices that can be sent to Shopify in a single batch price update request. The default value is 100, which will be used by the system if you set the field value to zero.';
                        ApplicationArea = NPRShopify;
                        Enabled = _ItemListIntegrationIsEnabled;
                    }
                }
                group(ItemWebhooks)
                {
                    Caption = 'Item Webhooks';
                    Visible = _HasAzureADConnection;

                    field(AutoSyncItemChanges; _AutoSyncItemChanges)
                    {
                        Caption = 'Auto Sync Item Changes from Shopify';
                        ToolTip = 'Specifies whether product changes made directly in Shopify should be automatically synced to Business Central. Note that this option is only available in BC SaaS environments.';
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
                        ToolTip = 'Specifies whether the system should automatically mark/unmark items as Shopify items in Business Central when related products are created/deleted in Shopify. Note that this option is only available in BC SaaS environments.';
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
                        ToolTip = 'Specifies whether to automatically update item information in Business Central when related product information is changed in Shopify. Note that this option is only available in BC SaaS environments.';
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
            group(InventoryIntegrationArea)
            {
                Caption = 'Inventory Integration';

                field("Send Inventory Updates"; Rec."Send Inventory Updates")
                {
                    ToolTip = 'Specifies whether to send available-to-sell inventory (stock balances) to Shopify.';
                    ApplicationArea = NPRShopify;

                    trigger OnValidate()
                    begin
                        UpdateControlVisibility();
                    end;
                }
                field("Include Transfer Orders"; Rec."Include Transfer Orders")
                {
                    ToolTip = 'Specifies whether outstanding transfer order lines should be taken into account when calculating available-to-sell inventory.';
                    ApplicationArea = NPRShopify;
                    Enabled = _InventoryIntegrationIsEnabled;
                }
                field("Send Negative Inventory"; Rec."Send Negative Inventory")
                {
                    ToolTip = 'Specifies whether negative inventory should be sent to Shopify. If disabled, zero will be sent instead.';
                    ApplicationArea = NPRShopify;
                    Enabled = _InventoryIntegrationIsEnabled;
                }
            }
            group(RetailVoucherIntegrationArea)
            {
                Caption = 'Retail Voucher Integration';

                field("Retail Voucher Integration"; Rec."Retail Voucher Integration")
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies whether retail voucher integration is enabled. Retail vouchers are created as Shopify gift cards.';
                    ApplicationArea = NPRShopify;
                }
                field("Voucher Type (Sold at Shopify)"; Rec."Voucher Type (Sold at Shopify)")
                {
                    ToolTip = 'Specifies the voucher type to create retail vouchers in Business Central for gift cards sold directly on Shopify.';
                    ApplicationArea = NPRShopify;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(Rec.LookupVoucherType(Text));
                    end;
                }
            }
            group(SalesOrderIntegrationArea)
            {
                Caption = 'Sales Order Integration';

                field("Sales Order Integration"; Rec."Sales Order Integration")
                {
                    Caption = 'Enabled';
                    ToolTip = 'Specifies whether sales order integration is enabled. If enabled, the system will set up and use a job queue to download new and updated orders from Shopify.';
                    ApplicationArea = NPRShopify;

                    trigger OnValidate()
                    begin
                        UpdateControlVisibility();
                    end;
                }
                field("Default Ec Store Code"; Rec."Default Ec Store Code")
                {
                    ToolTip = 'Specifies the default e-commerce store code that will be used when creating sales orders from Shopify orders. This is used when the Shopify order does not specify a source name, or when the specified source name is not linked to an e-commerce store in Business Central.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                }
                field("Sales Price on Order Lines"; Rec."Sales Price on Order Lines")
                {
                    ToolTip = 'Specifies whether the system should use the actual sales price or the "compare at price" when creating sales order lines from incoming Shopify orders. If the latter option is selected, the difference between the "compare at price" and the actual sales price will be recorded as a discount amount on the sales order line.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                }
                field("Allowed Payment Statuses"; _SpfyIntegrationMgt.GetAllowedFinancialStatusesAsCommaString(Rec.Code))
                {
                    Caption = 'Allowed Financial Statuses';
                    ToolTip = 'Specifies allowed Shopify order financial (payment) statuses. New orders will only be imported from Shopify if the order has an allowed financial status.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                    Importance = Additional;
                    Editable = false;
                    AssistEdit = true;

                    trigger OnAssistEdit()
                    begin
                        CurrPage.SaveRecord();
                        _SpfyIntegrationMgt.SelectAllowedFinancialStatuses(Rec.Code);
                        CurrPage.Update(false);
                    end;
                }
                field("Get Payment Lines from Shopify"; Rec."Get Payment Lines from Shopify")
                {
                    ToolTip = 'Specifies when the system should retrieve order payment information from Shopify and create sales order payment lines in Business Central. This can be when the order is first imported or just before the payment capture requests are sent to Shopify.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                    Editable = Rec."Send Payment Capture Requests";
                    Importance = Additional;
                }
                field("Post on Completion"; Rec."Post on Completion")
                {
                    ToolTip = 'Specifies whether the system should automatically post the sales order in Business Central when the associated Shopify order is marked as closed in Shopify.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                    Importance = Additional;
                }
                field("Delete After Final Post"; Rec."Delete After Final Post")
                {
                    ToolTip = 'Specifies whether the system should automatically delete the unposted part of the sales order in Business Central once the final posting process has been completed. This option is only available when the sales order is posted automatically based on information from Shopify indicating that the order has been closed. Therefore, the "Post on Completion" setup option must also be enabled.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled and Rec."Post on Completion";
                    Importance = Additional;
                }
                field("Delete on Cancellation"; Rec."Delete on Cancellation")
                {
                    ToolTip = 'Specifies whether the system should automatically delete the sales order in Business Central when the associated Shopify order is cancelled in Shopify.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                    Importance = Additional;
                }
                field("Send Order Fulfillments"; Rec."Send Order Fulfillments")
                {
                    ToolTip = 'Specifies whether to send order fulfillment requests from Business Central to Shopify. Order fulfillment requests are sent for sales orders that have been posted as shipped.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                }
                field("Send Payment Capture Requests"; Rec."Send Payment Capture Requests")
                {
                    ToolTip = 'Specifies whether to send payment capture requests from Business Central to Shopify. Payment capture requests are sent for sales orders that have been posted as invoiced.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                }
                field("Send Close Order Requets"; Rec."Send Close Order Requets")
                {
                    ToolTip = 'Specifies whether to send close order requests from Business Central to Shopify. Close order requests are sent for sales orders that have been posted as invoiced.';
                    ApplicationArea = NPRShopify;
                    Enabled = _SalesOrderIntegrationIsEnabled;
                    Importance = Additional;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency code of the Shopify Store. Orders imported from Shopify will be created in Business Central with this currency code.';
                    ApplicationArea = NPRShopify;
                    Style = Unfavorable;
                    StyleExpr = _InvalidCurrencyCode;
                }
                field("Get Orders Starting From"; Rec."Get Orders Starting From")
                {
                    ToolTip = 'Specifies the date and time from which sales orders should be downloaded from the Shopify store on the first run. Thereafter, the system will only download new or updated orders since the last time the process was run.';
                    ApplicationArea = NPRShopify;
                    Importance = Additional;
                }
                field("Last Orders Imported At"; Rec."Last Orders Imported At")
                {
                    ToolTip = 'Specifies the date and time sales orders were last imported from the Shopify store. The next time, the system will only import orders created or updated after this time.';
                    ApplicationArea = NPRShopify;
                    Importance = Additional;
                }
                field("Spfy C&C Order Workflow Code"; Rec."Spfy C&C Order Workflow Code")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Specifies the workflow code to be used for Click&Collect orders from this store.';
                }
                group(CustomerIntegration)
                {
                    Caption = 'Customer Integration';
                    field("Auto Sync New Customers"; Rec."Auto Sync New Customers")
                    {
                        ToolTip = 'Specifies whether new customers created in Business Central should be automatically created as customers in Shopify.';
                        ApplicationArea = NPRShopify;
                        Enabled = _SalesOrderIntegrationIsEnabled;
                    }
                    field("Loyalty Points as Metafield"; Rec."Loyalty Points as Metafield")
                    {
                        ToolTip = 'Specifies whether the membership loyalty points should be sent to Shopify as a customer metafield.';
                        ApplicationArea = NPRShopify;
                        Enabled = _SalesOrderIntegrationIsEnabled;
                    }
                    group(MMPointsMetafield)
                    {
                        ShowCaption = false;
                        Visible = Rec."Loyalty Points as Metafield";
                        field("Loyalty Points Metafield ID"; _LoyaltyPointsMetafieldID)
                        {
                            Caption = 'Loyalty Points Metafield ID';
                            ToolTip = 'Specifies the ID of the metafield that will be used to store the BC membership loyalty points in Shopify.';
                            ApplicationArea = NPRShopify;
                            Editable = false;
                            Enabled = _SalesOrderIntegrationIsEnabled;

                            trigger OnAssistEdit()
                            var
                                SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
                            begin
                                Rec.TestField("Code");
                                if SpfyMetafieldMgt.SelectShopifyMetafield(Rec."Code", Enum::"NPR Spfy Metafield Owner Type"::CUSTOMER, _LoyaltyPointsMetafieldID) then begin
                                    CurrPage.SaveRecord();
                                    Rec.SaveLoyaltyPointsMetafieldID(_LoyaltyPointsMetafieldID);
                                    CurrPage.Update(false);
                                end;
                            end;
                        }
                    }
                }
            }
            group(Connection)
            {
                Caption = 'Connection Parameters';

                field("Shopify Url"; Rec."Shopify Url")
                {
                    ToolTip = 'Specifies the Url to your Shopify store. Enter the URL that people will use to access your store. For example, https://navipartner.myshopify.com.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field("Shopify Access Token"; Rec."Shopify Access Token")
                {
                    ToolTip = 'Specifies the Shopify access token, which is the "Admin API access token" from the Shopify private app setup.';
                    ApplicationArea = NPRShopify;
                    ShowMandatory = true;
                }
                field(TestShopifyConnection; _TestShopifyConnectionLbl)
                {
                    ApplicationArea = NPRShopify;
                    DrillDown = true;
                    Editable = false;
                    ShowCaption = false;
                    Style = StrongAccent;
                    StyleExpr = true;

                    trigger OnDrillDown()
                    begin
                        Rec.TestField("Shopify Url");
                        Rec.TestField("Shopify Access Token");
                        CurrPage.SaveRecord();
                        Commit();
                        _SpfyIntegrationMgt.TestShopifyStoreConnection(Rec.Code);
                        CurrPage.Update(false);
                    end;
                }
                field("Shopify Store ID"; _SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
                {
                    Caption = 'Shopify Store ID';
                    ToolTip = 'Specifies the Shopify internal ID assigned to this store. Run the "Test connection ..." procedure to update this field with the information from Shopify.';
                    Editable = false;
                    ApplicationArea = NPRShopify;
                }
                field("Plan Display Name"; Rec."Plan Display Name")
                {
                    ToolTip = 'Specifies the subscription plan that is currently in effect for the Shopify store. Run the "Test connection ..." procedure to update this field with the latest information from Shopify.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Shopify Plus Subscription"; Rec."Shopify Plus Subscription")
                {
                    ToolTip = 'Specifies whether the Shopify Plus subscription is enabled for the Shopify store. Run the "Test connection ..." procedure to update this field with the latest information from Shopify.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
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
                    ToolTip = 'Executes initial item synchronization between Business Central and Shopify. The system will iterate through items in Business Central and identify those that already exist in Shopify. The system will also update item statuses, names, descriptions and metafields from Shopify and create requests to assign product tags in Shopify based on the item categories selected for the items in Business Central.';
                    ApplicationArea = NPRShopify;
                    Image = CheckList;

                    trigger OnAction()
                    var
                        SendItemAndInventory: Codeunit "NPR Spfy Send Items&Inventory";
                    begin
                        CurrPage.SaveRecord();
                        SendItemAndInventory.EnableIntegrationForItemsAlreadyOnShopify(Rec.Code, true);
                    end;
                }
                action(SyncCustomers)
                {
                    Caption = 'Sync. Customers';
                    ToolTip = 'Executes initial customer synchronization between Business Central and Shopify. The system will iterate through customers in Business Central and identify those that already exist in Shopify. The system will also update customer information from Shopify.';
                    ApplicationArea = NPRShopify;
                    Image = CheckList;

                    trigger OnAction()
                    var
                        SpfySendCustomers: Codeunit "NPR Spfy Send Customers";
                    begin
                        CurrPage.SaveRecord();
                        SpfySendCustomers.EnableIntegrationForCustomersAlreadyOnShopify(Rec.Code, true);
                    end;
                }
                action(SyncRetailVouchers)
                {
                    Caption = 'Sync. Vouchers';
                    ToolTip = 'Executes initial retail voucher migration from Business Central to Shopify. The system will iterate through retail vouchers in Business Central and create those marked as synchronizable with your selected Shopify store as gift cards in the store. The system will also update gift card balances in Shopify as needed.';
                    ApplicationArea = NPRShopify;
                    Image = Migration;

                    trigger OnAction()
                    var
                        ShopifyStore: Record "NPR Spfy Store";
                    begin
                        CurrPage.SaveRecord();
                        ShopifyStore.SetRange(Code, Rec.Code);
                        Report.Run(Report::"NPR Spfy Initial Voucher Sync", true, false, ShopifyStore);
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
                        var
                            ShopifyStore: Record "NPR Spfy Store";
                        begin
                            CurrPage.SaveRecord();
                            ShopifyStore.SetRange(Code, Rec.Code);
                            Report.Run(Report::"NPR Spfy Item Category Sync", true, false, ShopifyStore);
                        end;
                    }
                    action(InitItemCatMetafieldVals)
                    {
                        Caption = 'Init Item Metafield values';
                        ToolTip = 'Updates item metafield values based on the item categories currently assigned to items in Business Central.';
                        ApplicationArea = NPRShopify;
                        Image = CalculateLines;

                        trigger OnAction()
                        var
                            ShopifyStore: Record "NPR Spfy Store";
                        begin
                            CurrPage.SaveRecord();
                            ShopifyStore.SetRange(Code, Rec.Code);
                            Report.Run(Report::"NPR Spfy Init Item Cat.MF Vals", true, false, ShopifyStore);
                        end;
                    }
                }
            }
        }
        area(Navigation)
        {
            action(LocationLinks)
            {
                Caption = 'Linked Locations';
                ToolTip = 'View and set up Business Central-Shopify location links.';
                ApplicationArea = NPRShopify;
                Image = LinkWeb;
                RunObject = Page "NPR Spfy Store-Location Links";
                RunPageLink = "Shopify Store Code" = field(Code);
            }
            action(SalesChannels)
            {
                Caption = 'Sales Channels';
                ToolTip = 'View the list of Shopify sales channels for your shop and select the ones you want to use when creating new products in Shopify.';
                ApplicationArea = NPRShopify;
                Image = List;
                RunObject = Page "NPR Spfy Sales Channels";
                RunPageLink = "Shopify Store Code" = field(Code);
            }
        }
        area(Reporting)
        {
            action(EventLogEntries)
            {
                Caption = 'Event Log';
                ToolTip = 'View the list of registered Shopify events for this store.';
                ApplicationArea = NPRShopify;
                Image = ImportLog;
                RunObject = Page "NPR Spfy Event Log Entries";
                RunPageView = sorting("Store Code", "Event Date-Time", Type);
                RunPageLink = "Store Code" = field(Code);
            }
        }
#if not (BC17 or BC18 or BC19 or BC20)
        area(Promoted)
        {
            actionref(SyncItems_Promoted; SyncItems)
            {
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '2025-10-26';
                ObsoleteReason = 'No need to have initial sync actions as promoted.';
            }
            actionref(SyncCustomers_Promoted; SyncCustomers)
            {
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '2025-10-26';
                ObsoleteReason = 'No need to have initial sync actions as promoted.';
            }
            actionref(SyncRetailVouchers_Promoted; SyncRetailVouchers)
            {
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '2025-10-26';
                ObsoleteReason = 'No need to have initial sync actions as promoted.';
            }
            actionref(SyncItemCategories_Promoted; SyncItemCategories)
            {
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '2025-10-26';
                ObsoleteReason = 'No need to have initial sync actions as promoted.';
            }
            actionref(SalesChannels_Promoted; SalesChannels)
            {
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '2025-10-26';
                ObsoleteReason = 'No need to have initial sync actions as promoted.';
            }
        }
#endif
    }

    trigger OnOpenPage()
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
    begin
        PreparexDataSet();
        _HasAzureADConnection := AzureADTenant.GetAadTenantId() <> '';
    end;

    trigger OnAfterGetCurrRecord()
    var
        Parameters: Dictionary of [Text, Text];
    begin
        UpdateControlVisibility();
        CheckCurrencyCode();

        _ItemCategoryMetafieldID := Rec.ItemCategoryMetafieldID();
        _LoyaltyPointsMetafieldID := Rec.LoyaltyPointsMetafieldID();

        if _SpfyIntegrationMgt.IsEnabled(Enum::"NPR Spfy Integration Area"::" ", Rec.Code) then begin
            Parameters.Add('StoreCode', Rec.Code);
            CurrPage.EnqueueBackgroundTask(_BackgroundTaskId, Codeunit::"NPR Spfy Store Background Task", Parameters);
        end;
    end;

    trigger OnPageBackgroundTaskCompleted(TaskId: Integer; Results: Dictionary of [Text, Text])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        NewShopifyStoreID: Text[30];
        OldShopifyStoreID: Text[30];
    begin
        if Results.ContainsKey(Format(Rec.FieldNo("Plan Display Name"))) then
            Rec."Plan Display Name" := CopyStr(Results.Get(Format(Rec.FieldNo("Plan Display Name"))), 1, MaxStrLen(Rec."Plan Display Name"));
        if Results.ContainsKey(Format(Rec.FieldNo("Shopify Plus Subscription"))) then
            Evaluate(Rec."Shopify Plus Subscription", Results.Get(Format(Rec.FieldNo("Shopify Plus Subscription"))), 9);

        if Results.ContainsKey('ShopifyStoreID') then begin
            NewShopifyStoreID := CopyStr(Results.Get('ShopifyStoreID'), 1, MaxStrLen(NewShopifyStoreID));
            OldShopifyStoreID := _SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
            SpfyAssignedIDMgt.AssignShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID", NewShopifyStoreID, true);
            if NewShopifyStoreID <> OldShopifyStoreID then begin
                CurrPage.SaveRecord();
                CurrPage.Update(false);
            end;
        end;
    end;

    trigger OnPageBackgroundTaskError(TaskId: Integer; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text; var IsHandled: Boolean)
    var
        BackgrndTaskMgt: Codeunit "NPR Page Background Task Mgt.";
    begin
        if (TaskId = _BackgroundTaskId) then
            BackgrndTaskMgt.FailedTaskError(CurrPage.Caption(), ErrorCode, ErrorText);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        SessionSetting: SessionSettings;
        ReloginRequiredMsg: Label 'You have changed %1. All active users will have to restart their sessions for the changes to take effect.\Do you want to restart your session now?', Comment = '%1 - tablecaption';
    begin
        CurrPage.SaveRecord();
        if DataChanged() then
            if Confirm(ReloginRequiredMsg, true, Rec.TableCaption) then
                SessionSetting.RequestSessionUpdate(false);
    end;

    local procedure UpdateControlVisibility()
    begin
        _AutoSetAsShopifyItem := Rec."Auto Set as Shopify Item";
        _AutoUpdateItemInfo := Rec."Auto Update Items from Shopify";
        _AutoSyncItemChanges := Rec."Auto Set as Shopify Item" or Rec."Auto Update Items from Shopify";
        _ItemListIntegrationIsEnabled := Rec."Item List Integration";
        _InventoryIntegrationIsEnabled := Rec."Send Inventory Updates";
        _SalesOrderIntegrationIsEnabled := Rec."Sales Order Integration";
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

    local procedure PreparexDataSet()
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
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

    local procedure CheckCurrencyCode()
    var
        Currency: Record Currency;
    begin
        _InvalidCurrencyCode := false;
        if Rec."Currency Code" = '' then
            exit;
        _InvalidCurrencyCode := not Currency.Get(Rec."Currency Code");
    end;

    var
        TempxShopifyStore: Record "NPR Spfy Store" temporary;
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _ItemCategoryMetafieldID: Text[30];
        _LoyaltyPointsMetafieldID: Text[30];
        _BackgroundTaskId: Integer;
        _AutoSetAsShopifyItem: Boolean;
        _AutoSyncItemChanges: Boolean;
        _AutoUpdateItemInfo: Boolean;
        _HasAzureADConnection: Boolean;
        _InvalidCurrencyCode: Boolean;
        _InventoryIntegrationIsEnabled: Boolean;
        _ItemListIntegrationIsEnabled: Boolean;
        _SalesOrderIntegrationIsEnabled: Boolean;
        _TestShopifyConnectionLbl: Label 'Test connection and retrieve store data from Shopify';
}
#endif
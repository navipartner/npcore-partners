#if not BC17
table 6150810 "NPR Spfy Store"
{
    Access = Public;
    Caption = 'Shopify Store';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Stores";
    LookupPageId = "NPR Spfy Stores";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ShopifyStore: Record "NPR Spfy Store";
                OrderMgt: Codeunit "NPR Spfy Order Mgt.";
#if not (BC18 or BC19 or BC20)
                SpfyExportBCTransJQ: Codeunit "NPR Spfy Export BC Trans. JQ";
#endif
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
                SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
#endif
                SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
            begin
                if Enabled then
                    TestField("Shopify Url");
                Modify();

                ShopifyStore.Get("Code");
                ShopifyStore.SetRecFilter();
                SpfyScheduleSend.SetupTaskProcessingJobQueues(ShopifyStore);
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                if ShopifyEcommOrderExp.IsFeatureEnabled() then
                    SpfyEcomSalesDocPrcssr.SetupJobQueues()
                else
#endif
                OrderMgt.SetupJobQueues();
#if not (BC18 or BC19 or BC20)
                SpfyExportBCTransJQ.SetupBCTransExportJobQueues(ShopifyStore);
#endif
                Validate("Do Not Sync. Sales Prices");
            end;
        }
        field(20; "Shopify Url"; Text[250])
        {
            Caption = 'Shopify Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;

            trigger OnValidate()
            var
                SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
                InvalidShopUrlErr: Label 'The URL must refer to the internal shop location at myshopify.com.';
            begin
                if "Shopify URL" <> '' then begin
                    if not "Shopify URL".ToLower().StartsWith('https://') then
                        "Shopify URL" := CopyStr('https://' + "Shopify URL", 1, MaxStrLen("Shopify URL"));

                    if "Shopify URL".ToLower().StartsWith('https://admin.shopify.com/store/') then
                        "Shopify URL" := CopyStr('https://' + "Shopify URL".Replace('https://admin.shopify.com/store/', '').Split('/').Get(1) + '.myshopify.com', 1, MaxStrLen("Shopify URL"));

                    if not SpfyCommunicationHandler.IsValidShopUrl("Shopify URL") then
                        Error(InvalidShopUrlErr);
                end;
            end;
        }
        field(21; "Shopify Access Token"; Text[100])
        {
            Caption = 'Shopify Access Token';
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
        }
        field(30; "Currency Code"; Code[10])
        {
            Caption = 'Currency Code';
            TableRelation = Currency;
            DataClassification = CustomerContent;
        }
        field(40; "Get Orders Starting From"; DateTime)
        {
            Caption = 'Get Orders Starting From';
            DataClassification = CustomerContent;
        }
        field(50; "Last Orders Imported At"; DateTime)
        {
            Caption = 'Last Orders Imported At';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2025-11-07';
            ObsoleteReason = 'Replaced by the FlowField 51 "Last Orders Imported At (FF)", which is calculated based on table 6151261 "NPR Spfy Data Sync. Pointer".';
        }
        field(51; "Last Orders Imported At (FF)"; DateTime)
        {
            Caption = 'Last Orders Imported At';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Data Sync. Pointer"."Last Orders Imported At" where("Shopify Store Code" = field(Code)));
        }
        field(60; "Item List Integration"; Boolean)
        {
            Caption = 'Item List Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Item List Integration" then
                    _SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::Items);
            end;
        }
        field(61; "Do Not Sync. Sales Prices"; Boolean)
        {
            Caption = 'Do Not Sync. Sales Prices';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            var
                SpfyItemPriceMgt: Codeunit "NPR Spfy Item Price Mgt.";
                SpfyScheduleSendTasks: Codeunit "NPR Spfy Schedule Send Tasks";
            begin
                if not "Do Not Sync. Sales Prices" then begin
                    SpfyItemPriceMgt.EnableShopifyLogRetentionPolicy();
                    _SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Item Prices");
                end;
                SpfyScheduleSendTasks.ToggleSpfyItemPriceSyncJobQueue(Enabled and not "Do Not Sync. Sales Prices");
            end;
        }
        field(62; "Set Shopify Name/Descr. in BC"; Boolean)
        {
            Caption = 'Set Shopify Name/Descr. in BC';
            DataClassification = CustomerContent;
        }
        field(63; "New Product Status"; Enum "NPR Spfy Product Status")
        {
            Caption = 'New Product Status';
            DataClassification = CustomerContent;
            ValuesAllowed = DRAFT, ACTIVE, UNLISTED;
            InitValue = DRAFT;
        }
        field(64; "Item Category as Metafield"; Boolean)
        {
            Caption = 'Item Category as Metafield';
            DataClassification = CustomerContent;
        }
        field(65; "Default Weight Unit"; Enum "NPR Spfy Weight Unit")
        {
            Caption = 'Default Weight Unit';
            DataClassification = CustomerContent;
        }
        field(70; "Send Inventory Updates"; Boolean)
        {
            Caption = 'Send Inventory Updates';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                EnableItemListIntegrLbl: Label '"%1" is not enabled. Using "%2" is not recommended without it.\Do you want the "%1" be enabled now?', Comment = '%1 - Item List Integration fieldcaption, Send Inventory Updates fieldcaption';
            begin
                if "Send Inventory Updates" then begin
                    if not "Item List Integration" then
                        if Confirm(EnableItemListIntegrLbl, true, Rec.FieldCaption("Item List Integration"), Rec.FieldCaption("Send Inventory Updates")) then
                            Rec.Validate("Item List Integration", true);
                    _SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Inventory Levels");
                end;
            end;
        }
        field(71; "Include Transfer Orders"; Option)
        {
            Caption = 'Include Transfer Orders';
            DataClassification = CustomerContent;
            OptionMembers = No,Outbound,All;
            OptionCaption = 'No,Outbound,All';

            trigger OnValidate()
            begin
                if "Include Transfer Orders" <> "Include Transfer Orders"::No then begin
                    Modify();
                    _SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Inventory Levels");
                end;
            end;
        }
        field(72; "Send Negative Inventory"; Boolean)
        {
            Caption = 'Send Negative Inventory';
            DataClassification = CustomerContent;
        }
        field(80; "Sales Order Integration"; Boolean)
        {
            Caption = 'Sales Order Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpfyAllowedFinStatus: Record "NPR Spfy Allowed Fin. Status";
                OrderMgt: Codeunit "NPR Spfy Order Mgt.";
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
                ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
#endif
            begin
                Modify();
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                if ShopifyEcommOrderExp.IsFeatureEnabled() then
                    SpfyEcomSalesDocPrcssr.SetupJobQueues()
                else
#endif
                OrderMgt.SetupJobQueues();
                if "Sales Order Integration" then begin
                    _SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Sales Orders");
                    SpfyAllowedFinStatus.SetRange("Shopify Store Code", Code);
                    if SpfyAllowedFinStatus.IsEmpty() then
                        AddAllowedOrderFinancialStatus(Enum::"NPR Spfy Order FinancialStatus"::Authorized);
                end;
            end;
        }
        field(81; "Post on Completion"; Boolean)
        {
            Caption = 'Post on Completion';
            DataClassification = CustomerContent;
            InitValue = true;

            trigger OnValidate()
            begin
                if not "Post on Completion" then
                    "Delete After Final Post" := false;
            end;
        }
        field(82; "Delete on Cancellation"; Boolean)
        {
            Caption = 'Delete on Cancellation';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(83; "Default Ec Store Code"; Code[20])
        {
            Caption = 'Default E-commerce Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpEc Store".Code;
        }
        field(84; "Delete After Final Post"; Boolean)
        {
            Caption = 'Delete After Final Post';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(85; "Get Payment Lines from Shopify"; Option)
        {
            Caption = 'Get Payment Lines from Shopify';
            DataClassification = CustomerContent;
            OptionMembers = ON_CAPTURE,ON_ORDER_IMPORT,ON_IMPORT_AND_CAPTURE;
            OptionCaption = 'Before Capture,On Order Import,Both on Import and before Capture';
            InitValue = ON_IMPORT_AND_CAPTURE;

            trigger OnValidate()
            begin
                if "Get Payment Lines from Shopify" in ["Get Payment Lines from Shopify"::ON_CAPTURE, "Get Payment Lines from Shopify"::ON_IMPORT_AND_CAPTURE] then
                    TestField("Send Payment Capture Requests");
            end;
        }
        field(90; "Send Order Fulfillments"; Boolean)
        {
            Caption = 'Send Order Fulfillments';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Send Order Fulfillments" then
                    TestField("Sales Order Integration");
            end;
        }
        field(100; "Send Payment Capture Requests"; Boolean)
        {
            Caption = 'Send Payment Capture Requests';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Send Payment Capture Requests" then
                    TestField("Sales Order Integration")
                else
                    if "Get Payment Lines from Shopify" in ["Get Payment Lines from Shopify"::ON_CAPTURE, "Get Payment Lines from Shopify"::ON_IMPORT_AND_CAPTURE] then
                        "Get Payment Lines from Shopify" := "Get Payment Lines from Shopify"::ON_ORDER_IMPORT;
            end;
        }
        field(110; "Send Close Order Requets"; Boolean)
        {
            Caption = 'Send Close Order Requests';
            DataClassification = CustomerContent;
        }
        field(120; "Allowed Payment Statuses"; Option)
        {
            Caption = 'Allowed Payment Statuses';
            DataClassification = CustomerContent;
            OptionMembers = Authorized,Paid,Both;
            OptionCaption = 'Authorized,Paid,Both';
            ObsoleteState = Removed;
            ObsoleteTag = '2025-02-23';
            ObsoleteReason = 'Replaced by table 6151045 "NPR Spfy Allowed Fin. Status"';
        }
        field(130; "Retail Voucher Integration"; Boolean)
        {
            Caption = 'Retail Voucher Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Retail Voucher Integration" then
                    _SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Retail Vouchers");
            end;
        }
        field(131; "Voucher Type (Sold at Shopify)"; Code[20])
        {
            Caption = 'Voucher Type (Sold at Shopify)';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpRv Voucher Type";

            trigger OnValidate()
            var
                VoucherType: Record "NPR NpRv Voucher Type";
                IncorrectVoucherStoreErr: Label 'You will need to assign the value "%1" as the Shopify Store Code for Retail Voucher Type "%2" before you can select it as the type of vouchers sold on Shopify for the store.', Comment = '%1 - Shopify store code, %2 - Retail voucher type code';
            begin
                if "Voucher Type (Sold at Shopify)" <> '' then begin
                    VoucherType.Get("Voucher Type (Sold at Shopify)");
                    VoucherType.TestField("Integrate with Shopify", true);
                    if VoucherType.GetStoreCode() <> Code then
                        Error(IncorrectVoucherStoreErr, Code, "Voucher Type (Sold at Shopify)");
                end;
            end;
        }
        field(140; "Plan Display Name"; Text[50])
        {
            Caption = 'Shopify Plan';
            DataClassification = CustomerContent;
        }
        field(150; "Shopify Plus Subscription"; Boolean)
        {
            Caption = 'Shopify Plus Subscription';
            DataClassification = CustomerContent;
        }
        field(160; "Language Code"; Code[10])
        {
            Caption = 'Language Code';
            TableRelation = Language.Code;
            DataClassification = CustomerContent;
        }
        field(210; "Auto Sync New Customers"; Option)
        {
            Caption = 'Auto Sync New Customers';
            DataClassification = CustomerContent;
            OptionMembers = No,MembershipOnly;
            OptionCaption = 'No,Membership';
        }
        field(220; "Loyalty Points as Metafield"; Boolean)
        {
            Caption = 'Loyalty Points as Metafield';
            DataClassification = CustomerContent;
        }
        field(230; "Update Cust. Phone No. from BC"; Boolean)
        {
            Caption = 'Update Cust. Phone No. from BC';
            DataClassification = CustomerContent;
        }
#if not (BC18 or BC19 or BC20)
        field(300; "BC Customer Transactions"; Boolean)
        {
            Caption = 'Send POS Customer Purchases';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                POSEntry: Record "NPR POS Entry";
                ShopifyStore: Record "NPR Spfy Store";
                SpfyExportBCTransJQ: Codeunit "NPR Spfy Export BC Trans. JQ";
            begin
                if "BC Customer Transactions" then begin
                    if "Historical Data Cut-Off Date" = 0D then
                        "Historical Data Cut-Off Date" := CalcDate('<-2Y-CY>', Today());
                    CalcFields("Last POS Entry Row Version");
                    if "Last POS Entry Row Version" = 0 then begin
                        POSEntry.SetCurrentKey(SystemRowVersion);
                        if POSEntry.FindLast() then
                            SetLastPOSRowVersion(POSEntry.SystemRowVersion);
                    end;
                    Modify();

                    ShopifyStore := Rec;
                    ShopifyStore.SetRecFilter();
                    SpfyExportBCTransJQ.SetupBCTransExportJobQueues(ShopifyStore);
                end;
            end;
        }
        field(310; "Auto-Send Historical BC Orders"; Boolean)
        {
            Caption = 'Auto-Send Historical POS Trans.';
            DataClassification = CustomerContent;
        }
        field(320; "Historical Data Cut-Off Date"; Date)
        {
            Caption = 'Histor.POS Trans. Cut-Off Date';
            DataClassification = CustomerContent;
        }
        field(330; "Last POS Entry Row Version"; BigInteger)
        {
            Caption = 'Last POS Entry Row Version';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Data Sync. Pointer"."Last POS Entry Row Version" where("Shopify Store Code" = field(Code)));
        }
#endif
        field(500; "Auto Set as Shopify Item"; Boolean)
        {
            Caption = 'Auto Set as Shopify Item';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpfyItemWebhookHandler: Codeunit "NPR Spfy Item Webhook Handler";
                IncludeFields: List of [Text];
            begin
                TestField(Code);
                TestField(Enabled);
                Modify();
                if "Auto Set as Shopify Item" then
                    IncludeFields := SpfyItemWebhookHandler.WebhookSubscriptionFields();
                _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"products/create", IncludeFields, "Auto Set as Shopify Item");
                _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"products/delete", "Auto Set as Shopify Item");
                if not "Auto Update Items from Shopify" then
                    _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"products/update", IncludeFields, "Auto Set as Shopify Item");
            end;
        }
        field(510; "Auto Update Items from Shopify"; Boolean)
        {
            Caption = 'Auto Update Items from Shopify';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpfyItemWebhookHandler: Codeunit "NPR Spfy Item Webhook Handler";
            begin
                TestField(Code);
                TestField(Enabled);
                Modify();
                if not "Auto Set as Shopify Item" then
                    _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"products/update", SpfyItemWebhookHandler.WebhookSubscriptionFields(), "Auto Update Items from Shopify");
            end;
        }
        field(520; "Item Created Webhook Exists"; Boolean)
        {
            Caption = 'Item Created Webhook Exists';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Spfy Webhook Subscription" where("Store Code" = field(Code), Topic = const("products/create")));
            Editable = false;
        }
        field(530; "Item Deleted Webhook Exists"; Boolean)
        {
            Caption = 'Item Deleted Webhook Exists';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Spfy Webhook Subscription" where("Store Code" = field(Code), Topic = const("products/delete")));
            Editable = false;
        }
        field(540; "Item Updated Webhook Exists"; Boolean)
        {
            Caption = 'Item Updated Webhook Exists';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Spfy Webhook Subscription" where("Store Code" = field(Code), Topic = const("products/update")));
            Editable = false;
        }
        field(560; "Auto Update Cust. from Shopify"; Boolean)
        {
            Caption = 'Auto Update Customers from Shopify';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpfyCustWebhookHandler: Codeunit "NPR Spfy Cust. Webhook Handler";
                Window: Dialog;
                ApplyingChangesLbl: Label 'Applying changes. Please wait...';
            begin
                TestField(Code);
                TestField(Enabled);
                Modify();

                if GuiAllowed() then
                    Window.Open(ApplyingChangesLbl);
                _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"customers/update", SpfyCustWebhookHandler.WebhookSubscriptionFields(), "Auto Update Cust. from Shopify");
                if GuiAllowed() then
                    Window.Close();
            end;
        }
        field(590; "Cust. Updated Webhook Exists"; Boolean)
        {
            Caption = 'Customer Updated Webhook Exists';
            FieldClass = FlowField;
            CalcFormula = exist("NPR Spfy Webhook Subscription" where("Store Code" = field(Code), Topic = const("customers/update")));
            Editable = false;
        }
        field(600; "Customer No. (Price)"; Code[20])
        {
            Caption = 'Customer No. (Price)';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(610; "No. of Prices per Request"; Integer)
        {
            Caption = 'Price Update Batch Size';
            DataClassification = CustomerContent;
        }
        field(620; "Sales Price on Order Lines"; Enum "NPR Spfy Order Line Price Type")
        {
            Caption = 'Sales Price on Order Lines';
            DataClassification = CustomerContent;
        }
        field(630; "Spfy C&C Order Workflow Code"; Code[20])
        {
            Caption = 'C&C Order Workflow Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Workflow";
        }
        field(640; "Invent.Level Update Batch Size"; Integer)
        {
            Caption = 'Invent.Level Update Batch Size';
            DataClassification = CustomerContent;
        }
        field(650; "Send Order Ready for Pickup"; Boolean)
        {
            Caption = 'Send C&C Order Ready for Pickup';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        _SpfyDataLogSubscrMgt: Codeunit "NPR Spfy DLog Subscr.Mgt.Impl.";
        _SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label '%1 record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr, Rec.TableCaption());
    end;

    trigger OnDelete()
    var
        SpfyAllowedFinStatus: Record "NPR Spfy Allowed Fin. Status";
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
    begin
        SpfyAllowedFinStatus.SetRange("Shopify Store Code", Code);
        if not SpfyAllowedFinStatus.IsEmpty() then
            SpfyAllowedFinStatus.DeleteAll();
        SpfyDataSyncPointer.SetRange("Shopify Store Code", Code);
        if not SpfyDataSyncPointer.IsEmpty() then
            SpfyDataSyncPointer.DeleteAll();
        SpfyAssignedIDMgt.RemoveAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID");
    end;

    internal procedure NoOfPriceUpdatesPerRequest(): Integer
    begin
        if "No. of Prices per Request" > 0 then
            exit("No. of Prices per Request");
        exit(100);
    end;

    internal procedure InventoryLevelUpdateRequestBatchSize(): Integer
    begin
        if "Invent.Level Update Batch Size" > 0 then
            exit("Invent.Level Update Batch Size");
        exit(100);
    end;

    internal procedure LookupVoucherType(var Text: Text): Boolean
    var
        VoucherType: Record "NPR NpRv Voucher Type";
    begin
        VoucherType.SetRange("Integrate with Shopify", true);
        if VoucherType.FindSet() then
            repeat
                if VoucherType.GetStoreCode() = Code then
                    VoucherType.Mark(true);
            until VoucherType.Next() = 0;
        VoucherType.MarkedOnly(true);

        if not VoucherType.IsEmpty() and (Text <> '') then begin
            VoucherType.Code := CopyStr(Text, 1, MaxStrLen(VoucherType.Code));
            if VoucherType.Find('=><') then;
        end;

        if Page.RunModal(0, VoucherType) = Action::LookupOK then begin
            Text := VoucherType.Code;
            exit(true);
        end;
        exit(false);
    end;

    internal procedure AddAllowedOrderFinancialStatus(OrderFinancialStatus: Enum "NPR Spfy Order FinancialStatus")
    var
        SpfyAllowedFinStatus: Record "NPR Spfy Allowed Fin. Status";
    begin
        SpfyAllowedFinStatus.Init();
        SpfyAllowedFinStatus."Shopify Store Code" := "Code";
        SpfyAllowedFinStatus."Order Financial Status" := OrderFinancialStatus;
        if not SpfyAllowedFinStatus.Find() then
            SpfyAllowedFinStatus.Insert();
    end;

    internal procedure SetItemCategoryMetafieldID(var MetafieldID: Text[30])
    var
        SpfyMFHdlItemCateg: Codeunit "NPR Spfy M/F Hdl.-Item Categ.";
    begin
        TestField(Code);
        TestField("Item Category as Metafield");
        if MetafieldID = '' then
            MetafieldID := ItemCategoryMetafieldID();
        SpfyMFHdlItemCateg.GetItemCategoryMetafieldDefinitionID(Code, true, MetafieldID);
        if MetafieldID <> '' then
            SaveItemCategoryMetafieldID(MetafieldID);
    end;

    internal procedure ItemCategoryMetafieldID(): Text[30]
    var
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        SpfyMetafieldMgt.FilterMetafieldMapping(RecordId(), FieldNo("Item Category as Metafield"), Code, Enum::"NPR Spfy Metafield Owner Type"::PRODUCT, SpfyMetafieldMapping);
        if not SpfyMetafieldMapping.FindFirst() then
            exit('');
        exit(SpfyMetafieldMapping."Metafield ID");
    end;

    internal procedure LoyaltyPointsMetafieldID(): Text[30]
    var
        SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        SpfyMetafieldMgt.FilterMetafieldMapping(RecordId(), FieldNo("Loyalty Points as Metafield"), Code, Enum::"NPR Spfy Metafield Owner Type"::CUSTOMER, SpfyMetafieldMapping);
        if not SpfyMetafieldMapping.FindFirst() then
            exit('');
        exit(SpfyMetafieldMapping."Metafield ID");
    end;

    internal procedure SaveItemCategoryMetafieldID(MetafieldID: Text[30])
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        SpfyMetafieldMgt.SaveMetafieldMapping(RecordId(), FieldNo("Item Category as Metafield"), Code, Enum::"NPR Spfy Metafield Owner Type"::PRODUCT, MetafieldID);
    end;

    internal procedure SaveLoyaltyPointsMetafieldID(MetafieldID: Text[30])
    var
        SpfyMetafieldMgt: Codeunit "NPR Spfy Metafield Mgt.";
    begin
        SpfyMetafieldMgt.SaveMetafieldMapping(RecordId(), FieldNo("Loyalty Points as Metafield"), Code, Enum::"NPR Spfy Metafield Owner Type"::CUSTOMER, MetafieldID);
    end;

    internal procedure SetLastOrdersImportedAt(NewDateTime: DateTime)
    var
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
    begin
        FindDataSyncPointer(SpfyDataSyncPointer);
        SpfyDataSyncPointer."Last Orders Imported At" := NewDateTime;
        SpfyDataSyncPointer.Modify();
    end;

#if not (BC18 or BC19 or BC20)
    internal procedure SetLastPOSRowVersion(NewRowVersion: BigInteger)
    var
        SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer";
    begin
        FindDataSyncPointer(SpfyDataSyncPointer);
        SpfyDataSyncPointer."Last POS Entry Row Version" := NewRowVersion;
        SpfyDataSyncPointer.Modify();
    end;
#endif

    local procedure FindDataSyncPointer(var SpfyDataSyncPointer: Record "NPR Spfy Data Sync. Pointer")
    begin
        TestField(Code);
        SpfyDataSyncPointer.LockTable();
        SpfyDataSyncPointer."Shopify Store Code" := Code;
        if not SpfyDataSyncPointer.Find() then begin
            SpfyDataSyncPointer.Init();
            SpfyDataSyncPointer.Insert();
        end;
    end;
}
#endif
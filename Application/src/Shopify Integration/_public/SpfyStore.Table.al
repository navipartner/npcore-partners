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
                SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
            begin
                if Enabled then
                    TestField("Shopify Url");
                Modify();

                ShopifyStore.Get("Code");
                ShopifyStore.SetRecFilter();
                SpfyScheduleSend.SetupTaskProcessingJobQueues(ShopifyStore);
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
            begin
                Modify();
                OrderMgt.SetupJobQueues();
                if "Sales Order Integration" then begin
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
        }
        field(82; "Delete on Cancellation"; Boolean)
        {
            Caption = 'Delete on Cancellation';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(85; "Get Payment Lines from Shopify"; Option)
        {
            Caption = 'Get Payment Lines from Shopify';
            DataClassification = CustomerContent;
            OptionMembers = ON_CAPTURE,ON_ORDER_IMPORT;
            OptionCaption = 'Before Capture,On Order Import';
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
                    TestField("Sales Order Integration");
            end;
        }
        field(110; "Send Close Order Requets"; Boolean)
        {
            Caption = 'Send Close Order Requests';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Send Close Order Requets" then
                    TestField("Sales Order Integration");
            end;
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
        field(500; "Auto Set as Shopify Item"; Boolean)
        {
            Caption = 'Auto Set as Shopify Item';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Code);
                TestField(Enabled);
                Modify();
                _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"products/create", "Auto Set as Shopify Item");
                _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"products/delete", "Auto Set as Shopify Item");
                if not "Auto Update Items from Shopify" then
                    _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"products/update", "Auto Set as Shopify Item");
            end;
        }
        field(510; "Auto Update Items from Shopify"; Boolean)
        {
            Caption = 'Auto Update Items from Shopify';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Code);
                TestField(Enabled);
                Modify();
                if not "Auto Set as Shopify Item" then
                    _SpfyWebhookMgt.ToggleWebhook(Code, Enum::"NPR Spfy Webhook Topic"::"products/update", "Auto Update Items from Shopify");
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
        field(600; "Customer No. (Price)"; Code[20])
        {
            Caption = 'Customer No. (Price)';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(610; "No. of Prices per Request"; Integer)
        {
            Caption = 'No. of Prices per Request';
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
    begin
        SpfyAllowedFinStatus.SetRange("Shopify Store Code", Code);
        if not SpfyAllowedFinStatus.IsEmpty() then
            SpfyAllowedFinStatus.DeleteAll();
    end;

    internal procedure NoOfPriceUpdatesPerRequest(): Integer
    begin
        if "No. of Prices per Request" > 0 then
            exit("No. of Prices per Request");
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
}
#endif
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
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    var
        _SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";

    trigger OnRename()
    var
        RecordCannotBeRenamedErr: Label '%1 record cannot be renamed.';
    begin
        Error(RecordCannotBeRenamedErr, Rec.TableCaption());
    end;
}
#endif
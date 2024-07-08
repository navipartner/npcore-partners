#if not BC17
table 6150807 "NPR Spfy Integration Setup"
{
    Access = Internal;
    Caption = 'Shopify Integration Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Spfy Integration Setup";
    LookupPageID = "NPR Spfy Integration Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Enable Integration"; Boolean)
        {
            Caption = 'Enable Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                OrderMgt: Codeunit "NPR Spfy Order Mgt.";
                SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
            begin
                Modify();
                SpfyScheduleSend.SetupTaskProcessingJobQueues();
                OrderMgt.SetupJobQueues();
            end;
        }
        field(30; "Shopify Api Version"; Text[10])
        {
            Caption = 'Shopify Api Version';
            DataClassification = CustomerContent;
            InitValue = '2024-01';

            trigger OnValidate()
            var
                ShopifySetup2: Record "NPR Spfy Integration Setup";
            begin
                if "Shopify Api Version" = '' then begin
                    ShopifySetup2.Init();
                    if ShopifySetup2."Shopify Api Version" <> '' then
                        "Shopify Api Version" := ShopifySetup2."Shopify Api Version";
                end;
            end;
        }
        field(40; "Item List Integration"; Boolean)
        {
            Caption = 'Item List Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Item List Integration" then
                    SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::Items);
            end;
        }
        field(41; "Do Not Sync. Sales Prices"; Boolean)
        {
            Caption = 'Do Not Sync. Sales Prices';
            DataClassification = CustomerContent;
        }
        field(42; "Set Shopify Name/Descr. in BC"; Boolean)
        {
            Caption = 'Set Shopify Name/Descr. in BC';
            DataClassification = CustomerContent;
        }
        field(50; "Send Inventory Updates"; Boolean)
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
                    SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Inventory Levels");
                end;
            end;
        }
        field(51; "Include Transfer Orders"; Option)
        {
            Caption = 'Include Transfer Orders';
            DataClassification = CustomerContent;
            OptionMembers = No,Outbound,All;
            OptionCaption = 'No,Outbound,All';

            trigger OnValidate()
            begin
                if "Include Transfer Orders" <> "Include Transfer Orders"::No then begin
                    Modify();
                    SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Inventory Levels");
                end;
            end;
        }
        field(60; "Sales Order Integration"; Boolean)
        {
            Caption = 'Sales Order Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                OrderMgt: Codeunit "NPR Spfy Order Mgt.";
            begin
                Modify();
                OrderMgt.SetupJobQueues();
            end;
        }
        field(61; "Post on Completion"; Boolean)
        {
            Caption = 'Post on Completion';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(62; "Delete on Cancellation"; Boolean)
        {
            Caption = 'Delete on Cancellation';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(65; "Get Payment Lines From Shopify"; Option)
        {
            Caption = 'Get Payment Lines From Shopify';
            DataClassification = CustomerContent;
            OptionMembers = ON_CAPTURE,ON_ORDER_IMPORT;
            OptionCaption = 'Before Capture,On Order Import';
        }
        field(70; "Send Order Fulfillments"; Boolean)
        {
            Caption = 'Send Order Fulfillments';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Send Order Fulfillments" then
                    TestField("Sales Order Integration");
            end;
        }
        field(80; "Send Payment Capture Requests"; Boolean)
        {
            Caption = 'Send Payment Capture Requests';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Send Payment Capture Requests" then
                    TestField("Sales Order Integration");
            end;
        }
        field(90; "Send Close Order Requets"; Boolean)
        {
            Caption = 'Send Close Order Requests';
            DataClassification = CustomerContent;
        }
        field(100; "Allowed Payment Statuses"; Option)
        {
            Caption = 'Allowed Payment Statuses';
            DataClassification = CustomerContent;
            OptionMembers = Authorized,Paid,Both;
            OptionCaption = 'Authorized,Paid,Both';
        }
        field(110; "Retail Voucher Integration"; Boolean)
        {
            Caption = 'Retail Voucher Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Retail Voucher Integration" then
                    SpfyDataLogSubscrMgt.CreateDataLogSetup("NPR Spfy Integration Area"::"Retail Vouchers");
            end;
        }
        field(120; "Send Negative Inventory"; Boolean)
        {
            Caption = 'Send Negative Inventory';
            DataClassification = CustomerContent;
        }
        field(125; "C&C Order Integration"; Boolean)
        {
            Caption = 'CC Order Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                SpfyCCOrderHandler: Codeunit "NPR Spfy C&C Order Handler";
            begin
                if "C&C Order Integration" then begin
                    SpfyCCOrderHandler.RegisterCCOrderListener();
                    SpfyCCOrderHandler.EnableWebhookRequestRetentionPolicy();
                end;
            end;
        }
        field(130; "C&C Order Workflow Code"; Code[20])
        {
            Caption = 'CC Order Workflow Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Workflow";
        }
        field(140; "Data Processing Handler ID"; Code[20])
        {
            Caption = 'Data Processing Handler ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ConfirmDataProcessingHandlerChangeQst: Label 'You have changed %1. Note that the previous value may have already been used to set up associated task processor, import task type and data log subscriber records. These will not be updated automatically. You must update them manually or the functionality will not work properly.\\Are you sure you want to change the field value?', Comment = '%1 - field caption';
            begin
                if "Data Processing Handler ID" = '' then
                    SetDataProcessingHandlerIDToDefaultValue();
                if "Data Processing Handler ID" <> xRec."Data Processing Handler ID" then
                    if not Confirm(ConfirmDataProcessingHandlerChangeQst, false, FieldCaption("Data Processing Handler ID")) then
                        "Data Processing Handler ID" := xRec."Data Processing Handler ID";
            end;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        SetDataProcessingHandlerIDToDefaultValue();
    end;

    procedure SetDataProcessingHandlerIDToDefaultValue()
    var
        ShopifyDataProcessingHandlerID: Label 'SHOPIFY', Locked = true, MaxLength = 20;
    begin
        "Data Processing Handler ID" := ShopifyDataProcessingHandlerID;
    end;

    procedure GetRecordOnce(ReRead: Boolean)
    begin
        if RecordHasBeenRead and not ReRead then
            exit;
        if not Get() then begin
            Init();
            Insert(true);
        end;
        RecordHasBeenRead := true;
    end;

    var
        SpfyDataLogSubscrMgt: Codeunit "NPR Spfy DLog Subscr.Mgt.Impl.";
        RecordHasBeenRead: Boolean;
}
#endif
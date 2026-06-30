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
#if not (BC18 or BC19 or BC20)
                SpfyExportBCTransJQ: Codeunit "NPR Spfy Export BC Trans. JQ";
#endif
                SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
                SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
#endif
            begin
                Modify();
                SpfyScheduleSend.SetupTaskProcessingJobQueues();
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
                if ShopifyEcommOrderExp.IsFeatureEnabled() then
                    SpfyEcomSalesDocPrcssr.SetupJobQueues()
                else
#endif
                OrderMgt.SetupJobQueues();
#if not (BC18 or BC19 or BC20)
                SpfyExportBCTransJQ.SetupBCTransExportJobQueues();
#endif
            end;
        }
        field(30; "Shopify Api Version"; Text[10])
        {
            Caption = 'Shopify Api Version';
            DataClassification = CustomerContent;
            InitValue = '2025-10';

            trigger OnValidate()
            var
                ShopifySetup2: Record "NPR Spfy Integration Setup";
                ConfirmApiVersionChangeQst: Label 'The recommended %1 is ‘%3’, which this integration has been tested against. Changing it to ‘%2’ is not recommended and could cause some Shopify data exchange procedures to stop working or malfunction. Do you want to change the %1 anyway?', Comment = '%1 = Shopify Api Version field caption, %2 = the API version being entered, %3 = the recommended API version';
            begin
                ShopifySetup2.Init();
                if "Shopify Api Version" = '' then
                    "Shopify Api Version" := ShopifySetup2."Shopify Api Version"
                else
                    CheckApiVersionFormat("Shopify Api Version");
                if not ("Shopify Api Version" in ['', ShopifySetup2."Shopify Api Version"]) then
                    if not Confirm(ConfirmApiVersionChangeQst, false, FieldCaption("Shopify Api Version"), "Shopify Api Version", ShopifySetup2."Shopify Api Version") then
                        "Shopify Api Version" := ShopifySetup2."Shopify Api Version";
            end;
        }
        field(40; "Item List Integration"; Boolean)
        {
            Caption = 'Item List Integration';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(41; "Do Not Sync. Sales Prices"; Boolean)
        {
            Caption = 'Do Not Sync. Sales Prices';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(42; "Set Shopify Name/Descr. in BC"; Boolean)
        {
            Caption = 'Set Shopify Name/Descr. in BC';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(50; "Send Inventory Updates"; Boolean)
        {
            Caption = 'Send Inventory Updates';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(51; "Include Transfer Orders"; Option)
        {
            Caption = 'Include Transfer Orders';
            DataClassification = CustomerContent;
            OptionMembers = No,Outbound,All;
            OptionCaption = 'No,Outbound,All';
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(60; "Sales Order Integration"; Boolean)
        {
            Caption = 'Sales Order Integration';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(61; "Post on Completion"; Boolean)
        {
            Caption = 'Post on Completion';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(62; "Delete on Cancellation"; Boolean)
        {
            Caption = 'Delete on Cancellation';
            DataClassification = CustomerContent;
            InitValue = true;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(65; "Get Payment Lines From Shopify"; Option)
        {
            Caption = 'Get Payment Lines From Shopify';
            DataClassification = CustomerContent;
            OptionMembers = ON_CAPTURE,ON_ORDER_IMPORT;
            OptionCaption = 'Before Capture,On Order Import';
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(70; "Send Order Fulfillments"; Boolean)
        {
            Caption = 'Send Order Fulfillments';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(80; "Send Payment Capture Requests"; Boolean)
        {
            Caption = 'Send Payment Capture Requests';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(90; "Send Close Order Requets"; Boolean)
        {
            Caption = 'Send Close Order Requests';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(100; "Allowed Payment Statuses"; Option)
        {
            Caption = 'Allowed Payment Statuses';
            DataClassification = CustomerContent;
            OptionMembers = Authorized,Paid,Both;
            OptionCaption = 'Authorized,Paid,Both';
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(110; "Retail Voucher Integration"; Boolean)
        {
            Caption = 'Retail Voucher Integration';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(120; "Send Negative Inventory"; Boolean)
        {
            Caption = 'Send Negative Inventory';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'The setup is now store-specific (moved to table 6150810 "NPR Spfy Store")';
        }
        field(125; "C&C Order Integration"; Boolean)
        {
            Caption = 'CC Order Integration';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'Moved to a PTE as it was a customization for a specific customer.';
        }
        field(130; "C&C Order Workflow Code"; Code[20])
        {
            Caption = 'CC Order Workflow Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Workflow";
            ObsoleteState = Removed;
            ObsoleteTag = '2024-08-25';
            ObsoleteReason = 'Moved to a PTE as it was a customization for a specific customer.';
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
#if not BC18 and not BC19 and not BC20 and not BC21 and not BC22
        field(150; "Max Doc Process Retry Count"; Integer)
        {
            Caption = 'Max. Document Process Retry Count';
            DataClassification = CustomerContent;
            InitValue = 5;
        }
#endif
        field(160; "Enable Product Variant Sorting"; Boolean)
        {
            Caption = 'Enable Product Variant Sorting';
            DataClassification = CustomerContent;
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
        ShopifyDataProcessingHandlerID: Label 'SPFY', Locked = true, MaxLength = 20;
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

    local procedure CheckApiVersionFormat(ApiVersion: Text[10])
    var
        Year: Integer;
        Month: Integer;
        Index: Integer;
        ValidFormat: Boolean;
        InvalidFormatErr: Label 'The %1 ‘%2’ is not a valid Shopify API version. Shopify API versions use the YYYY-MM format, for example ‘%3’.', Comment = '%1 = Shopify Api Version field caption, %2 = the entered value, %3 = an example of a valid version';
        ExampleVersionTok: Label '2025-10', Locked = true;
    begin
        ValidFormat := StrLen(ApiVersion) = 7;
        if ValidFormat then
            ValidFormat := ApiVersion[5] = '-';
        if ValidFormat then
            for Index := 1 to 7 do
                if (Index <> 5) and not (ApiVersion[Index] in ['0' .. '9']) then
                    ValidFormat := false;
        if ValidFormat then begin
            Evaluate(Year, CopyStr(ApiVersion, 1, 4));
            Evaluate(Month, CopyStr(ApiVersion, 6, 2));
            // Shopify introduced dated API versions in 2019-04; allow next year too for versions Shopify pre-releases ahead of time.
            ValidFormat :=
                (Year >= 2019) and (Year <= Date2DMY(Today(), 3) + 1) and
                (Month >= 1) and (Month <= 12);
        end;
        if not ValidFormat then
            Error(InvalidFormatErr, FieldCaption("Shopify Api Version"), ApiVersion, ExampleVersionTok);
    end;

    var
        RecordHasBeenRead: Boolean;
}
#endif
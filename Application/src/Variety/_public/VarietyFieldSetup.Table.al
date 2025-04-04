﻿table 6059975 "NPR Variety Field Setup"
{
    Caption = 'Variety Field Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Variety Fields Lookup";
    LookupPageId = "NPR Variety Fields Lookup";

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Field,Internal,,Subscriber';
            OptionMembers = "Field",Internal,,Subscriber;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                if Type <> Type::Field then
                    exit;

                if "Field No." = 0 then
                    Clear(Field)
                else
                    Field.Get("Table No.", "Field No.");
                Description := Field.FieldName;
            end;
        }
        field(8; Disabled; Boolean)
        {
            Caption = 'Disabled';
            DataClassification = CustomerContent;
        }
        field(9; "Sort Order"; Integer)
        {
            Caption = 'Sort Order';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(12; "Show Total Column"; Boolean)
        {
            Caption = 'Show Total Column';
            DataClassification = CustomerContent;
        }
        field(15; "Variety Matrix Subscriber 1"; Text[60])
        {
            Caption = 'Variety Matrix Subscriber 1';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'GetVarietyMatrixFieldValue');//no its not a mistake. it must be called DrillDown, even if its Lookup
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) <> Action::LookupOK then
                    exit;

                Validate("Variety Matrix Subscriber 1", EventSubscription."Subscriber Function");
            end;

            trigger OnValidate()
            begin
                if Type = Type::Subscriber then
                    Description := CopyStr("Variety Matrix Subscriber 1", 1, MaxStrLen(Description));
            end;
        }
        field(20; "Validate Field"; Boolean)
        {
            Caption = 'Validate Field';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(21; "Editable Field"; Boolean)
        {
            Caption = 'Editable Field';
            DataClassification = CustomerContent;
        }
        field(22; "Is Table Default"; Boolean)
        {
            Caption = 'Is Table Default';
            DataClassification = CustomerContent;
        }
        field(23; "Is Table Default Maintenance"; Boolean)
        {
            Caption = 'Is Table Default (Maintenance Matrix)';
            DataClassification = CustomerContent;
        }
        field(30; "Use Location Filter"; Boolean)
        {
            Caption = 'Use Location Filter';
            DataClassification = CustomerContent;
        }
        field(31; "Use Global Dim 1 Filter"; Boolean)
        {
            Caption = 'Use Global Dim 1 Filter';
            DataClassification = CustomerContent;
        }
        field(32; "Use Global Dim 2 Filter"; Boolean)
        {
            Caption = 'Use Global Dim 2 Filter';
            DataClassification = CustomerContent;
        }
        field(40; "Field Type Name"; Text[30])
        {
            CalcFormula = lookup(Field."Type Name" where(TableNo = field("Table No."),
                                                          "No." = field("Field No.")));
            Caption = 'Field Type Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Secondary Type"; Option)
        {
            Caption = 'Secondary Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Field,Internal,Codeunit,Subscriber';
            OptionMembers = "Field",Internal,"Codeunit",Subscriber;
        }
        field(51; "Secondary Table No."; Integer)
        {
            Caption = 'Secondary Table No.';
            DataClassification = CustomerContent;
        }
        field(52; "Secondary Field No."; Integer)
        {
            Caption = 'Secondary Field No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                "Field": Record "Field";
            begin
                if "Secondary Type" = "Secondary Type"::Internal then begin
                    case "Secondary Field No." of
                        1:
                            "Secondary Description" := Text001;
                    end;
                end;

                if "Secondary Type" <> "Secondary Type"::Field then
                    exit;

                if "Secondary Field No." = 0 then
                    Clear(Field)
                else
                    Field.Get("Secondary Table No.", "Secondary Field No.");
                "Secondary Description" := Field.FieldName;
            end;
        }
        field(53; "Secondary Description"; Text[50])
        {
            Caption = 'Secondary Field Description';
            DataClassification = CustomerContent;
        }
        field(55; "Variety Matrix Subscriber 2"; Text[60])
        {
            Caption = 'Variety Matrix Subscriber 2';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'GetVarietyMatrixFieldValue');//no its not a mistake. it must be called DrillDown, even if its Lookup
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) <> Action::LookupOK then
                    exit;

                Validate("Variety Matrix Subscriber 2", EventSubscription."Subscriber Function");
            end;

            trigger OnValidate()
            begin
                if "Secondary Type" = "Secondary Type"::Subscriber then
                    "Secondary Description" := CopyStr("Variety Matrix Subscriber 2", 1, MaxStrLen("Secondary Description"));
            end;
        }
        field(57; "Secondary Field Type Name"; Text[30])
        {
            CalcFormula = lookup(Field."Type Name" where(TableNo = field("Secondary Table No."), "No." = field("Secondary Field No.")));
            Caption = 'Secondary Field Type Name';
            Editable = false;
            FieldClass = FlowField;
        }

        field(60; "Use Location Filter (Sec)"; Boolean)
        {
            Caption = 'Use Location Filter (Sec)';
            DataClassification = CustomerContent;
        }
        field(61; "Use Global Dim 1 Filter (Sec)"; Boolean)
        {
            Caption = 'Use Global Dim 1 Filter (Sec)';
            DataClassification = CustomerContent;
        }
        field(62; "Use Global Dim 2 Filter (Sec)"; Boolean)
        {
            Caption = 'Use Global Dim 2 Filter (Sec)';
            DataClassification = CustomerContent;
        }
        field(70; "Lookup Type"; Option)
        {
            Caption = 'Lookup Type';
            DataClassification = CustomerContent;
            OptionCaption = ',,Codeunit,Subscriber';
            OptionMembers = "Field",Internal,"Codeunit",Subscriber;
        }
        field(71; "Lookup Object No."; Integer)
        {
            Caption = 'Lookup Object No.';
            DataClassification = CustomerContent;
        }
        field(73; "Call Codeunit with rec"; Boolean)
        {
            Caption = 'Call Codeunit with rec';
            DataClassification = CustomerContent;
        }
        field(74; "Function Identifier"; Code[20])
        {
            Caption = 'Function Identifier';
            DataClassification = CustomerContent;
        }
        field(75; "OnLookup Subscriber"; Text[60])
        {
            Caption = 'OnLookup Subscriber';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'OnDrillDownVarietyMatrix');//no its not a mistake. it must be called DrillDown, even if its Lookup
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) <> Action::LookupOK then
                    exit;

                Validate("OnLookup Subscriber", EventSubscription."Subscriber Function");
            end;
        }
        field(76; "Use OnLookup Return Value"; Boolean)
        {
            Caption = 'Use OnLookup Return Value';
            DataClassification = CustomerContent;
        }
        field(80; "OnDrillDown Codeunit ID"; Integer)
        {
            Caption = 'OnDrillDown Codeunit ID';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'OnDrillDownEvent');
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) <> Action::LookupOK then
                    exit;

                Validate("OnDrillDown Codeunit ID", EventSubscription."Subscriber Codeunit ID");
            end;
        }
        field(85; "OnDrillDown Subscriber"; Text[60])
        {
            Caption = 'OnDrillDown Subscriber';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", Codeunit::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'OnDrillDownVarietyMatrix');
                if Page.RunModal(Page::"Event Subscriptions", EventSubscription) <> Action::LookupOK then
                    exit;

                Validate("OnDrillDown Subscriber", EventSubscription."Subscriber Function");
            end;
        }
        field(86; "Use OnDrillDown Return Value"; Boolean)
        {
            Caption = 'Use OnDrillDown Return Value';
            DataClassification = CustomerContent;
        }
        field(100; "Item No. (TMPParm)"; Code[20])
        {
            Caption = 'Item No. (TMPParm)';
            DataClassification = CustomerContent;
        }
        field(101; "Variant Code (TMPParm)"; Code[10])
        {
            Caption = 'Variant Code (TMPParm)';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Type, "Table No.", "Field No.")
        {
        }
        key(Key2; "Sort Order")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Inventory';
        CreateVariantDesc: Label 'Create Variants';

    procedure InitVarietyFields()
    var
        VRTFieldsSetup: Record "NPR Variety Field Setup";
    begin
        //Sales Line

        InsertVarietyFields(0, 37, 7, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupLocation', true, 'LookupInventoryPerLocation', false);
        InsertVarietyFields(0, 37, 10, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 15, true, true, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupAvailabilityByEvent', false, 'LookupAvailabilityByTimeLine', false);
        InsertVarietyFields(0, 37, 17, true, true, false, 0, 37, 15, '', '', '', false, '', false);
        InsertVarietyFields(0, 37, 18, true, true, false, 0, 37, 15, '', '', '', false, '', false);
        InsertVarietyFields(0, 37, 22, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 27, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 28, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 29, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 30, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 40, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 41, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 103, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 37, 5402, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //Purchase Line
        InsertVarietyFields(0, 39, 7, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupLocation', true, 'LookupInventoryPerLocation', false);
        InsertVarietyFields(0, 39, 10, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 15, true, true, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupAvailabilityByEvent', false, 'LookupAvailabilityByTimeLine', false);
        InsertVarietyFields(0, 39, 17, true, true, false, 0, 39, 15, '', '', '', false, '', false);
        InsertVarietyFields(0, 39, 18, true, true, false, 0, 39, 15, '', '', '', false, '', false);
        InsertVarietyFields(0, 39, 22, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 27, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 28, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 29, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 30, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 40, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 41, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 103, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 39, 5402, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //Sales Shipment line
        InsertVarietyFields(0, 111, 7, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupLocation', false, 'LookupInventoryPerLocation', false);
        InsertVarietyFields(0, 111, 10, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 111, 15, true, false, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 111, 22, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 111, 27, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 111, 40, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 111, 41, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 111, 5402, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //Sales Invoice line
        InsertVarietyFields(0, 113, 7, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupLocation', false, 'LookupInventoryPerLocation', false);
        InsertVarietyFields(0, 113, 10, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 113, 15, true, false, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 113, 22, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 113, 27, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 113, 40, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 113, 41, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 113, 5402, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //Sales Cr Memo line
        InsertVarietyFields(0, 115, 7, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupLocation', false, 'LookupInventoryPerLocation', false);
        InsertVarietyFields(0, 115, 10, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 115, 15, true, false, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 115, 22, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 115, 27, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 115, 40, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 115, 41, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 115, 5402, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //Purchase Receipt line
        InsertVarietyFields(0, 121, 7, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupLocation', false, 'LookupInventoryPerLocation', false);
        InsertVarietyFields(0, 121, 10, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 121, 15, true, false, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 121, 22, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 121, 27, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 121, 40, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 121, 41, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 121, 5402, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //Purchase Invoice line
        InsertVarietyFields(0, 123, 7, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupLocation', false, 'LookupInventoryPerLocation', false);
        InsertVarietyFields(0, 123, 10, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 123, 15, true, false, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 123, 22, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 123, 27, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 123, 40, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 123, 41, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 123, 5402, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //Purchase Cr Memo line
        InsertVarietyFields(0, 125, 7, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupLocation', false, 'LookupInventoryPerLocation', false);
        InsertVarietyFields(0, 125, 10, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 125, 15, true, false, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 125, 22, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 125, 27, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 125, 40, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 125, 41, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 125, 5402, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        InsertVarietyFields(0, 5401, 1, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 5401, 6059982, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        if VRTFieldsSetup.Get(1, 5401, 1) then
            VRTFieldsSetup.Delete();

        InsertVarietyFields(1, 5401, 2, false, false, true, 0, 0, 0, '', '', '', false, '', false);
        SetDescription(1, 5401, 2, CreateVariantDesc);

        if VRTFieldsSetup.Get(1, 5401, 3) then
            VRTFieldsSetup.Delete();
        InsertVarietyFields(3, 5401, 100000, false, true, false, 0, 0, 0, 'GetItemReference', '', 'LookupItemReference', true, '', false);

        InsertVarietyFields(3, 5401, 100001, false, false, false, 3, 0, 0, 'GetExpectedInventory', 'GetPlannedOrderRcpt', 'LookupAvailabilityByEvent', false, 'LookupAvailabilityByLocation', false);

        InsertVarietyFields(0, 5741, 4, true, true, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupAvailabilityByLocation', false, '', false);
        InsertVarietyFields(0, 5741, 6, true, true, false, 0, 5741, 4, '', '', '', false, '', false);
        InsertVarietyFields(0, 5741, 7, true, true, false, 0, 5741, 4, '', '', '', false, '', false);

        InsertVarietyFields(0, 7002, 5, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        InsertVarietyFields(0, 6014422, 3, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 7, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 8, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 17, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 18, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 47, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        InsertVarietyFields(0, 7012, 5, true, true, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        InsertVarietyFields(0, 83, 9, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 83, 13, true, true, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 83, 15, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 83, 50, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        Commit();
    end;

    local procedure InsertVarietyFields(ParamType: Integer; TableNo: Integer; FieldNo: Integer; ValidateField: Boolean; EditField: Boolean; TableDefault: Boolean; Type2: Integer; TableNo2: Integer; FieldNo2: Integer; MatrixSubscriber1: Text; MatrixSubscriber2: Text; MatrixSubscriberOnLookup: Text; UseOnLookupValue: Boolean; MatrixSubscriberOnDrillDown: Text; UseOnDrillDownalue: Boolean)
    var
        VRTFieldsSetup: Record "NPR Variety Field Setup";
    begin
        if VRTFieldsSetup.Get(ParamType, TableNo, FieldNo) then begin
            if (VRTFieldsSetup."Secondary Type" = 1) and
               (VRTFieldsSetup."Secondary Table No." = 1) and
               (VRTFieldsSetup."Secondary Field No." = 1) then begin
                VRTFieldsSetup."Secondary Type" := Type2;
                VRTFieldsSetup."Secondary Table No." := TableNo2;
                VRTFieldsSetup.Validate("Secondary Field No.", FieldNo2);
                VRTFieldsSetup.Validate("Variety Matrix Subscriber 1", MatrixSubscriber1);
                VRTFieldsSetup.Validate("Variety Matrix Subscriber 2", MatrixSubscriber2);
                VRTFieldsSetup."OnLookup Subscriber" := CopyStr(MatrixSubscriberOnLookup, 1, MaxStrLen(VRTFieldsSetup."OnLookup Subscriber"));
                VRTFieldsSetup."Use OnLookup Return Value" := UseOnLookupValue;
                VRTFieldsSetup."OnDrillDown Subscriber" := CopyStr(MatrixSubscriberOnDrillDown, 1, MaxStrLen(VRTFieldsSetup."OnDrillDown Subscriber"));
                VRTFieldsSetup."Use OnDrillDown Return Value" := UseOnDrillDownalue;
                VRTFieldsSetup.Modify();
            end;

            exit;
        end;

        VRTFieldsSetup.Init();
        VRTFieldsSetup.Type := ParamType;
        VRTFieldsSetup."Table No." := TableNo;
        VRTFieldsSetup.Validate("Field No.", FieldNo);
        VRTFieldsSetup."Validate Field" := ValidateField;
        VRTFieldsSetup."Editable Field" := EditField;
        VRTFieldsSetup."Is Table Default" := TableDefault;
        VRTFieldsSetup."Secondary Type" := Type2;
        VRTFieldsSetup."Secondary Table No." := TableNo2;
        VRTFieldsSetup.Validate("Secondary Field No.", FieldNo2);
        VRTFieldsSetup.Validate("Variety Matrix Subscriber 1", MatrixSubscriber1);
        VRTFieldsSetup.Validate("Variety Matrix Subscriber 2", MatrixSubscriber2);
        VRTFieldsSetup."OnLookup Subscriber" := CopyStr(MatrixSubscriberOnLookup, 1, MaxStrLen(VRTFieldsSetup."OnLookup Subscriber"));
        VRTFieldsSetup."Use OnLookup Return Value" := UseOnLookupValue;
        VRTFieldsSetup."OnDrillDown Subscriber" := CopyStr(MatrixSubscriberOnDrillDown, 1, MaxStrLen(VRTFieldsSetup."OnDrillDown Subscriber"));
        VRTFieldsSetup."Use OnDrillDown Return Value" := UseOnDrillDownalue;

        if VRTFieldsSetup.Insert() then;
    end;

    internal procedure UpdateToLatestVersion()
    var
        VRTFieldsSetup: Record "NPR Variety Field Setup";
    begin
        if VRTFieldsSetup.Get(0, 83, 13) then
            exit;

        InitVarietyFields();
    end;

    local procedure SetDescription(ParamType: Integer; TableNo: Integer; FieldNo: Integer; NewDescription: Text)
    var
        VRTFieldsSetup: Record "NPR Variety Field Setup";
    begin
        if not VRTFieldsSetup.Get(ParamType, TableNo, FieldNo) then
            exit;
        VRTFieldsSetup.Description := CopyStr(NewDescription, 1, MaxStrLen(VRTFieldsSetup.Description));
        VRTFieldsSetup.Modify();
    end;
}

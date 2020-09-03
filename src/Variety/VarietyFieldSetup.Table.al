table 6059975 "NPR Variety Field Setup"
{
    // VRT1.01/MMV/20150528 CASE 213635 Added RJL handling to default initialization
    // VRT1.10/JDH/20160105 CASE 201022 Added extra fields to default initialization
    // VRT1.11/JDH /20160601 CASE 242940 Changed default page to new lookuppage + Captions + changed a few fieldnames
    // NPR5.28/JDH /20161024 CASE 255961 Added Field "OnDrillDown Codeunit ID"
    // NPR5.31/JDH /20170502 CASE 271133 Added Purchase Prices
    // NPR5.32/JDH /20170510 CASE 274170 Variable Cleanup
    // NPR5.36/JDH /20170922 CASE 285733 Added Fields for Item Journal Line
    // NPR5.47/JDH /20180917 CASE 324997 Added Subscriber on every possible lookup
    // NPR5.47/NPKNAV/20181026  CASE 327541-01 Transport NPR5.47 - 26 October 2018

    Caption = 'Variety Field Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Variety Fields Lookup";
    LookupPageID = "NPR Variety Fields Lookup";

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
        field(15; "Variety Matrix Subscriber 1"; Text[60])
        {
            Caption = 'Variety Matrix Subscriber 1';
            DataClassification = CustomerContent;

            trigger OnLookup()
            var
                EventSubscription: Record "Event Subscription";
            begin
                //-NPR5.47 [324997]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'GetVarietyMatrixFieldValue');//no its not a mistake. it must be called DrillDown, even if its Lookup
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("Variety Matrix Subscriber 1", EventSubscription."Subscriber Function");
                //+NPR5.47 [324997]
            end;

            trigger OnValidate()
            begin
                //-NPR5.47 [327541]
                if Type = Type::Subscriber then
                    Description := CopyStr("Variety Matrix Subscriber 1", 1, MaxStrLen(Description));
                //+NPR5.47 [327541]
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
            CalcFormula = Lookup (Field."Type Name" WHERE(TableNo = FIELD("Table No."),
                                                          "No." = FIELD("Field No.")));
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
                //-VRT1.10
                if "Secondary Type" = "Secondary Type"::Internal then begin
                    case "Secondary Field No." of
                        1:
                            "Secondary Description" := Text001;
                    end;
                end;
                //+VRT1.10

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
                //-NPR5.47 [324997]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'GetVarietyMatrixFieldValue');//no its not a mistake. it must be called DrillDown, even if its Lookup
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("Variety Matrix Subscriber 2", EventSubscription."Subscriber Function");
                //+NPR5.47 [324997]
            end;

            trigger OnValidate()
            begin
                //-NPR5.47 [327541]
                if "Secondary Type" = "Secondary Type"::Subscriber then
                    "Secondary Description" := CopyStr("Variety Matrix Subscriber 2", 1, MaxStrLen("Secondary Description"));
                //+NPR5.47 [327541]
            end;
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
                //-NPR5.47 [324997]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'OnDrillDownVarietyMatrix');//no its not a mistake. it must be called DrillDown, even if its Lookup
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("OnLookup Subscriber", EventSubscription."Subscriber Function");
                //+NPR5.47 [324997]
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
                //-NPR5.28 [255961]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'OnDrillDownEvent');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("OnDrillDown Codeunit ID", EventSubscription."Subscriber Codeunit ID");
                //+NPR5.28 [255961]
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
                //-NPR5.47 [324997]
                EventSubscription.SetRange("Publisher Object Type", EventSubscription."Publisher Object Type"::Codeunit);
                EventSubscription.SetRange("Publisher Object ID", CODEUNIT::"NPR Variety Matrix Management");
                EventSubscription.SetRange("Published Function", 'OnDrillDownVarietyMatrix');
                if PAGE.RunModal(PAGE::"Event Subscriptions", EventSubscription) <> ACTION::LookupOK then
                    exit;

                Validate("OnDrillDown Subscriber", EventSubscription."Subscriber Function");
                //+NPR5.47 [324997]
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
        ItemCrossRef: Label 'Item Cross References';

    procedure InitVarietyFields()
    var
        VRTFieldsSetup: Record "NPR Variety Field Setup";
        VRTFieldsSetupCopy: Record "NPR Variety Field Setup";
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

        //Item Variant
        InsertVarietyFields(0, 5401, 1, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 5401, 6059982, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        if VRTFieldsSetup.Get(1, 5401, 1) then
            VRTFieldsSetup.Delete;

        InsertVarietyFields(1, 5401, 2, false, false, true, 0, 0, 0, '', '', '', false, '', false);
        SetDescription(1, 5401, 2, CreateVariantDesc);

        //-NPR5.47 [327541]
        //InsertVarietyFields(1,5401,3,FALSE,FALSE,FALSE, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', FALSE, '', FALSE);
        //SetDescription(1,5401,3, ItemCrossRef);
        if VRTFieldsSetup.Get(1, 5401, 3) then
            VRTFieldsSetup.Delete;
        InsertVarietyFields(3, 5401, 100000, false, true, false, 0, 0, 0, 'GetItemCrossReference', '', 'LookupItemCrossReference', true, '', false);

        InsertVarietyFields(3, 5401, 100001, false, false, false, 3, 0, 0, 'GetExpectedInventory', 'GetPlannedOrderRcpt', 'LookupAvailabilityByEvent', false, 'LookupAvailabilityByLocation', false);
        //+NPR5.47 [327541]

        //Transfer Line
        InsertVarietyFields(0, 5741, 4, true, true, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', 'LookupAvailabilityByLocation', false, '', false);
        InsertVarietyFields(0, 5741, 6, true, true, false, 0, 5741, 4, '', '', '', false, '', false);
        InsertVarietyFields(0, 5741, 7, true, true, false, 0, 5741, 4, '', '', '', false, '', false);

        //Sales Price
        InsertVarietyFields(0, 7002, 5, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //Retail Journal Line
        InsertVarietyFields(0, 6014422, 3, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 7, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 8, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 17, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 18, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 6014422, 47, true, false, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);

        //-NPR5.31 [271133]
        //Purchase Price
        InsertVarietyFields(0, 7012, 5, true, true, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        //+NPR5.31 [271133]

        //-NPR5.36 [285733]
        InsertVarietyFields(0, 83, 9, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 83, 13, true, true, true, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 83, 15, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        InsertVarietyFields(0, 83, 50, true, true, false, 3, 0, 0, '', 'GetQuantityAvailableToPromise', '', false, '', false);
        //+NPR5.36 [285733]

        Commit;
    end;

    local procedure InsertVarietyFields(Type: Integer; TableNo: Integer; FieldNo: Integer; ValidateField: Boolean; EditField: Boolean; TableDefault: Boolean; Type2: Integer; TableNo2: Integer; FieldNo2: Integer; MatrixSubscriber1: Text; MatrixSubscriber2: Text; MatrixSubscriberOnLookup: Text; UseOnLookupValue: Boolean; MatrixSubscriberOnDrillDown: Text; UseOnDrillDownalue: Boolean)
    var
        VRTFieldsSetup: Record "NPR Variety Field Setup";
    begin
        //-VRT1.20
        if VRTFieldsSetup.Get(Type, TableNo, FieldNo) then
        //-NPR5.47 [327541]
        //EXIT;
        begin
            if (VRTFieldsSetup."Secondary Type" = 1) and
               (VRTFieldsSetup."Secondary Table No." = 1) and
               (VRTFieldsSetup."Secondary Field No." = 1) then begin
                VRTFieldsSetup."Secondary Type" := Type2;
                VRTFieldsSetup."Secondary Table No." := TableNo2;
                VRTFieldsSetup.Validate("Secondary Field No.", FieldNo2);
                VRTFieldsSetup.Validate("Variety Matrix Subscriber 1", MatrixSubscriber1);
                VRTFieldsSetup.Validate("Variety Matrix Subscriber 2", MatrixSubscriber2);
                VRTFieldsSetup."OnLookup Subscriber" := MatrixSubscriberOnLookup;
                VRTFieldsSetup."Use OnLookup Return Value" := UseOnLookupValue;
                VRTFieldsSetup."OnDrillDown Subscriber" := MatrixSubscriberOnDrillDown;
                VRTFieldsSetup."Use OnDrillDown Return Value" := UseOnDrillDownalue;
                VRTFieldsSetup.Modify;
            end;

            exit;
        end;
        //+VRT1.20

        VRTFieldsSetup.Init;
        VRTFieldsSetup.Type := Type;
        VRTFieldsSetup."Table No." := TableNo;
        VRTFieldsSetup.Validate("Field No.", FieldNo);
        VRTFieldsSetup."Validate Field" := ValidateField;
        VRTFieldsSetup."Editable Field" := EditField;
        //-VRT1.10
        VRTFieldsSetup."Is Table Default" := TableDefault;
        VRTFieldsSetup."Secondary Type" := Type2;
        VRTFieldsSetup."Secondary Table No." := TableNo2;
        VRTFieldsSetup.Validate("Secondary Field No.", FieldNo2);
        //+VRT1.10
        //-NPR5.47 [327541]
        VRTFieldsSetup.Validate("Variety Matrix Subscriber 1", MatrixSubscriber1);
        VRTFieldsSetup.Validate("Variety Matrix Subscriber 2", MatrixSubscriber2);
        VRTFieldsSetup."OnLookup Subscriber" := MatrixSubscriberOnLookup;
        VRTFieldsSetup."Use OnLookup Return Value" := UseOnLookupValue;
        VRTFieldsSetup."OnDrillDown Subscriber" := MatrixSubscriberOnDrillDown;
        VRTFieldsSetup."Use OnDrillDown Return Value" := UseOnDrillDownalue;
        //+NPR5.47 [327541]

        if VRTFieldsSetup.Insert then;
    end;

    procedure UpdateToLatestVersion()
    var
        VRTFieldsSetup: Record "NPR Variety Field Setup";
    begin
        //-NPR5.32 [274170]
        //make sure its only executing when there is actually a change
        //-NPR5.36 [285733]
        //IF VRTFieldsSetup.GET(1, 5401, 3) THEN
        if VRTFieldsSetup.Get(0, 83, 13) then
            //+NPR5.36 [285733]
            exit;


        InitVarietyFields;
        //+NPR5.32 [274170]
    end;

    local procedure SetDescription(Type: Integer; TableNo: Integer; FieldNo: Integer; NewDescription: Text)
    var
        VRTFieldsSetup: Record "NPR Variety Field Setup";
    begin
        if not VRTFieldsSetup.Get(Type, TableNo, FieldNo) then
            exit;
        VRTFieldsSetup.Description := NewDescription;
        VRTFieldsSetup.Modify;
    end;
}


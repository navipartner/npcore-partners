table 6059981 "NPR Item Repair Action"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added Option Captions

    Caption = 'Item Repair Action';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(20; "Item Ledger Entry Qty."; Integer)
        {
            CalcFormula = Count("Item Ledger Entry" WHERE("Item No." = FIELD("Item No.")));
            Caption = 'Item Ledger Entry Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; "Variant Action"; Option)
        {
            Caption = 'Variant Action';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Block Variant,Delete Variant,Update From Item';
            OptionMembers = "None",BlockVariant,DeleteVariant,UpdateFromItem;
        }
        field(51; "Variety 1 Action"; Option)
        {
            Caption = 'Variety 1 Action';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(52; "Variety 2 Action"; Option)
        {
            Caption = 'Variety 2 Action';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(53; "Variety 3 Action"; Option)
        {
            Caption = 'Variety 3 Action';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(54; "Variety 4 Action"; Option)
        {
            Caption = 'Variety 4 Action';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(60; "New Variety 1"; Code[20])
        {
            Caption = 'New Variety 1';
            DataClassification = CustomerContent;
        }
        field(61; "New Variety 1 Table"; Code[20])
        {
            Caption = 'New Variety 1 Table';
            DataClassification = CustomerContent;
        }
        field(62; "New Variety 2"; Code[20])
        {
            Caption = 'New Variety 2';
            DataClassification = CustomerContent;
        }
        field(63; "New Variety 2 Table"; Code[20])
        {
            Caption = 'New Variety 2 Table';
            DataClassification = CustomerContent;
        }
        field(64; "New Variety 3"; Code[20])
        {
            Caption = 'New Variety 3';
            DataClassification = CustomerContent;
        }
        field(65; "New Variety 3 Table"; Code[20])
        {
            Caption = 'New Variety 3 Table';
            DataClassification = CustomerContent;
        }
        field(66; "New Variety 4"; Code[20])
        {
            Caption = 'New Variety 4';
            DataClassification = CustomerContent;
        }
        field(67; "New Variety 4 Table"; Code[20])
        {
            Caption = 'New Variety 4 Table';
            DataClassification = CustomerContent;
        }
        field(70; "New Variety 1 Value"; Code[20])
        {
            Caption = 'New Variety 1 Value';
            DataClassification = CustomerContent;
        }
        field(71; "New Variety 2 Value"; Code[20])
        {
            Caption = 'New Variety 2 Value';
            DataClassification = CustomerContent;
        }
        field(72; "New Variety 3 Value"; Code[20])
        {
            Caption = 'New Variety 3 Value';
            DataClassification = CustomerContent;
        }
        field(73; "New Variety 4 Value"; Code[20])
        {
            Caption = 'New Variety 4 Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }
}


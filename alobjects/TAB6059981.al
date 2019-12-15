table 6059981 "Item Repair Action"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants
    // NPR5.48/JDH /20181109 CASE 334163 Added Option Captions

    Caption = 'Item Repair Action';
    DrillDownPageID = "Item Repair Action";
    LookupPageID = "Item Repair Action";

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(2;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(20;"Item Ledger Entry Qty.";Integer)
        {
            CalcFormula = Count("Item Ledger Entry" WHERE ("Item No."=FIELD("Item No.")));
            Caption = 'Item Ledger Entry Qty.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30;"No. Of tests";Integer)
        {
            CalcFormula = Count("Item Repair Tests" WHERE ("Item No."=FIELD("Item No.")));
            Caption = 'No. Of tests';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31;"No.Of Errors";Integer)
        {
            CalcFormula = Count("Item Repair Tests" WHERE ("Item No."=FIELD("Item No."),
                                                           Success=CONST(false)));
            Caption = 'No.Of Errors';
            Editable = false;
            FieldClass = FlowField;
        }
        field(50;"Variant Action";Option)
        {
            Caption = 'Variant Action';
            OptionCaption = 'None,Block Variant,Delete Variant,Update From Item';
            OptionMembers = "None",BlockVariant,DeleteVariant,UpdateFromItem;
        }
        field(51;"Variety 1 Action";Option)
        {
            Caption = 'Variety 1 Action';
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(52;"Variety 2 Action";Option)
        {
            Caption = 'Variety 2 Action';
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(53;"Variety 3 Action";Option)
        {
            Caption = 'Variety 3 Action';
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(54;"Variety 4 Action";Option)
        {
            Caption = 'Variety 4 Action';
            OptionCaption = 'None,Use Variant Setup,Use Item Setup,Select Manual';
            OptionMembers = "None",UseVariantSetup,UseItemSetup,SelectManual;
        }
        field(60;"New Variety 1";Code[20])
        {
            Caption = 'New Variety 1';
        }
        field(61;"New Variety 1 Table";Code[20])
        {
            Caption = 'New Variety 1 Table';
        }
        field(62;"New Variety 2";Code[20])
        {
            Caption = 'New Variety 2';
        }
        field(63;"New Variety 2 Table";Code[20])
        {
            Caption = 'New Variety 2 Table';
        }
        field(64;"New Variety 3";Code[20])
        {
            Caption = 'New Variety 3';
        }
        field(65;"New Variety 3 Table";Code[20])
        {
            Caption = 'New Variety 3 Table';
        }
        field(66;"New Variety 4";Code[20])
        {
            Caption = 'New Variety 4';
        }
        field(67;"New Variety 4 Table";Code[20])
        {
            Caption = 'New Variety 4 Table';
        }
        field(70;"New Variety 1 Value";Code[20])
        {
            Caption = 'New Variety 1 Value';
        }
        field(71;"New Variety 2 Value";Code[20])
        {
            Caption = 'New Variety 2 Value';
        }
        field(72;"New Variety 3 Value";Code[20])
        {
            Caption = 'New Variety 3 Value';
        }
        field(73;"New Variety 4 Value";Code[20])
        {
            Caption = 'New Variety 4 Value';
        }
    }

    keys
    {
        key(Key1;"Item No.","Variant Code")
        {
        }
    }

    fieldgroups
    {
    }
}


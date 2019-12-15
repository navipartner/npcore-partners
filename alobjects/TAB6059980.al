table 6059980 "Item Repair Log"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants

    Caption = 'Item Repair Log';
    DrillDownPageID = "Item Repair";
    LookupPageID = "Item Repair";

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(5;"Item No.";Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE ("Item No."=FIELD("Item No."));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"From value";Text[50])
        {
            Caption = 'From value';
        }
        field(21;"To Value";Text[50])
        {
            Caption = 'To Value';
        }
        field(30;"Changed By";Text[30])
        {
            Caption = 'Changed By';
        }
        field(40;"Executed at";DateTime)
        {
            Caption = 'Executed at';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}


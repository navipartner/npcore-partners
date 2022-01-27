table 6059980 "NPR Item Repair Log"
{
    Access = Internal;
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants

    Caption = 'Item Repair Log';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(5; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "From value"; Text[50])
        {
            Caption = 'From value';
            DataClassification = CustomerContent;
        }
        field(21; "To Value"; Text[50])
        {
            Caption = 'To Value';
            DataClassification = CustomerContent;
        }
        field(30; "Changed By"; Text[30])
        {
            Caption = 'Changed By';
            DataClassification = CustomerContent;
        }
        field(40; "Executed at"; DateTime)
        {
            Caption = 'Executed at';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}


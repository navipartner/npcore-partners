table 6059983 "NPR Item Repair Tests"
{
    Access = Internal;
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants

    Caption = 'Item Repair Tests';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Repairs are not supported in core anymore.';

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(2; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(3; "Test No."; Integer)
        {
            Caption = 'Test No.';
            DataClassification = CustomerContent;
        }
        field(5; "Test Group"; Integer)
        {
            Caption = 'Test Group';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; Success; Boolean)
        {
            Caption = 'Success';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Item No.", "Variant Code", "Test No.")
        {
        }
        key(Key2; Success)
        {
        }
    }

    fieldgroups
    {
    }
}


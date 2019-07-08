table 6059983 "Item Repair Tests"
{
    // VRT1.20/JDH /20170106 CASE 251896 TestTool to analyse and fix Variants

    Caption = 'Item Repair Tests';
    DrillDownPageID = "Item Repair Tests";
    LookupPageID = "Item Repair Tests";

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(2;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(3;"Test No.";Integer)
        {
            Caption = 'Test No.';
        }
        field(5;"Test Group";Integer)
        {
            Caption = 'Test Group';
        }
        field(10;Description;Text[100])
        {
            Caption = 'Description';
        }
        field(20;Success;Boolean)
        {
            Caption = 'Success';
        }
    }

    keys
    {
        key(Key1;"Item No.","Variant Code","Test No.")
        {
        }
        key(Key2;Success)
        {
        }
    }

    fieldgroups
    {
    }
}


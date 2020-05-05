table 6151366 "CS Approved Data"
{
    // NPR5.54/CLVA/20200218  CASE 391080 Object created

    Caption = 'CS Approved Data';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(2;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(3;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(4;"Qty.";Integer)
        {
            Caption = 'Qty.';
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


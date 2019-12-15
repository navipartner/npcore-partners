table 6060056 "Inventory Overview Line"
{
    // NPR5.34/BR  /20170726   CASE 282748 Object Created

    Caption = 'Inventory Overview Line';

    fields
    {
        field(10;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(20;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(30;"Location Code";Code[10])
        {
            Caption = 'Location Code';
        }
        field(80;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(100;"Item Description";Text[50])
        {
            Caption = 'Item Description';
        }
        field(110;"Variant Description";Text[50])
        {
            Caption = 'Variant Description';
        }
        field(111;"Location Name";Text[50])
        {
            Caption = 'Location Name';
        }
    }

    keys
    {
        key(Key1;"Item No.","Variant Code","Location Code")
        {
        }
    }

    fieldgroups
    {
    }
}


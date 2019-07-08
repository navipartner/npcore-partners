table 6151604 "NpDc Item Buffer"
{
    // NPR5.38/MHA /20171204  CASE 298276 Object created

    Caption = 'Discount Item Buffer';

    fields
    {
        field(1;"Item No.";Code[20])
        {
            Caption = 'Item No.';
        }
        field(5;"Variant Code";Code[10])
        {
            Caption = 'Variant Code';
        }
        field(10;"Item Group";Code[10])
        {
            Caption = 'Item Group';
        }
        field(15;"Item Disc. Group";Code[10])
        {
            Caption = 'Item Disc. Group';
        }
        field(20;"Unit Price";Decimal)
        {
            Caption = 'Unit Price';
        }
        field(25;"Discount Type";Integer)
        {
            Caption = 'Discount Type';
        }
        field(30;"Discount Code";Code[20])
        {
            Caption = 'Discount Code';
        }
        field(32;"Discount %";Decimal)
        {
            Caption = 'Discount %';
            DecimalPlaces = 0:5;
        }
        field(35;"Discount Amount";Decimal)
        {
            Caption = 'Discount Amount';
        }
        field(50;Quantity;Decimal)
        {
            Caption = 'Quantity';
        }
        field(60;"Line Amount";Decimal)
        {
            Caption = 'Line Amount';
        }
    }

    keys
    {
        key(Key1;"Item No.","Variant Code","Item Group","Item Disc. Group","Unit Price","Discount Type","Discount Code","Discount %")
        {
        }
    }

    fieldgroups
    {
    }
}


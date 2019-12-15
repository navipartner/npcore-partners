table 6151205 "NpCs Store Inventory Buffer"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store
    // NPR5.52/MHA /20191002  CASE 369476 Added DecimalPlaces 0:5 to field 10 Quantity

    Caption = 'Collect Store Inventory Buffer';

    fields
    {
        field(1;"Store Code";Code[20])
        {
            Caption = 'Store Code';
            TableRelation = "NpCs Store";
        }
        field(5;Sku;Text[50])
        {
            Caption = 'Sku';
        }
        field(10;Quantity;Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0:5;
            Description = 'NPR5.52';
        }
        field(15;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(20;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
        field(100;Inventory;Decimal)
        {
            Caption = 'Inventory';
            DecimalPlaces = 0:5;
        }
        field(105;"In Stock";Boolean)
        {
            Caption = 'In Stock';
        }
    }

    keys
    {
        key(Key1;"Store Code",Sku)
        {
        }
    }

    fieldgroups
    {
    }
}


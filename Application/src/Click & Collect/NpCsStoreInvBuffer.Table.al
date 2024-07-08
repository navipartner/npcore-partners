table 6151205 "NPR NpCs Store Inv. Buffer"
{
    Access = Internal;
    Caption = 'Collect Store Inventory Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpCs Store";
        }
        field(5; Sku; Text[50])
        {
            Caption = 'Sku';
            DataClassification = CustomerContent;
        }
        field(10; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Description = 'NPR5.52';
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(100; Inventory; Decimal)
        {
            Caption = 'Inventory';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(105; "In Stock"; Boolean)
        {
            Caption = 'In Stock';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Store Code", Sku)
        {
        }
    }
}


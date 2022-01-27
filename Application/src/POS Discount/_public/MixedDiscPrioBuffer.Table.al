table 6014421 "NPR Mixed Disc. Prio. Buffer"
{
    // NPR5.31/MHA /20170222  CASE 262964 Object created - Buffer table to calculate Mixed Discount Type: Priority Discount per Min. Qty

    Caption = 'Item Amount';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Priority; Integer)
        {
            Caption = 'Priority';
            DataClassification = CustomerContent;
        }
        field(5; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DataClassification = CustomerContent;
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(15; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Priority, "Unit Price", "Item No.", "Variant Code")
        {
        }
    }

    fieldgroups
    {
    }
}


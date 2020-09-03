table 6014421 "NPR Mixed Disc. Prio. Buffer"
{
    // NPR5.31/MHA /20170222  CASE 262964 Object created - Buffer table to calculate Mixed Discount Type: Priority Discount per Min. Qty

    Caption = 'Item Amount';

    fields
    {
        field(1; Priority; Integer)
        {
            Caption = 'Priority';
        }
        field(5; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(15; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
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


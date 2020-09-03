table 6014440 "NPR Period Line"
{
    // NPR5.30/TJ  /20170215 CASE 265504 Changed ENU captions on fields with word Register in their name

    Caption = 'Period Line';

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'No.';
            Editable = false;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            Editable = false;
        }
        field(3; "Payment Type No."; Code[20])
        {
            Caption = 'Payment Type No.';
        }
        field(4; Weight; Decimal)
        {
            Caption = 'Weight';
        }
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
        }
        field(6; Amount; Decimal)
        {
            Caption = 'Amount ';
        }
        field(7; "Sales Ticket No."; Code[10])
        {
            Caption = 'Sales Ticket No.';
        }
    }

    keys
    {
        key(Key1; "Register No.", "Sales Ticket No.", "Payment Type No.", Weight)
        {
        }
    }

    fieldgroups
    {
    }
}


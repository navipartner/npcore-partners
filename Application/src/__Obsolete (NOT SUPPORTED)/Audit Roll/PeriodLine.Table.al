table 6014440 "NPR Period Line"
{
    Caption = 'Period Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(2; "Register No."; Code[10])
        {
            Caption = 'Cash Register No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(3; "Payment Type No."; Code[20])
        {
            Caption = 'Payment Type No.';
            DataClassification = CustomerContent;
        }
        field(4; Weight; Decimal)
        {
            Caption = 'Weight';
            DataClassification = CustomerContent;
        }
        field(5; Quantity; Integer)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(6; Amount; Decimal)
        {
            Caption = 'Amount ';
            DataClassification = CustomerContent;
        }
        field(7; "Sales Ticket No."; Code[10])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
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


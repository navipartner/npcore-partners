table 6151139 "NPR TM Waiting List Entry"
{
    Access = Internal;
    // TM1.45/TSA /20191203 CASE 380754 Initial Version

    Caption = 'Waiting List Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Ticket Waiting List Entry No."; Integer)
        {
            Caption = 'Ticket Waiting List Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(15; "Expires At"; DateTime)
        {
            Caption = 'Expires At';
            DataClassification = CustomerContent;
        }
        field(20; "Reference Code"; Code[20])
        {
            Caption = 'Reference Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Reference Code")
        {
        }
    }

    fieldgroups
    {
    }
}


table 6060104 "NPR Global Sale POS"
{
    Caption = 'Global Sale POS';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Company Name"; Text[50])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(3; "Register No."; Code[20])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
        }
        field(4; "Sales Ticket No."; Code[20])
        {
            Caption = 'Sales Ticket No.';
            DataClassification = CustomerContent;
        }
        field(5; "Returning Company Name"; Text[50])
        {
            Caption = 'Returning Company Name';
            DataClassification = CustomerContent;
        }
        field(6; "Audit Roll Line No."; Integer)
        {
            Caption = 'Audit Roll Line No.';
            DataClassification = CustomerContent;
        }
        field(7; "Sales Item No."; Code[20])
        {
            Caption = 'Sales Item No.';
            DataClassification = CustomerContent;
        }
        field(8; "Sales Line No."; Integer)
        {
            Caption = 'Sales Line No.';
            DataClassification = CustomerContent;
        }
        field(9; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}


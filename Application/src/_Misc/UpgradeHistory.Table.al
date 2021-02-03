table 6151000 "NPR Upgrade History"
{
    Caption = 'NPR Upgrade History';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Upgrade Time"; DateTime)
        {
            Caption = 'Upgrade Time';
            DataClassification = CustomerContent;
        }
        field(20; Version; Text[50])
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
    }
}


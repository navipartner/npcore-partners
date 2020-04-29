table 6151000 "NPR Upgrade History"
{
    // NPR5.41/THRO/20180425 CASE 311567 Table created

    Caption = 'NPR Upgrade History';
    DataPerCompany = false;

    fields
    {
        field(1;"Entry No.";Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(10;"Upgrade Time";DateTime)
        {
            Caption = 'Upgrade Time';
        }
        field(20;Version;Text[50])
        {
            Caption = 'Version';
        }
    }

    keys
    {
        key(Key1;"Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}


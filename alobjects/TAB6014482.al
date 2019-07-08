table 6014482 "Report Usage Log Entry"
{
    // NPR5.48/TJ  /20181108 CASE 324444 New object

    Caption = 'Report Usage Log Entry';

    fields
    {
        field(1;"Entry No.";Integer)
        {
            Caption = 'Entry No.';
        }
        field(10;"Database Name";Text[250])
        {
            Caption = 'Database Name';
        }
        field(20;"Tenant Id";Text[250])
        {
            Caption = 'Tenant Id';
        }
        field(30;"Company Name";Text[250])
        {
            Caption = 'Company Name';
        }
        field(40;"Report Id";Integer)
        {
            Caption = 'Report Id';
        }
        field(50;"User Id";Text[250])
        {
            Caption = 'User Id';
        }
        field(60;"Used on";DateTime)
        {
            Caption = 'Used on';
        }
        field(70;"Enabled/Disabled Entry";Boolean)
        {
            Caption = 'Enabled/Disabled Entry';
        }
        field(80;Description;Text[250])
        {
            Caption = 'Description';
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


table 6151491 "Raptor Setup"
{
    // NPR5.51/CLVA/20190710  CASE 355871 Object created

    Caption = 'Raptor Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Enable Raptor Functions";Boolean)
        {
            Caption = 'Enable Raptor Functions';
        }
        field(11;"API Key";Text[50])
        {
            Caption = 'API Key';
        }
        field(12;"Base Url";Text[250])
        {
            Caption = 'Base Url';
        }
        field(13;"Customer Guid";Text[50])
        {
            Caption = 'Customer Guid';
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}


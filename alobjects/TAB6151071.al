table 6151071 "Customers to Anonymize"
{
    // NPR5.53/ZESO/20200115 CASE 358656 New Object Created

    Caption = 'Customers to Anonymize';
    DrillDownPageID = "Customers to Anonymize List";
    LookupPageID = "Customers to Anonymize List";

    fields
    {
        field(1;"Entry No";Integer)
        {
            Caption = 'Entry No';
        }
        field(2;"Customer No";Code[20])
        {
            Caption = 'Customer No';
        }
        field(3;"Customer Name";Text[50])
        {
            Caption = 'Customer Name';
        }
    }

    keys
    {
        key(Key1;"Entry No")
        {
        }
    }

    fieldgroups
    {
    }
}


table 6151060 "Customer GDPR SetUp"
{
    // NPR5.52/ZESO/20190925 CASE 358656 Object Created

    Caption = 'Customer GDPR SetUp';

    fields
    {
        field(1;"Primary key";Code[10])
        {
            Caption = 'Primary key';
        }
        field(2;"Anonymize After";DateFormula)
        {
            Caption = 'Anonymize After';
        }
    }

    keys
    {
        key(Key1;"Primary key")
        {
        }
    }

    fieldgroups
    {
    }
}


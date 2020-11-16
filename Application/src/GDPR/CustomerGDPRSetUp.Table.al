table 6151060 "NPR Customer GDPR SetUp"
{
    // NPR5.52/ZESO/20190925 CASE 358656 Object Created
    // NPR5.53/ZESO/20200115 CASE 358656 Added New Fields ID 3,4,5

    Caption = 'Customer GDPR SetUp';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary key"; Code[10])
        {
            Caption = 'Primary key';
            DataClassification = CustomerContent;
        }
        field(2; "Anonymize After"; DateFormula)
        {
            Caption = 'Anonymize After';
            DataClassification = CustomerContent;
        }
        field(3; "Customer Posting Group Filter"; Text[250])
        {
            Caption = 'Customer Posting Group Filter';
            DataClassification = CustomerContent;
        }
        field(4; "No of Customers"; Integer)
        {
            CalcFormula = Count ("NPR Customers to Anonymize");
            Caption = 'No of Customers';
            FieldClass = FlowField;
        }
        field(5; "Gen. Bus. Posting Group Filter"; Text[250])
        {
            Caption = 'Gen. Bus. Posting Group Filter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary key")
        {
        }
    }

    fieldgroups
    {
    }
}


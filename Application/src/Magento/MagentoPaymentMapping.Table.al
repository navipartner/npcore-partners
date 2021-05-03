table 6151437 "NPR Magento Payment Mapping"
{
    Caption = 'Magento Payment Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(5; "External Payment Method Code"; Text[50])
        {
            Caption = 'External Payment Method Code';
            DataClassification = CustomerContent;
        }
        field(10; "External Payment Type"; Text[50])
        {
            Caption = 'External Payment Type';
            DataClassification = CustomerContent;
        }
        field(90; "Allow Adjust Payment Amount"; Boolean)
        {
            Caption = 'Allow Adjust Payment Amount';
            DataClassification = CustomerContent;
        }
        field(100; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        field(105; "Payment Gateway Code"; Code[10])
        {
            Caption = 'Payment Gateway Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Gateway";
        }
        field(110; "Captured Externally"; Boolean)
        {
            Caption = 'Captured Externally';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "External Payment Method Code", "External Payment Type")
        {
        }
    }
}

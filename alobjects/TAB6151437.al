table 6151437 "Magento Payment Mapping"
{
    // MAG1.01/MHA /20150121  CASE 199932 Refactored object from Web Integration
    // MAG1.12/MHA /20150403  CASE 210713 Update caption of field 10
    // MAG1.20/MHA /20150826  CASE 219645 Added field 105 Payment Gateway Code
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.05/MHA /20170712  CASE 283588 Added field 90 "Allow Adjust Payment Amount"
    // MAG2.23/ALPO/20191004  CASE 367219 Auto set capture date for payments captured externally

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
            Description = 'MAG1.12';
        }
        field(90; "Allow Adjust Payment Amount"; Boolean)
        {
            Caption = 'Allow Adjust Payment Amount';
            DataClassification = CustomerContent;
            Description = 'MAG2.05';
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
            Description = 'MAG1.20';
            TableRelation = "Magento Payment Gateway";
        }
        field(110; "Captured Externally"; Boolean)
        {
            Caption = 'Captured Externally';
            DataClassification = CustomerContent;
            Description = 'MAG2.23';
        }
    }

    keys
    {
        key(Key1; "External Payment Method Code", "External Payment Type")
        {
        }
    }

    fieldgroups
    {
    }
}


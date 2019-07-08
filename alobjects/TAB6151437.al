table 6151437 "Magento Payment Mapping"
{
    // MAG1.01/MHA /20150121  CASE 199932 Refactored object from Web Integration
    // MAG1.12/MHA /20150403  CASE 210713 Update caption of field 10
    // MAG1.20/MHA /20150826  CASE 219645 Added field 105 Payment Gateway Code
    // MAG2.00/MHA /20160525  CASE 242557 Magento Integration
    // MAG2.05/MHA /20170712  CASE 283588 Added field 90 "Allow Adjust Payment Amount"

    Caption = 'Magento Payment Mapping';

    fields
    {
        field(5;"External Payment Method Code";Text[50])
        {
            Caption = 'External Payment Method Code';
        }
        field(10;"External Payment Type";Text[50])
        {
            Caption = 'External Payment Type';
            Description = 'MAG1.12';
        }
        field(90;"Allow Adjust Payment Amount";Boolean)
        {
            Caption = 'Allow Adjust Payment Amount';
            Description = 'MAG2.05';
        }
        field(100;"Payment Method Code";Code[10])
        {
            Caption = 'Payment Method Code';
            TableRelation = "Payment Method";
        }
        field(105;"Payment Gateway Code";Code[10])
        {
            Caption = 'Payment Gateway Code';
            Description = 'MAG1.20';
            TableRelation = "Magento Payment Gateway";
        }
    }

    keys
    {
        key(Key1;"External Payment Method Code","External Payment Type")
        {
        }
    }

    fieldgroups
    {
    }
}


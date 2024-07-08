table 6059776 "NPR EFT Softpay Config"
{
    Access = Internal;
    DataClassification = CustomerContent;
    LookupPageId = "NPR EFT Softpay Config List";
    Caption = 'Softpay POS Merchant Table';
    Extensible = false;

    fields
    {
        field(1; "Register No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(5; "Merchant ID"; Text[50])
        {
            DataClassification = CustomerContent;
            TableRelation = "NPR EFT Softpay Merchant";
            Caption = 'Sofpay Merchant ID';
        }
    }

    keys
    {
        key(PK; "Register No.")
        {
            Clustered = true;
        }
    }
}

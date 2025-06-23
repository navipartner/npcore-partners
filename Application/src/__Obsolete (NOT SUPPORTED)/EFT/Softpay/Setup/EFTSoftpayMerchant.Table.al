table 6059775 "NPR EFT Softpay Merchant"
{
    Access = Internal;
    DataClassification = CustomerContent;
    LookupPageId = "NPR EFT Softpay Merchant List";
    Caption = 'Softpay Merchant Table';
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-06-13';
    ObsoleteReason = 'No longer supported';

    fields
    {
        field(1; "Merchant ID"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant ID';
        }
        field(2; "Merchant Password"; Text[50])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = Masked;
            Caption = 'Merchant Password';
        }
        field(3; Description; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Merchant Description';
        }
        field(4; Environment; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Environment';
            OptionMembers = Sandbox,Production;
        }
    }

    keys
    {
        key(PK; "Merchant ID")
        {
            Clustered = true;
        }
    }
}

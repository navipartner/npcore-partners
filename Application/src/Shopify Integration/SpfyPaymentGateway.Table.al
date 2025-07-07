#if not BC17
table 6150817 "NPR Spfy Payment Gateway"
{
    Access = Internal;
    Caption = 'Shopify Payment Gateway';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Payment Gateway";
            NotBlank = true;
            Editable = false;
        }
        field(22; "Currency Code"; Code[10])
        {
            Caption = 'Store Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(30; "Identify Final Capture"; Boolean)
        {
            Caption = 'Identify Final Capture';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
#endif
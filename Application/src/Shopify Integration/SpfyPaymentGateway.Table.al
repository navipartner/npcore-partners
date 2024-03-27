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
            Caption = 'Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
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
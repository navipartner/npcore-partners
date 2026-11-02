/// <summary>
/// Keeps the billing event ids of a billed Shopify payment line that was deleted before posting, so the line re-created for the same transaction takes them over instead of being billed again.
/// </summary>
table 6060071 "NPR Spfy Pmt. Line Billing Ids"
{
    Access = Internal;
    Caption = 'Shopify Payment Line Billing Ids';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shopify Transaction ID"; Text[30])
        {
            Caption = 'Shopify Transaction ID';
            DataClassification = CustomerContent;
        }
        field(2; "PCY Event Id"; Guid)
        {
            Caption = 'Presentment Currency Event Id';
            DataClassification = SystemMetadata;
        }
        field(3; "Shop Event Id"; Guid)
        {
            Caption = 'Shop Currency Event Id';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Shopify Transaction ID")
        {
            Clustered = true;
        }
    }
}

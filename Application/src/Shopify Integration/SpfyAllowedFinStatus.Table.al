#if not BC17
table 6151045 "NPR Spfy Allowed Fin. Status"
{
    Access = Internal;
    Caption = 'Allowed Order Financial Status';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            NotBlank = true;
        }
        field(2; "Order Financial Status"; Enum "NPR Spfy Order FinancialStatus")
        {
            Caption = 'Order Financial Status';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Shopify Store Code", "Order Financial Status")
        {
            Clustered = true;
        }
    }
}
#endif
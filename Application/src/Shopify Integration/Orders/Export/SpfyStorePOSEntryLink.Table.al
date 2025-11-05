#if not (BC17 or BC18 or BC19 or BC20)
table 6151253 "NPR Spfy Store-POS Entry Link"
{
    Access = Internal;
    Caption = 'Shopify Store-POS Entry Link';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(10; "POS Entry No."; Integer)
        {
            Caption = 'POS Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Entry"."Entry No.";
            NotBlank = true;
        }
        field(20; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            NotBlank = true;
        }
    }
    keys
    {
        key(PK; "POS Entry No.", "Shopify Store Code")
        {
            Clustered = true;
        }
        key(StoreLocations; "Shopify Store Code") { }
    }
}
#endif
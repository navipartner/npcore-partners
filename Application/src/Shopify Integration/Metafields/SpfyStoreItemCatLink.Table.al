#if not BC17
table 6151226 "NPR Spfy Store-Item Cat. Link"
{
    Access = Internal;
    Caption = 'Shopify Store-Item Category Link';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(20; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
        field(30; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            NotBlank = true;
        }
    }
    keys
    {
        key(PK; "Item No.", "Item Category Code", "Shopify Store Code")
        {
            Clustered = true;
        }
        key(StoreLocations; "Shopify Store Code") { }
    }
}
#endif
#if not BC17
table 6151277 "NPR Spfy Inv Item Location"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Shopify Inventory Item Locations';
    LookupPageId = "NPR Spfy Inv. Item Locations";
    DrillDownPageId = "NPR Spfy Inv. Item Locations";
    fields
    {
        field(1; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(2; "Shopify Location ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Shopify Location ID';
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item."No." WHERE(Type = CONST(Inventory));
        }
        field(4; "Variant Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(5; Activated; Boolean)
        {
            Caption = 'Activated';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Shopify Store Code", "Shopify Location ID", "Item No.", "Variant Code")
        {
            Clustered = true;
        }
    }
}
#endif
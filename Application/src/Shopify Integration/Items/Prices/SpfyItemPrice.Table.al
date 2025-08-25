#if not BC17
table 6150924 "NPR Spfy Item Price"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Caption = 'Shopify Item Price';
    LookupPageId = "NPR Spfy Item Prices";
    DrillDownPageId = "NPR Spfy Item Prices";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item."No.";
        }
        field(2; "Variant Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(3; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(4; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Price';
            DecimalPlaces = 0 : 5;
        }
        field(5; "Compare at Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Compare at Price';
            DecimalPlaces = 0 : 5;
        }
        field(6; "Currency Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(7; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Starting Date';
        }
    }

    keys
    {
        key(PK; "Shopify Store Code", "Item No.", "Variant Code")
        {
            Clustered = true;
        }
        key(ByItem; "Item No.", "Variant Code") { }
    }
}
#endif
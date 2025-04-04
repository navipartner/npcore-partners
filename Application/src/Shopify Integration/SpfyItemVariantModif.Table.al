#if not BC17
table 6151028 "NPR Spfy Item Variant Modif."
{
    Access = Internal;
    Extensible = false;
    Caption = 'Shopify Item Variant Modif.';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
            NotBlank = true;
        }
        field(20; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant" where("Item No." = field("Item No."));
        }
        field(30; "Shopify Store Code"; Code[20])
        {
            Caption = 'Shopify Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Spfy Store".Code;
            NotBlank = true;
        }
        field(100; "Not Available"; Boolean)
        {
            Caption = 'Not Available in Shopify';
            DataClassification = CustomerContent;
        }
        field(110; "Allow Backorder"; Boolean)
        {
            Caption = 'Allow Backorder';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Item No.", "Variant Code", "Shopify Store Code")
        {
            Clustered = true;
        }
        key(NotAvailabe; "Not Available") { }
    }
}
#endif
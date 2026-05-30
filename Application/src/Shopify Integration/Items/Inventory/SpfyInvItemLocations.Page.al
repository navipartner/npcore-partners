#if not BC17
page 6248200 "NPR Spfy Inv. Item Locations"
{
    Extensible = false;
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Inventory Item Locations';
    PageType = List;
    SourceTable = "NPR Spfy Inv Item Location";
    UsageCategory = Administration;
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store for which location is activated.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Shopify Location ID"; Rec."Shopify Location ID")
                {
                    ToolTip = 'Specifies the Shopify location ID where your items are handled and stored before being sold.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of Item No. field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the value of Variant Code field.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field(Activated; Rec.Activated)
                {
                    ToolTip = 'Specifies whether the location is activated in the Shopify store.';
                    ApplicationArea = NPRShopify;
                    Editable = false;
                }
                field("Auto-Activation Disabled"; Rec."Auto-Activation Disabled")
                {
                    ToolTip = 'Specifies that Business Central inventory synchronization must not (re)activate this item variant at this Shopify location, preserving a manual deactivation made in Shopify Admin. Business Central sets this automatically when it detects such a deactivation; clear it to let synchronization activate and update inventory at this location again.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
}
#endif
page 6150976 "NPR Spfy POS Entry Refunds"
{
    Extensible = false;
    Caption = 'Shopify POS Entry Refunds';
    PageType = List;
    SourceTable = "NPR Spfy POS Entry Refund";
    UsageCategory = None;
    Editable = false;
    ApplicationArea = NPRShopify;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store the refund was created in.';
                    ApplicationArea = NPRShopify;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ToolTip = 'Specifies the POS entry whose return lines were refunded.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Order ID"; Rec."Shopify Order ID")
                {
                    ToolTip = 'Specifies the Shopify order the refund was created on, which is the order of the original POS sale.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Refund ID"; Rec."Shopify Refund ID")
                {
                    ToolTip = 'Specifies the id of the refund in Shopify.';
                    ApplicationArea = NPRShopify;
                }
                field("Refunded Amount"; Rec."Refunded Amount")
                {
                    ToolTip = 'Specifies the amount Shopify recorded as refunded.';
                    ApplicationArea = NPRShopify;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency of the refunded amount.';
                    ApplicationArea = NPRShopify;
                }
                field("Created At"; Rec."Created At")
                {
                    ToolTip = 'Specifies when the refund was recorded in Business Central.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
}

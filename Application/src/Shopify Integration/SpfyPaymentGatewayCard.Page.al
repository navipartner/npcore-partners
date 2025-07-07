#if not BC17
page 6184568 "NPR Spfy Payment Gateway Card"
{
    Extensible = False;
    Caption = 'Shopify Payment Gateway Setup';
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR Spfy Payment Gateway";
    DeleteAllowed = true;
    InsertAllowed = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the payment gateway ID.';
                    ApplicationArea = NPRShopify;
                    Visible = false;
                    Editable = false;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the Shopify store currency code.';
                    ApplicationArea = NPRShopify;
                    Importance = Additional;
                }
                field("Identify Final Capture"; Rec."Identify Final Capture")
                {
                    ToolTip = 'Specifies whether the system should identify when the final capture of an order transaction is requested and notify Shopify of this. This only applies to Shopify Payments authorizations that are multi-capturable. If this is set to true, any uncaptured amount from the authorization will be voided by Shopify once the capture has been completed. If false, the authorization will remain open for future captures. Business Central identifies whether a capture request is final by checking all payment lines (both posted and unposted) for the same order. If there are no other payment lines with uncaptured amounts, the capture is considered final.';
                    ApplicationArea = NPRShopify;
                    Importance = Additional;
                }
            }
        }
    }
}
#endif
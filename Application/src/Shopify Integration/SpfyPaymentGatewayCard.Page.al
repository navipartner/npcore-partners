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
                    ToolTip = 'Specifies the currency for the payment gateway.';
                    ApplicationArea = NPRShopify;
                    Importance = Additional;
                }
            }
        }
    }
}
#endif
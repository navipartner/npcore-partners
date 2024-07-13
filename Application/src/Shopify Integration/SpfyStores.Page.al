#if not BC17
page 6184566 "NPR Spfy Stores"
{
    Extensible = false;
    Caption = 'Shopify Stores';
    PageType = List;
    CardPageId = "NPR Spfy Store Card";
    SourceTable = "NPR Spfy Store";
    UsageCategory = Administration;
    ApplicationArea = NPRShopify;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies an internal unique id of the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Shopify store.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
}
#endif
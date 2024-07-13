#if not BC17
page 6184556 "NPR Spfy Stores Subpage"
{
    Extensible = false;
    Caption = 'Shopify Stores';
    PageType = ListPart;
    CardPageId = "NPR Spfy Store Card";
    SourceTable = "NPR Spfy Store";
    Editable = false;
    UsageCategory = None;

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
                field(Enabled; Rec.Enabled)
                {
                    ToolTip = 'Specifies whether the integration with this Shopify store is enabled.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }
}
#endif
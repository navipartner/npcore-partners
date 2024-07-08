#if not BC17
pageextension 6014520 "NPR Stockkeeping Unit Card" extends "Stockkeeping Unit Card"
{
    layout
    {
        addlast(Content)
        {
            group("NPR Shopify")
            {
                Caption = 'Shopify';
                Visible = ShopifyIntegrationIsEnabled_Inventory;

                field("NPR Spfy Safety Stock Quantity"; Rec."NPR Spfy Safety Stock Quantity")
                {
                    ToolTip = 'Specifies the Shopify safety stock quantity. It helps limit stock shortages due to unforeseen events. Please note, if there is at least one stockkeeping unit for an item in Business Central, the value of the Shopify safety stock quantity specified on the Item Card is disregarded.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }

    var
        ShopifyIntegrationIsEnabled_Inventory: Boolean;

    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyIntegrationIsEnabled_Inventory := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Inventory Levels");
    end;
}
#endif
#if not BC17
page 6184831 "NPR Spfy Item Prices"
{
    Extensible = false;
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Item Prices';
    PageType = List;
    SourceTable = "NPR Spfy Item Price";
    UsageCategory = Administration;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store this Item Price is calclulated for.';
                    ApplicationArea = NPRShopify;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the Item No. that the Price is calculated for.';
                    ApplicationArea = NPRShopify;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the Variant Code that the Price is calculated for.';
                    ApplicationArea = NPRShopify;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the Currency Code of the Prices.';
                    ApplicationArea = NPRShopify;
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ToolTip = 'Specifies the Starting Date of Unit Price.';
                    ApplicationArea = NPRShopify;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the Unit Price of the Item.';
                    ApplicationArea = NPRShopify;
                }
                field("Compare at Price"; Rec."Compare at Price")
                {
                    ToolTip = 'Specifies the Compare at Price of the Item.';
                    ApplicationArea = NPRShopify;
                }
                field("Last Updated at"; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies when the Item Price was calculated.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateShopifyItemPrices)
            {
                Caption = 'Calculate Item Prices';
                ToolTip = 'Recalculate Shopify Item prices for all or selected Shopify integrated items.';
                ApplicationArea = NPRShopify;
                Image = Recalculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    ShopifyStore: Record "NPR Spfy Store";
                    SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
                    SpfyCalculateItemPricesParams: Report "NPR Spfy Calculate Item Prices";
                    ConfirmQst: Label 'This function will recalculate Item Prices for all or selected Shopify integrated items.';
                begin
                    SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::"Item Prices", '');
                    if not Confirm(ConfirmQst + '\' + SpfyIntegrationMgt.LongRunningProcessConfirmQst(), false) then
                        exit;
                    ShopifyStore.SetRange(Enabled, true);
                    ShopifyStore.SetRange("Do Not Sync. Sales Prices", false);
                    SpfyCalculateItemPricesParams.SetTableView(ShopifyStore);
                    SpfyCalculateItemPricesParams.RunModal();
                end;
            }
            action("Show Logs")
            {
                Caption = 'Show Logs';
                ToolTip = 'Show Log entries of the last recalculation process.';
                ApplicationArea = NPRShopify;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "NPR Spfy Logs";
                RunPageView = where("Log Source" = const("Item Price"));
            }
        }
    }
}
#endif
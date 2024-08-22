#if not BC17
page 6184564 "NPR Spfy Inventory Levels"
{
    Extensible = false;
    ApplicationArea = NPRShopify;
    Caption = 'Shopify Inventory Levels';
    PageType = List;
    SourceTable = "NPR Spfy Inventory Level";
    UsageCategory = Administration;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = true;
    ContextSensitiveHelpPage = 'sending_inventory.html';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Shopify Store Code"; Rec."Shopify Store Code")
                {
                    ToolTip = 'Specifies the Shopify store this inventory level is calclulated for.';
                    ApplicationArea = NPRShopify;
                }
                field("Shopify Location ID"; Rec."Shopify Location ID")
                {
                    ToolTip = 'Specifies the Shopify location ID where your items are handled and stored before being sold.';
                    ApplicationArea = NPRShopify;
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the Item No. available inventory is calculated for.';
                    ApplicationArea = NPRShopify;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ToolTip = 'Specifies the Variant Code available inventory is calculated for.';
                    ApplicationArea = NPRShopify;
                }
                field(Inventory; Rec.Inventory)
                {
                    ToolTip = 'Specifies how many units of the item are in inventory.';
                    ApplicationArea = NPRShopify;
                }
                field("Last Updated at"; Rec."Last Updated at")
                {
                    ToolTip = 'Specifies when the available inventory was calculated.';
                    ApplicationArea = NPRShopify;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CalculateShopifyInventoryLevels)
            {
                Caption = 'Calculate Inventory Levels';
                ToolTip = 'Recalculate inventory levels for all or selected Shopify integrated locations and items.';
                ApplicationArea = NPRShopify;
                Image = Recalculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Item: Record Item;
                    ShopifyStore: Record "NPR Spfy Store";
                    InventoryLevelMgt: Codeunit "NPR Spfy Inventory Level Mgt.";
                    SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
                    FilterPage: FilterPageBuilder;
                    ConfirmQst: Label 'This function will recalculate inventory levels for all or selected Shopify integrated locations and items.';
                begin
                    SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::"Inventory Levels", '');
                    if not Confirm(ConfirmQst + '\' + SpfyIntegrationMgt.LongRunningProcessConfirmQst(), false) then
                        exit;
                    FilterPage.AddTable(Item.TableCaption(), Database::Item);
                    FilterPage.AddFieldNo(Item.TableCaption(), Item.FieldNo("No."));
                    FilterPage.AddFieldNo(Item.TableCaption(), Item.FieldNo("Variant Filter"));
                    FilterPage.AddFieldNo(Item.TableCaption(), Item.FieldNo("Location Filter"));
                    FilterPage.AddTable(ShopifyStore.TableCaption(), Database::"NPR Spfy Store");
                    FilterPage.AddFieldNo(ShopifyStore.TableCaption(), ShopifyStore.FieldNo(Code));
                    FilterPage.SetView(ShopifyStore.TableCaption(), 'WHERE(Enabled=CONST(true),"Send Inventory Updates"=CONST(true))');
                    if FilterPage.RunModal() then begin
                        Item.SetView(FilterPage.GetView(Item.TableCaption()));
                        ShopifyStore.SetView(FilterPage.GetView(ShopifyStore.TableCaption()));
                        InventoryLevelMgt.InitializeInventoryLevels(ShopifyStore.GetFilter(Code), Item, false);
                    end;
                end;
            }
        }
    }
}
#endif
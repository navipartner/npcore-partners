#if not BC17
pageextension 6014535 "NPR Item Attribute" extends "Item Attribute"
{
    actions
    {
        addafter(ItemAttributeTranslations)
        {
            action("NPR SpfyMetafieldMapping")
            {
                ApplicationArea = NPRShopify;
                Caption = 'Shopify Metafield Mapping';
                Image = LinkWeb;
                ToolTip = 'Opens a window in which you can map the selected item attribute to a Shopify metafield for each store.';
                Visible = ShopifyIntegrationIsEnabled;

                trigger OnAction()
                var
                    SpfyMetafieldMapping: Record "NPR Spfy Metafield Mapping";
                begin
                    Rec.TestField(ID);
                    SpfyMetafieldMapping.SetRange("Table No.", Database::"Item Attribute");
                    SpfyMetafieldMapping.SetRange("BC Record ID", Rec.RecordId());
                    Page.Run(0, SpfyMetafieldMapping);
                end;
            }
        }
#if not (BC18 or BC19 or BC20)
        addafter(ItemAttributeTranslations_Promoted)
        {
            actionref("NPR SpfyMetafieldMapping_Promoted"; "NPR SpfyMetafieldMapping") { }
        }
#endif
    }

    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::Items);
    end;

    var
        ShopifyIntegrationIsEnabled: Boolean;
}
#endif
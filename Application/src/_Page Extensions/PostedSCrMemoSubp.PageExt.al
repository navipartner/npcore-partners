pageextension 6014482 "NPR Posted S.Cr.Memo Subp." extends "Posted Sales Cr. Memo Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Spfy Order Line ID"; _SpfyLegacyReturnMgt.GetOrderLineItemStamp(Rec.RecordId()))
            {
                Caption = 'Shopify Order Line ID';
                Editable = false;
                Visible = _ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify Order Line ID assigned to the document line, or of the order line a discount given after the sale credits.';
            }
        }
    }

    var
        _SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        _ShopifyIntegrationIsEnabled: Boolean;

    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        _ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns");
    end;
}

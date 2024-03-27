#if not BC17
pageextension 6014519 "NPR Posted Sales Shpt. Subp." extends "Posted Sales Shpt. Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Spfy Order Line ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
            {
                Caption = 'Shopify Order Line ID';
                Editable = false;
                Visible = ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify Order Line ID assigned to the document line.';
            }
        }
    }

    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyIntegrationIsEnabled: Boolean;

    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders");
    end;
}
#endif
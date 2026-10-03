pageextension 6014480 "NPR Posted Return Rcpt. Subp." extends "Posted Return Receipt Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("NPR Spfy Order Line ID"; _SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
            {
                Caption = 'Shopify Order Line ID';
                Editable = false;
                Visible = _ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify Order Line ID assigned to the document line.';
            }
        }
    }

    var
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        _ShopifyIntegrationIsEnabled: Boolean;

    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        _ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns");
    end;
}

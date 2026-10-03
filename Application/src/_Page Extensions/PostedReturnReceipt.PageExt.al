pageextension 6014479 "NPR Posted Return Receipt" extends "Posted Return Receipt"
{
    layout
    {
        addafter("External Document No.")
        {
            field("NPR Spfy Return ID"; _SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
            {
                Caption = 'Shopify Return ID';
                Editable = false;
                Visible = _ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify Return ID assigned to the document.';
            }
            field("NPR Shopify Store Code"; _SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code"))
            {
                Caption = 'Shopify Store Code';
                Editable = false;
                Visible = _ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify store the document has been created at.';
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

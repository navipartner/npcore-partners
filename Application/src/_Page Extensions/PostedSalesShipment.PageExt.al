pageextension 6014403 "NPR Posted Sales Shipment" extends "Posted Sales Shipment"
{
    layout
    {
        addafter("Sell-to Customer Name")
        {
            field("NPR Sell-to Customer Name 2"; Rec."Sell-to Customer Name 2")
            {
                ToolTip = 'Specifies the additinal name of the customer that will appear on the new sales document.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Name")
        {
            field("NPR Ship-to Name 2"; Rec."Ship-to Name 2")
            {
                ToolTip = 'Specifies the additional name of the customer that you shipped the items on the invoice to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Ship-to Contact")
        {
            field("NPR Kolli"; Rec."NPR Kolli")
            {
                Editable = false;
                Importance = Promoted;
                ToolTip = 'Specifies the number of packages';
                ApplicationArea = NPRRetail;
            }
            field("NPR Package Quantity"; Rec."NPR Package Quantity")
            {
                ToolTip = 'Specifies the value of the Package Quantity field.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Shipment Date")
        {
            field("NPR Delivery Location"; Rec."NPR Delivery Location")
            {
                Editable = false;
                ToolTip = 'Specifies where items from the document are shipped to.';
                ApplicationArea = NPRRetail;
            }
        }
        addafter("Bill-to Name")
        {
            field("NPR Bill-to Name 2"; Rec."Bill-to Name 2")
            {
                ToolTip = 'Specifies the additinal name of the customer that the invoice was sent to.';
                ApplicationArea = NPRRetail;
            }
        }
#if not BC17
        addafter("External Document No.")
        {
            field("NPR Spfy Order ID"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Entry ID"))
            {
                Caption = 'Shopify Order ID';
                Editable = false;
                Visible = ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify Order ID assigned to the document.';
            }
            field("NPR Shopify Store Code"; SpfyAssignedIDMgt.GetAssignedShopifyID(Rec.RecordId(), "NPR Spfy ID Type"::"Store Code"))
            {
                Caption = 'Shopify Store Code';
                Editable = false;
                Visible = ShopifyIntegrationIsEnabled;
                ApplicationArea = NPRShopify;
                ToolTip = 'Specifies the Shopify store the document has been created at.';
            }
        }
#endif
    }
    actions
    {
        addafter("&Navigate")
        {
            group("NPR Print Shipment Document")
            {
                action("NPR PrintShipmentDocument")
                {
                    Caption = 'Print Shipment Document';
                    ToolTip = 'View and print shipment document for the sale shipment.';
                    Image = Print;
                    ApplicationArea = NPRRetail;

                    trigger OnAction()
                    var
                        ShippingProviderSetup: record "NPR Shipping Provider Setup";
                    begin
                        if ShippingProviderSetup.Get() then
                            PrintShipmentDocument(ShippingProviderSetup."Shipping Provider");
                    end;
                }
            }
        }
    }
    local procedure PrintShipmentDocument(IShippingProvider: Interface "NPR IShipping Provider Interface")
    begin
        IShippingProvider.PrintShipmentDocument(Rec);
    end;

#if not BC17
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        ShopifyIntegrationIsEnabled: Boolean;

    trigger OnOpenPage()
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
    begin
        ShopifyIntegrationIsEnabled := SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders");
    end;
#endif
}
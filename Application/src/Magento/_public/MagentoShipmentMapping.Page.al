page 6151449 "NPR Magento Shipment Mapping"
{
    Caption = 'Shipment Method Mapping';
    PageType = List;
    SourceTable = "NPR Magento Shipment Mapping";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Shipment Method Code"; Rec."External Shipment Method Code")
                {
                    ToolTip = 'Specifies the value of the External Shipment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies Description of External Shipment. This Description will display on Web Orders - Sales line when filled in.';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    ApplicationArea = NPRRetail;
                }
#if not BC17
                field("Spfy Location Code"; Rec."Spfy Location Code")
                {
                    ApplicationArea = NPRShopify;
                    ToolTip = 'Shopify: specifies the location code, which will be used by default for imported Shopify orders. Alternatively, you can define location mapping for each e-commerce store.';
                }
#endif
                field("Shipment Fee Type"; Rec."Shipment Fee Type")
                {
                    ToolTip = 'Specifies the value of the Shipment Fee Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Shipment Fee No."; Rec."Shipment Fee No.")
                {
                    ToolTip = 'Specifies the value of the Shipment Fee No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Setup Magento Shipment Methods")
            {
                Caption = 'Setup Shipment Methods';
                Image = Setup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Setup Shipment Methods action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    MagentoSetupMgt.TriggerSetupShipmentMethodMapping();
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "NPR Magento Setup Mgt.";
}

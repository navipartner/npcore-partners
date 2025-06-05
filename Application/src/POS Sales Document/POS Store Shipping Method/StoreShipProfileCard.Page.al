page 6184714 "NPR Store Ship. Profile Card"
{
    PageType = Document;
    UsageCategory = None;
    SourceTable = "NPR Store Ship. Profile Header";
    Extensible = false;
    Caption = 'Store Shipment Profile Card';
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Code field.';

                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';

                }
            }
            part(ShipmentLines; "NPR Store Ship Profile Fees")
            {
                ApplicationArea = NPRRetail;
                SubPageLink = "Profile Code" = field("Code");
                UpdatePropagation = Both;
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(CreateShipmentSeesFromMagento)
            {
                ApplicationArea = NPRMagento;
                Caption = 'Create Shipment Fees from Webshop';
                Image = CreateWhseLoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create shipment fees from webshop';
                trigger OnAction()
                var
                    POSStoreShipMethodUtil: Codeunit "NPR POS Store Ship Method Util";
                begin
                    POSStoreShipMethodUtil.CreatePOSStoreShipmentMethodFromMagentoShipmentMethodMappings(Rec, true);
                end;
            }
        }
    }
}
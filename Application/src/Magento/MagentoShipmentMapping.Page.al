page 6151449 "NPR Magento Shipment Mapping"
{
    Caption = 'Shipment Method Mapping';
    PageType = List;
    SourceTable = "NPR Magento Shipment Mapping";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Shipment Method Code"; Rec."External Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Shipment Method Code field';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                }
                field("Shipment Fee Type"; Rec."Shipment Fee Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Fee Type field';
                }
                field("Shipment Fee No."; Rec."Shipment Fee No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Fee No. field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Setup Shipment Methods action';

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
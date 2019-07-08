page 6151449 "Magento Shipment Mapping"
{
    // MAG1.01/MH/20150121  CASE 199932 Refactored object from Web Integration
    // MAG1.17/MH/20150622  CASE 216851 Magento Setup functions moved to new codeunit
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration
    // MAG2.07/MHA /20170830  CASE 286943 Updated Magento Setup Actions to support Setup Event Subscription

    Caption = 'Shipment Method Mapping';
    PageType = List;
    SourceTable = "Magento Shipment Mapping";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Shipment Method Code";"External Shipment Method Code")
                {
                }
                field("Shipment Method Code";"Shipment Method Code")
                {
                }
                field("Shipping Agent Code";"Shipping Agent Code")
                {
                }
                field("Shipping Agent Service Code";"Shipping Agent Service Code")
                {
                }
                field("Shipment Fee Account No.";"Shipment Fee Account No.")
                {
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    //-MAG2.07 [286943]
                    //MagentoSetupMgt.SetupNaviConnectShipmentMethods();
                    MagentoSetupMgt.TriggerSetupShipmentMethodMapping();
                    //+MAG2.07 [286943]
                end;
            }
        }
    }

    var
        MagentoSetupMgt: Codeunit "Magento Setup Mgt.";
}


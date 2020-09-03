page 6151442 "NPR Magento Cont.Shpt.Methods"
{
    // MAG1.05/20150223  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Contact Shipment Methods';
    PageType = List;
    SourceTable = "NPR Magento Contact Shpt.Meth.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Shipment Method Code"; "External Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                }
                field("Shipment Fee Account No."; "Shipment Fee Account No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}


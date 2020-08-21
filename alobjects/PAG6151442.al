page 6151442 "Magento Contact Shpt. Methods"
{
    // MAG1.05/20150223  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Contact Shipment Methods';
    PageType = List;
    SourceTable = "Magento Contact Shpt. Method";

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


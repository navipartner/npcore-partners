page 6151442 "NPR Magento Cont.Shpt.Methods"
{
    // MAG1.05/20150223  CASE 206395 Object created
    // MAG2.00/MHA/20160525  CASE 242557 Magento Integration

    Caption = 'Contact Shipment Methods';
    PageType = List;
    UsageCategory = Administration;
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
                    ToolTip = 'Specifies the value of the External Shipment Method Code field';
                }
                field("Shipment Method Code"; "Shipment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                }
                field("Shipping Agent Code"; "Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                }
                field("Shipping Agent Service Code"; "Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                }
                field("Shipment Fee Account No."; "Shipment Fee Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Fee Account No. field';
                }
            }
        }
    }

    actions
    {
    }
}


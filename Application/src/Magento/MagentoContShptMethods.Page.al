page 6151442 "NPR Magento Cont.Shpt.Methods"
{
    Caption = 'Contact Shipment Methods';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Magento Contact Shpt.Meth.";

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
                field("Shipment Fee Account No."; Rec."Shipment Fee Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shipment Fee Account No. field';
                }
            }
        }
    }
}
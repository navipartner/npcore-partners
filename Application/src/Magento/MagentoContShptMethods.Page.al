﻿page 6151442 "NPR Magento Cont.Shpt.Methods"
{
    Extensible = False;
    Caption = 'Contact Shipment Methods';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Magento Contact Shpt.Meth.";
    ApplicationArea = NPRMagento;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("External Shipment Method Code"; Rec."External Shipment Method Code")
                {

                    ToolTip = 'Specifies the value of the External Shipment Method Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {

                    ToolTip = 'Specifies the value of the Shipment Method Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {

                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field';
                    ApplicationArea = NPRMagento;
                }
                field("Shipment Fee Account No."; Rec."Shipment Fee Account No.")
                {

                    ToolTip = 'Specifies the value of the Shipment Fee Account No. field';
                    ApplicationArea = NPRMagento;
                }
            }
        }
    }
}

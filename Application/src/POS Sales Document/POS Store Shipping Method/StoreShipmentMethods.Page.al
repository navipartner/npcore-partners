page 6184712 "NPR Store Shipment Methods"
{
    Caption = 'Store Shipment Methods';
    PageType = List;
    SourceTable = "NPR Store Ship. Profile Line";
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Profile Code"; Rec."Profile Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Profile Code field.';
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Line No. field.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field("Shipment Method Code"; Rec."Shipment Method Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Shipment Method Code field.';
                }
                field("Shipping Agent Code"; Rec."Shipping Agent Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Shipping Agent Code field.';
                }
                field("Shipping Agent Service Code"; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Shipping Agent Service Code field.';
                }
                field("Shipment Fee Type"; Rec."Shipment Fee Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Shipment Fee Type field.';
                }
                field("Shipment Fee No."; Rec."Shipment Fee No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Shipment Fee No. field.';
                }
                field("Shipment Fee Amount"; Rec."Shipment Fee Amount")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Shipment Fee Amount field.';
                    BlankZero = true;
                }

            }
        }
    }
}

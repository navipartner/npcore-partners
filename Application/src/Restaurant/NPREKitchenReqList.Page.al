page 6150691 "NPR NPRE Kitchen Req. List"
{
    Extensible = False;
    Caption = 'Kitchen Request List';
    Editable = false;
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR NPRE Kitchen Request";

    layout
    {
        area(content)
        {
            repeater("Order Lines")
            {
                Caption = 'Order Lines';
                field("Request No."; Rec."Request No.")
                {

                    ToolTip = 'Specifies the value of the Request No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Order ID"; Rec."Order ID")
                {

                    ToolTip = 'Specifies the value of the Order ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {

                    ToolTip = 'Specifies the value of the Unit of Measure Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {

                    ToolTip = 'Specifies the value of the Serving Step field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {

                    ToolTip = 'Specifies the value of the Created Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Requested Date-Time"; Rec."Serving Requested Date-Time")
                {

                    ToolTip = 'Specifies the value of the Serving Requested Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Status"; Rec."Line Status")
                {

                    ToolTip = 'Specifies the value of the Line Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Production Status"; Rec."Production Status")
                {

                    ToolTip = 'Specifies the value of the Production Status field';
                    ApplicationArea = NPRRetail;
                }
                field("No. of Kitchen Stations"; Rec."No. of Kitchen Stations")
                {

                    ToolTip = 'Specifies the value of the No. of Kitchen Stations field';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(SeatingCode; Rec.SeatingCode())
                {

                    Caption = 'Seating Code';
                    ToolTip = 'Specifies the value of the Seating Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

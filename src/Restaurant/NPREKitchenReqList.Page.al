page 6150691 "NPR NPRE Kitchen Req. List"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200420 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)
    // NPR5.55/ALPO/20200615 CASE 399170 Restaurant flow change: support for waiter pad related manipulations directly inside a POS sale

    Caption = 'Kitchen Request List';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Request";

    layout
    {
        area(content)
        {
            repeater("Order Lines")
            {
                Caption = 'Order Lines';
                field("Request No."; "Request No.")
                {
                    ApplicationArea = All;
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; "Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Serving Step"; "Serving Step")
                {
                    ApplicationArea = All;
                }
                field("Created Date-Time"; "Created Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Serving Requested Date-Time"; "Serving Requested Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Line Status"; "Line Status")
                {
                    ApplicationArea = All;
                }
                field("Production Status"; "Production Status")
                {
                    ApplicationArea = All;
                }
                field("No. of Kitchen Stations"; "No. of Kitchen Stations")
                {
                    ApplicationArea = All;
                }
                field("Restaurant Code"; "Restaurant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("SeatingCode()"; SeatingCode())
                {
                    ApplicationArea = All;
                    Caption = 'Seating Code';
                }
            }
        }
    }

    actions
    {
    }
}


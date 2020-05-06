page 6150691 "NPRE Kitchen Request List"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant

    Caption = 'Kitchen Request List';
    Editable = false;
    PageType = List;
    SourceTable = "NPRE Kitchen Request";

    layout
    {
        area(content)
        {
            repeater("Order Lines")
            {
                Caption = 'Order Lines';
                field("Request No.";"Request No.")
                {
                }
                field("Order ID";"Order ID")
                {
                }
                field(Type;Type)
                {
                }
                field("No.";"No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Unit of Measure Code";"Unit of Measure Code")
                {
                }
                field("Serving Step";"Serving Step")
                {
                }
                field("Created Date-Time";"Created Date-Time")
                {
                }
                field("Serving Requested Date-Time";"Serving Requested Date-Time")
                {
                }
                field("Line Status";"Line Status")
                {
                }
                field("Production Status";"Production Status")
                {
                }
                field("No. of Kitchen Stations";"No. of Kitchen Stations")
                {
                }
                field("Restaurant Code";"Restaurant Code")
                {
                    Visible = false;
                }
                field("Source Document Type";"Source Document Type")
                {
                }
                field("Source Document No.";"Source Document No.")
                {
                }
                field("Source Document Line No.";"Source Document Line No.")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}


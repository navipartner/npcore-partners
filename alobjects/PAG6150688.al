page 6150688 "NPRE Kitchen Order List"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Order List';
    CardPageID = "NPRE Kitchen Order Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPRE Kitchen Order";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order ID";"Order ID")
                {
                }
                field("Restaurant Code";"Restaurant Code")
                {
                }
                field(Status;Status)
                {
                }
                field(Priority;Priority)
                {
                }
                field("Created Date-Time";"Created Date-Time")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014408;Notes)
            {
                Visible = false;
            }
            systempart(Control6014407;Links)
            {
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Show Requests")
            {
                Caption = 'Show Requests';
                Image = ExpandDepositLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPRE Kitchen Requests";
                RunPageLink = "Order ID"=FIELD("Order ID");
                RunPageView = SORTING("Order ID");
            }
        }
    }
}


page 6150696 "NPRE Kitchen Order Card"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Order Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPRE Kitchen Order";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Order ID";"Order ID")
                {
                    Editable = false;
                }
                field("Restaurant Code";"Restaurant Code")
                {
                    Editable = false;
                }
                field("Created Date-Time";"Created Date-Time")
                {
                    Editable = false;
                }
                field(Status;Status)
                {
                    Editable = false;
                }
                field(Priority;Priority)
                {
                }
                field("On Hold";"On Hold")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014409;Notes)
            {
                Visible = false;
            }
            systempart(Control6014408;Links)
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


page 6150688 "NPR NPRE Kitchen Order List"
{
    // NPR5.54/ALPO/20200401 CASE 382428 Kitchen Display System (KDS) for NP Restaurant
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Order List';
    CardPageID = "NPR NPRE Kitchen Order Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Order";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                }
                field("Restaurant Code"; "Restaurant Code")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field(Priority; Priority)
                {
                    ApplicationArea = All;
                }
                field("Created Date-Time"; "Created Date-Time")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014408; Notes)
            {
                Visible = false;
                ApplicationArea=All;
            }
            systempart(Control6014407; Links)
            {
                Visible = false;
                ApplicationArea=All;
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
                RunObject = Page "NPR NPRE Kitchen Req.";
                RunPageLink = "Order ID" = FIELD("Order ID");
                RunPageView = SORTING("Order ID");
                ApplicationArea=All;
            }
        }
    }
}


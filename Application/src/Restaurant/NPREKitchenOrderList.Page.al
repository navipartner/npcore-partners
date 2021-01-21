page 6150688 "NPR NPRE Kitchen Order List"
{
    Caption = 'Kitchen Order List';
    CardPageID = "NPR NPRE Kitchen Order Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Order";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order ID"; Rec."Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order ID field';
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date-Time field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014408; Notes)
            {
                Visible = false;
                ApplicationArea = All;
            }
            systempart(Control6014407; Links)
            {
                Visible = false;
                ApplicationArea = All;
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
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR NPRE Kitchen Req.";
                RunPageLink = "Order ID" = FIELD("Order ID");
                RunPageView = SORTING("Order ID");
                ApplicationArea = All;
                ToolTip = 'Executes the Show Requests action';
            }
        }
    }
}

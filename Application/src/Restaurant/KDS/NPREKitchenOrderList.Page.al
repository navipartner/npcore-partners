page 6150688 "NPR NPRE Kitchen Order List"
{
    Extensible = False;
    Caption = 'Kitchen Order List';
    CardPageID = "NPR NPRE Kitchen Order Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Order";
    SourceTableView = order(descending);
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Order ID"; Rec."Order ID")
                {
                    ToolTip = 'Specifies the order unique Id, assigned by the system according to an automatically maintained number series.';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    ToolTip = 'Specifies the restaurant the ordered was created for.';
                    ApplicationArea = NPRRetail;
                }
                field("Expected Dine Date-Time"; Rec."Expected Dine Date-Time")
                {
                    ToolTip = 'Specifies the date-time the customer requested the order be ready at.';
                    ApplicationArea = NPRRetail;
                }
                field("Order Status"; Rec."Order Status")
                {
                    ToolTip = 'Specifies current status of the order.';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the priority of the order. The higher the number, the lower the priority. This priority is going to be assigned by default to all kitchen requests created under this order.';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ToolTip = 'Specifies the date-time the order was created at.';
                    ApplicationArea = NPRRetail;
                }
                field("Finished Date-Time"; Rec."Finished Date-Time")
                {
                    ToolTip = 'Specifies the date-time the order was finished at.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014408; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014407; Links)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
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
                RunPageLink = "Order ID" = FIELD("Order ID"), "Restaurant Code" = field("Restaurant Code");
                RunPageView = SORTING("Order ID");
                ToolTip = 'View outstaning kitchen requests for the order.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

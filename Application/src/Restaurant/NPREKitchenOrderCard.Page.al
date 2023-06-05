﻿page 6150696 "NPR NPRE Kitchen Order Card"
{
    Extensible = False;
    Caption = 'Kitchen Order Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR NPRE Kitchen Order";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Order ID"; Rec."Order ID")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Order ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Restaurant Code"; Rec."Restaurant Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Restaurant Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    Editable = false;
                    ToolTip = 'Specifies the value of the Created Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Expected Dine Date-Time"; Rec."Expected Dine Date-Time")
                {
                    ToolTip = 'Specifies the date-time the customer requested the order be ready at';
                    ApplicationArea = NPRRetail;
                }
                field("Order Status"; Rec."Order Status")
                {
                    Editable = false;
                    ToolTip = 'Specifies current status of the order';
                    ApplicationArea = NPRRetail;
                }
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
                field("On Hold"; Rec."On Hold")
                {
                    ToolTip = 'Specifies the value of the On Hold field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control6014409; Notes)
            {
                Visible = false;
                ApplicationArea = NPRRetail;
            }
            systempart(Control6014408; Links)
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
                RunPageLink = "Order ID" = FIELD("Order ID");
                RunPageView = SORTING("Order ID");
                ToolTip = 'Executes the Show Requests action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

page 6151137 "NPR TM Waiting List Setup"
{
    // TM1.45/TSA/20200122  CASE 380754 Transport TM1.45 - 22 January 2020

    Caption = 'Waiting List Setup';
    PageType = List;
    SourceTable = "NPR TM Waiting List Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field(Description; Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Simultaneous Notification Cnt."; "Simultaneous Notification Cnt.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Max Notifications per Address"; "Max Notifications per Address")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Expires In (Minutes)"; "Expires In (Minutes)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notification Delay (Minutes)"; "Notification Delay (Minutes)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field(URL; URL)
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Activate WL at Remaining Qty."; "Activate WL at Remaining Qty.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Remaing Capacity Threshold"; "Remaing Capacity Threshold")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notify Daily From Time"; "Notify Daily From Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notify Daily Until Time"; "Notify Daily Until Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Notify On Opt-In"; "Notify On Opt-In")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
                field("Enforce Same Item"; "Enforce Same Item")
                {
                    ApplicationArea = NPRTicketAdvanced;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("E-Mail Templates")
            {
                ToolTip = 'Navigate to e-mail template setup.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'E-Mail Templates';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6060110));

            }
            action("SMS Template")
            {
                ToolTip = 'Navigate to SMS template setup.';
                ApplicationArea = NPRTicketAdvanced;
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060110));

            }
        }
    }
}


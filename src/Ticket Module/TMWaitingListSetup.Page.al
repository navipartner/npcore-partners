page 6151137 "NPR TM Waiting List Setup"
{
    // TM1.45/TSA/20200122  CASE 380754 Transport TM1.45 - 22 January 2020

    Caption = 'Waiting List Setup';
    PageType = List;
    SourceTable = "NPR TM Waiting List Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Simultaneous Notification Cnt."; "Simultaneous Notification Cnt.")
                {
                    ApplicationArea = All;
                }
                field("Max Notifications per Address"; "Max Notifications per Address")
                {
                    ApplicationArea = All;
                }
                field("Expires In (Minutes)"; "Expires In (Minutes)")
                {
                    ApplicationArea = All;
                }
                field("Notification Delay (Minutes)"; "Notification Delay (Minutes)")
                {
                    ApplicationArea = All;
                }
                field(URL; URL)
                {
                    ApplicationArea = All;
                }
                field("Activate WL at Remaining Qty."; "Activate WL at Remaining Qty.")
                {
                    ApplicationArea = All;
                }
                field("Remaing Capacity Threshold"; "Remaing Capacity Threshold")
                {
                    ApplicationArea = All;
                }
                field("Notify Daily From Time"; "Notify Daily From Time")
                {
                    ApplicationArea = All;
                }
                field("Notify Daily Until Time"; "Notify Daily Until Time")
                {
                    ApplicationArea = All;
                }
                field("Notify On Opt-In"; "Notify On Opt-In")
                {
                    ApplicationArea = All;
                }
                field("Enforce Same Item"; "Enforce Same Item")
                {
                    ApplicationArea = All;
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
                Caption = 'E-Mail Templates';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6060110));
            }
            action("SMS Template")
            {
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


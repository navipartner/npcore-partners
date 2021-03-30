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
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Simultaneous Notification Cnt."; Rec."Simultaneous Notification Cnt.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Simultaneous Notification Cnt. field';
                }
                field("Max Notifications per Address"; Rec."Max Notifications per Address")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Max Notifications per Address field';
                }
                field("Expires In (Minutes)"; Rec."Expires In (Minutes)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Expires In (Minutes) field';
                }
                field("Notification Delay (Minutes)"; Rec."Notification Delay (Minutes)")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notification Delay  (Minutes) field';
                }
                field(URL; Rec.URL)
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the URL field';
                }
                field("Activate WL at Remaining Qty."; Rec."Activate WL at Remaining Qty.")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Activate WL at Remaining Qty. field';
                }
                field("Remaing Capacity Threshold"; Rec."Remaing Capacity Threshold")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Remaing Capacity Threshold field';
                }
                field("Notify Daily From Time"; Rec."Notify Daily From Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify Daily From Time field';
                }
                field("Notify Daily Until Time"; Rec."Notify Daily Until Time")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify Daily Until Time field';
                }
                field("Notify On Opt-In"; Rec."Notify On Opt-In")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Notify On Opt-In field';
                }
                field("Enforce Same Item"; Rec."Enforce Same Item")
                {
                    ApplicationArea = NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Enforce Same Item field';
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
                PromotedCategory = Process;
                PromotedOnly = true;
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
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6060110));

            }
        }
    }
}


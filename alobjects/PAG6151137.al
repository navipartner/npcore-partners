page 6151137 "TM Waiting List Setup"
{
    // TM1.45/TSA/20200122  CASE 380754 Transport TM1.45 - 22 January 2020

    Caption = 'Waiting List Setup';
    PageType = List;
    SourceTable = "TM Waiting List Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Simultaneous Notification Cnt.";"Simultaneous Notification Cnt.")
                {
                }
                field("Max Notifications per Address";"Max Notifications per Address")
                {
                }
                field("Expires In (Minutes)";"Expires In (Minutes)")
                {
                }
                field("Notification Delay (Minutes)";"Notification Delay (Minutes)")
                {
                }
                field(URL;URL)
                {
                }
                field("Activate WL at Remaining Qty.";"Activate WL at Remaining Qty.")
                {
                }
                field("Remaing Capacity Threshold";"Remaing Capacity Threshold")
                {
                }
                field("Notify Daily From Time";"Notify Daily From Time")
                {
                }
                field("Notify Daily Until Time";"Notify Daily Until Time")
                {
                }
                field("Notify On Opt-In";"Notify On Opt-In")
                {
                }
                field("Enforce Same Item";"Enforce Same Item")
                {
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
                RunObject = Page "E-mail Templates";
                RunPageView = WHERE("Table No."=CONST(6060110));
            }
            action("SMS Template")
            {
                Caption = 'SMS Template';
                Image = InteractionTemplate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "SMS Template List";
                RunPageView = WHERE("Table No."=CONST(6060110));
            }
        }
    }
}


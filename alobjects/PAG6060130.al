page 6060130 "MM Member Card List"
{
    // MM1.07/TSA/20160203  CASE 233438 Member Management
    // MM1.10/TSA/20130321  CASE 237176 Added flowfield company name
    // MM1.15/TSA/20160817  CASE 238445 Transport MM1.15 - 19 July 2016
    // MM1.18/TSA/20170220 CASE 266768 Added default filter to not show blocked entries
    // MM1.21/TSA /20170721 CASE 284653 Added button "Arrival Log"
    // MM1.22/TSA /20170911 CASE 284560 Added field Card Is Temporary

    Caption = 'Member Card List';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "MM Member Card";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Editable = false;
                field("External Membership No.";"External Membership No.")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field("External Card No.";"External Card No.")
                {
                }
                field("External Member No.";"External Member No.")
                {
                }
                field("Company Name";"Company Name")
                {
                }
                field("Display Name";"Display Name")
                {
                }
                field("E-Mail Address";"E-Mail Address")
                {
                }
                field("Valid Until";"Valid Until")
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Member Blocked";"Member Blocked")
                {
                }
                field("Membership Blocked";"Membership Blocked")
                {
                }
                field("Card Is Temporary";"Card Is Temporary")
                {
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(Membership)
            {
                Caption = 'Membership';
                Ellipsis = true;
                Image = CustomerList;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Membership Card";
                RunPageLink = "Entry No."=FIELD("Membership Entry No.");
            }
            action(Members)
            {
                Caption = 'Members';
                Ellipsis = true;
                Image = Customer;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Member Card";
                RunPageLink = "Entry No."=FIELD("Member Entry No.");
            }
            separator(Separator6014401)
            {
            }
            action("Arrival Log")
            {
                Caption = 'Arrival Log';
                Ellipsis = true;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "MM Member Arrival Log";
                RunPageLink = "External Card No."=FIELD("External Card No.");
            }
        }
    }
}


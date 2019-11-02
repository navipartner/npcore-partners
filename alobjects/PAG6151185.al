page 6151185 "MM Sponsorship Ticket Setup"
{
    // MM1.41/TSA /20191004 CASE 367471 Initial Version

    Caption = 'Sponsorship Ticket Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "MM Sponsorship Ticket Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership Code";"Membership Code")
                {
                }
                field("External Membership No.";"External Membership No.")
                {
                    Visible = false;
                }
                field("Event Type";"Event Type")
                {
                }
                field("Line No.";"Line No.")
                {
                }
                field("Item No.";"Item No.")
                {
                }
                field("Variant Code";"Variant Code")
                {
                }
                field(Description;Description)
                {
                }
                field(Quantity;Quantity)
                {
                }
                field(Blocked;Blocked)
                {
                }
                field("Delivery Method";"Delivery Method")
                {
                }
                field("Distribution Mode";"Distribution Mode")
                {
                }
                field("Once Per Period (On Demand)";"Once Per Period (On Demand)")
                {
                    Visible = false;
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
                Ellipsis = true;
                Image = InteractionTemplate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "E-mail Templates";
                RunPageView = WHERE("Table No."=CONST(6151186));
            }
            action("SMS Template")
            {
                Caption = 'SMS Template';
                Ellipsis = true;
                Image = InteractionTemplate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "SMS Template List";
                RunPageView = WHERE("Table No."=CONST(6151186));
            }
        }
        area(processing)
        {
            action("Send Pending Notifications")
            {
                Caption = 'Send Pending Notifications';
                Ellipsis = true;
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SponsorshipTicketMgmt: Codeunit "MM Sponsorship Ticket Mgmt.";
                begin

                    if (Confirm (SEND_CONFIRM, true)) then
                      SponsorshipTicketMgmt.NotifyRecipients ();
                end;
            }
        }
    }

    var
        SEND_CONFIRM: Label 'Send all pending notications?';
}


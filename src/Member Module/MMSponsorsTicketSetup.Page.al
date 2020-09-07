page 6151185 "NPR MM Sponsors. Ticket Setup"
{
    // MM1.41/TSA /20191004 CASE 367471 Initial Version

    Caption = 'Sponsorship Ticket Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR MM Sponsors. Ticket Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                }
                field("Delivery Method"; "Delivery Method")
                {
                    ApplicationArea = All;
                }
                field("Distribution Mode"; "Distribution Mode")
                {
                    ApplicationArea = All;
                }
                field("Once Per Period (On Demand)"; "Once Per Period (On Demand)")
                {
                    ApplicationArea = All;
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
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6151186));
                ApplicationArea=All;
            }
            action("SMS Template")
            {
                Caption = 'SMS Template';
                Ellipsis = true;
                Image = InteractionTemplate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6151186));
                ApplicationArea=All;
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
                ApplicationArea=All;

                trigger OnAction()
                var
                    SponsorshipTicketMgmt: Codeunit "NPR MM Sponsorship Ticket Mgt";
                begin

                    if (Confirm(SEND_CONFIRM, true)) then
                        SponsorshipTicketMgmt.NotifyRecipients();
                end;
            }
        }
    }

    var
        SEND_CONFIRM: Label 'Send all pending notications?';
}


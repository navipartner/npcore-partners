page 6151185 "NPR MM Sponsors. Ticket Setup"
{

    Caption = 'Sponsorship Ticket Setup';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field("Item No."; "Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item No. field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field(Blocked; Blocked)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Blocked field';
                }
                field("Delivery Method"; "Delivery Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delivery Method field';
                }
                field("Distribution Mode"; "Distribution Mode")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Mode field';
                }
                field("Once Per Period (On Demand)"; "Once Per Period (On Demand)")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Once Per Period (On Demand) field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the E-Mail Templates action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the SMS Template action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Send Pending Notifications action';

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


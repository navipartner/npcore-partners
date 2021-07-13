page 6151185 "NPR MM Sponsors. Ticket Setup"
{

    Caption = 'Sponsorship Ticket Setup';
    DelayedInsert = true;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Sponsors. Ticket Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Type"; Rec."Event Type")
                {

                    ToolTip = 'Specifies the value of the Event Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Line No."; Rec."Line No.")
                {

                    ToolTip = 'Specifies the value of the Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item No."; Rec."Item No.")
                {

                    ToolTip = 'Specifies the value of the Item No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    ToolTip = 'Specifies the value of the Variant Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field(Blocked; Rec.Blocked)
                {

                    ToolTip = 'Specifies the value of the Blocked field';
                    ApplicationArea = NPRRetail;
                }
                field("Delivery Method"; Rec."Delivery Method")
                {

                    ToolTip = 'Specifies the value of the Delivery Method field';
                    ApplicationArea = NPRRetail;
                }
                field("Distribution Mode"; Rec."Distribution Mode")
                {

                    ToolTip = 'Specifies the value of the Distribution Mode field';
                    ApplicationArea = NPRRetail;
                }
                field("Once Per Period (On Demand)"; Rec."Once Per Period (On Demand)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Once Per Period (On Demand) field';
                    ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR E-mail Templates";
                RunPageView = WHERE("Table No." = CONST(6151186));

                ToolTip = 'Executes the E-Mail Templates action';
                ApplicationArea = NPRRetail;
            }
            action("SMS Template")
            {
                Caption = 'SMS Template';
                Ellipsis = true;
                Image = InteractionTemplate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR SMS Template List";
                RunPageView = WHERE("Table No." = CONST(6151186));

                ToolTip = 'Executes the SMS Template action';
                ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Send Pending Notifications action';
                ApplicationArea = NPRRetail;

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


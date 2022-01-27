page 6060070 "NPR MM Members. AutoRenew List"
{
    Extensible = False;

    Caption = 'Membership Auto Renew List';
    CardPageID = "NPR MM Members. AutoRenew Card";
    PageType = List;
    SourceTable = "NPR MM Membership Auto Renew";
    UsageCategory = Tasks;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Valid Until Date"; Rec."Valid Until Date")
                {

                    ToolTip = 'Specifies the value of the Valid Until Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Document Date"; Rec."Document Date")
                {

                    ToolTip = 'Specifies the value of the Document Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Terms Code"; Rec."Payment Terms Code")
                {

                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Payment Method Code"; Rec."Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Invoice"; Rec."Post Invoice")
                {

                    ToolTip = 'Specifies the value of the Post Invoice field';
                    ApplicationArea = NPRRetail;
                }
                field("Posting Date"; Rec."Posting Date")
                {

                    ToolTip = 'Specifies the value of the Posting Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Started At"; Rec."Started At")
                {

                    ToolTip = 'Specifies the value of the Started At field';
                    ApplicationArea = NPRRetail;
                }
                field("Completed At"; Rec."Completed At")
                {

                    ToolTip = 'Specifies the value of the Completed At field';
                    ApplicationArea = NPRRetail;
                }
                field("Started By"; Rec."Started By")
                {

                    ToolTip = 'Specifies the value of the Started By field';
                    ApplicationArea = NPRRetail;
                }
                field("Selected Membership Count"; Rec."Selected Membership Count")
                {

                    ToolTip = 'Specifies the value of the Selected Membership Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto-Renew Success Count"; Rec."Auto-Renew Success Count")
                {

                    ToolTip = 'Specifies the value of the Auto-Renew Success Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto-Renew Fail Count"; Rec."Auto-Renew Fail Count")
                {

                    ToolTip = 'Specifies the value of the Auto-Renew Fail Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Invoice Create Fail Count"; Rec."Invoice Create Fail Count")
                {

                    ToolTip = 'Specifies the value of the Invoice Create Fail Count field';
                    ApplicationArea = NPRRetail;
                }
                field("Invoice Posting Fail Count"; Rec."Invoice Posting Fail Count")
                {

                    ToolTip = 'Specifies the value of the Invoice Posting Fail Count field';
                    ApplicationArea = NPRRetail;
                }
                field("First Invoice No."; Rec."First Invoice No.")
                {

                    ToolTip = 'Specifies the value of the First Invoice No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Invoice No."; Rec."Last Invoice No.")
                {

                    ToolTip = 'Specifies the value of the Last Invoice No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Start Auto-Renew")
            {
                Caption = 'Start Auto-Renew';
                Image = Start;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Start Auto-Renew action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    StartAutoRenew();
                end;
            }
        }
        area(navigation)
        {
            action("Auto-Renew Log")
            {
                Caption = 'Auto-Renew Log';
                Image = Log;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Members. Auto-Renew Log";
                RunPageLink = "Auto-Renew Entry No." = FIELD("Entry No.");

                ToolTip = 'Executes the Auto-Renew Log action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    var
        COMPLETE: Label 'This Auto Renew batch is complete and can not be restarted.';

    local procedure StartAutoRenew()
    var
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
    begin

        if Rec."Completed At" <> CreateDateTime(0D, 0T) then
            Error(COMPLETE);

        MembershipAutoRenew.AutoRenewBatch(Rec."Entry No.");
    end;
}


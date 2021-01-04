page 6060070 "NPR MM Members. AutoRenew List"
{

    Caption = 'Membership Auto Renew List';
    CardPageID = "NPR MM Members. AutoRenew Card";
    PageType = List;
    SourceTable = "NPR MM Membership Auto Renew";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Valid Until Date"; "Valid Until Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Valid Until Date field';
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Date field';
                }
                field("Payment Terms Code"; "Payment Terms Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Terms Code field';
                }
                field("Payment Method Code"; "Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Method Code field';
                }
                field("Post Invoice"; "Post Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Invoice field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field("Started At"; "Started At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Started At field';
                }
                field("Completed At"; "Completed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Completed At field';
                }
                field("Started By"; "Started By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Started By field';
                }
                field("Selected Membership Count"; "Selected Membership Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Selected Membership Count field';
                }
                field("Auto-Renew Success Count"; "Auto-Renew Success Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew Success Count field';
                }
                field("Auto-Renew Fail Count"; "Auto-Renew Fail Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto-Renew Fail Count field';
                }
                field("Invoice Create Fail Count"; "Invoice Create Fail Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Create Fail Count field';
                }
                field("Invoice Posting Fail Count"; "Invoice Posting Fail Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Invoice Posting Fail Count field';
                }
                field("First Invoice No."; "First Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Invoice No. field';
                }
                field("Last Invoice No."; "Last Invoice No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Invoice No. field';
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Start Auto-Renew action';

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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Members. Auto-Renew Log";
                RunPageLink = "Auto-Renew Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Auto-Renew Log action';
            }
        }
    }

    var
        COMPLETE: Label 'This Auto Renew batch is complete and can not be restarted.';

    local procedure StartAutoRenew()
    var
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
    begin

        if "Completed At" <> CreateDateTime(0D, 0T) then
            Error(COMPLETE);

        MembershipAutoRenew.AutoRenewBatch(Rec."Entry No.");
    end;
}


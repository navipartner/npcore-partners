page 6151186 "NPR MM Sponsor. Ticket Entry"
{
    Extensible = False;

    Caption = 'Sponsorship Ticket Entry';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Sponsors. Ticket Entry";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {

                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket Token"; Rec."Ticket Token")
                {

                    ToolTip = 'Specifies the value of the Ticket Token field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket No."; Rec."Ticket No.")
                {

                    ToolTip = 'Specifies the value of the Ticket No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Type"; Rec."Event Type")
                {

                    ToolTip = 'Specifies the value of the Event Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Created At"; Rec."Created At")
                {

                    ToolTip = 'Specifies the value of the Created At field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Send Status"; Rec."Notification Send Status")
                {

                    ToolTip = 'Specifies the value of the Notification Send Status field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Sent At"; Rec."Notification Sent At")
                {

                    ToolTip = 'Specifies the value of the Notification Sent At field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Sent By User"; Rec."Notification Sent By User")
                {

                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                    ApplicationArea = NPRRetail;
                }
                field("Notification Address"; Rec."Notification Address")
                {

                    ToolTip = 'Specifies the value of the Notification Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Picked Up At"; Rec."Picked Up At")
                {

                    ToolTip = 'Specifies the value of the Picked Up At field';
                    ApplicationArea = NPRRetail;
                }
                field("External Member No."; Rec."External Member No.")
                {

                    ToolTip = 'Specifies the value of the External Member No. field';
                    ApplicationArea = NPRRetail;
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {

                    ToolTip = 'Specifies the value of the E-Mail Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Phone No."; Rec."Phone No.")
                {

                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("First Name"; Rec."First Name")
                {

                    ToolTip = 'Specifies the value of the First Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Middle Name"; Rec."Middle Name")
                {

                    ToolTip = 'Specifies the value of the Middle Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Name"; Rec."Last Name")
                {

                    ToolTip = 'Specifies the value of the Last Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Display Name"; Rec."Display Name")
                {

                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Address; Rec.Address)
                {

                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Post Code Code"; Rec."Post Code Code")
                {

                    ToolTip = 'Specifies the value of the ZIP Code field';
                    ApplicationArea = NPRRetail;
                }
                field(City; Rec.City)
                {

                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRRetail;
                }
                field("Country Code"; Rec."Country Code")
                {

                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Country; Rec.Country)
                {

                    ToolTip = 'Specifies the value of the Country field';
                    ApplicationArea = NPRRetail;
                }
                field(Birthday; Rec.Birthday)
                {

                    ToolTip = 'Specifies the value of the Birthday field';
                    ApplicationArea = NPRRetail;
                }
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
                field("Membership Valid From"; Rec."Membership Valid From")
                {

                    ToolTip = 'Specifies the value of the Membership Valid From field';
                    ApplicationArea = NPRRetail;
                }
                field("Membership Valid Until"; Rec."Membership Valid Until")
                {

                    ToolTip = 'Specifies the value of the Membership Valid Until field';
                    ApplicationArea = NPRRetail;
                }
                field("External Membership No."; Rec."External Membership No.")
                {

                    ToolTip = 'Specifies the value of the External Membership No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Failed With Message"; Rec."Failed With Message")
                {

                    ToolTip = 'Specifies the value of the Failed With Message field';
                    ApplicationArea = NPRRetail;
                }
                field("Ticket URL"; Rec."Ticket URL")
                {

                    ToolTip = 'Specifies the value of the Ticket URL field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Resend Notification")
            {
                Caption = 'Resend Notification';
                Image = SendTo;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Resend Notification action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    ResendNotification(Rec);
                end;
            }
        }
        area(navigation)
        {
            action("Ticket Request")
            {
                Caption = 'Ticket Request';
                Ellipsis = true;
                Image = Navigate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR TM Ticket Request";
                RunPageLink = "Session Token ID" = FIELD("Ticket Token");

                ToolTip = 'Executes the Ticket Request action';
                ApplicationArea = NPRRetail;
            }
        }
    }

    local procedure ResendNotification(SponsorshipTicketEntry: Record "NPR MM Sponsors. Ticket Entry")
    var
        SponsorshipTicketMgmt: Codeunit "NPR MM Sponsorship Ticket Mgt";
    begin

        SponsorshipTicketEntry.TestField("Notification Send Status", SponsorshipTicketEntry."Notification Send Status"::NOT_DELIVERED);
        SponsorshipTicketMgmt.NotifyRecipient(SponsorshipTicketEntry."Entry No.");
    end;
}


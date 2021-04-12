page 6151186 "NPR MM Sponsor. Ticket Entry"
{

    Caption = 'Sponsorship Ticket Entry';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Sponsors. Ticket Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Membership Entry No."; Rec."Membership Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Ticket Token"; Rec."Ticket Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Token field';
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Event Type"; Rec."Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Created At"; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field("Notification Send Status"; Rec."Notification Send Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Send Status field';
                }
                field("Notification Sent At"; Rec."Notification Sent At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Sent At field';
                }
                field("Notification Sent By User"; Rec."Notification Sent By User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                }
                field("Notification Address"; Rec."Notification Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field("Picked Up At"; Rec."Picked Up At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picked Up At field';
                }
                field("External Member No."; Rec."External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("E-Mail Address"; Rec."E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                }
                field("Phone No."; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("First Name"; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Middle Name"; Rec."Middle Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Middle Name field';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Name field';
                }
                field(Address; Rec.Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code Code"; Rec."Post Code Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ZIP Code field';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Country Code"; Rec."Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field';
                }
                field(Country; Rec.Country)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country field';
                }
                field(Birthday; Rec.Birthday)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Birthday field';
                }
                field("Community Code"; Rec."Community Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Community Code field';
                }
                field("Membership Code"; Rec."Membership Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Code field';
                }
                field("Membership Valid From"; Rec."Membership Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Valid From field';
                }
                field("Membership Valid Until"; Rec."Membership Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Valid Until field';
                }
                field("External Membership No."; Rec."External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Failed With Message"; Rec."Failed With Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Failed With Message field';
                }
                field("Ticket URL"; Rec."Ticket URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket URL field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Resend Notification action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Ticket Request action';
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


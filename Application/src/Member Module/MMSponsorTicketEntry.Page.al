page 6151186 "NPR MM Sponsor. Ticket Entry"
{

    Caption = 'Sponsorship Ticket Entry';
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Sponsors. Ticket Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Entry No. field';
                }
                field("Ticket Token"; "Ticket Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket Token field';
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ticket No. field';
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Event Type field';
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created At field';
                }
                field("Notification Send Status"; "Notification Send Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Send Status field';
                }
                field("Notification Sent At"; "Notification Sent At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Sent At field';
                }
                field("Notification Sent By User"; "Notification Sent By User")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Sent By User field';
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Notification Address field';
                }
                field("Picked Up At"; "Picked Up At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Picked Up At field';
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Member No. field';
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-Mail Address field';
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Phone No. field';
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the First Name field';
                }
                field("Middle Name"; "Middle Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Middle Name field';
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Name field';
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Name field';
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Address field';
                }
                field("Post Code Code"; "Post Code Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ZIP Code field';
                }
                field(City; City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Country Code"; "Country Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Code field';
                }
                field(Country; Country)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country field';
                }
                field(Birthday; Birthday)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Birthday field';
                }
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
                field("Membership Valid From"; "Membership Valid From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Valid From field';
                }
                field("Membership Valid Until"; "Membership Valid Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Membership Valid Until field';
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Membership No. field';
                }
                field("Failed With Message"; "Failed With Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Failed With Message field';
                }
                field("Ticket URL"; "Ticket URL")
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


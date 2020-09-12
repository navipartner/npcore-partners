page 6151186 "NPR MM Sponsor. Ticket Entry"
{
    // MM1.41/TSA /20191004 CASE 367471 Initial Version

    Caption = 'Sponsorship Ticket Entry';
    InsertAllowed = false;
    PageType = List;
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
                }
                field("Membership Entry No."; "Membership Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Ticket Token"; "Ticket Token")
                {
                    ApplicationArea = All;
                }
                field("Ticket No."; "Ticket No.")
                {
                    ApplicationArea = All;
                }
                field("Event Type"; "Event Type")
                {
                    ApplicationArea = All;
                }
                field("Created At"; "Created At")
                {
                    ApplicationArea = All;
                }
                field("Notification Send Status"; "Notification Send Status")
                {
                    ApplicationArea = All;
                }
                field("Notification Sent At"; "Notification Sent At")
                {
                    ApplicationArea = All;
                }
                field("Notification Sent By User"; "Notification Sent By User")
                {
                    ApplicationArea = All;
                }
                field("Notification Address"; "Notification Address")
                {
                    ApplicationArea = All;
                }
                field("Picked Up At"; "Picked Up At")
                {
                    ApplicationArea = All;
                }
                field("External Member No."; "External Member No.")
                {
                    ApplicationArea = All;
                }
                field("E-Mail Address"; "E-Mail Address")
                {
                    ApplicationArea = All;
                }
                field("Phone No."; "Phone No.")
                {
                    ApplicationArea = All;
                }
                field("First Name"; "First Name")
                {
                    ApplicationArea = All;
                }
                field("Middle Name"; "Middle Name")
                {
                    ApplicationArea = All;
                }
                field("Last Name"; "Last Name")
                {
                    ApplicationArea = All;
                }
                field("Display Name"; "Display Name")
                {
                    ApplicationArea = All;
                }
                field(Address; Address)
                {
                    ApplicationArea = All;
                }
                field("Post Code Code"; "Post Code Code")
                {
                    ApplicationArea = All;
                }
                field(City; City)
                {
                    ApplicationArea = All;
                }
                field("Country Code"; "Country Code")
                {
                    ApplicationArea = All;
                }
                field(Country; Country)
                {
                    ApplicationArea = All;
                }
                field(Birthday; Birthday)
                {
                    ApplicationArea = All;
                }
                field("Community Code"; "Community Code")
                {
                    ApplicationArea = All;
                }
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Membership Valid From"; "Membership Valid From")
                {
                    ApplicationArea = All;
                }
                field("Membership Valid Until"; "Membership Valid Until")
                {
                    ApplicationArea = All;
                }
                field("External Membership No."; "External Membership No.")
                {
                    ApplicationArea = All;
                }
                field("Failed With Message"; "Failed With Message")
                {
                    ApplicationArea = All;
                }
                field("Ticket URL"; "Ticket URL")
                {
                    ApplicationArea = All;
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


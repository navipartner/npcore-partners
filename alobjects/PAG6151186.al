page 6151186 "MM Sponsorship Ticket Entry"
{
    // MM1.41/TSA /20191004 CASE 367471 Initial Version

    Caption = 'Sponsorship Ticket Entry';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "MM Sponsorship Ticket Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No.";"Entry No.")
                {
                }
                field("Membership Entry No.";"Membership Entry No.")
                {
                }
                field("Ticket Token";"Ticket Token")
                {
                }
                field("Ticket No.";"Ticket No.")
                {
                }
                field("Event Type";"Event Type")
                {
                }
                field("Created At";"Created At")
                {
                }
                field("Notification Send Status";"Notification Send Status")
                {
                }
                field("Notification Sent At";"Notification Sent At")
                {
                }
                field("Notification Sent By User";"Notification Sent By User")
                {
                }
                field("Notification Address";"Notification Address")
                {
                }
                field("Picked Up At";"Picked Up At")
                {
                }
                field("External Member No.";"External Member No.")
                {
                }
                field("E-Mail Address";"E-Mail Address")
                {
                }
                field("Phone No.";"Phone No.")
                {
                }
                field("First Name";"First Name")
                {
                }
                field("Middle Name";"Middle Name")
                {
                }
                field("Last Name";"Last Name")
                {
                }
                field("Display Name";"Display Name")
                {
                }
                field(Address;Address)
                {
                }
                field("Post Code Code";"Post Code Code")
                {
                }
                field(City;City)
                {
                }
                field("Country Code";"Country Code")
                {
                }
                field(Country;Country)
                {
                }
                field(Birthday;Birthday)
                {
                }
                field("Community Code";"Community Code")
                {
                }
                field("Membership Code";"Membership Code")
                {
                }
                field("Membership Valid From";"Membership Valid From")
                {
                }
                field("Membership Valid Until";"Membership Valid Until")
                {
                }
                field("External Membership No.";"External Membership No.")
                {
                }
                field("Failed With Message";"Failed With Message")
                {
                }
                field("Ticket URL";"Ticket URL")
                {
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

                trigger OnAction()
                begin
                    ResendNotification (Rec);
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
                RunObject = Page "TM Ticket Request";
                RunPageLink = "Session Token ID"=FIELD("Ticket Token");
            }
        }
    }

    local procedure ResendNotification(SponsorshipTicketEntry: Record "MM Sponsorship Ticket Entry")
    var
        SponsorshipTicketMgmt: Codeunit "MM Sponsorship Ticket Mgmt.";
    begin

        SponsorshipTicketEntry.TestField ("Notification Send Status", SponsorshipTicketEntry."Notification Send Status"::NOT_DELIVERED);
        SponsorshipTicketMgmt.NotifyRecipient (SponsorshipTicketEntry."Entry No.");
    end;
}


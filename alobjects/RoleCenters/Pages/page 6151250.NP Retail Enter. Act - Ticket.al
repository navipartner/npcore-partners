page 6151250 "NP Retail Enter. Act - Ticket"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NP Retail Entertainment Cue";

    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Issued Tickets"; "Issued Tickets")
                {
                }
                field("Ticket Requests"; "Ticket Requests")
                {
                    DrillDownPageID = "TM Ticket Request";
                }
                field("Ticket Schedules"; "Ticket Schedules")
                {
                    DrillDownPageID = "TM Ticket Schedules";
                }
                field("Ticket Admissions"; "Ticket Admissions")
                {
                    DrillDownPageID = "TM Ticket Admissions";
                }
            }
            cuegroup(Members)
            {
                Caption = 'Members';
                field(Control6; Members)
                {
                    ShowCaption = false;
                }
                field(Memberships; Memberships)
                {
                }
                field(Membercards; Membercards)
                {
                }
            }

            cuegroup(Master)
            {
                Caption = 'Master';
                field(Items; Items)
                {
                }
                field(Contacts; Contacts)
                {
                }
                field(Customers; Customers)
                {
                }

            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Reset;
        if not Get then begin
            Init;
            Insert;
        end;
    end;
}


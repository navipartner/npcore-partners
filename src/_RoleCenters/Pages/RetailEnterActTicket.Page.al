page 6151250 "NPR Retail Enter. Act - Ticket"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Entertainment Cue";

    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Issued Tickets"; "Issued Tickets")
                {
                    ApplicationArea = All;
                }
                field("Ticket Requests"; "Ticket Requests")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Request";
                }
                field("Ticket Schedules"; "Ticket Schedules")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Schedules";
                }
                field("Ticket Admissions"; "Ticket Admissions")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "NPR TM Ticket Admissions";
                }
            }
            cuegroup(Members)
            {
                Caption = 'Members';
                field(Control6; Members)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
                field(Memberships; Memberships)
                {
                    ApplicationArea = All;
                }
                field(Membercards; Membercards)
                {
                    ApplicationArea = All;
                }
            }

            cuegroup(Master)
            {
                Caption = 'Master';
                field(Items; Items)
                {
                    ApplicationArea = All;
                }
                field(Contacts; Contacts)
                {
                    ApplicationArea = All;
                }
                field(Customers; Customers)
                {
                    ApplicationArea = All;
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


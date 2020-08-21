page 6014692 "Retail Admin Activities - Tick"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - Tick';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Ticket Types"; "Ticket Types")
                {
                    ApplicationArea = All;
                }
                field("Ticket Admission BOMs"; "Ticket Admission BOMs")
                {
                    ApplicationArea = All;
                }
                field("Ticket Schedules"; "Ticket Schedules")
                {
                    ApplicationArea = All;
                }
                field("Ticket Admissions"; "Ticket Admissions")
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


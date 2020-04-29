page 6014570 "Retail Admin Activities"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(POS)
            {
                Caption = 'POS';
                field("User Setups";"User Setups")
                {
                }
                field(Salespersons;Salespersons)
                {
                }
                field("POS Stores";"POS Stores")
                {
                }
                field("POS Units";"POS Units")
                {
                }
                field("Cash Registers";"Cash Registers")
                {
                }
                field("POS Payment Bins";"POS Payment Bins")
                {
                }
                field("POS Payment Methods";"POS Payment Methods")
                {
                }
                field("POS Posting Setups";"POS Posting Setups")
                {
                }
            }
            cuegroup(Tickets)
            {
                Caption = 'Tickets';
                field("Ticket Types";"Ticket Types")
                {
                }
                field("Ticket Admission BOMs";"Ticket Admission BOMs")
                {
                }
                field("Ticket Schedules";"Ticket Schedules")
                {
                }
                field("Ticket Admissions";"Ticket Admissions")
                {
                }
            }
            cuegroup(Members)
            {
                Caption = 'Members';
                field("Membership Setup";"Membership Setup")
                {
                }
                field("Membership Sales Setup";"Membership Sales Setup")
                {
                }
                field("Member Alteration";"Member Alteration")
                {
                }
                field("Member Community";"Member Community")
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


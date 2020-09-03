page 6014570 "NPR Retail Admin Activities"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(POS)
            {
                Caption = 'POS';
                field("User Setups"; "User Setups")
                {
                    ApplicationArea = All;
                }
                field(Salespersons; Salespersons)
                {
                    ApplicationArea = All;
                }
                field("POS Stores"; "POS Stores")
                {
                    ApplicationArea = All;
                }
                field("POS Units"; "POS Units")
                {
                    ApplicationArea = All;
                }
                field("Cash Registers"; "Cash Registers")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Bins"; "POS Payment Bins")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Methods"; "POS Payment Methods")
                {
                    ApplicationArea = All;
                }
                field("POS Posting Setups"; "POS Posting Setups")
                {
                    ApplicationArea = All;
                }
            }
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
            cuegroup(Members)
            {
                Caption = 'Members';
                field("Membership Setup"; "Membership Setup")
                {
                    ApplicationArea = All;
                }
                field("Membership Sales Setup"; "Membership Sales Setup")
                {
                    ApplicationArea = All;
                }
                field("Member Alteration"; "Member Alteration")
                {
                    ApplicationArea = All;
                }
                field("Member Community"; "Member Community")
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


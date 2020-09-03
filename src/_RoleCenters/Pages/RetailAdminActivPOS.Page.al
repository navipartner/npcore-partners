page 6014694 "NPR Retail Admin Activ. - POS"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - POS';
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


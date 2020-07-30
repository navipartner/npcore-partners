page 6151248 "NP Retail Admin Act - POS"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'NP Retail - POS';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NP Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup(" ")
            {
                Caption = ' ';
                // CueGroupLayout = Rows;
                ShowCaption = false;
                field("User Setups"; "User Setups")
                {
                }
                field(Salespersons; Salespersons)
                {
                    DrillDownPageID = "Salespersons/Purchasers";
                }
                field("POS Stores"; "POS Stores")
                {
                }
                field("POS Units"; "POS Units")
                {
                }
                field("Cash Registers"; "Cash Registers")
                {
                    DrillDownPageID = "Register List";
                }
                field("POS Payment Bins"; "POS Payment Bins")
                {
                }
                field("POS Payment Methods"; "POS Payment Methods")
                {
                }
                field("POS Posting Setups"; "POS Posting Setups")
                {
                    DrillDownPageID = "POS Posting Setup";
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


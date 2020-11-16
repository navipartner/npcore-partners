page 6151248 "NPR Retail Admin Act - POS"
{
    // #343621/ZESO/20190725  CASE 343621 Object created.

    Caption = 'NP Retail - POS';
    PageType = CardPart;
    UsageCategory = Administration;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";

    layout
    {
        area(content)
        {
            cuegroup("")
            {
                Caption = ' ';
                // CueGroupLayout = Rows;
                ShowCaption = false;
                field("User Setups"; "User Setups")
                {
                    ApplicationArea = All;
                }
                field(Salespersons; Salespersons)
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Salespersons/Purchasers";
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
                    DrillDownPageID = "NPR Register List";
                }
                field("POS Payment Bins"; "POS Payment Bins")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Methods"; "POS Payment Methods")
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


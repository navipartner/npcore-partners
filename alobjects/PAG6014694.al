page 6014694 "Retail Admin Activities - POS"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - POS';
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
                CueGroupLayout = Rows;
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


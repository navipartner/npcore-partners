page 6014694 "NPR Retail Admin Activ. - POS"
{
    // NPR5.51/ZESO/20190725  CASE 343621 Object created.

    Caption = 'Retail Admin Activities - POS';
    PageType = CardPart;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the User Setups field';
                }
                field(Salespersons; Salespersons)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salespersons field';
                }
                field("POS Stores"; "POS Stores")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Stores field';
                }
                field("POS Units"; "POS Units")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Units field';
                }
                field("Cash Registers"; "Cash Registers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Registers field';
                }
                field("POS Payment Bins"; "POS Payment Bins")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bins field';
                }
                field("POS Payment Methods"; "POS Payment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Methods field';
                }
                field("POS Posting Setups"; "POS Posting Setups")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Posting Setups field';
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


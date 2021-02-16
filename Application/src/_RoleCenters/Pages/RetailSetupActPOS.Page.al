page 6151248 "NPR Setup Act - POS"
{
    Caption = 'NP Retail Setup - POS';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup("Users&Salespersons")
            {
                Caption = 'Salespersons';
                field("User Setups"; Rec."User Setups")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Setups field';
                }
                field(Salespersons; Rec.Salespersons)
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Salespersons/Purchasers";
                    ToolTip = 'Specifies the value of the Salespersons field';
                }
            }
            cuegroup(stores)
            {
                Caption = 'Stores';
                field("POS Stores"; Rec."POS Stores")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Stores field';
                }
                field("POS Units"; Rec."POS Units")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Units field';
                }
            }
            cuegroup(payments)
            {
                Caption = 'Payments';
                field("POS Payment Methods"; Rec."POS Payment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Methods field';
                }
                field("POS Payment Bins"; Rec."POS Payment Bins")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bins field';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset;
        if not Rec.Get then begin
            Rec.Init;
            Rec.Insert;
        end;
    end;
}


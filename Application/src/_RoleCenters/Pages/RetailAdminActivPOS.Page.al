page 6014694 "NPR Retail Admin Activ. - POS"
{
    Caption = 'Retail Admin Activities - POS';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "NPR Retail Admin Cue";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            cuegroup(POS)
            {
                Caption = 'POS';
                field("User Setups"; Rec."User Setups")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Setups field';
                }
                field(Salespersons; Rec.Salespersons)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salespersons field';
                }
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
                field("Cash Registers"; Rec."Cash Registers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Registers field';
                }
                field("POS Payment Bins"; Rec."POS Payment Bins")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bins field';
                }
                field("POS Payment Methods"; Rec."POS Payment Methods")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Methods field';
                }
                field("POS Posting Setups"; Rec."POS Posting Setups")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Posting Setups field';
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


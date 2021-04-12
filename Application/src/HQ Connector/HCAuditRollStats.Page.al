page 6150901 "NPR HC Audit Roll Stats"
{
    Caption = 'HC Audit Roll Statistics';
    Editable = false;
    PageType = Worksheet;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR HC Audit Roll";

    layout
    {
        area(content)
        {
            grid("NP -Retail Audit Roll Statistics")
            {
                Caption = 'NP -Retail Audit Roll Statistics';
                group(Control6150619)
                {
                    ShowCaption = false;
                    field("Register No."; Rec."Register No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Cash Register No. field';
                    }
                    field("Sales Ticket No."; Rec."Sales Ticket No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                    }
                    field("Salgspris+Rabat"; Salgspris + Rabat)
                    {
                        ApplicationArea = All;
                        Caption = 'Amount';
                        ToolTip = 'Specifies the value of the Amount field';
                    }
                    field(Rabat; Rabat)
                    {
                        ApplicationArea = All;
                        Caption = 'Rabat';
                        ToolTip = 'Specifies the value of the Rabat field';
                    }
                    field(Salgspris; Salgspris)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax Liability';
                        ToolTip = 'Specifies the value of the Tax Liability field';
                    }
                    field("<Control61506231>"; Netto)
                    {
                        ApplicationArea = All;
                        Caption = 'Net Price';
                        ToolTip = 'Specifies the value of the Net Price field';
                    }
                    field(CalcKostpris; CalcKostpris)
                    {
                        ApplicationArea = All;
                        Caption = 'Cost';
                        ToolTip = 'Specifies the value of the Cost field';
                    }
                    field(DB; DB)
                    {
                        ApplicationArea = All;
                        Caption = 'Margin';
                        ToolTip = 'Specifies the value of the Margin field';
                    }
                    field(DG; DG)
                    {
                        ApplicationArea = All;
                        Caption = 'Coverage';
                        ToolTip = 'Specifies the value of the Coverage field';
                    }
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Date", "Sale Type");
        Rec.CalcSums("Amount Including VAT", Cost, "Line Discount Amount", Amount);
        Salgspris := Rec."Amount Including VAT";
        CalcKostpris := Round(Rec.Cost, 0.01, '=');
        Rabat := Rec."Line Discount Amount";
        Netto := Rec.Amount;
        DB := Netto - CalcKostpris;
        if Netto <> 0 then
            DG := DB * 100 / Netto else
            DG := 0;
    end;

    var
        DG: Decimal;
        DB: Decimal;
        CalcKostpris: Decimal;
        Netto: Decimal;
        Salgspris: Decimal;
        Rabat: Decimal;
}


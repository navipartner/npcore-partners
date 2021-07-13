page 6150901 "NPR HC Audit Roll Stats"
{
    Caption = 'HC Audit Roll Statistics';
    Editable = false;
    PageType = Worksheet;
    UsageCategory = Administration;

    SourceTable = "NPR HC Audit Roll";
    ApplicationArea = NPRRetail;

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

                        ToolTip = 'Specifies the value of the Cash Register No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Sales Ticket No."; Rec."Sales Ticket No.")
                    {

                        ToolTip = 'Specifies the value of the Sales Ticket No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Salgspris+Rabat"; Salgspris + Rabat)
                    {

                        Caption = 'Amount';
                        ToolTip = 'Specifies the value of the Amount field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Rabat; Rabat)
                    {

                        Caption = 'Rabat';
                        ToolTip = 'Specifies the value of the Rabat field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Salgspris; Salgspris)
                    {

                        Caption = 'Tax Liability';
                        ToolTip = 'Specifies the value of the Tax Liability field';
                        ApplicationArea = NPRRetail;
                    }
                    field("<Control61506231>"; Netto)
                    {

                        Caption = 'Net Price';
                        ToolTip = 'Specifies the value of the Net Price field';
                        ApplicationArea = NPRRetail;
                    }
                    field(CalcKostpris; CalcKostpris)
                    {

                        Caption = 'Cost';
                        ToolTip = 'Specifies the value of the Cost field';
                        ApplicationArea = NPRRetail;
                    }
                    field(DB; DB)
                    {

                        Caption = 'Margin';
                        ToolTip = 'Specifies the value of the Margin field';
                        ApplicationArea = NPRRetail;
                    }
                    field(DG; DG)
                    {

                        Caption = 'Coverage';
                        ToolTip = 'Specifies the value of the Coverage field';
                        ApplicationArea = NPRRetail;
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


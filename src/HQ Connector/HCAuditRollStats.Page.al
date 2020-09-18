page 6150901 "NPR HC Audit Roll Stats"
{
    // NPR5.37/BR  /20171027 CASE 267552 HQ Connector Created Object based on Page 6014429

    Caption = 'HC Audit Roll Statistics';
    Editable = false;
    PageType = Worksheet;
    UsageCategory = Administration;
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
                    field("Register No."; "Register No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Sales Ticket No."; "Sales Ticket No.")
                    {
                        ApplicationArea = All;
                    }
                    field("Salgspris+Rabat"; Salgspris + Rabat)
                    {
                        ApplicationArea = All;
                        Caption = 'Amount';
                    }
                    field(Rabat; Rabat)
                    {
                        ApplicationArea = All;
                        Caption = 'Rabat';
                    }
                    field(Salgspris; Salgspris)
                    {
                        ApplicationArea = All;
                        Caption = 'Tax Liability';
                    }
                    field("<Control61506231>"; Netto)
                    {
                        ApplicationArea = All;
                        Caption = 'Net Price';
                    }
                    field(CalcKostpris; CalcKostpris)
                    {
                        ApplicationArea = All;
                        Caption = 'Cost';
                    }
                    field(DB; DB)
                    {
                        ApplicationArea = All;
                        Caption = 'Margin';
                    }
                    field(DG; DG)
                    {
                        ApplicationArea = All;
                        Caption = 'Coverage';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin

        SetCurrentKey("Register No.", "Sales Ticket No.", "Sale Date", "Sale Type");
        CalcSums("Amount Including VAT", Cost, "Line Discount Amount", Amount);
        Salgspris := "Amount Including VAT";
        CalcKostpris := Round(Cost, 0.01, '=');
        Rabat := "Line Discount Amount";
        Netto := Amount;
        DB := Netto - CalcKostpris;
        if Netto <> 0 then
            DG := DB * 100 / Netto else
            DG := 0;
    end;

    var
        Revisionsrulle1: Record "NPR HC Audit Roll";
        DG: Decimal;
        DB: Decimal;
        CalcKostpris: Decimal;
        Netto: Decimal;
        Salgspris: Decimal;
        Rabat: Decimal;
        Rabatpct: Decimal;
        Text10600000: Label '<Precision,2:2><Standard Format,0>';
}


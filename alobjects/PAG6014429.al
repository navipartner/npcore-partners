page 6014429 "Audit Roll Statistics"
{
    Caption = 'Audit Roll Statistics';
    Editable = false;
    PageType = Worksheet;
    SourceTable = "Audit Roll";

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
                    field("Register No.";"Register No.")
                    {
                    }
                    field("Sales Ticket No.";"Sales Ticket No.")
                    {
                    }
                    field("Salgspris+Rabat";Salgspris+Rabat)
                    {
                        Caption = 'Amount';
                    }
                    field(Rabat;Rabat)
                    {
                        Caption = 'Rabat';
                    }
                    field(Salgspris;Salgspris)
                    {
                        Caption = 'Tax Liability';
                    }
                    field("<Control61506231>";Netto)
                    {
                        Caption = 'Net Price';
                    }
                    field(CalcKostpris;CalcKostpris)
                    {
                        Caption = 'Cost';
                    }
                    field(DB;DB)
                    {
                        Caption = 'Margin';
                    }
                    field(DG;DG)
                    {
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

        SetCurrentKey("Register No.","Sales Ticket No.","Sale Date","Sale Type");
        CalcSums("Amount Including VAT",Cost,"Line Discount Amount",Amount);
        Salgspris := "Amount Including VAT";
        CalcKostpris  := Round( Cost, 0.01, '=' );
        Rabat := "Line Discount Amount";
        Netto := Amount;
        DB := Netto - CalcKostpris ;
        if Netto <> 0 then
        DG := DB * 100 / Netto else DG := 0;
    end;

    var
        Revisionsrulle1: Record "Audit Roll";
        DG: Decimal;
        DB: Decimal;
        CalcKostpris: Decimal;
        Netto: Decimal;
        Salgspris: Decimal;
        Rabat: Decimal;
        Rabatpct: Decimal;
        Text10600000: Label '<Precision,2:2><Standard Format,0>';
}


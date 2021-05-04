codeunit 6014639 "NPR POS Normal Tax Forward"
{
    procedure UpdateSourceBeforeCalculateTax(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec.Amount := Round(Rec.Amount, Currency."Amount Rounding Precision") - Rec."Invoice Discount Amount";
    end;

    procedure CalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        POSSaleTax."Source Amount" := Rec.Amount;
        CalculateTaxLines(POSSaleTax, Rec, Currency);
        SetHeaderValues(POSSaleTax, Currency);
        UpdateSourceAfterCalculateTax(POSSaleTax, Rec, Currency);
    end;

    local procedure CalculateTaxLines(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    var
        POSSaleTaxLine: record "NPR POS Sale Tax Line";
    begin
        OnBeforeCalculateTaxLines(POSSaleTax, Rec);
        Upsert(POSSaleTaxLine, Rec, POSSaleTax, Currency);
    end;

    local procedure Upsert(var POSSaleTaxLine: record "NPR POS Sale Tax Line"; Rec: Record "NPR POS Sale Line"; POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency)
    var
        TaxType: Enum "NPR POS Tax Type";
    begin
        case Rec."VAT Calculation Type" of
            Rec."VAT Calculation Type"::"Normal VAT":
                TaxType := TaxType::"Normal Tax";
            Rec."VAT Calculation Type"::"Reverse Charge VAT":
                TaxType := TaxType::"Reverse Tax";
        end;
        if not POSSaleTaxLine.FindLine(POSSaleTax, TaxType, false) then begin
            POSSaleTaxLine.Init();
            POSSaleTaxLine.CopyFromHeader(POSSaleTax);

            OnBeforeCalculateActiveTaxAmountLine(POSSaleTaxLine, Rec, POSSaleTax, Currency, TaxType);

            POSSaleTaxLine."Amount Excl. Tax" := POSSaleTaxLine."Unit Price Excl. Tax" * POSSaleTaxLine.Quantity - POSSaleTaxLine."Discount Amount" - POSSaleTaxLine."Invoice Disc. Amount";
            POSSaleTaxLine."Line Amount" := POSSaleTaxLine."Unit Price Excl. Tax" * POSSaleTaxLine.Quantity - POSSaleTaxLine."Discount Amount";
            POSSaleTaxLine."Amount Incl. Tax" := POSSaleTaxLine."Amount Excl. Tax" * (1 + POSSaleTaxLine."Tax %" / 100);
            POSSaleTaxLine."Tax Amount" := POSSaleTaxLine."Amount Incl. Tax" - POSSaleTaxLine."Amount Excl. Tax";

            POSSaleTaxLine."Unit Price Incl. Tax" := POSSaleTaxLine."Unit Price Excl. Tax" * (1 + POSSaleTaxLine."Tax %" / 100);
            POSSaleTaxLine."Unit Tax" := POSSaleTaxLine."Unit Price Incl. Tax" - POSSaleTaxLine."Unit Price Excl. Tax";

            OnBeforeRoundActiveTaxAmountLine(POSSaleTaxLine, Rec, POSSaleTax, Currency, TaxType);

            POSSaleTaxLine."Amount Excl. Tax" := Round(POSSaleTaxLine."Amount Excl. Tax", Currency."Amount Rounding Precision");
            POSSaleTaxLine."Line Amount" := Round(POSSaleTaxLine."Line Amount", Currency."Amount Rounding Precision");
            POSSaleTaxLine."Amount Incl. Tax" := Round(POSSaleTaxLine."Amount Incl. Tax", Currency."Amount Rounding Precision");
            POSSaleTaxLine."Tax Amount" := POSSaleTaxLine."Amount Incl. Tax" - POSSaleTaxLine."Amount Excl. Tax";

            OnAfterRoundActiveTaxAmountLine(POSSaleTaxLine, Rec, POSSaleTax, Currency, TaxType);

            POSSaleTaxLine."Applied Line Discount" := (POSSaleTaxLine."Discount Amount" > 0) or (POSSaleTaxLine."Discount %" > 0);
            POSSaleTaxLine."Applied Invoice Discount" := POSSaleTaxLine."Invoice Disc. Amount" > 0;

            POSSaleTaxLine.Insert();
        end;
    end;

    local procedure SetHeaderValues(var POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency)
    var
        POSSaleTaxLine: record "NPR POS Sale Tax Line";
    begin
        FindSingleLine(POSSaleTax, POSSaleTaxLine);

        POSSaleTax."Calculated Price Excl. Tax" := POSSaleTaxLine."Unit Price Excl. Tax";
        POSSaleTax."Calculated Unit Tax" := POSSaleTaxLine."Unit Tax";
        POSSaleTax."Calculated Price Incl. Tax" := POSSaleTaxLine."Unit Price Incl. Tax";

        POSSaleTax."Calculated Amount Excl. Tax" := POSSaleTaxLine."Amount Excl. Tax";
        POSSaleTax."Calculated Tax Amount" := POSSaleTaxLine."Tax Amount";
        POSSaleTax."Calculated Amount Incl. Tax" := POSSaleTaxLine."Amount Incl. Tax";
        POSSaleTax."Calculated Tax %" := POSSaleTaxLine."Tax %";
        POSSaleTax."Calculated Line Amount" := POSSaleTaxLine."Line Amount";

        POSSaleTax."Calc. Applied Invoice Discount" := POSSaleTaxLine."Applied Invoice Discount";
        POSSaleTax."Calc. Applied Line Discount" := POSSaleTaxLine."Applied Line Discount";
        POSSaleTax."Calculated Discount %" := POSSaleTaxLine."Discount %";
        POSSaleTax."Calculated Discount Amount" := POSSaleTaxLine."Discount Amount";
        POSSaleTax."Calculated Inv. Disc. Amount" := POSSaleTaxLine."Invoice Disc. Amount";
    end;

    local procedure FindSingleLine(POSSaleTax: Record "NPR POS Sale Tax"; var POSSaleTaxLine: record "NPR POS Sale Tax Line")
    var
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        POSSaleTaxLine.FindFirst();
    end;

    local procedure UpdateSourceAfterCalculateTax(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec.Amount := POSSaleTax."Calculated Amount Excl. Tax";
        Rec."VAT Base Amount" := Rec.Amount;
        Rec."Amount Including VAT" := POSSaleTax."Calculated Amount Incl. Tax";
        Rec."Line Amount" := POSSaleTax."Calculated Line Amount";
        if Rec.Amount = 0 then
            Rec."Amount Including VAT" := 0;
    end;

    local procedure ApplyDiscounts(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec."Discount %" := POSSaleTax."Calculated Discount %";
        Rec."Discount Amount" := POSSaleTax."Calculated Discount Amount";
        Rec."Invoice Discount Amount" := POSSaleTax."Calculated Inv. Disc. Amount";
        Rec."Allow Line Discount" := POSSaleTax."Calc. Applied Line Discount";
        Rec."Allow Invoice Discount" := POSSaleTax."Calc. Applied Invoice Discount";

        if Rec."Discount %" <> 0 then
            Rec."Discount Amount" := Round(Rec.Amount * Rec."Discount %" / 100, Currency."Amount Rounding Precision")
        else
            if Rec."Discount Amount" <> 0 then begin
                Rec."Discount Amount" := Round(Rec."Discount Amount", Currency."Amount Rounding Precision");
                Rec."Discount %" := Round(100 - (Rec.Amount - Rec."Discount Amount") / Rec.Amount * 100, 0.0001);
            end;
        Rec.Amount := Rec.Amount - Rec."Discount Amount" - Rec."Invoice Discount Amount";
        Rec."Line Amount" := Rec."Line Amount" - Rec."Discount Amount" - Rec."Invoice Discount Amount";
        Rec."Amount Including VAT" := Rec."Amount Including VAT" - Rec."Discount Amount" - Rec."Invoice Discount Amount";
    end;

    local procedure ApplyDiscounts(var POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    begin
        if not POSSaleTaxLine."Applied Line Discount" then begin
            POSSaleTaxLine."Discount %" := 0;
            POSSaleTaxLine."Discount Amount" := 0;
        end else begin
            POSSaleTaxLine."Amount Excl. Tax" := POSSaleTaxLine."Amount Excl. Tax" - POSSaleTaxLine."Discount Amount";
            POSSaleTaxLine."Line Amount" := POSSaleTaxLine."Amount Excl. Tax";
            POSSaleTaxLine."Amount Incl. Tax" := POSSaleTaxLine."Amount Excl. Tax" * (1 + POSSaleTaxLine."Tax %" / 100);
            POSSaleTaxLine."Tax Amount" := POSSaleTaxLine."Amount Incl. Tax" - POSSaleTaxLine."Amount Excl. Tax";
            POSSaleTaxLine."Unit Price Incl. Tax" := POSSaleTaxLine."Amount Incl. Tax" / POSSaleTaxLine.Quantity;
            POSSaleTaxLine."Unit Tax" := POSSaleTaxLine."Tax Amount" / POSSaleTaxLine.Quantity;
        end;
        if not POSSaleTaxLine."Applied Invoice Discount" then begin
            POSSaleTaxLine."Invoice Disc. Amount" := 0;
        end else begin
            POSSaleTaxLine."Amount Excl. Tax" := POSSaleTaxLine."Amount Excl. Tax" - POSSaleTaxLine."Invoice Disc. Amount";
            POSSaleTaxLine."Line Amount" := POSSaleTaxLine."Amount Excl. Tax";
            POSSaleTaxLine."Amount Incl. Tax" := POSSaleTaxLine."Amount Excl. Tax" * (1 + POSSaleTaxLine."Tax %" / 100);
            POSSaleTaxLine."Tax Amount" := POSSaleTaxLine."Amount Incl. Tax" - POSSaleTaxLine."Amount Excl. Tax";
            POSSaleTaxLine."Unit Price Incl. Tax" := POSSaleTaxLine."Amount Incl. Tax" / POSSaleTaxLine.Quantity;
            POSSaleTaxLine."Unit Tax" := POSSaleTaxLine."Tax Amount" / POSSaleTaxLine.Quantity;
        end;
        if POSSaleTaxLine."Applied Invoice Discount" or POSSaleTaxLine."Applied Invoice Discount" then
            POSSaleTaxLine.Modify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateTaxLines(var POSSaleTax: record "NPR POS Sale Tax"; Rec: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateActiveTaxAmountLine(var POSSaleTaxLine: record "NPR POS Sale Tax Line"; Rec: Record "NPR POS Sale Line"; POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency; TaxType: Enum "NPR POS Tax Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRoundActiveTaxAmountLine(var POSSaleTaxLine: record "NPR POS Sale Tax Line"; Rec: Record "NPR POS Sale Line"; POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency; TaxType: Enum "NPR POS Tax Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRoundActiveTaxAmountLine(var POSSaleTaxLine: record "NPR POS Sale Tax Line"; Rec: Record "NPR POS Sale Line"; POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency; TaxType: Enum "NPR POS Tax Type")
    begin
    end;
}
codeunit 6014638 "NPR POS Normal Tax Backward"
{
    procedure UpdateSourceBeforeCalculateTax(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec."Amount Including VAT" := Round(Rec."Amount Including VAT", Currency."Amount Rounding Precision");
    end;

    procedure CalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        POSSaleTax."Source Amount" := Rec."Amount Including VAT";
        CalculateTaxLines(POSSaleTax, Rec, Currency);
        SetHeaderValues(POSSaleTax);
        UpdateSourceAfterCalculateTax(POSSaleTax, Rec);
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

            POSSaleTaxLine."Amount Incl. Tax" := POSSaleTaxLine."Unit Price Incl. Tax" * POSSaleTaxLine.Quantity - POSSaleTaxLine."Discount Amount" - POSSaleTaxLine."Invoice Disc. Amount";
            POSSaleTaxLine."Line Amount" := POSSaleTaxLine."Unit Price Incl. Tax" * POSSaleTaxLine.Quantity - POSSaleTaxLine."Discount Amount";
            POSSaleTaxLine."Amount Excl. Tax" := POSSaleTaxLine."Amount Incl. Tax" / (1 + POSSaleTaxLine."Tax %" / 100);
            POSSaleTaxLine."Tax Amount" := POSSaleTaxLine."Amount Incl. Tax" - POSSaleTaxLine."Amount Excl. Tax";

            POSSaleTaxLine."Unit Price Excl. Tax" := POSSaleTaxLine."Unit Price Incl. Tax" / (1 + POSSaleTaxLine."Tax %" / 100);
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

    local procedure SetHeaderValues(var POSSaleTax: Record "NPR POS Sale Tax")
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

        POSSaleTax."Calc. Applied Line Discount" := POSSaleTaxLine."Applied Line Discount";
        POSSaleTax."Calculated Discount %" := POSSaleTaxLine."Discount %";
        POSSaleTax."Calculated Discount Amount" := POSSaleTaxLine."Discount Amount";
    end;

    local procedure FindSingleLine(POSSaleTax: Record "NPR POS Sale Tax"; var POSSaleTaxLine: record "NPR POS Sale Tax Line")
    var
        POSActiveTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSActiveTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        POSSaleTaxLine.FindFirst();
    end;

    local procedure UpdateSourceAfterCalculateTax(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line")
    begin
        Rec."Amount Including VAT" := POSSaleTax."Calculated Amount Incl. Tax";
        Rec.Amount := POSSaleTax."Calculated Amount Excl. Tax";
        Rec."Line Amount" := POSSaleTax."Calculated Line Amount";
        if Rec."Amount Including VAT" = 0 then
            Rec.Amount := 0;
        Rec."VAT Base Amount" := Rec.Amount;
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
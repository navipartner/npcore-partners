codeunit 6014654 "NPR External POS Tax Calc"
{
    Access = Internal;
    procedure PostExternalPOSSalesLineTaxAmount(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; ExtPOSSaleLine: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry")
    var
    begin
        InitPostTaxCalculation(POSEntryTaxLine, ExtPOSSaleLine, POSEntry);
        PostTaxCalculationAmounts(POSEntryTaxLine, ExtPOSSaleLine);
    end;

    local procedure InitPostTaxCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; ExtPOSSaleLine: Record "NPR External POS Sale Line"; POSEntry: Record "NPR POS Entry")
    begin
        POSEntryTaxLine."POS Entry No." := POSEntry."Entry No.";
        POSEntryTaxLine."VAT Identifier" := ExtPOSSaleLine."VAT Identifier";
        POSEntryTaxLine."Tax %" := ExtPOSSaleLine."VAT %";
        case ExtPOSSaleLine."VAT Calculation Type" of
            ExtPOSSaleLine."VAT Calculation Type"::"Normal VAT":
                POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Use Tax Only";
            ExtPOSSaleLine."VAT Calculation Type"::"Reverse Charge VAT":
                POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Use Tax Only";
        end;
        POSEntryTaxLine.Positive := ExtPOSSaleLine.Amount > 0;
        if not POSEntryTaxLine.Find() then begin
            POSEntryTaxLine.Init();

            POSEntryTaxLine."Tax Calculation Type" := ExtPOSSaleLine."VAT Calculation Type";

            POSEntryTaxLine.Insert(true);
        end;
    end;

    local procedure PostTaxCalculationAmounts(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; ExtPOSSaleLine: Record "NPR External POS Sale Line")
    var
        Currency: Record Currency;
    begin
        GetCurrency(Currency, ExtPOSSaleLine."Currency Code");

        POSEntryTaxLine.Quantity += ExtPOSSaleLine.Quantity;
        POSEntryTaxLine."Tax Base Amount" += ExtPOSSaleLine."VAT Base Amount";
        POSEntryTaxLine."Tax Base Amount FCY" += ExtPOSSaleLine."VAT Base Amount";
        POSEntryTaxLine."Line Amount" += ExtPOSSaleLine.Amount;
        POSEntryTaxLine."Amount Including Tax" += ExtPOSSaleLine."Amount Including VAT";

        POSEntryTaxLine."Tax Amount" += Round(ExtPOSSaleLine."Amount Including VAT", Currency."Amount Rounding Precision") -
            Round(ExtPOSSaleLine.Amount, Currency."Amount Rounding Precision");
        POSEntryTaxLine."Calculated Tax Amount" += Round(ExtPOSSaleLine."Amount Including VAT", Currency."Amount Rounding Precision") -
            Round(ExtPOSSaleLine.Amount, Currency."Amount Rounding Precision");

        POSEntryTaxLine.Modify();
    end;

    procedure GetCurrency(var Currency: Record Currency; CurrencyCode: Code[10])
    begin
        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else
            Currency.InitRoundingPrecision();
    end;
}

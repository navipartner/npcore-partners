codeunit 6184989 "NPR No Taxable VAT" implements "NPR POS ITaxCalc"
{
    Access = Internal;
    internal procedure CalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeRate: Decimal)
    begin
    end;

    internal procedure Show(SourceRecSysId: Guid)
    begin

    end;

    internal procedure UpdateTaxSetup(var Rec: Record "NPR POS Sale Line"; VATPostingSetup: Record "VAT Posting Setup")
    begin

    end;

    internal procedure SkipTaxCalculation(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency): Boolean
    begin
        if Rec."Price Includes VAT" then begin
            UpdateSourceBeforeCalculateTaxBackward(Rec, Currency);
        end else begin
            UpdateSourceBeforeCalculateTaxForward(Rec, Currency);
        end;
        exit(true);
    end;

    internal procedure PostTaxCalculationAmounts(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin

    end;

    internal procedure InitPostTaxCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSEntryNo: Integer; POSSaleTax: Record "NPR POS Sale Tax")
    begin

    end;

    internal procedure PostPOSTaxAmountCalculation(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax")
    begin

    end;

    internal procedure PostPOSTaxAmountCalculationReverseSign(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax")
    begin

    end;

    internal procedure UpdateSourceBeforeCalculateTaxBackward(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec."Amount Including VAT" := Round(Rec."Amount Including VAT", Currency."Amount Rounding Precision");
        Rec.Amount := Rec."Amount Including VAT";
        Rec."VAT Base Amount" := Rec.Amount;
    end;

    internal procedure UpdateSourceBeforeCalculateTaxForward(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec.Amount := Round(Rec.Amount, Currency."Amount Rounding Precision");
        Rec."VAT Base Amount" := Rec.Amount;
        Rec."Amount Including VAT" := Rec.Amount;
    end;

}
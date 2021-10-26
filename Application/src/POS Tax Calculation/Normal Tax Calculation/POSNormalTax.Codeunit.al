codeunit 6014636 "NPR POS Normal Tax" implements "NPR POS ITaxCalc"
{
    procedure Show(SourceRecSysId: Guid)
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        PageMgt: Codeunit "Page Management";
    begin
        POSSaleTax.SetRange("Source Rec. System Id", SourceRecSysId);
        PageMgt.PageRun(POSSaleTax);
    end;

    procedure CalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeFactor: Decimal)
    var
        POSNormalTaxForward: Codeunit "NPR POS Normal Tax Forward";
        POSNormalTaxBackward: Codeunit "NPR POS Normal Tax Backward";
    begin

        if POSSaleTax."Source Prices Including Tax" then begin
            POSNormalTaxBackward.CalculateTax(POSSaleTax, Rec, Currency);
        end else begin
            POSNormalTaxForward.CalculateTax(POSSaleTax, Rec, Currency);
        end;
    end;

    procedure UpdateTaxSetup(var Rec: Record "NPR POS Sale Line"; VATPostingSetup: Record "VAT Posting Setup")
    begin
        case Rec."VAT Calculation Type" of
            Rec."VAT Calculation Type"::"Normal VAT":
                Rec."VAT %" := VATPostingSetup."VAT %";
            Rec."VAT Calculation Type"::"Reverse Charge VAT":
                if (Rec.Type = Rec.Type::"G/L Entry") and (Rec."Gen. Posting Type" = Rec."Gen. Posting Type"::Purchase) then
                    Rec."VAT %" := VATPostingSetup."VAT %"
                else
                    Rec."VAT %" := 0;
        end;
    end;

    procedure SkipTaxCalculation(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency): Boolean
    var
        POSNormalTaxForward: Codeunit "NPR POS Normal Tax Forward";
        POSNormalTaxBackward: Codeunit "NPR POS Normal Tax Backward";
    begin
        if Rec."Price Includes VAT" then begin
            POSNormalTaxBackward.UpdateSourceBeforeCalculateTax(Rec, Currency);
        end else begin
            POSNormalTaxForward.UpdateSourceBeforeCalculateTax(Rec, Currency);
        end;
        exit((Rec.Quantity = 0) or (Rec."Unit Price" = 0));
    end;

    procedure PostPOSTaxAmountCalculation(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax")
    var
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        if POSSaleTaxLine.FindSet() then begin
            repeat
                InitPostTaxCalculation(POSEntryTaxLine, POSSaleTaxLine, EntryNo, POSSaleTax);
                PostTaxCalculationAmounts(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax);
            until POSSaleTaxLine.Next() = 0;
        end;
    end;

    procedure PostPOSTaxAmountCalculationReverseSign(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax")
    var
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
        Sign: Integer;
    begin
        POSEntrySalesLine.GetBySystemId(SystemId);
        Sign := 1;
        if POSEntrySalesLine."Amount Incl. VAT" <> 0 then
            Sign := POSEntrySalesLine."Amount Incl. VAT" / Abs(POSEntrySalesLine."Amount Incl. VAT");

        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        if POSSaleTaxLine.FindSet() then begin
            repeat
                InitPostTaxCalculation(POSEntryTaxLine, POSSaleTaxLine, EntryNo, POSSaleTax);
                PostTaxCalculationAmountsReverseSign(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax, Sign);
            until POSSaleTaxLine.Next() = 0;
        end;
    end;

    procedure PostTaxCalculationAmounts(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        POSEntryTaxLine.Quantity += POSSaleTax."Source Quantity";
        POSEntryTaxLine."Tax Base Amount" += POSSaleTax."Calculated Amount Excl. Tax";
        POSEntryTaxLine."Tax Base Amount FCY" += POSSaleTax."Calculated Amount Excl. Tax";
        POSEntryTaxLine."Line Amount" += POSSaleTax."Calculated Line Amount";
        POSEntryTaxLine."Amount Including Tax" += POSSaleTax."Calculated Amount Incl. Tax";
        POSEntryTaxLine."Tax Amount" += POSSaleTaxLine."Tax Amount";
        POSEntryTaxLine."Calculated Tax Amount" += POSSaleTaxLine."Tax Amount";

        POSEntryTaxLine.Modify();
    end;

    procedure PostTaxCalculationAmountsReverseSign(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax"; Sign: Integer)
    begin
        POSEntryTaxLine.Quantity += Sign * ABS(POSSaleTax."Source Quantity");
        POSEntryTaxLine."Tax Base Amount" += Sign * ABS(POSSaleTax."Calculated Amount Excl. Tax");
        POSEntryTaxLine."Tax Base Amount FCY" += Sign * ABS(POSSaleTax."Calculated Amount Excl. Tax");
        POSEntryTaxLine."Line Amount" += Sign * ABS(POSSaleTax."Calculated Line Amount");
        POSEntryTaxLine."Amount Including Tax" += Sign * ABS(POSSaleTax."Calculated Amount Incl. Tax");
        POSEntryTaxLine."Tax Amount" += Sign * ABS(POSSaleTaxLine."Tax Amount");
        POSEntryTaxLine."Calculated Tax Amount" += Sign * ABS(POSSaleTaxLine."Tax Amount");

        POSEntryTaxLine.Modify();
    end;

    procedure InitPostTaxCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSEntryNo: Integer; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        POSEntryTaxLine."POS Entry No." := POSEntryNo;
        POSEntryTaxLine."VAT Identifier" := POSSaleTaxLine."Tax Identifier";
        POSEntryTaxLine."Tax %" := POSSaleTaxLine."Tax %";
        case POSSaleTaxLine."Tax Type" of
            POSSaleTaxLine."Tax Type"::"Normal Tax":
                POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Use Tax Only";
            POSSaleTaxLine."Tax Type"::"Reverse Tax":
                POSEntryTaxLine."Tax Type" := POSEntryTaxLine."Tax Type"::"Use Tax Only";
        end;
        POSEntryTaxLine.Positive := POSSaleTaxLine.Positive;
        if not POSEntryTaxLine.Find() then begin
            POSEntryTaxLine.Init();

            POSEntryTaxLine."Tax Calculation Type" := POSSaleTaxLine."Tax Calculation Type";

            OnAfterInitPOSPostedTaxAmtLine(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax);

            POSEntryTaxLine.Insert(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitPOSPostedTaxAmtLine(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
    end;
}
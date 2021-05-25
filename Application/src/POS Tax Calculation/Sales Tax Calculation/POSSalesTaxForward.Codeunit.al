codeunit 6014632 "NPR POS Sales Tax Forward"
{
    var
        CalcOrderViolationTaxOnTaxErr: Label '%1 in %2 %3 must be filled in with unique values when %4 is %5.', Comment = '%1=TaxAreaLine.FieldCaption("Calculation Order");%2=TaxArea.TableCaption();%3=TaxAreaLine."Tax Area";%4=TaxDetail.FieldCaption("Calculate Tax on Tax");%5=CalculationOrderViolation';

    procedure UpdateSourceBeforeCalculateTax(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec.Amount := Round(Rec.Amount, Currency."Amount Rounding Precision");
        Rec."VAT Base Amount" := Rec.Amount;
        Rec."Amount Including VAT" := Rec.Amount;
    end;

    procedure CalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeFactor: Decimal)
    begin
        POSSaleTax."Source Amount" := Rec.Amount;
        CalculateTaxLines(POSSaleTax, Rec, Currency, ExchangeFactor);
        SetHeaderValues(POSSaleTax);
        UpdateSourceAfterCalculateTax(POSSaleTax, Rec);
    end;

    local procedure CalculateTaxLines(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeFactor: Decimal)
    begin
        if Rec."Tax Liable" then
            CalculateTaxLinesTaxLiable(POSSaleTax, Currency, ExchangeFactor)
        else
            CalculateTaxLinesTaxUnliable(POSSaleTax, Currency, ExchangeFactor);
    end;

    local procedure CalculateTaxLinesTaxUnliable(var POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency; ExchangeFactor: Decimal)
    var
        POSSaleTaxLine: record "NPR POS Sale Tax Line";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        CalculatedUnit: Decimal;
    begin
        Upsert(POSSaleTaxLine, POSSaleTax, TaxAreaLine, TaxDetail, CalculatedUnit, ExchangeFactor, Currency);
    end;

    local procedure CalculateTaxLinesTaxLiable(var POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency; ExchangeFactor: Decimal)
    var
        POSSaleTaxLine: record "NPR POS Sale Tax Line";
        xPOSSaleTaxLine: record "NPR POS Sale Tax Line";
        TaxAreaLine: Record "Tax Area Line";
        TaxDetail: Record "Tax Detail";
        TaxArea: Record "Tax Area";
        CalculatedUnit: Decimal;
        LastCalculationOrder: Integer;
        CalculationOrderViolation: Boolean;
    begin
        FilterTaxAreaLine(TaxAreaLine, POSSaleTax);

        if TaxAreaLine.Find('+') then begin
            LastCalculationOrder := TaxAreaLine."Calculation Order" + 1;

            CalculationOrderViolation := false;
            repeat
                SetLastCalculationOrder(LastCalculationOrder, CalculationOrderViolation, TaxAreaLine);
                if FindLastSalesTaxDetails(TaxDetail, TaxAreaLine, POSSaleTax."Source Posting Date") then begin
                    if TaxDetail."Calculate Tax on Tax" and CalculationOrderViolation then
                        Error(
                            CalcOrderViolationTaxOnTaxErr,
                            TaxAreaLine.FieldCaption("Calculation Order"), TaxArea.TableCaption(), TaxAreaLine."Tax Area",
                            TaxDetail.FieldCaption("Calculate Tax on Tax"), CalculationOrderViolation);

                    CalcUnitForSalesTaxDetails(TaxDetail, POSSaleTax, xPOSSaleTaxLine, CalculatedUnit);
                    Upsert(POSSaleTaxLine, POSSaleTax, TaxAreaLine, TaxDetail, CalculatedUnit, ExchangeFactor, Currency);

                    xPOSSaleTaxLine := POSSaleTaxLine;
                end;
                if FindLastExciseTaxDetails(TaxDetail, TaxAreaLine, POSSaleTax."Source Posting Date") then begin
                    CalcUnitForExciseTaxDetails(TaxDetail, POSSaleTax, CalculatedUnit);
                    Upsert(POSSaleTaxLine, POSSaleTax, TaxAreaLine, TaxDetail, CalculatedUnit, ExchangeFactor, Currency);
                end;
            until TaxAreaLine.Next(-1) = 0;
        end;
    end;

    procedure FilterTaxAreaLine(var TaxAreaLine: Record "Tax Area Line"; POSSaleTax: Record "NPR POS Sale Tax")
    begin
        TaxAreaLine.Reset();
        TaxAreaLine.SetCurrentKey("Tax Area", "Calculation Order");
        TaxAreaLine.SetRange("Tax Area", POSSaleTax."Source Tax Area Code");

        OnFilterTaxAreaLine(POSSaleTax, TaxAreaLine);
    end;

    local procedure Upsert(var POSSaleTaxLine: record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax"; TaxAreaLine: Record "Tax Area Line"; TaxDetail: Record "Tax Detail"; CalculatedUnit: Decimal; ExchangeFactor: Decimal; Currency: Record Currency)
    begin
        if not POSSaleTaxLine.FindLine(POSSaleTax, TaxAreaLine, TaxDetail) then begin
            POSSaleTaxLine.Init();
            POSSaleTaxLine.CopyFromHeader(POSSaleTax);
            CopyFromTaxArea(POSSaleTaxLine);

            OnBeforeCalculateActiveTaxAmountLine(POSSaleTaxLine, POSSaleTax, Currency);

            POSSaleTaxLine."Calculation Order" := TaxAreaLine."Calculation Order";
            POSSaleTaxLine."Calculate Tax on Tax" := TaxDetail."Calculate Tax on Tax";

            POSSaleTaxLine."Applied Line Discount" := (POSSaleTaxLine."Discount Amount" > 0) or (POSSaleTaxLine."Discount %" > 0);
            POSSaleTaxLine."Applied Invoice Discount" := POSSaleTaxLine."Invoice Disc. Amount" > 0;

            POSSaleTaxLine."Unit Tax" := CalculatedUnit / ExchangeFactor;
            POSSaleTaxLine."Unit Price Incl. Tax" := POSSaleTaxLine."Unit Price Excl. Tax" + POSSaleTaxLine."Unit Tax";
            POSSaleTaxLine."Tax %" := 100 * (POSSaleTaxLine."Unit Price Incl. Tax" - POSSaleTaxLine."Unit Price Excl. Tax") / POSSaleTaxLine."Unit Price Excl. Tax";

            POSSaleTaxLine."Amount Excl. Tax" := POSSaleTaxLine."Unit Price Excl. Tax" * POSSaleTaxLine.Quantity - POSSaleTaxLine."Discount Amount";
            POSSaleTaxLine."Line Amount" := POSSaleTaxLine."Unit Price Excl. Tax" * POSSaleTaxLine.Quantity - POSSaleTaxLine."Discount Amount";
            POSSaleTaxLine."Tax Amount" := POSSaleTaxLine."Unit Tax" * POSSaleTaxLine.Quantity;
            POSSaleTaxLine."Amount Incl. Tax" := POSSaleTaxLine."Amount Excl. Tax" + POSSaleTaxLine."Tax Amount";

            OnBeforeRoundActiveTaxAmountLine(POSSaleTaxLine, POSSaleTax, Currency);

            POSSaleTaxLine."Amount Excl. Tax" := Round(POSSaleTaxLine."Amount Excl. Tax", Currency."Amount Rounding Precision");
            POSSaleTaxLine."Line Amount" := Round(POSSaleTaxLine."Line Amount", Currency."Amount Rounding Precision");
            POSSaleTaxLine."Amount Incl. Tax" := Round(POSSaleTaxLine."Amount Incl. Tax", Currency."Amount Rounding Precision");
            POSSaleTaxLine."Tax Amount" := Round(POSSaleTaxLine."Tax Amount", Currency."Amount Rounding Precision");

            OnAfterRoundActiveTaxAmountLine(POSSaleTaxLine, POSSaleTax, Currency);

            POSSaleTaxLine.Insert();
        end;
    end;

    local procedure SetLastCalculationOrder(var LastCalculationOrder: Integer; var CalculationOrderViolation: Boolean; TaxAreaLine: Record "Tax Area Line")
    begin
        if TaxAreaLine."Calculation Order" >= LastCalculationOrder then
            CalculationOrderViolation := true
        else
            LastCalculationOrder := TaxAreaLine."Calculation Order";
    end;

    local procedure FindLastSalesTaxDetails(var TaxDetail: Record "Tax Detail"; TaxAreaLine: Record "Tax Area Line"; PostingDate: Date): Boolean
    begin
        FilterSalesTaxDetails(TaxDetail, TaxAreaLine, PostingDate);
        exit(TaxDetail.FindLast());
    end;

    local procedure FilterSalesTaxDetails(var TaxDetail: Record "Tax Detail"; TaxAreaLine: Record "Tax Area Line"; PostingDate: Date): Boolean
    begin
        TaxDetail.Reset();
        TaxDetail.SetRange("Tax Jurisdiction Code", TaxAreaLine."Tax Jurisdiction Code");
        if PostingDate = 0D then
            TaxDetail.SetFilter("Effective Date", '<=%1', WorkDate())
        else
            TaxDetail.SetFilter("Effective Date", '<=%1', PostingDate);
        TaxDetail.SetRange("Tax Type", 0); //"Sales Tax" for W1; "Sales and Use Tax" for US

        OnFilterSetSalesTaxDetails(TaxDetail, TaxAreaLine);
    end;

    procedure FilterSalesTaxDetails(var TaxDetail: Record "Tax Detail"; TaxAreaLine: Record "Tax Area Line"; TaxJurisdictionFilter: Text; EffectiveDate: Date): Boolean
    begin
        TaxDetail.Reset();
        TaxDetail.SetFilter("Tax Jurisdiction Code", TaxJurisdictionFilter);
        TaxDetail.SetFilter("Effective Date", '<=%1', EffectiveDate);
        TaxDetail.SetRange("Tax Type", 0); //"Sales Tax" for W1; "Sales and Use Tax" for US

        OnFilterSetSalesTaxDetails(TaxDetail, TaxAreaLine);
    end;

    local procedure CalcUnitForSalesTaxDetails(TaxDetail: Record "Tax Detail"; POSSaleTax: Record "NPR POS Sale Tax"; var xPOSSaleTaxLineTaxOnTax: Record "NPR POS Sale Tax Line"; var CalculatedUnit: Decimal)
    var
        TaxBaseUnitPrice: Decimal;
        MaxUnitPrice: Decimal;
    begin
        CalculatedUnit := 0;

        if TaxDetail."Calculate Tax on Tax" then
            TaxBaseUnitPrice := POSSaleTax."Source Line Amount" / POSSaleTax."Source Quantity" + xPOSSaleTaxLineTaxOnTax."Unit Price Incl. Tax"
        else
            TaxBaseUnitPrice := POSSaleTax."Source Line Amount" / POSSaleTax."Source Quantity";
        if (Abs(TaxBaseUnitPrice) <= (TaxDetail."Maximum Amount/Qty." / POSSaleTax."Source Quantity")) or (TaxDetail."Maximum Amount/Qty." = 0) then begin
            CalculatedUnit := TaxBaseUnitPrice * TaxDetail."Tax Below Maximum" / 100
        end else begin
            MaxUnitPrice := TaxBaseUnitPrice / Abs(TaxBaseUnitPrice) * (TaxDetail."Maximum Amount/Qty." / POSSaleTax."Source Quantity");
            CalculatedUnit := ((MaxUnitPrice * TaxDetail."Tax Below Maximum") + ((TaxBaseUnitPrice - MaxUnitPrice) * TaxDetail."Tax Above Maximum")) / 100;
        end;

        OnAfterCalcUnitForSalesTaxDetails(TaxDetail, POSSaleTax, xPOSSaleTaxLineTaxOnTax, CalculatedUnit);
    end;

    local procedure FindLastExciseTaxDetails(var TaxDetail: Record "Tax Detail"; TaxAreaLine: Record "Tax Area Line"; PostingDate: Date): Boolean
    begin
        FilterExciseTaxDetails(TaxDetail, TaxAreaLine, PostingDate);
        exit(TaxDetail.FindLast());
    end;

    local procedure FilterExciseTaxDetails(var TaxDetail: Record "Tax Detail"; TaxAreaLine: Record "Tax Area Line"; PostingDate: Date)
    begin
        TaxDetail.Reset();
        TaxDetail.SetRange("Tax Jurisdiction Code", TaxAreaLine."Tax Jurisdiction Code");
        if PostingDate = 0D then
            TaxDetail.SetFilter("Effective Date", '<=%1', WorkDate())
        else
            TaxDetail.SetFilter("Effective Date", '<=%1', PostingDate);
        TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Excise Tax");

        OnFilterSetExciseTaxDetails(TaxDetail, TaxAreaLine);
    end;

    procedure FilterExciseTaxDetails(var TaxDetail: Record "Tax Detail"; TaxAreaLine: Record "Tax Area Line"; TaxJurisdictionFilter: Text; EffectiveDate: Date)
    begin
        TaxDetail.Reset();
        TaxDetail.SetFilter("Tax Jurisdiction Code", TaxJurisdictionFilter);
        TaxDetail.SetFilter("Effective Date", '<=%1', EffectiveDate);
        TaxDetail.SetRange("Tax Type", TaxDetail."Tax Type"::"Excise Tax");

        OnFilterSetExciseTaxDetails(TaxDetail, TaxAreaLine);
    end;

    local procedure CalcUnitForExciseTaxDetails(TaxDetail: Record "Tax Detail"; POSSaleTax: Record "NPR POS Sale Tax"; var CalculatedUnit: Decimal)
    var
        MaxUnitPrice: Decimal;
    begin
        CalculatedUnit := 0;
        if (Abs(POSSaleTax."Source Quantity") <= TaxDetail."Maximum Amount/Qty.") or (TaxDetail."Maximum Amount/Qty." = 0) then begin
            CalculatedUnit := TaxDetail."Tax Below Maximum"
        end else begin
            MaxUnitPrice := POSSaleTax."Source Quantity" / Abs(POSSaleTax."Source Quantity") * TaxDetail."Maximum Amount/Qty.";
            CalculatedUnit := (MaxUnitPrice * TaxDetail."Tax Below Maximum") + ((POSSaleTax."Source Quantity" - MaxUnitPrice) / POSSaleTax."Source Quantity" * TaxDetail."Tax Above Maximum");
        end;

        OnAfterCalcUnitForExciseTaxDetails(TaxDetail, POSSaleTax, CalculatedUnit);

    end;

    local procedure CopyFromTaxArea(var POSSaleTaxLine: record "NPR POS Sale Tax Line")
    var
        TaxArea: Record "Tax Area";
        TaxJurisdiction: Record "Tax Jurisdiction";
        DataTypeMgt: Codeunit "Data Type Management";
        RecRef: RecordRef;
        FieldReference: FieldRef;
    begin
        case POSSaleTaxLine."Tax Group Type" of
            POSSaleTaxLine."Tax Group Type"::"Tax Area":
                begin
                    TaxArea.Get(POSSaleTaxLine."Tax Area Code");

                    DataTypeMgt.GetRecordRef(TaxArea, RecRef);
                    if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Round Tax') then begin
                        evaluate(POSSaleTaxLine."Round Tax", Format(FieldReference.Value()));
                    end;
                    POSSaleTaxLine."Is Report-to Jurisdiction" := (POSSaleTaxLine."Tax Jurisdiction Code" = TaxJurisdiction."Report-to Jurisdiction");
                    POSSaleTaxLine."Print Order" := 0;
                    POSSaleTaxLine."Print Description" := TaxArea.Description;
                end;
            POSSaleTaxLine."Tax Group Type"::"Tax Jurisdiction":
                begin
                    TaxJurisdiction.Get(POSSaleTaxLine."Tax Jurisdiction Code");

                    DataTypeMgt.GetRecordRef(TaxJurisdiction, RecRef);
                    if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Print Order') then begin
                        evaluate(POSSaleTaxLine."Print Order", Format(FieldReference.Value()));
                    end;
                    if DataTypeMgt.FindFieldByName(RecRef, FieldReference, 'Print Description') then begin
                        evaluate(POSSaleTaxLine."Print Description", Format(FieldReference.Value()));
                    end;
                end;
            else
                OnAfterCopyFromTaxArea(POSSaleTaxLine);
        end;
    end;

    local procedure SetHeaderValues(var POSSaleTax: Record "NPR POS Sale Tax")
    var
        POSSaleTaxLine: record "NPR POS Sale Tax Line";
    begin
        FindLines(POSSaleTax, POSSaleTaxLine);
        POSSaleTaxLine.CalcSums("Unit Tax", "Tax Amount");

        POSSaleTax."Calculated Price Excl. Tax" := POSSaleTaxLine."Unit Price Excl. Tax";
        POSSaleTax."Calculated Unit Tax" := POSSaleTaxLine."Unit Tax";
        POSSaleTax."Calculated Price Incl. Tax" := POSSaleTax."Calculated Price Excl. Tax" + POSSaleTax."Calculated Unit Tax";

        POSSaleTax."Calculated Amount Excl. Tax" := POSSaleTaxLine."Amount Excl. Tax";
        POSSaleTax."Calculated Tax Amount" := POSSaleTaxLine."Tax Amount";
        POSSaleTax."Calculated Amount Incl. Tax" := POSSaleTax."Calculated Amount Excl. Tax" + POSSaleTax."Calculated Tax Amount";
        if POSSaleTaxLine.Count() = 1 then
            POSSaleTax."Calculated Tax %" := POSSaleTaxLine."Tax %";
        POSSaleTax."Calculated Line Amount" := POSSaleTaxLine."Line Amount";

        POSSaleTax."Calc. Applied Line Discount" := POSSaleTaxLine."Applied Line Discount";
        POSSaleTax."Calculated Discount %" := POSSaleTaxLine."Discount %";
        POSSaleTax."Calculated Discount Amount" := POSSaleTaxLine."Discount Amount";
    end;

    local procedure FindLines(POSSaleTax: Record "NPR POS Sale Tax"; var POSSaleTaxLine: record "NPR POS Sale Tax Line")
    var
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.FilterLines(POSSaleTax, POSSaleTaxLine);
        POSSaleTaxLine.FindFirst();
    end;

    local procedure UpdateSourceAfterCalculateTax(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line")
    begin
        Rec.Amount := POSSaleTax."Calculated Amount Excl. Tax";
        Rec."VAT Base Amount" := Rec.Amount;
        Rec."Amount Including VAT" := POSSaleTax."Calculated Amount Incl. Tax";
        Rec."Line Amount" := POSSaleTax."Calculated Line Amount";
        Rec."VAT %" := 0;
        if Rec.Amount = 0 then
            Rec."Amount Including VAT" := 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFilterTaxAreaLine(POSSaleTax: record "NPR POS Sale Tax"; var TaxAreaLine: Record "Tax Area Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnFilterSetSalesTaxDetails(var TaxDetail: record "Tax Detail"; TaxAreaLine: Record "Tax Area Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcUnitForSalesTaxDetails(TaxDetail: Record "Tax Detail"; POSSaleTax: Record "NPR POS Sale Tax"; var xPOSSaleTaxLineTaxonTax: Record "NPR POS Sale Tax Line"; var CalculatedUnit: Decimal)
    begin
    end;


    [IntegrationEvent(false, false)]
    local procedure OnFilterSetExciseTaxDetails(var TaxDetail: record "Tax Detail"; TaxAreaLine: Record "Tax Area Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalcUnitForExciseTaxDetails(TaxDetail: Record "Tax Detail"; POSSaleTax: Record "NPR POS Sale Tax"; var CalculatedUnit: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateActiveTaxAmountLine(var POSSaleTaxLine: record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromTaxArea(var POSSaleTaxLine: record "NPR POS Sale Tax Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeRoundActiveTaxAmountLine(var POSSaleTaxLine: record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRoundActiveTaxAmountLine(var POSSaleTaxLine: record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax"; Currency: Record Currency)
    begin
    end;
}
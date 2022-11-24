﻿codeunit 6014630 "NPR POS Sale Tax Calc."
{
    var
        TaxAmountPOSRenameNotAllowedErr: Label 'You can''t rename %1', Comment = '%1=TaxAmountPOS.TableCaption()';

    internal procedure Show(SourceRecSysId: Guid)
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        POSTaxCalc: Interface "NPR POS ITaxCalc";
    begin
        if not Find(POSSaleTax, SourceRecSysId) then
            exit;
        POSSaleTax.GetHandler(POSTaxCalc);
        POSTaxCalc.Show(SourceRecSysId);
    end;

    internal procedure Delete(SourceRecSysId: Guid)
    var
        POSSaleTax: Record "NPR POS Sale Tax";
    begin
        if not IsEmpty(POSSaleTax, SourceRecSysId) then
            POSSaleTax.DeleteAll(true);
    end;

    internal procedure DeleteAllLines(POSSaleTax: Record "NPR POS Sale Tax")
    var
        POSSaleTaxLine: Record "NPR POS Sale Tax Line";
    begin
        FilterLines(POSSaleTax, POSSaleTaxLine);
        if not POSSaleTaxLine.IsEmpty() then
            POSSaleTaxLine.DeleteAll(true);
    end;

    internal procedure FilterLines(POSSaleTax: Record "NPR POS Sale Tax"; var POSSaleTaxLine: Record "NPR POS Sale Tax Line")
    begin
        POSSaleTaxLine.Reset();
        POSSaleTaxLine.SetRange("Source Rec. System Id", POSSaleTax."Source Rec. System Id");
    end;

    internal procedure RenameNotAllowed()
    var
        POSSaleTax: Record "NPR POS Sale Tax";
    begin
        Error(TaxAmountPOSRenameNotAllowedErr, POSSaleTax.TableCaption());
    end;

    internal procedure Find(var POSSaleTax: Record "NPR POS Sale Tax"; SourceRecSysId: Guid): Boolean
    begin
        POSSaleTax."Source Rec. System Id" := SourceRecSysId;
        exit(POSSaleTax.Find());
    end;

    internal procedure IsEmpty(var POSSaleTax: Record "NPR POS Sale Tax"; SourceRecSysId: Guid): Boolean
    begin
        POSSaleTax.Reset();
        POSSaleTax.SetRange("Source Rec. System Id", SourceRecSysId);
        exit(POSSaleTax.IsEmpty());
    end;

    internal procedure GetCurrency(var Currency: Record Currency; CurrencyCode: Code[10])
    begin
        if CurrencyCode <> '' then
            Currency.Get(CurrencyCode)
        else
            Currency.InitRoundingPrecision();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sale Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure DeleteTaxAmountPOSOnAfterDeleteSaleLinePOS(var Rec: Record "NPR POS Sale Line")
    begin
        DeleteTaxAmount(Rec);
    end;

    local procedure DeleteTaxAmount(Rec: Record "NPR POS Sale Line")
    var
        POSSaleTaxCalc: codeunit "NPR POS Sale Tax Calc.";
    begin
        POSSaleTaxCalc.Delete(Rec.SystemId);
    end;

    internal procedure CalculateTax(var Rec: Record "NPR POS Sale Line"; SalePOS: Record "NPR POS Sale"; CurrencyFactor: Decimal)
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        POSSaleTax2: Record "NPR POS Sale Tax";
        Currency: Record Currency;
        POSTaxCalc: Interface "NPR POS ITaxCalc";
        ExchangeRate: Decimal;
    begin
        DeleteTaxAmount(Rec);
        if Rec."Price Includes VAT" then begin
            UpdateSourceBeforeCalculateTaxBackward(Rec, Currency);
        end else begin
            UpdateSourceBeforeCalculateTaxForward(Rec, Currency);
        end;

        POSSaleTax2.SetTaxCalcTypeFromSource(Rec);
        POSSaleTax2.GetHandler(POSTaxCalc);
        if POSTaxCalc.SkipTaxCalculation(POSSaleTax2, Rec, Currency) then
            exit;

        if IsNullGuid(Rec.SystemId) then
            exit;

        if Rec."Line Type" in [Rec."Line Type"::"POS Payment", Rec."Line Type"::Comment, Rec."Line Type"::Rounding] then
            exit;

        if CurrencyFactor = 0 then
            ExchangeRate := 1
        else
            ExchangeRate := CurrencyFactor;

        GetCurrency(Currency, Rec."Currency Code");

        if not Find(POSSaleTax, Rec.SystemId) then begin
            POSSaleTax.Init();
            POSSaleTax.CopyFromSource(Rec);
            POSSaleTax."Source Currency Factor" := CurrencyFactor;
            POSSaleTax."Source Tax Calc. Type" := POSSaleTax2."Source Tax Calc. Type";
        end;

        POSSaleTax.CopyFromSourceAmounts(Rec);

        POSSaleTax.GetHandler(POSTaxCalc);
        POSTaxCalc.CalculateTax(POSSaleTax, Rec, Currency, ExchangeRate);
        POSSaleTax.Insert(true);
        Rec.Modify();
    end;

    internal procedure UpdateSourceBeforeCalculateTaxForward(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec.Amount := Rec.Quantity * Rec."Unit Price";
        if Rec."Discount %" <> 0 then
            Rec."Discount Amount" := Round(Rec.Amount * Rec."Discount %" / 100, Currency."Amount Rounding Precision")
        else
            if Rec."Discount Amount" <> 0 then begin
                Rec."Discount Amount" := Round(Rec."Discount Amount", Currency."Amount Rounding Precision");
                Rec."Discount %" := Round(100 - (Rec.Amount - Rec."Discount Amount") / Rec.Amount * 100, 0.0001);
            end;
        Rec.Amount := Round(Rec.Amount - Rec."Discount Amount", Currency."Amount Rounding Precision");
        Rec."Line Amount" := Round(Rec.Quantity * Rec."Unit Price" - Rec."Discount Amount", Currency."Amount Rounding Precision");
    end;

    internal procedure UpdateSourceBeforeCalculateTaxBackward(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
        Rec."Amount Including VAT" := Rec.Quantity * Rec."Unit Price";
        if Rec."Discount %" <> 0 then
            Rec."Discount Amount" := Round(Rec."Amount Including VAT" * Rec."Discount %" / 100, Currency."Amount Rounding Precision")
        else
            if Rec."Discount Amount" <> 0 then begin
                Rec."Discount Amount" := Round(Rec."Discount Amount", Currency."Amount Rounding Precision");
                Rec."Discount %" := Round(100 - (Rec."Amount Including VAT" - Rec."Discount Amount") / Rec."Amount Including VAT" * 100, 0.0001);
            end;
        Rec."Amount Including VAT" := Round(Rec."Amount Including VAT" - Rec."Discount Amount", Currency."Amount Rounding Precision");
        Rec."Line Amount" := Round(Rec.Quantity * Rec."Unit Price" - Rec."Discount Amount", Currency."Amount Rounding Precision");
    end;

    internal procedure UpdateSourceTaxSetup(var Rec: Record "NPR POS Sale Line"; VATPostingSetup: Record "VAT Posting Setup"; SalePOS: Record "NPR POS Sale"; CurrencyFactor: Decimal)
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        POSTaxCalc: Interface "NPR POS ITaxCalc";
    begin
        POSSaleTax.SetTaxCalcTypeFromSource(Rec);
        POSSaleTax.GetHandler(POSTaxCalc);
        POSTaxCalc.UpdateTaxSetup(Rec, VATPostingSetup);

        if not Find(POSSaleTax, Rec.SystemId) then
            exit;
        CalculateTax(Rec, SalePOS, CurrencyFactor);
    end;

    [IntegrationEvent(false, false)]
    procedure OnGetVATPostingSetup(VATPostingSetup: Record "VAT Posting Setup"; var Handled: Boolean)
    begin
    end;
}

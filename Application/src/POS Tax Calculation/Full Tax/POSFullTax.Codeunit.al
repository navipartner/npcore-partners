codeunit 6014635 "NPR POS Full Tax" implements "NPR POS ITaxCalc"
{
    var
        TaxCalcTypeNotSupportedInPOS: Label '%1 %2 not supported in POS';

    procedure CalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeFactor: Decimal)
    var
        Handled: Boolean;
    begin
        Handled := false;
        OnCalculateTax(POSSaleTax, Rec, Currency, ExchangeFactor, Handled);
        if not Handled then
            Error(TaxCalcTypeNotSupportedInPOS, POSSaleTax.FieldCaption("Source Tax Calc. Type"), POSSaleTax."Source Tax Calc. Type");
    end;

    procedure UpdateTaxSetup(var Rec: Record "NPR POS Sale Line"; VATPostingSetup: Record "VAT Posting Setup")
    var
        POSSaleTaxDummy: Record "NPR POS Sale Tax";
        Handled: Boolean;
    begin
        Handled := false;
        OnUpdateTaxSetup(Rec, VATPostingSetup, Handled);
        if not Handled then
            Error(TaxCalcTypeNotSupportedInPOS, POSSaleTaxDummy.FieldCaption("Source Tax Calc. Type"), POSSaleTaxDummy."Source Tax Calc. Type"::"Full VAT");
    end;

    procedure SkipTaxCalculation(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency): Boolean
    var
        Handled: Boolean;
    begin
        Handled := false;
        OnSkipTaxCalculation(POSSaleTax, Rec, Handled);
        if not Handled then
            Error(TaxCalcTypeNotSupportedInPOS, POSSaleTax.FieldCaption("Source Tax Calc. Type"), POSSaleTax."Source Tax Calc. Type");
        exit(Handled);
    end;

    procedure Show(SourceRecSysId: Guid)
    var
        POSSaleTax: Record "NPR POS Sale Tax";
        Handled: Boolean;
    begin
        OnShow(POSSaleTax, SourceRecSysId, Handled);
        if not Handled then
            Error(TaxCalcTypeNotSupportedInPOS, POSSaleTax.FieldCaption("Source Tax Calc. Type"), POSSaleTax."Source Tax Calc. Type");
    end;

    procedure PostTaxCalculationAmounts(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax")
    var
        Handled: Boolean;
    begin
        OnInitPostedTaxCalculationAmounts(POSEntryTaxLine, POSSaleTaxLine, POSSaleTax, Handled);
        if not Handled then
            Error(TaxCalcTypeNotSupportedInPOS, POSSaleTax.FieldCaption("Source Tax Calc. Type"), POSSaleTax."Source Tax Calc. Type");
    end;

    procedure InitPostTaxCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSEntryNo: Integer; POSSaleTax: Record "NPR POS Sale Tax")
    var
        Handled: Boolean;
    begin
        OnInitPostedTaxCalculation(POSEntryTaxLine, POSSaleTaxLine, POSEntryNo, POSSaleTax, Handled);
        if not Handled then
            Error(TaxCalcTypeNotSupportedInPOS, POSSaleTax.FieldCaption("Source Tax Calc. Type"), POSSaleTax."Source Tax Calc. Type");
    end;

    procedure PostPOSTaxAmountCalculation(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax")
    var
        Handled: Boolean;
    begin
        OnPostPOSTaxAmountCalculation(EntryNo, SystemId, POSSaleTax, Handled);
        if not Handled then
            Error(TaxCalcTypeNotSupportedInPOS, POSSaleTax.FieldCaption("Source Tax Calc. Type"), POSSaleTax."Source Tax Calc. Type"::"Full VAT");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostPOSTaxAmountCalculation(EntryNo: Integer; SystemId: Guid; POSSaleTax: Record "NPR POS Sale Tax"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitPostedTaxCalculation(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSEntryNo: Integer; POSSaleTax: Record "NPR POS Sale Tax"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInitPostedTaxCalculationAmounts(var POSEntryTaxLine: Record "NPR POS Entry Tax Line"; POSSaleTaxLine: Record "NPR POS Sale Tax Line"; POSSaleTax: Record "NPR POS Sale Tax"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeFactor: Decimal; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateTaxSetup(var Rec: Record "NPR POS Sale Line"; VAtPostingSetup: Record "VAT Posting Setup"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSkipTaxCalculation(POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShow(POSSaleTax: Record "NPR POS Sale Tax"; SourceRecSysId: Guid; var Handled: Boolean)
    begin
    end;
}
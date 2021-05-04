codeunit 6014633 "NPR POS Sales Tax Backward"
{
    var
        SalesTaxBackwardNotSupportedErr: Label 'Reverse sales tax calculation is not supported. Turn off Prices Including VAT on POS Pricing Profile for direct sale and for debit sale on the Customer card';

    procedure UpdateSourceBeforeCalculateTax(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    var
        Handled: Boolean;
    begin
        OnUpdateSourceBeforeCalculateTax(Rec, Currency);
        if Handled then
            exit;
        Error(SalesTaxBackwardNotSupportedErr);
    end;

    procedure CalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeFactor: Decimal)
    var
        Handled: Boolean;
    begin
        OnCalculateTax(POSSaleTax, Rec, Currency, ExchangeFactor, Handled);
        if Handled then
            exit;
        Error(SalesTaxBackwardNotSupportedErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateSourceBeforeCalculateTax(var Rec: Record "NPR POS Sale Line"; Currency: Record Currency)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCalculateTax(var POSSaleTax: Record "NPR POS Sale Tax"; var Rec: Record "NPR POS Sale Line"; Currency: Record Currency; ExchangeFactor: Decimal; var Handled: Boolean)
    begin
    end;
}
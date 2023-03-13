codeunit 6150822 "NPR POSAction: Set TaxLiable B"
{
    Access = Internal;

    procedure SetTaxLiable(TaxLiableValue: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Tax Liable", TaxLiableValue);
        SalePOS.Modify(true);
        POSSale.Refresh(SalePOS);
        POSSale.Modify(true, false);
    end;
}
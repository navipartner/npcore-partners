codeunit 6151073 "NPR POS Sales Price Calc.Mgt.W"
{
    var
        PriceCalcMgt: Codeunit "NPR POS Sales Price Calc. Mgt.";

    procedure InitTempPOSItemSale(var TempSaleLinePOS: Record "NPR POS Sale Line" temporary; var TempSalePOS: Record "NPR POS Sale" temporary)
    begin
        PriceCalcMgt.InitTempPOSItemSale(TempSaleLinePOS, TempSalePOS);
    end;

    procedure FindItemPrice(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        PriceCalcMgt.FindItemPrice(SalePOS, SaleLinePOS);
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterFindSalesLinePrice(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;
}
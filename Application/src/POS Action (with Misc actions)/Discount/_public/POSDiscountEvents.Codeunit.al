codeunit 6150807 "NPR POS Discount Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeSetDiscount(DiscountType: Option; var SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line"; DiscountAmount: Decimal)
    begin
    end;
}

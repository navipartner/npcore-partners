codeunit 6151249 "NPR NP Loyalty Disc. Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateSalesDiscountLine(var SalesLine: Record "Sales Line"; PaymentLine: Record "NPR Magento Payment Line")
    begin
    end;
}
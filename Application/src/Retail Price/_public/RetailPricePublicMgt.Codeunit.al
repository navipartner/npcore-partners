codeunit 6248619 "NPR Retail Price Public Mgt."
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterShouldCreateRetailPriceLogEntry(PriceListLine: Record "Price List Line"; var ShouldCreate: Boolean)
    begin
    end;
}
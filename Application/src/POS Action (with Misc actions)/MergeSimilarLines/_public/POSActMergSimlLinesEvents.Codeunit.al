codeunit 6184914 "NPR POSActMergSimlLinesEvents"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindLinesToCollapse(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeFindSimilarLinesToCollapse(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterFindLinesToCollapse(SalePOS: Record "NPR POS Sale"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCollapseSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; var CollapseSupported: Boolean)
    begin
    end;

}
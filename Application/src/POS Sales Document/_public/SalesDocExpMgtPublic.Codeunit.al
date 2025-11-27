codeunit 6060005 "NPR Sales Doc. Exp. Mgt Public"
{
    [IntegrationEvent(true, false)]
    internal procedure OnAfterDebitSalePostEvent(SalePOS: Record "NPR POS Sale"; SalesHeader: Record "Sales Header"; Posted: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure CreateSalesHeaderOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePost(var SalesHeader: Record "Sales Header"; var Post: Boolean; var AsyncPosting: Boolean)
    begin
    end;

}

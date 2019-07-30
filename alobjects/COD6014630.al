// TODO: CTRLUPGRADE - uses old Standard code; must be removed or refactored
codeunit 6014630 "Touch - Sale POS (Web)"
{
    [IntegrationEvent(false, false)]
    local procedure OnBeforeDebitSale(SalePOS: Record "Sale POS")
    begin
        //-NPR5.30 [267291]
        //+NPR5.30 [267291]
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGotoPayment(SalePOS: Record "Sale POS")
    begin
        //-NPR5.30 [267291]
        //+NPR5.30 [267291]
    end;
}

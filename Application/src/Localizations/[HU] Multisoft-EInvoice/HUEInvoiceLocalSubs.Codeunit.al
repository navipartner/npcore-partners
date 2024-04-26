codeunit 6184782 "NPR HU EInvoice Local. Subs."
{
    Access = Internal;

    var
        HUEInvoiceLocalizationMgt: Codeunit "NPR HU EInvoice Local. Mgt.";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Sales Doc. Exp. Mgt.", 'CreateSalesHeaderOnBeforeSalesHeaderModify', '', false, false)]
    local procedure SalesDocExpMgtCreateSalesHeaderOnBeforeSalesHeaderModify(var SalesHeader: Record "Sales Header"; var SalePOS: Record "NPR POS Sale")
    begin
        if not HUEInvoiceLocalizationMgt.GetLocalisationSetupEnabled() then
            exit;
        HUEInvoiceLocalizationMgt.SalesHeaderOnBeforeSalesHeaderModify(SalesHeader, SalePOS);
    end;
}
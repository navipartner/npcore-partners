codeunit 6248191 "NPR PostSalesDocEmailEvents"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetContent(SalesInvoiceHeader: Record "Sales Invoice Header"; var ContentJson: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterGenerateContentExample(var ContentJson: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddSellToInfo(var JSellTo: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddBillToInfo(var JBillTo: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddShipToInfo(var JShipTo: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddExampleSellToInfo(var JSellTo: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddExampleBillToInfo(var JBillTo: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddExampleShipToInfo(var JShipTo: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddSalesInvoiceLineJson(SalesInvoiceLine: Record "Sales Invoice Line"; var JLine: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddExampleSalesInvoiceLineJson(var JLine: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddPaymentMethodJson(MagentoPaymentLine: Record "NPR Magento Payment Line"; var JPaymentMethod: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddExamplePaymentMethodJson(var JPaymentMethod: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddSalesInvoiceHeaderJson(SalesInvoiceHeader: Record "Sales Invoice Header"; var JObject: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterAddExampleSalesInvoiceHeaderJson(var JObject: JsonObject)
    begin
    end;
}

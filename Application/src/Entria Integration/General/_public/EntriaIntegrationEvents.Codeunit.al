#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6151045 "NPR Entria Integration Events"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeEntriaOrderHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertEcommerceSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertEcommerceSalesLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeEcommerceSalesLine(SalesLineJsonToken: JsonToken; var EcomSalesLine: Record "NPR Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertEcommerceSalesPaymentLine(PaymentLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDeserializeEntriaPaymentLine(PaymentToken: JsonToken; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterReserveEntriaVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var VoucherSalesLine: Record "NPR NpRv Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertEcommerceSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; RequestBody: JsonToken);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertEcommerceSalesLine(SalesLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertEcommerceSalesPaymentLine(PaymentLineJsonToken: JsonToken; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCreateEcomDocument(StoreCode: Code[20]; DocumentNo: Code[20]; var EcomSalesHeader: Record "NPR Ecom Sales Header");
    begin
    end;
}
#endif

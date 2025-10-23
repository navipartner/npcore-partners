#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248607 "NPR EcomSalesDocImplEvents"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInitCustomer(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Customer: Record Customer)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterDecideNewCustomer(EcomSalesHeader: Record "NPR Ecom Sales Header"; var Customer: Record Customer; var NewCustomer: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeHandleCustomerUpdateMode(EcomSalesHeader: Record "NPR Ecom Sales Header"; CustomerTemplateCode: Code[20]; VATBusPostingGroupCode: Code[20]; IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup"; var Customer: Record Customer; var NewCustomer: Boolean; UpdateHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertCustomerBeforeFinalizeCustomer(EcomSalesHeader: Record "NPR Ecom Sales Header"; NewCustomer: Boolean; var Customer: Record Customer)
    begin
    end;


    [IntegrationEvent(false, false)]
    internal procedure OnAfterPopulateGeneralSalesHeaderInformation(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterIncomingSalesHeaderHasShipmentInformation(EcomSalesHeader: Record "NPR Ecom Sales Header"; var HasShipmentInformation: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesHeaderBeforeFinalizeSalesHeader(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineItemBeforeFinalizeSalesLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line");
    begin
    end;


    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineCommentBeforeFinalizeSalesLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineShipmentFeeAsCommentBeforeFinalizeComment(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesCommentLine: Record "Sales Comment Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineShipmentFeeSelectShippingFee(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line"; var ShipmentMapping: Record "NPR Magento Shipment Mapping");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineShipmentFeeBeforeFinalizeLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesLine: Record "NPR Ecom Sales Line"; var SalesLine: Record "Sales Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertPaymentLinePaymentMethodBeforeFinalizeLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; SalesHeader: Record "Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; var PaymentLine: Record "NPR Magento Payment Line");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertCommentLines(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHedaer: Record "Sales Header");
    begin
    end;


    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateExtCouponReservations(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHedaer: Record "Sales Header");
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnProcessBeforeRelease(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHedaer: Record "Sales Header");
    begin
    end;


    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertSalesDocument(EcomSalesHeader: Record "NPR Ecom Sales Header"; var SalesHeader: Record "Sales Header"; var Success: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentPostingStatusFromSalesHeaderBeforeFinalizeUpdate(SalesHeader: Record "Sales Header"; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateSalesDocumentPostingStatusFromSalesHeader(SalesHeader: Record "Sales Header"; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesInvoice(SalesInvLine: Record "Sales Invoice Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesCreditMemo(SalesCrMemoLine: Record "Sales Cr.Memo Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
    end;


    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentPaymentLinePostingInformationBeforeFinalizeRecord(PaymentLine: Record "NPR Magento Payment Line"; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcess(var EcomSalesHeader: Record "NPR Ecom Sales Header"; var Success: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentPaymentLineCaptureInformationBeforeFinalizeRecord(PaymentLine: Record "NPR Magento Payment Line"; var EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line")
    begin
    end;
}
#endif

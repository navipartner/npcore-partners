#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248449 "NPR IncEcomSalesDocImplEvents"
{
    Access = Public;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-10-26';
    ObsoleteReason = 'Replaced with NPR EcomSalesDocImplEvents';

    [Obsolete('Replaced by OnAfterInitCustomer in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterInitCustomer(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var Customer: Record Customer)
    begin
    end;

    [Obsolete('Replaced by OnAfterDecideNewCustomer in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterDecideNewCustomer(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var Customer: Record Customer; var NewCustomer: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnBeforeHandleCustomerUpdateMode in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeHandleCustomerUpdateMode(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; CustomerTemplateCode: Code[20]; VATBusPostingGroupCode: Code[20]; IncEcomSalesDocSetup: Record "NPR Inc Ecom Sales Doc Setup"; var Customer: Record Customer; var NewCustomer: Boolean; UpdateHandled: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnInsertCustomerBeforeFinalizeCustomer in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnInsertCustomerBeforeFinalizeCustomer(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; NewCustomer: Boolean; var Customer: Record Customer)
    begin
    end;

    [Obsolete('Replaced by OnAfterPopulateGeneralSalesHeaderInformation in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterPopulateGeneralSalesHeaderInformation(IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [Obsolete('Replaced by OnAfterInsertSalesHeader in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertSalesHeader(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header")
    begin
    end;

    [Obsolete('Replaced by OnAfterIncomingSalesHeaderHasShipmentInformation in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnAfterIncomingSalesHeaderHasShipmentInformation(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; var HasShipmentInformation: Boolean);
    begin
    end;

    [Obsolete('Replaced by OnInsertSalesHeaderBeforeFinalizeSalesHeader in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesHeaderBeforeFinalizeSalesHeader(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header");
    begin
    end;

    [Obsolete('Replaced by OnInsertSalesLineItemBeforeFinalizeSalesLine in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineItemBeforeFinalizeSalesLine(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLine: Record "Sales Line");
    begin
    end;

    [Obsolete('Replaced by OnInsertSalesLineCommenteforeFinalizeSalesLine in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineCommenteforeFinalizeSalesLine(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLine: Record "Sales Line");
    begin
    end;

    [Obsolete('Replaced by OnInsertSalesLineItemBeforeFinalizeSalesLine in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineShipmentFeeAsCommentBeforeFinalizeComment(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesCommentLine: Record "Sales Comment Line");
    begin
    end;

    [Obsolete('Replaced by OnInsertSalesLineShipmentFeeSelectShippingFee in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineShipmentFeeSelectShippingFee(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLine: Record "Sales Line"; var ShipmentMapping: Record "NPR Magento Shipment Mapping");
    begin
    end;

    [Obsolete('Replaced by OnInsertSalesLineShipmentFeeBeforeFinalizeLine in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnInsertSalesLineShipmentFeeBeforeFinalizeLine(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesLine: Record "NPR Inc Ecom Sales Line"; var SalesLine: Record "Sales Line");
    begin
    end;

    [Obsolete('Replaced by OnInsertPaymentLinePaymentMethodBeforeFinalizeLine in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]
    [IntegrationEvent(false, false)]
    internal procedure OnInsertPaymentLinePaymentMethodBeforeFinalizeLine(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHeader: Record "Sales Header"; IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line"; var PaymentLine: Record "NPR Magento Payment Line");
    begin
    end;

    [Obsolete('Replaced by OnAfterInsertCommentLines in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertCommentLines(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHedaer: Record "Sales Header");
    begin
    end;

    [Obsolete('Replaced by OnAfterUpdateExtCouponReservations in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateExtCouponReservations(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHedaer: Record "Sales Header");
    begin
    end;

    [Obsolete('Replaced by OnProcessBeforeRelease in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnProcessBeforeRelease(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; SalesHedaer: Record "Sales Header");
    begin
    end;

    [Obsolete('Replaced by OnAfterInsertSalesDocument in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnAfterInsertSalesDocument(IncomingSalesHeader: Record "NPR Inc Ecom Sales Header"; var SalesHeader: Record "Sales Header"; var Success: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnUpdateSalesDocumentPostingStatusFromSalesHeaderBeforeFinalizeUpdate in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentPostingStatusFromSalesHeaderBeforeFinalizeUpdate(SalesHeader: Record "Sales Header"; var IncomingSalesHeader: Record "NPR Inc Ecom Sales Header")
    begin
    end;

    [Obsolete('Replaced by OnAfterUpdateSalesDocumentPostingStatusFromSalesHeader in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnAfterUpdateSalesDocumentPostingStatusFromSalesHeader(SalesHeader: Record "Sales Header"; var IncomingSalesHeader: Record "NPR Inc Ecom Sales Header")
    begin
    end;

    [Obsolete('Replaced by OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesInvoice in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesInvoice(SalesInvLine: Record "Sales Invoice Line"; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncEcomSalesLine: Record "NPR Inc Ecom Sales Line")
    begin
    end;

    [Obsolete('Replaced by OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesCreditMemo in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentLinePostingInformationBeforeFinalizeRecordSalesCreditMemo(SalesCrMemoLine: Record "Sales Cr.Memo Line"; IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var IncEcomSalesLine: Record "NPR Inc Ecom Sales Line")
    begin
    end;

    [Obsolete('Replaced by OnUpdateSalesDocumentPaymentLinePostingInformationBeforeFinalizeRecord in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentPaymentLinePostingInformationBeforeFinalizeRecord(PaymentLine: Record "NPR Magento Payment Line"; var IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line")
    begin
    end;

    [Obsolete('Replaced by OnAfterProcess in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnAfterProcess(var IncEcomSalesHeader: Record "NPR Inc Ecom Sales Header"; var Success: Boolean)
    begin
    end;

    [Obsolete('Replaced by OnUpdateSalesDocumentPaymentLineCaptureInformationBeforeFinalizeRecord in codeunit NPR EcomSalesDocImplEvents', '2025-10-26')]

    [IntegrationEvent(false, false)]
    internal procedure OnUpdateSalesDocumentPaymentLineCaptureInformationBeforeFinalizeRecord(PaymentLine: Record "NPR Magento Payment Line"; var IncEcomSalesPmtLine: Record "NPR Inc Ecom Sales Pmt. Line")
    begin
    end;
}
#endif

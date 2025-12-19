#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248516 "NPR EcomVirtualItemEvents"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    procedure OnAfterVoucherProcessBeforeCommit(var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    [CommitBehavior(CommitBehavior::Error)]
    procedure OnAfterVoucherReferenceNoReservation(var NpRvSalesLine: Record "NPR NpRv Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnUpdateVirtualInformationInHeaderBeforeModify(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSetSalesDocVoucherStatusError(var EcomSalesLine: Record "NPR Ecom Sales Line"; var EcomSalesHeader: Record "NPR Ecom Sales Header"; ErrorMessage: Text[500]; UpdateStatus: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSetSalesDocVoucherStatusCreated(var EcomSalesLine: Record "NPR Ecom Sales Line"; var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCalculateVoucherCaptureAmountCanProcessVoucher(EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line"; VoucherType: Record "NPR NpRv Voucher Type"; Voucher: Record "NPR NpRv Voucher"; TotalAmountToCapture: Decimal; AvailableVoucherAmount: Decimal; var ProcessVoucher: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetSalesDocCaptureProcessingStatusErrorBeforeModify(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ErrorMessage: Text[500]; UpdateStatus: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHandleCaptureLineResponseBeforeModifyRecord(Success: Boolean; var EcomSalesHeader: Record "NPR Ecom Sales Header"; var PaymentLine: Record "NPR Magento Payment Line"; UpdateRetryCount: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnUpdateEcomSalesLineCaptureStatusProcessedBeforeModify(EcomSalesHeader: Record "NPR Ecom Sales Header"; RemainingCapturedAmount: Decimal; var EcomSalesLine: Record "NPR Ecom Sales Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetSalesDocCaptureProcessingStatusProcessedBeforeModify(var EcomSalesHeader: Record "NPR Ecom Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPaymentLinePaymentMethod(var PaymentLine: Record "NPR Magento Payment Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin

    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeInsertPaymentLineVoucher(var PaymentLine: Record "NPR Magento Payment Line"; EcomSalesHeader: Record "NPR Ecom Sales Header"; EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line");
    begin

    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeModifyVoucherReference(var NpRvSalesLine: Record "NPR NpRv Sales Line"; PaymentLine: Record "NPR Magento Payment Line");
    begin

    end;
}

#endif

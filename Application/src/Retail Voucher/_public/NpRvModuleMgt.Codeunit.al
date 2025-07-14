codeunit 6151011 "NPR NpRv Module Mgt."
{

    [IntegrationEvent(false, false)]
    internal procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHasSendVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasSendSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupSendVoucher(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunSendVoucher(Voucher: Record "NPR NpRv Voucher"; VoucherType: Record "NPR NpRv Voucher Type"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHasValidateVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasValidateSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupValidateVoucher(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunValidateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunFindVoucher(VoucherTypeCode: Code[20]; ReferenceNo: Text[50]; var Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunRedeemVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunCreateGlobalVoucher(Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunTopUpVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunUpdateVoucherAmount(Voucher: Record "NPR NpRv Voucher"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunTryValidateGlobalVoucherSetup(NpRvGlobalVoucherSetup: Record "NPR NpRv Global Vouch. Setup"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnHasApplyPaymentSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasApplySetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

    [Obsolete('Please use OnRunApplyPaymentV3 instead.', '2023-06-28')]
    [IntegrationEvent(false, false)]
    internal procedure OnRunApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnInsertVoucherPaymentReturnSalesDoc(VoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean);
    begin
    end;

    #region V3
    [IntegrationEvent(false, false)]
    internal procedure OnAfterApplyPaymentV3(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; POSLine: Record "NPR POS Sale Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnRunApplyPaymentV3(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean; var Handled: Boolean; var ActionContext: JsonObject)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnPreApplyPaymentV3(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var SalePOS: Record "NPR POS Sale"; VoucherType: Record "NPR NpRv Voucher Type"; ReferenceNo: Text; SuggestedAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeCheckCustomReferenceNoAlreadyUsed(var CustomReferenceNo: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeIssueVoucherCheckCustomReferenceNo(var CustomReferenceNo: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeIssueVoucher(VoucherType: Record "NPR NpRv Voucher Type"; var QuantityPerLine: Integer; var Quantity: Integer; var Amount: Decimal; var DiscountType: Text; var Discount: Decimal; ScanReferenceNos: Boolean; IssueVoucherPerQuantity: Boolean; ShouldIssueVoucherPerQuantity: Boolean)
    begin
    end;
    #endregion

    [IntegrationEvent(false, false)]
    procedure OnAfterSendVoucherSelection(var VoucherEntry: Record "NPR NpRv Voucher Entry"; SalePOS: Record "NPR POS Sale")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSendSalesDocVoucherSelection(var VoucherEntry: Record "NPR NpRv Voucher Entry"; var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoNo: Code[20])
    begin
    end;
}

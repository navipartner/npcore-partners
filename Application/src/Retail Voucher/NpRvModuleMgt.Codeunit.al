﻿codeunit 6151011 "NPR NpRv Module Mgt."
{
    Access = Internal;

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
    internal procedure OnHasApplyPaymentSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasApplySetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

    [Obsolete('Please use OnRunApplyPaymentV3 instead.', 'NPR23.0')]
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
    internal procedure OnRunApplyPaymentV3(POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; EndSale: Boolean; var Handled: Boolean; var ActionContext: JsonObject)
    begin
    end;
    #endregion
}

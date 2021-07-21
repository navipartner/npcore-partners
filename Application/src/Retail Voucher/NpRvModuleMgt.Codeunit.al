codeunit 6151011 "NPR NpRv Module Mgt."
{
    [IntegrationEvent(false, false)]
    procedure OnInitVoucherModules(var VoucherModule: Record "NPR NpRv Voucher Module")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasSendVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasSendSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupSendVoucher(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunSendVoucher(Voucher: Record "NPR NpRv Voucher"; VoucherType: Record "NPR NpRv Voucher Type"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasValidateVoucherSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasValidateSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupValidateVoucher(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunValidateVoucher(var TempNpRvVoucherBuffer: Record "NPR NpRv Voucher Buffer" temporary; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasApplyPaymentSetup(VoucherType: Record "NPR NpRv Voucher Type"; var HasApplySetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupApplyPayment(var VoucherType: Record "NPR NpRv Voucher Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunApplyPayment(FrontEnd: Codeunit "NPR POS Front End Management"; POSSession: Codeunit "NPR POS Session"; VoucherType: Record "NPR NpRv Voucher Type"; SaleLinePOSVoucher: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NPR NpRv Voucher Type"; SalesHeader: Record "Sales Header"; var NpRvSalesLine: Record "NPR NpRv Sales Line"; var Handled: Boolean)
    begin
    end;
}


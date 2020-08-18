codeunit 6151011 "NpRv Module Mgt."
{
    // NPR5.37/MHA /20171023  CASE 267346 Object created - NaviPartner Retail Voucher
    // NPR5.49/MHA /20190228  CASE 342811 Changed signature of function OnRunValidateVoucher()
    // NPR5.55/MHA /20200603  CASE 363864 Added interface for Sales Document Payments


    trigger OnRun()
    begin
    end;

    local procedure "--- Init"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnInitVoucherModules(var VoucherModule: Record "NpRv Voucher Module")
    begin
    end;

    local procedure "--- Send Voucher"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasSendVoucherSetup(VoucherType: Record "NpRv Voucher Type";var HasSendSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupSendVoucher(var VoucherType: Record "NpRv Voucher Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunSendVoucher(Voucher: Record "NpRv Voucher";VoucherType: Record "NpRv Voucher Type";var Handled: Boolean)
    begin
    end;

    local procedure "--- Validate Coupon"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasValidateVoucherSetup(VoucherType: Record "NpRv Voucher Type";var HasValidateSetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupValidateVoucher(var VoucherType: Record "NpRv Voucher Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunValidateVoucher(var NpRvVoucherBuffer: Record "NpRv Voucher Buffer" temporary;var Handled: Boolean)
    begin
    end;

    local procedure "--- Apply Payment"()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnHasApplyPaymentSetup(VoucherType: Record "NpRv Voucher Type";var HasApplySetup: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnSetupApplyPayment(var VoucherType: Record "NpRv Voucher Type")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunApplyPayment(FrontEnd: Codeunit "POS Front End Management";POSSession: Codeunit "POS Session";VoucherType: Record "NpRv Voucher Type";SaleLinePOSVoucher: Record "NpRv Sales Line";var Handled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnRunApplyPaymentSalesDoc(VoucherType: Record "NpRv Voucher Type";SalesHeader: Record "Sales Header";var NpRvSalesLine: Record "NpRv Sales Line";var Handled: Boolean)
    begin
        //-NPR5.55 [363864]
        //+NPR5.55 [363864]
    end;
}


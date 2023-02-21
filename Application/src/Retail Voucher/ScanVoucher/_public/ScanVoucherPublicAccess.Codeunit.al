codeunit 6150695 "NPR Scan Voucher Public Access"
{

    procedure ProcessPaymentRun(VoucherTypeCode: Code[20]; VoucherNumber: Text; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; EndSale: Boolean; var ActionContext: JsonObject)
    begin
        POSActionScanVoucher2B.ProcessPayment(VoucherTypeCode, VoucherNumber, Sale, PaymentLine, SaleLine, EndSale, ActionContext);
    end;

    procedure CheckReferenceNoRun(var ReferenceNoIn: Text; VoucherListEnabledIn: Boolean; VoucherTypeCodeIn: Code[20])
    begin
        POSActionScanVoucher2B.CheckReferenceNo(ReferenceNoIn, VoucherListEnabledIn, VoucherTypeCodeIn);
    end;

    procedure EndSaleRun(VoucherTypeCode: Text; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup")
    begin
        POSActionScanVoucher2B.EndSale(VoucherTypeCode, Sale, PaymentLine, SaleLine, Setup);
    end;

    var
        POSActionScanVoucher2B: codeunit "NPR POS Action Scan Voucher2B";
}
codeunit 6060026 "NPR NpRv ModValidGlobal Public"
{
    procedure CreateGlobalVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.CreateGlobalVoucher(Voucher);
    end;

    procedure RedeemVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.RedeemVoucher(VoucherEntry, Voucher);
    end;

    procedure RedeemPartnerVouchers(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.RedeemPartnerVouchers(VoucherEntry, Voucher);
    end;

    procedure ThrowGlobalVoucherWSError(ResponseReasonPhrase: Text; ResponseText: Text)
    var
        NpRvModueValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        NpRvModueValidGlobal.ThrowGlobalVoucherWSError(ResponseReasonPhrase, ResponseText);
    end;

    [Obsolete('Use one of the overloads that takes the additional parameters DocumentCurrencyCode and DocumentCurrencyFactor, representing the currency of the document to which the voucher payment that is being posted is attached (e.g., SalesHeader."Currency Code" and SalesHeader."Currency Factor").', '2026-01-30')]
    procedure PostVoucherPayment(var NpRvSalesLine: Record "NPR NpRv Sales Line")
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.PostPayment(NpRvSalesLine);
    end;

    procedure PostVoucherPayment(var NpRvSalesLine: Record "NPR NpRv Sales Line"; DocumentCurrencyCode: Code[10]; DocumentCurrencyFactor: Decimal)
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.PostPayment(NpRvSalesLine, DocumentCurrencyCode, DocumentCurrencyFactor);
    end;

    procedure PostVoucherPayment(var NpRvSalesLine: Record "NPR NpRv Sales Line"; MagentoPaymentLine: Record "NPR Magento Payment Line"; DocumentCurrencyCode: Code[10]; DocumentCurrencyFactor: Decimal)
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        NpRvVoucherMgt.PostPayment(NpRvSalesLine, MagentoPaymentLine, DocumentCurrencyCode, DocumentCurrencyFactor);
    end;
}

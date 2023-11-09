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
}

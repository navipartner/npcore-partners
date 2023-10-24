codeunit 6060026 "NPR NpRv ModValidGlobal Public"
{
    procedure CreateGlobalVoucher(Voucher: Record "NPR NpRv Voucher")
    var
        NpRvModueValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        NpRvModueValidGlobal.CreateGlobalVoucher(Voucher);
    end;

    procedure RedeemVoucher(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvModueValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        NpRvModueValidGlobal.RedeemVoucher(VoucherEntry, Voucher);
    end;

    procedure RedeemPartnerVouchers(VoucherEntry: Record "NPR NpRv Voucher Entry"; Voucher: Record "NPR NpRv Voucher")
    var
        NpRvModueValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        NpRvModueValidGlobal.RedeemPartnerVouchers(VoucherEntry, Voucher);
    end;

    procedure ThrowGlobalVoucherWSError(ResponseReasonPhrase: Text; ResponseText: Text)
    var
        NpRvModueValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        NpRvModueValidGlobal.ThrowGlobalVoucherWSError(ResponseReasonPhrase, ResponseText);
    end;
}

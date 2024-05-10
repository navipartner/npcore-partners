codeunit 6184882 "NPR Try Find Partner Voucher"
{
    Access = Internal;

    trigger OnRun()
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        _Found := NpRvVoucherMgt.FindPartnerVoucher(_VoucherType, _ReferenceNo, _Voucher);
    end;

    internal procedure SetReferenceNo(ReferenceNo: Text[50])
    begin
        _ReferenceNo := ReferenceNo;
    end;

    internal procedure GetReferenceNo(var ReferenceNo: Text[50])
    begin
        ReferenceNo := _ReferenceNo;
    end;

    internal procedure SetVoucherType(VoucherType: Code[20])
    begin
        _VoucherType := VoucherType;
    end;

    internal procedure GetVoucherType(VoucherType: Code[20])
    begin
        VoucherType := _VoucherType;
    end;

    internal procedure GetVoucher(var Voucher: Record "NPR NpRv Voucher");
    begin
        Voucher := _Voucher;
    end;

    internal procedure GetResult(var Voucher: Record "NPR NpRv Voucher"; var Found: Boolean)
    begin
        Voucher := _Voucher;
        Found := _Found;
    end;

    var
        _Voucher: Record "NPR NpRv Voucher";
        _ReferenceNo: Text[50];
        _VoucherType: Code[20];
        _Found: Boolean;

}
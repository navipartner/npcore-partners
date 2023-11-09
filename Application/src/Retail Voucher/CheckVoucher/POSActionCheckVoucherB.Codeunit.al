codeunit 6059908 "NPR POS Action:Check Voucher B"
{
    Access = Internal;
    internal procedure CheckVoucher(VoucherTypeCode: Code[20]; ReferenceNo: Text[50]): Boolean
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpRvVoucherCard: Page "NPR NpRv Voucher Card";
        NotFoundErr: Label 'Reference No. %1 and Voucher Type %2 not found', Comment = '%1=Voucher Reference No;%2=Voucher Type Code';
    begin
        if NpRvVoucherMgt.FindVoucher(VoucherTypeCode, ReferenceNo, Voucher) then
            NpRvVoucherMgt.UpdateVoucherAmount(Voucher)
        else
            if not NpRvVoucherMgt.FindPartnerVoucher(VoucherTypeCode, ReferenceNo, Voucher) then
                Error(NotFoundErr, ReferenceNo, VoucherTypeCode);

        NpRvVoucherCard.Editable(false);
        NpRvVoucherCard.SetRecord(Voucher);
        NpRvVoucherCard.RunModal();
    end;
}

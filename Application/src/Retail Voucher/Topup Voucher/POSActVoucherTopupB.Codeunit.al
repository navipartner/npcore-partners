codeunit 6059962 "NPR POS Act. Voucher Top-up-B"
{
    Access = Internal;
    procedure FindVoucher(VoucherTypeFilter: Text; ReferenceNo: Text) VoucherNo: Code[20]
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        NpRvModuleValidGlobal: Codeunit "NPR NpRv Module Valid.: Global";
        VoucherTypeCode: Code[20];
        VoucherReferenceNumber: Text[50];
        NotFoundErr: Label 'Reference No. %1 and Voucher Type %2 not found';
        TopupNotAllowErr: Label 'Top-up is not allowed for Retail Voucher %1';
    begin
        NpRvVoucherMgt.TrimTypeAndReference(VoucherTypeFilter, VoucherTypeCode, ReferenceNo, VoucherReferenceNumber);
        NpRvVoucher.SetFilter("Voucher Type", VoucherTypeCode);

        if VoucherReferenceNumber = '' then
            if Page.RunModal(0, NpRvVoucher) = Action::LookupOK then
                VoucherReferenceNumber := NpRvVoucher."Reference No.";

        NpRvVoucher.SetFilter("Reference No.", '=%1', VoucherReferenceNumber);
        if NpRvVoucher.FindFirst() then
            NpRvModuleValidGlobal.UpdateVoucherAmount(NpRvVoucher)
        else
            if not NpRvVoucherMgt.FindPartnerVoucher(VoucherTypeCode, VoucherReferenceNumber, NpRvVoucher) then
                Error(NotFoundErr, VoucherReferenceNumber, VoucherTypeCode);

        if not NpRvVoucher."Allow Top-up" then
            Error(TopupNotAllowErr, NpRvVoucher."Reference No.");

        exit(NpRvVoucher."No.");
    end;

    procedure RunVoucherCard(VoucherNo: Text)
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
    begin
        NpRvVoucher.Get(VoucherNo);
        PAGE.RunModal(PAGE::"NPR NpRv Voucher Card", NpRvVoucher);
    end;
}
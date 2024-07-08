codeunit 6151054 "NPR POSAction ForeignVoucher B"
{
    Access = Internal;
    internal procedure CapturePayment(AmountToCaptureLCY: Decimal;
                                      DefaultAmountToCaptureLCY: Decimal;
                                      POSPaymentLine: Codeunit "NPR POS Payment Line";
                                      var POSLine: Record "NPR POS Sale Line";
                                      POSPaymentMethod: Record "NPR POS Payment Method";
                                      VoucherNumber: Text; SalePOS: Record "NPR POS Sale";
                                      POSSession: Codeunit "NPR POS Session";
                                      FrontEnd: Codeunit "NPR POS Front End Management") IsCaptured: Boolean
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        VoucherTypeCode: Code[20];
        Voucher: Record "NPR NpRv Voucher";
        TooLongErr: Label '%1 is too long. Max %2 characters allowed.';
        VoucherNotValid: Label 'Voucher %1 is not valid.';
    begin
        IsCaptured := AmountToCaptureLCY = 0;
        if IsCaptured then
            exit;

        if not ValidateExternalVoucher(VoucherNumber) then
            Error(VoucherNotValid, VoucherNumber);

        if StrLen(VoucherNumber) > MaxStrLen(Voucher."Reference No.") then
            Error(TooLongErr, VoucherNumber, MaxStrLen(Voucher."Reference No."));

        NpRvVoucherType.SetRange("Payment Type", POSPaymentMethod.Code);
        if NpRvVoucherType.FindFirst() then
            VoucherTypeCode := NpRvVoucherType.Code;

        POSPaymentLine.ValidateAmountBeforePayment(POSPaymentMethod,
                                                   AmountToCaptureLCY,
                                                   DefaultAmountToCaptureLCY);

        ApplyForeignVoucherToPaymentLine(VoucherTypeCode,
                                         VoucherNumber,
                                         POSLine,
                                         AmountToCaptureLCY,
                                         SalePOS,
                                         POSSession,
                                         FrontEnd);

        IsCaptured := true;
    end;

    local procedure ValidateExternalVoucher(VoucherNumber: Text): Boolean
    begin
        exit(VoucherNumber <> ''); //TODO possible external validation
    end;

    local procedure ApplyForeignVoucherToPaymentLine(VoucherTypeCode: Code[20];
                                                     VoucherNumber: Text;
                                                     var PaymentLine: Record "NPR POS Sale Line";
                                                     AmountToCaptureLCY: Decimal;
                                                     SalePOS: Record "NPR POS Sale";
                                                     POSSession: Codeunit "NPR POS Session";
                                                     FrontEnd: Codeunit "NPR POS Front End Management") Applied: Boolean
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        POSLine: Record "NPR POS Sale Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentLine(POSLine);

        NpRvVoucherMgt.ApplyForeignVoucherPayment(VoucherTypeCode,
                                                  VoucherNumber,
                                                  PaymentLine,
                                                  SalePOS,
                                                  POSSession,
                                                  FrontEnd,
                                                  POSPaymentLine,
                                                  POSLine,
                                                  AmountToCaptureLCY);

        AmountToCaptureLCY := POSLine."Amount Including VAT";
        Applied := true;
    end;
}
codeunit 6150631 "NPR POS Action Scan Voucher2B"
{
    Access = Internal;
    internal procedure SetReferenceNo(VoucherTypeCode: Code[20]): Text
    var
        Voucher: Record "NPR NpRv Voucher";
        NpRvVouchers: Page "NPR NpRv Vouchers";
        ReferenceNo: Text;
        BlankReferenceNoErr: Label 'Reference No. can''t be blank';
    begin
        Voucher.SetCurrentKey("Voucher Type");
        Voucher.SetRange("Voucher Type", VoucherTypeCode);

        Clear(NpRvVouchers);
        NpRvVouchers.LookupMode := true;
        NpRvVouchers.SetTableView(Voucher);
        if NpRvVouchers.RunModal() = Action::LookupOK then begin
            NpRvVouchers.GetRecord(Voucher);
            ReferenceNo := CopyStr(Voucher."Reference No.", MaxStrLen(Voucher."Reference No."));
        end;
        if ReferenceNo = '' then
            Error(BlankReferenceNoErr);
        exit(ReferenceNo);

    end;

    internal procedure ProcessPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; SuggestedAmount: Decimal; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; ParamEndSale: Boolean; var ActionContext: JsonObject)
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        SalePOS: Record "NPR POS Sale";
        POSLine: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        Sale.GetCurrentSale(SalePOS);
        PaymentLine.GetPaymentLine(POSLine);

        NpRvVoucherMgt.ApplyVoucherPayment(VoucherTypeCode, VoucherNumber, SuggestedAmount, POSLine, SalePOS, POSSession, PaymentLine, POSLine, ParamEndSale, ActionContext);
    end;

    internal procedure ProcessPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; ParamEndSale: Boolean; var ActionContext: JsonObject)
    begin
        ProcessPayment(VoucherTypeCode,
                       VoucherNumber,
                       0,
                       Sale,
                       PaymentLine,
                       SaleLine,
                       ParamEndSale,
                       ActionContext)
    end;

    internal procedure EndSale(VoucherTypeCode: Text; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; Setup: Codeunit "NPR POS Setup")
    var
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSession: Codeunit "NPR POS Session";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        PaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);

        if Abs(Subtotal) > Abs(Setup.AmountRoundingPrecision()) then
            exit;

        NpRvVoucherType.Get(VoucherTypeCode);
        if not POSPaymentMethod.Get(NpRvVoucherType."Payment Type") then
            exit;
        if not ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code") then
            exit;
        if PaymentLine.CalculateRemainingPaymentSuggestion(SaleAmount, PaidAmount, POSPaymentMethod, ReturnPOSPaymentMethod, false) <> 0 then
            exit;
        if not Sale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod) then
            exit;
    end;

    internal procedure CheckReferenceNo(var ReferenceNoIn: Text; VoucherListEnabledIn: Boolean; VoucherTypeCodeIn: Code[20])
    var
        BlankReferenceNoErr: Label 'Reference No. can''t be blank';
    begin
        if VoucherListEnabledIn then
            ReferenceNoIn := SetReferenceNo(VoucherTypeCodeIn)
        else
            Error(BlankReferenceNoErr);
    end;

    internal procedure CalculateRemainingAmount(PaymentLine: Codeunit "NPR POS Payment Line";
                                                PaymentMethodCode: Code[10];
                                                var POSPaymentMethodOut: Record "NPR POS Payment Method";
                                                var RemainingAmount: Decimal)
    var
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SubTotal: Decimal;
    begin
        POSPaymentMethodOut.Get(PaymentMethodCode);
        ReturnPOSPaymentMethod.Get(POSPaymentMethodOut."Return Payment Method Code");
        POSPaymentMethodOut.TestField("Block POS Payment", false);
        ReturnPOSPaymentMethod.TestField("Block POS Payment", false);

        PaymentLine.CalculateBalance(POSPaymentMethodOut, SalesAmount, PaidAmount, ReturnAmount, SubTotal);
        RemainingAmount := PaymentLine.CalculateRemainingPaymentSuggestion(SalesAmount, PaidAmount, POSPaymentMethodOut, ReturnPOSPaymentMethod, true);
    end;

}

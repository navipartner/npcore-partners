codeunit 6150626 "NPR POSAct. SS Voucher Apply B"
{
    Access = Internal;
    internal procedure ProcessPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"; ParamEndSale: Boolean; var ActionContext: JsonObject)
    var
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        SalePOS: Record "NPR POS Sale";
        POSLine: Record "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        Sale.GetCurrentSale(SalePOS);
        PaymentLine.GetPaymentLine(POSLine);

        NpRvVoucherMgt.ApplyVoucherPayment(VoucherTypeCode, VoucherNumber, POSLine, SalePOS, POSSession, PaymentLine, POSLine, ParamEndSale, ActionContext);
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
}

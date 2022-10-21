codeunit 6184634 "NPR Cashout Voucher B"
{

    Access = Internal;

    internal procedure ApplyVoucherPayment(VoucherTypeCode: Code[20]; VoucherNumber: Text; Sale: Codeunit "NPR POS Sale"; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        POSLine: Record "NPR POS Sale Line";
        POSSale: Record "NPR POS Sale";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
    begin
        Sale.GetCurrentSale(POSSale);
        PaymentLine.GetPaymentLine(POSLine);
        NpRvVoucherMgt.PrepareForCashApplication(VoucherTypeCode, VoucherNumber, POSLine, POSSale, PaymentLine, POSLine);

        InsertCommentLine(SaleLine, POSLine);
    end;

    internal procedure InsertCommentLine(SaleLine: Codeunit "NPR POS Sale Line"; Line: Record "NPR POS Sale Line")
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine."Line Type" := POSSaleLine."Line Type"::Comment;
        POSSaleLine.Description := CopyStr('Cashout ' + Line.Description, 1, MaxStrLen(POSSaleLine.Description));
        SaleLine.InsertLine(POSSaleLine);
    end;

    internal procedure InsertCommision(GLAccount: Code[20]; VoucherType: Code[20]; CommisionPercentage: Decimal; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"): boolean
    var
        POSLine: Record "NPR POS Sale Line";
        PayInPayOutMgr: Codeunit "NPR Pay-in Payout Mgr";
        CommisionAmount: Decimal;
        POSPaymentMethod: Record "NPR POS Payment Method";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        CommisionLbl: label 'Commision %1%', Comment = 'Commision percentage = %1';
    begin
        PaymentLine.GetCurrentPaymentLine(POSLine);
        NpRvVoucherType.Get(VoucherType);
        POSPaymentMethod.Get(NpRvVoucherType."Payment Type");

        CommisionAmount := Round(POSLine."Amount Including VAT" * CommisionPercentage / 100, POSPaymentMethod."Rounding Precision", POSPaymentMethod.GetRoundingType());

        exit(PayInPayOutMgr.CreatePayInOutPayment(SaleLine, 1, GLAccount, StrSubstNo(CommisionLbl, Format(CommisionPercentage)), CommisionAmount, ''));
    end;

}

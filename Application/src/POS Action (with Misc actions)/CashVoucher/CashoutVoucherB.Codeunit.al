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

    internal procedure InsertCommision(GLAccount: Code[20]; VoucherType: Code[20]; CommisionType: Option Percentage,Amount; Commision: Decimal; PaymentLine: Codeunit "NPR POS Payment Line"; SaleLine: Codeunit "NPR POS Sale Line"): boolean
    var
        GLSetup: Record "General Ledger Setup";
        NpRvVoucherType: Record "NPR NpRv Voucher Type";
        POSLine: Record "NPR POS Sale Line";
        POSPaymentMethod: Record "NPR POS Payment Method";
        PayInPayOutMgr: Codeunit "NPR Pay-in Payout Mgr";
        CommisionAmount: Decimal;
        Description: Text;
        CommisionLbl: Label 'Fee %1%2', Comment = '%1 - specifies the Fee percentage or amount based on Fee Type, %2 - specifies % sign or LCY based on Fee Type';
    begin
        GLSetup.Get();
        PaymentLine.GetCurrentPaymentLine(POSLine);
        NpRvVoucherType.Get(VoucherType);
        POSPaymentMethod.Get(NpRvVoucherType."Payment Type");

        if CommisionType = CommisionType::Percentage then begin
            CommisionAmount := POSLine."Amount Including VAT" * Commision / 100;
            Description := StrSubstNo(CommisionLbl, Format(Commision), '%');
        end
        else begin
            CommisionAmount := Commision;
            Description := StrSubstNo(CommisionLbl, Format(Commision), GLSetup."LCY Code");
        end;

        if POSPaymentMethod."Rounding Precision" > 0 then
            CommisionAmount := Round(CommisionAmount, POSPaymentMethod."Rounding Precision", POSPaymentMethod.GetRoundingType());

#pragma warning disable AA0139
        exit(PayInPayOutMgr.CreatePayInOutPayment(SaleLine, 1, GLAccount, Description, CommisionAmount, ''));
#pragma warning restore
    end;
}
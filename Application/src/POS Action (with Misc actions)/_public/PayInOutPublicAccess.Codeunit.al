codeunit 6060029 "NPR PayInOut Public Access"
{
    procedure CreatePayInOutPaymentRun(SaleLine: Codeunit "NPR POS Sale Line"; PaymentType: Integer; AccountNo: Code[20]; Description: Text[100]; Amount: Decimal; ReasonCode: Code[10]): Boolean
    var
        PayinPayoutMgr: Codeunit "NPR Pay-in Payout Mgr";
    begin
        exit(PayinPayoutMgr.CreatePayInOutPayment(SaleLine, PaymentType, AccountNo, Description, Amount, ReasonCode));
    end;
}
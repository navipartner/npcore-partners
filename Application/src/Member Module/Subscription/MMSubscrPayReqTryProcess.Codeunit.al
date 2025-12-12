codeunit 6248669 "NPR MM Subscr.PayReqTryProcess"
{
    Access = Internal;
    TableNo = "NPR MM Subscr. Payment Request";

    trigger OnRun()
    var
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
    begin
        SubscrPaymentIHandler := Rec.PSP;
        SubscrPaymentIHandler.ProcessPaymentRequest(Rec, false, false);
    end;
}
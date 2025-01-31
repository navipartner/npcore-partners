codeunit 6185111 "NPR MM Subscr. Pay Req Proc JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    begin
        ProcessSubscriptionPaymentRequests();
    end;

    local procedure ProcessSubscriptionPaymentRequests()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetRange(Status, SubscrPaymentRequest.Status::New);
        if not SubscrPaymentRequest.FindSet() then
            exit;

        repeat
            SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
            SubscrPaymentIHandler.ProcessPaymentRequest(SubscrPaymentRequest, false, false);
        until SubscrPaymentRequest.Next() = 0;
    end;
}
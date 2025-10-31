codeunit 6248479 "NPR MM Subscr Termination JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ProcessRequestedTerminations();
    end;

    local procedure ProcessRequestedTerminations()
    var
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        TryRenewProcess: Codeunit "NPR MM Subs Try Renew Process";
    begin
#if (BC17 or BC18 or BC19 or BC20 or BC21)
        Subscription.LockTable();
#else
        Subscription.ReadIsolation := IsolationLevel::UpdLock;
#endif
        Subscription.SetRange("Auto-Renew", Subscription."Auto-Renew"::TERMINATION_REQUESTED);
        if (not Subscription.FindSet()) then
            exit;

        repeat
            SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
            SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Terminate);
            SubscriptionRequest.SetRange("Processing Status", SubscriptionRequest."Processing Status"::Pending);
            SubscriptionRequest.SetFilter("Terminate At", '<%1', WorkDate());
            if SubscriptionRequest.FindLast() then
                TryRenewProcess.ProcessTermination(SubscriptionRequest);
        until Subscription.Next() = 0;
    end;
}
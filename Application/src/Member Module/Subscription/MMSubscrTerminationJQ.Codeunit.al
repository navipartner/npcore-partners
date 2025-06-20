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
        Membership: Record "NPR MM Membership";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
    begin
#if (BC17 or BC18 or BC19 or BC20 or BC21)
        Subscription.LockTable();
#else
        Subscription.ReadIsolation := IsolationLevel::UpdLock;
#endif
        Subscription.SetFilter("Terminate At", '<%1', WorkDate());
        Subscription.SetRange("Auto-Renew", Subscription."Auto-Renew"::TERMINATION_REQUESTED);
        if (not Subscription.FindSet()) then
            exit;

        repeat
            if (Membership.Get(Subscription."Membership Entry No.")) then
                MembershipMgtInternal.DisableMembershipAutoRenewal(Membership, true, false);
        until Subscription.Next() = 0;
    end;
}
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248482 "NPR MembershipSubscrAgent"
{
    Access = Internal;

    internal procedure GetSubscription(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        if (not SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(SubscriptionDto(Membership, Subscription)));
    end;

    internal procedure EnterSubscription(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
    begin
        Membership.ReadIsolation := IsolationLevel::UpdLock;
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        if (not SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            SubscriptionMgtImpl.UpdateMembershipSubscriptionDetails(Membership) // This will create the subscription record.
        else
            if (MembershipMgtInternal.UnprocessedPartialRegretExists(Membership)) and (not PendingRefundConfirmed(Request)) then
                exit(Response.RespondBadRequest('The subscription has an unprocessed refund (partial regret) that might be processed at a later point and affect the membership. Pass query parameter confirmPendingRefund=true to resume anyway.'));

        Membership.Validate("Auto-Renew", Membership."Auto-Renew"::YES_INTERNAL);
        Membership.Modify();

        SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription);

        exit(Response.RespondOK(SubscriptionDto(Membership, Subscription)));
    end;

    local procedure PendingRefundConfirmed(var Request: Codeunit "NPR API Request"): Boolean
    var
        ParamValue: Text;
    begin
        if (not Request.QueryParams().Get('confirmPendingRefund', ParamValue)) then
            exit(false);
        exit(ParamValue.ToLower() = 'true');
    end;

    internal procedure TerminateSubscription(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        Membership: Record "NPR MM Membership";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        BodyJson: JsonToken;
        JHelper: Codeunit "NPR Json Helper";
        RequestedDate: Date;
        Subscription: Record "NPR MM Subscription";
    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        case Membership."Auto-Renew" of
            "NPR MM MembershipAutoRenew"::NO:
                exit(Response.RespondBadRequest('Membership does not have an active subscription.'));
            "NPR MM MembershipAutoRenew"::YES_EXTERNAL:
                exit(Response.RespondBadRequest('The subscription of the membership is not managed internally and can therefore not be terminated using this method.'));
            "NPR MM MembershipAutoRenew"::TERMINATION_REQUESTED:
                exit(Response.RespondBadRequest('Subscription is already pending termination.'));
        end;

        BodyJson := Request.BodyJson();

        RequestedDate := JHelper.GetJDate(BodyJson, 'terminationDate', false);
        if (RequestedDate = 0D) then begin
            SubscriptionMgtImpl.GetEarliestTerminationDate(Membership, RequestedDate);
            // The helper reports "no notice period and no commitment" as a blank date rather than a failure, and
            // terminating "at 0D" would write a meaningless date onto the request.
            //
            // Only 0D is corrected, deliberately. Moving any past date up to today would push Terminate At beyond
            // Valid Until Date on an expired subscription, which flips IsTerminationDue to false and lets the renewal
            // job charge the guest another period - the opposite of what they asked for. A past date is at worst odd
            // to look at; a date that resumes billing is a defect. A caller-supplied date is left exactly as sent.
            if (RequestedDate = 0D) then begin
                RequestedDate := Today();
                // Today is itself past the period end once the subscription has lapsed, so the rule above has to be
                // applied to this substitution as well: a date we invented must never allow a charge the guest did
                // not ask for. The roll-forward inside the helper is the one deliberate exception, because a notice
                // period running past the period end is something the guest owes. Nothing is owed here.
                if (SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
                    if (Subscription."Valid Until Date" <> 0D) then
                        if (RequestedDate > Subscription."Valid Until Date") then
                            RequestedDate := Subscription."Valid Until Date";
            end;
        end;

        if (not SubscriptionMgtImpl.RequestTermination(Membership, RequestedDate, Enum::"NPR MM Subs Termination Reason"::CUSTOMER_INITIATED)) then
            exit(Response.RespondBadRequest('Membership does not have a subscription associated with it or subscription could not be requested to terminate.'));

        SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription);

        exit(Response.RespondOK(SubscriptionDto(Membership, Subscription)));
    end;

    /// <summary>
    /// Takes the membership from the caller rather than re-reading it from the subscription: every caller has already
    /// resolved it, and a failed lookup here would have degraded the response to nulls without saying why.
    /// </summary>
    local procedure SubscriptionDto(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription"): Codeunit "NPR Json Builder"
    var
        Json: Codeunit "NPR Json Builder";
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        NextRenewalAttemptDate: Date;
        UsableUntilDate: Date;
        RenewalIsPlanned: Boolean;
        RenewalRequiredBeforeTermination: Boolean;
        UsableUntilDateKnown: Boolean;
    begin
        Json.StartObject()
                .AddProperty('id', Format(Subscription.SystemId, 0, 4).ToLower())
                .AddProperty('blocked', Subscription.Blocked);

        if (Subscription."Started At" <> 0DT) then
            Json.AddProperty('startedAt', Subscription."Started At");
        if (Subscription."Committed Until" <> 0D) then
            Json.AddProperty('committedUntil', Subscription."Committed Until");

        if Subscription."Auto-Renew" = Subscription."Auto-Renew"::TERMINATION_REQUESTED then
            GetTerminationSubsRequest(Subscription, Json);

        // One call for both dates: the usable-until rule gates on the renewal attempt date, so working them out
        // together is what stops this endpoint reporting a further charge beside a null attempt date. The agreed
        // termination case is handled inside it too, so no consumer of that procedure can report a different date for
        // the same membership.
        UsableUntilDateKnown := SubscriptionMgtImpl.GetSubscriptionDates(Membership, Subscription, UsableUntilDate, RenewalRequiredBeforeTermination, NextRenewalAttemptDate, RenewalIsPlanned);
        if (not RenewalIsPlanned) then
            Clear(NextRenewalAttemptDate);

        Json.AddObject(MembershipApiAgent.AddRequiredProperty(Json, 'usableUntilDate', UsableUntilDate));
        // Null rather than a bare false when the date itself is unknown: "no further renewal" would read as a fact
        // about a membership we could not answer for at all.
        if UsableUntilDateKnown then
            Json.AddProperty('renewalRequiredBeforeTermination', RenewalRequiredBeforeTermination)
        else
            Json.AddProperty('renewalRequiredBeforeTermination');
        Json.AddObject(MembershipApiAgent.AddRequiredProperty(Json, 'nextRenewalAttemptDate', NextRenewalAttemptDate));

        Json.AddProperty('autoRenew', Enum::"NPR MM MembershipAutoRenew".Names().Get(Enum::"NPR MM MembershipAutoRenew".Ordinals().IndexOf(Subscription."Auto-Renew".AsInteger())))
            .EndObject();
        exit(Json);
    end;

    local procedure GetTerminationSubsRequest(Subscription: Record "NPR MM Subscription"; var Json: Codeunit "NPR Json Builder")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Terminate);
        // These fields record what the guest asked for, so they stay visible for as long as the request is live.
        // Live means Pending or Error and neither withdrawn nor skipped, which is how the Outst. Subscr. Requests
        // Exist FlowField on "NPR MM Subscription" defines an outstanding request. A termination that has run out of
        // retries is still outstanding, and dropping it here would report autoRenew as TERMINATION_REQUESTED with
        // nothing to say about when or why.
        //
        // Both filters are load-bearing, and each covers what the other misses. Status alone would let through a
        // request whose processing is already finished; Processing Status alone would let through a withdrawn one,
        // because validating Status to Cancelled puts Processing Status back to Pending through the table trigger.
        //
        // Deliberately wider than TryGetAgreedTerminationDate, which backs usableUntilDate and takes Pending only. A
        // request in Error is not picked up by the termination job, so it cannot change when the card stops working
        // even though it is still a request the guest made.
        SubscriptionRequest.SetFilter(Status, '<>%1&<>%2', SubscriptionRequest.Status::Cancelled, SubscriptionRequest.Status::Skipped);
        SubscriptionRequest.SetFilter("Processing Status", '%1|%2', SubscriptionRequest."Processing Status"::Pending, SubscriptionRequest."Processing Status"::Error);
        if SubscriptionRequest.FindLast() then begin
            if (SubscriptionRequest."Terminate At" <> 0D) then
                Json.AddProperty('terminateAt', SubscriptionRequest."Terminate At");
            if (SubscriptionRequest."Termination Requested At" <> 0DT) then
                Json.AddProperty('terminationRequestedAt', SubscriptionRequest."Termination Requested At");
            if (SubscriptionRequest."Termination Reason" <> Enum::"NPR MM Subs Termination Reason"::NOT_TERMINATED) then
                Json.AddProperty('terminationReason', Enum::"NPR MM Subs Termination Reason".Names().Get(Enum::"NPR MM Subs Termination Reason".Ordinals().IndexOf(SubscriptionRequest."Termination Reason".AsInteger())));
        end;
    end;
}
#endif
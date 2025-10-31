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

        exit(Response.RespondOK(SubscriptionDto(Subscription)));
    end;

    internal procedure EnterSubscription(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        MembershipApiAgent: Codeunit "NPR MembershipApiAgent";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
    begin
        if (not MembershipApiAgent.GetMembershipById(Request, 2, Membership)) then
            exit(Response.RespondBadRequest('Invalid Membership - Membership Id not valid.'));

        if (not SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            SubscriptionMgtImpl.UpdateMembershipSubscriptionDetails(Membership); // This will create the subscription record.

        Membership.Validate("Auto-Renew", Membership."Auto-Renew"::YES_INTERNAL);
        Membership.Modify();

        SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription);

        exit(Response.RespondOK(SubscriptionDto(Subscription)));
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
        if (RequestedDate = 0D) then
            RequestedDate := Today();

        if (not SubscriptionMgtImpl.RequestTermination(Membership, RequestedDate, Enum::"NPR MM Subs Termination Reason"::CUSTOMER_INITIATED)) then
            exit(Response.RespondBadRequest('Membership does not have a subscription associated with it or subscription could not be requested to terminate.'));

        SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription);

        exit(Response.RespondOK(SubscriptionDto(Subscription)));
    end;

    local procedure SubscriptionDto(Subscription: Record "NPR MM Subscription"): Codeunit "NPR Json Builder"
    var
        Json: Codeunit "NPR Json Builder";
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
codeunit 6185033 "NPR MM Subscr. Renew Req. JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";


    trigger OnRun()
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
    begin
        JQParamStrMgt.Parse(Rec."Parameter String");
        FilterMembershipSetup(MembershipSetup, JQParamStrMgt);
        if MembershipSetup.FindSet() then
            repeat
                RenewMembershipType(MembershipSetup);
            until MembershipSetup.Next() = 0;
        Commit();
    end;

    local procedure RenewMembershipType(MembershipSetup: Record "NPR MM Membership Setup")
    var
        RecurPaymentSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        if not RecurPaymentSetup.Get(MembershipSetup."Recurring Payment Code") or
           (RecurPaymentSetup."Subscr. Auto-Renewal On" = RecurPaymentSetup."Subscr. Auto-Renewal On"::Never)
        then
            exit;

        case RecurPaymentSetup."Subscr. Auto-Renewal On" of
            RecurPaymentSetup."Subscr. Auto-Renewal On"::Schedule:
                ProcessRecurringPaymentWithRenewSchedule(RecurPaymentSetup, MembershipSetup)
            else
                ProcessRecurringPaymentWithRetryCount(RecurPaymentSetup, MembershipSetup);
        end;

    end;

    local procedure ProcessRecurringPaymentWithRenewSchedule(RecurPaymentSetup: Record "NPR MM Recur. Paym. Setup"; MembershipSetup: Record "NPR MM Membership Setup")
    var
        RenewalSchedLine: Record "NPR MM Renewal Sched Line";
        Subscription: Record "NPR MM Subscription";
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        RenewalDate: Date;
    begin
        if RecurPaymentSetup."Subscr. Auto-Renewal On" <> RecurPaymentSetup."Subscr. Auto-Renewal On"::Schedule then
            exit;

        if RecurPaymentSetup."Subscr Auto-Renewal Sched Code" = '' then
            exit;

        RequestSubscrRenewal.SetRecurringPaymentSetup(RecurPaymentSetup);
        RequestSubscrRenewal.SetSkipProcessSubscriptionCheck(true);

        RenewalSchedLine.Reset();
        RenewalSchedLine.SetRange("Schedule Code", RecurPaymentSetup."Subscr Auto-Renewal Sched Code");
        RenewalSchedLine.SetCurrentKey("Schedule Code", "Date Formula Duration (Days)");
        if RenewalSchedLine.FindSet() then
            repeat
                RenewalDate := WorkDate() - RenewalSchedLine."Date Formula Duration (Days)";

                Subscription.SetRange("Membership Code", MembershipSetup.Code);
                Subscription.SetRange(Blocked, false);
                Subscription.SetRange("Valid Until Date", RenewalDate);
                Subscription.SetRange("Postpone Renewal Attempt Until", 0D, WorkDate());
                Subscription.SetRange("Subscr. Request Type Filter", Subscription."Subscr. Request Type Filter"::Renew);
                Subscription.SetRange("Outst. Token Renew Req. Exist", false);
                Subscription.SetFilter("Auto-Renew", '%1|%2', Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew"::TERMINATION_REQUESTED);
                Subscription.SetRange("Subscr Renew Sched Date Filter", WorkDate());
                Subscription.SetRange("Subscr Renew Sched Id Filter", RenewalSchedLine.SystemId);
                Subscription.SetRange("Subscr Renew Sched Req Exist", false);
                Subscription.SetAutoCalcFields("Outst. Token Renew Req. Exist", "Subscr Renew Sched Req Exist");
                if Subscription.FindSet() then
                    repeat
                        if not ResolveExistingPayByLink(Subscription) then begin
                            RequestSubscrRenewal.SetRenewalSchedLine(RenewalSchedLine);
                            if not RequestSubscrRenewal.Run(Subscription) then begin
                                Subscription.Find();
                                SubscriptionMgtImpl.ReportSubscriptionRenewalCreationErrorFromLastError(Subscription, '');
                            end;
                        end;
                    until Subscription.Next() = 0;
            until RenewalSchedLine.Next() = 0;
    end;

    internal procedure ResolveExistingPayByLink(Subscription: Record "NPR MM Subscription") SkipRenewal: Boolean
    var
        OutstandingPayByLink: Record "NPR MM Subscr. Payment Request";
        TempPayment: Record "NPR MM Subscr. Payment Request" temporary;
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
        ResolvePayByLink: Codeunit "NPR MM Subscr. Resolve PBL";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin
        if SubscrRequestUtils.HasCapturedPayByLinkAwaitingRenewal(Subscription) then
            exit(true);
        SubscrRequestUtils.CollectPayByLinksToResolve(Subscription."Entry No.", TempPayment);
        if TempPayment.FindSet() then
            repeat
                OutstandingPayByLink.Get(TempPayment."Entry No.");
                Clear(ResolvePayByLink);
                Commit();
                if not ResolvePayByLink.Run(OutstandingPayByLink) then begin
                    SubscriptionMgtImpl.ReportSubscriptionRenewalCreationErrorFromLastError(Subscription, '');
                    exit(true);
                end;
                if ResolvePayByLink.SkipRenewal() then
                    exit(true);
            until TempPayment.Next() = 0;
    end;

    local procedure ProcessRecurringPaymentWithRetryCount(RecurPaymentSetup: Record "NPR MM Recur. Paym. Setup"; MembershipSetup: Record "NPR MM Membership Setup")
    var
        Subscription: Record "NPR MM Subscription";
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin
        if not (RecurPaymentSetup."Subscr. Auto-Renewal On" in [RecurPaymentSetup."Subscr. Auto-Renewal On"::"Expiry Date", RecurPaymentSetup."Subscr. Auto-Renewal On"::"Next Start Date"]) then
            exit;
        RequestSubscrRenewal.SetRecurringPaymentSetup(RecurPaymentSetup);
        RequestSubscrRenewal.SetSkipProcessSubscriptionCheck(true);

        Subscription.SetRange("Membership Code", MembershipSetup.Code);
        Subscription.SetRange(Blocked, false);
        Subscription.SetRange("Valid Until Date", 0D, Today() + RecurPaymentSetup."First Attempt Offset (Days)");
        Subscription.SetRange("Postpone Renewal Attempt Until", 0D, Today());
        Subscription.SetRange("Subscr. Request Type Filter", Subscription."Subscr. Request Type Filter"::Renew);
        Subscription.SetRange("Outst. Subscr. Requests Exist", false);
        Subscription.SetFilter("Auto-Renew", '%1|%2', Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew"::TERMINATION_REQUESTED);
        Subscription.SetAutoCalcFields("Outst. Subscr. Requests Exist");
        if Subscription.FindSet() then
            repeat
                if not RequestSubscrRenewal.Run(Subscription) then begin
                    Subscription.Find();
                    SubscriptionMgtImpl.ReportSubscriptionRenewalCreationErrorFromLastError(Subscription, '');
                end;
            until Subscription.Next() = 0;
    end;

    local procedure FilterMembershipSetup(var MembershipSetup: Record "NPR MM Membership Setup"; JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.")
    var
        MembershipFilterString: Text;
    begin
        MembershipSetup.Reset();
        if JQParamStrMgt.ContainsParam(ParamMembershipFilter()) then begin
            MembershipFilterString := JQParamStrMgt.GetParamValueAsText(ParamMembershipFilter());
            if MembershipFilterString <> '' then
                MembershipSetup.SetFilter(Code, MembershipFilterString);
        end;
        MembershipSetup.SetRange("Auto-Renew Model", MembershipSetup."Auto-Renew Model"::RECURRING_PAYMENT);
        MembershipSetup.SetFilter("Recurring Payment Code", '<>%1', '');
    end;

    internal procedure ParamMembershipFilter(): Text
    begin
        exit('membership');
    end;
}

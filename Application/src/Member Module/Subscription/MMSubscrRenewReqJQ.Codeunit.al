codeunit 6185033 "NPR MM Subscr. Renew Req. JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    var
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";

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
        Subscription: Record "NPR MM Subscription";
        RecurPaymentSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        if not RecurPaymentSetup.Get(MembershipSetup."Recurring Payment Code") or
           (RecurPaymentSetup."Subscr. Auto-Renewal On" = RecurPaymentSetup."Subscr. Auto-Renewal On"::Never)
        then
            exit;

        RequestSubscrRenewal.SetRecurringPaymentSetup(RecurPaymentSetup);
        RequestSubscrRenewal.SetSkipProcessSubscriptionCheck(true);

        Subscription.SetRange("Membership Code", MembershipSetup.Code);
        Subscription.SetRange(Blocked, false);
        Subscription.SetRange("Valid Until Date", 0D, Today() + RecurPaymentSetup."First Attempt Offset (Days)");
        Subscription.SetRange("Postpone Renewal Attempt Until", 0D, Today());
        Subscription.SetRange("Subscr. Request Type Filter", Subscription."Subscr. Request Type Filter"::Renew);
        Subscription.SetAutoCalcFields("Outst. Subscr. Requests Exist");
        if Subscription.FindSet() then
            repeat
                if not Subscription."Outst. Subscr. Requests Exist" then
                    if not RequestSubscrRenewal.Run(Subscription) then begin
                        Subscription.Find();
                        //TODO: log error
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
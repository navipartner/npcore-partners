codeunit 6059806 "NPR Stripe Create Trial Subs."
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

    internal procedure CreateTrialSubscription(var StripeSubscription: Record "NPR Stripe Subscription"): Boolean
    begin
        exit(DoCreateTrialSubscription(StripeSubscription));
    end;

    local procedure DoCreateTrialSubscription(var StripeSubscription: Record "NPR Stripe Subscription"): Boolean
    var
        StripeCustomer: Record "NPR Stripe Customer";
        StripePlan: Record "NPR Stripe Plan";
    begin
        if not StripeCustomer.CreateTrialCustomer() then
            exit(false);

        StripePlan.SetFilter("Trial Period Days", '<>%1', 0);
        StripePlan.FindFirst();

        exit(StripeSubscription.CreateSubscription(StripeCustomer, StripePlan, true));
    end;
}
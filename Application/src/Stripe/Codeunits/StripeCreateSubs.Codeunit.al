codeunit 6059805 "NPR Stripe Create Subs."
{
    Access = Internal;

    internal procedure CreateSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan"): Boolean
    begin
        exit(DoCreateSubscription(StripeCustomer, StripePlan));
    end;

    local procedure DoCreateSubscription(StripeCustomer: Record "NPR Stripe Customer"; StripePlan: Record "NPR Stripe Plan"): Boolean
    var
        StripeSubscription: Record "NPR Stripe Subscription";
        StripeCustomerTax: Record "NPR Stripe Customer Tax";
        SubscriptionCreated: Boolean;
    begin
        StripeCustomer.TestDetails();
        if not StripeCustomer.UpdateCustomer() then
            exit(false);

        if ShouldCreateCustomerTax(StripeCustomer) then
            if not StripeCustomerTax.CreateCustomerTax(StripeCustomer) then
                exit(false);

        StripeSubscription.SetCurrentKey(SystemCreatedAt);
        if StripeSubscription.FindLast() then begin
            if not StripeSubscription.RefreshSubscription() then
                exit(false);

            if StripeSubscription.Status <> StripeSubscription.Status::Canceled then
                SubscriptionCreated := StripeSubscription.UpdateSubscription(StripeCustomer, StripePlan)
            else
                SubscriptionCreated := StripeSubscription.CreateSubscription(StripeCustomer, StripePlan, false);
        end else
            SubscriptionCreated := StripeSubscription.CreateSubscription(StripeCustomer, StripePlan, false);

        if SubscriptionCreated then
            StripeSubscription.UpdateLastSubscriptionPeriodStartOnStripeSetup();
        exit(SubscriptionCreated);
    end;

    local procedure ShouldCreateCustomerTax(StripeCustomer: Record "NPR Stripe Customer"): Boolean
    var
        StripeCustomerTax: Record "NPR Stripe Customer Tax";
        Found: Boolean;
    begin
        if not StripeCustomer.VATRegistrationNoMandatory() then
            exit(false);

        StripeCustomerTax.SetRange("Customer Id", StripeCustomer.Id);
        StripeCustomerTax.SetRange(Type, StripeCustomerTax.GetEUVATType());

        if not StripeCustomerTax.FindSet() then
            exit(true);

        repeat
            Found := StripeCustomer."VAT Registration No." = StripeCustomerTax.Value;
        until (StripeCustomerTax.Next() = 0) or Found;

        exit(not Found);
    end;
}
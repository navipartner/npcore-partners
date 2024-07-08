codeunit 6059809 "NPR Stripe Refresh Data"
{
    Access = Internal;

    internal procedure RefreshData(var StripeSetup: Record "NPR Stripe Setup"): Boolean
    begin
        exit(DoRefreshData(StripeSetup));
    end;

    local procedure DoRefreshData(var StripeSetup: Record "NPR Stripe Setup"): Boolean
    var
        StripePlan: Record "NPR Stripe Plan";
        StripeProduct: Record "NPR Stripe Product";
        StripeTaxRate: Record "NPR Stripe Tax Rate";
        StripeSubscription: Record "NPR Stripe Subscription";
        DataRefreshed: Boolean;
    begin
        if not StripeSetup.IsStripeActive() then
            exit(false);

        if not ShouldRefreshStripeData(StripeSetup) then
            exit(true);

        if not StripeProduct.GetProducts() then
            exit(false);

        if not StripePlan.GetPlans() then
            exit(false);

        if not StripeTaxRate.GetTaxRates() then
            exit(false);

        StripeSubscription.SetCurrentKey(SystemCreatedAt);
        if StripeSubscription.FindLast() then
            DataRefreshed := StripeSubscription.RefreshSubscription()
        else
            DataRefreshed := StripeSubscription.CreateTrialSubscription();

        if DataRefreshed then begin
            StripeSetup."Last Synchronized" := CurrentDateTime();
            StripeSubscription.SetLastSubscriptionPeriodStartOnStripeSetup(StripeSetup);
            StripeSetup.Modify();
        end;

        exit(DataRefreshed);
    end;

    local procedure ShouldRefreshStripeData(var StripeSetup: Record "NPR Stripe Setup") ShouldRefresh: Boolean
    var
        Handled: Boolean;
    begin
        OnBeforeShouldRefreshStripeData(StripeSetup, ShouldRefresh, Handled);
        if Handled then
            exit(ShouldRefresh);

        StripeSetup.GetSetup();
        ShouldRefresh := true;
        if StripeSetup."Last Synchronized" <> 0DT then
            ShouldRefresh := (CurrentDateTime() - StripeSetup."Last Synchronized") > (1 * 60 * 30 * 1000);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShouldRefreshStripeData(var StripeSetup: Record "NPR Stripe Setup"; var ReturnValue: Boolean; var Handled: Boolean)
    begin
    end;
}
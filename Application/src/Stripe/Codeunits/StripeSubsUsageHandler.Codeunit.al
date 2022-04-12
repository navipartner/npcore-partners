codeunit 6059813 "NPR Stripe Subs Usage Handler"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Session", 'OnInitialize', '', false, false)]
    local procedure HandleOnInitialize()
    begin
        UpdateSubscriptionUsage();
    end;

    local procedure UpdateSubscriptionUsage()
    var
        StripeSetup: Record "NPR Stripe Setup";
        StripeSubscription: Record "NPR Stripe Subscription";
        StripePOSUser: Record "NPR Stripe POS User";
    begin
        if not StripeSetup.IsStripeActive() then
            exit;

        StripeSubscription.SetCurrentKey(SystemCreatedAt);
        if StripeSubscription.FindLast() then begin
            if not StripeSubscription.RefreshSubscription() then
                exit;

            StripeSubscription.UpdateLastSubscriptionPeriodStartOnStripeSetup();
            if StripePOSUser.FindSet() then
                repeat
                    if ShouldUpdateSubscriptionUsage(StripeSubscription, StripePOSUser) then begin
                        InserSubscriptionUsage(StripeSubscription, StripePOSUser);
                        StripeSubscription.UpdateSubscriptionUsage(1);
                    end;
                until StripePOSUser.Next() = 0;
        end;
    end;

    local procedure ShouldUpdateSubscriptionUsage(StripeSubscription: Record "NPR Stripe Subscription"; StripePOSUser: Record "NPR Stripe POS User") ShouldUpdate: Boolean
    var
        StripeSubscriptionUsage: Record "NPR Stripe Subscription Usage";
        Handled: Boolean;
    begin
        OnBeforeShouldUpdateSubscriptionUsage(StripeSubscription, StripePOSUser, ShouldUpdate, Handled);
        if Handled then
            exit(ShouldUpdate);

        ShouldUpdate := not StripeSubscriptionUsage.Get(StripeSubscription.Id, StripePOSUser."User ID", StripeSubscription."Current Period Start");
    end;

    local procedure InserSubscriptionUsage(StripeSubscription: Record "NPR Stripe Subscription"; StripePOSUser: Record "NPR Stripe POS User")
    var
        StripeSubscriptionUsage: Record "NPR Stripe Subscription Usage";
    begin
        StripeSubscriptionUsage.CopyFromSubscription(StripeSubscription);
        StripeSubscriptionUsage.Validate("POS User ID", StripePOSUser."User ID");
        StripeSubscriptionUsage.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeShouldUpdateSubscriptionUsage(StripeSubscription: Record "NPR Stripe Subscription"; StripePOSUser: Record "NPR Stripe POS User"; var ShouldUpdate: Boolean; var Handled: Boolean)
    begin
    end;
}
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
        StripeSubscription: Record "NPR Stripe Subscription";
        StripePOSUser: Record "NPR Stripe POS User";
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        // Following line makes sure that subscription is checked only for app installed in production SaaS environment. 
        // Apps in sandbox do not integrate with Stripe in this case.
        // Note: if need to test this in own container comment the code below
        if not EnvironmentInformation.IsProduction() or not EnvironmentInformation.IsSaaS() then
            exit;

        CheckIsCurrUserPOSUser();

        StripeSubscription.SetCurrentKey(SystemCreatedAt);
        if StripeSubscription.FindLast() then begin
            if not StripeSubscription.RefreshSubscription() then
                exit;

            StripeSubscription.UpdateLastSubscriptionPeriodStartOnStripeSetup();

            OnBeforeUpdateSubscriptionUsage();
            StripePOSUser.FindSet();

            repeat
                if ShouldUpdateSubscriptionUsage(StripeSubscription, StripePOSUser) then begin
                    InserSubscriptionUsage(StripeSubscription, StripePOSUser);
                    StripeSubscription.UpdateSubscriptionUsage(1);
                end;
            until StripePOSUser.Next() = 0;
        end;
    end;

    local procedure CheckIsCurrUserPOSUser()
    var
        StripePOSUser: Record "NPR Stripe POS User";
        POSUserDoesNotExistErr: Label 'User %1 must be defined as %2.', Comment = '%1 - current User Id, %2 - Stripe POS User table caption';
    begin
        if not StripePOSUser.Get(UserId) then
            Error(POSUserDoesNotExistErr, UserId, StripePOSUser.TableCaption);
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateSubscriptionUsage()
    begin
    end;
}
codeunit 6059813 "NPR Stripe Subs Usage Handler"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteTag = '2025-09-03';
    ObsoleteReason = 'Not used. Using POS Billing API integration to control licenses.';

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
        User: Record User;
        StripeSubscriptionUsage: Record "NPR Stripe Subscription Usage";
#IF NOT (BC17 or BC18 or BC19 or BC20)
        AzureADUserManagement: Codeunit "Azure AD User Management";
#ENDIF
        Handled: Boolean;
    begin
        OnBeforeShouldUpdateSubscriptionUsage(StripeSubscription, StripePOSUser, ShouldUpdate, Handled);
        if Handled then
            exit(ShouldUpdate);

        User.SetRange("User Name", StripePOSUser."User ID");
        if not User.FindFirst() then
            exit(false);

        ShouldUpdate := not StripeSubscriptionUsage.Get(StripeSubscription.Id, StripePOSUser."User ID", StripeSubscription."Current Period Start");
#IF NOT (BC17 or BC18 or BC19 or BC20)
        if ShouldUpdate then
            ShouldUpdate := not AzureADUserManagement.IsUserDelegated(User."User Security ID");
#ENDIF
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
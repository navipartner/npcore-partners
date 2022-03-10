codeunit 6059807 "NPR Stripe Integration"
{
    Access = Internal;

    // following areas are restricting app usage if the app subscription is not active or user is not defined as app user

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Conf./Personalization Mgt.", 'OnRoleCenterOpen', '', true, true)]
    local procedure CheckSubscriptionStatus_OnOpenRoleCenter()
    begin
        OnCheckSubscriptionStatus(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Stripe Subs Usage Handler", 'OnBeforeUpdateSubscriptionUsage', '', false, false)]
    local procedure CheckSubscriptionStatus_OnBeforeUpdateSubscriptionUsage()
    begin
        OnCheckSubscriptionStatus(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCheckSubscriptionStatus(ThrowSubscriptionIsNotValidErr: Boolean)
    begin
    end;
}
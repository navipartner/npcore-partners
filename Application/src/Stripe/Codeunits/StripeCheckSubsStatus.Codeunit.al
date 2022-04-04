codeunit 6059803 "NPR Stripe Check Subs. Status"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Stripe Integration", 'OnCheckSubscriptionStatus', '', false, false)]
    local procedure CheckSubscriptionStatus(ThrowSubscriptionIsNotValidErr: Boolean)
    var
        StripeSetup: Record "NPR Stripe Setup";
        StripeSubscription: Record "NPR Stripe Subscription";
    begin
        if not StripeSetup.IsStripeActive() then
            exit;

        if not StripeSetup.RefreshData() then
            exit;

        StripeSubscription.SetCurrentKey(SystemCreatedAt);
        StripeSubscription.FindLast();

        case StripeSubscription.Status of
            StripeSubscription.Status::trialing:
                OnTrialExpires(StripeSubscription.TrialDaysLeft());
            StripeSubscription.Status::active:
                if StripeSubscription.CurrentPeriodDaysLeft() <= 30 then
                    OnSubscriptionPeriodEnds(StripeSubscription.CurrentPeriodDaysLeft());
            StripeSubscription.Status::past_due:
                OnSubscriptionPastDue(StripeSubscription.PastDueDays());
            StripeSubscription.Status::canceled:
                OnSubscriptionCanceled(ThrowSubscriptionIsNotValidErr);
            StripeSubscription.Status::unpaid:
                OnSubscriptionUnpaid(ThrowSubscriptionIsNotValidErr);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnTrialExpires(TrialDaysLeft: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSubscriptionPeriodEnds(CurrentPeriodDaysLeft: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSubscriptionPastDue(PastDueDays: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSubscriptionCanceled(ThrowSubscriptionIsNotValidErr: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSubscriptionUnpaid(ThrowSubscriptionIsNotValidErr: Boolean)
    begin
    end;
}
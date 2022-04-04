codeunit 6059815 "NPR Stripe Notification Mgt."
{
    Access = Internal;

    var
        TokSubscriptionNotificationIdLbl: Label 'f82654ca-37af-4a19-9463-21ef6abf2f8b', Locked = true;
        ContactUsActionLbl: Label 'Contact us';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Stripe Check Subs. Status", 'OnTrialExpires', '', false, false)]
    local procedure HandleOnTrialExpires(TrialDaysLeft: Integer)
    begin
        CreateAndSendTrialExpiresNotification(TrialDaysLeft);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Stripe Check Subs. Status", 'OnSubscriptionPastDue', '', false, false)]
    local procedure HandleOnSubscriptionPastDue(PastDueDays: Integer)
    begin
        CreateAndSendSubscriptionPastDueNotification(PastDueDays);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Stripe Check Subs. Status", 'OnSubscriptionCanceled', '', false, false)]
    local procedure HandleOnSubscriptionCanceled(ThrowSubscriptionIsNotValidErr: Boolean)
    begin
        ErrorIfThrowSubscriptionCanceled(ThrowSubscriptionIsNotValidErr);
        CreateAndSendSubscriptionCanceledNotification();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Stripe Check Subs. Status", 'OnSubscriptionUnpaid', '', false, false)]
    local procedure HandleOnSubscriptionUnpaid(ThrowSubscriptionIsNotValidErr: Boolean)
    begin
        ErrorIfThrowSubscriptionUnpaid(ThrowSubscriptionIsNotValidErr);
        CreateAndSendSubscriptionUnpaidNotification();
    end;

    local procedure CreateAndSendTrialExpiresNotification(TrialDaysLeft: Integer)
    var
        TrialNotification: Notification;
        TokTrialNotificationIdLbl: Label 'f8d9fdb3-0fcd-4515-b687-86a17050ef90', Locked = true;
        ActivateSubscriptionActionLbl: Label 'Activate subscription...';
        TrialExpiresMsg: Label 'Thank you for trying out the NP Retail POS app. Your trial period expires in %1 days. Do you want to activate a subscription?', Comment = '%1 - Trial Days Left';
    begin
        if not GuiAllowed() then
            exit;

        TrialNotification.Id := TokTrialNotificationIdLbl;
        TrialNotification.Message := StrSubstNo(TrialExpiresMsg, TrialDaysLeft);
        TrialNotification.Scope := NotificationScope::LocalScope;
        TrialNotification.AddAction(ActivateSubscriptionActionLbl, Codeunit::"NPR Stripe Notification Mgt.", 'ActivateSubscription');
        TrialNotification.Send();
    end;

    local procedure CreateAndSendSubscriptionPastDueNotification(PastDueDays: Integer)
    var
        SubscriptionNotification: Notification;
        SubscriptionPastDueMsg: Label 'The payment of your subscription for the NP Retail POS app is %1 days overdue. Please contact us to solve this issue.', Comment = '%1 - Past Due Days';
    begin
        if not GuiAllowed() then
            exit;

        SubscriptionNotification.Id := TokSubscriptionNotificationIdLbl;
        SubscriptionNotification.Message := StrSubstNo(SubscriptionPastDueMsg, PastDueDays);
        SubscriptionNotification.Scope := NotificationScope::LocalScope;
        SubscriptionNotification.AddAction(ContactUsActionLbl, Codeunit::"NPR Stripe Notification Mgt.", 'ContactUs');
        SubscriptionNotification.Send();
    end;

    local procedure CreateAndSendSubscriptionCanceledNotification()
    var
        SubscriptionNotification: Notification;
        ReactivateSubscriptionActionLbl: Label 'Reactivate subscription...';
        SubscriptionCanceledMsg: Label 'Your subscription for the NP Retail POS app has been canceled. Please reactivate a subscription or contact us to solve this issue.';
    begin
        if not GuiAllowed() then
            exit;

        SubscriptionNotification.Id := TokSubscriptionNotificationIdLbl;
        SubscriptionNotification.Message := SubscriptionCanceledMsg;
        SubscriptionNotification.Scope := NotificationScope::LocalScope;
        SubscriptionNotification.AddAction(ReactivateSubscriptionActionLbl, Codeunit::"NPR Stripe Notification Mgt.", 'ReactivateSubscription');
        SubscriptionNotification.AddAction(ContactUsActionLbl, Codeunit::"NPR Stripe Notification Mgt.", 'ContactUs');
        SubscriptionNotification.Send();
    end;

    local procedure CreateAndSendSubscriptionUnpaidNotification()
    var
        SubscriptionNotification: Notification;
        PaySubscriptionActionLbl: Label 'Pay subscription...';
        SubscriptionUnpaidMsg: Label 'Your subscription for the NP Retail POS app has not been paid. Please proceed with payment for your subscription or contact us to solve this issue.';
    begin
        if not GuiAllowed() then
            exit;

        SubscriptionNotification.Id := TokSubscriptionNotificationIdLbl;
        SubscriptionNotification.Message := SubscriptionUnpaidMsg;
        SubscriptionNotification.Scope := NotificationScope::LocalScope;
        SubscriptionNotification.AddAction(PaySubscriptionActionLbl, Codeunit::"NPR Stripe Notification Mgt.", 'PaySubscription');
        SubscriptionNotification.AddAction(ContactUsActionLbl, Codeunit::"NPR Stripe Notification Mgt.", 'ContactUs');
        SubscriptionNotification.Send();
    end;

    local procedure ErrorIfThrowSubscriptionCanceled(ThrowSubscriptionIsNotValidErr: Boolean)
    var
        SubscriptionCanceledErr: Label 'Your subscription for the NP Retail POS app has been canceled. Please reactivate a subscription or contact us to solve this issue.';
    begin
        if ThrowSubscriptionIsNotValidErr then
            Error(SubscriptionCanceledErr)
    end;

    local procedure ErrorIfThrowSubscriptionUnpaid(ThrowSubscriptionIsNotValidErr: Boolean)
    var
        SubscriptionUnpaidErr: Label 'Your subscription for the NP Retail POS app has not been paid. Please proceed with payment for your subscription or contact us to solve this issue.';
    begin
        if ThrowSubscriptionIsNotValidErr then
            Error(SubscriptionUnpaidErr);
    end;

    internal procedure ActivateSubscription(SubscriptionNotification: Notification)
    begin
        Page.RunModal(Page::"NPR Stripe Create Subs. Wiz.");
    end;

    internal procedure ReactivateSubscription(SubscriptionNotification: Notification)
    begin
        Page.RunModal(Page::"NPR Stripe Create Subs. Wiz.");
    end;

    internal procedure PaySubscription(SubscriptionNotification: Notification)
    var
        StripeCustomer: Record "NPR Stripe Customer";
        CustomerPortalURL: Text;
    begin
        StripeCustomer.FindFirst();
        if StripeCustomer.GetCustomerPortalURL(CustomerPortalURL) then
            Hyperlink(CustomerPortalURL);
    end;

    internal procedure ContactUs(SubscriptionNotification: Notification)
    var
        ContactUsURLTxt: Label 'https://www.navipartner.com/contact-us/', Locked = true;
    begin
        Hyperlink(ContactUsURLTxt);
    end;
}
codeunit 6185060 "NPR UPG Subscriptions"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        CreateSubscriptions();
        SetMaxRecurringPaymentProcessingTryCount();
        SetMaxSubscriptionRequestProcessingTryCount();
        ScheduleSubscriptionRequestCreationJobQueue();
        ScheduleSubscriptionPaymentRequestProcessingJobQueue();
        ScheduleSubscriptionRequestProcessingJobQueue();
        UpdateSubscriptionAutoRenewStatus();
    end;

    internal procedure CreateSubscriptions()
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin
        UpgradeStep := 'CreateSubscriptions';
        if HasUpgradeTag() then
            exit;

        if Membership.FindSet() then
            repeat
                MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
                MembershipEntry.SetRange(Blocked, false);
                MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
                if MembershipEntry.FindLast() then
                    SubscriptionMgtImpl.UpdateMembershipSubscriptionDetails(Membership, MembershipEntry);
            until Membership.Next() = 0;

        SetUpgradeTag();
    end;

    internal procedure ScheduleSubscriptionRequestCreationJobQueue()
    var
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        UpgradeStep := 'ScheduleSubscriptionRequestCreationJobQueue';
        if HasUpgradeTag() then
            exit;

        SubscrRequestUtils.ScheduleSubscriptionRequestCreationJobQueueEntry();

        SetUpgradeTag();
    end;

    internal procedure ScheduleSubscriptionRequestProcessingJobQueue()
    var
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        UpgradeStep := 'ScheduleSubscriptionRequestProcessingJobQueue';
        if HasUpgradeTag() then
            exit;

        SubscrRequestUtils.ScheduleSubscriptionRequestProcessingJobQueueEntry();

        SetUpgradeTag();
    end;

    internal procedure ScheduleSubscriptionPaymentRequestProcessingJobQueue()
    var
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        UpgradeStep := 'ScheduleSubscriptionPaymentRequestProcessingJobQueue';
        if HasUpgradeTag() then
            exit;

        SubsPayRequestUtils.ScheduleSubscriptionPaymentRequestProcessingJobQueueEntryScheduled();

        SetUpgradeTag();
    end;

    local procedure SetMaxRecurringPaymentProcessingTryCount()
    var
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        UpgradeStep := 'SetMaxRecurringPaymentProcessingTryCount';
        if HasUpgradeTag() then
            exit;

        RecurPaymSetup.Reset();
        RecurPaymSetup.SetRange("Max. Pay. Process Try Count", 0);
        if not RecurPaymSetup.IsEmpty then
            RecurPaymSetup.ModifyAll("Max. Pay. Process Try Count", 5);

        SetUpgradeTag();
    end;

    local procedure SetMaxSubscriptionRequestProcessingTryCount()
    var
        NPPaySetup: Record "NPR Adyen Setup";
    begin
        UpgradeStep := 'SetMaxSubscriptionRequestProcessingTryCount';
        if HasUpgradeTag() then
            exit;

        if NPPaySetup.Get() then
            if NPPaySetup."Max Sub Req Process Try Count" = 0 then begin
                NPPaySetup."Max Sub Req Process Try Count" := 2;
                NPPaySetup.Modify();
            end;

        SetUpgradeTag();
    end;

    local procedure UpdateSubscriptionAutoRenewStatus()
    var
        Subscription: Record "NPR MM Subscription";
        Membership: Record "NPR MM Membership";
    begin
        UpgradeStep := 'UpdateSubscriptionAutoRenewStatus';
        if HasUpgradeTag() then
            exit;

        Subscription.Reset();
        if Subscription.FindSet() then
            repeat
                Membership.SetLoadFields("Auto-Renew");
                if Membership.Get(Subscription."Membership Entry No.") then
                    if Subscription."Auto-Renew" <> Membership."Auto-Renew" then begin
                        Subscription."Auto-Renew" := Membership."Auto-Renew";
                        Subscription.Modify(true);
                    end;
            until Subscription.Next() = 0;

        SetUpgradeTag();
    end;


    local procedure HasUpgradeTag(): Boolean
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", UpgradeStep)) then
            exit(true);
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Subscriptions', UpgradeStep);
    end;

    local procedure SetUpgradeTag()
    begin
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Subscriptions", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
}
codeunit 6185124 "NPR Subscriptions Install"
{
    Access = Internal;
    Subtype = Install;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnInstallAppPerCompany()
    begin
        ScheduleSubscriptionRequestCreationJobQueue();
        ScheduleSubscriptionPaymentRequestProcessingJobQueue();
        ScheduleSubscriptionRequestProcessingJobQueue();
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
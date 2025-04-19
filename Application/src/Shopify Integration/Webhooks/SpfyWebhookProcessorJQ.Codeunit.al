#if not BC17
codeunit 6184953 "NPR Spfy Webhook Processor JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SpfyWebhookNotification: Record "NPR Spfy Webhook Notification";
        SpfyWebhookNotifHandler: Codeunit "NPR Spfy Webhook Notif.Handler";
        RecRef: RecordRef;
    begin
        SelectLatestVersion();
        if Format(Rec."Record ID to Process") <> '' then
            if Rec."Record ID to Process".TableNo() = Database::"NPR Spfy Webhook Notification" then begin
                RecRef.Get(Rec."Record ID to Process");
                RecRef.SetRecFilter();
                RecRef.SetTable(SpfyWebhookNotification);
            end;
        SpfyWebhookNotification.SetRange(Status, SpfyWebhookNotification.Status::New, SpfyWebhookNotification.Status::Error);
        SpfyWebhookNotifHandler.ProcessWebhookNotifications(SpfyWebhookNotification, false);
    end;

    internal procedure RegisterShopifyWebhookNotificationProcessingJQ(Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        ShopifyWebhookProcessorLbl: Label 'Shopify webhook notification processor';
    begin
        if not Enable then begin
            if not SpfyWebhookSubscription.IsEmpty() then
                exit;
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId());
        end else
            if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                CurrCodeunitId(),
                '',
                ShopifyWebhookProcessorLbl,
                JobQueueMgt.NowWithDelayInSeconds(60),
                1,
                '',
                JobQueueEntry)
            then
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Spfy Webhook Processor JQ");
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RefreshJobQueueEntry()
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
    begin
        If ShopifySetup.IsEmpty() then
            exit;
        RegisterShopifyWebhookNotificationProcessingJQ(not SpfyWebhookSubscription.IsEmpty());
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnCheckIfIsNPRecurringJob', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnCheckIfIsNPRecurringJob, '', false, false)]
#endif
    local procedure CheckIfIsNPRecurringJob(JobQueueEntry: Record "Job Queue Entry"; var IsNpJob: Boolean; var Handled: Boolean)
    begin
        if Handled then
            exit;
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and
           (JobQueueEntry."Object ID to Run" = CurrCodeunitId())
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;
}
#endif
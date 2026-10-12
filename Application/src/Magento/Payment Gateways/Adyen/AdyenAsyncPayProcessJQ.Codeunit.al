codeunit 6248668 "NPR Adyen Async Pay ProcessJQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        AdyenAsyncPayProcesFeature: Codeunit "NPR AdyenAsyncPmtProcesFeature";
        StartTime: DateTime;
        MaxDuration: Duration;
    begin
        if not AdyenAsyncPayProcesFeature.IsFeatureEnabled() then
            exit;
        StartTime := CurrentDateTime();
        MaxDuration := 6 * 60 * 60 * 1000; // 6h
        repeat
            if EcomJobManagement.ShouldSoftExit(Rec.ID) then
                exit;
            Process(CurrentDateTime());
            Commit();
            if Rec."Recurring Job" then
                Sleep(1000);
        until (not Rec."Recurring Job") or EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);
    end;

    /// <summary>
    /// Processes new webhooks, retries failed ones after the backoff, and cancels failed ones older than the give-up age.
    /// An unmatched new webhook is checked again at most once a minute.
    /// The retry backoffs and the give-up age use ReferenceDateTime. The grace period for unmatched webhooks is checked
    /// in the webhook handler against the current time.
    /// </summary>
    internal procedure Process(ReferenceDateTime: DateTime)
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        Sentry: Codeunit "NPR Sentry";
        ScopeStarted: Boolean;
    begin
        SetCaptureEventFilter(AdyenWebhook);
        AdyenWebhook.SetRange(Status, AdyenWebhook.Status::New);
        AdyenWebhook.SetFilter("Processed Date", '=%1|<%2', 0DT, ReferenceDateTime - UnmatchedRetryBackoff());
        ProcessWebhooks(AdyenWebhook, Sentry, ScopeStarted);

        SetCaptureEventFilter(AdyenWebhook);
        AdyenWebhook.SetRange(Status, AdyenWebhook.Status::Error);
        AdyenWebhook.SetFilter("Processed Date", '<%1', ReferenceDateTime - ErrorRetryBackoff());
        AdyenWebhook.SetFilter(SystemCreatedAt, '>=%1', ReferenceDateTime - ErrorGiveUpAge());
        ProcessWebhooks(AdyenWebhook, Sentry, ScopeStarted);

        if ScopeStarted then
            Sentry.FinalizeScope();

        // Runs last so that no write transaction is open while the passes above call Codeunit.Run.
        CancelExpiredErrorWebhooks(ReferenceDateTime);
    end;

    local procedure SetCaptureEventFilter(var AdyenWebhook: Record "NPR Adyen Webhook")
    begin
        AdyenWebhook.Reset();
        AdyenWebhook.SetCurrentKey("Event Code", Status);
        AdyenWebhook.SetFilter("Event Code", '%1|%2', AdyenWebhook."Event Code"::CAPTURE, AdyenWebhook."Event Code"::CAPTURE_FAILED);
    end;

    local procedure ProcessWebhooks(var AdyenWebhook: Record "NPR Adyen Webhook"; var Sentry: Codeunit "NPR Sentry"; var ScopeStarted: Boolean)
    var
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
    begin
        if not AdyenWebhook.FindSet() then
            exit;
        if not ScopeStarted then begin
            Sentry.InitScopeAndTransaction('Asynchronous Adyen Payment Processing', 'bc.adyen.async.pmt.processing');
            ScopeStarted := true;
        end;
        repeat
            if not WebhookProcessing.Run(AdyenWebhook) then
                LogWebhookProcessingError(AdyenWebhook);
        until AdyenWebhook.Next() = 0;
    end;

    local procedure CancelExpiredErrorWebhooks(ReferenceDateTime: DateTime)
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenWebhookToCancel: Record "NPR Adyen Webhook";
        AdyenManagement: Codeunit "NPR Adyen Management";
        GiveUpLbl: Label 'The webhook request was canceled because it could not be processed within %1 hours of receipt.', Comment = '%1 = number of hours';
    begin
        SetCaptureEventFilter(AdyenWebhook);
        AdyenWebhook.SetRange(Status, AdyenWebhook.Status::Error);
        AdyenWebhook.SetFilter(SystemCreatedAt, '<%1', ReferenceDateTime - ErrorGiveUpAge());
        if not AdyenWebhook.FindSet() then
            exit;
        repeat
            AdyenWebhookToCancel.ReadIsolation := IsolationLevel::UpdLock;
            // The status is re-read under lock because the page Process action can change it concurrently.
            if AdyenWebhookToCancel.Get(AdyenWebhook."Entry No.") then
                if AdyenWebhookToCancel.Status = AdyenWebhookToCancel.Status::Error then begin
                    AdyenWebhookToCancel.Status := AdyenWebhookToCancel.Status::Canceled;
                    AdyenWebhookToCancel."Processed Date" := CurrentDateTime();
                    AdyenWebhookToCancel.Modify();
                    AdyenManagement.CreateGeneralLog(Enum::"NPR Adyen Webhook Log Type"::Process, false, StrSubstNo(GiveUpLbl, ErrorGiveUpHours()), AdyenWebhookToCancel."Entry No.");
                end;
        until AdyenWebhook.Next() = 0;
    end;

    local procedure LogWebhookProcessingError(AdyenWebhook: Record "NPR Adyen Webhook")
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        Sentry.AddTransactionTag('adyen.webhook.event.reference', Format(AdyenWebhook."PSP Reference"));
        Sentry.AddTransactionTag('adyen.webhook.event.code', Format(AdyenWebhook."Event Code"));
        Sentry.AddTransactionTag('adyen.webhook.merchant.account', Format(AdyenWebhook."Merchant Account Name"));
        Sentry.AddLastErrorInEnglish();
    end;

    internal procedure GetJQDescription(): Text
    var
        DescLbl: Label 'Process Adyen CAPTURE/CAPTURE_FAILED webhooks to finalize async capture';
    begin
        exit(DescLbl);
    end;

    internal procedure GetCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Adyen Async Pay ProcessJQ");
    end;

    local procedure UnmatchedGracePeriod(): Duration
    begin
        exit(15 * 60 * 1000); // 15 min
    end;

    internal procedure IsUnmatchedGraceExpired(ReceivedAt: DateTime; ReferenceDateTime: DateTime): Boolean
    begin
        exit(ReceivedAt < ReferenceDateTime - UnmatchedGracePeriod());
    end;

    local procedure UnmatchedRetryBackoff(): Duration
    begin
        exit(60 * 1000); // 1 min
    end;

    local procedure ErrorRetryBackoff(): Duration
    begin
        exit(5 * 60 * 1000); // 5 min
    end;

    local procedure ErrorGiveUpAge(): Duration
    begin
        exit(ErrorGiveUpHours() * 60 * 60 * 1000);
    end;

    local procedure ErrorGiveUpHours(): Integer
    begin
        exit(24);
    end;

    internal procedure ScheduleJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        JobQueueEntry.SetCurrentKey("Object Type to Run", "Object ID to Run");
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", GetCodeunitId());
        if JobQueueEntry.FindFirst() then begin
            ReassignMonitoring(JobQueueEntry);
            exit;
        end;

        JobQueueMgt.SetJobTimeout(7, 0); // shouldn't be less than loop max duration
        JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            GetCodeunitId(),
            '',
            GetJQDescription(),
            CreateDateTime(Today(), 070000T),
            1,
            '',
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);

        ReassignMonitoring(JobQueueEntry);
    end;

    local procedure ReassignMonitoring(var JobQueueEntry: Record "Job Queue Entry")
    var
        MonitoredJQMgt: Codeunit "NPR Monitored Job Queue Mgt.";
    begin
        MonitoredJQMgt.AssignJobQueueEntryToManagedAndMonitored(false, true, JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnBeforeValidateCreateMissingCustomJQs, '', false, false)]
    local procedure SkipValidateCreateMissingCustomJQs(JobQueueEntry: Record "Job Queue Entry"; var SkipValidation: Boolean)
    begin
        if (JobQueueEntry."Object Type to Run" = JobQueueEntry."Object Type to Run"::Codeunit) and (JobQueueEntry."Object ID to Run" = GetCodeunitId()) then
            SkipValidation := true;
    end;
}

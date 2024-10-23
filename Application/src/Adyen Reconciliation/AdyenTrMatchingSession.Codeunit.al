codeunit 6184786 "NPR Adyen Tr. Matching Session"
{
    Access = Internal;

    trigger OnRun()
    var
        RecWebhookRequests: Record "NPR AF Rec. Webhook Request";
        RecWebhookRequests2: Record "NPR AF Rec. Webhook Request";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenManagement: Codeunit "NPR Adyen Management";
        WebhookProcessing: Codeunit "NPR Adyen Webhook Processing";
        GeneralLogType: Enum "NPR Adyen Webhook Log Type";
        ReconciliationLogType: Enum "NPR Adyen Rec. Log Type";
    begin
        AdyenWebhook.Reset();
        AdyenWebhook.SetRange("Event Code", AdyenWebhook."Event Code"::REPORT_AVAILABLE);
        AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
        if AdyenWebhook.FindSet() then
            repeat
                if not WebhookProcessing.Run(AdyenWebhook) then begin
                    AdyenManagement.CreateGeneralLog(GeneralLogType::Error, false, GetLastErrorText(), AdyenWebhook."Entry No.");
                    AdyenWebhook.Status := AdyenWebhook.Status::Error;
                    AdyenWebhook.Modify();
                    Commit();
                end;
            until AdyenWebhook.Next() = 0;

        // Process all not processed Webhook Entries
        RecWebhookRequests.Reset();
        RecWebhookRequests.SetRange(Processed, false);

        if RecWebhookRequests.IsEmpty() then
            exit;

        if RecWebhookRequests.FindSet() then
            repeat
                RecWebhookRequests2 := RecWebhookRequests;
                if not Codeunit.Run(Codeunit::"NPR Adyen Rec. Report Process", RecWebhookRequests2) then begin
                    RecWebhookRequests2.Find();
                    RecWebhookRequests2.Processed := true;
                    RecWebhookRequests2."Processing Status" := RecWebhookRequests2."Processing Status"::Failed;
                    RecWebhookRequests2.Modify();
                    AdyenManagement.CreateReconciliationLog(ReconciliationLogType::"Background Session", false, GetLastErrorText(), RecWebhookRequests2.ID);
                    Commit();
                end;
            until RecWebhookRequests.Next() = 0;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RefreshReconciliationJob()
    begin
        SetupReconciliationTaskProcessingJobQueue();
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
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

    procedure SetupReconciliationTaskProcessingJobQueue()
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        Clear(AdyenSetup);
        AdyenSetup.GetRecordOnce();
        SetupReconciliationTaskProcessingJobQueue(AdyenSetup."Enable Reconciliation");
    end;

    procedure SetupReconciliationTaskProcessingJobQueue(Enable: Boolean)
    var
        ProccessPostPaymentLine: Label 'Process Reconciliation Documents.';
        JobQueueEntry: Record "Job Queue Entry";
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        if Enable then
            AdyenManagement.CreateAutoRescheduleAdyenJob(Codeunit::"NPR Adyen Tr. Matching Session", ProccessPostPaymentLine, 300)
        else begin
            JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
            JobQueueEntry.SetRange("Object ID to Run", CurrCodeunitID());
            if JobQueueEntry.FindSet() then
                repeat
                    JobQueueEntry.Cancel();
                    Commit();
                until JobQueueEntry.Next() = 0;
        end;
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR Adyen Tr. Matching Session");
    end;
}

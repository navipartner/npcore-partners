codeunit 6185103 "NPR MM Subs Pay Request Utils"
{
    Access = Internal;

    internal procedure ProcessSubsPayRequestWithConfirmation(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean)
    var
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmLbl: Label 'Are you sure you want to process entry no. %1?', Comment = '%1 Entry No.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmLbl, SubscrPaymentRequest."Entry No."), true) then
            exit;
        ClearLastError();
        SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
        if not SubscrPaymentIHandler.ProcessPaymentRequest(SubscrPaymentRequest, SkipTryCountUpdate, true) then
            Error(GetLastErrorText());

        //Refresh record after processing
        SubscrPaymentRequest.Get(SubscrPaymentRequest.RecordId);
    end;

    local procedure SetSubscrPaymentRequestStatusWithConfirmation(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; NewStatus: Enum "NPR MM Payment Request Status"; LogChange: Boolean) Success: Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
        NewStatusConfirmLbl: Label 'Are you sure you want to set the status of entry no. %1 to %2?', Comment = '%1 - entry no., %2 - Status';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(NewStatusConfirmLbl, SubscrPaymentRequest."Entry No.", NewStatus), true) then
            exit;
        SetSubscrPaymentRequestStatus(SubscrPaymentRequest, NewStatus, LogChange);

        Success := true;
    end;

    internal procedure SetSubscrPaymentRequestStatus(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; NewStatus: Enum "NPR MM Payment Request Status"; LogChange: Boolean)
    var
        SubsPayReqLogEntry: Record "NPR MM Subs Pay Req Log Entry";
        SubsPayReqLogUtils: Codeunit "NPR MM Subs Pay Req Log Utils";
        SubscrReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
    begin
        if SubscrPaymentRequest.Status = NewStatus then
            exit;
        SubscrPaymentRequest.Validate(Status, NewStatus);
        SubscrPaymentRequest.Modify(true);
        if NewStatus = NewStatus::Cancelled then
            SubscrReversalMgt.CancelReversal(SubscrPaymentRequest);

        if LogChange then
            SubsPayReqLogUtils.LogEntry(SubscrPaymentRequest, '', '', true, SubsPayReqLogEntry);
    end;

    internal procedure SetSubscrPaymentRequestStatusCancelled(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SkipTryCountUpdate: Boolean)
    var
        SubscrPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
        CannotCancelCapturedErr: Label 'Captured subscription payment requests cannot be cancelled. Please request a refund instead.';

    begin
        if SubscrPaymentRequest.Status = SubscrPaymentRequest.Status::Captured then
            Error(CannotCancelCapturedErr);

        if not SetSubscrPaymentRequestStatusWithConfirmation(SubscrPaymentRequest, Enum::"NPR MM Payment Request Status"::Cancelled, false) then
            exit;

        SubscrPaymentIHandler := SubscrPaymentRequest.PSP;
        if not SubscrPaymentIHandler.ProcessPaymentRequest(SubscrPaymentRequest, SkipTryCountUpdate, true) then
            Error(GetLastErrorText());

        //Refresh record after processing
        SubscrPaymentRequest.Get(SubscrPaymentRequest.RecordId);
    end;

    local procedure CreateSubscriptionPaymentRequestProcessingJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        SubscriptionsJobQueueCategoryCode: Code[10];
        DescriptionLbl: Label 'Processes subscription payment requests';
        StartDateTime: DateTime;
    begin
        StartDateTime := JobQueueManagement.NowWithDelayInSeconds(5);
        SubscriptionsJobQueueCategoryCode := SubscriptionMgtImpl.GetSubscriptionsJobQueueCategoryCode();
        JobQueueManagement.SetMaxNoOfAttemptsToRun(999999999);
        JobQueueManagement.SetRerunDelay(10);
        JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 20, '');
        exit(
            JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR MM Subscr. Pay Req Proc JQ",
                '',
                DescriptionLbl,
                StartDateTime,
                120,
                SubscriptionsJobQueueCategoryCode,
                JobQueueEntry));
    end;

    internal procedure ScheduleSubscriptionPaymentRequestProcessingJobQueueEntryScheduled()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if CreateSubscriptionPaymentRequestProcessingJobQueueEntry(JobQueueEntry) then
            JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure ResetProcessTryCount(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    begin
        SubscrPaymentRequest."Process Try Count" := 0;
        SubscrPaymentRequest.Modify(true)
    end;

    internal procedure ResetProcessTryCountWithConfirmation(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ResetTryCountConfirmationLbl: Label 'Are you sure you want to reset the process try count of entry no. %1?', Comment = '%1 - subscription request entry no.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ResetTryCountConfirmationLbl, SubscrPaymentRequest."Entry No."), true) then
            exit;

        ResetProcessTryCount(SubscrPaymentRequest);
    end;
}
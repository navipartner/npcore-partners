codeunit 6185102 "NPR MM Subscr. Request Utils"
{
    Access = Internal;

    internal procedure ProcessSubscriptionRequestWithConfirmation(var SubscrRequest: Record "NPR MM Subscr. Request"; SkipTryCountUpdate: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ConfirmLbl: Label 'Are you sure you want to process entry no. %1?', Comment = '%1 Entry No.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ConfirmLbl, SubscrRequest."Entry No."), true) then
            exit;

        ProcessSubscriptionRequest(SubscrRequest, SkipTryCountUpdate);
    end;

    local procedure ProcessSubscriptionRequest(var SubscrRequest: Record "NPR MM Subscr. Request"; SkipTryCountUpdate: Boolean)
    var
        SubscrRenewProcess: Codeunit "NPR MM Subscr. Renew: Process";
    begin
        if not SubscrRenewProcess.ProcessSubscriptionRequest(SubscrRequest, SkipTryCountUpdate, true) then
            Error(GetLastErrorText());

        //Refresh Record
        if not SubscrRequest.Get(SubscrRequest.RecordId) then
            exit;
    end;

    local procedure SetSubscriptionRequestStatus(var SubscrRequest: Record "NPR MM Subscr. Request"; NewStatus: Enum "NPR MM Subscr. Request Status"; SkipTryCountUpdate: Boolean)
    var
        SubsReqLogEntry: Record "NPR MM Subs Req Log Entry";
        SubsReqLogUtils: Codeunit "NPR MM Subs Req Log Utils";
        SubscrReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubsPaymentIHandler: Interface "NPR MM Subs Payment IHandler";
    begin
        if SubscrRequest.Status = NewStatus then
            exit;

        SubscrRequest.Validate(Status, NewStatus);
        SubscrRequest.Validate("Processing Status", SubscrRequest."Processing Status"::Success);
        SubscrRequest.Modify(true);
        if NewStatus = NewStatus::Cancelled then begin
            SubscrReversalMgt.CancelReversal(SubscrRequest);
            SubscrPaymentRequest.Reset();
            SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscrRequest."Entry No.");
            if SubscrPaymentRequest.FindLast() then begin
                ClearLastError();
                SubsPaymentIHandler := SubscrPaymentRequest.PSP;
                if not SubsPaymentIHandler.ProcessPaymentRequest(SubscrPaymentRequest, SkipTryCountUpdate, true) then
                    Error(GetLastErrorText());
            end;
        end;

        SubsReqLogUtils.LogEntry(SubscrRequest, true, SubsReqLogEntry);
    end;

    local procedure SetSubscriptionRequestStatusCancelled(var SubscrRequest: Record "NPR MM Subscr. Request"; SkipTryCountUpdate: Boolean)
    begin
        CheckSuccessfulPaymentRequestsExistAndGiveError(SubscrRequest);
        SetSubscriptionRequestStatus(SubscrRequest, Enum::"NPR MM Subscr. Request Status"::Cancelled, SkipTryCountUpdate);
    end;

    internal procedure SetSubscriptionRequestStatusCancelledWithConfirmation(var SubscrRequest: Record "NPR MM Subscr. Request"; SkipTryCountUpdate: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        NewStatusConfirmLbl: Label 'Are you sure you want to set the status of entry no. %1 to %2?', Comment = '%1 - entry no., %2 - Status';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(NewStatusConfirmLbl, SubscrRequest."Entry No.", Enum::"NPR MM Subscr. Request Status"::Cancelled), true) then
            exit;

        SetSubscriptionRequestStatusCancelled(SubscrRequest, SkipTryCountUpdate);
    end;

    local procedure CheckSuccessfulPaymentRequestsExist(SubscrRequest: Record "NPR MM Subscr. Request"; var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request") Found: Boolean
    begin
        SubscrPaymentRequest.Reset();
        SubscrPaymentRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscrRequest."Entry No.");
        SubscrPaymentRequest.SetFilter(Status, '%1|%2', SubscrPaymentRequest.Status::Authorized, SubscrPaymentRequest.Status::Captured);
        SubscrPaymentRequest.SetLoadFields("Entry No.", Status);

        Found := SubscrPaymentRequest.FindFirst();
    end;

    internal procedure CheckSuccessfulPaymentRequestsExistAndGiveError(SubscrRequest: Record "NPR MM Subscr. Request")
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        CancelErrorLbl: Label 'Subscription payment request no. %1 must not be with status %2.', Comment = '%1 - subscription payment entry, %2 - Status';
    begin
        if not CheckSuccessfulPaymentRequestsExist(SubscrRequest, SubscrPaymentRequest) then
            exit;

        Error(CancelErrorLbl, SubscrPaymentRequest."Entry No.", SubscrPaymentRequest.Status);
    end;

    internal procedure UpdateUnprocessableStatusInSubscriptionPaymentRequestStatus(SubscrRequest: Record "NPR MM Subscr. Request")
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPaymentRequestForModify: Record "NPR MM Subscr. Payment Request";
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
        NewPmtRequestStatus: Enum "NPR MM Payment Request Status";
    begin
        if not (SubscrRequest.Status in [SubscrRequest.Status::Rejected, SubscrRequest.Status::Cancelled]) then
            exit;

        case SubscrRequest.Status of
            SubscrRequest.Status::Rejected:
                NewPmtRequestStatus := NewPmtRequestStatus::Rejected;
            SubscrRequest.Status::Cancelled:
                NewPmtRequestStatus := NewPmtRequestStatus::Cancelled;
        end;
        SubscrPaymentRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscrRequest."Entry No.");
        SubscrPaymentRequest.SetFilter(Status, '<>%1', NewPmtRequestStatus);
        SubscrPaymentRequest.SetLoadFields("Subscr. Request Entry No.", Status, "Entry No.");
        if not SubscrPaymentRequest.FindSet() then
            exit;
        CheckSuccessfulPaymentRequestsExistAndGiveError(SubscrRequest);
        repeat
            SubscrPaymentRequestForModify.Get(SubscrPaymentRequest.RecordId);
            SubsPayRequestUtils.SetSubscrPaymentRequestStatus(SubscrPaymentRequestForModify, NewPmtRequestStatus, false);
        until SubscrPaymentRequest.Next() = 0;
    end;

    local procedure CreateSubscriptionRequestCreationJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        SubscriptionsJobQueueCategoryCode: Code[10];
        DescriptionLbl: Label 'Creates subscription requests for expiring memberships';
        StartDateTime: DateTime;
    begin
        StartDateTime := CreateDateTime(Today, 060000T);
        if CurrentDateTime > StartDateTime then
            StartDateTime := CreateDateTime(CalcDate('<+1D>', Today), 060000T);
        SubscriptionsJobQueueCategoryCode := SubscriptionMgtImpl.GetSubscriptionsJobQueueCategoryCode();

        JobQueueManagement.SetMaxNoOfAttemptsToRun(999999999);
        JobQueueManagement.SetRerunDelay(10);
        JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 20, '');
        exit(
            JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR MM Subscr. Renew Req. JQ",
                '',
                DescriptionLbl,
                StartDateTime,
                060000T,
                230000T,
                1440,
                SubscriptionsJobQueueCategoryCode,
                JobQueueEntry));
    end;

    internal procedure ScheduleSubscriptionRequestCreationJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if CreateSubscriptionRequestCreationJobQueueEntry(JobQueueEntry) then
            JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;

    local procedure CreateSubscriptionRequestProcessingJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        SubscriptionsJobQueueCategoryCode: Code[10];
        DescriptionLbl: Label 'Process subscription requests for expiring memberships';
        StartDateTime: DateTime;
    begin
        StartDateTime := CreateDateTime(Today, 230000T);
        if CurrentDateTime > StartDateTime then
            StartDateTime := CreateDateTime(CalcDate('<+1D>', Today), 230000T);
        SubscriptionsJobQueueCategoryCode := SubscriptionMgtImpl.GetSubscriptionsJobQueueCategoryCode();

        JobQueueManagement.SetMaxNoOfAttemptsToRun(999999999);
        JobQueueManagement.SetRerunDelay(10);
        JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 20, '');
        exit(
            JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR MM Subscr. Renew Proc. JQ",
                '',
                DescriptionLbl,
                StartDateTime,
                230000T,
                060000T,
                1440,
                SubscriptionsJobQueueCategoryCode,
                JobQueueEntry));
    end;

    internal procedure ScheduleSubscriptionRequestProcessingJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if CreateSubscriptionRequestProcessingJobQueueEntry(JobQueueEntry) then
            JobQueueManagement.StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure OpenLogEntries(SubscrRequest: Record "NPR MM Subscr. Request")
    var
        SubsReqLogEntry: Record "NPR MM Subs Req Log Entry";
    begin
        SubsReqLogEntry.SetRange("Request Entry No.", SubscrRequest."Entry No.");
        Page.Run(0, SubsReqLogEntry);
    end;

    local procedure ResetProcessTryCount(var SubscrRequest: Record "NPR MM Subscr. Request")
    begin
        SubscrRequest."Process Try Count" := 0;
        SubscrRequest.Modify(true)
    end;

    internal procedure ResetProcessTryCountWithConfirmation(var SubscrRequest: Record "NPR MM Subscr. Request")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        ResetTryCountConfirmationLbl: Label 'Are you sure you want to reset the process try count of entry no. %1?', Comment = '%1 - subscription request entry no.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(ResetTryCountConfirmationLbl, SubscrRequest."Entry No."), true) then
            exit;

        ResetProcessTryCount(SubscrRequest);
    end;


}
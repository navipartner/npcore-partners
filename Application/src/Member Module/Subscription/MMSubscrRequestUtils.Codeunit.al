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

        if NewStatus = NewStatus::Cancelled then begin
            ConfirmAdyenPayByLinksCancelled(SubscrRequest);
            SubscrRequest.ReadIsolation := IsolationLevel::UpdLock;
            SubscrRequest.Get(SubscrRequest.RecordId);
            CheckSuccessfulPaymentRequestsExistAndGiveError(SubscrRequest);
        end;

        SubscrRequest.Validate(Status, NewStatus);
        SubscrRequest.Validate("Processing Status", SubscrRequest."Processing Status"::Success);
        SubscrRequest.Modify(true);
        if NewStatus = NewStatus::Cancelled then begin
            SubscrReversalMgt.CancelReversal(SubscrRequest);
            SubscrPaymentRequest.Reset();
            SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscrRequest."Entry No.");
            if SubscrPaymentRequest.FindLast() then begin
                if not ((SubscrPaymentRequest.Type = SubscrPaymentRequest.Type::PayByLink) and
                        (SubscrPaymentRequest.PSP = SubscrPaymentRequest.PSP::Adyen))
                then begin
                    ClearLastError();
                    SubsPaymentIHandler := SubscrPaymentRequest.PSP;
                    if not SubsPaymentIHandler.ProcessPaymentRequest(SubscrPaymentRequest, SkipTryCountUpdate, true) then
                        Error(GetLastErrorText());
                end;
            end;
        end;

        SubsReqLogUtils.LogEntry(SubscrRequest, true, SubsReqLogEntry);
    end;

    local procedure ConfirmAdyenPayByLinksCancelled(SubscrRequest: Record "NPR MM Subscr. Request")
    var
        PaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrPmtAdyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
        ErrorMessage: Text;
    begin
        PaymentRequest.SetRange("Subscr. Request Entry No.", SubscrRequest."Entry No.");
        PaymentRequest.SetRange(Type, PaymentRequest.Type::PayByLink);
        PaymentRequest.SetRange(PSP, PaymentRequest.PSP::Adyen);
        PaymentRequest.SetFilter(Status, '<>%1', PaymentRequest.Status::Skipped);
        if PaymentRequest.FindSet() then
            repeat
                if not SubscrPmtAdyen.ConfirmPayByLinkCancellation(PaymentRequest, ErrorMessage) then
                    Error('%1', ErrorMessage);
            until PaymentRequest.Next() = 0;
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
        EnableAutoRenewalOnTerminationCancellation(SubscrRequest);
    end;

    local procedure SetSubscriptionRequestStatusSkipped(var SubscrRequest: Record "NPR MM Subscr. Request"; SkipTryCountUpdate: Boolean)
    begin
        SetSubscriptionRequestStatus(SubscrRequest, Enum::"NPR MM Subscr. Request Status"::Skipped, SkipTryCountUpdate);
    end;

    internal procedure SetSubscriptionRequestStatusSkippedWithConfirmation(var SubscrRequest: Record "NPR MM Subscr. Request"; SkipTryCountUpdate: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        SkipConfirmLbl: Label 'Warning: This action only updates the status in Business Central. No communication will be made to the PSP provider and no other side effects will occur (e.g. reversals will not be undone, membership auto-renewal status will not change).\\If a transaction is pending or in progress at the PSP, it may still be processed. Before skipping, verify the status of this request directly with the PSP provider.\\Are you sure you want to set entry no. %1 to status "Skipped"?', Comment = '%1 - Entry No.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(SkipConfirmLbl, SubscrRequest."Entry No."), false) then
            exit;

        SetSubscriptionRequestStatusSkipped(SubscrRequest, SkipTryCountUpdate);
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
        if not (SubscrRequest.Status in [SubscrRequest.Status::Rejected, SubscrRequest.Status::Cancelled, SubscrRequest.Status::Skipped]) then
            exit;

        case SubscrRequest.Status of
            SubscrRequest.Status::Rejected:
                NewPmtRequestStatus := NewPmtRequestStatus::Rejected;
            SubscrRequest.Status::Cancelled:
                NewPmtRequestStatus := NewPmtRequestStatus::Cancelled;
            SubscrRequest.Status::Skipped:
                NewPmtRequestStatus := NewPmtRequestStatus::Skipped;
        end;
        SubscrPaymentRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscrRequest."Entry No.");
        SubscrPaymentRequest.SetFilter(Status, '<>%1', NewPmtRequestStatus);
        SubscrPaymentRequest.SetLoadFields("Subscr. Request Entry No.", Status, "Entry No.");
        if not SubscrPaymentRequest.FindSet() then
            exit;
        if SubscrRequest.Status <> SubscrRequest.Status::Skipped then
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
        JobQueueManagement.SetProtected(true);
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
    begin
        SubscriptionsJobQueueCategoryCode := SubscriptionMgtImpl.GetSubscriptionsJobQueueCategoryCode();

        JobQueueManagement.SetMaxNoOfAttemptsToRun(999999999);
        JobQueueManagement.SetRerunDelay(10);
        JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 20, '');
        JobQueueManagement.SetProtected(true);
        exit(
            JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR MM Subscr. Renew Proc. JQ",
                '',
                DescriptionLbl,
                CurrentDateTime,
                1,
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

    local procedure CreateSubscriptionRequestTerminationJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        SubscriptionsJobQueueCategoryCode: Code[10];
        DescriptionLbl: Label 'Process subscriptions pending termination.';
        StartDateTime: DateTime;
    begin
        StartDateTime := CreateDateTime(Today, 230000T);
        if CurrentDateTime > StartDateTime then
            StartDateTime := CreateDateTime(CalcDate('<+1D>', Today), 230000T);
        SubscriptionsJobQueueCategoryCode := SubscriptionMgtImpl.GetSubscriptionsJobQueueCategoryCode();

        JobQueueManagement.SetMaxNoOfAttemptsToRun(999999999);
        JobQueueManagement.SetRerunDelay(10);
        JobQueueManagement.SetAutoRescheduleAndNotifyOnError(true, 20, '');
        JobQueueManagement.SetProtected(true);
        exit(
            JobQueueManagement.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                Codeunit::"NPR MM Subscr Termination JQ",
                '',
                DescriptionLbl,
                StartDateTime,
                230000T,
                060000T,
                1440,
                SubscriptionsJobQueueCategoryCode,
                JobQueueEntry));
    end;

    internal procedure ScheduleSubscriptionTerminationProcessingJobQueueEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        if (CreateSubscriptionRequestTerminationJobQueueEntry(JobQueueEntry)) then
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

    local procedure EnableAutoRenewalOnTerminationCancellation(var SubscrRequest: Record "NPR MM Subscr. Request")
    var
        Subscription: Record "NPR MM Subscription";
        Membership: Record "NPR MM Membership";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        RelatedPartialRefundRequest: Record "NPR MM Subscr. Request";
    begin
        if SubscrRequest.Type <> SubscrRequest.Type::Terminate then
            exit;

        // Cancel any related partial refund request
        RelatedPartialRefundRequest.SetRange("Related Termination Req. No.", SubscrRequest."Entry No.");
        RelatedPartialRefundRequest.SetRange(Type, RelatedPartialRefundRequest.Type::"Partial Regret");
        if RelatedPartialRefundRequest.FindFirst() then
            SetSubscriptionRequestStatusCancelled(RelatedPartialRefundRequest, true);

        Subscription.SetLoadFields("Membership Entry No.");
        if not Subscription.Get(SubscrRequest."Subscription Entry No.") then
            exit;

        Membership.SetLoadFields("Entry No.", "Auto-Renew", "Membership Code");
        if not Membership.Get(Subscription."Membership Entry No.") then
            exit;

        if Membership."Auto-Renew" = Membership."Auto-Renew"::YES_INTERNAL then
            exit;

        MembershipMgtInternal.EnableMembershipInternalAutoRenewal(Membership, false, false);
    end;

    internal procedure CancelPendingTerminationRequests(SubscriptionEntryNo: Integer)
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
    begin
        SubscrRequest.SetRange("Subscription Entry No.", SubscriptionEntryNo);
        SubscrRequest.SetRange(Type, SubscrRequest.Type::Terminate);
        SubscrRequest.SetFilter("Processing Status", '%1|%2', SubscrRequest."Processing Status"::Error, SubscrRequest."Processing Status"::Pending);
        if not SubscrRequest.FindSet() then
            exit;
        repeat
            SetSubscriptionRequestStatusCancelled(SubscrRequest, true);
        until SubscrRequest.Next() = 0;
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

    internal procedure LastRenewSchedPeriod(SubscrRequest: Record "NPR MM Subscr. Request"; RecurPaymSetup: Record "NPR MM Recur. Paym. Setup") IsLastRenewSchedPeriod: Boolean
    var
        CurrRenewalSchedLine: Record "NPR MM Renewal Sched Line";
        RenewalSchedLine: Record "NPR MM Renewal Sched Line";
    begin
        IsLastRenewSchedPeriod := RecurPaymSetup."Subscr. Auto-Renewal On" <> RecurPaymSetup."Subscr. Auto-Renewal On"::Schedule;
        if IsLastRenewSchedPeriod then
            exit;

        CurrRenewalSchedLine.SetLoadFields("Date Formula Duration (Days)");
        CurrRenewalSchedLine.GetBySystemId(SubscrRequest."Renew Schedule Id");

        RenewalSchedLine.Reset();
        RenewalSchedLine.SetRange("Schedule Code", RecurPaymSetup."Subscr Auto-Renewal Sched Code");
        RenewalSchedLine.SetFilter("Date Formula Duration (Days)", '>%1', CurrRenewalSchedLine."Date Formula Duration (Days)");
        IsLastRenewSchedPeriod := RenewalSchedLine.IsEmpty();
    end;

    internal procedure UsesRenewalSchedule(SubscrRequest: Record "NPR MM Subscr. Request"): Boolean
    var
        Subscription: Record "NPR MM Subscription";
        MembershipSetup: Record "NPR MM Membership Setup";
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        MembershipCode: Code[20];
    begin
        MembershipCode := SubscrRequest."Membership Code";
        if MembershipCode = '' then
            if Subscription.Get(SubscrRequest."Subscription Entry No.") then
                MembershipCode := Subscription."Membership Code";
        if MembershipSetup.Get(MembershipCode) then
            if RecurPaymSetup.Get(MembershipSetup."Recurring Payment Code") then
                exit(RecurPaymSetup."Subscr. Auto-Renewal On" = RecurPaymSetup."Subscr. Auto-Renewal On"::Schedule);
        exit(not IsNullGuid(SubscrRequest."Renew Schedule Id"));
    end;

    internal procedure HasCapturedTokenPayment(PayByLinkPaymentRequest: Record "NPR MM Subscr. Payment Request"): Boolean
    var
        ScheduleModes: Dictionary of [Code[20], Boolean];
    begin
        exit(HasCapturedTokenPayment(PayByLinkPaymentRequest, ScheduleModes));
    end;

    internal procedure HasCapturedTokenPayment(PayByLinkPaymentRequest: Record "NPR MM Subscr. Payment Request"; var ScheduleModes: Dictionary of [Code[20], Boolean]): Boolean
    var
        PayByLinkRequest: Record "NPR MM Subscr. Request";
        TokenRequest: Record "NPR MM Subscr. Request";
        TokenPayment: Record "NPR MM Subscr. Payment Request";
        MembershipSetup: Record "NPR MM Membership Setup";
        RecurPaymSetup: Record "NPR MM Recur. Paym. Setup";
        UsesSchedule: Boolean;
    begin
        if not PayByLinkRequest.Get(PayByLinkPaymentRequest."Subscr. Request Entry No.") then
            exit(false);
        if (PayByLinkRequest.Type <> PayByLinkRequest.Type::Renew) or (PayByLinkRequest."Created from Entry No." = 0) then
            exit(false);

        TokenRequest.SetRange("Subscription Entry No.", PayByLinkRequest."Subscription Entry No.");
        TokenRequest.SetRange(Type, TokenRequest.Type::Renew);
        TokenRequest.SetRange("Created from Entry No.", 0);
        TokenRequest.SetRange("New Valid From Date", PayByLinkRequest."New Valid From Date");
        TokenRequest.SetRange("New Valid Until Date", PayByLinkRequest."New Valid Until Date");
        TokenPayment.SetRange(Type, TokenPayment.Type::Payment);
        TokenPayment.SetRange(Status, TokenPayment.Status::Captured);
        TokenPayment.SetRange(PSP, PayByLinkPaymentRequest.PSP);
        if TokenRequest.FindSet() then
            repeat
                TokenPayment.SetRange("Subscr. Request Entry No.", TokenRequest."Entry No.");
                if HasCapturedPaymentAwaitingRefund(TokenPayment) then begin
                    if not ScheduleModes.Get(TokenRequest."Membership Code", UsesSchedule) then begin
                        if (TokenRequest."Membership Code" <> '') and MembershipSetup.Get(TokenRequest."Membership Code") then begin
                            if RecurPaymSetup.Get(MembershipSetup."Recurring Payment Code") then begin
                                UsesSchedule := RecurPaymSetup."Subscr. Auto-Renewal On" = RecurPaymSetup."Subscr. Auto-Renewal On"::Schedule;
                                ScheduleModes.Set(TokenRequest."Membership Code", UsesSchedule);
                            end else
                                UsesSchedule := UsesRenewalSchedule(TokenRequest);
                        end else
                            UsesSchedule := UsesRenewalSchedule(TokenRequest);
                    end;
                    if UsesSchedule then
                        exit(true);
                end;
            until TokenRequest.Next() = 0;
        exit(false);
    end;

    internal procedure HasCapturedPayByLinkForRenewal(RenewalRequest: Record "NPR MM Subscr. Request"): Boolean
    var
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
    begin
        LinkRequest.SetCurrentKey("Subscription Entry No.");
        LinkRequest.SetRange("Subscription Entry No.", RenewalRequest."Subscription Entry No.");
        LinkRequest.SetRange(Type, LinkRequest.Type::Renew);
        LinkRequest.SetFilter("Created from Entry No.", '<>%1', 0);
        LinkRequest.SetFilter(Status, '<>%1&<>%2', LinkRequest.Status::Cancelled, LinkRequest.Status::Skipped);
        LinkRequest.SetRange("New Valid From Date", RenewalRequest."New Valid From Date");
        LinkRequest.SetRange("New Valid Until Date", RenewalRequest."New Valid Until Date");
        LinkRequest.SetLoadFields("Entry No.");
        LinkPayment.SetCurrentKey("Subscr. Request Entry No.", Status);
        LinkPayment.SetRange(Type, LinkPayment.Type::PayByLink);
        LinkPayment.SetRange(Status, LinkPayment.Status::Captured);
        if LinkRequest.FindSet() then
            repeat
                LinkPayment.SetRange("Subscr. Request Entry No.", LinkRequest."Entry No.");
                if HasCapturedPaymentAwaitingRefund(LinkPayment) then
                    exit(true);
            until LinkRequest.Next() = 0;
        exit(false);
    end;

    internal procedure HasCapturedPayByLinkAwaitingRenewal(Subscription: Record "NPR MM Subscription"): Boolean
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
        PaymentRequest: Record "NPR MM Subscr. Payment Request";
    begin
        SubscrRequest.SetCurrentKey("Subscription Entry No.");
        SubscrRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscrRequest.SetRange(Type, SubscrRequest.Type::Renew);
        SubscrRequest.SetFilter("Created from Entry No.", '<>%1', 0);
        SubscrRequest.SetFilter("Processing Status", '%1|%2', SubscrRequest."Processing Status"::Pending, SubscrRequest."Processing Status"::Error);
        SubscrRequest.SetFilter(Status, '<>%1&<>%2', SubscrRequest.Status::Cancelled, SubscrRequest.Status::Skipped);
        SubscrRequest.SetFilter("New Valid Until Date", '>%1', Subscription."Valid Until Date");
        SubscrRequest.SetLoadFields("Entry No.");
        PaymentRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
        PaymentRequest.SetRange(Type, PaymentRequest.Type::PayByLink);
        PaymentRequest.SetRange(Status, PaymentRequest.Status::Captured);
        if SubscrRequest.FindSet() then
            repeat
                PaymentRequest.SetRange("Subscr. Request Entry No.", SubscrRequest."Entry No.");
                if HasCapturedPaymentAwaitingRefund(PaymentRequest) then
                    exit(true);
            until SubscrRequest.Next() = 0;
        exit(false);
    end;

    local procedure HasCapturedPaymentAwaitingRefund(var PaymentRequest: Record "NPR MM Subscr. Payment Request"): Boolean
    var
        Refund: Record "NPR MM Subscr. Payment Request";
    begin
        if PaymentRequest.FindSet() then
            repeat
                // Reversed is set when the refund is requested, before the provider confirms it.
                if not PaymentRequest.Reversed then
                    exit(true);
                if not Refund.Get(PaymentRequest."Reversed by Entry No.") then
                    exit(true);
                if (Refund.Type <> Refund.Type::Refund) or
                   (Refund.Status <> Refund.Status::Captured) or
                   (Refund.PSP <> PaymentRequest.PSP) or
                   (Refund."Currency Code" <> PaymentRequest."Currency Code") or
                   (Refund.Amount <> -PaymentRequest.Amount)
                then
                    exit(true);
            until PaymentRequest.Next() = 0;
        exit(false);
    end;

    internal procedure CollectPayByLinksToResolve(SubscriptionEntryNo: Integer; var TempPayment: Record "NPR MM Subscr. Payment Request" temporary)
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
        Subscription: Record "NPR MM Subscription";
        PayByLinkPaymentRequest: Record "NPR MM Subscr. Payment Request";
        IncludeCancelled: Boolean;
    begin
        TempPayment.Reset();
        TempPayment.DeleteAll();
        if not Subscription.Get(SubscriptionEntryNo) then
            exit;
        SubscrRequest.SetRange("Subscription Entry No.", SubscriptionEntryNo);
        SubscrRequest.SetRange(Type, SubscrRequest.Type::Renew);
        SubscrRequest.SetFilter("Created from Entry No.", '<>%1', 0);
        SubscrRequest.SetFilter(Status, '%1|%2', SubscrRequest.Status::Requested, SubscrRequest.Status::Cancelled);
        SubscrRequest.SetLoadFields("Entry No.", Status, "New Valid Until Date", "Subscription Entry No.", "Membership Code", "Renew Schedule Id");
        if SubscrRequest.FindSet() then
            repeat
                IncludeCancelled := (SubscrRequest.Status = SubscrRequest.Status::Cancelled) and
                    (SubscrRequest."New Valid Until Date" > Subscription."Valid Until Date");
                if IncludeCancelled then
                    IncludeCancelled := UsesRenewalSchedule(SubscrRequest);
                PayByLinkPaymentRequest.Reset();
                PayByLinkPaymentRequest.SetCurrentKey("Subscr. Request Entry No.", Status);
                PayByLinkPaymentRequest.SetRange("Subscr. Request Entry No.", SubscrRequest."Entry No.");
                PayByLinkPaymentRequest.SetRange(Type, PayByLinkPaymentRequest.Type::PayByLink);
                PayByLinkPaymentRequest.SetRange(Status, PayByLinkPaymentRequest.Status::Requested);
                if IncludeCancelled then begin
                    PayByLinkPaymentRequest.SetRange(Status, PayByLinkPaymentRequest.Status::Cancelled);
                    PayByLinkPaymentRequest.SetRange(PSP, PayByLinkPaymentRequest.PSP::Adyen);
                    PayByLinkPaymentRequest.SetRange(Reversed, false);
                end;
                if (SubscrRequest.Status = SubscrRequest.Status::Requested) or IncludeCancelled then
                    if PayByLinkPaymentRequest.FindSet() then
                        repeat
                            if not IncludeCancelled or (PayByLinkPaymentRequest."Pay by Link ID" <> '') or (PayByLinkPaymentRequest."Pay by Link URL" <> '') then begin
                                TempPayment := PayByLinkPaymentRequest;
                                TempPayment.Insert();
                            end;
                        until PayByLinkPaymentRequest.Next() = 0;
            until SubscrRequest.Next() = 0;
    end;


}

codeunit 6185043 "NPR MM Subscription Mgt. Impl."
{
    Access = Internal;

    internal procedure GetSubscriptionFromMembership(MembershipEntryNo: Integer; var Subscription: Record "NPR MM Subscription"): Boolean
    begin
        Subscription.Reset();
        Subscription.SetCurrentKey("Membership Entry No.");
        Subscription.SetRange("Membership Entry No.", MembershipEntryNo);
        exit(Subscription.FindFirst());
    end;

    internal procedure GetEarliestTerminationDate(Membership: Record "NPR MM Membership"; var EarliestDate: Date): Boolean
    var
        Subscription: Record "NPR MM Subscription";
    begin
        if (not GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            exit(false);
        EarliestDate := CalculateEarliestTerminationDate(Membership);
        if (EarliestDate < Subscription."Committed Until") then
            EarliestDate := Subscription."Committed Until";
        exit(true);
    end;

    local procedure CalculateEarliestTerminationDate(Membership: Record "NPR MM Membership") TerminationDate: Date
    var
        RecurPaymtSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        if (not TryGetRecurPaymentSetup(Membership, RecurPaymtSetup)) then
            exit;
        if (Format(RecurPaymtSetup.TerminationPeriod) = '') then
            exit;
        TerminationDate := CalcDate(RecurPaymtSetup.TerminationPeriod, WorkDate());
    end;

    internal procedure UpdateMembershipSubscriptionDetails(MembershipLedger: Record "NPR MM Membership Entry")
    var
        Membership: Record "NPR MM Membership";
    begin
        if not Membership.Get(MembershipLedger."Membership Entry No.") then
            Clear(Membership);
        UpdateMembershipSubscriptionDetails(Membership, MembershipLedger);
    end;

    internal procedure UpdateMembershipSubscriptionDetails(Membership: Record "NPR MM Membership")
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        NeedsAtLeastOnePeriodErr: Label 'The membership must have at least one unblocked period to update subscription details.';
    begin
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            Error(NeedsAtLeastOnePeriodErr);

        UpdateMembershipSubscriptionDetails(Membership, MembershipEntry);
    end;

    internal procedure UpdateMembershipSubscriptionDetails(Membership: Record "NPR MM Membership"; MembershipLedger: Record "NPR MM Membership Entry")
    var
        Subscription: Record "NPR MM Subscription";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        MaxValidUntilDate: Date;
    begin
        MembershipLedger.TestField("Membership Entry No.");
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
        Subscription.ReadIsolation := IsolationLevel::UpdLock;
#else
        Subscription.LockTable();
#endif
        MembershipManagement.GetMembershipValidDate(Membership."Entry No.", Today, ValidFromDate, ValidUntilDate);
        MembershipManagement.GetMembershipMaxValidUntilDate(Membership."Entry No.", MaxValidUntilDate);
        if MaxValidUntilDate > ValidUntilDate then
            ValidUntilDate := MaxValidUntilDate;

        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        if not Subscription.FindFirst() then begin
            Subscription.Init();
            Subscription."Entry No." := 0;
            Subscription."Membership Entry No." := Membership."Entry No.";
            Subscription.Insert(true);
        end;
        Subscription."Membership Ledger Entry No." := MembershipLedger."Entry No.";
        Subscription."Membership Code" := MembershipLedger."Membership Code";
        Subscription.Blocked := Membership.Blocked;
        Subscription."Valid From Date" := ValidFromDate;
        Subscription."Valid Until Date" := ValidUntilDate;
        Subscription."Postpone Renewal Attempt Until" := 0D;
        Subscription.Modify(true);
    end;

    internal procedure CreateNewSubscriptionRequestWithConfirmation(Subscription: Record "NPR MM Subscription");
    var
        ConfirmManagement: Codeunit "Confirm Management";
        SubscrRenewRequest: Codeunit "NPR MM Subscr. Renew: Request";
        NewSubscriptionRequestConfirmLbl: Label 'Are you sure you want to create a new subscription request for subscription no. %1?', Comment = '%1 - Subscription entry no.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(NewSubscriptionRequestConfirmLbl, Subscription."Entry No."), true) then
            exit;

        SubscrRenewRequest.Run(Subscription);
    end;

    internal procedure GetSubscriptionsJobQueueCategoryCode() JobQueueCategoryCode: Code[10]
    var
        JobQueueCategory: Record "Job Queue Category";
        SubscriptionsJobQueueCategoryCodeLbl: Label 'NPR-SUBS', Locked = true, MaxLength = 10;
        SubscriptionsJobQueueCategoryDescriptionLbl: Label 'NPR Subscriptions';
    begin
        JobQueueCategory.InsertRec(SubscriptionsJobQueueCategoryCodeLbl, SubscriptionsJobQueueCategoryDescriptionLbl);
        JobQueueCategoryCode := SubscriptionsJobQueueCategoryCodeLbl;
    end;

    local procedure ScheduleSubscriptionProcessingJobQueueEntries()
    var
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        SubscrRequestUtils.ScheduleSubscriptionRequestCreationJobQueueEntry();
        SubsPayRequestUtils.ScheduleSubscriptionPaymentRequestProcessingJobQueueEntryScheduled();
        SubscrRequestUtils.ScheduleSubscriptionRequestProcessingJobQueueEntry();
        SubscrRequestUtils.ScheduleSubscriptionTerminationProcessingJobQueueEntry();
    end;

    internal procedure BlockSubscriptionWithConfirmation(var Subscription: Record "NPR MM Subscription")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        BlockSubscriptionConfirmLbl: Label 'Are you sure you want to block subscription no. %1?', Comment = '%1 - Subscription no.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(BlockSubscriptionConfirmLbl, Subscription."Entry No."), true) then
            exit;
        BlockSubscription(Subscription);
    end;


    local procedure BlockSubscription(var Subscription: Record "NPR MM Subscription")
    begin
        CheckIfUnprocessedSubscriptionRequestExists(Subscription);

        Subscription.Blocked := true;
        Subscription.Modify(true);
    end;

    internal procedure UnblockSubscriptionWithConfirmation(var Subscription: Record "NPR MM Subscription")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        BlockSubscriptionConfirmLbl: Label 'Are you sure you want to unblock subscription no. %1?', Comment = '%1 - Subscription no.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(BlockSubscriptionConfirmLbl, Subscription."Entry No."), true) then
            exit;
        UnblockSubscription(Subscription);
    end;

    local procedure UnblockSubscription(var Subscription: Record "NPR MM Subscription")
    begin
        Subscription.Blocked := false;
        Subscription.Modify(true);
    end;

    internal procedure RequestTermination(var Membership: Record "NPR MM Membership"; RequestedDate: Date; Reason: Enum "NPR MM Subs Termination Reason"): Boolean
    var
        Subscription: Record "NPR MM Subscription";
    begin
        if (not GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            exit(false);
        if (Subscription."Auto-Renew" <> Subscription."Auto-Renew"::YES_INTERNAL) then
            exit(false);

        CheckTerminationPeriod(Membership, Subscription, RequestedDate);

        SetTerminationFields(Subscription, RequestedDate, Reason);
        Subscription."Auto-Renew" := Subscription."Auto-Renew"::TERMINATION_REQUESTED;
        Subscription.Modify(true);

        Membership.Validate("Auto-Renew", Membership."Auto-Renew"::TERMINATION_REQUESTED);
        Membership.Modify();

        exit(true);
    end;

    local procedure CheckIfUnprocessedSubscriptionRequestExists(var Subscription: Record "NPR MM Subscription")
    var
        SubscrRequest: Record "NPR MM Subscr. Request";
        OutstandingSubscriptionRequestErrorLbl: Label 'Subscription request %1 for subscription %2 is not processed. Please process it and try again.', Comment = '%1 - subscription request no., %2 subscription no.';
    begin
        SubscrRequest.Reset();
        SubscrRequest.SetCurrentKey("Subscription Entry No.", "Processing Status");
        SubscrRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscrRequest.SetFilter("Processing Status", '%1|%2', SubscrRequest."Processing Status"::Pending, SubscrRequest."Processing Status"::Error);
        SubscrRequest.SetLoadFields("Entry No.");
        if not SubscrRequest.FindLast() then
            exit;

        Error(OutstandingSubscriptionRequestErrorLbl, SubscrRequest."Entry No.", Subscription."Entry No.");
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Membership Entry", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Membership Entry", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure UpdateSubscription(var Rec: Record "NPR MM Membership Entry")
    begin
        if Rec.IsTemporary() then
            exit;

        //TODO: check if subscription record needs to be updated when a membership entry is blocked
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
#else    
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", OnRefreshNPRJobQueueList, '', false, false)]
#endif
    local procedure RefreshJobQueueEntry()
    begin
        ScheduleSubscriptionProcessingJobQueueEntries();
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
           (JobQueueEntry."Object ID to Run" in [Codeunit::"NPR MM Subscr. Renew Req. JQ", Codeunit::"NPR MM Subscr. Pay Req Proc JQ", Codeunit::"NPR MM Subscr. Renew Proc. JQ", Codeunit::"NPR MM Subscr Termination JQ"])
        then begin
            IsNpJob := true;
            Handled := true;
        end;
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Membership", 'OnAfterModifyEvent', '', false, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"NPR MM Membership", OnAfterModifyEvent, '', false, false)]
#endif
    local procedure OnAfterModifyMembership(var Rec: Record "NPR MM Membership"; var xRec: Record "NPR MM Membership")
    begin
        if Rec.IsTemporary then
            exit;

        UpdateSubscriptionAutoRenewStatus(Rec);
    end;

    internal procedure UpdateSubscriptionPeriodFromMembership(MembershipEntryNo: Integer)
    var
        Subscription: Record "NPR MM Subscription";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        MaxValidUntilDate: Date;
        IsModified: Boolean;
    begin
        Subscription.Reset();
        Subscription.SetCurrentKey("Membership Entry No.");
        Subscription.SetRange("Membership Entry No.", MembershipEntryNo);
        if not Subscription.FindFirst() then
            exit;

        MembershipManagement.GetMembershipValidDate(MembershipEntryNo, Today, ValidFromDate, ValidUntilDate);
        MembershipManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, MaxValidUntilDate);

        if MaxValidUntilDate > ValidUntilDate then
            ValidUntilDate := MaxValidUntilDate;

        if Subscription."Valid From Date" <> ValidFromDate then begin
            Subscription."Valid From Date" := ValidFromDate;
            IsModified := true;
        end;

        if Subscription."Valid Until Date" <> ValidUntilDate then begin
            Subscription."Valid Until Date" := ValidUntilDate;
            IsModified := true;
        end;

        if IsModified then
            Subscription.Modify(true);
    end;

    internal procedure UpdateSubscriptionValidUntilDateFromMembershipEntry(MembershipEntry: Record "NPR MM Membership Entry")
    var
        Subscription: Record "NPR MM Subscription";
    begin
        Subscription.Reset();
        Subscription.SetCurrentKey("Membership Entry No.");
        Subscription.SetRange("Membership Entry No.", MembershipEntry."Membership Entry No.");
        if not Subscription.FindFirst() then
            exit;

        if Subscription."Valid Until Date" = MembershipEntry."Valid Until Date" then
            exit;

        Subscription."Valid Until Date" := MembershipEntry."Valid Until Date";

        Subscription.Modify(true);
    end;

    local procedure UpdateSubscriptionAutoRenewStatus(Membership: Record "NPR MM Membership")
    var
        Subscription: Record "NPR MM Subscription";
    begin
        Subscription.SetCurrentKey("Membership Entry No.");
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        if not Subscription.FindFirst() then
            exit;

        if Subscription."Auto-Renew" = Membership."Auto-Renew" then
            exit;

        case Membership."Auto-Renew" of
            "NPR MM MembershipAutoRenew"::YES_INTERNAL:
                begin
                    // We have put the subscription into an internal state, calculate commitment period if the subscription was not pending termination.
                    if (Subscription."Auto-Renew" <> Subscription."Auto-Renew"::TERMINATION_REQUESTED) then begin
                        Subscription."Started At" := CurrentDateTime();
                        SetCommitmentPeriod(Membership, Subscription);
                    end;

                    ResetTerminationFields(Subscription);
                end;
            "NPR MM MembershipAutoRenew"::TERMINATION_REQUESTED:
                // This is a catch all if somebody sets it directly on the membership. We make some assumptions here.
                SetTerminationFields(Subscription, Today(), "NPR MM Subs Termination Reason"::CUSTOMER_INITIATED);
        end;

        Subscription."Auto-Renew" := Membership."Auto-Renew";
        Subscription.Modify(true);
    end;

    local procedure SetCommitmentPeriod(Membership: Record "NPR MM Membership"; var Subscription: Record "NPR MM Subscription")
    var
        RecurPaymtSetup: Record "NPR MM Recur. Paym. Setup";
        CommittedUntil: Date;
    begin
        if (not TryGetRecurPaymentSetup(Membership, RecurPaymtSetup)) then
            exit;
        if (Format(RecurPaymtSetup.SubscriptionCommitmentPeriod) = '') then
            exit;

        case RecurPaymtSetup.SubscriptionCommitStartDate of
            RecurPaymtSetup.SubscriptionCommitStartDate::WORK_DATE:
                CommittedUntil := CalcDate(RecurPaymtSetup.SubscriptionCommitmentPeriod, WorkDate());
            RecurPaymtSetup.SubscriptionCommitStartDate::SUBS_VALID_FROM:
                CommittedUntil := CalcDate(RecurPaymtSetup.SubscriptionCommitmentPeriod, Subscription."Valid From Date");
        end;

        Subscription."Committed Until" := CommittedUntil;
    end;

    local procedure SetTerminationFields(var Subscription: Record "NPR MM Subscription"; RequestedDate: Date; Reason: Enum "NPR MM Subs Termination Reason")
    begin
        Subscription."Terminate At" := RequestedDate;
        Subscription."Termination Reason" := Reason;
        Subscription."Termination Requested At" := CurrentDateTime();
    end;

    local procedure ResetTerminationFields(var Subscription: Record "NPR MM Subscription")
    begin
        Subscription."Terminate At" := 0D;
        Subscription."Termination Reason" := Subscription."Termination Reason"::NOT_TERMINATED;
        Subscription."Termination Requested At" := 0DT;
    end;

    local procedure CheckTerminationPeriod(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription"; RequestedDate: Date)
    var
        ConfirmMgt: Codeunit "Confirm Management";
        RecurPaymtSetup: Record "NPR MM Recur. Paym. Setup";
        EarliestTerminationDate: Date;
        SubsCantBeTerminatedDueToTerminationPeriodErr: Label 'The subscription cannot be terminated due to the termination period. The earliest termination date is %1', Comment = '%1 = the latest termination day';
        AllowBreakOfTerminationPeriodQst: Label 'Terminating subscription would violate the termination period. Do you want to allow breaking the termination period?\The earliest termination date is %1', Comment = '%1 = the latest termiantion day';
        SubsCantBeTerminatedDueToCommitmentPeriodErr: Label 'The subscription cannot be terminated due to the commitment period. The subscription is committed until %1', Comment = '%1 = the committed until date';
        AllowBreakOfCommitmentPeriodQst: Label 'Terminating subscription would violate the commitment period. Do you want to allow breaking the commitment period?\The subscription is committed until %1', Comment = '%1 = the last day of the commitment period';
    begin
        if (not TryGetRecurPaymentSetup(Membership, RecurPaymtSetup)) then
            exit;
        if (Format(RecurPaymtSetup.TerminationPeriod) = '') then
            exit;
        if (not RecurPaymtSetup.EnforceTerminationPeriod) then
            exit;

        if (Subscription."Committed Until" <> 0D) then
            if (Subscription."Committed Until" > RequestedDate) then
                if (not ConfirmMgt.GetResponseOrDefault(StrSubstNo(AllowBreakOfCommitmentPeriodQst, Subscription."Committed Until"), false)) then
                    Error(SubsCantBeTerminatedDueToCommitmentPeriodErr, Subscription."Committed Until");

        EarliestTerminationDate := CalculateEarliestTerminationDate(Membership);

        if (EarliestTerminationDate > Subscription."Valid Until Date") or (EarliestTerminationDate > RequestedDate) then
            if (not ConfirmMgt.GetResponseOrDefault(StrSubstNo(AllowBreakOfTerminationPeriodQst, EarliestTerminationDate), false)) then
                Error(SubsCantBeTerminatedDueToTerminationPeriodErr, EarliestTerminationDate);
    end;

    procedure CheckIfPendingSubscriptionRequestExist(MembershipEntryNo: Integer; var SubscriptionRequest: Record "NPR MM Subscr. Request"): Boolean
    var
        Subscription: Record "NPR MM Subscription";
    begin
        Subscription.Reset();
        Subscription.SetCurrentKey("Membership Entry No.");
        Subscription.SetRange("Membership Entry No.", MembershipEntryNo);
        if not Subscription.FindFirst() then
            exit(false);

        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetFilter(Status, '%1|%2|%3', SubscriptionRequest.Status::New, SubscriptionRequest.Status::Requested, SubscriptionRequest.Status::Confirmed);
        SubscriptionRequest.SetRange("Processing Status", SubscriptionRequest."Processing Status"::Pending);
        SubscriptionRequest.SetRange(Reversed, false);
        exit(SubscriptionRequest.FindFirst());
    end;

    internal procedure CreatePayByLinkPaymentMethodCollect(Membership: Record "NPR MM Membership")
    var
        MMPaymentMethodCollection: Page "NPR MM PaymentMethodCollection";
    begin
        Clear(MMPaymentMethodCollection);
        MMPaymentMethodCollection.SetMembership(Membership);
        MMPaymentMethodCollection.RunModal();
    end;

    [TryFunction]
    local procedure TryGetRecurPaymentSetup(Membership: Record "NPR MM Membership"; var RecurPaymentSetup: Record "NPR MM Recur. Paym. Setup")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        Clear(RecurPaymentSetup);
        MembershipSetup.Get(Membership."Membership Code");
        RecurPaymentSetup.Get(MembershipSetup."Recurring Payment Code");
    end;
}
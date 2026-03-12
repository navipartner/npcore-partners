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
        MembershipManagement.GetMembershipValidDate(Membership."Entry No.", Today, ValidFromDate, ValidUntilDate);
        MembershipManagement.GetMembershipMaxValidUntilDate(Membership."Entry No.", MaxValidUntilDate);
        if MaxValidUntilDate > ValidUntilDate then
            ValidUntilDate := MaxValidUntilDate;

        Subscription.SetCurrentKey("Membership Entry No.");
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
        TerminationRequest: Record "NPR MM Subscr. Request";
    begin
        exit(RequestTermination(Membership, RequestedDate, Reason, TerminationRequest));
    end;

    internal procedure RequestTermination(var Membership: Record "NPR MM Membership"; RequestedDate: Date; Reason: Enum "NPR MM Subs Termination Reason"; var TerminationRequest: Record "NPR MM Subscr. Request"): Boolean
    var
        Subscription: Record "NPR MM Subscription";
    begin
        if (not GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            exit(false);
        if (Subscription."Auto-Renew" <> Subscription."Auto-Renew"::YES_INTERNAL) then
            exit(false);

        CheckTerminationPeriod(Membership, Subscription, RequestedDate);

        CreateTerminationSubsRequest(Subscription, RequestedDate, Reason, TerminationRequest);
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
        TerminationRequest: Record "NPR MM Subscr. Request";
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

                end;
            "NPR MM MembershipAutoRenew"::TERMINATION_REQUESTED:
                // This is a catch all if somebody sets it directly on the membership. We make some assumptions here.
                CreateTerminationSubsRequest(Subscription, Today(), "NPR MM Subs Termination Reason"::CUSTOMER_INITIATED, TerminationRequest);

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

    local procedure CreateTerminationSubsRequest(Subscription: Record "NPR MM Subscription"; RequestedDate: Date; Reason: Enum "NPR MM Subs Termination Reason"; var TerminationRequest: Record "NPR MM Subscr. Request")
    var
        TerminationRequestLbl: Label 'Termination request';
    begin
        TerminationRequest.Init();
        TerminationRequest.Type := TerminationRequest.Type::Terminate;
        TerminationRequest.Status := TerminationRequest.Status::Confirmed;
        TerminationRequest."Processing Status" := TerminationRequest."Processing Status"::Pending;
        TerminationRequest."Subscription Entry No." := Subscription."Entry No.";
        TerminationRequest.Description := TerminationRequestLbl;
        TerminationRequest."Membership Code" := Subscription."Membership Code";
        TerminationRequest."Terminate At" := RequestedDate;
        TerminationRequest."Termination Reason" := Reason;
        TerminationRequest."Termination Requested At" := CurrentDateTime();
        TerminationRequest.Insert(true);
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

    internal procedure CreateInitialSaleSubscriptionRequest(Subscription: Record "NPR MM Subscription"; MembershipEntry: Record "NPR MM Membership Entry"; MemberPaymentMethod: Record "NPR MM Member Payment Method"; var EFTTransactionRequest: Record "NPR EFT Transaction Request"; SaleAmountInclVAT: Decimal)
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        InitialSaleDescrLbl: Label 'Initial sale';
    begin
        if EFTTransactionRequest."Result Amount" <= 0 then
            exit;

        if Subscription."Auto-Renew" <> Subscription."Auto-Renew"::YES_INTERNAL then
            exit;

        if EFTTransactionRequest."Manual Capture" then
            exit;

        SubscriptionRequest.SetCurrentKey("Subscription Entry No.", Type, "Processing Status", Status);
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        SubscriptionRequest.SetRange(Reversed, false);
        if not SubscriptionRequest.IsEmpty() then
            exit;

        SubscriptionRequest.Init();
        SubscriptionRequest.Type := SubscriptionRequest.Type::"Initial Sale";
        SubscriptionRequest.Status := SubscriptionRequest.Status::Confirmed;
        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
        SubscriptionRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscriptionRequest."Membership Code" := Subscription."Membership Code";
        SubscriptionRequest.Amount := SaleAmountInclVAT;
        SubscriptionRequest."Currency Code" := EFTTransactionRequest."Currency Code";
        SubscriptionRequest."New Valid From Date" := MembershipEntry."Valid From Date";
        SubscriptionRequest."New Valid Until Date" := MembershipEntry."Valid Until Date";
        SubscriptionRequest."Posted M/ship Ledg. Entry No." := MembershipEntry."Entry No.";
        SubscriptionRequest.Description := InitialSaleDescrLbl;
        SubscriptionRequest.Insert(true);

        CreateInitialSaleSubscrPaymentRequest(Subscription, SubscriptionRequest, MemberPaymentMethod, EFTTransactionRequest);
    end;

    local procedure CreateInitialSaleSubscrPaymentRequest(Subscription: Record "NPR MM Subscription"; SubscriptionRequest: Record "NPR MM Subscr. Request"; MemberPaymentMethod: Record "NPR MM Member Payment Method"; var EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubsPayReqUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        SubscrPaymentRequest.Init();
        SubscrPaymentRequest."Entry No." := 0;
        SubscrPaymentRequest.Type := SubscrPaymentRequest.Type::Payment;
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::Captured;
        SubscrPaymentRequest."Subscr. Request Entry No." := SubscriptionRequest."Entry No.";
        SubscrPaymentRequest.PSP := MemberPaymentMethod.PSP;
        SubscrPaymentRequest."Payment Method Entry No." := MemberPaymentMethod."Entry No.";
        SubscrPaymentRequest."Payment Token" := MemberPaymentMethod."Payment Token";
        SubscrPaymentRequest.Amount := EFTTransactionRequest."Result Amount";
        SubscrPaymentRequest."Currency Code" := EFTTransactionRequest."Currency Code";
        SubscrPaymentRequest.Description := SubscriptionRequest.Description;
        SubscrPaymentRequest."PSP Reference" := EFTTransactionRequest."PSP Reference";
        SubscrPaymentRequest."Subscription Payment Reference" := CopyStr(SubsPayReqUtils.GenerateSubscriptionPaymentReference(), 1, MaxStrLen(SubscrPaymentRequest."Subscription Payment Reference"));
        SubscrPaymentRequest."External Membership No." := SubsPayReqUtils.GetExternalMembershipNo(Subscription."Membership Entry No.");
        SubscrPaymentRequest."PAN Last 4 Digits" := MemberPaymentMethod."PAN Last 4 Digits";
        SubscrPaymentRequest."Masked PAN" := MemberPaymentMethod."Masked PAN";
        SubsPayReqUtils.TrySetPaymentContactFromUserAcc(SubscrPaymentRequest, MemberPaymentMethod);
        SubscrPaymentRequest.Insert(true);
    end;

#if BC17 or BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', false, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", OnAfterEndSale, '', false, false)]
#endif
    local procedure CreateInitialSaleSubscrRequestOnAfterEndSale(SalePOS: Record "NPR POS Sale")
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        if SalePOS."Header Type" = SalePOS."Header Type"::Cancelled then
            exit;

        if SalePOS."Sales Ticket No." = '' then
            exit;

        MembershipEntry.SetCurrentKey("Receipt No.", "Line No.");
        MembershipEntry.SetRange("Receipt No.", SalePOS."Sales Ticket No.");
        if not MembershipEntry.FindSet() then
            exit;

        repeat
            ProcessMembershipEntryForInitialSale(SalePOS, MembershipEntry);
        until MembershipEntry.Next() = 0;
    end;

    local procedure ProcessMembershipEntryForInitialSale(SalePOS: Record "NPR POS Sale"; MembershipEntry: Record "NPR MM Membership Entry")
    var
        ActiveMembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not Membership.Get(MembershipEntry."Membership Entry No.") then
            exit;

        ActiveMembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        ActiveMembershipEntry.SetRange(Blocked, false);
        ActiveMembershipEntry.SetFilter(Context, '<>%1', ActiveMembershipEntry.Context::REGRET);
        if not ActiveMembershipEntry.FindLast() then
            exit;

        Subscription.SetCurrentKey("Membership Entry No.");
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        if not Subscription.FindFirst() then
            exit;

        if Subscription."Auto-Renew" <> Subscription."Auto-Renew"::YES_INTERNAL then
            exit;

        MembershipPmtMethodMap.SetRange(MembershipId, Membership.SystemId);
        MembershipPmtMethodMap.SetRange(Default, true);
        if not MembershipPmtMethodMap.FindFirst() then
            exit;

        if not MemberPaymentMethod.GetBySystemId(MembershipPmtMethodMap.PaymentMethodId) then
            exit;

        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        EFTTransactionRequest.SetFilter("Sales Line No.", '<>%1', 0);
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::PAYMENT);
        EFTTransactionRequest.SetFilter("Recurring Detail Reference", '<>%1', '');
        if EFTTransactionRequest.FindLast() then
            CreateInitialSaleSubscriptionRequest(Subscription, ActiveMembershipEntry, MemberPaymentMethod, EFTTransactionRequest, EFTTransactionRequest."Result Amount");
    end;

    internal procedure CreateCancellationSubscriptionRequest(Subscription: Record "NPR MM Subscription"; MembershipEntry: Record "NPR MM Membership Entry"; MemberInfoCapture: Record "NPR MM Member Info Capture"; SalesTicketNo: Code[20])
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        PartialRegretRequest: Record "NPR MM Subscr. Request";
        OriginalSubscrRequest: Record "NPR MM Subscr. Request";
        OriginalSubscrPmtRequest: Record "NPR MM Subscr. Payment Request";
        RefundPmtRequest: Record "NPR MM Subscr. Payment Request";
        RefundPmtRequestCreated: Boolean;
        OriginalSubscrRequestFound: Boolean;
        PartialRegretDescrLbl: Label 'POS cancellation';
    begin
        SubscriptionRequest.SetCurrentKey("Subscription Entry No.", Type, "Processing Status", Status);
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        SubscriptionRequest.SetRange("Membership Entry To Cancel", MembershipEntry."Entry No.");
        if not SubscriptionRequest.IsEmpty() then
            exit;

        OriginalSubscrRequest.SetCurrentKey("Subscription Entry No.", Type, "Processing Status", Status);
        OriginalSubscrRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        OriginalSubscrRequest.SetFilter(Type, '%1|%2', OriginalSubscrRequest.Type::Renew, OriginalSubscrRequest.Type::"Initial Sale");
        OriginalSubscrRequest.SetRange("Posted M/ship Ledg. Entry No.", MembershipEntry."Entry No.");
        OriginalSubscrRequest.SetRange("Processing Status", OriginalSubscrRequest."Processing Status"::Success);
        OriginalSubscrRequest.SetRange(Reversed, false);
        OriginalSubscrRequestFound := OriginalSubscrRequest.FindLast();

        // Create Partial Regret subscription request
        PartialRegretRequest.Init();
        PartialRegretRequest."Entry No." := 0;
        PartialRegretRequest.Type := PartialRegretRequest.Type::"Partial Regret";
        PartialRegretRequest.Status := PartialRegretRequest.Status::Confirmed;
        PartialRegretRequest."Processing Status" := PartialRegretRequest."Processing Status"::Success;
        PartialRegretRequest."Subscription Entry No." := Subscription."Entry No.";
        PartialRegretRequest."Membership Code" := Subscription."Membership Code";
        PartialRegretRequest.Amount := MemberInfoCapture."Unit Price";
        PartialRegretRequest."New Valid From Date" := MembershipEntry."Valid From Date";
        PartialRegretRequest."New Valid Until Date" := MemberInfoCapture."Document Date";
        PartialRegretRequest."Membership Entry To Cancel" := MembershipEntry."Entry No.";
        PartialRegretRequest."Posted M/ship Ledg. Entry No." := MembershipEntry."Entry No.";
        PartialRegretRequest.Description := PartialRegretDescrLbl;
        if OriginalSubscrRequestFound then
            PartialRegretRequest."Currency Code" := OriginalSubscrRequest."Currency Code";
        PartialRegretRequest.Insert(true);

        // Create Refund payment request (Adyen card-only)
        RefundPmtRequestCreated := CreateCancellationRefundPmtRequest(Subscription, PartialRegretRequest, SalesTicketNo, RefundPmtRequest);

        // Reverse connected Initial Sale / Renew
        if OriginalSubscrRequestFound then begin
            OriginalSubscrRequest.Reversed := true;
            OriginalSubscrRequest."Reversed by Entry No." := PartialRegretRequest."Entry No.";
            OriginalSubscrRequest.Modify(true);

            if RefundPmtRequestCreated then begin
                OriginalSubscrPmtRequest.SetRange("Subscr. Request Entry No.", OriginalSubscrRequest."Entry No.");
                OriginalSubscrPmtRequest.SetRange(Reversed, false);
                OriginalSubscrPmtRequest.SetRange(Status, OriginalSubscrPmtRequest.Status::Captured);
                if OriginalSubscrPmtRequest.FindLast() then begin
                    OriginalSubscrPmtRequest.Reversed := true;
                    OriginalSubscrPmtRequest."Reversed by Entry No." := RefundPmtRequest."Entry No.";
                    OriginalSubscrPmtRequest.Modify(true);
                end;
            end;
        end;
    end;

    local procedure CreateCancellationRefundPmtRequest(Subscription: Record "NPR MM Subscription"; PartialRegretRequest: Record "NPR MM Subscr. Request"; SalesTicketNo: Code[20]; var RefundPmtRequest: Record "NPR MM Subscr. Payment Request"): Boolean
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSaleLine: Record "NPR POS Sale Line";
        Membership: Record "NPR MM Membership";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        SubsPayReqUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        POSSaleLine.SetRange("Sales Ticket No.", SalesTicketNo);
        POSSaleLine.SetRange("Line Type", POSSaleLine."Line Type"::"POS Payment");
        if not POSSaleLine.FindFirst() then
            exit(false);
        if POSSaleLine.Next() <> 0 then
            exit(false);

        EFTTransactionRequest.SetCurrentKey("Sales Ticket No.", "Sales Line No.");
        EFTTransactionRequest.SetRange("Sales Ticket No.", SalesTicketNo);
        EFTTransactionRequest.SetRange(Successful, true);
        EFTTransactionRequest.SetRange("Processing Type", EFTTransactionRequest."Processing Type"::REFUND);
        if not EFTTransactionRequest.FindFirst() then
            exit(false);
        if EFTTransactionRequest.Next() <> 0 then
            exit(false);
        if CopyStr(EFTTransactionRequest."Integration Type", 1, 5) <> 'ADYEN' then
            exit(false);

        if not Membership.Get(Subscription."Membership Entry No.") then
            exit(false);

        MembershipPmtMethodMap.SetRange(MembershipId, Membership.SystemId);
        MembershipPmtMethodMap.SetRange(Default, true);
        if not MembershipPmtMethodMap.FindFirst() then
            exit(false);

        if not MemberPaymentMethod.GetBySystemId(MembershipPmtMethodMap.PaymentMethodId) then
            exit(false);

        RefundPmtRequest.Init();
        RefundPmtRequest."Entry No." := 0;
        RefundPmtRequest.Type := RefundPmtRequest.Type::Refund;
        RefundPmtRequest.Status := RefundPmtRequest.Status::Captured;
        RefundPmtRequest."Subscr. Request Entry No." := PartialRegretRequest."Entry No.";
        RefundPmtRequest.PSP := MemberPaymentMethod.PSP;
        RefundPmtRequest."Payment Method Entry No." := MemberPaymentMethod."Entry No.";
        RefundPmtRequest."Payment Token" := MemberPaymentMethod."Payment Token";
        RefundPmtRequest.Amount := EFTTransactionRequest."Result Amount";
        RefundPmtRequest."Currency Code" := EFTTransactionRequest."Currency Code";
        RefundPmtRequest.Description := PartialRegretRequest.Description;
        RefundPmtRequest."PSP Reference" := EFTTransactionRequest."PSP Reference";
        RefundPmtRequest."Subscription Payment Reference" := CopyStr(SubsPayReqUtils.GenerateSubscriptionPaymentReference(), 1, MaxStrLen(RefundPmtRequest."Subscription Payment Reference"));
        RefundPmtRequest."External Membership No." := SubsPayReqUtils.GetExternalMembershipNo(Subscription."Membership Entry No.");
        RefundPmtRequest."PAN Last 4 Digits" := MemberPaymentMethod."PAN Last 4 Digits";
        RefundPmtRequest."Masked PAN" := MemberPaymentMethod."Masked PAN";
        SubsPayReqUtils.TrySetPaymentContactFromUserAcc(RefundPmtRequest, MemberPaymentMethod);
        RefundPmtRequest.Insert(true);
        exit(true);
    end;
}
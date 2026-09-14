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

    /// <summary>
    /// The earliest date the system will accept as a termination date. This is a validation value: it prefills the
    /// termination page and is the fallback the terminate endpoint feeds back into RequestTermination, where
    /// CheckTerminationPeriod validates it again. Returning anything earlier than the notice period allows makes that
    /// round trip fail, so this must NOT be narrowed for display purposes - see GetUsableUntilDateIfCancelledNow.
    /// </summary>
    internal procedure GetEarliestTerminationDate(Membership: Record "NPR MM Membership"; var EarliestDate: Date): Boolean
    var
        Subscription: Record "NPR MM Subscription";
        CoveringPeriodEnd: Date;
        PeriodsRenewed: Integer;
    begin
        if (not GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            exit(false);
        EarliestDate := CalculateEarliestTerminationDate(Membership);
        if (EarliestDate < Subscription."Committed Until") then
            EarliestDate := Subscription."Committed Until";

        // Rolls forward across every period the notice spans, not just one. With a notice period longer than a
        // renewal period, stopping after one left this returning a date that its own caller CheckTerminationPeriod
        // then rejected, so the terminate endpoint's default could not satisfy the endpoint's own validation.
        if (EarliestDate > Subscription."Valid Until Date") then
            if (TryCalculatePeriodEndCovering(Membership, Subscription, EarliestDate, CoveringPeriodEnd, PeriodsRenewed)) then
                EarliestDate := CoveringPeriodEnd;

        exit(true);
    end;

    /// <summary>
    /// How long the membership stays usable if the guest cancels auto-renewal right now, and whether one more period
    /// is charged before that. This is the guest-facing display value behind the API's usableUntilDate.
    /// </summary>
    /// <remarks>
    /// Deliberately separate from GetEarliestTerminationDate. That one answers "what termination date will the system
    /// accept", which is an input to RequestTermination and must stay compatible with CheckTerminationPeriod. This one
    /// answers "when does the card stop working", which is free to clamp and to decline to answer.
    /// </remarks>
    internal procedure GetUsableUntilDateIfCancelledNow(Membership: Record "NPR MM Membership"; var UsableUntilDate: Date; var RenewalRequiredFirst: Boolean): Boolean
    var
        NextRenewalAttemptDate: Date;
        RenewalIsPlanned: Boolean;
    begin
        exit(GetSubscriptionDates(Membership, UsableUntilDate, RenewalRequiredFirst, NextRenewalAttemptDate, RenewalIsPlanned));
    end;

    /// <summary>
    /// Overload for callers that already hold the subscription, so a response building several of these values does
    /// not re-read it per field.
    /// </summary>
    internal procedure GetUsableUntilDateIfCancelledNow(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription"; var UsableUntilDate: Date; var RenewalRequiredFirst: Boolean): Boolean
    var
        NextRenewalAttemptDate: Date;
        RenewalIsPlanned: Boolean;
    begin
        exit(GetSubscriptionDates(Membership, Subscription, UsableUntilDate, RenewalRequiredFirst, NextRenewalAttemptDate, RenewalIsPlanned));
    end;

    /// <summary>
    /// Both guest-facing subscription dates in one pass: how long the membership stays usable if the guest cancels
    /// now, and when the next renewal charge will be attempted. Returns whether the usable-until date could be
    /// answered at all; RenewalIsPlanned says the same for the attempt date.
    /// </summary>
    /// <remarks>
    /// The attempt date is worked out once and handed to the usable-until calculation, which gates on it. Computing it
    /// separately per field left the two free to disagree, and made a single guest-facing GET run the whole subscription
    /// read twice over, setup and alteration rule lookups included. Callers reporting both values should use this
    /// rather than the two single-value procedures, which exist for callers that genuinely want only one.
    /// </remarks>
    internal procedure GetSubscriptionDates(Membership: Record "NPR MM Membership"; var UsableUntilDate: Date; var RenewalRequiredFirst: Boolean; var NextRenewalAttemptDate: Date; var RenewalIsPlanned: Boolean): Boolean
    var
        Subscription: Record "NPR MM Subscription";
    begin
        Clear(UsableUntilDate);
        Clear(NextRenewalAttemptDate);
        RenewalRequiredFirst := false;
        RenewalIsPlanned := false;

        if (not GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            exit(false);

        exit(GetSubscriptionDates(Membership, Subscription, UsableUntilDate, RenewalRequiredFirst, NextRenewalAttemptDate, RenewalIsPlanned));
    end;

    /// <summary>
    /// Overload for callers that already hold the subscription, so a response building several of these values does
    /// not re-read it per field.
    /// </summary>
    internal procedure GetSubscriptionDates(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription"; var UsableUntilDate: Date; var RenewalRequiredFirst: Boolean; var NextRenewalAttemptDate: Date; var RenewalIsPlanned: Boolean): Boolean
    begin
        Clear(UsableUntilDate);
        Clear(NextRenewalAttemptDate);
        RenewalRequiredFirst := false;

        RenewalIsPlanned := GetNextRenewalAttemptDate(Membership, Subscription, NextRenewalAttemptDate);
        exit(CalculateUsableUntilDate(Membership, Subscription, RenewalIsPlanned, UsableUntilDate, RenewalRequiredFirst));
    end;

    local procedure CalculateUsableUntilDate(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription"; RenewalIsPlanned: Boolean; var UsableUntilDate: Date; var RenewalRequiredFirst: Boolean): Boolean
    var
        TerminationEffectiveDate: Date;
        CoveringPeriodEnd: Date;
        AgreedTerminationDate: Date;
        PeriodsRenewed: Integer;
        TerminationIsAgreed: Boolean;
    begin
        RenewalRequiredFirst := false;
        Clear(UsableUntilDate);

        // Only meaningful while there is an internally managed auto-renewal to cancel. Termination of anything else
        // is rejected outright, so quoting a date would contradict the rest of the payload.
        if (not (Subscription."Auto-Renew" in [Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew"::TERMINATION_REQUESTED])) then
            exit(false);

        // Without a period end nothing below can be reasoned about: every comparison against it would be against a
        // blank date. Same guard as AutoRenewalCanStillHappen, so the two fields agree about what is answerable.
        if (Subscription."Valid Until Date" = 0D) then
            exit(false);

        // Work out when the termination takes effect. Once one is agreed with the guest that date is the answer;
        // otherwise it is the earliest the notice period and any commitment allow. Kept in one place rather than in
        // each API agent so every consumer reports the same thing.
        // Nested rather than an "and": AL has no short-circuit evaluation and the lookup reads the database.
        TerminationIsAgreed := false;
        if (Subscription."Auto-Renew" = Subscription."Auto-Renew"::TERMINATION_REQUESTED) then
            TerminationIsAgreed := TryGetAgreedTerminationDate(Subscription, AgreedTerminationDate);

        if (TerminationIsAgreed) then begin
            TerminationEffectiveDate := AgreedTerminationDate;
        end else begin
            TerminationEffectiveDate := CalculateEarliestTerminationDate(Membership);
            if (TerminationEffectiveDate < Subscription."Committed Until") then
                TerminationEffectiveDate := Subscription."Committed Until";
            // A termination cannot take effect in the past. Neither input guarantees a future date: with no notice
            // period the calculation yields 0D, and Committed Until is stamped once and never cleared, so it is stale
            // as soon as the commitment has passed. In both cases the guest can end it immediately, which means today.
            if (TerminationEffectiveDate < Today()) then
                TerminationEffectiveDate := Today();
        end;

        // Terminating only switches auto-renewal off - ProcessTermination calls DisableMembershipAutoRenewal and
        // nothing shortens the membership entry - so the card keeps working to the end of the period already paid
        // for. The guest-facing answer is that period's end, not the date the termination takes effect. This is what
        // the Mit Tivoli card means by "cancel now and you can still use it until <date>".
        if (TerminationEffectiveDate <= Subscription."Valid Until Date") then begin
            UsableUntilDate := Subscription."Valid Until Date";
            exit(true);
        end;

        // The notice period runs past the paid period, so the membership renews, and is charged, until a period
        // covers it. A notice period longer than one renewal period takes more than one renewal to reach.
        //
        // Gated on the very value reported as nextRenewalAttemptDate, passed in by the caller rather than worked out
        // again here, so the two fields cannot disagree. Gating on a separate feasibility predicate instead left
        // cases - an expired subscription whose whole schedule is in the past, for one - where this claimed a further
        // charge while that field was null.
        if (not RenewalIsPlanned) then begin
            // Nothing will renew, so there is no next period to run into: the membership stops when the paid period
            // ends. Deliberately not clamped up to today - for a membership that has already lapsed, the honest
            // answer to "how long can I still use this" is the past date it stopped on, not a claim that it works
            // today. The clamp above applies to the notice period, which is a commitment, not to an observed end.
            UsableUntilDate := Subscription."Valid Until Date";
            exit(true);
        end;

        // A renewal is coming but the covering period could not be worked out - the roll-forward hit its cap, or the
        // duration does not advance. Decline rather than answer: reporting the paid period end here would say the
        // membership stops while nextRenewalAttemptDate says it is about to be charged.
        if (not TryCalculatePeriodEndCovering(Membership, Subscription, TerminationEffectiveDate, CoveringPeriodEnd, PeriodsRenewed)) then
            exit(false);

        UsableUntilDate := CoveringPeriodEnd;
        RenewalRequiredFirst := (PeriodsRenewed > 0);
        exit(true);
    end;

    /// <summary>
    /// The end of the notice period, counted from today.
    /// </summary>
    /// <remarks>
    /// Today, not WorkDate. A notice period is a commitment to the guest measured in calendar days, so no session may
    /// move it: neither a service session behind the guest-facing endpoint nor a back-office session sitting on a
    /// stray work date. This also gates CheckTerminationPeriod, so the termination page, POS and the public
    /// RequestSubscriptionTermination measure the notice from today as well.
    ///
    /// That is deliberate, and it puts the gate on the same clock as the date it compares against: the subscription's
    /// own Valid Until Date is derived through GetMembershipValidDate(..., Today, ...) a few procedures up.
    /// </remarks>
    local procedure CalculateEarliestTerminationDate(Membership: Record "NPR MM Membership") TerminationDate: Date
    var
        RecurPaymtSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        if (not TryGetRecurPaymentSetup(Membership, RecurPaymtSetup)) then
            exit;
        if (Format(RecurPaymtSetup.TerminationPeriod) = '') then
            exit;
        TerminationDate := CalcDate(RecurPaymtSetup.TerminationPeriod, Today());
    end;

    internal procedure GetNextRenewalAttemptDate(Membership: Record "NPR MM Membership"; var NextAttemptDate: Date): Boolean
    var
        Subscription: Record "NPR MM Subscription";
    begin
        Clear(NextAttemptDate);

        if (not GetSubscriptionFromMembership(Membership."Entry No.", Subscription)) then
            exit(false);

        exit(GetNextRenewalAttemptDate(Membership, Subscription, NextAttemptDate));
    end;

    /// <summary>
    /// Overload for callers that already hold the subscription, so a response building several of these values does
    /// not re-read it per field.
    /// </summary>
    internal procedure GetNextRenewalAttemptDate(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription"; var NextAttemptDate: Date): Boolean
    var
        RecurPaymtSetup: Record "NPR MM Recur. Paym. Setup";
        EarliestAllowedDate: Date;
    begin
        Clear(NextAttemptDate);

        if (not AutoRenewalCanStillHappen(Membership, Subscription)) then
            exit(false);

        if (not TryGetRecurPaymentSetupForSubscription(Subscription, RecurPaymtSetup)) then
            exit(false);

        EarliestAllowedDate := Today();
        if (Subscription."Postpone Renewal Attempt Until" > EarliestAllowedDate) then
            EarliestAllowedDate := Subscription."Postpone Renewal Attempt Until";

        case RecurPaymtSetup."Subscr. Auto-Renewal On" of
            RecurPaymtSetup."Subscr. Auto-Renewal On"::Schedule:
                exit(FindNextScheduledRenewalAttempt(RecurPaymtSetup, Subscription, EarliestAllowedDate, NextAttemptDate));
            RecurPaymtSetup."Subscr. Auto-Renewal On"::"Expiry Date",
            RecurPaymtSetup."Subscr. Auto-Renewal On"::"Next Start Date":
                exit(FindNextOffsetRenewalAttempt(RecurPaymtSetup, Subscription, EarliestAllowedDate, NextAttemptDate));
        end;

        // Never falls through to "no date".
        exit(false);
    end;

    /// <summary>
    /// Answers whether an automatic renewal can still happen at all for this subscription.
    /// </summary>
    /// <remarks>
    /// Deliberately gates only on conditions that mean an attempt will NEVER happen, not on everything the renewal
    /// request job filters on. A renewal request that is already outstanding, for example, stops that job creating
    /// another one, but the processing job is about to charge it - so suppressing the date there would hide an
    /// imminent payment rather than avoid promising a phantom one.
    /// </remarks>
    local procedure AutoRenewalCanStillHappen(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription"): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        RecurPaymtSetup: Record "NPR MM Recur. Paym. Setup";
        TerminationRequest: Record "NPR MM Subscr. Request";
        PeriodDuration: DateFormula;
    begin
        // Without a period end there is no date to base an attempt on.
        if (Subscription."Valid Until Date" = 0D) then
            exit(false);

        if (Subscription.Blocked) then
            exit(false);

        if (not (Subscription."Auto-Renew" in [Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew"::TERMINATION_REQUESTED])) then
            exit(false);

        // Only membership types on the recurring payment model are ever picked up; the others can keep a stale
        // Recurring Payment Code that nothing acts on.
        if (not MembershipSetup.Get(Subscription."Membership Code")) then
            exit(false);
        if (MembershipSetup."Auto-Renew Model" <> MembershipSetup."Auto-Renew Model"::RECURRING_PAYMENT) then
            exit(false);

        // A missing recurring payment setup, or one set to never renew automatically, means the job exits before it
        // ever looks at the subscription.
        if (not TryGetRecurPaymentSetupForSubscription(Subscription, RecurPaymtSetup)) then
            exit(false);
        if (RecurPaymtSetup."Subscr. Auto-Renewal On" = RecurPaymtSetup."Subscr. Auto-Renewal On"::Never) then
            exit(false);

        // A cancellation that takes effect on or before the period end stops the renewal outright - this is the
        // ordinary shape of a cancelled subscription, so without this check every cancelled membership would still
        // advertise a charge.
        //
        // Mirrors IsTerminationDue in "NPR MM Subscr. Renew: Request", its Auto-Renew precondition included. That
        // precondition is load-bearing rather than decoration: the engine does not look for a termination at all
        // unless the subscription is flagged TERMINATION_REQUESTED, so asking without it reports "no charge coming"
        // for a subscription the engine will renew and charge. A YES_INTERNAL subscription can carry a Pending
        // Terminate row - the Adyen handler leaves one Cancelled while still Pending, and resuming auto-renewal does
        // not clear it, because cancelling an already cancelled request exits before touching processing status.
        //
        // The absence of a Status filter is part of the same mirror: the engine has none, so a row left Cancelled and
        // Pending does stop its renewal, and excluding it here would put the two back out of step.
        if (Subscription."Auto-Renew" = Subscription."Auto-Renew"::TERMINATION_REQUESTED) then begin
            TerminationRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
            TerminationRequest.SetRange(Type, TerminationRequest.Type::Terminate);
            TerminationRequest.SetRange("Processing Status", TerminationRequest."Processing Status"::Pending);
            TerminationRequest.SetFilter("Terminate At", '<=%1', Subscription."Valid Until Date");
            if (not TerminationRequest.IsEmpty()) then
                exit(false);
        end;

        // A renewal with nowhere to renew to fails on every run and never charges, so there is no attempt to report.
        exit(TryGetAutoRenewPeriodDuration(Membership, PeriodDuration));
    end;

    /// <summary>
    /// Resolves the recurring payment setup the renewal job would use for this subscription. The job matches
    /// subscriptions on Subscription."Membership Code", so the prediction has to resolve from the same field rather
    /// than from the membership, which can carry a different code after an upgrade.
    /// </summary>
    local procedure TryGetRecurPaymentSetupForSubscription(Subscription: Record "NPR MM Subscription"; var RecurPaymentSetup: Record "NPR MM Recur. Paym. Setup"): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        Clear(RecurPaymentSetup);
        if (not MembershipSetup.Get(Subscription."Membership Code")) then
            exit(false);
        exit(RecurPaymentSetup.Get(MembershipSetup."Recurring Payment Code"));
    end;

    local procedure FindNextScheduledRenewalAttempt(RecurPaymtSetup: Record "NPR MM Recur. Paym. Setup"; Subscription: Record "NPR MM Subscription"; EarliestAllowedDate: Date; var NextAttemptDate: Date): Boolean
    var
        RenewalSchedLine: Record "NPR MM Renewal Sched Line";
        AttemptDate: Date;
    begin
        if (RecurPaymtSetup."Subscr Auto-Renewal Sched Code" = '') then
            exit(false);

        // The schedule only fires on its exact dates, so once they are all behind us there is no further attempt.
        RenewalSchedLine.SetCurrentKey("Schedule Code", "Date Formula Duration (Days)");
        RenewalSchedLine.SetRange("Schedule Code", RecurPaymtSetup."Subscr Auto-Renewal Sched Code");
        if (not RenewalSchedLine.FindSet()) then
            exit(false);

        repeat
            AttemptDate := Subscription."Valid Until Date" + RenewalSchedLine."Date Formula Duration (Days)";
            if (AttemptDate >= EarliestAllowedDate) then begin
                NextAttemptDate := AttemptDate;
                exit(true);
            end;
        until (RenewalSchedLine.Next() = 0);

        exit(false);
    end;

    local procedure FindNextOffsetRenewalAttempt(RecurPaymtSetup: Record "NPR MM Recur. Paym. Setup"; Subscription: Record "NPR MM Subscription"; EarliestAllowedDate: Date; var NextAttemptDate: Date): Boolean
    var
        FirstAttemptDate: Date;
    begin
        // A postpone date the engine has already written is authoritative: it scheduled that attempt itself, so report
        // it whatever else is true. This has to be checked before the lapsed-period bail-out below, because the Next
        // Start Date model routinely postpones to after the period end - with a zero offset, to the very next day -
        // and bailing out first would report "no charge coming" on the exact day the guest is billed.
        if (Subscription."Postpone Renewal Attempt Until" >= Today()) then begin
            NextAttemptDate := Subscription."Postpone Renewal Attempt Until";
            exit(true);
        end;

        // Once the paid period has ended with no scheduled attempt, whether the job still retries depends on how many
        // attempts a failed request has already burned against Max. Pay. Process Try Count. A request in terminal
        // error is never retried, so answering "today" would advertise a charge that never comes, every day, forever.
        // Modelling the try count would mean mirroring yet another branch of the renewal engine, so decline instead.
        // This under-reports during a legitimate post-expiry retry, the safer direction for a guest-facing date.
        if (Subscription."Valid Until Date" < Today()) then
            exit(false);

        // Within the period the job retries daily once the offset window has opened, so the next attempt is either the
        // day the window opens or, if that is already behind us, the first day an attempt is allowed again.
        //
        // The two offset models differ by where the window is anchored. Expiry Date counts back from the period end;
        // Next Start Date counts back from the start of the next period, which the engine builds back to back with
        // this one. Once the job has run once it persists the exact date in Postpone Renewal Attempt Until, which
        // EarliestAllowedDate already carries, so this only has to be right for the window before that first run.
        FirstAttemptDate := Subscription."Valid Until Date" - RecurPaymtSetup."First Attempt Offset (Days)";
        if (RecurPaymtSetup."Subscr. Auto-Renewal On" = RecurPaymtSetup."Subscr. Auto-Renewal On"::"Next Start Date") then
            FirstAttemptDate := CalcDate('<+1D>', Subscription."Valid Until Date") - RecurPaymtSetup."First Attempt Offset (Days)";

        if (FirstAttemptDate < EarliestAllowedDate) then
            FirstAttemptDate := EarliestAllowedDate;

        NextAttemptDate := FirstAttemptDate;
        exit(true);
    end;

    /// <summary>
    /// Rolls forward from the paid period until the period end reaches TargetDate, so a notice period spanning more
    /// than one renewal period lands on the period that actually covers it. Also reports how many renewals that took,
    /// which is what tells the guest whether a further charge is coming.
    /// </summary>
    /// <remarks>
    /// Assumes periods run back to back, as the shipped one-period calculation always has. An AUTORENEW rule using
    /// Alteration Activate From::DF starts its next period from a date formula instead, so the quoted period end is
    /// an approximation for those setups. Deriving it exactly means re-running the renewal calculation, which is the
    /// engine-mirroring this feature deliberately avoids.
    /// </remarks>
    local procedure TryCalculatePeriodEndCovering(Membership: Record "NPR MM Membership"; Subscription: Record "NPR MM Subscription"; TargetDate: Date; var PeriodEnd: Date; var PeriodsRenewed: Integer): Boolean
    var
        PeriodDuration: DateFormula;
        PreviousPeriodEnd: Date;
    begin
        PeriodsRenewed := 0;

        // Nothing to roll forward from. Walking from a blank period end would anchor every period on the AL date
        // epoch rather than on the subscription's own schedule, so the covering period end would be a date with no
        // relation to it. Guarded here rather than at each call site so no future caller can reintroduce it.
        if (Subscription."Valid Until Date" = 0D) then
            exit(false);

        if (not TryGetAutoRenewPeriodDuration(Membership, PeriodDuration)) then
            exit(false);

        PeriodEnd := Subscription."Valid Until Date";
        while (PeriodEnd < TargetDate) do begin
            PreviousPeriodEnd := PeriodEnd;
            PeriodEnd := CalcDate(PeriodDuration, CalcDate('<+1D>', PreviousPeriodEnd));

            // A duration that does not move the period end forward would loop forever. Refuse to answer rather than
            // spin, and rather than return a date derived from a setup that cannot renew.
            if (PeriodEnd <= PreviousPeriodEnd) then
                exit(false);

            PeriodsRenewed += 1;

            // A long-lapsed subscription on a short period - daily, say, abandoned for years - would otherwise walk
            // thousands of steps inside a synchronous request. Nothing legitimate needs this many renewals to cover a
            // notice period, so treat it as unanswerable rather than spend the time.
            if (PeriodsRenewed > MaxPeriodsToRollForward()) then
                exit(false);
        end;

        exit(true);
    end;

    /// <summary>
    /// Reads the termination date already agreed with the guest.
    /// </summary>
    /// <remarks>
    /// Pending only, because that is all the termination job takes: a request stuck in Error will not be applied, so
    /// treating its date as agreed would report the membership stopping while a charge is still coming. Falling
    /// through to the notice period calculation describes that state correctly.
    ///
    /// The Status exclusion is a deliberate divergence from the engine rather than a mirror of it. Neither
    /// IsTerminationDue nor the termination job filters Status at all, so a request left Cancelled while still
    /// Pending - the state the Adyen handler produces, since it sets Status without closing the processing off - is
    /// one the engine will still act on. This declines to quote it anyway: the field answers what the guest agreed
    /// to, and they withdrew this one. The row surviving as Pending is a defect in that handler, and quoting its date
    /// would carry the defect into a guest-facing answer.
    ///
    /// This is deliberately narrower than GetTerminationSubsRequest in the API agent, which reports terminateAt and
    /// the rest of the request. That field records what the guest asked for and stays visible while the request is
    /// live, Error included. This one answers when the card stops, which only a request that will be applied can
    /// change.
    /// </remarks>
    local procedure TryGetAgreedTerminationDate(Subscription: Record "NPR MM Subscription"; var AgreedTerminationDate: Date): Boolean
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        Clear(AgreedTerminationDate);

        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Terminate);
        SubscriptionRequest.SetFilter(Status, '<>%1&<>%2', SubscriptionRequest.Status::Cancelled, SubscriptionRequest.Status::Skipped);
        SubscriptionRequest.SetRange("Processing Status", SubscriptionRequest."Processing Status"::Pending);
        if (not SubscriptionRequest.FindLast()) then
            exit(false);

        AgreedTerminationDate := SubscriptionRequest."Terminate At";
        exit(AgreedTerminationDate <> 0D);
    end;

    local procedure MaxPeriodsToRollForward(): Integer
    begin
        exit(120);
    end;

    local procedure TryGetAutoRenewPeriodDuration(Membership: Record "NPR MM Membership"; var PeriodDuration: DateFormula): Boolean
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        RenewWithItemNo: Code[20];
        AlterationRuleSystemId: Guid;
        ReasonText: Text;
    begin
        Clear(PeriodDuration);

        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            exit(false);

        if (not MembershipMgt.SelectAutoRenewRule(MembershipEntry, RenewWithItemNo, AlterationRuleSystemId, ReasonText)) then
            exit(false);

        if (not MembershipAlterationSetup.GetBySystemId(AlterationRuleSystemId)) then
            exit(false);

        if (Format(MembershipAlterationSetup."Membership Duration") = '') then
            exit(false);

        PeriodDuration := MembershipAlterationSetup."Membership Duration";
        exit(true);
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
        CreationErrorText: Text;
        NewSubscriptionRequestConfirmLbl: Label 'Are you sure you want to create a new subscription request for subscription no. %1?', Comment = '%1 - Subscription entry no.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(NewSubscriptionRequestConfirmLbl, Subscription."Entry No."), true) then
            exit;

        ClearLastError();
        if not SubscrRenewRequest.Run(Subscription) then begin
            // Manual Create surfaces the error to the admin directly, so log to Sentry only when it's a programming bug.
            // Capture the cause before reporting: Sentry's FinalizeScope is a TryFunction and could replace the last error.
            CreationErrorText := GetLastErrorText();
            ReportSubscriptionRenewalCreationProgrammingBugFromLastError(Subscription);
            Error(CreationErrorText);
        end;
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
        MemberNotification: Codeunit "NPR MM Member Notification";
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

        MemberNotification.AddTerminationRequestedNotification(Membership."Entry No.", Membership."Membership Code", TerminationRequest."Terminate At", TerminationRequest."Termination Requested At");

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
        MemberNotification: Codeunit "NPR MM Member Notification";
        SubscrRequestUtils: Codeunit "NPR MM Subscr. Request Utils";
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

                    // Resuming into an internal subscription - cancel any pending/errored termination request so it doesn't remain stuck and later affect the membership.
                    SubscrRequestUtils.CancelPendingTerminationRequests(Subscription."Entry No.");
                end;
            "NPR MM MembershipAutoRenew"::TERMINATION_REQUESTED:
                begin
                    // This is a catch all if somebody sets it directly on the membership. We make some assumptions here.
                    CreateTerminationSubsRequest(Subscription, Today(), "NPR MM Subs Termination Reason"::CUSTOMER_INITIATED, TerminationRequest);
                    MemberNotification.AddTerminationRequestedNotification(Membership."Entry No.", Membership."Membership Code", TerminationRequest."Terminate At", TerminationRequest."Termination Requested At");
                end;

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

        if (EarliestTerminationDate > RequestedDate) then
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

    internal procedure ProcessMembershipEntryForInitialSale(SalePOS: Record "NPR POS Sale"; MembershipEntry: Record "NPR MM Membership Entry")
    var
        ActiveMembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if MembershipEntry.Context <> MembershipEntry.Context::NEW then
            exit;

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

    internal procedure CreateCancellationSubscriptionRequest(Subscription: Record "NPR MM Subscription"; MembershipEntry: Record "NPR MM Membership Entry"; MemberInfoCapture: Record "NPR MM Member Info Capture"; SalesTicketNo: Code[20]; NewValidUntilDate: Date)
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
        PartialRegretRequest."New Valid Until Date" := NewValidUntilDate;
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

    /// <summary>
    /// Reports a terminal payment-request error to Sentry with a caller-supplied cause (English text + callstack).
    /// Use this when the originating error is no longer the live last error at report time (e.g. the JQ crash
    /// path, which must snapshot the cause before a later TryFunction).
    /// </summary>
    internal procedure ReportPaymentRequestTerminalError(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; CauseText: Text; CauseCallStack: Text)
    var
        Tags: Dictionary of [Text, Text];
        TransactionNameLbl: Label 'Subscription payment request %1 failed', Locked = true, Comment = '%1 = entry no.';
        PaymentTerminalErrorMsgLbl: Label 'Subscription payment request reached terminal Error status', Locked = true;
    begin
        // Preserve the CORE-775 payment-specific fallback text (the generic core default would otherwise change observable behavior).
        if CauseText = '' then
            CauseText := PaymentTerminalErrorMsgLbl;
        BuildPaymentRequestTags(SubscrPaymentRequest, Tags);
        ReportSubscriptionTerminalError(StrSubstNo(TransactionNameLbl, SubscrPaymentRequest."Entry No."), Tags, CauseText, CauseCallStack);
    end;

    /// <summary>
    /// Reports a terminal payment-request error to Sentry from the live last error (English text + callstack).
    /// Use when the failure is still the last error at report time (e.g. the Adyen ProcessResponse path).
    /// Falls back to FallbackMessage when there is no AL error (e.g. webhook success=false carries only a reason).
    /// </summary>
    internal procedure ReportPaymentRequestTerminalErrorFromLastError(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; FallbackMessage: Text)
    var
        Tags: Dictionary of [Text, Text];
        TransactionNameLbl: Label 'Subscription payment request %1 failed', Locked = true, Comment = '%1 = entry no.';
        PaymentTerminalErrorMsgLbl: Label 'Subscription payment request reached terminal Error status', Locked = true;
    begin
        if FallbackMessage = '' then
            FallbackMessage := PaymentTerminalErrorMsgLbl;
        BuildPaymentRequestTags(SubscrPaymentRequest, Tags);
        ReportSubscriptionTerminalErrorFromLastError(StrSubstNo(TransactionNameLbl, SubscrPaymentRequest."Entry No."), Tags, FallbackMessage);
    end;

    /// <summary>
    /// Reports a terminal payment-request failure to Sentry only when the last error is a genuine programming bug.
    /// Used by the manual Process path, where the admin already sees the thrown error.
    /// </summary>
    internal procedure ReportPaymentRequestTerminalProgrammingBugFromLastError(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        Tags: Dictionary of [Text, Text];
        TransactionNameLbl: Label 'Subscription payment request %1 failed', Locked = true, Comment = '%1 = entry no.';
    begin
        BuildPaymentRequestTags(SubscrPaymentRequest, Tags);
        ReportSubscriptionTerminalProgrammingBugFromLastError(StrSubstNo(TransactionNameLbl, SubscrPaymentRequest."Entry No."), Tags);
    end;

    local procedure BuildPaymentRequestTags(SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; var Tags: Dictionary of [Text, Text])
    begin
        Tags.Add('subscription_payment.entry_no', Format(SubscrPaymentRequest."Entry No.", 0, 9));
        Tags.Add('subscription_payment.psp_reference', SubscrPaymentRequest."PSP Reference");
        Tags.Add('subscription_payment.psp', Format(SubscrPaymentRequest.PSP));
        Tags.Add('subscription_payment.request_type', Format(SubscrPaymentRequest.Type));
    end;

    /// <summary>
    /// Reports a terminal subscription-request processing failure to Sentry from the live last error.
    /// Use in the automated processing path (Renew Proc JQ), which logs every request that reaches terminal Error.
    /// </summary>
    internal procedure ReportSubscriptionRequestTerminalErrorFromLastError(SubscrRequest: Record "NPR MM Subscr. Request"; FallbackMessage: Text)
    var
        Tags: Dictionary of [Text, Text];
        TransactionNameLbl: Label 'Subscription request %1 failed', Locked = true, Comment = '%1 = entry no.';
        DefaultMessageLbl: Label 'Subscription request reached terminal Error status', Locked = true;
    begin
        if FallbackMessage = '' then
            FallbackMessage := DefaultMessageLbl;
        BuildSubscriptionRequestTags(SubscrRequest, Tags);
        ReportSubscriptionTerminalErrorFromLastError(StrSubstNo(TransactionNameLbl, SubscrRequest."Entry No."), Tags, FallbackMessage);
    end;

    /// <summary>
    /// Reports a terminal subscription-request processing failure to Sentry only when the last error is a genuine
    /// programming bug. Used by the manual Process button, where the admin already sees the thrown error.
    /// </summary>
    internal procedure ReportSubscriptionRequestTerminalProgrammingBugFromLastError(SubscrRequest: Record "NPR MM Subscr. Request")
    var
        Tags: Dictionary of [Text, Text];
        TransactionNameLbl: Label 'Subscription request %1 failed', Locked = true, Comment = '%1 = entry no.';
    begin
        BuildSubscriptionRequestTags(SubscrRequest, Tags);
        ReportSubscriptionTerminalProgrammingBugFromLastError(StrSubstNo(TransactionNameLbl, SubscrRequest."Entry No."), Tags);
    end;

    local procedure BuildSubscriptionRequestTags(SubscrRequest: Record "NPR MM Subscr. Request"; var Tags: Dictionary of [Text, Text])
    begin
        Tags.Add('subscription_request.entry_no', Format(SubscrRequest."Entry No.", 0, 9));
        Tags.Add('subscription_request.subscription_entry_no', Format(SubscrRequest."Subscription Entry No.", 0, 9));
        Tags.Add('subscription_request.type', Format(SubscrRequest.Type));
        Tags.Add('subscription_request.membership_code', SubscrRequest."Membership Code");
    end;

    /// <summary>
    /// Reports a renewal-request creation failure to Sentry from the live last error.
    /// Use in the automated creation path (Renew Req JQ), which logs every failed creation attempt.
    /// </summary>
    internal procedure ReportSubscriptionRenewalCreationErrorFromLastError(Subscription: Record "NPR MM Subscription"; FallbackMessage: Text)
    var
        Tags: Dictionary of [Text, Text];
        TransactionNameLbl: Label 'Subscription renewal creation for subscription %1 failed', Locked = true, Comment = '%1 = subscription entry no.';
        DefaultMessageLbl: Label 'Subscription renewal request creation failed', Locked = true;
    begin
        if FallbackMessage = '' then
            FallbackMessage := DefaultMessageLbl;
        BuildSubscriptionTags(Subscription, Tags);
        ReportSubscriptionTerminalErrorFromLastError(StrSubstNo(TransactionNameLbl, Subscription."Entry No."), Tags, FallbackMessage);
    end;

    /// <summary>
    /// Reports a renewal-request creation failure to Sentry only when the last error is a genuine programming bug.
    /// Used by the manual Create button, where the admin already sees the thrown error.
    /// </summary>
    internal procedure ReportSubscriptionRenewalCreationProgrammingBugFromLastError(Subscription: Record "NPR MM Subscription")
    var
        Tags: Dictionary of [Text, Text];
        TransactionNameLbl: Label 'Subscription renewal creation for subscription %1 failed', Locked = true, Comment = '%1 = subscription entry no.';
    begin
        BuildSubscriptionTags(Subscription, Tags);
        ReportSubscriptionTerminalProgrammingBugFromLastError(StrSubstNo(TransactionNameLbl, Subscription."Entry No."), Tags);
    end;

    local procedure BuildSubscriptionTags(Subscription: Record "NPR MM Subscription"; var Tags: Dictionary of [Text, Text])
    begin
        Tags.Add('subscription.entry_no', Format(Subscription."Entry No.", 0, 9));
        Tags.Add('subscription.membership_entry_no', Format(Subscription."Membership Entry No.", 0, 9));
        Tags.Add('subscription.membership_code', Subscription."Membership Code");
    end;

    local procedure ReportSubscriptionTerminalError(TransactionName: Text; var Tags: Dictionary of [Text, Text]; CauseText: Text; CauseCallStack: Text)
    var
        Sentry: Codeunit "NPR Sentry";
        EffectiveMessage: Text;
        TagKey: Text;
        TerminalErrorMsgLbl: Label 'Subscription operation failed', Locked = true;
        OperationTok: Label 'bc.membership.subscription.error', Locked = true;
    begin
        EffectiveMessage := CauseText;
        if EffectiveMessage = '' then
            EffectiveMessage := TerminalErrorMsgLbl;

        Sentry.InitScopeAndTransaction(CopyStr(TransactionName, 1, 250), OperationTok);
        foreach TagKey in Tags.Keys() do
            Sentry.AddTransactionTag(TagKey, Tags.Get(TagKey));
        Sentry.AddError(EffectiveMessage, CauseCallStack);
        Sentry.FinalizeScope();
    end;

    local procedure ReportSubscriptionTerminalErrorFromLastError(TransactionName: Text; var Tags: Dictionary of [Text, Text]; FallbackMessage: Text)
    var
        Sentry: Codeunit "NPR Sentry";
        ErrorText: Text;
        ErrorCallStack: Text;
    begin
        Sentry.GetLastErrorInEnglish(ErrorText, ErrorCallStack);
        if ErrorText = '' then
            ErrorText := FallbackMessage;
        ReportSubscriptionTerminalError(TransactionName, Tags, ErrorText, ErrorCallStack);
    end;

    local procedure ReportSubscriptionTerminalProgrammingBugFromLastError(TransactionName: Text; var Tags: Dictionary of [Text, Text])
    var
        SentryErrorHandling: Codeunit "NPR Sentry Error Handling";
    begin
        // Gate before opening the scope: the core transaction always samples, so a non-bug error would emit an empty transaction.
        if not SentryErrorHandling.IsLastErrorAProgrammingBug() then
            exit;
        ReportSubscriptionTerminalErrorFromLastError(TransactionName, Tags, '');
    end;
}

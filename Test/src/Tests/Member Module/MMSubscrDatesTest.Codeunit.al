#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 85429 "NPR MMSubscrDatesTest"
{
    // [FEATURE] Membership Subscription Termination And Renewal Dates
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _NoticePeriodConfirmWasRaised: Boolean;
        _MemberModuleLib: Codeunit "NPR Library - Member Module";
        _GoldMembershipCodeLbl: Label 'T-GOLD', Locked = true;
        _GoldSalesItemLbl: Label 'T-320100', Locked = true;
        _RenewalScheduleCodeLbl: Label 'TEST-RENEW', Locked = true;
        _AutoRenewItemLbl: Label 'T-320100-AUTORENEW', Locked = true;
        _AutoRenewDescriptionLbl: Label 'Auto Renew GOLD Membership', Locked = true;

    #region Next renewal attempt date - schedule model

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_ReturnsEarliestScheduledAttempt()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] A subscription whose renewal schedule is entirely in the future reports the earliest of its scheduled attempts.
        Initialize();

        // [GIVEN] A membership renewing on a schedule of 5 and 2 days before expiry, then 1 and 4 days after
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days, so the whole schedule is still ahead
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] An attempt is reported
        Assert.IsTrue(AttemptIsPlanned, 'A next renewal attempt date should be available for an auto-renewing subscription.');

        // [THEN] It is the earliest scheduled attempt, 5 days before expiry
        Assert.AreEqual(CalcDate('<+25D>', Today()), NextRenewalAttemptDate, 'The next renewal attempt should be the earliest scheduled attempt, 5 days before expiry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_SkipsAttemptsInThePast()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] Scheduled attempts that have already passed are skipped in favour of the next one that can still happen.
        Initialize();

        // [GIVEN] A membership renewing on a schedule of 5 and 2 days before expiry, then 1 and 4 days after
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires tomorrow, so the two attempts before expiry have been and gone
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+1D>', Today()));

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] An attempt is reported
        Assert.IsTrue(AttemptIsPlanned, 'A next renewal attempt date should be available while future attempts remain.');

        // [THEN] It is the first attempt still ahead, a day after expiry
        Assert.AreEqual(CalcDate('<+2D>', Today()), NextRenewalAttemptDate, 'Attempts already in the past should be skipped in favour of the next future attempt.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_HonoursPostponeRenewalAttemptUntil()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] Attempts suppressed by Postpone Renewal Attempt Until are skipped in favour of the first attempt that is allowed to run.
        Initialize();

        // [GIVEN] A membership renewing on a schedule of 5 and 2 days before expiry, then 1 and 4 days after
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [GIVEN] Renewal attempts are postponed until 28 days out, past the first scheduled attempt
        _MemberModuleLib.SetSubscriptionPostponeRenewalUntil(Membership."Entry No.", CalcDate('<+28D>', Today()));

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] An attempt is reported
        Assert.IsTrue(AttemptIsPlanned, 'A next renewal attempt date should be available when a later attempt is still allowed.');

        // [THEN] It is the first attempt the postpone date allows
        Assert.AreEqual(CalcDate('<+28D>', Today()), NextRenewalAttemptDate, 'The next renewal attempt should skip attempts suppressed by Postpone Renewal Attempt Until.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_NotAvailableWhenAllAttemptsArePast()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] No renewal attempt is reported once every date in the schedule has passed.
        Initialize();

        // [GIVEN] A membership renewing on a schedule of 5 and 2 days before expiry, then 1 and 4 days after
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expired ten days ago, so every scheduled attempt is behind us
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<-10D>', Today()));

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] No attempt is reported, since there is none left to promise the guest
        Assert.IsFalse(AttemptIsPlanned, 'No renewal attempt date should be reported once the whole schedule is in the past.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_NotAvailableWhenAutoRenewIsOff()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] No renewal attempt is reported for a subscription that is not set to auto-renew, even though its schedule still resolves.
        Initialize();

        // [GIVEN] A membership renewing on a schedule of 5 and 2 days before expiry, then 1 and 4 days after
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [GIVEN] Auto-renewal is switched off
        _MemberModuleLib.SetSubscriptionAutoRenew(Membership."Entry No.", "NPR MM MembershipAutoRenew"::NO);

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] No attempt is reported, since the guest will never be charged again
        Assert.IsFalse(AttemptIsPlanned, 'No renewal attempt date should be reported when auto-renew is off.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_StillReportedWhileARenewalRequestIsOutstanding()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] An outstanding renewal request means a charge is imminent rather than absent, so the attempt date is still reported.
        Initialize();

        // [GIVEN] A membership renewing on a schedule of 5 and 2 days before expiry, then 1 and 4 days after
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [GIVEN] A renewal request is already outstanding, which stops the request job creating a second one
        _MemberModuleLib.CreateOutstandingRenewalRequest(Membership."Entry No.");

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] An attempt is still reported, because the processing job is about to take the money
        Assert.IsTrue(AttemptIsPlanned, 'A renewal attempt date should still be reported while a renewal request is outstanding.');

        // [THEN] It is still the earliest scheduled attempt
        Assert.AreEqual(CalcDate('<+25D>', Today()), NextRenewalAttemptDate, 'The reported attempt should still be the earliest scheduled attempt.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_NotAvailableWhenMembershipDoesNotRenewByRecurringPayment()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] No renewal attempt is reported for a membership type that does not renew through a recurring payment.
        Initialize();

        // [GIVEN] A membership renewing on a schedule of 5 and 2 days before expiry, then 1 and 4 days after
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [GIVEN] The membership type is left on the invoice model, keeping a Recurring Payment Code nothing acts on
        MembershipSetup.Get(_GoldMembershipCodeLbl);
        MembershipSetup."Auto-Renew Model" := MembershipSetup."Auto-Renew Model"::INVOICE;
        MembershipSetup.Modify();

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] No attempt is reported, since the renewal job never walks this membership type
        Assert.IsFalse(AttemptIsPlanned, 'No renewal attempt date should be reported when the membership does not renew through a recurring payment.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_ReportedWhenATerminationRowOutlivesTheTermination()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] A subscription whose auto-renewal was resumed still reports its next renewal attempt, even though the termination request behind it was left unprocessed.
        Initialize();

        // [GIVEN] A membership renewing on a schedule of 5 and 2 days before expiry, then 1 and 4 days after
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [GIVEN] The guest asked to stop inside that period, and auto-renewal was then resumed without the
        // termination request being closed off - the state the Adyen handler leaves behind, since it sets the request
        // to Cancelled without touching its processing status and cancelling it again then exits early
        _MemberModuleLib.RequestSubscriptionTerminationDirectly(Membership."Entry No.", CalcDate('<+10D>', Today()));
        _MemberModuleLib.SetSubscriptionAutoRenew(Membership."Entry No.", "NPR MM MembershipAutoRenew"::YES_INTERNAL);

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] An attempt is reported. The renewal engine does not look for a termination at all unless the
        // subscription is flagged as terminating, so it will renew and charge this one. Answering "no attempt" would
        // tell the guest nothing more is coming and then charge them.
        Assert.IsTrue(AttemptIsPlanned, 'A resumed subscription should report its renewal attempt even with an unprocessed termination request against it.');

        // [THEN] It is the earliest scheduled attempt, 5 days before expiry
        Assert.AreEqual(CalcDate('<+25D>', Today()), NextRenewalAttemptDate, 'The next renewal attempt should be the earliest scheduled attempt, 5 days before expiry.');
    end;

    #endregion

    #region Next renewal attempt date - offset model

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_OffsetModelUsesFirstAttemptOffset()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] On the Expiry Date model the attempt is the expiry date less the first attempt offset, rather than a schedule date.
        Initialize();

        // [GIVEN] A membership with a rule to renew into
        _MemberModuleLib.SetupAutoRenewToSelf(_GoldMembershipCodeLbl, _AutoRenewItemLbl, _AutoRenewDescriptionLbl);

        // [GIVEN] The membership type renews on the Expiry Date model, first attempt 5 days before expiry
        _MemberModuleLib.SetupRecurringPaymentOffsetModel(_GoldMembershipCodeLbl, 5);
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] An attempt is reported
        Assert.IsTrue(AttemptIsPlanned, 'A next renewal attempt date should be available on the offset model.');

        // [THEN] It is the expiry date less the offset
        Assert.AreEqual(CalcDate('<+25D>', Today()), NextRenewalAttemptDate, 'The next renewal attempt should be the expiry date less the first attempt offset.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_NextStartDateModelCountsBackFromTheNextPeriod()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] On the Next Start Date model the attempt window is anchored on the start of the next period, so it lands a day later than on the Expiry Date model.
        Initialize();

        // [GIVEN] A membership with a rule to renew into
        _MemberModuleLib.SetupAutoRenewToSelf(_GoldMembershipCodeLbl, _AutoRenewItemLbl, _AutoRenewDescriptionLbl);

        // [GIVEN] The membership type renews on the Next Start Date model, first attempt 5 days before the next period starts
        _MemberModuleLib.SetupRecurringPaymentNextStartDateModel(_GoldMembershipCodeLbl, 5);
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] An attempt is reported
        Assert.IsTrue(AttemptIsPlanned, 'A next renewal attempt date should be available on the next start date model.');

        // [THEN] It counts back from the day after this period ends, not from the period end itself
        Assert.AreEqual(CalcDate('<+26D>', Today()), NextRenewalAttemptDate, 'The attempt should count back from the start of the next period, a day after this one ends.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_ReportsAScheduledAttemptAfterThePeriodEnded()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] An attempt date the engine has already scheduled is reported even though the paid period has ended.
        Initialize();

        // [GIVEN] A membership with a rule to renew into
        _MemberModuleLib.SetupAutoRenewToSelf(_GoldMembershipCodeLbl, _AutoRenewItemLbl, _AutoRenewDescriptionLbl);

        // [GIVEN] The membership type renews on the Next Start Date model with no offset, which postpones to the day after expiry
        _MemberModuleLib.SetupRecurringPaymentNextStartDateModel(_GoldMembershipCodeLbl, 0);
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expired yesterday and the engine has scheduled today's attempt
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<-1D>', Today()));
        _MemberModuleLib.SetSubscriptionPostponeRenewalUntil(Membership."Entry No.", Today());

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] The scheduled attempt is reported rather than suppressed as a lapsed period
        Assert.IsTrue(AttemptIsPlanned, 'A scheduled attempt should be reported even though the paid period has ended.');

        // [THEN] It is the date the engine wrote down
        Assert.AreEqual(Today(), NextRenewalAttemptDate, 'The date the engine scheduled should be reported as-is.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_OffsetModelSilentOncePeriodHasEnded()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] No renewal attempt is reported on the offset model once the paid period has ended and nothing is scheduled.
        Initialize();

        // [GIVEN] A membership with a rule to renew into
        _MemberModuleLib.SetupAutoRenewToSelf(_GoldMembershipCodeLbl, _AutoRenewItemLbl, _AutoRenewDescriptionLbl);

        // [GIVEN] The membership type renews on the Expiry Date model, first attempt 5 days before expiry
        _MemberModuleLib.SetupRecurringPaymentOffsetModel(_GoldMembershipCodeLbl, 5);
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expired ten days ago with no attempt scheduled
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<-10D>', Today()));

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] No attempt is reported, since whether the job still retries depends on try counts we do not model
        Assert.IsFalse(AttemptIsPlanned, 'No renewal attempt date should be reported on the offset model once the paid period has ended.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NextRenewalAttemptDate_NotAvailableWhenAutoRenewalIsNever()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        NextRenewalAttemptDate: Date;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] No renewal attempt is reported when the recurring payment setup says renewals never run automatically.
        Initialize();

        // [GIVEN] A membership type whose recurring payment setup never renews automatically
        _MemberModuleLib.SetupRecurringPaymentNeverModel(_GoldMembershipCodeLbl);
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [WHEN] The next renewal attempt date is read
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] No attempt is reported
        Assert.IsFalse(AttemptIsPlanned, 'No renewal attempt date should be reported when auto-renewal is set to Never.');
    end;

    #endregion

    #region Earliest termination date

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_WithinCurrentPeriodDoesNotRequireRenewal()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A notice period ending inside the paid period leaves the membership usable to that period's end, with no further charge.
        Initialize();

        // [GIVEN] A membership type with a one month notice period
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months, so the notice period ends well inside it
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available for a subscribed membership.');

        // [THEN] It is the end of the paid period, since terminating only switches auto-renewal off
        Assert.AreEqual(CalcDate('<+6M>', Today()), UsableUntilDate, 'The membership stays usable to the end of the paid period, not to the notice date.');

        // [THEN] No further renewal is flagged
        Assert.IsFalse(RenewalRequiredBeforeTermination, 'No further renewal should be required when the notice period ends inside the current period.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_BeyondCurrentPeriodRequiresRenewalFirst()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        ValidUntilDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A notice period running past the paid period rolls the usable-until date into the next period and flags the further charge.
        Initialize();

        // [GIVEN] A membership that can actually renew, which needs the recurring payment model and a rule to renew into
        SetupTivoliRenewalSchedule();

        // [GIVEN] A one year notice period
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1Y>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days, so the notice period runs past it
        ValidUntilDate := CalcDate('<+30D>', Today());
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", ValidUntilDate);

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available for a subscribed membership.');

        // [THEN] It is the end of the next period
        Assert.AreEqual(CalcDate('<+1Y-1D>', CalcDate('<+1D>', ValidUntilDate)), UsableUntilDate, 'The usable-until date should roll forward to the end of the next period.');

        // [THEN] The further renewal is flagged, so the guest is warned of the charge rather than left to infer it
        Assert.IsTrue(RenewalRequiredBeforeTermination, 'A further renewal should be flagged when the notice period runs past the end of the current period.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_NotAvailableWhenAutoRenewIsOff()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] No usable-until date is reported when auto-renewal is already off, since there is nothing left to cancel.
        Initialize();

        // [GIVEN] A membership type with a one month notice period
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] Auto-renewal is switched off, so a termination request would be rejected outright
        _MemberModuleLib.SetSubscriptionAutoRenew(Membership."Entry No.", "NPR MM MembershipAutoRenew"::NO);

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] No date is reported, since quoting one would contradict the rest of the payload
        Assert.IsFalse(DateIsKnown, 'No usable-until date should be reported when auto-renewal is already off.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_ClampsToPeriodEndWhenNoRenewalRuleResolves()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        ValidUntilDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] With no auto-renew rule to renew into, the membership stops at the paid period end however long the notice period is.
        Initialize();

        // [GIVEN] A membership type with no auto-renew rule configured
        _MemberModuleLib.RemoveAutoRenewSetup(_GoldMembershipCodeLbl);

        // [GIVEN] A one year notice period, which runs past the paid period
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1Y>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        ValidUntilDate := CalcDate('<+30D>', Today());
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", ValidUntilDate);

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available for a subscribed membership.');

        // [THEN] It is the paid period end, not the notice date beyond the point the membership stops working
        Assert.AreEqual(ValidUntilDate, UsableUntilDate, 'The usable-until date should fall back to the end of the paid period when no renewal rule resolves.');

        // [THEN] No further renewal is flagged
        Assert.IsFalse(RenewalRequiredBeforeTermination, 'No further renewal should be flagged when no renewal rule resolves.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_RollsForwardOverEveryPeriodTheNoticeSpans()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        ValidUntilDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A notice period spanning more than one renewal period rolls forward across every period it covers, not just the first.
        Initialize();

        // [GIVEN] A membership renewing into one year periods
        SetupTivoliRenewalSchedule();

        // [GIVEN] A two year notice period, which one roll-forward cannot satisfy
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<2Y>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        ValidUntilDate := CalcDate('<+30D>', Today());
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", ValidUntilDate);

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available for a subscribed membership.');

        // [THEN] It covers the whole notice period rather than stopping after the first renewal
        Assert.IsTrue(UsableUntilDate >= CalcDate('<2Y>', Today()), 'The date should cover the whole notice period, not stop after the first renewal.');

        // [THEN] The further renewals are flagged
        Assert.IsTrue(RenewalRequiredBeforeTermination, 'A further renewal should be flagged when the notice period spans more than the paid period.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_IsTodayWhenThereIsNoNoticePeriod()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A membership type with no notice period reports the paid period end rather than coming back empty.
        Initialize();

        // [GIVEN] A membership renewing on a schedule
        SetupTivoliRenewalSchedule();

        // [GIVEN] No notice period at all, so the guest can end it immediately
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available for a subscribed membership.');

        // [THEN] It is the paid period end, not a blank date
        Assert.AreEqual(CalcDate('<+6M>', Today()), UsableUntilDate, 'With no notice period the guest can end it immediately, and the card still runs to the end of the paid period.');

        // [THEN] No further renewal is flagged
        Assert.IsFalse(RenewalRequiredBeforeTermination, 'No further renewal should be flagged when the membership can end today.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_DoesNotRollForwardWhenAutoRenewalIsNever()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        ValidUntilDate: Date;
        NextRenewalAttemptDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
        AttemptIsPlanned: Boolean;
    begin
        // [SCENARIO] When renewals never run automatically, the usable-until date and the renewal attempt date agree that nothing further will be charged.
        Initialize();

        // [GIVEN] A membership with a rule to renew into
        _MemberModuleLib.SetupAutoRenewToSelf(_GoldMembershipCodeLbl, _AutoRenewItemLbl, _AutoRenewDescriptionLbl);

        // [GIVEN] A recurring payment setup that never renews automatically
        _MemberModuleLib.SetupRecurringPaymentNeverModel(_GoldMembershipCodeLbl);

        // [GIVEN] A one year notice period, which runs past the paid period
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1Y>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        ValidUntilDate := CalcDate('<+30D>', Today());
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", ValidUntilDate);

        // [WHEN] Both subscription dates are read for the membership
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);
        AttemptIsPlanned := SubscriptionMgt.GetNextRenewalAttemptDate(Membership, NextRenewalAttemptDate);

        // [THEN] A usable-until date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available for a subscribed membership.');

        // [THEN] It is the paid period end, not a period that will never be renewed
        Assert.AreEqual(ValidUntilDate, UsableUntilDate, 'The membership should stop at the paid period end when nothing will renew it.');

        // [THEN] No further renewal is claimed
        Assert.IsFalse(RenewalRequiredBeforeTermination, 'No further renewal should be claimed when auto-renewal never runs.');

        // [THEN] The renewal attempt date agrees that nothing will renew
        Assert.IsFalse(AttemptIsPlanned, 'The renewal attempt date must agree that nothing will renew.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_DoesNotClaimARenewalThatCannotHappen()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        AgreedTerminationDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A termination agreed past the paid period claims no further charge when there is no rule to renew into.
        Initialize();

        // [GIVEN] A membership type on the recurring payment model, set explicitly so an earlier test's Never model cannot leak in
        _MemberModuleLib.SetupRenewalSchedule(_GoldMembershipCodeLbl, _RenewalScheduleCodeLbl, TivoliAttemptOffsets());

        // [GIVEN] No auto-renew rule to renew into
        _MemberModuleLib.RemoveAutoRenewSetup(_GoldMembershipCodeLbl);

        // [GIVEN] A one month notice period
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in 30 days
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+30D>', Today()));

        // [GIVEN] A termination has been agreed for six months out, past the paid period
        AgreedTerminationDate := CalcDate('<+6M>', Today());
        _MemberModuleLib.RequestSubscriptionTerminationDirectly(Membership."Entry No.", AgreedTerminationDate);

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'The agreed termination date should be reported.');

        // [THEN] It is the paid period end, with the agreed date reported separately as terminateAt
        Assert.AreEqual(CalcDate('<+30D>', Today()), UsableUntilDate, 'The card stays usable to the end of the paid period; the agreed date is when the subscription ends, reported separately as terminateAt.');

        // [THEN] No further renewal is claimed, since there is nothing to renew into
        Assert.IsFalse(RenewalRequiredBeforeTermination, 'No further renewal should be claimed when there is no renewal rule to renew into.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_IgnoresAWithdrawnTermination()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        WithdrawnTerminationDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A withdrawn termination is ignored, so its date is not reported as the day the membership stops.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with a one month notice period
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] The guest cancelled for three months out and then changed their mind
        WithdrawnTerminationDate := CalcDate('<+3M>', Today());
        _MemberModuleLib.RequestSubscriptionTerminationDirectly(Membership."Entry No.", WithdrawnTerminationDate);
        _MemberModuleLib.WithdrawSubscriptionTermination(Membership."Entry No.");

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available once the termination is withdrawn.');

        // [THEN] It is not the date the guest backed out of
        Assert.AreNotEqual(WithdrawnTerminationDate, UsableUntilDate, 'A withdrawn termination date should not be reported as the date the membership stops.');

        // [THEN] It is the paid period end
        Assert.AreEqual(CalcDate('<+6M>', Today()), UsableUntilDate, 'The card stays usable to the end of the paid period once the termination is withdrawn.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_IgnoresACancelledTerminationThatIsStillPending()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        CancelledTerminationDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A cancelled termination request is not read as an agreed date even while its processing status is still Pending.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with a one month notice period
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] The guest asked to stop nine months out, past the paid period end so that honouring the request
        // would visibly change the answer, and the request was then cancelled without its processing being closed off
        // - leaving the subscription still flagged as terminating and the row still Pending
        CancelledTerminationDate := CalcDate('<+9M>', Today());
        _MemberModuleLib.RequestSubscriptionTerminationDirectly(Membership."Entry No.", CancelledTerminationDate);
        _MemberModuleLib.CancelTerminationRequestKeepingItPending(Membership."Entry No.");

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available while a termination is flagged.');

        // [THEN] The answer is the paid period end, the same as for a membership with nothing agreed. Read as agreed,
        // the cancelled date would run past that period and roll the answer forward a whole year instead. Only the
        // Status filter excludes this row: its processing status is Pending, so that filter passes it through.
        Assert.AreEqual(CalcDate('<+6M>', Today()), UsableUntilDate, 'A cancelled termination request must not be read as an agreed termination date.');

        // [THEN] Nothing has to be charged first, since no termination is in force
        Assert.IsFalse(RenewalRequiredBeforeTermination, 'With no termination in force the paid period end is reached without a further charge.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_IgnoresATerminationStuckInError()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        FailedTerminationDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A termination that has run out of retries is not read as an agreed date, because it does not stop the renewal engine.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with a one month notice period
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] The guest asked to stop nine months out, past the paid period end so that honouring the request
        // would visibly change the answer, and the request then failed permanently
        FailedTerminationDate := CalcDate('<+9M>', Today());
        _MemberModuleLib.RequestSubscriptionTerminationDirectly(Membership."Entry No.", FailedTerminationDate);
        _MemberModuleLib.FailTerminationRequest(Membership."Entry No.");

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available while a termination is flagged.');

        // [THEN] The answer is the paid period end, which is what happens if the guest cancels afresh today. Read as
        // agreed, the failed date would run past that period and roll the answer forward a whole year, promising a
        // stop date that nothing in the system is going to bring about.
        Assert.AreEqual(CalcDate('<+6M>', Today()), UsableUntilDate, 'A termination stuck in Error must not be reported as the date the membership stops.');

        // [THEN] Nothing has to be charged first, since no termination is in force
        Assert.IsFalse(RenewalRequiredBeforeTermination, 'With no termination in force the paid period end is reached without a further charge.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_ClampsTheNoticeDateToTodayOnALapsedPeriod()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A termination that could take effect immediately is measured from today, so a paid period that has already ended does not read as still covering it.
        Initialize();

        // [GIVEN] A membership with a rule to renew into and no notice period, so the termination could take effect at once
        _MemberModuleLib.SetupAutoRenewToSelf(_GoldMembershipCodeLbl, _AutoRenewItemLbl, _AutoRenewDescriptionLbl);
        _MemberModuleLib.SetupRecurringPaymentNextStartDateModel(_GoldMembershipCodeLbl, 0);
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expired yesterday and the engine has scheduled today's renewal attempt
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<-1D>', Today()));
        _MemberModuleLib.SetSubscriptionPostponeRenewalUntil(Membership."Entry No.", Today());

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available for a subscribed membership.');

        // [THEN] It is the end of the period the imminent renewal buys, not the period end that has already passed.
        // Unclamped, the blank notice date would compare as earlier than the lapsed period end and report yesterday,
        // telling a guest the card is finished on the very day they are about to be charged for another year.
        Assert.AreEqual(CalcDate('<+1Y-1D>', Today()), UsableUntilDate, 'A termination taking effect today runs past a period that has already ended, so the answer is the end of the period the pending renewal buys.');

        // [THEN] The guest is told that renewal happens first
        Assert.IsTrue(RenewalRequiredBeforeTermination, 'Reaching that date requires the pending renewal to be charged first.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_IsNotShortenedByALapsedCommitment()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        UsableUntilDate: Date;
        RenewalRequiredBeforeTermination: Boolean;
        DateIsKnown: Boolean;
    begin
        // [SCENARIO] A commitment that has already lapsed does not shorten the usable-until date below the paid period end.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with no notice period
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] Its commitment lapsed three months ago and was never cleared
        _MemberModuleLib.SetSubscriptionCommittedUntil(Membership."Entry No.", CalcDate('<-3M>', Today()));

        // [WHEN] The usable-until date is read
        DateIsKnown := SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);

        // [THEN] A date is reported
        Assert.IsTrue(DateIsKnown, 'A usable-until date should be available for a subscribed membership.');

        // [THEN] The stale commitment does not drag it into the past
        Assert.AreEqual(CalcDate('<+6M>', Today()), UsableUntilDate, 'A lapsed commitment must not shorten the usable-until date below the paid period end.');

        // [THEN] Nothing has to be charged to reach it, since it is the period already paid for
        Assert.IsFalse(RenewalRequiredBeforeTermination, 'The paid period end is reached without a further charge.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UsableUntilDate_IsBasedOnTodayNotWorkDate()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        UsableUntilDate: Date;
        OriginalWorkDate: Date;
        CallSucceeded: Boolean;
    begin
        // [SCENARIO] The notice period is counted from today rather than from the session work date.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with a one month notice period
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription expires in two months, close enough that the two base dates give different answers:
        // counted from today the notice lands inside the period, counted from the work date it would roll past it
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+2M>', Today()));

        // [GIVEN] A session sitting on a work date 100 days out
        OriginalWorkDate := WorkDate();
        WorkDate(CalcDate('<+100D>', Today()));

        // [WHEN] The usable-until date is read
        // Trapped so the work date is restored even if the call errors. The work date is session state, not
        // transactional, so leaking a shifted one would corrupt every later test in the run.
        CallSucceeded := TryGetUsableUntilDate(Membership, UsableUntilDate);
        WorkDate(OriginalWorkDate);

        // [THEN] The read succeeds
        Assert.IsTrue(CallSucceeded, 'Reading the usable-until date should not fail.');

        // [THEN] The answer is the paid period end, which is what counting from today gives
        Assert.AreEqual(CalcDate('<+2M>', Today()), UsableUntilDate, 'The notice period should be counted from today, not from the work date: from today it lands inside the paid period, so the answer is that period end.');
    end;

    [TryFunction]
    local procedure TryGetUsableUntilDate(Membership: Record "NPR MM Membership"; var UsableUntilDate: Date)
    var
        SubscriptionMgt: Codeunit "NPR MM Subscription Mgt.";
        RenewalRequiredBeforeTermination: Boolean;
    begin
        SubscriptionMgt.GetUsableUntilDateIfCancelledNow(Membership, UsableUntilDate, RenewalRequiredBeforeTermination);
    end;

    #endregion

    #region Termination notice period gate

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TerminationGateCountsTheNoticePeriodFromTodayNotWorkDate()
    var
        Assert: Codeunit Assert;
        SubsTerminateLib: Codeunit "NPR Library - Subs Terminate";
        Membership: Record "NPR MM Membership";
        OriginalWorkDate: Date;
        RequestedDate: Date;
        RefusalText: Text;
        TerminationWasAccepted: Boolean;
    begin
        // [SCENARIO] A termination date that satisfies the notice period counted from today is accepted even when the session sits on a later work date.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with an enforced one month notice period
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        _MemberModuleLib.EnforceTerminationPeriod(_GoldMembershipCodeLbl);
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months, so the requested date lands inside the paid period
        // and nothing but the notice period can refuse it
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] The membership is flagged as internally auto-renewing, which is what termination requires. Re-read
        // afterwards: termination modifies the membership it is handed, and the enabling wrote to the same record, so
        // a copy taken before it is stale and its Modify would be refused for that rather than for the notice period.
        _MemberModuleLib.EnableMembershipAutoRenewal(Membership."Entry No.");
        Membership.Get(Membership."Entry No.");

        // [GIVEN] A session sitting on a work date 100 days out, far enough that a notice period counted from it
        // would land well past the requested date
        OriginalWorkDate := WorkDate();
        WorkDate(CalcDate('<+100D>', Today()));

        // [WHEN] A termination is requested for the first date the notice period allows, counted from today
        // Trapped so the work date is restored even if the call is refused. The work date is session state, not
        // transactional, so leaking a shifted one would corrupt every later test in the run. Trapped through
        // Codeunit.Run rather than a [TryFunction] because the termination inserts a request row, and the test runner
        // refuses a write inside a TryFunction while RunTests is on the stack.
        RequestedDate := CalcDate('<+1M>', Today());
        SubsTerminateLib.SetRequestedDate(RequestedDate);
        // Run opens its own transaction scope, which it cannot do on top of the uncommitted writes the arrange phase
        // above has made, so the fixture is committed first. Without this the call fails on the transaction rather
        // than on anything the test is about.
        Commit();
        TerminationWasAccepted := SubsTerminateLib.Run(Membership);
        RefusalText := GetLastErrorText();
        WorkDate(OriginalWorkDate);

        // [THEN] The request is accepted. This is the cross-app surface other apps call, and counting the notice from
        // the work date instead would put the floor at 100 days out and refuse a date the guest is entitled to.
        // The refusal is quoted because a trapped call can fail for reasons that have nothing to do with the gate.
        Assert.IsTrue(TerminationWasAccepted, StrSubstNo('A termination date that satisfies the notice period counted from today should be accepted whatever the session work date is. Refused with: %1', RefusalText));
    end;

    #endregion

    #region Subscription endpoint

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscriptionEndpointExposesTerminationAndRenewalDates()
    var
        Assert: Codeunit Assert;
        JsonHelper: Codeunit "NPR Json Helper";
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        Body: JsonObject;
    begin
        // [SCENARIO] The subscription endpoint reports both the usable-until date and the next renewal attempt in a single read, without requesting a termination.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with a one month notice period
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [WHEN] The subscription endpoint is read
        Response := InvokeApi('GET', StrSubstNo('membership/%1/subscription', Format(Membership.SystemId, 0, 4).ToLower()), EmptyBody());
        Body := GetResponseBodyOrError(Response, 'Get subscription failed.');

        // [THEN] The usable-until date is the paid period end
        Assert.AreEqual(CalcDate('<+6M>', Today()), JsonHelper.GetJDate(Body.AsToken(), 'usableUntilDate', true), 'The subscription endpoint should report the usable-until date.');

        // [THEN] The next renewal attempt is the earliest scheduled attempt, 5 days before expiry
        Assert.AreEqual(CalcDate('<+6M-5D>', Today()), JsonHelper.GetJDate(Body.AsToken(), 'nextRenewalAttemptDate', true), 'The subscription endpoint should report the next renewal attempt date.');

        // [THEN] No further renewal is flagged
        Assert.IsFalse(JsonHelper.GetJBoolean(Body.AsToken(), 'renewalRequiredBeforeTermination', true), 'The subscription endpoint should report that no further renewal is required.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscriptionEndpointReturnsNullRenewalAttemptWhenAutoRenewIsOff()
    var
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        Body: JsonObject;
    begin
        // [SCENARIO] The renewal attempt property is present and null when no attempt is planned, so a consumer can tell that apart from an omitted field.
        Initialize();

        // [GIVEN] A membership renewing on a schedule
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] Auto-renewal is switched off, so no attempt is planned
        _MemberModuleLib.SetSubscriptionAutoRenew(Membership."Entry No.", "NPR MM MembershipAutoRenew"::NO);

        // [WHEN] The subscription endpoint is read
        Response := InvokeApi('GET', StrSubstNo('membership/%1/subscription', Format(Membership.SystemId, 0, 4).ToLower()), EmptyBody());
        Body := GetResponseBodyOrError(Response, 'Get subscription failed.');

        // [THEN] The property is present and null rather than absent
        AssertPropertyIsNull(Body, 'nextRenewalAttemptDate');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscriptionEndpointReturnsAgreedTerminateAtWhenTerminationRequested()
    var
        Assert: Codeunit Assert;
        JsonHelper: Codeunit "NPR Json Helper";
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        Body: JsonObject;
        AgreedTerminationDate: Date;
    begin
        // [SCENARIO] Once a termination is agreed the endpoint reports the paid period end as the usable-until date and the agreed date separately as terminateAt.
        Initialize();

        // [GIVEN] A membership type with a one month notice period
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] The guest has agreed a termination for three months out
        AgreedTerminationDate := CalcDate('<+3M>', Today());
        _MemberModuleLib.RequestSubscriptionTerminationDirectly(Membership."Entry No.", AgreedTerminationDate);

        // [WHEN] The subscription endpoint is read
        Response := InvokeApi('GET', StrSubstNo('membership/%1/subscription', Format(Membership.SystemId, 0, 4).ToLower()), EmptyBody());
        Body := GetResponseBodyOrError(Response, 'Get subscription failed.');

        // [THEN] The card stays usable to the paid period end, since terminating only switches auto-renewal off
        Assert.AreEqual(CalcDate('<+6M>', Today()), JsonHelper.GetJDate(Body.AsToken(), 'usableUntilDate', true), 'The card stays usable to the end of the paid period even once a termination is agreed.');

        // [THEN] The agreed date is still reported as terminateAt
        Assert.AreEqual(AgreedTerminationDate, JsonHelper.GetJDate(Body.AsToken(), 'terminateAt', true), 'The agreed termination date should still be reported as terminateAt.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscriptionEndpointReportsNoRenewalAttemptOnceATerminationIsDue()
    var
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        Body: JsonObject;
    begin
        // [SCENARIO] A termination taking effect on or before the period end suppresses the renewal attempt date, because the engine will not renew that subscription.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, so an attempt would otherwise be reported
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] A termination is agreed for three months out, inside that period
        _MemberModuleLib.RequestSubscriptionTerminationDirectly(Membership."Entry No.", CalcDate('<+3M>', Today()));

        // [WHEN] The subscription endpoint is read
        Response := InvokeApi('GET', StrSubstNo('membership/%1/subscription', Format(Membership.SystemId, 0, 4).ToLower()), EmptyBody());
        Body := GetResponseBodyOrError(Response, 'Get subscription failed.');

        // [THEN] No attempt is advertised, since the termination stops the renewal before the schedule reaches it
        AssertPropertyIsNull(Body, 'nextRenewalAttemptDate');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TerminateEndpointDefaultsToTodayWhenThereIsNoNoticePeriod()
    var
        Assert: Codeunit Assert;
        JsonHelper: Codeunit "NPR Json Helper";
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        Body: JsonObject;
    begin
        // [SCENARIO] Terminating without a date, on a membership type with no notice period, ends the subscription today rather than on a blank date.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with no notice period at all
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '');
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] The membership is flagged as internally auto-renewing, which is what the endpoint requires before it
        // will accept a cancellation
        _MemberModuleLib.EnableMembershipAutoRenewal(Membership."Entry No.");

        // [WHEN] The termination is requested with no date in the body
        Response := InvokeApi('POST', StrSubstNo('membership/%1/subscription/terminate', Format(Membership.SystemId, 0, 4).ToLower()), EmptyBody());
        Body := GetResponseBodyOrError(Response, 'Terminate subscription failed.');

        // [THEN] The termination is stamped for today. The notice period calculation yields a blank date here, and
        // writing that onto the request would leave a termination that no comparison against a real date can order.
        Assert.AreEqual(Today(), JsonHelper.GetJDate(Body.AsToken(), 'terminateAt', true), 'With no notice period and no requested date, the termination should take effect today.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TerminateEndpointDefaultDoesNotOutliveALapsedPeriod()
    var
        Assert: Codeunit Assert;
        JsonHelper: Codeunit "NPR Json Helper";
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        Body: JsonObject;
        LapsedPeriodEnd: Date;
    begin
        // [SCENARIO] Terminating without a date, on a subscription whose paid period has already ended, stops it on that period end rather than today.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with no notice period and no commitment, so the endpoint has
        // to invent the termination date itself
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '');
        CreateGoldMembership(Membership);

        // [GIVEN] The membership is flagged as internally auto-renewing, which is what the endpoint requires before it
        // will accept a cancellation
        _MemberModuleLib.EnableMembershipAutoRenewal(Membership."Entry No.");

        // [GIVEN] The paid period ended ten days ago, so the subscription is sitting on a renewal that has not run yet
        LapsedPeriodEnd := CalcDate('<-10D>', Today());
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", LapsedPeriodEnd);

        // [WHEN] The termination is requested with no date in the body
        Response := InvokeApi('POST', StrSubstNo('membership/%1/subscription/terminate', Format(Membership.SystemId, 0, 4).ToLower()), EmptyBody());
        Body := GetResponseBodyOrError(Response, 'Terminate subscription failed.');

        // [THEN] The termination is stamped for the lapsed period end, not for today. IsTerminationDue only suppresses
        // the renewal for a date on or before the period end, so stamping today would leave the renewal job free to
        // charge the guest for another period straight after they asked to stop.
        Assert.AreEqual(LapsedPeriodEnd, JsonHelper.GetJDate(Body.AsToken(), 'terminateAt', true), 'A termination date the endpoint invents must not outlive the period already paid for.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TerminateEndpointDefaultRollsForwardOverANoticeLongerThanOnePeriod()
    var
        Assert: Codeunit Assert;
        JsonHelper: Codeunit "NPR Json Helper";
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        Body: JsonObject;
        ValidUntilDate: Date;
    begin
        // [SCENARIO] Terminating without a date, on a membership type whose notice period outruns a renewal period, returns a date the endpoint's own validation accepts.
        Initialize();

        // [GIVEN] A membership renewing on a schedule into one year periods
        SetupTivoliRenewalSchedule();

        // [GIVEN] A two year notice period, which no single one year renewal can cover, enforced so that the
        // endpoint's own default has to pass the gate rather than sail through an inert one
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<2Y>');
        _MemberModuleLib.EnforceTerminationPeriod(_GoldMembershipCodeLbl);
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        ValidUntilDate := CalcDate('<+6M>', Today());
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", ValidUntilDate);

        // [GIVEN] The membership is flagged as internally auto-renewing, which is what the endpoint requires before it
        // will accept a cancellation
        _MemberModuleLib.EnableMembershipAutoRenewal(Membership."Entry No.");

        // [WHEN] The termination is requested with no date in the body, so the endpoint fills in its own default
        Response := InvokeApi('POST', StrSubstNo('membership/%1/subscription/terminate', Format(Membership.SystemId, 0, 4).ToLower()), EmptyBody());

        // [THEN] The request is accepted. This is the whole point of the roll-forward: the default is fed straight
        // back into RequestTermination, which validates it again, so a default that stopped after one renewal period
        // would still be inside the notice period and the endpoint would reject its own answer.
        Body := GetResponseBodyOrError(Response, 'Terminating with a notice period longer than one renewal period should be accepted.');

        // [THEN] The stamped date is the end of the second renewed period, the first one that covers two years of notice
        Assert.AreEqual(CalcDate('<+1Y-1D>', CalcDate('<+1D>', CalcDate('<+1Y-1D>', CalcDate('<+1D>', ValidUntilDate)))), JsonHelper.GetJDate(Body.AsToken(), 'terminateAt', true), 'The default termination date should roll forward over every period the notice spans.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('DeclineBreakingTheNoticePeriod')]
    procedure TerminateEndpointRefusesADateInsideTheNoticePeriod()
    var
        Assert: Codeunit Assert;
        JsonHelper: Codeunit "NPR Json Helper";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Membership: Record "NPR MM Membership";
        Body: JsonObject;
        Response: JsonObject;
        ResponseText: Text;
    begin
        // [SCENARIO] Terminating with a date earlier than the enforced notice period allows is refused outright, rather than quietly moved to a date the notice period does allow.
        Initialize();
        _NoticePeriodConfirmWasRaised := false;

        // [GIVEN] A membership renewing on a schedule, with an enforced one month notice period
        SetupTivoliRenewalSchedule();
        _MemberModuleLib.SetupTerminationPeriod(_GoldMembershipCodeLbl, '<1M>');
        _MemberModuleLib.EnforceTerminationPeriod(_GoldMembershipCodeLbl);
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months, so only the notice period stands in the way
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [GIVEN] The membership is flagged as internally auto-renewing, which is what the endpoint requires before it
        // will accept a cancellation
        _MemberModuleLib.EnableMembershipAutoRenewal(Membership."Entry No.");

        // [WHEN] The termination is requested for tomorrow, well inside the notice period
        // Called directly rather than trapped: the module handler runs each agent through Codeunit.Run and turns the
        // gate's error into an error response, so the refusal arrives as a status code rather than as a failed call.
        Body.Add('terminationDate', Format(CalcDate('<+1D>', Today()), 0, 9));
        Response := InvokeApi('POST', StrSubstNo('membership/%1/subscription/terminate', Format(Membership.SystemId, 0, 4).ToLower()), Body);
        Response.WriteTo(ResponseText);

        // [THEN] The termination does not go through. A client that computes its own date has to be ready for that:
        // the server does not silently correct the date to one it would accept.
        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), StrSubstNo('A termination date inside the notice period should be refused. Response: %1', ResponseText));

        // [THEN] It comes back as a 400 rather than as a failed request. The module handler runs each agent through
        // Codeunit.Run, so the gate's error becomes an error response body, and that is the contract an external
        // client integrates against. Pinned here because it is documented in the Fern spec.
        Assert.AreEqual(400, JsonHelper.GetJInteger(Response.AsToken(), 'statusCode', true), StrSubstNo('A refused termination should answer 400. Response: %1', ResponseText));

        // [THEN] It was refused on the notice period rather than on something incidental. The handler is what proves
        // it: the gate is the only thing in this path that asks, and it asks before it refuses.
        Assert.IsTrue(_NoticePeriodConfirmWasRaised, StrSubstNo('The refusal should come from the notice period gate. Response: %1', ResponseText));

        // [THEN] Nothing is left half applied: the membership still renews
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'A refused termination must leave the membership renewing as it was.');
    end;

    /// <summary>
    /// Answers no to the gate's confirm, which is what a web service session does on its own: with no UI available
    /// GetResponseOrDefault takes its default, and that default is no. The test runner does have UI, so without this
    /// the endpoint would stop on an unhandled dialog instead of reaching the error a real caller gets.
    /// </summary>
    [ConfirmHandler]
    procedure DeclineBreakingTheNoticePeriod(Question: Text; var Reply: Boolean)
    begin
        _NoticePeriodConfirmWasRaised := true;
        Reply := false;
    end;

    #endregion

    #region Renewal endpoint

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalEndpointExposesNextRenewalAttemptDate()
    var
        Assert: Codeunit Assert;
        JsonHelper: Codeunit "NPR Json Helper";
        Membership: Record "NPR MM Membership";
        Response: JsonObject;
        Body: JsonObject;
    begin
        // [SCENARIO] The renewal endpoint reports the next renewal attempt alongside the price it already serves.
        Initialize();

        // [GIVEN] A membership renewing on a schedule, with a rule to renew into
        _MemberModuleLib.SetupAutoRenewToSelf(_GoldMembershipCodeLbl, _AutoRenewItemLbl, _AutoRenewDescriptionLbl);
        SetupTivoliRenewalSchedule();
        CreateGoldMembership(Membership);

        // [GIVEN] The subscription runs for another six months
        _MemberModuleLib.SetSubscriptionPeriod(Membership."Entry No.", CalcDate('<+6M>', Today()));

        // [WHEN] The renewal endpoint is read
        Response := InvokeApi('GET', StrSubstNo('membership/%1/renewal', Format(Membership.SystemId, 0, 4).ToLower()), EmptyBody());
        Body := GetResponseBodyOrError(Response, 'Get renewal info failed.');

        // [THEN] The next renewal attempt is reported beside the price
        Assert.AreEqual(CalcDate('<+6M-5D>', Today()), JsonHelper.GetJDate(Body.AsToken(), 'membership.nextRenewalAttemptDate', true), 'The renewal endpoint should report the next renewal attempt date alongside the price.');
    end;

    #endregion

    #region Setup helpers

    local procedure Initialize()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
    begin
        if _IsInitialized then
            exit;

        _MemberModuleLib.Initialize();
        _MemberModuleLib.CreateScenario_SmokeTest();

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Membership');

        _IsInitialized := true;
    end;

    /// <summary>
    /// The renewal schedule Tivoli actually runs: attempts 5 and 2 days before expiry, then 1 and 4 days after.
    /// Also installs the auto-renew rule, because a renewal with nowhere to renew to never charges and so reports
    /// no attempt date at all.
    /// </summary>
    local procedure SetupTivoliRenewalSchedule()
    begin
        _MemberModuleLib.SetupRenewalScheduleWithAutoRenew(_GoldMembershipCodeLbl, _RenewalScheduleCodeLbl, _AutoRenewItemLbl, TivoliAttemptOffsets());
    end;

    /// <summary>
    /// Attempts 5 and 2 days before expiry, then 1 and 4 days after: the schedule Tivoli actually runs.
    /// </summary>
    local procedure TivoliAttemptOffsets() AttemptOffsetsInDays: List of [Integer]
    begin
        AttemptOffsetsInDays.Add(-5);
        AttemptOffsetsInDays.Add(-2);
        AttemptOffsetsInDays.Add(1);
        AttemptOffsetsInDays.Add(4);
    end;

    local procedure CreateGoldMembership(var Membership: Record "NPR MM Membership")
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
        MembershipId: Guid;
    begin
        Body.Add('itemNumber', _GoldSalesItemLbl);
        Body.Add('activationDate', CalcDate('<-6M>', Today()));

        Response := InvokeApi('POST', 'membership', Body);
        ResponseBody := GetResponseBodyOrError(Response, 'Create membership failed.');

        Evaluate(MembershipId, JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipId', true));
        Membership.GetBySystemId(MembershipId);
    end;

    #endregion

    #region API helpers

    local procedure InvokeApi(Method: Text; Path: Text; Body: JsonObject) Response: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        QueryParameters: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
    begin
        Headers.Add('x-api-version', Format(Today, 0, 9));
        exit(LibraryNPRetailAPI.CallApi(Method, Path, Body, QueryParameters, Headers));
    end;

    local procedure GetResponseBodyOrError(Response: JsonObject; ErrorText: Text) Body: JsonObject
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        ResponseText: Text;
    begin
        // Status before body. A failed call need not carry a body shaped like the success payload at all, so reading
        // it first can fail on its own and bury the status code that actually explains what went wrong. The whole
        // response is reported rather than just the body, since the status is the useful half.
        if not LibraryNPRetailAPI.IsSuccessStatusCode(Response) then begin
            Response.WriteTo(ResponseText);
            Error('%1 Response: %2', ErrorText, ResponseText);
        end;
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
    end;

    local procedure EmptyBody(): JsonObject
    var
        Body: JsonObject;
    begin
        exit(Body);
    end;

    local procedure AssertPropertyIsNull(Body: JsonObject; PropertyName: Text)
    var
        Assert: Codeunit Assert;
        Token: JsonToken;
    begin
        Assert.IsTrue(Body.AsToken().SelectToken(PropertyName, Token), StrSubstNo('Property %1 should be present in the response.', PropertyName));
        Assert.IsTrue(Token.IsValue(), StrSubstNo('Property %1 should be a value.', PropertyName));
        Assert.IsTrue(Token.AsValue().IsNull(), StrSubstNo('Property %1 should be null.', PropertyName));
    end;

    #endregion
}
#endif

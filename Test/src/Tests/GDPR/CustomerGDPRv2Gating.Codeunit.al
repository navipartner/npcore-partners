codeunit 85298 "NPR Customer GDPR V2 Gating"
{
    Subtype = Test;

    var
        _Library: Codeunit "NPR Library - Customer GDPR";
        _Assert: Codeunit Assert;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeMembership_FeatureOff_NoBlockingError()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership: Record "NPR MM Membership";
        CustNo: Code[20];
        MembershipEntryNo: Integer;
        MemberEntryNo: Integer;
    begin
        // [SCENARIO] With feature OFF, the OnBeforeAnonymizeMembership subscriber must NOT raise CustomerNotDueErr.
        // [GIVEN] Customer with NPR Estimated Cleanup Date = 0D linked to a membership, feature disabled
        _Library.DisableCustomerGDPRV2Feature();
        CustNo := _Library.CreateCustomer();
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        MemberEntryNo := LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Membership.Get(MembershipEntryNo);
        Membership."Customer No." := CustNo;
        Membership.Modify(false);

        // [WHEN] Membership is anonymized (this fires OnBeforeAnonymizeMembership)
        LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);

        // [THEN] No error was raised; membership was anonymized
        LibraryMemberGDPR.Assert_AllIsAnonymized(MembershipEntryNo, MemberEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeMembership_FeatureOn_BlocksWhenCustomerNotDue()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership: Record "NPR MM Membership";
        CustNo: Code[20];
        MembershipEntryNo: Integer;
    begin
        // [SCENARIO] With the feature ON, OnBeforeAnonymizeMembership raises CustomerNotDueErr when cleanup date is in the future.
        // [GIVEN] Customer with future cleanup date linked to a membership, feature enabled
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomerWithFutureCleanupDate();
        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Membership.Get(MembershipEntryNo);
        Membership."Customer No." := CustNo;
        Membership.Modify(false);

        // [WHEN] Membership anonymization is attempted
        // [THEN] The subscriber raises an error containing 'not yet due'
        asserterror LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);
        _Assert.ExpectedError('not yet due to be anonymized');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AnonymizeMembership_FeatureOn_RefreshStampedFutureDate_Blocks()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Membership: Record "NPR MM Membership";
        Customer: Record Customer;
        CustNo: Code[20];
        MembershipEntryNo: Integer;
    begin
        // [SCENARIO] Customer with Estimated Cleanup Date = 0D but recent POS/CLE/ILE activity:
        // RefreshSingleCustomer stamps a future cleanup date as a side-effect, and that just-stamped
        // future date makes the gate block this same anonymization attempt.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomer();
        _Library.SeedPOSEntryForCustomer(CustNo, Today());

        MembershipEntryNo := LibraryMemberGDPR.CreatePlainMembership(CalcDate('<-10D>'));
        LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Membership.Get(MembershipEntryNo);
        Membership."Customer No." := CustNo;
        Membership.Modify(false);

        // Sanity: cleanup date must be 0D before the attempt.
        Customer.Get(CustNo);
        _Assert.AreEqual(0D, Customer."NPR Estimated Cleanup Date", 'Pre-condition: cleanup date should be 0D.');

        // [WHEN/THEN] Anonymization is blocked by the just-stamped future cleanup date.
        asserterror LibraryMemberGDPR.AnonymizeMembership(MembershipEntryNo);
        _Assert.ExpectedError('not yet due to be anonymized');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Runner_FeatureOn_CustomerNotDue_IsolatesFailure_NotAnonymized()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Runner: Codeunit "NPR MM GDPR Anon. Runner";
        Membership: Record "NPR MM Membership";
        CustNo: Code[20];
        MembershipEntryNo: Integer;
        RunOk: Boolean;
    begin
        // [SCENARIO] A membership whose customer is not yet due must fail in isolation (guarded Run returns
        // false) and stay un-anonymized, instead of aborting the batch.
        // GDPR membership is required so that, under AgreementCheck = true, execution reaches DoAnonymizeMembership
        // and raises OnBeforeAnonymizeMembership (see the "AgreementCheck nuance" in the plan Background).
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        CustNo := _Library.CreateCustomerWithFutureCleanupDate();
        MembershipEntryNo := LibraryMemberGDPR.CreateGdprMembership(CalcDate('<-10D>'));
        LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Membership.Get(MembershipEntryNo);
        Membership."Customer No." := CustNo;
        Membership.Modify(false);
        Commit(); // guarded Codeunit.Run requires no uncommitted writes; isolation runner rolls this back per-test

        // [WHEN] The membership is processed through the isolation runner's guarded Run
        Runner.SetMembershipEntryNo(MembershipEntryNo);
        RunOk := Runner.Run();

        // [THEN] The run reports failure (isolated) and the membership is NOT anonymized (the guarded Run rolled
        // back the partial role/member writes made before the throw)
        _Assert.IsFalse(RunOk, 'Runner.Run must report failure for a not-yet-due customer.');
        LibraryMemberGDPR.Assert_MembershipIsNotAnonymized(MembershipEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Runner_FeatureOn_DueMembership_Anonymized()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Runner: Codeunit "NPR MM GDPR Anon. Runner";
        Membership: Record "NPR MM Membership";
        MembershipEntryNo: Integer;
        RunOk: Boolean;
    begin
        // [SCENARIO] A GDPR membership with no linked customer (the subscriber exits early on blank Customer No.)
        // and expired validity is anonymized normally through the runner.
        _Library.EnableCustomerGDPRV2Feature();
        _Library.EnsureGDPRSetup('<+1Y>');
        MembershipEntryNo := LibraryMemberGDPR.CreateGdprMembership(CalcDate('<-10D>'));
        LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Membership.Get(MembershipEntryNo);
        _Assert.AreEqual('', Membership."Customer No.", 'Pre-condition: membership must have no linked customer.');
        Commit(); // guarded Codeunit.Run requires no uncommitted writes; isolation runner rolls this back per-test

        // [WHEN] The membership is processed through the isolation runner's guarded Run
        Runner.SetMembershipEntryNo(MembershipEntryNo);
        RunOk := Runner.Run();

        // [THEN] The run succeeds and the membership is anonymized
        _Assert.IsTrue(RunOk, 'Runner.Run must succeed for a membership eligible for anonymization.');
        LibraryMemberGDPR.Assert_MembershipIsAnonymized(MembershipEntryNo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Runner_FeatureOff_Anonymized_RegardlessOfCustomer()
    var
        LibraryMemberGDPR: Codeunit "NPR Library - Member GDPR";
        Runner: Codeunit "NPR MM GDPR Anon. Runner";
        Membership: Record "NPR MM Membership";
        CustNo: Code[20];
        MembershipEntryNo: Integer;
        RunOk: Boolean;
    begin
        // [SCENARIO] With the feature OFF, the subscriber never throws, so the runner anonymizes even a GDPR
        // membership linked to a customer with a future cleanup date.
        _Library.DisableCustomerGDPRV2Feature();
        CustNo := _Library.CreateCustomerWithFutureCleanupDate();
        MembershipEntryNo := LibraryMemberGDPR.CreateGdprMembership(CalcDate('<-10D>'));
        LibraryMemberGDPR.AddAdminMember(MembershipEntryNo);
        Membership.Get(MembershipEntryNo);
        Membership."Customer No." := CustNo;
        Membership.Modify(false);
        Commit(); // guarded Codeunit.Run requires no uncommitted writes; isolation runner rolls this back per-test

        // [WHEN] The membership is processed through the isolation runner's guarded Run
        Runner.SetMembershipEntryNo(MembershipEntryNo);
        RunOk := Runner.Run();

        // [THEN] The run succeeds and the membership is anonymized
        _Assert.IsTrue(RunOk, 'Runner.Run must succeed with the feature OFF.');
        LibraryMemberGDPR.Assert_MembershipIsAnonymized(MembershipEntryNo);
    end;
}

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85240 "NPR MMMembershipLifecycleTest"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;
        _MemberModuleLib: Codeunit "NPR Library - Member Module";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure RenewMembership_01()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
    begin

        // Test: Basic renew creates a new membership ledger entry without changing membership code.
        // Scenario:
        // - Create a GOLD membership + member.
        // - Pick the first available renewal option and run RenewMembership.
        // Steps verified:
        // 1) The membership header keeps its original code (GOLD) after renewal.
        // 2) Renewal adds exactly one new membership ledger entry (total count becomes 2: create + renew).
        // 3) Both the first (create) and last (renew) membership entries have the GOLD membership code.

        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);

        OptionId := SelectFirstRenewalOptionId(MembershipId);
        RenewMembership(MembershipId, OptionId);

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should remain ' + CurrentMembershipCode + ' after renewal.');

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after renewal.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');

        MembershipEntry.FindLast();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should remain ' + CurrentMembershipCode + ' after renewal.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure RenewMembership_02()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        PendingUpdate: Codeunit "NPR MM Update Customer Pending";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
    begin

        // Test: Renewal that alters membership code applies immediately when "Defer Cust. Update Alterations" is false.
        // Scenario:
        // - Configure SILVER (the target membership code) with Defer Cust. Update Alterations = false.
        // - Set up a renewal option that renews GOLD -> SILVER (no grace, not stackable).
        // - Create a GOLD membership + member, then renew using that option.
        // Steps verified:
        // 1) Membership header flips from GOLD to SILVER immediately after renewal (no pending/deferred update flow).
        // 2) Renewal creates exactly one additional membership ledger entry (total count becomes 2: create + renew).
        // 3) The first membership entry is GOLD (create) and the last membership entry is SILVER (renewal/alteration).
        // 4) No Pending Customer Update is created for this renewal (FindFirst should error / no record).

        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := false;
        MembershipSetup.Modify();

        OptionId := _MemberModuleLib.SetupRenew_NoGraceNotStackable(CurrentMembershipCode, _MemberModuleLib.CreateItem('T-320100-G2S', '', 'Renew GOLD Membership', 157), TargetMembershipCode, 'Renew GOLD Membership to SILVER');
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        RenewMembership(MembershipId, OptionId);

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should flip to ' + TargetMembershipCode + ' immediate when deferred update is false.');

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after renewal.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after renewal.');

        PendingCustomerUpdate.SetFilter(MembershipEntryNo, '=%1', Membership."Entry No.");
        asserterror PendingCustomerUpdate.FindFirst();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure RenewMembership_03()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        PendingUpdate: Codeunit "NPR MM Update Customer Pending";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
    begin

        // Test: Renewal that alters membership code is deferred when "Defer Cust. Update Alterations" is true.
        // Scenario:
        // - Configure SILVER (the target membership code) with Defer Cust. Update Alterations = true.
        // - Set up a renewal option that renews GOLD -> SILVER (no grace, not stackable).
        // - Create a GOLD membership + member, then renew using that option.
        // Steps verified:
        // 1) After renewal, the membership header stays on GOLD (the alteration is not applied immediately).
        // 2) Renewal adds exactly one new membership ledger entry (total count becomes 2: create + renew).
        // 3) The renewal ledger entry is created with the target code (SILVER), even though the membership header is still GOLD.
        // 4) A Pending Customer Update is created for the membership with MembershipCode = SILVER and an effective date matching
        //    the renewal entry "Valid From Date".
        // 5) Applying the pending update flips the membership header to SILVER.

        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := true;
        MembershipSetup.Modify();

        OptionId := _MemberModuleLib.SetupRenew_NoGraceNotStackable(CurrentMembershipCode, _MemberModuleLib.CreateItem('T-320100-G2S', '', 'Renew GOLD Membership 2 SILVER', 157), TargetMembershipCode, 'Renew GOLD Membership to SILVER');

        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        RenewMembership(MembershipId, OptionId);

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should remain current after a not yet activated renewal.');

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after renewal.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be current after create.');

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be target after renewal.');

        PendingCustomerUpdate.SetFilter(MembershipEntryNo, '=%1', Membership."Entry No.");
        PendingCustomerUpdate.FindFirst();
        Assert.AreEqual(TargetMembershipCode, PendingCustomerUpdate.MembershipCode, 'Pending customer update should have target membership code target.');
        Assert.AreEqual(MembershipEntry."Valid From Date", PendingCustomerUpdate."Valid From Date", 'Pending customer update effective date should match membership entry valid from date.');

        PendingUpdate.ApplyUpdate(PendingCustomerUpdate);
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be target after the pending customer update applied.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Upgrade_01()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
    begin
        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);

        OptionId := SelectFirstUpgradeOptionId(MembershipId);
        UpgradeMembership(MembershipId, OptionId, Today());

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after alteration.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');
        Assert.AreEqual(Today(), MembershipEntry."Valid From Date", 'Membership entry valid from date should be today after alteration.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Upgrade_02()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
    begin
        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := false;
        MembershipSetup.Modify();

        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);

        OptionId := SelectFirstUpgradeOptionId(MembershipId);
        UpgradeMembership(MembershipId, OptionId, CalcDate('<+7D>'));

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after alteration.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');
        Assert.AreEqual(CalcDate('<+7D>'), MembershipEntry."Valid From Date", 'Membership entry valid from date should be in 7 days after alteration.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Upgrade_03()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        PendingUpdate: Codeunit "NPR MM Update Customer Pending";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
    begin
        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := true;
        MembershipSetup.Modify();

        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);

        OptionId := SelectFirstUpgradeOptionId(MembershipId);
        UpgradeMembership(MembershipId, OptionId, CalcDate('<+7D>'));

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after alteration.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');
        Assert.AreEqual(CalcDate('<+7D>'), MembershipEntry."Valid From Date", 'Membership entry valid from date should be in 7 days after alteration.');

        PendingCustomerUpdate.SetFilter(MembershipEntryNo, '=%1', Membership."Entry No.");
        PendingCustomerUpdate.FindFirst();
        Assert.AreEqual(TargetMembershipCode, PendingCustomerUpdate.MembershipCode, 'Pending customer update should have target membership code target.');
        Assert.AreEqual(MembershipEntry."Valid From Date", PendingCustomerUpdate."Valid From Date", 'Pending customer update effective date should match membership entry valid from date.');

        PendingUpdate.ApplyUpdate(PendingCustomerUpdate);
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be target after the pending customer update applied.');

    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Extend_01()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode: Code[20];
    begin
        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);

        OptionId := SelectFirstExtendOptionId(MembershipId);
        ExtendMembership(MembershipId, OptionId, Today());

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after alteration.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');

        MembershipEntry.FindLast();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');
        Assert.AreEqual(Today(), MembershipEntry."Valid From Date", 'Membership entry valid from date should be today after alteration.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure Cancel_01()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode: Code[20];
    begin

        // Test: Scheduled cancellation shortens validity without creating a new membership ledger entry.
        // Scenario:
        // - Create a GOLD membership + member.
        // - Configure a cancel option (no grace) and cancel the membership effective in 7 days.
        // Steps verified:
        // 1) Membership header keeps its original code (GOLD) after cancellation (cancel does not change membership type).
        // 2) Cancellation does not add a new membership entry; the ledger still contains only the original create entry (count = 1).
        // 3) The existing membership entry is updated so "Valid Until Date" becomes today + 7 days (scheduled end of validity).

        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);

        OptionId := _MemberModuleLib.SetupCancel_NoGrace(CurrentMembershipCode, _MemberModuleLib.CreateItem('T-320100-CANCEL', '', 'Cancel Membership', 157), '', 'Cancel Membership');
        CancelMembership(MembershipId, OptionId, CalcDate('<+7D>'));

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(1, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 1 after alteration.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');
        Assert.AreEqual(CalcDate('<+7D>'), MembershipEntry."Valid Until Date", 'Membership entry valid from date should be +7 days after alteration.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AutoRenew_01()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        CurrentMembershipCode: Code[20];
        ValidUntilDate: Date;
    begin

        // Test: Auto-renew to self creates a new back-to-back membership period.
        // Scenario:
        // - Configure GOLD to auto-renew to GOLD (self renewal).
        // - Create a GOLD membership + member, then run AutoRenew.
        // Steps verified:
        // 1) AutoRenew creates one additional membership ledger entry (total count becomes 2: create + renew).
        // 2) Both the original and the new entry have membership code GOLD.
        // 3) The new entry starts the day after the previous entry ends (Valid From Date = previous Valid Until Date + 1 day),
        //    ensuring the periods are back-to-back with no overlap.

        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        _MemberModuleLib.SetupAutoRenewToSelf(CurrentMembershipCode, 'T-320100-AUTORENEW', 'Auto Renew GOLD Membership');

        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        AutoRenew(MembershipId);

        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after alteration.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');
        ValidUntilDate := MembershipEntry."Valid Until Date";

        MembershipEntry.FindLast();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');
        Assert.AreEqual(CalcDate('<+1D>', ValidUntilDate), MembershipEntry."Valid From Date", 'Membership entry valid from date should be day after valid until date of previous entry.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AutoRenew_02()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
        ValidUntilDate: Date;
    begin

        // Test: Auto-renew alters membership code immediately when the target does NOT defer customer update alterations.
        // Scenario:
        // - Configure auto-renew for GOLD to renew into SILVER (GOLD -> SILVER).
        // - Configure SILVER (target) with Defer Cust. Update Alterations = false so the alteration applies immediately.
        // - Create a GOLD membership + member, then run AutoRenew.
        // Steps verified:
        // 1) AutoRenew creates one additional membership ledger entry (total count becomes 2: create + renew).
        // 2) The first entry is GOLD (create) and the last entry is SILVER (renewal/alteration).
        // 3) The new SILVER period starts the day after the previous GOLD period ends (back-to-back validity).
        // 4) Membership header is updated immediately to SILVER (no pending/deferred update flow).

        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';
        _MemberModuleLib.SetupAutoRenew(CurrentMembershipCode, 'T-320100-AUTORENEW', TargetMembershipCode, 'Auto Renew GOLD->SILVER Membership');

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := false;
        MembershipSetup.Modify();

        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        AutoRenew(MembershipId);

        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after alteration.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');
        ValidUntilDate := MembershipEntry."Valid Until Date";

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');
        Assert.AreEqual(CalcDate('<+1D>', ValidUntilDate), MembershipEntry."Valid From Date", 'Membership entry valid from date should be day after valid until date of previous entry.');

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AutoRenew_03()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MembershipSetup: Record "NPR MM Membership Setup";
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        PendingUpdate: Codeunit "NPR MM Update Customer Pending";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
        ValidUntilDate: Date;
    begin

        // Test: Auto-renew creates a target-code ledger entry but defers changing the membership header when the target defers alterations.
        // Scenario:
        // - Configure auto-renew for GOLD to renew into SILVER (GOLD -> SILVER).
        // - Configure SILVER (target) with Defer Cust. Update Alterations = true so the membership header change is deferred.
        // - Create a GOLD membership + member, then run AutoRenew.
        // Steps verified:
        // 1) AutoRenew creates one additional membership ledger entry (total count becomes 2: create + renew).
        // 2) The first entry is GOLD (create) and the last entry is SILVER (renewal/alteration entry).
        // 3) The new SILVER period starts the day after the previous GOLD period ends (back-to-back validity).
        // 4) Membership header remains GOLD immediately after AutoRenew (alteration not applied yet).
        // 5) A Pending Customer Update is created with MembershipCode = SILVER and an effective date matching the renewal entry
        //    "Valid From Date".
        // 6) Applying the pending update flips the membership header to SILVER.


        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';
        _MemberModuleLib.SetupAutoRenew(CurrentMembershipCode, 'T-320100-AUTORENEW', TargetMembershipCode, 'Auto Renew GOLD->SILVER Membership');

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := true;
        MembershipSetup.Modify();

        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        AutoRenew(MembershipId);

        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        Assert.AreEqual(2, GetMembershipLedgerEntryCount(MembershipId), 'Membership ledger entry count should be 2 after alteration.');

        MembershipEntry.FindFirst();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');
        ValidUntilDate := MembershipEntry."Valid Until Date";

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');
        Assert.AreEqual(CalcDate('<+1D>', ValidUntilDate), MembershipEntry."Valid From Date", 'Membership entry valid from date should be day after valid until date of previous entry.');

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        PendingCustomerUpdate.SetFilter(MembershipEntryNo, '=%1', Membership."Entry No.");
        PendingCustomerUpdate.FindFirst();
        Assert.AreEqual(TargetMembershipCode, PendingCustomerUpdate.MembershipCode, 'Pending customer update should have target membership code target.');
        Assert.AreEqual(MembershipEntry."Valid From Date", PendingCustomerUpdate."Valid From Date", 'Pending customer update effective date should match membership entry valid from date.');

        PendingUpdate.ApplyUpdate(PendingCustomerUpdate);
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be target after the pending customer update applied.');

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AutoRenew_04()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        PendingUpdate: Codeunit "NPR MM Update Customer Pending";
        MembershipId: Text;
        MembershipNumber: Text;
        OptionId: Guid;
        MemberId: Text;
        MemberNumber: Text;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
        ValidUntilDate: Date;
        SalesItemNo: Code[20];
    begin

        // Test: Age-constraint driven auto-renewal switches GOLD -> SILVER immediately when the target does NOT defer alterations.
        // Scenario:
        // - Configure auto-renew for GOLD with an age constraint (LT 8 years). When the constraint is violated, auto-renew should
        //   switch to the SILVER auto-renew option (AutoRenewToOnAgeConstraint).
        // - Enable age verification for both GOLD and SILVER (validated against sales date).
        // - Configure SILVER (target) with Defer Cust. Update Alterations = false so membership code changes apply immediately.
        // Steps verified:
        // 1) Create a GOLD membership for a member under the age threshold and run multiple AutoRenew calls; renewals stay on GOLD.
        // 2) After changing the member birthday to exceed the age threshold, the next AutoRenew switches the renewal to SILVER.
        // 3) Because SILVER does not defer alterations, the membership header flips to SILVER immediately.
        // 4) No Pending Customer Update is created (FindFirst should error / no record).

        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';
        SalesItemNo := 'T-320100';

        _MemberModuleLib.SetupAutoRenew(TargetMembershipCode, 'T-320101-AUTORENEW', '', 'Auto Renew SILVER Membership');

        OptionId := _MemberModuleLib.SetupAutoRenew(CurrentMembershipCode, 'T-320100-AUTORENEW', TargetMembershipCode, 'Auto Renew GOLD Membership');
        MembershipAlterationSetup.GetBySystemId(OptionId);
        MembershipAlterationSetup."Age Constraint Type" := MembershipAlterationSetup."Age Constraint Type"::LT;
        MembershipAlterationSetup."Age Constraint (Years)" := 8;
        MembershipAlterationSetup.AutoRenewToOnAgeConstraint := 'T-320101-AUTORENEW';
        MembershipAlterationSetup.Modify();

        MembershipSetup.Get(CurrentMembershipCode); // Current membership code for renewal dictates age verification behavior
        MembershipSetup."Enable Age Verification" := true;
        MembershipSetup."Validate Age Against" := MembershipSetup."Validate Age Against"::SALESDATE_YMD;
        MembershipSetup.Modify();

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := false;
        MembershipSetup."Enable Age Verification" := true;
        MembershipSetup."Validate Age Against" := MembershipSetup."Validate Age Against"::SALESDATE_YMD;
        MembershipSetup.Modify();

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, SalesItemNo);
        MembershipSalesSetup."Age Constraint (Years)" := 8;
        MembershipSalesSetup."Age Constraint Type" := MembershipSalesSetup."Age Constraint Type"::LT;
        MembershipSalesSetup."Age Constraint Applies To" := MembershipSalesSetup."Age Constraint Applies To"::ALL;
        MembershipSalesSetup.Modify();
        Commit();

        CreateGoldMembershipAndMember(SalesItemNo, Calcdate('<-6Y>'), MembershipId, MembershipNumber, MemberId, MemberNumber);

        AutoRenew(MembershipId);
        AutoRenew(MembershipId);

        AutoRenew(MembershipId);

        MembershipEntry.FindLast();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');
        ValidUntilDate := MembershipEntry."Valid Until Date";

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        // Change member age to trigger age constraint based auto-renewal to different membership code
        Member.GetBySystemId(MemberId);
        Member.Birthday := Calcdate('<-10Y>');
        Member.Modify();

        AutoRenew(MembershipId);
        AutoRenew(MembershipId);

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');

        // With deferred update, membership code should not yet be altered
        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');

        PendingCustomerUpdate.SetFilter(MembershipEntryNo, '=%1', Membership."Entry No.");
        asserterror PendingCustomerUpdate.FindFirst();

    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AutoRenew_05()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        PendingUpdate: Codeunit "NPR MM Update Customer Pending";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
        ValidUntilDate: Date;
        SalesItemNo: Code[20];
    begin

        // Test: AutoRenew with age validation on sale + age-triggered switch to a different membership code, with deferred update.
        // Scenario:
        // - Configure GOLD to auto-renew, but when member age crosses an LT 8y constraint the renewal should switch to SILVER.
        // - Both memberships have age verification enabled (validated against sales date).
        // - SILVER defers customer update alterations, meaning the membership record should not change code immediately;
        //   instead a Pending Customer Update is created and must be applied to finalize the switch.
        // Steps verified:
        // 1) Creating GOLD with an over-age member fails (age constraint enforced at sale), while creating with an under-age member succeeds.
        // 2) While the member remains under the age constraint, repeated AutoRenew calls keep entries on GOLD and membership stays GOLD.
        // 3) After changing the member birthday to exceed the age constraint, the next AutoRenew creates a SILVER membership entry,
        //    but the membership record still shows GOLD until the Pending Customer Update is applied.
        // 4) Applying the pending update switches the membership record to SILVER.
        // 5) Subsequent AutoRenew calls keep both membership entries and membership record on SILVER.

        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';
        SalesItemNo := 'T-320100';

        _MemberModuleLib.SetupAutoRenew(TargetMembershipCode, 'T-320101-AUTORENEW', '', 'Auto Renew SILVER Membership');

        OptionId := _MemberModuleLib.SetupAutoRenew(CurrentMembershipCode, 'T-320100-AUTORENEW', TargetMembershipCode, 'Auto Renew GOLD Membership');
        MembershipAlterationSetup.GetBySystemId(OptionId);
        MembershipAlterationSetup."Age Constraint Type" := MembershipAlterationSetup."Age Constraint Type"::LT;
        MembershipAlterationSetup."Age Constraint (Years)" := 8;
        MembershipAlterationSetup.AutoRenewToOnAgeConstraint := 'T-320101-AUTORENEW';
        MembershipAlterationSetup.Modify();

        MembershipSetup.Get(CurrentMembershipCode); // Current membership code for renewal dictates age verification behavior
        MembershipSetup."Enable Age Verification" := true;
        MembershipSetup."Validate Age Against" := MembershipSetup."Validate Age Against"::SALESDATE_YMD;
        MembershipSetup.Modify();

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := true;
        MembershipSetup."Enable Age Verification" := true;
        MembershipSetup."Validate Age Against" := MembershipSetup."Validate Age Against"::SALESDATE_YMD;
        MembershipSetup.Modify();

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, SalesItemNo);
        MembershipSalesSetup."Age Constraint (Years)" := 8;
        MembershipSalesSetup."Age Constraint Type" := MembershipSalesSetup."Age Constraint Type"::LT;
        MembershipSalesSetup."Age Constraint Applies To" := MembershipSalesSetup."Age Constraint Applies To"::ALL;
        MembershipSalesSetup.Modify();
        Commit();

        // Verify member age constraint rules for initial membership
        asserterror CreateGoldMembershipAndMember(SalesItemNo, Calcdate('<-10Y>'), MembershipId, MembershipNumber, MemberId, MemberNumber);
        CreateGoldMembershipAndMember(SalesItemNo, Calcdate('<-6Y>'), MembershipId, MembershipNumber, MemberId, MemberNumber);

        // Member is initially under age constraint, so auto-renewals stay on current membership code
        AutoRenew(MembershipId);
        AutoRenew(MembershipId);
        AutoRenew(MembershipId);

        MembershipEntry.FindLast();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');
        ValidUntilDate := MembershipEntry."Valid Until Date";

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        // Change member age to trigger age constraint based auto-renewal to different membership code
        Member.GetBySystemId(MemberId);
        Member.Birthday := Calcdate('<-10Y>');
        Member.Modify();

        // First auto-renew to target membership code
        AutoRenew(MembershipId);

        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');

        // With deferred update, membership code should not yet be altered
        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        // Run pending customer update to apply target membership code
        PendingCustomerUpdate.SetFilter(MembershipEntryNo, '=%1', Membership."Entry No.");
        PendingCustomerUpdate.FindFirst();
        Assert.AreEqual(TargetMembershipCode, PendingCustomerUpdate.MembershipCode, 'Pending customer update should have target membership code target.');
        Assert.AreEqual(MembershipEntry."Valid From Date", PendingCustomerUpdate."Valid From Date", 'Pending customer update effective date should match membership entry valid from date.');

        PendingUpdate.ApplyUpdate(PendingCustomerUpdate);
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be target after the pending customer update applied.');
        // --


        // Next auto-renews should stay on target membership code
        AutoRenew(MembershipId);
        AutoRenew(MembershipId);
        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');

        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be target after the pending customer update applied.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RecurringPayments_Renew_01()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        PendingUpdate: Codeunit "NPR MM Update Customer Pending";

        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OptionId: Guid;
        CurrentMembershipCode, TargetMembershipCode : Code[20];
        ValidUntilDate: Date;
        SalesItemNo: Code[20];
    begin

        // Test: Recurring-payment auto-renewal with age-based membership switch + deferred customer update.
        // Scenario:
        // - Start with a GOLD membership created from SalesItemNo with age verification enabled.
        // - Configure auto-renew for GOLD, but when member age crosses an Less Than 8y constraint the renewal should switch to SILVER.
        // - SILVER is configured to defer customer update alterations, so the membership code should NOT change immediately on renew;
        //   instead a Pending Customer Update should be created with the target membership code schedule to run on the switch over date.
        // Steps verified:
        // 1) Multiple recurring-payment renewals keep the membership on GOLD and extend validity as normal.
        // 2) After changing the member birthday to trigger the age constraint, the next renewal creates a Pending Customer Update
        //    targeting SILVER (effective from the new entry Valid From Date) while the membership remains GOLD.
        // 3) Applying the pending update flips the membership to SILVER, and subsequent renewals/entries stay on SILVER.


        Initialize();
        CurrentMembershipCode := 'T-GOLD';
        TargetMembershipCode := 'T-SILVER';
        SalesItemNo := 'T-320100';

        _MemberModuleLib.SetupAutoRenew(TargetMembershipCode, 'T-320101-AUTORENEW', '', 'Auto Renew SILVER Membership');

        OptionId := _MemberModuleLib.SetupAutoRenew(CurrentMembershipCode, 'T-320100-AUTORENEW', TargetMembershipCode, 'Auto Renew GOLD Membership');
        MembershipAlterationSetup.GetBySystemId(OptionId);
        MembershipAlterationSetup."Age Constraint Type" := MembershipAlterationSetup."Age Constraint Type"::LT;
        MembershipAlterationSetup."Age Constraint (Years)" := 8;
        MembershipAlterationSetup.AutoRenewToOnAgeConstraint := 'T-320101-AUTORENEW';
        MembershipAlterationSetup.Modify();

        MembershipSetup.Get(CurrentMembershipCode); // Current membership code for renewal dictates age verification behavior
        MembershipSetup."Enable Age Verification" := true;
        MembershipSetup."Validate Age Against" := MembershipSetup."Validate Age Against"::SALESDATE_YMD;
        MembershipSetup.Modify();

        MembershipSetup.Get(TargetMembershipCode); // Target membership code for renewal dictates update deferral behavior
        MembershipSetup."Defer Cust. Update Alterations" := true;
        MembershipSetup."Enable Age Verification" := true;
        MembershipSetup."Validate Age Against" := MembershipSetup."Validate Age Against"::SALESDATE_YMD;
        MembershipSetup.Modify();

        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, SalesItemNo);
        MembershipSalesSetup."Age Constraint (Years)" := 8;
        MembershipSalesSetup."Age Constraint Type" := MembershipSalesSetup."Age Constraint Type"::LT;
        MembershipSalesSetup."Age Constraint Applies To" := MembershipSalesSetup."Age Constraint Applies To"::ALL;
        MembershipSalesSetup.Modify();
        Commit();

        CreateGoldMembershipAndMember(SalesItemNo, Calcdate('<-6Y>'), MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);

        AutoRenewViaRecurringPayment(MembershipId);
        AutoRenewViaRecurringPayment(MembershipId);
        AutoRenewViaRecurringPayment(MembershipId);

        // Check
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.FindLast();
        Assert.AreEqual(CurrentMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after create.');
        ValidUntilDate := MembershipEntry."Valid Until Date";

        Membership.GetBySystemId(MembershipId);
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        // Change member age to trigger age constraint based auto-renewal to different membership code
        Member.GetBySystemId(MemberId);
        Member.Birthday := Calcdate('<-10Y>');
        Member.Modify();

        AutoRenewViaRecurringPayment(MembershipId);

        MembershipEntry.FindLast();
        // Run pending customer update to apply target membership code
        PendingCustomerUpdate.SetFilter(MembershipEntryNo, '=%1', Membership."Entry No.");
        PendingCustomerUpdate.FindFirst();
        Assert.AreEqual(TargetMembershipCode, PendingCustomerUpdate.MembershipCode, 'Pending customer update should have target membership code target.');
        Assert.AreEqual(MembershipEntry."Valid From Date", PendingCustomerUpdate."Valid From Date", 'Pending customer update effective date should match membership entry valid from date.');
        Assert.AreEqual(CurrentMembershipCode, Membership."Membership Code", 'Membership code should be ' + CurrentMembershipCode + ' after alteration.');

        PendingUpdate.ApplyUpdate(PendingCustomerUpdate);
        Membership.Get(Membership."Entry No.");
        Assert.AreEqual(TargetMembershipCode, Membership."Membership Code", 'Membership code should be target after the pending customer update applied.');

        AutoRenewViaRecurringPayment(MembershipId);

        // Check
        MembershipEntry.FindLast();
        Assert.AreEqual(TargetMembershipCode, MembershipEntry."Membership Code", 'Membership code should be ' + TargetMembershipCode + ' after alteration.');


    end;


    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    local procedure Initialize()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        CancelItemNo: Code[20];
    begin
        if _IsInitialized then
            exit;

        MemberLibrary.Initialize();
        MemberLibrary.CreateScenario_SmokeTest();

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Membership');

        _IsInitialized := true;
    end;

    local procedure CreateGoldMembershipAndMember(var MembershipId: Text; var MembershipNumber: Text; var MemberId: Text; var MemberNumber: Text)
    begin
        CreateGoldMembership('T-320100', MembershipId, MembershipNumber);
        AddMember(0D, MembershipId, MemberId, MemberNumber);
    end;

    local procedure CreateGoldMembershipAndMember(SalesItem: Code[20]; DateOfBirth: Date; var MembershipId: Text; var MembershipNumber: Text; var MemberId: Text; var MemberNumber: Text)
    begin
        CreateGoldMembership(SalesItem, MembershipId, MembershipNumber);
        AddMember(DateOfBirth, MembershipId, MemberId, MemberNumber);
    end;

    local procedure CreateGoldMembership(SalesItem: Code[20]; var MembershipId: Text; var MembershipNumber: Text)
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
    begin
        Body.Add('itemNumber', SalesItem);
        Body.Add('activationDate', CalcDate('<-6M>'));

        Response := InvokeApi('POST', 'membership', Body);
        ResponseBody := GetResponseBodyOrError(Response, 'Create membership failed.');

        MembershipId := JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipId', true);
        MembershipNumber := JsonHelper.GetJText(ResponseBody.AsToken(), 'membership.membershipNumber', true);
    end;

    local procedure AddMember(DateOfBirth: Date; MembershipId: Text; var MemberId: Text; var MemberNumber: Text)
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        JsonHelper: Codeunit "NPR Json Helper";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Body: JsonObject;
        MemberJson: JsonObject;
        Response: JsonObject;
        ResponseBody: JsonObject;
    begin
        MemberLibrary.SetRandomMemberInfoData(MemberInfoCapture);
        if (DateOfBirth <> 0D) then
            MemberInfoCapture.Birthday := DateOfBirth;

        MemberJson.Add('firstName', MemberInfoCapture."First Name");
        MemberJson.Add('middleName', MemberInfoCapture."Middle Name");
        MemberJson.Add('lastName', MemberInfoCapture."Last Name");
        MemberJson.Add('email', MemberInfoCapture."E-Mail Address");
        MemberJson.Add('phoneNo', MemberInfoCapture."Phone No.");
        MemberJson.Add('birthday', MemberInfoCapture.Birthday);
        MemberJson.Add('city', MemberInfoCapture.City);
        MemberJson.Add('country', MemberInfoCapture.Country);
        MemberJson.Add('postCode', MemberInfoCapture."Post Code Code");
        MemberJson.Add('preferredLanguage', MemberInfoCapture.PreferredLanguageCode);

        Body.Add('member', MemberJson);

        Response := InvokeApi('POST', StrSubstNo('membership/%1/addMember', MembershipId), Body);
        ResponseBody := GetResponseBodyOrError(Response, 'Add member failed.');

        MemberId := JsonHelper.GetJText(ResponseBody.AsToken(), 'member.memberId', true);
        MemberNumber := JsonHelper.GetJText(ResponseBody.AsToken(), 'member.memberNumber', true);
    end;

    local procedure SelectFirstRenewalOptionId(MembershipId: Text): Guid
    begin
        exit(SelectFirstOptionId(MembershipId, 'renewalOptions'));
    end;

    local procedure SelectFirstUpgradeOptionId(MembershipId: Text): Guid
    begin
        exit(SelectFirstOptionId(MembershipId, 'upgradeOptions'));
    end;

    local procedure SelectFirstExtendOptionId(MembershipId: Text): Guid
    begin
        exit(SelectFirstOptionId(MembershipId, 'extendOptions'));
    end;

    local procedure SelectFirstOptionId(MembershipId: Text; OptionsPath: Text) OptionId: Guid
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Body: JsonObject;
        Response: JsonObject;
        OptionsToken: JsonToken;
        OptionToken: JsonToken;
        Options: JsonArray;
    begin
        Response := InvokeApi('GET', StrSubstNo('membership/%1/%2', MembershipId, OptionsPath), EmptyBody());
        Body := GetResponseBodyOrError(Response, StrSubstNo('Get %1 failed.', OptionsPath));

        if not Body.AsToken().SelectToken('membership.options', OptionsToken) then
            Error('Options not returned.');

        Options := OptionsToken.AsArray();
        if Options.Count() = 0 then
            Error('No options returned.');

        Options.Get(0, OptionToken);
        Evaluate(OptionId, JsonHelper.GetJText(OptionToken, 'optionId', true));
    end;

    local procedure RenewMembership(MembershipId: Text; OptionId: Guid)
    begin
        ApplyMembershipChangeOption(MembershipId, 'renew', OptionId, 0D);
    end;

    local procedure UpgradeMembership(MembershipId: Text; OptionId: Guid; DocumentDate: Date)
    begin
        ApplyMembershipChangeOption(MembershipId, 'upgrade', OptionId, DocumentDate);
    end;

    local procedure ExtendMembership(MembershipId: Text; OptionId: Guid; DocumentDate: Date)
    begin
        ApplyMembershipChangeOption(MembershipId, 'extend', OptionId, DocumentDate);
    end;

    local procedure CancelMembership(MembershipId: Text; OptionId: Guid; DocumentDate: Date)
    begin
        ApplyMembershipChangeOption(MembershipId, 'cancel', OptionId, DocumentDate);
    end;

    local procedure ApplyMembershipChangeOption(MembershipId: Text; ActionPath: Text; OptionId: Guid; DocumentDate: Date)
    var
        Body: JsonObject;
        Response: JsonObject;
    begin
        Body.Add('optionId', Format(OptionId, 0, 4).ToLower());

        if (DocumentDate <> 0D) then
            Body.Add('documentDate', DocumentDate);

        Response := InvokeApi('POST', StrSubstNo('membership/%1/%2', MembershipId, ActionPath), Body);
        GetResponseBodyOrError(Response, StrSubstNo('Apply %1 failed.', ActionPath));
    end;

    local procedure ApplyRegret(MembershipId: Text; EntryId: Text)
    var
        Body: JsonObject;
        Response: JsonObject;
    begin
        Body.Add('entryId', EntryId);

        Response := InvokeApi('POST', StrSubstNo('membership/%1/regret', MembershipId), Body);
        GetResponseBodyOrError(Response, 'Regret failed.');
    end;

    local procedure GetMembershipLedgerEntryCount(MembershipId: Text): Integer
    var
        Body: JsonObject;
        Response: JsonObject;
        EntriesToken: JsonToken;
        Entries: JsonArray;
    begin
        Response := InvokeApi('GET', StrSubstNo('membership/%1/history', MembershipId), EmptyBody());
        Body := GetResponseBodyOrError(Response, 'Get history failed.');

        if not Body.AsToken().SelectToken('membership.entries', EntriesToken) then
            exit(0);

        Entries := EntriesToken.AsArray();
        exit(Entries.Count());
    end;


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
        Body := LibraryNPRetailAPI.GetResponseBody(Response);
        if not LibraryNPRetailAPI.IsSuccessStatusCode(Response) then begin
            Body.WriteTo(ResponseText);
            Error('%1 Response: %2', ErrorText, ResponseText);
        end;
    end;

    local procedure EmptyBody(): JsonObject
    var
        Body: JsonObject;
    begin
        exit(Body);
    end;

    local procedure AutoRenew(MembershipId: Guid)
    var
        Membership: Record "NPR MM Membership";
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        EntryNo: Integer;
        ReasonText: Text;
        StartDateOut, UntilDateOut : Date;
        AutoRenewPrice: Decimal;
    begin
        Membership.GetBySystemId(MembershipId);
        Membership."Auto-Renew" := Membership."Auto-Renew"::YES_EXTERNAL;
        Membership.Modify();

        EntryNo := MembershipManagement.CreateAutoRenewMemberInfoRequest(Membership."Entry No.", '', ReasonText);
        if (EntryNo = 0) then
            Error('Auto-renew member info request creation failed: %1.', ReasonText);

        MemberInfoCapture.Get(EntryNo);
        if (not MembershipManagement.AutoRenewMembership(MemberInfoCapture, true, Today(), StartDateOut, UntilDateOut, AutoRenewPrice, ReasonText)) then
            Error('Auto-renew membership failed: %1.', ReasonText);

    end;

    local procedure AutoRenewViaRecurringPayment(MembershipId: Guid)
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest, SubscriptionRequest2 : Record "NPR MM Subscr. Request";
        RenewProcess: Codeunit "NPR MM Subs Try Renew Process";
        RequestSubscrRenewal: Codeunit "NPR MM Subscr. Renew: Request";
    begin
        Membership.GetBySystemId(MembershipId);
        Membership."Auto-Renew" := Membership."Auto-Renew"::YES_EXTERNAL;
        Membership.Modify();

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.FindLast();

        // Do - Create recurring payment subscription for membership
        Subscription."Membership Entry No." := Membership."Entry No.";
        Subscription."Membership Ledger Entry No." := MembershipEntry."Entry No.";
        Subscription."Valid From Date" := MembershipEntry."Valid From Date";
        Subscription."Valid Until Date" := MembershipEntry."Valid Until Date";
        Subscription.Insert();

        SubscriptionRequest.Type := Enum::"NPR MM Subscr. Request Type"::Renew;
        SubscriptionRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscriptionRequest.Insert();

        RequestSubscrRenewal.CalculateSubscriptionRenewal(Subscription, SubscriptionRequest2);
        SubscriptionRequest."New Valid From Date" := SubscriptionRequest2."New Valid From Date";
        SubscriptionRequest."New Valid Until Date" := SubscriptionRequest2."New Valid Until Date";
        SubscriptionRequest.Amount := SubscriptionRequest2.Amount;
        SubscriptionRequest.Modify();

        RenewProcess.ProcessConfirmedStatus(SubscriptionRequest);

        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        SubscriptionRequest.TestField("Processing Status", SubscriptionRequest."Processing Status"::Success);
    end;
}
#endif
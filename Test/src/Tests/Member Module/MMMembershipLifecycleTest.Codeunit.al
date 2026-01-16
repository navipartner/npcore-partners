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
}
#endif
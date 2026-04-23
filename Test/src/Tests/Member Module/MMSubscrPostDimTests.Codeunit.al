codeunit 85223 "NPR MM Subscr.Post.Dim.Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERM: Codeunit "Library - ERM";
        _MemberModuleLib: Codeunit "NPR Library - Member Module";
        _IsInitialized: Boolean;
        _MembershipCode: Code[20];
        _MembershipSetup: Record "NPR MM Membership Setup";
        _RecurringPaymentSetup: Record "NPR MM Recur. Paym. Setup";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPostingNoDimensionsSucceeds()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        GLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Subscription posting without any dimension setup should succeed
        // [GIVEN] A membership with subscription and no dimension requirements
        Initialize();
        CreateMembershipWithSubscription(Membership);
        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);

        // [WHEN] Posting the subscription request
        PostSubscriptionRequest(SubscriptionRequest, Membership);

        // [THEN] The posting succeeds and G/L entries are created without dimensions
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscriptionRequest.Posted, 'Subscription request should be posted.');
        Assert.AreNotEqual(0, SubscriptionRequest."G/L Entry No.", 'G/L Entry No. should be set.');

        GLEntry.Get(SubscriptionRequest."G/L Entry No.");
        Assert.AreEqual(0, GLEntry."Dimension Set ID", 'Dimension Set ID should be 0 when no dimensions are configured.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPostingMandatoryDimOnRevenueGLNoDimOnSetup()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        // [SCENARIO] Subscription posting with mandatory dimension on Revenue G/L Account, no dimension on Recurring Payment Setup - should fail
        // [GIVEN] A mandatory dimension (Global Dimension 1) on the Revenue G/L Account
        Initialize();
        GeneralLedgerSetup.Get();
        SetMandatoryDimensionOnGLAccount(_RecurringPaymentSetup."Revenue Account", GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] No dimension configured on Recurring Payment Setup
        ClearDimensionsOnRecurringPaymentSetup();

        // [GIVEN] A membership with subscription request
        CreateMembershipWithSubscription(Membership);
        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);

        // [WHEN] Posting the subscription request
        // [THEN] The posting fails due to missing mandatory dimension
        asserterror PostSubscriptionRequest(SubscriptionRequest, Membership);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPaymentPostingMandatoryDimOnPaymentAccNoDimOnSetup()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PaymentAccountNo: Code[20];
    begin
        // [SCENARIO] Payment posting with mandatory dimension on Payment Account (PSP), no dimension on Recurring Payment Setup - should fail
        // [GIVEN] A mandatory dimension (Global Dimension 1) on the Payment Account
        Initialize();
        GeneralLedgerSetup.Get();
        PaymentAccountNo := SetupAdyenPaymentGateway();
        SetMandatoryDimensionOnGLAccount(PaymentAccountNo, GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] No dimension configured on Recurring Payment Setup
        ClearDimensionsOnRecurringPaymentSetup();

        // [GIVEN] A membership with subscription request and payment request
        CreateMembershipWithSubscription(Membership);
        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);
        PostSubscriptionRequest(SubscriptionRequest, Membership);
        CreateCapturedPaymentRequest(SubscriptionRequest, SubscrPaymentRequest);

        // [WHEN] Posting the payment request
        // [THEN] The posting fails due to missing mandatory dimension
        asserterror PostPaymentRequest(SubscriptionRequest);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPostingMandatoryDimOnBothAccountsNoDimOnSetup()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        GeneralLedgerSetup: Record "General Ledger Setup";
        PaymentAccountNo: Code[20];
    begin
        // [SCENARIO] Subscription posting with mandatory dimension on BOTH Revenue G/L and Payment Account, no dimension on setup - should fail
        // [GIVEN] A mandatory dimension (Global Dimension 1) on Revenue G/L Account
        Initialize();
        GeneralLedgerSetup.Get();
        SetMandatoryDimensionOnGLAccount(_RecurringPaymentSetup."Revenue Account", GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] Same mandatory dimension on Payment Account
        PaymentAccountNo := SetupAdyenPaymentGateway();
        SetMandatoryDimensionOnGLAccount(PaymentAccountNo, GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] No dimension configured on Recurring Payment Setup
        ClearDimensionsOnRecurringPaymentSetup();

        // [GIVEN] A membership with subscription request
        CreateMembershipWithSubscription(Membership);
        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);

        // [WHEN] Posting the subscription request (invoice)
        // [THEN] The posting fails due to missing mandatory dimension on Revenue G/L Account
        asserterror PostSubscriptionRequest(SubscriptionRequest, Membership);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPostingMandatoryDimOnRevenueGLDimOnSetupSucceeds()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GlobalDim1Value: Record "Dimension Value";
        GLEntry: Record "G/L Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
    begin
        // [SCENARIO] Subscription posting with mandatory dimension on Revenue G/L Account, dimension configured on Recurring Payment Setup - should succeed
        // [GIVEN] A mandatory dimension (Global Dimension 1) on the Revenue G/L Account
        Initialize();
        GeneralLedgerSetup.Get();
        SetMandatoryDimensionOnGLAccount(_RecurringPaymentSetup."Revenue Account", GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] The same dimension configured on Recurring Payment Setup via Global Dimension 1 Code field
        CreateDimensionValueForDimension(GlobalDim1Value, GeneralLedgerSetup."Global Dimension 1 Code");
        _RecurringPaymentSetup.Get(_RecurringPaymentSetup.Code);
        _RecurringPaymentSetup.Validate("Global Dimension 1 Code", GlobalDim1Value.Code);
        _RecurringPaymentSetup.Modify(true);

        // [GIVEN] A membership with subscription request
        CreateMembershipWithSubscription(Membership);
        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);

        // [WHEN] Posting the subscription request
        PostSubscriptionRequest(SubscriptionRequest, Membership);

        // [THEN] The posting succeeds
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscriptionRequest.Posted, 'Subscription request should be posted.');

        // [THEN] G/L entries have the correct dimensions
        GLEntry.Get(SubscriptionRequest."G/L Entry No.");
        Assert.AreNotEqual(0, GLEntry."Dimension Set ID", 'Dimension Set ID should not be 0.');

        DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        DimensionSetEntry.SetRange("Dimension Value Code", GlobalDim1Value.Code);
        Assert.IsTrue(DimensionSetEntry.FindFirst(), 'Dimension should be present on G/L entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPaymentPostingMandatoryDimOnPaymentAccDimOnSetupSucceeds()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GlobalDim1Value: Record "Dimension Value";
        GLEntry: Record "G/L Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        PaymentAccountNo: Code[20];
    begin
        // [SCENARIO] Payment posting with mandatory dimension on Payment Account, dimension configured on Recurring Payment Setup - should succeed
        // [GIVEN] A mandatory dimension (Global Dimension 1) on the Payment Account
        Initialize();
        GeneralLedgerSetup.Get();
        PaymentAccountNo := SetupAdyenPaymentGateway();
        SetMandatoryDimensionOnGLAccount(PaymentAccountNo, GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] The same dimension configured on Recurring Payment Setup via Global Dimension 1 Code field
        CreateDimensionValueForDimension(GlobalDim1Value, GeneralLedgerSetup."Global Dimension 1 Code");
        _RecurringPaymentSetup.Get(_RecurringPaymentSetup.Code);
        _RecurringPaymentSetup.Validate("Global Dimension 1 Code", GlobalDim1Value.Code);
        _RecurringPaymentSetup.Modify(true);

        // [GIVEN] A membership with subscription request and payment request
        CreateMembershipWithSubscription(Membership);
        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);
        PostSubscriptionRequest(SubscriptionRequest, Membership);
        CreateCapturedPaymentRequest(SubscriptionRequest, SubscrPaymentRequest);

        // [WHEN] Posting the payment request
        PostPaymentRequest(SubscriptionRequest);

        // [THEN] The posting succeeds
        SubscrPaymentRequest.Get(SubscrPaymentRequest."Entry No.");
        Assert.IsTrue(SubscrPaymentRequest.Posted, 'Payment request should be posted.');

        // [THEN] G/L entries have the correct dimensions
        GLEntry.Get(SubscrPaymentRequest."G/L Entry No.");
        Assert.AreNotEqual(0, GLEntry."Dimension Set ID", 'Dimension Set ID should not be 0.');

        DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        DimensionSetEntry.SetRange("Dimension Value Code", GlobalDim1Value.Code);
        Assert.IsTrue(DimensionSetEntry.FindFirst(), 'Dimension should be present on G/L entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPostingMandatoryDimOnBothAccountsDimOnSetupSucceeds()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GlobalDim1Value: Record "Dimension Value";
        GLEntry: Record "G/L Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        PaymentAccountNo: Code[20];
    begin
        // [SCENARIO] Subscription posting with mandatory dimension on BOTH Revenue G/L and Payment Account, dimension configured on Recurring Payment Setup - should succeed
        // [GIVEN] A mandatory dimension (Global Dimension 1) on both the Revenue G/L Account and Payment Account
        Initialize();
        GeneralLedgerSetup.Get();
        SetMandatoryDimensionOnGLAccount(_RecurringPaymentSetup."Revenue Account", GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] Same mandatory dimension on Payment Account
        PaymentAccountNo := SetupAdyenPaymentGateway();
        SetMandatoryDimensionOnGLAccount(PaymentAccountNo, GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] The same dimension configured on Recurring Payment Setup via Global Dimension 1 Code field
        CreateDimensionValueForDimension(GlobalDim1Value, GeneralLedgerSetup."Global Dimension 1 Code");
        _RecurringPaymentSetup.Get(_RecurringPaymentSetup.Code);
        _RecurringPaymentSetup.Validate("Global Dimension 1 Code", GlobalDim1Value.Code);
        _RecurringPaymentSetup.Modify(true);

        // [GIVEN] A membership with subscription request
        CreateMembershipWithSubscription(Membership);
        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);

        // [WHEN] Posting the subscription request (invoice)
        PostSubscriptionRequest(SubscriptionRequest, Membership);

        // [THEN] The invoice posting succeeds
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscriptionRequest.Posted, 'Subscription request should be posted.');

        // [THEN] G/L entries have the correct dimensions
        GLEntry.Get(SubscriptionRequest."G/L Entry No.");
        Assert.AreNotEqual(0, GLEntry."Dimension Set ID", 'Dimension Set ID should not be 0.');

        DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        DimensionSetEntry.SetRange("Dimension Value Code", GlobalDim1Value.Code);
        Assert.IsTrue(DimensionSetEntry.FindFirst(), 'Dimension should be present on invoice G/L entry.');

        // [WHEN] Posting the payment request
        CreateCapturedPaymentRequest(SubscriptionRequest, SubscrPaymentRequest);
        PostPaymentRequest(SubscriptionRequest);

        // [THEN] The payment posting succeeds
        SubscrPaymentRequest.Get(SubscrPaymentRequest."Entry No.");
        Assert.IsTrue(SubscrPaymentRequest.Posted, 'Payment request should be posted.');

        // [THEN] Payment G/L entries have the correct dimensions
        GLEntry.Get(SubscrPaymentRequest."G/L Entry No.");
        Assert.AreNotEqual(0, GLEntry."Dimension Set ID", 'Payment Dimension Set ID should not be 0.');

        DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        DimensionSetEntry.SetRange("Dimension Value Code", GlobalDim1Value.Code);
        Assert.IsTrue(DimensionSetEntry.FindFirst(), 'Dimension should be present on payment G/L entry.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPostingWithDeferralDimensionsOnDeferralEntries()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        Item: Record Item;
        DeferralTemplate: Record "Deferral Template";
        GeneralLedgerSetup: Record "General Ledger Setup";
        GlobalDim1Value: Record "Dimension Value";
        GLEntry: Record "G/L Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        PostedDeferralHeader: Record "Posted Deferral Header";
        PostedDeferralLine: Record "Posted Deferral Line";
    begin
        // [SCENARIO] Subscription posting with mandatory dimensions and deferral setup - should succeed; verify dimensions flow to deferral entries
        // [GIVEN] A mandatory dimension (Global Dimension 1) on the Revenue G/L Account
        Initialize();
        GeneralLedgerSetup.Get();
        SetMandatoryDimensionOnGLAccount(_RecurringPaymentSetup."Revenue Account", GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] The same dimension configured on Recurring Payment Setup via Global Dimension 1 Code field
        CreateDimensionValueForDimension(GlobalDim1Value, GeneralLedgerSetup."Global Dimension 1 Code");
        _RecurringPaymentSetup.Get(_RecurringPaymentSetup.Code);
        _RecurringPaymentSetup.Validate("Global Dimension 1 Code", GlobalDim1Value.Code);
        _RecurringPaymentSetup.Modify(true);

        // [GIVEN] A deferral template on the subscription item
        CreateDeferralTemplate(DeferralTemplate);

        // [GIVEN] A membership with subscription request using an item with deferral
        CreateMembershipWithSubscription(Membership);
        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);
        Item.Get(SubscriptionRequest."Item No.");
        Item."Default Deferral Template Code" := DeferralTemplate."Deferral Code";
        Item.Modify();

        // [WHEN] Posting the subscription request
        PostSubscriptionRequest(SubscriptionRequest, Membership);

        // [THEN] The posting succeeds
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscriptionRequest.Posted, 'Subscription request should be posted.');

        // [THEN] G/L entries have the correct dimensions
        GLEntry.Get(SubscriptionRequest."G/L Entry No.");
        Assert.AreNotEqual(0, GLEntry."Dimension Set ID", 'Dimension Set ID should not be 0.');

        DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        DimensionSetEntry.SetRange("Dimension Value Code", GlobalDim1Value.Code);
        Assert.IsTrue(DimensionSetEntry.FindFirst(), 'Dimension should be present on G/L entry.');

        // [THEN] Posted deferral header exists
        PostedDeferralHeader.SetRange("Document No.", Format(SubscriptionRequest."Entry No."));
        PostedDeferralHeader.SetRange("Deferral Doc. Type", PostedDeferralHeader."Deferral Doc. Type"::"G/L");
        Assert.IsTrue(PostedDeferralHeader.FindFirst(), 'Posted deferral header should exist.');

        // [THEN] Posted deferral lines exist
        PostedDeferralLine.SetRange("Deferral Doc. Type", PostedDeferralHeader."Deferral Doc. Type");
        PostedDeferralLine.SetRange("Document No.", PostedDeferralHeader."Document No.");
        Assert.IsTrue(PostedDeferralLine.FindFirst(), 'Posted deferral lines should exist.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SubscrPostingDimensionPrioritySetupOverridesCustomer()
    var
        Membership: Record "NPR MM Membership";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        GeneralLedgerSetup: Record "General Ledger Setup";
        SetupDimensionValue: Record "Dimension Value";
        CustomerDimensionValue: Record "Dimension Value";
        GLEntry: Record "G/L Entry";
        DimensionSetEntry: Record "Dimension Set Entry";
        Customer: Record Customer;
    begin
        // [SCENARIO] Test Default Dimension Priorities - when same dimension is configured on multiple sources with different values
        // [GIVEN] Global Dimension 1 with two different values
        Initialize();
        GeneralLedgerSetup.Get();
        CreateDimensionValueForDimension(SetupDimensionValue, GeneralLedgerSetup."Global Dimension 1 Code");
        CreateDimensionValueForDimension(CustomerDimensionValue, GeneralLedgerSetup."Global Dimension 1 Code");

        // [GIVEN] Default Dimension Priority configured - Recurring Payment Setup has higher priority (1) than Customer (2)
        SetupDefaultDimensionPriority(_RecurringPaymentSetup."Source Code", Database::"NPR MM Recur. Paym. Setup", 1);
        SetupDefaultDimensionPriority(_RecurringPaymentSetup."Source Code", Database::Customer, 2);

        // [GIVEN] The dimension configured on Recurring Payment Setup with value A via Global Dimension 1 Code field
        _RecurringPaymentSetup.Get(_RecurringPaymentSetup.Code);
        _RecurringPaymentSetup.Validate("Global Dimension 1 Code", SetupDimensionValue.Code);
        _RecurringPaymentSetup.Modify(true);

        // [GIVEN] A membership with subscription request
        CreateMembershipWithSubscription(Membership);

        // [GIVEN] The same dimension configured on Customer with value B
        Customer.Get(Membership."Customer No.");
        SetDefaultDimensionOnCustomer(Customer."No.", GeneralLedgerSetup."Global Dimension 1 Code", CustomerDimensionValue.Code);

        CreateRenewalSubscriptionRequest(Membership, SubscriptionRequest);

        // [WHEN] Posting the subscription request
        PostSubscriptionRequest(SubscriptionRequest, Membership);

        // [THEN] The posting succeeds
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscriptionRequest.Posted, 'Subscription request should be posted.');

        // [THEN] G/L entries have the dimension value from the Recurring Payment Setup (higher priority)
        GLEntry.Get(SubscriptionRequest."G/L Entry No.");
        Assert.AreNotEqual(0, GLEntry."Dimension Set ID", 'Dimension Set ID should not be 0.');

        DimensionSetEntry.SetRange("Dimension Set ID", GLEntry."Dimension Set ID");
        DimensionSetEntry.SetRange("Dimension Code", GeneralLedgerSetup."Global Dimension 1 Code");
        Assert.IsTrue(DimensionSetEntry.FindFirst(), 'Dimension should be present on G/L entry.');

        // [THEN] Verify the Setup value applied because it has higher priority (lower number)
        Assert.AreEqual(SetupDimensionValue.Code, DimensionSetEntry."Dimension Value Code",
            'Dimension value should be from Recurring Payment Setup (priority 1) not Customer (priority 2).');
    end;

    local procedure Initialize()
    begin
        if _IsInitialized then
            exit;

        _MemberModuleLib.Initialize();
        _MemberModuleLib.CreateScenario_SmokeTest();

        _MembershipCode := 'T-GOLD';
        _MembershipSetup.Get(_MembershipCode);
        _RecurringPaymentSetup.Get(_MembershipSetup."Recurring Payment Code");

        if _RecurringPaymentSetup."Revenue Account" = '' then begin
            _RecurringPaymentSetup."Revenue Account" := LibraryERM.CreateGLAccountWithSalesSetup();
            _RecurringPaymentSetup.Modify();
        end;
        if _RecurringPaymentSetup."Source Code" = '' then
            SetupSourceCode();
        if _RecurringPaymentSetup."Document No. Series" = '' then
            SetupDocumentNoSeries();

        _IsInitialized := true;
    end;

    local procedure SetupSourceCode()
    var
        SourceCode: Record "Source Code";
    begin
        SourceCode.Code := 'MMSUBSCR';
        SourceCode.Description := 'Membership Subscription';
        if SourceCode.Insert() then;

        _RecurringPaymentSetup."Source Code" := SourceCode.Code;
        _RecurringPaymentSetup.Modify();
    end;

    local procedure SetupDocumentNoSeries()
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if not NoSeries.Get('MM-SUBSPOST') then begin
            NoSeries.Code := 'MM-SUBSPOST';
            NoSeries.Description := 'Subscription Posting';
            NoSeries."Default Nos." := true;
            NoSeries.Insert();

            NoSeriesLine."Series Code" := NoSeries.Code;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := WorkDate();
            NoSeriesLine."Starting No." := 'MMSUB000001';
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;

        _RecurringPaymentSetup."Document No. Series" := 'MM-SUBSPOST';
        _RecurringPaymentSetup.Modify();
    end;

    local procedure CreateMembershipWithSubscription(var Membership: Record "NPR MM Membership")
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);

        Membership.Init();
        Membership."Membership Code" := _MembershipCode;
        Membership."Customer No." := Customer."No.";
        Membership.Insert(true);

        MembershipEntry.Init();
        MembershipEntry."Membership Entry No." := Membership."Entry No.";
        MembershipEntry."Membership Code" := _MembershipCode;
        MembershipEntry.Context := MembershipEntry.Context::NEW;
        MembershipEntry."Valid From Date" := WorkDate();
        MembershipEntry."Valid Until Date" := CalcDate('<+1Y>', WorkDate());
        MembershipEntry.Insert(true);

        Subscription.Init();
        Subscription."Membership Entry No." := Membership."Entry No.";
        Subscription."Membership Ledger Entry No." := MembershipEntry."Entry No.";
        Subscription."Valid From Date" := MembershipEntry."Valid From Date";
        Subscription."Valid Until Date" := MembershipEntry."Valid Until Date";
        Subscription.Insert();
    end;

    local procedure CreateRenewalSubscriptionRequest(Membership: Record "NPR MM Membership"; var SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        Subscription: Record "NPR MM Subscription";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
    begin
        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        Subscription.FindFirst();

        SubscriptionRequest.Init();
        SubscriptionRequest.Type := Enum::"NPR MM Subscr. Request Type"::Renew;
        SubscriptionRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscriptionRequest."Membership Code" := _MembershipCode;
        SubscriptionRequest.Status := Enum::"NPR MM Subscr. Request Status"::Confirmed;
        SubscriptionRequest."New Valid From Date" := CalcDate('<+1D>', Subscription."Valid Until Date");
        SubscriptionRequest."New Valid Until Date" := CalcDate('<+1Y>', SubscriptionRequest."New Valid From Date");
        SubscriptionRequest.Amount := 100;
        SubscriptionRequest."Currency Code" := '';

        MembershipSalesSetup.SetRange("Membership Code", _MembershipCode);
        MembershipSalesSetup.SetRange("Business Flow Type", MembershipSalesSetup."Business Flow Type"::MEMBERSHIP);
        if MembershipSalesSetup.FindFirst() then
            SubscriptionRequest."Item No." := MembershipSalesSetup."No."
        else
            SubscriptionRequest."Item No." := 'T-320100';

        SubscriptionRequest.Insert();
    end;

    local procedure PostSubscriptionRequest(var SubscriptionRequest: Record "NPR MM Subscr. Request"; Membership: Record "NPR MM Membership")
    var
        SubscrRenewPost: Codeunit "NPR MM Subscr. Renew: Post";
    begin
        SubscrRenewPost.PostInvoiceToGL(SubscriptionRequest, Membership, _MembershipSetup);
        SubscriptionRequest.Modify();
    end;

    local procedure CreateDimensionValueForDimension(var DimensionValue: Record "Dimension Value"; DimensionCode: Code[20])
    begin
        if DimensionCode = '' then
            exit;
        LibraryDimension.CreateDimensionValue(DimensionValue, DimensionCode);
    end;

    local procedure ClearDimensionsOnRecurringPaymentSetup()
    begin
        _RecurringPaymentSetup.Get(_RecurringPaymentSetup.Code);
        if (_RecurringPaymentSetup."Global Dimension 1 Code" = '') and (_RecurringPaymentSetup."Global Dimension 2 Code" = '') then
            exit;
        _RecurringPaymentSetup."Global Dimension 1 Code" := '';
        _RecurringPaymentSetup."Global Dimension 2 Code" := '';
        _RecurringPaymentSetup.Modify();
    end;

    local procedure SetMandatoryDimensionOnGLAccount(GLAccountNo: Code[20]; DimensionCode: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if DefaultDimension.Get(Database::"G/L Account", GLAccountNo, DimensionCode) then
            DefaultDimension.Delete();

        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::"G/L Account", GLAccountNo, DimensionCode, '');
        DefaultDimension."Value Posting" := DefaultDimension."Value Posting"::"Code Mandatory";
        DefaultDimension.Modify();
    end;

    local procedure SetDefaultDimensionOnCustomer(CustomerNo: Code[20]; DimensionCode: Code[20]; DimensionValueCode: Code[20])
    var
        DefaultDimension: Record "Default Dimension";
    begin
        if DefaultDimension.Get(Database::Customer, CustomerNo, DimensionCode) then
            DefaultDimension.Delete();

        LibraryDimension.CreateDefaultDimension(DefaultDimension, Database::Customer, CustomerNo, DimensionCode, DimensionValueCode);
    end;

    local procedure SetupDefaultDimensionPriority(SourceCode: Code[10]; TableID: Integer; Priority: Integer)
    var
        DefaultDimensionPriority: Record "Default Dimension Priority";
    begin
        if DefaultDimensionPriority.Get(SourceCode, TableID) then
            DefaultDimensionPriority.Delete();

        DefaultDimensionPriority.Init();
        DefaultDimensionPriority."Source Code" := SourceCode;
        DefaultDimensionPriority."Table ID" := TableID;
        DefaultDimensionPriority.Priority := Priority;
        DefaultDimensionPriority.Insert();
    end;

    local procedure CreateDeferralTemplate(var DeferralTemplate: Record "Deferral Template")
    var
        GLAccount: Record "G/L Account";
    begin
        EnsureAccountingPeriodsExist();

        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.FindFirst();

        DeferralTemplate.Init();
        DeferralTemplate."Deferral Code" := 'MMSUBS' + Format(Random(1000));
        DeferralTemplate.Description := 'Test Deferral Template';
        DeferralTemplate."Deferral Account" := GLAccount."No.";
        DeferralTemplate."Calc. Method" := DeferralTemplate."Calc. Method"::"Straight-Line";
        DeferralTemplate."Start Date" := DeferralTemplate."Start Date"::"Posting Date";
        DeferralTemplate."No. of Periods" := 12;
        DeferralTemplate."Period Description" := 'Deferral %4';
        DeferralTemplate.Insert();
    end;

    local procedure EnsureAccountingPeriodsExist()
    var
        AccountingPeriod: Record "Accounting Period";
        StartDate: Date;
        i: Integer;
    begin
        AccountingPeriod.SetFilter("Starting Date", '>=%1', WorkDate());
        if AccountingPeriod.Count() >= 13 then
            exit;

        StartDate := CalcDate('<-CY>', WorkDate());
        for i := 0 to 24 do begin
            AccountingPeriod.Init();
            AccountingPeriod."Starting Date" := CalcDate('<' + Format(i) + 'M>', StartDate);
            AccountingPeriod."New Fiscal Year" := (i mod 12 = 0);
            if AccountingPeriod.Insert() then;
        end;
    end;

    local procedure SetupAdyenPaymentGateway(): Code[20]
    var
        SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
        PaymentAccountNo: Code[20];
    begin
        PaymentAccountNo := LibraryERM.CreateGLAccountWithSalesSetup();

        if not SubsPaymentGateway.Get('ADYEN-TEST') then begin
            SubsPaymentGateway.Init();
            SubsPaymentGateway.Code := 'ADYEN-TEST';
            SubsPaymentGateway.Description := 'Test Adyen Gateway';
            SubsPaymentGateway."Integration Type" := SubsPaymentGateway."Integration Type"::Adyen;
            SubsPaymentGateway.Status := SubsPaymentGateway.Status::Enabled;
            SubsPaymentGateway.Insert();
        end;

        if not SubsAdyenPGSetup.Get('ADYEN-TEST') then begin
            SubsAdyenPGSetup.Init();
            SubsAdyenPGSetup.Code := 'ADYEN-TEST';
            SubsAdyenPGSetup."Payment Account Type" := SubsAdyenPGSetup."Payment Account Type"::"G/L Account";
            SubsAdyenPGSetup."Payment Account No." := PaymentAccountNo;
            SubsAdyenPGSetup.Environment := SubsAdyenPGSetup.Environment::Test;
            SubsAdyenPGSetup."Merchant Name" := 'TestMerchant';
            SubsAdyenPGSetup.Insert();
        end else begin
            SubsAdyenPGSetup."Payment Account No." := PaymentAccountNo;
            SubsAdyenPGSetup.Modify();
        end;

        exit(PaymentAccountNo);
    end;

    local procedure CreateCapturedPaymentRequest(SubscriptionRequest: Record "NPR MM Subscr. Request"; var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    begin
        SubscrPaymentRequest.Init();
        SubscrPaymentRequest."Subscr. Request Entry No." := SubscriptionRequest."Entry No.";
        SubscrPaymentRequest.Type := SubscrPaymentRequest.Type::Payment;
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::Captured;
        SubscrPaymentRequest.PSP := SubscrPaymentRequest.PSP::Adyen;
        SubscrPaymentRequest.Amount := SubscriptionRequest.Amount;
        SubscrPaymentRequest."Currency Code" := SubscriptionRequest."Currency Code";
        SubscrPaymentRequest.Insert();
    end;

    local procedure PostPaymentRequest(SubscriptionRequest: Record "NPR MM Subscr. Request")
    var
        SubscrRenewPost: Codeunit "NPR MM Subscr. Renew: Post";
    begin
        SubscrRenewPost.PostPaymentsToGL(SubscriptionRequest, SubscriptionRequest."Posting Document No.");
    end;
}

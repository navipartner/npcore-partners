#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85171 "NPR MM Subscription Audit Test"
{
    Subtype = Test;

    var
        _IsInitialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InitialSale_CreatesSubscriptionRequestAndPaymentRequest()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SaleAmount: Decimal;
    begin
        // [SCENARIO] Happy path - CreateInitialSaleSubscriptionRequest creates both subscription request and payment request with correct field values.
        Initialize();
        SaleAmount := 299.00;

        // [GIVEN] A membership with subscription (Auto-Renew = YES_INTERNAL), member payment method, and EFT transaction
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::YES_INTERNAL);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEFTTransactionRequest(EFTTransactionRequest, SaleAmount, false);

        // [WHEN] CreateInitialSaleSubscriptionRequest is called
        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, SaleAmount);

        // [THEN] A subscription request of type Initial Sale is created with correct fields
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'Initial Sale subscription request should exist.');
        Assert.AreEqual(SubscriptionRequest.Status::Confirmed, SubscriptionRequest.Status, 'Status should be Confirmed.');
        Assert.AreEqual(SubscriptionRequest."Processing Status"::Success, SubscriptionRequest."Processing Status", 'Processing Status should be Success.');
        Assert.AreEqual(SaleAmount, SubscriptionRequest.Amount, 'Amount should match sale amount.');
        Assert.AreEqual(MembershipEntry."Valid From Date", SubscriptionRequest."New Valid From Date", 'Valid From Date should match membership entry.');
        Assert.AreEqual(MembershipEntry."Valid Until Date", SubscriptionRequest."New Valid Until Date", 'Valid Until Date should match membership entry.');
        Assert.AreEqual(MembershipEntry."Entry No.", SubscriptionRequest."Posted M/ship Ledg. Entry No.", 'Posted membership entry no. should match.');
        Assert.AreEqual(Subscription."Membership Code", SubscriptionRequest."Membership Code", 'Membership Code should match subscription.');

        // [THEN] A subscription payment request is created with correct fields
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscrPaymentRequest.FindFirst(), 'Subscription payment request should exist.');
        Assert.AreEqual(SubscrPaymentRequest.Type::Payment, SubscrPaymentRequest.Type, 'Payment request type should be Payment.');
        Assert.AreEqual(SubscrPaymentRequest.Status::Captured, SubscrPaymentRequest.Status, 'Payment request status should be Captured.');
        Assert.AreEqual(EFTTransactionRequest."Result Amount", SubscrPaymentRequest.Amount, 'Payment request amount should match EFT result amount.');
        Assert.AreEqual(EFTTransactionRequest."PSP Reference", SubscrPaymentRequest."PSP Reference", 'PSP Reference should match EFT transaction.');
        Assert.AreEqual(MemberPaymentMethod."Payment Token", SubscrPaymentRequest."Payment Token", 'Payment Token should match member payment method.');
        Assert.AreEqual(MemberPaymentMethod."PAN Last 4 Digits", SubscrPaymentRequest."PAN Last 4 Digits", 'PAN Last 4 Digits should match member payment method.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InitialSale_SkipsWhenAmountIsZero()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] Zero amount exits silently (tokenization-only scenario).
        Initialize();

        // [GIVEN] A valid setup but with zero EFT amount
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::YES_INTERNAL);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEFTTransactionRequest(EFTTransactionRequest, 0, false);

        // [WHEN] CreateInitialSaleSubscriptionRequest is called with zero amount
        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, 0);

        // [THEN] No Initial Sale subscription request is created
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.IsTrue(SubscriptionRequest.IsEmpty(), 'No Initial Sale subscription request should be created for zero amount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InitialSale_SkipsWhenAutoRenewNotInternal()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SaleAmount: Decimal;
    begin
        // [SCENARIO] Only YES_INTERNAL auto-renew triggers creation; NO should skip.
        Initialize();
        SaleAmount := 299.00;

        // [GIVEN] A subscription with Auto-Renew = NO
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEFTTransactionRequest(EFTTransactionRequest, SaleAmount, false);

        // [WHEN] CreateInitialSaleSubscriptionRequest is called
        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, SaleAmount);

        // [THEN] No Initial Sale subscription request is created
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.IsTrue(SubscriptionRequest.IsEmpty(), 'No Initial Sale subscription request should be created when Auto-Renew is not YES_INTERNAL.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InitialSale_SkipsWhenManualCapture()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SaleAmount: Decimal;
    begin
        // [SCENARIO] Manual capture payments are skipped.
        Initialize();
        SaleAmount := 299.00;

        // [GIVEN] An EFT transaction with Manual Capture = true
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::YES_INTERNAL);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEFTTransactionRequest(EFTTransactionRequest, SaleAmount, true);

        // [WHEN] CreateInitialSaleSubscriptionRequest is called
        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, SaleAmount);

        // [THEN] No Initial Sale subscription request is created
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.IsTrue(SubscriptionRequest.IsEmpty(), 'No Initial Sale subscription request should be created for Manual Capture.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InitialSale_IdempotentWhenCalledTwice()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SaleAmount: Decimal;
    begin
        // [SCENARIO] Calling twice does not create duplicate subscription requests (idempotency guard).
        Initialize();
        SaleAmount := 299.00;

        // [GIVEN] A valid setup for initial sale subscription request
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::YES_INTERNAL);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEFTTransactionRequest(EFTTransactionRequest, SaleAmount, false);

        // [WHEN] CreateInitialSaleSubscriptionRequest is called twice
        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, SaleAmount);
        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, SaleAmount);

        // [THEN] Exactly 1 Initial Sale subscription request exists (not 2)
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.AreEqual(1, SubscriptionRequest.Count(), 'Exactly 1 Initial Sale subscription request should exist after calling twice.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InitialSale_RenewalJobQueueIgnoresInitialSale()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        RenewProcess: Codeunit "NPR MM Subs Try Renew Process";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SaleAmount: Decimal;
        OriginalProcessingStatus: Enum "NPR MM Subs Req Proc Status";
    begin
        // [SCENARIO] The renewal job queue processor does not pick up Initial Sale requests - it has no handler for this type.
        Initialize();
        SaleAmount := 299.00;

        // [GIVEN] An Initial Sale subscription request exists
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::YES_INTERNAL);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEFTTransactionRequest(EFTTransactionRequest, SaleAmount, false);

        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, SaleAmount);

        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        SubscriptionRequest.FindFirst();
        OriginalProcessingStatus := SubscriptionRequest."Processing Status";

        // [WHEN] ProcessConfirmedStatus is called on the Initial Sale subscription request
        RenewProcess.ProcessConfirmedStatus(SubscriptionRequest);

        // [THEN] The subscription request is unchanged (ProcessConfirmedStatus has no handler for Initial Sale)
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        Assert.AreEqual(OriginalProcessingStatus, SubscriptionRequest."Processing Status", 'Processing Status should remain unchanged after ProcessConfirmedStatus.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TerminationPage_FindsInitialSaleForRefund()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SaleAmount: Decimal;
    begin
        // [SCENARIO] The termination page filter finds Initial Sale records for refund (not just Renew).
        Initialize();
        SaleAmount := 299.00;

        // [GIVEN] Only an Initial Sale subscription request exists (no Renew records)
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::YES_INTERNAL);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEFTTransactionRequest(EFTTransactionRequest, SaleAmount, false);

        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, SaleAmount);

        // [WHEN] We filter subscription requests the same way the termination page does
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetFilter(Type, '%1|%2', SubscriptionRequest.Type::Renew, SubscriptionRequest.Type::"Initial Sale");
        SubscriptionRequest.SetRange("Processing Status", SubscriptionRequest."Processing Status"::Success);
        SubscriptionRequest.SetRange(Reversed, false);

        // [THEN] The Initial Sale record is found (filter includes Initial Sale alongside Renew)
        Assert.IsFalse(SubscriptionRequest.IsEmpty(), 'Initial Sale subscription request should be found by termination page filter.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure TerminationPage_MismatchGuardBlocksRefundWhenEntryChanged()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipEntry2: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SaleAmount: Decimal;
        LastActiveEntry: Record "NPR MM Membership Entry";
    begin
        // [SCENARIO] Mismatch guard detects when membership entry no longer matches the last subscription payment.
        Initialize();
        SaleAmount := 299.00;

        // [GIVEN] An Initial Sale subscription request pointing to membership entry X
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::YES_INTERNAL);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEFTTransactionRequest(EFTTransactionRequest, SaleAmount, false);

        SubscriptionMgtImpl.CreateInitialSaleSubscriptionRequest(Subscription, MembershipEntry, MemberPaymentMethod, EFTTransactionRequest, SaleAmount);

        // Get the subscription request for the mismatch check
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        SubscriptionRequest.FindFirst();

        // [GIVEN] A new membership entry is created (simulating a return/void/regret that changed the active entry)
        MembershipEntry2.Init();
        MembershipEntry2."Entry No." := 0;
        MembershipEntry2."Membership Entry No." := Membership."Entry No.";
        MembershipEntry2."Valid From Date" := MembershipEntry."Valid From Date";
        MembershipEntry2."Valid Until Date" := MembershipEntry."Valid Until Date";
        MembershipEntry2.Blocked := false;
        MembershipEntry2.Context := MembershipEntry2.Context::NEW;
        MembershipEntry2.Insert(true);

        // [WHEN] We check if the last active membership entry matches the subscription request's posted entry
        // (Replicating MembershipEntryMatchesLastSubscriptionPayment logic from MMSubsRequestTermination.Page.al)
        LastActiveEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        LastActiveEntry.SetRange(Blocked, false);
        LastActiveEntry.SetFilter(Context, '<>%1', LastActiveEntry.Context::REGRET);
        LastActiveEntry.FindLast();

        // [THEN] The last active entry no. does NOT match the subscription request's posted entry no. (mismatch detected)
        Assert.AreNotEqual(
            SubscriptionRequest."Posted M/ship Ledg. Entry No.",
            LastActiveEntry."Entry No.",
            'Last active membership entry should not match subscription request posted entry (mismatch guard).');
    end;

    // === Cancellation Integration Test ===

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_Integration_CancelMembershipCreatesPartialRegret()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OutStartDate: Date;
        OutUntilDate: Date;
        SuggestedUnitPrice: Decimal;
        ReasonText: Text;
        CancelItemNo: Code[20];
    begin
        // [SCENARIO] Calling CancelMembership end-to-end creates a Partial Regret subscription request
        // when the subscription has Auto-Renew = YES_INTERNAL.
        Initialize();

        // [GIVEN] A membership with subscription (Auto-Renew = YES_INTERNAL) and a CANCEL alteration setup
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        Assert.IsTrue(SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription), 'Subscription should exist after membership creation.');
        Subscription."Auto-Renew" := Subscription."Auto-Renew"::YES_INTERNAL;
        Subscription.Modify(true);
        CancelItemNo := CreateCancelItem(MemberLibrary, Membership."Membership Code");

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::CANCEL;
        MemberInfoCapture."Item No." := CancelItemNo;
        MemberInfoCapture."Unit Price" := -150.00;
        MemberInfoCapture."Document Date" := CalcDate('<+7D>');
        MemberInfoCapture."Receipt No." := 'TEST-RECEIPT-INT';
        MemberInfoCapture.Insert(true);

        // [WHEN] CancelMembership is called (the real entry point, not the internal procedure)
        Assert.IsTrue(
            MembershipMgtInternal.CancelMembershipVerbose(MemberInfoCapture, false, true, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText),
            StrSubstNo('CancelMembership should return true. Reason: %1', ReasonText));

        // [THEN] A Partial Regret subscription request is created
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        Assert.IsTrue(SubscriptionRequest.FindFirst(), StrSubstNo('Partial Regret should exist. Subscription Entry No.: %1', Subscription."Entry No."));
        Assert.AreEqual(SubscriptionRequest."Processing Status"::Success, SubscriptionRequest."Processing Status", 'Processing Status should be Success.');
        Assert.AreEqual(MembershipEntry."Entry No.", SubscriptionRequest."Membership Entry To Cancel", 'Membership Entry To Cancel should match.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_Integration_SkipsWhenAutoRenewIsNo()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        MemberLibrary: Codeunit "NPR Library - Member Module";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OutStartDate: Date;
        OutUntilDate: Date;
        SuggestedUnitPrice: Decimal;
        ReasonText: Text;
        CancelItemNo: Code[20];
    begin
        // [SCENARIO] CancelMembership does NOT create a Partial Regret when subscription Auto-Renew = NO.
        Initialize();

        // [GIVEN] A membership with subscription (Auto-Renew = NO) and a CANCEL alteration setup
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription);
        CancelItemNo := CreateCancelItem(MemberLibrary, Membership."Membership Code");

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::CANCEL;
        MemberInfoCapture."Item No." := CancelItemNo;
        MemberInfoCapture."Unit Price" := -150.00;
        MemberInfoCapture."Document Date" := CalcDate('<+7D>');
        MemberInfoCapture."Receipt No." := 'TEST-RECEIPT-INT2';
        MemberInfoCapture.Insert(true);

        // [WHEN] CancelMembership is called
        Assert.IsTrue(
            MembershipMgtInternal.CancelMembershipVerbose(MemberInfoCapture, false, true, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText),
            StrSubstNo('CancelMembership should return true. Reason: %1', ReasonText));

        // [THEN] No Partial Regret subscription request exists (Auto-Renew guard blocks it)
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        Assert.IsTrue(SubscriptionRequest.IsEmpty(), 'No Partial Regret should be created when Auto-Renew = NO.');
    end;

    // === Cancellation Unit Tests ===

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_CreatesPartialRegretRequest()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        CancellationAmount: Decimal;
        CancellationDate: Date;
        NewValidUntilDate: Date;
    begin
        // [SCENARIO] Happy path - CreateCancellationSubscriptionRequest creates a Partial Regret with correct fields.
        Initialize();
        CancellationAmount := -150.00;
        CancellationDate := CalcDate('<+7D>');
        NewValidUntilDate := CalcDate('<+30D>');

        // [GIVEN] A membership with subscription and a CANCEL MemberInfoCapture
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", CancellationAmount, CancellationDate);

        // [WHEN] CreateCancellationSubscriptionRequest is called
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, 'TEST-RECEIPT-001', NewValidUntilDate);

        // [THEN] A Partial Regret subscription request is created with correct fields
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'Partial Regret subscription request should exist.');
        Assert.AreEqual(SubscriptionRequest.Status::Confirmed, SubscriptionRequest.Status, 'Status should be Confirmed.');
        Assert.AreEqual(SubscriptionRequest."Processing Status"::Success, SubscriptionRequest."Processing Status", 'Processing Status should be Success.');
        Assert.AreEqual(CancellationAmount, SubscriptionRequest.Amount, 'Amount should match cancellation amount.');
        Assert.AreEqual(MembershipEntry."Valid From Date", SubscriptionRequest."New Valid From Date", 'Valid From Date should match membership entry.');
        Assert.AreEqual(NewValidUntilDate, SubscriptionRequest."New Valid Until Date", 'Valid Until Date should match the NewValidUntilDate parameter, not Document Date.');
        Assert.AreEqual(MembershipEntry."Entry No.", SubscriptionRequest."Membership Entry To Cancel", 'Membership Entry To Cancel should match.');
        Assert.AreEqual(Subscription."Membership Code", SubscriptionRequest."Membership Code", 'Membership Code should match.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_ReversesConnectedInitialSale()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        OriginalRequest: Record "NPR MM Subscr. Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] Existing Initial Sale request gets Reversed=true, "Reversed by" points to Partial Regret.
        Initialize();

        // [GIVEN] A membership with subscription and an Initial Sale subscription request
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateOriginalSubscriptionRequest(OriginalRequest, Subscription, MembershipEntry, OriginalRequest.Type::"Initial Sale");
        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", -150.00, CalcDate('<+7D>'));

        // [WHEN] CreateCancellationSubscriptionRequest is called
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, 'TEST-RECEIPT-002', CalcDate('<+7D>'));

        // [THEN] The Initial Sale request is reversed pointing to the Partial Regret
        OriginalRequest.Get(OriginalRequest."Entry No.");
        Assert.IsTrue(OriginalRequest.Reversed, 'Initial Sale should be reversed.');

        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        SubscriptionRequest.FindFirst();
        Assert.AreEqual(SubscriptionRequest."Entry No.", OriginalRequest."Reversed by Entry No.", 'Reversed by should point to Partial Regret.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_ReversesConnectedRenew()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        OriginalRequest: Record "NPR MM Subscr. Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] Existing Renew request gets Reversed=true, "Reversed by" points to Partial Regret.
        Initialize();

        // [GIVEN] A membership with subscription and a Renew subscription request
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateOriginalSubscriptionRequest(OriginalRequest, Subscription, MembershipEntry, OriginalRequest.Type::Renew);
        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", -150.00, CalcDate('<+7D>'));

        // [WHEN] CreateCancellationSubscriptionRequest is called
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, 'TEST-RECEIPT-003', CalcDate('<+7D>'));

        // [THEN] The Renew request is reversed
        OriginalRequest.Get(OriginalRequest."Entry No.");
        Assert.IsTrue(OriginalRequest.Reversed, 'Renew should be reversed.');

        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        SubscriptionRequest.FindFirst();
        Assert.AreEqual(SubscriptionRequest."Entry No.", OriginalRequest."Reversed by Entry No.", 'Reversed by should point to Partial Regret.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_NoReversalWhenNoConnectedRequest()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] No prior request = Partial Regret still created, nothing reversed.
        Initialize();

        // [GIVEN] A membership with subscription but NO prior Initial Sale or Renew request
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", -150.00, CalcDate('<+7D>'));

        // [WHEN] CreateCancellationSubscriptionRequest is called
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, 'TEST-RECEIPT-004', CalcDate('<+7D>'));

        // [THEN] Partial Regret is still created
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'Partial Regret should exist even without prior request.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_NoReversalWhenAlreadyReversed()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        OriginalRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        OriginalReversedByEntryNo: BigInteger;
    begin
        // [SCENARIO] Already-reversed request is not overwritten.
        Initialize();

        // [GIVEN] A membership with subscription and an already-reversed Initial Sale request
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateOriginalSubscriptionRequest(OriginalRequest, Subscription, MembershipEntry, OriginalRequest.Type::"Initial Sale");

        // Mark as already reversed
        OriginalRequest.Reversed := true;
        OriginalRequest."Reversed by Entry No." := 99999;
        OriginalRequest.Modify();
        OriginalReversedByEntryNo := OriginalRequest."Reversed by Entry No.";

        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", -150.00, CalcDate('<+7D>'));

        // [WHEN] CreateCancellationSubscriptionRequest is called
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, 'TEST-RECEIPT-005', CalcDate('<+7D>'));

        // [THEN] The already-reversed request is NOT overwritten
        OriginalRequest.Get(OriginalRequest."Entry No.");
        Assert.AreEqual(OriginalReversedByEntryNo, OriginalRequest."Reversed by Entry No.", 'Reversed by Entry No. should not be overwritten.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_CreatesRefundPaymentForAdyenCard()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSaleLine: Record "NPR POS Sale Line";
        OriginalRequest: Record "NPR MM Subscr. Request";
        OriginalPmtRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SalesTicketNo: Code[20];
    begin
        // [SCENARIO] Single Adyen EFT refund creates Refund payment request AND reverses original payment request.
        Initialize();
        SalesTicketNo := 'TEST-RECEIPT-006';

        // [GIVEN] A membership with subscription, payment method, Initial Sale + payment request, single Adyen EFT refund, single payment line
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateOriginalSubscriptionRequest(OriginalRequest, Subscription, MembershipEntry, OriginalRequest.Type::"Initial Sale");
        CreateOriginalPaymentRequest(OriginalPmtRequest, OriginalRequest);
        CreateAdyenRefundEFTTransaction(EFTTransactionRequest, SalesTicketNo, -150.00);
        CreatePOSPaymentSaleLine(POSSaleLine, SalesTicketNo);
        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", -150.00, CalcDate('<+7D>'));

        // [WHEN] CreateCancellationSubscriptionRequest is called
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, SalesTicketNo, CalcDate('<+7D>'));

        // [THEN] A Refund payment request is created
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        SubscriptionRequest.FindFirst();

        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscrPaymentRequest.FindFirst(), 'Refund payment request should exist.');
        Assert.AreEqual(SubscrPaymentRequest.Type::Refund, SubscrPaymentRequest.Type, 'Payment request type should be Refund.');
        Assert.AreEqual(SubscrPaymentRequest.Status::Captured, SubscrPaymentRequest.Status, 'Payment request status should be Captured.');
        Assert.AreEqual(EFTTransactionRequest."Result Amount", SubscrPaymentRequest.Amount, 'Amount should match EFT result amount.');
        Assert.AreEqual(EFTTransactionRequest."PSP Reference", SubscrPaymentRequest."PSP Reference", 'PSP Reference should match.');
        Assert.AreEqual(MemberPaymentMethod."Payment Token", SubscrPaymentRequest."Payment Token", 'Payment Token should match.');

        // [THEN] The original payment request is also reversed pointing to the refund payment request
        OriginalPmtRequest.Get(OriginalPmtRequest."Entry No.");
        Assert.IsTrue(OriginalPmtRequest.Reversed, 'Original payment request should be reversed.');
        Assert.AreEqual(SubscrPaymentRequest."Entry No.", OriginalPmtRequest."Reversed by Entry No.", 'Original payment reversed by should point to refund payment request.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_NoRefundPaymentForCash()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] No EFT transaction (cash return) = no refund payment request, but Partial Regret still created.
        Initialize();

        // [GIVEN] A membership with subscription but NO EFT transaction (cash return)
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", -150.00, CalcDate('<+7D>'));

        // [WHEN] CreateCancellationSubscriptionRequest is called (no EFT, no payment lines setup)
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, 'TEST-RECEIPT-007', CalcDate('<+7D>'));

        // [THEN] Partial Regret exists but no refund payment request
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'Partial Regret should exist.');

        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscrPaymentRequest.IsEmpty(), 'No refund payment request should exist for cash return.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_NoRefundPaymentForSplitTender()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSaleLine: Record "NPR POS Sale Line";
        POSSaleLine2: Record "NPR POS Sale Line";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SalesTicketNo: Code[20];
    begin
        // [SCENARIO] Split tender (card + cash) = no refund payment request even though a valid Adyen EFT exists.
        Initialize();
        SalesTicketNo := 'TEST-RECEIPT-009';

        // [GIVEN] A membership with subscription, payment method, Adyen EFT refund, but TWO payment lines (split tender)
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateAdyenRefundEFTTransaction(EFTTransactionRequest, SalesTicketNo, -100.00);
        CreatePOSPaymentSaleLine(POSSaleLine, SalesTicketNo);

        // Add second payment line (cash portion of split tender)
        POSSaleLine2.Init();
        POSSaleLine2."Sales Ticket No." := SalesTicketNo;
        POSSaleLine2."Line No." := 20000;
        POSSaleLine2."Line Type" := POSSaleLine2."Line Type"::"POS Payment";
        POSSaleLine2.Insert(true);

        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", -150.00, CalcDate('<+7D>'));

        // [WHEN] CreateCancellationSubscriptionRequest is called
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, SalesTicketNo, CalcDate('<+7D>'));

        // [THEN] Partial Regret exists but no refund payment request (split tender blocks it)
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'Partial Regret should exist.');

        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", SubscriptionRequest."Entry No.");
        Assert.IsTrue(SubscrPaymentRequest.IsEmpty(), 'No refund payment request should exist for split tender.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure Cancellation_IdempotentWhenCalledTwice()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] Calling twice does not create duplicate Partial Regret requests.
        Initialize();

        // [GIVEN] A membership with subscription
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        CreateSubscription(Subscription, Membership, MembershipEntry, Subscription."Auto-Renew"::NO);
        CreateCancelMemberInfoCapture(MemberInfoCapture, Membership."Entry No.", -150.00, CalcDate('<+7D>'));

        // [WHEN] Called twice
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, 'TEST-RECEIPT-008', CalcDate('<+7D>'));
        SubscriptionMgtImpl.CreateCancellationSubscriptionRequest(Subscription, MembershipEntry, MemberInfoCapture, 'TEST-RECEIPT-008', CalcDate('<+7D>'));

        // [THEN] Exactly 1 Partial Regret exists
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Partial Regret");
        Assert.AreEqual(1, SubscriptionRequest.Count(), 'Exactly 1 Partial Regret should exist after calling twice.');
    end;

    // === Helper Procedures ===

    local procedure Initialize()
    var
        MemberLibrary: Codeunit "NPR Library - Member Module";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
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

    local procedure CreateSubscription(var Subscription: Record "NPR MM Subscription"; Membership: Record "NPR MM Membership"; MembershipEntry: Record "NPR MM Membership Entry"; AutoRenew: Enum "NPR MM MembershipAutoRenew")
    begin
        Subscription.Init();
        Subscription."Entry No." := 0;
        Subscription."Membership Entry No." := Membership."Entry No.";
        Subscription."Membership Ledger Entry No." := MembershipEntry."Entry No.";
        Subscription."Membership Code" := Membership."Membership Code";
        Subscription."Valid From Date" := MembershipEntry."Valid From Date";
        Subscription."Valid Until Date" := MembershipEntry."Valid Until Date";
        Subscription."Auto-Renew" := AutoRenew;
        Subscription."Started At" := CurrentDateTime();
        Subscription.Insert(true);
    end;

    local procedure CreateMemberPaymentMethod(var MemberPaymentMethod: Record "NPR MM Member Payment Method")
    begin
        MemberPaymentMethod.Init();
        MemberPaymentMethod."Entry No." := 0;
        MemberPaymentMethod.PSP := MemberPaymentMethod.PSP::Adyen;
        MemberPaymentMethod.Status := MemberPaymentMethod.Status::Active;
        MemberPaymentMethod."Payment Token" := 'TEST-TOKEN-' + Format(CreateGuid());
        MemberPaymentMethod."PAN Last 4 Digits" := '4242';
        MemberPaymentMethod."Masked PAN" := '************4242';
        MemberPaymentMethod.Insert(true);
    end;

    local procedure CreateMembershipPmtMethodMap(var MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap"; MemberPaymentMethod: Record "NPR MM Member Payment Method"; Membership: Record "NPR MM Membership")
    begin
        MembershipPmtMethodMap.Init();
        MembershipPmtMethodMap.PaymentMethodId := MemberPaymentMethod.SystemId;
        MembershipPmtMethodMap.MembershipId := Membership.SystemId;
        MembershipPmtMethodMap.Status := MembershipPmtMethodMap.Status::Active;
        MembershipPmtMethodMap.Default := true;
        MembershipPmtMethodMap.Insert(true);
    end;

    local procedure CreateEFTTransactionRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; Amount: Decimal; ManualCapture: Boolean)
    begin
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Entry No." := 0;
        EFTTransactionRequest."Result Amount" := Amount;
        EFTTransactionRequest."PSP Reference" := CopyStr('PSP-' + Format(CreateGuid()), 1, 16);
        EFTTransactionRequest."Currency Code" := '';
        EFTTransactionRequest."Manual Capture" := ManualCapture;
        EFTTransactionRequest.Insert(true);
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

    local procedure CreateCancelMemberInfoCapture(var MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntryNo: Integer; UnitPrice: Decimal; DocumentDate: Date)
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::CANCEL;
        MemberInfoCapture."Unit Price" := UnitPrice;
        MemberInfoCapture."Document Date" := DocumentDate;
        MemberInfoCapture.Insert(true);
    end;

    local procedure CreateCancelItem(MemberLibrary: Codeunit "NPR Library - Member Module"; MembershipCode: Code[20]): Code[20]
    var
        ItemNo: Code[20];
    begin
        ItemNo := MemberLibrary.CreateItem('T-320100-CANCEL', '', 'Cancel GOLD Membership', 0);
        MemberLibrary.SetupCancel_NoGrace(MembershipCode, ItemNo, '', 'Cancel GOLD Membership');
        exit(ItemNo);
    end;

    local procedure CreateOriginalSubscriptionRequest(var SubscriptionRequest: Record "NPR MM Subscr. Request"; Subscription: Record "NPR MM Subscription"; MembershipEntry: Record "NPR MM Membership Entry"; RequestType: Enum "NPR MM Subscr. Request Type")
    begin
        SubscriptionRequest.Init();
        SubscriptionRequest."Entry No." := 0;
        SubscriptionRequest.Type := RequestType;
        SubscriptionRequest.Status := SubscriptionRequest.Status::Confirmed;
        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
        SubscriptionRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscriptionRequest."Membership Code" := Subscription."Membership Code";
        SubscriptionRequest."Posted M/ship Ledg. Entry No." := MembershipEntry."Entry No.";
        SubscriptionRequest."New Valid From Date" := MembershipEntry."Valid From Date";
        SubscriptionRequest."New Valid Until Date" := MembershipEntry."Valid Until Date";
        SubscriptionRequest.Amount := 299.00;
        SubscriptionRequest.Insert(true);
    end;

    local procedure CreateOriginalPaymentRequest(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SubscriptionRequest: Record "NPR MM Subscr. Request")
    begin
        SubscrPaymentRequest.Init();
        SubscrPaymentRequest."Entry No." := 0;
        SubscrPaymentRequest.Type := SubscrPaymentRequest.Type::Payment;
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::Captured;
        SubscrPaymentRequest."Subscr. Request Entry No." := SubscriptionRequest."Entry No.";
        SubscrPaymentRequest.Amount := SubscriptionRequest.Amount;
        SubscrPaymentRequest.Insert(true);
    end;

    local procedure CreateAdyenRefundEFTTransaction(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; SalesTicketNo: Code[20]; Amount: Decimal)
    begin
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Entry No." := 0;
        EFTTransactionRequest."Sales Ticket No." := SalesTicketNo;
        EFTTransactionRequest."Result Amount" := Amount;
        EFTTransactionRequest."PSP Reference" := CopyStr('PSP-' + Format(CreateGuid()), 1, 16);
        EFTTransactionRequest."Currency Code" := '';
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::REFUND;
        EFTTransactionRequest."Recurring Detail Reference" := 'RECURRING-REF-001';
        EFTTransactionRequest."Integration Type" := 'ADYEN_CLOUD';
        EFTTransactionRequest.Insert(true);
    end;

    local procedure CreatePOSPaymentSaleLine(var POSSaleLine: Record "NPR POS Sale Line"; SalesTicketNo: Code[20])
    begin
        POSSaleLine.Init();
        POSSaleLine."Sales Ticket No." := SalesTicketNo;
        POSSaleLine."Line No." := 10000;
        POSSaleLine."Line Type" := POSSaleLine."Line Type"::"POS Payment";
        POSSaleLine.Insert(true);
    end;
}
#endif
codeunit 85183 "NPR TM TicketDeferRevenueTest"
{
    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSSession: Codeunit "NPR POS Session";
        _POSSetup: Record "NPR POS Setup";
        _POSStore: Record "NPR POS Store";
        _POSUnit: Record "NPR POS Unit";
        _POSPaymentMethodCash: Record "NPR POS Payment Method";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IndividualTicket_Qty1_DefersFullAmount()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        ExpectedAmountExVat: Decimal;
        ActualSumExVat: Decimal;
        SalesReceiptNo: Code[20];
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 1);
        TriggerDeferral();

        ExpectedAmountExVat := SalesAmountForSalesReceipt(SalesReceiptNo);
        ActualSumExVat := SumAmountToDeferForSalesReceipt(SalesReceiptNo);

        AssertDeferralForReceipt(SalesReceiptNo, 1, ExpectedAmountExVat, 'INDIVIDUAL qty=1');
        Assert.AreNearlyEqual(ExpectedAmountExVat, ActualSumExVat, 0.01, 'Deferred amount should equal full sale amount for INDIVIDUAL ticket (qty=1).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure IndividualTicket_QtyN_DefersFullAmount()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        ExpectedAmountExVat: Decimal;
        ActualSumExVat: Decimal;
        SalesReceiptNo: Code[20];
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 5);
        TriggerDeferral();

        ExpectedAmountExVat := SalesAmountForSalesReceipt(SalesReceiptNo);
        ActualSumExVat := SumAmountToDeferForSalesReceipt(SalesReceiptNo);

        AssertDeferralForReceipt(SalesReceiptNo, 5, ExpectedAmountExVat, 'INDIVIDUAL qty=5');
        Assert.AreNearlyEqual(ExpectedAmountExVat, ActualSumExVat, 0.01, 'Deferred amount should equal full sale amount for INDIVIDUAL ticket (qty>1).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GroupTicket_Qty1_DefersFullAmount()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        ExpectedAmountExVat: Decimal;
        ActualSumExVat: Decimal;
        SalesReceiptNo: Code[20];
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        PatchToGroupTicket(Item, 7);

        SalesReceiptNo := SellAndPostTicket(Item, 1);
        TriggerDeferral();

        ExpectedAmountExVat := SalesAmountForSalesReceipt(SalesReceiptNo);
        ActualSumExVat := SumAmountToDeferForSalesReceipt(SalesReceiptNo);

        AssertDeferralForReceipt(SalesReceiptNo, 1, ExpectedAmountExVat, 'GROUP qty=1');
        Assert.AreNearlyEqual(ExpectedAmountExVat, ActualSumExVat, 0.01, 'Deferred amount should equal full sale amount for GROUP ticket (qty=1).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GroupTicket_QtyN_DefersFullAmount()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        ExpectedAmountExVat: Decimal;
        ActualSumExVat: Decimal;
        SalesReceiptNo: Code[20];
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        PatchToGroupTicket(Item, 7);
        SalesReceiptNo := SellAndPostTicket(Item, 5);
        TriggerDeferral();

        ExpectedAmountExVat := SalesAmountForSalesReceipt(SalesReceiptNo);
        ActualSumExVat := SumAmountToDeferForSalesReceipt(SalesReceiptNo);

        AssertDeferralForReceipt(SalesReceiptNo, 1, ExpectedAmountExVat, 'GROUP qty=5');
        Assert.AreNearlyEqual(ExpectedAmountExVat, ActualSumExVat, 0.01, 'Deferred amount should equal full sale amount for GROUP ticket (qty>1).');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GroupTicket_QtyN_AdmitAndDefer()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        ExpectedAmountExVat: Decimal;
        PostedAmount: Decimal;
        SalesReceiptNo: Code[20];
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        PatchToGroupTicket(Item, 7);
        SalesReceiptNo := SellAndPostTicket(Item, 5);
        TriggerDeferral();

        Assert.AreEqual(1, AdmitTicketsForSalesReceipt(SalesReceiptNo), 'Should have admitted 1 group ticket only.');
        TriggerDeferral();

        ExpectedAmountExVat := SalesAmountForSalesReceipt(SalesReceiptNo);
        PostedAmount := DeferralPostedAmountForSalesReceipt(SalesReceiptNo);

        AssertDeferralForReceipt(SalesReceiptNo, 1, ExpectedAmountExVat, 'GROUP qty=5 (admitted)');
        Assert.AreNearlyEqual(ExpectedAmountExVat, Abs(PostedAmount), 0.01, 'Posted deferral amount on achieved revenue account should equal full sale amount.');
    end;


    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AdmittedTicket_StatusReachesDeferred()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 7);
        TriggerDeferral();

        Assert.AreEqual(7, AdmitTicketsForSalesReceipt(SalesReceiptNo), 'Should have admitted 7 tickets.');
        TriggerDeferral();

        DeferRevenueRequest.SetFilter(SourceDocumentNo, '=%1', SalesReceiptNo);
        Assert.IsTrue(DeferRevenueRequest.FindFirst(), 'Deferral request should exist after sale.');

        Assert.AreEqual(DeferRevenueRequest.Status::DEFERRED, DeferRevenueRequest.Status, 'Status should be DEFERRED after admission and second batch run.');
        Assert.AreNotEqual(0D, DeferRevenueRequest.AchievedDate, 'AchievedDate should be set once admission has happened.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DeferredRequest_HasAllFieldsPopulated()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 1);
        TriggerDeferral();

        AdmitTicketsForSalesReceipt(SalesReceiptNo);
        TriggerDeferral();

        DeferRevenueRequest.SetFilter(SourceDocumentNo, '=%1', SalesReceiptNo);
        Assert.IsTrue(DeferRevenueRequest.FindFirst(), 'Deferral request should exist after sale.');

        Assert.AreNotEqual('', DeferRevenueRequest.TicketNo, 'TicketNo should be populated.');
        Assert.AreNotEqual('', DeferRevenueRequest.ItemNo, 'ItemNo should be populated.');
        Assert.AreNotEqual('', DeferRevenueRequest.AdmissionCode, 'AdmissionCode should be populated.');
        Assert.AreNotEqual('', DeferRevenueRequest.DeferRevenueProfileCode, 'DeferRevenueProfileCode should be populated.');
        Assert.AreNotEqual(0D, DeferRevenueRequest.SalesDate, 'SalesDate should be populated.');
        Assert.AreNotEqual(0D, DeferRevenueRequest.AchievedDate, 'AchievedDate should be populated after admission.');

        Assert.AreNotEqual('', DeferRevenueRequest.SourceDocumentNo, 'SourceDocumentNo should be populated.');
        Assert.AreNotEqual(0D, DeferRevenueRequest.SourcePostingDate, 'SourcePostingDate should be populated.');
        Assert.AreNotEqual(0, DeferRevenueRequest.ValueEntryNo, 'ValueEntryNo should be populated.');

        Assert.AreNotEqual('', DeferRevenueRequest.OriginalSalesAccount, 'OriginalSalesAccount should be populated.');
        Assert.AreNotEqual('', DeferRevenueRequest.AchievedRevenueAccount, 'AchievedRevenueAccount should be populated.');
        Assert.AreNotEqual('', DeferRevenueRequest.InterimAdjustmentAccount, 'InterimAdjustmentAccount should be populated.');

        Assert.AreNotEqual(0, DeferRevenueRequest.AmountToDefer, 'AmountToDefer should be non-zero.');
        Assert.AreNotEqual('', DeferRevenueRequest.DeferralDocumentNo, 'DeferralDocumentNo should be populated after posting.');
        Assert.AreNotEqual(0D, DeferRevenueRequest.DeferralPostingDate, 'DeferralPostingDate should be populated after posting.');
        Assert.AreNotEqual(0D, DeferRevenueRequest.DeferralDocumentDate, 'DeferralDocumentDate should be populated after posting.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure NonDeferringTicketType_NoRequestCreated()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        DisableDeferralForItem(Item);
        SellAndPostTicket(Item, 1);
        TriggerDeferral();

        DeferRevenueRequest.SetFilter(ItemNo, '=%1', Item."No.");
        Assert.RecordIsEmpty(DeferRevenueRequest);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelledTicket_DeferralIsAborted()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        TicketDeferral: Codeunit "NPR TM RevenueDeferral";
        TicketNo: Code[20];
    begin
        Initialize();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SellAndPostTicket(Item, 1);
        TriggerDeferral();

        DeferRevenueRequest.SetFilter(ItemNo, '=%1', Item."No.");
        Assert.IsTrue(DeferRevenueRequest.FindFirst(), 'Deferral request should exist after sale.');
        TicketNo := DeferRevenueRequest.TicketNo;

        TicketDeferral.AbortDeferral(TicketNo);

        DeferRevenueRequest.Find();
        Assert.AreEqual(DeferRevenueRequest.Status::DEFERRAL_ABORTED, DeferRevenueRequest.Status, 'Status should be DEFERRAL_ABORTED after cancellation.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaitingRequest_NotDue_IsSkipped()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
    begin
        // [SCENARIO] The batch leaves WAITING requests alone while their tickets are neither expired nor admitted
        Initialize();

        // [GIVEN] Three tickets sold on one receipt, their requests WAITING and valid for another 30 days
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 3);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNo, 3);
        SetRequestDatesForReceipt(SalesReceiptNo, Today() + 30, 0D);

        // [GIVEN] The reservation is unpaid, so re-processing a request would change it
        MakeReservationUnpaidForReceipt(SalesReceiptNo);

        // [WHEN] The deferral batch runs
        TriggerDeferral();

        // [THEN] Every request is still WAITING with no new register attempt and the original PaymentOption
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        Assert.AreEqual(3, DeferRevenueRequest.Count(), 'Deferral request count for the receipt.');
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreEqual(DeferRevenueRequest.Status::WAITING, DeferRevenueRequest.Status, 'Status should stay WAITING for a request that is not due.');
            Assert.AreEqual(0, DeferRevenueRequest.AttemptedRegisterCount, 'AttemptedRegisterCount should not change for a request that is not due.');
            Assert.AreEqual(DeferRevenueRequest.PaymentOption::DIRECT, DeferRevenueRequest.PaymentOption, 'PaymentOption should not be re-resolved for a request that is not due.');
        until (DeferRevenueRequest.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaitingRequest_ValidUntilToday_IsSkipped()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
    begin
        // [SCENARIO] A WAITING request whose ticket is valid until today is not due yet
        Initialize();

        // [GIVEN] A sold ticket whose request is WAITING
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 1);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNo, 1);

        // [GIVEN] The reservation is unpaid and the ticket is valid until today
        MakeReservationUnpaidForReceipt(SalesReceiptNo);
        SetRequestDatesForReceipt(SalesReceiptNo, Today(), 0D);

        // [WHEN] The deferral batch runs
        TriggerDeferral();

        // [THEN] The request is still WAITING with no new register attempt and the original PaymentOption
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindFirst();
        Assert.AreEqual(DeferRevenueRequest.Status::WAITING, DeferRevenueRequest.Status, 'Status should stay WAITING when TicketValidUntil is today.');
        Assert.AreEqual(0, DeferRevenueRequest.AttemptedRegisterCount, 'AttemptedRegisterCount should not change when TicketValidUntil is today.');
        Assert.AreEqual(DeferRevenueRequest.PaymentOption::DIRECT, DeferRevenueRequest.PaymentOption, 'PaymentOption should not be re-resolved when TicketValidUntil is today.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaitingRequest_ValidUntilYesterday_IsForcedDeferred()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        GLEntry: Record "G/L Entry";
        ExpectedAmountExVat: Decimal;
        PostedAmount: Decimal;
        SalesReceiptNo: Code[20];
    begin
        // [SCENARIO] A WAITING request whose ticket expired yesterday is force-deferred and posted on the expiry date
        Initialize();
        AllowAnyPostingDate();

        // [GIVEN] Three tickets sold on one receipt, their requests WAITING
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 3);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNo, 3);

        // [GIVEN] The tickets expired yesterday without admission
        SetRequestDatesForReceipt(SalesReceiptNo, Today() - 1, 0D);

        // [WHEN] The deferral batch runs
        TriggerDeferral();

        // [THEN] Every request is DEFERRED_FORCED with DeferralPostingDate = yesterday
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        Assert.AreEqual(3, DeferRevenueRequest.Count(), 'Deferral request count for the receipt.');
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreEqual(DeferRevenueRequest.Status::DEFERRED_FORCED, DeferRevenueRequest.Status, 'Status should be DEFERRED_FORCED for an expired ticket.');
            Assert.AreEqual(Today() - 1, DeferRevenueRequest.DeferralPostingDate, 'DeferralPostingDate should be the TicketValidUntil date.');
        until (DeferRevenueRequest.Next() = 0);

        // [THEN] The deferral is posted to the achieved revenue account on yesterday's date for the full sale amount
        GLEntry.SetFilter("G/L Account No.", '=%1', DeferRevenueRequest.AchievedRevenueAccount);
        GLEntry.SetFilter("Document No.", '=%1', DeferRevenueRequest.DeferralDocumentNo);
        GLEntry.SetFilter("Posting Date", '=%1', Today() - 1);
        Assert.RecordIsNotEmpty(GLEntry);
        GLEntry.FindSet();
        repeat
            PostedAmount += GLEntry.Amount;
        until (GLEntry.Next() = 0);

        ExpectedAmountExVat := SalesAmountForSalesReceipt(SalesReceiptNo);
        Assert.AreNearlyEqual(ExpectedAmountExVat, Abs(PostedAmount), 0.01, 'Posted deferral amount on the achieved revenue account should equal the full sale amount.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaitingRequest_BlankValidUntil_IsPromoted()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
    begin
        // [SCENARIO] A WAITING request without TicketValidUntil counts as expired and is promoted to PENDING_DEFERRAL
        Initialize();

        // [GIVEN] A sold ticket whose request is WAITING and has a blank TicketValidUntil
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 1);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNo, 1);
        SetRequestDatesForReceipt(SalesReceiptNo, 0D, 0D);

        // [WHEN] The deferral batch runs
        TriggerDeferral();

        // [THEN] The request is PENDING_DEFERRAL; with no date to defer to it is not posted
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindFirst();
        Assert.AreEqual(DeferRevenueRequest.Status::PENDING_DEFERRAL, DeferRevenueRequest.Status, 'Status should be PENDING_DEFERRAL when TicketValidUntil is blank.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaitingRequest_AchievedDateWithoutStatusChange_IsDeferred()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
    begin
        // [SCENARIO] A WAITING request with an AchievedDate is processed even though its ticket is still valid
        Initialize();

        // [GIVEN] A sold ticket whose request is WAITING, valid for another 30 days, with AchievedDate set but Status unchanged
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 1);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNo, 1);
        SetRequestDatesForReceipt(SalesReceiptNo, Today() + 30, Today());

        // [WHEN] The deferral batch runs
        TriggerDeferral();

        // [THEN] The request is DEFERRED
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindFirst();
        Assert.AreEqual(DeferRevenueRequest.Status::DEFERRED, DeferRevenueRequest.Status, 'Status should be DEFERRED when AchievedDate is set.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaitingRequest_DueByBothRules_CountedOnce()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
    begin
        // [SCENARIO] A WAITING request that is both expired and admitted is processed once per run
        Initialize();

        // [GIVEN] A sold ticket whose request is WAITING, expired yesterday and admitted yesterday
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 1);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNo, 1);
        SetRequestDatesForReceipt(SalesReceiptNo, Today() - 1, Today() - 1);

        // [GIVEN] The reservation is unpaid, so each processing adds one register attempt
        MakeReservationUnpaidForReceipt(SalesReceiptNo);

        // [WHEN] The deferral batch runs once
        TriggerDeferral();

        // [THEN] AttemptedRegisterCount went up by exactly one
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindFirst();
        Assert.AreEqual(1, DeferRevenueRequest.AttemptedRegisterCount, 'AttemptedRegisterCount should increase by one per batch run.');
        Assert.AreEqual(DeferRevenueRequest.PaymentOption::UNPAID, DeferRevenueRequest.PaymentOption, 'PaymentOption should be re-resolved to UNPAID.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RegisteredRequest_Unresolved_RetriedEveryRun()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
    begin
        // [SCENARIO] A REGISTERED request that cannot be resolved is attempted again on every run
        Initialize();

        // [GIVEN] Three tickets sold on one receipt, their requests REGISTERED and the reservation unpaid
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 3);
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        Assert.AreEqual(3, DeferRevenueRequest.Count(), 'Deferral request count for the receipt.');
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreEqual(DeferRevenueRequest.Status::REGISTERED, DeferRevenueRequest.Status, 'Precondition: Status should be REGISTERED after the sale.');
        until (DeferRevenueRequest.Next() = 0);
        MakeReservationUnpaidForReceipt(SalesReceiptNo);

        // [WHEN] The deferral batch runs twice
        TriggerDeferral();
        TriggerDeferral();

        // [THEN] Every request is still REGISTERED with AttemptedRegisterCount = 2 and PaymentOption UNPAID
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreEqual(DeferRevenueRequest.Status::REGISTERED, DeferRevenueRequest.Status, 'Status should stay REGISTERED for an unresolved request.');
            Assert.AreEqual(2, DeferRevenueRequest.AttemptedRegisterCount, 'AttemptedRegisterCount should increase on every batch run.');
            Assert.AreEqual(DeferRevenueRequest.PaymentOption::UNPAID, DeferRevenueRequest.PaymentOption, 'PaymentOption should be re-resolved to UNPAID.');
        until (DeferRevenueRequest.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaitingRequest_MixedDueInOneToken_OnlyDueRequestIsProcessed()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        SalesReceiptNo: Code[20];
        ExpiredTicketAccessEntryNo: Integer;
        TokenID: Text[100];
    begin
        // [SCENARIO] When one request of a token is due and the others are not, the batch processes only the due request
        Initialize();

        // [GIVEN] Three tickets sold on one receipt, their requests WAITING and valid for another 30 days
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 3);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNo, 3);
        SetRequestDatesForReceipt(SalesReceiptNo, Today() + 30, 0D);

        // [GIVEN] One of the requests expired yesterday
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindFirst();
        DeferRevenueRequest.TicketValidUntil := Today() - 1;
        DeferRevenueRequest.Modify();
        ExpiredTicketAccessEntryNo := DeferRevenueRequest.TicketAccessEntryNo;

        // [GIVEN] All three requests share the same non-blank TokenID
        TokenID := DeferRevenueRequest.TokenID;
        Assert.AreNotEqual('', TokenID, 'Precondition: TokenID should not be blank.');
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreEqual(TokenID, DeferRevenueRequest.TokenID, 'Precondition: every request of the receipt should have the same TokenID.');
        until (DeferRevenueRequest.Next() = 0);

        // [GIVEN] The reservation is unpaid, so processing a request adds one register attempt
        MakeReservationUnpaidForReceipt(SalesReceiptNo);

        // [WHEN] The deferral batch runs
        TriggerDeferral();

        // [THEN] Only the expired request got a register attempt; the other two are untouched
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        Assert.AreEqual(3, DeferRevenueRequest.Count(), 'Deferral request count for the receipt.');
        DeferRevenueRequest.FindSet();
        repeat
            if (DeferRevenueRequest.TicketAccessEntryNo = ExpiredTicketAccessEntryNo) then begin
                Assert.AreEqual(1, DeferRevenueRequest.AttemptedRegisterCount, 'AttemptedRegisterCount should increase by one for the expired request.');
                Assert.AreEqual(DeferRevenueRequest.PaymentOption::UNPAID, DeferRevenueRequest.PaymentOption, 'PaymentOption should be re-resolved to UNPAID for the expired request.');
            end else begin
                Assert.AreEqual(DeferRevenueRequest.Status::WAITING, DeferRevenueRequest.Status, 'Status should stay WAITING for a request that is not due.');
                Assert.AreEqual(0, DeferRevenueRequest.AttemptedRegisterCount, 'AttemptedRegisterCount should not change for a request that is not due.');
                Assert.AreEqual(DeferRevenueRequest.PaymentOption::DIRECT, DeferRevenueRequest.PaymentOption, 'PaymentOption should not be re-resolved for a request that is not due.');
            end;
        until (DeferRevenueRequest.Next() = 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure WaitingRequest_StatusChangedByOtherRun_IsNotPostedAgain()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        RequestA, RequestB : Record "NPR TM DeferRevenueRequest";
        GLEntry: Record "G/L Entry";
        DeferTestSubscribers: Codeunit "NPR TM Defer Test Subscribers";
        SalesReceiptNoA, SalesReceiptNoB : Code[20];
        SentinelDocumentNo: Code[20];
    begin
        // [SCENARIO] A WAITING request that another run changed after the candidate read is skipped, not resolved and posted again
        Initialize();
        AllowAnyPostingDate();
        SentinelDocumentNo := 'TMDEFER-SENTINEL';

        // [GIVEN] Receipt A and then receipt B with one ticket each, their requests WAITING
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNoA := SellAndPostTicket(Item, 1);
        SalesReceiptNoB := SellAndPostTicket(Item, 1);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNoA, 1);
        AssertRequestsWaitingForReceipt(SalesReceiptNoB, 1);

        FilterRequestsForReceipt(SalesReceiptNoA, RequestA);
        RequestA.FindFirst();
        FilterRequestsForReceipt(SalesReceiptNoB, RequestB);
        RequestB.FindFirst();
        Assert.IsTrue(RequestA.TicketAccessEntryNo < RequestB.TicketAccessEntryNo, 'Precondition: TicketAccessEntryNo of A''s request should be lower than that of B''s request.');
        Assert.AreNotEqual(RequestA.TokenID, RequestB.TokenID, 'Precondition: the requests of A and B should have different TokenID values.');
        Assert.AreEqual('', RequestB.DeferralDocumentNo, 'Precondition: DeferralDocumentNo of B''s request should be blank.');
        Assert.AreNotEqual('', RequestB.AchievedRevenueAccount, 'Precondition: AchievedRevenueAccount of B''s request should not be blank.');
        Assert.AreEqual(SalesReceiptNoB, RequestB.SourceDocumentNo, 'Precondition: SourceDocumentNo of B''s request should be receipt B.');

        // [GIVEN] Both tickets expired yesterday, and nothing is posted on B's achieved revenue account under receipt B
        SetRequestDatesForReceipt(SalesReceiptNoA, Today() - 1, 0D);
        SetRequestDatesForReceipt(SalesReceiptNoB, Today() - 1, 0D);
        GLEntry.SetFilter("G/L Account No.", '=%1', RequestB.AchievedRevenueAccount);
        GLEntry.SetFilter("Document No.", '=%1', SalesReceiptNoB);
        Assert.RecordIsEmpty(GLEntry);

        // [GIVEN] When the batch modifies A's request, another run force-defers B's request under a sentinel document number
        DeferTestSubscribers.SetFlipOnModify(RequestA.TicketAccessEntryNo, RequestB.TicketAccessEntryNo, SentinelDocumentNo);
        BindSubscription(DeferTestSubscribers);

        // [WHEN] The deferral batch runs
        TriggerDeferral();
        UnbindSubscription(DeferTestSubscribers);

        // [THEN] B's request keeps the other run's result and nothing is posted for it
        RequestB.Get(RequestB.TicketAccessEntryNo);
        Assert.AreEqual(RequestB.Status::DEFERRED_FORCED, RequestB.Status, 'Status of B''s request should stay as the other run set it.');
        Assert.AreEqual(SentinelDocumentNo, RequestB.DeferralDocumentNo, 'DeferralDocumentNo of B''s request should stay as the other run set it.');
        Assert.RecordIsEmpty(GLEntry);

        // [THEN] A's request is force-deferred and posted on its achieved revenue account under receipt A
        RequestA.Get(RequestA.TicketAccessEntryNo);
        Assert.AreEqual(RequestA.Status::DEFERRED_FORCED, RequestA.Status, 'Status of A''s request should be DEFERRED_FORCED.');
        GLEntry.SetFilter("G/L Account No.", '=%1', RequestA.AchievedRevenueAccount);
        GLEntry.SetFilter("Document No.", '=%1', SalesReceiptNoA);
        Assert.RecordIsNotEmpty(GLEntry);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RegisteredRequests_FailingToken_KeepsEarlierTokensCommitted()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        RequestA, RequestB : Record "NPR TM DeferRevenueRequest";
        RequestDetail: Record "NPR TM DeferRevenueReqDetail";
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
        DeferTestSubscribers: Codeunit "NPR TM Defer Test Subscribers";
        SalesReceiptNoA, SalesReceiptNoB : Code[20];
    begin
        // [SCENARIO] When the batch fails on one reservation token, the tokens processed before it stay committed
        Initialize();

        // [GIVEN] Receipt A and then receipt B with one ticket each, their requests REGISTERED
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNoA := SellAndPostTicket(Item, 1);
        SalesReceiptNoB := SellAndPostTicket(Item, 1);

        FilterRequestsForReceipt(SalesReceiptNoA, RequestA);
        RequestA.FindFirst();
        FilterRequestsForReceipt(SalesReceiptNoB, RequestB);
        RequestB.FindFirst();
        Assert.AreEqual(RequestA.Status::REGISTERED, RequestA.Status, 'Precondition: Status of A''s request should be REGISTERED after the sale.');
        Assert.AreEqual(RequestB.Status::REGISTERED, RequestB.Status, 'Precondition: Status of B''s request should be REGISTERED after the sale.');
        Assert.AreEqual(0, RequestA.AttemptedRegisterCount, 'Precondition: AttemptedRegisterCount of A''s request should be 0 after the sale.');
        Assert.AreEqual(0, RequestB.AttemptedRegisterCount, 'Precondition: AttemptedRegisterCount of B''s request should be 0 after the sale.');
        Assert.IsTrue(RequestA.TicketAccessEntryNo < RequestB.TicketAccessEntryNo, 'Precondition: TicketAccessEntryNo of A''s request should be lower than that of B''s request.');
        Assert.AreNotEqual(RequestA.TokenID, RequestB.TokenID, 'Precondition: the requests of A and B should have different TokenID values.');
        // The setup is committed so the failing run can only roll back its own token.
        Commit();

        // [GIVEN] Every modify of B's request fails
        DeferTestSubscribers.SetErrorOnModify(RequestB.TicketAccessEntryNo);
        BindSubscription(DeferTestSubscribers);

        // [WHEN] The deferral batch runs: A's token comes first, then B's token fails
        asserterror DeferRevenue.ProcessBatch();

        RequestA.Get(RequestA.TicketAccessEntryNo);
        RequestB.Get(RequestB.TicketAccessEntryNo);
        UnbindSubscription(DeferTestSubscribers);

        // [THEN] The run fails on B's request
        Assert.ExpectedError(DeferTestSubscribers.ErrorText());

        // [THEN] A's token stayed committed: its request is WAITING and resolved from receipt A
        Assert.AreEqual(RequestA.Status::WAITING, RequestA.Status, 'Status of A''s request should stay WAITING after B''s token fails.');
        Assert.AreEqual(RequestA.PaymentOption::DIRECT, RequestA.PaymentOption, 'PaymentOption of A''s request should stay DIRECT after B''s token fails.');
        Assert.AreEqual(SalesReceiptNoA, RequestA.SourceDocumentNo, 'SourceDocumentNo of A''s request should stay receipt A after B''s token fails.');

        // [THEN] B's token was rolled back: its request has no detail row
        RequestDetail.SetFilter(TicketAccessEntryNo, '=%1', RequestB.TicketAccessEntryNo);
        Assert.RecordIsEmpty(RequestDetail);
        // Sanity only: the refused Modify is the only write to B's request, so Status and AttemptedRegisterCount stay the same with or without the rollback.
        Assert.AreEqual(RequestB.Status::REGISTERED, RequestB.Status, 'Status of B''s request should still be REGISTERED.');
        Assert.AreEqual(0, RequestB.AttemptedRegisterCount, 'AttemptedRegisterCount of B''s request should still be 0.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PendingDeferral_DocumentLargerThanBatch_IsPostedInBatchSizeChunks()
    var
        Item: Record Item;
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
        SalesReceiptNo: Code[20];
    begin
        // [SCENARIO] A receipt with more pending requests than the batch size is posted in chunks of the batch size
        Initialize();
        ParkForeignPendingRequests();
        AllowAnyPostingDate();

        // [GIVEN] Five admitted tickets on one receipt, their requests PENDING_DEFERRAL
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNo := SellAndPostTicket(Item, 5);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNo, 5);
        AdmitTicketsForSalesReceipt(SalesReceiptNo);
        AssertRequestsPendingForReceipt(SalesReceiptNo, 5);

        // [WHEN] The deferral batch runs with a batch size of 2
        DeferRevenue.ProcessBatch(2);

        // [THEN] Every request is DEFERRED and the receipt is posted in 3 lines (2 + 2 + 1) for the full sale amount
        AssertReceiptDeferredInLines(SalesReceiptNo, 5, 3);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PendingDeferral_DocumentsThatFitABatch_AreNotSplit()
    var
        Item: Record Item;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
        SalesReceiptNoA, SalesReceiptNoB, SalesReceiptNoC : Code[20];
        TokenIDA: Text[100];
    begin
        // [SCENARIO] A receipt that fits in a batch is never split across batches, even when one of its requests carries another receipt's token
        // Regression guard: the single-transaction posting never split a receipt either, so this also passes there.
        Initialize();
        ParkForeignPendingRequests();
        AllowAnyPostingDate();

        // [GIVEN] Receipts A, B and C with two admitted tickets each
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNoA := SellAndPostTicket(Item, 2);
        SalesReceiptNoB := SellAndPostTicket(Item, 2);
        SalesReceiptNoC := SellAndPostTicket(Item, 2);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNoA, 2);
        AssertRequestsWaitingForReceipt(SalesReceiptNoB, 2);
        AssertRequestsWaitingForReceipt(SalesReceiptNoC, 2);
        AdmitTicketsForSalesReceipt(SalesReceiptNoA);
        AdmitTicketsForSalesReceipt(SalesReceiptNoB);
        AdmitTicketsForSalesReceipt(SalesReceiptNoC);

        // [GIVEN] One of receipt B's requests carries receipt A's token
        FilterRequestsForReceipt(SalesReceiptNoA, DeferRevenueRequest);
        DeferRevenueRequest.FindFirst();
        TokenIDA := DeferRevenueRequest.TokenID;
        FilterRequestsForReceipt(SalesReceiptNoB, DeferRevenueRequest);
        DeferRevenueRequest.FindFirst();
        DeferRevenueRequest.TokenID := TokenIDA;
        DeferRevenueRequest.Modify();

        AssertRequestsPendingForReceipt(SalesReceiptNoA, 2);
        AssertRequestsPendingForReceipt(SalesReceiptNoB, 2);
        AssertRequestsPendingForReceipt(SalesReceiptNoC, 2);

        // [WHEN] The deferral batch runs with a batch size of 3
        DeferRevenue.ProcessBatch(3);

        // [THEN] Every request is DEFERRED and each receipt is posted in exactly one line
        AssertReceiptDeferredInLines(SalesReceiptNoA, 2, 1);
        AssertReceiptDeferredInLines(SalesReceiptNoB, 2, 1);
        AssertReceiptDeferredInLines(SalesReceiptNoC, 2, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PendingDeferral_CompressedProfile_BatchesFillToSize()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        Profile: Record "NPR TM DeferRevenueProfile";
        TicketType: Record "NPR TM Ticket Type";
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        GLEntry: Record "G/L Entry";
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
        LibraryUtility: Codeunit "Library - Utility";
        RequestCountByDocumentNo: Dictionary of [Code[20], Integer];
        SalesReceiptNos: List of [Code[20]];
        SalesReceiptNo: Code[20];
        DeferralDocumentNo: Code[20];
        RequestCount: Integer;
        SharedDocumentCount: Integer;
        ReceiptCount: Integer;
        ExpectedAmountExVat: Decimal;
        PostedAmount: Decimal;
    begin
        // [SCENARIO] With a compressed profile, a batch is filled up to the batch size and posted under one document number
        Initialize();
        ParkForeignPendingRequests();
        AllowAnyPostingDate();

        // [GIVEN] A compressed deferral profile with a number series on the ticket type
        CopyDeferralProfile('TMDEFERC', Profile);
        Profile.PostingMode := Profile.PostingMode::COMPRESSED;
        Profile.NoSeries := LibraryUtility.GetGlobalNoSeriesCode();
        Profile.Modify();

        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        TicketType.Get(Item."NPR Ticket Type");
        TicketType.DeferRevenueProfileCode := Profile.DeferRevenueProfileCode;
        TicketType.Modify();

        // [GIVEN] Three receipts with one admitted ticket each
        for ReceiptCount := 1 to 3 do
            SalesReceiptNos.Add(SellAndPostTicket(Item, 1));
        TriggerDeferral();
        foreach SalesReceiptNo in SalesReceiptNos do begin
            AssertRequestsWaitingForReceipt(SalesReceiptNo, 1);
            AdmitTicketsForSalesReceipt(SalesReceiptNo);
        end;
        foreach SalesReceiptNo in SalesReceiptNos do
            AssertRequestsPendingForReceipt(SalesReceiptNo, 1);

        // [WHEN] The deferral batch runs with a batch size of 2
        DeferRevenue.ProcessBatch(2);

        // [THEN] Every request is DEFERRED; two of them share one deferral document number and the third has its own
        foreach SalesReceiptNo in SalesReceiptNos do begin
            FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
            DeferRevenueRequest.FindFirst();
            Assert.AreEqual(DeferRevenueRequest.Status::DEFERRED, DeferRevenueRequest.Status, 'Status should be DEFERRED after the batch run.');
            ExpectedAmountExVat += SalesAmountForSalesReceipt(SalesReceiptNo);

            if (not RequestCountByDocumentNo.Get(DeferRevenueRequest.DeferralDocumentNo, RequestCount)) then
                RequestCount := 0;
            RequestCountByDocumentNo.Set(DeferRevenueRequest.DeferralDocumentNo, RequestCount + 1);
        end;
        Assert.AreEqual(2, RequestCountByDocumentNo.Count(), 'Number of deferral document numbers for three requests in batches of 2.');

        // [THEN] Each deferral document is posted in one line, and together they post the full sale amount
        GLEntry.SetFilter("G/L Account No.", '=%1', DeferRevenueRequest.AchievedRevenueAccount);
        foreach DeferralDocumentNo in RequestCountByDocumentNo.Keys() do begin
            if (RequestCountByDocumentNo.Get(DeferralDocumentNo) = 2) then
                SharedDocumentCount += 1;

            GLEntry.SetFilter("Document No.", '=%1', DeferralDocumentNo);
            Assert.AreEqual(1, GLEntry.Count(), 'Number of compressed deferral lines posted for one deferral document.');
            GLEntry.CalcSums(Amount);
            PostedAmount += GLEntry.Amount;
        end;
        Assert.AreEqual(1, SharedDocumentCount, 'Exactly one deferral document number should be shared by two requests.');
        Assert.AreNearlyEqual(ExpectedAmountExVat, Abs(PostedAmount), 0.02, 'Posted deferral amount should equal the full sale amount of the three receipts.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PendingDeferral_FailingBatch_KeepsEarlierBatchesCommitted()
    var
        Assert: Codeunit Assert;
        Item: Record Item;
        Profile: Record "NPR TM DeferRevenueProfile";
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        RequestA, RequestB : Record "NPR TM DeferRevenueRequest";
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
        SalesReceiptNoA, SalesReceiptNoB : Code[20];
    begin
        // [SCENARIO] When a batch fails, the batches posted before it stay committed and the failing batch's request stays PENDING_DEFERRAL
        Initialize();
        ParkForeignPendingRequests();
        AllowAnyPostingDate();

        // [GIVEN] An uncompressed deferral profile without a number series, which fails when a request is posted with it
        CopyDeferralProfile('TMDEFERU', Profile);
        Profile.PostingMode := Profile.PostingMode::UNCOMPRESSED;
        Profile.NoSeries := '';
        Profile.Modify();

        // [GIVEN] Receipt A and then receipt B with one ticket each
        Item.Get(SelectSmokeTestScenario());
        ConfigureItem(Item, true, 148.22);
        SalesReceiptNoA := SellAndPostTicket(Item, 1);
        SalesReceiptNoB := SellAndPostTicket(Item, 1);
        TriggerDeferral();
        AssertRequestsWaitingForReceipt(SalesReceiptNoA, 1);
        AssertRequestsWaitingForReceipt(SalesReceiptNoB, 1);

        // [GIVEN] Receipt B's request uses the failing profile, and both tickets are admitted
        FilterRequestsForReceipt(SalesReceiptNoB, DeferRevenueRequest);
        DeferRevenueRequest.ModifyAll(DeferRevenueProfileCode, Profile.DeferRevenueProfileCode);
        AdmitTicketsForSalesReceipt(SalesReceiptNoA);
        AdmitTicketsForSalesReceipt(SalesReceiptNoB);
        AssertRequestsPendingForReceipt(SalesReceiptNoA, 1);
        AssertRequestsPendingForReceipt(SalesReceiptNoB, 1);
        // The setup is committed so the failing run can only roll back its own batch.
        Commit();

        // [WHEN] The deferral batch runs with a batch size of 1: A's batch comes first, then B's batch fails
        asserterror DeferRevenue.ProcessBatch(1);

        FilterRequestsForReceipt(SalesReceiptNoA, RequestA);
        RequestA.FindFirst();
        FilterRequestsForReceipt(SalesReceiptNoB, RequestB);
        RequestB.FindFirst();

        // B's request would fail every later batch run, so it is parked before the assertions.
        ParkForeignPendingRequests();

        // [THEN] The run fails on the profile without a number series
        Assert.ExpectedError(Profile.DeferRevenueProfileCode);

        // [THEN] A's batch stayed committed and B's request is still PENDING_DEFERRAL
        Assert.AreEqual(RequestA.Status::DEFERRED, RequestA.Status, 'The request in the batch before the failing one should stay DEFERRED.');
        Assert.AreEqual(RequestB.Status::PENDING_DEFERRAL, RequestB.Status, 'The request in the failing batch should still be PENDING_DEFERRAL.');
    end;

    local procedure Initialize()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        TicketRequestMgr: Codeunit "NPR TM Ticket Request Manager";
        PeriodRegister: Record "NPR POS Period Register";
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);

        if (not _Initialized) then begin
            LibraryPOSMasterData.CreatePOSSetup(_POSSetup);
            LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
            LibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
            LibraryPOSMasterData.CreatePOSPaymentMethod(_POSPaymentMethodCash, _POSPaymentMethodCash."Processing Type"::CASH, '', false);

            PeriodRegister.SetFilter("POS Unit No.", '=%1', _POSUnit."No.");
            PeriodRegister.SetFilter("POS Store Code", '=%1', _POSStore."Code");
            PeriodRegister.FindFirst();
            PeriodRegister."Document No." := '';
            PeriodRegister."Posting Compression" := PeriodRegister."Posting Compression"::"Per POS Entry";
            PeriodRegister.Modify();

            TicketRequestMgr.ExpireReservationRequests();
            _Initialized := true;
        end;

        Commit();
    end;

    local procedure ConfigureItem(var Item: Record Item; IncludesVat: Boolean; UnitPrice: Decimal)
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        POSMasterData: Codeunit "NPR Library - POS Master Data";
        POSPostingProfile: Record "NPR POS Posting Profile";
        LibraryRandom: Codeunit "Library - Random";
    begin
        _POSStore.GetProfile(POSPostingProfile);
        Item."VAT Bus. Posting Gr. (Price)" := POSPostingProfile."VAT Bus. Posting Group";
        Item."Price Includes VAT" := IncludesVat;
        Item."Unit Price" := UnitPrice;
        Item."Unit Cost" := LibraryRandom.RandDecInDecimalRange(0.01, UnitPrice, 1);
        Item.Modify();

        POSMasterData.CreatePostingSetupForSaleItem(Item, _POSUnit, _POSStore);

        TicketType.Get(Item."NPR Ticket Type");
        TicketType."Defer Revenue" := true;
        TicketType.DeferRevenueProfileCode := GetDeferralProfile();
        TicketType.Modify();

        TicketBOM.SetFilter("Item No.", '=%1', Item."No.");
        if (TicketBOM.FindSet(true)) then
            repeat
                TicketBOM.DeferRevenue := true;
                TicketBOM.Modify();
            until (TicketBOM.Next() = 0);
    end;

    local procedure PatchToGroupTicket(var Item: Record Item; GroupSize: Integer)
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin
        TicketType.Get(Item."NPR Ticket Type");
        TicketType."Admission Registration" := TicketType."Admission Registration"::GROUP;
        TicketType.Modify();

        TicketBOM.SetFilter("Item No.", '=%1', Item."No.");
        if (TicketBOM.FindSet(true)) then
            repeat
                TicketBOM.Quantity := GroupSize;
                TicketBOM.Modify();
            until (TicketBOM.Next() = 0);
    end;

    local procedure GetDeferralProfile() ProfileCode: Code[10]
    var
        Profile: Record "NPR TM DeferRevenueProfile";
        LibraryERM: Codeunit "Library - ERM";
        GenJournalTemplate: Record "Gen. Journal Template";
        SourceCode: Record "Source Code";
    begin
        ProfileCode := 'TMDEFER';
        if (Profile.Get(ProfileCode)) then
            exit(ProfileCode);

        Profile.Init();
        Profile.DeferRevenueProfileCode := ProfileCode;
        Profile.AchievedRevenueAccount := LibraryERM.CreateGLAccountWithSalesSetup();
        Profile.InterimAdjustmentAccount := LibraryERM.CreateGLAccountWithSalesSetup();
        Profile.PostingMode := Profile.PostingMode::INLINE;
        Profile.MaxAttempts := 5;
        if (GenJournalTemplate.FindFirst()) then
            Profile.JournalTemplateName := GenJournalTemplate.Name;
        if (SourceCode.FindFirst()) then
            Profile.SourceCode := SourceCode.Code;
        Profile.Insert();
    end;

    local procedure SellAndPostTicket(Item: Record Item; Quantity: Integer) SalesReceiptNo: Code[20]
    var
        Salesperson: Record "Salesperson/Purchaser";
        POSSaleLine: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SaleLine: Codeunit "NPR POS Sale Line";
        LibraryPOSMock: Codeunit "NPR Library - POS Mock";
        Amount: Decimal;
    begin
        _POSSession.ClearAll();
        Clear(_POSSession);

        LibraryPOSMock.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, Salesperson, POSSale);
        LibraryPOSMock.CreateItemLine(_POSSession, Item."No.", Quantity);

        _POSSession.GetSaleLine(SaleLine);
        SaleLine.GetCurrentSaleLine(POSSaleLine);
        SalesReceiptNo := POSSaleLine."Sales Ticket No.";
        Amount := POSSaleLine."Amount Including VAT";

        if (not LibraryPOSMock.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethodCash.Code, Amount, '', true)) then
            Error('Failed to complete POS sale in test setup.');
    end;

    local procedure TriggerDeferral()
    var
        DeferRevenue: Codeunit "NPR TM RevenueDeferral";
    begin
        DeferRevenue.ProcessBatch();
    end;

    local procedure AdmitTicketsForSalesReceipt(SalesReceiptNo: Code[20]) TicketCount: Integer
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketMgt: Codeunit "NPR TM Ticket Management";
    begin
        ReservationRequest.SetCurrentKey("Receipt No.");
        ReservationRequest.SetFilter("Receipt No.", '=%1', SalesReceiptNo);
        ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        if (not ReservationRequest.FindFirst()) then
            exit;

        DeferRevenueRequest.SetFilter(ReservationRequestEntryNo, '=%1', ReservationRequest."Entry No.");

        if (DeferRevenueRequest.FindSet()) then
            repeat
                TicketCount += 1;
                if (Ticket.Get(DeferRevenueRequest.TicketNo)) then
                    TicketMgt.ValidateTicketForArrival(Ticket, DeferRevenueRequest.AdmissionCode, '');
            until (DeferRevenueRequest.Next() = 0);
    end;

    local procedure DisableDeferralForItem(Item: Record Item)
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
    begin
        TicketType.Get(Item."NPR Ticket Type");
        TicketType."Defer Revenue" := false;
        TicketType.Modify();

        TicketBOM.SetFilter("Item No.", '=%1', Item."No.");
        if (TicketBOM.FindSet(true)) then
            repeat
                TicketBOM.DeferRevenue := false;
                TicketBOM.Modify();
            until (TicketBOM.Next() = 0);
    end;

    local procedure SumAmountToDeferForSalesReceipt(SalesReceiptNo: Code[20]) Total: Decimal
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        ReservationRequest.SetCurrentKey("Receipt No.");
        ReservationRequest.SetFilter("Receipt No.", '=%1', SalesReceiptNo);
        ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        if (not ReservationRequest.FindFirst()) then
            exit;

        DeferRevenueRequest.SetFilter(ReservationRequestEntryNo, '=%1', ReservationRequest."Entry No.");
        if (DeferRevenueRequest.FindSet()) then
            repeat
                Total += DeferRevenueRequest.AmountToDefer;
            until (DeferRevenueRequest.Next() = 0);
    end;

    local procedure SalesAmountForSalesReceipt(SalesReceiptNo: Code[20]) Total: Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetFilter("Document No.", '=%1', SalesReceiptNo);
        ValueEntry.SetFilter("Item Ledger Entry Type", '=%1', ValueEntry."Item Ledger Entry Type"::Sale);
        ValueEntry.SetFilter("Entry Type", '=%1', ValueEntry."Entry Type"::"Direct Cost");
        if (ValueEntry.FindSet()) then
            repeat
                Total += ValueEntry."Sales Amount (Actual)";
            until (ValueEntry.Next() = 0);
    end;


    local procedure DeferralPostedAmountForSalesReceipt(SalesReceiptNo: Code[20]) Total: Decimal
    var
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        Profile: Record "NPR TM DeferRevenueProfile";
        GLEntry: Record "G/L Entry";
    begin
        ReservationRequest.SetCurrentKey("Receipt No.");
        ReservationRequest.SetFilter("Receipt No.", '=%1', SalesReceiptNo);
        ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        if (not ReservationRequest.FindFirst()) then
            exit;

        DeferRevenueRequest.SetFilter(ReservationRequestEntryNo, '=%1', ReservationRequest."Entry No.");
        DeferRevenueRequest.SetFilter(DeferralDocumentNo, '<>%1', '');
        if (not DeferRevenueRequest.FindFirst()) then
            exit;

        Profile.Get(DeferRevenueRequest.DeferRevenueProfileCode);

        GLEntry.SetFilter("G/L Account No.", '=%1', Profile.AchievedRevenueAccount);
        GLEntry.SetFilter("Document No.", '=%1', DeferRevenueRequest.DeferralDocumentNo);
        if (GLEntry.FindSet()) then
            repeat
                Total += GLEntry.Amount;
            until (GLEntry.Next() = 0);
    end;

    local procedure AssertDeferralForReceipt(SalesReceiptNo: Code[20]; ExpectedCount: Integer; ExpectedSumAmount: Decimal; Tag: Text)
    var
        Assert: Codeunit Assert;
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        ExpectedPerRecord: Decimal;
    begin
        ReservationRequest.SetCurrentKey("Receipt No.");
        ReservationRequest.SetFilter("Receipt No.", '=%1', SalesReceiptNo);
        ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        Assert.IsTrue(ReservationRequest.FindFirst(), Tag + ': primary reservation request should exist.');

        DeferRevenueRequest.SetFilter(ReservationRequestEntryNo, '=%1', ReservationRequest."Entry No.");
        Assert.AreEqual(ExpectedCount, DeferRevenueRequest.Count(), Tag + ': deferral request count.');

        ExpectedPerRecord := ExpectedSumAmount / ExpectedCount;
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreNearlyEqual(ExpectedPerRecord, DeferRevenueRequest.AmountToDefer, 0.01, Tag + ': per-record AmountToDefer.');
        until (DeferRevenueRequest.Next() = 0);
    end;

    local procedure FilterRequestsForReceipt(SalesReceiptNo: Code[20]; var DeferRevenueRequest: Record "NPR TM DeferRevenueRequest")
    var
        Assert: Codeunit Assert;
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        ReservationRequest.SetCurrentKey("Receipt No.");
        ReservationRequest.SetFilter("Receipt No.", '=%1', SalesReceiptNo);
        ReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        Assert.IsTrue(ReservationRequest.FindFirst(), 'Primary reservation request should exist for the receipt.');

        DeferRevenueRequest.Reset();
        DeferRevenueRequest.SetFilter(ReservationRequestEntryNo, '=%1', ReservationRequest."Entry No.");
    end;

    local procedure AssertRequestsWaitingForReceipt(SalesReceiptNo: Code[20]; ExpectedCount: Integer)
    var
        Assert: Codeunit Assert;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        Assert.AreEqual(ExpectedCount, DeferRevenueRequest.Count(), 'Precondition: deferral request count for the receipt.');
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreEqual(DeferRevenueRequest.Status::WAITING, DeferRevenueRequest.Status, 'Precondition: Status should be WAITING after the first batch run.');
            Assert.AreEqual(0, DeferRevenueRequest.AttemptedRegisterCount, 'Precondition: AttemptedRegisterCount should be 0 after the first batch run.');
        until (DeferRevenueRequest.Next() = 0);
    end;

    local procedure SetRequestDatesForReceipt(SalesReceiptNo: Code[20]; ValidUntil: Date; Achieved: Date)
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindSet(true);
        repeat
            DeferRevenueRequest.TicketValidUntil := ValidUntil;
            DeferRevenueRequest.AchievedDate := Achieved;
            DeferRevenueRequest.Modify();
        until (DeferRevenueRequest.Next() = 0);
    end;

    local procedure MakeReservationUnpaidForReceipt(SalesReceiptNo: Code[20])
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        ReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        // An unpaid reservation does not resolve, so every processing of the request adds one register attempt.
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        DeferRevenueRequest.FindFirst();
        ReservationRequest.Get(DeferRevenueRequest.ReservationRequestEntryNo);
        ReservationRequest."Payment Option" := ReservationRequest."Payment Option"::UNPAID;
        ReservationRequest.Modify();
    end;

    local procedure AllowAnyPostingDate()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        UserSetup: Record "User Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Allow Posting From" := 0D;
        GeneralLedgerSetup."Allow Posting To" := 0D;
        GeneralLedgerSetup.Modify();

        if (UserSetup.Get(UserId())) then begin
            UserSetup."Allow Posting From" := 0D;
            UserSetup."Allow Posting To" := 0D;
            UserSetup.Modify();
        end;
    end;

    local procedure ParkForeignPendingRequests()
    var
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        // Requests left PENDING_DEFERRAL by earlier tests would join the batches under test, so they are taken out of the run.
        DeferRevenueRequest.SetFilter(Status, '=%1', DeferRevenueRequest.Status::PENDING_DEFERRAL);
        DeferRevenueRequest.ModifyAll(Status, DeferRevenueRequest.Status::DEFERRAL_ABORTED);
        Commit();
    end;

    local procedure CopyDeferralProfile(ProfileCode: Code[10]; var Profile: Record "NPR TM DeferRevenueProfile")
    begin
        Profile.Get(GetDeferralProfile());
        Profile.DeferRevenueProfileCode := ProfileCode;
        if (not Profile.Insert()) then
            Profile.Modify();
    end;

    local procedure AssertRequestsPendingForReceipt(SalesReceiptNo: Code[20]; ExpectedCount: Integer)
    var
        Assert: Codeunit Assert;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
    begin
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        Assert.AreEqual(ExpectedCount, DeferRevenueRequest.Count(), 'Precondition: deferral request count for the receipt.');
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreEqual(DeferRevenueRequest.Status::PENDING_DEFERRAL, DeferRevenueRequest.Status, 'Precondition: Status should be PENDING_DEFERRAL after admission.');
            Assert.AreEqual(SalesReceiptNo, DeferRevenueRequest.SourceDocumentNo, 'Precondition: SourceDocumentNo should be the receipt.');
        until (DeferRevenueRequest.Next() = 0);
    end;

    local procedure AssertReceiptDeferredInLines(SalesReceiptNo: Code[20]; ExpectedRequestCount: Integer; ExpectedLineCount: Integer)
    var
        Assert: Codeunit Assert;
        DeferRevenueRequest: Record "NPR TM DeferRevenueRequest";
        GLEntry: Record "G/L Entry";
    begin
        FilterRequestsForReceipt(SalesReceiptNo, DeferRevenueRequest);
        Assert.AreEqual(ExpectedRequestCount, DeferRevenueRequest.Count(), 'Deferral request count for the receipt.');
        DeferRevenueRequest.FindSet();
        repeat
            Assert.AreEqual(DeferRevenueRequest.Status::DEFERRED, DeferRevenueRequest.Status, 'Status should be DEFERRED after the batch run.');
            Assert.AreEqual(SalesReceiptNo, DeferRevenueRequest.DeferralDocumentNo, 'DeferralDocumentNo should be the receipt for an inline profile.');
        until (DeferRevenueRequest.Next() = 0);

        GLEntry.SetFilter("G/L Account No.", '=%1', DeferRevenueRequest.AchievedRevenueAccount);
        GLEntry.SetFilter("Document No.", '=%1', DeferRevenueRequest.DeferralDocumentNo);
        Assert.AreEqual(ExpectedLineCount, GLEntry.Count(), 'Number of deferral lines posted to the achieved revenue account for the receipt.');
        GLEntry.CalcSums(Amount);
        Assert.AreNearlyEqual(SalesAmountForSalesReceipt(SalesReceiptNo), Abs(GLEntry.Amount), 0.01 * ExpectedLineCount, 'Posted deferral amount should equal the full sale amount of the receipt.');
    end;

    local procedure SelectSmokeTestScenario() ItemNo: Code[20]
    var
        TicketLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        ItemNo := TicketLibrary.CreateScenario_SmokeTest();
    end;

}

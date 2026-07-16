codeunit 85154 "NPR Adyen Reconciliation Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _LibraryERM: Codeunit "Library - ERM";
        _LibraryUtility: Codeunit "Library - Utility";
        _Assert: Codeunit Assert;
        _AdyenSetup: Record "NPR Adyen Setup";
        _AdyenMerchantSetup: Record "NPR Adyen Merchant Setup";
        _MerchantAccount: Text[80];
        _NetCurrency: Code[10];
        _LCYCode: Code[10];
        _Initialized: Boolean;
        _BatchNumberSeed: Integer;
        _SettledTypeLbl: Label 'Settled', Locked = true;
        _FeeTypeLbl: Label 'Fee', Locked = true;
        _CompanyAccountLbl: Label 'NPCompanyTestAccount', Locked = true;
        _LocalFileLbl: Label 'Local File Upload', Locked = true;
        _DataSheetLbl: Label 'data', Locked = true;

    #region [Import Process]

    [Test]
    procedure ImportProcess_EFT()
    var
        AFRecWebhookRequest: Record "NPR AF Rec. Webhook Request";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        AdyenRecReportProcess: Codeunit "NPR Adyen Rec. Report Process";
        BatchNumber: Integer;
        PSPReference: Code[16];
        SettledAmount: Decimal;
        FeeAmount: Decimal;
    begin
        // [Scenario] A settlement report with an EFT-style settled transaction + a Fee row is imported into recon lines correctly
        Initialize();
        BatchNumber := GenerateUniqueBatchNumber();
        PSPReference := GenerateUniquePSPReference();
        SettledAmount := 100;
        FeeAmount := 2;

        // [Given] A webhook request whose Report Data blob carries an XLSX 'Settlement details' report
        BuildWebhookRequest(AFRecWebhookRequest, BatchNumber, PSPReference, 'EFT-ORDER-' + Format(BatchNumber), SettledAmount, FeeAmount);

        // [When] Running the report processing entry point
        AdyenRecReportProcess.Run(AFRecWebhookRequest);

        // [Then] One reconciliation header for this batch + merchant exists, status updated by automation
        ReconciliationHeader.SetRange("Batch Number", BatchNumber);
        ReconciliationHeader.SetRange("Merchant Account", _MerchantAccount);
        ReconciliationHeader.FindFirst();
        ReconciliationHeader.TestField("Document Type", ReconciliationHeader."Document Type"::"Settlement details");

        // [Then] Two reconciliation lines are present: one Settled, one Fee — with the values from the XLSX
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        _Assert.AreEqual(2, ReconciliationLine.Count(), 'Expected exactly two recon lines (Settled + Fee) imported from the EFT scenario report');

        ReconciliationLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type"::Settled);
        ReconciliationLine.FindFirst();
        ReconciliationLine.TestField("PSP Reference", PSPReference);
        ReconciliationLine.TestField("Amount (TCY)", SettledAmount);
        ReconciliationLine.TestField("Payment Fees (NC)", FeeAmount);
        ReconciliationLine.TestField("Adyen Acc. Currency Code", _NetCurrency);
        ReconciliationLine.TestField("Merchant Account", _MerchantAccount);

        ReconciliationLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type"::Fee);
        _Assert.IsFalse(ReconciliationLine.IsEmpty(), 'Expected a Fee transaction-type line to be created from the EFT scenario report');
    end;

    [Test]
    procedure ImportProcess_Magento()
    var
        AFRecWebhookRequest: Record "NPR AF Rec. Webhook Request";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        AdyenRecReportProcess: Codeunit "NPR Adyen Rec. Report Process";
        BatchNumber: Integer;
        PSPReference: Code[16];
        SettledAmount: Decimal;
        FeeAmount: Decimal;
    begin
        // [Scenario] A settlement report with a Magento-style settled transaction + a Fee is imported correctly
        Initialize();
        BatchNumber := GenerateUniqueBatchNumber();
        PSPReference := GenerateUniquePSPReference();
        SettledAmount := 250;
        FeeAmount := 5;

        BuildWebhookRequest(AFRecWebhookRequest, BatchNumber, PSPReference, 'MAG-ORDER-' + Format(BatchNumber), SettledAmount, FeeAmount);

        AdyenRecReportProcess.Run(AFRecWebhookRequest);

        ReconciliationHeader.SetRange("Batch Number", BatchNumber);
        ReconciliationHeader.SetRange("Merchant Account", _MerchantAccount);
        ReconciliationHeader.FindFirst();

        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        _Assert.AreEqual(2, ReconciliationLine.Count(), 'Expected exactly two recon lines (Settled + Fee) imported from the Magento scenario report');

        ReconciliationLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type"::Settled);
        ReconciliationLine.FindFirst();
        ReconciliationLine.TestField("PSP Reference", PSPReference);
        ReconciliationLine.TestField("Amount (TCY)", SettledAmount);
        ReconciliationLine.TestField("Adyen Acc. Currency Code", _NetCurrency);

        ReconciliationLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type"::Fee);
        _Assert.IsFalse(ReconciliationLine.IsEmpty(), 'Expected a Fee transaction-type line to be created from the Magento scenario report');
    end;

    [Test]
    procedure ImportProcess_Subscription()
    var
        AFRecWebhookRequest: Record "NPR AF Rec. Webhook Request";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        AdyenRecReportProcess: Codeunit "NPR Adyen Rec. Report Process";
        BatchNumber: Integer;
        PSPReference: Code[16];
        SettledAmount: Decimal;
        FeeAmount: Decimal;
    begin
        // [Scenario] A settlement report with a Subscription-style settled transaction + a Fee is imported correctly
        Initialize();
        BatchNumber := GenerateUniqueBatchNumber();
        PSPReference := GenerateUniquePSPReference();
        SettledAmount := 75;
        FeeAmount := 1;

        BuildWebhookRequest(AFRecWebhookRequest, BatchNumber, PSPReference, 'SUBS-ORDER-' + Format(BatchNumber), SettledAmount, FeeAmount);

        AdyenRecReportProcess.Run(AFRecWebhookRequest);

        ReconciliationHeader.SetRange("Batch Number", BatchNumber);
        ReconciliationHeader.SetRange("Merchant Account", _MerchantAccount);
        ReconciliationHeader.FindFirst();

        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        _Assert.AreEqual(2, ReconciliationLine.Count(), 'Expected exactly two recon lines (Settled + Fee) imported from the Subscription scenario report');

        ReconciliationLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type"::Settled);
        ReconciliationLine.FindFirst();
        ReconciliationLine.TestField("PSP Reference", PSPReference);
        ReconciliationLine.TestField("Amount (TCY)", SettledAmount);
        ReconciliationLine.TestField("Adyen Acc. Currency Code", _NetCurrency);

        ReconciliationLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type"::Fee);
        _Assert.IsFalse(ReconciliationLine.IsEmpty(), 'Expected a Fee transaction-type line to be created from the Subscription scenario report');
    end;

    #endregion

    #region [Matching Process]

    [Test]
    procedure MatchingProcess_EFT()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        PSPReference: Code[16];
        Amount: Decimal;
    begin
        // [Scenario] A recon line gets matched to an EFT Transaction Request that shares its PSP Reference and amount
        Initialize();
        PSPReference := GenerateUniquePSPReference();
        Amount := 50;

        // [Given] A successful EFT Transaction Request with the PSP reference and amount, not yet reconciled
        CreateEFTTransactionRequest(EFTTransactionRequest, PSPReference, Amount);

        // [Given] A recon header and an unmatched Settled line for the same PSP reference + amount
        CreateReconHeader(ReconciliationHeader);
        InsertSettledReconLine(ReconciliationLine, ReconciliationHeader, PSPReference, Amount);

        // [When] Running the matching pass
        AdyenTransMatching.MatchEntries(ReconciliationHeader);

        // [Then] The recon line is bound to the EFT transaction record and marked Matched
        ReconciliationLine.Find();
        ReconciliationLine.TestField("Matching Table Name", ReconciliationLine."Matching Table Name"::"EFT Transaction");
        ReconciliationLine.TestField("Matching Entry System ID", EFTTransactionRequest.SystemId);
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Matched);

        // [Then] The header now reflects the matched status
        ReconciliationHeader.Find();
        ReconciliationHeader.TestField(Status, ReconciliationHeader.Status::Matched);
        ReconciliationHeader.TestField("Failed Lines Exist", false);
    end;

    [Test]
    procedure MatchingProcess_Magento()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        PSPReference: Code[16];
        Amount: Decimal;
    begin
        // [Scenario] A recon line gets matched to a Magento Payment Line whose Transaction ID equals the PSP Reference
        Initialize();
        PSPReference := GenerateUniquePSPReference();
        Amount := 120;

        CreateMagentoPaymentLine(MagentoPaymentLine, PSPReference, Amount);

        CreateReconHeader(ReconciliationHeader);
        InsertSettledReconLine(ReconciliationLine, ReconciliationHeader, PSPReference, Amount);

        AdyenTransMatching.MatchEntries(ReconciliationHeader);

        ReconciliationLine.Find();
        ReconciliationLine.TestField("Matching Table Name", ReconciliationLine."Matching Table Name"::"Magento Payment Line");
        ReconciliationLine.TestField("Matching Entry System ID", MagentoPaymentLine.SystemId);
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Matched);

        ReconciliationHeader.Find();
        ReconciliationHeader.TestField(Status, ReconciliationHeader.Status::Matched);
    end;

    [Test]
    procedure MatchingProcess_Subscription()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        PSPReference: Code[16];
        Amount: Decimal;
    begin
        // [Scenario] A recon line gets matched to a Subscription Payment Request whose PSP Reference + amount agree
        Initialize();
        PSPReference := GenerateUniquePSPReference();
        Amount := 30;

        CreateSubscrPaymentRequest(SubscrPaymentRequest, PSPReference, Amount);

        CreateReconHeader(ReconciliationHeader);
        InsertSettledReconLine(ReconciliationLine, ReconciliationHeader, PSPReference, Amount);

        AdyenTransMatching.MatchEntries(ReconciliationHeader);

        ReconciliationLine.Find();
        ReconciliationLine.TestField("Matching Table Name", ReconciliationLine."Matching Table Name"::"Subscription Payment");
        ReconciliationLine.TestField("Matching Entry System ID", SubscrPaymentRequest.SystemId);
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Matched);

        ReconciliationHeader.Find();
        ReconciliationHeader.TestField(Status, ReconciliationHeader.Status::Matched);
    end;

    #endregion

    #region [Posting Process]

    [Test]
    procedure PostingProcess_FeeFromEFTReport()
    begin
        // [Scenario] A Fee adjustment from an EFT-style settlement report posts to the configured Fee G/L account
        AssertFeePostingPostsToFeeAccount();
    end;

    [Test]
    procedure PostingProcess_FeeFromMagentoReport()
    begin
        // [Scenario] A Fee adjustment from a Magento-style settlement report posts to the configured Fee G/L account
        AssertFeePostingPostsToFeeAccount();
    end;

    [Test]
    procedure PostingProcess_FeeFromSubscriptionReport()
    begin
        // [Scenario] A Fee adjustment from a Subscription-style settlement report posts to the configured Fee G/L account
        AssertFeePostingPostsToFeeAccount();
    end;

    [Test]
    procedure PostingProcess_FeeWithCurrencySpecificAccounts()
    var
        ReconciliationHeader: array[3] of Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: array[3] of Record "NPR Adyen Recon. Line";
        DedicatedMerchantSetup: Record "NPR Adyen Merchant Setup";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        DedicatedMerchant: Text[80];
        CurrencyCode: array[3] of Code[10];
        FeeAccount: array[3] of Code[20];
        ReconciledPaymentAccount: array[3] of Code[20];
        FeeAmount: array[3] of Decimal;
        i: Integer;
    begin
        // [Scenario] A Fee line for each of three currencies (LCY, two FCY) posts to the matching
        //            currency-specific Fee + Reconciled Payment G/L accounts from NPR Merchant Currency Setup,
        //            not the merchant-wide defaults on NPR Adyen Merchant Setup.

        // [Given] Setup, plus a dedicated merchant whose per-currency overrides are scoped to this test only.
        //         Using a separate merchant prevents the Merchant Currency Setup rows from leaking into other
        //         tests that post against the shared _MerchantAccount and assert against the default G/L accounts
        //         on NPR Adyen Merchant Setup.
        Initialize();
        DedicatedMerchant := CreateDedicatedMerchant(DedicatedMerchantSetup);

        // Pick three distinct currencies (LCY + two FCY). The FCY codes are chosen dynamically from a candidate
        // pool so the test doesn't collide with LCY in CRONUS variants where LCY happens to equal one of our
        // hardcoded picks (e.g. CRONUS Intl Ltd. uses GBP as LCY; using a hardcoded 'GBP' as CurrencyCode[3]
        // collides with CurrencyCode[1] and the second NPR Merchant Currency Setup row overwrites the first,
        // making PostEntries on header[1] post to the wrong account).
        CurrencyCode[1] := _LCYCode;
        CurrencyCode[2] := PickFCYDistinctFrom(_LCYCode, '');
        CurrencyCode[3] := PickFCYDistinctFrom(_LCYCode, CurrencyCode[2]);
        FeeAmount[1] := 4;
        FeeAmount[2] := 9;
        FeeAmount[3] := 11;

        EnsureCurrencyWithExchangeRate(CurrencyCode[2]);
        EnsureCurrencyWithExchangeRate(CurrencyCode[3]);
        for i := 1 to ArrayLen(CurrencyCode) do begin
            FeeAccount[i] := _LibraryERM.CreateGLAccountNo();
            ReconciledPaymentAccount[i] := _LibraryERM.CreateGLAccountNo();
            CreateMerchantCurrencySetup(DedicatedMerchant, CurrencyCode[i], Enum::"NPR Merchant Account"::Fee, FeeAccount[i]);
            CreateMerchantCurrencySetup(DedicatedMerchant, CurrencyCode[i], Enum::"NPR Merchant Account"::"Reconciled Payment", ReconciledPaymentAccount[i]);
        end;

        // [Given] One reconciliation header per currency with a matched Fee adjustment line in that currency,
        //         all bound to the dedicated merchant
        for i := 1 to ArrayLen(CurrencyCode) do begin
            CreateReconHeaderForMerchantAndCurrency(ReconciliationHeader[i], DedicatedMerchant, CurrencyCode[i]);
            InsertAdjustmentFeeReconLineForCurrency(ReconciliationLine[i], ReconciliationHeader[i], FeeAmount[i], CurrencyCode[i]);
            MarkHeaderMatched(ReconciliationHeader[i]);
        end;

        // [When] Posting each header
        for i := 1 to ArrayLen(CurrencyCode) do
            AdyenTransMatching.PostEntries(ReconciliationHeader[i]);

        // [Then] Each fee posted to its currency-specific Fee account and balanced to its currency-specific
        //        Reconciled Payment account — proving the NPR Merchant Currency Setup override
        for i := 1 to ArrayLen(CurrencyCode) do begin
            ReconciliationLine[i].Find();
            ReconciliationLine[i].TestField(Status, ReconciliationLine[i].Status::Posted);
            AssertFeeAndBalancingGLEntry(
              ReconciliationLine[i],
              FeeAccount[i],
              ReconciledPaymentAccount[i]);
        end;
    end;

    [Test]
    procedure PostingProcess_SubscriptionRealizedGL()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        SubscrRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        PSPReference: Code[16];
        TransactionCurrency: Code[10];
        Amount: Decimal;
        BookedAmountLCY: Decimal;
        ExchangeRate: Decimal;
        ExpectedRealizedGL: Decimal;
        BaselineLogId: Integer;
    begin
        // [Scenario] A matched cross-currency subscription line bases Realized Gains/Losses on the payment's stored
        //            "Amount (LCY)", not a re-conversion of the settlement Amount (TCY): booked LCY 90 vs rate*TCY 120 => 30.
        Initialize();
        EnsureSubscriptionAdyenGateway();
        TransactionCurrency := 'NPSUBFX'; // synthetic currency this test controls; guarantees direct-postable realized accounts
        EnsureCurrencyWithRealizedAccounts(TransactionCurrency);

        PSPReference := GenerateUniquePSPReference();
        Amount := 100;
        ExchangeRate := 1.2;
        BookedAmountLCY := 90;
        ExpectedRealizedGL := Round(ExchangeRate * Amount) - BookedAmountLCY;

        // [Given] A captured Adyen subscription payment whose stored Amount (LCY) differs from its transaction Amount
        CreateSubscrRequestForPayment(SubscrRequest);
        CreateSubscrPaymentRequestWithLCY(SubscrPaymentRequest, SubscrRequest, PSPReference, Amount, TransactionCurrency, BookedAmountLCY);

        // [Given] A cross-currency settled recon line (Transaction Currency <> Acquirer Currency), matched to that payment
        CreateReconHeader(ReconciliationHeader);
        InsertFCYSettledReconLine(ReconciliationLine, ReconciliationHeader, PSPReference, Amount, TransactionCurrency, ExchangeRate);
        AdyenTransMatching.MatchEntries(ReconciliationHeader);
        ReconciliationLine.Find();
        ReconciliationLine.TestField("Matching Table Name", ReconciliationLine."Matching Table Name"::"Subscription Payment");
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Matched);

        // [When] Posting the reconciliation document
        BaselineLogId := LastReconLogId();
        AdyenTransMatching.PostEntries(ReconciliationHeader);

        // [Then] The line posts and Realized G/L = Round(rate x Amount(TCY)) - the stored booked LCY
        ReconciliationLine.Find();
        _Assert.AreEqual(ReconciliationLine.Status::Posted, ReconciliationLine.Status, StrSubstNo('Subscription line was not posted. Root-cause reconciliation-log error: %1', GetFirstReconErrorSince(BaselineLogId)));
        _Assert.AreEqual(ExpectedRealizedGL, ReconciliationLine."Realized Gains or Losses", 'Realized G/L must use the stored Amount (LCY) as basis, not a re-conversion of Amount (TCY).');

        // [Then] The matched Subscription Payment Request is reconciled
        SubscrPaymentRequest.Find();
        SubscrPaymentRequest.TestField(Reconciled, true);
    end;

    [Test]
    procedure PostingProcess_SubscriptionChargebackRealizedGL()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        SubscrRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        ReverseSubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        PSPReference: Code[16];
        TransactionCurrency: Code[10];
        Amount: Decimal;
        BookedAmountLCY: Decimal;
        ExchangeRate: Decimal;
        ExpectedRealizedGL: Decimal;
        BaselineLogId: Integer;
    begin
        // [Scenario] A cross-currency chargeback line (negative Amount(TCY)) matches the original positive payment, so the
        //            sign-flip must follow the line: Realized G/L = Round(rate*-100) + 90 = -30, and the created reversal
        //            inherits the negated booked LCY (-90). This is the branch every cross-currency chargeback hits.
        Initialize();
        EnsureSubscriptionAdyenGateway();
        TransactionCurrency := 'NPSUBFX';
        EnsureCurrencyWithRealizedAccounts(TransactionCurrency);

        PSPReference := GenerateUniquePSPReference();
        Amount := 100;
        ExchangeRate := 1.2;
        BookedAmountLCY := 90;
        ExpectedRealizedGL := Round(ExchangeRate * -Amount) + BookedAmountLCY; // rate*(-TCY) - (-bookedLCY) = -120 + 90 = -30

        // [Given] A captured Adyen subscription payment (positive, already settled) with a known booked LCY.
        //         Reconciled = true both mirrors reality and stops CreateReverseSubscrPaymentRequest from mistaking the
        //         original for a pre-existing reverse (its lookup excludes reconciled rows) - the chargeback matcher only
        //         filters on Reversed, so the row still matches.
        CreateSubscrRequestForPayment(SubscrRequest);
        CreateSubscrPaymentRequestWithLCY(SubscrPaymentRequest, SubscrRequest, PSPReference, Amount, TransactionCurrency, BookedAmountLCY);
        SubscrPaymentRequest.Reconciled := true;
        SubscrPaymentRequest.Modify();

        // [Given] A cross-currency chargeback settlement line (negative) matched to that payment
        CreateReconHeader(ReconciliationHeader);
        InsertFCYChargebackReconLine(ReconciliationLine, ReconciliationHeader, PSPReference, Amount, TransactionCurrency, ExchangeRate);
        AdyenTransMatching.MatchEntries(ReconciliationHeader);
        ReconciliationLine.Find();
        ReconciliationLine.TestField("Matching Table Name", ReconciliationLine."Matching Table Name"::"Subscription Payment");
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Matched);

        // [When] Posting the reconciliation document
        BaselineLogId := LastReconLogId();
        AdyenTransMatching.PostEntries(ReconciliationHeader);

        // [Then] Sign-flip applied: realized G/L follows the settlement line's (negative) sign
        ReconciliationLine.Find();
        _Assert.AreEqual(ReconciliationLine.Status::Posted, ReconciliationLine.Status, StrSubstNo('Chargeback line was not posted. Root-cause reconciliation-log error: %1', GetFirstReconErrorSince(BaselineLogId)));
        _Assert.AreEqual(ExpectedRealizedGL, ReconciliationLine."Realized Gains or Losses", 'Chargeback Realized G/L must follow the settlement line sign (booked LCY negated).');

        // [Then] The original is reversed and the created reversal inherited the negated booked LCY
        SubscrPaymentRequest.Find();
        SubscrPaymentRequest.TestField(Reversed, true);
        ReverseSubscrPaymentRequest.GetBySystemId(ReconciliationLine."Matching Entry System ID");
        _Assert.AreEqual(-BookedAmountLCY, ReverseSubscrPaymentRequest."Amount (LCY)", 'The reversal should inherit the negated booked Amount (LCY).');
    end;

    local procedure AssertFeePostingPostsToFeeAccount()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        FeeAmount: Decimal;
    begin
        // [Given] Setup + a matched recon header containing a single Fee line marked as an adjustment (matched to G/L Entry)
        Initialize();
        FeeAmount := 7;
        CreateReconHeader(ReconciliationHeader);
        InsertAdjustmentFeeReconLine(ReconciliationLine, ReconciliationHeader, FeeAmount);
        MarkHeaderMatched(ReconciliationHeader);

        // [When] Running the posting pass on the header
        AdyenTransMatching.PostEntries(ReconciliationHeader);

        // [Then] The Fee recon line is posted
        ReconciliationLine.Find();
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Posted);

        // [Then] Both halves of the G/L pair exist: Fee account + Reconciled Payment account, with opposite amounts
        AssertFeeAndBalancingGLEntry(
          ReconciliationLine,
          _AdyenMerchantSetup."Fee G/L Account",
          _AdyenMerchantSetup."Reconciled Payment Acc. No.");

        // [Then] The header status is now Posted (single line was the only line and it was posted)
        ReconciliationHeader.Find();
        ReconciliationHeader.TestField(Status, ReconciliationHeader.Status::Posted);
    end;

    local procedure AssertFeeAndBalancingGLEntry(ReconciliationLine: Record "NPR Adyen Recon. Line"; ExpectedFeeAccount: Code[20]; ExpectedReconciledPaymentAccount: Code[20])
    var
        ReconRelation: Record "NPR Adyen Recons.Line Relation";
        FeeGLEntry: Record "G/L Entry";
        BalancingGLEntry: Record "G/L Entry";
        AmountType: Enum "NPR Adyen Recon. Amount Type";
        ExpectedFeeAmountLCY: Decimal;
    begin
        // [Then] A recon-line-relation row of Amount Type 'Fee' was created with the line's Amount(AAC)
        ReconRelation.SetRange("Document No.", ReconciliationLine."Document No.");
        ReconRelation.SetRange("Document Line No.", ReconciliationLine."Line No.");
        ReconRelation.SetRange("Amount Type", AmountType::Fee);
        ReconRelation.FindFirst();
        ReconRelation.TestField(Amount, ReconciliationLine."Amount(AAC)");

        // [Then] The G/L Entry referenced by the relation hit the expected Fee G/L Account
        FeeGLEntry.Get(ReconRelation."GL Entry No.");
        FeeGLEntry.TestField("G/L Account No.", ExpectedFeeAccount);

        // [Then] Fee posting recorded -Amount(AAC) (positive fee value) against the Fee account in LCY
        ExpectedFeeAmountLCY := -ReconciliationLine."Amount(AAC)";
        FeeGLEntry.TestField(Amount, ExpectedFeeAmountLCY);

        // [Then] A balancing G/L Entry exists in the same transaction targeting the Reconciled Payment account
        BalancingGLEntry.SetRange("Transaction No.", FeeGLEntry."Transaction No.");
        BalancingGLEntry.SetRange("G/L Account No.", ExpectedReconciledPaymentAccount);
        BalancingGLEntry.FindFirst();
        BalancingGLEntry.TestField(Amount, -ExpectedFeeAmountLCY);
    end;

    #endregion

    #region [Reconcile Process]

    [Test]
    procedure ReconcileProcess_EFT()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        PSPReference: Code[16];
        Amount: Decimal;
    begin
        // [Scenario] When automatic posting is disabled, running the Reconcile pass on a matched EFT line
        //            marks the EFT Transaction Request as Reconciled and the recon line/header as Reconciled

        // [Given] Setup with automatic posting disabled (forcing the Reconcile path instead of Post)
        Initialize();
        SetEnableAutomaticPosting(false);
        PSPReference := GenerateUniquePSPReference();
        Amount := 60;

        CreateEFTTransactionRequest(EFTTransactionRequest, PSPReference, Amount);
        CreateReconHeader(ReconciliationHeader);
        InsertSettledReconLine(ReconciliationLine, ReconciliationHeader, PSPReference, Amount);

        // [Given] The line has been matched to the EFT Transaction Request
        AdyenTransMatching.MatchEntries(ReconciliationHeader);

        // [When] Running the reconcile pass
        AdyenTransMatching.ReconcileEntries(ReconciliationHeader);

        // [Then] The matched EFT Transaction Request is now flagged as Reconciled with today's date
        EFTTransactionRequest.Find();
        EFTTransactionRequest.TestField(Reconciled, true);
        EFTTransactionRequest.TestField("Reconciliation Date", Today());

        // [Then] The recon line + header are both Reconciled
        ReconciliationLine.Find();
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Reconciled);
        ReconciliationHeader.Find();
        ReconciliationHeader.TestField(Status, ReconciliationHeader.Status::Reconciled);
    end;

    [Test]
    procedure ReconcileProcess_Magento()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        PSPReference: Code[16];
        Amount: Decimal;
    begin
        // [Scenario] Running the Reconcile pass on a matched Magento line marks the Magento Payment Line as Reconciled

        Initialize();
        SetEnableAutomaticPosting(false);
        PSPReference := GenerateUniquePSPReference();
        Amount := 140;

        CreateMagentoPaymentLine(MagentoPaymentLine, PSPReference, Amount);
        CreateReconHeader(ReconciliationHeader);
        InsertSettledReconLine(ReconciliationLine, ReconciliationHeader, PSPReference, Amount);

        AdyenTransMatching.MatchEntries(ReconciliationHeader);
        AdyenTransMatching.ReconcileEntries(ReconciliationHeader);

        MagentoPaymentLine.Find();
        MagentoPaymentLine.TestField(Reconciled, true);
        MagentoPaymentLine.TestField("Reconciliation Date", Today());

        ReconciliationLine.Find();
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Reconciled);
        ReconciliationHeader.Find();
        ReconciliationHeader.TestField(Status, ReconciliationHeader.Status::Reconciled);
    end;

    [Test]
    procedure ReconcileProcess_Subscription()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        PSPReference: Code[16];
        Amount: Decimal;
    begin
        // [Scenario] Running the Reconcile pass on a matched Subscription line marks the Subscr. Payment Request as Reconciled

        Initialize();
        SetEnableAutomaticPosting(false);
        PSPReference := GenerateUniquePSPReference();
        Amount := 35;

        CreateSubscrPaymentRequest(SubscrPaymentRequest, PSPReference, Amount);
        CreateReconHeader(ReconciliationHeader);
        InsertSettledReconLine(ReconciliationLine, ReconciliationHeader, PSPReference, Amount);

        AdyenTransMatching.MatchEntries(ReconciliationHeader);
        AdyenTransMatching.ReconcileEntries(ReconciliationHeader);

        SubscrPaymentRequest.Find();
        SubscrPaymentRequest.TestField(Reconciled, true);
        SubscrPaymentRequest.TestField("Reconciliation Date", Today());

        ReconciliationLine.Find();
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Reconciled);
        ReconciliationHeader.Find();
        ReconciliationHeader.TestField(Status, ReconciliationHeader.Status::Reconciled);
    end;

    #endregion

    #region [Reverse Postings]

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ReversePostings_RevertsLineStatusAndReversesGLEntries()
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        ReconRelation: Record "NPR Adyen Recons.Line Relation";
        OriginalGLEntry: Record "G/L Entry";
        ReversingGLEntry: Record "G/L Entry";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        AmountType: Enum "NPR Adyen Recon. Amount Type";
        FeeAmount: Decimal;
    begin
        // [Scenario] Calling Reverse Postings on a posted reconciliation document creates reversal G/L entries,
        //            marks the relation rows as Reversed, and rolls the recon line/header status back to Matched

        // [Given] A fully-posted reconciliation header with a single Fee adjustment line
        Initialize();
        FeeAmount := 8;
        CreateReconHeader(ReconciliationHeader);
        InsertAdjustmentFeeReconLine(ReconciliationLine, ReconciliationHeader, FeeAmount);
        MarkHeaderMatched(ReconciliationHeader);
        AdyenTransMatching.PostEntries(ReconciliationHeader);

        ReconciliationLine.Find();
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Posted);

        // [Given] The Fee G/L Entry id from the posting (used later to confirm reversal)
        ReconRelation.SetRange("Document No.", ReconciliationLine."Document No.");
        ReconRelation.SetRange("Document Line No.", ReconciliationLine."Line No.");
        ReconRelation.SetRange("Amount Type", AmountType::Fee);
        ReconRelation.FindFirst();
        OriginalGLEntry.Get(ReconRelation."GL Entry No.");

        // [When] Reversing the document's postings
        AdyenTransMatching.ReversePostings(ReconciliationHeader);

        // [Then] The relation row is flagged Reversed
        ReconRelation.Find();
        ReconRelation.TestField(Reversed, true);

        // [Then] A reversing G/L Entry exists for the original Fee account with the opposite amount
        ReversingGLEntry.SetRange("G/L Account No.", OriginalGLEntry."G/L Account No.");
        ReversingGLEntry.SetRange(Amount, -OriginalGLEntry.Amount);
        ReversingGLEntry.SetFilter("Entry No.", '>%1', OriginalGLEntry."Entry No.");
        _Assert.IsFalse(ReversingGLEntry.IsEmpty(), 'Expected a reversing G/L Entry on the Fee account with the opposite amount of the original posting');

        // [Then] The original G/L Entry is now flagged Reversed by BC
        OriginalGLEntry.Find();
        OriginalGLEntry.TestField(Reversed, true);

        // [Then] The recon line status is rolled back from Posted to Matched, posting fields cleared
        ReconciliationLine.Find();
        ReconciliationLine.TestField(Status, ReconciliationLine.Status::Matched);
        ReconciliationLine.TestField("Posting No.", '');
        ReconciliationLine.TestField("Posting Date", 0D);

        // [Then] The header status is rolled back to Matched
        ReconciliationHeader.Find();
        ReconciliationHeader.TestField(Status, ReconciliationHeader.Status::Matched);
    end;

    #endregion

    #region [Webhook Chain]

    [Test]
    procedure WebhookChain_ReportAvailable_EmulatesFullPipeline()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        AFRecWebhookRequest: Record "NPR AF Rec. Webhook Request";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconciliationLine: Record "NPR Adyen Recon. Line";
        ProcessReportReady: Codeunit "NPR Adyen Process Report Ready";
        AdyenRecReportProcess: Codeunit "NPR Adyen Rec. Report Process";
        WebhookReference: Code[80];
        ReportFileName: Text;
        ReportURL: Text;
        BatchNumber: Integer;
        PSPReference: Code[16];
        SettledAmount: Decimal;
        FeeAmount: Decimal;
    begin
        // [Scenario] Emulate the REPORT_AVAILABLE webhook chain: a recorded NPR Adyen Webhook of that event code
        //            is processed by NPR Adyen Process Report Ready, which spawns an NPR AF Rec. Webhook Request,
        //            which the report-process codeunit then turns into a reconciliation document + lines.

        // [Given] Setup, a unique batch + PSP reference, and an XLSX prepared as the report file
        Initialize();
        BatchNumber := GenerateUniqueBatchNumber();
        PSPReference := GenerateUniquePSPReference();
        WebhookReference := CopyStr('WHREF-' + Format(BatchNumber), 1, MaxStrLen(WebhookReference));
        SettledAmount := 200;
        FeeAmount := 4;
        ReportFileName := 'settlement_detail_batch_' + Format(BatchNumber) + '.xlsx';
        ReportURL := 'https://test.invalid/' + Format(BatchNumber) + '/' + ReportFileName;

        // [Given] An NPR Adyen Webhook row of event REPORT_AVAILABLE with a JSON blob pointing at the report URL.
        //         This is what NPR Adyen Management would persist after a successful NPR AF Rec. API Request.ReceiveWebhook call;
        //         we skip the ValidateWebhookReference HTTP round-trip to Adyen since it is unreachable in tests.
        InitAdyenWebhookRecord(AdyenWebhook, WebhookReference, ReportURL, PSPReference);

        // [When] The job-queue handler for REPORT_AVAILABLE processes the webhook
        ProcessReportReady.ProcessReportReadyWebhook(AdyenWebhook);

        // [Then] The webhook is now marked Processed and a reconciliation webhook request was created from it
        AdyenWebhook.Find();
        AdyenWebhook.TestField(Status, AdyenWebhook.Status::Processed);

        AFRecWebhookRequest.SetRange("Adyen Webhook Entry No.", AdyenWebhook."Entry No.");
        AFRecWebhookRequest.FindFirst();
        AFRecWebhookRequest.TestField("Report Download URL", CopyStr(ReportURL, 1, MaxStrLen(AFRecWebhookRequest."Report Download URL")));
        AFRecWebhookRequest.TestField("Report Name", CopyStr(ReportFileName, 1, MaxStrLen(AFRecWebhookRequest."Report Name")));
        AFRecWebhookRequest.TestField("Report Type", AFRecWebhookRequest."Report Type"::"Settlement details");

        // [Given] The XLSX is injected as the request's Report Data blob (substituting for the live HTTP download
        //         that the report-process codeunit would otherwise attempt). The URL is flipped to the local-upload marker.
        InjectReportBlob(AFRecWebhookRequest, BatchNumber, PSPReference, 'CHAIN-ORDER-' + Format(BatchNumber), SettledAmount, FeeAmount);

        // [When] The report-process codeunit imports + matches + posts the now-populated request
        AdyenRecReportProcess.Run(AFRecWebhookRequest);

        // [Then] A reconciliation header was created for this batch + merchant
        ReconciliationHeader.SetRange("Batch Number", BatchNumber);
        ReconciliationHeader.SetRange("Merchant Account", _MerchantAccount);
        ReconciliationHeader.FindFirst();
        ReconciliationHeader.TestField("Document Type", ReconciliationHeader."Document Type"::"Settlement details");

        // [Then] The Settled + Fee lines from the XLSX were imported correctly
        ReconciliationLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        _Assert.AreEqual(2, ReconciliationLine.Count(), 'Expected exactly two recon lines (Settled + Fee) created from the report referenced by the webhook');

        ReconciliationLine.SetRange("Transaction Type", ReconciliationLine."Transaction Type"::Settled);
        ReconciliationLine.FindFirst();
        ReconciliationLine.TestField("PSP Reference", PSPReference);
        ReconciliationLine.TestField("Amount (TCY)", SettledAmount);
    end;

    #endregion

    #region [Setup]

    local procedure Initialize()
    begin
        // Persistence contract:
        //   The BC test framework rolls back each [Test] procedure's changes implicitly. To keep the codeunit's
        //   shared fixtures alive across tests we Commit() once on first call and short-circuit thereafter via
        //   _Initialized. As a result, the records inserted below survive the whole codeunit run AND any later
        //   re-run against the same database:
        //     - NPR Adyen Setup            (singleton, primary key '')
        //     - NPR Adyen Merchant Account (key = randomized merchant name, fresh per session)
        //     - NPR Adyen Merchant Setup   (same merchant key)
        //     - No. Series + No. Series Line for reconciliation + posting document nos.
        //     - NPR Magento Payment Gateway 'ADYENTEST' (idempotent insert)
        //     - Currency + Currency Exchange Rate rows for _NetCurrency at Today() (overwritten to 1:1)
        //   We deliberately do NOT mutate the LCY code on General Ledger Setup here — tests run against
        //   whatever LCY the company already has configured. The exchange-rate row at Today() does get
        //   overwritten, but only for currencies we control via this codeunit's helpers.
        if not _Initialized then begin
            _NetCurrency := 'EUR';
            LoadLCYCode();
            EnsureCurrencyWithExchangeRate(_NetCurrency);
            InitAdyenSetup();
            _MerchantAccount := CopyStr('TestMerch-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 80);
            InitMerchantAccount(_MerchantAccount);
            InitMerchantSetup(_MerchantAccount, _AdyenMerchantSetup);
            EnsureAdyenPaymentGateway();
            _Initialized := true;
            Commit();
        end;

        // Reset the Enable Automatic Posting flag to true on every Initialize call. The Reconcile tests flip
        // it to false but the BC test framework runs all [Test] procs in the same codeunit instance, so
        // _Initialized stays true and later tests would otherwise inherit the flipped state — making any
        // test that goes through NPR Adyen Rec. Report Process silently take the Reconcile branch instead of
        // the Post branch.
        SetEnableAutomaticPosting(true);
    end;

    local procedure InitAdyenSetup()
    var
        ReconNoSeries: Record "No. Series";
        PostingNoSeries: Record "No. Series";
        ReconNoSeriesLine: Record "No. Series Line";
        PostingNoSeriesLine: Record "No. Series Line";
    begin
        if _AdyenSetup.Get() then begin
            EnsureNoSeries(_AdyenSetup."Reconciliation Document Nos.", 'NPRAR');
            EnsureNoSeries(_AdyenSetup."Posting Document Nos.", 'NPRAP');
            if not _AdyenSetup."Enable Automatic Posting" then begin
                _AdyenSetup."Enable Automatic Posting" := true;
                _AdyenSetup.Modify();
            end;
            exit;
        end;
        _LibraryUtility.CreateNoSeries(ReconNoSeries, true, false, false);
        _LibraryUtility.CreateNoSeriesLine(ReconNoSeriesLine, ReconNoSeries.Code, 'NPRAR-0001', 'NPRAR-9999');
        _LibraryUtility.CreateNoSeries(PostingNoSeries, true, false, false);
        _LibraryUtility.CreateNoSeriesLine(PostingNoSeriesLine, PostingNoSeries.Code, 'NPRAP-0001', 'NPRAP-9999');
        _AdyenSetup.Init();
        _AdyenSetup."Primary Key" := '';
        _AdyenSetup."Enable Reconciliation" := true;
        _AdyenSetup."Enable Reconcil. Automation" := false;
        _AdyenSetup."Reconciliation Document Nos." := ReconNoSeries.Code;
        _AdyenSetup."Posting Document Nos." := PostingNoSeries.Code;
        _AdyenSetup."Enable Automatic Posting" := true;
        _AdyenSetup.Insert();
    end;

    local procedure SetEnableAutomaticPosting(Value: Boolean)
    begin
        // Toggle the setup field so tests can choose between the Post (true) and Reconcile (false) automation paths.
        // Each test instantiates its own AdyenTransMatching codeunit, so the in-codeunit GetRecordOnce cache picks
        // up this DB change on the next call.
        _AdyenSetup.Get();
        if _AdyenSetup."Enable Automatic Posting" = Value then
            exit;
        _AdyenSetup."Enable Automatic Posting" := Value;
        _AdyenSetup.Modify();
        Commit();
    end;

    local procedure EnsureNoSeries(NoSeriesCode: Code[20]; StartPrefix: Code[10])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeriesCode = '' then
            exit;
        if not NoSeries.Get(NoSeriesCode) then begin
            NoSeries.Init();
            NoSeries.Code := NoSeriesCode;
            NoSeries."Default Nos." := true;
            NoSeries.Insert();
        end;
        NoSeriesLine.SetRange("Series Code", NoSeriesCode);
        if NoSeriesLine.IsEmpty() then
            _LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeriesCode, StartPrefix + '0001', StartPrefix + '9999');
    end;

    local procedure InitMerchantAccount(MerchantAccount: Text[80])
    var
        AdyenMerchantAccount: Record "NPR Adyen Merchant Account";
    begin
        if AdyenMerchantAccount.Get(MerchantAccount) then
            exit;
        AdyenMerchantAccount.Init();
        AdyenMerchantAccount.Name := MerchantAccount;
        AdyenMerchantAccount."Company ID" := CopyStr(_CompanyAccountLbl, 1, MaxStrLen(AdyenMerchantAccount."Company ID"));
        AdyenMerchantAccount.Insert();
    end;

    local procedure InitMerchantSetup(MerchantAccount: Text[80]; var AdyenMerchantSetup: Record "NPR Adyen Merchant Setup")
    begin
        if AdyenMerchantSetup.Get(MerchantAccount) then
            exit;
        AdyenMerchantSetup.Init();
        AdyenMerchantSetup."Primary Key" := '';
        AdyenMerchantSetup."Merchant Account" := MerchantAccount;
        AdyenMerchantSetup."Deposit G/L Account" := _LibraryERM.CreateGLAccountNo();
        AdyenMerchantSetup."Fee G/L Account" := _LibraryERM.CreateGLAccountNo();
        AdyenMerchantSetup."Markup G/L Account" := _LibraryERM.CreateGLAccountNo();
        AdyenMerchantSetup."Other commissions G/L Account" := _LibraryERM.CreateGLAccountNo();
        AdyenMerchantSetup."Invoice Deduction G/L Account" := _LibraryERM.CreateGLAccountNo();
        AdyenMerchantSetup."Merchant Payout Acc. Type" := AdyenMerchantSetup."Merchant Payout Acc. Type"::"G/L Account";
        AdyenMerchantSetup."Merchant Payout Acc. No." := _LibraryERM.CreateGLAccountNo();
        AdyenMerchantSetup."Reconciled Payment Acc. Type" := AdyenMerchantSetup."Reconciled Payment Acc. Type"::"G/L Account";
        AdyenMerchantSetup."Reconciled Payment Acc. No." := _LibraryERM.CreateGLAccountNo();
        AdyenMerchantSetup."Chargeback Fees G/L Account" := _LibraryERM.CreateGLAccountNo();
        AdyenMerchantSetup.Insert();
    end;

    local procedure CreateMerchantCurrencySetup(MerchantAccount: Text[80]; CurrencyCode: Code[10]; AccountType: Enum "NPR Merchant Account"; AccountNo: Code[20])
    var
        MerchantCurrencySetup: Record "NPR Merchant Currency Setup";
    begin
        if MerchantCurrencySetup.Get(MerchantAccount, AccountType, CurrencyCode) then begin
            MerchantCurrencySetup."Account Type" := MerchantCurrencySetup."Account Type"::"G/L Account";
            MerchantCurrencySetup."Account No." := AccountNo;
            MerchantCurrencySetup.Modify();
            exit;
        end;
        MerchantCurrencySetup.Init();
        MerchantCurrencySetup."Merchant Account Name" := MerchantAccount;
        MerchantCurrencySetup."Reconciliation Account Type" := AccountType;
        MerchantCurrencySetup."NP Pay Currency Code" := CurrencyCode;
        MerchantCurrencySetup."Account Type" := MerchantCurrencySetup."Account Type"::"G/L Account";
        MerchantCurrencySetup."Account No." := AccountNo;
        MerchantCurrencySetup.Insert();
    end;

    local procedure LoadLCYCode()
    var
        GLSetup: Record "General Ledger Setup";
    begin
        // Read the company's LCY without mutating it. A previous version of this helper set LCY to 'DKK' when
        // unset, which would silently persist that mutation in the database forever. Tests now require the host
        // company to already have an LCY configured (CRONUS-style databases always do) and fail loudly otherwise.
        GLSetup.Get();
        GLSetup.TestField("LCY Code");
        _LCYCode := GLSetup."LCY Code";
    end;

    local procedure EnsureCurrency(CurrencyCode: Code[10])
    var
        Currency: Record Currency;
    begin
        if Currency.Get(CurrencyCode) then
            exit;
        Currency.Init();
        Currency.Code := CurrencyCode;
        Currency.Description := CurrencyCode;
        Currency."ISO Code" := CopyStr(CurrencyCode, 1, MaxStrLen(Currency."ISO Code"));
        Currency.Insert();
    end;

    local procedure EnsureCurrencyWithExchangeRate(CurrencyCode: Code[10])
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        // Force today's rate to 1:1 so the LCY value posted to the G/L Entry equals the FCY value the recon
        // line was tested with. BC picks the latest rate where Starting Date <= Posting Date, so an upsert at
        // Today() (with posting also at Today()) is what every test in this codeunit observes — regardless of
        // any older historic rates already present in the demo company.
        EnsureCurrency(CurrencyCode);
        if CurrencyCode = _LCYCode then
            exit;
        if not CurrencyExchangeRate.Get(CurrencyCode, Today()) then begin
            CurrencyExchangeRate.Init();
            CurrencyExchangeRate."Currency Code" := CurrencyCode;
            CurrencyExchangeRate."Starting Date" := Today();
            CurrencyExchangeRate.Insert();
        end;
        CurrencyExchangeRate."Exchange Rate Amount" := 1;
        CurrencyExchangeRate."Adjustment Exch. Rate Amount" := 1;
        CurrencyExchangeRate."Relational Exch. Rate Amount" := 1;
        CurrencyExchangeRate."Relational Adjmt Exch Rate Amt" := 1;
        CurrencyExchangeRate.Modify();
    end;

    local procedure EnsureAdyenPaymentGateway()
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        // Filter by Integration Type = Adyen in ALL versions. The "Integration Type" field and the Adyen enum
        // value at ordinal 1 both exist for every supported BC version (only the Shopify value at ordinal 10 is
        // BC18+). If we skipped the filter on BC17 — or skipped setting Integration Type on the row we insert —
        // we would either (a) exit early when CRONUS already has a non-Adyen Magento Payment Gateway like PayPal,
        // or (b) create a gateway with ordinal 0 Integration Type that the production Magento matcher then filters
        // out, breaking Magento matching/reconciliation tests.
        PaymentGateway.SetRange("Integration Type", Enum::"NPR PG Integrations"::Adyen);
        if not PaymentGateway.IsEmpty() then
            exit;
        PaymentGateway.Init();
        PaymentGateway.Code := 'ADYENTEST';
        PaymentGateway."Integration Type" := Enum::"NPR PG Integrations"::Adyen;
        PaymentGateway.Description := 'Adyen Test Gateway';
        PaymentGateway.Insert();
    end;

    #endregion

    #region [Fixture helpers]

    local procedure CreateReconHeader(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr")
    begin
        CreateReconHeaderForMerchantAndCurrency(ReconciliationHeader, _MerchantAccount, _NetCurrency);
    end;

    local procedure CreateReconHeaderForCurrency(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; CurrencyCode: Code[10])
    begin
        CreateReconHeaderForMerchantAndCurrency(ReconciliationHeader, _MerchantAccount, CurrencyCode);
    end;

    local procedure CreateReconHeaderForMerchantAndCurrency(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; MerchantAccount: Text[80]; CurrencyCode: Code[10])
    var
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23)
        NoSeriesMgt: Codeunit "No. Series";
#else
        NoSeriesMgt: Codeunit NoSeriesManagement;
#endif
    begin
        ReconciliationHeader.Init();
        ReconciliationHeader."Document No." := CopyStr(NoSeriesMgt.GetNextNo(_AdyenSetup."Reconciliation Document Nos.", Today(), true), 1, 20);
        ReconciliationHeader."Document Type" := ReconciliationHeader."Document Type"::"Settlement details";
        ReconciliationHeader."Document Date" := Today();
        ReconciliationHeader."Posting Date" := Today();
        ReconciliationHeader."Batch Number" := GenerateUniqueBatchNumber();
        ReconciliationHeader."Merchant Account" := MerchantAccount;
        ReconciliationHeader."Adyen Acc. Currency Code" := CurrencyCode;
        ReconciliationHeader.Insert();
    end;

    local procedure PickFCYDistinctFrom(Excluded1: Code[10]; Excluded2: Code[10]): Code[10]
    var
        Candidates: array[6] of Code[10];
        i: Integer;
    begin
        // Returns the first three-letter ISO code from the candidate pool that is neither Excluded1 nor Excluded2.
        // Used by PostingProcess_FeeWithCurrencySpecificAccounts to pick FCY codes that don't collide with LCY
        // (or each other) regardless of which demo company the test runs against.
        Candidates[1] := 'EUR';
        Candidates[2] := 'USD';
        Candidates[3] := 'GBP';
        Candidates[4] := 'DKK';
        Candidates[5] := 'SEK';
        Candidates[6] := 'NOK';
        for i := 1 to ArrayLen(Candidates) do
            if (Candidates[i] <> Excluded1) and (Candidates[i] <> Excluded2) then
                exit(Candidates[i]);
    end;

    local procedure CreateDedicatedMerchant(var DedicatedMerchantSetup: Record "NPR Adyen Merchant Setup") MerchantAccount: Text[80]
    begin
        // Builds a fresh merchant account + default NPR Adyen Merchant Setup, used by tests that need to mutate
        // merchant-scoped configuration (e.g. NPR Merchant Currency Setup overrides) without contaminating the
        // shared _MerchantAccount.
        MerchantAccount := CopyStr('TestMerchCC-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 80);
        InitMerchantAccount(MerchantAccount);
        InitMerchantSetup(MerchantAccount, DedicatedMerchantSetup);
    end;

    local procedure MarkHeaderMatched(var ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr")
    begin
        ReconciliationHeader.Find();
        ReconciliationHeader.Status := ReconciliationHeader.Status::Matched;
        ReconciliationHeader.Modify();
    end;

    local procedure InsertSettledReconLine(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; PSPReference: Code[16]; Amount: Decimal)
    begin
        InitReconLineForHeader(ReconciliationLine, ReconciliationHeader);
        ReconciliationLine."PSP Reference" := PSPReference;
        ReconciliationLine."Merchant Reference" := CopyStr('REF-' + Format(ReconciliationLine."Line No."), 1, MaxStrLen(ReconciliationLine."Merchant Reference"));
        ReconciliationLine."Merchant Order Reference" := CopyStr('ORD-' + Format(ReconciliationLine."Line No."), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
        ReconciliationLine."Transaction Date" := CreateDateTime(Today(), Time());
        ReconciliationLine."Transaction Currency Code" := _NetCurrency;
        ReconciliationLine."Adyen Acc. Currency Code" := _NetCurrency;
        ReconciliationLine.Validate("Gross Credit", Amount);
        ReconciliationLine.Validate("Net Credit", Amount);
        ReconciliationLine."Amount (LCY)" := ReconciliationLine."Amount(AAC)";
        ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::Settled;
        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"To Be Determined";
        ReconciliationLine.Status := ReconciliationLine.Status::" ";
        ReconciliationLine.Insert();
    end;

    local procedure InsertAdjustmentFeeReconLine(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; FeeAmount: Decimal)
    begin
        InsertAdjustmentFeeReconLineForCurrency(ReconciliationLine, ReconciliationHeader, FeeAmount, _NetCurrency);
    end;

    local procedure InsertAdjustmentFeeReconLineForCurrency(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; FeeAmount: Decimal; CurrencyCode: Code[10])
    begin
        InitReconLineForHeader(ReconciliationLine, ReconciliationHeader);
        ReconciliationLine."Merchant Reference" := CopyStr('FEE-' + Format(ReconciliationLine."Line No."), 1, MaxStrLen(ReconciliationLine."Merchant Reference"));
        ReconciliationLine."Merchant Order Reference" := CopyStr('FEEORD-' + Format(ReconciliationLine."Line No."), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
        ReconciliationLine."Modification Reference" := 'feeRef-' + Format(ReconciliationLine."Line No.");
        ReconciliationLine."Transaction Date" := CreateDateTime(Today(), Time());
        ReconciliationLine."Transaction Currency Code" := CurrencyCode;
        ReconciliationLine."Adyen Acc. Currency Code" := CurrencyCode;
        ReconciliationLine.Validate("Net Debit", FeeAmount);
        ReconciliationLine."Amount (LCY)" := ReconciliationLine."Amount(AAC)";
        ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::Fee;
        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"G/L Entry";
        ReconciliationLine.Status := ReconciliationLine.Status::"Not to be Matched";
        ReconciliationLine.Insert();
    end;

    local procedure InitReconLineForHeader(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr")
    var
        ExistingReconLine: Record "NPR Adyen Recon. Line";
    begin
        ExistingReconLine.SetRange("Document No.", ReconciliationHeader."Document No.");
        ReconciliationLine.Init();
        ReconciliationLine."Document No." := ReconciliationHeader."Document No.";
        ReconciliationLine."Line No." := 1;
        if ExistingReconLine.FindLast() then
            ReconciliationLine."Line No." := ExistingReconLine."Line No." + 1;
        ReconciliationLine."Merchant Account" := ReconciliationHeader."Merchant Account";
        ReconciliationLine."Batch Number" := ReconciliationHeader."Batch Number";
    end;

    local procedure CreateEFTTransactionRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; PSPReference: Code[16]; Amount: Decimal)
    var
        AdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integrat.";
        SalesTicketNo: Code[20];
    begin
        // Give the request a unique Sales Ticket No. and create a matching POS Entry so the FlowField
        // "FF Moved to POS Entry" (Exist NPR POS Entry where Document No. = Sales Ticket No.) is true.
        // PostingOrReconcilingAllowed gates the EFT reconcile path on that flag; without a POS Entry it
        // marks the line as Failed to Reconcile with a "Sale not finished" log entry.
        SalesTicketNo := CopyStr('EFTT-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20);
        EnsurePOSEntryFor(SalesTicketNo);

        EFTTransactionRequest.Init();
        EFTTransactionRequest."Entry No." := 0;
        EFTTransactionRequest."Integration Type" := AdyenCloudIntegration.IntegrationType();
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::PAYMENT;
        EFTTransactionRequest."PSP Reference" := PSPReference;
        EFTTransactionRequest."Result Amount" := Amount;
        EFTTransactionRequest."Amount Input" := Amount;
        EFTTransactionRequest."Amount Output" := Amount;
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."Result Processed" := true;
        EFTTransactionRequest."External Result Known" := true;
        EFTTransactionRequest."Financial Impact" := true;
        EFTTransactionRequest."Currency Code" := _NetCurrency;
        EFTTransactionRequest."Sales Ticket No." := SalesTicketNo;
        EFTTransactionRequest."Sales Line ID" := CreateGuid();
        EFTTransactionRequest."Transaction Date" := Today();
        EFTTransactionRequest."Transaction Time" := Time();
        EFTTransactionRequest.Finished := CurrentDateTime();
        EFTTransactionRequest.Insert();
    end;

    local procedure EnsurePOSEntryFor(SalesTicketNo: Code[20])
    var
        POSEntry: Record "NPR POS Entry";
    begin
        POSEntry.SetRange("Document No.", SalesTicketNo);
        if not POSEntry.IsEmpty() then
            exit;
        POSEntry.Init();
        POSEntry."Entry No." := 0;
        POSEntry."Document No." := SalesTicketNo;
        POSEntry."Entry Date" := Today();
        POSEntry."Entry Type" := POSEntry."Entry Type"::"Direct Sale";
        POSEntry.Insert();
    end;

    local procedure CreateMagentoPaymentLine(var MagentoPaymentLine: Record "NPR Magento Payment Line"; PSPReference: Code[16]; Amount: Decimal)
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        DocumentNo: Code[20];
    begin
        // Filter by Integration Type = Adyen unconditionally — the production Magento matcher filters by
        // Adyen|Shopify, so the Payment Gateway Code we stamp on the test row must point at an Adyen-typed
        // gateway. Without this filter, FindFirst() may return a pre-existing non-Adyen gateway from the
        // demo company, and the matcher's FilterPGCodes would exclude our row.
        PaymentGateway.SetRange("Integration Type", Enum::"NPR PG Integrations"::Adyen);
        PaymentGateway.FindFirst();

        DocumentNo := CopyStr('MAG-' + DelChr(Format(CreateGuid()), '=', '{}-'), 1, 20);

        MagentoPaymentLine.Init();
        MagentoPaymentLine."Document Table No." := 0;
        MagentoPaymentLine."Document Type" := MagentoPaymentLine."Document Type"::Order;
        MagentoPaymentLine."Document No." := DocumentNo;
        MagentoPaymentLine."Line No." := 10000;
        MagentoPaymentLine."Transaction ID" := PSPReference;
        MagentoPaymentLine."External Reference No." := PSPReference;
        MagentoPaymentLine.Amount := Amount;
        MagentoPaymentLine."Payment Gateway Code" := PaymentGateway.Code;
        MagentoPaymentLine."Account Type" := MagentoPaymentLine."Account Type"::"G/L Account";
        MagentoPaymentLine."Account No." := _LibraryERM.CreateGLAccountNo();
        MagentoPaymentLine."Posting Date" := Today();
        MagentoPaymentLine.Reconciled := false;
        MagentoPaymentLine.Reversed := false;
        MagentoPaymentLine.Insert();
    end;

    local procedure CreateSubscrPaymentRequest(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; PSPReference: Code[16]; Amount: Decimal)
    begin
        SubscrPaymentRequest.Init();
        SubscrPaymentRequest."Entry No." := 0;
        SubscrPaymentRequest."Batch No." := 0;
        SubscrPaymentRequest.Type := SubscrPaymentRequest.Type::Payment;
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::Captured;
        SubscrPaymentRequest.PSP := SubscrPaymentRequest.PSP::Adyen;
        SubscrPaymentRequest."PSP Reference" := PSPReference;
        SubscrPaymentRequest.Amount := Amount;
        SubscrPaymentRequest."Currency Code" := _NetCurrency;
        SubscrPaymentRequest.Reconciled := false;
        SubscrPaymentRequest.Reversed := false;
        SubscrPaymentRequest.Insert();
    end;

    local procedure LastReconLogId(): Integer
    var
        ReconciliationLog: Record "NPR Adyen Reconciliation Log";
    begin
        if ReconciliationLog.FindLast() then
            exit(ReconciliationLog.ID);
        exit(0);
    end;

    local procedure GetFirstReconErrorSince(AfterLogId: Integer): Text
    var
        ReconciliationLog: Record "NPR Adyen Reconciliation Log";
    begin
        // First failure of the run: the specific cause is logged before the generic "Couldn't post N entries" summary.
        ReconciliationLog.SetFilter(ID, '>%1', AfterLogId);
        ReconciliationLog.SetRange(Success, false);
        if ReconciliationLog.FindFirst() then
            exit(ReconciliationLog.Description);
        exit('(no failed reconciliation-log entry found)');
    end;

    local procedure EnsureSubscriptionAdyenGateway()
    var
        SubsPaymentGateway: Record "NPR MM Subs. Payment Gateway";
        SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup";
    begin
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
            SubsAdyenPGSetup."Payment Account No." := _LibraryERM.CreateGLAccountNo();
            SubsAdyenPGSetup.Environment := SubsAdyenPGSetup.Environment::Test;
            SubsAdyenPGSetup."Merchant Name" := 'TestMerchant';
            SubsAdyenPGSetup.Insert();
        end else begin
            // Refresh to a fresh account: the sibling MMSubscrPostDimTests stamps a mandatory dimension on its account, which
            // this test (DimensionSetID = 0) cannot satisfy - reusing it would make the outcome depend on test run order.
            SubsAdyenPGSetup."Payment Account No." := _LibraryERM.CreateGLAccountNo();
            SubsAdyenPGSetup.Modify();
        end;
    end;

    local procedure EnsureCurrencyWithRealizedAccounts(CurrencyCode: Code[10])
    var
        Currency: Record Currency;
    begin
        EnsureCurrencyWithExchangeRate(CurrencyCode);
        Currency.Get(CurrencyCode);
        Currency."Realized Gains Acc." := EnsureDirectPostingAccount(Currency."Realized Gains Acc.");
        Currency."Realized Losses Acc." := EnsureDirectPostingAccount(Currency."Realized Losses Acc.");
        Currency.Modify();
    end;

    local procedure EnsureDirectPostingAccount(AccountNo: Code[20]): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        if (AccountNo <> '') and GLAccount.Get(AccountNo) and GLAccount."Direct Posting" then
            exit(AccountNo);
        exit(_LibraryERM.CreateGLAccountNo());
    end;

    local procedure CreateSubscrRequestForPayment(var SubscrRequest: Record "NPR MM Subscr. Request")
    begin
        SubscrRequest.Init();
        SubscrRequest."Entry No." := 0;
        SubscrRequest."Posting Date" := Today();
        SubscrRequest.Insert(true);
    end;

    local procedure CreateSubscrPaymentRequestWithLCY(var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request"; SubscrRequest: Record "NPR MM Subscr. Request"; PSPReference: Code[16]; Amount: Decimal; CurrencyCode: Code[10]; AmountLCY: Decimal)
    begin
        SubscrPaymentRequest.Init();
        SubscrPaymentRequest."Entry No." := 0;
        SubscrPaymentRequest."Batch No." := 0;
        SubscrPaymentRequest."Subscr. Request Entry No." := SubscrRequest."Entry No.";
        SubscrPaymentRequest.Type := SubscrPaymentRequest.Type::Payment;
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::Captured;
        SubscrPaymentRequest.PSP := SubscrPaymentRequest.PSP::Adyen;
        SubscrPaymentRequest."PSP Reference" := PSPReference;
        SubscrPaymentRequest.Amount := Amount;
        SubscrPaymentRequest."Currency Code" := CurrencyCode;
        SubscrPaymentRequest."Amount (LCY)" := AmountLCY; // Insert() below (not Insert(true)) so the OnInsert trigger keeps this test-set value
        SubscrPaymentRequest.Reconciled := false;
        SubscrPaymentRequest.Reversed := false;
        SubscrPaymentRequest.Insert();
    end;

    local procedure InsertFCYSettledReconLine(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; PSPReference: Code[16]; Amount: Decimal; TransactionCurrency: Code[10]; ExchangeRate: Decimal)
    begin
        InitReconLineForHeader(ReconciliationLine, ReconciliationHeader);
        ReconciliationLine."PSP Reference" := PSPReference;
        ReconciliationLine."Merchant Reference" := CopyStr('REF-' + Format(ReconciliationLine."Line No."), 1, MaxStrLen(ReconciliationLine."Merchant Reference"));
        ReconciliationLine."Merchant Order Reference" := CopyStr('ORD-' + Format(ReconciliationLine."Line No."), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
        ReconciliationLine."Transaction Date" := CreateDateTime(Today(), Time());
        ReconciliationLine."Transaction Currency Code" := TransactionCurrency;
        ReconciliationLine."Adyen Acc. Currency Code" := _NetCurrency;
        ReconciliationLine.Validate("Gross Credit", Amount);
        ReconciliationLine.Validate("Net Credit", Amount);
        ReconciliationLine."Exchange Rate" := ExchangeRate;
        ReconciliationLine."Amount (LCY)" := ReconciliationLine."Amount(AAC)";
        ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::Settled;
        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"To Be Determined";
        ReconciliationLine.Status := ReconciliationLine.Status::" ";
        ReconciliationLine.Insert();
    end;

    local procedure InsertFCYChargebackReconLine(var ReconciliationLine: Record "NPR Adyen Recon. Line"; ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"; PSPReference: Code[16]; Amount: Decimal; TransactionCurrency: Code[10]; ExchangeRate: Decimal)
    begin
        InitReconLineForHeader(ReconciliationLine, ReconciliationHeader);
        ReconciliationLine."PSP Reference" := PSPReference;
        ReconciliationLine."Merchant Reference" := CopyStr('CB-' + Format(ReconciliationLine."Line No."), 1, MaxStrLen(ReconciliationLine."Merchant Reference"));
        ReconciliationLine."Merchant Order Reference" := CopyStr('CBORD-' + Format(ReconciliationLine."Line No."), 1, MaxStrLen(ReconciliationLine."Merchant Order Reference"));
        ReconciliationLine."Transaction Date" := CreateDateTime(Today(), Time());
        ReconciliationLine."Transaction Currency Code" := TransactionCurrency;
        ReconciliationLine."Adyen Acc. Currency Code" := _NetCurrency;
        ReconciliationLine.Validate("Gross Debit", Amount); // debit => negative Amount(TCY), i.e. money charged back
        ReconciliationLine.Validate("Net Debit", Amount);
        ReconciliationLine."Exchange Rate" := ExchangeRate;
        ReconciliationLine."Amount (LCY)" := ReconciliationLine."Amount(AAC)";
        ReconciliationLine."Transaction Type" := ReconciliationLine."Transaction Type"::Chargeback;
        ReconciliationLine."Matching Table Name" := ReconciliationLine."Matching Table Name"::"To Be Determined";
        ReconciliationLine.Status := ReconciliationLine.Status::" ";
        ReconciliationLine.Insert();
    end;

    local procedure GenerateUniquePSPReference(): Code[16]
    var
        Guid: Guid;
        GuidText: Text;
        Reference: Text;
    begin
        Guid := CreateGuid();
        GuidText := DelChr(Format(Guid), '=', '{}-');
        Reference := 'P' + CopyStr(GuidText, 1, 15);
        exit(UpperCase(CopyStr(Reference, 1, 16)));
    end;

    local procedure GenerateUniqueBatchNumber(): Integer
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
    begin
        if _BatchNumberSeed = 0 then begin
            ReconciliationHeader.SetCurrentKey("Batch Number");
            if ReconciliationHeader.FindLast() then
                _BatchNumberSeed := ReconciliationHeader."Batch Number" + 1
            else
                _BatchNumberSeed := 1000000;
        end else
            _BatchNumberSeed += 1;
        exit(_BatchNumberSeed);
    end;

    #endregion

    #region [XLSX builders]

    local procedure BuildWebhookRequest(var AFRecWebhookRequest: Record "NPR AF Rec. Webhook Request"; BatchNumber: Integer; PSPReference: Code[16]; MerchantOrderRef: Text; SettledAmount: Decimal; FeeAmount: Decimal)
    var
        TempBlob: Codeunit "Temp Blob";
        BlobInStr: InStream;
        ReportOutStr: OutStream;
        FileName: Text;
    begin
        BuildXLSXBlob(TempBlob, BatchNumber, PSPReference, MerchantOrderRef, SettledAmount, FeeAmount);
        TempBlob.CreateInStream(BlobInStr);

        FileName := 'settlement_detail_batch_' + Format(BatchNumber) + '.xlsx';
        AFRecWebhookRequest.Init();
        AFRecWebhookRequest.ID := 0;
        AFRecWebhookRequest."Report Name" := CopyStr(FileName, 1, MaxStrLen(AFRecWebhookRequest."Report Name"));
        AFRecWebhookRequest."Report Type" := AFRecWebhookRequest."Report Type"::"Settlement details";
        AFRecWebhookRequest."Report Download URL" := _LocalFileLbl;
        AFRecWebhookRequest.Insert();

        AFRecWebhookRequest."Report Data".CreateOutStream(ReportOutStr);
        CopyStream(ReportOutStr, BlobInStr);
        AFRecWebhookRequest.Modify();
    end;

    local procedure InjectReportBlob(var AFRecWebhookRequest: Record "NPR AF Rec. Webhook Request"; BatchNumber: Integer; PSPReference: Code[16]; MerchantOrderRef: Text; SettledAmount: Decimal; FeeAmount: Decimal)
    var
        TempBlob: Codeunit "Temp Blob";
        BlobInStr: InStream;
        ReportOutStr: OutStream;
    begin
        // Substitutes for the live HTTP download in tests by writing the XLSX blob directly into
        // the Webhook Request's Report Data field and flipping the URL to the local-upload marker.
        BuildXLSXBlob(TempBlob, BatchNumber, PSPReference, MerchantOrderRef, SettledAmount, FeeAmount);
        TempBlob.CreateInStream(BlobInStr);

        Clear(AFRecWebhookRequest."Report Data");
        AFRecWebhookRequest."Report Data".CreateOutStream(ReportOutStr);
        CopyStream(ReportOutStr, BlobInStr);
        AFRecWebhookRequest."Report Download URL" := _LocalFileLbl;
        AFRecWebhookRequest.Modify();
    end;

    local procedure BuildXLSXBlob(var TempBlob: Codeunit "Temp Blob"; BatchNumber: Integer; PSPReference: Code[16]; MerchantOrderRef: Text; SettledAmount: Decimal; FeeAmount: Decimal)
    var
        TempExcelBuf: Record "Excel Buffer" temporary;
        BlobOutStr: OutStream;
    begin
        WriteSettlementWorkbook(TempExcelBuf, BatchNumber, PSPReference, MerchantOrderRef, SettledAmount, FeeAmount);
        TempBlob.CreateOutStream(BlobOutStr);
        TempExcelBuf.SaveToStream(BlobOutStr, true);
    end;

    local procedure WriteSettlementWorkbook(var TempExcelBuf: Record "Excel Buffer" temporary; BatchNumber: Integer; PSPReference: Code[16]; MerchantOrderRef: Text; SettledAmount: Decimal; FeeAmount: Decimal)
    begin
        TempExcelBuf.DeleteAll();
        WriteHeaderRow(TempExcelBuf);
        WriteSettledRow(TempExcelBuf, 2, BatchNumber, PSPReference, MerchantOrderRef, SettledAmount, FeeAmount);
        WriteFeeRow(TempExcelBuf, 3, BatchNumber, MerchantOrderRef, FeeAmount);

        TempExcelBuf.CreateNewBook(_DataSheetLbl);
        TempExcelBuf.WriteSheet(_DataSheetLbl, CompanyName(), UserId());
        TempExcelBuf.CloseBook();
    end;

    local procedure WriteHeaderRow(var TempExcelBuf: Record "Excel Buffer" temporary)
    begin
        SetCell(TempExcelBuf, 1, 1, 'Company Account');
        SetCell(TempExcelBuf, 1, 2, 'Merchant Account');
        SetCell(TempExcelBuf, 1, 3, 'Psp Reference');
        SetCell(TempExcelBuf, 1, 4, 'Merchant Reference');
        SetCell(TempExcelBuf, 1, 5, 'Payment Method');
        SetCell(TempExcelBuf, 1, 6, 'Creation Date');
        SetCell(TempExcelBuf, 1, 7, 'TimeZone');
        SetCell(TempExcelBuf, 1, 8, 'Type');
        SetCell(TempExcelBuf, 1, 9, 'Modification Reference');
        SetCell(TempExcelBuf, 1, 10, 'Gross Currency');
        SetCell(TempExcelBuf, 1, 11, 'Gross Debit (GC)');
        SetCell(TempExcelBuf, 1, 12, 'Gross Credit (GC)');
        SetCell(TempExcelBuf, 1, 13, 'Exchange Rate');
        SetCell(TempExcelBuf, 1, 14, 'Net Currency');
        SetCell(TempExcelBuf, 1, 15, 'Net Debit (NC)');
        SetCell(TempExcelBuf, 1, 16, 'Net Credit (NC)');
        SetCell(TempExcelBuf, 1, 17, 'Commission (NC)');
        SetCell(TempExcelBuf, 1, 18, 'Markup (NC)');
        SetCell(TempExcelBuf, 1, 19, 'Payment Method Variant');
        SetCell(TempExcelBuf, 1, 20, 'Modification Merchant Reference');
        SetCell(TempExcelBuf, 1, 21, 'Batch Number');
        SetCell(TempExcelBuf, 1, 22, 'DCC Markup (NC)');
        SetCell(TempExcelBuf, 1, 23, 'Surcharge Amount');
        SetCell(TempExcelBuf, 1, 24, 'Merchant Order Reference');
        SetCell(TempExcelBuf, 1, 25, 'Scheme Fees (NC)');
        SetCell(TempExcelBuf, 1, 26, 'Interchange (NC)');
        SetCell(TempExcelBuf, 1, 27, 'Payment Fees (NC)');
        SetCell(TempExcelBuf, 1, 28, 'Creation Date (AMS)');
    end;

    local procedure WriteSettledRow(var TempExcelBuf: Record "Excel Buffer" temporary; RowNo: Integer; BatchNumber: Integer; PSPReference: Code[16]; MerchantOrderRef: Text; SettledAmount: Decimal; FeeAmount: Decimal)
    begin
        SetCell(TempExcelBuf, RowNo, 1, _CompanyAccountLbl);
        SetCell(TempExcelBuf, RowNo, 2, _MerchantAccount);
        SetCell(TempExcelBuf, RowNo, 3, PSPReference);
        SetCell(TempExcelBuf, RowNo, 4, 'REF-' + PSPReference);
        SetCell(TempExcelBuf, RowNo, 5, 'mc');
        SetCell(TempExcelBuf, RowNo, 6, FormatDateTimeIso(CurrentDateTime()));
        SetCell(TempExcelBuf, RowNo, 7, 'CET');
        SetCell(TempExcelBuf, RowNo, 8, _SettledTypeLbl);
        SetCell(TempExcelBuf, RowNo, 9, '');
        SetCell(TempExcelBuf, RowNo, 10, _NetCurrency);
        SetCell(TempExcelBuf, RowNo, 11, '0');
        SetCell(TempExcelBuf, RowNo, 12, FormatDecimal(SettledAmount));
        SetCell(TempExcelBuf, RowNo, 13, '1');
        SetCell(TempExcelBuf, RowNo, 14, _NetCurrency);
        SetCell(TempExcelBuf, RowNo, 15, '0');
        SetCell(TempExcelBuf, RowNo, 16, FormatDecimal(SettledAmount - FeeAmount));
        SetCell(TempExcelBuf, RowNo, 17, '0');
        SetCell(TempExcelBuf, RowNo, 18, '0');
        SetCell(TempExcelBuf, RowNo, 19, 'mc_credit');
        SetCell(TempExcelBuf, RowNo, 20, '');
        SetCell(TempExcelBuf, RowNo, 21, Format(BatchNumber));
        SetCell(TempExcelBuf, RowNo, 22, '0');
        SetCell(TempExcelBuf, RowNo, 23, '0');
        SetCell(TempExcelBuf, RowNo, 24, MerchantOrderRef);
        SetCell(TempExcelBuf, RowNo, 25, '0');
        SetCell(TempExcelBuf, RowNo, 26, '0');
        SetCell(TempExcelBuf, RowNo, 27, FormatDecimal(FeeAmount));
        SetCell(TempExcelBuf, RowNo, 28, FormatDateTimeIso(CurrentDateTime()));
    end;

    local procedure WriteFeeRow(var TempExcelBuf: Record "Excel Buffer" temporary; RowNo: Integer; BatchNumber: Integer; MerchantOrderRef: Text; FeeAmount: Decimal)
    var
        ModificationRef: Text;
    begin
        ModificationRef := 'fee-' + Format(BatchNumber);
        SetCell(TempExcelBuf, RowNo, 1, _CompanyAccountLbl);
        SetCell(TempExcelBuf, RowNo, 2, _MerchantAccount);
        SetCell(TempExcelBuf, RowNo, 3, '');
        SetCell(TempExcelBuf, RowNo, 4, 'FEEREF-' + Format(BatchNumber));
        SetCell(TempExcelBuf, RowNo, 5, 'mc');
        SetCell(TempExcelBuf, RowNo, 6, FormatDateTimeIso(CurrentDateTime()));
        SetCell(TempExcelBuf, RowNo, 7, 'CET');
        SetCell(TempExcelBuf, RowNo, 8, _FeeTypeLbl);
        SetCell(TempExcelBuf, RowNo, 9, ModificationRef);
        SetCell(TempExcelBuf, RowNo, 10, _NetCurrency);
        SetCell(TempExcelBuf, RowNo, 11, '0');
        SetCell(TempExcelBuf, RowNo, 12, '0');
        SetCell(TempExcelBuf, RowNo, 13, '1');
        SetCell(TempExcelBuf, RowNo, 14, _NetCurrency);
        SetCell(TempExcelBuf, RowNo, 15, FormatDecimal(FeeAmount));
        SetCell(TempExcelBuf, RowNo, 16, '0');
        SetCell(TempExcelBuf, RowNo, 17, '0');
        SetCell(TempExcelBuf, RowNo, 18, '0');
        SetCell(TempExcelBuf, RowNo, 19, '');
        SetCell(TempExcelBuf, RowNo, 20, '');
        SetCell(TempExcelBuf, RowNo, 21, Format(BatchNumber));
        SetCell(TempExcelBuf, RowNo, 22, '0');
        SetCell(TempExcelBuf, RowNo, 23, '0');
        SetCell(TempExcelBuf, RowNo, 24, MerchantOrderRef);
        SetCell(TempExcelBuf, RowNo, 25, '0');
        SetCell(TempExcelBuf, RowNo, 26, '0');
        SetCell(TempExcelBuf, RowNo, 27, FormatDecimal(FeeAmount));
        SetCell(TempExcelBuf, RowNo, 28, FormatDateTimeIso(CurrentDateTime()));
    end;

    local procedure SetCell(var TempExcelBuf: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer; CellValue: Text)
    begin
        TempExcelBuf.Init();
        TempExcelBuf.Validate("Row No.", RowNo);
        TempExcelBuf.Validate("Column No.", ColNo);
        TempExcelBuf."Cell Value as Text" := CopyStr(CellValue, 1, MaxStrLen(TempExcelBuf."Cell Value as Text"));
        TempExcelBuf."Cell Type" := TempExcelBuf."Cell Type"::Text;
        TempExcelBuf.Insert();
    end;

    local procedure FormatDecimal(Value: Decimal): Text
    begin
        exit(Format(Value, 0, '<Sign><Integer><Decimals><Comma,.>'));
    end;

    local procedure FormatDateTimeIso(Value: DateTime): Text
    begin
        // The import only requires the cell to be parseable into a DateTime; ISO works.
        exit(Format(Value, 0, 9));
    end;

    #endregion

    #region [Webhook JSON builders]

    local procedure InitAdyenWebhookRecord(var AdyenWebhook: Record "NPR Adyen Webhook"; WebhookReference: Code[80]; ReportURL: Text; PSPReference: Code[16])
    var
        WebhookOutStream: OutStream;
        WebhookJsonText: Text;
    begin
        WebhookJsonText := BuildReportReadyWebhookContent(ReportURL, PSPReference);

        AdyenWebhook.Init();
        AdyenWebhook."Entry No." := 0;
        AdyenWebhook."Event Code" := AdyenWebhook."Event Code"::REPORT_AVAILABLE;
        AdyenWebhook."Webhook Type" := AdyenWebhook."Webhook Type"::Reconciliation;
        AdyenWebhook.Status := AdyenWebhook.Status::New;
        AdyenWebhook.Success := true;
        AdyenWebhook.Live := false;
        AdyenWebhook."Event Date" := CurrentDateTime();
        AdyenWebhook."Merchant Account Name" := _MerchantAccount;
        AdyenWebhook."PSP Reference" := PSPReference;
        AdyenWebhook."Webhook Reference" := WebhookReference;
        AdyenWebhook."Webhook Data".CreateOutStream(WebhookOutStream, TextEncoding::UTF8);
        WebhookOutStream.WriteText(WebhookJsonText);
        AdyenWebhook.Insert();
    end;

    local procedure BuildReportReadyWebhookContent(ReportURL: Text; PSPReference: Code[16]) WebhookJson: Text
    var
        RootObject: JsonObject;
        NotificationItemWrapper: JsonObject;
        NotificationRequestItem: JsonObject;
        NotificationItems: JsonArray;
    begin
        // Shape mirrors what NPR Adyen Process Report Ready expects to find in the Webhook Data blob:
        //   { "live": ..., "notificationItems": [ { "NotificationRequestItem": { "reason": <url>, "pspReference": <ref> } } ] }
        NotificationRequestItem.Add('reason', ReportURL);
        NotificationRequestItem.Add('pspReference', PSPReference);
        NotificationItemWrapper.Add('NotificationRequestItem', NotificationRequestItem);
        NotificationItems.Add(NotificationItemWrapper);
        RootObject.Add('live', false);
        RootObject.Add('notificationItems', NotificationItems);
        RootObject.WriteTo(WebhookJson);
    end;

    #endregion

    #region [Handlers]

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        // Swallows UI messages raised by procedures we test (e.g. ReversePostings emits Message(...)).
    end;

    #endregion
}

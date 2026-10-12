codeunit 85487 "NPR Adyen Async Capture Tests"
{
    // [FEATURE] Asynchronous Adyen capture confirmation through CAPTURE and CAPTURE_FAILED webhooks

    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibPaymentGateway: Codeunit "NPR Library - Payment Gateway";
        _AsyncFeature: Codeunit "NPR AdyenAsyncPmtProcesFeature";
        _OriginalFeatureEnabled: Boolean;
        _Initialized: Boolean;
        _MockMerchantName: Text[80];
        _MockFirstPageStatusCode: Integer;
        _MockFirstPageBody: Text;
        _MockSecondPageBody: Text;
        _MockUpdatableWebhookId: Code[80];
        _MockCreateResponseBody: Text;
        _MockFirstPageRequests: Integer;
        _MockSecondPageRequests: Integer;
        _MockCreateRequests: Integer;
        _MockUpdateRequests: Integer;
        _MockUnexpectedRequests: Integer;
        _MockMerchantListStatusCode: Integer;
        _MockMerchantListBody: Text;
        _MockMerchantListRequests: Integer;
        _MockCapturePsp: Text;
        _MockCaptureRequests: Integer;
        _LastConfirmQuestion: Text;
        _StrMenuChoice: Integer;
        _LastStrMenuOptions: Text;
        _LastStrMenuInstruction: Text;
        _LastMessage: Text;
        _RefreshMerchantListReply: Boolean;
        _MerchantsNotListedReply: Boolean;
        _RefreshMerchantListQuestion: Text;
        _MerchantsNotListedQuestion: Text;
        _UnexpectedConfirmQuestion: Text;

    [Test]
    procedure CaptureWebhook_Successful_MarksInFlightLineCaptured()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A successful CAPTURE webhook confirms the capture in flight
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A successful CAPTURE webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The line is captured today and keeps its Charge ID
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The payment line should have been marked as captured today');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID should be kept after a successful capture');

        // [THEN] The capture interaction log is completed as a success
        AssertCaptureLogCompleted(PaymentLine, true);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_NotSuccessful_LeavesLineUncapturedAndLogsFailure()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A CAPTURE webhook with success false fails the capture in flight so it can be requested again
        Initialize();

        // [GIVEN] An Adyen payment line on a posted invoice with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Invoice Header", Enum::"Sales Document Type"::Quote, PaymentLine);

        // [GIVEN] A CAPTURE webhook with success false for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'false', 'Insufficient balance', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The line is not captured and the capture request is cleared
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'The payment line should not have been marked as captured');
        _Assert.AreEqual('', PaymentLine."Charge ID", 'The Charge ID should have been cleared after a failed capture');
        _Assert.AreEqual(false, PaymentLine."Capture Requested", 'Capture Requested should have been cleared after a failed capture');

        // [THEN] The capture interaction log is completed as a failure
        AssertCaptureLogCompleted(PaymentLine, false);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureFailedWebhook_InFlight_ClearsChargeIdAndCaptureRequested()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        Psp: Text;
    begin
        // [SCENARIO] A CAPTURE_FAILED webhook fails the capture in flight so it can be requested again
        Initialize();

        // [GIVEN] An Adyen payment line on a posted invoice with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Invoice Header", Enum::"Sales Document Type"::Quote, PaymentLine);

        // [GIVEN] A CAPTURE_FAILED webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE_FAILED, Psp, 'true', 'Capture rejected', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The line is not captured and the capture request is cleared
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'The payment line should not have been marked as captured');
        _Assert.AreEqual('', PaymentLine."Charge ID", 'The Charge ID should have been cleared after a capture failure');
        _Assert.AreEqual(false, PaymentLine."Capture Requested", 'Capture Requested should have been cleared after a capture failure');

        // [THEN] The capture interaction log is completed as a failure with the reason Adyen gave
        AssertCaptureLogCompleted(PaymentLine, false);
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual('Capture rejected', ReadLogErrorMessage(InteractionLog), 'The capture log should keep the reason Adyen gave');

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureFailedWebhook_AlreadyCaptured_LeavesLineUntouched()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A CAPTURE_FAILED webhook for a line that is already captured does not change the line
        Initialize();

        // [GIVEN] An Adyen payment line that was captured asynchronously today
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Invoice Header", Enum::"Sales Document Type"::Quote, PaymentLine);
        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify();

        // [GIVEN] A CAPTURE_FAILED webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE_FAILED, Psp, 'true', 'Capture rejected', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The line is unchanged
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'Date Captured should not have been changed');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID should not have been changed');
        _Assert.AreEqual(true, PaymentLine."Capture Requested", 'Capture Requested should not have been changed');
        AssertCaptureLogStillInProgress(PaymentLine);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_LineAlreadyCaptured_IsIgnored()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A successful CAPTURE webhook for a line that is already captured does not change the line
        Initialize();

        // [GIVEN] An Adyen payment line on a posted invoice that was captured yesterday and still has Capture Requested
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Invoice Header", Enum::"Sales Document Type"::Quote, PaymentLine);
        PaymentLine."Date Captured" := Today() - 1;
        PaymentLine.Modify();

        // [GIVEN] A successful CAPTURE webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The line keeps its capture date, Charge ID and Capture Requested, and its capture log stays open
        PaymentLine.Find();
        _Assert.AreEqual(Today() - 1, PaymentLine."Date Captured", 'Date Captured should not have been changed');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID should not have been changed');
        _Assert.AreEqual(true, PaymentLine."Capture Requested", 'Capture Requested should not have been changed');
        AssertCaptureLogStillInProgress(PaymentLine);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_LineNotInFlight_IsIgnored()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A CAPTURE webhook for a line without a capture in flight does not change the line
        Initialize();

        // [GIVEN] An Adyen payment line with the PSP reference as Charge ID but no capture requested
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Invoice Header", Enum::"Sales Document Type"::Quote, PaymentLine);
        PaymentLine."Capture Requested" := false;
        PaymentLine.Modify();

        // [GIVEN] A successful CAPTURE webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The line is unchanged
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'The payment line should not have been marked as captured');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID should not have been changed');
        _Assert.AreEqual(false, PaymentLine."Capture Requested", 'Capture Requested should not have been changed');
        AssertCaptureLogStillInProgress(PaymentLine);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_CreditMemoCopyWithSameChargeId_IsNotMatched()
    var
        InvoicePaymentLine: Record "NPR Magento Payment Line";
        CreditMemoPaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A CAPTURE webhook skips a credit memo line that carries the same Charge ID as the captured line
        Initialize();

        // [GIVEN] An Adyen payment line on a posted invoice with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Invoice Header", Enum::"Sales Document Type"::Quote, InvoicePaymentLine);

        // [GIVEN] A copy of that line on a sales credit memo with the same Charge ID.
        // It sorts before the invoice line on the Charge ID key, so the lookup reaches it first.
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::"Credit Memo", CreditMemoPaymentLine);

        // [GIVEN] A successful CAPTURE webhook for the PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The invoice line is captured
        InvoicePaymentLine.Find();
        _Assert.AreEqual(Today(), InvoicePaymentLine."Date Captured", 'The invoice payment line should have been marked as captured today');

        // [THEN] The credit memo line is unchanged
        CreditMemoPaymentLine.Find();
        _Assert.AreEqual(0D, CreditMemoPaymentLine."Date Captured", 'The credit memo payment line should not have been marked as captured');
        _Assert.AreEqual(UpperCase(Psp), CreditMemoPaymentLine."Charge ID", 'The Charge ID of the credit memo payment line should not have been changed');
        _Assert.AreEqual(true, CreditMemoPaymentLine."Capture Requested", 'Capture Requested of the credit memo payment line should not have been changed');
        AssertCaptureLogStillInProgress(CreditMemoPaymentLine);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_OrderLineAndPostedInvoiceCopy_CapturesBoth()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceCopyLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A successful CAPTURE webhook confirms the order line and the posted invoice copy that share its Charge ID
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] Partial posting split the line into a posted invoice copy with the same Charge ID
        CreatePostedInvoiceCopy(PaymentLine, InvoiceCopyLine);

        // [GIVEN] A successful CAPTURE webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] Both lines are captured today and keep their Charge ID
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The order payment line should have been marked as captured today');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID of the order payment line should be kept after a successful capture');
        InvoiceCopyLine.Find();
        _Assert.AreEqual(Today(), InvoiceCopyLine."Date Captured", 'The invoice payment line should have been marked as captured today');
        _Assert.AreEqual(UpperCase(Psp), InvoiceCopyLine."Charge ID", 'The Charge ID of the invoice payment line should be kept after a successful capture');

        // [THEN] The capture interaction log of the order line is completed as a success
        AssertCaptureLogCompleted(PaymentLine, true);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureFailedWebhook_OrderLineAndPostedInvoiceCopy_FailsBoth()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceCopyLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        Psp: Text;
    begin
        // [SCENARIO] A CAPTURE_FAILED webhook fails the capture on the order line and on the posted invoice copy that share its Charge ID
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] Partial posting split the line into a posted invoice copy with the same Charge ID
        CreatePostedInvoiceCopy(PaymentLine, InvoiceCopyLine);

        // [GIVEN] A CAPTURE_FAILED webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE_FAILED, Psp, 'true', 'Capture rejected', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] Neither line is captured and both capture requests are cleared
        AssertCaptureFailedOnLine(PaymentLine);
        AssertCaptureFailedOnLine(InvoiceCopyLine);

        // [THEN] The capture interaction log of the order line is completed as a failure with the reason Adyen gave
        AssertCaptureLogCompleted(PaymentLine, false);
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual('Capture rejected', ReadLogErrorMessage(InteractionLog), 'The capture log should keep the reason Adyen gave');

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_NotSuccessful_OrderLineAndPostedInvoiceCopy_FailsBoth()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceCopyLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A CAPTURE webhook with success false fails the capture on the order line and on the posted invoice copy
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] Partial posting split the line into a posted invoice copy with the same Charge ID
        CreatePostedInvoiceCopy(PaymentLine, InvoiceCopyLine);

        // [GIVEN] A CAPTURE webhook with success false for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'false', 'Insufficient balance', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] Neither line is captured and both capture requests are cleared
        AssertCaptureFailedOnLine(PaymentLine);
        AssertCaptureFailedOnLine(InvoiceCopyLine);

        // [THEN] The capture interaction log of the order line is completed as a failure
        AssertCaptureLogCompleted(PaymentLine, false);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_PostedCreditMemoCopyAfterCapturableLines_IsNotTouched()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceCopyLine: Record "NPR Magento Payment Line";
        CreditMemoCopyLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A successful CAPTURE webhook skips a posted credit memo line that the loop reaches after the capturable lines with the same Charge ID
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] Partial posting split the line into a posted invoice copy with the same Charge ID
        CreatePostedInvoiceCopy(PaymentLine, InvoiceCopyLine);

        // [GIVEN] A posted credit memo line with the same Charge ID and a capture in flight.
        // It sorts after the order and invoice lines on the Charge ID key, so the loop reaches it after the capturable lines.
        CreatePostedCreditMemoCopy(PaymentLine, CreditMemoCopyLine);

        // [GIVEN] A successful CAPTURE webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The order line and the invoice copy are captured today and keep their Charge ID
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The order payment line should have been marked as captured today');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID of the order payment line should be kept after a successful capture');
        InvoiceCopyLine.Find();
        _Assert.AreEqual(Today(), InvoiceCopyLine."Date Captured", 'The invoice payment line should have been marked as captured today');
        _Assert.AreEqual(UpperCase(Psp), InvoiceCopyLine."Charge ID", 'The Charge ID of the invoice payment line should be kept after a successful capture');

        // [THEN] The credit memo line is unchanged
        AssertInFlightLineUntouched(CreditMemoCopyLine, Psp);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureFailedWebhook_PostedCreditMemoCopyAfterCapturableLines_IsNotTouched()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceCopyLine: Record "NPR Magento Payment Line";
        CreditMemoCopyLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        Psp: Text;
    begin
        // [SCENARIO] A CAPTURE_FAILED webhook skips a posted credit memo line that the loop reaches after the capturable lines with the same Charge ID
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] Partial posting split the line into a posted invoice copy with the same Charge ID
        CreatePostedInvoiceCopy(PaymentLine, InvoiceCopyLine);

        // [GIVEN] A posted credit memo line with the same Charge ID and a capture in flight.
        // It sorts after the order and invoice lines on the Charge ID key, so the loop reaches it after the capturable lines.
        CreatePostedCreditMemoCopy(PaymentLine, CreditMemoCopyLine);

        // [GIVEN] A CAPTURE_FAILED webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE_FAILED, Psp, 'true', 'Capture rejected', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] Neither the order line nor the invoice copy is captured and both capture requests are cleared
        AssertCaptureFailedOnLine(PaymentLine);
        AssertCaptureFailedOnLine(InvoiceCopyLine);

        // [THEN] The credit memo line is unchanged
        AssertInFlightLineUntouched(CreditMemoCopyLine, Psp);

        // [THEN] The webhook is processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure LogOperationFinished_AsyncCapture_IsNotSuccessUntilWebhook()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        TempRequest: Record "NPR PG Payment Request" temporary;
        TempResponse: Record "NPR PG Payment Response" temporary;
        AdyenWebhook: Record "NPR Adyen Webhook";
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        Psp: Text;
    begin
        // [SCENARIO] A capture that Adyen accepted for asynchronous processing is logged as in progress, not as a success
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight and a started capture log
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        FindCaptureLog(PaymentLine, InteractionLog);

        // [GIVEN] A response that accepted the capture for asynchronous processing
        PaymentLine.ToRequest(TempRequest);
        TempResponse.Init();
        TempResponse."Response Success" := true;
        TempResponse."Async Processing" := true;
        TempResponse."Reported Operation Status" := TempResponse."Reported Operation Status"::Pending;

        // [WHEN] The capture call is logged as finished
        LogMgt.LogOperationFinished(InteractionLog, TempRequest, TempResponse, true, '');

        // [THEN] The log stays in progress and is not a success yet
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual(true, InteractionLog."In Progress", 'The capture interaction log should stay in progress until the webhook arrives');
        _Assert.AreEqual(false, InteractionLog."Operation Success", 'The capture interaction log should not be a success before the webhook arrives');
        _Assert.AreEqual(false, InteractionLog."Ran With Error", 'The capture interaction log should not have an error');

        // [WHEN] A successful CAPTURE webhook for its PSP reference is processed
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);
        ProcessWebhook(AdyenWebhook);

        // [THEN] The webhook completes the log as a success
        AssertCaptureLogCompleted(PaymentLine, true);

        RestoreFeature();
    end;

    [Test]
    procedure LogOperationFinished_SyncCapture_IsSuccess()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        TempRequest: Record "NPR PG Payment Request" temporary;
        TempResponse: Record "NPR PG Payment Response" temporary;
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        Psp: Text;
    begin
        // [SCENARIO] A capture that completed synchronously is logged as a finished success
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a started capture log
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        FindCaptureLog(PaymentLine, InteractionLog);

        // [GIVEN] A successful response without asynchronous processing
        PaymentLine.ToRequest(TempRequest);
        TempResponse.Init();
        TempResponse."Response Success" := true;
        TempResponse."Async Processing" := false;
        TempResponse."Reported Operation Status" := TempResponse."Reported Operation Status"::Success;

        // [WHEN] The capture call is logged as finished
        LogMgt.LogOperationFinished(InteractionLog, TempRequest, TempResponse, true, '');

        // [THEN] The log is completed as a success
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual(false, InteractionLog."In Progress", 'The capture interaction log should have been completed');
        _Assert.AreEqual(true, InteractionLog."Operation Success", 'The capture interaction log should be a success');
        _Assert.AreEqual(false, InteractionLog."Ran With Error", 'The capture interaction log should not have an error');

        RestoreFeature();
    end;

    [Test]
    procedure UnmatchedCaptureWebhook_OlderThanGrace_IsCanceled()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
    begin
        // [SCENARIO] A CAPTURE webhook with no matching payment line is canceled once the grace period has passed
        Initialize();

        // [GIVEN] A CAPTURE webhook received 16 minutes ago for a PSP reference that no payment line carries
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, NewPspReference(), 'true', '', CurrentDateTime() - MinutesToDuration(16), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The webhook is canceled and stamped as processed
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::Canceled);
        _Assert.AreNotEqual(0DT, AdyenWebhook."Processed Date", 'The canceled webhook should have a Processed Date');

        RestoreFeature();
    end;

    [Test]
    procedure UnmatchedCaptureFailedWebhook_OlderThanGrace_IsCanceled()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
    begin
        // [SCENARIO] A CAPTURE_FAILED webhook with no matching payment line is canceled once the grace period has passed
        Initialize();

        // [GIVEN] A CAPTURE_FAILED webhook received 16 minutes ago for a PSP reference that no payment line carries
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE_FAILED, NewPspReference(), 'true', 'Capture rejected', CurrentDateTime() - MinutesToDuration(16), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The webhook is canceled and stamped as processed
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::Canceled);
        _Assert.AreNotEqual(0DT, AdyenWebhook."Processed Date", 'The canceled webhook should have a Processed Date');

        RestoreFeature();
    end;

    [Test]
    procedure UnmatchedCaptureWebhook_WithinGrace_StaysNewAndIsStamped()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
    begin
        // [SCENARIO] A CAPTURE webhook with no matching payment line waits while the grace period runs, and is stamped so the job waits before checking it again
        Initialize();

        // [GIVEN] A CAPTURE webhook received 5 minutes ago for a PSP reference that no payment line carries
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, NewPspReference(), 'true', '', CurrentDateTime() - MinutesToDuration(5), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The webhook stays New and has a Processed Date
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::New);
        _Assert.AreNotEqual(0DT, AdyenWebhook."Processed Date", 'The unmatched webhook within the grace period should have a Processed Date');

        RestoreFeature();
    end;

    [Test]
    procedure UnmatchedCaptureWebhook_FeatureDisabled_StaysNew()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
    begin
        // [SCENARIO] With the feature disabled, an unmatched CAPTURE webhook is left alone even after the grace period
        Initialize();

        // [GIVEN] The asynchronous capture feature is disabled
        _AsyncFeature.SetFeatureEnabled(false);

        // [GIVEN] A CAPTURE webhook received 16 minutes ago for a PSP reference that no payment line carries
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, NewPspReference(), 'true', '', CurrentDateTime() - MinutesToDuration(16), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The webhook stays New and is not stamped
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::New);
        _Assert.AreEqual(0DT, AdyenWebhook."Processed Date", 'A webhook left alone because the feature is disabled should not have a Processed Date');

        RestoreFeature();
    end;

    [Test]
    procedure Process_UnmatchedWebhookCheckedRecently_IsNotReprocessed()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        Psp: Text;
        StampedAt: DateTime;
    begin
        // [SCENARIO] The job does not check a new webhook again until a minute has passed since it was last found unmatched
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A new successful CAPTURE webhook for its PSP reference that was found unmatched 30 seconds ago
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);
        AdyenWebhook."Processed Date" := CurrentDateTime() - 30 * 1000;
        AdyenWebhook.Modify();
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        StampedAt := AdyenWebhook."Processed Date";
        Commit();

        // [WHEN] The job processes webhooks now
        AdyenAsyncPayProcessJQ.Process(CurrentDateTime());

        // [THEN] The line still has its capture in flight
        AssertInFlightLineUntouched(PaymentLine, Psp);

        // [THEN] The webhook stays New with the same Processed Date
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::New);
        _Assert.AreEqual(StampedAt, AdyenWebhook."Processed Date", 'The webhook should not have been processed again within the retry backoff');

        RestoreFeature();
    end;

    [Test]
    procedure Process_UnmatchedWebhookAfterRetryBackoff_IsReprocessed()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        Psp: Text;
    begin
        // [SCENARIO] The job checks a new webhook again once a minute has passed since it was last found unmatched
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A new successful CAPTURE webhook for its PSP reference that was found unmatched 30 seconds ago
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);
        AdyenWebhook."Processed Date" := CurrentDateTime() - 30 * 1000;
        AdyenWebhook.Modify();
        Commit();

        // [WHEN] The job processes webhooks 2 minutes from now
        AdyenAsyncPayProcessJQ.Process(CurrentDateTime() + MinutesToDuration(2));

        // [THEN] The line is captured today and its capture log is completed as a success
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The webhook checked again after the retry backoff should have marked the payment line as captured today');
        AssertCaptureLogCompleted(PaymentLine, true);

        // [THEN] The webhook is processed
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure Process_UnmatchedWebhookOlderThanGrace_IsCanceledOnFirstPass()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
    begin
        // [SCENARIO] The job picks up a new webhook that was never processed and cancels it when the grace period has passed
        // This also passes without the retry backoff filter. It guards the blank Processed Date part of that filter.
        Initialize();

        // [GIVEN] A new CAPTURE webhook received 16 minutes ago for a PSP reference that no payment line carries, never processed
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, NewPspReference(), 'true', '', CurrentDateTime() - MinutesToDuration(16), AdyenWebhook);
        Commit();

        // [WHEN] The job processes webhooks now, once
        AdyenAsyncPayProcessJQ.Process(CurrentDateTime());

        // [THEN] The webhook is canceled and stamped as processed
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::Canceled);
        _Assert.AreNotEqual(0DT, AdyenWebhook."Processed Date", 'The canceled webhook should have a Processed Date');

        RestoreFeature();
    end;

    [Test]
    procedure UnmatchedCaptureWebhook_EmptyPspReference_OlderThanGrace_IsCanceled()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
    begin
        // [SCENARIO] A CAPTURE webhook without a PSP reference is canceled once the grace period has passed, instead of staying New
        Initialize();

        // [GIVEN] A CAPTURE webhook received 16 minutes ago whose notification item has an empty pspReference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, '', 'true', '', CurrentDateTime() - MinutesToDuration(16), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The webhook is canceled and stamped as processed
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::Canceled);
        _Assert.AreNotEqual(0DT, AdyenWebhook."Processed Date", 'The canceled webhook should have a Processed Date');

        RestoreFeature();
    end;

    [Test]
    procedure UnmatchedCaptureWebhook_NoNotificationRequestItem_OlderThanGrace_IsCanceled()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
    begin
        // [SCENARIO] A CAPTURE webhook whose notification item has no NotificationRequestItem is canceled once the grace period has passed, instead of staying New
        Initialize();

        // [GIVEN] A CAPTURE webhook received 16 minutes ago with one empty notification item
        InsertCaptureWebhookWithData(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, '', true, CurrentDateTime() - MinutesToDuration(16), '{"live":"false","notificationItems":[{}]}', AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The webhook is canceled and stamped as processed
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::Canceled);
        _Assert.AreNotEqual(0DT, AdyenWebhook."Processed Date", 'The canceled webhook should have a Processed Date');

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_MatchedItemThenUnmatchedItem_OlderThanGrace_StaysProcessed()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        RootObject: JsonObject;
        NotificationItems: JsonArray;
        WebhookJsonText: Text;
        Psp: Text;
    begin
        // [SCENARIO] An unmatched notification item after a matched one does not cancel a webhook that the matched item already processed
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A CAPTURE webhook received 16 minutes ago whose first item is for that PSP reference and whose second item is for a PSP reference that no payment line carries
        NotificationItems.Add(NotificationItemJson(Psp, 'true', ''));
        NotificationItems.Add(NotificationItemJson(NewPspReference(), 'true', ''));
        RootObject.Add('live', 'false');
        RootObject.Add('notificationItems', NotificationItems);
        RootObject.WriteTo(WebhookJsonText);
        InsertCaptureWebhookWithData(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, true, CurrentDateTime() - MinutesToDuration(16), WebhookJsonText, AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The line is captured today
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The matched item should have marked the payment line as captured today');

        // [THEN] The webhook stays processed
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure ErrorWebhook_WithinBackoff_IsNotReprocessed()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        Psp: Text;
    begin
        // [SCENARIO] The job does not retry a failed webhook until the retry backoff has passed
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A successful CAPTURE webhook for its PSP reference that failed processing 1 minute ago
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);
        SetWebhookError(AdyenWebhook, CurrentDateTime() - MinutesToDuration(1));
        Commit();

        // [WHEN] The job processes webhooks now
        AdyenAsyncPayProcessJQ.Process(CurrentDateTime());

        // [THEN] The line still has its capture in flight
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'The payment line should not have been marked as captured');
        _Assert.AreEqual(true, PaymentLine."Capture Requested", 'Capture Requested should not have been changed');

        // [THEN] The webhook stays in Error
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::Error);

        RestoreFeature();
    end;

    [Test]
    procedure ErrorWebhook_OlderThan24Hours_IsCanceled()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        Psp: Text;
        ReferenceDateTime: DateTime;
    begin
        // [SCENARIO] The job cancels a failed webhook once it is older than the give-up age, without retrying it first
        Initialize();
        ReferenceDateTime := CurrentDateTime() + MinutesToDuration(25 * 60);

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A successful CAPTURE webhook for its PSP reference that failed processing.
        // Its Event Date and Processed Date are 10 minutes before the job run, past the 5 minute retry backoff,
        // so only its creation time keeps it out of the retry pass.
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', ReferenceDateTime - MinutesToDuration(10), AdyenWebhook);
        SetWebhookError(AdyenWebhook, ReferenceDateTime - MinutesToDuration(10));
        Commit();

        // [WHEN] The job processes webhooks 25 hours after the webhook was received
        AdyenAsyncPayProcessJQ.Process(ReferenceDateTime);

        // [THEN] The webhook is canceled
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        AssertWebhookStatus(AdyenWebhook, AdyenWebhook.Status::Canceled);

        // [THEN] The webhook was not retried, so the line still has its capture in flight
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'The expired webhook should not have been retried and captured the payment line');
        _Assert.AreEqual(true, PaymentLine."Capture Requested", 'Capture Requested should not have been changed');

        RestoreFeature();
    end;

    [Test]
    procedure ErrorWebhook_AfterBackoff_IsReprocessed()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        Psp: Text;
    begin
        // [SCENARIO] The job retries a failed webhook once the retry backoff has passed
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A successful CAPTURE webhook for its PSP reference, received now, that failed processing 6 minutes ago
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);
        SetWebhookError(AdyenWebhook, CurrentDateTime() - MinutesToDuration(6));
        Commit();

        // [WHEN] The job processes webhooks now
        AdyenAsyncPayProcessJQ.Process(CurrentDateTime());

        // [THEN] The line is captured today
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The retried webhook should have marked the payment line as captured today');

        // [THEN] The webhook is processed
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    procedure Process_NewCaptureWebhook_CapturesInFlightLine()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        Psp: Text;
    begin
        // [SCENARIO] The job processes a new CAPTURE webhook and confirms the capture in flight
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A new successful CAPTURE webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);
        Commit();

        // [WHEN] The job processes webhooks now
        AdyenAsyncPayProcessJQ.Process(CurrentDateTime());

        // [THEN] The line is captured today
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The new webhook should have marked the payment line as captured today');

        // [THEN] The webhook is processed
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        AssertWebhookProcessed(AdyenWebhook);

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure WebhooksPage_ProcessCanceledCaptureWebhook_CapturesLine()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenWebhooks: TestPage "NPR Adyen Webhooks";
        Psp: Text;
    begin
        // [SCENARIO] Processing a canceled CAPTURE webhook from the webhook page confirms the capture in flight
        Initialize();

        // [GIVEN] An Adyen payment line on a posted invoice with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Invoice Header", Enum::"Sales Document Type"::Quote, PaymentLine);

        // [GIVEN] A successful CAPTURE webhook for its PSP reference that was canceled
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);
        AdyenWebhook.Status := AdyenWebhook.Status::Canceled;
        AdyenWebhook.Modify();
        Commit();

        // [WHEN] An administrator runs Process on the webhook and answers Yes
        _LastConfirmQuestion := '';
        AdyenWebhooks.OpenView();
        _Assert.IsTrue(AdyenWebhooks.GoToRecord(AdyenWebhook), 'The webhook should be shown on the webhook page');
        AdyenWebhooks.Process.Invoke();
        AdyenWebhooks.Close();

        // [THEN] The administrator was asked to process the webhook
        _Assert.IsTrue(
            _LastConfirmQuestion.StartsWith('This will process the selected Webhook'),
            StrSubstNo('The process question must be shown, actual question: %1', _LastConfirmQuestion));

        // [THEN] The webhook is processed
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
        AssertWebhookProcessed(AdyenWebhook);

        // [THEN] The line is captured today and its capture log is completed as a success
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The processed webhook should have marked the payment line as captured today');
        AssertCaptureLogCompleted(PaymentLine, true);

        RestoreFeature();
    end;

    [Test]
    procedure CancelPaymentLine_AdyenLineWithCaptureInFlight_IsNotCancelled()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        Psp: Text;
        LogEntriesBefore: Integer;
    begin
        // [SCENARIO] A capture that awaits confirmation cannot be cancelled
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight and cancel enabled on its gateway
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        InteractionLog.SetRange("Payment Line System Id", PaymentLine.SystemId);
        LogEntriesBefore := InteractionLog.Count();

        // [WHEN] The payment line is cancelled
        MagentoPmtMgt.CancelPaymentLine(PaymentLine);

        // [THEN] The line is not cancelled and keeps its amount and capture request
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Canceled", 'The payment line should not have been cancelled');
        _Assert.AreEqual(100, PaymentLine.Amount, 'The amount of the payment line should not have been changed');
        _Assert.AreEqual(true, PaymentLine."Capture Requested", 'Capture Requested should not have been changed');

        // [THEN] No gateway call was logged for the line
        _Assert.AreEqual(LogEntriesBefore, InteractionLog.Count(), 'No interaction log entry should have been added for the payment line');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenCaptureApiMock')]
    procedure CapturePaymentLine_FeatureOff_OrderLine_CapturesSynchronously()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        // [SCENARIO] With the feature disabled, a capture that Adyen accepts marks a sales order line captured at once
        Initialize();
        AssertHttpMockAvailable();

        // [GIVEN] The asynchronous capture feature is disabled
        _AsyncFeature.SetFeatureEnabled(false);

        // [GIVEN] An Adyen payment line on a sales order without a Charge ID, and an Adyen /capture endpoint that accepts the capture
        CreateAdyenOrderPaymentLineWithCaptureSetup(SalesHeader, PaymentLine);
        _Assert.AreEqual('', PaymentLine."Charge ID", 'The payment line should start without a Charge ID');
        ResetCaptureApiMock(NewPspReference());
        Commit();

        // [WHEN] The payment line is captured
        MagentoPmtMgt.CapturePaymentLine(PaymentLine);

        // [THEN] Adyen was called once
        AssertOneCaptureRequestSent();

        // [THEN] The line is captured today, has no capture in flight and no Charge ID
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The payment line should have been marked as captured today');
        _Assert.AreEqual(false, PaymentLine."Capture Requested", 'Capture Requested should not be set after a synchronous capture');
        _Assert.AreEqual('', PaymentLine."Charge ID", 'A synchronous capture should not set the Charge ID');

        // [THEN] The capture interaction log is completed as a success
        AssertCaptureLogCompleted(PaymentLine, true);

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenCaptureApiMock')]
    procedure CapturePaymentLine_FeatureOn_OrderLine_CaptureStaysInFlight()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        // [SCENARIO] With the feature enabled, a capture that Adyen accepts leaves a sales order line in flight until the webhook arrives
        Initialize();
        AssertHttpMockAvailable();

        // [GIVEN] An Adyen payment line on a sales order and an Adyen /capture endpoint that accepts the capture
        CreateAdyenOrderPaymentLineWithCaptureSetup(SalesHeader, PaymentLine);
        ResetCaptureApiMock(NewPspReference());
        Commit();

        // [WHEN] The payment line is captured
        MagentoPmtMgt.CapturePaymentLine(PaymentLine);

        // [THEN] Adyen was called once
        AssertOneCaptureRequestSent();

        // [THEN] The line has a capture in flight with the PSP reference from Adyen as Charge ID
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'The payment line should not be captured before the webhook arrives');
        _Assert.AreEqual(true, PaymentLine."Capture Requested", 'Capture Requested should be set while the capture is in flight');
        _Assert.AreEqual(_MockCapturePsp, PaymentLine."Charge ID", 'The Charge ID should be the PSP reference returned by Adyen');
        _Assert.IsTrue(MagentoPmtMgt.IsCaptureInFlight(PaymentLine), 'The payment line should have a capture in flight');

        // [THEN] The capture interaction log stays in progress and is not a success yet
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual(true, InteractionLog."In Progress", 'The capture interaction log should stay in progress until the webhook arrives');
        _Assert.AreEqual(false, InteractionLog."Operation Success", 'The capture interaction log should not be a success before the webhook arrives');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenCaptureApiMock')]
    procedure CapturePaymentLine_FeatureOn_EcomLinkedLine_CapturesSynchronously()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        // [SCENARIO] With the feature enabled, a sales order line that came from an ecommerce document is still captured synchronously
        Initialize();
        AssertHttpMockAvailable();

        // [GIVEN] An Adyen payment line on a sales order, linked to an ecommerce document, and an Adyen /capture endpoint that accepts the capture
        CreateAdyenOrderPaymentLineWithCaptureSetup(SalesHeader, PaymentLine);
        PaymentLine."NPR Inc Ecom Sale Id" := CreateGuid();
        PaymentLine.Modify();
        ResetCaptureApiMock(NewPspReference());
        Commit();

        // [WHEN] The payment line is captured
        MagentoPmtMgt.CapturePaymentLine(PaymentLine);

        // [THEN] Adyen was called once
        AssertOneCaptureRequestSent();

        // [THEN] The line is captured today and has no capture in flight
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The ecommerce payment line should have been marked as captured today');
        _Assert.AreEqual(false, PaymentLine."Capture Requested", 'Capture Requested should not be set after a synchronous capture');

        // [THEN] The capture interaction log is completed as a success
        AssertCaptureLogCompleted(PaymentLine, true);

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenCaptureApiMock')]
    procedure CapturePaymentLine_FeatureOn_EcomSalesPmtLineLinkedLine_CapturesSynchronously()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
    begin
        // [SCENARIO] With the feature enabled, a sales order line linked only to an ecommerce payment line is still captured synchronously
        Initialize();
        AssertHttpMockAvailable();

        // [GIVEN] An Adyen payment line on a sales order, linked to an ecommerce payment line but not to an ecommerce document, and an Adyen /capture endpoint that accepts the capture
        CreateAdyenOrderPaymentLineWithCaptureSetup(SalesHeader, PaymentLine);
        PaymentLine."NPR Inc Ecom Sales Pmt Line Id" := CreateGuid();
        PaymentLine.Modify();
        _Assert.IsTrue(IsNullGuid(PaymentLine."NPR Inc Ecom Sale Id"), 'The payment line should not be linked to an ecommerce document');
        ResetCaptureApiMock(NewPspReference());
        Commit();

        // [WHEN] The payment line is captured
        MagentoPmtMgt.CapturePaymentLine(PaymentLine);

        // [THEN] Adyen was called once
        AssertOneCaptureRequestSent();

        // [THEN] The line is captured today and has no capture in flight
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The ecommerce payment line should have been marked as captured today');
        _Assert.AreEqual(false, PaymentLine."Capture Requested", 'Capture Requested should not be set after a synchronous capture');

        // [THEN] The capture interaction log is completed as a success
        AssertCaptureLogCompleted(PaymentLine, true);

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('CaptureMessageHandler')]
    procedure PaymentLineList_CaptureOnInFlightAdyenLine_ShowsInProgressMessage()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
        Psp: Text;
        LogEntriesBefore: Integer;
    begin
        // [SCENARIO] Capture Payment on an Adyen line with a capture in flight tells the user the capture is in progress and calls nothing
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        LogEntriesBefore := CountInteractionLogs(PaymentLine.SystemId);

        // [WHEN] Capture Payment is run on the line from the payment line list
        _LastMessage := '';
        PaymentLineList.OpenView();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');
        PaymentLineList."Capture Payment".Invoke();
        PaymentLineList.Close();

        // [THEN] The user is told the capture is in progress
        _Assert.AreEqual(CaptureInProgressMsg(), _LastMessage, 'The capture in progress message should have been shown');

        // [THEN] The line is unchanged and no gateway call was logged
        AssertInFlightLineUntouched(PaymentLine, Psp);
        _Assert.AreEqual(LogEntriesBefore, CountInteractionLogs(PaymentLine.SystemId), 'No interaction log entry should have been added for the payment line');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('CaptureMessageHandler')]
    procedure PaymentLineList_CancelOnInFlightAdyenLine_ShowsInProgressMessage()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
        Psp: Text;
        LogEntriesBefore: Integer;
    begin
        // [SCENARIO] Cancel Payment on an Adyen line with a capture in flight tells the user the capture is in progress and calls nothing
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        LogEntriesBefore := CountInteractionLogs(PaymentLine.SystemId);

        // [WHEN] Cancel Payment is run on the line from the payment line list
        _LastMessage := '';
        PaymentLineList.OpenView();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');
        PaymentLineList."Cancel Payment".Invoke();
        PaymentLineList.Close();

        // [THEN] The user is told the capture is in progress
        _Assert.AreEqual(CaptureInProgressMsg(), _LastMessage, 'The capture in progress message should have been shown');

        // [THEN] The line is unchanged and no gateway call was logged
        AssertInFlightLineUntouched(PaymentLine, Psp);
        _Assert.AreEqual(LogEntriesBefore, CountInteractionLogs(PaymentLine.SystemId), 'No interaction log entry should have been added for the payment line');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,AdyenCaptureApiMock')]
    procedure PaymentLineList_CaptureAgainOnCapturedAdyenLine_ClearsCaptureRequestedAndCaptures()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
    begin
        // [SCENARIO] Capturing again an Adyen line that was captured asynchronously clears Capture Requested first, so the line is captured again instead of being treated as in flight
        Initialize();
        AssertHttpMockAvailable();

        // [GIVEN] An Adyen payment line on a sales order that was captured asynchronously and still has Capture Requested
        CreateAdyenOrderPaymentLineWithCaptureSetup(SalesHeader, PaymentLine);
        PaymentLine."Charge ID" := CopyStr(NewPspReference(), 1, MaxStrLen(PaymentLine."Charge ID"));
        PaymentLine."Capture Requested" := true;
        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify();

        // [GIVEN] An Adyen /capture endpoint that accepts the capture
        ResetCaptureApiMock(NewPspReference());
        Commit();

        // [WHEN] Capture Payment is run on the line from the payment line list and the user confirms capturing again
        PaymentLineList.OpenEdit();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');
        PaymentLineList."Capture Payment".Invoke();
        PaymentLineList.Close();

        // [THEN] Adyen was called once
        AssertOneCaptureRequestSent();

        // [THEN] The line has a new capture in flight with the PSP reference from Adyen as Charge ID
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'The payment line should not be captured before the webhook arrives');
        _Assert.AreEqual(true, PaymentLine."Capture Requested", 'Capture Requested should be set while the new capture is in flight');
        _Assert.AreEqual(_MockCapturePsp, PaymentLine."Charge ID", 'The Charge ID should be the PSP reference of the new capture');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('CaptureMessageHandler')]
    procedure PaymentLineList_ResetCaptureRequestOnLineNotInFlight_ShowsNoCaptureRequestMessage()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
        Psp: Text;
    begin
        // [SCENARIO] Reset Capture Request on an Adyen line without a capture in flight tells the user there is nothing to reset and changes nothing
        Initialize();

        // [GIVEN] An Adyen payment line on a posted invoice with a Charge ID and an open capture log, but no capture requested
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Invoice Header", Enum::"Sales Document Type"::Quote, PaymentLine);
        PaymentLine."Capture Requested" := false;
        PaymentLine.Modify();

        // [WHEN] Reset Capture Request is run on the line from the payment line list
        _LastMessage := '';
        PaymentLineList.OpenView();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');
        PaymentLineList."Reset Capture Request".Invoke();
        PaymentLineList.Close();

        // [THEN] The user is told there is no capture request in progress
        _Assert.AreEqual(NoCaptureRequestMsg(), _LastMessage, 'The no capture request message should have been shown');

        // [THEN] The line and its open capture log are unchanged
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", 'Date Captured should not have been changed');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID should not have been changed');
        _Assert.AreEqual(false, PaymentLine."Capture Requested", 'Capture Requested should not have been changed');
        _Assert.AreEqual(1, CountOpenCaptureLogs(PaymentLine.SystemId), 'The open capture log should not have been completed');

        RestoreFeature();
    end;

    [Test]
    procedure PaymentLineList_ResetCaptureRequest_VisibleForAdyenLineWhenFeatureEnabled()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
    begin
        // [SCENARIO] Reset Capture Request is shown for an Adyen line with capture enabled while the asynchronous capture feature is enabled
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [WHEN] The payment line list is opened on the line
        PaymentLineList.OpenView();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');

        // [THEN] Reset Capture Request is visible
        _Assert.IsTrue(PaymentLineList."Reset Capture Request".Visible(), 'The Reset Capture Request action should be visible');
        PaymentLineList.Close();

        RestoreFeature();
    end;

    [Test]
    procedure PaymentLineList_ResetCaptureRequest_VisibleWhenFeatureDisabled()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
    begin
        // [SCENARIO] Reset Capture Request stays visible while the asynchronous capture feature is disabled, so captures left in flight can still be reset
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] The asynchronous capture feature is disabled
        _AsyncFeature.SetFeatureEnabled(false);

        // [WHEN] The payment line list is opened on the line
        PaymentLineList.OpenView();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');

        // [THEN] Capture Payment is still visible, so the gateway allows capture
        _Assert.IsTrue(PaymentLineList."Capture Payment".Visible(), 'The Capture Payment action should be visible');

        // [THEN] Reset Capture Request is visible
        _Assert.IsTrue(PaymentLineList."Reset Capture Request".Visible(), 'The Reset Capture Request action should be visible');
        PaymentLineList.Close();

        RestoreFeature();
    end;

    [Test]
    procedure PaymentLineList_ResetCaptureRequest_HiddenForNonAdyenGateway()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
    begin
        // [SCENARIO] Reset Capture Request is hidden for a line whose gateway is not Adyen
        Initialize();

        // [GIVEN] A payment line with a capture in flight on a non-Adyen gateway with capture enabled
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        PaymentLine."Payment Gateway Code" := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        PaymentLine.Modify();

        // [WHEN] The payment line list is opened on the line
        PaymentLineList.OpenView();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');

        // [THEN] Capture Payment is still visible, so the gateway allows capture
        _Assert.IsTrue(PaymentLineList."Capture Payment".Visible(), 'The Capture Payment action should be visible');

        // [THEN] Reset Capture Request is hidden
        _Assert.IsFalse(PaymentLineList."Reset Capture Request".Visible(), 'The Reset Capture Request action should be hidden');
        PaymentLineList.Close();

        RestoreFeature();
    end;

    // Guards the Enable Capture part of the visibility rule, so it also passes on the code before the Adyen check.
    [Test]
    procedure PaymentLineList_ResetCaptureRequest_HiddenWhenGatewayCaptureDisabled()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
    begin
        // [SCENARIO] Reset Capture Request is hidden when the line's Adyen gateway has capture disabled
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] The line's gateway has capture disabled
        PaymentGateway.Get(PaymentLine."Payment Gateway Code");
        PaymentGateway."Enable Capture" := false;
        PaymentGateway.Modify();

        // [WHEN] The payment line list is opened on the line
        PaymentLineList.OpenView();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');

        // [THEN] Reset Capture Request is hidden
        _Assert.IsFalse(PaymentLineList."Reset Capture Request".Visible(), 'The Reset Capture Request action should be hidden');
        PaymentLineList.Close();

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_AdyenShowsCapture_MarksLineCapturedAndCompletesLog()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        Psp: Text;
    begin
        // [SCENARIO] Resetting a capture request older than 24 hours as captured marks the line captured, as a successful CAPTURE webhook would
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        Commit();

        // [WHEN] The capture request is reset as captured 25 hours from now
        _Assert.IsTrue(AdyenTryWebhookProcess.ResetCaptureRequest(PaymentLine, true, CurrentDateTime() + MinutesToDuration(25 * 60)), 'The capture request should have been reset');

        // [THEN] The line is captured today, keeps its Charge ID and has no capture in flight
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The payment line should have been marked as captured today');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID should be kept after a reset as captured');
        _Assert.IsFalse(MagentoPmtMgt.IsCaptureInFlight(PaymentLine), 'The payment line should no longer have a capture in flight');

        // [THEN] The capture interaction log is completed as a success
        AssertCaptureLogCompleted(PaymentLine, true);

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_AdyenShowsNoCapture_ReleasesLineAndFailsLog()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
    begin
        // [SCENARIO] Resetting a capture request older than 24 hours as not captured releases the line, as a CAPTURE_FAILED webhook would
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        Commit();

        // [WHEN] The capture request is reset as not captured 25 hours from now
        _Assert.IsTrue(AdyenTryWebhookProcess.ResetCaptureRequest(PaymentLine, false, CurrentDateTime() + MinutesToDuration(25 * 60)), 'The capture request should have been reset');

        // [THEN] The line is not captured and the capture request is cleared
        AssertCaptureFailedOnLine(PaymentLine);

        // [THEN] The capture interaction log is completed as a failure with the reset reason
        AssertCaptureLogCompleted(PaymentLine, false);
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual('Reset by user.', ReadLogErrorMessage(InteractionLog), 'The capture interaction log should carry the reset reason');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('ResetCaptureStrMenuHandler')]
    procedure RunResetCaptureRequest_ChoiceCaptured_MarksLineCaptured()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        MagentoPmtMgt: Codeunit "NPR Magento Pmt. Mgt.";
        Psp: Text;
    begin
        // [SCENARIO] Choosing Captured in the Reset Capture Request menu marks the line captured without asking for confirmation
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        Commit();

        // [GIVEN] The user picks option 1, Captured
        PrepareResetCaptureDialogs(1);

        // [WHEN] Reset Capture Request is run 25 hours from now
        AdyenTryWebhookProcess.RunResetCaptureRequest(PaymentLine, CurrentDateTime() + MinutesToDuration(25 * 60));

        // [THEN] The menu offers Captured first and Not captured second, and names the PSP reference
        _Assert.AreEqual('Captured,Not captured', _LastStrMenuOptions, 'Unexpected Reset Capture Request menu options');
        _Assert.IsTrue(_LastStrMenuInstruction.Contains(UpperCase(Psp)), StrSubstNo('The menu instruction should name the PSP reference, actual instruction: %1', _LastStrMenuInstruction));

        // [THEN] The line is captured today, keeps its Charge ID and has no capture in flight
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'The payment line should have been marked as captured today');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID should be kept after a reset as captured');
        _Assert.IsFalse(MagentoPmtMgt.IsCaptureInFlight(PaymentLine), 'The payment line should no longer have a capture in flight');

        // [THEN] The capture interaction log is completed as a success
        AssertCaptureLogCompleted(PaymentLine, true);

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('ResetCaptureStrMenuHandler,ConfirmYesHandler')]
    procedure RunResetCaptureRequest_ChoiceNotCapturedConfirmed_ReleasesLine()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
    begin
        // [SCENARIO] Choosing Not captured in the Reset Capture Request menu and confirming releases the line
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        Commit();

        // [GIVEN] The user picks option 2, Not captured, and confirms the release
        PrepareResetCaptureDialogs(2);

        // [WHEN] Reset Capture Request is run 25 hours from now
        AdyenTryWebhookProcess.RunResetCaptureRequest(PaymentLine, CurrentDateTime() + MinutesToDuration(25 * 60));

        // [THEN] The release question names the PSP reference
        _Assert.IsTrue(_LastConfirmQuestion.Contains(UpperCase(Psp)), StrSubstNo('The release question should name the PSP reference, actual question: %1', _LastConfirmQuestion));

        // [THEN] The line is not captured and the capture request is cleared
        AssertCaptureFailedOnLine(PaymentLine);

        // [THEN] The capture interaction log is completed as a failure with the reset reason
        AssertCaptureLogCompleted(PaymentLine, false);
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual('Reset by user.', ReadLogErrorMessage(InteractionLog), 'The capture interaction log should carry the reset reason');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('ResetCaptureStrMenuHandler,DisableConfirmNoHandler')]
    procedure RunResetCaptureRequest_ChoiceNotCapturedDeclined_LeavesLineUntouched()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
    begin
        // [SCENARIO] Choosing Not captured in the Reset Capture Request menu and declining the release leaves the capture in flight
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        Commit();

        // [GIVEN] The user picks option 2, Not captured, and declines the release
        PrepareResetCaptureDialogs(2);

        // [WHEN] Reset Capture Request is run 25 hours from now
        AdyenTryWebhookProcess.RunResetCaptureRequest(PaymentLine, CurrentDateTime() + MinutesToDuration(25 * 60));

        // [THEN] The release question was asked for the PSP reference
        _Assert.IsTrue(_LastConfirmQuestion.Contains(UpperCase(Psp)), StrSubstNo('The release question should name the PSP reference, actual question: %1', _LastConfirmQuestion));

        // [THEN] The line keeps its capture in flight and the capture log stays open
        AssertInFlightLineUntouched(PaymentLine, Psp);
        AssertCaptureLogStillInProgress(PaymentLine);

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('CaptureMessageHandler')]
    procedure ResetCaptureRequestAction_CaptureYoungerThan24Hours_IsRefused()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        PaymentLineList: TestPage "NPR Magento Payment Line List";
        Psp: Text;
        RequestedAt: DateTime;
        ExpectedAllowedAfter: DateTime;
        ResetAllowedAfter: DateTime;
        LogEntriesBefore: Integer;
        CaptureResetTooEarlyMsg: Label 'The capture request was sent less than 24 hours ago. Wait for the payment provider to confirm or reject it, or try again after %1.', Comment = '%1 = date and time after which the capture request can be reset';
    begin
        // [SCENARIO] A capture request can be reset only when its open capture log is more than 24 hours old, and the page refuses a younger one
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture requested just now
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        FindCaptureLog(PaymentLine, InteractionLog);
        RequestedAt := InteractionLog.SystemCreatedAt;
        ExpectedAllowedAfter := RequestedAt + MinutesToDuration(24 * 60);
        LogEntriesBefore := CountInteractionLogs(PaymentLine.SystemId);

        // [THEN] A reset becomes possible strictly after 24 hours from the stored log creation time
        _Assert.IsTrue(AdyenTryWebhookProcess.GetCaptureResetAllowedAfter(PaymentLine, ResetAllowedAfter), 'The time after which a reset is allowed should be known');
        _Assert.AreEqual(ExpectedAllowedAfter, ResetAllowedAfter, 'A reset should be allowed 24 hours after the capture log was created');
        _Assert.IsFalse(AdyenTryWebhookProcess.IsCaptureResetAllowed(PaymentLine, CurrentDateTime()), 'A reset should not be allowed right after the capture request');
        _Assert.IsFalse(AdyenTryWebhookProcess.IsCaptureResetAllowed(PaymentLine, ExpectedAllowedAfter), 'A reset should not be allowed exactly 24 hours after the capture request');
        _Assert.IsTrue(AdyenTryWebhookProcess.IsCaptureResetAllowed(PaymentLine, ExpectedAllowedAfter + 1), 'A reset should be allowed 1 ms after 24 hours from the capture request');

        // [WHEN] Reset Capture Request is run on the line from the payment line list now
        _LastMessage := '';
        PaymentLineList.OpenView();
        _Assert.IsTrue(PaymentLineList.GoToRecord(PaymentLine), 'The payment line should be shown on the payment line list');
        PaymentLineList."Reset Capture Request".Invoke();
        PaymentLineList.Close();

        // [THEN] The user is told the reset is possible after 24 hours
        _Assert.AreEqual(StrSubstNo(CaptureResetTooEarlyMsg, ExpectedAllowedAfter), _LastMessage, 'The reset too early message should have been shown');

        // [THEN] The line and its capture log are unchanged and no log entry was added
        AssertInFlightLineUntouched(PaymentLine, Psp);
        AssertCaptureLogStillInProgress(PaymentLine);
        _Assert.AreEqual(LogEntriesBefore, CountInteractionLogs(PaymentLine.SystemId), 'No interaction log entry should have been added for the payment line');

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_PartialPostingCopy_ReleasesBothLines()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceCopyLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
    begin
        // [SCENARIO] Resetting the posted invoice copy releases every capturable line with the same Charge ID, as a CAPTURE_FAILED webhook would
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] Partial posting split the line into a posted invoice copy with the same Charge ID and no capture log
        CreatePostedInvoiceCopy(PaymentLine, InvoiceCopyLine);
        Commit();

        // [WHEN] The capture request of the invoice copy is reset as not captured 25 hours from now
        _Assert.IsTrue(AdyenTryWebhookProcess.ResetCaptureRequest(InvoiceCopyLine, false, CurrentDateTime() + MinutesToDuration(25 * 60)), 'The capture request should have been reset');

        // [THEN] Neither line is captured and both capture requests are cleared
        AssertCaptureFailedOnLine(PaymentLine);
        AssertCaptureFailedOnLine(InvoiceCopyLine);

        // [THEN] The capture interaction log of the order line is completed as a failure
        AssertCaptureLogCompleted(PaymentLine, false);

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_NoOpenCaptureLog_IsRefused()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
    begin
        // [SCENARIO] A capture in flight without an open capture log has no known age, so it cannot be reset
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight whose capture log was deleted
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        InteractionLog.SetRange("Payment Line System Id", PaymentLine.SystemId);
        InteractionLog.DeleteAll();
        Commit();

        // [WHEN] A reset is checked and attempted 25 hours from now
        // [THEN] It is not allowed and nothing is reset
        _Assert.IsFalse(AdyenTryWebhookProcess.IsCaptureResetAllowed(PaymentLine, CurrentDateTime() + MinutesToDuration(25 * 60)), 'A reset should not be allowed without an open capture log');
        _Assert.IsFalse(AdyenTryWebhookProcess.ResetCaptureRequest(PaymentLine, false, CurrentDateTime() + MinutesToDuration(25 * 60)), 'The capture request should not have been reset without an open capture log');

        // [THEN] The line is unchanged
        AssertInFlightLineUntouched(PaymentLine, Psp);

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_LineAlreadyCaptured_ChangesNothing()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
    begin
        // [SCENARIO] A line that is already captured has no capture in flight, so a reset changes nothing
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order that was captured today and still has an open capture log
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        PaymentLine."Date Captured" := Today();
        PaymentLine.Modify();
        Commit();

        // [WHEN] The capture request is reset as not captured 25 hours from now
        // [THEN] Nothing is reset
        _Assert.IsFalse(AdyenTryWebhookProcess.ResetCaptureRequest(PaymentLine, false, CurrentDateTime() + MinutesToDuration(25 * 60)), 'A captured line should not have been reset');

        // [THEN] The line and its capture log are unchanged
        PaymentLine.Find();
        _Assert.AreEqual(Today(), PaymentLine."Date Captured", 'Date Captured should not have been changed');
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", 'The Charge ID should not have been changed');
        _Assert.AreEqual(true, PaymentLine."Capture Requested", 'Capture Requested should not have been changed');
        AssertCaptureLogStillInProgress(PaymentLine);

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_CaptureYoungerThan24Hours_ChangesNothing()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
    begin
        // [SCENARIO] The reset checks the 24 hour rule again itself, so a reset of a capture requested just now changes nothing
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture requested just now
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        Commit();

        // [WHEN] The capture request is reset as not captured now
        // [THEN] Nothing is reset
        _Assert.IsFalse(AdyenTryWebhookProcess.ResetCaptureRequest(PaymentLine, false, CurrentDateTime()), 'A capture request younger than 24 hours should not have been reset');

        // [THEN] The line and its capture log are unchanged
        AssertInFlightLineUntouched(PaymentLine, Psp);
        AssertCaptureLogStillInProgress(PaymentLine);

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_OtherChargeId_IsNotTouched()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        OtherPaymentLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
        OtherPsp: Text;
    begin
        // [SCENARIO] Resetting one capture request leaves a capture in flight with another Charge ID untouched
        Initialize();

        // [GIVEN] Two Adyen payment lines on sales orders, each with a capture in flight under its own PSP reference
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        OtherPsp := NewPspReference();
        CreateAdyenInFlightLine(OtherPsp, Database::"Sales Header", Enum::"Sales Document Type"::Order, OtherPaymentLine);
        Commit();

        // [WHEN] The capture request of the first line is reset as not captured 25 hours from now
        _Assert.IsTrue(AdyenTryWebhookProcess.ResetCaptureRequest(PaymentLine, false, CurrentDateTime() + MinutesToDuration(25 * 60)), 'The capture request should have been reset');

        // [THEN] The first line is released
        AssertCaptureFailedOnLine(PaymentLine);

        // [THEN] The other line and its capture log are unchanged
        AssertInFlightLineUntouched(OtherPaymentLine, OtherPsp);
        AssertCaptureLogStillInProgress(OtherPaymentLine);

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_BlankChargeId_ResetsOnlySelectedLine()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        OtherPaymentLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
    begin
        // [SCENARIO] A capture in flight without a Charge ID is reset alone, not together with other lines that also lack a Charge ID
        Initialize();

        // [GIVEN] Two Adyen payment lines on sales orders, each with a capture in flight and no Charge ID, as when Adyen returned no PSP reference
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        PaymentLine."Charge ID" := '';
        PaymentLine.Modify();
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, OtherPaymentLine);
        OtherPaymentLine."Charge ID" := '';
        OtherPaymentLine.Modify();
        Commit();

        // [WHEN] The capture request of the first line is reset as not captured 25 hours from now
        _Assert.IsTrue(AdyenTryWebhookProcess.ResetCaptureRequest(PaymentLine, false, CurrentDateTime() + MinutesToDuration(25 * 60)), 'The capture request should have been reset');

        // [THEN] The first line is released and its capture log is completed as a failure
        AssertCaptureFailedOnLine(PaymentLine);
        AssertCaptureLogCompleted(PaymentLine, false);

        // [THEN] The other line and its capture log are unchanged
        AssertInFlightLineUntouched(OtherPaymentLine, '');
        AssertCaptureLogStillInProgress(OtherPaymentLine);

        RestoreFeature();
    end;

    [Test]
    procedure IsCaptureResetAllowed_OrphanOlderOpenLog_UsesNewestOpenLog()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
        OlderRequestedAt: DateTime;
        NewerRequestedAt: DateTime;
    begin
        // [SCENARIO] When a line has an orphan open capture log from an earlier attempt, the age of the capture request is taken from the newest open log
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight and its open capture log
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A newer open capture log for the same line, created a moment later
        Sleep(50);
        LogMgt.LogCaptureStart(InteractionLog, PaymentLine.SystemId);

        InteractionLog.Reset();
        InteractionLog.SetRange("Payment Line System Id", PaymentLine.SystemId);
        InteractionLog.SetRange("Interaction Type", InteractionLog."Interaction Type"::Capture);
        InteractionLog.SetRange("In Progress", true);
        _Assert.AreEqual(2, InteractionLog.Count(), 'The line should have two open capture logs');
        InteractionLog.FindFirst();
        OlderRequestedAt := InteractionLog.SystemCreatedAt;
        InteractionLog.FindLast();
        NewerRequestedAt := InteractionLog.SystemCreatedAt;
        _Assert.IsTrue(NewerRequestedAt > OlderRequestedAt, 'The second open capture log should have been created after the first');

        // [WHEN] A reset is checked just after 24 hours from the older log, and just after 24 hours from the newer log
        // [THEN] Only the newer log decides
        _Assert.IsFalse(AdyenTryWebhookProcess.IsCaptureResetAllowed(PaymentLine, OlderRequestedAt + MinutesToDuration(24 * 60) + 1), 'The orphan older log should not make the capture request old enough to reset');
        _Assert.IsTrue(AdyenTryWebhookProcess.IsCaptureResetAllowed(PaymentLine, NewerRequestedAt + MinutesToDuration(24 * 60) + 1), 'A reset should be allowed 24 hours after the newest open capture log');

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_StaleChargeIdOnPageRecord_ChangesNothing()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        OtherPaymentLine: Record "NPR Magento Payment Line";
        StalePaymentLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
        OtherPsp: Text;
    begin
        // [SCENARIO] A reset started from a page record whose Charge ID no longer matches the stored line changes nothing, neither on the stored line nor on the lines of the stale Charge ID
        Initialize();

        // [GIVEN] Two Adyen payment lines on sales orders, each with a capture in flight under its own PSP reference
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);
        OtherPsp := NewPspReference();
        CreateAdyenInFlightLine(OtherPsp, Database::"Sales Header", Enum::"Sales Document Type"::Order, OtherPaymentLine);

        // [GIVEN] A page record of the second line that still shows the Charge ID of the first line
        StalePaymentLine := OtherPaymentLine;
        StalePaymentLine."Charge ID" := CopyStr(Psp, 1, MaxStrLen(StalePaymentLine."Charge ID"));
        Commit();

        // [WHEN] The capture request of the stale page record is reset as not captured 25 hours from now
        // [THEN] Nothing is reset
        _Assert.IsFalse(AdyenTryWebhookProcess.ResetCaptureRequest(StalePaymentLine, false, CurrentDateTime() + MinutesToDuration(25 * 60)), 'A page record with a stale Charge ID should not have been reset');

        // [THEN] Both lines and their capture logs are unchanged
        AssertInFlightLineUntouched(PaymentLine, Psp);
        AssertCaptureLogStillInProgress(PaymentLine);
        AssertInFlightLineUntouched(OtherPaymentLine, OtherPsp);
        AssertCaptureLogStillInProgress(OtherPaymentLine);

        RestoreFeature();
    end;

    [Test]
    procedure CaptureWebhook_LineWithOrphanOpenLog_CompletesNewestLog()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        Psp: Text;
        OlderEntryNo: BigInteger;
        NewerEntryNo: BigInteger;
    begin
        // [SCENARIO] When a line has an orphan open capture log from an earlier attempt, a successful CAPTURE webhook completes the newest open log
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight and its open capture log
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A newer open capture log for the same line, created a moment later
        Sleep(50);
        LogMgt.LogCaptureStart(InteractionLog, PaymentLine.SystemId);

        InteractionLog.Reset();
        InteractionLog.SetRange("Payment Line System Id", PaymentLine.SystemId);
        InteractionLog.SetRange("Interaction Type", InteractionLog."Interaction Type"::Capture);
        InteractionLog.SetRange("In Progress", true);
        _Assert.AreEqual(2, InteractionLog.Count(), 'The line should have two open capture logs');
        InteractionLog.FindFirst();
        OlderEntryNo := InteractionLog."Entry No.";
        InteractionLog.FindLast();
        NewerEntryNo := InteractionLog."Entry No.";
        _Assert.IsTrue(NewerEntryNo > OlderEntryNo, 'The second open capture log should have a higher entry number than the first');

        // [GIVEN] A successful CAPTURE webhook for its PSP reference
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);

        // [WHEN] The webhook is processed
        ProcessWebhook(AdyenWebhook);

        // [THEN] The newest capture log is completed as a success
        InteractionLog.Get(NewerEntryNo);
        _Assert.AreEqual(false, InteractionLog."In Progress", 'The newest capture log should have been completed');
        _Assert.AreEqual(true, InteractionLog."Operation Success", 'The newest capture log should have been completed as a success');

        // [THEN] The orphan older capture log is still open
        InteractionLog.Get(OlderEntryNo);
        _Assert.AreEqual(true, InteractionLog."In Progress", 'The orphan older capture log should not have been completed');

        RestoreFeature();
    end;

    [Test]
    procedure IsCaptureResetAllowed_ChargeIdScope_UsesNewestLogAcrossLines()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceCopyLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
        OlderRequestedAt: DateTime;
        NewerRequestedAt: DateTime;
    begin
        // [SCENARIO] When several lines share a Charge ID, the age of the capture request is taken from the newest open capture log of all of them
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight and its open capture log
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A posted invoice copy with the same Charge ID and its own open capture log, created a moment later
        CreatePostedInvoiceCopy(PaymentLine, InvoiceCopyLine);
        Sleep(50);
        LogMgt.LogCaptureStart(InteractionLog, InvoiceCopyLine.SystemId);

        InteractionLog.Reset();
        InteractionLog.SetRange("Interaction Type", InteractionLog."Interaction Type"::Capture);
        InteractionLog.SetRange("In Progress", true);
        InteractionLog.SetRange("Payment Line System Id", PaymentLine.SystemId);
        InteractionLog.FindLast();
        OlderRequestedAt := InteractionLog.SystemCreatedAt;
        InteractionLog.SetRange("Payment Line System Id", InvoiceCopyLine.SystemId);
        InteractionLog.FindLast();
        NewerRequestedAt := InteractionLog.SystemCreatedAt;
        _Assert.IsTrue(NewerRequestedAt > OlderRequestedAt, 'The capture log of the invoice copy should have been created after the one of the order line');

        // [WHEN] A reset of the invoice copy is checked just after 24 hours from the older log, and just after 24 hours from the newer log
        // [THEN] Only the newest log across the lines with the same Charge ID decides
        _Assert.IsFalse(AdyenTryWebhookProcess.IsCaptureResetAllowed(InvoiceCopyLine, OlderRequestedAt + MinutesToDuration(24 * 60) + 1), 'The older log of the order line should not make the capture request old enough to reset');
        _Assert.IsTrue(AdyenTryWebhookProcess.IsCaptureResetAllowed(InvoiceCopyLine, NewerRequestedAt + MinutesToDuration(24 * 60) + 1), 'A reset should be allowed 24 hours after the newest open capture log of the Charge ID');

        // [WHEN] A reset of the order line is checked at the same two times
        // [THEN] The newer log of the invoice copy decides for the order line too
        _Assert.IsFalse(AdyenTryWebhookProcess.IsCaptureResetAllowed(PaymentLine, OlderRequestedAt + MinutesToDuration(24 * 60) + 1), 'The own older log of the order line should not make the capture request old enough to reset');
        _Assert.IsTrue(AdyenTryWebhookProcess.IsCaptureResetAllowed(PaymentLine, NewerRequestedAt + MinutesToDuration(24 * 60) + 1), 'A reset of the order line should be allowed 24 hours after the newest open capture log of the Charge ID');

        RestoreFeature();
    end;

    [Test]
    procedure ResetCaptureRequest_SiblingAlreadyCaptured_IsNotTouched()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        CapturedCopyLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        Psp: Text;
    begin
        // [SCENARIO] Resetting a capture request releases only the lines of the Charge ID that are still in flight, and leaves an already captured line with the same Charge ID untouched
        Initialize();

        // [GIVEN] An Adyen payment line on a sales order with a capture in flight and its open capture log
        Psp := NewPspReference();
        CreateAdyenInFlightLine(Psp, Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] A posted invoice copy with the same Charge ID that is already captured today
        CreatePostedInvoiceCopy(PaymentLine, CapturedCopyLine);
        CapturedCopyLine."Date Captured" := Today();
        CapturedCopyLine."Capture Requested" := false;
        CapturedCopyLine.Modify();
        Commit();

        // [WHEN] The capture request of the order line is reset as not captured 25 hours from now
        _Assert.IsTrue(AdyenTryWebhookProcess.ResetCaptureRequest(PaymentLine, false, CurrentDateTime() + MinutesToDuration(25 * 60)), 'The capture request should have been reset');

        // [THEN] The order line is released
        AssertCaptureFailedOnLine(PaymentLine);

        // [THEN] The captured invoice copy keeps its Charge ID and capture date
        CapturedCopyLine.Find();
        _Assert.AreEqual(UpperCase(Psp), CapturedCopyLine."Charge ID", 'The Charge ID of the captured line should not have been changed');
        _Assert.AreEqual(Today(), CapturedCopyLine."Date Captured", 'Date Captured of the captured line should not have been changed');
        _Assert.AreEqual(false, CapturedCopyLine."Capture Requested", 'Capture Requested of the captured line should not have been changed');

        RestoreFeature();
    end;

    [Test]
    procedure Posting_FullyInvoicedOrderWithCaptureInFlight_MovesOpenLogToInvoiceCopy()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        CopyLine: Record "NPR Magento Payment Line";
        SourceLine: Record "NPR Magento Payment Line";
        AdyenWebhook: Record "NPR Adyen Webhook";
        SalesPost: Codeunit "Sales-Post";
        SourceSystemId: Guid;
        Psp: Text;
    begin
        // [SCENARIO] Posting that invoices the whole Adyen order payment line with a capture in flight moves the open capture log to the posted invoice copy, so the webhook completes it
        Initialize();

        // [GIVEN] A sales order with an Adyen payment line with a capture in flight and its open capture log
        CreateAdyenOrderPaymentLine(SalesHeader, PaymentLine, _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen));
        Psp := NewPspReference();
        MarkInFlightWithLog(PaymentLine, Psp);
        SourceSystemId := PaymentLine.SystemId;
        Commit();

        // [WHEN] The order is shipped and invoiced in full
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] The posted invoice copy still has the capture in flight, so posting did not capture it again
        _Assert.IsTrue(CopyLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');
        AssertInFlightLineUntouched(CopyLine, Psp);

        // [THEN] The order payment line is gone with the order
        _Assert.IsFalse(SourceLine.GetBySystemId(SourceSystemId), 'The order payment line should have been deleted with the posted order');

        // [THEN] The open capture log is on the invoice copy and none is left on the order line
        _Assert.AreEqual(1, CountOpenCaptureLogs(CopyLine.SystemId), 'The open capture log should have moved to the posted invoice copy');
        _Assert.AreEqual(0, CountOpenCaptureLogs(SourceSystemId), 'No open capture log should be left on the deleted order payment line');

        // [WHEN] A successful CAPTURE webhook for its PSP reference is processed
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, Psp, 'true', '', CurrentDateTime(), AdyenWebhook);
        ProcessWebhook(AdyenWebhook);

        // [THEN] The invoice copy is captured today and its capture log is completed as a success
        CopyLine.Find();
        _Assert.AreEqual(Today(), CopyLine."Date Captured", 'The posted invoice copy should have been marked as captured today');
        AssertCaptureLogCompleted(CopyLine, true);

        RestoreFeature();
    end;

    [Test]
    procedure Posting_PartiallyInvoicedOrderWithCaptureInFlight_MovesOpenLogToInvoiceCopy()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentLine: Record "NPR Magento Payment Line";
        CopyLine: Record "NPR Magento Payment Line";
        LibrarySales: Codeunit "Library - Sales";
        SalesPost: Codeunit "Sales-Post";
        Psp: Text;
    begin
        // [SCENARIO] Posting that invoices only part of the Adyen order payment line with a capture in flight moves the open capture log to the posted invoice copy
        Initialize();

        // [GIVEN] A sales order with 2 units of which 1 is to be shipped and invoiced
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine.Validate(Quantity, 2);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(true);

        // [GIVEN] An Adyen payment line for the full order amount with a capture in flight and its open capture log
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen), PaymentLine);
        Psp := NewPspReference();
        MarkInFlightWithLog(PaymentLine, Psp);
        Commit();

        // [WHEN] The order is shipped and invoiced for the quantity to ship
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] The order payment line keeps the rest of the amount and the capture in flight
        PaymentLine.Find();
        _Assert.IsTrue(PaymentLine.Amount > 0, 'The order payment line should keep the amount that was not invoiced');
        AssertInFlightLineUntouched(PaymentLine, Psp);

        // [THEN] The open capture log is on the posted invoice copy and none is left on the order line
        _Assert.IsTrue(CopyLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');
        _Assert.AreEqual(1, CountOpenCaptureLogs(CopyLine.SystemId), 'The open capture log should have moved to the posted invoice copy');
        _Assert.AreEqual(0, CountOpenCaptureLogs(PaymentLine.SystemId), 'No open capture log should be left on the order payment line');

        RestoreFeature();
    end;

    [Test]
    procedure Posting_OverpaidOrderFullyInvoicedWithCaptureInFlight_MovesOpenLogToInvoiceCopy()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        CopyLine: Record "NPR Magento Payment Line";
        SourceLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        SalesPost: Codeunit "Sales-Post";
        SourceSystemId: Guid;
        OverpaidAmount: Decimal;
        Psp: Text;
    begin
        // [SCENARIO] Posting that invoices the whole order paid with more than its total moves the open capture log to the posted invoice copy, so it survives the delete of the order
        Initialize();

        // [GIVEN] A sales order with an Adyen payment line 10 above the order total, in the document currency, with a capture in flight and its open capture log
        CreateAdyenOrderPaymentLine(SalesHeader, PaymentLine, _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen));
        PaymentLine.Amount += 10;
        PaymentLine.Modify();
        Psp := NewPspReference();
        MarkInFlightWithLog(PaymentLine, Psp);
        SourceSystemId := PaymentLine.SystemId;
        OverpaidAmount := PaymentLine.Amount;
        Commit();

        // [WHEN] The order is shipped and invoiced in full
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] The posted invoice copy holds only the invoiced part of the payment, and the order payment line is gone with the order
        _Assert.IsTrue(CopyLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');
        _Assert.IsTrue(CopyLine.Amount < OverpaidAmount, 'The posted invoice copy should hold less than the overpaid amount');
        _Assert.IsFalse(SourceLine.GetBySystemId(SourceSystemId), 'The order payment line should have been deleted with the posted order');

        // [THEN] The open capture log is on the posted invoice copy and none is left on the deleted order line
        _Assert.AreEqual(1, CountOpenCaptureLogs(CopyLine.SystemId), 'The open capture log should have moved to the posted invoice copy');
        _Assert.AreEqual(0, CountOpenCaptureLogs(SourceSystemId), 'No open capture log should be left on the deleted order payment line');

        // [THEN] The capture request of the copy can be reset only after 24 hours
        _Assert.IsFalse(AdyenTryWebhookProcess.IsCaptureResetAllowed(CopyLine, CurrentDateTime()), 'A reset should not be allowed right after posting');
        _Assert.IsTrue(AdyenTryWebhookProcess.IsCaptureResetAllowed(CopyLine, CurrentDateTime() + MinutesToDuration(25 * 60)), 'A reset of the posted invoice copy should be allowed after 24 hours');

        RestoreFeature();
    end;

    [Test]
    procedure Posting_PartiallyInvoicedOrderThenDeleted_InvoiceCopyKeepsOpenLog()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentLine: Record "NPR Magento Payment Line";
        CopyLine: Record "NPR Magento Payment Line";
        SourceLine: Record "NPR Magento Payment Line";
        AdyenTryWebhookProcess: Codeunit "NPR Adyen Try Webhook Process";
        LibrarySales: Codeunit "Library - Sales";
        SalesPost: Codeunit "Sales-Post";
        SourceSystemId: Guid;
        Psp: Text;
    begin
        // [SCENARIO] When a partly invoiced order is deleted, the posted invoice copy keeps the open capture log, so the capture can still be completed or reset
        Initialize();

        // [GIVEN] A sales order with 2 units of which 1 is to be shipped and invoiced
        LibrarySales.CreateSalesOrder(SalesHeader);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine.Validate(Quantity, 2);
        SalesLine.Validate("Qty. to Ship", 1);
        SalesLine.Modify(true);

        // [GIVEN] An Adyen payment line for the full order amount with a capture in flight and its open capture log
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen), PaymentLine);
        Psp := NewPspReference();
        MarkInFlightWithLog(PaymentLine, Psp);
        SourceSystemId := PaymentLine.SystemId;
        Commit();

        // [GIVEN] The order is shipped and invoiced for the quantity to ship
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);
        _Assert.IsTrue(CopyLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');

        // [WHEN] The partly invoiced order is deleted
        SalesHeader.Find();
        SalesHeader.Delete(true);

        // [THEN] The order payment line is gone with the order
        _Assert.IsFalse(SourceLine.GetBySystemId(SourceSystemId), 'The order payment line should have been deleted with the order');

        // [THEN] The posted invoice copy keeps the capture in flight and the open capture log
        AssertInFlightLineUntouched(CopyLine, Psp);
        _Assert.AreEqual(1, CountOpenCaptureLogs(CopyLine.SystemId), 'The posted invoice copy should keep the open capture log');

        // [THEN] The capture request of the copy can be reset after 24 hours
        CopyLine.Find();
        _Assert.IsTrue(AdyenTryWebhookProcess.IsCaptureResetAllowed(CopyLine, CurrentDateTime() + MinutesToDuration(25 * 60)), 'A reset of the posted invoice copy should be allowed after 24 hours');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenCaptureApiMock')]
    procedure Posting_FeatureOn_PostedInvoiceLine_CaptureStaysInFlight()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        CopyLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        SalesPost: Codeunit "Sales-Post";
    begin
        // [SCENARIO] With the feature enabled, the capture that posting sends for the posted invoice line stays in flight until the webhook arrives
        Initialize();
        AssertHttpMockAvailable();

        // [GIVEN] A sales order with an Adyen payment line and an Adyen /capture endpoint that accepts the capture
        CreateAdyenOrderPaymentLineWithCaptureSetup(SalesHeader, PaymentLine);
        ResetCaptureApiMock(NewPspReference());
        Commit();

        // [WHEN] The order is shipped and invoiced in full
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] Adyen was called once
        AssertOneCaptureRequestSent();

        // [THEN] The posted invoice line has a capture in flight with the PSP reference from Adyen as Charge ID
        _Assert.IsTrue(CopyLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');
        _Assert.AreEqual(0D, CopyLine."Date Captured", 'The posted invoice line should not be captured before the webhook arrives');
        _Assert.AreEqual(true, CopyLine."Capture Requested", 'Capture Requested should be set while the capture is in flight');
        _Assert.AreEqual(_MockCapturePsp, CopyLine."Charge ID", 'The Charge ID should be the PSP reference returned by Adyen');

        // [THEN] The capture interaction log of the posted invoice line stays in progress and is not a success yet
        FindCaptureLog(CopyLine, InteractionLog);
        _Assert.AreEqual(true, InteractionLog."In Progress", 'The capture interaction log should stay in progress until the webhook arrives');
        _Assert.AreEqual(false, InteractionLog."Operation Success", 'The capture interaction log should not be a success before the webhook arrives');

        RestoreFeature();
    end;

    [Test]
    procedure Posting_FullyInvoicedOrderWithOrphanOpenLog_MovesEveryOpenLogToInvoiceCopy()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        CopyLine: Record "NPR Magento Payment Line";
        InteractionLog: Record "NPR PG Interaction Log Entry";
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
        SalesPost: Codeunit "Sales-Post";
        SourceSystemId: Guid;
        Psp: Text;
    begin
        // [SCENARIO] Posting that invoices the whole Adyen order payment line moves every open capture log to the posted invoice copy, including an orphan from an earlier attempt
        Initialize();

        // [GIVEN] A sales order with an Adyen payment line with an orphan open capture log, a capture in flight and its open capture log
        CreateAdyenOrderPaymentLine(SalesHeader, PaymentLine, _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen));
        LogMgt.LogCaptureStart(InteractionLog, PaymentLine.SystemId);
        Psp := NewPspReference();
        MarkInFlightWithLog(PaymentLine, Psp);
        SourceSystemId := PaymentLine.SystemId;
        Commit();

        // [WHEN] The order is shipped and invoiced in full
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);

        // [THEN] Both open capture logs are on the posted invoice copy and none is left on the order line
        _Assert.IsTrue(CopyLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');
        _Assert.AreEqual(2, CountOpenCaptureLogs(CopyLine.SystemId), 'Every open capture log should have moved to the posted invoice copy');
        _Assert.AreEqual(0, CountOpenCaptureLogs(SourceSystemId), 'No open capture log should be left on the deleted order payment line');

        RestoreFeature();
    end;

    [Test]
    procedure CopyToCreditMemo_PostedInvoiceWithCaptureInFlight_ClearsCaptureOnCopy()
    var
        SalesHeader: Record "Sales Header";
        CrMemoHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        PostedLine: Record "NPR Magento Payment Line";
        CreditLine: Record "NPR Magento Payment Line";
        SalesPost: Codeunit "Sales-Post";
        Psp: Text;
    begin
        // [SCENARIO] A credit memo copied from a posted invoice whose Adyen capture is in flight does not inherit the capture in flight
        Initialize();

        // [GIVEN] A posted invoice with an Adyen payment line with a capture in flight
        CreateAdyenOrderPaymentLine(SalesHeader, PaymentLine, _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen));
        Psp := NewPspReference();
        MarkInFlightWithLog(PaymentLine, Psp);
        Commit();
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);
        _Assert.IsTrue(PostedLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');
        AssertInFlightLineUntouched(PostedLine, Psp);

        // [WHEN] A credit memo is copied from the posted invoice
        CreateCreditMemoFromPostedInvoice(SalesHeader."Last Posting No.", CrMemoHeader);

        // [THEN] The credit memo payment line has no capture in flight and keeps the payment details
        _Assert.IsTrue(CreditLine.Get(Database::"Sales Header", CrMemoHeader."Document Type", CrMemoHeader."No.", PaymentLine."Line No."), 'The payment line for the credit memo should have been created');
        _Assert.AreEqual(false, CreditLine."Capture Requested", 'Capture Requested should have been cleared on the credit memo payment line');
        _Assert.AreEqual('', CreditLine."Charge ID", 'The Charge ID should have been cleared on the credit memo payment line');
        _Assert.AreEqual(0D, CreditLine."Date Captured", 'The credit memo payment line should not be marked as captured');
        _Assert.AreEqual(PostedLine."Transaction ID", CreditLine."Transaction ID", 'The Transaction ID should have been copied to the credit memo payment line');
        _Assert.AreEqual(PostedLine.Amount, CreditLine.Amount, 'The amount should have been copied to the credit memo payment line');
        _Assert.AreEqual(PostedLine."Payment Gateway Code", CreditLine."Payment Gateway Code", 'The payment gateway should have been copied to the credit memo payment line');

        // [THEN] The posted invoice payment line still has its capture in flight
        AssertInFlightLineUntouched(PostedLine, Psp);

        RestoreFeature();
    end;

    [Test]
    procedure CopyToCreditMemo_PostedInvoiceCaptured_KeepsCaptureOnCopy()
    var
        SalesHeader: Record "Sales Header";
        CrMemoHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        PostedLine: Record "NPR Magento Payment Line";
        CreditLine: Record "NPR Magento Payment Line";
        SalesPost: Codeunit "Sales-Post";
        Psp: Text;
    begin
        // [SCENARIO] A credit memo copied from a posted invoice whose Adyen capture is confirmed keeps the capture details
        Initialize();

        // [GIVEN] A posted invoice with an Adyen payment line captured today
        CreateAdyenOrderPaymentLine(SalesHeader, PaymentLine, _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen));
        Psp := NewPspReference();
        MarkInFlightWithLog(PaymentLine, Psp);
        Commit();
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);
        _Assert.IsTrue(PostedLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');
        AssertInFlightLineUntouched(PostedLine, Psp);
        PostedLine."Date Captured" := Today();
        PostedLine.Modify();

        // [WHEN] A credit memo is copied from the posted invoice
        CreateCreditMemoFromPostedInvoice(SalesHeader."Last Posting No.", CrMemoHeader);

        // [THEN] The credit memo payment line keeps the capture details
        _Assert.IsTrue(CreditLine.Get(Database::"Sales Header", CrMemoHeader."Document Type", CrMemoHeader."No.", PaymentLine."Line No."), 'The payment line for the credit memo should have been created');
        _Assert.AreEqual(true, CreditLine."Capture Requested", 'Capture Requested should have been copied to the credit memo payment line');
        _Assert.AreEqual(PostedLine."Charge ID", CreditLine."Charge ID", 'The Charge ID should have been copied to the credit memo payment line');
        _Assert.AreEqual(Today(), CreditLine."Date Captured", 'Date Captured should have been copied to the credit memo payment line');

        RestoreFeature();
    end;

    [Test]
    procedure CopyToCreditMemo_NonAdyenCaptureRequested_KeepsCaptureOnCopy()
    var
        SalesHeader: Record "Sales Header";
        CrMemoHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        PostedLine: Record "NPR Magento Payment Line";
        CreditLine: Record "NPR Magento Payment Line";
        SalesPost: Codeunit "Sales-Post";
        Psp: Text;
    begin
        // [SCENARIO] A credit memo copied from a posted invoice with a requested, unconfirmed capture on a non-Adyen gateway keeps the capture details
        Initialize();

        // [GIVEN] A posted invoice with a payment line with a capture requested and not confirmed
        CreateAdyenOrderPaymentLine(SalesHeader, PaymentLine, _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen));
        Psp := NewPspReference();
        MarkInFlightWithLog(PaymentLine, Psp);
        Commit();
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        SalesPost.Run(SalesHeader);
        _Assert.IsTrue(PostedLine.Get(Database::"Sales Invoice Header", 0, SalesHeader."Last Posting No.", PaymentLine."Line No."), 'The payment line for the posted invoice should have been created');
        AssertInFlightLineUntouched(PostedLine, Psp);

        // [GIVEN] The posted invoice payment line belongs to a non-Adyen gateway
        PostedLine."Payment Gateway Code" := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        PostedLine.Modify();

        // [WHEN] A credit memo is copied from the posted invoice
        CreateCreditMemoFromPostedInvoice(SalesHeader."Last Posting No.", CrMemoHeader);

        // [THEN] The credit memo payment line keeps the capture details
        _Assert.IsTrue(CreditLine.Get(Database::"Sales Header", CrMemoHeader."Document Type", CrMemoHeader."No.", PaymentLine."Line No."), 'The payment line for the credit memo should have been created');
        _Assert.AreEqual(true, CreditLine."Capture Requested", 'Capture Requested should have been copied to the credit memo payment line');
        _Assert.AreEqual(PostedLine."Charge ID", CreditLine."Charge ID", 'The Charge ID should have been copied to the credit memo payment line');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EnsureCaptureWebhooks_ExistingCombinedFilterWebhook_CreatesNoNewWebhook()
    var
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] Creating the capture webhooks reuses an active webhook whose event filter lists CAPTURE and CAPTURE_FAILED among other events
        Initialize();

        // [GIVEN] One merchant with an active standard webhook for AUTHORISATION, CAPTURE and CAPTURE_FAILED
        PrepareEnsureWebhookFixture('AUTHORISATION|CAPTURE|CAPTURE_FAILED', MerchantName, ApiKeyAdded);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] No webhook was added for the merchant
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'No webhook should have been created for the merchant');

        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EnsureCaptureWebhooks_ExistingEmptyFilterWebhook_CreatesNoNewWebhook()
    var
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] Creating the capture webhooks reuses an active webhook with an empty event filter, which delivers the default events
        Initialize();

        // [GIVEN] One merchant with an active standard webhook without an event filter
        PrepareEnsureWebhookFixture('', MerchantName, ApiKeyAdded);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] No webhook was added for the merchant
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'No webhook should have been created for the merchant');

        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EnsureCaptureWebhooks_ExistingRangeFilterWebhook_CreatesNoNewWebhook()
    var
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] Creating the capture webhooks reuses an active webhook whose event filter holds a range that starts at CAPTURE and ends at CAPTURE_FAILED
        Initialize();

        // [GIVEN] One merchant with an active standard webhook whose filter is the form the setup card writes for adjacent events
        PrepareEnsureWebhookFixture('AUTHORISATION|CAPTURE..CAPTURE_FAILED|REFUND', MerchantName, ApiKeyAdded);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] No webhook was added for the merchant
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'No webhook should have been created for the merchant');

        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EnsureCaptureWebhooks_EventInsideRangeFilter_CreatesNoNewWebhook()
    var
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] Creating the capture webhooks reuses an active webhook whose event filter holds a range with CAPTURE and CAPTURE_FAILED strictly inside it
        Initialize();

        // [GIVEN] One merchant with an active standard webhook for AUTHORISATION and the range CANCELLATION..CHARGEBACK
        PrepareEnsureWebhookFixture('AUTHORISATION|CANCELLATION..CHARGEBACK', MerchantName, ApiKeyAdded);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] No webhook was added for the merchant
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'No webhook should have been created for the merchant');

        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure EnsureCaptureWebhooks_PGMerchantListed_NoRefreshNoPrompt()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        MerchantAccount: Record "NPR Adyen Merchant Account";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] When the merchant of every Adyen payment gateway with capture enabled is in the merchant list, the list is not refreshed and nothing is asked
        // No confirm handler and no HTTP handler are bound, so a question or a call to Adyen fails the test.
        Initialize();

        // [GIVEN] One merchant with an active webhook for CAPTURE and CAPTURE_FAILED, and a Company ID so a refresh would really call Adyen
        PrepareEnsureWebhookFixture('CAPTURE|CAPTURE_FAILED', MerchantName, ApiKeyAdded);
        AdyenSetup.Get();
        if AdyenSetup."Company ID" = '' then begin
            AdyenSetup."Company ID" := 'ASYNC-CAPTURE-TEST-COMPANY';
            AdyenSetup.Modify();
        end;

        // [GIVEN] A new Adyen payment gateway with capture enabled whose merchant is that listed merchant
        CreateCaptureGatewayForMerchant(MerchantName);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] The merchant list was not refreshed and no webhook was added for the merchant
        _Assert.AreEqual(1, MerchantAccount.Count(), 'The merchant list should still hold only the fixture merchant');
        _Assert.IsTrue(MerchantAccount.Get(MerchantName), 'The fixture merchant should still be in the merchant list');
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'No webhook should have been created for the merchant');

        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    procedure WebhookSetupList_CaptureWebhooksAction_HiddenWhenFeatureDisabled()
    var
        WebhookSetupList: TestPage "NPR Adyen Webhook Setup List";
    begin
        // [SCENARIO] The action that creates the capture webhooks is hidden while the feature is disabled
        Initialize();

        // [GIVEN] The asynchronous capture feature is disabled
        _AsyncFeature.SetFeatureEnabled(false);

        // [WHEN] The webhook setup list is opened
        WebhookSetupList.OpenView();

        // [THEN] The capture webhooks action is hidden
        _Assert.IsFalse(WebhookSetupList.CreateCaptureWebhooks.Visible(), 'The Create Capture Webhooks action should be hidden');
        WebhookSetupList.Close();

        RestoreFeature();
    end;

    [Test]
    procedure WebhookSetupList_CaptureWebhooksAction_VisibleWhenFeatureEnabled()
    var
        WebhookSetupList: TestPage "NPR Adyen Webhook Setup List";
    begin
        // [SCENARIO] The action that creates the capture webhooks is shown while the feature is enabled
        Initialize();

        // [WHEN] The webhook setup list is opened
        WebhookSetupList.OpenView();

        // [THEN] The capture webhooks action is visible
        _Assert.IsTrue(WebhookSetupList.CreateCaptureWebhooks.Visible(), 'The Create Capture Webhooks action should be visible');
        WebhookSetupList.Close();

        RestoreFeature();
    end;

    [Test]
    procedure ActivitiesCue_RecentCaptureFailures_HiddenWhenFeatureDisabled()
    var
        Activities: TestPage "NPR Activities";
    begin
        // [SCENARIO] The recent capture failures cue is hidden while the feature is disabled
        Initialize();

        // [GIVEN] The asynchronous capture feature is disabled
        _AsyncFeature.SetFeatureEnabled(false);

        // [WHEN] The activities page is opened
        Activities.OpenView();

        // [THEN] The recent capture failures cue is hidden
        _Assert.IsFalse(Activities.RecentCaptureFailures.Visible(), 'The recent capture failures cue should be hidden');
        Activities.Close();

        RestoreFeature();
    end;

    [Test]
    procedure ActivitiesCue_RecentCaptureFailures_VisibleWhenFeatureEnabled()
    var
        Activities: TestPage "NPR Activities";
    begin
        // [SCENARIO] The recent capture failures cue is shown while the feature is enabled
        Initialize();

        // [WHEN] The activities page is opened
        Activities.OpenView();

        // [THEN] The recent capture failures cue is visible
        _Assert.IsTrue(Activities.RecentCaptureFailures.Visible(), 'The recent capture failures cue should be visible');
        Activities.Close();

        RestoreFeature();
    end;

    [Test]
    procedure RecentCaptureFailureFilter_WindowAndEventCode()
    var
        FailedWebhook: Record "NPR Adyen Webhook";
        CaptureWebhook: Record "NPR Adyen Webhook";
        AdyenWebhook: Record "NPR Adyen Webhook";
        AdyenManagement: Codeunit "NPR Adyen Management";
        ReferenceDateTime: DateTime;
    begin
        // [SCENARIO] The recent capture failure filter keeps CAPTURE_FAILED webhooks created in the seven days up to the reference time
        Initialize();

        // [GIVEN] A CAPTURE_FAILED webhook and a CAPTURE webhook
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE_FAILED, NewPspReference(), 'true', 'Capture rejected', CurrentDateTime(), FailedWebhook);
        InsertCaptureWebhook(Enum::"NPR Adyen Webhook Event Code"::CAPTURE, NewPspReference(), 'true', '', CurrentDateTime(), CaptureWebhook);
        FailedWebhook.Find();
        ReferenceDateTime := FailedWebhook.SystemCreatedAt;

        // [WHEN] The filter is applied at the creation time, one minute later, one minute earlier, exactly seven days later and seven days and one minute later
        // [THEN] Only the CAPTURE_FAILED webhook is kept, and only while its creation time is inside the window
        Clear(AdyenWebhook);
        AdyenManagement.SetRecentCaptureFailureFilter(AdyenWebhook, ReferenceDateTime);
        AdyenWebhook.SetFilter("Entry No.", '%1|%2', FailedWebhook."Entry No.", CaptureWebhook."Entry No.");
        _Assert.AreEqual(1, AdyenWebhook.Count(), 'The filter should keep the CAPTURE_FAILED webhook at its creation time');

        Clear(AdyenWebhook);
        AdyenManagement.SetRecentCaptureFailureFilter(AdyenWebhook, ReferenceDateTime + 60 * 1000);
        AdyenWebhook.SetFilter("Entry No.", '%1|%2', FailedWebhook."Entry No.", CaptureWebhook."Entry No.");
        _Assert.AreEqual(1, AdyenWebhook.Count(), 'The filter should keep the CAPTURE_FAILED webhook one minute after its creation time');

        Clear(AdyenWebhook);
        AdyenManagement.SetRecentCaptureFailureFilter(AdyenWebhook, ReferenceDateTime - 60 * 1000);
        AdyenWebhook.SetFilter("Entry No.", '%1|%2', FailedWebhook."Entry No.", CaptureWebhook."Entry No.");
        _Assert.AreEqual(0, AdyenWebhook.Count(), 'The filter should leave out a webhook created after the reference time');

        Clear(AdyenWebhook);
        AdyenManagement.SetRecentCaptureFailureFilter(AdyenWebhook, ReferenceDateTime + 7 * 24 * 60 * 60 * 1000);
        AdyenWebhook.SetFilter("Entry No.", '%1|%2', FailedWebhook."Entry No.", CaptureWebhook."Entry No.");
        _Assert.AreEqual(1, AdyenWebhook.Count(), 'The filter should keep a webhook created exactly seven days before the reference time');

        Clear(AdyenWebhook);
        AdyenManagement.SetRecentCaptureFailureFilter(AdyenWebhook, ReferenceDateTime + 7 * 24 * 60 * 60 * 1000 + 60 * 1000);
        AdyenWebhook.SetFilter("Entry No.", '%1|%2', FailedWebhook."Entry No.", CaptureWebhook."Entry No.");
        _Assert.AreEqual(0, AdyenWebhook.Count(), 'The filter should leave out a webhook older than seven days');

        RestoreFeature();
    end;

    [Test]
    procedure GetMissingEventsFilter_NoWebhook_ReturnsBothEvents()
    var
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] Both capture events are missing on a merchant without webhooks
        Initialize();

        // [GIVEN] A merchant without webhooks
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);

        // [WHEN] The missing events are read
        // [THEN] Both events are missing, in list order
        _Assert.AreEqual('CAPTURE|CAPTURE_FAILED', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'Both events should be missing on a merchant without webhooks');

        RestoreFeature();
    end;

    [Test]
    procedure GetMissingEventsFilter_ActiveWebhookCoversBoth_ReturnsEmpty()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] No event is missing when an active webhook on the merchant covers both capture events
        Initialize();

        // [GIVEN] A merchant with an active webhook for CAPTURE and CAPTURE_FAILED
        MerchantName := NewMerchantName();
        InsertWebhookSetup(MerchantName, 'CAPTURE|CAPTURE_FAILED', true, '', WebhookSetup);
        GetCaptureEventCodes(EventCodes);

        // [WHEN] The missing events are read
        // [THEN] No event is missing
        _Assert.AreEqual('', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'No event should be missing when an active webhook covers both');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure GetMissingEventsFilter_ActiveWebhookCoversCaptureOnly_ReturnsCaptureFailed()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] Only CAPTURE_FAILED is missing when the active webhook on the merchant covers only CAPTURE
        Initialize();

        // [GIVEN] A merchant with an active webhook for CAPTURE only
        MerchantName := NewMerchantName();
        InsertWebhookSetup(MerchantName, 'CAPTURE', true, '', WebhookSetup);
        GetCaptureEventCodes(EventCodes);

        // [WHEN] The missing events are read
        // [THEN] Only CAPTURE_FAILED is missing
        _Assert.AreEqual('CAPTURE_FAILED', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'Only CAPTURE_FAILED should be missing');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure GetMissingEventsFilter_InactiveCombinedWebhookWithPassword_ReturnsEmpty()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] An inactive webhook created for CAPTURE and CAPTURE_FAILED together, with a stored password, is found for reactivation
        Initialize();

        // [GIVEN] A merchant with an inactive webhook whose filter is CAPTURE|CAPTURE_FAILED and which has a stored password
        MerchantName := NewMerchantName();
        InsertWebhookSetup(MerchantName, 'CAPTURE|CAPTURE_FAILED', false, 'stored-password', WebhookSetup);
        GetCaptureEventCodes(EventCodes);

        // [WHEN] The missing events are read
        // [THEN] No event is missing because the inactive webhook can be reactivated
        _Assert.AreEqual('', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'The inactive combined webhook should be found for both events');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure GetMissingEventsFilter_InactiveReversedCombinedWebhookWithPassword_ReturnsEmpty()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] An inactive webhook whose filter lists CAPTURE_FAILED before CAPTURE, with a stored password, is found for reactivation
        Initialize();

        // [GIVEN] A merchant with an inactive webhook whose filter is CAPTURE_FAILED|CAPTURE and which has a stored password
        MerchantName := NewMerchantName();
        InsertWebhookSetup(MerchantName, 'CAPTURE_FAILED|CAPTURE', false, 'stored-password', WebhookSetup);
        GetCaptureEventCodes(EventCodes);

        // [WHEN] The missing events are read
        // [THEN] No event is missing because the inactive webhook can be reactivated
        _Assert.AreEqual('', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'The inactive combined webhook in reversed order should be found for both events');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure GetMissingEventsFilter_InactiveBasicAuthWebhookWithoutPassword_StaysMissing()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] An inactive basic authentication webhook without a stored password is not reactivated, because that would send a blank password to Adyen
        Initialize();

        // [GIVEN] A merchant with an inactive CAPTURE webhook that uses basic authentication with a user and no password
        MerchantName := NewMerchantName();
        InsertWebhookSetup(MerchantName, 'CAPTURE', false, '', WebhookSetup);
        WebhookSetup."Web Service Security" := WebhookSetup."Web Service Security"::"Basic authentication";
        WebhookSetup."Web Service User" := 'webhook-user';
        WebhookSetup.Modify(false);
        EventCodes.Add('CAPTURE');

        // [WHEN] The missing events are read
        // [THEN] CAPTURE is still missing
        _Assert.AreEqual('CAPTURE', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'An inactive basic authentication webhook without a password should not be found');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure GetMissingEventsFilter_InactiveBasicAuthWebhookWithPassword_ReturnsEmpty()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] An inactive basic authentication webhook with a stored password is found for reactivation on every environment
        Initialize();

        // [GIVEN] A merchant with an inactive CAPTURE webhook that uses basic authentication with a user and a stored password
        MerchantName := NewMerchantName();
        InsertWebhookSetup(MerchantName, 'CAPTURE', false, 'stored-password', WebhookSetup);
        WebhookSetup."Web Service Security" := WebhookSetup."Web Service Security"::"Basic authentication";
        WebhookSetup."Web Service User" := 'webhook-user';
        WebhookSetup.Modify(false);
        EventCodes.Add('CAPTURE');

        // [WHEN] The missing events are read
        // [THEN] No event is missing because the stored password lets the webhook be reactivated
        _Assert.AreEqual('', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'An inactive basic authentication webhook with a stored password should be found');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure GetMissingEventsFilter_InactiveWebhookWithoutSecurityOrPassword_MissingOnlyOnCrane()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
        ExpectedFilter: Text;
    begin
        // [SCENARIO] An inactive webhook without web service security and without a stored password is found for reactivation on SaaS, but not on Crane, where reactivating it would send a blank password
        Initialize();

        // [GIVEN] A merchant with an inactive CAPTURE webhook with the default web service security and no password
        MerchantName := NewMerchantName();
        InsertWebhookSetup(MerchantName, 'CAPTURE', false, '', WebhookSetup);
        EventCodes.Add('CAPTURE');

        // [GIVEN] The expected result for the environment the test runs on
        if AsyncAdyenPmtProcessing.IsCraneEnvironment() then
            ExpectedFilter := 'CAPTURE'
        else
            ExpectedFilter := '';

        // [WHEN] The missing events are read
        // [THEN] CAPTURE is missing on Crane and found on SaaS
        _Assert.AreEqual(ExpectedFilter, AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'Unexpected missing events for an inactive webhook without security or password on this environment');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_CoveringWebhook_InsertedWithBlankPasswordOnMerchant()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
        WebhookId: Code[80];
    begin
        // [SCENARIO] A webhook read from Adyen that covers the missing events is inserted on the merchant without its password
        Initialize();

        // [GIVEN] A merchant without webhooks
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);

        // [GIVEN] A buffered active webhook for both events that carries basic authentication, a password and another merchant name
        WebhookId := NewWebhookId();
        AddBufferWebhook(TempWebhookSetup, 1, WebhookId, 'CAPTURE|CAPTURE_FAILED', true);
        TempWebhookSetup."Merchant Account" := 'OTHER-MERCHANT';
        TempWebhookSetup."Web Service Security" := TempWebhookSetup."Web Service Security"::"Basic authentication";
        TempWebhookSetup."Web Service User" := 'webhook-user';
        TempWebhookSetup."Web Service Password" := 'buffered-password';
        TempWebhookSetup.Modify();

        // [WHEN] Covering webhooks are adopted
        // [THEN] A webhook was adopted
        _Assert.IsTrue(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'The covering webhook should have been adopted');

        // [THEN] One webhook with the buffered id is on the merchant, with a blank password and the buffered user
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'One webhook should have been adopted on the merchant');
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.FindFirst();
        _Assert.AreEqual(WebhookId, WebhookSetup.ID, 'The adopted webhook should keep the id from Adyen');
        _Assert.AreEqual('', WebhookSetup."Web Service Password", 'The adopted webhook should have a blank password');
        _Assert.AreEqual('webhook-user', WebhookSetup."Web Service User", 'The adopted webhook should keep the user from Adyen');
        _Assert.IsTrue(WebhookSetup.Active, 'The adopted webhook should be active');

        // [THEN] Both events are covered
        _Assert.AreEqual('', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'No event should be missing after the adoption');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_InactiveWebhook_IsNotAdopted()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] An inactive webhook read from Adyen is not adopted
        Initialize();

        // [GIVEN] A merchant without webhooks and a buffered inactive webhook for both events
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);
        AddBufferWebhook(TempWebhookSetup, 1, NewWebhookId(), 'CAPTURE|CAPTURE_FAILED', false);

        // [WHEN] Covering webhooks are adopted
        // [THEN] Nothing was adopted
        _Assert.IsFalse(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'An inactive webhook should not have been adopted');
        _Assert.AreEqual(0, CountWebhookSetups(MerchantName), 'No webhook should have been inserted on the merchant');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_NonStandardTypeWebhook_IsNotAdopted()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] An active webhook read from Adyen that is not a standard webhook is not adopted, even with an empty event filter
        Initialize();

        // [GIVEN] A merchant without webhooks and a buffered active report-notification webhook without an event filter
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);
        AddBufferWebhook(TempWebhookSetup, 1, NewWebhookId(), '', true);
        TempWebhookSetup.Type := TempWebhookSetup.Type::"report-notification";
        TempWebhookSetup.Modify();

        // [WHEN] Covering webhooks are adopted
        // [THEN] Nothing was adopted
        _Assert.IsFalse(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'A webhook that is not a standard webhook should not have been adopted');
        _Assert.AreEqual(0, CountWebhookSetups(MerchantName), 'No webhook should have been inserted on the merchant');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_WebhookForOtherEvents_IsNotAdopted()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] A webhook read from Adyen that delivers neither capture event is not adopted
        Initialize();

        // [GIVEN] A merchant without webhooks and a buffered active webhook for REPORT_AVAILABLE only
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);
        AddBufferWebhook(TempWebhookSetup, 1, NewWebhookId(), 'REPORT_AVAILABLE', true);

        // [WHEN] Covering webhooks are adopted
        // [THEN] Nothing was adopted
        _Assert.IsFalse(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'A webhook for other events should not have been adopted');
        _Assert.AreEqual(0, CountWebhookSetups(MerchantName), 'No webhook should have been inserted on the merchant');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_EmptyFilterWebhook_IsAdopted()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] A webhook read from Adyen with an empty event filter delivers the default events and is adopted
        Initialize();

        // [GIVEN] A merchant without webhooks and a buffered active webhook without an event filter
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);
        AddBufferWebhook(TempWebhookSetup, 1, NewWebhookId(), '', true);

        // [WHEN] Covering webhooks are adopted
        // [THEN] The webhook was adopted and covers both events
        _Assert.IsTrue(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'The empty filter webhook should have been adopted');
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'One webhook should have been inserted on the merchant');
        _Assert.AreEqual('', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'No event should be missing after the adoption');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_IdAlreadyInBC_IsNotAdoptedAgain()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
        OtherMerchantName: Text[80];
    begin
        // [SCENARIO] A webhook read from Adyen whose id is already stored in BC, on any merchant, is not inserted again
        Initialize();

        // [GIVEN] A merchant without webhooks
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);

        // [GIVEN] The same webhook id stored on another merchant
        OtherMerchantName := NewMerchantName();
        InsertWebhookSetup(OtherMerchantName, 'CAPTURE|CAPTURE_FAILED', true, '', WebhookSetup);

        // [GIVEN] A buffered active webhook for both events with that id
        AddBufferWebhook(TempWebhookSetup, 1, WebhookSetup.ID, 'CAPTURE|CAPTURE_FAILED', true);

        // [WHEN] Covering webhooks are adopted
        // [THEN] Nothing was adopted
        _Assert.IsFalse(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'A webhook already stored in BC should not have been adopted');
        _Assert.AreEqual(0, CountWebhookSetups(MerchantName), 'No webhook should have been inserted on the merchant');
        _Assert.AreEqual(1, CountWebhookSetups(OtherMerchantName), 'The webhook on the other merchant should be unchanged');

        DeleteWebhookSetups(MerchantName);
        DeleteWebhookSetups(OtherMerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_SecondWebhookForCoveredEvents_IsNotAdopted()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
        FirstWebhookId: Code[80];
    begin
        // [SCENARIO] A second webhook read from Adyen whose events the first adopted webhook already covers is not adopted
        Initialize();

        // [GIVEN] A merchant without webhooks
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);

        // [GIVEN] Two buffered active webhooks that each cover both events
        FirstWebhookId := NewWebhookId();
        AddBufferWebhook(TempWebhookSetup, 1, FirstWebhookId, 'CAPTURE|CAPTURE_FAILED', true);
        AddBufferWebhook(TempWebhookSetup, 2, NewWebhookId(), 'CAPTURE|CAPTURE_FAILED', true);

        // [WHEN] Covering webhooks are adopted
        // [THEN] Only the first webhook was adopted
        _Assert.IsTrue(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'A covering webhook should have been adopted');
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'Only one webhook should have been inserted on the merchant');
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.FindFirst();
        _Assert.AreEqual(FirstWebhookId, WebhookSetup.ID, 'The first covering webhook should have been adopted');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_TwoSingleEventWebhooks_AdoptsBoth()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] Two webhooks read from Adyen that each cover one capture event are both adopted
        Initialize();

        // [GIVEN] A merchant without webhooks
        MerchantName := NewMerchantName();
        GetCaptureEventCodes(EventCodes);

        // [GIVEN] A buffered active webhook for CAPTURE and another for CAPTURE_FAILED
        AddBufferWebhook(TempWebhookSetup, 1, NewWebhookId(), 'CAPTURE', true);
        AddBufferWebhook(TempWebhookSetup, 2, NewWebhookId(), 'CAPTURE_FAILED', true);

        // [WHEN] Covering webhooks are adopted
        // [THEN] Both webhooks were adopted and cover both events
        _Assert.IsTrue(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'The single event webhooks should have been adopted');
        _Assert.AreEqual(2, CountWebhookSetups(MerchantName), 'Both webhooks should have been inserted on the merchant');
        _Assert.AreEqual('', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'No event should be missing after the adoption');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure AdoptCoveringWebhooks_EventAlreadyCoveredInBC_IsNotAdopted()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        EventCodes: List of [Text[2048]];
        MerchantName: Text[80];
    begin
        // [SCENARIO] A webhook read from Adyen that covers only an event the merchant already has is not adopted
        Initialize();

        // [GIVEN] A merchant with an active CAPTURE webhook in BC
        MerchantName := NewMerchantName();
        InsertWebhookSetup(MerchantName, 'CAPTURE', true, '', WebhookSetup);
        GetCaptureEventCodes(EventCodes);

        // [GIVEN] A buffered active webhook for CAPTURE only
        AddBufferWebhook(TempWebhookSetup, 1, NewWebhookId(), 'CAPTURE', true);

        // [WHEN] Covering webhooks are adopted
        // [THEN] Nothing was adopted and CAPTURE_FAILED is still missing
        _Assert.IsFalse(AsyncAdyenPmtProcessing.AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup), 'A webhook for an already covered event should not have been adopted');
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'No webhook should have been inserted on the merchant');
        _Assert.AreEqual('CAPTURE_FAILED', AsyncAdyenPmtProcessing.GetMissingEventsFilter(MerchantName, EventCodes), 'CAPTURE_FAILED should still be missing');

        DeleteWebhookSetups(MerchantName);
        RestoreFeature();
    end;

    [Test]
    procedure MatchesWebhookUrl_ExpectedUrlWithOwnRef_ReturnsTrue()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] A webhook URL that is the expected URL followed by its own webhook reference matches
        // [GIVEN] The expected URL and the webhook id WH-1
        // [WHEN] The URL Adyen returned is the expected URL with &webhookRef=WH-1
        // [THEN] It matches
        _Assert.IsTrue(AdyenManagement.MatchesWebhookUrl(TestWebhookUrl('Secret1') + '&webhookRef=WH-1', 'WH-1', TestWebhookUrl('Secret1')), 'The URL with its own webhook reference should match');
    end;

    [Test]
    procedure MatchesWebhookUrl_WithoutRef_ReturnsFalse()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] A webhook URL without a webhook reference does not match
        // [GIVEN] The expected URL and the webhook id WH-1
        // [WHEN] The URL Adyen returned is the expected URL without a webhook reference
        // [THEN] It does not match
        _Assert.IsFalse(AdyenManagement.MatchesWebhookUrl(TestWebhookUrl('Secret1'), 'WH-1', TestWebhookUrl('Secret1')), 'The URL without a webhook reference should not match');
    end;

    [Test]
    procedure MatchesWebhookUrl_RefOfOtherWebhook_ReturnsFalse()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] A webhook URL that carries the reference of another webhook does not match
        // [GIVEN] The expected URL and the webhook id WH-1
        // [WHEN] The URL Adyen returned carries &webhookRef=WH-2
        // [THEN] It does not match
        _Assert.IsFalse(AdyenManagement.MatchesWebhookUrl(TestWebhookUrl('Secret1') + '&webhookRef=WH-2', 'WH-1', TestWebhookUrl('Secret1')), 'The URL with the reference of another webhook should not match');
    end;

    [Test]
    procedure MatchesWebhookUrl_DifferentPassword_ReturnsFalse()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] A webhook URL created with another password does not match, also when the password differs only in case
        // [GIVEN] The webhook id WH-1 and a URL Adyen returned with password Secret1
        // [WHEN] The expected URL carries password Secret2, or secret1
        // [THEN] Neither matches
        _Assert.IsFalse(AdyenManagement.MatchesWebhookUrl(TestWebhookUrl('Secret1') + '&webhookRef=WH-1', 'WH-1', TestWebhookUrl('Secret2')), 'The URL created with another password should not match');
        _Assert.IsFalse(AdyenManagement.MatchesWebhookUrl(TestWebhookUrl('Secret1') + '&webhookRef=WH-1', 'WH-1', TestWebhookUrl('secret1')), 'The URL created with a password that differs in case should not match');
    end;

    [Test]
    procedure MatchesWebhookUrl_ParameterAfterRef_ReturnsFalse()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] A webhook URL with a parameter after its webhook reference does not match
        // [GIVEN] The expected URL and the webhook id WH-1
        // [WHEN] The URL Adyen returned has &extra=1 after &webhookRef=WH-1
        // [THEN] It does not match
        _Assert.IsFalse(AdyenManagement.MatchesWebhookUrl(TestWebhookUrl('Secret1') + '&webhookRef=WH-1&extra=1', 'WH-1', TestWebhookUrl('Secret1')), 'The URL with a parameter after the webhook reference should not match');
    end;

    [Test]
    procedure MatchesWebhookUrl_BlankWebhookIdOrExpectedUrl_ReturnsFalse()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] A webhook URL never matches a blank webhook id or a blank expected URL, even when the strings would line up
        // [GIVEN] A blank webhook id with an expected URL, and a webhook id X with a blank expected URL
        // [WHEN] The URL Adyen returned ends with a webhook reference that fits each of them
        // [THEN] Neither matches
        _Assert.IsFalse(AdyenManagement.MatchesWebhookUrl(TestWebhookUrl('Secret1') + '&webhookRef=', '', TestWebhookUrl('Secret1')), 'The URL should not match a blank webhook id');
        _Assert.IsFalse(AdyenManagement.MatchesWebhookUrl('&webhookRef=X', 'X', ''), 'The URL should not match a blank expected URL');
    end;

    [Test]
    procedure IsOwnEnvironmentWebhook_SaaS_OwnRefAndCurrentEnvironment_ReturnsTrue()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] On SaaS a webhook URL of this tenant, environment and company that ends with its own webhook reference belongs to this environment, without an expected URL
        // [GIVEN] The webhook id WH-1 and a URL Adyen returned for this environment with &webhookRef=WH-1
        // [WHEN] The URL is checked as on SaaS with a blank expected URL
        // [THEN] It belongs to this environment
        _Assert.IsTrue(AdyenManagement.IsOwnEnvironmentWebhook(CurrentEnvironmentWebhookUrl('WH-1'), 'WH-1', true, ''), 'On SaaS the URL of this environment with its own webhook reference should belong to this environment');
    end;

    [Test]
    procedure IsOwnEnvironmentWebhook_SaaS_RefOfOtherWebhook_ReturnsFalse()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] On SaaS a webhook URL of this environment that carries the reference of another webhook does not belong to this environment
        // [GIVEN] The webhook id WH-1 and a URL Adyen returned for this environment with &webhookRef=WH-2
        // [WHEN] The URL is checked as on SaaS with a blank expected URL
        // [THEN] It does not belong to this environment
        _Assert.IsFalse(AdyenManagement.IsOwnEnvironmentWebhook(CurrentEnvironmentWebhookUrl('WH-2'), 'WH-1', true, ''), 'On SaaS the URL with the reference of another webhook should not belong to this environment');
    end;

    [Test]
    procedure IsOwnEnvironmentWebhook_SaaS_OtherCompany_ReturnsFalse()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] On SaaS a webhook URL with its own webhook reference that names another company does not belong to this environment
        // [GIVEN] The webhook id WH-1 and a URL Adyen returned for this tenant and environment, company OTHER-COMPANY, with &webhookRef=WH-1
        _Assert.AreNotEqual('OTHER-COMPANY', CompanyName(), 'The test company must differ from the other company in the webhook URL');
        // [WHEN] The URL is checked as on SaaS with a blank expected URL
        // [THEN] It does not belong to this environment
        _Assert.IsFalse(AdyenManagement.IsOwnEnvironmentWebhook(CurrentEnvironmentWebhookUrlForCompany('WH-1', 'OTHER-COMPANY'), 'WH-1', true, ''), 'On SaaS the URL of another company should not belong to this environment');
    end;

    [Test]
    procedure IsOwnEnvironmentWebhook_NotSaaS_RequiresExactMatchWithExpectedUrl()
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // [SCENARIO] Outside SaaS a webhook URL belongs to this environment only when it is the expected URL followed by its own webhook reference
        // [GIVEN] The webhook id WH-1
        // [WHEN] The URL Adyen returned is the expected URL with &webhookRef=WH-1
        // [THEN] It belongs to this environment
        _Assert.IsTrue(AdyenManagement.IsOwnEnvironmentWebhook(TestWebhookUrl('Secret1') + '&webhookRef=WH-1', 'WH-1', false, TestWebhookUrl('Secret1')), 'Outside SaaS the expected URL with its own webhook reference should belong to this environment');
        // [WHEN] The URL Adyen returned names this tenant, environment and company with &webhookRef=WH-1, and there is no expected URL
        // [THEN] It does not belong to this environment
        _Assert.IsFalse(AdyenManagement.IsOwnEnvironmentWebhook(CurrentEnvironmentWebhookUrl('WH-1'), 'WH-1', false, ''), 'Outside SaaS a URL should not belong to this environment without an exact match on the expected URL');
    end;

    [Test]
    procedure CanReactivateWebhook_BasicAuthWithoutPasswordNotOnCrane_ReturnsFalse()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
    begin
        // [SCENARIO] An inactive webhook with basic authentication and no stored password is not reactivated outside Crane, because Adyen would receive a blank password
        // [GIVEN] A webhook with basic authentication and a blank password
        TempWebhookSetup.Init();
        TempWebhookSetup."Web Service Security" := TempWebhookSetup."Web Service Security"::"Basic authentication";
        TempWebhookSetup."Web Service Password" := '';
        // [WHEN] Reactivation is checked outside Crane
        // [THEN] It cannot be reactivated
        _Assert.IsFalse(AsyncAdyenPmtProcessing.CanReactivateWebhook(TempWebhookSetup, false), 'A webhook with basic authentication and no password should not be reactivated');
    end;

    [Test]
    procedure CanReactivateWebhook_NoSecurityWithoutPasswordNotOnCrane_ReturnsTrue()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
    begin
        // [SCENARIO] An inactive webhook without web service security needs no password, so it is reactivated outside Crane
        // [GIVEN] A webhook without web service security and a blank password
        TempWebhookSetup.Init();
        TempWebhookSetup."Web Service Security" := TempWebhookSetup."Web Service Security"::" ";
        TempWebhookSetup."Web Service Password" := '';
        // [WHEN] Reactivation is checked outside Crane
        // [THEN] It can be reactivated
        _Assert.IsTrue(AsyncAdyenPmtProcessing.CanReactivateWebhook(TempWebhookSetup, false), 'A webhook without web service security should be reactivated outside Crane');
    end;

    [Test]
    procedure CanReactivateWebhook_NoSecurityWithoutPasswordOnCrane_ReturnsFalse()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
    begin
        // [SCENARIO] On Crane an inactive webhook without a stored password is not reactivated, whatever its web service security
        // [GIVEN] A webhook without web service security and a blank password
        TempWebhookSetup.Init();
        TempWebhookSetup."Web Service Security" := TempWebhookSetup."Web Service Security"::" ";
        TempWebhookSetup."Web Service Password" := '';
        // [WHEN] Reactivation is checked on Crane
        // [THEN] It cannot be reactivated
        _Assert.IsFalse(AsyncAdyenPmtProcessing.CanReactivateWebhook(TempWebhookSetup, true), 'On Crane a webhook without a password should not be reactivated');
    end;

    [Test]
    procedure CanReactivateWebhook_BasicAuthWithPasswordOnCrane_ReturnsTrue()
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
    begin
        // [SCENARIO] An inactive webhook with a stored password is reactivated on Crane, also with basic authentication
        // [GIVEN] A webhook with basic authentication and a stored password
        TempWebhookSetup.Init();
        TempWebhookSetup."Web Service Security" := TempWebhookSetup."Web Service Security"::"Basic authentication";
        TempWebhookSetup."Web Service Password" := 'Secret1';
        // [WHEN] Reactivation is checked on Crane
        // [THEN] It can be reactivated
        _Assert.IsTrue(AsyncAdyenPmtProcessing.CanReactivateWebhook(TempWebhookSetup, true), 'A webhook with a stored password should be reactivated on Crane');
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock,MessageHandler')]
    procedure EnsureCaptureWebhooks_Crane_AdyenWebhookWithSameCredentials_IsAdoptedWithoutCreate()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        AdyenWebhookId: Code[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] On Crane, a capture webhook that already exists at Adyen with a URL built from the same credentials is adopted, and no webhook is created
        Initialize();

        // [GIVEN] One merchant without webhooks in BC, and credentials supplied with password Secret1
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret1', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] Adyen lists one active standard webhook for CAPTURE and CAPTURE_FAILED whose URL is the one built from those credentials, followed by its own webhookRef
        AdyenWebhookId := NewWebhookId();
        _MockFirstPageBody := WebhooksPageJson(1, AdyenWebhookId, CraneWebhookUrl('Secret1') + '&webhookRef=' + AdyenWebhookId);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] The webhook list was read once and no webhook was created or updated at Adyen
        _Assert.AreEqual(1, _MockFirstPageRequests, 'The merchant webhook list should have been read once');
        _Assert.AreEqual(0, _MockCreateRequests, 'No webhook should have been created at Adyen');
        _Assert.AreEqual(0, _MockUpdateRequests, 'The adopted webhook should not have been sent back to Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] The merchant has exactly one webhook, the one from Adyen, with a blank password
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'Exactly one webhook should be on the merchant');
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.FindFirst();
        _Assert.AreEqual(AdyenWebhookId, WebhookSetup.ID, 'The webhook on the merchant should be the one adopted from Adyen');
        _Assert.AreEqual('', WebhookSetup."Web Service Password", 'The adopted webhook should have a blank password');
        _Assert.IsTrue(WebhookSetup.Active, 'The adopted webhook should be active');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock,MessageHandler')]
    procedure EnsureCaptureWebhooks_Crane_AdyenWebhookWithOtherPassword_CreatesNewWebhook()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        AdyenWebhookId: Code[80];
        CreatedWebhookId: Code[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] On Crane, a capture webhook at Adyen whose URL carries another password is not adopted, and a new webhook is created with the password just entered
        Initialize();

        // [GIVEN] One merchant without webhooks in BC, and credentials supplied with password Secret2
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret2', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] Adyen lists one active standard webhook for CAPTURE and CAPTURE_FAILED whose URL was built with password Secret1
        AdyenWebhookId := NewWebhookId();
        _MockFirstPageBody := WebhooksPageJson(1, AdyenWebhookId, CraneWebhookUrl('Secret1') + '&webhookRef=' + AdyenWebhookId);

        // [GIVEN] Adyen answers the create request with a new webhook id
        CreatedWebhookId := NewWebhookId();
        MockCreateResponse(CreatedWebhookId);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] One webhook was created and then updated at Adyen
        _Assert.AreEqual(1, _MockFirstPageRequests, 'The merchant webhook list should have been read once');
        _Assert.AreEqual(1, _MockCreateRequests, 'Exactly one webhook should have been created at Adyen');
        _Assert.AreEqual(1, _MockUpdateRequests, 'The created webhook should have been updated once at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] The merchant has exactly one webhook, the created one, with the password and URL from the credentials just entered
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'Exactly one webhook should be on the merchant');
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.FindFirst();
        _Assert.AreEqual(CreatedWebhookId, WebhookSetup.ID, 'The webhook on the merchant should be the created one, not the one with the other password');
        _Assert.AreEqual('Secret2', WebhookSetup."Web Service Password", 'The created webhook should store the password just entered');
        _Assert.AreEqual(CraneWebhookUrl('Secret2') + '&webhookRef=' + CreatedWebhookId, WebhookSetup."Web Service URL", 'The created webhook should use the URL built from the credentials just entered');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock,MessageHandler')]
    procedure EnsureCaptureWebhooks_Crane_MatchingWebhookOnSecondPage_IsAdoptedWithoutCreate()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        OtherWebhookId: Code[80];
        AdyenWebhookId: Code[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] On Crane, the webhook list is read page by page, so a matching webhook on the second page is adopted and no webhook is created
        Initialize();

        // [GIVEN] One merchant without webhooks in BC, and credentials supplied with password Secret1
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret1', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] The first of two pages holds a capture webhook whose URL was built with password Secret2
        OtherWebhookId := NewWebhookId();
        _MockFirstPageBody := WebhooksPageJson(2, OtherWebhookId, CraneWebhookUrl('Secret2') + '&webhookRef=' + OtherWebhookId);

        // [GIVEN] The second page holds a capture webhook whose URL was built with password Secret1
        AdyenWebhookId := NewWebhookId();
        _MockSecondPageBody := WebhooksPageJson(2, AdyenWebhookId, CraneWebhookUrl('Secret1') + '&webhookRef=' + AdyenWebhookId);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] Both pages were read and no webhook was created at Adyen
        _Assert.AreEqual(1, _MockFirstPageRequests, 'The first page of the webhook list should have been read once');
        _Assert.AreEqual(1, _MockSecondPageRequests, 'The second page of the webhook list should have been read once');
        _Assert.AreEqual(0, _MockCreateRequests, 'No webhook should have been created at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] The merchant has exactly one webhook, the one from the second page, with a blank password
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'Exactly one webhook should be on the merchant');
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.FindFirst();
        _Assert.AreEqual(AdyenWebhookId, WebhookSetup.ID, 'The webhook on the merchant should be the one from the second page');
        _Assert.AreEqual('', WebhookSetup."Web Service Password", 'The adopted webhook should have a blank password');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock,MessageHandler')]
    procedure EnsureCaptureWebhooks_Crane_WebhookListFails_CreatesWebhookForBothEvents()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        CreatedWebhookId: Code[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] On Crane, when the webhook list cannot be read, one webhook is created for CAPTURE and CAPTURE_FAILED
        Initialize();

        // [GIVEN] One merchant without webhooks in BC, and credentials supplied with password Secret1
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret1', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] Adyen answers the webhook list with HTTP 500 and a body without pagesTotal
        _MockFirstPageStatusCode := 500;
        _MockFirstPageBody := '{"status":500,"errorCode":"00_500","message":"Internal server error","errorType":"internal"}';

        // [GIVEN] Adyen answers the create request with a new webhook id
        CreatedWebhookId := NewWebhookId();
        MockCreateResponse(CreatedWebhookId);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] Exactly one webhook was created and then updated at Adyen
        _Assert.AreEqual(1, _MockFirstPageRequests, 'The merchant webhook list should have been requested once');
        _Assert.AreEqual(1, _MockCreateRequests, 'Exactly one webhook should have been created at Adyen');
        _Assert.AreEqual(1, _MockUpdateRequests, 'The created webhook should have been updated once at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] The created webhook is the only one on the merchant and filters on both events
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'Exactly one webhook should be on the merchant');
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.FindFirst();
        _Assert.AreEqual(CreatedWebhookId, WebhookSetup.ID, 'The webhook on the merchant should be the created one');
        // TestHttpRequestMessage does not expose the request body, so the PATCH payload is not observable here; the test asserts the stored filter.
        _Assert.AreEqual('CAPTURE|CAPTURE_FAILED', WebhookSetup."Include Events Filter", 'The created webhook should filter on CAPTURE and CAPTURE_FAILED');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock')]
    procedure EnsureCaptureWebhooks_Crane_CreateResponseWithoutId_FailsWithCreateError()
    var
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        ApiKeyAdded: Boolean;
        WebhookCreateFailedErr: Label 'Failed to create the Adyen webhook for events %1 on merchant %2.', Comment = '%1 = event codes separated by |, %2 = merchant account name';
    begin
        // [SCENARIO] On Crane, when Adyen answers the create request without a webhook id, ensuring the webhooks fails with the create error
        Initialize();

        // [GIVEN] One merchant without webhooks in BC, and credentials supplied with password Secret1
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret1', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] Adyen answers the webhook list with a body without pagesTotal
        _MockFirstPageBody := '{"data":[]}';

        // [GIVEN] Adyen answers the create request with an error body without a webhook id
        _MockCreateResponseBody := '{"status":422,"errorCode":"14_030","title":"Invalid webhook","type":"https://docs.adyen.com/errors/validation"}';

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        asserterror AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] It fails with the create error for both events on the merchant
        _Assert.ExpectedError(StrSubstNo(WebhookCreateFailedErr, 'CAPTURE|CAPTURE_FAILED', MerchantName));

        // [THEN] One create request was sent and the webhook was never updated at Adyen
        _Assert.AreEqual(1, _MockFirstPageRequests, 'The merchant webhook list should have been requested once');
        _Assert.AreEqual(1, _MockCreateRequests, 'Exactly one webhook create request should have been sent');
        _Assert.AreEqual(0, _MockUpdateRequests, 'A webhook without an id should never be updated at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock,MessageHandler')]
    procedure EnsureCaptureWebhooks_Crane_InactiveWebhookWithPassword_IsReactivatedWithoutPrompt()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        WebhookId: Code[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] On Crane, an inactive capture webhook in BC that stores its basic authentication password is reactivated at Adyen, without asking for credentials, reading the webhook list or creating a webhook
        Initialize();

        // [GIVEN] One merchant whose only webhook in BC is an inactive standard webhook for CAPTURE and CAPTURE_FAILED with basic authentication, user and password
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        WebhookId := NewWebhookId();
        WebhookSetup.Init();
        WebhookSetup."Primary Key" := 0;
        WebhookSetup.ID := WebhookId;
        WebhookSetup.Type := WebhookSetup.Type::standard;
        WebhookSetup."Merchant Account" := MerchantName;
        WebhookSetup."Include Events Filter" := 'CAPTURE|CAPTURE_FAILED';
        WebhookSetup."Web Service Security" := WebhookSetup."Web Service Security"::"Basic authentication";
        WebhookSetup."Web Service User" := CraneWebUser();
        WebhookSetup."Web Service Password" := 'Secret1';
        WebhookSetup."Web Service URL" := CopyStr(CraneWebhookUrl('Secret1') + '&webhookRef=' + WebhookId, 1, MaxStrLen(WebhookSetup."Web Service URL"));
        WebhookSetup.Active := false;
        WebhookSetup.Insert();

        // [GIVEN] Adyen answers the update of that webhook with its id
        MockUpdateResponse(WebhookId);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] Only that webhook was updated at Adyen, once, and the webhook list was not read
        _Assert.AreEqual(1, _MockUpdateRequests, 'The inactive webhook should have been updated once at Adyen');
        _Assert.AreEqual(0, _MockFirstPageRequests, 'The merchant webhook list should not have been read');
        _Assert.AreEqual(0, _MockCreateRequests, 'No webhook should have been created at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] The merchant still has exactly that one webhook, now active
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'Exactly one webhook should be on the merchant');
        WebhookSetup.Reset();
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.FindFirst();
        _Assert.AreEqual(WebhookId, WebhookSetup.ID, 'The webhook on the merchant should be the reactivated one');
        _Assert.IsTrue(WebhookSetup.Active, 'The webhook should have been reactivated');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock,MessageHandler')]
    procedure EnsureCaptureWebhooks_Crane_AdyenWebhookForCaptureOnly_IsAdoptedAndCaptureFailedCreated()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        DataArray: JsonArray;
        EventCodes: List of [Text];
        MerchantName: Text[80];
        AdyenWebhookId: Code[80];
        CreatedWebhookId: Code[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] On Crane, a webhook at Adyen with the same credentials that covers only CAPTURE is adopted, and a webhook is created for CAPTURE_FAILED alone
        Initialize();

        // [GIVEN] One merchant without webhooks in BC, and credentials supplied with password Secret1
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret1', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] Adyen lists one active standard webhook for CAPTURE only whose URL is the one built from those credentials, followed by its own webhookRef
        AdyenWebhookId := NewWebhookId();
        EventCodes.Add('CAPTURE');
        DataArray.Add(WebhookJson(AdyenWebhookId, 'standard', CraneWebhookUrl('Secret1') + '&webhookRef=' + AdyenWebhookId, CraneWebUser(), true, EventCodes));
        _MockFirstPageBody := WebhookListJson(1, DataArray);

        // [GIVEN] Adyen answers the create request with a new webhook id
        CreatedWebhookId := NewWebhookId();
        MockCreateResponse(CreatedWebhookId);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] The webhook list was read once, and one webhook was created and then updated at Adyen
        _Assert.AreEqual(1, _MockFirstPageRequests, 'The merchant webhook list should have been read once');
        _Assert.AreEqual(1, _MockCreateRequests, 'Exactly one webhook should have been created at Adyen');
        _Assert.AreEqual(1, _MockUpdateRequests, 'The created webhook should have been updated once at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] The merchant has two webhooks: the adopted one for CAPTURE and the created one for CAPTURE_FAILED
        _Assert.AreEqual(2, CountWebhookSetups(MerchantName), 'Two webhooks should be on the merchant');
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.SetRange(ID, AdyenWebhookId);
        _Assert.IsTrue(WebhookSetup.FindFirst(), 'The webhook from Adyen should have been adopted on the merchant');
        _Assert.AreEqual('CAPTURE', WebhookSetup."Include Events Filter", 'The adopted webhook should keep its CAPTURE filter');
        WebhookSetup.SetRange(ID, CreatedWebhookId);
        _Assert.IsTrue(WebhookSetup.FindFirst(), 'The created webhook should be on the merchant');
        _Assert.AreEqual('CAPTURE_FAILED', WebhookSetup."Include Events Filter", 'The created webhook should filter on CAPTURE_FAILED only');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('EnsureWebhooksConfirmHandler,AdyenManagementApiMock')]
    procedure EnsureCaptureWebhooks_Crane_PGMerchantNotListedAfterRefresh_UserDeclines_NothingChanges()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        MerchantAccount: Record "NPR Adyen Merchant Account";
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantNames: List of [Text];
        MerchantName: Text[80];
        MissingMerchantName: Text[80];
        RefreshOnlyMerchant: Text[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] When a payment gateway merchant is still missing after the merchant list was refreshed from Adyen, and the user declines to continue, no webhook is set up and the merchant list is left as it was
        Initialize();

        // [GIVEN] One listed merchant with an active webhook for CAPTURE and CAPTURE_FAILED, and credentials supplied
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        InsertWebhookSetup(MerchantName, 'CAPTURE|CAPTURE_FAILED', true, '', WebhookSetup);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret1', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] A new Adyen payment gateway with capture enabled whose merchant is not in the merchant list
        MissingMerchantName := NewMerchantName();
        CreateCaptureGatewayForMerchant(MissingMerchantName);

        // [GIVEN] Adyen lists the fixture merchant and one merchant that is not in the merchant list yet, but not the missing merchant
        RefreshOnlyMerchant := NewMerchantName();
        MerchantNames.Add(MerchantName);
        MerchantNames.Add(RefreshOnlyMerchant);
        _MockMerchantListBody := MerchantListJson(MerchantNames);

        // [GIVEN] The user agrees to refresh the merchant list and declines to continue without the missing merchant
        ResetEnsureWebhooksConfirm(true, false);
        // The asserterror below rolls back to the last commit, so the fixture is committed to see what the call itself left behind.
        Commit();

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        asserterror AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] It stops without an error message
        _Assert.AreEqual('', GetLastErrorText(), 'Declining to continue should stop without an error message');

        // [THEN] The user was asked to refresh the list and then to continue, both times naming the missing merchant
        _Assert.IsTrue(_RefreshMerchantListQuestion.Contains(MissingMerchantName), StrSubstNo('The refresh question should name the missing merchant, actual question: %1', _RefreshMerchantListQuestion));
        _Assert.IsTrue(_MerchantsNotListedQuestion.Contains(MissingMerchantName), StrSubstNo('The continue question should name the missing merchant, actual question: %1', _MerchantsNotListedQuestion));
        _Assert.AreEqual('', _UnexpectedConfirmQuestion, 'No other question should have been asked');

        // [THEN] After the refresh, the continue question names the management API key as the reason
        _Assert.IsTrue(_MerchantsNotListedQuestion.Contains(AdyenSetup.FieldCaption("Management API Key Token")), StrSubstNo('After a refresh the continue question should name the management API key, actual question: %1', _MerchantsNotListedQuestion));

        // [THEN] The merchant list was read from Adyen once and no webhook was read, created or updated
        _Assert.AreEqual(1, _MockMerchantListRequests, 'The merchant list should have been read from Adyen once');
        _Assert.AreEqual(0, _MockFirstPageRequests, 'No webhook list should have been read');
        _Assert.AreEqual(0, _MockCreateRequests, 'No webhook should have been created at Adyen');
        _Assert.AreEqual(0, _MockUpdateRequests, 'No webhook should have been updated at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] The merchant list is as it was before the refresh, without the merchant only Adyen listed
        _Assert.AreEqual(1, MerchantAccount.Count(), 'The merchant list should still hold only the fixture merchant');
        _Assert.IsTrue(MerchantAccount.Get(MerchantName), 'The fixture merchant should still be in the merchant list');
        _Assert.IsFalse(MerchantAccount.Get(RefreshOnlyMerchant), 'The merchant read from Adyen during the declined refresh should not be in the merchant list');
        _Assert.AreEqual(0, CountWebhookSetups(MissingMerchantName), 'No webhook should be on the missing merchant');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('EnsureWebhooksConfirmHandler,AdyenManagementApiMock,MessageHandler')]
    procedure EnsureCaptureWebhooks_Crane_PGMerchantListedAfterRefresh_EnsuresWebhookWithoutSecondQuestion()
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantNames: List of [Text];
        MerchantName: Text[80];
        NewMerchant: Text[80];
        AdyenWebhookId: Code[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] When the refreshed merchant list holds the payment gateway merchant that was missing, the capture webhook is ensured for it and the user is not asked to continue
        Initialize();

        // [GIVEN] One listed merchant with an active webhook for CAPTURE and CAPTURE_FAILED, and credentials supplied with password Secret1
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        InsertWebhookSetup(MerchantName, 'CAPTURE|CAPTURE_FAILED', true, '', WebhookSetup);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret1', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] A new Adyen payment gateway with capture enabled whose merchant is not in the merchant list yet
        NewMerchant := NewMerchantName();
        CreateCaptureGatewayForMerchant(NewMerchant);

        // [GIVEN] Adyen lists both merchants
        MerchantNames.Add(MerchantName);
        MerchantNames.Add(NewMerchant);
        _MockMerchantListBody := MerchantListJson(MerchantNames);

        // [GIVEN] Adyen lists, for the new merchant, an active capture webhook whose URL is the one built from those credentials
        _MockMerchantName := NewMerchant;
        AdyenWebhookId := NewWebhookId();
        _MockFirstPageBody := WebhooksPageJson(1, AdyenWebhookId, CraneWebhookUrl('Secret1') + '&webhookRef=' + AdyenWebhookId);

        // [GIVEN] The user agrees to refresh the merchant list
        ResetEnsureWebhooksConfirm(true, false);

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] The user was asked to refresh the list and not asked to continue
        _Assert.IsTrue(_RefreshMerchantListQuestion.Contains(NewMerchant), StrSubstNo('The refresh question should name the missing merchant, actual question: %1', _RefreshMerchantListQuestion));
        _Assert.AreEqual('', _MerchantsNotListedQuestion, 'The user should not be asked to continue when the refresh found the merchant');
        _Assert.AreEqual('', _UnexpectedConfirmQuestion, 'No other question should have been asked');

        // [THEN] The new merchant is in the merchant list and its webhook from Adyen was adopted without creating one
        _Assert.IsTrue(MerchantAccount.Get(NewMerchant), 'The refresh should have added the new merchant to the merchant list');
        _Assert.AreEqual(1, CountWebhookSetups(NewMerchant), 'Exactly one webhook should be on the new merchant');
        WebhookSetup.Reset();
        WebhookSetup.SetRange("Merchant Account", NewMerchant);
        WebhookSetup.FindFirst();
        _Assert.AreEqual(AdyenWebhookId, WebhookSetup.ID, 'The webhook on the new merchant should be the one adopted from Adyen');

        // [THEN] Adyen was asked for the merchant list once and for the webhooks of the new merchant once, and nothing was created
        _Assert.AreEqual(1, _MockMerchantListRequests, 'The merchant list should have been read from Adyen once');
        _Assert.AreEqual(1, _MockFirstPageRequests, 'The webhook list of the new merchant should have been read once');
        _Assert.AreEqual(0, _MockCreateRequests, 'No webhook should have been created at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        DeleteWebhookSetups(NewMerchant);
        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('EnsureWebhooksConfirmHandler,AdyenManagementApiMock')]
    procedure EnsureCaptureWebhooks_Crane_MerchantListRefreshFails_ErrorsAndKeepsList()
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        MerchantName: Text[80];
        MissingMerchantName: Text[80];
        ApiKeyAdded: Boolean;
        MerchantListRefreshErr: Label 'Could not refresh %1 from Adyen.', Comment = '%1 = NP Pay Merchant Account table caption';
    begin
        // [SCENARIO] When the merchant list cannot be refreshed from Adyen, ensuring the webhooks fails with the refresh error and the merchant list is left as it was
        Initialize();

        // [GIVEN] One listed merchant with an active webhook for CAPTURE and CAPTURE_FAILED, and credentials supplied
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);
        InsertWebhookSetup(MerchantName, 'CAPTURE|CAPTURE_FAILED', true, '', WebhookSetup);
        AsyncAdyenPmtProcessing.SetBasicAuthCredentials(CraneWebUser(), 'Secret1', CopyStr(CraneBaseUrl(), 1, 2048));

        // [GIVEN] A new Adyen payment gateway with capture enabled whose merchant is not in the merchant list
        MissingMerchantName := NewMerchantName();
        CreateCaptureGatewayForMerchant(MissingMerchantName);

        // [GIVEN] Adyen answers the merchant list with HTTP 500
        _MockMerchantListStatusCode := 500;
        _MockMerchantListBody := '{"status":500,"errorCode":"00_500","message":"Internal server error","errorType":"internal"}';

        // [GIVEN] The user agrees to refresh the merchant list
        ResetEnsureWebhooksConfirm(true, false);
        // The asserterror below rolls back to the last commit, so the fixture is committed to see what the call itself left behind.
        Commit();

        // [WHEN] The CAPTURE and CAPTURE_FAILED webhooks are ensured
        asserterror AsyncAdyenPmtProcessing.EnsureCaptureWebhooks();

        // [THEN] It fails with the refresh error
        _Assert.ExpectedError(StrSubstNo(MerchantListRefreshErr, MerchantAccount.TableCaption));

        // [THEN] The merchant list was requested once, the user was not asked to continue, and no webhook was read or created
        _Assert.AreEqual(1, _MockMerchantListRequests, 'The merchant list should have been requested from Adyen once');
        _Assert.AreEqual('', _MerchantsNotListedQuestion, 'The user should not be asked to continue after a failed refresh');
        _Assert.AreEqual('', _UnexpectedConfirmQuestion, 'No other question should have been asked');
        _Assert.AreEqual(0, _MockFirstPageRequests, 'No webhook list should have been read');
        _Assert.AreEqual(0, _MockCreateRequests, 'No webhook should have been created at Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] The merchant list is as it was before the refresh
        _Assert.AreEqual(1, MerchantAccount.Count(), 'The merchant list should still hold only the fixture merchant');
        _Assert.IsTrue(MerchantAccount.Get(MerchantName), 'The fixture merchant should still be in the merchant list');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock')]
    procedure ImportWebhooks_CurrentEnvironmentStandardWebhook_IsImportedAndUnknownTypeSkipped()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AdyenManagement: Codeunit "NPR Adyen Management";
        DataArray: JsonArray;
        StandardWebhookObject: JsonObject;
        EventCodes: List of [Text];
        MerchantName: Text[80];
        StandardWebhookId: Code[80];
        UnknownTypeWebhookId: Code[80];
        OtherCompanyWebhookId: Code[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] Importing webhooks from Adyen maps a standard webhook of this environment with its basic authentication user, events and status, and skips a webhook of a type BC does not know and a webhook of another company
        Initialize();

        // [GIVEN] One merchant without webhooks in BC
        PrepareCraneEnsureFixture(MerchantName, ApiKeyAdded);

        // [GIVEN] Adyen lists an active standard webhook of this environment with description d1 for user u1 with AUTHORISATION and CAPTURE
        StandardWebhookId := NewWebhookId();
        EventCodes.Add('AUTHORISATION');
        EventCodes.Add('CAPTURE');
        StandardWebhookObject := WebhookJson(StandardWebhookId, 'standard', CurrentEnvironmentWebhookUrl(StandardWebhookId), 'u1', true, EventCodes);
        StandardWebhookObject.Add('description', 'd1');
        DataArray.Add(StandardWebhookObject);

        // [GIVEN] Adyen lists a webhook of this environment with a type BC does not know
        UnknownTypeWebhookId := NewWebhookId();
        DataArray.Add(WebhookJson(UnknownTypeWebhookId, 'unmapped-test-notification', CurrentEnvironmentWebhookUrl(UnknownTypeWebhookId), 'u1', true, EventCodes));

        // [GIVEN] Adyen lists an active standard webhook of this tenant and environment whose URL names company OTHER-COMPANY
        _Assert.AreNotEqual('OTHER-COMPANY', CompanyName(), 'The test company must differ from the other company in the webhook URL');
        OtherCompanyWebhookId := NewWebhookId();
        DataArray.Add(WebhookJson(OtherCompanyWebhookId, 'standard', CurrentEnvironmentWebhookUrlForCompany(OtherCompanyWebhookId, 'OTHER-COMPANY'), 'u1', true, EventCodes));
        _MockFirstPageBody := WebhookListJson(1, DataArray);

        // [WHEN] The webhooks of the merchant are imported, as the Import Webhooks from Adyen action does
        AdyenManagement.ImportWebhooks(0, MerchantName);

        // [THEN] The webhook list was read once and nothing else was sent
        _Assert.AreEqual(1, _MockFirstPageRequests, 'The merchant webhook list should have been read once');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        // [THEN] Only the standard webhook of this company was imported
        _Assert.AreEqual(1, AdyenManagement.GetImportedWebhooksAmount(), 'Exactly one webhook should have been imported');
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'Exactly one webhook should be on the merchant');
        WebhookSetup.SetRange(ID, UnknownTypeWebhookId);
        _Assert.IsTrue(WebhookSetup.IsEmpty(), 'The webhook with an unknown type should not have been imported');
        WebhookSetup.SetRange(ID, OtherCompanyWebhookId);
        _Assert.IsTrue(WebhookSetup.IsEmpty(), 'The webhook of another company should not have been imported');

        // [THEN] The imported webhook carries the type, URL, description, basic authentication user, events, status and merchant from Adyen
        WebhookSetup.SetRange(ID, StandardWebhookId);
        _Assert.IsTrue(WebhookSetup.FindFirst(), 'The standard webhook should have been imported');
        _Assert.IsTrue(WebhookSetup.Type = WebhookSetup.Type::standard, 'The imported webhook should be a standard webhook');
        _Assert.AreEqual(CurrentEnvironmentWebhookUrl(StandardWebhookId), WebhookSetup."Web Service URL", 'The imported webhook should keep the URL from Adyen');
        _Assert.AreEqual('d1', WebhookSetup.Description, 'The imported webhook should keep the description from Adyen');
        _Assert.IsTrue(WebhookSetup."Web Service Security" = WebhookSetup."Web Service Security"::"Basic authentication", 'The imported webhook should use basic authentication');
        _Assert.AreEqual('u1', WebhookSetup."Web Service User", 'The imported webhook should keep the user from Adyen');
        _Assert.AreEqual('AUTHORISATION|CAPTURE', WebhookSetup."Include Events Filter", 'The imported webhook should filter on the events from Adyen');
        _Assert.IsTrue(WebhookSetup.Active, 'The imported webhook should be active');
        _Assert.AreEqual(MerchantName, WebhookSetup."Merchant Account", 'The imported webhook should be on the merchant');

        DeleteWebhookSetups(MerchantName);
        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    procedure HasCapturesInFlight_NoLinesWaiting_ReturnsFalse()
    var
        CapturedLine: Record "NPR Magento Payment Line";
        NonAdyenLine: Record "NPR Magento Payment Line";
        CreditMemoSourceLine: Record "NPR Magento Payment Line";
        CreditMemoCopyLine: Record "NPR Magento Payment Line";
        SalesCreditMemoLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] Lines the CAPTURE webhook would not confirm do not count as captures in flight
        Initialize();
        ClearCapturesInFlight();

        // [GIVEN] An Adyen line on a sales order that is already captured
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, CapturedLine);
        CapturedLine."Date Captured" := Today();
        CapturedLine.Modify(false);

        // [GIVEN] A line on a sales order with a capture requested through a gateway that is not Adyen
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, NonAdyenLine);
        NonAdyenLine."Payment Gateway Code" := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        NonAdyenLine.Modify(false);

        // [GIVEN] A copy on a posted credit memo that keeps the capture requested, from a captured Adyen line
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, CreditMemoSourceLine);
        CreditMemoSourceLine."Date Captured" := Today();
        CreditMemoSourceLine.Modify(false);
        CreatePostedCreditMemoCopy(CreditMemoSourceLine, CreditMemoCopyLine);

        // [GIVEN] An Adyen line on an unposted sales credit memo with a capture requested
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::"Credit Memo", SalesCreditMemoLine);

        // [WHEN] Captures in flight are checked
        // [THEN] None is found
        _Assert.IsFalse(_AsyncFeature.HasCapturesInFlight(), 'Captured, non-Adyen and credit memo lines must not count as captures in flight');

        RestoreFeature();
    end;

    [Test]
    procedure HasCapturesInFlight_AdyenOrderLineWaiting_ReturnsTrue()
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] An Adyen sales order line waiting for capture confirmation counts as a capture in flight
        Initialize();
        ClearCapturesInFlight();

        // [GIVEN] An Adyen line on a sales order with a capture in flight
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [WHEN] Captures in flight are checked
        // [THEN] The line is found
        _Assert.IsTrue(_AsyncFeature.HasCapturesInFlight(), 'An Adyen sales order line with a capture in flight must count as a capture in flight');

        RestoreFeature();
    end;

    [Test]
    procedure HasCapturesInFlight_PostedInvoiceLineWaiting_ReturnsTrue()
    var
        SourceLine: Record "NPR Magento Payment Line";
        InvoiceCopyLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] An Adyen line on a posted sales invoice waiting for capture confirmation counts as a capture in flight
        Initialize();
        ClearCapturesInFlight();

        // [GIVEN] A copy on a posted sales invoice of an Adyen order line with a capture in flight
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, SourceLine);
        CreatePostedInvoiceCopy(SourceLine, InvoiceCopyLine);

        // [GIVEN] The source order line no longer waits, so only the invoice copy is in flight
        SourceLine."Capture Requested" := false;
        SourceLine.Modify(false);

        // [WHEN] Captures in flight are checked
        // [THEN] The invoice copy is found
        _Assert.IsTrue(_AsyncFeature.HasCapturesInFlight(), 'An Adyen posted sales invoice line with a capture in flight must count as a capture in flight');

        RestoreFeature();
    end;

    [Test]
    procedure HasCapturesInFlight_AdyenSalesInvoiceLineWaiting_ReturnsTrue()
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        // [SCENARIO] An Adyen line on an unposted sales invoice waiting for capture confirmation counts as a capture in flight
        Initialize();
        ClearCapturesInFlight();

        // [GIVEN] An Adyen line on an unposted sales invoice with a capture in flight
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Invoice, PaymentLine);

        // [WHEN] Captures in flight are checked
        // [THEN] The line is found
        _Assert.IsTrue(_AsyncFeature.HasCapturesInFlight(), 'An Adyen sales invoice line with a capture in flight must count as a capture in flight');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('DisableConfirmNoHandler')]
    procedure DisableFeature_CapturesInFlight_UserDeclines_ConfirmShownAndDisableRefused()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        JobQueueEntry: Record "Job Queue Entry";
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] Declining the warning about captures in flight keeps the feature enabled and its job in place
        Initialize();

        // [GIVEN] An Adyen line on a sales order with a capture in flight
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] The job that processes the capture webhooks, on hold so the scheduler does not run it
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR Adyen Async Pay ProcessJQ";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(false);
        Commit();

        // [WHEN] An administrator turns the feature off on the page, answers No and closes the page
        _LastConfirmQuestion := '';
        OpenAsyncFeature(FeatureManagement);
        FeatureManagement.Enabled.SetValue(false);
        FeatureManagement.Close();

        // [THEN] The administrator was warned, the declined disable was not saved and the job for the capture webhooks remains
        _Assert.IsTrue(
            _LastConfirmQuestion.StartsWith('Some payment lines have an Adyen capture'),
            StrSubstNo('The warning about captures in flight must be shown, actual question: %1', _LastConfirmQuestion));
        _Assert.IsTrue(_AsyncFeature.IsFeatureEnabled(), 'A declined disable must leave the feature enabled');
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Adyen Async Pay ProcessJQ");
        _Assert.IsFalse(JobQueueEntry.IsEmpty(), 'A declined disable must keep the job that processes the capture webhooks');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('DisableConfirmYesHandler')]
    procedure DisableFeature_CapturesInFlight_UserConfirms_FeatureDisabledAndJobRemoved()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        JobQueueEntry: Record "Job Queue Entry";
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] Confirming the warning about captures in flight disables the feature and removes its job
        Initialize();

        // [GIVEN] An Adyen line on a sales order with a capture in flight
        CreateAdyenInFlightLine(NewPspReference(), Database::"Sales Header", Enum::"Sales Document Type"::Order, PaymentLine);

        // [GIVEN] The job that processes the capture webhooks, on hold so the scheduler does not run it
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR Adyen Async Pay ProcessJQ";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(false);
        Commit();

        // [WHEN] An administrator turns the feature off on the page and answers Yes. The record is modified when the page closes.
        _LastConfirmQuestion := '';
        OpenAsyncFeature(FeatureManagement);
        FeatureManagement.Enabled.SetValue(false);
        FeatureManagement.Close();

        // [THEN] The administrator was warned, the feature is disabled and no job for the capture webhooks remains
        _Assert.IsTrue(
            _LastConfirmQuestion.StartsWith('Some payment lines have an Adyen capture'),
            StrSubstNo('The warning about captures in flight must be shown, actual question: %1', _LastConfirmQuestion));
        _Assert.IsFalse(_AsyncFeature.IsFeatureEnabled(), 'A confirmed disable must disable the feature');
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Adyen Async Pay ProcessJQ");
        _Assert.IsTrue(JobQueueEntry.IsEmpty(), 'A confirmed disable must remove the job that processes the capture webhooks');

        RestoreFeature();
    end;

    [Test]
    procedure DisableFeature_NoCapturesInFlight_NoPrompt()
    var
        FeatureManagement: TestPage "NPR Feature Management";
    begin
        // [SCENARIO] Without captures in flight the feature is disabled without a warning
        Initialize();

        // [GIVEN] No payment line waiting for capture confirmation
        ClearCapturesInFlight();
        Commit();

        // [WHEN] An administrator turns the feature off on the page. No confirm handler is bound, so a prompt fails the test.
        OpenAsyncFeature(FeatureManagement);
        FeatureManagement.Enabled.SetValue(false);
        FeatureManagement.Close();

        // [THEN] The feature is disabled
        _Assert.IsFalse(_AsyncFeature.IsFeatureEnabled(), 'The feature must be disabled when no capture is in flight');

        RestoreFeature();
    end;

    [Test]
    procedure DisableFeature_JobQueueEntryDeletedByHand_RemovesMonitoredEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        FeatureManagement: TestPage "NPR Feature Management";
        DeletedJobQueueEntryId: Guid;
    begin
        // [SCENARIO] Disabling the feature removes the monitored entry of its job even when the job itself was deleted by hand, so the job queue refresher cannot bring the job back
        Initialize();
        ClearCapturesInFlight();
        DeleteAsyncJobQueueEntries();

        // [GIVEN] The job that processes the capture webhooks, scheduled while the feature is off so a scheduler run would do nothing
        _AsyncFeature.SetFeatureEnabled(false);
        AdyenAsyncPayProcessJQ.ScheduleJobQueue();
        _Assert.IsTrue(FindAsyncJobQueueEntry(JobQueueEntry), 'The job that processes the capture webhooks should have been scheduled');
        DeletedJobQueueEntryId := JobQueueEntry.ID;

        // [GIVEN] A user deleted that job by hand, which leaves its monitored entry behind
        JobQueueEntry.Delete(true);
        _Assert.AreEqual(1, CountAsyncMonitoredEntries(), 'The monitored entry of the job should be left behind after the job was deleted by hand');
        _AsyncFeature.SetFeatureEnabled(true);

        // [WHEN] An administrator turns the feature off on the page. No confirm handler is bound, so a prompt fails the test.
        OpenAsyncFeature(FeatureManagement);
        FeatureManagement.Enabled.SetValue(false);
        FeatureManagement.Close();

        // [THEN] The feature is disabled and no monitored entry of the job is left
        _Assert.IsFalse(_AsyncFeature.IsFeatureEnabled(), 'The feature must be disabled');
        _Assert.AreEqual(0, CountAsyncMonitoredEntries(), 'Disabling the feature should remove the monitored entry of the deleted job');
        _Assert.IsFalse(ManagedByAppJobQueue.Get(DeletedJobQueueEntryId), 'No managed by app entry should be left for the deleted job');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('EnsureWebhooksConfirmHandler')]
    procedure EnableFeature_PGMerchantNotListed_UserDeclinesRefreshAndContinue_FeatureStaysOff()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        JobQueueEntry: Record "Job Queue Entry";
        FeatureManagement: TestPage "NPR Feature Management";
        MerchantName: Text[80];
        MissingMerchantName: Text[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] Enabling the feature while a payment gateway merchant is not in the merchant list asks whether to refresh the list and whether to continue; declining both keeps the feature off and schedules no job
        // No HTTP handler is bound: declining the refresh must not call Adyen.
        Initialize();
        _AsyncFeature.SetFeatureEnabled(false);
        DeleteAsyncJobQueueEntries();

        // [GIVEN] One listed merchant with an active webhook for CAPTURE and CAPTURE_FAILED
        PrepareEnsureWebhookFixture('CAPTURE|CAPTURE_FAILED', MerchantName, ApiKeyAdded);

        // [GIVEN] A new Adyen payment gateway with capture enabled whose merchant is not in the merchant list
        MissingMerchantName := NewMerchantName();
        CreateCaptureGatewayForMerchant(MissingMerchantName);

        // [GIVEN] The user confirms enabling, declines to refresh the merchant list and declines to continue without the missing merchant
        ResetEnsureWebhooksConfirm(false, false);
        Commit();

        // [WHEN] An administrator turns the feature on on the page
        OpenAsyncFeature(FeatureManagement);
        FeatureManagement.Enabled.SetValue(true);
        FeatureManagement.Close();

        // [THEN] The administrator was asked to refresh the list and then to continue, both times naming the missing merchant
        _Assert.IsTrue(_RefreshMerchantListQuestion.Contains(MissingMerchantName), StrSubstNo('The refresh question should name the missing merchant, actual question: %1', _RefreshMerchantListQuestion));
        _Assert.IsTrue(_MerchantsNotListedQuestion.Contains(MissingMerchantName), StrSubstNo('The continue question should name the missing merchant, actual question: %1', _MerchantsNotListedQuestion));
        _Assert.AreEqual('', _UnexpectedConfirmQuestion, 'No other question should have been asked');

        // [THEN] Without a refresh, the continue question does not blame the management API key
        _Assert.IsFalse(_MerchantsNotListedQuestion.Contains(AdyenSetup.FieldCaption("Management API Key Token")), StrSubstNo('Without a refresh the continue question should not name the management API key, actual question: %1', _MerchantsNotListedQuestion));

        // [THEN] The feature stays off, no job was scheduled and no webhook was set up for the missing merchant
        _Assert.IsFalse(_AsyncFeature.IsFeatureEnabled(), 'Declining to continue must leave the feature disabled');
        _Assert.IsFalse(FindAsyncJobQueueEntry(JobQueueEntry), 'Declining to continue must not schedule the job that processes the capture webhooks');
        _Assert.AreEqual(0, CountWebhookSetups(MissingMerchantName), 'No webhook should be on the missing merchant');

        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,MessageHandler')]
    procedure EnableFeature_FromFeaturePage_EnsuresWebhooksAndSchedulesJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        FeatureManagement: TestPage "NPR Feature Management";
        MerchantName: Text[80];
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] Enabling the feature on the page asks for confirmation, ensures the capture webhooks and schedules the job that processes them
        Initialize();
        _AsyncFeature.SetFeatureEnabled(false);
        DeleteAsyncJobQueueEntries();

        // [GIVEN] One listed merchant with an active webhook for CAPTURE and CAPTURE_FAILED, so no call to Adyen is needed
        PrepareEnsureWebhookFixture('CAPTURE|CAPTURE_FAILED', MerchantName, ApiKeyAdded);
        Commit();

        // [WHEN] An administrator turns the feature on on the page and answers Yes
        _LastConfirmQuestion := '';
        OpenAsyncFeature(FeatureManagement);
        FeatureManagement.Enabled.SetValue(true);
        FeatureManagement.Close();

        // [THEN] The job that processes the capture webhooks was scheduled. It is put on hold first, so the scheduler does not run it.
        _Assert.IsTrue(FindAsyncJobQueueEntry(JobQueueEntry), 'Enabling the feature should schedule the job that processes the capture webhooks');
        PutAsyncJobQueueEntriesOnHold();

        // [THEN] The administrator was asked to confirm the webhook setup and the feature is enabled
        _Assert.IsTrue(
            _LastConfirmQuestion.StartsWith('Enabling this feature will set up a webhook'),
            StrSubstNo('The question about the webhook setup must be shown, actual question: %1', _LastConfirmQuestion));
        _Assert.IsTrue(_AsyncFeature.IsFeatureEnabled(), 'The feature should be enabled');

        // [THEN] The merchant keeps its one webhook
        _Assert.AreEqual(1, CountWebhookSetups(MerchantName), 'No webhook should have been created for the merchant');

        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [Test]
    procedure ScheduleJobQueue_NoEntry_CreatesRecurringManagedMonitoredEntry()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
    begin
        // [SCENARIO] Scheduling the job without an existing entry creates a job that runs every minute, is managed by the app and is monitored
        Initialize();
        DeleteAsyncJobQueueEntries();

        // [GIVEN] The feature is off while scheduling, so a scheduler run would do nothing
        _AsyncFeature.SetFeatureEnabled(false);

        // [WHEN] The job is scheduled
        AdyenAsyncPayProcessJQ.ScheduleJobQueue();

        // [THEN] One job exists. It is put on hold first, so the scheduler does not run it.
        _Assert.IsTrue(FindAsyncJobQueueEntry(JobQueueEntry), 'The job that processes the capture webhooks should have been created');
        PutAsyncJobQueueEntriesOnHold();
        JobQueueEntry.Find();

        // [THEN] The job is recurring every minute
        _Assert.IsTrue(JobQueueEntry."Recurring Job", 'The job should be recurring');
        _Assert.AreEqual(1, JobQueueEntry."No. of Minutes between Runs", 'The job should run every minute');

        // [THEN] The job is managed by the app and monitored
        _Assert.IsTrue(ManagedByAppJobQueue.Get(JobQueueEntry.ID), 'The job should have a managed by app entry');
        _Assert.IsTrue(ManagedByAppJobQueue."Managed by App", 'The job should be managed by the app');
        MonitoredJQEntry.SetRange("Job Queue Entry ID", JobQueueEntry.ID);
        _Assert.AreEqual(1, MonitoredJQEntry.Count(), 'The job should have one monitored entry');

        RestoreFeature();
    end;

    [Test]
    procedure ScheduleJobQueue_ExistingEntry_IsReusedNotDuplicated()
    var
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
        AdyenAsyncPayProcessJQ: Codeunit "NPR Adyen Async Pay ProcessJQ";
        ExistingJobQueueEntryId: Guid;
        EntryCount: Integer;
        OnHoldAfterScheduling: Boolean;
    begin
        // [SCENARIO] Scheduling the job when its entry already exists reuses that entry and leaves its status as it was
        Initialize();
        DeleteAsyncJobQueueEntries();

        // [GIVEN] The job that processes the capture webhooks, on hold
        JobQueueEntry.Init();
        JobQueueEntry.ID := CreateGuid();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"NPR Adyen Async Pay ProcessJQ";
        JobQueueEntry.Status := JobQueueEntry.Status::"On Hold";
        JobQueueEntry.Insert(false);
        ExistingJobQueueEntryId := JobQueueEntry.ID;

        // [WHEN] The job is scheduled
        AdyenAsyncPayProcessJQ.ScheduleJobQueue();

        // [THEN] The status after scheduling is read, then every entry is put on hold, so the scheduler does not run a new one
        _Assert.IsTrue(JobQueueEntry.Get(ExistingJobQueueEntryId), 'The existing job should still exist');
        OnHoldAfterScheduling := JobQueueEntry.Status = JobQueueEntry.Status::"On Hold";
        EntryCount := CountAsyncJobQueueEntries();
        PutAsyncJobQueueEntriesOnHold();

        // [THEN] The existing entry is the only one and it is still on hold
        _Assert.AreEqual(1, EntryCount, 'Scheduling should reuse the existing job and not create another one');
        _Assert.IsTrue(OnHoldAfterScheduling, 'Scheduling should not restart the existing job');

        // [THEN] The existing entry is managed by the app
        _Assert.IsTrue(ManagedByAppJobQueue.Get(ExistingJobQueueEntryId), 'The existing job should have a managed by app entry');

        RestoreFeature();
    end;

    [Test]
    [HandlerFunctions('AdyenManagementApiMock')]
    procedure AdyenSetupPage_ConfigureAsyncJobQueueAction_SchedulesJob()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        JobQueueEntry: Record "Job Queue Entry";
        ManagedByAppJobQueue: Record "NPR Managed By App Job Queue";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
        AdyenSetupPage: TestPage "NPR Adyen Setup";
        ApiKeyAdded: Boolean;
    begin
        // [SCENARIO] The NP Pay Setup action for the asynchronous payment processing job schedules the job
        Initialize();
        // Opening NP Pay Setup with a Management API key tests the key at Adyen, which only the HTTP handler on an on-prem service tier can answer.
        _Assert.IsTrue(AsyncAdyenPmtProcessing.IsCraneEnvironment(), 'The NP Pay Setup page test mocks HTTP and must run on an on-prem service tier');
        DeleteAsyncJobQueueEntries();

        // [GIVEN] NP Pay Setup with a Management API key, so opening the page always tests the key at the mocked Adyen
        if not AdyenSetup.Get() then begin
            AdyenSetup.Init();
            AdyenSetup.Insert();
        end;
        ApiKeyAdded := not AdyenSetup.HasManagementAPIKey();
        if ApiKeyAdded then
            AdyenSetup.SetManagementAPIKey('test-management-api-key');
        AdyenSetup."Environment Type" := AdyenSetup."Environment Type"::Test;
        if AdyenSetup."Company ID" = '' then
            AdyenSetup."Company ID" := 'ASYNC-CAPTURE-TEST-COMPANY';
        AdyenSetup.Modify();
        ResetAdyenApiMock('');

        // [WHEN] The action is run from NP Pay Setup while the feature is enabled
        AdyenSetupPage.OpenEdit();
        AdyenSetupPage.ConfigureAsyncPmtProcessJQ.Invoke();
        AdyenSetupPage.Close();

        // [THEN] The job that processes the capture webhooks was scheduled. It is put on hold first, so the scheduler does not run it.
        _Assert.IsTrue(FindAsyncJobQueueEntry(JobQueueEntry), 'The action should schedule the job that processes the capture webhooks');
        PutAsyncJobQueueEntriesOnHold();

        // [THEN] The job is managed by the app and the page sent nothing to Adyen but the key test
        _Assert.IsTrue(ManagedByAppJobQueue.Get(JobQueueEntry.ID), 'The scheduled job should have a managed by app entry');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen calls should have been sent');

        RemoveTestManagementApiKey(ApiKeyAdded);
        RestoreFeature();
    end;

    [ConfirmHandler]
    procedure DisableConfirmNoHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        _LastConfirmQuestion := Question;
        Reply := false;
    end;

    [ConfirmHandler]
    procedure DisableConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        _LastConfirmQuestion := Question;
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        _LastConfirmQuestion := Question;
        Reply := true;
    end;

    // Answers Yes to enabling the feature, answers the two merchant list questions as set by ResetEnsureWebhooksConfirm, and records which were asked.
    [ConfirmHandler]
    procedure EnsureWebhooksConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        _LastConfirmQuestion := Question;
        if Question.StartsWith('Enabling this feature will set up a webhook') then begin
            Reply := true;
            exit;
        end;
        if Question.Contains('Do you want to refresh') then begin
            _RefreshMerchantListQuestion := Question;
            Reply := _RefreshMerchantListReply;
            exit;
        end;
        if Question.Contains('their captures stay pending until they are reset') then begin
            _MerchantsNotListedQuestion := Question;
            Reply := _MerchantsNotListedReply;
            exit;
        end;
        _UnexpectedConfirmQuestion := Question;
        Reply := false;
    end;

    [StrMenuHandler]
    procedure ResetCaptureStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        _LastStrMenuOptions := Options;
        _LastStrMenuInstruction := Instruction;
        Choice := _StrMenuChoice;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [MessageHandler]
    procedure CaptureMessageHandler(Message: Text[1024])
    begin
        _LastMessage := Message;
    end;

    [HttpClientHandler]
    procedure AdyenCaptureApiMock(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        QueryParameters: Dictionary of [Text, Text];
        RequestUrl: Text;
    begin
        // Fails closed: only the Adyen capture call is answered, anything else gets a 404 and is counted.
        ReadRequestUrl(Request, RequestUrl, QueryParameters);
        if (Request.RequestType() = HttpRequestType::Post) and RequestUrl.EndsWith('/capture') then begin
            _MockCaptureRequests += 1;
            SetMockResponse(Response, 200, '{"pspReference":"' + _MockCapturePsp + '","response":"[capture-received]"}');
            exit(false);
        end;

        _MockUnexpectedRequests += 1;
        SetMockResponse(Response, 404, '{"status":404}');
        exit(false);
    end;

    [HttpClientHandler]
    procedure AdyenManagementApiMock(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        QueryParameters: Dictionary of [Text, Text];
        RequestUrl: Text;
        WebhooksPath: Text;
        PageSize: Text;
        PageNumber: Text;
    begin
        // Fails closed: anything other than the webhook list, create and update calls set up for the merchant under test,
        // the merchant list set up by the test and the API key test gets a 404 and is counted, and every test asserts that count is zero.
        ReadRequestUrl(Request, RequestUrl, QueryParameters);
        WebhooksPath := '/merchants/' + _MockMerchantName + '/webhooks';

        if (Request.RequestType() = HttpRequestType::Get) and RequestUrl.EndsWith(WebhooksPath) then begin
            if not QueryParameters.Get('pageSize', PageSize) then
                PageSize := '';
            if not QueryParameters.Get('pageNumber', PageNumber) then
                PageNumber := '1';
            if PageSize = '100' then begin
                if (PageNumber = '1') and (_MockFirstPageBody <> '') then begin
                    _MockFirstPageRequests += 1;
                    SetMockResponse(Response, _MockFirstPageStatusCode, _MockFirstPageBody);
                    exit(false);
                end;
                if (PageNumber = '2') and (_MockSecondPageBody <> '') then begin
                    _MockSecondPageRequests += 1;
                    SetMockResponse(Response, 200, _MockSecondPageBody);
                    exit(false);
                end;
            end;
        end;

        if (Request.RequestType() = HttpRequestType::Post) and RequestUrl.EndsWith(WebhooksPath) and (_MockCreateResponseBody <> '') then begin
            _MockCreateRequests += 1;
            SetMockResponse(Response, 200, _MockCreateResponseBody);
            exit(false);
        end;

        if (Request.RequestType() = HttpRequestType::Patch) and (_MockUpdatableWebhookId <> '') and RequestUrl.EndsWith(WebhooksPath + '/' + _MockUpdatableWebhookId) then begin
            _MockUpdateRequests += 1;
            SetMockResponse(Response, 200, WebhookIdJson(_MockUpdatableWebhookId));
            exit(false);
        end;

        if (Request.RequestType() = HttpRequestType::Get) and RequestUrl.EndsWith('/merchants') and (_MockMerchantListBody <> '') then begin
            _MockMerchantListRequests += 1;
            SetMockResponse(Response, _MockMerchantListStatusCode, _MockMerchantListBody);
            exit(false);
        end;

        // NP Pay Setup tests the Management API key with this call when it opens.
        if (Request.RequestType() = HttpRequestType::Get) and RequestUrl.EndsWith('/companies') then begin
            SetMockResponse(Response, 200, '{"data":[]}');
            exit(false);
        end;

        _MockUnexpectedRequests += 1;
        SetMockResponse(Response, 404, '{"status":404}');
        exit(false);
    end;

    local procedure Initialize()
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
    begin
        _AsyncFeature.AddFeature();
        if not _Initialized then begin
            _OriginalFeatureEnabled := _AsyncFeature.IsFeatureEnabled();
            _Initialized := true;
        end;
        _AsyncFeature.SetFeatureEnabled(true);

        AdyenWebhook.SetFilter("Event Code", '%1|%2', AdyenWebhook."Event Code"::CAPTURE, AdyenWebhook."Event Code"::CAPTURE_FAILED);
        AdyenWebhook.SetFilter(Status, '%1|%2', AdyenWebhook.Status::New, AdyenWebhook.Status::Error);
        AdyenWebhook.DeleteAll();
    end;

    local procedure RestoreFeature()
    begin
        _AsyncFeature.SetFeatureEnabled(_OriginalFeatureEnabled);
    end;

    local procedure OpenAsyncFeature(var FeatureManagement: TestPage "NPR Feature Management")
    var
        FeatureIdTok: Label 'asynchAdyenPaymentProcessing', Locked = true;
    begin
        FeatureManagement.OpenEdit();
        FeatureManagement.Filter.SetFilter(Id, FeatureIdTok);
        FeatureManagement.First();
    end;

    // Earlier cases in this codeunit leave capture requests in flight behind, so a case that needs none clears them first.
    local procedure ClearCapturesInFlight()
    var
        PaymentLine: Record "NPR Magento Payment Line";
    begin
        PaymentLine.SetRange("Capture Requested", true);
        PaymentLine.SetRange("Date Captured", 0D);
        PaymentLine.ModifyAll("Capture Requested", false, false);
    end;

    local procedure NewPspReference(): Text
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;

    local procedure CreateAdyenInFlightLine(Psp: Text; DocTableNo: Integer; DocType: Enum "Sales Document Type"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        InteractionLog: Record "NPR PG Interaction Log Entry";
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
    begin
        PaymentLine.Init();
        PaymentLine."Document Table No." := DocTableNo;
        PaymentLine."Document Type" := DocType;
        PaymentLine."Document No." := CopyStr(Psp, 1, MaxStrLen(PaymentLine."Document No."));
        PaymentLine."Line No." := 10000;
        PaymentLine."No." := CopyStr(Psp, 1, MaxStrLen(PaymentLine."No."));
        PaymentLine.Description := 'Test Adyen async capture';
        PaymentLine.Amount := 100;
        PaymentLine."Payment Gateway Code" := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen);
        PaymentLine."Charge ID" := CopyStr(Psp, 1, MaxStrLen(PaymentLine."Charge ID"));
        PaymentLine."Capture Requested" := true;
        PaymentLine."Date Captured" := 0D;
        PaymentLine.Insert(true);

        LogMgt.LogCaptureStart(InteractionLog, PaymentLine.SystemId);
    end;

    // Builds a partial-posting copy with the open log still on the source line, so the webhook and reset tests cover a log on either line.
    // The copy keeps Charge ID, Capture Requested and the ecommerce link and gets a new SystemId; the source line keeps the rest of the amount.
    local procedure CreatePostedInvoiceCopy(var SourceLine: Record "NPR Magento Payment Line"; var CopyLine: Record "NPR Magento Payment Line")
    var
        InvoicedAmount: Decimal;
    begin
        InvoicedAmount := 60;

        CopyLine.Init();
        CopyLine := SourceLine;
        CopyLine."Document Table No." := Database::"Sales Invoice Header";
        CopyLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
        CopyLine."Document No." := CopyStr('INV' + NewPspReference(), 1, MaxStrLen(CopyLine."Document No."));
        CopyLine."Posting Date" := Today();
        CopyLine.Amount := InvoicedAmount;
        CopyLine.Insert();

        SourceLine.Amount -= InvoicedAmount;
        SourceLine.Modify();
    end;

    // A copy on a posted credit memo that keeps the Charge ID and the capture in flight, with a new SystemId and no interaction log.
    local procedure CreatePostedCreditMemoCopy(SourceLine: Record "NPR Magento Payment Line"; var CopyLine: Record "NPR Magento Payment Line")
    begin
        CopyLine.Init();
        CopyLine := SourceLine;
        CopyLine."Document Table No." := Database::"Sales Cr.Memo Header";
        CopyLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
        CopyLine."Document No." := CopyStr('CRM' + NewPspReference(), 1, MaxStrLen(CopyLine."Document No."));
        CopyLine."Posting Date" := Today();
        CopyLine."Capture Requested" := true;
        CopyLine."Date Captured" := 0D;
        CopyLine.Insert();
    end;

    local procedure AssertInFlightLineUntouched(PaymentLine: Record "NPR Magento Payment Line"; Psp: Text)
    begin
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", StrSubstNo('The payment line for table %1 should not have been marked as captured', PaymentLine."Document Table No."));
        _Assert.AreEqual(UpperCase(Psp), PaymentLine."Charge ID", StrSubstNo('The Charge ID of the payment line for table %1 should not have been changed', PaymentLine."Document Table No."));
        _Assert.AreEqual(true, PaymentLine."Capture Requested", StrSubstNo('Capture Requested of the payment line for table %1 should not have been changed', PaymentLine."Document Table No."));
    end;

    local procedure AssertCaptureFailedOnLine(PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine.Find();
        _Assert.AreEqual(0D, PaymentLine."Date Captured", StrSubstNo('The payment line for table %1 should not have been marked as captured', PaymentLine."Document Table No."));
        _Assert.AreEqual('', PaymentLine."Charge ID", StrSubstNo('The Charge ID of the payment line for table %1 should have been cleared', PaymentLine."Document Table No."));
        _Assert.AreEqual(false, PaymentLine."Capture Requested", StrSubstNo('Capture Requested of the payment line for table %1 should have been cleared', PaymentLine."Document Table No."));
    end;

    local procedure InsertCaptureWebhook(EventCode: Enum "NPR Adyen Webhook Event Code"; Psp: Text; SuccessTxt: Text; Reason: Text; EventDate: DateTime; var AdyenWebhook: Record "NPR Adyen Webhook")
    var
        RootObject: JsonObject;
        NotificationItems: JsonArray;
        WebhookJsonText: Text;
    begin
        NotificationItems.Add(NotificationItemJson(Psp, SuccessTxt, Reason));
        RootObject.Add('live', 'false');
        RootObject.Add('notificationItems', NotificationItems);
        RootObject.WriteTo(WebhookJsonText);

        InsertCaptureWebhookWithData(EventCode, Psp, SuccessTxt = 'true', EventDate, WebhookJsonText, AdyenWebhook);
    end;

    local procedure NotificationItemJson(Psp: Text; SuccessTxt: Text; Reason: Text): JsonObject
    var
        NotificationItemWrapper: JsonObject;
        NotificationRequestItem: JsonObject;
    begin
        NotificationRequestItem.Add('pspReference', Psp);
        NotificationRequestItem.Add('success', SuccessTxt);
        NotificationRequestItem.Add('reason', Reason);
        NotificationItemWrapper.Add('NotificationRequestItem', NotificationRequestItem);
        exit(NotificationItemWrapper);
    end;

    local procedure InsertCaptureWebhookWithData(EventCode: Enum "NPR Adyen Webhook Event Code"; Psp: Text; IsSuccess: Boolean; EventDate: DateTime; WebhookJsonText: Text; var AdyenWebhook: Record "NPR Adyen Webhook")
    var
        WebhookOutStream: OutStream;
    begin
        AdyenWebhook.Init();
        AdyenWebhook."Entry No." := 0;
        AdyenWebhook."Event Code" := EventCode;
        AdyenWebhook.Status := AdyenWebhook.Status::New;
        AdyenWebhook.Success := IsSuccess;
        AdyenWebhook.Live := false;
        AdyenWebhook."Event Date" := EventDate;
        AdyenWebhook."PSP Reference" := CopyStr(Psp, 1, MaxStrLen(AdyenWebhook."PSP Reference"));
        AdyenWebhook."Webhook Data".CreateOutStream(WebhookOutStream, TextEncoding::UTF8);
        WebhookOutStream.WriteText(WebhookJsonText);
        AdyenWebhook.Insert();
    end;

    local procedure AssertHttpMockAvailable()
    var
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
    begin
        // HttpClientHandler intercepts requests only on an on-prem service tier.
        _Assert.IsTrue(AsyncAdyenPmtProcessing.IsCraneEnvironment(), 'The Adyen capture tests mock HTTP and must run on an on-prem service tier');
    end;

    local procedure CreateAdyenCaptureSetup(GatewayCode: Code[10])
    var
        AdyenSetup: Record "NPR PG Adyen Setup";
    begin
        AdyenSetup.Init();
        AdyenSetup.Code := GatewayCode;
        AdyenSetup.Environment := AdyenSetup.Environment::Test;
        AdyenSetup."Merchant Name" := 'ASYNCCAPTURETEST';
        AdyenSetup."API Username" := 'ws@async-capture-test';
        // The capture call reads the password from isolated storage and fails without it.
        AdyenSetup.SetAPIPassword('async-capture-test');
        AdyenSetup.Insert();
    end;

    local procedure CreateAdyenOrderPaymentLine(var SalesHeader: Record "Sales Header"; var PaymentLine: Record "NPR Magento Payment Line"; GatewayCode: Code[10])
    var
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateSalesOrder(SalesHeader);
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);
    end;

    local procedure CreateCreditMemoFromPostedInvoice(PostedInvoiceNo: Code[20]; var CreditMemoHeader: Record "Sales Header")
    var
        CopyDocMgt: Codeunit "Copy Document Mgt.";
    begin
        Clear(CreditMemoHeader);
        CreditMemoHeader."No." := '';
        CreditMemoHeader."Document Type" := CreditMemoHeader."Document Type"::"Credit Memo";
        CreditMemoHeader.SetAllowSelectNoSeries();
        CreditMemoHeader.Insert(true);

        CopyDocMgt.SetPropertiesForCreditMemoCorrection();

        CopyDocMgt.CopySalesDocForInvoiceCancelling(PostedInvoiceNo, CreditMemoHeader);
    end;

    local procedure CreateAdyenOrderPaymentLineWithCaptureSetup(var SalesHeader: Record "Sales Header"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        GatewayCode: Code[10];
    begin
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen);
        CreateAdyenCaptureSetup(GatewayCode);
        CreateAdyenOrderPaymentLine(SalesHeader, PaymentLine, GatewayCode);
    end;

    local procedure ResetCaptureApiMock(Psp: Text)
    begin
        _MockCapturePsp := Psp;
        _MockCaptureRequests := 0;
        _MockUnexpectedRequests := 0;
    end;

    local procedure AssertOneCaptureRequestSent()
    begin
        _Assert.AreEqual(1, _MockCaptureRequests, 'Exactly one capture request should have been sent to Adyen');
        _Assert.AreEqual(0, _MockUnexpectedRequests, 'No request outside the mocked Adyen capture call should have been sent');
    end;

    // Same capture in flight as CreateAdyenInFlightLine, on a payment line that already exists.
    local procedure MarkInFlightWithLog(var PaymentLine: Record "NPR Magento Payment Line"; Psp: Text)
    var
        InteractionLog: Record "NPR PG Interaction Log Entry";
        LogMgt: Codeunit "NPR PG Interactions Log Mgt.";
    begin
        PaymentLine."Charge ID" := CopyStr(Psp, 1, MaxStrLen(PaymentLine."Charge ID"));
        PaymentLine."Capture Requested" := true;
        PaymentLine."Date Captured" := 0D;
        PaymentLine.Modify();

        LogMgt.LogCaptureStart(InteractionLog, PaymentLine.SystemId);
    end;

    local procedure CountInteractionLogs(PaymentLineSystemId: Guid): Integer
    var
        InteractionLog: Record "NPR PG Interaction Log Entry";
    begin
        InteractionLog.SetRange("Payment Line System Id", PaymentLineSystemId);
        exit(InteractionLog.Count());
    end;

    local procedure CountOpenCaptureLogs(PaymentLineSystemId: Guid): Integer
    var
        InteractionLog: Record "NPR PG Interaction Log Entry";
    begin
        InteractionLog.SetRange("Payment Line System Id", PaymentLineSystemId);
        InteractionLog.SetRange("Interaction Type", InteractionLog."Interaction Type"::Capture);
        InteractionLog.SetRange("In Progress", true);
        exit(InteractionLog.Count());
    end;

    local procedure ReadLogErrorMessage(var InteractionLog: Record "NPR PG Interaction Log Entry") ErrorMessage: Text
    var
        ErrorInStream: InStream;
    begin
        InteractionLog.CalcFields("Error Message");
        if not InteractionLog."Error Message".HasValue() then
            exit('');
        InteractionLog."Error Message".CreateInStream(ErrorInStream);
        ErrorInStream.ReadText(ErrorMessage);
    end;

    local procedure CaptureInProgressMsg(): Text
    var
        CaptureInProgressLbl: Label 'A capture of this payment is already in progress. Wait until the payment provider confirms or rejects it.';
    begin
        exit(CaptureInProgressLbl);
    end;

    local procedure NoCaptureRequestMsg(): Text
    var
        NoCaptureRequestLbl: Label 'There is no capture request in progress for this payment line.';
    begin
        exit(NoCaptureRequestLbl);
    end;

    local procedure ProcessWebhook(var AdyenWebhook: Record "NPR Adyen Webhook")
    begin
        Commit();
        _Assert.AreEqual(true, Codeunit.Run(Codeunit::"NPR Adyen Webhook Processing", AdyenWebhook), GetLastErrorText());
        AdyenWebhook.Get(AdyenWebhook."Entry No.");
    end;

    local procedure AssertWebhookProcessed(AdyenWebhook: Record "NPR Adyen Webhook")
    begin
        _Assert.IsTrue(AdyenWebhook.Status = AdyenWebhook.Status::Processed, StrSubstNo('The webhook should have been processed but its status is %1', AdyenWebhook.Status));
    end;

    local procedure AssertCaptureLogCompleted(PaymentLine: Record "NPR Magento Payment Line"; ExpectedSuccess: Boolean)
    var
        InteractionLog: Record "NPR PG Interaction Log Entry";
    begin
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual(false, InteractionLog."In Progress", 'The capture interaction log should have been completed');
        _Assert.AreEqual(ExpectedSuccess, InteractionLog."Operation Success", 'Unexpected Operation Success on the capture interaction log');
        _Assert.AreEqual(not ExpectedSuccess, InteractionLog."Ran With Error", 'Unexpected Ran With Error on the capture interaction log');
    end;

    local procedure AssertCaptureLogStillInProgress(PaymentLine: Record "NPR Magento Payment Line")
    var
        InteractionLog: Record "NPR PG Interaction Log Entry";
    begin
        FindCaptureLog(PaymentLine, InteractionLog);
        _Assert.AreEqual(true, InteractionLog."In Progress", 'The capture interaction log should not have been completed');
    end;

    local procedure FindCaptureLog(PaymentLine: Record "NPR Magento Payment Line"; var InteractionLog: Record "NPR PG Interaction Log Entry")
    begin
        InteractionLog.SetRange("Payment Line System Id", PaymentLine.SystemId);
        InteractionLog.SetRange("Interaction Type", InteractionLog."Interaction Type"::Capture);
        _Assert.AreEqual(true, InteractionLog.FindFirst(), 'The capture interaction log was not found');
    end;

    local procedure MinutesToDuration(Minutes: Integer): Duration
    begin
        exit(Minutes * 60 * 1000);
    end;

    local procedure SetWebhookError(var AdyenWebhook: Record "NPR Adyen Webhook"; ProcessedDate: DateTime)
    begin
        AdyenWebhook.Status := AdyenWebhook.Status::Error;
        AdyenWebhook."Processed Date" := ProcessedDate;
        AdyenWebhook.Modify();
    end;

    local procedure AssertWebhookStatus(AdyenWebhook: Record "NPR Adyen Webhook"; ExpectedStatus: Enum "NPR Adyen Webhook Status")
    begin
        _Assert.IsTrue(AdyenWebhook.Status = ExpectedStatus, StrSubstNo('The webhook status should be %1 but it is %2', ExpectedStatus, AdyenWebhook.Status));
    end;

    local procedure PrepareEnsureWebhookFixture(IncludeEventsFilter: Text[2048]; var MerchantName: Text[80]; var ApiKeyAdded: Boolean)
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
    begin
        PrepareMerchantWithoutWebhooks(MerchantName, ApiKeyAdded);

        WebhookSetup.Init();
        WebhookSetup."Primary Key" := 0;
        WebhookSetup.ID := 'WH-ASYNC-CAPTURE-TEST';
        WebhookSetup.Type := WebhookSetup.Type::standard;
        WebhookSetup."Merchant Account" := MerchantName;
        WebhookSetup."Include Events Filter" := IncludeEventsFilter;
        WebhookSetup.Active := true;
        WebhookSetup.Insert();
    end;

    local procedure PrepareMerchantWithoutWebhooks(var MerchantName: Text[80]; var ApiKeyAdded: Boolean)
    var
        AdyenSetup: Record "NPR Adyen Setup";
        MerchantAccount: Record "NPR Adyen Merchant Account";
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        PGAdyenSetup: Record "NPR PG Adyen Setup";
    begin
        if not AdyenSetup.Get() then begin
            AdyenSetup.Init();
            AdyenSetup.Insert();
        end;
        ApiKeyAdded := not AdyenSetup.HasManagementAPIKey();
        if ApiKeyAdded then begin
            AdyenSetup.SetManagementAPIKey('test-management-api-key');
            AdyenSetup.Modify();
        end;

        // The webhooks are ensured on every merchant, so the fixture merchant has to be the only one.
        MerchantAccount.DeleteAll();
        MerchantName := 'ASYNC-CAPTURE-TEST';
        MerchantAccount.Init();
        MerchantAccount.Name := MerchantName;
        MerchantAccount.Insert();

        // Ensuring the webhooks also checks the merchant of every Adyen payment gateway, so all of them point at the fixture merchant.
        PGAdyenSetup.ModifyAll("Merchant Name", CopyStr(MerchantName, 1, MaxStrLen(PGAdyenSetup."Merchant Name")), false);

        // DeleteAll without triggers: the OnDelete trigger asks to delete the webhook in NP Pay as well.
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.DeleteAll(false);
    end;

    local procedure CountWebhookSetups(MerchantName: Text[80]): Integer
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
    begin
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        exit(WebhookSetup.Count());
    end;

    local procedure RemoveTestManagementApiKey(ApiKeyAdded: Boolean)
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        if not ApiKeyAdded then
            exit;
        // An asserterror rolls back the key written by the fixture, so the key may already be gone.
        if not AdyenSetup.Get() then
            exit;
        if AdyenSetup.HasManagementAPIKey() then
            AdyenSetup.DeleteManagementAPIKey();
    end;

    local procedure NewMerchantName(): Text[80]
    begin
        exit(CopyStr('ASYNC-' + NewPspReference(), 1, 80));
    end;

    local procedure NewWebhookId(): Code[80]
    begin
        exit(CopyStr('WH-' + NewPspReference(), 1, 80));
    end;

    local procedure GetCaptureEventCodes(var EventCodes: List of [Text[2048]])
    begin
        Clear(EventCodes);
        EventCodes.Add('CAPTURE');
        EventCodes.Add('CAPTURE_FAILED');
    end;

    local procedure InsertWebhookSetup(MerchantName: Text[80]; IncludeEventsFilter: Text[2048]; IsActive: Boolean; Password: Text[2048]; var WebhookSetup: Record "NPR Adyen Webhook Setup")
    begin
        WebhookSetup.Init();
        WebhookSetup."Primary Key" := 0;
        WebhookSetup.ID := NewWebhookId();
        WebhookSetup.Type := WebhookSetup.Type::standard;
        WebhookSetup."Merchant Account" := MerchantName;
        WebhookSetup."Include Events Filter" := IncludeEventsFilter;
        WebhookSetup."Web Service Password" := Password;
        WebhookSetup.Active := IsActive;
        WebhookSetup.Insert();
    end;

    local procedure AddBufferWebhook(var TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary; PrimaryKey: Integer; WebhookId: Code[80]; IncludeEventsFilter: Text[2048]; IsActive: Boolean)
    begin
        TempWebhookSetup.Init();
        TempWebhookSetup."Primary Key" := PrimaryKey;
        TempWebhookSetup.ID := WebhookId;
        TempWebhookSetup.Type := TempWebhookSetup.Type::standard;
        TempWebhookSetup."Include Events Filter" := IncludeEventsFilter;
        TempWebhookSetup.Active := IsActive;
        TempWebhookSetup.Insert();
    end;

    local procedure DeleteWebhookSetups(MerchantName: Text[80])
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
    begin
        // Without triggers: the OnDelete trigger asks to delete the webhook in NP Pay as well.
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.DeleteAll(false);
    end;

    local procedure TestWebhookUrl(Password: Text): Text
    begin
        exit('https://bc.example.com/BC/ODataV4/AdyenWebhook?company=CRONUS&username=webhook-user&password=' + Password);
    end;

    local procedure PrepareCraneEnsureFixture(var MerchantName: Text[80]; var ApiKeyAdded: Boolean)
    var
        AdyenSetup: Record "NPR Adyen Setup";
        AsyncAdyenPmtProcessing: Codeunit "NPR Async Adyen Pmt Processing";
    begin
        // HttpClientHandler intercepts requests only on an on-prem service tier, and only Crane asks for the credentials these tests answer.
        _Assert.IsTrue(AsyncAdyenPmtProcessing.IsCraneEnvironment(), 'The Crane webhook tests mock HTTP and must run on an on-prem service tier');

        PrepareMerchantWithoutWebhooks(MerchantName, ApiKeyAdded);

        // The Adyen calls refuse to run without a Company ID, and the Test environment selects the test management API URL.
        AdyenSetup.Get();
        AdyenSetup."Environment Type" := AdyenSetup."Environment Type"::Test;
        if AdyenSetup."Company ID" = '' then
            AdyenSetup."Company ID" := 'ASYNC-CAPTURE-TEST-COMPANY';
        AdyenSetup.Modify();

        ResetAdyenApiMock(MerchantName);
    end;

    local procedure ResetAdyenApiMock(MerchantName: Text[80])
    begin
        _MockMerchantName := MerchantName;
        _MockFirstPageStatusCode := 200;
        _MockFirstPageBody := '';
        _MockSecondPageBody := '';
        _MockUpdatableWebhookId := '';
        _MockCreateResponseBody := '';
        _MockFirstPageRequests := 0;
        _MockSecondPageRequests := 0;
        _MockCreateRequests := 0;
        _MockUpdateRequests := 0;
        _MockUnexpectedRequests := 0;
        _MockMerchantListStatusCode := 200;
        _MockMerchantListBody := '';
        _MockMerchantListRequests := 0;
    end;

    local procedure MerchantListJson(MerchantNames: List of [Text]): Text
    var
        PageObject: JsonObject;
        MerchantObject: JsonObject;
        DataArray: JsonArray;
        MerchantName: Text;
        Body: Text;
    begin
        foreach MerchantName in MerchantNames do begin
            Clear(MerchantObject);
            MerchantObject.Add('id', MerchantName);
            DataArray.Add(MerchantObject);
        end;
        PageObject.Add('pagesTotal', 1);
        PageObject.Add('data', DataArray);
        PageObject.WriteTo(Body);
        exit(Body);
    end;

    local procedure ResetEnsureWebhooksConfirm(RefreshMerchantListReply: Boolean; MerchantsNotListedReply: Boolean)
    begin
        _RefreshMerchantListReply := RefreshMerchantListReply;
        _MerchantsNotListedReply := MerchantsNotListedReply;
        _RefreshMerchantListQuestion := '';
        _MerchantsNotListedQuestion := '';
        _UnexpectedConfirmQuestion := '';
        _LastConfirmQuestion := '';
    end;

    local procedure PrepareResetCaptureDialogs(StrMenuChoice: Integer)
    begin
        _StrMenuChoice := StrMenuChoice;
        _LastStrMenuOptions := '';
        _LastStrMenuInstruction := '';
        _LastConfirmQuestion := '';
    end;

    // A new Adyen payment gateway with capture enabled whose NP Pay setup points at the given merchant.
    local procedure CreateCaptureGatewayForMerchant(MerchantNameParam: Text[80])
    var
        PGAdyenSetup: Record "NPR PG Adyen Setup";
        GatewayCode: Code[10];
    begin
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::Adyen);
        CreateAdyenCaptureSetup(GatewayCode);
        PGAdyenSetup.Get(GatewayCode);
        PGAdyenSetup."Merchant Name" := CopyStr(MerchantNameParam, 1, MaxStrLen(PGAdyenSetup."Merchant Name"));
        PGAdyenSetup.Modify();
    end;

    // Earlier cases leave the job of the capture webhooks and its monitored entry behind, so a job queue case removes them first.
    local procedure DeleteAsyncJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Adyen Async Pay ProcessJQ");
        JobQueueEntry.DeleteAll(true);

        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        MonitoredJQEntry.SetRange("Object ID to Run", Codeunit::"NPR Adyen Async Pay ProcessJQ");
        MonitoredJQEntry.DeleteAll(true);
    end;

    local procedure FindAsyncJobQueueEntry(var JobQueueEntry: Record "Job Queue Entry"): Boolean
    begin
        JobQueueEntry.Reset();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Adyen Async Pay ProcessJQ");
        exit(JobQueueEntry.FindFirst());
    end;

    local procedure CountAsyncJobQueueEntries(): Integer
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Adyen Async Pay ProcessJQ");
        exit(JobQueueEntry.Count());
    end;

    // Scheduling starts the job, so a case puts it on hold before it asserts, and never commits while it is ready.
    local procedure PutAsyncJobQueueEntriesOnHold()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Adyen Async Pay ProcessJQ");
        if JobQueueEntry.FindSet(true) then
            repeat
                if JobQueueEntry.Status <> JobQueueEntry.Status::"On Hold" then
                    JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
            until JobQueueEntry.Next() = 0;
    end;

    local procedure CountAsyncMonitoredEntries(): Integer
    var
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
    begin
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        MonitoredJQEntry.SetRange("Object ID to Run", Codeunit::"NPR Adyen Async Pay ProcessJQ");
        exit(MonitoredJQEntry.Count());
    end;

    local procedure MockCreateResponse(WebhookId: Code[80])
    begin
        _MockUpdatableWebhookId := WebhookId;
        _MockCreateResponseBody := WebhookIdJson(WebhookId);
    end;

    local procedure MockUpdateResponse(WebhookId: Code[80])
    begin
        _MockUpdatableWebhookId := WebhookId;
    end;

    local procedure WebhookListJson(PagesTotal: Integer; DataArray: JsonArray): Text
    var
        PageObject: JsonObject;
        Body: Text;
    begin
        PageObject.Add('pagesTotal', PagesTotal);
        PageObject.Add('data', DataArray);
        PageObject.WriteTo(Body);
        exit(Body);
    end;

    local procedure WebhookJson(WebhookId: Code[80]; WebhookType: Text; WebhookUrl: Text; UserName: Text; IsActive: Boolean; EventCodes: List of [Text]): JsonObject
    var
        WebhookObject: JsonObject;
        AdditionalSettingsObject: JsonObject;
        EventCodesArray: JsonArray;
        EventCode: Text;
    begin
        foreach EventCode in EventCodes do
            EventCodesArray.Add(EventCode);
        AdditionalSettingsObject.Add('includeEventCodes', EventCodesArray);

        WebhookObject.Add('id', Format(WebhookId));
        WebhookObject.Add('type', WebhookType);
        WebhookObject.Add('url', WebhookUrl);
        WebhookObject.Add('username', UserName);
        WebhookObject.Add('active', IsActive);
        WebhookObject.Add('additionalSettings', AdditionalSettingsObject);
        exit(WebhookObject);
    end;

    local procedure CurrentEnvironmentWebhookUrl(WebhookId: Code[80]): Text
    begin
        exit(CurrentEnvironmentWebhookUrlForCompany(WebhookId, CompanyName()));
    end;

    local procedure CurrentEnvironmentWebhookUrlForCompany(WebhookId: Code[80]; CompanyNameParam: Text): Text
    var
        AzureADTenant: Codeunit "Azure AD Tenant";
        EnvironmentInformation: Codeunit "Environment Information";
        TypeHelper: Codeunit "Type Helper";
        TenantId: Text;
        EnvironmentName: Text;
        UrlEncodedCompanyName: Text;
    begin
        // The import keeps a webhook only when tenant, environment and companyName in its URL are this environment's,
        // so the URL is built from the values the import compares against on the service tier the test runs on.
        TenantId := AzureADTenant.GetAadTenantId();
        EnvironmentName := EnvironmentInformation.GetEnvironmentName();
        _Assert.IsFalse(TenantId.Contains('&') or TenantId.Contains('='), 'The tenant id cannot be carried as a URL parameter on this service tier');
        _Assert.IsFalse(EnvironmentName.Contains('&') or EnvironmentName.Contains('='), 'The environment name cannot be carried as a URL parameter on this service tier');
        UrlEncodedCompanyName := CompanyNameParam;
        TypeHelper.UrlEncode(UrlEncodedCompanyName);
        exit('https://webhook.example.test?mode=cloud&tenant=' + TenantId + '&environment=' + EnvironmentName + '&companyName=' + UrlEncodedCompanyName + '&webhookRef=' + WebhookId);
    end;

    local procedure WebhooksPageJson(PagesTotal: Integer; WebhookId: Code[80]; WebhookUrl: Text): Text
    var
        PageObject: JsonObject;
        DataArray: JsonArray;
        Body: Text;
    begin
        DataArray.Add(CaptureWebhookJson(WebhookId, WebhookUrl));
        PageObject.Add('pagesTotal', PagesTotal);
        PageObject.Add('data', DataArray);
        PageObject.WriteTo(Body);
        exit(Body);
    end;

    local procedure CaptureWebhookJson(WebhookId: Code[80]; WebhookUrl: Text): JsonObject
    var
        WebhookObject: JsonObject;
        AdditionalSettingsObject: JsonObject;
        EventCodesArray: JsonArray;
    begin
        EventCodesArray.Add('CAPTURE');
        EventCodesArray.Add('CAPTURE_FAILED');
        AdditionalSettingsObject.Add('includeEventCodes', EventCodesArray);

        WebhookObject.Add('id', Format(WebhookId));
        WebhookObject.Add('type', 'standard');
        WebhookObject.Add('url', WebhookUrl);
        WebhookObject.Add('username', CraneWebUser());
        WebhookObject.Add('active', true);
        WebhookObject.Add('additionalSettings', AdditionalSettingsObject);
        exit(WebhookObject);
    end;

    local procedure WebhookIdJson(WebhookId: Code[80]): Text
    var
        WebhookObject: JsonObject;
        Body: Text;
    begin
        WebhookObject.Add('id', Format(WebhookId));
        WebhookObject.Add('type', 'standard');
        WebhookObject.WriteTo(Body);
        exit(Body);
    end;

    local procedure SetMockResponse(var Response: TestHttpResponseMessage; StatusCode: Integer; Body: Text)
    begin
        Response.HttpStatusCode := StatusCode;
        case StatusCode of
            200:
                Response.ReasonPhrase := 'OK';
            404:
                Response.ReasonPhrase := 'Not Found';
            else
                Response.ReasonPhrase := 'Internal Server Error';
        end;
        Response.Content.WriteFrom(Body);
    end;

    local procedure ReadRequestUrl(Request: TestHttpRequestMessage; var RequestUrl: Text; var QueryParameters: Dictionary of [Text, Text])
    var
        RequestQueryParameters: Dictionary of [Text, Text];
        ParamParts: List of [Text];
        Parameter: Text;
        QueryString: Text;
        ParameterName: Text;
        QuestionMarkPos: Integer;
    begin
        // Reads the parameters from QueryParameters and, should Path carry the query string as well, from Path, so the match does not depend on which of the two holds it.
        Clear(QueryParameters);
        RequestQueryParameters := Request.QueryParameters();
        foreach ParameterName in RequestQueryParameters.Keys() do
            QueryParameters.Set(ParameterName, RequestQueryParameters.Get(ParameterName));

        RequestUrl := Request.Path();
        QuestionMarkPos := RequestUrl.IndexOf('?');
        if QuestionMarkPos = 0 then
            exit;

        QueryString := RequestUrl.Substring(QuestionMarkPos + 1);
        RequestUrl := RequestUrl.Substring(1, QuestionMarkPos - 1);
        foreach Parameter in QueryString.Split('&') do begin
            ParamParts := Parameter.Split('=');
            if ParamParts.Count() = 2 then
                if not QueryParameters.ContainsKey(ParamParts.Get(1)) then
                    QueryParameters.Add(ParamParts.Get(1), ParamParts.Get(2));
        end;
    end;

    local procedure CraneWebhookUrl(Password: Text[100]) WebhookUrl: Text
    var
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        // Built by the production URL composer from a blank webhook, which is how the webhook list is matched and how a new webhook gets its URL.
        TempWebhookSetup.Init();
        TempWebhookSetup.Insert();
        AdyenManagement.SuggestAFWebServiceURL(TempWebhookSetup, CraneWebUser(), Password, CraneBaseUrl());
        WebhookUrl := TempWebhookSetup."Web Service URL";
        _Assert.AreNotEqual('', WebhookUrl, 'The webhook URL for the Crane credentials should not be blank');
    end;

    local procedure CraneWebUser(): Text[100]
    begin
        exit('webhook-user');
    end;

    local procedure CraneBaseUrl(): Text
    begin
        exit('https://bc.example.test/BC');
    end;
}

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85171 "NPR MM Subscription Audit Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        _IsInitialized: Boolean;
        _PayByLinkGetResponse: Text;
        _PayByLinkCancelResponse: Text;
        _FailPayByLinkGet: Boolean;
        _FailPayByLinkCancel: Boolean;
        _PayByLinkGetCount: Integer;
        _PayByLinkCancelCount: Integer;
        _FailGatewaySetup: Boolean;
        _MockGateway: Record "NPR MM Subs Adyen PG Setup";
        _MockLinkCreation: Boolean;
        _LinkCreationStatusCode: Integer;
        _LinkCreationCount: Integer;
        _MockTokenCharge: Boolean;
        _TokenChargeCount: Integer;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancellation')]
    procedure ManualPayByLinkCancel_PaidLinkPreservesBothRequests()
    begin
        VerifyManualPayByLinkCancellation('{"status":"completed"}', '', false, false, false, 'already been paid', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancellation')]
    procedure ManualPayByLinkCancel_StatusFailurePreservesBothRequests()
    begin
        VerifyManualPayByLinkCancellation('', '', true, false, false, 'Mock payment provider failure', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancellation')]
    procedure ManualPayByLinkCancel_PatchFailurePreservesBothRequests()
    begin
        VerifyManualPayByLinkCancellation('{"status":"active"}', '', false, true, false, 'Mock payment provider failure', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancellation')]
    procedure ManualPayByLinkCancel_PaymentRacePreservesBothRequests()
    begin
        VerifyManualPayByLinkCancellation('{"status":"active"}', '{"status":"completed"}', false, false, false, 'did not confirm', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancellation')]
    procedure ManualPayByLinkCancel_ConfirmedExpiryCancelsBothRequests()
    begin
        VerifyManualPayByLinkCancellation('{"status":"active"}', '{"status":"expired"}', false, false, true, '', false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancellation')]
    procedure ManualSubscriptionCancel_PaidLinkPreservesBothRequests()
    begin
        VerifyManualPayByLinkCancellation('{"status":"completed"}', '', false, false, false, 'already been paid', true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancellation')]
    procedure ManualSubscriptionCancel_ConfirmedExpiryCancelsBothRequests()
    begin
        VerifyManualPayByLinkCancellation('{"status":"active"}', '{"status":"expired"}', false, false, true, '', true);
    end;

    local procedure VerifyManualPayByLinkCancellation(GetResponse: Text; CancelResponse: Text; FailGet: Boolean; FailCancel: Boolean; ExpectCancelled: Boolean; ExpectedError: Text; FromSubscription: Boolean)
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
        ExpectedPatchCount: Integer;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        Mock.InitializeGateway();
        Mock.ConfigurePayByLinkMock(GetResponse, CancelResponse, FailGet, FailCancel);
        BindSubscription(Mock);
        if ExpectCancelled then
            CancelManualPayByLink(Payment, Request, FromSubscription)
        else begin
            asserterror CancelManualPayByLink(Payment, Request, FromSubscription);
            Assert.ExpectedError(ExpectedError);
        end;
        Payment.Get(Payment.RecordId);
        Request.Get(Request.RecordId);
        if ExpectCancelled then begin
            Assert.AreEqual(Payment.Status::Cancelled, Payment.Status, 'Provider-confirmed expiry must cancel the payment.');
            Assert.AreEqual(Request.Status::Cancelled, Request.Status, 'Provider-confirmed expiry must cancel the subscription request.');
        end else begin
            Assert.AreEqual(Payment.Status::Requested, Payment.Status, 'Rejected cancellation must not change the payment status.');
            Assert.AreEqual(Request.Status::Requested, Request.Status, 'Rejected cancellation must not change the subscription request status.');
            Assert.AreEqual(Request."Processing Status"::Pending, Request."Processing Status", 'Rejected cancellation must not complete the subscription request.');
        end;
        if GetResponse = '{"status":"active"}' then
            ExpectedPatchCount := 1;
        Mock.AssertPayByLinkCalls(1, ExpectedPatchCount);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    local procedure CancelManualPayByLink(var Payment: Record "NPR MM Subscr. Payment Request"; var Request: Record "NPR MM Subscr. Request"; FromSubscription: Boolean)
    var
        PaymentUtils: Codeunit "NPR MM Subs Pay Request Utils";
        RequestUtils: Codeunit "NPR MM Subscr. Request Utils";
    begin
        if FromSubscription then
            RequestUtils.SetSubscriptionRequestStatusCancelledWithConfirmation(Request, false)
        else
            PaymentUtils.SetSubscrPaymentRequestStatusCancelled(Payment, false);
    end;

    [ConfirmHandler]
    procedure ConfirmCancellation(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ConfirmCancellation')]
    procedure ManualPayByLinkCancel_UnknownCreationRequiresReconciliation()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        PaymentUtils: Codeunit "NPR MM Subs Pay Request Utils";
        Assert: Codeunit Assert;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        Payment."Pay by Link ID" := '';
        Payment."Result Code" := 'PBL_SUBMISSION_UNKNOWN';
        Payment.Modify();
        asserterror PaymentUtils.SetSubscrPaymentRequestStatusCancelled(Payment, false);
        Assert.ExpectedError('Reconcile the payment');
        Payment.Get(Payment.RecordId);
        Request.Get(Request.RecordId);
        Assert.AreEqual(Payment.Status::Requested, Payment.Status, 'An uncertain submission must not be treated as an absent link.');
        Assert.AreEqual(Request.Status::Requested, Request.Status, 'Reconciliation must not cancel the subscription request.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PendingPaidWebhook_PreventsExpiryAndRenewal()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        Webhook: Record "NPR Adyen Webhook";
        CancelJQ: Codeunit "NPR Adyen PayByLink Cancel JQ";
        RenewalJQ: Codeunit "NPR MM Subscr. Renew Req. JQ";
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
        IsPaid: Boolean;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        CreatePaidLinkWebhook(Payment, Webhook, true, 'PBL-TEST', false);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        CancelJQ.CancelExpiredLink(Payment);
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Requested, Payment.Status, 'A paid link must not be expired locally.');
        Assert.IsTrue(RenewalJQ.ResolveExistingPayByLink(Subscription), 'A pending paid webhook must block the next token attempt.');
        Assert.IsTrue(RenewalMgt.TryIsOutstandingPayByLinkPaid(Subscription."Entry No.", IsPaid), 'The local webhook is sufficient evidence.');
        Assert.IsTrue(IsPaid, 'A successful pending authorisation must be treated as paid.');
        Webhook.Get(Webhook.RecordId);
        Assert.AreEqual(Webhook.Status::New, Webhook.Status, 'Only the webhook job may process the notification.');
        Mock.AssertPayByLinkCalls(0, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PendingPaidWebhook_ReportsDuplicateOnlyOnce()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        Webhook: Record "NPR Adyen Webhook";
        LogEntry: Record "NPR MM Subs Pay Req Log Entry";
        Adyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        CreatePaidLinkWebhook(Payment, Webhook, true, 'PBL-TEST', false);
        Webhook.Status := Webhook.Status::Error;
        Webhook.Modify();
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.IsTrue(Adyen.ResolveOutstandingPayByLink(Payment, true), 'Paid evidence after a token charge must be reported.');
        Assert.IsTrue(Adyen.ResolveOutstandingPayByLink(Payment, true), 'Repeated checks must preserve the link.');
        LogEntry.SetRange("Payment Request Entry No.", Payment."Entry No.");
        LogEntry.SetFilter("Error Message", '*Reconcile the payments*');
        Assert.AreEqual(1, LogEntry.Count(), 'Duplicate evidence must only be reported once.');
        Mock.AssertPayByLinkCalls(0, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExpiredLink_StatusFailureDoesNotStopNextLink()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        NextSubscription: Record "NPR MM Subscription";
        NextRequest: Record "NPR MM Subscr. Request";
        NextPayment: Record "NPR MM Subscr. Payment Request";
        CancelJQ: Codeunit "NPR Adyen PayByLink Cancel JQ";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        CreatePendingLinkForExpiry(NextSubscription, NextRequest, NextPayment);
        Mock.InitializeGateway();
        Mock.ConfigurePayByLinkMock('', '', true, false);
        BindSubscription(Mock);
        CancelJQ.CancelExpiredLink(Payment);
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Requested, Payment.Status, 'A failed check must preserve the unresolved link.');
        Mock.ConfigurePayByLinkMock('{"status":"expired"}', '', false, false);
        CancelJQ.CancelExpiredLink(NextPayment);
        NextPayment.Get(NextPayment.RecordId);
        Assert.AreEqual(NextPayment.Status::Cancelled, NextPayment.Status, 'Processing must continue to the next expired link.');
        Mock.AssertPayByLinkCalls(1, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExpiredLink_ActiveProviderLinkIsPreserved()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        CancelJQ: Codeunit "NPR Adyen PayByLink Cancel JQ";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        Mock.InitializeGateway();
        Mock.ConfigurePayByLinkMock('{"status":"active"}', '', false, false);
        BindSubscription(Mock);
        CancelJQ.CancelExpiredLink(Payment);
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Requested, Payment.Status, 'A local timestamp must not override the provider status.');
        Mock.AssertPayByLinkCalls(1, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CancelledLinks_AllCheckedBeforeNextRenewal()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        PaidPayment: Record "NPR MM Subscr. Payment Request";
        Webhook: Record "NPR Adyen Webhook";
        RenewalJQ: Codeunit "NPR MM Subscr. Renew Req. JQ";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        Payment.Validate(Status, Payment.Status::Cancelled);
        Payment.Modify(true);
        PaidPayment := Payment;
        PaidPayment."Entry No." := 0;
        PaidPayment."Pay by Link ID" := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(PaidPayment."Pay by Link ID"));
        PaidPayment.Insert();
        CreatePaidLinkWebhook(PaidPayment, Webhook, true, 'PBL-TEST', false);
        Mock.InitializeGateway();
        Mock.ConfigurePayByLinkMock('{"status":"expired"}', '', false, false);
        BindSubscription(Mock);
        Assert.IsTrue(RenewalJQ.ResolveExistingPayByLink(Subscription), 'A later locally cancelled paid link must still block renewal.');
        Mock.AssertPayByLinkCalls(1, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaidWebhook_MustMatchSuccessMerchantAndEnvironment()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        Webhook: Record "NPR Adyen Webhook";
        CancelJQ: Codeunit "NPR Adyen PayByLink Cancel JQ";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        CreatePaidLinkWebhook(Payment, Webhook, false, 'PBL-TEST', false);
        CreatePaidLinkWebhook(Payment, Webhook, true, 'OTHER', false);
        CreatePaidLinkWebhook(Payment, Webhook, true, 'PBL-TEST', true);
        CreatePaidLinkWebhook(Payment, Webhook, true, 'PBL-TEST', false);
        Webhook."Webhook Type" := Webhook."Webhook Type"::Reconciliation;
        Webhook.Modify();
        CreatePaidLinkWebhook(Payment, Webhook, true, 'PBL-TEST', false);
        Webhook."PSP Reference" := 'OTHER-LINK';
        Webhook.Modify();
        Mock.InitializeGateway();
        Mock.ConfigurePayByLinkMock('{"status":"expired"}', '', false, false);
        BindSubscription(Mock);
        CancelJQ.CancelExpiredLink(Payment);
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Cancelled, Payment.Status, 'Unrelated webhooks must not replace a provider status check.');
        Mock.AssertPayByLinkCalls(1, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaidWebhook_LinksCanBeCheckedInReverseOrder()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        FirstPayment: Record "NPR MM Subscr. Payment Request";
        SecondPayment: Record "NPR MM Subscr. Payment Request";
        Webhook: Record "NPR Adyen Webhook";
        Adyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, FirstPayment);
        CreatePaidLinkWebhook(FirstPayment, Webhook, true, 'PBL-TEST', false);
        Clear(Subscription);
        Clear(Request);
        CreatePendingLinkForExpiry(Subscription, Request, SecondPayment);
        CreatePaidLinkWebhook(SecondPayment, Webhook, true, 'PBL-TEST', false);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.IsTrue(Adyen.ResolveOutstandingPayByLink(SecondPayment, false), 'The newer paid link must block cancellation.');
        Assert.IsTrue(Adyen.ResolveOutstandingPayByLink(FirstPayment, false), 'Checking another link must not hide an older paid webhook.');
        Mock.AssertPayByLinkCalls(0, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExpiredLink_CancellationIsLoggedOnce()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        LogEntry: Record "NPR MM Subs Pay Req Log Entry";
        CancelJQ: Codeunit "NPR Adyen PayByLink Cancel JQ";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreatePendingLinkForExpiry(Subscription, Request, Payment);
        Mock.InitializeGateway();
        Mock.ConfigurePayByLinkMock('{"status":"expired"}', '', false, false);
        BindSubscription(Mock);
        CancelJQ.CancelExpiredLink(Payment);
        CancelJQ.CancelExpiredLink(Payment);
        LogEntry.SetRange("Payment Request Entry No.", Payment."Entry No.");
        Assert.AreEqual(1, LogEntry.Count(), 'Only the actual cancellation must create a log entry.');
        LogEntry.FindFirst();
        Assert.AreEqual(Payment.Status::Cancelled, LogEntry.Status, 'The log must record the cancelled status.');
        Assert.AreEqual(LogEntry."Processing Status"::Success, LogEntry."Processing Status", 'The cancellation log must record success.');
        Assert.IsFalse(LogEntry.Manual, 'Expiry cancellation must be logged as automatic.');
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    local procedure CreatePendingLinkForExpiry(var Subscription: Record "NPR MM Subscription"; var Request: Record "NPR MM Subscr. Request"; var Payment: Record "NPR MM Subscr. Payment Request")
    begin
        CreateRenewalPayByLinkFixture(Subscription, Request, Payment);
        Subscription."Valid Until Date" := WorkDate();
        Subscription.Modify();
        Request."New Valid From Date" := WorkDate() + 1;
        Request."New Valid Until Date" := CalcDate('<1Y>', WorkDate());
        Request.Modify();
        Payment."Pay by Link ID" := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(Payment."Pay by Link ID"));
        Payment."Pay By Link Expires At" := CurrentDateTime() - 60000;
        Payment.Modify();
    end;

    local procedure CreatePaidLinkWebhook(Payment: Record "NPR MM Subscr. Payment Request"; var Webhook: Record "NPR Adyen Webhook"; Success: Boolean; Merchant: Text[80]; Live: Boolean)
    var
        Stream: OutStream;
        Notification: JsonObject;
        AdditionalData: JsonObject;
        Item: JsonObject;
        Items: JsonArray;
        Root: JsonObject;
    begin
        Clear(Webhook);
        Webhook."Event Code" := Webhook."Event Code"::AUTHORISATION;
        Webhook."Webhook Type" := Webhook."Webhook Type"::"Pay by Link";
        Webhook."PSP Reference" := Payment."Pay by Link ID";
        Webhook.Success := Success;
        Webhook."Merchant Account Name" := Merchant;
        Webhook.Live := Live;
        AdditionalData.Add('paymentLinkId', LowerCase(Payment."Pay by Link ID"));
        Notification.Add('eventCode', 'AUTHORISATION');
        Notification.Add('success', LowerCase(Format(Success, 0, 9)));
        Notification.Add('merchantAccountCode', Merchant);
        Notification.Add('additionalData', AdditionalData);
        Item.Add('NotificationRequestItem', Notification);
        Items.Add(Item);
        Root.Add('live', Live);
        Root.Add('notificationItems', Items);
        Webhook."Webhook Data".CreateOutStream(Stream, TextEncoding::UTF8);
        Root.WriteTo(Stream);
        Webhook.Insert();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_EarlyLinkFailureUnblocksNextAttempt()
    begin
        VerifyRejectedLinkCreationFailure(false, 422, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_LastLinkFailureRetainsRetry()
    begin
        VerifyRejectedLinkCreationFailure(true, 422, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_UncertainLinkDoesNotResubmit()
    begin
        VerifyRejectedLinkCreationFailure(false, 0, false);
    end;

    local procedure VerifyRejectedLinkCreationFailure(LastAttempt: Boolean; HttpStatus: Integer; ExpectedSuccess: Boolean)
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        ChildRequest: Record "NPR MM Subscr. Request";
        ChildPayment: Record "NPR MM Subscr. Payment Request";
        Membership: Record "NPR MM Membership";
        Notification: Record "NPR MM Membership Notific.";
        ProcessRenewal: Codeunit "NPR MM Subscr. Renew: Process";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateScheduledTokenFixture(Subscription, Request, Payment, LastAttempt);
        Mock.InitializeGateway();
        Mock.ConfigureLinkCreationFailure(HttpStatus);
        BindSubscription(Mock);
        Assert.AreEqual(ExpectedSuccess, ProcessRenewal.ProcessSubscriptionRequest(Request, false, false), 'Only a confirmed early link failure may finish the attempt.');
        Request.Get(Request.RecordId);
        Assert.AreEqual(ExpectedSuccess, Request."Processing Status" = Request."Processing Status"::Success, 'An uncertain or final failure must remain retryable or require reconciliation.');
        Subscription.CalcFields("Outst. Token Renew Req. Exist");
        Assert.AreEqual(not ExpectedSuccess, Subscription."Outst. Token Renew Req. Exist", 'Confirmed early link failure must not block the next schedule day.');
        Membership.Get(Subscription."Membership Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'A link creation failure must not disable auto renewal.');
        Notification.SetRange("Membership Entry No.", Membership."Entry No.");
        Notification.SetRange("Notification Trigger", Notification."Notification Trigger"::RENEWAL_FAILURE);
        Assert.IsTrue(Notification.IsEmpty(), 'Failed link creation must not send a misleading payment email.');
        ChildRequest.SetRange("Created from Entry No.", Payment."Entry No.");
        ChildRequest.FindFirst();
        ChildPayment.SetRange("Subscr. Request Entry No.", ChildRequest."Entry No.");
        ChildPayment.FindFirst();
        if HttpStatus = 0 then begin
            Assert.AreEqual(ChildPayment.Status::Error, ChildPayment.Status, 'A timeout must preserve the unresolved child.');
            Assert.IsFalse(ProcessRenewal.ProcessSubscriptionRequest(Request, false, true), 'A retry must require reconciliation instead of submitting another link.');
            Assert.IsFalse(ProcessRenewal.ProcessSubscriptionRequest(ChildRequest, false, true), 'Processing the child must not resubmit an uncertain creation either.');
            Assert.AreEqual(1, ChildRequest.Count(), 'A retry must not create another child.');
        end else
            Assert.AreEqual(ChildPayment.Status::Cancelled, ChildPayment.Status, 'A confirmed failed creation can be cancelled locally.');
        Mock.AssertCreationCalls(1, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_ManualFinalAttemptRetriesCard()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        Membership: Record "NPR MM Membership";
        Notification: Record "NPR MM Membership Notific.";
        ProcessRenewal: Codeunit "NPR MM Subscr. Renew: Process";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateScheduledTokenFixture(Subscription, Request, Payment, true);
        Payment.Status := Payment.Status::Error;
        Payment.Modify();
        Request.Status := Request.Status::"Request Error";
        Request.Modify();
        Mock.InitializeGateway();
        Mock.ConfigureTokenCharge();
        BindSubscription(Mock);
        Assert.IsTrue(ProcessRenewal.ProcessSubscriptionRequest(Request, false, true), 'Manual processing must retry the corrected gateway setup.');
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Captured, Payment.Status, 'The manual retry must actually collect the token payment.');
        Membership.Get(Subscription."Membership Entry No.");
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'Manual recovery must not disable auto renewal.');
        Notification.SetRange("Membership Entry No.", Membership."Entry No.");
        Notification.SetRange("Notification Trigger", Notification."Notification Trigger"::RENEWAL_FAILURE);
        Assert.IsTrue(Notification.IsEmpty(), 'Successful manual recovery must not notify failure.');
        Mock.AssertCreationCalls(0, 1);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_ManualRetryStillChecksPaidLink()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
        Webhook: Record "NPR Adyen Webhook";
        ProcessRenewal: Codeunit "NPR MM Subscr. Renew: Process";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateScheduledTokenFixture(Subscription, Request, Payment, true);
        Payment.Status := Payment.Status::Error;
        Payment.Modify();
        Request.Status := Request.Status::"Request Error";
        Request.Modify();
        LinkRequest := Request;
        LinkRequest."Entry No." := 0;
        LinkRequest."Created from Entry No." := Payment."Entry No.";
        LinkRequest.Status := LinkRequest.Status::Requested;
        LinkRequest.Insert();
        LinkPayment."Subscr. Request Entry No." := LinkRequest."Entry No.";
        LinkPayment.Type := LinkPayment.Type::PayByLink;
        LinkPayment.PSP := LinkPayment.PSP::Adyen;
        LinkPayment.Status := LinkPayment.Status::Requested;
        LinkPayment."Pay by Link ID" := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(LinkPayment."Pay by Link ID"));
        LinkPayment.Insert();
        CreatePaidLinkWebhook(LinkPayment, Webhook, true, 'PBL-TEST', false);
        Mock.InitializeGateway();
        Mock.ConfigureTokenCharge();
        BindSubscription(Mock);
        Assert.IsTrue(ProcessRenewal.ProcessSubscriptionRequest(Request, false, true), 'Manual processing must defer to an already paid link.');
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Error, Payment.Status, 'The original token payment must not be retried after link payment.');
        Mock.AssertPayByLinkCalls(0, 0);
        Mock.AssertCreationCalls(0, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    local procedure CreateScheduledTokenFixture(var Subscription: Record "NPR MM Subscription"; var Request: Record "NPR MM Subscr. Request"; var Payment: Record "NPR MM Subscr. Payment Request"; LastAttempt: Boolean)
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Community: Record "NPR MM Member Community";
        RecurSetup: Record "NPR MM Recur. Paym. Setup";
        ScheduleLine: Record "NPR MM Renewal Sched Line";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        PaymentMap: Record "NPR MM MembershipPmtMethodMap";
        NpPaySetup: Record "NPR Adyen Setup";
        SetupCode: Code[10];
    begin
        SetupCode := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(SetupCode));
        Community.Code := SetupCode;
        Community.Insert();
        RecurSetup.Code := SetupCode;
        RecurSetup."Subscr. Auto-Renewal On" := RecurSetup."Subscr. Auto-Renewal On"::Schedule;
        RecurSetup."Subscr Auto-Renewal Sched Code" := SetupCode;
        RecurSetup."Max. Pay. Process Try Count" := 1;
        RecurSetup.Insert();
        MembershipSetup.Code := SetupCode;
        MembershipSetup."Community Code" := SetupCode;
        MembershipSetup."Recurring Payment Code" := SetupCode;
        MembershipSetup."Create Renewal Failure Notif" := true;
        MembershipSetup.Insert();
        Membership."Membership Code" := SetupCode;
        Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
        Membership.Insert();
        CreateMemberPaymentMethod(MemberPaymentMethod);
        MemberPaymentMethod."Shopper Reference" := 'MOCK-SHOPPER';
        MemberPaymentMethod.Modify();
        CreateMembershipPmtMethodMap(PaymentMap, MemberPaymentMethod, Membership);
        Subscription."Membership Entry No." := Membership."Entry No.";
        Subscription."Membership Code" := SetupCode;
        Subscription."Valid Until Date" := WorkDate();
        Subscription."Auto-Renew" := Subscription."Auto-Renew"::YES_INTERNAL;
        Subscription.Insert();
        NotificationSetup.Code := SetupCode;
        NotificationSetup."Community Code" := SetupCode;
        NotificationSetup."Membership Code" := SetupCode;
        NotificationSetup.Type := NotificationSetup.Type::RENEWAL_FAILURE;
        NotificationSetup.Insert();
        ScheduleLine."Schedule Code" := SetupCode;
        ScheduleLine."Date Formula Duration (Days)" := 1;
        ScheduleLine.Insert();
        Request."Renew Schedule Id" := ScheduleLine.SystemId;
        if not LastAttempt then begin
            Clear(ScheduleLine);
            ScheduleLine."Schedule Code" := SetupCode;
            ScheduleLine."Date Formula Duration (Days)" := 2;
            ScheduleLine.Insert();
        end;
        Request.Type := Request.Type::Renew;
        Request.Status := Request.Status::Rejected;
        Request."Membership Code" := SetupCode;
        Request."Subscription Entry No." := Subscription."Entry No.";
        Request."New Valid From Date" := WorkDate() + 1;
        Request."New Valid Until Date" := CalcDate('<1Y>', WorkDate());
        Request.Insert();
        Payment."Subscr. Request Entry No." := Request."Entry No.";
        Payment.Type := Payment.Type::Payment;
        Payment.PSP := Payment.PSP::Adyen;
        Payment.Status := Payment.Status::Rejected;
        Payment."Result Code" := 'Refused';
        Payment."Currency Code" := 'EUR';
        Payment.Amount := 10;
        Payment.Insert();
        if not NpPaySetup.Get() then
            NpPaySetup.Insert();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalDecline_TechnicalErrorIsCaseInsensitive()
    var
        PaymentRequest: Record "NPR MM Subscr. Payment Request" temporary;
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        Assert: Codeunit Assert;
        ResultCode: Text;
    begin
        PaymentRequest.PSP := PaymentRequest.PSP::Adyen;
        foreach ResultCode in 'Error,ERROR,error'.Split(',') do begin
            PaymentRequest."Result Code" := CopyStr(ResultCode, 1, MaxStrLen(PaymentRequest."Result Code"));
            Assert.IsFalse(RenewalMgt.IsCustomerActionableDecline(PaymentRequest), 'Technical errors must not depend on result-code casing.');
        end;
        PaymentRequest."Result Code" := 'Refused';
        Assert.IsTrue(RenewalMgt.IsCustomerActionableDecline(PaymentRequest), 'A customer decline must remain actionable.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_UnhandledProviderDefersRenewal()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        PaymentRequest: Record "NPR MM Subscr. Payment Request";
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        Assert: Codeunit Assert;
        IsPaid: Boolean;
    begin
        CreateRenewalPayByLinkFixture(Subscription, Request, PaymentRequest);
        PaymentRequest.PSP := Enum::"NPR MM Subscription PSP".FromInteger(0);
        PaymentRequest.Modify();
        Commit();
        asserterror RenewalMgt.ResolveOutstandingPayByLink(PaymentRequest);
        Assert.ExpectedError('does not support checking outstanding payment links');
        PaymentRequest.Get(PaymentRequest.RecordId);
        asserterror RenewalMgt.TryIsOutstandingPayByLinkPaid(Subscription."Entry No.", IsPaid);
        Assert.ExpectedError('does not support checking outstanding payment links');
        Assert.IsFalse(RenewalMgt.IsCustomerActionableDecline(PaymentRequest), 'An unclassified provider failure must not notify on every attempt.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_NoOutstandingLinkIsKnownUnpaid()
    var
        Subscription: Record "NPR MM Subscription";
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        Assert: Codeunit Assert;
        IsPaid: Boolean;
    begin
        Subscription.Insert();
        IsPaid := true;
        Assert.IsTrue(RenewalMgt.TryIsOutstandingPayByLinkPaid(Subscription."Entry No.", IsPaid), 'No link is a known result.');
        Assert.IsFalse(IsPaid, 'The output must be reset when no link exists.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_PaidLinkIsNotCancelled()
    begin
        VerifyPayByLinkResolution('{"status":"completed"}', '', false, false, true, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_ActiveLinkIsCancelled()
    begin
        VerifyPayByLinkResolution('{"status":"active"}', '{"status":"expired"}', false, false, false, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_ExpiredLinkNeedsNoPatch()
    begin
        VerifyPayByLinkResolution('{"status":"expired"}', '', false, false, false, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_GetFailurePreservesOutstandingLink()
    begin
        VerifyPayByLinkResolution('', '', true, false, true, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_InvalidStatusPreservesOutstandingLink()
    begin
        VerifyPayByLinkResolution('{"status":{}}', '', false, false, true, 0);
        VerifyPayByLinkResolution('{}', '', false, false, true, 0);
        VerifyPayByLinkResolution('{"status":"unrecognized"}', '', false, false, true, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_PendingPaymentDefersRenewal()
    begin
        VerifyPayByLinkResolution('{"status":"paymentPending"}', '', false, false, true, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_CancelFailurePreservesOutstandingLink()
    begin
        VerifyPayByLinkResolution('{"status":"active"}', '', false, true, true, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_UnconfirmedCancellationPreservesOutstandingLink()
    begin
        VerifyPayByLinkResolution('{"status":"active"}', '', false, false, true, 1);
        VerifyPayByLinkResolution('{"status":"active"}', '{}', false, false, true, 1);
        VerifyPayByLinkResolution('{"status":"active"}', '{"status":"completed"}', false, false, true, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_UnknownLinkStatusRemainsPending()
    begin
        VerifyRenewalErrorPaidCheck(Enum::"NPR MM Subscr. Request Type"::Renew, false, '', true, false, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_PaidLinkCompletesOnlyParentRequest()
    begin
        VerifyRenewalErrorPaidCheck(Enum::"NPR MM Subscr. Request Type"::Renew, false, '{"status":"completed"}', false, true, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_RefundsDoNotCheckRenewalLinks()
    begin
        VerifyRenewalErrorPaidCheck(Enum::"NPR MM Subscr. Request Type"::Regret, false, '{"status":"completed"}', false, false, 0);
        VerifyRenewalErrorPaidCheck(Enum::"NPR MM Subscr. Request Type"::"Partial Regret", false, '{"status":"completed"}', false, false, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_ChildRequestDoesNotCheckRenewalLinks()
    begin
        VerifyRenewalErrorPaidCheck(Enum::"NPR MM Subscr. Request Type"::Renew, true, '{"status":"completed"}', false, false, 0);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_ExpiryDateDoesNotCheckPaidLink()
    begin
        VerifyRenewalErrorPaidCheck(Enum::"NPR MM Subscr. Request Type"::Renew, false, '{"status":"completed"}', false, false, 0,
            Enum::"NPR MM Subscr. Auto-Renewal"::"Expiry Date");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_NextStartDateDoesNotCheckPaidLink()
    begin
        VerifyRenewalErrorPaidCheck(Enum::"NPR MM Subscr. Request Type"::Renew, false, '{"status":"completed"}', false, false, 0,
            Enum::"NPR MM Subscr. Auto-Renewal"::"Next Start Date");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_ExpiryDateDoesNotRunNewCleanup()
    begin
        VerifyPayByLinkCleanupMode(Enum::"NPR MM Subscr. Auto-Renewal"::"Expiry Date");
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_NextStartDateDoesNotRunNewCleanup()
    begin
        VerifyPayByLinkCleanupMode(Enum::"NPR MM Subscr. Auto-Renewal"::"Next Start Date");
    end;

    local procedure VerifyPayByLinkCleanupMode(RenewalMode: Enum "NPR MM Subscr. Auto-Renewal")
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
        TokenRequest: Record "NPR MM Subscr. Request";
        TokenPayment: Record "NPR MM Subscr. Payment Request";
        PaymentJQ: Codeunit "NPR MM Subscr. Pay Req Proc JQ";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateRenewalPayByLinkFixture(Subscription, LinkRequest, LinkPayment);
        SetPayByLinkFixtureMode(Subscription, RenewalMode);
        TokenRequest."Subscription Entry No." := Subscription."Entry No.";
        TokenRequest.Type := TokenRequest.Type::Renew;
        TokenRequest."Renew Schedule Id" := CreateGuid();
        TokenRequest.Insert();
        TokenPayment."Subscr. Request Entry No." := TokenRequest."Entry No.";
        TokenPayment.Type := TokenPayment.Type::Payment;
        TokenPayment.Status := TokenPayment.Status::Captured;
        TokenPayment.PSP := TokenPayment.PSP::Adyen;
        TokenPayment.Insert();
        Mock.ConfigurePayByLinkMock('{"status":"active"}', '{"status":"expired"}', false, false);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        PaymentJQ.RetryPayByLinkCancellation();
        LinkPayment.Get(LinkPayment.RecordId);
        Assert.AreEqual(LinkPayment.Status::Requested, LinkPayment.Status, 'The new cleanup must not alter non-scheduled renewal links.');
        Mock.AssertPayByLinkCalls(0, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_CleanupRetriesAfterTokenSuccess()
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
        TokenRequest: Record "NPR MM Subscr. Request";
        TokenPayment: Record "NPR MM Subscr. Payment Request";
        PaymentJQ: Codeunit "NPR MM Subscr. Pay Req Proc JQ";
        RequestUtils: Codeunit "NPR MM Subscr. Request Utils";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateRenewalPayByLinkFixture(Subscription, LinkRequest, LinkPayment);
        TokenRequest."Subscription Entry No." := Subscription."Entry No.";
        TokenRequest.Type := TokenRequest.Type::Renew;
        TokenRequest."New Valid From Date" := WorkDate();
        TokenRequest.Insert();
        TokenPayment."Subscr. Request Entry No." := TokenRequest."Entry No.";
        TokenPayment.Type := TokenPayment.Type::Payment;
        TokenPayment.Status := TokenPayment.Status::Captured;
        TokenPayment.PSP := TokenPayment.PSP::Adyen;
        TokenPayment.Insert();
        Assert.IsFalse(RequestUtils.HasCapturedTokenPayment(LinkPayment), 'A payment for another period must not cancel this link.');
        TokenRequest."New Valid From Date" := LinkRequest."New Valid From Date";
        TokenRequest.Modify();
        Assert.IsTrue(RequestUtils.HasCapturedTokenPayment(LinkPayment), 'The matching captured payment must schedule cleanup.');

        Mock.ConfigurePayByLinkMock('{"status":"active"}', '', false, true);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        PaymentJQ.RetryPayByLinkCancellation();
        LinkPayment.Get(LinkPayment.RecordId);
        Assert.AreEqual(LinkPayment.Status::Requested, LinkPayment.Status, 'Failed cleanup must remain discoverable.');
        Mock.ConfigurePayByLinkMock('{"status":"active"}', '{"status":"expired"}', false, false);
        PaymentJQ.RetryPayByLinkCancellation();
        LinkPayment.Get(LinkPayment.RecordId);
        Assert.AreEqual(LinkPayment.Status::Cancelled, LinkPayment.Status, 'A later cleanup run must cancel the link without another token charge.');
        TokenPayment.Get(TokenPayment.RecordId);
        Assert.AreEqual(TokenPayment.Status::Captured, TokenPayment.Status, 'Cleanup must preserve the successful payment.');
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_LastAttemptUsesFallbackReason()
    begin
        VerifyScheduledRenewalError(true, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_EarlierAttemptDoesNotTerminate()
    begin
        VerifyScheduledRenewalError(true, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_MissingScheduleKeepsRetryBehaviour()
    begin
        VerifyScheduledRenewalError(false, false);
    end;

    local procedure VerifyScheduledRenewalError(HasSchedule: Boolean; IsLastAttempt: Boolean)
    begin
        VerifyRenewalFailure(HasSchedule, IsLastAttempt, false, 'Error', true, false, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_PaidLinkWaitsForWebhook()
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        Request: Record "NPR MM Subscr. Request";
        ProcessRenewal: Codeunit "NPR MM Subs Try Renew Process";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateRenewalPayByLinkFixture(Subscription, LinkRequest, Payment);
        Request."Subscription Entry No." := Subscription."Entry No.";
        Request.Type := Request.Type::Renew;
        Request.Status := Request.Status::Rejected;
        Request.Insert();
        Mock.ConfigurePayByLinkMock('{"status":"completed"}', '', false, false);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Commit();
        Assert.IsTrue(ProcessRenewal.Run(Request), 'A paid link must bypass rejected-payment processing.');
        Request.Get(Request.RecordId);
        Assert.AreEqual(Request."Processing Status"::Success, Request."Processing Status", 'The rejected parent must stop processing.');
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Requested, Payment.Status, 'The webhook must retain ownership of the paid link.');
        Subscription.Get(Subscription.RecordId);
        Assert.AreNotEqual(Subscription."Termination Reason"::FORCED_TERMINATION, Subscription."Termination Reason", 'A paid member must not be terminated.');
        Mock.AssertPayByLinkCalls(1, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ScheduledPayByLink_RequiresTokenPaymentAndSchedule()
    var
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request" temporary;
        RecurSetup: Record "NPR MM Recur. Paym. Setup" temporary;
        Adyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
        Assert: Codeunit Assert;
    begin
        RecurSetup."Subscr. Auto-Renewal On" := RecurSetup."Subscr. Auto-Renewal On"::Schedule;
        Payment.Type := Payment.Type::PayByLink;
        Assert.IsFalse(Adyen.ExecutePayByLinkFunctionality(Payment, RecurSetup), 'Child payments must not issue another link.');
        Request.Insert();
        Payment."Subscr. Request Entry No." := Request."Entry No.";
        Payment.Type := Payment.Type::Payment;
        Payment.PSP := Payment.PSP::Adyen;
        Payment."Result Code" := 'Refused';
        Assert.IsFalse(Adyen.ExecutePayByLinkFunctionality(Payment, RecurSetup), 'A token request without a schedule must not issue a link.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ScheduledRenewal_OnlyOutstandingParentsBlockNextAttempt()
    var
        Subscription: Record "NPR MM Subscription";
        ChildRequest: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        ParentRequest: Record "NPR MM Subscr. Request";
        Assert: Codeunit Assert;
    begin
        CreateRenewalPayByLinkFixture(Subscription, ChildRequest, Payment);
        Subscription.CalcFields("Outst. Token Renew Req. Exist");
        Assert.IsFalse(Subscription."Outst. Token Renew Req. Exist", 'An outstanding child link must not block a later scheduled attempt.');
        ParentRequest.Type := ParentRequest.Type::Renew;
        ParentRequest."Subscription Entry No." := Subscription."Entry No.";
        ParentRequest.Insert();
        Subscription.CalcFields("Outst. Token Renew Req. Exist");
        Assert.IsTrue(Subscription."Outst. Token Renew Req. Exist", 'A pending parent must block a duplicate token attempt.');
        ParentRequest."Processing Status" := ParentRequest."Processing Status"::Error;
        ParentRequest.Modify();
        Subscription.CalcFields("Outst. Token Renew Req. Exist");
        Assert.IsTrue(Subscription."Outst. Token Renew Req. Exist", 'An error parent must continue blocking a duplicate charge.');
        ParentRequest."Processing Status" := ParentRequest."Processing Status"::Success;
        ParentRequest.Modify();
        Subscription.CalcFields("Outst. Token Renew Req. Exist");
        Assert.IsFalse(Subscription."Outst. Token Renew Req. Exist", 'A completed parent must allow the next schedule date.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_MissingIdWithoutUrlCancelsLocally()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
        IsPaid: Boolean;
    begin
        CreateRenewalPayByLinkFixture(Subscription, Request, Payment);
        Payment."Pay by Link ID" := '';
        Payment.Modify();
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.IsTrue(RenewalMgt.TryIsOutstandingPayByLinkPaid(Subscription."Entry No.", IsPaid), 'An empty link must not make an invalid HTTP request.');
        Assert.IsFalse(IsPaid, 'No link is unpaid.');
        Assert.IsFalse(RenewalMgt.ResolveOutstandingPayByLink(Payment), 'An empty link must not block renewal.');
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Cancelled, Payment.Status, 'The empty link must be cancelled locally.');
        Mock.AssertPayByLinkCalls(0, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_MissingIdWithUrlRequiresReconciliation()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
        IsPaid: Boolean;
        ErrorMessage: Text;
    begin
        CreateRenewalPayByLinkFixture(Subscription, Request, Payment);
        Payment."Pay by Link ID" := '';
        Payment."Pay by Link URL" := 'https://example.test/payment';
        Payment."Pay By Link Expires At" := CurrentDateTime() - 1000;
        Payment.Modify();
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.IsFalse(RenewalMgt.TryIsOutstandingPayByLinkPaid(Subscription."Entry No.", IsPaid, ErrorMessage), 'Expiry alone cannot prove that a link was not paid.');
        Assert.IsTrue(ErrorMessage.Contains('Reconcile'), 'A missing ID needs an actionable diagnostic.');
        asserterror RenewalMgt.ResolveOutstandingPayByLink(Payment);
        Assert.ExpectedError('Reconcile');
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Requested, Payment.Status, 'The unresolved link must remain visible.');
        Mock.AssertPayByLinkCalls(0, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_SetupAndHttpErrorsKeepOriginalDiagnostic()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
        IsPaid: Boolean;
        ErrorMessage: Text;
    begin
        CreateRenewalPayByLinkFixture(Subscription, Request, Payment);
        Mock.FailGatewaySetup();
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.IsFalse(RenewalMgt.TryIsOutstandingPayByLinkPaid(Subscription."Entry No.", IsPaid, ErrorMessage), 'Missing setup must fail.');
        Assert.IsTrue(ErrorMessage.Contains('Mock payment gateway setup is missing'), 'The original setup error must survive the outer try method.');
        Mock.AssertPayByLinkCalls(0, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
        Clear(Mock);
        Mock.ConfigurePayByLinkMock('', '', true, false);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.IsFalse(RenewalMgt.TryIsOutstandingPayByLinkPaid(Subscription."Entry No.", IsPaid, ErrorMessage), 'HTTP failure must fail.');
        Assert.IsTrue(ErrorMessage.Contains('Mock payment provider failure'), 'The original HTTP error must survive the outer try method.');
        Mock.AssertPayByLinkCalls(1, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_DuplicatePaymentIsReportedOnlyOnce()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        LogEntry: Record "NPR MM Subs Pay Req Log Entry";
        Adyen: Codeunit "NPR MM Subscr.Pmt.: Adyen";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateRenewalPayByLinkFixture(Subscription, Request, Payment);
        Mock.ConfigurePayByLinkMock('{"status":"completed"}', '', false, false);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.IsTrue(Adyen.ResolveOutstandingPayByLink(Payment, true), 'A completed link must not be cancelled.');
        Assert.IsTrue(Adyen.ResolveOutstandingPayByLink(Payment, true), 'A repeated check must preserve the completed link.');
        LogEntry.SetRange("Payment Request Entry No.", Payment."Entry No.");
        LogEntry.SetFilter("Error Message", '*Reconcile the payments*');
        Assert.AreEqual(1, LogEntry.Count(), 'Only the first observed duplicate payment may report the incident.');
        Mock.AssertPayByLinkCalls(2, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_StatusFailureEscalatesAndBacksOff()
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        Request: Record "NPR MM Subscr. Request";
        AdyenSetup: Record "NPR Adyen Setup";
        ProcessRenewal: Codeunit "NPR MM Subscr. Renew: Process";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
        ExpectedTryCount: Integer;
    begin
        CreateRenewalPayByLinkFixture(Subscription, LinkRequest, Payment);
        if not AdyenSetup.Get() then
            AdyenSetup.Insert();
        ExpectedTryCount := AdyenSetup."Max Sub Req Process Try Count";
        if ExpectedTryCount < 1 then
            ExpectedTryCount := 1;
        Request."Subscription Entry No." := Subscription."Entry No.";
        Request.Type := Request.Type::Renew;
        Request.Status := Request.Status::Rejected;
        Request."Process Try Count" := ExpectedTryCount - 1;
        Request.Insert();
        Mock.ConfigurePayByLinkMock('', '', true, false);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.IsFalse(ProcessRenewal.ProcessSubscriptionRequest(Request, false, false), 'Failed status checks must reach the processing error handler.');
        Request.Get(Request.RecordId);
        Assert.AreEqual(Request."Processing Status"::Error, Request."Processing Status", 'Exhausted processing retries must escalate.');
        Assert.IsFalse(ProcessRenewal.ProcessSubscriptionRequest(Request, false, false), 'Automatic error retries must back off.');
        Request.Get(Request.RecordId);
        Assert.AreEqual(ExpectedTryCount, Request."Process Try Count", 'Backoff must not consume another attempt.');
        Mock.AssertPayByLinkCalls(1, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_ScheduledDeclineNotifiesEachAttempt()
    begin
        VerifyRenewalFailure(true, false, true, 'Refused', true, false, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
        VerifyRenewalFailure(true, true, true, 'Refused', true, false, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_TechnicalFailureOnlyNotifiesLastAttempt()
    begin
        VerifyRenewalFailure(true, false, true, 'Error', true, false, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
        VerifyRenewalFailure(true, true, true, 'Error', true, false, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_NotificationSetupIsRespected()
    begin
        VerifyRenewalFailure(true, false, true, 'Refused', false, false, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
        VerifyRenewalFailure(true, true, true, 'Error', false, false, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_ChildDoesNotNotifyOrTerminate()
    begin
        VerifyRenewalFailure(false, false, true, 'Refused', true, true, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_NonScheduleRetainsTerminalNotification()
    begin
        VerifyRenewalFailure(false, true, true, 'Refused', true, false, Enum::"NPR MM Subscr. Auto-Renewal"::"Expiry Date");
        VerifyRenewalFailure(false, true, true, 'Error', true, false, Enum::"NPR MM Subscr. Auto-Renewal"::"Next Start Date");
    end;

    local procedure VerifyRenewalFailure(HasSchedule: Boolean; IsLastAttempt: Boolean; IsRejected: Boolean; ResultCode: Text[50]; NotificationsEnabled: Boolean; IsChild: Boolean; RenewalMode: Enum "NPR MM Subscr. Auto-Renewal")
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Community: Record "NPR MM Member Community";
        RecurSetup: Record "NPR MM Recur. Paym. Setup";
        ScheduleLine: Record "NPR MM Renewal Sched Line";
        NotificationSetup: Record "NPR MM Member Notific. Setup";
        Notification: Record "NPR MM Membership Notific.";
        ProcessRenewal: Codeunit "NPR MM Subs Try Renew Process";
        Assert: Codeunit Assert;
        SetupCode: Code[10];
        Payment: Record "NPR MM Subscr. Payment Request";
        ChildRequest: Record "NPR MM Subscr. Request";
        ChildPayment: Record "NPR MM Subscr. Payment Request";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        ExpectedNotification: Boolean;
    begin
        SetupCode := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(SetupCode));
        Community.Code := SetupCode;
        Community.Insert();
        RecurSetup.Code := SetupCode;
        RecurSetup."Subscr. Auto-Renewal On" := RenewalMode;
        RecurSetup."Subscr Auto-Renewal Sched Code" := SetupCode;
        RecurSetup.Insert();
        MembershipSetup.Code := SetupCode;
        MembershipSetup."Community Code" := SetupCode;
        MembershipSetup."Recurring Payment Code" := SetupCode;
        MembershipSetup."Create Renewal Failure Notif" := NotificationsEnabled;
        MembershipSetup.Insert();
        Membership."Membership Code" := SetupCode;
        Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
        Membership.Insert();
        Subscription."Membership Entry No." := Membership."Entry No.";
        Subscription."Membership Code" := SetupCode;
        Subscription.Insert();
        NotificationSetup.Code := SetupCode;
        NotificationSetup."Community Code" := SetupCode;
        NotificationSetup."Membership Code" := SetupCode;
        NotificationSetup.Type := NotificationSetup.Type::RENEWAL_FAILURE;
        NotificationSetup.Insert();

        if HasSchedule then begin
            ScheduleLine."Schedule Code" := SetupCode;
            ScheduleLine."Date Formula Duration (Days)" := 1;
            ScheduleLine.Insert();
            Request."Renew Schedule Id" := ScheduleLine.SystemId;
            if not IsLastAttempt then begin
                Clear(ScheduleLine);
                ScheduleLine."Schedule Code" := SetupCode;
                ScheduleLine."Date Formula Duration (Days)" := 2;
                ScheduleLine.Insert();
            end;
        end;
        Request.Type := Request.Type::Renew;
        Request.Status := Request.Status::"Request Error";
        if IsRejected then
            Request.Status := Request.Status::Rejected;
        if IsChild then
            Request."Created from Entry No." := 1;
        Request."Subscription Entry No." := Subscription."Entry No.";
        Request.Insert();
        if IsRejected then begin
            Payment."Subscr. Request Entry No." := Request."Entry No.";
            Payment.Type := Payment.Type::Payment;
            Payment.PSP := Payment.PSP::Adyen;
            Payment.Status := Payment.Status::Rejected;
            Payment."Result Code" := ResultCode;
            Payment."Rejected Reason Description" := ResultCode;
            Payment.Insert();
            ChildRequest."Subscription Entry No." := Subscription."Entry No.";
            ChildRequest."Created from Entry No." := Payment."Entry No.";
            ChildRequest.Type := ChildRequest.Type::Renew;
            ChildRequest.Insert();
            ChildPayment."Subscr. Request Entry No." := ChildRequest."Entry No.";
            ChildPayment.Type := ChildPayment.Type::PayByLink;
            ChildPayment."Pay by Link URL" := 'https://example.test/payment';
            ChildPayment.Insert();
        end;
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Commit();
        Assert.IsTrue(ProcessRenewal.Run(Request), 'Request-error handling must not fail without an error payment record or a schedule ID.');
        Request.Get(Request.RecordId);
        Membership.Get(Membership.RecordId);
        Assert.AreEqual(IsRejected or IsLastAttempt, Request."Processing Status" = Request."Processing Status"::Success, 'Rejected attempts finish; only the final request-error attempt may give up.');
        Assert.AreEqual(IsLastAttempt and not IsChild, Membership."Auto-Renew" = Membership."Auto-Renew"::NO, 'Earlier attempts and children must preserve auto-renewal.');
        Notification.SetRange("Membership Entry No.", Membership."Entry No.");
        Notification.SetRange("Notification Trigger", Notification."Notification Trigger"::RENEWAL_FAILURE);
        ExpectedNotification := NotificationsEnabled and not IsChild and (IsLastAttempt or (IsRejected and (ResultCode <> 'Error')));
        if ExpectedNotification then begin
            Assert.IsTrue(Notification.FindFirst(), 'The final attempt must notify even without a payment error record.');
            Assert.AreNotEqual('', Notification."Rejected Reason Description", 'The final notification must have an explicit fallback reason.');
            Assert.AreEqual(ChildPayment."Pay by Link URL", Notification."Pay by Link URL", 'The notification must use the existing child payment link.');
            Assert.AreEqual(1, Notification.Count(), 'The final attempt must create exactly one notification.');
        end else
            Assert.IsTrue(Notification.IsEmpty(), 'Earlier technical failures, children and disabled notifications must remain silent.');
        Subscription.Get(Subscription.RecordId);
        if IsChild or (not IsLastAttempt and (ResultCode = 'Error')) then
            Assert.AreNotEqual(Subscription."Termination Reason"::FORCED_TERMINATION, Subscription."Termination Reason", 'A technical early failure or child must not terminate the subscription.');
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    local procedure VerifyPayByLinkResolution(GetResponse: Text; CancelResponse: Text; FailGet: Boolean; FailCancel: Boolean; ExpectedSkip: Boolean; ExpectedCancelCount: Integer)
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        PaymentRequest: Record "NPR MM Subscr. Payment Request";
        LogEntry: Record "NPR MM Subs Pay Req Log Entry";
        RenewalMgt: Codeunit "NPR MM Subs. Renewal Mgt.";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateRenewalPayByLinkFixture(Subscription, Request, PaymentRequest);
        Mock.ConfigurePayByLinkMock(GetResponse, CancelResponse, FailGet, FailCancel);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Assert.AreEqual(ExpectedSkip, RenewalMgt.ResolveOutstandingPayByLink(PaymentRequest), 'Unexpected renewal decision.');
        PaymentRequest.Get(PaymentRequest.RecordId);
        if ExpectedSkip then
            Assert.AreEqual(PaymentRequest.Status::Requested, PaymentRequest.Status, 'An unresolved link must remain discoverable.')
        else
            Assert.AreEqual(PaymentRequest.Status::Cancelled, PaymentRequest.Status, 'Confirmed expiry must cancel the local link.');
        Mock.AssertPayByLinkCalls(1, ExpectedCancelCount);
        LogEntry.SetRange("Payment Request Entry No.", PaymentRequest."Entry No.");
        LogEntry.SetRange(Status, PaymentRequest.Status::Cancelled);
        LogEntry.SetRange("Processing Status", LogEntry."Processing Status"::Success);
        if ExpectedSkip then
            Assert.IsTrue(LogEntry.IsEmpty(), 'A paid or unresolved link must not have a successful cancellation log.')
        else
            Assert.AreEqual(1, LogEntry.Count(), 'A confirmed cancellation must have exactly one success log.');
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    local procedure VerifyRenewalErrorPaidCheck(RequestType: Enum "NPR MM Subscr. Request Type"; IsChild: Boolean; GetResponse: Text; FailGet: Boolean; ExpectedSuccess: Boolean; ExpectedGetCount: Integer)
    begin
        VerifyRenewalErrorPaidCheck(RequestType, IsChild, GetResponse, FailGet, ExpectedSuccess, ExpectedGetCount, Enum::"NPR MM Subscr. Auto-Renewal"::Schedule);
    end;

    local procedure VerifyRenewalErrorPaidCheck(RequestType: Enum "NPR MM Subscr. Request Type"; IsChild: Boolean; GetResponse: Text; FailGet: Boolean; ExpectedSuccess: Boolean; ExpectedGetCount: Integer; RenewalMode: Enum "NPR MM Subscr. Auto-Renewal")
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
        Request: Record "NPR MM Subscr. Request";
        ProcessRenewal: Codeunit "NPR MM Subs Try Renew Process";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateRenewalPayByLinkFixture(Subscription, LinkRequest, LinkPayment);
        SetPayByLinkFixtureMode(Subscription, RenewalMode);
        Request."Subscription Entry No." := Subscription."Entry No.";
        Request.Type := RequestType;
        Request.Status := Request.Status::"Request Error";
        if RenewalMode <> RenewalMode::Schedule then
            Request."Renew Schedule Id" := CreateGuid();
        if IsChild then
            Request."Created from Entry No." := LinkPayment."Entry No.";
        Request.Insert();
        Mock.ConfigurePayByLinkMock(GetResponse, '', FailGet, false);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        Commit();
        Assert.AreEqual(not FailGet, ProcessRenewal.Run(Request), 'A failed status check must propagate into the processing retry machinery.');
        Request.Get(Request.RecordId);
        Assert.AreEqual(ExpectedSuccess, Request."Processing Status" = Request."Processing Status"::Success, 'Only a paid parent renewal may be marked processed.');
        LinkPayment.Get(LinkPayment.RecordId);
        Assert.AreEqual(LinkPayment.Status::Requested, LinkPayment.Status, 'The payment webhook must retain ownership of the paid link.');
        Mock.AssertPayByLinkCalls(ExpectedGetCount, 0);
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ScheduledRenewal_CapturedLinkWaitsForRenewalProcessing()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        Requests: Record "NPR MM Subscr. Request";
        RenewalJQ: Codeunit "NPR MM Subscr. Renew Req. JQ";
        CreateRenewal: Codeunit "NPR MM Subscr. Renew: Request";
        Assert: Codeunit Assert;
    begin
        CreateCapturedPayByLinkFixture(Subscription, Request, Payment);
        Assert.IsTrue(RenewalJQ.ResolveExistingPayByLink(Subscription), 'A captured link must block the next scheduled attempt while its renewal is pending.');
        CreateRenewal.SetSkipProcessSubscriptionCheck(true);
        CreateRenewal.Run(Subscription);
        Request.Status := Request.Status::Confirmed;
        Request."Processing Status" := Request."Processing Status"::Error;
        Request.Modify();
        Assert.IsTrue(RenewalJQ.ResolveExistingPayByLink(Subscription), 'A confirmed child with a processing error must still block another charge.');
        CreateRenewal.SetSkipProcessSubscriptionCheck(true);
        CreateRenewal.Run(Subscription);
        Requests.SetRange("Subscription Entry No.", Subscription."Entry No.");
        Assert.AreEqual(1, Requests.Count(), 'Creation must leave the existing child as the only renewal request.');
        Payment.Get(Payment.RecordId);
        Assert.AreEqual(Payment.Status::Captured, Payment.Status, 'The captured payment must remain untouched.');
        Request.Get(Request.RecordId);
        Assert.AreEqual(Request."Processing Status"::Error, Request."Processing Status", 'Only the processing job may finish the paid renewal.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ManualRenewal_CapturedPendingLinkReportsExistingRequest()
    begin
        VerifyManualCapturedLinkReportsExistingRequest(Enum::"NPR MM Subs Req Proc Status"::Pending);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ManualRenewal_CapturedErrorLinkReportsExistingRequest()
    begin
        VerifyManualCapturedLinkReportsExistingRequest(Enum::"NPR MM Subs Req Proc Status"::Error);
    end;

    local procedure VerifyManualCapturedLinkReportsExistingRequest(ProcessingStatus: Enum "NPR MM Subs Req Proc Status")
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        CreateRenewal: Codeunit "NPR MM Subscr. Renew: Request";
        Assert: Codeunit Assert;
    begin
        CreateCapturedPayByLinkFixture(Subscription, Request, Payment);
        Request.Status := Request.Status::Confirmed;
        Request."Processing Status" := ProcessingStatus;
        Request.Modify();

        asserterror CreateRenewal.Run(Subscription);
        Assert.ExpectedError(StrSubstNo('Subscription request for subscription no. %1 already exists.', Subscription."Entry No."));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ScheduledRenewal_CapturedLinkDoesNotBlockLaterPeriods()
    var
        Subscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        RenewalJQ: Codeunit "NPR MM Subscr. Renew Req. JQ";
        Assert: Codeunit Assert;
    begin
        CreateCapturedPayByLinkFixture(Subscription, Request, Payment);
        Request."Processing Status" := Request."Processing Status"::Success;
        Request.Modify();
        Assert.IsFalse(RenewalJQ.ResolveExistingPayByLink(Subscription), 'A processed renewal must not block creation.');
        Request."Processing Status" := Request."Processing Status"::Pending;
        Request.Modify();
        Subscription."Valid Until Date" := Request."New Valid Until Date";
        Subscription.Modify();
        Assert.IsFalse(RenewalJQ.ResolveExistingPayByLink(Subscription), 'A paid period already covered by the subscription must not block the next period.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ScheduledRenewal_CapturedLinkGuardIsScopedToRenewal()
    var
        Subscription: Record "NPR MM Subscription";
        OtherSubscription: Record "NPR MM Subscription";
        Request: Record "NPR MM Subscr. Request";
        Payment: Record "NPR MM Subscr. Payment Request";
        RequestUtils: Codeunit "NPR MM Subscr. Request Utils";
        Assert: Codeunit Assert;
    begin
        CreateCapturedPayByLinkFixture(Subscription, Request, Payment);
        OtherSubscription.Insert();
        Assert.IsFalse(RequestUtils.HasCapturedPayByLinkAwaitingRenewal(OtherSubscription), 'Another subscription must not be blocked.');
        Payment.Status := Payment.Status::Requested;
        Payment.Modify();
        Assert.IsFalse(RequestUtils.HasCapturedPayByLinkAwaitingRenewal(Subscription), 'An unpaid link belongs to the existing resolution path.');
        Payment.Status := Payment.Status::Captured;
        Payment.Reversed := true;
        Payment.Modify();
        Assert.IsTrue(RequestUtils.HasCapturedPayByLinkAwaitingRenewal(Subscription), 'A reversal flag without a confirmed refund must still count as collected money.');
        Payment.Reversed := false;
        Payment.Modify();
        Request.Type := Request.Type::Regret;
        Request.Modify();
        Assert.IsFalse(RequestUtils.HasCapturedPayByLinkAwaitingRenewal(Subscription), 'A refund request must not count as a paid renewal.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectedRenewal_LocallyCapturedLinkStopsFailureProcessing()
    begin
        VerifyCapturedLinkStopsFailureProcessing(Enum::"NPR MM Subscr. Request Status"::Rejected);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RenewalError_LocallyCapturedLinkStopsFailureProcessing()
    begin
        VerifyCapturedLinkStopsFailureProcessing(Enum::"NPR MM Subscr. Request Status"::"Request Error");
    end;

    local procedure VerifyCapturedLinkStopsFailureProcessing(RequestStatus: Enum "NPR MM Subscr. Request Status")
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
        ParentRequest: Record "NPR MM Subscr. Request";
        Membership: Record "NPR MM Membership";
        Notification: Record "NPR MM Membership Notific.";
        ProcessRenewal: Codeunit "NPR MM Subs Try Renew Process";
        Assert: Codeunit Assert;
    begin
        CreateCapturedPayByLinkFixture(Subscription, LinkRequest, LinkPayment);
        Membership."Membership Code" := Subscription."Membership Code";
        Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
        Membership.Insert();
        Subscription."Membership Entry No." := Membership."Entry No.";
        Subscription.Modify();
        LinkRequest.Status := LinkRequest.Status::Confirmed;
        LinkRequest.Modify();
        ParentRequest.Type := ParentRequest.Type::Renew;
        ParentRequest.Status := RequestStatus;
        ParentRequest."Subscription Entry No." := Subscription."Entry No.";
        ParentRequest."New Valid From Date" := LinkRequest."New Valid From Date";
        ParentRequest."New Valid Until Date" := LinkRequest."New Valid Until Date";
        ParentRequest.Insert();
        ProcessRenewal.Run(ParentRequest);
        ParentRequest.Get(ParentRequest.RecordId);
        Assert.AreEqual(ParentRequest."Processing Status"::Success, ParentRequest."Processing Status", 'A captured link must complete the failed parent without another payment attempt.');
        LinkRequest.Get(LinkRequest.RecordId);
        Assert.AreEqual(LinkRequest."Processing Status"::Pending, LinkRequest."Processing Status", 'The child renewal must be left for the processing job.');
        LinkPayment.Get(LinkPayment.RecordId);
        Assert.AreEqual(LinkPayment.Status::Captured, LinkPayment.Status, 'The captured payment must remain untouched.');
        Membership.Get(Membership.RecordId);
        Assert.AreEqual(Membership."Auto-Renew"::YES_INTERNAL, Membership."Auto-Renew", 'Payment success must preserve auto-renewal.');
        Subscription.Get(Subscription.RecordId);
        Assert.AreNotEqual(Subscription."Termination Reason"::FORCED_TERMINATION, Subscription."Termination Reason", 'A paid renewal must not force termination.');
        Notification.SetRange("Membership Entry No.", Membership."Entry No.");
        Notification.SetRange("Notification Trigger", Notification."Notification Trigger"::RENEWAL_FAILURE);
        Assert.IsTrue(Notification.IsEmpty(), 'A paid renewal must not send a failure notification.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CapturedLink_MatchesUnrefundedPaymentForSamePeriod()
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
        ParentRequest: Record "NPR MM Subscr. Request";
        RequestUtils: Codeunit "NPR MM Subscr. Request Utils";
        Assert: Codeunit Assert;
    begin
        CreateCapturedPayByLinkFixture(Subscription, LinkRequest, LinkPayment);
        ParentRequest."Subscription Entry No." := Subscription."Entry No.";
        ParentRequest."New Valid From Date" := LinkRequest."New Valid From Date";
        ParentRequest."New Valid Until Date" := LinkRequest."New Valid Until Date";
        Assert.IsTrue(RequestUtils.HasCapturedPayByLinkForRenewal(ParentRequest), 'The captured payment must be recognized before child processing.');
        LinkRequest."Processing Status" := LinkRequest."Processing Status"::Success;
        LinkRequest.Modify();
        Assert.IsTrue(RequestUtils.HasCapturedPayByLinkForRenewal(ParentRequest), 'A processed child must still protect its failed parent.');
        ParentRequest."New Valid From Date" += 1;
        Assert.IsFalse(RequestUtils.HasCapturedPayByLinkForRenewal(ParentRequest), 'A different start date must not match.');
        ParentRequest."New Valid From Date" := LinkRequest."New Valid From Date";
        ParentRequest."New Valid Until Date" += 1;
        Assert.IsFalse(RequestUtils.HasCapturedPayByLinkForRenewal(ParentRequest), 'A different end date must not match.');
        ParentRequest."New Valid Until Date" := LinkRequest."New Valid Until Date";
        ParentRequest."Subscription Entry No." := 0;
        Assert.IsFalse(RequestUtils.HasCapturedPayByLinkForRenewal(ParentRequest), 'Another subscription must not match.');
        ParentRequest."Subscription Entry No." := Subscription."Entry No.";
        LinkPayment.Reversed := true;
        LinkPayment.Modify();
        Assert.IsTrue(RequestUtils.HasCapturedPayByLinkForRenewal(ParentRequest), 'A reversal flag without a confirmed refund must still count as paid.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure CapturedLink_RefundMustSucceedBeforeRenewal()
    begin
        VerifyCapturedLinkRefund(Enum::"NPR MM Payment Request Status"::New, false);
        VerifyCapturedLinkRefund(Enum::"NPR MM Payment Request Status"::Authorized, false);
        VerifyCapturedLinkRefund(Enum::"NPR MM Payment Request Status"::Requested, false);
        VerifyCapturedLinkRefund(Enum::"NPR MM Payment Request Status"::Error, false);
        VerifyCapturedLinkRefund(Enum::"NPR MM Payment Request Status"::Rejected, false);
        VerifyCapturedLinkRefund(Enum::"NPR MM Payment Request Status"::Cancelled, false);
        VerifyCapturedLinkRefund(Enum::"NPR MM Payment Request Status"::Captured, true);
    end;

    local procedure VerifyCapturedLinkRefund(RefundStatus: Enum "NPR MM Payment Request Status"; Refunded: Boolean)
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
        Refund: Record "NPR MM Subscr. Payment Request";
        ReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        RequestUtils: Codeunit "NPR MM Subscr. Request Utils";
        RenewalJQ: Codeunit "NPR MM Subscr. Renew Req. JQ";
        Assert: Codeunit Assert;
    begin
        CreateCapturedPayByLinkFixture(Subscription, LinkRequest, LinkPayment);
        LinkPayment.Amount := 10;
        LinkPayment.Modify();
        ReversalMgt.RequestRefund(LinkRequest, LinkPayment, false, Refund);
        LinkPayment.Get(LinkPayment.RecordId);
        Assert.IsTrue(LinkPayment.Reversed, 'Creating a refund must set the reversal flag before money is returned.');
        Assert.AreEqual(Refund.Status::New, Refund.Status, 'The real refund creation path must leave the refund pending.');
        Assert.IsTrue(RenewalJQ.ResolveExistingPayByLink(Subscription), 'Requesting a refund must not permit another charge.');
        Refund.Status := RefundStatus;
        Refund.Modify();
        Assert.AreEqual(not Refunded, RequestUtils.HasCapturedPayByLinkAwaitingRenewal(Subscription), 'Creation must remain blocked until the refund succeeds.');
        Assert.AreEqual(not Refunded, RequestUtils.HasCapturedPayByLinkForRenewal(LinkRequest), 'Processing must retain the same paid-payment safeguard.');
        Assert.AreEqual(not Refunded, RenewalJQ.ResolveExistingPayByLink(Subscription), 'The JQ must defer pending or failed refunds without raising an error.');
        if Refunded then begin
            Refund.Amount := -5;
            Refund.Modify();
            Assert.IsTrue(RenewalJQ.ResolveExistingPayByLink(Subscription), 'A partial refund must not allow the full renewal amount to be charged again.');
        end;
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_PendingTokenRefundRetainsCleanup()
    begin
        VerifyTokenRefundCleanup(Enum::"NPR MM Payment Request Status"::New, -10, true);
        VerifyTokenRefundCleanup(Enum::"NPR MM Payment Request Status"::Authorized, -10, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_FailedTokenRefundRetainsCleanup()
    begin
        VerifyTokenRefundCleanup(Enum::"NPR MM Payment Request Status"::Error, -10, true);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_RefundedTokenDoesNotTriggerCleanup()
    begin
        VerifyTokenRefundCleanup(Enum::"NPR MM Payment Request Status"::Captured, -10, false);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayByLink_PartialTokenRefundRetainsCleanup()
    begin
        VerifyTokenRefundCleanup(Enum::"NPR MM Payment Request Status"::Captured, -5, true);
    end;

    local procedure VerifyTokenRefundCleanup(RefundStatus: Enum "NPR MM Payment Request Status"; RefundAmount: Decimal; ExpectCleanup: Boolean)
    var
        Subscription: Record "NPR MM Subscription";
        LinkRequest: Record "NPR MM Subscr. Request";
        LinkPayment: Record "NPR MM Subscr. Payment Request";
        TokenRequest: Record "NPR MM Subscr. Request";
        TokenPayment: Record "NPR MM Subscr. Payment Request";
        Refund: Record "NPR MM Subscr. Payment Request";
        ReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        PaymentJQ: Codeunit "NPR MM Subscr. Pay Req Proc JQ";
        RequestUtils: Codeunit "NPR MM Subscr. Request Utils";
        Mock: Codeunit "NPR MM Subscription Audit Test";
        Assert: Codeunit Assert;
    begin
        CreateRenewalPayByLinkFixture(Subscription, LinkRequest, LinkPayment);
        TokenRequest.Type := TokenRequest.Type::Renew;
        TokenRequest."Subscription Entry No." := Subscription."Entry No.";
        TokenRequest.Insert();
        TokenPayment."Subscr. Request Entry No." := TokenRequest."Entry No.";
        TokenPayment.Type := TokenPayment.Type::Payment;
        TokenPayment.Status := TokenPayment.Status::Captured;
        TokenPayment.PSP := TokenPayment.PSP::Adyen;
        TokenPayment.Amount := 10;
        TokenPayment.Insert();
        Assert.IsTrue(RequestUtils.HasCapturedTokenPayment(LinkPayment), 'The original capture must qualify for cleanup.');
        Mock.ConfigurePayByLinkMock('{"status":"active"}', '', false, true);
        Mock.InitializeGateway();
        BindSubscription(Mock);
        PaymentJQ.RetryPayByLinkCancellation();
        LinkPayment.Get(LinkPayment.RecordId);
        Assert.AreEqual(LinkPayment.Status::Requested, LinkPayment.Status, 'A failed cancellation must leave the link available for cleanup retry.');
        Mock.AssertPayByLinkCalls(1, 1);

        ReversalMgt.RequestRefund(TokenRequest, TokenPayment, false, Refund);
        Assert.IsTrue(TokenPayment.Reversed, 'Actual refund creation must mark the original payment reversed immediately.');
        Assert.AreEqual(Refund.Status::New, Refund.Status, 'The refund must start pending.');
        Assert.IsTrue(RequestUtils.HasCapturedTokenPayment(LinkPayment), 'Requesting a refund must not stop cleanup.');
        Refund.Status := RefundStatus;
        Refund.Amount := RefundAmount;
        Refund.Modify();
        Assert.AreEqual(ExpectCleanup, RequestUtils.HasCapturedTokenPayment(LinkPayment), 'Only a confirmed full refund may release the cleanup guard.');
        Mock.ConfigurePayByLinkMock('{"status":"active"}', '{"status":"expired"}', false, false);
        PaymentJQ.RetryPayByLinkCancellation();
        LinkPayment.Get(LinkPayment.RecordId);
        if ExpectCleanup then begin
            Assert.AreEqual(LinkPayment.Status::Cancelled, LinkPayment.Status, 'Cleanup must retry while any of the original charge is retained.');
            Mock.AssertPayByLinkCalls(1, 1);
        end else begin
            Assert.AreEqual(LinkPayment.Status::Requested, LinkPayment.Status, 'A fully refunded token must no longer cause link cancellation.');
            Mock.AssertPayByLinkCalls(0, 0);
        end;
        TokenPayment.Get(TokenPayment.RecordId);
        Assert.AreEqual(TokenPayment.Status::Captured, TokenPayment.Status, 'Link cleanup must not change the original payment status.');
        Mock.CleanupGateway();
        UnbindSubscription(Mock);
    end;

    local procedure CreateCapturedPayByLinkFixture(var Subscription: Record "NPR MM Subscription"; var Request: Record "NPR MM Subscr. Request"; var Payment: Record "NPR MM Subscr. Payment Request")
    begin
        CreateRenewalPayByLinkFixture(Subscription, Request, Payment);
        Subscription."Valid Until Date" := WorkDate();
        Subscription.Modify();
        Request."New Valid From Date" := WorkDate() + 1;
        Request."New Valid Until Date" := CalcDate('<1Y>', WorkDate());
        Request.Modify();
        Payment.Status := Payment.Status::Captured;
        Payment.Modify();
    end;

    local procedure CreateRenewalPayByLinkFixture(var Subscription: Record "NPR MM Subscription"; var Request: Record "NPR MM Subscr. Request"; var PaymentRequest: Record "NPR MM Subscr. Payment Request")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        RecurSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        RecurSetup.Code := CopyStr(DelChr(Format(CreateGuid()), '=', '{}-'), 1, MaxStrLen(RecurSetup.Code));
        RecurSetup."Subscr. Auto-Renewal On" := RecurSetup."Subscr. Auto-Renewal On"::Schedule;
        RecurSetup.Insert();
        MembershipSetup.Code := RecurSetup.Code;
        MembershipSetup."Recurring Payment Code" := RecurSetup.Code;
        MembershipSetup.Insert();
        Subscription."Membership Code" := MembershipSetup.Code;
        Subscription.Insert();
        Request."Subscription Entry No." := Subscription."Entry No.";
        Request.Type := Request.Type::Renew;
        Request.Status := Request.Status::Requested;
        Request."Created from Entry No." := 1;
        Request.Insert();
        PaymentRequest."Subscr. Request Entry No." := Request."Entry No.";
        PaymentRequest.Type := PaymentRequest.Type::PayByLink;
        PaymentRequest.Status := PaymentRequest.Status::Requested;
        PaymentRequest.PSP := PaymentRequest.PSP::Adyen;
        PaymentRequest."Pay by Link ID" := 'MOCK-LINK';
        PaymentRequest.Insert();
    end;

    local procedure SetPayByLinkFixtureMode(Subscription: Record "NPR MM Subscription"; RenewalMode: Enum "NPR MM Subscr. Auto-Renewal")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        RecurSetup: Record "NPR MM Recur. Paym. Setup";
    begin
        MembershipSetup.Get(Subscription."Membership Code");
        RecurSetup.Get(MembershipSetup."Recurring Payment Code");
        RecurSetup."Subscr. Auto-Renewal On" := RenewalMode;
        RecurSetup.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Subscr.Pmt.: Adyen", 'OnBeforeGetAdyenPaymentGatewaySetup', '', false, false)]
    local procedure MockRenewalGateway(var SubsAdyenPGSetup: Record "NPR MM Subs Adyen PG Setup"; var Handled: Boolean)
    var
        MockSetupErr: Label 'Mock payment gateway setup is missing.';
    begin
        if _FailGatewaySetup then
            Error(MockSetupErr);
        _MockGateway.TestField(Code);
        SubsAdyenPGSetup := _MockGateway;
        Handled := true;
    end;

    procedure InitializeGateway()
    begin
        if _MockGateway.Code = '' then begin
            _MockGateway.Code := 'PBL-TEST';
            _MockGateway.Environment := _MockGateway.Environment::Test;
            _MockGateway."Merchant Name" := 'PBL-TEST';
            _MockGateway.SetAPIKey('mock-key');
        end;
    end;

    procedure FailGatewaySetup()
    begin
        _FailGatewaySetup := true;
    end;

    procedure CleanupGateway()
    begin
        _MockGateway.DeleteAPIKey();
        Clear(_MockGateway);
    end;

    procedure ConfigurePayByLinkMock(GetResponse: Text; CancelResponse: Text; FailGet: Boolean; FailCancel: Boolean)
    begin
        _PayByLinkGetResponse := GetResponse;
        _PayByLinkCancelResponse := CancelResponse;
        _FailPayByLinkGet := FailGet;
        _FailPayByLinkCancel := FailCancel;
        _PayByLinkGetCount := 0;
        _PayByLinkCancelCount := 0;
    end;

    procedure AssertPayByLinkCalls(ExpectedGetCount: Integer; ExpectedCancelCount: Integer)
    var
        Assert: Codeunit Assert;
    begin
        Assert.AreEqual(ExpectedGetCount, _PayByLinkGetCount, 'Unexpected number of status checks.');
        Assert.AreEqual(ExpectedCancelCount, _PayByLinkCancelCount, 'Unexpected number of cancellation calls.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Subscr.Pmt.: Adyen", 'OnBeforeInvokeAPI', '', false, false)]
    local procedure MockRenewalPayByLinkHttp(var Request: Text; var Response: Text; var Handled: Boolean)
    var
        MockHttpErr: Label 'Mock payment provider failure.';
        Assert: Codeunit Assert;
    begin
        Handled := true;
        if _MockTokenCharge and Request.Contains('storedPaymentMethodId') then begin
            _TokenChargeCount += 1;
            Response := '{"resultCode":"Authorised","pspReference":"MOCK-TOKEN"}';
            exit;
        end;
        if Request = '' then begin
            _PayByLinkGetCount += 1;
            if _FailPayByLinkGet then
                Error(MockHttpErr);
            Response := _PayByLinkGetResponse;
        end else begin
            Assert.IsTrue(Request.Contains('expired'), 'Only link expiry is expected; another charge must not be sent.');
            _PayByLinkCancelCount += 1;
            if _FailPayByLinkCancel then
                Error(MockHttpErr);
            Response := _PayByLinkCancelResponse;
        end;
    end;

    procedure ConfigureLinkCreationFailure(StatusCode: Integer)
    begin
        _MockLinkCreation := true;
        _LinkCreationStatusCode := StatusCode;
    end;

    procedure ConfigureTokenCharge()
    begin
        _MockTokenCharge := true;
    end;

    procedure AssertCreationCalls(ExpectedLinks: Integer; ExpectedCharges: Integer)
    var
        Assert: Codeunit Assert;
    begin
        Assert.AreEqual(ExpectedLinks, _LinkCreationCount, 'Unexpected number of link submissions.');
        Assert.AreEqual(ExpectedCharges, _TokenChargeCount, 'Unexpected number of token charges.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR MM Subscr.Pmt.: Adyen", 'OnBeforeSendPayByLinkRequest', '', false, false)]
    local procedure MockLinkCreation(var Response: Text; var StatusCode: Integer; var Success: Boolean; var Handled: Boolean)
    begin
        if not _MockLinkCreation then
            exit;
        _LinkCreationCount += 1;
        StatusCode := _LinkCreationStatusCode;
        Response := '{"message":"Mock link creation failed"}';
        Success := false;
        Handled := true;
    end;

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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResumeSubscriptionCancelsPendingTerminationRequest()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] Resuming a subscription (Auto-Renew -> YES_INTERNAL) while a termination request is
        // pending must cancel the pending termination request instead of leaving it stuck as pending
        Initialize();

        // [GIVEN] A membership with a subscription that has a pending termination request
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        Assert.IsTrue(SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription), 'Subscription should exist after membership creation.');
        Subscription."Auto-Renew" := Subscription."Auto-Renew"::YES_INTERNAL;
        Subscription.Modify(true);

        Assert.IsTrue(
            SubscriptionMgtImpl.RequestTermination(Membership, CalcDate('<+7D>'), Enum::"NPR MM Subs Termination Reason"::CUSTOMER_INITIATED),
            'RequestTermination should succeed.');

        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Terminate);
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'A pending termination request should exist.');
        Assert.AreEqual(SubscriptionRequest."Processing Status"::Pending, SubscriptionRequest."Processing Status", 'Termination request should be Pending before resume.');

        // [WHEN] The membership is resumed the same way the subscription resume API does it
        Membership.Get(Membership."Entry No.");
        Membership.Validate("Auto-Renew", Membership."Auto-Renew"::YES_INTERNAL);
        Membership.Modify();

        // [THEN] The pending termination request is cancelled, not left dangling
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        Assert.AreEqual(SubscriptionRequest.Status::Cancelled, SubscriptionRequest.Status, 'Termination request should be Cancelled after resume.');
        Assert.AreEqual(SubscriptionRequest."Processing Status"::Success, SubscriptionRequest."Processing Status", 'Termination request Processing Status should be Success (not left Pending) after resume.');

        // [THEN] The subscription itself reflects the resumed state
        Subscription.Get(Subscription."Entry No.");
        Assert.AreEqual(Subscription."Auto-Renew"::YES_INTERNAL, Subscription."Auto-Renew", 'Subscription Auto-Renew should be YES_INTERNAL after resume.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResumeSubscriptionCancelsErroredTerminationRequest()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] Resuming a subscription must also cancel a termination request whose processing has
        // ended in Error (not only Pending ones), so it doesn't remain stuck and later affect the membership.
        Initialize();

        // [GIVEN] A membership with a subscription that has an errored termination request
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        Assert.IsTrue(SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription), 'Subscription should exist after membership creation.');
        Subscription."Auto-Renew" := Subscription."Auto-Renew"::YES_INTERNAL;
        Subscription.Modify(true);

        Assert.IsTrue(
            SubscriptionMgtImpl.RequestTermination(Membership, CalcDate('<+7D>'), Enum::"NPR MM Subs Termination Reason"::CUSTOMER_INITIATED),
            'RequestTermination should succeed.');

        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Terminate);
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'A termination request should exist.');

        // Force the termination request into an Error processing state (simulating a failed processing attempt)
        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Error;
        SubscriptionRequest.Modify(true);

        // [WHEN] The membership is resumed
        Membership.Get(Membership."Entry No.");
        Membership.Validate("Auto-Renew", Membership."Auto-Renew"::YES_INTERNAL);
        Membership.Modify();

        // [THEN] The errored termination request is cancelled, not left dangling
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        Assert.AreEqual(SubscriptionRequest.Status::Cancelled, SubscriptionRequest.Status, 'Errored termination request should be Cancelled after resume.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure UnprocessedPartialRegretExists_DetectsPendingErrorButNotProcessed()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        Subscription: Record "NPR MM Subscription";
        PartialRegretRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
    begin
        // [SCENARIO] UnprocessedPartialRegretExists returns true for a Pending or Error partial regret
        // request, and false when there is none or the only one is already processed (Success).
        Initialize();

        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        Assert.IsTrue(SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription), 'Subscription should exist after membership creation.');

        // [THEN] No partial regret request -> false
        Assert.IsFalse(MembershipMgtInternal.UnprocessedPartialRegretExists(Membership), 'Should be false when no partial regret request exists.');

        // [GIVEN] A Pending partial regret request -> true
        CreatePartialRegretRequest(PartialRegretRequest, Subscription, PartialRegretRequest."Processing Status"::Pending);
        Assert.IsTrue(MembershipMgtInternal.UnprocessedPartialRegretExists(Membership), 'Should be true for a Pending partial regret request.');

        // [GIVEN] The request moves to Error -> still true
        PartialRegretRequest."Processing Status" := PartialRegretRequest."Processing Status"::Error;
        PartialRegretRequest.Modify(true);
        Assert.IsTrue(MembershipMgtInternal.UnprocessedPartialRegretExists(Membership), 'Should be true for an Error partial regret request.');

        // [GIVEN] The request is processed (Processing Status Success) -> false
        PartialRegretRequest."Processing Status" := PartialRegretRequest."Processing Status"::Success;
        PartialRegretRequest.Modify(true);
        Assert.IsFalse(MembershipMgtInternal.UnprocessedPartialRegretExists(Membership), 'Should be false when the only partial regret request is already processed.');
    end;

    // === Context Guard Tests (CORE-227) ===

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ProcessMembershipEntryForInitialSale_SkipsRenewContext()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SalePOS: Record "NPR POS Sale";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SalesTicketNo: Code[20];
    begin
        // [SCENARIO] ProcessMembershipEntryForInitialSale exits early when the membership entry
        // context is RENEW, preventing an Initial Sale subscription request (regression for CORE-227).
        Initialize();
        SalesTicketNo := CopyStr('TEST-RENEW-' + Format(CreateGuid()).Substring(1, 5), 1, MaxStrLen(SalesTicketNo));

        // [GIVEN] A membership with subscription (Auto-Renew = YES_INTERNAL) and all required payment data
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        // Set context to RENEW (simulating a POS renewal) and link to the sales ticket
        MembershipEntry.Context := MembershipEntry.Context::RENEW;
        MembershipEntry."Original Context" := MembershipEntry."Original Context"::RENEW;
        MembershipEntry."Receipt No." := SalesTicketNo;
        MembershipEntry.Modify();

        // Subscription is auto-created with the membership; set Auto-Renew to YES_INTERNAL
        Assert.IsTrue(SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription), 'Subscription should exist after membership creation.');
        Subscription."Auto-Renew" := Subscription."Auto-Renew"::YES_INTERNAL;
        Subscription.Modify(true);

        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEndSaleEFTTransactionRequest(EFTTransactionRequest, SalesTicketNo, 299.00);

        SalePOS.Init();
        SalePOS."Sales Ticket No." := SalesTicketNo;

        // [WHEN] ProcessMembershipEntryForInitialSale is called with a RENEW-context membership entry
        SubscriptionMgtImpl.ProcessMembershipEntryForInitialSale(SalePOS, MembershipEntry);

        // [THEN] No Initial Sale subscription request is created
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.IsTrue(SubscriptionRequest.IsEmpty(), 'No Initial Sale subscription request should be created for RENEW context.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ProcessMembershipEntryForInitialSale_CreatesForNewContext()
    var
        Assert: Codeunit Assert;
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        Subscription: Record "NPR MM Subscription";
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SalePOS: Record "NPR POS Sale";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        MembershipId: Text;
        MembershipNumber: Text;
        MemberId: Text;
        MemberNumber: Text;
        SalesTicketNo: Code[20];
    begin
        // [SCENARIO] ProcessMembershipEntryForInitialSale creates an Initial Sale subscription request
        // when the membership entry context is NEW (positive test for CORE-227 fix).
        Initialize();
        SalesTicketNo := CopyStr('TEST-NEW-' + Format(CreateGuid()).Substring(1, 5), 1, MaxStrLen(SalesTicketNo));

        // [GIVEN] A membership with subscription (Auto-Renew = YES_INTERNAL) and all required payment data
        CreateGoldMembershipAndMember(MembershipId, MembershipNumber, MemberId, MemberNumber);
        Membership.GetBySystemId(MembershipId);
        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.FindLast();

        // Context is already NEW from creation, just link to the sales ticket
        MembershipEntry."Receipt No." := SalesTicketNo;
        MembershipEntry.Modify();

        // Subscription is auto-created with the membership; set Auto-Renew to YES_INTERNAL
        Assert.IsTrue(SubscriptionMgtImpl.GetSubscriptionFromMembership(Membership."Entry No.", Subscription), 'Subscription should exist after membership creation.');
        Subscription."Auto-Renew" := Subscription."Auto-Renew"::YES_INTERNAL;
        Subscription.Modify(true);

        CreateMemberPaymentMethod(MemberPaymentMethod);
        CreateMembershipPmtMethodMap(MembershipPmtMethodMap, MemberPaymentMethod, Membership);
        CreateEndSaleEFTTransactionRequest(EFTTransactionRequest, SalesTicketNo, 299.00);

        SalePOS.Init();
        SalePOS."Sales Ticket No." := SalesTicketNo;

        // [WHEN] ProcessMembershipEntryForInitialSale is called with a NEW-context membership entry
        SubscriptionMgtImpl.ProcessMembershipEntryForInitialSale(SalePOS, MembershipEntry);

        // [THEN] An Initial Sale subscription request IS created
        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::"Initial Sale");
        Assert.IsTrue(SubscriptionRequest.FindFirst(), 'Initial Sale subscription request should be created for NEW context.');
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

    local procedure CreatePartialRegretRequest(var PartialRegretRequest: Record "NPR MM Subscr. Request"; Subscription: Record "NPR MM Subscription"; ProcessingStatus: Enum "NPR MM Subs Req Proc Status")
    begin
        PartialRegretRequest.Init();
        PartialRegretRequest."Entry No." := 0;
        PartialRegretRequest.Type := PartialRegretRequest.Type::"Partial Regret";
        PartialRegretRequest.Status := PartialRegretRequest.Status::New;
        PartialRegretRequest."Processing Status" := ProcessingStatus;
        PartialRegretRequest."Subscription Entry No." := Subscription."Entry No.";
        PartialRegretRequest."Membership Code" := Subscription."Membership Code";
        PartialRegretRequest."Terminate At" := CalcDate('<+7D>');
        PartialRegretRequest.Insert(true);
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

    local procedure CreateEndSaleEFTTransactionRequest(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; SalesTicketNo: Code[20]; Amount: Decimal)
    begin
        EFTTransactionRequest.Init();
        EFTTransactionRequest."Entry No." := 0;
        EFTTransactionRequest."Sales Ticket No." := SalesTicketNo;
        EFTTransactionRequest."Sales Line No." := 10000;
        EFTTransactionRequest."Result Amount" := Amount;
        EFTTransactionRequest."PSP Reference" := CopyStr('PSP-' + Format(CreateGuid()), 1, 16);
        EFTTransactionRequest."Currency Code" := '';
        EFTTransactionRequest.Successful := true;
        EFTTransactionRequest."Processing Type" := EFTTransactionRequest."Processing Type"::PAYMENT;
        EFTTransactionRequest."Recurring Detail Reference" := 'RECURRING-REF-TEST';
        EFTTransactionRequest."Manual Capture" := false;
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

codeunit 85521 "NPR MM Subs PayReq xRec Tests"
{
    // [FEATURE] Subscription payment request status propagation: a status change still reaches the subscription request, and the subscriber leaves xRec to later subscribers
    Access = Internal;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure CapturedPaymentRequestConfirmsItsSubscriptionRequest()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        // [SCENARIO] Capturing a payment request from code confirms its subscription request and queues it for processing.
        // [GIVEN] A requested subscription request with a requested payment request
        CreateRequestedPair(SubscriptionRequest, SubscrPaymentRequest);

        // [WHEN] The payment request is captured from code
        SubscrPaymentRequest.Validate(Status, SubscrPaymentRequest.Status::Captured);
        SubscrPaymentRequest.Modify(true);

        // [THEN] The subscription request is confirmed and pending processing
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        _Assert.AreEqual(SubscriptionRequest.Status::Confirmed, SubscriptionRequest.Status, 'The subscription request must be confirmed');
        _Assert.AreEqual(SubscriptionRequest."Processing Status"::Pending, SubscriptionRequest."Processing Status", 'The subscription request must be pending processing');
    end;

    [Test]
    procedure PaymentRequestModifyWithoutStatusChangeLeavesSubscriptionRequestAlone()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        // [SCENARIO] Modifying a captured payment request from code without changing its status leaves its already processed subscription request untouched.
        // [GIVEN] A captured payment request whose subscription request is confirmed and already processed
        CreateRequestedPair(SubscriptionRequest, SubscrPaymentRequest);
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::Captured;
        SubscrPaymentRequest.Modify(false);
        SubscriptionRequest.Status := SubscriptionRequest.Status::Confirmed;
        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
        SubscriptionRequest.Modify(false);

        // [WHEN] Only the amount is changed from code
        SubscrPaymentRequest.Amount += 1;
        SubscrPaymentRequest.Modify(true);

        // [THEN] The subscription request keeps its status and its processing status
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        _Assert.AreEqual(SubscriptionRequest.Status::Confirmed, SubscriptionRequest.Status, 'The subscription request must keep its status');
        _Assert.AreEqual(SubscriptionRequest."Processing Status"::Success, SubscriptionRequest."Processing Status", 'The subscription request must stay processed');
    end;

    [Test]
    procedure CapturedPaymentRequestStillConfirmsItsRequestWhenAnotherSubscriberModifiesTheRowAgain()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        TestNestedPayReqModify: Codeunit "NPR Test Nested PayReq Modify";
    begin
        // [SCENARIO] A capture whose after-event is interrupted by another subscriber modifying the same payment request still confirms the subscription request.
        // [GIVEN] A requested subscription request with a requested payment request
        CreateRequestedPair(SubscriptionRequest, SubscrPaymentRequest);

        // [GIVEN] A subscriber that modifies the same payment request again during the after-event
        BindSubscription(TestNestedPayReqModify);

        // [WHEN] The payment request is captured from code
        SubscrPaymentRequest.Validate(Status, SubscrPaymentRequest.Status::Captured);
        SubscrPaymentRequest.Modify(true);

        // [THEN] The nested modify ran and the subscription request is still confirmed
        _Assert.IsTrue(TestNestedPayReqModify.NestedModifyRan(), 'The nested modify must have run');
        SubscriptionRequest.Get(SubscriptionRequest."Entry No.");
        _Assert.AreEqual(SubscriptionRequest.Status::Confirmed, SubscriptionRequest.Status, 'The subscription request must be confirmed despite the nested modify');
    end;

    [Test]
    procedure CodeDrivenPaymentRequestModifyLeavesXRecUntouchedForLaterSubscribers()
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        TestXRecProbe: Codeunit "NPR Test xRec Probe";
    begin
        // [SCENARIO] A code-driven status change of a payment request reaches later subscribers with the xRec the platform supplied, which carries the status being written rather than the one on disk.
        // [GIVEN] A requested subscription request with a requested payment request
        CreateRequestedPair(SubscriptionRequest, SubscrPaymentRequest);

        // [GIVEN] A probe subscriber observing the modify event
        BindSubscription(TestXRecProbe);

        // [WHEN] The payment request is captured from code
        SubscrPaymentRequest.Validate(Status, SubscrPaymentRequest.Status::Captured);
        SubscrPaymentRequest.Modify(true);

        // [THEN] The probe saw the modify with xRec still carrying the new status
        _Assert.IsTrue(TestXRecProbe.ModifySeen(Database::"NPR MM Subscr. Payment Request"), 'The probe must observe the payment request modify');
        _Assert.IsTrue(TestXRecProbe.XRecCarriesRecValue(Database::"NPR MM Subscr. Payment Request"), 'The status propagation subscriber must not replace xRec');
    end;

    [Test]
    procedure OldStatusesOfNestedModifiesComeBackInnermostFirst()
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubsPayReqOldStatus: Codeunit "NPR MM Subs PayReq Old Status";
        FirstStatus: Enum "NPR MM Payment Request Status";
        SecondStatus: Enum "NPR MM Payment Request Status";
        ThirdStatus: Enum "NPR MM Payment Request Status";
        FirstTaken: Boolean;
        SecondTaken: Boolean;
        ThirdTaken: Boolean;
    begin
        // [SCENARIO] The old statuses remembered for an outer and a nested modify of one payment request come back nested first, so the nested modify cannot consume the outer one's status.
        // [GIVEN] A requested payment request whose status is remembered for an outer modify
        CreateRequestedPair(SubscriptionRequest, SubscrPaymentRequest);
        SubsPayReqOldStatus.Remember(SubscrPaymentRequest);

        // [GIVEN] The payment request authorized on disk, and its status remembered for a nested modify
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::Authorized;
        SubscrPaymentRequest.Modify(false);
        SubsPayReqOldStatus.Remember(SubscrPaymentRequest);

        // [WHEN] The old statuses are taken back three times
        FirstTaken := SubsPayReqOldStatus.Take(SubscrPaymentRequest."Entry No.", FirstStatus);
        SecondTaken := SubsPayReqOldStatus.Take(SubscrPaymentRequest."Entry No.", SecondStatus);
        ThirdTaken := SubsPayReqOldStatus.Take(SubscrPaymentRequest."Entry No.", ThirdStatus);

        // [THEN] The nested modify's status comes first, then the outer one's, then nothing
        _Assert.IsTrue(FirstTaken, 'The nested status must be handed out');
        _Assert.AreEqual(SubscrPaymentRequest.Status::Authorized, FirstStatus, 'The nested modify must get its own old status first');
        _Assert.IsTrue(SecondTaken, 'The outer status must still be there after the nested one');
        _Assert.AreEqual(SubscrPaymentRequest.Status::Requested, SecondStatus, 'The outer modify must get the status remembered for it');
        _Assert.IsFalse(ThirdTaken, 'Nothing may be left once both statuses are taken');
    end;

    local procedure CreateRequestedPair(var SubscriptionRequest: Record "NPR MM Subscr. Request"; var SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request")
    begin
        SubscriptionRequest.Init();
        SubscriptionRequest."Entry No." := 0;
        SubscriptionRequest.Status := SubscriptionRequest.Status::Requested;
        // Error rather than Pending, so the "pending processing" assertion can only be met by the subscriber's own write.
        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Error;
        SubscriptionRequest.Amount := 100;
        SubscriptionRequest.Insert(true);

        SubscrPaymentRequest.Init();
        SubscrPaymentRequest."Entry No." := 0;
        SubscrPaymentRequest.Type := SubscrPaymentRequest.Type::Payment;
        SubscrPaymentRequest.Status := SubscrPaymentRequest.Status::Requested;
        SubscrPaymentRequest."Subscr. Request Entry No." := SubscriptionRequest."Entry No.";
        SubscrPaymentRequest.Amount := SubscriptionRequest.Amount;
        SubscrPaymentRequest.Insert(true);
    end;
}

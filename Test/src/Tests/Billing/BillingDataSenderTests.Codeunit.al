codeunit 85666 "NPR Billing Data Sender Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestHttpRequestPolicy = BlockOutboundRequests;

    var
        _Assert: Codeunit Assert;
        _ApiKeySecretNameTok: Label 'NpBillingApiSharedKey', Locked = true;

    [Test]
    procedure Run_MoreEventsThanOneBatch_SendsAllOfThemInBatchesOf100()
    var
        MockBillingApi: Codeunit "NPR Mock Billing Api";
        EventIds: List of [Guid];
    begin
        Initialize(MockBillingApi);
        RegisterEvents(250, EventIds);

        _Assert.IsTrue(RunSender(), 'The run should succeed: ' + GetLastErrorText());

        _Assert.AreEqual(3, MockBillingApi.RequestCount(), 'One run must send every pending event, 100 per request');
        _Assert.AreEqual(100, MockBillingApi.RequestSize(1), 'A request must carry at most 100 events, which the API queues in one call');
        _Assert.AreEqual(100, MockBillingApi.RequestSize(2), 'A request must carry at most 100 events, which the API queues in one call');
        _Assert.AreEqual(50, MockBillingApi.RequestSize(3), 'The last request must carry the remaining events');
        AssertEveryEventDoneAndStored(MockBillingApi, EventIds, 1, 250, 1);
    end;

    [Test]
    procedure Run_NothingPending_SendsNoRequest()
    var
        MockBillingApi: Codeunit "NPR Mock Billing Api";
    begin
        Initialize(MockBillingApi);

        _Assert.IsTrue(RunSender(), 'The run should succeed: ' + GetLastErrorText());

        _Assert.AreEqual(0, MockBillingApi.RequestCount(), 'No request may be sent when nothing is pending');
    end;

    [Test]
    procedure Run_RequestFails_SendsTheSameBatchAgainAndGoesOn()
    var
        MockBillingApi: Codeunit "NPR Mock Billing Api";
        EventIds: List of [Guid];
    begin
        Initialize(MockBillingApi);
        RegisterEvents(250, EventIds);
        MockBillingApi.FailRequests(2, 3);

        _Assert.IsTrue(RunSender(), 'Two failed requests in a row must not end the run: ' + GetLastErrorText());

        _Assert.AreEqual(5, MockBillingApi.RequestCount(), 'The failed batch must be sent again until the API takes it');
        AssertEveryEventDoneAndStored(MockBillingApi, EventIds, 1, 250, 1);
    end;

    [Test]
    procedure Run_AnswerOfAcceptedRequestIsLost_KeepsTheBatchPendingAndSendsItAgain()
    var
        MockBillingApi: Codeunit "NPR Mock Billing Api";
        EventIds: List of [Guid];
    begin
        Initialize(MockBillingApi);
        RegisterEvents(150, EventIds);
        MockBillingApi.LoseAnswerOfRequest(1);

        _Assert.IsTrue(RunSender(), 'The run should succeed: ' + GetLastErrorText());

        _Assert.AreEqual(3, MockBillingApi.RequestCount(), 'A batch without an answer must be sent again');
        AssertEveryEventDoneAndStored(MockBillingApi, EventIds, 1, 100, 2);
        AssertEveryEventDoneAndStored(MockBillingApi, EventIds, 101, 150, 1);
    end;

    [Test]
    procedure Run_ThreeRequestsInARowFail_StopsAndKeepsOnlyTheSentBatchDone()
    var
        MockBillingApi: Codeunit "NPR Mock Billing Api";
        EventIds: List of [Guid];
    begin
        Initialize(MockBillingApi);
        RegisterEvents(250, EventIds);
        MockBillingApi.FailRequests(2, 4);

        _Assert.IsFalse(RunSender(), 'Three failed requests in a row must end the run with the error');
        _Assert.IsTrue(GetLastErrorText().Contains('500'), 'The run must end with the error of the failed request, got: ' + GetLastErrorText());

        _Assert.AreEqual(4, MockBillingApi.RequestCount(), 'The run must stop after the third failed request in a row');
        _Assert.AreEqual(100, CountEntries(Enum::"NPR Billing Queue Status"::Done), 'The batch sent before the failures must stay done');
        _Assert.AreEqual(150, CountEntries(Enum::"NPR Billing Queue Status"::Pending), 'Events the API did not take must stay pending');

        _Assert.IsTrue(RunSender(), 'The next run should succeed: ' + GetLastErrorText());

        AssertEveryEventDoneAndStored(MockBillingApi, EventIds, 1, 250, 1);
    end;

    [Test]
    procedure Run_RequestOfLessThanOneBatchFails_SendsItAgain()
    var
        MockBillingApi: Codeunit "NPR Mock Billing Api";
        EventIds: List of [Guid];
    begin
        Initialize(MockBillingApi);
        RegisterEvents(50, EventIds);
        MockBillingApi.FailRequests(1, 1);

        _Assert.IsTrue(RunSender(), 'One failed request must not end the run: ' + GetLastErrorText());

        _Assert.AreEqual(2, MockBillingApi.RequestCount(), 'The failed batch must be sent again in the same run');
        AssertEveryEventDoneAndStored(MockBillingApi, EventIds, 1, 50, 1);
    end;

    [Test]
    procedure Run_ThreeRequestsOfLessThanOneBatchFail_StopsAndKeepsTheEventsPending()
    var
        MockBillingApi: Codeunit "NPR Mock Billing Api";
        EventIds: List of [Guid];
    begin
        Initialize(MockBillingApi);
        RegisterEvents(50, EventIds);
        MockBillingApi.FailRequests(1, 3);

        _Assert.IsFalse(RunSender(), 'Three failed requests in a row must end the run with the error');

        _Assert.AreEqual(3, MockBillingApi.RequestCount(), 'The run must stop after the third failed request in a row');
        _Assert.AreEqual(50, CountEntries(Enum::"NPR Billing Queue Status"::Pending), 'Events the API did not take must stay pending');
    end;

    [Test]
    procedure Run_BatchFailsBeforeTheRequest_StopsWithThatErrorAndSendsNothing()
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        MockBillingApi: Codeunit "NPR Mock Billing Api";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        EventIds: List of [Guid];
    begin
        Initialize(MockBillingApi);
        RegisterEvents(50, EventIds);
        BillingQueueEntry.FindFirst();
        BillingQueueEntry."Billing API URL" := 'https://another-billing-api.invalid/api';
        BillingQueueEntry.Modify();

        SentryCapture.Start();
        _Assert.IsFalse(RunSender(), 'A batch that fails three times in a row must end the run with the error');
        SentryCapture.Stop();
        _Assert.IsTrue(GetLastErrorText().Contains(BillingQueueEntry.FieldCaption("Billing API URL")), 'The run must end with the error of the failed batch, got: ' + GetLastErrorText());

        _Assert.AreEqual(0, MockBillingApi.RequestCount(), 'A batch with an entry of another billing API must not be sent');
        _Assert.AreEqual(50, CountEntries(Enum::"NPR Billing Queue Status"::Pending), 'Events of a failed batch must stay pending');
        _Assert.AreEqual(0, SentryCapture.PayloadCount(), 'An error that is not a programming bug must not be sent to Sentry');
    end;

    [Test]
    procedure Run_BatchFailsWithAProgrammingBug_SendsTheErrorToSentry()
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        MockBillingApi: Codeunit "NPR Mock Billing Api";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        EventIds: List of [Guid];
    begin
        Initialize(MockBillingApi);
        RegisterEvents(50, EventIds);
        // The value becomes part of the error text, and these words in an error text are what makes it a programming bug for Sentry.
        BillingQueueEntry.FindFirst();
        BillingQueueEntry."Billing API URL" := 'https://another-billing-api.invalid/This is a programming bug';
        BillingQueueEntry.Modify();

        SentryCapture.Start();
        _Assert.IsFalse(RunSender(), 'A batch that fails three times in a row must end the run with the error');
        SentryCapture.Stop();

        _Assert.IsTrue(SentryCapture.Contains('another-billing-api.invalid'), 'A programming bug in a batch must be sent to Sentry, although the session of the job has no Sentry transaction');
    end;

    local procedure Initialize(var MockBillingApi: Codeunit "NPR Mock Billing Api")
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        EventBillingClient: Codeunit "NPR Event Billing Client";
    begin
        EventBillingClient.SetHttpClientHandler(MockBillingApi);
        BillingQueueEntry.DeleteAll();
    end;

    local procedure RegisterEvents(NoOfEvents: Integer; var EventIds: List of [Guid])
    var
        EventBillingClient: Codeunit "NPR Event Billing Client";
        EventId: Guid;
        i: Integer;
    begin
        for i := 1 to NoOfEvents do begin
            EventId := CreateGuid();
            EventBillingClient.RegisterEvent(EventId, Enum::"NPR Billing Event Type"::InternalDevelopmentEvent, 1);
            EventIds.Add(EventId);
        end;
    end;

    local procedure RunSender() Success: Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
        SandboxSecretInjection: Codeunit "NPR Sandbox Secret Injection";
    begin
        SandboxSecretInjection.AddSecret(_ApiKeySecretNameTok, 'test-key');
        Commit();
        Success := Codeunit.Run(Codeunit::"NPR Billing Data Sender JQ", JobQueueEntry);
        SandboxSecretInjection.RemoveSecret(_ApiKeySecretNameTok);
    end;

    local procedure AssertEveryEventDoneAndStored(var MockBillingApi: Codeunit "NPR Mock Billing Api"; EventIds: List of [Guid]; FromEvent: Integer; ToEvent: Integer; ExpectedStoredCount: Integer)
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
        i: Integer;
        EventNotDoneLbl: Label 'Event %1 must be done after the run', Locked = true;
        StoredCountLbl: Label 'Number of times the API stored event %1', Locked = true;
    begin
        for i := FromEvent to ToEvent do begin
            BillingQueueEntry.SetRange("Event ID", EventIds.Get(i));
            BillingQueueEntry.FindFirst();
            _Assert.IsTrue(BillingQueueEntry.Status = BillingQueueEntry.Status::Done, StrSubstNo(EventNotDoneLbl, i));
            _Assert.AreEqual(ExpectedStoredCount, MockBillingApi.StoredCount(EventIds.Get(i)), StrSubstNo(StoredCountLbl, i));
        end;
    end;

    local procedure CountEntries(Status: Enum "NPR Billing Queue Status"): Integer
    var
        BillingQueueEntry: Record "NPR Billing Queue Entry";
    begin
        BillingQueueEntry.SetRange(Status, Status);
        exit(BillingQueueEntry.Count());
    end;
}

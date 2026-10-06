codeunit 85493 "NPR ES Offline Invoice Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Item: Record Item;
        _ESClient: Record "NPR ES Client";
        _ESOrganization: Record "NPR ES Organization";
        _POSPaymentMethod: Record "NPR POS Payment Method";
        _POSUnit: Record "NPR POS Unit";
        _Salesperson: Record "Salesperson/Purchaser";
        _Assert: Codeunit Assert;
        _POSSession: Codeunit "NPR POS Session";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure SaleIsIssuedOfflineWhenFiskalyIsUnavailable()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        // [SCENARIO] Fiskaly answers with a server error when the sale ends, so the invoice is issued offline instead of being lost
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Ending a cash sale while Fiskaly is unavailable
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        GetAuxInfo(DoItemSale(ESFiscalLibrary), ESPOSAuditLogAuxInfo);

        // [THEN] The invoice is issued offline with a consumed number and is waiting for submission
        AssertIssuedOffline(ESPOSAuditLogAuxInfo, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure SaleIsIssuedOfflineWhenFiskalyDoesNotRespond()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        // [SCENARIO] No response is received from Fiskaly (connection failure or timeout), so the invoice is issued offline
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Ending a cash sale while Fiskaly cannot be reached
        ESFiscalLibrary.SetSimulatedFiskalyFailure(0);
        GetAuxInfo(DoItemSale(ESFiscalLibrary), ESPOSAuditLogAuxInfo);

        // [THEN] The invoice is issued offline
        AssertIssuedOffline(ESPOSAuditLogAuxInfo, 1);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,AfterEndSaleErrorMessageHandler')]
    procedure SaleIsNotIssuedOfflineWhenFiskalyRejectsInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        // [SCENARIO] Fiskaly rejects the invoice as invalid, which is not an outage, so it must not be issued offline
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Ending a cash sale and Fiskaly answers with a validation error
        ESFiscalLibrary.SetSimulatedFiskalyFailure(400);
        GetAuxInfo(DoItemSale(ESFiscalLibrary), ESPOSAuditLogAuxInfo);

        // [THEN] The invoice is neither created nor issued offline, and no invoice number is consumed
        _Assert.IsFalse(ESPOSAuditLogAuxInfo."Issued Offline", 'Invoice rejected by Fiskaly must not be issued offline.');
        _Assert.AreEqual('', ESPOSAuditLogAuxInfo."Invoice No.", 'Invoice number must not be consumed for a rejected invoice.');
        _Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State"::" ", ESPOSAuditLogAuxInfo."Invoice State", 'Invoice must not be created.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure NextSaleIsIssuedOfflineWhileBacklogCannotBeSubmitted()
    var
        FirstESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        SecondESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        FirstPOSEntryNo: Integer;
    begin
        // [SCENARIO] While the outage lasts, later invoices are also issued offline so Fiskaly receives them in order
        // [GIVEN] POS and ES audit setup and an invoice issued offline
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        FirstPOSEntryNo := DoItemSale(ESFiscalLibrary);
        MakeSaleRetryDue(FirstPOSEntryNo);

        // [WHEN] Ending another sale while Fiskaly is still unavailable
        GetAuxInfo(DoItemSale(ESFiscalLibrary), SecondESPOSAuditLogAuxInfo);

        // [THEN] The backlog was retried once and the new invoice is issued offline with the next number
        GetAuxInfo(FirstPOSEntryNo, FirstESPOSAuditLogAuxInfo);
        AssertIssuedOffline(FirstESPOSAuditLogAuxInfo, 2);
        AssertIssuedOffline(SecondESPOSAuditLogAuxInfo, 0);
        _Assert.AreEqual(IncStr(FirstESPOSAuditLogAuxInfo."Invoice No."), SecondESPOSAuditLogAuxInfo."Invoice No.", 'Offline invoice numbers must be correlative.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure BacklogIsSubmittedBeforeNextSaleWhenFiskalyIsBack()
    var
        FirstESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        SecondESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        FirstPOSEntryNo: Integer;
    begin
        // [SCENARIO] Once Fiskaly is reachable again, the next sale submits the backlog first and is then created online
        // [GIVEN] POS and ES audit setup and an invoice issued offline
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        FirstPOSEntryNo := DoItemSale(ESFiscalLibrary);
        MakeSaleRetryDue(FirstPOSEntryNo);

        // [WHEN] Ending another sale after Fiskaly is available again
        ESFiscalLibrary.ClearSimulatedFiskalyFailure();
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        GetAuxInfo(DoItemSale(ESFiscalLibrary), SecondESPOSAuditLogAuxInfo);

        // [THEN] The offline invoice is accepted by Fiskaly and the new invoice is created online
        GetAuxInfo(FirstPOSEntryNo, FirstESPOSAuditLogAuxInfo);
        _Assert.IsTrue(FirstESPOSAuditLogAuxInfo."Issued Offline", 'Offline invoice must keep its offline marker.');
        _Assert.AreEqual(FirstESPOSAuditLogAuxInfo."Invoice State"::ISSUED, FirstESPOSAuditLogAuxInfo."Invoice State", 'Offline invoice must be submitted before the next sale.');
        _Assert.AreEqual(1, ESFiscalLibrary.GetSubmittedOfflineInvoiceCount(), 'Offline invoice must be submitted exactly once.');
        _Assert.IsFalse(SecondESPOSAuditLogAuxInfo."Issued Offline", 'Invoice must be created online once the backlog is cleared.');
        _Assert.AreEqual(SecondESPOSAuditLogAuxInfo."Invoice State"::ISSUED, SecondESPOSAuditLogAuxInfo."Invoice State", 'Invoice must be created online once the backlog is cleared.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure JobQueueSubmitsOfflineInvoiceWithIncidentAnnotation()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESOfflineInvoiceMgt: Codeunit "NPR ES Offline Invoice Mgt.";
        RequestBody: JsonObject;
        POSEntryNo: Integer;
    begin
        // [SCENARIO] The job queue submits invoices issued offline with the Verifactu incident annotation and the original issue time
        // [GIVEN] POS and ES audit setup and an invoice issued offline
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        POSEntryNo := DoItemSale(ESFiscalLibrary);

        // [WHEN] Fiskaly is available again and the job queue runs
        ESFiscalLibrary.ClearSimulatedFiskalyFailure();
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        BindSubscription(ESFiscalLibrary);
        Codeunit.Run(Codeunit::"NPR ES Retrieve Pending Inv JQ");
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] The invoice is accepted by Fiskaly
        GetAuxInfo(POSEntryNo, ESPOSAuditLogAuxInfo);
        _Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State"::ISSUED, ESPOSAuditLogAuxInfo."Invoice State", 'Offline invoice must be submitted by the job queue.');
        _Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Registration State"::REGISTERED, ESPOSAuditLogAuxInfo."Invoice Registration State", 'Offline invoice must be registered.');
        _Assert.IsFalse(ESPOSAuditLogAuxInfo.IsPendingOfflineSubmission(), 'Offline invoice must no longer be pending.');
        AssertIssuedAtMatchesOfflineIssuedAt(ESPOSAuditLogAuxInfo);

        // [THEN] The request reuses the offline number and issue time and carries the incident annotation
        RequestBody.ReadFrom(ESFiscalLibrary.GetLastSubmittedOfflineInvoiceBody());
        _Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice No.", GetJsonText(RequestBody, '$.content.number'), 'Offline invoice must be submitted with the number printed on the receipt.');
        _Assert.AreEqual(ESOfflineInvoiceMgt.GetLocalIssuedAtTimestamp(ESPOSAuditLogAuxInfo."Offline Issued At", _ESOrganization), GetJsonText(RequestBody, '$.content.issued_at'), 'Offline invoice must be submitted with the offline issue time.');
        _Assert.AreEqual('INCIDENT', GetJsonText(RequestBody, '$.annotations[0].type'), 'Offline invoice must carry the incident annotation.');
        _Assert.AreEqual('OFFLINE', GetJsonText(RequestBody, '$.annotations[0].incident_type'), 'Incident annotation must mark the invoice as issued offline.');
        _Assert.AreNotEqual('', GetJsonText(RequestBody, '$.annotations[0].reason'), 'Incident annotation must have a reason.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure JobQueueFailsWhenFiskalyRejectsOfflineInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSEntryNo: Integer;
    begin
        // [SCENARIO] Fiskaly rejects an offline invoice for a reason other than an outage, so the job queue must fail to raise an alert
        // [GIVEN] POS and ES audit setup and an invoice issued offline
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        POSEntryNo := DoItemSale(ESFiscalLibrary);

        // [WHEN] The job queue runs and Fiskaly rejects the invoice as invalid
        ESFiscalLibrary.SetSimulatedFiskalyFailure(400);
        BindSubscription(ESFiscalLibrary);
        asserterror Codeunit.Run(Codeunit::"NPR ES Retrieve Pending Inv JQ");
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] The run fails and the invoice stays pending with the rejection recorded
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'could not be submitted to Fiskaly') > 0, 'Job queue must fail when an offline invoice is rejected.');
        GetAuxInfo(POSEntryNo, ESPOSAuditLogAuxInfo);
        _Assert.IsTrue(ESPOSAuditLogAuxInfo.IsPendingOfflineSubmission(), 'Rejected offline invoice must stay pending.');
        _Assert.AreEqual(2, ESPOSAuditLogAuxInfo."Submission Attempts", 'Rejected submission must be counted.');
        _Assert.IsTrue(StrPos(ESPOSAuditLogAuxInfo."Last Submission Error", 'Submit offline invoice failed.') > 0, 'Rejection must be stored on the invoice.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure JobQueueSucceedsWhileFiskalyIsStillUnavailable()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSEntryNo: Integer;
    begin
        // [SCENARIO] An outage is expected, so the job queue retries quietly instead of failing
        // [GIVEN] POS and ES audit setup and an invoice issued offline
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        POSEntryNo := DoItemSale(ESFiscalLibrary);

        // [WHEN] The job queue runs while Fiskaly is still unavailable
        BindSubscription(ESFiscalLibrary);
        Codeunit.Run(Codeunit::"NPR ES Retrieve Pending Inv JQ");
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] The attempt is recorded and the invoice stays pending
        GetAuxInfo(POSEntryNo, ESPOSAuditLogAuxInfo);
        AssertIssuedOffline(ESPOSAuditLogAuxInfo, 2);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure RejectedOfflineInvoiceKeepsLaterSalesOffline()
    var
        SecondESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        // [SCENARIO] A rejected offline invoice keeps blocking its POS unit so Fiskaly still receives the invoices in order
        // [GIVEN] POS and ES audit setup and an invoice issued offline
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        MakeSaleRetryDue(DoItemSale(ESFiscalLibrary));

        // [WHEN] Fiskaly is back but rejects the offline invoice, and another sale ends
        ESFiscalLibrary.SetSimulatedFiskalyFailure(400);
        GetAuxInfo(DoItemSale(ESFiscalLibrary), SecondESPOSAuditLogAuxInfo);

        // [THEN] The new invoice is issued offline behind the rejected one and carries the rejection as its reason
        AssertIssuedOffline(SecondESPOSAuditLogAuxInfo, 0);
        _Assert.IsTrue(StrPos(SecondESPOSAuditLogAuxInfo."Last Submission Error", 'Submit offline invoice failed.') > 0, 'Held invoice must carry the error of the invoice that blocks the backlog.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure NextSaleSkipsBacklogRetryShortlyAfterFailedAttempt()
    var
        FirstESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        SecondESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        FirstPOSEntryNo: Integer;
    begin
        // [SCENARIO] Right after a failed attempt the sale does not retry the backlog, so a hanging Fiskaly does not block every sale
        // [GIVEN] POS and ES audit setup and an invoice that just failed to reach Fiskaly
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        FirstPOSEntryNo := DoItemSale(ESFiscalLibrary);

        // [WHEN] Fiskaly is available again and another sale ends immediately
        ESFiscalLibrary.ClearSimulatedFiskalyFailure();
        GetAuxInfo(DoItemSale(ESFiscalLibrary), SecondESPOSAuditLogAuxInfo);

        // [THEN] The backlog is left to the job queue and the new invoice is issued offline behind it
        GetAuxInfo(FirstPOSEntryNo, FirstESPOSAuditLogAuxInfo);
        AssertIssuedOffline(FirstESPOSAuditLogAuxInfo, 1);
        AssertIssuedOffline(SecondESPOSAuditLogAuxInfo, 0);
        _Assert.AreEqual(0, ESFiscalLibrary.GetSubmittedOfflineInvoiceCount(), 'Backlog must not be retried on the sale right after a failed attempt.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure JobQueueResolvesConflictByRetrievingInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSEntryNo: Integer;
    begin
        // [SCENARIO] Fiskaly already holds the offline invoice (e.g. the original request timed out after it was stored), so the 409 is resolved by retrieving it
        // [GIVEN] POS and ES audit setup and an invoice issued offline
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        POSEntryNo := DoItemSale(ESFiscalLibrary);

        // [WHEN] The job queue resubmits it and Fiskaly answers with a conflict
        ESFiscalLibrary.SetSimulatedFiskalyFailure(409);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        BindSubscription(ESFiscalLibrary);
        Codeunit.Run(Codeunit::"NPR ES Retrieve Pending Inv JQ");
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] The invoice is taken over from Fiskaly and no longer pending
        GetAuxInfo(POSEntryNo, ESPOSAuditLogAuxInfo);
        _Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State"::ISSUED, ESPOSAuditLogAuxInfo."Invoice State", 'Conflicting offline invoice must be retrieved from Fiskaly.');
        _Assert.IsFalse(ESPOSAuditLogAuxInfo.IsPendingOfflineSubmission(), 'Conflicting offline invoice must no longer be pending.');
        _Assert.AreEqual(1, ESPOSAuditLogAuxInfo."Submission Attempts", 'Resolved conflict must not count as a failed attempt.');
        AssertIssuedAtMatchesOfflineIssuedAt(ESPOSAuditLogAuxInfo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,AfterEndSaleErrorMessageHandler')]
    procedure SaleIsNotIssuedOfflineInTicketBAITerritory()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        // [SCENARIO] TicketBAI requires a special incident series and notifying the tax authority during an outage, so the Verifactu offline fallback must not be used
        // [GIVEN] POS and ES audit setup in a Basque TicketBAI territory
        InitializeData();
        _ESOrganization."Taxpayer Territory" := _ESOrganization."Taxpayer Territory"::GIPUZKOA;
        _ESOrganization.Modify();
        Commit();

        // [WHEN] Ending a cash sale while Fiskaly is unavailable
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        GetAuxInfo(DoItemSale(ESFiscalLibrary), ESPOSAuditLogAuxInfo);

        // [THEN] The invoice is neither created nor issued offline, and no invoice number is consumed
        _Assert.IsFalse(ESPOSAuditLogAuxInfo."Issued Offline", 'Invoice in a TicketBAI territory must not be issued offline.');
        _Assert.AreEqual('', ESPOSAuditLogAuxInfo."Invoice No.", 'Invoice number must not be consumed when the invoice is not issued offline.');
        _Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State"::" ", ESPOSAuditLogAuxInfo."Invoice State", 'Invoice must not be created.');
    end;

    local procedure MakeSaleRetryDue(POSEntryNo: Integer)
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
    begin
        // Pretend the last failed attempt is old enough for the sale path to retry the backlog again
        GetAuxInfo(POSEntryNo, ESPOSAuditLogAuxInfo);
        ESPOSAuditLogAuxInfo."Last Submission Attempt At" := CurrentDateTime() - 10 * 60 * 1000;
        ESPOSAuditLogAuxInfo.Modify();
        Commit();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,AfterEndSaleErrorMessageHandler')]
    procedure ManualCreateIsRefusedWhileOfflineInvoicesArePending()
    var
        RejectedESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        RejectedPOSEntryNo: Integer;
    begin
        // [SCENARIO] Creating an earlier rejected invoice by hand must not overtake invoices that wait for submission
        // [GIVEN] POS and ES audit setup, an invoice rejected by Fiskaly and a later invoice issued offline
        InitializeData();
        ESFiscalLibrary.SetSimulatedFiskalyFailure(400);
        RejectedPOSEntryNo := DoItemSale(ESFiscalLibrary);
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        DoItemSale(ESFiscalLibrary);

        // [WHEN] Fiskaly is available again and the rejected invoice is created from the audit log page
        ESFiscalLibrary.ClearSimulatedFiskalyFailure();
        GetAuxInfo(RejectedPOSEntryNo, RejectedESPOSAuditLogAuxInfo);
        BindSubscription(ESFiscalLibrary);
        asserterror ESFiskalyCommunication.CreateInvoice(RejectedESPOSAuditLogAuxInfo);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] Creation is refused until the offline invoices are submitted
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Use Submit Offline Invoice first.') > 0, 'Manual create must be refused while offline invoices are pending.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure OfflineInvoiceHasLocalAEATValidationUrl()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        ESOfflineInvoiceMgt: Codeunit "NPR ES Offline Invoice Mgt.";
        ExpectedUrl: Text;
        IssuedAtTimestamp: Text;
    begin
        // [SCENARIO] The receipt of an offline invoice gets the AEAT validation QR code built locally, as described by Fiskaly for offline cases
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Ending a cash sale while Fiskaly is unavailable
        ESFiscalLibrary.SetSimulatedFiskalyFailure(503);
        GetAuxInfo(DoItemSale(ESFiscalLibrary), ESPOSAuditLogAuxInfo);

        // [THEN] The validation url points to the AEAT test environment with nif, numserie, fecha and importe in that order
        IssuedAtTimestamp := ESOfflineInvoiceMgt.GetLocalIssuedAtTimestamp(ESPOSAuditLogAuxInfo."Offline Issued At", _ESOrganization);
        ExpectedUrl := 'https://prewww2.aeat.es/wlpl/TIKE-CONT/ValidarQR?nif=' + GetCompanyVATRegistrationNo() +
            '&numserie=' + ESPOSAuditLogAuxInfo."Invoice No." +
            '&fecha=' + CopyStr(IssuedAtTimestamp, 9, 2) + '-' + CopyStr(IssuedAtTimestamp, 6, 2) + '-' + CopyStr(IssuedAtTimestamp, 1, 4) +
            '&importe=' + Format(ESPOSAuditLogAuxInfo."Amount Incl. Tax", 0, '<Precision,2:2><Standard Format,2>');
        _Assert.AreEqual(ExpectedUrl, ESPOSAuditLogAuxInfo."Validation URL", 'Offline validation url must follow the AEAT format.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure LocalIssuedAtTimestampUsesSpanishTimeZones()
    var
        TestESOrganization: Record "NPR ES Organization";
        ESOfflineInvoiceMgt: Codeunit "NPR ES Offline Invoice Mgt.";
        SummerIssuedAt: DateTime;
        WinterIssuedAt: DateTime;
    begin
        // [SCENARIO] Fiskaly needs the local time of the issuing location with its UTC offset, including daylight saving time
        // [GIVEN] Issue times in summer and in winter
        Evaluate(SummerIssuedAt, '2026-07-15T10:00:00Z', 9);
        Evaluate(WinterIssuedAt, '2026-01-15T10:00:00Z', 9);

        // [WHEN] [THEN] Mainland Spain uses Europe/Madrid time
        TestESOrganization."Taxpayer Territory" := TestESOrganization."Taxpayer Territory"::SPAIN_OTHER;
        _Assert.AreEqual('2026-07-15T12:00:00+02:00', ESOfflineInvoiceMgt.GetLocalIssuedAtTimestamp(SummerIssuedAt, TestESOrganization), 'Mainland summer time must be UTC+2.');
        _Assert.AreEqual('2026-01-15T11:00:00+01:00', ESOfflineInvoiceMgt.GetLocalIssuedAtTimestamp(WinterIssuedAt, TestESOrganization), 'Mainland winter time must be UTC+1.');

        // [WHEN] [THEN] The Canary Islands use Atlantic/Canary time
        TestESOrganization."Taxpayer Territory" := TestESOrganization."Taxpayer Territory"::CANARY_ISLANDS;
        _Assert.AreEqual('2026-07-15T11:00:00+01:00', ESOfflineInvoiceMgt.GetLocalIssuedAtTimestamp(SummerIssuedAt, TestESOrganization), 'Canary Islands summer time must be UTC+1.');
        _Assert.AreEqual('2026-01-15T10:00:00+00:00', ESOfflineInvoiceMgt.GetLocalIssuedAtTimestamp(WinterIssuedAt, TestESOrganization), 'Canary Islands winter time must be UTC+0.');
    end;

    local procedure AssertIssuedOffline(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info"; ExpectedSubmissionAttempts: Integer)
    begin
        _Assert.IsTrue(ESPOSAuditLogAuxInfo."Issued Offline", 'Invoice must be issued offline.');
        _Assert.IsTrue(ESPOSAuditLogAuxInfo.IsPendingOfflineSubmission(), 'Offline invoice must wait for submission.');
        _Assert.AreNotEqual('', ESPOSAuditLogAuxInfo."Invoice No.", 'Offline invoice must have a number.');
        _Assert.AreNotEqual(0DT, ESPOSAuditLogAuxInfo."Offline Issued At", 'Offline invoice must have an issue time.');
        _Assert.AreEqual(ExpectedSubmissionAttempts, ESPOSAuditLogAuxInfo."Submission Attempts", 'Unexpected number of submission attempts.');
        _Assert.AreNotEqual('', ESPOSAuditLogAuxInfo."Last Submission Error", 'Reason for offline issuing must be stored.');
        _Assert.AreNotEqual('', ESPOSAuditLogAuxInfo."Validation URL", 'Offline invoice must have a local validation url.');
    end;

    local procedure AssertIssuedAtMatchesOfflineIssuedAt(ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    var
        Difference: Duration;
    begin
        // Fiskaly returns the offline issue time with timezone and without milliseconds
        Difference := ESPOSAuditLogAuxInfo."Issued At" - ESPOSAuditLogAuxInfo."Offline Issued At";
        _Assert.IsTrue((Difference > -1000) and (Difference < 1000), 'Issued At returned by Fiskaly must be the offline issue time.');
    end;

    local procedure GetAuxInfo(POSEntryNo: Integer; var ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info")
    begin
        ESPOSAuditLogAuxInfo.Reset();
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        ESPOSAuditLogAuxInfo.FindFirst();
    end;

    local procedure GetJsonText(JsonObj: JsonObject; Path: Text): Text
    var
        JToken: JsonToken;
    begin
        if not JsonObj.SelectToken(Path, JToken) then
            exit('');
        exit(JToken.AsValue().AsText());
    end;

    local procedure GetCompanyVATRegistrationNo(): Text
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        exit(CompanyInformation."VAT Registration No.");
    end;

    local procedure DoItemSale(var ESFiscalLibrary: Codeunit "NPR Library ES Fiscal"): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(_POSSession, _POSUnit, _Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(_POSSession, _Item."No.", 1);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(_POSSession, _POSPaymentMethod.Code, _Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);
        UnbindSubscription(ESFiscalLibrary);

        // The sale must be posted regardless of the Fiskaly outcome
        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        _POSSession.ClearAll();
        Clear(_POSSession);
        exit(POSEntry."Entry No.");
    end;

    [ConfirmHandler]
    procedure GeneralConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        CreateCompleteInvoiceQst: Label 'Do you want to create complete invoice?', Locked = true;
        QuestionNotExpectedErr: Label 'Question "%1" is not expected.', Locked = true;
    begin
        case true of
            Question = CreateCompleteInvoiceQst:
                Reply := false;
            else
                Error(QuestionNotExpectedErr, Question);
        end;
    end;

    [MessageHandler]
    procedure AfterEndSaleErrorMessageHandler(Message: Text[1024])
    var
        UnexpectedMessageErr: Label 'Message "%1" is not expected.', Locked = true;
    begin
        if StrPos(Message, 'Create invoice failed.') = 0 then
            Error(UnexpectedMessageErr, Message);
    end;

    local procedure InitializeData()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESSigner: Record "NPR ES Signer";
        VoucherTypeDefault: Record "NPR NpRv Voucher Type";
        POSAuditLog: Record "NPR POS Audit Log";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSStore: Record "NPR POS Store";
        ReturnReason: Record "Return Reason";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        POSMasterDataLibrary: Codeunit "NPR Library - POS Master Data";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
    begin
        if _Initialized then begin
            // Clean any previous mock session
            _POSSession.ClearAll();
            Clear(_POSSession);
        end else begin
            POSMasterDataLibrary.CreatePOSSetup(POSSetup);
            POSMasterDataLibrary.CreateDefaultVoucherType(VoucherTypeDefault, false);
            POSMasterDataLibrary.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSUnit(_POSUnit, POSStore.Code, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSPaymentMethod(_POSPaymentMethod, _POSPaymentMethod."Processing Type"::CASH, '', false);
            POSMasterDataLibrary.CreateItemForPOSSaleUsage(_Item, _POSUnit, POSStore);
            CreateSalesperson();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            _Item."Unit Price" := 10;
            _Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", _Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();
            ESFiscalLibrary.CreateAuditProfileAndESSetups(POSAuditProfile, VATPostingSetup, _POSUnit);
            // Verifactu territory validated by AEAT, so offline invoices get the incident annotation and a local QR code
            ESFiscalLibrary.CreateESOrganization(_ESOrganization, Enum::"NPR ES Taxpayer Territory"::SPAIN_OTHER, Enum::"NPR ES Taxpayer Type"::COMPANY);
            // Tax number of the software producer as retrieved from Fiskaly; the offline QR code must not use it as issuer tax number
            _ESOrganization."Company Tax Number" := 'B99999999';
            _ESOrganization.Modify();
            ESFiscalLibrary.CreateESSigner(ESSigner, _ESOrganization.Code);
            ESFiscalLibrary.CreateESClient(_ESClient, ESSigner, _POSUnit."No.", _ESOrganization.Code);

            _Initialized := true;
        end;

        // Tests may switch the territory, so every test starts in a Verifactu territory validated by AEAT
        _ESOrganization.Get(_ESOrganization.Code);
        _ESOrganization."Taxpayer Territory" := _ESOrganization."Taxpayer Territory"::SPAIN_OTHER;
        _ESOrganization.Modify();

        // Clean between tests, a pending offline invoice would otherwise force the next sale offline
        ESPOSAuditLogAuxInfo.SetPendingOfflineSubmissionFilter();
        ESPOSAuditLogAuxInfo.DeleteAll();
        POSAuditLog.DeleteAll(true);
        Commit();
    end;

    local procedure CreateSalesperson()
    begin
        if not _Salesperson.Get('1') then begin
            _Salesperson.Init();
            _Salesperson.Validate(Code, '1');
            _Salesperson.Validate(Name, 'Test');
            _Salesperson.Insert();
        end;
        _Salesperson."NPR Register Password" := '1';
        _Salesperson.Modify();
    end;
}

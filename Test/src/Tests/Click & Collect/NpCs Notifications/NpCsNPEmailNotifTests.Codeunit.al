codeunit 85252 "NPR NpCs NPEmail Notif Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ResolvesTemplateForCurrentStatus()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NotifMock: Codeunit "NPR NpCs NPEmail Notif Mock";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        CnCTemplateId: Code[20];
    begin
        // [Given] the NP Email + New Email Experience features are enabled
        NewEmailExpFeature.SetFeatureEnabled(true);
        // [Given] a Click & Collect template wired to the Confirmed status
        CnCTemplateId := 'CNC-CONFIRMED';
        CreateEmailTemplate(CnCTemplateId, "NPR DynTemplateDataProvider"::CLICK_COLLECT_NOTIFICATION);
        CreateCnCDocument(NpCsDocument, NpCsDocument."Processing Status"::Confirmed);
        NpCsDocument."NP E-mail Template (Confirmed)" := CnCTemplateId;
        NpCsDocument.Modify();

        // [When] the customer NP Email notification runs (send intercepted)
        BindSubscription(NotifMock);
        RunCustomerEmailNotification(NpCsDocument);
        UnbindSubscription(NotifMock);

        // [Then] the Confirmed-status template is resolved and handed to the send hook, with the customer e-mail
        Assert.IsTrue(NotifMock.Fired(), 'The NP Email send hook should have been reached.');
        Assert.AreEqual(CnCTemplateId, NotifMock.ResolvedTemplateId(), 'The Confirmed status template should have been resolved.');
        Assert.AreEqual(NpCsDocument."Customer E-mail", NotifMock.CapturedEmail(), 'The customer e-mail should have been passed to the send hook.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RejectsTemplateFromAnotherProvider()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NotifMock: Codeunit "NPR NpCs NPEmail Notif Mock";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        WrongProviderTemplateId: Code[20];
    begin
        // [Given] the features are enabled
        NewEmailExpFeature.SetFeatureEnabled(true);
        // [Given] a template that belongs to another data provider (Ticket, not Click & Collect)
        WrongProviderTemplateId := 'WRONG-PROVIDER';
        CreateEmailTemplate(WrongProviderTemplateId, "NPR DynTemplateDataProvider"::TICKET_NOTIFICATION);
        // [Given] a Confirmed C&C document pointing at it (as an imported document could, bypassing the TableRelation)
        CreateCnCDocument(NpCsDocument, NpCsDocument."Processing Status"::Confirmed);
        NpCsDocument."NP E-mail Template (Confirmed)" := WrongProviderTemplateId;
        NpCsDocument.Modify();

        // [When] the notification runs
        BindSubscription(NotifMock);
        RunCustomerEmailNotification(NpCsDocument);
        UnbindSubscription(NotifMock);

        // [Then] the send hook is never reached, and the mismatch is logged as an error
        Assert.IsFalse(NotifMock.Fired(), 'A template from another data provider must not reach the NP Email send hook.');
        Assert.AreEqual(1, ErrorLogEntryCount(NpCsDocument), 'The wrong-provider template should be logged as an error.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure SkipsBlankStatusTemplateWithoutError()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NotifMock: Codeunit "NPR NpCs NPEmail Notif Mock";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        CnCTemplateId: Code[20];
    begin
        // [Given] the features are enabled
        NewEmailExpFeature.SetFeatureEnabled(true);
        // [Given] only the Confirmed template is configured; the Rejected status template is left blank
        CnCTemplateId := 'CNC-CONFIRMED';
        CreateEmailTemplate(CnCTemplateId, "NPR DynTemplateDataProvider"::CLICK_COLLECT_NOTIFICATION);
        CreateCnCDocument(NpCsDocument, NpCsDocument."Processing Status"::Rejected);
        NpCsDocument."NP E-mail Template (Confirmed)" := CnCTemplateId;
        NpCsDocument.Modify();

        // [When] the notification runs while the document is in the (unconfigured) Rejected status
        BindSubscription(NotifMock);
        RunCustomerEmailNotification(NpCsDocument);
        UnbindSubscription(NotifMock);

        // [Then] a blank per-status template is treated as "don't notify for this status": nothing sent, nothing logged
        Assert.IsFalse(NotifMock.Fired(), 'A blank template for the current status should skip the notification.');
        Assert.AreEqual(0, ErrorLogEntryCount(NpCsDocument), 'A blank per-status template should not log an error while other templates are configured.');
    end;

    local procedure CreateEmailTemplate(TemplateId: Code[20]; DataProvider: Enum "NPR DynTemplateDataProvider")
    var
        NPEmailTemplate: Record "NPR NPEmailTemplate";
    begin
        // Isolation for this runner is per-codeunit, so a template created in an earlier [Test] is still present
        // here. Make creation idempotent so tests that reuse a template code don't collide on insert.
        if NPEmailTemplate.Get(TemplateId) then
            NPEmailTemplate.Delete();
        NPEmailTemplate.Init();
        NPEmailTemplate.TemplateId := TemplateId;
        NPEmailTemplate.DataProvider := DataProvider;
        NPEmailTemplate.Insert(true);
    end;

    local procedure CreateCnCDocument(var NpCsDocument: Record "NPR NpCs Document"; ProcessingStatus: Integer)
    begin
        NpCsDocument.Init();
        NpCsDocument."Entry No." := 0;
        NpCsDocument.Type := NpCsDocument.Type::"Collect in Store";
        NpCsDocument."Customer E-mail" := 'customer@example.com';
        NpCsDocument."Notify Customer via E-mail" := true;
        NpCsDocument."Enable NP Email" := true;
        NpCsDocument."Processing Status" := ProcessingStatus;
        NpCsDocument.Insert(true);
    end;

    local procedure RunCustomerEmailNotification(NpCsDocument: Record "NPR NpCs Document")
    var
        RunWorkflowStep: Codeunit "NPR NpCs Run Workflow Step";
    begin
        RunWorkflowStep.SetWorkflowFunctionType(5); // "Send Notification to Customer"
        RunWorkflowStep.SetNotificationType(1); // Email
        RunWorkflowStep.Run(NpCsDocument);
    end;

    local procedure ErrorLogEntryCount(NpCsDocument: Record "NPR NpCs Document"): Integer
    var
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
    begin
        NpCsDocumentLogEntry.SetRange("Document Entry No.", NpCsDocument."Entry No.");
        NpCsDocumentLogEntry.SetRange("Error Entry", true);
        exit(NpCsDocumentLogEntry.Count());
    end;
}

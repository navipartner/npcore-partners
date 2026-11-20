codeunit 85252 "NPR NpCs NPEmail Notif Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Assert";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistingCustomerNPEmailWorksWithoutClickCollectFeature()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NotifMock: Codeunit "NPR NpCs NPEmail Notif Mock";
        CnCTemplateId: Code[20];
    begin
        // [Given] NP Email and New Email Experience are enabled, but the new Click & Collect feature is disabled
        SetNPEmailFeatures(false);
        // [Given] a Click & Collect template wired to the Confirmed status
        CnCTemplateId := 'CNC-CONFIRMED';
        CreateEmailTemplate(CnCTemplateId, "NPR DynTemplateDataProvider"::CLICK_COLLECT_NOTIFICATION);
        CreateCnCDocument(NpCsDocument, NpCsDocument."Processing Status"::Confirmed);
        // [Given] the existing document opted into customer NP Email and has no legacy template
        NpCsDocument."Enable NP Email" := true;
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
        WrongProviderTemplateId: Code[20];
    begin
        // [Given] the features are enabled
        SetNPEmailFeatures(true);
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
        CnCTemplateId: Code[20];
    begin
        // [Given] the features are enabled
        SetNPEmailFeatures(true);
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

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenNpEmailEnabled_WhenBuildingAndImportingCollectOrder_ThenTagsEmittedAndAccepted()
    var
        NpCsDocument: Record "NPR NpCs Document";
        TempSalesHeader: Record "Sales Header" temporary;
        NpCsSendOrder: Codeunit "NPR NpCs Send Order";
        ReExportedXml: Text;
        RequestBody: Text;
    begin
        // [Given] all three features are enabled, the obsolete checkbox is false, and customer and store templates are set
        CreateSendToStoreCollectDocument(NpCsDocument, true);
        // [Given] store email notifications are enabled on the source document
        NpCsDocument."Notify Store via E-mail" := true;
        NpCsDocument.Modify();

        // [When] the request body is built by the sender and its sales_document payload imported through the receiver xmlport
        NpCsSendOrder.InitReqBody(NpCsDocument, RequestBody);
        ImportThroughReceiverXmlport(RequestBody, TempSalesHeader, ReExportedXml);

        // [Then] the NP Email block was emitted and the receiver schema accepted the payload
        Assert.IsTrue(StrPos(RequestBody, '<enable_np_email>') > 0, 'The NP Email block should be emitted when all three features are enabled.');
        Assert.IsTrue(StrPos(ReExportedXml, 'STORE-PENDING') > 0, 'The receiver must preserve the store Pending template.');
        Assert.IsTrue(StrPos(ReExportedXml, 'STORE-EXPIRED') > 0, 'The receiver must preserve the store Expired template.');
        Assert.IsTrue(TempSalesHeader.FindFirst(), 'The receiver xmlport should have imported the collect sales document.');
        Assert.AreEqual(NpCsDocument."Document No.", TempSalesHeader."No.", 'The imported sales document should match the collect document No.');
        // The re-export consumed by the receiving import entry must retain the customer templates.
        Assert.IsTrue(StrPos(ReExportedXml, 'CNC-CONFIRMED') > 0, 'The re-exported document should carry the NP Email templates.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure ExistingCustomerNPSettingsSurviveExportWithoutSenderFeatures()
    var
        NpCsDocument: Record "NPR NpCs Document";
        TempSalesHeader: Record "Sales Header" temporary;
        NpCsSendOrder: Codeunit "NPR NpCs Send Order";
        NPEmailFeature: Codeunit "NPR NP Email Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        ReExportedXml: Text;
        RequestBody: Text;
    begin
        // [Given] an existing document opted into customer NP Email with customer and store templates configured
        CreateSendToStoreCollectDocument(NpCsDocument, false);
        // [Given] the receiving store owns notifications and all sender NP Email features are disabled
        NpCsDocument."Send Notification from Store" := true;
        NpCsDocument.Modify();
        NewEmailExpFeature.SetFeatureEnabled(false);
        NPEmailFeature.SetFeatureEnabled(false);

        // [When] the request body is built by the sender and its sales_document payload imported through the receiver xmlport
        NpCsSendOrder.InitReqBody(NpCsDocument, RequestBody);
        ImportThroughReceiverXmlport(RequestBody, TempSalesHeader, ReExportedXml);

        // [Then] the customer NP configuration survives transfer while the new store NP elements are omitted
        Assert.IsTrue(StrPos(RequestBody, '<enable_np_email>true</enable_np_email>') > 0, 'The existing customer NP Email opt-in must survive export.');
        Assert.IsTrue(StrPos(ReExportedXml, '<enable_np_email>true</enable_np_email>') > 0, 'The receiver must preserve the customer NP Email opt-in.');
        Assert.IsTrue(StrPos(ReExportedXml, 'CNC-PENDING') > 0, 'The receiver must preserve the customer Pending template.');
        Assert.IsTrue(StrPos(ReExportedXml, 'CNC-CONFIRMED') > 0, 'The receiver must preserve the customer Confirmed template.');
        Assert.IsTrue(StrPos(ReExportedXml, 'CNC-REJECTED') > 0, 'The receiver must preserve the customer Rejected template.');
        Assert.IsTrue(StrPos(ReExportedXml, 'CNC-EXPIRED') > 0, 'The receiver must preserve the customer Expired template.');
        Assert.AreEqual(0, StrPos(RequestBody, '<store_np_email_template_pending>'), 'The store NP Email block must also be omitted when the Click & Collect feature is disabled.');
        Assert.AreEqual(0, StrPos(RequestBody, '<store_np_email_template_expired>'), 'The store Expired NP template must be omitted when the Click & Collect feature is disabled.');
        Assert.IsTrue(TempSalesHeader.FindFirst(), 'The receiver xmlport should have imported the collect sales document.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StoreDeliveryExpiryOverridesPendingProcessing()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsStore: Record "NPR NpCs Store";
        NotifMock: Codeunit "NPR NpCs NPEmail Notif Mock";
    begin
        // [Given] all three NP Email features are enabled and the obsolete document checkbox is false, with Pending and Expired templates
        // [Given] processing is Pending while delivery is Expired
        CreateStoreNotificationDocument(NpCsDocument);
        NpCsDocument."Delivery Status" := NpCsDocument."Delivery Status"::Expired;
        NpCsDocument.Modify();
        NpCsStore.Get(NpCsDocument."To Store Code");

        // [When] the store notification runs with sending intercepted
        BindSubscription(NotifMock);
        RunStoreEmailNotification(NpCsDocument);
        UnbindSubscription(NotifMock);

        // [Then] the Expired template is selected for the destination store without logging an error
        Assert.IsTrue(NotifMock.Fired(), 'The store NP Email send hook should be reached.');
        Assert.AreEqual(NpCsDocument."Store NP Email Templ (Expired)", NotifMock.ResolvedTemplateId(), 'Delivery expiry must take precedence over pending processing.');
        Assert.AreEqual(NpCsStore."E-mail", NotifMock.CapturedEmail(), 'The notification must be addressed to the destination store.');
        Assert.AreEqual(0, ErrorLogEntryCount(NpCsDocument), 'A successful store notification must not log an error.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledStoreNotificationsDoNotSend()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
        NotifMock: Codeunit "NPR NpCs NPEmail Notif Mock";
    begin
        // [Given] NP Email is enabled but store email notifications are disabled
        CreateStoreNotificationDocument(NpCsDocument);
        NpCsDocument."Notify Store via E-mail" := false;
        NpCsDocument.Modify();
        BindSubscription(NotifMock);

        // [When] the store email notification runs
        RunStoreEmailNotification(NpCsDocument);
        UnbindSubscription(NotifMock);

        // [Then] no email is sent and no success or error log is created
        Assert.IsFalse(NotifMock.Fired(), 'A disabled store notification must not send.');
        NpCsDocumentLogEntry.SetRange("Document Entry No.", NpCsDocument."Entry No.");
        Assert.IsTrue(NpCsDocumentLogEntry.IsEmpty(), 'A skipped store notification must not create success or error logs.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure StoreNPTemplateFromAnotherProviderLogsError()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NPEmailTemplate: Record "NPR NPEmailTemplate";
        NotifMock: Codeunit "NPR NpCs NPEmail Notif Mock";
    begin
        // [Given] the configured store NP Email template belongs to another data provider
        CreateStoreNotificationDocument(NpCsDocument);
        NPEmailTemplate.Get(NpCsDocument."Store NP Email Templ (Pending)");
        NPEmailTemplate.DataProvider := "NPR DynTemplateDataProvider"::TICKET_NOTIFICATION;
        NPEmailTemplate.Modify();
        BindSubscription(NotifMock);

        // [When] the store email notification runs
        RunStoreEmailNotification(NpCsDocument);
        UnbindSubscription(NotifMock);

        // [Then] no email is sent and one error is logged
        Assert.IsFalse(NotifMock.Fired(), 'A template from another data provider must not reach the send hook.');
        Assert.AreEqual(1, ErrorLogEntryCount(NpCsDocument), 'A template from another data provider must log one error.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure DisabledClickCollectFeatureUsesLegacyStoreTemplate()
    var
        NpCsDocument: Record "NPR NpCs Document";
        EmailTemplateHeader: Record "NPR E-mail Template Header";
        LibraryUtility: Codeunit "Library - Utility";
        ClickCollectNPEmailFeature: Codeunit "NPR CnC NP Email Feature";
        NotifMock: Codeunit "NPR NpCs NPEmail Notif Mock";
    begin
        // [Given] NP Email and New Email Experience are enabled, but the Click & Collect feature is disabled
        // [Given] the obsolete document checkbox is true and must not select NP Email
        CreateStoreNotificationDocument(NpCsDocument);
        NpCsDocument."Enable NP Email" := true;
        ClickCollectNPEmailFeature.SetFeatureEnabled(false);
        // [Given] a legacy template for another table, so validation stops before any real email is sent
        EmailTemplateHeader.Code := LibraryUtility.GenerateRandomCode20(EmailTemplateHeader.FieldNo(Code), Database::"NPR E-mail Template Header");
        EmailTemplateHeader."Table No." := Database::Customer;
        EmailTemplateHeader.Insert();
        NpCsDocument."Store E-mail Temp. (Pending)" := EmailTemplateHeader.Code;
        NpCsDocument.Modify();
        BindSubscription(NotifMock);

        // [When] the store email notification runs
        asserterror RunStoreEmailNotification(NpCsDocument);

        // [Then] legacy template validation runs and the NP Email send hook is not reached
        Assert.ExpectedError(EmailTemplateHeader.FieldCaption("Table No."));
        Assert.ExpectedError(EmailTemplateHeader.Code);
        UnbindSubscription(NotifMock);
        Assert.IsFalse(NotifMock.Fired(), 'Disabling the Click & Collect feature must bypass NP Email even when the obsolete document checkbox is true.');
    end;

    local procedure CreateStoreNotificationDocument(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsStore: Record "NPR NpCs Store";
        LibraryClickCollect: Codeunit "NPR Library Click & Collect";
    begin
        SetNPEmailFeatures(true);
        CreateEmailTemplate('STORE-PENDING', "NPR DynTemplateDataProvider"::CLICK_COLLECT_NOTIFICATION);
        CreateEmailTemplate('STORE-EXPIRED', "NPR DynTemplateDataProvider"::CLICK_COLLECT_NOTIFICATION);
        NpCsStore.Get(LibraryClickCollect.CreateLocalCollectStore());
        NpCsStore."E-mail" := 'store@example.com';
        NpCsStore.Modify();
        CreateCnCDocument(NpCsDocument, NpCsDocument."Processing Status"::Pending);
        NpCsDocument."To Store Code" := NpCsStore.Code;
        NpCsDocument."Notify Store via E-mail" := true;
        NpCsDocument."Enable NP Email" := false;
        NpCsDocument."Send Notification from Store" := true;
        NpCsDocument."Store NP Email Templ (Pending)" := 'STORE-PENDING';
        NpCsDocument."Store NP Email Templ (Expired)" := 'STORE-EXPIRED';
        NpCsDocument.Modify();
    end;

    local procedure RunStoreEmailNotification(NpCsDocument: Record "NPR NpCs Document")
    var
        RunWorkflowStep: Codeunit "NPR NpCs Run Workflow Step";
    begin
        RunWorkflowStep.SetWorkflowFunctionType(4); // "Send Notification to Store"
        RunWorkflowStep.SetNotificationType(1); // Email
        RunWorkflowStep.Run(NpCsDocument);
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
        NpCsDocument."Enable NP Email" := false;
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

    local procedure CreateSendToStoreCollectDocument(var NpCsDocument: Record "NPR NpCs Document"; EnableNpEmail: Boolean)
    var
        NpCsWorkflow: Record "NPR NpCs Workflow";
        SalesHeader: Record "Sales Header";
        LibraryClickCollect: Codeunit "NPR Library Click & Collect";
        LibrarySales: Codeunit "Library - Sales";
    begin
        SetNPEmailFeatures(EnableNpEmail);
        CreateWorkflow(NpCsWorkflow);
        LibrarySales.CreateSalesOrder(SalesHeader);

        NpCsDocument.Init();
        NpCsDocument."Entry No." := 0;
        NpCsDocument.Type := NpCsDocument.Type::"Send to Store";
        NpCsDocument."Document Type" := SalesHeader."Document Type";
        NpCsDocument."Document No." := SalesHeader."No.";
        NpCsDocument."Reference No." := SalesHeader."No.";
        NpCsDocument."From Store Code" := LibraryClickCollect.CreateLocalCollectStore();
        NpCsDocument."To Store Code" := LibraryClickCollect.CreateLocalCollectStore();
        NpCsDocument."Workflow Code" := NpCsWorkflow.Code;
        NpCsDocument."Customer E-mail" := 'customer@example.com';
        NpCsDocument."Enable NP Email" := not EnableNpEmail;
        NpCsDocument."NP E-mail Template (Pending)" := 'CNC-PENDING';
        NpCsDocument."NP E-mail Template (Confirmed)" := 'CNC-CONFIRMED';
        NpCsDocument."NP E-mail Template (Rejected)" := 'CNC-REJECTED';
        NpCsDocument."NP E-mail Template (Expired)" := 'CNC-EXPIRED';
        NpCsDocument."Store NP Email Templ (Pending)" := 'STORE-PENDING';
        NpCsDocument."Store NP Email Templ (Expired)" := 'STORE-EXPIRED';
        NpCsDocument.Insert(true);
    end;

    local procedure SetNPEmailFeatures(ClickCollectEnabled: Boolean)
    var
        NPEmailFeature: Codeunit "NPR NP Email Feature";
        NewEmailExpFeature: Codeunit "NPR NewEmailExpFeature";
        ClickCollectNPEmailFeature: Codeunit "NPR CnC NP Email Feature";
    begin
        NewEmailExpFeature.SetFeatureEnabled(true);
        NPEmailFeature.SetFeatureEnabled(true);
        ClickCollectNPEmailFeature.SetFeatureEnabled(ClickCollectEnabled);
    end;

    local procedure CreateWorkflow(var NpCsWorkflow: Record "NPR NpCs Workflow")
    var
        LibraryUtility: Codeunit "Library - Utility";
    begin
        NpCsWorkflow.Init();
        NpCsWorkflow.Validate(Code, LibraryUtility.GenerateRandomCode20(NpCsWorkflow.FieldNo(Code), Database::"NPR NpCs Workflow"));
        NpCsWorkflow.Insert(true);
    end;

    local procedure ImportThroughReceiverXmlport(RequestBody: Text; var TempSalesHeader: Record "Sales Header" temporary; var ReExportedXml: Text)
    var
        TempBLOBbuffer: Record "NPR BLOB buffer" temporary;
        TypeHelper: Codeunit "Type Helper";
        SalesDocXmlPort: XMLport "NPR NpCs Sales Document";
        SoapDocument: XmlDocument;
        SoapRoot: XmlElement;
        SalesDocElement: XmlElement;
        NamespaceMgr: XmlNamespaceManager;
        SalesDocNode: XmlNode;
        IStream: InStream;
        OStream: OutStream;
        SalesDocXml: Text;
        WrappedXml: Text;
        XmlPortNamespace: Text;
    begin
        // Reproduce what the web service host does: strip the SOAP envelope and hand the sales_documents element to the xmlport
        XmlPortNamespace := 'urn:microsoft-dynamics-nav/xmlports/collect_in_store_sales_document';
        XmlDocument.ReadFrom(RequestBody, SoapDocument);
        SoapDocument.GetRoot(SoapRoot);
        NamespaceMgr.NameTable(SoapDocument.NameTable());
        NamespaceMgr.AddNamespace('cis', XmlPortNamespace);
        SoapRoot.SelectSingleNode('.//cis:sales_document', NamespaceMgr, SalesDocNode);
        SalesDocElement := SalesDocNode.AsXmlElement();
        SalesDocElement.WriteTo(SalesDocXml);
        WrappedXml := '<sales_documents xmlns="' + XmlPortNamespace + '">' + SalesDocXml + '</sales_documents>';

        TempBLOBbuffer.Insert();
        TempBLOBbuffer."Buffer 1".CreateOutStream(OStream, TextEncoding::UTF8);
        OStream.WriteText(WrappedXml);
        TempBLOBbuffer.Modify();
        TempBLOBbuffer."Buffer 1".CreateInStream(IStream, TextEncoding::UTF8);

        // Mirror NPR NpCs Collect WS.ImportSalesDocuments exactly: Import, CopySourceTable, then re-export into the import entry blob
        SalesDocXmlPort.SetSource(IStream);
        SalesDocXmlPort.Import();
        SalesDocXmlPort.CopySourceTable(TempSalesHeader);

        TempBLOBbuffer."Buffer 2".CreateOutStream(OStream, TextEncoding::UTF8);
        SalesDocXmlPort.SetDestination(OStream);
        SalesDocXmlPort.Export();
        TempBLOBbuffer.Modify();
        TempBLOBbuffer."Buffer 2".CreateInStream(IStream, TextEncoding::UTF8);
        ReExportedXml := TypeHelper.ReadAsTextWithSeparator(IStream, TypeHelper.LFSeparator());
    end;
}

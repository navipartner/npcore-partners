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
        // [Given] a Send-to-Store collect order with NP Email enabled and its four templates set
        CreateSendToStoreCollectDocument(NpCsDocument, true);

        // [When] the request body is built by the sender and its sales_document payload imported through the receiver xmlport
        NpCsSendOrder.InitReqBody(NpCsDocument, RequestBody);
        ImportThroughReceiverXmlport(RequestBody, TempSalesHeader, ReExportedXml);

        // [Then] the NP Email block was emitted and the receiver schema accepted the payload
        Assert.IsTrue(StrPos(RequestBody, '<enable_np_email>') > 0, 'The NP Email block should be emitted when Enable NP Email is true.');
        Assert.IsTrue(TempSalesHeader.FindFirst(), 'The receiver xmlport should have imported the collect sales document.');
        Assert.AreEqual(NpCsDocument."Document No.", TempSalesHeader."No.", 'The imported sales document should match the collect document No.');
        // [Then] the re-export the receiving import entry is fed from still carries the NP Email values
        Assert.IsTrue(StrPos(ReExportedXml, 'CNC-CONFIRMED') > 0, 'The re-exported document should carry the NP Email templates.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure GivenNpEmailDisabled_WhenBuildingAndImportingCollectOrder_ThenTagsOmittedAndAccepted()
    var
        NpCsDocument: Record "NPR NpCs Document";
        TempSalesHeader: Record "Sales Header" temporary;
        NpCsSendOrder: Codeunit "NPR NpCs Send Order";
        ReExportedXml: Text;
        RequestBody: Text;
    begin
        // [Given] the same Send-to-Store collect order but with NP Email disabled
        CreateSendToStoreCollectDocument(NpCsDocument, false);

        // [When] the request body is built by the sender and its sales_document payload imported through the receiver xmlport
        NpCsSendOrder.InitReqBody(NpCsDocument, RequestBody);
        ImportThroughReceiverXmlport(RequestBody, TempSalesHeader, ReExportedXml);

        // [Then] the NP Email block was omitted and the receiver schema still accepted the payload
        Assert.AreEqual(0, StrPos(RequestBody, '<enable_np_email>'), 'The NP Email block must be omitted when Enable NP Email is false.');
        Assert.IsTrue(TempSalesHeader.FindFirst(), 'The receiver xmlport should have imported the collect sales document.');
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

    local procedure CreateSendToStoreCollectDocument(var NpCsDocument: Record "NPR NpCs Document"; EnableNpEmail: Boolean)
    var
        NpCsWorkflow: Record "NPR NpCs Workflow";
        SalesHeader: Record "Sales Header";
        LibraryClickCollect: Codeunit "NPR Library Click & Collect";
        LibrarySales: Codeunit "Library - Sales";
    begin
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
        if EnableNpEmail then begin
            NpCsDocument."Enable NP Email" := true;
            NpCsDocument."NP E-mail Template (Pending)" := 'CNC-PENDING';
            NpCsDocument."NP E-mail Template (Confirmed)" := 'CNC-CONFIRMED';
            NpCsDocument."NP E-mail Template (Rejected)" := 'CNC-REJECTED';
            NpCsDocument."NP E-mail Template (Expired)" := 'CNC-EXPIRED';
        end;
        NpCsDocument.Insert(true);
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

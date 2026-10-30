codeunit 85199 "NPR RS EI Sales Tests"
{
    Subtype = Test;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        _Customer: Record Customer;
        _GeneralPostingSetup: Record "General Posting Setup";
        _VATPostingSetup: Record "VAT Posting Setup";
        _Assert: Codeunit Assert;
        _LibrarySales: Codeunit "Library - Sales";
        _Initialized: Boolean;
        _PostedDocumentNo: Code[20];
        _PostedDocumentCrMemoNo: Code[20];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ShouldSendDocumentToSEFConfirmHandler,GeneralMessageHandler')]
    procedure EInvoiceSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        PostedDocumentNo: Code[20];
    begin
        // [Scenario] Check that successful post of Sales Order gets successful response from E-Invoice API when RS E-Invoicing is Enabled
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Inovice Setup
        InitializeData();

        // [When] Creating Sales Document and Posting it
        LibraryRSEInvoice.CreateSalesHeaderWLines(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, SalesLine.Type::Item, _Customer, _GeneralPostingSetup, _VATPostingSetup, 'EISO');
        _PostedDocumentNo := LibraryRSEInvoice.PeekNextPostingNo(SalesHeader."Posting No. Series");
        PostedDocumentNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesHeader."Document Type", PostedDocumentNo);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryRSEInvoice);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ShouldSendDocumentToSEFConfirmHandler,GeneralMessageHandler')]
    procedure EInvoiceSalesPrepayment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        PostedDocumentNo: Code[20];
        PrepaymentDocNo: Code[20];
    begin
        // [Scenario] Check that successful post of Sales Prepayment gets successful response from E-Invoice API when RS E-Invoicing is Enabled
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Inovice Setup
        InitializeData();

        // [When] Creating Sales Document and Posting it
        LibraryRSEInvoice.CreateSalesHeaderWLines(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, SalesLine.Type::Item, _Customer, _GeneralPostingSetup, _VATPostingSetup, 'EISPREP');

        LibraryRSEInvoice.CreatePrepaymentSalesHeader(SalesHeader, SalesLine, _Customer, _GeneralPostingSetup, _VATPostingSetup);

        _PostedDocumentNo := LibraryRSEInvoice.PeekNextPostingNo(SalesHeader."Prepayment No. Series");
        PrepaymentDocNo := _LibrarySales.PostSalesPrepaymentInvoice(SalesHeader);

        _PostedDocumentNo := LibraryRSEInvoice.PeekNextPostingNo(SalesHeader."Posting No. Series");
        PostedDocumentNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesHeader."Document Type", PrepaymentDocNo);
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesHeader."Document Type", PostedDocumentNo);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryRSEInvoice);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ShouldSendDocumentToSEFConfirmHandler,GeneralMessageHandler')]
    procedure EInvoiceSalesCrMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesHeader2: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        PostedCreditMemoNo: Code[20];
        PostedDocumentNo: Code[20];
        SalesDocumentType: Enum "Sales Document Type";
    begin
        // [Scenario] Check that successful post of Sales Credit Memo gets successful response from E-Invoice API when RS E-Invoicing is Enabled
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Inovice Setup
        InitializeData();

        // [When] Creating Sales Document and Posting it
        LibraryRSEInvoice.CreateSalesHeaderWLines(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, SalesLine.Type::Item, _Customer, _GeneralPostingSetup, _VATPostingSetup, 'EISCRM');
        _PostedDocumentNo := LibraryRSEInvoice.PeekNextPostingNo(SalesHeader."Posting No. Series");
        PostedDocumentNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        LibraryRSEInvoice.CreateSalesCreditMemo(SalesHeader2, SalesLine, _GeneralPostingSetup, _VATPostingSetup, PostedDocumentNo, 'EISCRM2');
        PostedCreditMemoNo := _LibrarySales.PostSalesDocument(SalesHeader2, true, true);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesHeader."Document Type", PostedDocumentNo);
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesDocumentType::"Credit Memo", PostedCreditMemoNo);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryRSEInvoice);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ShouldSendDocumentToSEFConfirmHandler,GeneralMessageHandler')]
    procedure GivenSEFRejectsSalesDocuments_WhenASentInvoiceIsResent_ThenItsEInvoiceDocumentIsKept()
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        SentRSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
    begin
        // [Scenario] A resend that SEF does not accept keeps the e-invoice document of the earlier accepted send
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Invoice Setup
        InitializeData();

        // [Given] A posted invoice that SEF accepted
        SentRSEInvoiceDocument.SetRange("Document No.", PostSalesOrder('EIRSREJ'));
        SentRSEInvoiceDocument.FindFirst();
        _Assert.IsFalse(IsNullGuid(SentRSEInvoiceDocument."Request ID"), 'Precondition: the accepted send must store a Request ID.');
        _Assert.AreEqual(3357127, SentRSEInvoiceDocument."Sales Invoice ID", 'Precondition: the accepted send must store the SEF Sales Invoice ID.');

        // [Given] SEF rejects sales documents but still answers status requests
        LibraryRSEInvoice.SetSEFRejectsSalesDocuments(true);

        // [When] The invoice is resent
        RSEInvoiceDocument := SentRSEInvoiceDocument;
        RSEICommunicationMgt.ResendSalesDocument(RSEInvoiceDocument);

        // [Then] Its e-invoice document still holds the request and SEF ids of the accepted send
        _Assert.IsTrue(RSEInvoiceDocument.Get(SentRSEInvoiceDocument."Entry No."), 'A resend that SEF did not accept must not delete the e-invoice document.');
        _Assert.AreEqual(SentRSEInvoiceDocument."Request ID", RSEInvoiceDocument."Request ID", 'A resend that SEF did not accept must not replace the Request ID.');
        _Assert.AreEqual(SentRSEInvoiceDocument."Sales Invoice ID", RSEInvoiceDocument."Sales Invoice ID", 'A resend that SEF did not accept must not replace the Sales Invoice ID.');

        // [Cleanup] Remove the e-invoice document and unbind Event Subscriptions in Test Library Codeunit
        RSEInvoiceDocument.Delete();
        UnbindSubscription(LibraryRSEInvoice);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ShouldSendDocumentToSEFConfirmHandler,GeneralMessageHandler')]
    procedure GivenSEFRejectsSalesDocuments_WhenAResentInvoiceIsSaved_ThenItKeepsTheRequestIDOfTheAcceptedSend()
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        SentRSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
    begin
        // [Scenario] A resend that SEF does not accept leaves nothing on the record that saving it afterwards (as the Resend page action does) would store
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Invoice Setup
        InitializeData();

        // [Given] A posted invoice that SEF accepted
        SentRSEInvoiceDocument.SetRange("Document No.", PostSalesOrder('EIRSSAV'));
        SentRSEInvoiceDocument.FindFirst();
        _Assert.IsFalse(IsNullGuid(SentRSEInvoiceDocument."Request ID"), 'Precondition: the accepted send must store a Request ID.');

        // [Given] SEF rejects sales documents but still answers status requests
        LibraryRSEInvoice.SetSEFRejectsSalesDocuments(true);

        // [When] The invoice is resent and the record is saved afterwards
        RSEInvoiceDocument := SentRSEInvoiceDocument;
        RSEICommunicationMgt.ResendSalesDocument(RSEInvoiceDocument);
        RSEInvoiceDocument.Modify();

        // [Then] The e-invoice document still holds the Request ID of the accepted send
        RSEInvoiceDocument.Get(SentRSEInvoiceDocument."Entry No.");
        _Assert.AreEqual(SentRSEInvoiceDocument."Request ID", RSEInvoiceDocument."Request ID", 'A resend that SEF did not accept must not leave its Request ID on the record.');

        // [Cleanup] Remove the e-invoice document and unbind Event Subscriptions in Test Library Codeunit
        RSEInvoiceDocument.Delete();
        UnbindSubscription(LibraryRSEInvoice);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ShouldSendDocumentToSEFConfirmHandler,GeneralMessageHandler')]
    procedure GivenSEFIsUp_WhenASentInvoiceIsResent_ThenItsStatusIsRefreshedFromSEF()
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        SentRequestID: Guid;
    begin
        // [Scenario] A resend that SEF accepts is followed by a status refresh from SEF
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Invoice Setup
        InitializeData();

        // [Given] A posted invoice that SEF accepted, still a draft locally
        RSEInvoiceDocument.SetRange("Document No.", PostSalesOrder('EIRSUP'));
        RSEInvoiceDocument.FindFirst();
        _Assert.AreEqual(RSEInvoiceDocument."Invoice Status"::DRAFT, RSEInvoiceDocument."Invoice Status", 'Precondition: this test needs a document SEF has not reported a status for yet.');
        SentRequestID := RSEInvoiceDocument."Request ID";
        _Assert.IsFalse(IsNullGuid(SentRequestID), 'Precondition: the accepted send must store a Request ID.');

        // [When] The invoice is resent
        RSEICommunicationMgt.ResendSalesDocument(RSEInvoiceDocument);

        // [Then] The document carries the Request ID of the resend and the status SEF reports
        RSEInvoiceDocument.Get(RSEInvoiceDocument."Entry No.");
        _Assert.IsFalse(IsNullGuid(RSEInvoiceDocument."Request ID"), 'A resend that SEF accepted must store its Request ID.');
        _Assert.AreNotEqual(SentRequestID, RSEInvoiceDocument."Request ID", 'A resend that SEF accepted must store the Request ID it was sent with.');
        _Assert.AreEqual(RSEInvoiceDocument."Invoice Status"::APPROVED, RSEInvoiceDocument."Invoice Status", 'A resend that SEF accepted must refresh the document status from SEF.');

        // [Cleanup] Remove the e-invoice document and unbind Event Subscriptions in Test Library Codeunit
        RSEInvoiceDocument.Delete();
        UnbindSubscription(LibraryRSEInvoice);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ShouldSendDocumentToSEFConfirmHandler,GeneralMessageHandler')]
    procedure GivenSEFRejectsSalesDocuments_WhenAnInvoiceIsPosted_ThenNoEInvoiceDocumentIsKept()
    var
        RSEInvoiceDocument: Record "NPR RS E-Invoice Document";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
    begin
        // [Scenario] A first send that SEF does not accept leaves no e-invoice document, so Send E-Invoice on the posted invoice can create it again
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Invoice Setup
        InitializeData();

        // [Given] SEF rejects sales documents
        LibraryRSEInvoice.SetSEFRejectsSalesDocuments(true);

        // [When] A sales order is posted
        RSEInvoiceDocument.SetRange("Document No.", PostSalesOrder('EIPSREJ'));

        // [Then] No e-invoice document is kept for the posted invoice
        _Assert.RecordIsEmpty(RSEInvoiceDocument);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit
        UnbindSubscription(LibraryRSEInvoice);
    end;

    local procedure PostSalesOrder(NoSeriesPrefix: Text) PostedDocumentNo: Code[20]
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
    begin
        LibraryRSEInvoice.CreateSalesHeaderWLines(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, SalesLine.Type::Item, _Customer, _GeneralPostingSetup, _VATPostingSetup, NoSeriesPrefix);
        _PostedDocumentNo := LibraryRSEInvoice.PeekNextPostingNo(SalesHeader."Posting No. Series");
        PostedDocumentNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
    end;

    internal procedure InitializeData()
    var
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
    begin
        if _Initialized then begin
            //Refresh Allowed UOMs and Tax Exemption List
            RSEICommunicationMgt.GetAllowedUOMs();
            RSEICommunicationMgt.GetTaxExemptionReasonList();
            exit;
        end;

        LibraryRSEInvoice.CreateRSEInvoiceSetup();
        LibraryRSEInvoice.CreateRSLocalizationSetup();
        LibraryRSEInvoice.CreateGeneralPostingSetup(_GeneralPostingSetup);
        LibraryRSEInvoice.CreateVATPostingSetup(_VATPostingSetup, _GeneralPostingSetup);
        LibraryRSEInvoice.CreateRSVATPostingSetup(_VATPostingSetup, _GeneralPostingSetup);
        LibraryRSEInvoice.CreateCustomer(_Customer, _GeneralPostingSetup."Gen. Bus. Posting Group", _VATPostingSetup."VAT Bus. Posting Group");

        _Initialized := true;
    end;

    [ConfirmHandler]
    procedure ShouldSendDocumentToSEFConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        if _PostedDocumentCrMemoNo <> '' then begin
            _Assert.ExpectedMessage(StrSubstNo('Are you sure document %1 should be sent to SEF?', _PostedDocumentCrMemoNo), Question);
            Reply := true;
            Clear(_PostedDocumentCrMemoNo);
        end else
            if _PostedDocumentNo <> '' then begin
                _Assert.ExpectedMessage(StrSubstNo('Are you sure document %1 should be sent to SEF?', _PostedDocumentNo), Question);
                Reply := true;
                Clear(_PostedDocumentNo);
            end
    end;

    [MessageHandler]
    procedure GeneralMessageHandler(Msg: Text[1024])
    begin
        case true of
            Msg.Contains('Allowed Units of Measure have been updated.'):
                exit;
            Msg.Contains('Tax Exemption Reason List has been updated.'):
                exit;
            else
                Error('Message "%1" is not expected.', Msg);
        end;
    end;
#endif
}
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
        LibraryRSEInvoice.CreateSalesHeaderWLines(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, SalesLine.Type::Item, _Customer, _GeneralPostingSetup, _VATPostingSetup);
        PostedDocumentNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesHeader."Document Type", PostedDocumentNo);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit and Cleanup Records
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
        LibraryRSEInvoice.CreateSalesHeaderWLines(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, SalesLine.Type::Item, _Customer, _GeneralPostingSetup, _VATPostingSetup);
        PrepaymentDocNo := LibraryRSEInvoice.CreateAndPostPrepaymentSalesHeader(SalesHeader, SalesLine, _Customer, _GeneralPostingSetup, _VATPostingSetup);
        PostedDocumentNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesHeader."Document Type", PrepaymentDocNo);
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesHeader."Document Type", PostedDocumentNo);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit and Cleanup Records
        UnbindSubscription(LibraryRSEInvoice);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ShouldSendDocumentToSEFConfirmHandler,GeneralMessageHandler')]
    procedure EInvoiceSalesCrMemo()
    var
        SalesHeader: Record "Sales Header";
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
        LibraryRSEInvoice.CreateSalesHeaderWLines(SalesHeader, SalesLine, SalesHeader."Document Type"::Order, SalesLine.Type::Item, _Customer, _GeneralPostingSetup, _VATPostingSetup);
        PostedDocumentNo := _LibrarySales.PostSalesDocument(SalesHeader, true, true);
        PostedCreditMemoNo := LibraryRSEInvoice.CreateAndPostSalesCreditMemo(SalesLine, _GeneralPostingSetup, _VATPostingSetup, PostedDocumentNo);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesHeader."Document Type", PostedDocumentNo);
        LibraryRSEInvoice.VerifySalesDocumentIsSentToSEFAndCleanup(SalesDocumentType::"Credit Memo", PostedCreditMemoNo);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit and Cleanup Records
        UnbindSubscription(LibraryRSEInvoice);
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
        _Assert.ExpectedMessage('Are you sure this document should be sent to SEF?', Question);
        Reply := true;
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
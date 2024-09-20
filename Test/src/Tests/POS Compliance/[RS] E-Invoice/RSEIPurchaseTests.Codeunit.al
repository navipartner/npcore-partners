codeunit 85202 "NPR RS EI Purchase Tests"
{
    Subtype = Test;

#if not (BC17 or BC18 or BC19 or BC20 or BC21)
    var
        TempRSEInvoiceDocument: Record "NPR RS E-Invoice Document" temporary;
        _GeneralPostingSetup: Record "General Posting Setup";
        _VATPostingSetup: Record "VAT Posting Setup";
        _Vendor: Record Vendor;
        _VendorPostingGroup: Record "Vendor Posting Group";
        _LibraryPurchase: Codeunit "Library - Purchase";
        _Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralMessageHandler,ConfirmYesHandler,RSEInvoiceSelectionPurchOrderHandler,VendorCardModalPageHandler')]
    procedure PurchaseOrderImport()
    var
        PurchaseHeader: Record "Purchase Header";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        PurchHeaderNo: Code[20];
    begin
        // [Scenario] Check that successful post of Sales Order gets successful response from E-Invoice API when RS E-Invoicing is Enabled
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Inovice Setup
        InitializeData();

        // [When] Creating Sales Document and Posting it
        RSEICommunicationMgt.GetPurchaseInvoice(TempRSEInvoiceDocument, 3184198);
        RSEInvoiceMgt.ProcessSelectedPurchaseInvoicesForImporting(TempRSEInvoiceDocument);
        LibraryRSEInvoice.GetPurchaseHeaderNo(PurchHeaderNo);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifyPurchaseDocumentIsSentToSEFAndCleanup(PurchaseHeader."Document Type", PurchHeaderNo, false);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit and Cleanup Records
        UnbindSubscription(LibraryRSEInvoice);
        CleanupGlobals();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralMessageHandler,ConfirmYesHandler,RSEInvoiceSelectionPurchInvoiceHandler,VendorCardModalPageHandler')]
    procedure PurchaseInvoiceImport()
    var
        PurchaseHeader: Record "Purchase Header";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        PurchHeaderNo: Code[20];
    begin
        // [Scenario] Check that successful post of Sales Order gets successful response from E-Invoice API when RS E-Invoicing is Enabled
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Inovice Setup
        InitializeData();

        // [When] Creating Sales Document and Posting it
        RSEICommunicationMgt.GetPurchaseInvoice(TempRSEInvoiceDocument, 3184198);
        RSEInvoiceMgt.ProcessSelectedPurchaseInvoicesForImporting(TempRSEInvoiceDocument);
        LibraryRSEInvoice.GetPurchaseHeaderNo(PurchHeaderNo);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifyPurchaseDocumentIsSentToSEFAndCleanup(PurchaseHeader."Document Type", PurchHeaderNo, false);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit and Cleanup Records
        UnbindSubscription(LibraryRSEInvoice);
        CleanupGlobals();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralMessageHandler,ConfirmYesHandler,RSEInvoiceSelectionPurchOrderHandler,VendorCardModalPageHandler')]
    procedure PurchaseOrderImportAndPost()
    var
        PurchaseHeader: Record "Purchase Header";
        LibraryRSEInvoice: Codeunit "NPR Library RS E-Invoice";
        RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
        RSEInvoiceMgt: Codeunit "NPR RS E-Invoice Mgt.";
        PurchHeaderNo: Code[20];
        LineAmount: Decimal;
    begin
        // [Scenario] Check that successful post of Sales Order gets successful response from E-Invoice API when RS E-Invoicing is Enabled
        // [Given] Enable Mock response instead of real http response
        BindSubscription(LibraryRSEInvoice);

        // [Given] RS E-Inovice Setup
        InitializeData();

        // [When] Creating Sales Document and Posting it
        RSEICommunicationMgt.GetPurchaseInvoice(TempRSEInvoiceDocument, 3184198);
        RSEInvoiceMgt.ProcessSelectedPurchaseInvoicesForImporting(TempRSEInvoiceDocument);
        LibraryRSEInvoice.GetPurchaseHeaderNo(PurchHeaderNo);
        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PurchHeaderNo);
        LibraryRSEInvoice.GetPurchHeaderAuxAmount(LineAmount, PurchaseHeader);
        LibraryRSEInvoice.CreatePurchaseLine(PurchaseHeader, _GeneralPostingSetup."Gen. Prod. Posting Group", _VATPostingSetup."VAT Prod. Posting Group", LineAmount);
        _LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        // [Then] For Normal Sale RS E-Invoice Document is created and filled
        LibraryRSEInvoice.VerifyPurchaseDocumentIsSentToSEFAndCleanup(PurchaseHeader."Document Type", PurchaseHeader."Last Posting No.", true);

        // [Cleanup] Unbind Event Subscriptions in Test Library Codeunit and Cleanup Records
        UnbindSubscription(LibraryRSEInvoice);
        CleanupGlobals();
    end;

    local procedure InitializeData()
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
        LibraryRSEInvoice.CreateGeneralPostingSetup(_GeneralPostingSetup);
        LibraryRSEInvoice.CreateVATPostingSetup(_VATPostingSetup, _GeneralPostingSetup);
        LibraryRSEInvoice.CreateVendorPostingGroup(_VendorPostingGroup);

        _Initialized := true;
    end;

    local procedure CleanupGlobals()
    begin
        _Vendor.Delete();
        Clear(_Vendor);
        TempRSEInvoiceDocument.DeleteAll();
        Clear(TempRSEInvoiceDocument);
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

    [ModalPageHandler]
    procedure RSEInvoiceSelectionPurchOrderHandler(var Page: Page "NPR RS E-Invoice Selection"; var Response: Action)
    begin
        TempRSEInvoiceDocument."Document Type" := TempRSEInvoiceDocument."Document Type"::"Purchase Order";
        TempRSEInvoiceDocument.Modify();
        Page.SetRecord(TempRSEInvoiceDocument);
        Response := Action::LookupOK;
    end;

    [ModalPageHandler]
    procedure RSEInvoiceSelectionPurchInvoiceHandler(var Page: Page "NPR RS E-Invoice Selection"; var Response: Action)
    begin
        TempRSEInvoiceDocument."Document Type" := TempRSEInvoiceDocument."Document Type"::"Purchase Invoice";
        TempRSEInvoiceDocument.Modify();
        Page.SetRecord(TempRSEInvoiceDocument);
        Response := Action::LookupOK;
    end;

    [ModalPageHandler]
    procedure VendorCardModalPageHandler(var Page: Page "Vendor Card"; var Response: Action)
    begin
        Page.GetRecord(_Vendor);
        _Vendor.Validate("Gen. Bus. Posting Group", _GeneralPostingSetup."Gen. Bus. Posting Group");
        _Vendor.Validate("VAT Bus. Posting Group", _VATPostingSetup."VAT Bus. Posting Group");
        _Vendor.Validate("Vendor Posting Group", _VendorPostingGroup.Code);
        _Vendor.Modify();
        Page.SetRecord(_Vendor);
        Response := Action::OK;
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
#endif
}
codeunit 85456 "NPR RS EI Purch Editab. Tests"
{
    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibraryPurchase: Codeunit "Library - Purchase";
        DocumentNoNotEditableErr: Label 'imported as an RS e-invoice', Locked = true;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure AuxPurchHeaderReadClearsRSEInvoiceMarkerWhenRSEInvoiceDisabled()
    var
        PurchaseHeader: Record "Purchase Header";
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
    begin
        // [Scenario] With RS E-Invoice disabled the read must leave no marker behind, so nothing downstream can mistake
        // an ordinary document for an imported e-invoice.

        // [Given] RS E-Invoice is disabled
        RSEInvoiceSetup.DeleteAll();

        // [Given] A purchase invoice
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice);

        // [Given] An aux record still carrying the marker of a previously read document
        RSEIAuxPurchHeader."NPR RS E-Invoice" := true;

        // [When] Reading the aux fields for the purchase invoice
        RSEIAuxPurchHeader.ReadRSEIAuxPurchHeaderFields(PurchaseHeader);

        // [Then] The marker is cleared, and no live primary key is handed back that a later save could overwrite
        _Assert.IsFalse(RSEIAuxPurchHeader."NPR RS E-Invoice", 'RS e-invoice marker must be cleared while RS E-Invoice is disabled.');
        _Assert.IsTrue(IsNullGuid(RSEIAuxPurchHeader."Purchase Header SystemId"), 'A disabled read must not hand back a record keyed to a real document.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorInvoiceNoCannotBeChangedOnRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [Scenario] The RS rule is enforced on the record, so it holds on every write path including page based
        // web service calls where no page trigger runs.

        // [Given] A purchase invoice imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice);
        MarkAsRSEInvoice(PurchaseHeader);

        // [When] Writing a different vendor invoice number
        asserterror PurchaseHeader.Validate("Vendor Invoice No.", 'O1869468');

        // [Then] The write is refused
        _Assert.ExpectedError(DocumentNoNotEditableErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorInvoiceNoCannotBeChangedOnRSEInvoiceOrder()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [Scenario] The rule is enforced on the record rather than the page, so it covers an imported order just as
        // it covers an imported invoice.

        // [Given] A purchase order imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order);
        MarkAsRSEInvoice(PurchaseHeader);

        // [When] Writing a different vendor invoice number
        asserterror PurchaseHeader.Validate("Vendor Invoice No.", 'O1869468');

        // [Then] The write is refused
        _Assert.ExpectedError(DocumentNoNotEditableErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorCrMemoNoCannotBeChangedOnRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [Scenario] The same record level rule covers the credit memo document number.

        // [Given] A purchase credit memo imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo");
        MarkAsRSEInvoice(PurchaseHeader);

        // [When] Writing a different vendor credit memo number
        asserterror PurchaseHeader.Validate("Vendor Cr. Memo No.", 'O1869468');

        // [Then] The write is refused
        _Assert.ExpectedError(DocumentNoNotEditableErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorInvoiceNoCanBeChangedWhenDocumentIsNotRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        // [Scenario] The rule must not over-fire: an ordinary document stays writable while RS E-Invoice is enabled.

        // [Given] A purchase invoice that was not imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice);

        // [When] Writing a vendor invoice number
        PurchaseHeader.Validate("Vendor Invoice No.", 'O1869468');

        // [Then] The write is accepted
        _Assert.AreEqual('O1869468', PurchaseHeader."Vendor Invoice No.", 'An ordinary purchase invoice must accept a vendor invoice number.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorInvoiceNoCanBeChangedWhenRSEInvoiceDisabled()
    var
        PurchaseHeader: Record "Purchase Header";
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
    begin
        // [Scenario] A company that does not use RS e-invoicing is never affected by the rule, even on a document
        // that still carries a marker from an earlier configuration.

        // [Given] A marked document in a company where RS E-Invoice is switched off
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice);
        MarkAsRSEInvoice(PurchaseHeader);
        RSEInvoiceSetup.DeleteAll();

        // [When] Writing a vendor invoice number
        PurchaseHeader.Validate("Vendor Invoice No.", 'O1869468');

        // [Then] The write is accepted
        _Assert.AreEqual('O1869468', PurchaseHeader."Vendor Invoice No.", 'A company with RS E-Invoice disabled must accept a vendor invoice number.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorInvoiceNoIsEditableOnPurchaseInvoiceWhenDocumentIsNotRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        // [Scenario] The page keeps the field writable for an ordinary purchase invoice.

        // [Given] A purchase invoice that was not imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice);

        // [When] Opening the purchase invoice
        DisableClosingDocumentNotification();
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.GoToRecord(PurchaseHeader);

        // [Then] Vendor Invoice No. is writable
        _Assert.IsTrue(PurchaseInvoice."Vendor Invoice No.".Editable(), 'Vendor Invoice No. must stay editable on an ordinary purchase invoice.');

        PurchaseInvoice.Close();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorInvoiceNoIsReadOnlyOnPurchaseInvoiceWhenDocumentIsRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoice: TestPage "Purchase Invoice";
    begin
        // [Scenario] The page greys the field out for an imported purchase invoice.

        // [Given] A purchase invoice imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice);
        MarkAsRSEInvoice(PurchaseHeader);

        // [When] Opening the purchase invoice
        DisableClosingDocumentNotification();
        PurchaseInvoice.OpenEdit();
        PurchaseInvoice.GoToRecord(PurchaseHeader);

        // [Then] Vendor Invoice No. is protected
        _Assert.IsFalse(PurchaseInvoice."Vendor Invoice No.".Editable(), 'Vendor Invoice No. must stay read-only on an RS e-invoice.');

        PurchaseInvoice.Close();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorInvoiceNoIsEditableOnPurchaseOrderWhenDocumentIsNotRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrder: TestPage "Purchase Order";
    begin
        // [Scenario] The purchase order page computes editability in OnAfterGetRecord rather than OnAfterGetCurrRecord,
        // so it needs its own coverage.

        // [Given] A purchase order that was not imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order);

        // [When] Opening the purchase order
        DisableClosingDocumentNotification();
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchaseHeader);

        // [Then] Vendor Invoice No. is writable
        _Assert.IsTrue(PurchaseOrder."Vendor Invoice No.".Editable(), 'Vendor Invoice No. must stay editable on an ordinary purchase order.');

        PurchaseOrder.Close();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorInvoiceNoIsReadOnlyOnPurchaseOrderWhenDocumentIsRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseOrder: TestPage "Purchase Order";
    begin
        // [Scenario] The purchase order page protects the field for an imported document.

        // [Given] A purchase order imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order);
        MarkAsRSEInvoice(PurchaseHeader);

        // [When] Opening the purchase order
        DisableClosingDocumentNotification();
        PurchaseOrder.OpenEdit();
        PurchaseOrder.GoToRecord(PurchaseHeader);

        // [Then] Vendor Invoice No. is protected
        _Assert.IsFalse(PurchaseOrder."Vendor Invoice No.".Editable(), 'Vendor Invoice No. must stay read-only on an RS e-invoice order.');

        PurchaseOrder.Close();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorCrMemoNoIsEditableOnPurchaseCrMemoWhenDocumentIsNotRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        // [Scenario] The credit memo page guards a different field, Vendor Cr. Memo No., so it needs its own coverage.

        // [Given] A purchase credit memo that was not imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo");

        // [When] Opening the purchase credit memo
        DisableClosingDocumentNotification();
        PurchaseCreditMemo.OpenEdit();
        PurchaseCreditMemo.GoToRecord(PurchaseHeader);

        // [Then] Vendor Cr. Memo No. is writable
        _Assert.IsTrue(PurchaseCreditMemo."Vendor Cr. Memo No.".Editable(), 'Vendor Cr. Memo No. must stay editable on an ordinary purchase credit memo.');

        PurchaseCreditMemo.Close();
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure VendorCrMemoNoIsReadOnlyOnPurchaseCrMemoWhenDocumentIsRSEInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseCreditMemo: TestPage "Purchase Credit Memo";
    begin
        // [Scenario] The credit memo page protects its field for an imported document.

        // [Given] A purchase credit memo imported from SEF
        EnableRSEInvoice();
        CreatePurchaseHeader(PurchaseHeader, PurchaseHeader."Document Type"::"Credit Memo");
        MarkAsRSEInvoice(PurchaseHeader);

        // [When] Opening the purchase credit memo
        DisableClosingDocumentNotification();
        PurchaseCreditMemo.OpenEdit();
        PurchaseCreditMemo.GoToRecord(PurchaseHeader);

        // [Then] Vendor Cr. Memo No. is protected
        _Assert.IsFalse(PurchaseCreditMemo."Vendor Cr. Memo No.".Editable(), 'Vendor Cr. Memo No. must stay read-only on an RS e-invoice credit memo.');

        PurchaseCreditMemo.Close();
    end;

    local procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; DocumentType: Enum "Purchase Document Type")
    var
        Vendor: Record Vendor;
    begin
        _LibraryPurchase.CreateVendor(Vendor);
        _LibraryPurchase.CreatePurchHeader(PurchaseHeader, DocumentType, Vendor."No.");
    end;

    local procedure MarkAsRSEInvoice(PurchaseHeader: Record "Purchase Header")
    var
        RSEIAuxPurchHeader: Record "NPR RS EI Aux Purch. Header";
    begin
        RSEIAuxPurchHeader.Init();
        RSEIAuxPurchHeader."Purchase Header SystemId" := PurchaseHeader.SystemId;
        RSEIAuxPurchHeader."NPR RS E-Invoice" := true;
        RSEIAuxPurchHeader.Insert();
    end;

    local procedure EnableRSEInvoice()
    var
        RSEInvoiceSetup: Record "NPR RS E-Invoice Setup";
    begin
        RSEInvoiceSetup.DeleteAll();
        RSEInvoiceSetup.Init();
        RSEInvoiceSetup."Enable RS E-Invoice" := true;
        RSEInvoiceSetup."API URL" := 'https://demoefaktura.mfin.gov.rs/';
        RSEInvoiceSetup."API Key" := CreateGuid();
        RSEInvoiceSetup.Insert();
    end;

    local procedure DisableClosingDocumentNotification()
    var
        MyNotifications: Record "My Notifications";
        InstructionMgt: Codeunit "Instruction Mgt.";
    begin
        MyNotifications.Disable(InstructionMgt.GetClosingUnpostedDocumentNotificationId());
    end;
}

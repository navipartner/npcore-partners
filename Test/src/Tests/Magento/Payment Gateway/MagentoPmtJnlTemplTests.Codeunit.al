codeunit 85508 "NPR Magento Pmt JnlTempl Tests"
{
    // [FEATURE] Posting Magento payment lines when General Ledger Setup requires a journal template name

    Subtype = Test;

    var
        _Assert: Codeunit Assert;
        _LibERM: Codeunit "Library - ERM";
        _LibPaymentGateway: Codeunit "NPR Library - Payment Gateway";
        _LibSales: Codeunit "Library - Sales";
        _LibUtility: Codeunit "Library - Utility";
        _TestIntegration: Codeunit "NPR PG CI Test Integration";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLineIsPostedOnInvoicePostingWhenJnlTemplNameMandatory()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GatewayCode: Code[10];
        InvoiceTemplateName: Code[10];
        Posted: Boolean;
        PostingError: Text;
    begin
        // [SCENARIO] With "Journal Templ. Name Mandatory" on (default in the Belgian localization), posting a sales order
        // that has a Magento payment line also posts the payment and applies it to the invoice.
        _TestIntegration.Reset();

        // [GIVEN] Journal templates are mandatory and sales invoices and inventory cost posting use their own templates
        InvoiceTemplateName := SetupMandatoryJnlTemplates();

        // [GIVEN] A sales order with a Magento payment line covering the full amount
        _LibSales.CreateSalesOrder(SalesHeader);
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        _LibPaymentGateway.CreatePaymentLineForSalesHeader(SalesHeader, GatewayCode, PaymentLine);
        Commit();

        // [WHEN] The order is shipped and invoiced
        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Posted := Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
        if not Posted then
            PostingError := GetLastErrorText() + ' ' + GetLastErrorCallStack();

        // [THEN] Posting succeeded
        _Assert.IsTrue(Posted, StrSubstNo('Sales order posting failed: %1', PostingError));

        SalesInvoiceHeader.SetRange("Order No.", SalesHeader."No.");
        SalesInvoiceHeader.FindFirst();

        // [THEN] The payment line for the posted invoice is marked as posted
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        _Assert.IsTrue(PaymentLine.FindFirst(), 'Payment line for the posted sales invoice was not found.');
        _Assert.IsTrue(PaymentLine.Posted, 'Payment line should have been posted together with the sales invoice.');

        // [THEN] The payment is posted with the invoice's journal template and closes the invoice
        AssertPaymentPostedAndApplied(SalesInvoiceHeader."No.", InvoiceTemplateName);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLinePostedLaterUsesInvoiceJnlTemplate()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceTemplateName: Code[10];
    begin
        // [SCENARIO] A payment line posted on its own after the invoice (payment line list, Adyen/Shopify jobs) uses the
        // journal template of the invoice it settles, even if the sales setup template has changed since.
        _TestIntegration.Reset();

        // [GIVEN] Journal templates are mandatory and a sales invoice is posted with template A
        InvoiceTemplateName := SetupMandatoryJnlTemplates();
        PostSalesOrder(SalesInvoiceHeader);

        // [GIVEN] The sales setup invoice template is then changed to template B
        SetSalesInvoiceTemplateName(CreateGenJnlTemplate());

        // [GIVEN] A Magento payment line for the posted invoice
        CreatePaymentLineForInvoice(SalesInvoiceHeader, PaymentLine);

        // [WHEN] The payment line is posted on its own
        PostPaymentLine(PaymentLine);

        // [THEN] The payment is posted with template A and closes the invoice
        AssertPaymentPostedAndApplied(SalesInvoiceHeader."No.", InvoiceTemplateName);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PaymentLineFallsBackToSetupJnlTemplateForInvoiceWithoutTemplate()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentLine: Record "NPR Magento Payment Line";
        InvoiceTemplateName: Code[10];
    begin
        // [SCENARIO] An invoice posted before journal templates became mandatory has no template on its ledger entry.
        // Its payment line is posted with the sales setup invoice template.
        _TestIntegration.Reset();

        // [GIVEN] Journal templates are not mandatory and a sales invoice is posted
        SetJnlTemplNameMandatory(false);
        SetPostedShipmentNos();
        PostSalesOrder(SalesInvoiceHeader);
        _Assert.AreEqual('', GetInvoiceCustLedgerEntryJnlTemplName(SalesInvoiceHeader."No."), 'Precondition: the invoice ledger entry should have no journal template.');

        // [GIVEN] Journal templates are then made mandatory
        InvoiceTemplateName := SetupMandatoryJnlTemplates();

        // [GIVEN] A Magento payment line for the posted invoice
        CreatePaymentLineForInvoice(SalesInvoiceHeader, PaymentLine);

        // [WHEN] The payment line is posted on its own
        PostPaymentLine(PaymentLine);

        // [THEN] The payment is posted with the sales setup invoice template and closes the invoice
        AssertPaymentPostedAndApplied(SalesInvoiceHeader."No.", InvoiceTemplateName);
    end;

    local procedure SetupMandatoryJnlTemplates() InvoiceTemplateName: Code[10]
    var
        InventorySetup: Record "Inventory Setup";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        SetJnlTemplNameMandatory(true);

        InvoiceTemplateName := CreateGenJnlTemplate();
        SetSalesInvoiceTemplateName(InvoiceTemplateName);
        SetPostedShipmentNos();

        _LibERM.CreateGenJournalBatch(GenJournalBatch, CreateGenJnlTemplate());
        InventorySetup.Get();
        InventorySetup."Invt. Cost Jnl. Template Name" := GenJournalBatch."Journal Template Name";
        InventorySetup."Invt. Cost Jnl. Batch Name" := GenJournalBatch.Name;
        InventorySetup.Modify();
    end;

    local procedure SetJnlTemplNameMandatory(Mandatory: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        GLSetup."Journal Templ. Name Mandatory" := Mandatory;
        GLSetup.Modify();
    end;

    local procedure SetSalesInvoiceTemplateName(TemplateName: Code[10])
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        SalesSetup."S. Invoice Template Name" := TemplateName;
        SalesSetup.Modify();
    end;

    local procedure SetPostedShipmentNos()
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        SalesSetup.Get();
        SalesSetup."Posted Shipment Nos." := _LibUtility.GetGlobalNoSeriesCode();
        SalesSetup.Modify();
    end;

    local procedure CreateGenJnlTemplate(): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        _LibERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate."Posting No. Series" := _LibUtility.GetGlobalNoSeriesCode();
        GenJournalTemplate.Modify();
        exit(GenJournalTemplate.Name);
    end;

    local procedure PostSalesOrder(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesHeader: Record "Sales Header";
    begin
        _LibSales.CreateSalesOrder(SalesHeader);
        SalesInvoiceHeader.Get(_LibSales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreatePaymentLineForInvoice(SalesInvoiceHeader: Record "Sales Invoice Header"; var PaymentLine: Record "NPR Magento Payment Line")
    var
        GatewayCode: Code[10];
    begin
        GatewayCode := _LibPaymentGateway.CreatePaymentGateway(Enum::"NPR PG Integrations"::"CI Test Integration");
        _LibPaymentGateway.CreatePaymentLineForSalesInvoiceHeader(SalesInvoiceHeader, GatewayCode, PaymentLine);
        PaymentLine."Posting Date" := SalesInvoiceHeader."Posting Date";
        PaymentLine.Modify();
    end;

    local procedure PostPaymentLine(var PaymentLine: Record "NPR Magento Payment Line")
    var
        Posted: Boolean;
        PostingError: Text;
    begin
        Commit();
        Posted := Codeunit.Run(Codeunit::"NPR Magento Post Payment Line", PaymentLine);
        if not Posted then
            PostingError := GetLastErrorText() + ' ' + GetLastErrorCallStack();
        _Assert.IsTrue(Posted, StrSubstNo('Payment line posting failed: %1', PostingError));

        PaymentLine.Find();
        _Assert.IsTrue(PaymentLine.Posted, 'Payment line should be marked as posted.');
    end;

    local procedure GetInvoiceCustLedgerEntryJnlTemplName(InvoiceNo: Code[20]): Code[10]
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        CustLedgerEntry.FindFirst();
        exit(CustLedgerEntry."Journal Templ. Name");
    end;

    local procedure AssertPaymentPostedAndApplied(InvoiceNo: Code[20]; ExpectedTemplateName: Code[10])
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        _Assert.IsTrue(CustLedgerEntry.FindFirst(), 'Payment customer ledger entry was not created.');
        _Assert.AreEqual(ExpectedTemplateName, CustLedgerEntry."Journal Templ. Name", 'Payment was posted with the wrong journal template.');

        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.FindFirst();
        _Assert.IsFalse(CustLedgerEntry.Open, 'The payment should be applied to the invoice and close it.');
    end;
}

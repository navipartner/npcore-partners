codeunit 85212 "NPR ES Invoice Mgt. Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Item: Record Item;
        ESClient: Record "NPR ES Client";
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSUnit: Record "NPR POS Unit";
        Salesperson: Record "Salesperson/Purchaser";
        Assert: Codeunit Assert;
        POSSession: Codeunit "NPR POS Session";
        Initialized: Boolean;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure CreateInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntryNo: Integer;
        SalesShouldBeCreatedErr: Label 'Sales should be created.', Locked = true;
    begin
        // [SCENARIO] Checks creating invoice for ES POS Audit Log Aux. Info record with successful response from Fiskaly for successful cash sales
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Ending normal cash sale
        POSEntryNo := DoItemSale(Enum::"NPR ES Inv. Registration State"::PENDING);

        // [THEN] For normal cash sale ES POS Audit Log is created
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        ESPOSAuditLogAuxInfo.FindFirst();
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Invoice No." <> '', SalesShouldBeCreatedErr);
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Signer Id"), SalesShouldBeCreatedErr);
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Client Id"), SalesShouldBeCreatedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State", ESPOSAuditLogAuxInfo."Invoice State"::ISSUED, SalesShouldBeCreatedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Issued At" <> 0DT, SalesShouldBeCreatedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo.GetQRCode() <> '', SalesShouldBeCreatedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Validation URL" <> '', SalesShouldBeCreatedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::PENDING, SalesShouldBeCreatedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Cancellation State", ESPOSAuditLogAuxInfo."Invoice Cancellation State"::NOT_CANCELLED, SalesShouldBeCreatedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure RetrieveInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSEntryNo: Integer;
        SalesShouldBeRetrievedErr: Label 'Sales should be retrieved.', Locked = true;
    begin
        // [SCENARIO] Checks retrieving invoice for ES POS Audit Log Aux. Info record with successful response from Fiskaly for successful cash sales
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES POS Audit Log for invoice exists
        POSEntryNo := DoItemSale(Enum::"NPR ES Inv. Registration State"::PENDING);
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        ESPOSAuditLogAuxInfo.FindFirst();

        // [WHEN] Retrieving invoice from Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        ESFiskalyCommunication.RetrieveInvoice(ESPOSAuditLogAuxInfo);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES POS Audit Log for invoice is retrieved
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Signer Id"), SalesShouldBeRetrievedErr);
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Client Id"), SalesShouldBeRetrievedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State", ESPOSAuditLogAuxInfo."Invoice State"::ISSUED, SalesShouldBeRetrievedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Issued At" <> 0DT, SalesShouldBeRetrievedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo.GetQRCode() <> '', SalesShouldBeRetrievedErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Validation URL" <> '', SalesShouldBeRetrievedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::REGISTERED, SalesShouldBeRetrievedErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Cancellation State", ESPOSAuditLogAuxInfo."Invoice Cancellation State"::NOT_CANCELLED, SalesShouldBeRetrievedErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure CancelInvoice()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        ESFiskalyCommunication: Codeunit "NPR ES Fiskaly Communication";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSEntryNo: Integer;
        SalesShouldBeCancelledErr: Label 'Sales should be cancelled.', Locked = true;
    begin
        // [SCENARIO] Checks cancelling invoice for ES POS Audit Log Aux. Info record with successful response from Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] ES POS Audit Log for invoice registered at Fiskaly exists
        POSEntryNo := DoItemSale(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntryNo);
        ESPOSAuditLogAuxInfo.FindFirst();

        // [WHEN] Cancelling invoice at Fiskaly
        BindSubscription(ESFiscalLibrary);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        ESFiscalLibrary.SetInvoiceCancellationState(Enum::"NPR ES Inv. Cancellation State"::CANCELLED);
        ESFiskalyCommunication.CancelInvoice(ESPOSAuditLogAuxInfo);
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] ES POS Audit Log for invoice is cancelled
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Signer Id"), SalesShouldBeCancelledErr);
        Assert.IsFalse(IsNullGuid(ESPOSAuditLogAuxInfo."ES Client Id"), SalesShouldBeCancelledErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State", ESPOSAuditLogAuxInfo."Invoice State"::CANCELLED, SalesShouldBeCancelledErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Issued At" <> 0DT, SalesShouldBeCancelledErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo.GetQRCode() <> '', SalesShouldBeCancelledErr);
        Assert.IsTrue(ESPOSAuditLogAuxInfo."Validation URL" <> '', SalesShouldBeCancelledErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Registration State", ESPOSAuditLogAuxInfo."Invoice Registration State"::REGISTERED, SalesShouldBeCancelledErr);
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Cancellation State", ESPOSAuditLogAuxInfo."Invoice Cancellation State"::CANCELLED, SalesShouldBeCancelledErr);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure PayPrepaymentOfSalesOrder()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSActionDocPrepayB: Codeunit "NPR POS Action: Doc. Prepay B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
        PrepaymentAmount: Decimal;
        SaleEnded: Boolean;
        SaleShouldEndErr: Label 'Sale with prepayment of sales order should end.', Locked = true;
    begin
        // [SCENARIO] Paying a prepayment of a sales order on POS ends the sale and posts the prepayment invoice instead of Fiskaly rejecting an invoice without items
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] Sales order of a customer
        CreateSalesOrderForPrepayment(SalesHeader);

        // [WHEN] Paying a prepayment of the sales order on POS
        PrepaymentAmount := 5;
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(SalePOS);
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, PrepaymentAmount, true, false, false, POSSalesDocumentPost::Synchronous);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        BindSubscription(ESFiscalLibrary);
        SaleEnded := POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleLinePOS."Amount Including VAT", '');
        UnbindSubscription(ESFiscalLibrary);

        // [THEN] Sale ends and the prepayment invoice is posted
        Assert.IsTrue(SaleEnded, SaleShouldEndErr);
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        Assert.RecordIsNotEmpty(SalesInvoiceHeader);

        // [THEN] The prepayment is not fiscalized at Fiskaly, since it has no item or voucher lines
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.RecordIsEmpty(ESPOSAuditLogAuxInfo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure SellItemAndPayPrepaymentOfSalesOrder()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        InvoiceBody: JsonObject;
        FullAmountToken: JsonToken;
    begin
        // [SCENARIO] A sale of an item together with a prepayment of a sales order is fiscalized at Fiskaly with the item only, since the prepayment is invoiced by its own prepayment invoice
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Selling an item and paying a prepayment of a sales order in the same POS sale
        POSEntry.Get(DoItemAndPrepaymentSale(ESFiscalLibrary));

        // [THEN] The invoice at Fiskaly amounts to the item line only
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.FindFirst();

        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntry."Entry No.");
        ESPOSAuditLogAuxInfo.FindFirst();
        Assert.AreEqual(POSEntrySalesLine."Amount Incl. VAT", ESPOSAuditLogAuxInfo."Amount Incl. Tax", ESPOSAuditLogAuxInfo.FieldCaption("Amount Incl. Tax"));

        InvoiceBody.ReadFrom(ESFiscalLibrary.GetLastCreateInvoiceBody());
        InvoiceBody.SelectToken('$.content.full_amount', FullAmountToken);
        Assert.AreEqual(Format(POSEntrySalesLine."Amount Incl. VAT", 0, '<Precision,2:2><Standard Format,2>'), FullAmountToken.AsValue().AsText(), 'full_amount');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure PrintReceiptOfItemSaleWithPrepaymentOfSalesOrder()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        DepositPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ItemPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        Base64: Codeunit "Base64 Convert";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
        PrintedLines: List of [Text];
        DepositLineIndex: Integer;
        InvoiceTotalLineIndex: Integer;
        ItemVATLineIndex: Integer;
        TotalLbl: Label 'Total', Locked = true;
        AmountToPayLbl: Label 'Amount to Pay', Locked = true;
        DepositAfterInvoiceTotalErr: Label 'The prepayment line must be printed after the invoice total, since it is not part of the invoice.', Locked = true;
    begin
        // [SCENARIO] The fiscal receipt of an item sale with a prepayment of a sales order shows the invoice registered at Fiskaly, with the prepayment printed apart from it
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] Ended sale of an item together with a prepayment of a sales order
        POSEntry.Get(DoItemAndPrepaymentSale(ESFiscalLibrary));
        ItemPOSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        ItemPOSEntrySalesLine.SetRange(Type, ItemPOSEntrySalesLine.Type::Item);
        ItemPOSEntrySalesLine.FindFirst();
        DepositPOSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        DepositPOSEntrySalesLine.SetRange(Type, DepositPOSEntrySalesLine.Type::Customer);
        DepositPOSEntrySalesLine.FindFirst();
        ESPOSAuditLogAuxInfo.FindAuditLog(POSEntry."Entry No.");

        // [WHEN] Printing the fiscal receipt
        BindSubscription(RetailPrintHandler);
        Codeunit.Run(Codeunit::"NPR ES Fiscal Thermal Print", POSEntry);
        UnbindSubscription(RetailPrintHandler);
        PrintedLines := GetPrintedLines(Base64.FromBase64(RetailPrintHandler.GetPrintJobBase64()));

        // [THEN] The invoice total is the amount registered at Fiskaly and its VAT is the VAT of the item only
        InvoiceTotalLineIndex := FindPrintedLine(PrintedLines, TotalLbl, 1);
        AssertPrintedLineContains(PrintedLines, InvoiceTotalLineIndex, FormatReceiptAmount(ESPOSAuditLogAuxInfo."Amount Incl. Tax"));
        ItemVATLineIndex := FindPrintedLine(PrintedLines, GetReceiptVATLabel(ItemPOSEntrySalesLine."VAT Identifier"), FindPrintedLine(PrintedLines, CopyStr(ItemPOSEntrySalesLine.Description, 1, 15), 1) + 1);
        Assert.IsTrue(ItemVATLineIndex < InvoiceTotalLineIndex, 'VAT of the item must be printed in the invoice part of the receipt.');
        AssertPrintedLineContains(PrintedLines, ItemVATLineIndex, FormatReceiptAmount(ItemPOSEntrySalesLine."Amount Incl. VAT" - ItemPOSEntrySalesLine."Amount Excl. VAT"));

        // [THEN] The prepayment is printed after the invoice total, followed by the amount the customer paid
        // Descriptions longer than the description column wrap onto the next line, where the amount is printed
        DepositLineIndex := FindPrintedLine(PrintedLines, CopyStr(DepositPOSEntrySalesLine.Description, 1, 15), 1);
        Assert.IsTrue(DepositLineIndex > InvoiceTotalLineIndex, DepositAfterInvoiceTotalErr);
        Assert.IsTrue(FindPrintedLine(PrintedLines, FormatReceiptAmount(DepositPOSEntrySalesLine."Amount Incl. VAT"), DepositLineIndex) <= DepositLineIndex + 1, 'The prepayment amount must be printed with the prepayment line.');
        AssertPrintedLineContains(PrintedLines, FindPrintedLine(PrintedLines, AmountToPayLbl, DepositLineIndex), FormatReceiptAmount(POSEntry."Amount Incl. Tax"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure ReturnItemAndPayPrepaymentOfSalesOrder()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
    begin
        // [SCENARIO] A sale that pays a prepayment of a sales order and returns a fiscalized item is fiscalized as a correcting invoice of the returned item, whatever the order of its lines
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Paying a prepayment of a sales order, larger than the item, and then returning a fiscalized item in the same POS sale
        POSEntry.Get(DoPrepaymentAndItemReturnSale());

        // [THEN] The returned item is issued at Fiskaly as a correcting invoice
        ESPOSAuditLogAuxInfo.FindAuditLog(POSEntry."Entry No.");
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice Type"::CORRECTING, ESPOSAuditLogAuxInfo."Invoice Type", ESPOSAuditLogAuxInfo.FieldCaption("Invoice Type"));
        Assert.AreEqual(ESPOSAuditLogAuxInfo."Invoice State"::ISSUED, ESPOSAuditLogAuxInfo."Invoice State", ESPOSAuditLogAuxInfo.FieldCaption("Invoice State"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure SellItemWithGLAccountDiscountLine()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
    begin
        // [SCENARIO] A G/L account line of a sale, such as a GS1 coupon discount, stays part of the amount fiscalized at Fiskaly
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Selling an item with a G/L account discount line
        POSEntry.Get(DoItemAndGLAccountDiscountSale());

        // [THEN] The amount fiscalized at Fiskaly is the total of the sale
        ESPOSAuditLogAuxInfo.FindAuditLog(POSEntry."Entry No.");
        Assert.AreEqual(POSEntry."Amount Incl. Tax", ESPOSAuditLogAuxInfo."Amount Incl. Tax", ESPOSAuditLogAuxInfo.FieldCaption("Amount Incl. Tax"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure PrintReceiptOfItemSaleWithGLAccountDiscountLine()
    var
        GLPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        Base64: Codeunit "Base64 Convert";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
        PrintedLines: List of [Text];
        InvoiceTotalLineIndex: Integer;
        TotalLbl: Label 'Total', Locked = true;
        AmountToPayLbl: Label 'Amount to Pay', Locked = true;
    begin
        // [SCENARIO] The fiscal receipt of a sale with a G/L account discount line prints that line as part of the invoice
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] Ended sale of an item with a G/L account discount line
        POSEntry.Get(DoItemAndGLAccountDiscountSale());
        GLPOSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        GLPOSEntrySalesLine.SetRange(Type, GLPOSEntrySalesLine.Type::"G/L Account");
        GLPOSEntrySalesLine.FindFirst();

        // [WHEN] Printing the fiscal receipt
        BindSubscription(RetailPrintHandler);
        Codeunit.Run(Codeunit::"NPR ES Fiscal Thermal Print", POSEntry);
        UnbindSubscription(RetailPrintHandler);
        PrintedLines := GetPrintedLines(Base64.FromBase64(RetailPrintHandler.GetPrintJobBase64()));

        // [THEN] The G/L account line is printed before the invoice total, which is the total of the sale, and no separate amount to pay is printed
        InvoiceTotalLineIndex := FindPrintedLine(PrintedLines, TotalLbl, 1);
        Assert.IsTrue(FindPrintedLine(PrintedLines, GLPOSEntrySalesLine.Description, 1) < InvoiceTotalLineIndex, 'The G/L account line must be printed in the invoice part of the receipt.');
        AssertPrintedLineContains(PrintedLines, InvoiceTotalLineIndex, FormatReceiptAmount(POSEntry."Amount Incl. Tax"));
        Assert.IsFalse(IsTextPrinted(PrintedLines, AmountToPayLbl), 'A receipt without prepayment lines must not print a separate amount to pay.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,AfterEndSaleErrorMessageHandler')]
    procedure SaleOfOnlyAGLAccountLineIsStillFiscalized()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
    begin
        // [SCENARIO] PR review: only prepayments and customer deposits are invoiced outside Fiskaly. A sale of only a G/L account line, such as a shipment fee,
        // must still be fiscalized, so that a rejection by Fiskaly is shown instead of the sale silently ending without a fiscal invoice.
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [WHEN] Ending a sale of only a G/L account line
        POSEntry.Get(DoGLAccountOnlySale());

        // [THEN] The sale has an ES audit record, so it is sent to Fiskaly
        Assert.IsTrue(ESPOSAuditLogAuxInfo.FindAuditLog(POSEntry."Entry No."), 'A sale of only a G/L account line must have an ES audit record.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure PrintReceiptOfItemSaleWithCommentLine()
    var
        POSEntry: Record "NPR POS Entry";
        Base64: Codeunit "Base64 Convert";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
        PrintedLines: List of [Text];
        CommentTxt: Label 'ES receipt comment', Locked = true;
        TotalLbl: Label 'Total', Locked = true;
    begin
        // [SCENARIO] PR review: a comment line of a sale is printed on the fiscal receipt, although the POS entry excludes comment lines from posting like the lines it carries for async posting
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] Ended sale of an item with a comment line
        POSEntry.Get(DoItemAndCommentSale(CommentTxt));

        // [WHEN] Printing the fiscal receipt
        BindSubscription(RetailPrintHandler);
        Codeunit.Run(Codeunit::"NPR ES Fiscal Thermal Print", POSEntry);
        UnbindSubscription(RetailPrintHandler);
        PrintedLines := GetPrintedLines(Base64.FromBase64(RetailPrintHandler.GetPrintJobBase64()));

        // [THEN] The comment is printed among the sale lines, before the invoice total
        Assert.IsTrue(FindPrintedLine(PrintedLines, CommentTxt, 1) < FindPrintedLine(PrintedLines, TotalLbl, 1), 'The comment line must be printed among the sale lines.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler')]
    procedure PrintReceiptOfItemReturnWithPrepaymentOfSalesOrder()
    var
        DepositPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        ReturnPOSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntry: Record "NPR POS Entry";
        Base64: Codeunit "Base64 Convert";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
        PrintedLines: List of [Text];
        DepositLineIndex: Integer;
        InvoiceTotalLineIndex: Integer;
        TotalLbl: Label 'Total', Locked = true;
        AmountToPayLbl: Label 'Amount to Pay', Locked = true;
        DepositAfterInvoiceTotalErr: Label 'The prepayment line must be printed after the invoice total, since it is not part of the invoice.', Locked = true;
    begin
        // [SCENARIO] The fiscal receipt of a return with a larger prepayment of a sales order shows the correcting invoice of the returned item as its total, with the prepayment printed apart from it
        // [GIVEN] POS and ES audit setup
        InitializeData();

        // [GIVEN] Ended sale that pays a prepayment of a sales order and returns a fiscalized item
        POSEntry.Get(DoPrepaymentAndItemReturnSale());
        ReturnPOSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        ReturnPOSEntrySalesLine.SetRange(Type, ReturnPOSEntrySalesLine.Type::Item);
        ReturnPOSEntrySalesLine.FindFirst();
        DepositPOSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        DepositPOSEntrySalesLine.SetRange(Type, DepositPOSEntrySalesLine.Type::Customer);
        DepositPOSEntrySalesLine.FindFirst();

        // [WHEN] Printing the fiscal receipt
        BindSubscription(RetailPrintHandler);
        Codeunit.Run(Codeunit::"NPR ES Fiscal Thermal Print", POSEntry);
        UnbindSubscription(RetailPrintHandler);
        PrintedLines := GetPrintedLines(Base64.FromBase64(RetailPrintHandler.GetPrintJobBase64()));

        // [THEN] The invoice total is the negative amount of the returned item, not the positive total of the sale
        InvoiceTotalLineIndex := FindPrintedLine(PrintedLines, TotalLbl, 1);
        AssertPrintedLineContains(PrintedLines, InvoiceTotalLineIndex, FormatReceiptAmount(ReturnPOSEntrySalesLine."Amount Incl. VAT"));

        // [THEN] The prepayment is printed after the invoice total, followed by the amount the customer paid for the whole sale
        DepositLineIndex := FindPrintedLine(PrintedLines, CopyStr(DepositPOSEntrySalesLine.Description, 1, 15), 1);
        Assert.IsTrue(DepositLineIndex > InvoiceTotalLineIndex, DepositAfterInvoiceTotalErr);
        AssertPrintedLineContains(PrintedLines, FindPrintedLine(PrintedLines, AmountToPayLbl, DepositLineIndex), FormatReceiptAmount(POSEntry."Amount Incl. Tax"));
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ScheduledForPostingMessageHandler')]
    procedure PayPrepaymentOfSalesOrderWithAsyncPosting()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSActionDocPrepayB: Codeunit "NPR POS Action: Doc. Prepay B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
        SaleEnded: Boolean;
        SaleShouldEndErr: Label 'Sale with prepayment of sales order should end.', Locked = true;
    begin
        // [SCENARIO] A prepayment of a sales order posted by job queue is not fiscalized at Fiskaly, although the POS entry carries the lines of the sales order for posting
        // [GIVEN] POS and ES audit setup, with sales documents posted by job queue
        InitializeData();
        EnableSalesDocumentPostingWithJobQueue();

        // [GIVEN] Sales order of a customer
        CreateSalesOrderForPrepayment(SalesHeader);

        // [WHEN] Paying a prepayment of the sales order on POS
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(SalePOS);
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, 5, true, false, false, POSSalesDocumentPost::Asynchronous);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        BindSubscription(ESFiscalLibrary);
        SaleEnded := POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleLinePOS."Amount Including VAT", '');
        UnbindSubscription(ESFiscalLibrary);
        Assert.IsTrue(SaleEnded, SaleShouldEndErr);

        // [THEN] The prepayment is not fiscalized at Fiskaly
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.RecordIsEmpty(ESPOSAuditLogAuxInfo);
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('GeneralConfirmHandler,ScheduledForPostingMessageHandler')]
    procedure SellItemAndPayPrepaymentOfSalesOrderWithAsyncPosting()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        Base64: Codeunit "Base64 Convert";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        RetailPrintHandler: Codeunit "NPR Retail Print Handler";
        InvoiceBody: JsonObject;
        ItemsToken: JsonToken;
        PrintedLines: List of [Text];
        TotalLbl: Label 'Total', Locked = true;
        SalesOrderLineQuantityLbl: Label '10x', Locked = true;
    begin
        // [SCENARIO] A sale of an item together with a prepayment of a sales order posted by job queue is fiscalized and printed with the sold item only, without the lines of the sales order that the POS entry carries for posting
        // [GIVEN] POS and ES audit setup, with sales documents posted by job queue
        InitializeData();
        EnableSalesDocumentPostingWithJobQueue();

        // [WHEN] Selling an item and paying a prepayment of a sales order in the same POS sale
        POSEntry.Get(DoItemAndPrepaymentSale(ESFiscalLibrary, Enum::"NPR POS Sales Document Post"::Asynchronous));

        // [THEN] Only the sold item is sent to Fiskaly
        InvoiceBody.ReadFrom(ESFiscalLibrary.GetLastCreateInvoiceBody());
        InvoiceBody.SelectToken('$.content.items', ItemsToken);
        Assert.AreEqual(1, ItemsToken.AsArray().Count(), 'Number of items sent to Fiskaly');

        // [THEN] The fiscal receipt shows the registered amount and does not print the lines of the sales order (quantity 10)
        ESPOSAuditLogAuxInfo.FindAuditLog(POSEntry."Entry No.");
        BindSubscription(RetailPrintHandler);
        Codeunit.Run(Codeunit::"NPR ES Fiscal Thermal Print", POSEntry);
        UnbindSubscription(RetailPrintHandler);
        PrintedLines := GetPrintedLines(Base64.FromBase64(RetailPrintHandler.GetPrintJobBase64()));
        AssertPrintedLineContains(PrintedLines, FindPrintedLine(PrintedLines, TotalLbl, 1), FormatReceiptAmount(ESPOSAuditLogAuxInfo."Amount Incl. Tax"));
        Assert.IsFalse(IsTextPrinted(PrintedLines, SalesOrderLineQuantityLbl), 'The lines of the sales order must not be printed on the fiscal receipt.');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    [HandlerFunctions('ScheduledForPostingMessageHandler')]
    procedure PaySalesOrderWithAsyncPosting()
    var
        ESPOSAuditLogAuxInfo: Record "NPR ES POS Audit Log Aux. Info";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSActionDocPayPostB: Codeunit "NPR POS Action: Doc.Pay&Post B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
        SaleEnded: Boolean;
        SaleShouldEndErr: Label 'Sale with payment of sales order should end.', Locked = true;
    begin
        // [SCENARIO] PR review: a full payment of a sales order posted by job queue is not fiscalized at Fiskaly, although the POS entry carries the lines of the sales order for posting,
        // since the sales invoice posted for the order is the invoice for those goods, and registering the POS sale as well would invoice them twice
        // [GIVEN] POS and ES audit setup, with sales documents posted by job queue
        InitializeData();
        EnableSalesDocumentPostingWithJobQueue();

        // [GIVEN] Sales order of a customer
        CreateSalesOrderForPrepayment(SalesHeader);

        // [WHEN] Paying the whole sales order on POS
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(SalePOS);
        POSActionDocPayPostB.CreateDocumentPaymentLine(POSSession, SalesHeader, false, false, false, POSSalesDocumentPost::Asynchronous);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        BindSubscription(ESFiscalLibrary);
        SaleEnded := POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleLinePOS."Amount Including VAT", '');
        UnbindSubscription(ESFiscalLibrary);
        Assert.IsTrue(SaleEnded, SaleShouldEndErr);

        // [THEN] The POS entry carries the lines of the sales order for posting
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSEntrySalesLine.SetRange("POS Entry No.", POSEntry."Entry No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.SetRange("Exclude from Posting", true);
        Assert.RecordIsNotEmpty(POSEntrySalesLine);

        // [THEN] The payment is not fiscalized at Fiskaly
        ESPOSAuditLogAuxInfo.SetRange("Audit Entry Type", ESPOSAuditLogAuxInfo."Audit Entry Type"::"POS Entry");
        ESPOSAuditLogAuxInfo.SetRange("POS Entry No.", POSEntry."Entry No.");
        Assert.RecordIsEmpty(ESPOSAuditLogAuxInfo);
    end;

    local procedure EnableSalesDocumentPostingWithJobQueue()
    var
        POSSalesDocumentSetup: Record "NPR POS Sales Document Setup";
    begin
        if not POSSalesDocumentSetup.Get() then
            POSSalesDocumentSetup.Insert();
        POSSalesDocumentSetup."Post with Job Queue" := true;
        POSSalesDocumentSetup.Modify();
    end;

    local procedure DoPrepaymentAndItemReturnSale(): Integer
    var
        OriginalPOSEntry: Record "NPR POS Entry";
        POSEntry: Record "NPR POS Entry";
        ReturnReason: Record "Return Reason";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSActionDocPrepayB: Codeunit "NPR POS Action: Doc. Prepay B";
        POSActionRevDirSale: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
        SaleShouldEndErr: Label 'Sale with prepayment of sales order and return of item should end.', Locked = true;
    begin
        OriginalPOSEntry.Get(DoItemSale(Enum::"NPR ES Inv. Registration State"::REGISTERED));
        CreateSalesOrderForPrepayment(SalesHeader);

        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(SalePOS);
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, 20, true, false, false, POSSalesDocumentPost::Synchronous);
        ReturnReason.FindFirst();
        POSActionRevDirSale.ReverseSalesTicket(SalePOS, OriginalPOSEntry."Document No.", ReturnReason.Code, true);
        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SalesAmount, '') then
            Error(SaleShouldEndErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoItemAndGLAccountDiscountSale(): Integer
    var
        GLAccount: Record "G/L Account";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        ItemSaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
        SaleShouldEndErr: Label 'Sale with item and G/L account discount line should end.', Locked = true;
    begin
        CreateSalesGLAccount(GLAccount);

        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(SalePOS);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);

        // Same G/L account line as a GS1 coupon discount, which turns an inserted sale line into a G/L account line
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(ItemSaleLinePOS);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"GL Payment");
        SaleLinePOS.Validate("No.", GLAccount."No.");
        SaleLinePOS."Gen. Bus. Posting Group" := ItemSaleLinePOS."Gen. Bus. Posting Group";
        SaleLinePOS."VAT Bus. Posting Group" := ItemSaleLinePOS."VAT Bus. Posting Group";
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Description := 'GS1 discount';
        SaleLinePOS.Validate("Unit Price", -2);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);

        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SalesAmount, '') then
            Error(SaleShouldEndErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoGLAccountOnlySale(): Integer
    var
        GLAccount: Record "G/L Account";
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        ChangeAmount: Decimal;
        PaidAmount: Decimal;
        RoundingAmount: Decimal;
        SalesAmount: Decimal;
        SaleShouldEndErr: Label 'Sale of only a G/L account line should end.', Locked = true;
    begin
        CreateSalesGLAccount(GLAccount);

        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(SalePOS);

        // Same G/L account line as a shipment fee, here the only line of the sale
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Validate("Line Type", SaleLinePOS."Line Type"::"GL Payment");
        SaleLinePOS.Validate("No.", GLAccount."No.");
        SaleLinePOS."Gen. Bus. Posting Group" := SalePOS."Gen. Bus. Posting Group";
        SaleLinePOS."VAT Bus. Posting Group" := SalePOS."VAT Bus. Posting Group";
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS.Description := 'Shipment fee';
        SaleLinePOS.Validate("Unit Price", 5);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);

        POSSaleWrapper.GetTotals(SalesAmount, PaidAmount, ChangeAmount, RoundingAmount);
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SalesAmount, '') then
            Error(SaleShouldEndErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure DoItemAndCommentSale(CommentText: Text): Integer
    var
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleShouldEndErr: Label 'Sale with item and comment line should end.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(SalePOS);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Line Type" := SaleLinePOS."Line Type"::Comment;
        SaleLinePOS.Description := CopyStr(CommentText, 1, MaxStrLen(SaleLinePOS.Description));
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);

        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleShouldEndErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure CreateSalesGLAccount(var GLAccount: Record "G/L Account")
    var
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Gen. Posting Type", GLAccount."Gen. Posting Type"::Sale);
        GLAccount.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
        GLAccount.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
        GLAccount.Modify();
    end;

    local procedure DoItemAndPrepaymentSale(var ESFiscalLibrary: Codeunit "NPR Library ES Fiscal"): Integer
    begin
        exit(DoItemAndPrepaymentSale(ESFiscalLibrary, Enum::"NPR POS Sales Document Post"::Synchronous));
    end;

    local procedure DoItemAndPrepaymentSale(var ESFiscalLibrary: Codeunit "NPR Library ES Fiscal"; POSSalesDocumentPost: Enum "NPR POS Sales Document Post"): Integer
    var
        POSEntry: Record "NPR POS Entry";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalesHeader: Record "Sales Header";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        POSActionDocPrepayB: Codeunit "NPR POS Action: Doc. Prepay B";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleShouldEndErr: Label 'Sale with item and prepayment of sales order should end.', Locked = true;
    begin
        CreateSalesOrderForPrepayment(SalesHeader);

        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(SalePOS);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        POSActionDocPrepayB.CreatePrepaymentLine(POSSession, SalesHeader, false, 5, true, false, false, POSSalesDocumentPost);
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.CalcSums("Amount Including VAT");
        ESFiscalLibrary.SetInvoiceRegistrationState(Enum::"NPR ES Inv. Registration State"::REGISTERED);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, SaleLinePOS."Amount Including VAT", '') then
            Error(SaleShouldEndErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    local procedure GetPrintedLines(PrintJob: Text) PrintedLines: List of [Text]
    var
        PrintedLine: Text;
        LineFeed: Text[1];
        Index: Integer;
    begin
        // Keep the printable text only, so printer commands do not hide it in assertion messages
        LineFeed[1] := 10;
        foreach PrintedLine in PrintJob.Split(LineFeed) do begin
            for Index := StrLen(PrintedLine) downto 1 do
                if PrintedLine[Index] < 32 then
                    PrintedLine := DelStr(PrintedLine, Index, 1);
            PrintedLines.Add(PrintedLine);
        end;
    end;

    local procedure FindPrintedLine(PrintedLines: List of [Text]; Text: Text; FromIndex: Integer): Integer
    var
        Index: Integer;
        TextNotPrintedErr: Label '''%1'' is not printed on the receipt.', Locked = true;
    begin
        for Index := FromIndex to PrintedLines.Count() do
            if PrintedLines.Get(Index).Contains(Text) then
                exit(Index);
        Error(TextNotPrintedErr, Text);
    end;

    local procedure IsTextPrinted(PrintedLines: List of [Text]; Text: Text): Boolean
    var
        PrintedLine: Text;
    begin
        foreach PrintedLine in PrintedLines do
            if PrintedLine.Contains(Text) then
                exit(true);
    end;

    local procedure GetReceiptVATLabel(VATIdentifier: Code[20]): Text
    var
        IncludingVATLbl: Label 'Including VAT', Locked = true;
    begin
        if VATIdentifier <> '' then
            exit(VATIdentifier);
        exit(IncludingVATLbl);
    end;

    local procedure AssertPrintedLineContains(PrintedLines: List of [Text]; Index: Integer; Text: Text)
    var
        LineDoesNotContainErr: Label 'Receipt line ''%1'' must contain ''%2''.', Locked = true;
    begin
        Assert.IsTrue(PrintedLines.Get(Index).Contains(Text), StrSubstNo(LineDoesNotContainErr, PrintedLines.Get(Index), Text));
    end;

    local procedure FormatReceiptAmount(Amount: Decimal): Text
    begin
        exit(Format(Amount, 0, '<Precision,2:2><Standard Format,2>'));
    end;

    local procedure DoItemSale(InvoiceRegistrationState: Enum "NPR ES Inv. Registration State"): Integer
    var
        POSEntry: Record "NPR POS Entry";
        POSSale: Record "NPR POS Sale";
        POSMockLibrary: Codeunit "NPR Library - POS Mock";
        ESFiscalLibrary: Codeunit "NPR Library ES Fiscal";
        POSSaleWrapper: Codeunit "NPR POS Sale";
        SaleNotEndedAsExpectedErr: Label 'Sale not ended as expected.', Locked = true;
    begin
        POSMockLibrary.InitializePOSSessionAndStartSale(POSSession, POSUnit, Salesperson, POSSaleWrapper);
        POSSaleWrapper.GetCurrentSale(POSSale);
        POSMockLibrary.CreateItemLine(POSSession, Item."No.", 1);
        ESFiscalLibrary.SetInvoiceRegistrationState(InvoiceRegistrationState);
        BindSubscription(ESFiscalLibrary);
        if not POSMockLibrary.PayAndTryEndSaleAndStartNew(POSSession, POSPaymentMethod.Code, Item."Unit Price", '') then
            Error(SaleNotEndedAsExpectedErr);
        UnbindSubscription(ESFiscalLibrary);

        POSEntry.SetRange("Document No.", POSSale."Sales Ticket No.");
        POSEntry.FindFirst();
        POSSession.ClearAll();
        Clear(POSSession);
        exit(POSEntry."Entry No.");
    end;

    [ConfirmHandler]
    procedure GeneralConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
        CancelConfirmQst: Label 'Are you sure that you want to cancel this invoice since it is irreversible?';
        CreateCompleteInvoiceQst: Label 'Do you want to create complete invoice?', Locked = true;
        QuestionNotExpectedErr: Label 'Question "%1" is not expected.', Locked = true;
    begin
        case true of
            Question = CancelConfirmQst:
                Reply := true;
            Question = CreateCompleteInvoiceQst:
                Reply := false;
            else
                Error(QuestionNotExpectedErr, Question);
        end;
    end;

    [MessageHandler]
    procedure ScheduledForPostingMessageHandler(Message: Text[1024])
    var
        ScheduledForPostingTxt: Label 'has been scheduled for posting', Locked = true;
        MessageNotExpectedErr: Label 'Message "%1" is not expected.', Locked = true;
    begin
        if not Message.Contains(ScheduledForPostingTxt) then
            Error(MessageNotExpectedErr, Message);
    end;

    [MessageHandler]
    procedure AfterEndSaleErrorMessageHandler(Message: Text[1024])
    var
        AfterEndSaleErrorTxt: Label 'An error occurred after the sale ended', Locked = true;
        MessageNotExpectedErr: Label 'Message "%1" is not expected.', Locked = true;
    begin
        // Fiskaly rejects an invoice without items, and the POS reports errors raised after the sale ended in a message
        if not Message.Contains(AfterEndSaleErrorTxt) then
            Error(MessageNotExpectedErr, Message);
    end;

    local procedure InitializeData()
    var
        ESOrganization: Record "NPR ES Organization";
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
        if Initialized then begin
            // Clean any previous mock session
            POSSession.ClearAll();
            Clear(POSSession);
        end else begin
            POSMasterDataLibrary.CreatePOSSetup(POSSetup);
            POSMasterDataLibrary.CreateDefaultVoucherType(VoucherTypeDefault, false);
            POSMasterDataLibrary.CreateDefaultPostingSetup(POSPostingProfile);
            POSPostingProfile."POS Period Register No. Series" := '';
            POSPostingProfile.Modify();
            POSMasterDataLibrary.CreatePOSStore(POSStore, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSUnit(POSUnit, POSStore.Code, POSPostingProfile.Code);
            POSMasterDataLibrary.CreatePOSPaymentMethod(POSPaymentMethod, POSPaymentMethod."Processing Type"::CASH, '', false);
            POSMasterDataLibrary.CreateItemForPOSSaleUsage(Item, POSUnit, POSStore);
            CreateSalesperson();

            LibraryERM.CreateReturnReasonCode(ReturnReason);
            Item."Unit Price" := 10;
            Item.Modify();

            VATPostingSetup.SetRange("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
            VATPostingSetup.SetRange("VAT Bus. Posting Group", POSPostingProfile."VAT Bus. Posting Group");
            VATPostingSetup.SetFilter("VAT %", '<>%1', 0);
            VATPostingSetup.FindFirst();
            ESFiscalLibrary.CreateAuditProfileAndESSetups(POSAuditProfile, VATPostingSetup, POSUnit);
            ESFiscalLibrary.CreateESOrganization(ESOrganization, Enum::"NPR ES Taxpayer Territory"::BIZKAIA, Enum::"NPR ES Taxpayer Type"::COMPANY);
            ESFiscalLibrary.CreateESSigner(ESSigner, ESOrganization.Code);
            ESFiscalLibrary.CreateESClient(ESClient, ESSigner, POSUnit."No.", ESOrganization.Code);

            Initialized := true;
        end;

        POSAuditLog.DeleteAll(true); // Clean between tests
        Commit();
    end;

    local procedure CreateSalesOrderForPrepayment(var SalesHeader: Record "Sales Header")
    var
        Customer: Record Customer;
        GeneralPostingSetup: Record "General Posting Setup";
        GLAccount: Record "G/L Account";
        SalesLine: Record "Sales Line";
        SalesSetup: Record "Sales & Receivables Setup";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
    begin
        LibrarySales.CreateCustomer(Customer);

        SalesSetup.Get();
        if SalesSetup."Posted Prepmt. Inv. Nos." = '' then begin
            SalesSetup."Posted Prepmt. Inv. Nos." := LibraryERM.CreateNoSeriesCode();
            SalesSetup.Modify();
        end;

        if not GeneralPostingSetup.Get(Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
            LibraryERM.CreateGeneralPostingSetup(GeneralPostingSetup, Customer."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
        if GeneralPostingSetup."Sales Prepayments Account" = '' then begin
            LibraryERM.CreateGLAccount(GLAccount);
            GLAccount.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
            GLAccount.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
            GLAccount.Modify();
            GeneralPostingSetup.Validate("Sales Prepayments Account", GLAccount."No.");
            GeneralPostingSetup.Modify();
        end else begin
            GLAccount.Get(GeneralPostingSetup."Sales Prepayments Account");
            if (GLAccount."Gen. Prod. Posting Group" = '') or (GLAccount."VAT Prod. Posting Group" = '') then begin
                GLAccount.Validate("Gen. Prod. Posting Group", Item."Gen. Prod. Posting Group");
                GLAccount.Validate("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                GLAccount.Modify();
            end;
        end;
        if not VATPostingSetup.Get(Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group") then
            LibraryERM.CreateVATPostingSetup(VATPostingSetup, Customer."VAT Bus. Posting Group", Item."VAT Prod. Posting Group");

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 10);
    end;

    local procedure CreateSalesperson()
    begin
        if not Salesperson.Get('1') then begin
            Salesperson.Init();
            Salesperson.Validate(Code, '1');
            Salesperson.Validate(Name, 'Test');
            Salesperson.Insert();
        end;
        Salesperson."NPR Register Password" := '1';
        Salesperson.Modify();
    end;
}
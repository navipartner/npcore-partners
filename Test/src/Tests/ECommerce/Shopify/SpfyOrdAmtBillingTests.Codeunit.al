codeunit 85576 "NPR Spfy Ord Amt Billing Tests"
{
    // [FEATURE] Shopify order amount billing events
    // A Shopify payment line is billed once in presentment and once in shop currency, under event ids stored on the line.
    // They are registered when the capture is confirmed and again when the line is posted; the stored ids make the second call a no-op.
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _LibBilling: Codeunit "NPR Library - Spfy Billing";
        _LibInventory: Codeunit "Library - Inventory";
        _LibSales: Codeunit "Library - Sales";
        _CardGLAccountNo: Code[20];
        _TransactionNo: Integer;
        _Initialized: Boolean;

    [Test]
    procedure CapturedLinePostedInFull_PostingQueuesNoSecondAmountEvent()
    var
        SalesHeader: Record "Sales Header";
        OrderPaymentLine: Record "NPR Magento Payment Line";
        InvoicePaymentLine: Record "NPR Magento Payment Line";
        InvoiceNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] Posting an order whose Shopify payment was billed at capture copies the line onto the invoice with the stored event ids, so posting bills nothing more.
        Initialize();

        // [GIVEN] A sales order paid by a Shopify card line, captured and billed in both currencies
        CreateOrder(SalesHeader, 300, 0);
        AddShopifyCardLine(SalesHeader, OrderPaymentLine);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();
        ConfirmCapture(OrderPaymentLine);
        _Assert.AreEqual(2, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'The confirmed capture must queue one amount event in each currency.');

        // [WHEN] The order is shipped and invoiced
        InvoiceNo := _LibSales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The posted invoice line keeps both event ids from the capture
        FindInvoicePaymentLine(InvoiceNo, InvoicePaymentLine);
        _Assert.IsTrue(InvoicePaymentLine.Posted, 'The payment line must be posted with the invoice.');
        _Assert.AreEqual(OrderPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", InvoicePaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The invoice line must keep the presentment currency event id stored at capture.');
        _Assert.AreEqual(OrderPaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", InvoicePaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", 'The invoice line must keep the shop currency event id stored at capture.');
        // [THEN] Posting queued no further amount event
        _Assert.AreEqual(2, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'Posting a payment already billed at capture must not bill it again.');
    end;

    [Test]
    procedure CapturedLineInvoicedInTwoParts_NeitherInvoiceQueuesAnAmountEvent()
    var
        SalesHeader: Record "Sales Header";
        OrderPaymentLine: Record "NPR Magento Payment Line";
        InvoicePaymentLine: Record "NPR Magento Payment Line";
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] A Shopify payment billed at capture and split over two partial invoices is billed once in total, not once per invoice.
        Initialize();

        // [GIVEN] A sales order of two lines paid by one Shopify card line, captured and billed in both currencies
        CreateOrder(SalesHeader, 100, 200);
        OrderNo := SalesHeader."No.";
        AddShopifyCardLine(SalesHeader, OrderPaymentLine);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();
        ConfirmCapture(OrderPaymentLine);
        // [GIVEN] The first line has been invoiced, which splits the card line
        SetLineToPost(SalesHeader, 1);
        FirstInvoiceNo := _LibSales.PostSalesDocument(SalesHeader, true, true);
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        SetLineToPost(SalesHeader, 2);

        // [WHEN] The rest of the order is invoiced
        SecondInvoiceNo := _LibSales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Both invoice lines carry the presentment currency event id stored at capture
        FindInvoicePaymentLine(FirstInvoiceNo, InvoicePaymentLine);
        _Assert.AreEqual(OrderPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", InvoicePaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The first invoice line must keep the event id stored at capture.');
        FindInvoicePaymentLine(SecondInvoiceNo, InvoicePaymentLine);
        _Assert.AreEqual(OrderPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", InvoicePaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The second invoice line must keep the event id stored at capture.');
        // [THEN] Only the two events of the capture are queued
        _Assert.AreEqual(2, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A payment split over two invoices must be billed once, at capture.');
    end;

    [Test]
    procedure UncapturedLinePosted_PostingQueuesEachAmountEventOnce()
    var
        SalesHeader: Record "Sales Header";
        OrderPaymentLine: Record "NPR Magento Payment Line";
        InvoicePaymentLine: Record "NPR Magento Payment Line";
        InvoiceNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] A Shopify payment line posted before any capture was confirmed is still billed at posting, once in each currency, each event with its own amount and currency.
        Initialize();

        // [GIVEN] A sales order paid by a Shopify card line that has not been captured, worth 400 in the EUR shop currency
        CreateOrder(SalesHeader, 300, 0);
        AddShopifyCardLine(SalesHeader, OrderPaymentLine);
        OrderPaymentLine."Amount (Store Currency)" := 400;
        OrderPaymentLine."Requested Amt. (Store Curr.)" := 400;
        OrderPaymentLine."Store Currency Code" := 'EUR';
        OrderPaymentLine.Modify();
        _Assert.AreNotEqual('EUR', OrderPaymentLine.TransactionCurrencyCode(false), 'Precondition: the presentment and the shop currency must differ, or the currency of each event cannot be told apart.');
        _Assert.AreNotEqual(400, OrderPaymentLine.Amount, 'Precondition: the presentment and the shop currency amounts must differ, or the amount of each event cannot be told apart.');
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The order is shipped and invoiced
        InvoiceNo := _LibSales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] The posted invoice line is billed in both currencies under the ids stored on it, each event for its own amount
        FindInvoicePaymentLine(InvoiceNo, InvoicePaymentLine);
        _LibBilling.AssertSingleAmountQueueEntry(InvoicePaymentLine."NPR Spfy Ord.Amt.PCY Event Id", "NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_PRESENTMENT, OrderPaymentLine.Amount);
        _LibBilling.AssertSingleAmountQueueEntry(InvoicePaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", "NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_SHOP, 400);
        _Assert.AreEqual(2, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'Posting must bill an uncaptured payment exactly once in each currency.');
        // [THEN] Each event names its own currency: the document's for the presentment event, the shop's for the shop currency event
        _Assert.AreEqual(OrderPaymentLine.TransactionCurrencyCode(false), _LibBilling.AmountQueueEntryMetadata(InvoicePaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'currency'), 'The presentment currency event must carry the currency of the document.');
        _Assert.AreEqual('EUR', _LibBilling.AmountQueueEntryMetadata(InvoicePaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", 'currency'), 'The shop currency event must carry the shop currency.');
    end;

    [Test]
    procedure PostedLineCaptureConfirmedLater_IsNotBilledAgain()
    var
        PaymentLine: Record "NPR Magento Payment Line";
        EventBillingClient: Codeunit "NPR Event Billing Client";
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] A line posted before its capture was confirmed was billed at posting, so confirming its capture later bills nothing, also when an older version billed it without storing the presentment event id.
        Initialize();

        // [GIVEN] A posted Shopify invoice payment line of 500, worth 400 in shop currency, with no capture date, billed at posting the old way: presentment under its SystemId, shop currency under a stored id
        CreatePostedInvoicePaymentLine(PaymentLine, 500, 400);
        EventBillingClient.RegisterEvent(PaymentLine.SystemId, "NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_PRESENTMENT, 500);
        PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id" := CreateGuid();
        PaymentLine.Modify();
        EventBillingClient.RegisterEvent(PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", "NPR Billing Event Type"::ECOM_SHOPIFY_ORDERS_AMOUNT_SHOP, 400);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();

        // [WHEN] Its capture is confirmed
        ConfirmCapture(PaymentLine);

        // [THEN] Nothing new is queued and the line gets no presentment event id
        _Assert.AreEqual(0, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A line billed at posting must not be billed again when its capture is confirmed.');
        _Assert.IsTrue(IsNullGuid(PaymentLine."NPR Spfy Ord.Amt.PCY Event Id"), 'Confirming the capture of a posted line must not bill it, so it must not assign a presentment event id.');
    end;

    [Test]
    procedure LineCapturedOnEcomDocument_AmountEventsCarryTheStoreCode()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        StoreCode: Code[20];
    begin
        // [SCENARIO] A Shopify payment captured while its line still belongs to the ecommerce document, as virtual items are, is billed with the Shopify store the order came from.
        Initialize();

        // [GIVEN] A Shopify order on the ecommerce route, whose event log entry names its store, with a Shopify card payment line of 200 still on the ecommerce document
        StoreCode := CreateShopifyEcomOrder(EcomSalesHeader);
        CreateEcomDocumentPaymentLine(EcomSalesHeader, PaymentLine, 200);

        // [WHEN] Its capture is confirmed
        ConfirmCapture(PaymentLine);

        // [THEN] Both amount events carry the store code
        _Assert.AreEqual(StoreCode, _LibBilling.AmountQueueEntryMetadata(PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'shopify_store_code'), 'The presentment currency event must name the Shopify store of the order.');
        _Assert.AreEqual(StoreCode, _LibBilling.AmountQueueEntryMetadata(PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", 'shopify_store_code'), 'The shop currency event must name the Shopify store of the order.');
    end;

    [Test]
    procedure BilledOrderDeletedAndLineRecreated_RecreatedLineIsNotBilledAgain()
    var
        SalesHeader: Record "Sales Header";
        DeletedPaymentLine: Record "NPR Magento Payment Line";
        PaymentLine: Record "NPR Magento Payment Line";
        PmtLineBillingIds: Record "NPR Spfy Pmt. Line Billing Ids";
        ShopifyTransactionID: Text[30];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] When a sales order whose Shopify payment was billed at capture is deleted and the order is imported again, the payment line re-created for the same transaction takes over the old event ids and is not billed a second time.
        Initialize();

        // [GIVEN] A sales order paid by a Shopify card line, captured and billed in both currencies
        CreateOrder(SalesHeader, 300, 0);
        AddShopifyCardLine(SalesHeader, DeletedPaymentLine);
        ShopifyTransactionID := TransactionId();
        ConfirmCapture(DeletedPaymentLine);
        // [GIVEN] The user deleted the order
        SalesHeader.Delete(true);
        // [GIVEN] The order was imported again, with a card line for the same Shopify transaction
        CreateOrder(SalesHeader, 300, 0);
        AddShopifyCardLineForTransaction(SalesHeader, PaymentLine, ShopifyTransactionID);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The capture of the re-created line is confirmed
        ConfirmCapture(PaymentLine);

        // [THEN] The re-created line carries the event ids of the deleted line
        _Assert.AreEqual(DeletedPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The re-created line must take over the presentment currency event id of the deleted line.');
        _Assert.AreEqual(DeletedPaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", 'The re-created line must take over the shop currency event id of the deleted line.');
        // [THEN] No further amount event is queued
        _Assert.AreEqual(0, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A transaction already billed must not be billed again when its payment line is re-created.');
        // [THEN] The kept ids are used up
        _Assert.IsFalse(PmtLineBillingIds.Get(ShopifyTransactionID), 'The kept event ids must be removed once a re-created line has taken them over.');
    end;

    [Test]
    procedure BilledOrderDeleted_LineForAnotherTransactionIsStillBilled()
    var
        SalesHeader: Record "Sales Header";
        DeletedPaymentLine: Record "NPR Magento Payment Line";
        PaymentLine: Record "NPR Magento Payment Line";
        PmtLineBillingIds: Record "NPR Spfy Pmt. Line Billing Ids";
        DeletedTransactionID: Text[30];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] Ids kept from a deleted payment line are taken over only by a line of the same Shopify transaction; a line of another transaction is billed under ids of its own.
        Initialize();

        // [GIVEN] A sales order paid by a Shopify card line, captured, billed and then deleted by the user
        CreateOrder(SalesHeader, 300, 0);
        AddShopifyCardLine(SalesHeader, DeletedPaymentLine);
        DeletedTransactionID := TransactionId();
        ConfirmCapture(DeletedPaymentLine);
        SalesHeader.Delete(true);
        // [GIVEN] Another sales order paid by a Shopify card line of a different transaction
        CreateOrder(SalesHeader, 300, 0);
        AddShopifyCardLine(SalesHeader, PaymentLine);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();

        // [WHEN] Its capture is confirmed
        ConfirmCapture(PaymentLine);

        // [THEN] It is billed once in each currency, under ids that are not the deleted line's
        _Assert.AreEqual(2, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A line of another transaction must be billed once in each currency.');
        _Assert.AreNotEqual(DeletedPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'A line of another transaction must not take over the ids kept from the deleted line.');
        // [THEN] The ids kept from the deleted line still wait for their own transaction
        PmtLineBillingIds.Get(DeletedTransactionID);
        _Assert.AreEqual(DeletedPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", PmtLineBillingIds."PCY Event Id", 'The ids kept from the deleted line must stay until a line of its transaction takes them over.');
    end;

    [Test]
    procedure UnbilledOrderDeleted_KeepsNoIds()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        PmtLineBillingIds: Record "NPR Spfy Pmt. Line Billing Ids";
        ShopifyTransactionID: Text[30];
    begin
        // [SCENARIO] Deleting a sales order whose Shopify payment line was never billed keeps nothing, so a later line of that transaction is billed normally.
        Initialize();

        // [GIVEN] A sales order paid by a Shopify card line that has not been captured or billed
        CreateOrder(SalesHeader, 300, 0);
        AddShopifyCardLine(SalesHeader, PaymentLine);
        ShopifyTransactionID := TransactionId();

        // [WHEN] The user deletes the order
        SalesHeader.Delete(true);

        // [THEN] No event ids are kept for the transaction
        _Assert.IsFalse(PmtLineBillingIds.Get(ShopifyTransactionID), 'A payment line that was never billed must not leave kept event ids behind.');
    end;

    [Test]
    procedure BilledOrderPosted_KeepsNoIdsForRecreation()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        PmtLineBillingIds: Record "NPR Spfy Pmt. Line Billing Ids";
        ShopifyTransactionID: Text[30];
    begin
        // [SCENARIO] Posting deletes the sales order without keeping the billing event ids of its payment lines, since the posted invoice lines carry them.
        Initialize();

        // [GIVEN] A sales order paid by a Shopify card line, captured and billed in both currencies
        CreateOrder(SalesHeader, 300, 0);
        AddShopifyCardLine(SalesHeader, PaymentLine);
        ShopifyTransactionID := TransactionId();
        ConfirmCapture(PaymentLine);

        // [WHEN] The order is shipped and invoiced
        _LibSales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] No event ids are kept for the transaction
        _Assert.IsFalse(PmtLineBillingIds.Get(ShopifyTransactionID), 'Posting must not keep the event ids of the order payment lines it deletes.');
    end;

    [Test]
    procedure BilledLineDeletedBesideAnotherLineOfItsTransaction_OtherLineIsBilledOnItsOwn()
    var
        SalesHeader: Record "Sales Header";
        DeletedPaymentLine: Record "NPR Magento Payment Line";
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        ShopifyTransactionID: Text[30];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] A billed payment line deleted while another line of the same Shopify transaction stays on the order keeps no ids, since a later line of the transaction cannot be told apart as its replacement, so the remaining line is billed for its own amount.
        Initialize();

        // [GIVEN] A sales order with two card lines of one Shopify transaction, as the ecommerce route leaves a captured virtual item line beside the line for the rest; the first is captured and billed
        CreateOrder(SalesHeader, 100, 200);
        AddShopifyCardLine(SalesHeader, DeletedPaymentLine);
        ShopifyTransactionID := TransactionId();
        AddShopifyCardLineForTransaction(SalesHeader, PaymentLine, ShopifyTransactionID);
        ConfirmCapture(DeletedPaymentLine);
        // [GIVEN] The user deleted the billed line from the Payment Line List
        SpfyPaymentGatewayHdlr.KeepBillingEventIds(DeletedPaymentLine);
        DeletedPaymentLine.Delete(true);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The capture of the remaining line is confirmed
        ConfirmCapture(PaymentLine);

        // [THEN] The remaining line is billed once in each currency, under ids of its own
        _Assert.AreEqual(2, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'The remaining line of the transaction must be billed once in each currency.');
        _Assert.AreNotEqual(DeletedPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The remaining line must not take over the ids of the deleted line.');
    end;

    [Test]
    procedure RecreatedLineInvoicedInTwoParts_NeitherInvoiceIsBilledAgain()
    var
        SalesHeader: Record "Sales Header";
        DeletedPaymentLine: Record "NPR Magento Payment Line";
        PaymentLine: Record "NPR Magento Payment Line";
        InvoicePaymentLine: Record "NPR Magento Payment Line";
        ShopifyTransactionID: Text[30];
        FirstInvoiceNo: Code[20];
        SecondInvoiceNo: Code[20];
        OrderNo: Code[20];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] A payment line re-created for a billed transaction and invoiced in two parts before any capture is confirmed is billed by neither invoice, because the order line takes over the kept ids before its first invoice copy is made.
        Initialize();

        // [GIVEN] A sales order paid by a Shopify card line, captured, billed and then deleted by the user
        CreateOrder(SalesHeader, 100, 200);
        AddShopifyCardLine(SalesHeader, DeletedPaymentLine);
        ShopifyTransactionID := TransactionId();
        ConfirmCapture(DeletedPaymentLine);
        SalesHeader.Delete(true);
        // [GIVEN] The order was imported again, with a card line for the same Shopify transaction that is not captured yet
        CreateOrder(SalesHeader, 100, 200);
        OrderNo := SalesHeader."No.";
        AddShopifyCardLineForTransaction(SalesHeader, PaymentLine, ShopifyTransactionID);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();
        // [GIVEN] The first line has been invoiced, which splits the card line
        SetLineToPost(SalesHeader, 1);
        FirstInvoiceNo := _LibSales.PostSalesDocument(SalesHeader, true, true);
        SalesHeader.Get(SalesHeader."Document Type"::Order, OrderNo);
        SetLineToPost(SalesHeader, 2);

        // [WHEN] The rest of the order is invoiced
        SecondInvoiceNo := _LibSales.PostSalesDocument(SalesHeader, true, true);

        // [THEN] Both invoice lines carry the presentment currency event id of the deleted line
        FindInvoicePaymentLine(FirstInvoiceNo, InvoicePaymentLine);
        _Assert.AreEqual(DeletedPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", InvoicePaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The first invoice line must carry the event id kept from the deleted line.');
        FindInvoicePaymentLine(SecondInvoiceNo, InvoicePaymentLine);
        _Assert.AreEqual(DeletedPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", InvoicePaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The second invoice line must carry the event id kept from the deleted line.');
        // [THEN] Neither invoice queued an amount event
        _Assert.AreEqual(0, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A transaction already billed must not be billed again by the invoices of its re-created line.');
    end;

    [Test]
    procedure BilledEcomDocumentDeletedAndProcessedAgain_RecreatedLineIsNotBilledAgain()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        DeletedPaymentLine: Record "NPR Magento Payment Line";
        PaymentLine: Record "NPR Magento Payment Line";
        ShopifyTransactionID: Text[30];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] When an ecommerce document whose virtual item payment was billed at capture is deleted and the Shopify order is processed again, the payment line the new capture creates for the same transaction takes over the old event ids and is not billed a second time.
        Initialize();

        // [GIVEN] A Shopify order on the ecommerce route with a card payment line on the ecommerce document, captured and billed in both currencies
        CreateShopifyEcomOrder(EcomSalesHeader);
        CreateEcomDocumentPaymentLine(EcomSalesHeader, DeletedPaymentLine, 200);
        ShopifyTransactionID := TransactionId();
        ConfirmCapture(DeletedPaymentLine);
        // [GIVEN] The user deleted the ecommerce document
        EcomSalesHeader.Delete(true);
        // [GIVEN] The order was processed again into a new ecommerce document, with a card line for the same Shopify transaction
        CreateEcomDocument(EcomSalesHeader, EcomSalesHeader."External No.");
        CreateEcomDocumentPaymentLineForTransaction(EcomSalesHeader, PaymentLine, 200, ShopifyTransactionID);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The capture of the new line is confirmed
        ConfirmCapture(PaymentLine);

        // [THEN] The new line carries the event ids of the line on the deleted document
        _Assert.AreEqual(DeletedPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The new line must take over the presentment currency event id of the line on the deleted document.');
        _Assert.AreEqual(DeletedPaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", PaymentLine."NPR Ecom Spfy.Ord.Amt.Event Id", 'The new line must take over the shop currency event id of the line on the deleted document.');
        // [THEN] No further amount event is queued
        _Assert.AreEqual(0, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A transaction already billed must not be billed again when its ecommerce document is processed again.');
    end;

    [Test]
    procedure EcomDocumentDeletedTwice_LineOfTheThirdDocumentIsNotBilledAgain()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        FirstPaymentLine: Record "NPR Magento Payment Line";
        PaymentLine: Record "NPR Magento Payment Line";
        ShopifyTransactionID: Text[30];
        StartEntryNo: BigInteger;
    begin
        // [SCENARIO] A payment line left behind by an ecommerce document deleted earlier does not count as another line of its transaction, so deleting the next document of the order keeps the ids again.
        Initialize();

        // [GIVEN] A Shopify order on the ecommerce route with a card payment line on the ecommerce document, captured and billed, then the document deleted
        CreateShopifyEcomOrder(EcomSalesHeader);
        CreateEcomDocumentPaymentLine(EcomSalesHeader, FirstPaymentLine, 200);
        ShopifyTransactionID := TransactionId();
        ConfirmCapture(FirstPaymentLine);
        EcomSalesHeader.Delete(true);
        // [GIVEN] The order processed again, the capture of the new line for the same transaction confirmed, and that document deleted too
        CreateEcomDocument(EcomSalesHeader, EcomSalesHeader."External No.");
        CreateEcomDocumentPaymentLineForTransaction(EcomSalesHeader, PaymentLine, 200, ShopifyTransactionID);
        ConfirmCapture(PaymentLine);
        EcomSalesHeader.Delete(true);
        // [GIVEN] The order processed a third time, with a card line for the same transaction
        CreateEcomDocument(EcomSalesHeader, EcomSalesHeader."External No.");
        CreateEcomDocumentPaymentLineForTransaction(EcomSalesHeader, PaymentLine, 200, ShopifyTransactionID);
        StartEntryNo := _LibBilling.LastBillingQueueEntryNo();

        // [WHEN] The capture of the third line is confirmed
        ConfirmCapture(PaymentLine);

        // [THEN] The third line carries the event ids of the first line
        _Assert.AreEqual(FirstPaymentLine."NPR Spfy Ord.Amt.PCY Event Id", PaymentLine."NPR Spfy Ord.Amt.PCY Event Id", 'The line of the third document must carry the presentment currency event id the transaction was billed under.');
        // [THEN] No further amount event is queued
        _Assert.AreEqual(0, _LibBilling.AmountQueueEntriesSince(StartEntryNo), 'A transaction already billed must not be billed again when its ecommerce document is deleted and processed again a second time.');
    end;

    local procedure Initialize()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        LibERM: Codeunit "Library - ERM";
        LibUtility: Codeunit "Library - Utility";
    begin
        if _Initialized then
            exit;

        SalesSetup.Get();
        if SalesSetup."Posted Shipment Nos." = '' then begin
            SalesSetup."Posted Shipment Nos." := LibUtility.GetGlobalNoSeriesCode();
            SalesSetup.Modify();
        end;
        _CardGLAccountNo := LibERM.CreateGLAccountNoWithDirectPosting();

        _Initialized := true;
        Commit();
    end;

    local procedure CreateOrder(var SalesHeader: Record "Sales Header"; Line1UnitPrice: Decimal; Line2UnitPrice: Decimal)
    begin
        _LibSales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, _LibSales.CreateCustomerNo());
        AddItemLine(SalesHeader, Line1UnitPrice);
        AddItemLine(SalesHeader, Line2UnitPrice);
    end;

    local procedure AddItemLine(SalesHeader: Record "Sales Header"; UnitPrice: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        if UnitPrice = 0 then
            exit;
        _LibSales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, _LibInventory.CreateItemNo(), 1);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
    end;

    /// <summary>
    /// A card payment line for the whole order, linked to a Shopify transaction as the order import links it.
    /// </summary>
    local procedure AddShopifyCardLine(var SalesHeader: Record "Sales Header"; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        _TransactionNo += 1;
        AddShopifyCardLineForTransaction(SalesHeader, PaymentLine, TransactionId());
    end;

    local procedure AddShopifyCardLineForTransaction(var SalesHeader: Record "Sales Header"; var PaymentLine: Record "NPR Magento Payment Line"; ShopifyTransactionID: Text[30])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        LineNo: Integer;
    begin
        SalesHeader.CalcFields("Amount Including VAT");
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        if PaymentLine.FindLast() then
            LineNo := PaymentLine."Line No.";
        PaymentLine.Reset();

        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := LineNo + 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine.Description := 'Shopify card';
        PaymentLine."Account Type" := PaymentLine."Account Type"::"G/L Account";
        PaymentLine."Account No." := _CardGLAccountNo;
        PaymentLine."No." := CopyStr(ShopifyTransactionID, 1, MaxStrLen(PaymentLine."No."));
        PaymentLine."Posting Date" := SalesHeader."Posting Date";
        PaymentLine.Amount := SalesHeader."Amount Including VAT";
        PaymentLine."Requested Amount" := PaymentLine.Amount;
        PaymentLine."Amount (Store Currency)" := PaymentLine.Amount;
        PaymentLine."Requested Amt. (Store Curr.)" := PaymentLine.Amount;
        PaymentLine.Insert(true);
        SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyTransactionID, false);
    end;

    local procedure CreatePostedInvoicePaymentLine(var PaymentLine: Record "NPR Magento Payment Line"; Amount: Decimal; StoreCurrencyAmount: Decimal)
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        LibUtility: Codeunit "Library - Utility";
    begin
        _TransactionNo += 1;

        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Invoice Header";
        PaymentLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
        PaymentLine."Document No." := LibUtility.GenerateGUID();
        PaymentLine."Line No." := 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine.Amount := Amount;
        PaymentLine."Amount (Store Currency)" := StoreCurrencyAmount;
        PaymentLine."Store Currency Code" := 'EUR';
        PaymentLine.Posted := true;
        PaymentLine.Insert();
        SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TransactionId(), false);
    end;

    /// <summary>
    /// An ecommerce order imported from Shopify, with the event log entry that records which store it came from. Returns the store code.
    /// </summary>
    local procedure CreateShopifyEcomOrder(var EcomSalesHeader: Record "NPR Ecom Sales Header") StoreCode: Code[20]
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        LibUtility: Codeunit "Library - Utility";
    begin
        StoreCode := LibUtility.GenerateGUID();
        CreateEcomDocument(EcomSalesHeader, LibUtility.GenerateGUID());

        SpfyEventLogEntry.Init();
        SpfyEventLogEntry."Entry No." := 0;
        SpfyEventLogEntry."Store Code" := StoreCode;
        SpfyEventLogEntry."Shopify ID" := EcomSalesHeader."External No.";
        SpfyEventLogEntry."Document Type" := SpfyEventLogEntry."Document Type"::Order;
        SpfyEventLogEntry.Insert(false);
    end;

    /// <summary>
    /// An ecommerce document for the Shopify order with the given number. Processing an order again after its document was deleted creates another one with the same number.
    /// </summary>
    local procedure CreateEcomDocument(var EcomSalesHeader: Record "NPR Ecom Sales Header"; ExternalNo: Code[20])
    begin
        Clear(EcomSalesHeader);
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := ExternalNo;
        EcomSalesHeader."Document Type" := EcomSalesHeader."Document Type"::Order;
        EcomSalesHeader.Insert(false);
    end;

    /// <summary>
    /// A Shopify card payment line on the ecommerce document itself, as the virtual item capture creates it.
    /// </summary>
    local procedure CreateEcomDocumentPaymentLine(EcomSalesHeader: Record "NPR Ecom Sales Header"; var PaymentLine: Record "NPR Magento Payment Line"; Amount: Decimal)
    begin
        _TransactionNo += 1;
        CreateEcomDocumentPaymentLineForTransaction(EcomSalesHeader, PaymentLine, Amount, TransactionId());
    end;

    local procedure CreateEcomDocumentPaymentLineForTransaction(EcomSalesHeader: Record "NPR Ecom Sales Header"; var PaymentLine: Record "NPR Magento Payment Line"; Amount: Decimal; ShopifyTransactionID: Text[30])
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        LineNo: Integer;
    begin
        // Lines left behind by a deleted document of the same order keep their numbers, so the capture numbers new lines after them.
        PaymentLine.SetRange("Document Table No.", Database::"NPR Ecom Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::Order);
        PaymentLine.SetRange("Document No.", EcomSalesHeader."External No.");
        if PaymentLine.FindLast() then
            LineNo := PaymentLine."Line No.";
        PaymentLine.Reset();

        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"NPR Ecom Sales Header";
        PaymentLine."Document Type" := PaymentLine."Document Type"::Order;
        PaymentLine."Document No." := EcomSalesHeader."External No.";
        PaymentLine."Line No." := LineNo + 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::"Payment Method";
        PaymentLine.Amount := Amount;
        PaymentLine."Amount (Store Currency)" := Amount;
        PaymentLine."NPR Inc Ecom Sale Id" := EcomSalesHeader.SystemId;
        PaymentLine.Insert(false);
        SpfyAssignedIDMgt.AssignShopifyID(PaymentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyTransactionID, false);
    end;

    /// <summary>
    /// What a capture attempt that finds the line captured by Shopify does: marks it captured, bills it through the shared capture hook and saves it.
    /// </summary>
    local procedure ConfirmCapture(var PaymentLine: Record "NPR Magento Payment Line")
    var
        xPaymentLine: Record "NPR Magento Payment Line";
        TempResponse: Record "NPR PG Payment Response" temporary;
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
    begin
        xPaymentLine := PaymentLine;
        PaymentLine."Date Captured" := WorkDate();
        SpfyPaymentGatewayHdlr.RegisterBillingEventsOnCapture(PaymentLine, xPaymentLine, TempResponse, true);
        PaymentLine.Modify();
    end;

    /// <summary>
    /// Ships and invoices only the given item line of the order (1-based, in line order) and leaves the other lines for later.
    /// </summary>
    local procedure SetLineToPost(SalesHeader: Record "Sales Header"; LineToPost: Integer)
    var
        SalesLine: Record "Sales Line";
        LineIndex: Integer;
    begin
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindSet(true);
        repeat
            LineIndex += 1;
            if LineIndex = LineToPost then
                SalesLine.Validate("Qty. to Ship", SalesLine."Outstanding Quantity")
            else
                SalesLine.Validate("Qty. to Ship", 0);
            SalesLine.Modify(true);
        until SalesLine.Next() = 0;
    end;

    local procedure FindInvoicePaymentLine(InvoiceNo: Code[20]; var PaymentLine: Record "NPR Magento Payment Line")
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", InvoiceNo);
        PaymentLine.SetRange("Payment Type", PaymentLine."Payment Type"::"Payment Method");
        PaymentLine.FindFirst();
    end;

    local procedure TransactionId(): Text[30]
    begin
        exit(Format(170000000 + _TransactionNo, 0, 9));
    end;
}

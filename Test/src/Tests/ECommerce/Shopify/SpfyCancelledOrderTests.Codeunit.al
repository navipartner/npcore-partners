codeunit 85669 "NPR Spfy Cancelled Order Tests"
{
    // [FEATURE] Shopify order import: an order that is canceled in Shopify by the time Business Central would create a sales document for it gets none, on the import list routine and on the Ecommerce routine.
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;

    [Test]
    procedure CancelCheck_OrderWithCancellationTime_IsCancelled()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderCancelCheck: Codeunit "NPR Spfy Order Cancel Check";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        ShopifyId: Text[30];
        IsCancelled: Boolean;
    begin
        // [SCENARIO] An order Shopify returns with a cancellation time is reported as canceled, and Shopify is asked about that order by its id.
        ShopifyId := '940000000001';
        StoreCode := 'SPFYCXLCHK';

        // [GIVEN] a Shopify store
        LibrarySpfyImport.CreateStore(StoreCode);

        // [GIVEN] Shopify has the order as canceled
        SpfyOrderCancelStub.SetOrderCancelled(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the order is checked
        IsCancelled := SpfyOrderCancelCheck.IsCancelled(StoreCode, ShopifyId);

        // [THEN] it is reported as canceled
        _Assert.IsTrue(IsCancelled, 'An order with a cancellation time must be reported as canceled.');

        // [THEN] Shopify was asked once, about this order
        _Assert.AreEqual(1, SpfyOrderCancelStub.RequestCountFor(ShopifyId), 'Shopify must be asked once about the order being checked.');
    end;

    [Test]
    procedure CancelCheck_OrderWithoutCancellationTime_IsNotCancelled()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderCancelCheck: Codeunit "NPR Spfy Order Cancel Check";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        ShopifyId: Text[30];
        IsCancelled: Boolean;
    begin
        // [SCENARIO] An order Shopify returns without a cancellation time is reported as not canceled.
        ShopifyId := '940000000002';
        StoreCode := 'SPFYCXLCHK';

        // [GIVEN] a Shopify store
        LibrarySpfyImport.CreateStore(StoreCode);

        // [GIVEN] Shopify has the order as not canceled
        SpfyOrderCancelStub.SetOrderOpen(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the order is checked
        IsCancelled := SpfyOrderCancelCheck.IsCancelled(StoreCode, ShopifyId);

        // [THEN] it is reported as not canceled
        _Assert.IsFalse(IsCancelled, 'An order without a cancellation time must not be reported as canceled.');
    end;

    [Test]
    procedure CancelCheck_ShopifyDoesNotReturnTheOrder_Fails()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderCancelCheck: Codeunit "NPR Spfy Order Cancel Check";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] When Shopify answers without the order, the check fails instead of treating the order as not canceled.
        ShopifyId := '940000000003';
        StoreCode := 'SPFYCXLCHK';

        // [GIVEN] a Shopify store
        LibrarySpfyImport.CreateStore(StoreCode);

        // [GIVEN] Shopify does not return the order
        SpfyOrderCancelStub.SetOrderMissing(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the order is checked
        asserterror SpfyOrderCancelCheck.IsCancelled(StoreCode, ShopifyId);

        // [THEN] the check fails and says that Shopify returned nothing for the order
        _Assert.ExpectedError('Shopify returned no data for order ' + ShopifyId);

        // [THEN] the error names the access scope an order older than 60 days needs
        _Assert.ExpectedError('read_all_orders');
    end;

    [Test]
    procedure CancelCheck_RequestFails_Fails()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderCancelCheck: Codeunit "NPR Spfy Order Cancel Check";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] When the request to Shopify fails, the check fails instead of treating the order as not canceled.
        ShopifyId := '940000000004';
        StoreCode := 'SPFYCXLCHK';

        // [GIVEN] a Shopify store
        LibrarySpfyImport.CreateStore(StoreCode);

        // [GIVEN] the request about the order fails
        SpfyOrderCancelStub.SetRequestFails(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the order is checked
        asserterror SpfyOrderCancelCheck.IsCancelled(StoreCode, ShopifyId);

        // [THEN] the check fails with the reason the request failed
        _Assert.ExpectedError('Mock GraphQL client simulated transport failure.');
    end;

    [Test]
    procedure LegacyCreate_OrderCancelledInShopify_NoSalesOrderAndEntrySaysWhy()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        SpfyCreateOrder: Codeunit "NPR Spfy Create Order";
        SpfyOrderCancelCheck: Codeunit "NPR Spfy Order Cancel Check";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A create entry whose stored order is still open, run after the order was canceled in Shopify, creates no sales order and says why on the entry.
        ShopifyId := '941000000001';

        // [GIVEN] a store set up so that the legacy order import would create the sales order
        PrepareLegacyStoreForCreate(ShopifyId, StoreCode);

        // [GIVEN] a create entry holding the order as it was downloaded, not canceled
        InsertImportEntry(ImportEntry, StoreCode, LegacyOrderJson(ShopifyId, 941001, false));

        // [GIVEN] the order has been canceled in Shopify since
        SpfyOrderCancelStub.SetOrderCancelled(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the create entry is processed
        SpfyCreateOrder.RunProcessImportEntry(ImportEntry);

        // [THEN] no sales order exists for the order
        _Assert.IsFalse(SpfyOrderMgt.SalesOrderExists(StoreCode, ShopifyId), 'A canceled order must not get a sales order.');

        // [THEN] the entry says that the order was canceled
        ImportEntry.Get(ImportEntry."Entry No.");
        _Assert.AreEqual(SpfyOrderCancelCheck.NoDocumentCreatedMsg(), ImportEntry."Error Message", 'The entry must say why nothing was created.');
    end;

    [Test]
    procedure LegacyCreate_OrderOpenInShopify_SalesOrderIsCreated()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyCreateOrder: Codeunit "NPR Spfy Create Order";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A create entry for an order that is not canceled in Shopify creates the sales order as before, after asking Shopify once.
        ShopifyId := '941000000002';

        // [GIVEN] a store set up for the legacy order import, with a customer a sales order can be created for
        PrepareLegacyStoreForCreate(ShopifyId, StoreCode);

        // [GIVEN] a create entry holding the order
        InsertImportEntry(ImportEntry, StoreCode, LegacyOrderJson(ShopifyId, 941002, false));

        // [GIVEN] the order is not canceled in Shopify
        SpfyOrderCancelStub.SetOrderOpen(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the create entry is processed
        SpfyCreateOrder.RunProcessImportEntry(ImportEntry);

        // [THEN] the sales order exists
        _Assert.IsTrue(SpfyOrderMgt.SalesOrderExists(StoreCode, ShopifyId), 'An order that is not canceled must get its sales order.');

        // [THEN] Shopify was asked once about the order
        _Assert.AreEqual(1, SpfyOrderCancelStub.RequestCountFor(ShopifyId), 'Shopify must be asked once before the sales order is created.');

        UnbindSubscription(SpfyOrderCancelStub);
        DeleteCommittedImportEntry(ImportEntry);
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
    end;

    [Test]
    procedure LegacyCreate_SalesOrderAlreadyExists_ShopifyIsNotAsked()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyCreateOrder: Codeunit "NPR Spfy Create Order";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A create entry for an order that already has its sales order does not ask Shopify anything, so re-running imported entries costs no requests.
        ShopifyId := '941000000003';

        // [GIVEN] a store set up for the legacy order import
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] the sales order of the order already exists
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, 'SPFYCXL-O3', ShopifyId, StoreCode);

        // [GIVEN] a create entry holding the same order
        InsertImportEntry(ImportEntry, StoreCode, LegacyOrderJson(ShopifyId, 941003, false));
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the create entry is processed
        SpfyCreateOrder.RunProcessImportEntry(ImportEntry);

        // [THEN] Shopify was not asked whether the order is canceled
        _Assert.AreEqual(0, SpfyOrderCancelStub.RequestCount(), 'An order that already has its sales order must not cost a request.');
    end;

    [Test]
    procedure LegacyCreate_ShopifyDoesNotReturnTheOrder_FailsWithoutSalesOrder()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyCreateOrder: Codeunit "NPR Spfy Create Order";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] When Shopify cannot say whether the order is canceled, the create entry fails instead of creating a sales order, so it stays open for a retry.
        ShopifyId := '941000000004';

        // [GIVEN] a store set up for the legacy order import
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] a create entry holding the order
        InsertImportEntry(ImportEntry, StoreCode, LegacyOrderJson(ShopifyId, 941004, false));

        // [GIVEN] Shopify does not return the order
        SpfyOrderCancelStub.SetOrderMissing(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the create entry is processed
        asserterror SpfyCreateOrder.RunProcessImportEntry(ImportEntry);

        // [THEN] it fails on the check, before anything is created
        _Assert.ExpectedError('Shopify returned no data for order ' + ShopifyId);
    end;

    [Test]
    procedure LegacyPost_OrderCancelledInShopify_NoSalesOrderAndEntrySaysWhy()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        SpfyOrderCancelCheck: Codeunit "NPR Spfy Order Cancel Check";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        SpfyPostOrder: Codeunit "NPR Spfy Post Order";
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A post entry for an order that has no sales order and was canceled in Shopify after its download creates and posts nothing, and says why on the entry.
        ShopifyId := '941000000005';

        // [GIVEN] a store set up so that the legacy order import would create the sales order
        PrepareLegacyStoreForCreate(ShopifyId, StoreCode);

        // [GIVEN] a post entry holding the order as it was downloaded, closed and not canceled, with no sales order or invoice for it
        InsertImportEntry(ImportEntry, StoreCode, LegacyOrderJson(ShopifyId, 941005, true));

        // [GIVEN] the order has been canceled in Shopify since
        SpfyOrderCancelStub.SetOrderCancelled(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the post entry is processed
        SpfyPostOrder.RunProcessImportEntry(ImportEntry);

        // [THEN] no sales order was created for the order
        _Assert.IsFalse(SpfyOrderMgt.SalesOrderExists(StoreCode, ShopifyId), 'A canceled order must not get a sales order from its post entry.');

        // [THEN] no invoice was posted for the order
        _Assert.IsFalse(SpfyOrderMgt.PostedDocumentExists(StoreCode, ShopifyId, true), 'A canceled order must not be invoiced.');

        // [THEN] the entry says that the order was canceled
        ImportEntry.Get(ImportEntry."Entry No.");
        _Assert.AreEqual(SpfyOrderCancelCheck.NoDocumentCreatedMsg(), ImportEntry."Error Message", 'The entry must say why nothing was created.');
    end;

    [Test]
    procedure EcomCancelledEntry_SalesOrderFromAnotherRoutineExists_EntryFailsAndKeepsTheSalesOrder()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        SalesOrderNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A cancelled entry for an order whose sales order was not created by the Ecommerce routine does not report that there was nothing to do: it fails, and the sales order stays for manual handling.
        ShopifyId := '942000000003';
        SalesOrderNo := 'SPFYCXL-E3';

        // [GIVEN] a store set up for the Ecommerce order import
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] a sales order for the order that another routine created, so there is no Ecommerce document
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, SalesOrderNo, ShopifyId, StoreCode);

        // [GIVEN] the cancelled entry of the order
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Cancelled, CurrentDateTime());
        LogEntry.SetRecFilter();
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [WHEN] the entry is processed
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] the entry failed
        LogEntry.Get(LogEntry."Entry No.");
        _Assert.AreEqual(LogEntry."Processing Status"::Error, LogEntry."Processing Status", 'A cancelled entry must not be completed while a sales order of the order is left.');

        // [THEN] it failed because the sales order was not created by the Ecommerce routine, and names that sales order
        _Assert.IsTrue(LogEntry."Last Error Message".Contains('not created by the Ecommerce flow'), 'The entry must fail because the sales order belongs to another routine, not for another reason. Actual: ' + LogEntry."Last Error Message");
        _Assert.IsTrue(LogEntry."Last Error Message".Contains(SalesOrderNo), 'The error must name the sales order to handle. Actual: ' + LogEntry."Last Error Message");

        // [THEN] it tells the user to delete the sales order, which is what lets a cancelled entry complete
        _Assert.IsTrue(LogEntry."Last Error Message".Contains('Delete it manually'), 'A cancelled entry completes only once the sales order is gone, so the error must not promise that posting it helps. Actual: ' + LogEntry."Last Error Message");

        // [THEN] the sales order is still there
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo), 'A sales order of another routine must not be deleted.');

        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
    end;

    [Test]
    procedure EcomCancelledEntry_PostedDocumentFromAnotherRoutineExists_EntryFailsAndSaysItNeedsManualHandling()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A cancelled entry for an order that another routine has already invoiced fails and says the posted document has to be handled manually, because processing the entry again can never complete it.
        ShopifyId := '942000000006';

        // [GIVEN] a store set up for the Ecommerce order import
        LibrarySpfyImport.CleanupCommittedPostedOrderIds(ShopifyId);
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] a posted sales invoice for the order that another routine created, and no unposted sales document
        LibrarySpfyImport.InsertPostedSalesInvoiceWithShopifyId('SPFYCXL-I7', ShopifyId);

        // [GIVEN] the cancelled entry of the order
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Cancelled, CurrentDateTime());
        LogEntry.SetRecFilter();
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [WHEN] the entry is processed
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] the entry failed
        LogEntry.Get(LogEntry."Entry No.");
        _Assert.AreEqual(LogEntry."Processing Status"::Error, LogEntry."Processing Status", 'A cancelled entry must not be completed while a posted document of another routine exists for the order.');

        // [THEN] it says the posted document has to be handled manually, not that posting completes the entry
        _Assert.IsTrue(LogEntry."Last Error Message".Contains('posted outside the Ecommerce flow'), 'The entry must fail because a posted document of another routine exists. Actual: ' + LogEntry."Last Error Message");
        _Assert.IsFalse(LogEntry."Last Error Message".Contains('once it is posted'), 'The error must not promise that posting completes a cancelled entry. Actual: ' + LogEntry."Last Error Message");

        LibrarySpfyImport.CleanupCommittedPostedOrderIds(ShopifyId);
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
    end;

    [Test]
    procedure EcomOpenReturnEntry_ShopifyIsNotAskedAboutAnOrder()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An open entry of a return does not ask Shopify whether an order is canceled, because the id on a return entry is the id of the return.
        ShopifyId := '942000000004';

        // [GIVEN] a store set up for the Ecommerce order import
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] an open entry of a return
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LogEntry.SetRecFilter();
        BindSubscription(SpfyOrderCancelStub);
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [WHEN] the entry is processed
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] Shopify was not asked whether an order is canceled
        _Assert.AreEqual(0, SpfyOrderCancelStub.RequestCount(), 'A return entry must not be checked as if its id were an order id.');

        UnbindSubscription(SpfyOrderCancelStub);
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
    end;

    [Test]
    procedure EcomOpenEntry_OrderCancelledInShopify_SalesOrderFromAnotherRoutineExists_EntryFailsAndKeepsTheSalesOrder()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        SalesOrderNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An open entry for an order that is canceled in Shopify, while an unposted sales order of another routine exists for it, does not report that no sales document was created: it fails, and the sales order stays for manual handling.
        ShopifyId := '942000000005';
        SalesOrderNo := 'SPFYCXL-E5';

        // [GIVEN] a store set up for the Ecommerce order import
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] an unposted sales order for the order that another routine created, so there is no Ecommerce document
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, SalesOrderNo, ShopifyId, StoreCode);

        // [GIVEN] the open entry of the order
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LogEntry.SetRecFilter();
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [GIVEN] the order has been canceled in Shopify
        SpfyOrderCancelStub.SetOrderCancelled(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the entry is processed
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] the entry failed because the sales order was not created by the Ecommerce routine, and names that sales order
        LogEntry.Get(LogEntry."Entry No.");
        _Assert.AreEqual(LogEntry."Processing Status"::Error, LogEntry."Processing Status", 'An entry must not be completed as having created nothing while a sales order of the order is left.');
        _Assert.IsTrue(LogEntry."Last Error Message".Contains('not created by the Ecommerce flow'), 'The entry must fail because the sales order belongs to another routine, not for another reason. Actual: ' + LogEntry."Last Error Message");
        _Assert.IsTrue(LogEntry."Last Error Message".Contains(SalesOrderNo), 'The error must name the sales order to handle. Actual: ' + LogEntry."Last Error Message");

        // [THEN] the sales order is still there
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::Order, SalesOrderNo), 'A sales order of another routine must not be deleted.');

        UnbindSubscription(SpfyOrderCancelStub);
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
    end;

    [Test]
    procedure EcomOpenEntry_PostponedEarlier_CheckFails_EntryEndsInErrorWithTheReason()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An open entry that was postponed on an earlier attempt, and now fails because Shopify cannot say whether the order is canceled, ends in Error with that reason instead of staying postponed with the earlier message.
        ShopifyId := '942000000007';

        // [GIVEN] a store set up for the Ecommerce order import
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] an open entry that an earlier attempt postponed
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Postponed, 1);
        LogEntry.SetRecFilter();
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [GIVEN] Shopify does not return the order
        SpfyOrderCancelStub.SetOrderMissing(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the entry is processed
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] the entry is in Error and no longer postponed
        LogEntry.Get(LogEntry."Entry No.");
        _Assert.AreEqual(LogEntry."Processing Status"::Error, LogEntry."Processing Status", 'A failed attempt must be recorded as a failure, not as the earlier postponement.');
        _Assert.IsFalse(LogEntry.Postponed, 'A failed attempt must not leave the entry postponed.');

        // [THEN] it carries the reason of this attempt
        _Assert.IsTrue(LogEntry."Last Error Message".Contains('Shopify returned no data for order ' + ShopifyId), 'The entry must say why this attempt failed. Actual: ' + LogEntry."Last Error Message");

        UnbindSubscription(SpfyOrderCancelStub);
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
    end;

    [Test]
    procedure EcomCancelledEntry_PostponedEarlier_SalesOrderFromAnotherRoutineExists_EntryEndsInErrorWithTheReason()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        SalesOrderNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A cancelled entry that was postponed on an earlier attempt, and now fails because a sales order of another routine exists for the order, ends in Error with that reason instead of staying postponed with the earlier message.
        ShopifyId := '942000000008';
        SalesOrderNo := 'SPFYCXL-E8';

        // [GIVEN] a store set up for the Ecommerce order import
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] a sales order for the order that another routine created, so there is no Ecommerce document
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, SalesOrderNo, ShopifyId, StoreCode);

        // [GIVEN] the cancelled entry of the order, which an earlier attempt postponed
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Cancelled, CurrentDateTime());
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Postponed, 1);
        LogEntry.SetRecFilter();
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [WHEN] the entry is processed
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] the entry is in Error and no longer postponed
        LogEntry.Get(LogEntry."Entry No.");
        _Assert.AreEqual(LogEntry."Processing Status"::Error, LogEntry."Processing Status", 'A failed attempt must be recorded as a failure, not as the earlier postponement.');
        _Assert.IsFalse(LogEntry.Postponed, 'A failed attempt must not leave the entry postponed.');

        // [THEN] it carries the reason of this attempt and names the sales order
        _Assert.IsTrue(LogEntry."Last Error Message".Contains(SalesOrderNo), 'The entry must say why this attempt failed. Actual: ' + LogEntry."Last Error Message");

        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
    end;

    [Test]
    procedure LegacyPost_OrderOpenInShopify_SalesOrderIsCreated()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        SpfyPostOrder: Codeunit "NPR Spfy Post Order";
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A post entry for an order that has no sales order and is not canceled in Shopify creates the sales order as before, after asking Shopify once.
        ShopifyId := '941000000007';

        // [GIVEN] a store set up so that the legacy order import creates the sales order
        PrepareLegacyStoreForCreate(ShopifyId, StoreCode);

        // [GIVEN] a post entry holding the closed order, with no sales order or invoice for it
        InsertImportEntry(ImportEntry, StoreCode, LegacyOrderJson(ShopifyId, 941007, true));

        // [GIVEN] the order is not canceled in Shopify
        SpfyOrderCancelStub.SetOrderOpen(ShopifyId);
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the post entry is processed
        SpfyPostOrder.RunProcessImportEntry(ImportEntry);

        // [THEN] the sales order exists
        _Assert.IsTrue(SpfyOrderMgt.SalesOrderExists(StoreCode, ShopifyId), 'A closed order that is not canceled must get its sales order from its post entry.');

        // [THEN] Shopify was asked once about the order
        _Assert.AreEqual(1, SpfyOrderCancelStub.RequestCountFor(ShopifyId), 'Shopify must be asked once before the sales order is created.');

        UnbindSubscription(SpfyOrderCancelStub);
        DeleteCommittedImportEntry(ImportEntry);
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
    end;

    [Test]
    procedure LegacyPost_OrderAlreadyInvoiced_ShopifyIsNotAsked()
    var
        ImportEntry: Record "NPR Nc Import Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderCancelStub: Codeunit "NPR Spfy Order Cancel Stub";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        SpfyPostOrder: Codeunit "NPR Spfy Post Order";
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A post entry for an order that is already invoiced does not ask Shopify anything and creates no sales order, so re-running posted entries costs no requests.
        ShopifyId := '941000000006';

        // [GIVEN] a store set up for the legacy order import
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);

        // [GIVEN] the order is already invoiced
        LibrarySpfyImport.InsertPostedSalesInvoiceWithShopifyId('SPFYCXL-I6', ShopifyId);

        // [GIVEN] a post entry holding the closed order
        InsertImportEntry(ImportEntry, StoreCode, LegacyOrderJson(ShopifyId, 941006, true));
        BindSubscription(SpfyOrderCancelStub);

        // [WHEN] the post entry is processed
        SpfyPostOrder.RunProcessImportEntry(ImportEntry);

        // [THEN] Shopify was not asked whether the order is canceled
        _Assert.AreEqual(0, SpfyOrderCancelStub.RequestCount(), 'An order that is already invoiced must not cost a request.');

        // [THEN] no sales order was created
        _Assert.IsFalse(SpfyOrderMgt.SalesOrderExists(StoreCode, ShopifyId), 'An invoiced order must not get a new sales order.');
    end;

    /// <summary>Removes what an earlier run committed for the order, then sets up the store so that the legacy create handler can build a real sales order without calling Shopify for payment lines.</summary>
    local procedure PrepareLegacyStoreForCreate(ShopifyId: Text[30]; var StoreCode: Code[20])
    var
        Customer: Record Customer;
        NpEcStore: Record "NPR NpEc Store";
        SharedNpEcStore: Record "NPR NpEc Store";
        SpfyStore: Record "NPR Spfy Store";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SharedStoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        LegacyStoreTok: Label 'SPFYCXLLEGACY', Locked = true;
        LegacyEcStoreTok: Label 'SPFYCXLLEGEC', Locked = true;
    begin
        LibrarySpfyImport.CleanupCommittedSimpleItemOrder(ShopifyId);
        LibrarySpfyImport.SetupSimpleItemOrder(SharedStoreCode, Sku, ItemNo);
        LibrarySales.SetCreditWarningsToNoWarnings();

        // A store of its own: the create handler commits, and the shared test store must keep its settings for the other suites.
        StoreCode := LegacyStoreTok;
        if not SpfyStore.Get(StoreCode) then begin
            SpfyStore.Init();
            SpfyStore.Code := StoreCode;
            SpfyStore."Get Payment Lines from Shopify" := SpfyStore."Get Payment Lines from Shopify"::ON_CAPTURE;
            SpfyStore.Insert();
        end;

        if not NpEcStore.Get(LegacyEcStoreTok) then begin
            SharedNpEcStore.SetRange("Shopify Store Code", SharedStoreCode);
            SharedNpEcStore.FindFirst();
            LibrarySales.CreateCustomer(Customer);
            NpEcStore := SharedNpEcStore;
            NpEcStore.Code := LegacyEcStoreTok;
            NpEcStore."Shopify Store Code" := StoreCode;
            NpEcStore."Spfy Customer No." := Customer."No.";
            NpEcStore.Insert();
        end;
    end;

    local procedure InsertImportEntry(var ImportEntry: Record "NPR Nc Import Entry"; StoreCode: Code[20]; Order: JsonToken)
    var
        OutStr: OutStream;
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Store Code" := StoreCode;
        ImportEntry."Document Name" := 'order.json';
        ImportEntry."Document Source".CreateOutStream(OutStr, TextEncoding::UTF8);
        Order.WriteTo(OutStr);
        ImportEntry.Insert(true);
    end;

    local procedure DeleteCommittedImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    begin
        if ImportEntry.Find() then
            ImportEntry.Delete();
        Commit();
    end;

    /// <summary>An order with no lines the way the legacy REST order import stores it: authorized and not canceled, and closed when a post entry holds it.</summary>
    local procedure LegacyOrderJson(ShopifyId: Text[30]; OrderNumber: Integer; Closed: Boolean) Order: JsonToken
    var
        GLSetup: Record "General Ledger Setup";
        Builder: TextBuilder;
        InvalidErr: Label 'Built legacy order JSON is not valid.', Locked = true;
    begin
        GLSetup.Get();
        Builder.Append('{"id":' + ShopifyId + ',');
        Builder.Append('"order_number":' + Format(OrderNumber, 0, 9) + ',');
        Builder.Append('"name":"#' + Format(OrderNumber, 0, 9) + '",');
        Builder.Append('"source_name":"web",');
        Builder.Append('"created_at":"2026-01-10T10:00:00Z",');
        if Closed then
            Builder.Append('"closed_at":"2026-01-12T10:00:00Z",')
        else
            Builder.Append('"closed_at":null,');
        Builder.Append('"cancelled_at":null,');
        Builder.Append('"financial_status":"authorized",');
        Builder.Append('"currency":"' + GLSetup."LCY Code" + '","presentment_currency":"' + GLSetup."LCY Code" + '",');
        Builder.Append('"total_price_set":{"presentment_money":{"amount":"0.00"},"shop_money":{"amount":"0.00"}},');
        Builder.Append('"email":"jane@example.com",');
        Builder.Append('"customer":{"id":7700000001,"first_name":"Jane","last_name":"Doe"},');
        Builder.Append('"billing_address":{"first_name":"Jane","last_name":"Doe","company":null,"address1":"1 Test St","address2":null,"city":"Testville","zip":"1000"},');
        Builder.Append('"line_items":[],"fulfillments":[],"shipping_lines":[]}');
        if not Order.ReadFrom(Builder.ToText()) then
            Error(InvalidErr);
    end;
}

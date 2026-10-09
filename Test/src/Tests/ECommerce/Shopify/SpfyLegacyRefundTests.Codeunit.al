codeunit 85510 "NPR Spfy Legacy Refund Tests"
{
    // [FEATURE] Shopify refunds without a return and path-neutral settlement on the legacy order import path
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Library Spfy Legacy Refund";
        _ReturnLib: Codeunit "NPR Library Spfy Legacy Return";
        _CapturedMessage: Text;

    [Test]
    procedure Posting_ReturnOrderBuiltWithoutAQueueRow_IsSettled()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ReturnOrderNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A Return Order the document builder made without any queue row is settled at posting, so another import path can reuse the builder and the posting unchanged.
        // [GIVEN] A legacy-path store
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);

        // [GIVEN] A Return Order built from a return refunded 500 by card, and no queue row for that return
        _Lib.BuildReturnOrderWithoutQueue(StoreCode, _ReturnLib.ReturnDetailResponse('2301901', '2301001', '#2301001', Sku, '2301701', 2, 400, 100, 25, '71001', _ReturnLib.RefundTxnJson('2301801', 'shopify_payments', 500, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), '2301901', SalesHeader);
        ReturnOrderNo := SalesHeader."No.";
        _Assert.IsFalse(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '2301901'), 'Precondition: no queue row exists for the return.');

        // [WHEN] The Return Order is posted
        Succeeded := _Lib.PostReturnOrder(SalesHeader);

        // [THEN] The posting succeeds
        _Assert.IsTrue(Succeeded, 'Posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo is settled on the card clearing account
        _ReturnLib.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-500, GLEntry.Amount, 'The refund must be credited to the clearing account.');
    end;

    [Test]
    procedure Posting_StampedReturnOrderWithoutASettlementRow_IsLeftUnsettled()
    var
        ShopifyStore: Record "NPR Spfy Store";
        Settlement: Record "NPR Spfy Refund Settlement";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ReturnOrderNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A Return Order that carries the Shopify stamps but has no settlement row is not this engine's document: it posts without a refund journal line and its credit memo stays open.
        // [GIVEN] A legacy-path store and a Return Order built by the builder for a return refunded 500 by card
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.BuildReturnOrderWithoutQueue(StoreCode, _ReturnLib.ReturnDetailResponse('2301902', '2301002', '#2301002', Sku, '2301702', 2, 400, 100, 25, '71001', _ReturnLib.RefundTxnJson('2301802', 'shopify_payments', 500, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), '2301902', SalesHeader);
        ReturnOrderNo := SalesHeader."No.";

        // [GIVEN] Its settlement row is removed
        Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, '2301902');
        Settlement.Delete();

        // [WHEN] The Return Order is posted
        Succeeded := _Lib.PostReturnOrder(SalesHeader);

        // [THEN] The posting succeeds and the credit memo stays open, with nothing on the clearing account
        _Assert.IsTrue(Succeeded, 'Posting must succeed: ' + GetLastErrorText());
        _ReturnLib.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(-500, CustLedgerEntry."Remaining Amount", 'Without a settlement row the credit memo must stay open.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.IsTrue(GLEntry.IsEmpty(), 'Nothing may be settled without a settlement row.');
    end;

    [Test]
    procedure QueuePage_DiscardDraft_RemovesTheSettlementRow()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Settlement: Record "NPR Spfy Refund Settlement";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Discarding a draft removes its settlement row with it, so a later build starts clean.
        // [GIVEN] A legacy-path store that posts by hand, and a queued return whose draft was built
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _ReturnLib.InsertQueueRow(StoreCode, '2301903', '2301003', QueueRow);
        MockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2301903', '2301003', '#2301003', Sku, '2301703', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2301803', 'shopify_payments', 100, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()));
        _Assert.IsTrue(_ReturnLib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());
        _Assert.IsTrue(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, '2301903'), 'Precondition: the build wrote a settlement row.');

        // [WHEN] The draft is discarded
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '2301903');
        SpfyLegacyReturnMgt.DiscardDraft(QueueRow);

        // [THEN] The settlement row is gone
        _Assert.IsFalse(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, '2301903'), 'Discarding the draft must remove its settlement row.');

        // Cleanup: restore the committed store.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := true;
        ShopifyStore.Modify();
        Commit();
    end;

    [Test]
    procedure StoreDeleted_RemovesItsSettlementRows()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Settlement: Record "NPR Spfy Refund Settlement";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Deleting a store whose returns are all imported removes their settlement rows along with the queue rows.
        // [GIVEN] A legacy-path store with one imported return and its settlement row
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll(false);
        _ReturnLib.InsertQueueRow(StoreCode, '2301904', '2301004', QueueRow);
        QueueRow.Status := QueueRow.Status::Imported;
        QueueRow.Modify();
        Settlement.Init();
        Settlement."Shopify Store Code" := StoreCode;
        Settlement."Shopify Id" := '2301904';
        Settlement.Insert();

        // [WHEN] The store is deleted
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Delete(true);

        // [THEN] No settlement row of the store is left
        Settlement.SetRange("Shopify Store Code", StoreCode);
        _Assert.IsTrue(Settlement.IsEmpty(), 'The deleted store must leave no settlement rows behind.');
    end;

    [Test]
    procedure Upgrade_QueueRowWithADraft_GetsItsSettlementRow()
    var
#pragma warning disable AL0432
        OldQueueRow: Record "NPR Spfy Legacy Return Queue";
#pragma warning restore AL0432
        Settlement: Record "NPR Spfy Refund Settlement";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A draft built before the settlement table existed still settles after the upgrade: its row in the obsolete queue gives its gift card share and voucher to a settlement row of the right kind.
        // [GIVEN] A row of the obsolete queue linked to a draft, carrying a gift card share of 50 and voucher V-UPG in its old fields
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        OldQueueRow.Init();
        OldQueueRow."Shopify Store Code" := StoreCode;
        OldQueueRow."Return Id" := '2301905';
        OldQueueRow."Return Name" := '#2301005-R1';
        OldQueueRow."Order Id" := '2301005';
        OldQueueRow."Sales Header Doc. No." := 'RO-2301905';
        OldQueueRow."Gift Card Refund Amount" := 50;
        OldQueueRow."Voucher No." := 'V-UPG';
        OldQueueRow.Insert();
        _ReturnLib.DeleteSettlement(StoreCode, '2301905');

        // [WHEN] The upgrade copy runs
        SpfyAppUpgrade.CopyLegacyReturnQueueToSettlement();

        // [THEN] A return's settlement row carries the row's order, share and voucher
        _Assert.IsTrue(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, '2301905'), 'The upgrade must create the settlement row.');
        _Assert.AreEqual(50, Settlement."Gift Card Refund Amount", 'The gift card share must be copied.');
        _Assert.AreEqual('V-UPG', Settlement."Voucher No.", 'The voucher must be copied.');
        _Assert.AreEqual('2301005', Settlement."Order Id", 'The order id must be copied.');
        _Assert.AreEqual('RO-2301905', Settlement."Return Order No.", 'The draft''s number must be copied, so the row settles that draft only.');
    end;

    [Test]
    procedure Upgrade_PreReleaseRefundSettlement_IsNotShadowedByTheQueueCopy()
    var
#pragma warning disable AL0432
        OldQueueRow: Record "NPR Spfy Legacy Return Queue";
#pragma warning restore AL0432
        Settlement: Record "NPR Spfy Refund Settlement";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A pre-release refund draft whose settlement row is still keyed by the prefixed id keeps that row through the upgrade copy, instead of getting an empty row under the plain id that would replace it.
        // [GIVEN] A pre-release refund row Refund/2309941 of the obsolete queue linked to draft RO-2309941, its old share fields empty
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        OldQueueRow.SetRange("Shopify Store Code", StoreCode);
        OldQueueRow.SetRange("Return Id", 'Refund/2309941');
        OldQueueRow.DeleteAll();
        OldQueueRow.Init();
        OldQueueRow."Shopify Store Code" := StoreCode;
        OldQueueRow."Return Id" := 'Refund/2309941';
        OldQueueRow."Source Type" := OldQueueRow."Source Type"::Refund;
        OldQueueRow."Return Name" := '#2309041 / 2309941';
        OldQueueRow."Order Id" := '2309041';
        OldQueueRow."Sales Header Doc. No." := 'RO-2309941';
        OldQueueRow.Insert();
        // [GIVEN] Its settlement row as the pre-release build wrote it: keyed Refund/2309941 as a return, with a gift card share of 50 on voucher V-2309941
        Settlement.SetRange("Shopify Store Code", StoreCode);
        Settlement.SetFilter("Shopify Id", '%1|%2', 'Refund/2309941', '2309941');
        Settlement.DeleteAll();
        Settlement.Init();
        Settlement."Shopify Store Code" := StoreCode;
        Settlement."Source Doc. Type" := Settlement."Source Doc. Type"::Return;
        Settlement."Shopify Id" := 'Refund/2309941';
        Settlement."Return Order No." := 'RO-2309941';
        Settlement."Gift Card Refund Amount" := 50;
        Settlement."Voucher No." := 'V-2309941';
        Settlement.Insert();

        // [WHEN] The upgrade copy runs
        SpfyAppUpgrade.CopyLegacyReturnQueueToSettlement();

        // [THEN] No row is created under the plain id, and the pre-release row keeps its share and voucher for the restamp to rekey
        _Assert.IsFalse(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Refund, '2309941'), 'The copy must not create a row the restamp would keep over the real one.');
        _Assert.IsTrue(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, 'Refund/2309941'), 'The pre-release row must stay.');
        _Assert.AreEqual(50, Settlement."Gift Card Refund Amount", 'The pre-release row keeps its gift card share.');
        _Assert.AreEqual('V-2309941', Settlement."Voucher No.", 'The pre-release row keeps its voucher.');
    end;

    [Test]
    procedure Upgrade_ObsoleteQueueRows_MoveToTheNewQueueWithPlainIds()
    var
#pragma warning disable AL0432
        OldQueueRow: Record "NPR Spfy Legacy Return Queue";
#pragma warning restore AL0432
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The upgrade moves every row of the obsolete queue to the queue keyed by entry number, and a refund row of a pre-release build, keyed by "Refund/" and the id, arrives with the plain id next to a return of the same number.
        // [GIVEN] In the obsolete queue, an imported return 2309901 and a waiting pre-release refund Refund/2309901 of the same store
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        OldQueueRow.SetRange("Shopify Store Code", StoreCode);
        OldQueueRow.SetFilter("Return Id", '%1|%2', '2309901', 'Refund/2309901');
        OldQueueRow.DeleteAll();
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetRange("Source Doc. ID", '2309901');
        QueueRow.DeleteAll();
        OldQueueRow.Init();
        OldQueueRow."Shopify Store Code" := StoreCode;
        OldQueueRow."Return Id" := '2309901';
        OldQueueRow."Return Name" := '#2309001-R1';
        OldQueueRow."Order Id" := '2309001';
        OldQueueRow.Status := OldQueueRow.Status::Imported;
        OldQueueRow."Posted Doc. No." := 'CM-2309901';
        OldQueueRow."Detected At" := CreateDateTime(20260920D, 100000T);
        OldQueueRow.Insert();
        OldQueueRow.Init();
        OldQueueRow."Shopify Store Code" := StoreCode;
        OldQueueRow."Return Id" := 'Refund/2309901';
        OldQueueRow."Source Type" := OldQueueRow."Source Type"::Refund;
        OldQueueRow."Return Name" := '#2309002 / 2309901';
        OldQueueRow."Order Id" := '2309002';
        OldQueueRow.Status := OldQueueRow.Status::Waiting;
        OldQueueRow."Outcome Note" := 'Waiting for the order';
        OldQueueRow.Insert();

        // [WHEN] The upgrade moves the queue
        SpfyAppUpgrade.MoveLegacyReturnQueueRows();

        // [THEN] The return arrives with its id, status, posted document and detection time
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '2309901'), 'The return must be moved.');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The status must be moved.');
        _Assert.AreEqual('CM-2309901', QueueRow."Posted Doc. No.", 'The posted document must be moved.');
        _Assert.AreEqual(CreateDateTime(20260920D, 100000T), QueueRow."Detected At", 'The detection time must be kept.');

        // [THEN] The refund arrives as a refund under its plain id, with its note
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2309901'), 'The refund must be moved under its plain id.');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'The refund''s status must be moved.');
        _Assert.AreEqual('Waiting for the order', QueueRow."Outcome Note", 'The note must be moved.');
    end;

    [Test]
    procedure Upgrade_PreReleaseRefundStamps_BecomeRefundIdsThatTheQueueRecognises()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        ReturnReceiptHeader: Record "Return Receipt Header";
        Settlement: Record "NPR Spfy Refund Settlement";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        SourceDocType: Enum "NPR Spfy Legacy Return Source";
        ShopifyId: Text[30];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The upgrade restamps the documents and settlement rows a pre-release build gave "Refund/" and "Discount/" Entry IDs, so the queue recognises the refund's posted credit memo and draft again, and a return's stamps stay as they are.
        // [GIVEN] Refund 2309911 posted by a pre-release build: credit memo and receipt stamped Entry ID Refund/2309911, a post-sale discount line stamped Discount/2309811, a settlement row under Refund/2309911
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.InsertPostedCrMemoWithReturnIds('CM-2309911', StoreCode, 'Refund/2309911');
        _ReturnLib.InsertPostedReceiptWithReturnIds('RR-2309911', StoreCode, 'Refund/2309911', 'RO-2309911');
        if not SalesCrMemoLine.Get('CM-2309911', 10000) then begin
            SalesCrMemoLine.Init();
            SalesCrMemoLine."Document No." := 'CM-2309911';
            SalesCrMemoLine."Line No." := 10000;
            SalesCrMemoLine.Insert();
        end;
        SpfyAssignedIDMgt.AssignShopifyID(SalesCrMemoLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", 'Discount/2309811', false);
        Settlement.SetRange("Shopify Store Code", StoreCode);
        Settlement.SetFilter("Shopify Id", '%1|%2', 'Refund/2309911', '2309911');
        Settlement.DeleteAll();
        Settlement.Init();
        Settlement."Shopify Store Code" := StoreCode;
        Settlement."Source Doc. Type" := Settlement."Source Doc. Type"::Return;
        Settlement."Shopify Id" := 'Refund/2309911';
        Settlement."Return Order No." := 'RO-2309911';
        Settlement.Insert();
        _ReturnLib.InsertQueueRow(StoreCode, QueueRow."Source Doc. Type"::Refund, '2309911', '2309011', '#2309011', QueueRow);
        QueueRow."Posted Doc. No." := 'CM-2309911';
        QueueRow.Status := QueueRow.Status::Imported;
        QueueRow.Modify();
        // [GIVEN] Refund 2309912 drafted by a pre-release build as a Return Order stamped Entry ID Refund/2309912
        _ReturnLib.InsertReturnOrderWithReturnIds('RO-2309912', StoreCode, 'Refund/2309912', SalesHeader);
        // [GIVEN] Return 2309913 credited as a credit memo stamped with its plain Entry ID
        _ReturnLib.InsertPostedCrMemoWithReturnIds('CM-2309913', StoreCode, '2309913');

        // [WHEN] The upgrade restamps the pre-release ids
        SpfyAppUpgrade.RestampPreReleaseRefundIds();

        // [THEN] The refund's credit memo carries the refund id and no Entry ID, and the queue row recognises it, so Open Document finds it
        SalesCrMemoHeader.Get('CM-2309911');
        _Assert.IsTrue(SpfyLegacyReturnMgt.GetSourceDocStamp(SalesCrMemoHeader.RecordId(), SourceDocType, ShopifyId), 'The credit memo must carry a refund stamp.');
        _Assert.AreEqual(SourceDocType::Refund, SourceDocType, 'The credit memo must be stamped as a refund.');
        _Assert.AreEqual('2309911', ShopifyId, 'The refund id must be plain.');
        _Assert.AreEqual('', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'The prefixed Entry ID must be gone.');
        _Assert.IsTrue(SpfyLegacyReturnMgt.IsCreditMemoPosted(QueueRow), 'The queue row must recognise the credit memo.');
        // [THEN] The receipt carries the refund id too
        ReturnReceiptHeader.Get('RR-2309911');
        _Assert.AreEqual('2309911', SpfyAssignedIDMgt.GetAssignedShopifyID(ReturnReceiptHeader.RecordId(), "NPR Spfy ID Type"::"Refund ID"), 'The receipt must carry the plain refund id.');
        // [THEN] The discount line carries the discounted order line under its own type
        _Assert.AreEqual('2309811', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoLine.RecordId(), "NPR Spfy ID Type"::"Post-Sale Disc. Line Item ID"), 'The discount line must carry the plain line item id.');
        _Assert.AreEqual('', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'The prefixed discount Entry ID must be gone.');
        // [THEN] The settlement row is keyed as the refund's
        _Assert.IsTrue(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Refund, '2309911'), 'The settlement row must be keyed by the refund.');
        _Assert.AreEqual('RO-2309911', Settlement."Return Order No.", 'The settlement row must keep its values.');
        _Assert.IsFalse(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, 'Refund/2309911'), 'The prefixed settlement row must be gone.');
        // [THEN] The pre-release draft is found as the refund's
        _Assert.IsTrue(SpfyLegacyReturnMgt.FindDraftForReturn(StoreCode, SourceDocType::Refund, '2309912', SalesHeader), 'The draft must be found by its refund id.');
        // [THEN] The return's credit memo keeps its Entry ID
        SalesCrMemoHeader.Get('CM-2309913');
        _Assert.AreEqual('2309913', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'A return''s stamp must stay.');
        _Assert.AreEqual('', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Refund ID"), 'A return must not get a refund stamp.');
    end;

    [Test]
    procedure Identity_DiscountLineAfterTheSale_ShowsTheOrderLineItDiscounts()
    var
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        OrderLineItemId: Text[30];
    begin
        // [SCENARIO] A credit memo line that credits a discount given after the sale carries no Entry ID, and the order line it discounts is still shown as its Shopify order line.
        // [GIVEN] A posted credit memo line stamped only with the discounted order line 2309821
        if not SalesCrMemoLine.Get('CM-2309921', 10000) then begin
            SalesCrMemoLine.Init();
            SalesCrMemoLine."Document No." := 'CM-2309921';
            SalesCrMemoLine."Line No." := 10000;
            SalesCrMemoLine.Insert();
        end;
        SpfyAssignedIDMgt.AssignShopifyID(SalesCrMemoLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", '', false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesCrMemoLine.RecordId(), "NPR Spfy ID Type"::"Post-Sale Disc. Line Item ID", '2309821', false);

        // [WHEN] The line's Shopify order line is read as the posted credit memo subform reads it
        OrderLineItemId := SpfyLegacyReturnMgt.GetOrderLineItemStamp(SalesCrMemoLine.RecordId());

        // [THEN] It is the discounted order line
        _Assert.AreEqual('2309821', OrderLineItemId, 'A discount line must show the order line it discounts.');
    end;

    [Test]
    procedure Caption_ReturnAndRefund_NameTheirKind()
    var
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        ReturnCaption: Text[50];
        RefundCaption: Text[50];
    begin
        // [SCENARIO] Messages name a return as "return <name>" and a refund, which has no name of its own, as "refund <id> of order <order>".
        // [GIVEN] Return #2301006-R1, and refund 2301906 of order #2301006

        // [WHEN] Both captions are built
        ReturnCaption := SpfyLegacyReturnAPI.DocumentCaption("NPR Spfy Legacy Return Source"::Return, '#2301006-R1', '2301806');
        RefundCaption := SpfyLegacyReturnAPI.DocumentCaption("NPR Spfy Legacy Return Source"::Refund, '#2301006', '2301906');

        // [THEN] Each reads with its kind, the refund with its id and its order
        _Assert.AreEqual('return #2301006-R1', ReturnCaption, 'A return reads as a return.');
        _Assert.AreEqual('refund 2301906 of order #2301006', RefundCaption, 'A refund reads as a refund of its order.');
    end;

    [Test]
    procedure Posting_ReturnPaidBeyondItsLines_BooksTheDiscrepancyAccount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return whose merchant refunded 30 more than the returned line imports, books the 30 on the discrepancy account and settles the whole refund.
        // [GIVEN] A legacy-path store with a discrepancy account
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);

        // [GIVEN] A queued return of one line worth 100, refunded 130 with an order adjustment of -30
        _ReturnLib.InsertQueueRow(StoreCode, '2301907', '2301007', QueueRow);
        MockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2301907', '2301007', '#2301007', Sku, '2301707', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2301807', 'shopify_payments', 130, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy(), _ReturnLib.SingleRestockedDispositionJson('71001', 1), '[]', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo carries 30 on the discrepancy account and is settled
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '2301907');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Refund Discrepancy G/L Acc.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The amount paid beyond the lines must be booked on the discrepancy account.');
        _Assert.AreEqual(30, SalesCrMemoLine."Amount Including VAT", 'The discrepancy line carries what was paid beyond the lines.');
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');
    end;

    [Test]
    procedure PollJQ_RefundWithoutAReturn_IsQueuedAsARefund()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A refund made on an order without a return is queued as a New refund row under its plain Shopify id, named by its order, since a refund has no name of its own.
        // [GIVEN] A legacy-path store with no queued rows
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();

        // [GIVEN] Shopify lists one order with no return and one refund without a return
        MockClient.AddResponse('sortKey:UPDATED_AT', 'refunds(first: 50) { id createdAt', _Lib.RefundListResponse('gid://shopify/Order/2301008', '#2301008', '', _Lib.RefundListItemJson('2301908', '2026-09-20T10:00:00Z', '')));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] One New refund row exists under the plain refund id
        _Assert.AreEqual(1, QueueRow.Count(), 'One row per refund without a return.');
        QueueRow.FindFirst();
        _Assert.AreEqual('2301908', QueueRow."Source Doc. ID", 'A refund is queued under its plain id.');
        _Assert.AreEqual(QueueRow."Source Doc. Type"::Refund, QueueRow."Source Doc. Type", 'The row must be a refund row.');
        _Assert.AreEqual('#2301008', QueueRow."Source Doc. Name", 'The row is named by its order.');
        _Assert.AreEqual('2301008', QueueRow."Order Id", 'The order id is numeric.');
        _Assert.AreEqual('#2301008', QueueRow."Order No.", 'The row carries the order name, so a waiting note can name the order.');

        // Cleanup: remove the committed rows.
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure PollJQ_OrderWithAReturnAndARefund_QueuesOneRowEach()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] An order with a closed return, the return's own refund and a separate refund without a return yields one return row and one refund row; the return's refund is not queued on its own.
        // [GIVEN] A legacy-path store with no queued rows
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();

        // [GIVEN] Shopify lists the order with closed return 2301909, its refund 2301910 and a separate refund 2301911
        MockClient.AddResponse('sortKey:UPDATED_AT', 'refunds(first: 50) { id createdAt', _Lib.RefundListResponse('gid://shopify/Order/2301009', '#2301009', _Lib.ClosedReturnEdgeJson('gid://shopify/Return/2301909', '#2301009-R1'), _Lib.RefundListItemJson('2301910', '2026-09-20T10:00:00Z', 'gid://shopify/Return/2301909') + ',' + _Lib.RefundListItemJson('2301911', '2026-09-21T10:00:00Z', '')));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] Two rows exist: the return and the separate refund
        _Assert.AreEqual(2, QueueRow.Count(), 'One return row and one refund row.');
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '2301909'), 'The return is queued.');
        _Assert.AreEqual(QueueRow."Source Doc. Type"::Return, QueueRow."Source Doc. Type", 'The return row is a return row.');
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301911'), 'The separate refund is queued.');
        _Assert.IsFalse(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301910'), 'The return''s own refund must not be queued on its own.');

        // Cleanup: remove the committed rows.
        QueueRow.Reset();
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure PollJQ_RefundBeforeTheStartDate_IsNotQueued()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A refund created before the store's "Get Returns Starting From" stays with manual handling and is not queued.
        // [GIVEN] A legacy-path store starting from 2026-01-01 with no queued rows
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();

        // [GIVEN] Shopify lists a refund without a return created on 2025-12-31
        MockClient.AddResponse('sortKey:UPDATED_AT', 'refunds(first: 50) { id createdAt', _Lib.RefundListResponse('gid://shopify/Order/2301012', '#2301012', '', _Lib.RefundListItemJson('2301912', '2025-12-31T10:00:00Z', '')));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] Nothing is queued
        _Assert.IsTrue(QueueRow.IsEmpty(), 'A refund before the start date must not be queued.');
    end;

    [Test]
    procedure PollJQ_FiftyRefundsOnOneOrder_QueuesThemAndReportsTheOrder()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        RefundsJson: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        i: Integer;
    begin
        // [SCENARIO] An order that comes back with as many refunds as one request reads may hold more: the refunds read are queued and the poll fails naming the order, so the gap is visible in the job log.
        // [GIVEN] A legacy-path store with no queued rows
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();
        Commit();

        // [GIVEN] Shopify lists one order with 50 refunds without a return
        for i := 1 to 50 do begin
            if i > 1 then
                RefundsJson += ',';
            RefundsJson += _Lib.RefundListItemJson('23019500' + Format(100 + i), '2026-09-20T10:00:00Z', '');
        end;
        MockClient.AddResponse('sortKey:UPDATED_AT', 'refunds(first: 50) { id createdAt', _Lib.RefundListResponse('gid://shopify/Order/2301013', '#2301013', '', RefundsJson));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        asserterror SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The poll fails naming the order, and all 50 refunds were queued
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#2301013') > 0, 'The failure must name the order: ' + GetLastErrorText());
        _Assert.AreEqual(50, QueueRow.Count(), 'The refunds read must still be queued.');

        // Cleanup: remove the committed rows.
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure RefundApi_ParseDetail_AmountOnly_IsMoneyBeyondTheLines()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ExpectedPostingDateTime: DateTime;
    begin
        // [SCENARIO] A refund of 200 with no lines and an order adjustment of -200 (Shopify order #1146) parses into a refund header with 200 paid beyond the lines, no line and one transaction, dated by the refund.
        // [GIVEN] The refund detail response
        Response.ReadFrom(_Lib.RefundDetailResponse('2301914', '2301014', '#2301014', '2026-09-22T08:00:00Z', true, '', '', _ReturnLib.OrderAdjustmentJson(-200, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301814', 'bogus', 200, _ReturnLib.Lcy(), '')));

        // [WHEN] The detail is parsed
        SpfyLegacyReturnAPI.ParseRefundDetail('SPFYLRSTORE', '2301914', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The header is a refund under its plain id, named by its order, with 200 beyond the lines and the refund's date
        _Assert.IsTrue(TempReturnBuffer.Get('2301914'), 'The refund header is keyed by the refund id.');
        _Assert.AreEqual(TempReturnBuffer."Source Type"::Refund, TempReturnBuffer."Source Type", 'The header is a refund.');
        _Assert.AreEqual('#2301014', TempReturnBuffer."Return Name", 'The refund is named by its order.');
        _Assert.AreEqual(200, TempReturnBuffer."Refund Beyond Lines Amount", 'The negative adjustment is money paid beyond the lines.');
        _Assert.AreEqual(0, TempReturnBuffer."Fee Amount", 'Nothing is withheld.');
        Evaluate(ExpectedPostingDateTime, '2026-09-22T08:00:00Z', 9);
        _Assert.AreEqual(ExpectedPostingDateTime, TempReturnBuffer."Posting DateTime", 'The document is dated by the refund.');
        _Assert.IsFalse(TempReturnBuffer."Belongs to Return", 'A Refund-flow refund has no return.');

        // [THEN] No line and one transaction of 200
        _Assert.IsTrue(TempLineBuffer.IsEmpty(), 'An amount-only refund has no line.');
        TempRefundTxnBuffer.CalcSums(Amount);
        _Assert.AreEqual(200, TempRefundTxnBuffer.Amount, 'The refund transaction is read.');
    end;

    [Test]
    procedure RefundApi_ParseDetail_LinesKeepTheirRestockType()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A restocked refund line keeps its location and a line refunded without restock is marked Not Restocked; on a shop without taxes included the line gross is subtotal plus tax.
        // [GIVEN] A refund of one restocked line (80 + 20 tax at location 71001) and one line kept by the customer (40 + 10 tax), taxes excluded
        Response.ReadFrom(_Lib.RefundDetailResponse('2301915', '2301015', '#2301015', '2026-09-22T08:00:00Z', false,
            _Lib.RefundLineJson('2301715', 'SKU-A', 1, 'RETURN', '71001', 80, 20, 25) + ',' + _Lib.RefundLineJson('2301716', 'SKU-B', 1, 'NO_RESTOCK', '', 40, 10, 25),
            '', '', _ReturnLib.RefundTxnJson('2301815', 'bogus', 150, _ReturnLib.Lcy(), '')));

        // [WHEN] The detail is parsed
        SpfyLegacyReturnAPI.ParseRefundDetail('SPFYLRSTORE', '2301915', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The restocked line has its location and gross 100
        TempLineBuffer.SetRange("Order Line Item Id", '2301715');
        _Assert.IsTrue(TempLineBuffer.FindFirst(), 'The restocked line is parsed.');
        _Assert.AreEqual('RETURN', TempLineBuffer."Restock Type", 'The restock type is kept.');
        _Assert.AreEqual('71001', TempLineBuffer."Disposition Location Id", 'A restocked line keeps its location.');
        _Assert.AreEqual(100, TempLineBuffer."Line Amount", 'Gross is subtotal plus tax without taxes included.');

        // [THEN] The kept line is Not Restocked and has no location
        TempLineBuffer.SetRange("Order Line Item Id", '2301716');
        _Assert.IsTrue(TempLineBuffer.FindFirst(), 'The kept line is parsed.');
        _Assert.AreEqual('NO_RESTOCK', TempLineBuffer."Restock Type", 'The restock type is kept.');
        _Assert.IsTrue(TempLineBuffer."Not Restocked", 'A line the customer keeps is Not Restocked.');
        _Assert.AreEqual('', TempLineBuffer."Disposition Location Id", 'A line the customer keeps has no restock location.');
        _Assert.AreEqual(50, TempLineBuffer."Line Amount", 'Gross is subtotal plus tax without taxes included.');
    end;

    [Test]
    procedure RefundApi_ParseDetail_RefundOfAReturn_IsFlagged()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A refund that belongs to a return is flagged, so the import can refuse it and leave it to the return.
        // [GIVEN] A refund detail whose return is set
        Response.ReadFrom(_Lib.BelongingToReturn(_Lib.RefundDetailResponse('2301916', '2301016', '#2301016', '2026-09-22T08:00:00Z', true, '', '', _ReturnLib.OrderAdjustmentJson(-10, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301816', 'bogus', 10, _ReturnLib.Lcy(), '')), '2301999'));

        // [WHEN] The detail is parsed
        SpfyLegacyReturnAPI.ParseRefundDetail('SPFYLRSTORE', '2301916', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The header says it belongs to a return
        _Assert.IsTrue(TempReturnBuffer.Get('2301916'), 'The refund header is parsed.');
        _Assert.IsTrue(TempReturnBuffer."Belongs to Return", 'A refund of a return must be flagged.');
    end;

    [Test]
    procedure RefundApi_ParseDetail_OrderWithOnlyCancelledFulfillments_IsNotFulfilled()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] An order whose fulfillments were all cancelled is not taken for a shipped order, so a refund of it can still end with nothing to credit.
        // [GIVEN] A refund detail whose order has two cancelled fulfillments and none that succeeded
        Response.ReadFrom(_Lib.WithOrderFulfillments(_Lib.RefundDetailResponse('2350093', '2350003', '#2350003', '2026-09-22T08:00:00Z', true, '', '', _ReturnLib.OrderAdjustmentJson(-10, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2350083', 'bogus', 10, _ReturnLib.Lcy(), '')), '{"status":"CANCELLED"},{"status":"CANCELLED"}'));

        // [WHEN] The detail is parsed
        SpfyLegacyReturnAPI.ParseRefundDetail('SPFYLRSTORE', '2350093', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The order is not marked fulfilled
        _Assert.IsTrue(TempReturnBuffer.Get('2350093'), 'The refund header is parsed.');
        _Assert.IsFalse(TempReturnBuffer."Order Fulfilled", 'Only a successful fulfillment means Shopify shipped the order.');
    end;

    [Test]
    procedure Posting_AmountOnlyRefund_PostsSettlesAndBooksTheDiscrepancy()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of 200 with no lines (Shopify order #1146) on an invoiced order is imported, posted as a credit memo with one line on the discrepancy account, settled on the card account, and the row ends Imported.
        // [GIVEN] A legacy-path store and an order invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301017', '2301717', 1, 875, ShipmentNo);

        // [GIVEN] A queued refund of 200 without lines, all of it an order adjustment of -200
        _Lib.InsertRefundQueueRow(StoreCode, '2301917', '2301017', '#2301017', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301917', '2301017', '#2301017', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-200, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301817', 'bogus', 200, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301017', _Lib.RefundListItemJson('2301917', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting succeed and the row is Imported
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301917');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The row must be Imported.');

        // [THEN] The credit memo carries 200 on the discrepancy account only
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Quantity, '<>0');
        _Assert.AreEqual(1, SalesCrMemoLine.Count(), 'An amount-only refund is one line.');
        SalesCrMemoLine.FindFirst();
        _Assert.AreEqual(ShopifyStore."Refund Discrepancy G/L Acc.", SalesCrMemoLine."No.", 'The amount goes to the discrepancy account.');
        _Assert.AreEqual(200, SalesCrMemoLine."Amount Including VAT", 'The line carries the refunded amount.');

        // [THEN] The credit memo is settled on the card account
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-200, GLEntry.Amount, 'The refund must be credited to the clearing account.');
    end;

    [Test]
    procedure Posting_RestockedLineRefund_ReturnsTheItemToTheLinkedLocation()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Item: Record Item;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InventoryBefore: Decimal;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund that restocks a line without a return object brings the unit back into stock at the location linked to Shopify's restock location.
        // [GIVEN] A legacy-path store and an order of one unit invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301018', '2301718', 1, 100, ShipmentNo);
        Item.Get(Sku);
        Item.SetRange("Location Filter", LocationCode);
        Item.CalcFields(Inventory);
        InventoryBefore := Item.Inventory;

        // [GIVEN] A queued refund restocking that unit at location 71001, refunded 100
        _Lib.InsertRefundQueueRow(StoreCode, '2301918', '2301018', '#2301018', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301918', '2301018', '#2301018', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301718', Sku, 1, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301818', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301018', _Lib.RefundListItemJson('2301918', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting succeed and the unit is back in stock at the linked location
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        Item.CalcFields(Inventory);
        _Assert.AreEqual(InventoryBefore + 1, Item.Inventory, 'The restocked unit must come back into stock.');
    end;

    [Test]
    procedure Posting_RefundOfATaxesExcludedOrder_CreditsTheSubtotalPlusTax()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order whose prices exclude tax is credited at the line's subtotal plus its tax, which is what Shopify refunded.
        // [GIVEN] A legacy-path store and an order of one unit invoiced at 125 including VAT
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2309032', '2309732', 1, 125, ShipmentNo);

        // [GIVEN] A queued refund restocking that unit on a taxes-excluded order: subtotal 100, tax 25, refunded 125
        _Lib.InsertRefundQueueRow(StoreCode, '2309932', '2309032', '#2309032', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2309932', '2309032', '#2309032', _Lib.RefundTimeAfterNow(), false, _Lib.RefundLineJson('2309732', Sku, 1, 'RETURN', '71001', 100, 25, 25), '', '', _ReturnLib.RefundTxnJson('2309832', 'bogus', 125, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2309032', _Lib.RefundListItemJson('2309932', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo credits 125 including VAT
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2309932');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(125, SalesCrMemoHeader."Amount Including VAT", 'The credit memo credits the subtotal plus its tax.');
    end;

    [Test]
    procedure Posting_ShippingOnlyRefund_CreditsTheShippingAccount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of the shipping cost alone credits the shipping refund account with the shipping line's subtotal plus tax.
        // [GIVEN] A legacy-path store and an order invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301019', '2301719', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund of shipping only, 40 plus 10 tax, refunded 50
        _Lib.InsertRefundQueueRow(StoreCode, '2301919', '2301019', '#2301019', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301919', '2301019', '#2301019', _Lib.RefundTimeAfterNow(), true, '', _ReturnLib.RefundShippingLineJson(40, 10), '', _ReturnLib.RefundTxnJson('2301819', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301019', _Lib.RefundListItemJson('2301919', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo has one line of 50 on the shipping refund account
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301919');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The shipping refund must be credited on the shipping account.');
        _Assert.AreEqual(50, SalesCrMemoLine."Amount Including VAT", 'Shipping is subtotal plus tax.');
    end;

    [Test]
    procedure Import_RefundWithOnlyAPendingTransaction_Waits()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund whose only transaction is still pending at Shopify waits for it, naming the refund, without using up a retry or building a Return Order.
        // [GIVEN] A legacy-path store and an order invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301020', '2301720', 1, 100, ShipmentNo);

        // [GIVEN] A queued amount-only refund of 30 whose transaction is pending
        _Lib.InsertRefundQueueRow(StoreCode, '2301920', '2301020', '#2301020', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301920', '2301020', '#2301020', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301820', 'bogus', 30, _ReturnLib.Lcy(), '').Replace('"status":"SUCCESS"', '"status":"PENDING"')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301020', _Lib.RefundListItemJson('2301920', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row waits with a note naming the refund, no retry is used, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Waiting is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301920');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'A pending refund waits.');
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", 'refund 2301920 of order #2301020') > 0, 'The note must name the refund: ' + QueueRow."Outcome Note");
        _Assert.AreEqual(0, QueueRow."Retry Count", 'Waiting costs no retry.');
        _Lib.AssertNoReturnOrder(CustomerNo);

        // [THEN] Only the refund itself was fetched, not the order's other refunds
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('GetOrderRefunds'), 'A waiting refund must not fetch the order''s other refunds.');
    end;

    [Test]
    procedure Import_RefundBelongingToAReturn_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund that turns out to belong to a return is left to the return: the refund row is refused and nothing is built.
        // [GIVEN] A legacy-path store and an order invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301021', '2301721', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund whose detail names a return
        _Lib.InsertRefundQueueRow(StoreCode, '2301921', '2301021', '#2301021', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.BelongingToReturn(_Lib.RefundDetailResponse('2301921', '2301021', '#2301021', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301821', 'bogus', 30, _ReturnLib.Lcy(), '')), '2301998'));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301021', _Lib.RefundListItemJson('2301921', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused and no Return Order exists
        _Assert.IsFalse(Succeeded, 'A refund of a return must be refused on its own row.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'belongs to a return') > 0, 'The error must say the refund belongs to a return: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_CancelOfAnInvoicedUnit_IsRefusedNamingTheOrder()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Shopify cancelling a unit that Business Central invoiced contradicts the order's invoices, so the refund is refused naming the order and nothing is built.
        // [GIVEN] A legacy-path store and an order of one unit, shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301022', '2301722', 1, 10, ShipmentNo);

        // [GIVEN] A queued refund cancelling that unit
        _Lib.InsertRefundQueueRow(StoreCode, '2301922', '2301022', '#2301022', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301922', '2301022', '#2301022', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301722', Sku, 1, 'CANCEL', '71001', 10, 0, 0), '', '', _ReturnLib.RefundTxnJson('2301822', 'bogus', 10, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301022', _Lib.RefundListItemJson('2301922', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the order, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'A cancel of an invoiced unit must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'order #2301022') > 0, 'The error must name the order: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_RefundWhileTheSalesOrderIsOpen_Waits()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        Settlement: Record "NPR Spfy Refund Settlement";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund on an order still open in Business Central waits for the order to be invoiced, naming the Sales Order, without asking Shopify and without building anything.
        // [GIVEN] A legacy-path store and an open Sales Order of the Shopify order
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateOpenShopifyOrder(StoreCode, CustomerNo, Sku, '2301023', SalesHeader);

        // [GIVEN] A queued refund on that order
        _Lib.InsertRefundQueueRow(StoreCode, '2301923', '2301023', '#2301023', QueueRow);

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row waits with a note naming the Sales Order, Shopify was not asked, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Waiting is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301923');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'The row waits for the order.');
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", SalesHeader."No.") > 0, 'The note must name the Sales Order: ' + QueueRow."Outcome Note");
        _Assert.AreEqual(0, QueueRow."Retry Count", 'Waiting costs no retry.');
        _Assert.AreEqual(0, MockClient.RequestCount(), 'A waiting refund costs no Shopify request.');
        _Assert.IsFalse(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Refund, '2301923'), 'A waiting refund writes no settlement row.');
        _Lib.AssertNoReturnOrder(CustomerNo);

        // Cleanup: remove the committed order and row.
        SalesHeader.Find();
        SalesHeader.Delete(true);
        QueueRow.Delete(false);
        Commit();
    end;

    [Test]
    procedure Posting_RefundOfAShippedUnitMadeBeforeTheInvoice_CreditsIt()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A unit refunded after Shopify shipped it but before Business Central posted the invoice was invoiced in full, so the refund is credited and paid out.
        // [GIVEN] A legacy-path store with a refund item charge and an order of two units at 50, both shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301024', '2301724', 2, 50, ShipmentNo);

        // [GIVEN] A queued refund of one unit without restock, made on 2026-01-02, before that invoice
        _Lib.InsertRefundQueueRow(StoreCode, '2301924', '2301024', '#2301024', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301924', '2301024', '#2301024', '2026-01-02T00:00:00Z', true, _Lib.RefundLineJsonOrdered('2301724', Sku, 1, 2, 'NO_RESTOCK', '', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2301824', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301024', _Lib.RefundListItemJson('2301924', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] A credit memo of 50 is posted and settled
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301924');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(50, SalesCrMemoHeader."Amount Including VAT", 'The shipped unit is credited.');
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        _Assert.IsFalse(CustLedgerEntry.Open, 'The credit memo is settled.');
    end;

    [Test]
    procedure Posting_RefundOfAnInvoicedAndAnUnfulfilledUnit_CreditsTheInvoicedOne()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PaymentLine: Record "NPR Magento Payment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Of two units refunded on a line ordered twice and invoiced once, only the invoiced one is credited, and only its money is paid out.
        // [GIVEN] A legacy-path store and an order line ordered twice in Shopify, one unit shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301025', '2301725', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund restocking both units for 200
        _Lib.InsertRefundQueueRow(StoreCode, '2301925', '2301025', '#2301025', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301925', '2301025', '#2301025', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2301725', Sku, 2, 2, 'RETURN', '71001', 200, 40, 25), '', '', _ReturnLib.RefundTxnJson('2301825', 'bogus', 200, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301025', _Lib.RefundListItemJson('2301925', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] One unit is credited for 100 and 100 is paid out
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301925');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'Only the invoiced unit is credited.');
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.CalcSums(Amount);
        _Assert.AreEqual(100, PaymentLine.Amount, 'Only the money Business Central received is paid out.');
    end;

    [Test]
    procedure Posting_NoRestockRefund_ChargesTheOriginalShipmentWithoutStock()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        ChargeNo: Code[20];
        InventoryBefore: Decimal;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A line refunded while the customer keeps the goods becomes an item charge on the original shipment: the sale's value is reduced and no stock comes back.
        // [GIVEN] A legacy-path store with a refund item charge and an order of one unit at 125 invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ChargeNo := _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301026', '2301726', 1, 125, ShipmentNo);
        Item.Get(Sku);
        Item.CalcFields(Inventory);
        InventoryBefore := Item.Inventory;

        // [GIVEN] A queued refund of 100 gross (25% VAT included) on that line without restock
        _Lib.InsertRefundQueueRow(StoreCode, '2301926', '2301026', '#2301026', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301926', '2301026', '#2301026', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301726', Sku, 1, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301826', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301026', _Lib.RefundListItemJson('2301926', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting succeed with one charge line of 100
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301926');
        // [THEN] No location fallback is flagged
        _Assert.IsFalse(QueueRow."Location Fallback Used", 'A refund that restocks nothing uses no location fallback.');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"Charge (Item)");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The refund must be an item charge line.');
        _Assert.AreEqual(100, SalesCrMemoLine."Amount Including VAT", 'The charge credits what Shopify refunded.');

        // [THEN] The charge carries the item's VAT and reduced the shipment's sales value by its net amount
        SalesShipmentLine.SetRange("Document No.", ShipmentNo);
        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
        SalesShipmentLine.FindFirst();
        _Assert.AreEqual(SalesShipmentLine."VAT %", SalesCrMemoLine."VAT %", 'The charge must carry the VAT of the item it reduces.');
        ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Sales Shipment");
        ItemLedgerEntry.SetRange("Document No.", ShipmentNo);
        ItemLedgerEntry.FindFirst();
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ValueEntry.SetRange("Item Charge No.", ChargeNo);
        ValueEntry.CalcSums("Sales Amount (Actual)");
        _Assert.AreEqual(-SalesCrMemoLine.Amount, ValueEntry."Sales Amount (Actual)", 'The charge must reduce the sale on the original shipment by its net amount.');

        // [THEN] No stock came back
        Item.CalcFields(Inventory);
        _Assert.AreEqual(InventoryBefore, Item.Inventory, 'A refund without restock must not create stock.');
    end;

    [Test]
    procedure Posting_NoRestockRefundWithAWithheldAmount_ChargesAndWithholds()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A backpack of 874.97 refunded as 87.49 with 787.48 withheld (Shopify order #1153) becomes a charge of 874.97 and a fee line of -787.48, and the credit memo of 87.49 is settled.
        // [GIVEN] A legacy-path store with a refund item charge and the order invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301027', '2301727', 1, 874.97, ShipmentNo);

        // [GIVEN] A queued refund of the line without restock with an order adjustment of +787.48, refunded 87.49
        _Lib.InsertRefundQueueRow(StoreCode, '2301927', '2301027', '#2301027', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301927', '2301027', '#2301027', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301727', Sku, 1, 'NO_RESTOCK', '', 874.97, 174.99, 25), '', _ReturnLib.OrderAdjustmentJson(787.48, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301827', 'bogus', 87.49, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301027', _Lib.RefundListItemJson('2301927', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo has the charge and the withheld fee, and is settled
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301927');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"Charge (Item)");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The kept line must be an item charge.');
        _Assert.AreEqual(874.97, SalesCrMemoLine."Amount Including VAT", 'The charge carries the refunded line.');
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Return Fee G/L Account No.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The withheld amount must be a fee line.');
        _Assert.AreEqual(-787.48, SalesCrMemoLine."Amount Including VAT", 'The withheld amount is a negative fee line.');
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');
    end;

    [Test]
    procedure Posting_NoRestockRefundOfAnOrderShippedInTwoParts_ChargesBothShipments()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ChargeNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Two units shipped and invoiced in two parts, both refunded without restock, are charged one unit to each shipment, since the invoiced quantity adds up across both invoices.
        // [GIVEN] A legacy-path store with a refund item charge and a two-unit line shipped and invoiced in two parts
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ChargeNo := _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrderInTwoParts(StoreCode, CustomerNo, Sku, LocationCode, '2301028', '2301728', 125);

        // [GIVEN] A queued refund of both units without restock, 200 gross
        _Lib.InsertRefundQueueRow(StoreCode, '2301928', '2301028', '#2301028', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301928', '2301028', '#2301028', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301728', Sku, 2, 'NO_RESTOCK', '', 200, 40, 25), '', '', _ReturnLib.RefundTxnJson('2301828', 'bogus', 200, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301028', _Lib.RefundListItemJson('2301928', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] Each shipment's entry carries one unit's charge, half of the charge line's net amount
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301928');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"Charge (Item)");
        SalesCrMemoLine.FindFirst();
        ItemLedgerEntry.SetRange("Item No.", Sku);
        ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Sales Shipment");
        _Assert.AreEqual(2, ItemLedgerEntry.Count(), 'Precondition: two shipments.');
        ItemLedgerEntry.FindSet();
        repeat
            ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
            ValueEntry.SetRange("Item Charge No.", ChargeNo);
            ValueEntry.CalcSums("Sales Amount (Actual)");
            _Assert.AreEqual(-SalesCrMemoLine.Amount / 2, ValueEntry."Sales Amount (Actual)", 'Each shipment carries one unit of the charge.');
        until ItemLedgerEntry.Next() = 0;
    end;

    [Test]
    procedure Posting_NoRestockRefundOfAnOrderShippedAgainAfterAnUndo_ChargesTheNewShipment()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ItemLedgerEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ChargeNo: Code[20];
        UndoneShipmentNo: Code[20];
        ReshipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A unit refunded without restock whose first shipment was undone and shipped again is charged to the new shipment, not to the undone one.
        // [GIVEN] A legacy-path store with a refund item charge and a one-unit line shipped, undone, shipped again and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ChargeNo := _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrderShippedUndoneAndReshipped(StoreCode, CustomerNo, Sku, LocationCode, '2309031', '2309731', 125, UndoneShipmentNo, ReshipmentNo);

        // [GIVEN] A queued refund of the unit without restock, 100 gross
        _Lib.InsertRefundQueueRow(StoreCode, '2309931', '2309031', '#2309031', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2309931', '2309031', '#2309031', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2309731', Sku, 1, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2309831', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2309031', _Lib.RefundListItemJson('2309931', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The new shipment's entry carries the whole charge and the undone shipment's entry none
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2309931');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"Charge (Item)");
        SalesCrMemoLine.FindFirst();
        ItemLedgerEntry.SetRange("Item No.", Sku);
        ItemLedgerEntry.SetRange("Document No.", ReshipmentNo);
        ItemLedgerEntry.FindFirst();
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
        ValueEntry.SetRange("Item Charge No.", ChargeNo);
        ValueEntry.CalcSums("Sales Amount (Actual)");
        _Assert.AreEqual(-SalesCrMemoLine.Amount, ValueEntry."Sales Amount (Actual)", 'The new shipment carries the charge.');
        // [THEN] No entry of the undone shipment carries any of it
        ItemLedgerEntry.SetRange("Document No.", UndoneShipmentNo);
        _Assert.IsTrue(ItemLedgerEntry.FindSet(), 'Precondition: the undone shipment has its entries.');
        repeat
            ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntry."Entry No.");
            _Assert.IsTrue(ValueEntry.IsEmpty(), 'The undone shipment must not be charged.');
        until ItemLedgerEntry.Next() = 0;
    end;

    [Test]
    procedure Posting_RefundWithRestockedAndKeptLines_ReturnsOneAndChargesTheOther()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ItemB: Record Item;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        LibraryInventory: Codeunit "Library - Inventory";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] One refund restocking item A and refunding item B without restock yields an item return line for A at the restock location and a charge line for B, with no location fallback.
        // [GIVEN] A legacy-path store with a refund item charge and an order of items A and B invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        LibraryInventory.CreateItem(ItemB);
        _Lib.PostShopifyOrderTwoLines(StoreCode, CustomerNo, LocationCode, '2301029', Sku, '2301729', ItemB."No.", '2301730', 125);

        // [GIVEN] A queued refund restocking A at 71001 and keeping B, 100 each
        _Lib.InsertRefundQueueRow(StoreCode, '2301929', '2301029', '#2301029', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301929', '2301029', '#2301029', _Lib.RefundTimeAfterNow(), true,
            _Lib.RefundLineJson('2301729', Sku, 1, 'RETURN', '71001', 100, 20, 25) + ',' + _Lib.RefundLineJson('2301730', ItemB."No.", 1, 'NO_RESTOCK', '', 100, 20, 25),
            '', '', _ReturnLib.RefundTxnJson('2301829', 'bogus', 200, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301029', _Lib.RefundListItemJson('2301929', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] A comes back as an item line and B is charged, with no location fallback
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301929');
        _Assert.IsFalse(QueueRow."Location Fallback Used", 'The restock location was linked, so no fallback.');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        _Assert.AreEqual(LocationCode, SalesCrMemoHeader."Location Code", 'The header takes the restock location.');
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.SetRange("No.", Sku);
        _Assert.IsFalse(SalesCrMemoLine.IsEmpty(), 'The restocked item comes back as an item line.');
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"Charge (Item)");
        SalesCrMemoLine.SetRange("No.");
        _Assert.IsFalse(SalesCrMemoLine.IsEmpty(), 'The kept item is charged.');
    end;

    [Test]
    procedure Import_NoRestockRefundWithoutAnItemCharge_IsRefusedNamingTheField()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        ItemChargeNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A line refunded without restock on a store without a refund item charge is refused naming that field, and nothing is built.
        // [GIVEN] A legacy-path store without a refund item charge and an order invoiced before the refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        ItemChargeNo := ShopifyStore."Refund Item Charge No.";
        ShopifyStore."Refund Item Charge No." := '';
        ShopifyStore.Modify();
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301030', '2301731', 1, 125, ShipmentNo);

        // [GIVEN] A queued refund of that line without restock
        _Lib.InsertRefundQueueRow(StoreCode, '2301930', '2301030', '#2301030', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301930', '2301030', '#2301030', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301731', Sku, 1, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301830', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301030', _Lib.RefundListItemJson('2301930', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Refund Item Charge No." := ItemChargeNo;
        ShopifyStore.Modify();
        Commit();

        // [THEN] It is refused naming the field, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'Without an item charge the refund must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), ShopifyStore.FieldCaption("Refund Item Charge No.")) > 0, 'The error must name the field: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_NpGiftCardRefund_CreditsTheSaleAccountAndArchivesTheCards()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Voucher: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        VoucherNos: List of [Code[20]];
        VoucherNo: Code[20];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Two NP gift cards refunded without a return credit the account of their sale and both vouchers are written off and archived, although their type allows top-up.
        // [GIVEN] A legacy-path store and an earlier invoice that sold two 50 gift cards on line 2301741 and issued two untouched vouchers
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _ReturnLib.CreateSalesGLAccountNo(Sku);
        _ReturnLib.InsertPostedGiftCardSale('SI-230141', StoreCode, '2301041', '2301741', GLAccountNo, 2, 50, VoucherNos);

        // [GIVEN] A queued refund of both cards, 100 to the card
        _Lib.InsertRefundQueueRow(StoreCode, '2301941', '2301041', '#2301041', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301941', '2301041', '#2301041', _Lib.RefundTimeAfterNow(), true, _Lib.GiftCardRefundLineJson('2301741', 2, 100, false), '', '', _ReturnLib.RefundTxnJson('2301841', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301041', _Lib.RefundListItemJson('2301941', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo credits 100 on the sale account
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301941');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange("No.", GLAccountNo);
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The gift card line must be credited on the account of its sale.');
        _Assert.AreEqual(100, SalesCrMemoLine."Amount Including VAT", 'The gift card line credits what Shopify refunded.');

        // [THEN] Both vouchers are archived with nothing left on them
        foreach VoucherNo in VoucherNos do begin
            _Assert.IsFalse(Voucher.Get(VoucherNo), 'Voucher ' + VoucherNo + ' must be archived.');
            _Assert.IsTrue(ArchVoucher.Get(VoucherNo), 'Archived voucher ' + VoucherNo + ' must exist.');
            ArchVoucher.CalcFields(Amount);
            _Assert.AreEqual(0, ArchVoucher.Amount, 'Nothing may be left on the voucher.');
        end;
    end;

    [Test]
    procedure Posting_ShopifyNativeGiftCardRefund_ArchivesItsVoucher()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        VoucherNos: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A Shopify-native gift card refunded without a return revokes the voucher its sale issued, like an NP gift card, so the voucher sync deactivates the card at Shopify.
        // [GIVEN] A legacy-path store and an earlier invoice that sold one 50 gift card on line 2301742
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _ReturnLib.CreateSalesGLAccountNo(Sku);
        _ReturnLib.InsertPostedGiftCardSale('SI-230142', StoreCode, '2301042', '2301742', GLAccountNo, 1, 50, VoucherNos);

        // [GIVEN] A queued refund of that Shopify-native gift card line, 50 to the card
        _Lib.InsertRefundQueueRow(StoreCode, '2301942', '2301042', '#2301042', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301942', '2301042', '#2301042', _Lib.RefundTimeAfterNow(), true, _Lib.GiftCardRefundLineJson('2301742', 1, 50, true), '', '', _ReturnLib.RefundTxnJson('2301842', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301042', _Lib.RefundListItemJson('2301942', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The voucher is archived
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        _Assert.IsFalse(Voucher.Get(VoucherNos.Get(1)), 'The voucher of the refunded card must be archived.');
    end;

    [Test]
    procedure Import_GiftCardRefund_UsedVoucher_IsRefusedNamingTheInvoice()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        VoucherNos: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Refunding two gift cards when one of their vouchers was partly spent is refused naming the invoice that sold them, and nothing is built.
        // [GIVEN] A legacy-path store and an earlier invoice that sold two 50 gift cards on line 2301743, one of them spent by 10
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _ReturnLib.CreateSalesGLAccountNo(Sku);
        _ReturnLib.InsertPostedGiftCardSale('SI-230143', StoreCode, '2301043', '2301743', GLAccountNo, 2, 50, VoucherNos);
        _ReturnLib.UseVoucherAmount(VoucherNos.Get(1), 10);

        // [GIVEN] A queued refund of both cards
        _Lib.InsertRefundQueueRow(StoreCode, '2301943', '2301043', '#2301043', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301943', '2301043', '#2301043', _Lib.RefundTimeAfterNow(), true, _Lib.GiftCardRefundLineJson('2301743', 2, 100, false), '', '', _ReturnLib.RefundTxnJson('2301843', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301043', _Lib.RefundListItemJson('2301943', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the invoice, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'A used card must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SI-230143') > 0, 'The error must name the invoice: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_RefundToAGiftCard_CreditsTheVoucherBack()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        BalanceBefore: Decimal;
        InitialAmountBefore: Decimal;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A goodwill refund of 50 paid to a gift card gives the voucher behind that card back 50 as a reversed payment, as a return refunded to a gift card does, and leaves its initial amount alone.
        // [GIVEN] A legacy-path store and a voucher linked to Shopify gift card 2301944 that paid 50 on the order's invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.CreateVoucherWithGiftCardId('SPFYRFGC44', StoreCode, '2301944', Voucher);
        _ReturnLib.InsertPostedInvoiceWithVoucherPayment('SI-230144', StoreCode, '2301044', Voucher."No.", 50);
        Voucher.CalcFields(Amount, "Initial Amount");
        BalanceBefore := Voucher.Amount;
        InitialAmountBefore := Voucher."Initial Amount";

        // [GIVEN] A queued amount-only refund of 50 to that gift card
        _Lib.InsertRefundQueueRow(StoreCode, '2301945', '2301044', '#2301044', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301945', '2301044', '#2301044', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-50, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301844', 'gift_card', 50, _ReturnLib.Lcy(), '2301944')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301044', _Lib.RefundListItemJson('2301945', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The voucher's balance grew by 50 and its initial amount did not
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        Voucher.Get('SPFYRFGC44');
        Voucher.CalcFields(Amount, "Initial Amount");
        _Assert.AreEqual(BalanceBefore + 50, Voucher.Amount, 'The gift card share must be given back to the voucher.');
        _Assert.AreEqual(InitialAmountBefore, Voucher."Initial Amount", 'Giving a payment back must not change the initial amount.');
    end;

    [Test]
    procedure Posting_RefundDraftPostedByAUser_SettlesAndMarksTheRowImported()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] With automatic posting off a refund row stops at Draft Created; when a user posts the Return Order, the credit memo is settled and the row becomes Imported.
        // [GIVEN] A legacy-path store that posts by hand and an invoiced order
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301046', '2301746', 1, 100, ShipmentNo);

        // [GIVEN] A queued amount-only refund of 40 processed by the job into a draft
        _Lib.InsertRefundQueueRow(StoreCode, '2301946', '2301046', '#2301046', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301946', '2301046', '#2301046', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-40, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301846', 'bogus', 40, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301046', _Lib.RefundListItemJson('2301946', '2026-09-20T10:00:00Z', '')));
        _Assert.IsTrue(_ReturnLib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301946');
        Commit();
        SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301946');
        _Assert.AreEqual(QueueRow.Status::"Draft Created", QueueRow.Status, 'Precondition: the row waits at Draft Created.');
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");

        // [WHEN] A user posts the Return Order
        Succeeded := _Lib.PostReturnOrder(SalesHeader);

        // [THEN] The credit memo is settled and the row is Imported
        _Assert.IsTrue(Succeeded, 'Posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301946');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A posted refund row is Imported.');
        SalesCrMemoHeader.Get(QueueRow."Posted Doc. No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');

        // Cleanup: restore the committed store.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := true;
        ShopifyStore.Modify();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_FailingRefundRow_CountsEveryFailedAttempt()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShopifyUrl: Text[250];
        Attempt: Integer;
    begin
        // [SCENARIO] A refund row whose import keeps failing is retried and counted like a return row, ending at Error with its message kept.
        // [GIVEN] A legacy-path store that cannot reach Shopify (blank Shopify Url) and a queued refund
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        ShopifyUrl := ShopifyStore."Shopify Url";
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();
        _Lib.InsertRefundQueueRow(StoreCode, '2301947', '2301047', '#2301047', QueueRow);
        Commit();

        // [WHEN] The row is processed three times
        for Attempt := 1 to 3 do begin
            QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301947');
            SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);
            Commit();
        end;

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Shopify Url" := ShopifyUrl;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The row is at Error with three attempts and the last error kept
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301947');
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'A failing refund row ends at Error.');
        _Assert.AreEqual(3, QueueRow."Retry Count", 'Each attempt counts.');
        _Assert.AreNotEqual('', QueueRow."Last Error", 'The row keeps the last error.');
    end;

    [Test]
    procedure PollJQ_DismissedRefund_IsNotQueuedAgain()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A refund dismissed as handled by hand stays dismissed when the poll sees it again.
        // [GIVEN] A legacy-path store with a dismissed refund row
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();
        _Lib.InsertRefundQueueRow(StoreCode, '2301948', '2301048', '#2301048', QueueRow);
        SpfyLegacyReturnMgt.DismissReturn(QueueRow);
        Commit();

        // [GIVEN] Shopify still lists the refund
        MockClient.AddResponse('sortKey:UPDATED_AT', 'refunds(first: 50) { id createdAt', _Lib.RefundListResponse('gid://shopify/Order/2301048', '#2301048', '', _Lib.RefundListItemJson('2301948', '2026-09-20T10:00:00Z', '')));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The row is still the one dismissed row
        QueueRow.Reset();
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        _Assert.AreEqual(1, QueueRow.Count(), 'The refund is not queued twice.');
        QueueRow.FindFirst();
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'The dismissed refund stays dismissed.');

        // Cleanup: remove the committed rows.
        QueueRow.DeleteAll(false);
        Commit();
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure FeatureFlagOn_IsRefusedWhileARefundRowIsUnprocessed()
    var
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        Feature: Record "NPR Feature";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Enabling the Ecommerce feature is refused while a refund row is New, as for a return row.
        // [GIVEN] No unprocessed rows left over from other tests
        LegacyReturnQueue.SetFilter(Status, '<>%1&<>%2', LegacyReturnQueue.Status::Imported, LegacyReturnQueue.Status::"Nothing to Credit");
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off and a New refund row
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Lib.InsertRefundQueueRow(StoreCode, '2301949', '2301049', '#2301049', QueueRow);
        Clear(_CapturedMessage);

        // [WHEN] The pre-flight check for enabling runs
        Feature.Enabled := true;
        asserterror ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] It refuses, naming the queue
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The message must name the legacy return queue.');
    end;

    [Test]
    procedure StoreDeleted_WithAnUnfinishedRefund_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A store with a refund row that is not imported cannot be deleted, as with a return row.
        // [GIVEN] A legacy-path store with a New refund row
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2301950', '2301050', '#2301050', QueueRow);

        // [WHEN] The store is deleted
        ShopifyStore.Get(StoreCode);
        asserterror ShopifyStore.Delete(true);

        // [THEN] The deletion is refused naming the queue
        _Assert.IsTrue(StrPos(GetLastErrorText(), QueueRow.TableCaption()) > 0, 'The error must name the legacy return queue: ' + GetLastErrorText());
    end;

    [Test]
    procedure RefundApi_ParseDetail_ReadsTheOrderedQuantity()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A refund line keeps how many units its order line was ordered, refunded and removed units included.
        // [GIVEN] Refund detail with one unit refunded of a line ordered three times
        Response.ReadFrom(_Lib.RefundDetailResponse('2301951', '2301051', '#2301051', '2026-09-20T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2301751', 'SKU1', 1, 3, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301851', 'bogus', 100, _ReturnLib.Lcy(), '')));

        // [WHEN] The detail is parsed
        SpfyLegacyReturnAPI.ParseRefundDetail('', '2301951', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The line carries ordered quantity 3
        TempLineBuffer.FindFirst();
        _Assert.AreEqual(3, TempLineBuffer."Ordered Quantity", 'The ordered quantity comes from lineItem.quantity.');
    end;

    [Test]
    procedure RefundApi_ParseDetail_OrderedBelowRefunded_IsAProgrammingBug()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A refund line refunding more units than its order line was ordered cannot be allocated and is reported as a programming bug.
        // [GIVEN] Refund detail refunding two units of a line Shopify reports as ordered once
        Response.ReadFrom(_Lib.RefundDetailResponse('2301952', '2301052', '#2301052', '2026-09-20T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2301752', 'SKU1', 2, 1, 'RETURN', '71001', 200, 40, 25), '', '', _ReturnLib.RefundTxnJson('2301852', 'bogus', 200, _ReturnLib.Lcy(), '')));

        // [WHEN] The detail is parsed
        asserterror SpfyLegacyReturnAPI.ParseRefundDetail('', '2301952', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error is a programming bug naming the line item
        _Assert.ExpectedError('This is a programming bug');
        _Assert.IsTrue(StrPos(GetLastErrorText(), '2301752') > 0, 'The error must name the line item: ' + GetLastErrorText());
    end;

    [Test]
    procedure RefundApi_ParseDetail_BlankCreatedAt_IsRefused()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        DetailJson: Text;
    begin
        // [SCENARIO] A refund without a creation time cannot be ordered among the order's refunds, so its detail is refused.
        // [GIVEN] Refund detail whose createdAt is null
        DetailJson := _Lib.RefundDetailResponse('2301953', '2301053', '#2301053', '2026-09-20T10:00:00Z', true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301853', 'bogus', 30, _ReturnLib.Lcy(), ''));
        Response.ReadFrom(DetailJson.Replace('"createdAt":"2026-09-20T10:00:00Z","processedAt"', '"createdAt":null,"processedAt"'));

        // [WHEN] The detail is parsed
        asserterror SpfyLegacyReturnAPI.ParseRefundDetail('', '2301953', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] It is refused
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'createdAt') > 0, 'The error must name the missing field: ' + GetLastErrorText());
    end;

    [Test]
    procedure RefundApi_EarlierRefunds_OnlyRefundActionRefundsMadeBefore()
    var
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        EarlierRefundIds: List of [Text];
        LaterRefundIds: List of [Text];
        Incomplete: Boolean;
    begin
        // [SCENARIO] The order's Refund-action refunds are split into those created before this one and those after it; a return's refund and this refund itself are left out.
        // [GIVEN] An order with a Refund-action refund before this one, a return's refund before it, a refund after it, and this refund
        Response.ReadFrom(_Lib.OrderRefundsResponse('2301054',
            _Lib.RefundListItemJson('2302101', '2026-09-01T10:00:00Z', '') + ',' +
            _Lib.RefundListItemJson('2302102', '2026-09-02T10:00:00Z', 'gid://shopify/Return/2301954') + ',' +
            _Lib.RefundListItemJson('2302104', '2026-09-20T10:00:00Z', '') + ',' +
            _Lib.RefundListItemJson('2302103', '2026-09-30T10:00:00Z', '')));

        // [WHEN] The earlier refunds of refund 2302104 are picked
        SpfyLegacyReturnAPI.ParseOrderRefundIds('2302104', UtcDateTime('2026-09-20T10:00:00Z'), Response, EarlierRefundIds, LaterRefundIds, Incomplete);

        // [THEN] Only the Refund-action refund made before it is picked
        _Assert.AreEqual(1, EarlierRefundIds.Count(), 'One earlier Refund-action refund.');
        _Assert.AreEqual('2302101', EarlierRefundIds.Get(1), 'The earlier refund is 2302101.');

        // [THEN] The Refund-action refund made after it is listed apart, so its cancelled units can still be counted
        _Assert.AreEqual(1, LaterRefundIds.Count(), 'One later Refund-action refund.');
        _Assert.AreEqual('2302103', LaterRefundIds.Get(1), 'The later refund is 2302103.');
    end;

    [Test]
    procedure RefundApi_EarlierRefunds_SameSecond_LowerIdIsEarlier()
    var
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        EarlierRefundIds: List of [Text];
        LaterRefundIds: List of [Text];
        Incomplete: Boolean;
    begin
        // [SCENARIO] Of two refunds created in the same second, the one with the lower Shopify id counts as the earlier one.
        // [GIVEN] Two Refund-action refunds of one order created in the same second
        Response.ReadFrom(_Lib.OrderRefundsResponse('2301055',
            _Lib.RefundListItemJson('2302105', '2026-09-20T10:00:00Z', '') + ',' +
            _Lib.RefundListItemJson('2302106', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The earlier refunds of the higher id are picked
        SpfyLegacyReturnAPI.ParseOrderRefundIds('2302106', UtcDateTime('2026-09-20T10:00:00Z'), Response, EarlierRefundIds, LaterRefundIds, Incomplete);

        // [THEN] The lower id is the earlier one
        _Assert.AreEqual(1, EarlierRefundIds.Count(), 'One earlier refund.');
        _Assert.AreEqual('2302105', EarlierRefundIds.Get(1), 'The lower id is earlier.');
    end;

    [Test]
    procedure RefundApi_EarlierRefunds_FullPage_IsFlaggedIncomplete()
    var
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        EarlierRefundIds: List of [Text];
        LaterRefundIds: List of [Text];
        RefundsJson: Text;
        Incomplete: Boolean;
        i: Integer;
    begin
        // [SCENARIO] An order listing a full page of 50 refunds may hold more, so the list is flagged incomplete for the allocation to refuse if it needs it.
        // [GIVEN] An order whose refund list holds 50 refunds
        for i := 1 to 50 do begin
            if RefundsJson <> '' then
                RefundsJson += ',';
            RefundsJson += _Lib.RefundListItemJson(Format(2302000 + i), '2026-09-01T10:00:00Z', '');
        end;
        Response.ReadFrom(_Lib.OrderRefundsResponse('2301056', RefundsJson));

        // [WHEN] The earlier refunds are picked
        SpfyLegacyReturnAPI.ParseOrderRefundIds('2301956', UtcDateTime('2026-09-20T10:00:00Z'), Response, EarlierRefundIds, LaterRefundIds, Incomplete);

        // [THEN] The list is flagged incomplete and the refunds it holds are still picked
        _Assert.IsTrue(Incomplete, 'A full page of refunds may hold more.');
        _Assert.AreEqual(50, EarlierRefundIds.Count(), 'The listed refunds made before are still picked.');
    end;

    [Test]
    procedure RefundApi_EarlierRefunds_MissingList_IsFlaggedIncomplete()
    var
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        EarlierRefundIds: List of [Text];
        LaterRefundIds: List of [Text];
        Incomplete: Boolean;
    begin
        // [SCENARIO] An order whose refund list does not come back is flagged incomplete, since the list always holds the refund itself and the other refunds are unknown.
        // [GIVEN] A response without the order
        Response.ReadFrom('{"data":{"order":null}}');

        // [WHEN] The earlier refunds are picked
        SpfyLegacyReturnAPI.ParseOrderRefundIds('2301956', UtcDateTime('2026-09-20T10:00:00Z'), Response, EarlierRefundIds, LaterRefundIds, Incomplete);

        // [THEN] The list is flagged incomplete
        _Assert.IsTrue(Incomplete, 'A missing refund list leaves the other refunds unknown.');
    end;

    [Test]
    procedure RefundApi_EarlierRefunds_ListWithoutThisRefund_IsFlaggedIncomplete()
    var
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        EarlierRefundIds: List of [Text];
        LaterRefundIds: List of [Text];
        Incomplete: Boolean;
    begin
        // [SCENARIO] An order refund list that does not hold the refund itself is not the order's whole list, so it is flagged incomplete.
        // [GIVEN] An order whose refund list comes back empty
        Response.ReadFrom(_Lib.OrderRefundsResponse('2301956', ''));

        // [WHEN] The earlier refunds are picked
        SpfyLegacyReturnAPI.ParseOrderRefundIds('2301956', UtcDateTime('2026-09-20T10:00:00Z'), Response, EarlierRefundIds, LaterRefundIds, Incomplete);

        // [THEN] The list is flagged incomplete
        _Assert.IsTrue(Incomplete, 'A list without the refund itself leaves the other refunds unknown.');
    end;

    [Test]
    procedure RefundApi_OtherRefundWithoutItsLines_IsFlaggedIncomplete()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Another refund of the order that comes back without its line items leaves its units unknown, so the other refunds are flagged incomplete.
        // [GIVEN] A legacy-path store and an earlier refund of the order returned without its line items
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302436', '{"data":{"refund":{"id":"gid://shopify/Refund/2302436","createdAt":"2026-09-01T10:00:00Z","refundLineItems":null}}}');
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302437', _Lib.RefundDetailResponse('2302437', '2302228', '#2302228', '2026-09-20T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302328', Sku, 1, 2, 'NO_RESTOCK', '', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2302537', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302228', _Lib.RefundListItemJson('2302436', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302437', '2026-09-20T10:00:00Z', '')));
        SpfyLegacyReturnAPI.SetGraphQLClient(MockClient);

        // [WHEN] The later refund's detail is read
        SpfyLegacyReturnAPI.GetRefundDetail(StoreCode, '2302437', TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
        SpfyLegacyReturnAPI.GetOtherRefundLines(StoreCode, '2302437', TempReturnBuffer, TempOtherLineBuffer);

        // [THEN] The other refunds are flagged incomplete
        TempReturnBuffer.Get('2302437');
        _Assert.IsTrue(TempReturnBuffer."Other Refunds Incomplete", 'A refund returned without its line items leaves its units unknown.');
    end;

    [Test]
    procedure RefundApi_GetRefundDetail_FillsTheEarlierRefundLines()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempEarlierLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Reading a refund also reads the line items of the order's Refund-action refunds made before it, each with its creation time.
        // [GIVEN] A legacy-path store and an order with one earlier refund cancelling one unit
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302107', _Lib.RefundDetailResponse('2302107', '2301057', '#2301057', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2301757', Sku, 1, 2, 'CANCEL', '71001', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2301857', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2301957', _Lib.RefundDetailResponse('2301957', '2301057', '#2301057', '2026-09-20T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2301757', Sku, 1, 2, 'NO_RESTOCK', '', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2301858', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301057', _Lib.RefundListItemJson('2302107', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2301957', '2026-09-20T10:00:00Z', '')));
        SpfyLegacyReturnAPI.SetGraphQLClient(MockClient);

        // [WHEN] The refund detail is read
        SpfyLegacyReturnAPI.GetRefundDetail(StoreCode, '2301957', TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
        SpfyLegacyReturnAPI.GetOtherRefundLines(StoreCode, '2301957', TempReturnBuffer, TempEarlierLineBuffer);

        // [THEN] The earlier refund's CANCEL line is in the earlier buffer with its creation time
        _Assert.AreEqual(1, TempEarlierLineBuffer.Count(), 'One earlier refund line.');
        TempEarlierLineBuffer.FindFirst();
        _Assert.AreEqual('CANCEL', TempEarlierLineBuffer."Restock Type", 'The earlier line keeps its restock type.');
        _Assert.AreEqual(UtcDateTime('2026-09-01T10:00:00Z'), TempEarlierLineBuffer."Source Created At", 'The earlier line carries its refund''s creation time.');
    end;

    [Test]
    procedure Import_RefundOfAShippedLineOnAPartlyShippedOrder_Waits()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        ItemB: Record Item;
        LibraryInventory: Codeunit "Library - Inventory";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of a line that was shipped and invoiced, on an order whose other line is not shipped yet, waits until the order is invoiced instead of being dismissed.
        // [GIVEN] A legacy-path store and an order with line A invoiced and line B still open
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LibraryInventory.CreateItem(ItemB);
        _Lib.PostShopifyOrderFirstLineOnly(StoreCode, CustomerNo, LocationCode, '2301058', Sku, '2301758', ItemB."No.", '2301798', 125, SalesHeader);

        // [GIVEN] A queued refund of line A
        _Lib.InsertRefundQueueRow(StoreCode, '2301958', '2301058', '#2301058', QueueRow);

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row waits naming the Sales Order and nothing is built
        _Assert.IsTrue(Succeeded, 'Waiting is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301958');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'The row waits for the order.');
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", SalesHeader."No.") > 0, 'The note must name the Sales Order: ' + QueueRow."Outcome Note");
        _Lib.AssertNoReturnOrder(CustomerNo);
        _Assert.AreEqual(0, MockClient.RequestCount(), 'A waiting refund costs no Shopify request.');

        // Cleanup: remove the committed order and row.
        SalesHeader.Find();
        SalesHeader.Delete(true);
        QueueRow.Delete(false);
        Commit();
    end;

    [Test]
    procedure Import_WaitingRefundAfterTheOrderIsInvoiced_CreditsTheShippedLine()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ItemB: Record Item;
        LibraryInventory: Codeunit "Library - Inventory";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A waiting refund of a shipped line is credited in full once Business Central has invoiced the rest of the order.
        // [GIVEN] A legacy-path store and an order with line A invoiced, then line B invoiced too, so the Sales Order is gone
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LibraryInventory.CreateItem(ItemB);
        _Lib.PostShopifyOrderFirstLineOnly(StoreCode, CustomerNo, LocationCode, '2301059', Sku, '2301759', ItemB."No.", '2301799', 125, SalesHeader);
        _Lib.PostRemainingLines(StoreCode, SalesHeader);

        // [GIVEN] A waiting refund restocking line A for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2301959', '2301059', '#2301059', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Business Central has invoiced Shopify order #2301059.';
        QueueRow.Modify();
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301959', '2301059', '#2301059', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301759', Sku, 1, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301859', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301059', _Lib.RefundListItemJson('2301959', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs again
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The refund is credited for 100 and the row is imported with its note cleared
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301959');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The row is imported.');
        _Assert.AreEqual('', QueueRow."Outcome Note", 'A built refund carries no waiting note.');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The shipped line is credited in full.');
    end;

    [Test]
    procedure ProcessJQ_WaitingRefundRow_IsPickedUpEveryRunWithoutRetries()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        ShopifyStore: Record "NPR Spfy Store";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShopifyUrl: Text[250];
        LongAgo: DateTime;
        RunNo: Integer;
    begin
        // [SCENARIO] The process job looks at a waiting refund on every run and never counts it as a failed attempt.
        // [GIVEN] No unfinished rows left by other tests, and a store that cannot reach Shopify (blank Shopify Url), so a Shopify call would fail the row instead of reaching a real shop
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.DeleteUnfinishedQueueRows();
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        ShopifyUrl := ShopifyStore."Shopify Url";
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();

        // [GIVEN] An open Sales Order and a waiting refund row on it
        _Lib.CreateOpenShopifyOrder(StoreCode, CustomerNo, Sku, '2301060', SalesHeader);
        _Lib.InsertRefundQueueRow(StoreCode, '2301960', '2301060', '#2301060', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [GIVEN] The job has run twice, and the row's last attempt is then set back to long ago
        for RunNo := 1 to 2 do
            SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);
        LongAgo := CreateDateTime(DMY2Date(1, 1, 2020), 0T);
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301960');
        QueueRow."Processed At" := LongAgo;
        QueueRow.Modify();
        Commit();

        // [WHEN] The process job runs a third time
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Shopify Url" := ShopifyUrl;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The third run picked the row up again; it still waits, carries no retry and no error, so Shopify was never called
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301960');
        _Assert.IsTrue(QueueRow."Processed At" > LongAgo, 'The third run picked the row up again.');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'The row still waits.');
        _Assert.AreEqual(0, QueueRow."Retry Count", 'Waiting is never counted.');
        _Assert.AreEqual('', QueueRow."Last Error", 'A waiting row makes no Shopify call.');

        // Cleanup: remove the committed order and row.
        SalesHeader.Find();
        SalesHeader.Delete(true);
        QueueRow.Delete(false);
        Commit();
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure FeatureFlagOn_IsRefusedWhileARefundRowIsWaiting()
    var
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        Feature: Record "NPR Feature";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Enabling the Ecommerce feature is refused while a refund row waits for its order, since the legacy engine still owes it.
        // [GIVEN] No unprocessed rows left over from other tests
        LegacyReturnQueue.SetFilter(Status, '<>%1&<>%2', LegacyReturnQueue.Status::Imported, LegacyReturnQueue.Status::"Nothing to Credit");
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off and a waiting refund row
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Lib.InsertRefundQueueRow(StoreCode, '2301961', '2301061', '#2301061', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow.Modify();
        Clear(_CapturedMessage);

        // [WHEN] The pre-flight check for enabling runs
        Feature.Enabled := true;
        asserterror ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] It refuses, naming the queue
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The message must name the legacy return queue.');
    end;

    [Test]
    procedure StoreDeleted_WithAWaitingRefund_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A store with a refund row waiting for its order cannot be deleted.
        // [GIVEN] A legacy-path store with a waiting refund row
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2301962', '2301062', '#2301062', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow.Modify();

        // [WHEN] The store is deleted
        ShopifyStore.Get(StoreCode);
        asserterror ShopifyStore.Delete(true);

        // [THEN] The deletion is refused naming the queue
        _Assert.IsTrue(StrPos(GetLastErrorText(), QueueRow.TableCaption()) > 0, 'The error must name the legacy return queue: ' + GetLastErrorText());
    end;

    [Test]
    procedure StoreDeleted_WithOnlyNothingToCreditRows_IsAllowed()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A refund row that ended with nothing to credit is finished, so it does not hold its store back from deletion.
        // [GIVEN] A legacy-path store whose only row ended with nothing to credit
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll(false);
        _Lib.InsertRefundQueueRow(StoreCode, '2301963', '2301063', '#2301063', QueueRow);
        QueueRow.Status := QueueRow.Status::"Nothing to Credit";
        QueueRow.Modify();

        // [WHEN] The store is deleted
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Delete(true);

        // [THEN] The store and its rows are gone
        QueueRow.Reset();
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        _Assert.IsTrue(QueueRow.IsEmpty(), 'The store''s rows are deleted with it.');
    end;

    [Test]
    procedure ProcessJQ_NothingToCreditRow_IsLeftAlone()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] Processing a refund that ended with nothing to credit claims nothing and leaves the row as it is.
        // [GIVEN] A refund row that ended with nothing to credit
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2301964', '2301064', '#2301064', QueueRow);
        QueueRow.Status := QueueRow.Status::"Nothing to Credit";
        QueueRow.Modify();
        Commit();

        // [WHEN] The row is processed
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] Nothing was claimed and the status stays
        _Assert.IsFalse(Claimed, 'A finished row is not claimed.');
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301964');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'The status stays.');

        // Cleanup: remove the committed row.
        QueueRow.Delete(false);
        Commit();
    end;

    [Test]
    procedure Posting_EarlierRefundFollowedByALaterCancel_CreditsTheShippedUnit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of three units of a line ordered four times, one shipped, is credited for the shipped unit even when a later refund cancels the last unshipped unit.
        // [GIVEN] A legacy-path store with a refund item charge and an order line ordered four times, one unit shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301084', '2301784', 1, 125, ShipmentNo);

        // [GIVEN] A queued refund of three units without restock for 300, and a later refund cancelling the fourth unit
        _Lib.InsertRefundQueueRow(StoreCode, '2301985', '2301084', '#2301084', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2301985', _Lib.RefundDetailResponse('2301985', '2301084', '#2301084', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2301784', Sku, 3, 4, 'NO_RESTOCK', '', 300, 60, 25), '', '', _ReturnLib.RefundTxnJson('2301884', 'bogus', 300, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2301986', _Lib.RefundDetailResponse('2301986', '2301084', '#2301084', '2026-09-10T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2301784', Sku, 1, 4, 'CANCEL', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301885', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301084', _Lib.RefundListItemJson('2301985', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2301986', '2026-09-10T10:00:00Z', '')));

        // [WHEN] The import of the earlier refund runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The shipped unit is credited for 100
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301985');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The shipped unit is owed, so the refund is imported.');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The later cancel takes its own unit; the shipped unit is credited.');
    end;

    /// <summary>
    /// Shopify's createdAt is a UTC instant; the expected value must be the same instant, not a local wall-clock time.
    /// </summary>
    local procedure UtcDateTime(IsoText: Text) Result: DateTime
    begin
        Evaluate(Result, IsoText, 9);
    end;

    [Test]
    procedure Import_RefundOfAnOrderInvoicedFromItsShipment_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order Business Central invoiced from its posted shipment, on an invoice that carries no Shopify stamps, is refused for manual handling instead of being taken for an order Business Central never invoiced.
        // [GIVEN] A legacy-path store and an order shipped, then invoiced from its shipment on a separate Sales Invoice, its Sales Order left with nothing to post
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrderShippedOnly(StoreCode, CustomerNo, Sku, LocationCode, '2309071', '2309771', SalesHeader);
        _Lib.InvoiceShipmentsOfOrder(CustomerNo, SalesHeader."No.");

        // [GIVEN] A queued refund of that unit
        _Lib.InsertRefundQueueRow(StoreCode, '2309971', '2309071', '#2309071', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2309971', '2309071', '#2309071', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2309771', Sku, 1, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2309871', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2309071', _Lib.RefundListItemJson('2309971', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The refund is refused naming the order, never ends as nothing to credit, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'An order invoiced outside its Sales Order must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#2309071') > 0, 'The refusal must name the order: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'CheckInvoicedThroughOrder') > 0, 'The refusal must come from the invoicing check: ' + GetLastErrorCallStack());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2309971');
        _Assert.AreNotEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'The refund must not end as nothing to credit.');
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_RefundOfACancelledUnfulfilledUnit_HasNothingToCredit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund cancelling a unit Business Central never invoiced (Shopify order #1135) ends with nothing to credit, naming the order, and builds nothing.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301065', '2301765', 1, 10, ShipmentNo);

        // [GIVEN] A queued refund cancelling the other unit
        _Lib.InsertRefundQueueRow(StoreCode, '2301965', '2301065', '#2301065', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301965', '2301065', '#2301065', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2301765', Sku, 1, 2, 'CANCEL', '71001', 10, 0, 0), '', '', _ReturnLib.RefundTxnJson('2301865', 'bogus', 10, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301065', _Lib.RefundListItemJson('2301965', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row has nothing to credit, its note names the order, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Nothing to credit is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301965');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'Nothing is owed.');
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", 'order #2301065') > 0, 'The note must name the order: ' + QueueRow."Outcome Note");
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_RefundWithoutRestockOfAnUnfulfilledUnit_HasNothingToCredit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund without restock of a unit Business Central never invoiced ends with nothing to credit, as a cancel does.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301066', '2301766', 1, 10, ShipmentNo);

        // [GIVEN] A queued refund of the other unit without restock
        _Lib.InsertRefundQueueRow(StoreCode, '2301966', '2301066', '#2301066', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301966', '2301066', '#2301066', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2301766', Sku, 1, 2, 'NO_RESTOCK', '', 10, 2, 25), '', '', _ReturnLib.RefundTxnJson('2301866', 'bogus', 10, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301066', _Lib.RefundListItemJson('2301966', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row has nothing to credit and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Nothing to credit is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301966');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'Nothing is owed.');
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_MixedRefund_CreditsTheShippedLineAndKeepsTheCancelledLineOut()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PaymentLine: Record "NPR Magento Payment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] One refund of a shipped line and a cancelled unshipped line credits the shipped line only, and pays out only its money.
        // [GIVEN] A legacy-path store with a refund item charge and an order whose line A is invoiced and whose line B never reached an invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301067', '2301767', 1, 125, ShipmentNo);

        // [GIVEN] A queued refund of line A without restock for 100 and line B cancelled for 50, 150 refunded
        _Lib.InsertRefundQueueRow(StoreCode, '2301967', '2301067', '#2301067', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301967', '2301067', '#2301067', _Lib.RefundTimeAfterNow(), true,
            _Lib.RefundLineJson('2301767', Sku, 1, 'NO_RESTOCK', '', 100, 20, 25) + ',' + _Lib.RefundLineJson('2301797', Sku, 1, 'CANCEL', '71001', 50, 10, 25),
            '', '', _ReturnLib.RefundTxnJson('2301867', 'bogus', 150, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301067', _Lib.RefundListItemJson('2301967', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo is 100 and 100 is paid out
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301967');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'Only the shipped line is credited.');
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.CalcSums(Amount);
        _Assert.AreEqual(100, PaymentLine.Amount, 'The cancelled line''s money was never received and is not paid out.');
    end;

    [Test]
    procedure Posting_TwoRefundsOfOneLine_TheEarlierTakesTheDroppedUnit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When an earlier refund already took the unit the order import left out, a later refund of the same line is credited in full.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301068', '2301768', 1, 100, ShipmentNo);

        // [GIVEN] An earlier refund of one unit without restock and a queued later refund restocking one unit for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2301982', '2301068', '#2301068', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2301968', _Lib.RefundDetailResponse('2301968', '2301068', '#2301068', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2301768', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301868', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2301982', _Lib.RefundDetailResponse('2301982', '2301068', '#2301068', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2301768', Sku, 1, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301869', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301068', _Lib.RefundListItemJson('2301968', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2301982', '2026-10-01T10:00:00Z', '')));

        // [WHEN] The import of the later refund runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The later refund is credited for 100
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301982');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The later refund is credited in full.');
    end;

    [Test]
    procedure Posting_OneLineCancelledAndKeptInOneRefund_CreditsTheKeptUnit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] One refund cancelling an unshipped unit and refunding a shipped unit of the same line without restock credits the shipped unit only.
        // [GIVEN] A legacy-path store with a refund item charge and an order line ordered three times, two units shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301070', '2301770', 2, 50, ShipmentNo);

        // [GIVEN] A queued refund with a NO_RESTOCK line and then a CANCEL line of that line item, 50 each, so line order alone would drop the kept unit
        _Lib.InsertRefundQueueRow(StoreCode, '2301970', '2301070', '#2301070', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301970', '2301070', '#2301070', _Lib.RefundTimeAfterNow(), true,
            _Lib.RefundLineJsonOrdered('2301770', Sku, 1, 3, 'NO_RESTOCK', '', 50, 10, 25) + ',' + _Lib.RefundLineJsonOrdered('2301770', Sku, 1, 3, 'CANCEL', '71001', 50, 10, 25),
            '', '', _ReturnLib.RefundTxnJson('2301870', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301070', _Lib.RefundListItemJson('2301970', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] Only the shipped unit is credited, for 50
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301970');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(50, SalesCrMemoHeader."Amount Including VAT", 'The cancel takes the uninvoiced unit; the kept unit is credited.');
    end;

    [Test]
    procedure Posting_DroppedThirdOfALine_KeepsTheTotalCheckExact()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When one of three refunded units was never invoiced, its third of the refunded gross is left out with rounding that keeps the exact total check passing.
        // [GIVEN] A legacy-path store and an order line ordered three times, two units shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301071', '2301771', 2, 50, ShipmentNo);

        // [GIVEN] A queued refund restocking all three units for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2301971', '2301071', '#2301071', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301971', '2301071', '#2301071', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2301771', Sku, 3, 3, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301871', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301071', _Lib.RefundListItemJson('2301971', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] Two units are credited for 66.67
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301971');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(66.67, SalesCrMemoHeader."Amount Including VAT", 'Two thirds of 100 are credited.');
    end;

    [Test]
    procedure Import_DeductionReachingAGiftCardShare_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Money Business Central never received cannot come off a refund paid back to a gift card, so the refund is refused for manual handling.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301069', '2301769', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund restocking both units for 200, all of it to a gift card
        _Lib.InsertRefundQueueRow(StoreCode, '2301969', '2301069', '#2301069', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301969', '2301069', '#2301069', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2301769', Sku, 2, 2, 'RETURN', '71001', 200, 40, 25), '', '', _ReturnLib.RefundTxnJson('2301872', 'gift_card', 200, _ReturnLib.Lcy(), '555')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301069', _Lib.RefundListItemJson('2301969', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the refund, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'A deduction from a gift card share must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'refund 2301969 of order #2301069') > 0, 'The error must name the refund: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'never received') > 0, 'The error must say the money was never received: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_RefundOfAnOrderNotInBusinessCentralYet_Waits()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order with neither a Sales Order nor an invoice in Business Central yet waits for the order to be imported and invoiced, naming the order, instead of failing until its retries run out.
        // [GIVEN] A legacy-path store and a queued amount-only refund of an order Business Central has not imported
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2301972', '2301072', '#2301072', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301972', '2301072', '#2301072', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301873', 'bogus', 30, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301072', _Lib.RefundListItemJson('2301972', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row waits with a note naming the order, no retry is used, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Waiting is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301972');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'A refund of an order not in Business Central yet waits.');
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", '#2301072') > 0, 'The note must name the order: ' + QueueRow."Outcome Note");
        _Assert.AreEqual(0, QueueRow."Retry Count", 'Waiting costs no retry.');
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_FullRefundBeforeTheInvoiceWasPaid_ClearsTheInvoiceWithoutPayingOut()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentLine: Record "NPR Magento Payment Line";
        ShopifyStore: Record "NPR Spfy Store";
        GLEntry: Record "G/L Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When the whole order was refunded before Business Central posted it, the invoice posted unpaid; the credit memo clears that invoice and pays nothing out.
        // [GIVEN] A legacy-path store and an order of two units at 50, invoiced without a payment
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2301073', '2301773', 2, 50, ShipmentNo);

        // [GIVEN] A queued refund restocking both units for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2301973', '2301073', '#2301073', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301973', '2301073', '#2301073', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301773', Sku, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301874', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301073', _Lib.RefundListItemJson('2301973', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo carries no payment line, both ledger entries are closed and nothing was paid out
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301973');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.IsTrue(PaymentLine.IsEmpty(), 'Nothing is paid out.');
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        CustLedgerEntry.FindFirst();
        _Assert.IsFalse(CustLedgerEntry.Open, 'The unpaid invoice is cleared.');
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        _Assert.IsFalse(CustLedgerEntry.Open, 'The credit memo is fully applied.');
        ShopifyStore.Get(StoreCode);
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.IsTrue(GLEntry.IsEmpty(), 'No customer refund is posted.');
    end;

    [Test]
    procedure Posting_CreditMemoAppliedToAnotherInvoiceByApplyToOldest_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Customer: Record Customer;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        OtherInvoiceNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of a paid order is refused when Business Central applies its credit memo to another open invoice of the customer (Application Method Apply to Oldest): settling only what the application left would pay nothing out and close an unrelated invoice.
        // [GIVEN] A legacy-path store whose customer applies by Apply to Oldest, a paid order of two units at 50, and another order of the customer invoiced unpaid
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        Customer.Get(CustomerNo);
        Customer.Validate("Application Method", Customer."Application Method"::"Apply to Oldest");
        Customer.Modify(true);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301097', '2301796', 2, 50, ShipmentNo);
        OtherInvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2301098', '2301896', 2, 50, ShipmentNo);

        // [GIVEN] A queued refund of the paid order restocking both units for 100, paid back to the card
        _Lib.InsertRefundQueueRow(StoreCode, '2301997', '2301097', '#2301097', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301997', '2301097', '#2301097', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301796', Sku, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301897', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301097', _Lib.RefundListItemJson('2301997', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The posting is refused naming the refund and the application method
        _Assert.IsFalse(Succeeded, 'A credit memo applied where the import did not plan it must not settle.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), '2301997') > 0, 'The error must name the refund: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), Customer.FieldCaption("Application Method")) > 0, 'The error must name the application method: ' + GetLastErrorText());
        // [THEN] No credit memo is posted and the other order's invoice stays open
        SalesCrMemoHeader.SetRange("Bill-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesCrMemoHeader.IsEmpty(), 'No credit memo may be posted.');
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", OtherInvoiceNo);
        CustLedgerEntry.FindFirst();
        _Assert.IsTrue(CustLedgerEntry.Open, 'The other order''s invoice must stay open.');
    end;

    [Test]
    procedure Posting_RefundPartlyAgainstAnUnpaidInvoice_AppliesItAndPaysTheRest()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ShopifyStore: Record "NPR Spfy Store";
        GLEntry: Record "G/L Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        InvoiceNos: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order shipped in two parcels, the first invoice paid and the second not, settles the unpaid invoice and pays out the rest.
        // [GIVEN] A legacy-path store and a two-unit line invoiced in two parts at 50, only the first invoice paid
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrderInTwoPartsUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2301075', '2301775', 50, InvoiceNos);
        _Lib.PayInvoice(StoreCode, InvoiceNos.Get(1));

        // [GIVEN] A queued refund restocking both units for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2301975', '2301075', '#2301075', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301975', '2301075', '#2301075', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301775', Sku, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301875', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301075', _Lib.RefundListItemJson('2301975', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The second invoice is cleared and 50 is paid out
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNos.Get(2));
        CustLedgerEntry.FindFirst();
        _Assert.IsFalse(CustLedgerEntry.Open, 'The unpaid invoice is cleared.');
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301975');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        ShopifyStore.Get(StoreCode);
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(50, Abs(GLEntry.Amount), 'The rest is paid out.');
    end;

    [Test]
    procedure Import_RefundOfAnOrderWithTwoUnpaidInvoices_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        InvoiceNos: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A credit memo can be applied to one open invoice only, so a refund of an order with two unpaid invoices is refused naming them.
        // [GIVEN] A legacy-path store and a two-unit line invoiced in two parts, neither paid
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrderInTwoPartsUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2301074', '2301774', 50, InvoiceNos);

        // [GIVEN] A queued refund restocking both units for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2301974', '2301074', '#2301074', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301974', '2301074', '#2301074', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301774', Sku, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301876', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301074', _Lib.RefundListItemJson('2301974', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming both invoices, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'Two open invoices must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), InvoiceNos.Get(1)) > 0, 'The error must name the first invoice: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), InvoiceNos.Get(2)) > 0, 'The error must name the second invoice: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Build_ReturnAgainstAnUnpaidInvoice_IsAppliedToIt()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] A return of an order whose invoice is still unpaid is applied to that invoice and pays nothing out, as a refund is.
        // [GIVEN] A legacy-path store and an order of one unit at 125, invoiced without a payment
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2301076', '2301776', 1, 125, ShipmentNo);

        // [WHEN] A return of that unit, refunded 100, is built
        _Lib.BuildReturnOrderWithoutQueue(StoreCode, _ReturnLib.ReturnDetailResponse('2301976', '2301076', '#2301076', Sku, '2301776', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2301877', 'bogus', 100, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), '2301976', SalesHeader);

        // [THEN] The Return Order applies to the invoice and carries no payment line
        _Assert.AreEqual(InvoiceNo, SalesHeader."Applies-to Doc. No.", 'The return is applied to the unpaid invoice.');
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        _Assert.IsTrue(PaymentLine.IsEmpty(), 'Nothing is paid out.');
    end;

    [Test]
    procedure Posting_AppliedCreditMemoRaisedByHand_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySales: Codeunit "Library - Sales";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        PostAutomatically: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A credit memo applied to an unpaid invoice and then raised by hand above the refund is still refused at posting.
        // [GIVEN] A legacy-path store that does not post returns automatically, and an order of two units at 50 invoiced without a payment
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2301077', '2301777', 2, 50, ShipmentNo);

        // [GIVEN] A draft for a refund of both units for 100, raised by a G/L line of 20 typed in by hand
        _Lib.InsertRefundQueueRow(StoreCode, '2301977', '2301077', '#2301077', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301977', '2301077', '#2301077', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301777', Sku, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301878', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301077', _Lib.RefundListItemJson('2301977', '2026-09-20T10:00:00Z', '')));
        _ReturnLib.RunImport(QueueRow, MockClient);
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301977');
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"G/L Account", ShopifyStore."Return Refund G/L Account No.", 1);
        SalesLine.Validate("Unit Price", 20);
        SalesLine.Modify(true);

        // [WHEN] The draft is posted
        Succeeded := _Lib.PostReturnOrder(SalesHeader);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();

        // [THEN] It is refused naming the refund
        _Assert.IsFalse(Succeeded, 'A credit memo raised above the refund must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'refund 2301977 of order #2301077') > 0, 'The error must name the refund: ' + GetLastErrorText());
    end;

    [Test]
    procedure Import_ReusedDraftAppliedToAnOpenInvoice_PassesItsCheck()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        DraftNo: Code[20];
        PostAutomatically: Boolean;
        FirstRunSucceeded: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A draft that pays out less than its total because part of it settles an unpaid invoice still passes the check when the row is processed again.
        // [GIVEN] A legacy-path store that does not post returns automatically, an order of two units at 50 invoiced without a payment, and the refund's draft already built
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2301078', '2301778', 2, 50, ShipmentNo);
        _Lib.InsertRefundQueueRow(StoreCode, '2301978', '2301078', '#2301078', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301978', '2301078', '#2301078', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2301778', Sku, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301879', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301078', _Lib.RefundListItemJson('2301978', '2026-09-20T10:00:00Z', '')));
        FirstRunSucceeded := _ReturnLib.RunImport(QueueRow, MockClient);
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301978');
        DraftNo := QueueRow."Sales Header Doc. No.";

        // [WHEN] The import runs again on the row with its draft
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The first run built the draft and the second reused it without asking Shopify again, and passed its check
        _Assert.IsTrue(FirstRunSucceeded, 'Precondition: the first run builds the draft: ' + GetLastErrorText());
        _Assert.AreNotEqual('', DraftNo, 'Precondition: the row records its draft.');
        _Assert.IsTrue(Succeeded, 'The applied amount counts towards the refund: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301978');
        _Assert.AreEqual(DraftNo, QueueRow."Sales Header Doc. No.", 'The second run keeps the same draft.');
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('GetRefund'), 'A reused draft is checked without fetching the refund again.');
    end;

    local procedure ParseTruncatedRefund(Connection: Text; RefundId: Text[30]; OrderId: Text)
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        DetailJson: Text;
    begin
        DetailJson := _Lib.RefundDetailResponse(RefundId, OrderId, '#' + OrderId, '2026-09-20T10:00:00Z', true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2301880', 'bogus', 30, _ReturnLib.Lcy(), ''));
        Response.ReadFrom(DetailJson.Replace('"' + Connection + '":{"pageInfo":{"hasNextPage":false}', '"' + Connection + '":{"pageInfo":{"hasNextPage":true}'));
        SpfyLegacyReturnAPI.ParseRefundDetail('', RefundId, Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
    end;

    [Test]
    procedure RefundApi_ParseDetail_TruncatedLines_IsRefused()
    begin
        // [SCENARIO] A refund whose line items do not fit one page is refused, since its amounts cannot be calculated reliably.
        // [GIVEN] Refund detail whose refundLineItems has another page
        // [WHEN] The detail is parsed
        asserterror ParseTruncatedRefund('refundLineItems', '2301980', '2301080');
        // [THEN] It is refused naming the connection
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'refundLineItems') > 0, 'The error must name the connection: ' + GetLastErrorText());
    end;

    [Test]
    procedure RefundApi_ParseDetail_TruncatedShippingLines_IsRefused()
    begin
        // [SCENARIO] A refund whose refunded shipping lines do not fit one page is refused, since its amounts cannot be calculated reliably.
        // [GIVEN] Refund detail whose refundShippingLines has another page
        // [WHEN] The detail is parsed
        asserterror ParseTruncatedRefund('refundShippingLines', '2301981', '2301081');
        // [THEN] It is refused naming the connection
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'refundShippingLines') > 0, 'The error must name the connection: ' + GetLastErrorText());
    end;

    [Test]
    procedure RefundApi_ParseDetail_TruncatedAdjustments_IsRefused()
    begin
        // [SCENARIO] A refund whose order adjustments do not fit one page is refused, since its amounts cannot be calculated reliably.
        // [GIVEN] Refund detail whose orderAdjustments has another page
        // [WHEN] The detail is parsed
        asserterror ParseTruncatedRefund('orderAdjustments', '2301983', '2301082');
        // [THEN] It is refused naming the connection
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'orderAdjustments') > 0, 'The error must name the connection: ' + GetLastErrorText());
    end;

    [Test]
    procedure RefundApi_ParseDetail_TruncatedTransactions_IsRefused()
    begin
        // [SCENARIO] A refund whose transactions do not fit one page is refused, since its amounts cannot be calculated reliably.
        // [GIVEN] Refund detail whose transactions has another page
        // [WHEN] The detail is parsed
        asserterror ParseTruncatedRefund('transactions', '2301984', '2301083');
        // [THEN] It is refused naming the connection
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'transactions') > 0, 'The error must name the connection: ' + GetLastErrorText());
    end;

    [Test]
    procedure Posting_RefundCreditMemo_IsDatedOnTheRefundsProcessedDate()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        ProcessedOn: Date;
        Succeeded: Boolean;
    begin
        // [SCENARIO] The credit memo of a refund is dated on the day Shopify processed the refund, not on the work date.
        // [GIVEN] A legacy-path store and an order of one unit at 125, shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2301079', '2301779', 1, 125, ShipmentNo);

        // [GIVEN] A queued refund restocking it for 100, processed the day after the work date
        ProcessedOn := WorkDate() + 1;
        _Lib.InsertRefundQueueRow(StoreCode, '2301979', '2301079', '#2301079', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2301979', '2301079', '#2301079', Format(CreateDateTime(ProcessedOn, 120000T), 0, 9), true, _Lib.RefundLineJson('2301779', Sku, 1, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2301881', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2301079', _Lib.RefundListItemJson('2301979', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo is dated on the processed day
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2301979');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        _Assert.AreEqual(ProcessedOn, SalesCrMemoHeader."Posting Date", 'The credit memo is dated on the processed day.');
    end;

    [Test]
    procedure ProcessJQ_WaitingRefundThatFailsOnceItsOrderIsGone_LosesItsWaitingNote()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShopifyUrl: Text[250];
    begin
        // [SCENARIO] A refund that waited for its order and then fails keeps only its error, not the note saying it waits.
        // [GIVEN] A legacy-path store that cannot reach Shopify (blank Shopify Url)
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        ShopifyUrl := ShopifyStore."Shopify Url";
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();

        // [GIVEN] A waiting refund row with its waiting note, whose order has no Sales Order any more
        _Lib.InsertRefundQueueRow(StoreCode, '2302410', '2302210', '#2302210', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Business Central has invoiced Shopify order #2302210.';
        QueueRow.Modify();
        Commit();

        // [WHEN] The row is processed
        SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);
        Commit();

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Shopify Url" := ShopifyUrl;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The row is at Error with its error and without the waiting note
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302410');
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'The failed attempt ends at Error.');
        _Assert.AreNotEqual('', QueueRow."Last Error", 'The row keeps its error.');
        _Assert.AreEqual('', QueueRow."Outcome Note", 'A row that no longer waits carries no waiting note.');
    end;

    [Test]
    procedure QueuePage_DiscardDraftAndRetryOnAWaitingRow_ClearsItsNote()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Queuing a waiting refund again from the start clears the note that said it waits.
        // [GIVEN] A legacy-path store and a waiting refund row with its waiting note
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2302411', '2302211', '#2302211', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Business Central has invoiced Shopify order #2302211.';
        QueueRow.Modify();

        // [WHEN] Discard Draft and Retry is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        QueuePage.DiscardDraftAndRetry.Invoke();
        QueuePage.Close();

        // [THEN] The row is New and carries no note
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302411');
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'The row is queued again.');
        _Assert.AreEqual('', QueueRow."Outcome Note", 'A row queued again carries no waiting note.');
    end;

    [Test]
    procedure QueuePage_DiscardDraftAndRetryOnANothingToCreditRow_QueuesItAgain()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A refund that ended with nothing to credit is queued again from the start by Discard Draft and Retry, without its old note, so it can be measured anew.
        // [GIVEN] A legacy-path store and a Nothing to Credit refund row with its note
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2302413', '2302213', '#2302213', QueueRow);
        QueueRow.Status := QueueRow.Status::"Nothing to Credit";
        QueueRow."Outcome Note" := 'Every unit Shopify refund 2302413 of order #2302213 refunds was left off the invoices of order #2302213.';
        QueueRow.Modify();

        // [WHEN] Discard Draft and Retry is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        QueuePage.DiscardDraftAndRetry.Invoke();
        QueuePage.Close();

        // [THEN] The row is New with no retries and no note
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302413');
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'The row is queued again.');
        _Assert.AreEqual(0, QueueRow."Retry Count", 'A row queued again starts with no retries.');
        _Assert.AreEqual('', QueueRow."Outcome Note", 'A row queued again carries no outcome note.');
    end;

    [Test]
    procedure Import_WithheldAmountLargerThanWhatIsLeftToCredit_IsRefusedWithItsOwnMessage()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund whose withheld amount exceeds what is left to credit once the units Business Central never invoiced are left out is refused for manual handling, with a message that says so.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced at 50
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302201', '2302301', 1, 50, ShipmentNo);

        // [GIVEN] A queued refund restocking both units for 100 with 60 withheld, so 40 is refunded
        _Lib.InsertRefundQueueRow(StoreCode, '2302401', '2302201', '#2302201', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302401', '2302201', '#2302201', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302301', Sku, 2, 2, 'RETURN', '71001', 100, 20, 25), '', _ReturnLib.OrderAdjustmentJson(60, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2302501', 'bogus', 40, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302201', _Lib.RefundListItemJson('2302401', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the refund and the withheld amount, not as a gift card deduction, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'Nothing positive is left to credit, so the refund must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'refund 2302401 of order #2302201') > 0, 'The error must name the refund: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'withheld') > 0, 'The error must name the withheld amount: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'gift card') = 0, 'The error must not blame a gift card: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure RefundApi_EarlierRefundTheImportCouldNotBuild_StillGivesItsLines()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempEarlierLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        EarlierDetail: Text;
    begin
        // [SCENARIO] An earlier refund that could not be imported itself, with a line that has no order line and more transactions than one request reads, still gives its line items to a later refund.
        // [GIVEN] A legacy-path store and an earlier refund cancelling one unit, with a line without an order line and truncated transactions
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        EarlierDetail := _Lib.RefundDetailResponse('2302403', '2302203', '#2302203', '2026-09-01T10:00:00Z', true,
            _Lib.RefundLineJsonOrdered('2302303', Sku, 1, 2, 'CANCEL', '71001', 50, 10, 25) + ',' + LineWithoutOrderLineJson(),
            '', '', _ReturnLib.RefundTxnJson('2302503', 'bogus', 55, _ReturnLib.Lcy(), ''));
        EarlierDetail := EarlierDetail.Replace('"transactions":{"pageInfo":{"hasNextPage":false}', '"transactions":{"pageInfo":{"hasNextPage":true}');
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302403', EarlierDetail);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302404', _Lib.RefundDetailResponse('2302404', '2302203', '#2302203', '2026-09-20T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302303', Sku, 1, 2, 'NO_RESTOCK', '', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2302504', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302203', _Lib.RefundListItemJson('2302403', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302404', '2026-09-20T10:00:00Z', '')));
        SpfyLegacyReturnAPI.SetGraphQLClient(MockClient);

        // [WHEN] The later refund's detail is read
        SpfyLegacyReturnAPI.GetRefundDetail(StoreCode, '2302404', TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
        SpfyLegacyReturnAPI.GetOtherRefundLines(StoreCode, '2302404', TempReturnBuffer, TempEarlierLineBuffer);

        // [THEN] The earlier refund's CANCEL line is in the earlier buffer and its line without an order line is not
        _Assert.AreEqual(1, TempEarlierLineBuffer.Count(), 'One earlier refund line of an order line.');
        TempEarlierLineBuffer.FindFirst();
        _Assert.AreEqual('CANCEL', TempEarlierLineBuffer."Restock Type", 'The earlier line keeps its restock type.');
        _Assert.AreEqual('2302303', TempEarlierLineBuffer."Order Line Item Id", 'The earlier line keeps its order line.');
    end;

    [Test]
    procedure Import_EarlierRefundTooLongToRead_IsIgnoredWhenNoUnitWasLeftOff()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] An earlier refund with more line items than one request reads does not block a later refund of an order whose units were all invoiced.
        // [GIVEN] A legacy-path store and an order of one unit at 100, shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302205', '2302305', 1, 100, ShipmentNo);

        // [GIVEN] An earlier refund whose line items do not fit one request, and a queued refund restocking the unit for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2302406', '2302205', '#2302205', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302405', TruncatedLines(_Lib.RefundDetailResponse('2302405', '2302205', '#2302205', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJson('2302399', Sku, 1, 'CANCEL', '71001', 10, 2, 25), '', '', _ReturnLib.RefundTxnJson('2302505', 'bogus', 10, _ReturnLib.Lcy(), ''))));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302406', _Lib.RefundDetailResponse('2302406', '2302205', '#2302205', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2302305', Sku, 1, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302506', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302205', _Lib.RefundListItemJson('2302405', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302406', '2026-10-01T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The refund is credited for 100
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302406');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The refund is credited in full.');
    end;

    [Test]
    procedure Import_EarlierRefundTooLongToRead_IsRefusedWhenUnitsWereLeftOff()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When units were left off the invoices and an earlier refund has more line items than one request reads, the allocation cannot be trusted and the refund is refused for manual handling.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302206', '2302306', 1, 100, ShipmentNo);

        // [GIVEN] An earlier refund whose line items do not fit one request, and a queued refund restocking both units for 200
        _Lib.InsertRefundQueueRow(StoreCode, '2302408', '2302206', '#2302206', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302407', TruncatedLines(_Lib.RefundDetailResponse('2302407', '2302206', '#2302206', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJson('2302398', Sku, 1, 'CANCEL', '71001', 10, 2, 25), '', '', _ReturnLib.RefundTxnJson('2302507', 'bogus', 10, _ReturnLib.Lcy(), ''))));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302408', _Lib.RefundDetailResponse('2302408', '2302206', '#2302206', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302306', Sku, 2, 2, 'RETURN', '71001', 200, 40, 25), '', '', _ReturnLib.RefundTxnJson('2302508', 'bogus', 200, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302206', _Lib.RefundListItemJson('2302407', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302408', '2026-10-01T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the refund and the unreadable refunds, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'An allocation over refunds that could not all be read must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'refund 2302408 of order #2302206') > 0, 'The error must name the refund: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'could not be read in full') > 0, 'The error must say the other refunds could not be read: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_RefundOfAnOrderWithAnUnpaidInvoiceOfAnotherCustomer_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Customer: Record Customer;
        OtherCustomer: Record Customer;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order whose unpaid invoice is posted to another customer than the refund resolves to is refused, instead of paying out while the invoice stays open.
        // [GIVEN] A legacy-path store and an order of one unit at 100, invoiced without a payment to another customer than the store's
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        Customer.Get(CustomerNo);
        OtherCustomer := Customer;
        OtherCustomer."No." := '';
        OtherCustomer.Insert(true);
        OtherCustomer.TransferFields(Customer, false);
        OtherCustomer.Modify();
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, OtherCustomer."No.", Sku, LocationCode, '2302207', '2302307', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund restocking the unit for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2302409', '2302207', '#2302207', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302409', '2302207', '#2302207', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2302307', Sku, 1, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302509', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302207', _Lib.RefundListItemJson('2302409', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the invoice and its customer, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'A refund must not pay out while the order''s invoice is open under another customer.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), InvoiceNo) > 0, 'The error must name the invoice: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), OtherCustomer."No.") > 0, 'The error must name the invoice''s customer: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_ReturnAgainstAnUnpaidInvoice_SettlesItWithoutPayingOut()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        ShopifyStore: Record "NPR Spfy Store";
        GLEntry: Record "G/L Entry";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
        ReturnOrderNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return of an order whose invoice is still unpaid posts against that invoice, lowering what is owed on it by the refund and paying nothing out.
        // [GIVEN] A legacy-path store and an order of one unit at 125, invoiced without a payment
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2302208', '2302308', 1, 125, ShipmentNo);

        // [GIVEN] The Return Order of a return of that unit refunded 100
        _Lib.BuildReturnOrderWithoutQueue(StoreCode, _ReturnLib.ReturnDetailResponse('2302412', '2302208', '#2302208', Sku, '2302308', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2302512', 'bogus', 100, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), '2302412', SalesHeader);
        ReturnOrderNo := SalesHeader."No.";

        // [WHEN] The Return Order is posted
        Succeeded := _Lib.PostReturnOrder(SalesHeader);

        // [THEN] The invoice still owes 25 and nothing was paid out
        _Assert.IsTrue(Succeeded, 'Posting must succeed: ' + GetLastErrorText());
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(25, CustLedgerEntry."Remaining Amount", 'The return lowers the unpaid invoice by the refund.');
        _ReturnLib.GetCreditMemoForReturnOrder(ReturnOrderNo, SalesCrMemoHeader);
        ShopifyStore.Get(StoreCode);
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(0, GLEntry.Amount, 'Nothing is paid out.');
    end;

    [Test]
    procedure Import_UnitLeftOffInACurrencyWithoutDecimals_KeepsTheTotalCheckExact()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        GLSetup: Record "General Ledger Setup";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        AmountRoundingPrecision: Decimal;
        PostAutomatically: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] When one unit of three is left off the invoices in a currency without decimals, the money left out is rounded like the document's lines, so the total check still matches.
        // [GIVEN] A legacy-path store that posts by hand, and an order line ordered three times, two units shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302214', '2302314', 2, 300, ShipmentNo);

        // [GIVEN] A local currency rounded to whole units
        GLSetup.Get();
        AmountRoundingPrecision := GLSetup."Amount Rounding Precision";
        GLSetup."Amount Rounding Precision" := 1;
        GLSetup.Modify();

        // [GIVEN] A queued refund restocking all three units for 1000
        _Lib.InsertRefundQueueRow(StoreCode, '2302414', '2302214', '#2302214', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302414', '2302214', '#2302214', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302314', Sku, 3, 3, 'RETURN', '71001', 1000, 200, 25), '', '', _ReturnLib.RefundTxnJson('2302514', 'bogus', 1000, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302214', _Lib.RefundListItemJson('2302414', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed setup and store before asserting.
        GLSetup.Get();
        GLSetup."Amount Rounding Precision" := AmountRoundingPrecision;
        GLSetup.Modify();
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The draft is built for the two invoiced units at 667, the refund less the 333 left out
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302414');
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(667, SalesHeader."Amount Including VAT", 'The two invoiced units are credited at the refund less the rounded unit left out.');
    end;

    [Test]
    procedure Import_RefundWhileAnotherDraftSettlesTheSameUnpaidInvoice_Waits()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SecondQueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        FirstDraftNo: Code[20];
        RequestsBefore: Integer;
        PostAutomatically: Boolean;
        FirstBuilt: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order whose unpaid invoice an unposted draft already settles waits for that draft, since Business Central applies a credit memo's whole amount when it posts.
        // [GIVEN] A legacy-path store that posts by hand, and an order of two units at 50 invoiced without a payment
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2302215', '2302315', 2, 50, ShipmentNo);

        // [GIVEN] A first refund restocking one unit and the shipping for 80, built as a draft applied to the invoice, and a queued second refund of the other unit for 50
        _Lib.InsertRefundQueueRow(StoreCode, '2302415', '2302215', '#2302215', QueueRow);
        _Lib.InsertRefundQueueRow(StoreCode, '2302416', '2302215', '#2302215', SecondQueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302415', _Lib.RefundDetailResponse('2302415', '2302215', '#2302215', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302315', Sku, 1, 2, 'RETURN', '71001', 50, 10, 25), _ReturnLib.RefundShippingLineJson(24, 6), '', _ReturnLib.RefundTxnJson('2302515', 'bogus', 80, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302416', _Lib.RefundDetailResponse('2302416', '2302215', '#2302215', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302315', Sku, 1, 2, 'RETURN', '71001', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2302516', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302215', _Lib.RefundListItemJson('2302415', '2026-09-20T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302416', '2026-09-20T10:00:00Z', '')));
        FirstBuilt := _ReturnLib.RunImport(QueueRow, MockClient);
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302415');
        FirstDraftNo := QueueRow."Sales Header Doc. No.";
        RequestsBefore := MockClient.CountRequestsContaining('gid://shopify/Refund/2302416');

        // [WHEN] The second refund is imported
        Succeeded := _ReturnLib.RunImport(SecondQueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The second refund waits for the first draft, naming it, and builds nothing
        _Assert.IsTrue(FirstBuilt, 'Precondition: the first draft builds: ' + GetLastErrorText());
        _Assert.AreNotEqual('', FirstDraftNo, 'Precondition: the first row records its draft.');
        _Assert.IsTrue(Succeeded, 'Waiting is not an error: ' + GetLastErrorText());
        SecondQueueRow.FindSourceDoc(StoreCode, SecondQueueRow."Source Doc. Type"::Refund, '2302416');
        _Assert.AreEqual(SecondQueueRow.Status::Waiting, SecondQueueRow.Status, 'The second refund waits.');
        _Assert.AreEqual('', SecondQueueRow."Sales Header Doc. No.", 'No second draft is built.');
        _Assert.IsTrue(StrPos(SecondQueueRow."Outcome Note", FirstDraftNo) > 0, 'The note names the draft it waits for: ' + SecondQueueRow."Outcome Note");
        _Assert.AreEqual(RequestsBefore, MockClient.CountRequestsContaining('gid://shopify/Refund/2302416'), 'A waiting refund makes no Shopify call.');
    end;

    [Test]
    procedure Posting_RefundAfterTheOtherDraftOnTheUnpaidInvoiceIsPosted_SettlesTheRest()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SecondQueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        FirstDraft: Record "Sales Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
        PostAutomatically: Boolean;
        FirstBuilt: Boolean;
        FirstPosted: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] Once the draft that settled part of an unpaid invoice is posted, the next refund of the order settles what is left of the invoice and pays out the rest.
        // [GIVEN] A legacy-path store that posts by hand, and an order of two units at 50 invoiced without a payment
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2302219', '2302319', 2, 50, ShipmentNo);

        // [GIVEN] A first refund restocking one unit and the shipping for 80, built and posted against the invoice
        _Lib.InsertRefundQueueRow(StoreCode, '2302422', '2302219', '#2302219', QueueRow);
        _Lib.InsertRefundQueueRow(StoreCode, '2302423', '2302219', '#2302219', SecondQueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302422', _Lib.RefundDetailResponse('2302422', '2302219', '#2302219', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302319', Sku, 1, 2, 'RETURN', '71001', 50, 10, 25), _ReturnLib.RefundShippingLineJson(24, 6), '', _ReturnLib.RefundTxnJson('2302522', 'bogus', 80, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302423', _Lib.RefundDetailResponse('2302423', '2302219', '#2302219', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302319', Sku, 1, 2, 'RETURN', '71001', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2302523', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302219', _Lib.RefundListItemJson('2302422', '2026-09-20T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302423', '2026-09-20T10:00:00Z', '')));
        FirstBuilt := _ReturnLib.RunImport(QueueRow, MockClient);
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302422');
        if FirstDraft.Get(FirstDraft."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.") then
            FirstPosted := _Lib.PostReturnOrder(FirstDraft);

        // [GIVEN] The store posts returns automatically again
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := true;
        ShopifyStore.Modify();

        // [WHEN] The second refund, restocking the other unit for 50, is imported
        Succeeded := _ReturnLib.RunImport(SecondQueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();

        // [THEN] It is imported and the invoice is settled
        _Assert.IsTrue(FirstBuilt, 'Precondition: the first draft builds: ' + GetLastErrorText());
        _Assert.IsTrue(FirstPosted, 'Precondition: the first draft posts.');
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        SecondQueueRow.FindSourceDoc(StoreCode, SecondQueueRow."Source Doc. Type"::Refund, '2302423');
        _Assert.AreEqual(SecondQueueRow.Status::Imported, SecondQueueRow.Status, 'The second refund is imported.');
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Document No.", InvoiceNo);
        CustLedgerEntry.FindFirst();
        _Assert.IsFalse(CustLedgerEntry.Open, 'The unpaid invoice is settled by the two refunds.');
    end;

    [Test]
    procedure Posting_UnitLeftOffInARefundOfAReturnedAndAKeptUnit_ReceivesTheReturnedUnit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When a refund returns one unit and lets the customer keep another of the same line, and one unit was never invoiced, the unit left out is the kept one, so the returned unit comes back into stock.
        // [GIVEN] A legacy-path store with a refund item charge and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302216', '2302316', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund with a restocked unit listed before a kept unit, 100 each
        _Lib.InsertRefundQueueRow(StoreCode, '2302417', '2302216', '#2302216', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302417', '2302216', '#2302216', _Lib.RefundTimeAfterNow(), true,
            _Lib.RefundLineJsonOrdered('2302316', Sku, 1, 2, 'RETURN', '71001', 100, 20, 25) + ',' + _Lib.RefundLineJsonOrdered('2302316', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25),
            '', '', _ReturnLib.RefundTxnJson('2302517', 'bogus', 200, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302216', _Lib.RefundListItemJson('2302417', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo receives the returned unit as an item line and charges nothing
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302417');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.CalcSums(Quantity);
        _Assert.AreEqual(1, SalesCrMemoLine.Quantity, 'The returned unit is received back.');
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"Charge (Item)");
        _Assert.IsTrue(SalesCrMemoLine.IsEmpty(), 'The kept unit was the one left off the invoices, so nothing is charged.');
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The invoiced unit is credited.');
    end;

    [Test]
    procedure Posting_ReturnedUnitWithALaterRefundOfAKeptUnit_ReceivesTheReturnedUnit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When a refund returns the shipped unit of a line and a later refund lets the customer keep the unit that never shipped, the unit left off the invoices is the later kept one, so the returned unit is received and credited.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302217', '2302317', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund restocking one unit for 100, and a later refund of the other unit without restock
        _Lib.InsertRefundQueueRow(StoreCode, '2302418', '2302217', '#2302217', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302418', _Lib.RefundDetailResponse('2302418', '2302217', '#2302217', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302317', Sku, 1, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302518', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302419', _Lib.RefundDetailResponse('2302419', '2302217', '#2302217', '2026-09-02T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302317', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302519', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302217', _Lib.RefundListItemJson('2302418', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302419', '2026-09-02T10:00:00Z', '')));

        // [WHEN] The import of the earlier refund runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The returned unit is received and credited for 100
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302418');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The returned unit is credited, so the row is imported.');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.CalcSums(Quantity);
        _Assert.AreEqual(1, SalesCrMemoLine.Quantity, 'The returned unit is received back.');
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The returned unit is credited.');
    end;

    [Test]
    procedure Import_KeptUnitRefundedAfterTheShippedUnitWasReturned_HasNothingToCredit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of a kept unit made after the shipped unit of the line was returned refunds the unit that never shipped, so there is nothing to credit.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302218', '2302318', 1, 100, ShipmentNo);

        // [GIVEN] An earlier refund restocking one unit, and a queued later refund of the other unit without restock for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2302421', '2302218', '#2302218', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302420', _Lib.RefundDetailResponse('2302420', '2302218', '#2302218', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302318', Sku, 1, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302520', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302421', _Lib.RefundDetailResponse('2302421', '2302218', '#2302218', '2026-09-02T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302318', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302521', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302218', _Lib.RefundListItemJson('2302420', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302421', '2026-09-02T10:00:00Z', '')));

        // [WHEN] The import of the later refund runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row has nothing to credit and no Return Order exists
        _Assert.IsTrue(Succeeded, 'The import must run: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302421');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'The kept unit never shipped, so nothing is owed for it.');
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_UnitLeftOffInARefundOfALegacyRestockedAndAKeptUnit_ReceivesTheRestockedUnit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Of a legacy-restocked and a kept unit of one line in one refund, the kept unit is the one left off the invoices, so the restocked unit is received.
        // [GIVEN] A legacy-path store with a refund item charge and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302220', '2302320', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund with a legacy-restocked unit listed before a kept unit, 100 each
        _Lib.InsertRefundQueueRow(StoreCode, '2302424', '2302220', '#2302220', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302424', '2302220', '#2302220', _Lib.RefundTimeAfterNow(), true,
            _Lib.RefundLineJsonOrdered('2302320', Sku, 1, 2, 'LEGACY_RESTOCK', '71001', 100, 20, 25) + ',' + _Lib.RefundLineJsonOrdered('2302320', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25),
            '', '', _ReturnLib.RefundTxnJson('2302524', 'bogus', 200, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302220', _Lib.RefundListItemJson('2302424', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo receives the restocked unit and charges nothing
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302424');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.CalcSums(Quantity);
        _Assert.AreEqual(1, SalesCrMemoLine.Quantity, 'The restocked unit is received back.');
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"Charge (Item)");
        _Assert.IsTrue(SalesCrMemoLine.IsEmpty(), 'The kept unit was the one left off the invoices, so nothing is charged.');
    end;

    [Test]
    procedure Import_EarlierOfTwoKeptUnitRefunds_HasNothingToCredit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Of two refunds of one unit each without restock, the older one takes the unit left off the invoices, even when the newer one is already known.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302221', '2302321', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund of one unit without restock, and a later refund of the other unit without restock
        _Lib.InsertRefundQueueRow(StoreCode, '2302425', '2302221', '#2302221', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302425', _Lib.RefundDetailResponse('2302425', '2302221', '#2302221', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302321', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302525', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302426', _Lib.RefundDetailResponse('2302426', '2302221', '#2302221', '2026-09-02T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302321', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302526', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302221', _Lib.RefundListItemJson('2302425', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302426', '2026-09-02T10:00:00Z', '')));

        // [WHEN] The import of the older refund runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The older refund has nothing to credit and no Return Order exists
        _Assert.IsTrue(Succeeded, 'The import must run: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302425');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'The older refund takes the unit left off the invoices.');
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_LaterOfTwoKeptUnitRefunds_ChargesTheShippedUnit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Of two refunds of one unit each without restock, the newer one is credited, since the older one took the unit left off the invoices.
        // [GIVEN] A legacy-path store with a refund item charge and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302222', '2302322', 1, 100, ShipmentNo);

        // [GIVEN] An earlier refund of one unit without restock, and a queued later refund of the other unit without restock for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2302428', '2302222', '#2302222', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302427', _Lib.RefundDetailResponse('2302427', '2302222', '#2302222', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302322', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302527', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302428', _Lib.RefundDetailResponse('2302428', '2302222', '#2302222', '2026-09-02T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302322', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302528', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302222', _Lib.RefundListItemJson('2302427', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302428', '2026-09-02T10:00:00Z', '')));

        // [WHEN] The import of the later refund runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The later refund is credited for 100
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302428');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The later refund is credited for the shipped unit.');
    end;

    [Test]
    procedure Posting_KeptUnitRefundAfterAnEarlierCancel_ChargesTheShippedUnit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When an earlier refund cancelled the unit left off the invoices, a later refund of the other unit without restock is credited.
        // [GIVEN] A legacy-path store with a refund item charge and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302223', '2302323', 1, 100, ShipmentNo);

        // [GIVEN] An earlier refund cancelling one unit, and a queued later refund of the other unit without restock for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2302430', '2302223', '#2302223', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302429', _Lib.RefundDetailResponse('2302429', '2302223', '#2302223', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302323', Sku, 1, 2, 'CANCEL', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302529', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302430', _Lib.RefundDetailResponse('2302430', '2302223', '#2302223', '2026-09-02T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302323', Sku, 1, 2, 'NO_RESTOCK', '', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302530', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302223', _Lib.RefundListItemJson('2302429', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302430', '2026-09-02T10:00:00Z', '')));

        // [WHEN] The import of the later refund runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The later refund is credited for 100
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302430');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The earlier cancel took the unit left off, so the shipped unit is credited.');
    end;

    [Test]
    procedure Import_RefundWithADraftWhenASalesOrderOfItsOrderAppears_KeepsItsDraft()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        SalesOrder: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        DraftNo: Code[20];
        PostAutomatically: Boolean;
        FirstBuilt: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund whose draft was already built is not sent back to wait when a Sales Order of its Shopify order appears, so its draft is never orphaned.
        // [GIVEN] A legacy-path store that posts by hand, an order of one unit at 100 shipped and invoiced, and the refund's draft built
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302224', '2302324', 1, 100, ShipmentNo);
        _Lib.InsertRefundQueueRow(StoreCode, '2302431', '2302224', '#2302224', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302431', '2302224', '#2302224', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2302324', Sku, 1, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302531', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302224', _Lib.RefundListItemJson('2302431', '2026-09-20T10:00:00Z', '')));
        FirstBuilt := _ReturnLib.RunImport(QueueRow, MockClient);
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302431');
        DraftNo := QueueRow."Sales Header Doc. No.";

        // [GIVEN] An open Sales Order carrying the same Shopify order
        _Lib.CreateOpenShopifyOrder(StoreCode, CustomerNo, Sku, '2302224', SalesOrder);

        // [WHEN] The import runs again on the row with its draft
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed store and remove the committed order before asserting.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        SalesOrder.Find();
        SalesOrder.Delete(true);
        Commit();

        // [THEN] The row keeps its draft and does not wait
        _Assert.IsTrue(FirstBuilt, 'Precondition: the draft builds: ' + GetLastErrorText());
        _Assert.IsTrue(Succeeded, 'The run on the draft must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302431');
        _Assert.AreNotEqual(QueueRow.Status::Waiting, QueueRow.Status, 'A row with a draft does not wait.');
        _Assert.AreEqual(DraftNo, QueueRow."Sales Header Doc. No.", 'The row keeps its draft.');
    end;

    [Test]
    procedure Build_ReturnWhileAnotherDraftSettlesTheSameUnpaidInvoice_Waits()
    var
        FirstSalesHeader: Record "Sales Header";
        SecondSalesHeader: Record "Sales Header";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Outcome: Enum "NPR Spfy Refund Build Outcome";
    begin
        // [SCENARIO] The document builder makes a return wait, as it does a refund, while another draft settles an unpaid invoice of the same order.
        // [GIVEN] A legacy-path store, an order of two units at 125 invoiced without a payment, and a first return's Return Order applied to that invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2302225', '2302325', 2, 125, ShipmentNo);
        _Lib.BuildReturnOrderWithoutQueue(StoreCode, _ReturnLib.ReturnDetailResponse('2302432', '2302225', '#2302225', Sku, '2302325', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2302532', 'bogus', 100, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), '2302432', FirstSalesHeader);

        // [WHEN] A second return of the order is built
        Outcome := _Lib.BuildReturnOrderWithoutQueue(StoreCode, _ReturnLib.ReturnDetailResponse('2302433', '2302225', '#2302225', Sku, '2302325', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2302533', 'bogus', 100, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), '2302433', SecondSalesHeader);

        // [THEN] It waits and no second Return Order is built
        _Assert.AreNotEqual('', FirstSalesHeader."Applies-to Doc. No.", 'Precondition: the first Return Order settles the invoice.');
        _Assert.AreEqual(Outcome::Waiting, Outcome, 'The second return waits for the first draft.');
        _Assert.AreEqual('', SecondSalesHeader."No.", 'No second Return Order is built.');
    end;

    [Test]
    procedure Build_ReturnWhileACreditMemoSettlesTheSameUnpaidInvoice_Waits()
    var
        CreditMemo: Record "Sales Header";
        SalesHeader: Record "Sales Header";
        LibrarySales: Codeunit "Library - Sales";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
        Outcome: Enum "NPR Spfy Refund Build Outcome";
    begin
        // [SCENARIO] A return waits while a Sales Credit Memo made by hand settles an unpaid invoice of the same order, as it does for a Return Order.
        // [GIVEN] A legacy-path store, an order of two units at 125 invoiced without a payment, and a Sales Credit Memo applied to that invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2302227', '2302327', 2, 125, ShipmentNo);
        LibrarySales.CreateSalesHeader(CreditMemo, CreditMemo."Document Type"::"Credit Memo", CustomerNo);
        CreditMemo.Validate("Applies-to Doc. Type", CreditMemo."Applies-to Doc. Type"::Invoice);
        CreditMemo.Validate("Applies-to Doc. No.", InvoiceNo);
        CreditMemo.Modify(true);

        // [WHEN] A return of the order is built
        Outcome := _Lib.BuildReturnOrderWithoutQueue(StoreCode, _ReturnLib.ReturnDetailResponse('2302435', '2302227', '#2302227', Sku, '2302327', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2302535', 'bogus', 100, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), '2302435', SalesHeader);

        // [THEN] It waits and no Return Order is built
        _Assert.AreEqual(Outcome::Waiting, Outcome, 'The return waits for the credit memo.');
        _Assert.AreEqual('', SalesHeader."No.", 'No Return Order is built.');
    end;

    [Test]
    procedure Import_UnitLeftOffAndAnUnpaidInvoice_PaysNothingOut()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
        PostAutomatically: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund with a unit left off the invoices of an order whose invoice is unpaid settles the invoice and pays nothing out: neither the unit's money nor the invoice's ever reached Business Central.
        // [GIVEN] A legacy-path store that posts by hand, and an order line ordered three times, two units invoiced at 50 without a payment
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2302229', '2302329', 2, 50, ShipmentNo);

        // [GIVEN] A queued refund restocking all three units for 150
        _Lib.InsertRefundQueueRow(StoreCode, '2302438', '2302229', '#2302229', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302438', '2302229', '#2302229', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302329', Sku, 3, 3, 'RETURN', '71001', 150, 30, 25), '', '', _ReturnLib.RefundTxnJson('2302538', 'bogus', 150, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302229', _Lib.RefundListItemJson('2302438', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The draft credits the two invoiced units, is applied to the invoice and carries no payment line
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302438');
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesHeader."Amount Including VAT", 'The two invoiced units are credited.');
        _Assert.AreEqual(InvoiceNo, SalesHeader."Applies-to Doc. No.", 'The credit memo settles the unpaid invoice.');
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        _Assert.IsTrue(PaymentLine.IsEmpty(), 'Nothing is paid out: the unit left off and the invoice were never paid to Business Central.');
    end;

    [Test]
    procedure Posting_RefundBesideAnotherRefundsCancelOfAnInvoicedUnit_IsCredited()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Another refund cancelling a unit Business Central invoiced is that refund's problem: a refund that cancels nothing on the line is still credited.
        // [GIVEN] A legacy-path store and an order line ordered twice, both units shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302230', '2302330', 2, 100, ShipmentNo);

        // [GIVEN] An earlier refund cancelling one unit, and a queued later refund restocking the other for 100
        _Lib.InsertRefundQueueRow(StoreCode, '2302440', '2302230', '#2302230', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302439', _Lib.RefundDetailResponse('2302439', '2302230', '#2302230', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302330', Sku, 1, 2, 'CANCEL', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302539', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302440', _Lib.RefundDetailResponse('2302440', '2302230', '#2302230', '2026-09-02T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302330', Sku, 1, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302540', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302230', _Lib.RefundListItemJson('2302439', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302440', '2026-09-02T10:00:00Z', '')));

        // [WHEN] The import of the later refund runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The later refund is credited for 100
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302440');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(100, SalesCrMemoHeader."Amount Including VAT", 'The refund that cancels nothing is credited.');
    end;

    [Test]
    procedure Import_EarlierOfTwoCancelsWithOneUnitLeftOff_HasNothingToCredit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Of two refunds each cancelling a unit of a line with only one unit left off the invoices, the older cancel takes that unit, so the older refund has nothing to credit and is not refused for the later one.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302231', '2302331', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund cancelling one unit, and a later refund cancelling the other
        _Lib.InsertRefundQueueRow(StoreCode, '2302441', '2302231', '#2302231', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302441', _Lib.RefundDetailResponse('2302441', '2302231', '#2302231', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302331', Sku, 1, 2, 'CANCEL', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302541', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302442', _Lib.RefundDetailResponse('2302442', '2302231', '#2302231', '2026-09-02T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302331', Sku, 1, 2, 'CANCEL', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302542', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302231', _Lib.RefundListItemJson('2302441', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302442', '2026-09-02T10:00:00Z', '')));

        // [WHEN] The import of the older refund runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The older refund has nothing to credit
        _Assert.IsTrue(Succeeded, 'The older cancel fits what was left off: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302441');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'The older cancel takes the unit left off the invoices.');
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_UnitLeftOffRefundedPartlyToAGiftCard_ComesOffTheCardRefund()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        PostAutomatically: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] The money of a unit left off the invoices comes off the card refund only, so the gift card share is paid out in full.
        // [GIVEN] A legacy-path store that posts by hand, and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302232', '2302332', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund restocking both units for 200, paid back 120 to the card and 80 to a gift card
        _Lib.InsertRefundQueueRow(StoreCode, '2302443', '2302232', '#2302232', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302443', '2302232', '#2302232', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302332', Sku, 2, 2, 'RETURN', '71001', 200, 40, 25), '', '',
            _ReturnLib.RefundTxnJson('2302543', 'bogus', 120, _ReturnLib.Lcy(), '') + ',' + _ReturnLib.RefundTxnJson('2302544', 'gift_card', 80, _ReturnLib.Lcy(), '2302644')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302232', _Lib.RefundListItemJson('2302443', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The 100 never received comes off the card line, leaving 20, and the gift card line keeps its 80
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302443');
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.SetRange("Transaction ID", '2302543');
        PaymentLine.FindFirst();
        _Assert.AreEqual(20, PaymentLine.Amount, 'The card refund carries the deduction.');
        PaymentLine.SetRange("Transaction ID", '2302544');
        PaymentLine.FindFirst();
        _Assert.AreEqual(80, PaymentLine.Amount, 'The gift card share is untouched.');
    end;

    [Test]
    procedure Import_RefundCreditingMoreThanShopifyRefunded_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund whose lines are worth more than Shopify refunded, with nothing withheld to explain it, is refused instead of crediting the difference.
        // [GIVEN] A legacy-path store and an order of one unit at 100, shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302233', '2302333', 1, 100, ShipmentNo);

        // [GIVEN] A queued refund restocking the unit for 100 of which Shopify refunded only 80
        _Lib.InsertRefundQueueRow(StoreCode, '2302444', '2302233', '#2302233', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302444', '2302233', '#2302233', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2302333', Sku, 1, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302545', 'bogus', 80, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302233', _Lib.RefundListItemJson('2302444', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused as exceeding the refund, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'Crediting more than was refunded must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'exceeds the') > 0, 'The error must say the document exceeds the refund: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'VerifyDocumentCoversRefund') > 0, 'The refusal must come from the total check: ' + GetLastErrorCallStack());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_LaterOfTwoCancelsWithOneUnitLeftOff_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Of two refunds each cancelling a unit of a line with only one unit left off the invoices, the later cancel no longer fits, so the later refund is refused for manual handling.
        // [GIVEN] A legacy-path store and an order line ordered twice, one unit shipped and invoiced at 100
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302234', '2302334', 1, 100, ShipmentNo);

        // [GIVEN] An earlier refund cancelling one unit, and a queued later refund cancelling the other
        _Lib.InsertRefundQueueRow(StoreCode, '2302446', '2302234', '#2302234', QueueRow);
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302445', _Lib.RefundDetailResponse('2302445', '2302234', '#2302234', '2026-09-01T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302334', Sku, 1, 2, 'CANCEL', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302546', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetRefund', 'gid://shopify/Refund/2302446', _Lib.RefundDetailResponse('2302446', '2302234', '#2302234', '2026-09-02T10:00:00Z', true, _Lib.RefundLineJsonOrdered('2302334', Sku, 1, 2, 'CANCEL', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302547', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302234', _Lib.RefundListItemJson('2302445', '2026-09-01T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302446', '2026-09-02T10:00:00Z', '')));

        // [WHEN] The import of the later refund runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the order, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'The later cancel does not fit what was left off.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'order #2302234') > 0, 'The error must name the order: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'AllocateLineItem') > 0, 'The refusal must come from the allocation: ' + GetLastErrorCallStack());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_DraftWhoseInvoiceWasPaidSinceItWasBuilt_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
        PostAutomatically: Boolean;
        FirstBuilt: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A draft built to settle an unpaid invoice is refused, asking for a discard and retry, once the invoice has been paid in the meantime, since it would pay nothing out.
        // [GIVEN] A legacy-path store that posts by hand, an order of two units at 50 invoiced without a payment, and the refund's draft built against that invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyStore.Get(StoreCode);
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2302226', '2302326', 2, 50, ShipmentNo);
        _Lib.InsertRefundQueueRow(StoreCode, '2302434', '2302226', '#2302226', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302434', '2302226', '#2302226', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJson('2302326', Sku, 2, 'RETURN', '71001', 100, 20, 25), '', '', _ReturnLib.RefundTxnJson('2302534', 'bogus', 100, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302226', _Lib.RefundListItemJson('2302434', '2026-09-20T10:00:00Z', '')));
        FirstBuilt := _ReturnLib.RunImport(QueueRow, MockClient);
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302434');

        // [GIVEN] The invoice paid in full since
        _Lib.PayInvoice(StoreCode, InvoiceNo);

        // [WHEN] The import runs again on the row with its draft
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();

        // [THEN] It is refused, asking for a discard and retry
        _Assert.IsTrue(FirstBuilt, 'Precondition: the draft builds: ' + GetLastErrorText());
        _Assert.IsFalse(Succeeded, 'A draft that would settle a paid invoice must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Discard the draft and retry') > 0, 'The error must say what to do: ' + GetLastErrorText());
    end;

    [Test]
    procedure Import_RefundOfAnOrderCancelledBeforeAnyInvoice_HasNothingToCredit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order Shopify cancelled before Business Central invoiced any of it ends with nothing to credit, naming the order, because Business Central never received money for it.
        // [GIVEN] A legacy-path store and a queued refund of 30 on an order Shopify cancelled, with neither a Sales Order nor an invoice in Business Central
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2302791', '2302701', '#2302701', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.OfCancelledOrder(_Lib.RefundDetailResponse('2302791', '2302701', '#2302701', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2302891', 'bogus', 30, _ReturnLib.Lcy(), ''))));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302701', _Lib.RefundListItemJson('2302791', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row ends Nothing to Credit with a note naming the order, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Nothing to credit is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302791');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'A refund of an order cancelled before any invoice has nothing to credit.');
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", '#2302701') > 0, 'The note must name the order: ' + QueueRow."Outcome Note");
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_RefundWhileTheSalesOrderHasNothingLeftToPost_IsCredited()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A Sales Order the order import left with nothing to ship or invoice is never posted again, so a refund of its order does not wait for it and is credited.
        // [GIVEN] A legacy-path store and an order of two units whose first unit was shipped, invoiced and paid while the second was cancelled, leaving the Sales Order with nothing to post
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.PostShopifyOrderLeavingNothingToPost(StoreCode, CustomerNo, Sku, LocationCode, '2302702', '2302712', 100, SalesOrder);

        // [GIVEN] A queued goodwill refund of 30 on that order
        _Lib.InsertRefundQueueRow(StoreCode, '2302792', '2302702', '#2302702', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302792', '2302702', '#2302702', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2302892', 'bogus', 30, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302702', _Lib.RefundListItemJson('2302792', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The refund is imported rather than waiting for the Sales Order
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302792');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A Sales Order with nothing left to post must not hold the refund back: ' + QueueRow."Outcome Note");

        // [THEN] The credit memo carries the 30 on the discrepancy account
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Refund Discrepancy G/L Acc.");
        SalesCrMemoLine.CalcSums("Amount Including VAT");
        _Assert.AreEqual(30, SalesCrMemoLine."Amount Including VAT", 'The goodwill amount is credited on the discrepancy account.');
    end;

    [Test]
    procedure Import_ReturnWithAPendingRefundTransaction_Waits()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return whose refund transaction is still pending at Shopify waits for it, naming the return, without using up a retry or building a Return Order.
        // [GIVEN] A legacy-path store and a queued closed return refunded 100 by a transaction Shopify has not completed
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.InsertQueueRow(StoreCode, '2302793', '2302703', QueueRow);
        MockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2302793', '2302703', '#2302703', Sku, '2302713', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2302893', 'shopify_payments', 100, _ReturnLib.Lcy(), '').Replace('"status":"SUCCESS"', '"status":"PENDING"'), _ReturnLib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row waits with a note naming the return, no retry is used, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Waiting is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '2302793');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'A return with a pending refund waits.');
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", '#2302703-R1') > 0, 'The note must name the return: ' + QueueRow."Outcome Note");
        _Assert.AreEqual(0, QueueRow."Retry Count", 'Waiting costs no retry.');
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure PollJQ_RefundBeforeTheRefundStartDate_IsNotQueued()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A refund created after "Get Returns Starting From" but before "Get Refunds Starting From" was credited by hand before refunds were imported, so it is not queued, while a refund after both is.
        // [GIVEN] A legacy-path store importing returns from 2026-01-01 and refunds from 2026-09-15, with no queued rows
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Get Refunds Starting From" := CreateDateTime(20260915D, 0T);
        ShopifyStore.Modify();
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();

        // [GIVEN] Shopify lists an order with a refund created on 2026-09-10 and one created on 2026-09-20, neither belonging to a return
        MockClient.AddResponse('sortKey:UPDATED_AT', 'refunds(first: 50) { id createdAt', _Lib.RefundListResponse('gid://shopify/Order/2302704', '#2302704', '', _Lib.RefundListItemJson('2302794', '2026-09-10T10:00:00Z', '') + ',' + _Lib.RefundListItemJson('2302795', '2026-09-20T10:00:00Z', '')));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] Only the refund after the refund start date is queued
        _Assert.AreEqual(1, QueueRow.Count(), 'Only one refund may be queued.');
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302795'), 'The refund after the refund start date must be queued.');
    end;

    [Test]
    procedure Upgrade_StoresWithoutARefundStartDate_ImportRefundsFromTheUpgradeOn()
    var
        ShopifyStore: Record "NPR Spfy Store";
        OtherStore: Record "NPR Spfy Store";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The upgrade gives every store without a refund start date the upgrade time, so refunds credited by hand before refunds were imported are never imported again; a start date already set is kept.
        // [GIVEN] A legacy-path store without a refund start date and another store whose refund start date is 2026-09-01
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        if OtherStore.Get('SPFYUPG2302') then
            OtherStore.Delete();
        OtherStore.Init();
        OtherStore.Code := 'SPFYUPG2302';
        OtherStore."Get Refunds Starting From" := CreateDateTime(20260901D, 0T);
        OtherStore.Insert();

        // [WHEN] The upgrade step stamps the refund start date, here with a time before every fixture's refunds
        SpfyAppUpgrade.StampRefundsStartingFrom(CreateDateTime(20200101D, 0T));

        // [THEN] The store without a date gets the upgrade time and the other store keeps its own
        ShopifyStore.Get(StoreCode);
        _Assert.AreEqual(CreateDateTime(20200101D, 0T), ShopifyStore."Get Refunds Starting From", 'A store without a refund start date must get the upgrade time.');
        OtherStore.Get('SPFYUPG2302');
        _Assert.AreEqual(CreateDateTime(20260901D, 0T), OtherStore."Get Refunds Starting From", 'A refund start date already set must be kept.');

        // Cleanup: remove the extra store.
        OtherStore.Delete();
    end;

    [Test]
    procedure Posting_ReturnOrderOtherThanTheSettlementRows_IsNotSettledByIt()
    var
        ShopifyStore: Record "NPR Spfy Store";
        Settlement: Record "NPR Spfy Refund Settlement";
        SalesHeader: Record "Sales Header";
        OtherReturnOrder: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OtherReturnOrderNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A settlement row settles only the Return Order it was written for: once that draft is deleted by hand and another Return Order carries the same Shopify ids, as the Ecommerce engine leaves it, posting that one settles nothing.
        // [GIVEN] A legacy-path store and a Return Order built by the builder for a return refunded 500 by card, which writes its settlement row
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.BuildReturnOrderWithoutQueue(StoreCode, _ReturnLib.ReturnDetailResponse('2302796', '2302706', '#2302706', Sku, '2302716', 2, 400, 100, 25, '71001', _ReturnLib.RefundTxnJson('2302896', 'shopify_payments', 500, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), '2302796', SalesHeader);

        // [GIVEN] The draft is deleted by hand, which leaves its settlement row behind
        SalesHeader.Find();
        SalesHeader.Delete(true);
        _Assert.IsTrue(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, '2302796'), 'Precondition: the settlement row outlives the deleted draft.');

        // [GIVEN] Another Return Order stamped with the same return id and store
        _Lib.CreateStampedReturnOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302796', 100, OtherReturnOrder);
        OtherReturnOrderNo := OtherReturnOrder."No.";

        // [WHEN] The other Return Order is posted
        Succeeded := _Lib.PostReturnOrder(OtherReturnOrder);

        // [THEN] The posting succeeds, the credit memo stays open and nothing is booked on the clearing account
        _Assert.IsTrue(Succeeded, 'Posting must succeed: ' + GetLastErrorText());
        _ReturnLib.GetCreditMemoForReturnOrder(OtherReturnOrderNo, SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(-SalesCrMemoHeader."Amount Including VAT", CustLedgerEntry."Remaining Amount", 'Another document''s settlement row must not settle this credit memo.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.IsTrue(GLEntry.IsEmpty(), 'Nothing may be settled for this credit memo.');
    end;

    [Test]
    procedure QueuePage_Dismiss_RemovesTheSettlementRow()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Settlement: Record "NPR Spfy Refund Settlement";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Dismissing a row whose draft is gone removes the settlement row it left behind, so nothing settles on the row's behalf any more.
        // [GIVEN] A queued return without a draft and a settlement row left behind for it
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.InsertQueueRow(StoreCode, '2302797', '2302707', QueueRow);
        _ReturnLib.SetSettlement(QueueRow, 0, '');

        // [WHEN] The row is dismissed
        SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // [THEN] The settlement row is gone
        _Assert.IsFalse(Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, '2302797'), 'Dismissing must remove the settlement row.');
    end;

    [Test]
    procedure Posting_KeptLineWithDefaultQuantityToShipBlank_IsCredited()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        OriginalDefault: Integer;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] With "Default Quantity to Ship" set to Blank, a unit the customer keeps is still credited as an item charge on its shipment and posted in full.
        // [GIVEN] A legacy-path store with a refund item charge and an order of two units at 50, both shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302801', '2302811', 2, 50, ShipmentNo);

        // [GIVEN] A sales setup with Default Quantity to Ship Blank from now on
        SalesSetup.Get();
        OriginalDefault := SalesSetup."Default Quantity to Ship";
        SalesSetup."Default Quantity to Ship" := SalesSetup."Default Quantity to Ship"::Blank;
        SalesSetup.Modify();

        // [GIVEN] A queued refund of one unit without restock
        _Lib.InsertRefundQueueRow(StoreCode, '2302891', '2302801', '#2302801', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302891', '2302801', '#2302801', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302811', Sku, 1, 2, 'NO_RESTOCK', '', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2302881', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302801', _Lib.RefundListItemJson('2302891', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore and commit the sales setup before asserting; the import committed the Blank default.
        SalesSetup.Get();
        SalesSetup."Default Quantity to Ship" := OriginalDefault;
        SalesSetup.Modify();
        Commit();

        // [THEN] A credit memo of 50 is posted for the kept unit
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed with a blank default quantity: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302891');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(50, SalesCrMemoHeader."Amount Including VAT", 'The kept unit is credited in full.');
    end;

    [Test]
    procedure Import_RefundWhoseSalesOrderHasNothingLeftAndNoInvoice_HasNothingToCredit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order whose Sales Order has nothing left to ship or invoice and was never invoiced, and that Shopify never shipped, has nothing to credit, naming the Sales Order, because Business Central will never receive money for it.
        // [GIVEN] A legacy-path store and a Sales Order of the Shopify order cut to nothing, with no invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateShopifyOrderWithNothingToPost(StoreCode, CustomerNo, Sku, '2302802', SalesOrder);

        // [GIVEN] A queued refund of 30 on that order, which Shopify neither shipped nor cancelled
        _Lib.InsertRefundQueueRow(StoreCode, '2302892', '2302802', '#2302802', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302892', '2302802', '#2302802', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2302882', 'bogus', 30, _ReturnLib.Lcy(), '')));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row ends Nothing to Credit with a note naming the Sales Order, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Nothing to credit is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302892');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'A Sales Order with nothing left and no invoice will never be invoiced: ' + QueueRow."Outcome Note");
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", SalesOrder."No.") > 0, 'The note must name the Sales Order: ' + QueueRow."Outcome Note");
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_RefundOfAShippedOrderWhoseSalesOrderShowsNothingToPost_Waits()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order Shopify has shipped waits while its Sales Order shows nothing to ship or invoice and no invoice exists, naming the Sales Order, because the order import still has to invoice what was shipped.
        // [GIVEN] A legacy-path store and a Sales Order of the Shopify order with nothing to post, with no invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateShopifyOrderWithNothingToPost(StoreCode, CustomerNo, Sku, '2350001', SalesOrder);

        // [GIVEN] A queued shipping refund of 29 on that order, which Shopify has shipped
        _Lib.InsertRefundQueueRow(StoreCode, '2350091', '2350001', '#2350001', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.OfFulfilledOrder(_Lib.RefundDetailResponse('2350091', '2350001', '#2350001', _Lib.RefundTimeAfterNow(), true, '', _ReturnLib.RefundShippingLineJson(23.20, 5.80), '', _ReturnLib.RefundTxnJson('2350081', 'bogus', 29, _ReturnLib.Lcy(), ''))));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row waits with a note naming the Sales Order, without a retry counted, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Waiting is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2350091');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'A shipped order is still to be invoiced, so its refund must wait: ' + QueueRow."Outcome Note");
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", SalesOrder."No.") > 0, 'The note must name the Sales Order: ' + QueueRow."Outcome Note");
        _Assert.AreEqual(0, QueueRow."Retry Count", 'Waiting costs no retry.');
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_RefundOfAShippedThenCancelledOrderWithNothingToPost_HasNothingToCredit()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of an order Shopify shipped and then cancelled has nothing to credit while its Sales Order has nothing to post and no invoice exists, because the order import never invoices a cancelled order.
        // [GIVEN] A legacy-path store and a Sales Order of the Shopify order with nothing to post, with no invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateShopifyOrderWithNothingToPost(StoreCode, CustomerNo, Sku, '2350002', SalesOrder);

        // [GIVEN] A queued refund of 30 on that order, which Shopify shipped and then cancelled
        _Lib.InsertRefundQueueRow(StoreCode, '2350092', '2350002', '#2350002', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.OfCancelledOrder(_Lib.OfFulfilledOrder(_Lib.RefundDetailResponse('2350092', '2350002', '#2350002', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-30, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2350082', 'bogus', 30, _ReturnLib.Lcy(), '')))));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row ends Nothing to Credit with a note naming the Sales Order, and no Return Order exists
        _Assert.IsTrue(Succeeded, 'Nothing to credit is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2350092');
        _Assert.AreEqual(QueueRow.Status::"Nothing to Credit", QueueRow.Status, 'A cancelled order is never invoiced, shipped or not: ' + QueueRow."Outcome Note");
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", SalesOrder."No.") > 0, 'The note must name the Sales Order: ' + QueueRow."Outcome Note");
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    [HandlerFunctions('SalesOrderPageHandler')]
    procedure QueuePage_OpenDocumentOnARowWaitingForTheOrderInvoice_OpensTheSalesOrder()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Open Document on a refund that waits for its shipped order to be invoiced opens the Sales Order its note names.
        // [GIVEN] A legacy-path store and a Sales Order of the Shopify order with nothing to post, with no invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateShopifyOrderWithNothingToPost(StoreCode, CustomerNo, Sku, '2350004', SalesOrder);

        // [GIVEN] A shipping refund of 29 on that order, which Shopify has shipped, imported and waiting
        _Lib.InsertRefundQueueRow(StoreCode, '2350094', '2350004', '#2350004', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.OfFulfilledOrder(_Lib.RefundDetailResponse('2350094', '2350004', '#2350004', _Lib.RefundTimeAfterNow(), true, '', _ReturnLib.RefundShippingLineJson(23.20, 5.80), '', _ReturnLib.RefundTxnJson('2350084', 'bogus', 29, _ReturnLib.Lcy(), ''))));
        _Assert.IsTrue(_ReturnLib.RunImport(QueueRow, MockClient), 'Precondition: the import runs: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2350094');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'Precondition: the row waits.');
        Clear(_CapturedMessage);

        // [WHEN] Open Document is run on the row
        SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] The Sales Order opens
        _Assert.AreEqual(SalesOrder."No.", _CapturedMessage, 'Open Document must open the Sales Order the row waits for.');
    end;

    [Test]
    [HandlerFunctions('SalesReturnOrderPageHandler')]
    procedure QueuePage_OpenDocumentOnARowWaitingForAnotherDraft_OpensThatDraft()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherDraft: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Open Document on a refund that waits for another draft settling the order's unpaid invoice opens that draft.
        // [GIVEN] A legacy-path store and an order invoiced without a payment
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2350005', '2350705', 1, 50, ShipmentNo);

        // [GIVEN] Another Return Order applied to that invoice
        OtherDraft.Init();
        OtherDraft."Document Type" := OtherDraft."Document Type"::"Return Order";
        OtherDraft."No." := 'RO2350005';
        OtherDraft."Sell-to Customer No." := CustomerNo;
        OtherDraft."Bill-to Customer No." := CustomerNo;
        OtherDraft."Applies-to Doc. Type" := OtherDraft."Applies-to Doc. Type"::Invoice;
        OtherDraft."Applies-to Doc. No." := InvoiceNo;
        OtherDraft.Insert();

        // [GIVEN] A refund row of the same order waiting for it, its note naming the Return Order
        _Lib.InsertRefundQueueRow(StoreCode, '2350095', '2350005', '#2350005', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Return Order RO2350005, which settles the unpaid Sales Invoice Header ' + InvoiceNo + ' of the same Shopify order, is posted or deleted; Shopify refund 2350095 of order #2350005 is imported then.';
        QueueRow.Modify();
        Clear(_CapturedMessage);

        // [WHEN] Open Document is run on the row
        SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] The other Return Order opens
        _Assert.AreEqual(OtherDraft."No.", _CapturedMessage, 'Open Document must open the draft the row waits for.');
    end;

    [Test]
    procedure QueuePage_OpenDocumentOnARowWaitingOnShopify_SaysNoDocumentHoldsItBack()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
    begin
        // [SCENARIO] Open Document on a refund that waits on Shopify, with no document in Business Central to wait for, says so and points to the row's note.
        // [GIVEN] A legacy-path store and an order invoiced and paid
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2350006', '2350706', 1, 100, ShipmentNo);

        // [GIVEN] A refund row of that order waiting, as one with a pending transaction does
        _Lib.InsertRefundQueueRow(StoreCode, '2350096', '2350006', '#2350006', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow.Modify();

        // [WHEN] Open Document is run on the row
        asserterror SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] The error says no document in Business Central holds the row back and names the note
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'No document in Business Central holds') > 0, 'The error must say no document holds the row back: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), QueueRow.FieldCaption("Outcome Note")) > 0, 'The error must name the note: ' + GetLastErrorText());
    end;

    [Test]
    [HandlerFunctions('SalesCreditMemoPageHandler')]
    procedure QueuePage_OpenDocumentOnARowWaitingForACreditMemo_OpensTheCreditMemo()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherDraft: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Open Document on a refund that waits for a Credit Memo settling the order's unpaid invoice opens that Credit Memo.
        // [GIVEN] A legacy-path store and an order invoiced without a payment, with a Credit Memo applied to that invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2350011', '2350711', 1, 50, ShipmentNo);
        OtherDraft.Init();
        OtherDraft."Document Type" := OtherDraft."Document Type"::"Credit Memo";
        OtherDraft."No." := 'CM2350011';
        OtherDraft."Sell-to Customer No." := CustomerNo;
        OtherDraft."Bill-to Customer No." := CustomerNo;
        OtherDraft."Applies-to Doc. Type" := OtherDraft."Applies-to Doc. Type"::Invoice;
        OtherDraft."Applies-to Doc. No." := InvoiceNo;
        OtherDraft.Insert();

        // [GIVEN] A refund row of the same order waiting for it, its note naming the Credit Memo
        _Lib.InsertRefundQueueRow(StoreCode, '2350101', '2350011', '#2350011', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Credit Memo CM2350011, which settles the unpaid Sales Invoice Header ' + InvoiceNo + ' of the same Shopify order, is posted or deleted; Shopify refund 2350101 of order #2350011 is imported then.';
        QueueRow.Modify();
        Clear(_CapturedMessage);

        // [WHEN] Open Document is run on the row
        SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] The Credit Memo opens
        _Assert.AreEqual(OtherDraft."No.", _CapturedMessage, 'Open Document must open the Credit Memo the row waits for.');
    end;

    [Test]
    procedure QueuePage_OpenDocumentOnARowWhoseNoteNamesAnotherNumber_OpensNothing()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherDraft: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Open Document opens a document only when the row's note names its number as a whole word: Return Order RO235001 is not the RO2350012 the note names.
        // [GIVEN] A legacy-path store and an order invoiced without a payment, with Return Order RO235001 applied to that invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2350010', '2350710', 1, 50, ShipmentNo);
        OtherDraft.Init();
        OtherDraft."Document Type" := OtherDraft."Document Type"::"Return Order";
        OtherDraft."No." := 'RO235001';
        OtherDraft."Sell-to Customer No." := CustomerNo;
        OtherDraft."Bill-to Customer No." := CustomerNo;
        OtherDraft."Applies-to Doc. Type" := OtherDraft."Applies-to Doc. Type"::Invoice;
        OtherDraft."Applies-to Doc. No." := InvoiceNo;
        OtherDraft.Insert();

        // [GIVEN] A refund row of the same order waiting, its note naming Return Order RO2350012
        _Lib.InsertRefundQueueRow(StoreCode, '2350100', '2350010', '#2350010', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Return Order RO2350012, which settles the unpaid Sales Invoice Header ' + InvoiceNo + ' of the same Shopify order, is posted or deleted; Shopify refund 2350100 of order #2350010 is imported then.';
        QueueRow.Modify();

        // [WHEN] Open Document is run on the row
        asserterror SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] No document is opened; the error says no document in Business Central holds the row back
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'No document in Business Central holds') > 0, 'A document whose number is only part of the named one must not open: ' + GetLastErrorText());
    end;

    [Test]
    procedure QueuePage_OpenDocumentOnARowWaitingForAPendingTransaction_OpensNotTheOpenSalesOrder()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Open Document on a refund whose note says it waits for a pending transaction at Shopify does not open the order's open Sales Order, which the note does not name.
        // [GIVEN] A legacy-path store and an open Sales Order of the Shopify order with something left to post
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateOpenShopifyOrder(StoreCode, CustomerNo, Sku, '2350009', SalesOrder);

        // [GIVEN] A refund row of that order waiting for a pending refund transaction
        _Lib.InsertRefundQueueRow(StoreCode, '2350099', '2350009', '#2350009', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Shopify completes the pending refund transaction of Shopify refund 2350099 of order #2350009.';
        QueueRow.Modify();

        // [WHEN] Open Document is run on the row
        asserterror SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] No document is opened; the error says no document in Business Central holds the row back
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'No document in Business Central holds') > 0, 'The Sales Order the note does not name must not open: ' + GetLastErrorText());
    end;

    [Test]
    procedure QueuePage_OpenDocumentOnANothingToCreditRow_OpensNoUnrelatedDraft()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherDraft: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
    begin
        // [SCENARIO] Open Document on a refund that has nothing to credit does not open a draft its note never named, such as another Return Order applied to the order's unpaid invoice later.
        // [GIVEN] A legacy-path store and an order invoiced without a payment, with another Return Order applied to that invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        InvoiceNo := _Lib.PostShopifyOrderUnpaid(StoreCode, CustomerNo, Sku, LocationCode, '2350008', '2350708', 1, 50, ShipmentNo);
        OtherDraft.Init();
        OtherDraft."Document Type" := OtherDraft."Document Type"::"Return Order";
        OtherDraft."No." := 'RO2350008';
        OtherDraft."Sell-to Customer No." := CustomerNo;
        OtherDraft."Bill-to Customer No." := CustomerNo;
        OtherDraft."Applies-to Doc. Type" := OtherDraft."Applies-to Doc. Type"::Invoice;
        OtherDraft."Applies-to Doc. No." := InvoiceNo;
        OtherDraft.Insert();

        // [GIVEN] A refund row of the same order that ended with nothing to credit
        _Lib.InsertRefundQueueRow(StoreCode, '2350098', '2350008', '#2350008', QueueRow);
        QueueRow.Status := QueueRow.Status::"Nothing to Credit";
        QueueRow.Modify();

        // [WHEN] Open Document is run on the row
        asserterror SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] No document is opened and the row is said to have none
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Nothing is credited') > 0, 'A row with nothing to credit must not open a draft its note does not name: ' + GetLastErrorText());
    end;

    [Test]
    [HandlerFunctions('SalesOrderPageHandler')]
    procedure QueuePage_OpenDocumentOnARowWaitingForTheOpenSalesOrderOfAnInvoicedOrder_OpensIt()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        ItemB: Record Item;
        LibraryInventory: Codeunit "Library - Inventory";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Open Document on a refund that waits for the order's open Sales Order opens it, also when part of the order is already invoiced.
        // [GIVEN] A legacy-path store and an order with line A invoiced and line B still open on its Sales Order
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LibraryInventory.CreateItem(ItemB);
        _Lib.PostShopifyOrderFirstLineOnly(StoreCode, CustomerNo, LocationCode, '2350015', Sku, '2350715', ItemB."No.", '2350795', 125, SalesOrder);

        // [GIVEN] A refund row of that order whose note says it waits for that Sales Order
        _Lib.InsertRefundQueueRow(StoreCode, '2350115', '2350015', '#2350015', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Business Central has invoiced Shopify order #2350015 (Sales Header ' + SalesOrder."No." + '); this refund is imported then.';
        QueueRow.Modify();
        Clear(_CapturedMessage);

        // [WHEN] Open Document is run on the row
        SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] The Sales Order opens
        _Assert.AreEqual(SalesOrder."No.", _CapturedMessage, 'Open Document must open the open Sales Order the row waits for.');
    end;

    [Test]
    [HandlerFunctions('SalesOrderPageHandler')]
    procedure QueuePage_OpenDocumentOnANothingToCreditRow_OpensTheSalesOrderItsNoteNames()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Open Document on a refund with nothing to credit opens the Sales Order with nothing to post that its note names.
        // [GIVEN] A legacy-path store and a Sales Order of the Shopify order with nothing to post, with no invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateShopifyOrderWithNothingToPost(StoreCode, CustomerNo, Sku, '2350016', SalesOrder);

        // [GIVEN] A refund row of that order with nothing to credit, whose note names that Sales Order
        _Lib.InsertRefundQueueRow(StoreCode, '2350116', '2350016', '#2350016', QueueRow);
        QueueRow.Status := QueueRow.Status::"Nothing to Credit";
        QueueRow."Outcome Note" := 'Business Central never invoiced Shopify order #2350016, and its Sales Header ' + SalesOrder."No." + ' has nothing left to ship or invoice, so Business Central never received money for it and Shopify refund 2350116 of order #2350016 has nothing to credit.';
        QueueRow.Modify();
        Clear(_CapturedMessage);

        // [WHEN] Open Document is run on the row
        SpfyLegacyReturnMgt.OpenRelatedDocument(QueueRow);

        // [THEN] The Sales Order opens
        _Assert.AreEqual(SalesOrder."No.", _CapturedMessage, 'Open Document must open the Sales Order the note names.');
    end;

    [Test]
    [HandlerFunctions('SalesReturnOrderPageHandler')]
    procedure QueuePage_OpenDocumentOnARowTheJobMovedOnSinceThePageReadIt_OpensItsDraft()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        RowAsThePageShowsIt: Record "NPR Spfy NC Return Queue";
        ReturnOrder: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Open Document acts on the row as it is now, not as the page last read it: a row the job built a draft for since opens that draft.
        // [GIVEN] A refund row the page shows as waiting for a pending transaction
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2350117', '2350017', '#2350017', QueueRow);
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := 'Waiting until Shopify completes 1 pending refund transaction(s) of Shopify refund 2350117 of order #2350017; it is imported then.';
        QueueRow.Modify();
        RowAsThePageShowsIt := QueueRow;

        // [GIVEN] The job has since built the Return Order and recorded it on the row
        _Lib.CreateStampedReturnOrder(StoreCode, CustomerNo, Sku, LocationCode, '2350117', 100, ReturnOrder);
        QueueRow.Status := QueueRow.Status::"Draft Created";
        QueueRow."Sales Header Doc. No." := ReturnOrder."No.";
        QueueRow."Outcome Note" := '';
        QueueRow.Modify();
        Clear(_CapturedMessage);

        // [WHEN] Open Document is run on the row the page still shows
        SpfyLegacyReturnMgt.OpenRelatedDocument(RowAsThePageShowsIt);

        // [THEN] The Return Order opens
        _Assert.AreEqual(ReturnOrder."No.", _CapturedMessage, 'Open Document must open the draft the row has now.');
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure QueuePage_DrillDownOnTheOutcomeNote_ShowsTheWholeNote()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        LongNote: Text;
    begin
        // [SCENARIO] Choosing a row's outcome note on the queue page shows the whole note, which the column cuts off.
        // [GIVEN] A refund row whose outcome note is longer than the column shows
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2350097', '2350007', '#2350007', QueueRow);
        LongNote := 'Waiting until Business Central has invoiced Shopify order #2350007: Shopify has shipped it, but its Sales Header SO2350007 has nothing to ship or invoice yet. Shopify refund 2350097 of order #2350007 is imported once the order is invoiced. If SO2350007 cannot be posted, correct it; if the order is never invoiced here, dismiss this row.';
        QueueRow.Status := QueueRow.Status::Waiting;
        QueueRow."Outcome Note" := CopyStr(LongNote, 1, MaxStrLen(QueueRow."Outcome Note"));
        QueueRow.Modify();
        Clear(_CapturedMessage);
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);

        // [WHEN] The outcome note is drilled down on
        QueuePage."Outcome Note".Drilldown();

        // [THEN] The whole note is shown
        QueuePage.Close();
        _Assert.AreEqual(LongNote, _CapturedMessage, 'The whole outcome note must be shown.');
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure QueuePage_DrillDownOnTheLastError_ShowsTheWholeError()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        LongError: Text;
    begin
        // [SCENARIO] Choosing a row's last error on the queue page shows the whole error, not the row's outcome note.
        // [GIVEN] A refund row whose last error is longer than the column shows, and which has no outcome note
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertRefundQueueRow(StoreCode, '2350114', '2350014', '#2350014', QueueRow);
        LongError := 'Shopify refund 2350114 of order #2350014 refunds 250 to Voucher SPFYLRV2350014, but the card paid only 200 on the invoices of the order that earlier refunds have not already put back. Crediting more would raise the card beyond what was spent from it, so this Return Order cannot be posted; delete it and handle the refund manually.';
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Last Error" := CopyStr(LongError, 1, MaxStrLen(QueueRow."Last Error"));
        QueueRow."Outcome Note" := '';
        QueueRow.Modify();
        Clear(_CapturedMessage);
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);

        // [WHEN] The last error is drilled down on
        QueuePage."Last Error".Drilldown();

        // [THEN] The whole error is shown
        QueuePage.Close();
        _Assert.AreEqual(LongError, _CapturedMessage, 'The whole last error must be shown.');
    end;

    [PageHandler]
    procedure SalesOrderPageHandler(var SalesOrder: TestPage "Sales Order")
    begin
        _CapturedMessage := SalesOrder."No.".Value();
        SalesOrder.Close();
    end;

    [PageHandler]
    procedure SalesCreditMemoPageHandler(var SalesCreditMemo: TestPage "Sales Credit Memo")
    begin
        _CapturedMessage := SalesCreditMemo."No.".Value();
        SalesCreditMemo.Close();
    end;

    [PageHandler]
    procedure SalesReturnOrderPageHandler(var SalesReturnOrder: TestPage "Sales Return Order")
    begin
        _CapturedMessage := SalesReturnOrder."No.".Value();
        SalesReturnOrder.Close();
    end;

    [Test]
    procedure Import_RefundWithNothingLeftOffTheInvoices_DoesNotFetchTheOtherRefunds()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When Business Central invoiced every unit of the refunded line, the order's other refunds cannot change what is credited, so the import does not ask Shopify for them.
        // [GIVEN] A legacy-path store with a refund item charge and an order of two units at 50, both shipped and invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.EnsureRefundItemCharge(StoreCode, Sku);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302803', '2302813', 2, 50, ShipmentNo);

        // [GIVEN] A queued refund of one unit without restock
        _Lib.InsertRefundQueueRow(StoreCode, '2302893', '2302803', '#2302803', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2302893', '2302803', '#2302803', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2302813', Sku, 1, 2, 'NO_RESTOCK', '', 50, 10, 25), '', '', _ReturnLib.RefundTxnJson('2302883', 'bogus', 50, _ReturnLib.Lcy(), '')));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2302803', _Lib.RefundListItemJson('2302893', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The refund is imported without a request for the order's refunds
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302893');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The refund must be imported.');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('GetOrderRefunds'), 'The order''s other refunds must not be fetched when nothing was left off the invoices.');
    end;

    [Test]
    procedure Import_RefundWhileTheSalesOrderIsShippedNotInvoiced_Waits()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesOrder: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund on an order whose Sales Order has shipped units not yet invoiced waits for the invoice, naming the Sales Order, so the shipped units are not taken for units left off the invoices.
        // [GIVEN] A legacy-path store and a Sales Order of the Shopify order with its only unit shipped but not invoiced
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrderShippedOnly(StoreCode, CustomerNo, Sku, LocationCode, '2302804', '2302814', SalesOrder);

        // [GIVEN] A queued refund on that order
        _Lib.InsertRefundQueueRow(StoreCode, '2302894', '2302804', '#2302804', QueueRow);

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The row waits with a note naming the Sales Order, and Shopify was not asked
        _Assert.IsTrue(Succeeded, 'Waiting is not an error: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302894');
        _Assert.AreEqual(QueueRow.Status::Waiting, QueueRow.Status, 'A Sales Order with units shipped but not invoiced holds the refund back.');
        _Assert.IsTrue(StrPos(QueueRow."Outcome Note", SalesOrder."No.") > 0, 'The note must name the Sales Order: ' + QueueRow."Outcome Note");
        _Assert.AreEqual(0, MockClient.RequestCount(), 'A waiting refund costs no Shopify request.');
    end;

    [Test]
    procedure Posting_GiftCardShareBeyondWhatTheCardPaid_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund that would give a gift card back more than it paid on the order is refused naming the voucher, because crediting more would be a top-up in disguise; the card keeps its balance and nothing is posted.
        // [GIVEN] A legacy-path store and gift card 9271 whose voucher paid 100 on the order's invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.CreateVoucherWithGiftCardId('SPFYLRV2701', StoreCode, '9271', Voucher);
        _ReturnLib.InsertPostedInvoiceWithVoucherPayment('SI-2302701', StoreCode, '2302711', Voucher."No.", 100);

        // [GIVEN] A queued return of that order refunded 300 by card and 200 to the gift card
        _ReturnLib.InsertQueueRow(StoreCode, '2302701', '2302711', QueueRow);
        MockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2302701', '2302711', '#2302711', Sku, '2302721', 2, 400, 100, 25, '71001',
            _ReturnLib.RefundTxnJson('2302731', 'shopify_payments', 300, _ReturnLib.Lcy(), '') + ',' + _ReturnLib.RefundTxnJson('2302732', 'gift_card', 200, _ReturnLib.Lcy(), '9271'), _ReturnLib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The posting is refused naming the voucher, and the card keeps its balance of 100
        _Assert.IsFalse(Succeeded, 'Giving the card back more than it paid must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Voucher."No.") > 0, 'The error must name the voucher: ' + GetLastErrorText());
        Voucher.CalcFields(Amount);
        _Assert.AreEqual(100, Voucher.Amount, 'The card must not be credited.');
    end;

    [Test]
    procedure Posting_SecondRefundToTheSameCard_CountsWhatTheFirstGaveBack()
    var
        FirstRow: Record "NPR Spfy NC Return Queue";
        SecondRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SecondMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        FirstSucceeded: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] What earlier credit memos of the same order gave back to a gift card counts against what the card paid, so a second return cannot give it back more in total than it paid on the order.
        // [GIVEN] A legacy-path store and gift card 9272 whose voucher paid 100 on the order's invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.CreateVoucherWithGiftCardId('SPFYLRV2702', StoreCode, '9272', Voucher);
        _ReturnLib.InsertPostedInvoiceWithVoucherPayment('SI-2302702', StoreCode, '2302712', Voucher."No.", 100);

        // [GIVEN] A first return of the order, refunded 40 by card and 60 to the gift card, imported and posted
        _ReturnLib.InsertQueueRow(StoreCode, '2302702', '2302712', FirstRow);
        MockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2302702', '2302712', '#2302712', Sku, '2302722', 1, 80, 20, 25, '71001',
            _ReturnLib.RefundTxnJson('2302733', 'shopify_payments', 40, _ReturnLib.Lcy(), '') + ',' + _ReturnLib.RefundTxnJson('2302734', 'gift_card', 60, _ReturnLib.Lcy(), '9272'), _ReturnLib.Lcy()));
        FirstSucceeded := _ReturnLib.RunImport(FirstRow, MockClient);
        _Assert.IsTrue(FirstSucceeded, 'Precondition: the first return posts: ' + GetLastErrorText());

        // [GIVEN] A second return of the same order, refunded 40 by card and 60 to the gift card again
        _ReturnLib.InsertQueueRow(StoreCode, '2302703', '2302712', SecondRow);
        SecondMockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2302703', '2302712', '#2302712', Sku, '2302722', 1, 80, 20, 25, '71001',
            _ReturnLib.RefundTxnJson('2302735', 'shopify_payments', 40, _ReturnLib.Lcy(), '') + ',' + _ReturnLib.RefundTxnJson('2302736', 'gift_card', 60, _ReturnLib.Lcy(), '9272'), _ReturnLib.Lcy()));

        // [WHEN] The second return is imported with automatic posting
        Succeeded := _ReturnLib.RunImport(SecondRow, SecondMockClient);

        // [THEN] It is refused, since only 40 of the card's payment is left to give back, and the card keeps the first refund only
        _Assert.IsFalse(Succeeded, 'A second refund beyond what the card paid must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Voucher."No.") > 0, 'The error must name the voucher: ' + GetLastErrorText());
        Voucher.CalcFields(Amount);
        _Assert.AreEqual(160, Voucher.Amount, 'Only the first refund of 60 is given back to the card.');
    end;

    [Test]
    procedure Posting_RefundOfADiscountGivenAfterTheSale_CreditsItWithTheLinesVat()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        InvoiceNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of a discount given after the sale, which Shopify records with no line, no shipping and no adjustment (Shopify order #1169: the line repriced from 49.97 to 39.98 after Business Central invoiced it), credits the 9.99 on the discrepancy account with the VAT of the discounted line.
        // [GIVEN] A legacy-path store whose discrepancy account carries a VAT group other than the item's
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.UseOtherVatOnDiscrepancyAccount(StoreCode, Sku);

        // [GIVEN] The order's line invoiced at its original 49.97
        InvoiceNo := _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302901', '2302911', 1, 49.97, ShipmentNo);

        // [GIVEN] A queued refund of 9.99 to the card with nothing else recorded, on an order whose line Shopify now discounts by 9.99
        _Lib.InsertRefundQueueRow(StoreCode, '2302991', '2302901', '#2302901', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2302991', '2302901', '#2302901', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2302981', 'bogus', 9.99, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2302911', 1, 49.97, 9.99, 25)));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The refund is imported as a credit memo of one 9.99 line on the discrepancy account
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302991');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The row must be Imported.');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Quantity, '<>0');
        _Assert.AreEqual(1, SalesCrMemoLine.Count(), 'The discount is one line.');
        SalesCrMemoLine.FindFirst();
        _Assert.AreEqual(ShopifyStore."Refund Discrepancy G/L Acc.", SalesCrMemoLine."No.", 'The discount goes to the discrepancy account.');
        _Assert.AreEqual(9.99, SalesCrMemoLine."Amount Including VAT", 'The line carries the refunded discount.');

        // [THEN] The line carries the VAT of the invoiced line it discounts, not the account's
        SalesInvoiceLine.SetRange("Document No.", InvoiceNo);
        SalesInvoiceLine.SetRange(Type, SalesInvoiceLine.Type::Item);
        SalesInvoiceLine.FindFirst();
        _Assert.AreEqual(SalesInvoiceLine."VAT Prod. Posting Group", SalesCrMemoLine."VAT Prod. Posting Group", 'The discount takes the VAT group of the discounted line.');
        _Assert.AreEqual(SalesInvoiceLine."VAT %", SalesCrMemoLine."VAT %", 'The discount takes the VAT rate of the discounted line.');
    end;

    [Test]
    procedure Import_RefundOfADiscountAlreadyInvoicedAtTheReducedPrice_IsRefusedNamingTheAmount()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of a discount given after the sale, on an order Business Central invoiced at the reduced price, is refused naming the amount instead of crediting the discount a second time, and leaves no Return Order.
        // [GIVEN] A legacy-path store and the order's line invoiced at the reduced 39.98
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302904', '2302914', 1, 39.98, ShipmentNo);

        // [GIVEN] A queued refund of 9.99 with nothing else recorded, on an order whose line Shopify discounts by 9.99 off 49.97
        _Lib.InsertRefundQueueRow(StoreCode, '2302994', '2302904', '#2302904', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2302994', '2302904', '#2302904', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2302984', 'bogus', 9.99, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2302914', 1, 49.97, 9.99, 25)));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the unexplained amount, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'A discount Business Central already invoiced must not be credited again.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Format(9.99)) > 0, 'The error must name the amount: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'BookUnexplainedRefund') > 0, 'The refusal must come from the unexplained-money rule: ' + GetLastErrorCallStack());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_SecondRefundOfAPostedDiscount_IsRefused()
    var
        FirstRow: Record "NPR Spfy NC Return Queue";
        SecondRow: Record "NPR Spfy NC Return Queue";
        FirstMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SecondMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A discount given after the sale is credited once: a second refund that leaves the same discount unexplained is refused once the first refund's credit memo is posted.
        // [GIVEN] A legacy-path store and the order's line invoiced at its original 49.97
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302905', '2302915', 1, 49.97, ShipmentNo);

        // [GIVEN] A first refund of the 9.99 discount, imported and posted
        _Lib.InsertRefundQueueRow(StoreCode, '2302995', '2302905', '#2302905', FirstRow);
        FirstMockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2302995', '2302905', '#2302905', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2302985', 'bogus', 9.99, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2302915', 1, 49.97, 9.99, 25)));
        _Assert.IsTrue(_ReturnLib.RunImport(FirstRow, FirstMockClient), 'Precondition: the first refund must post: ' + GetLastErrorText());

        // [GIVEN] A second queued refund of 9.99 with nothing else recorded, on the same discounted line
        _Lib.InsertRefundQueueRow(StoreCode, '2302996', '2302905', '#2302905', SecondRow);
        SecondMockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2302996', '2302905', '#2302905', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2302986', 'bogus', 9.99, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2302915', 1, 49.97, 9.99, 25)));

        // [WHEN] The second refund is imported
        Succeeded := _ReturnLib.RunImport(SecondRow, SecondMockClient);

        // [THEN] It is refused naming the amount, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'A discount already credited must not be credited again.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Format(9.99)) > 0, 'The error must name the amount: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'BookUnexplainedRefund') > 0, 'The refusal must come from the unexplained-money rule: ' + GetLastErrorCallStack());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_SecondRefundOfADiscountOnAnOpenDraft_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        FirstRow: Record "NPR Spfy NC Return Queue";
        SecondRow: Record "NPR Spfy NC Return Queue";
        FirstMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SecondMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A discount given after the sale that an unposted draft of an earlier refund already credits is not credited again by a second refund.
        // [GIVEN] A legacy-path store that posts by hand, and the order's line invoiced at its original 49.97
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302906', '2302916', 1, 49.97, ShipmentNo);

        // [GIVEN] A first refund of the 9.99 discount, imported into a draft that is not posted
        _Lib.InsertRefundQueueRow(StoreCode, '2302997', '2302906', '#2302906', FirstRow);
        FirstMockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2302997', '2302906', '#2302906', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2302987', 'bogus', 9.99, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2302916', 1, 49.97, 9.99, 25)));
        _Assert.IsTrue(_ReturnLib.RunImport(FirstRow, FirstMockClient), 'Precondition: the first draft must build: ' + GetLastErrorText());

        // [GIVEN] A second queued refund of 9.99 with nothing else recorded, on the same discounted line
        _Lib.InsertRefundQueueRow(StoreCode, '2302998', '2302906', '#2302906', SecondRow);
        SecondMockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2302998', '2302906', '#2302906', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2302988', 'bogus', 9.99, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2302916', 1, 49.97, 9.99, 25)));

        // [WHEN] The second refund is imported
        Succeeded := _ReturnLib.RunImport(SecondRow, SecondMockClient);

        // [THEN] It is refused naming the amount
        _Assert.IsFalse(Succeeded, 'A discount an open draft already credits must not be credited again.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Format(9.99)) > 0, 'The error must name the amount: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'BookUnexplainedRefund') > 0, 'The refusal must come from the unexplained-money rule: ' + GetLastErrorCallStack());
    end;

    [Test]
    procedure Posting_RefundOfADiscountOverInvoicedUnits_TakesTheRoundingCent()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A discount given after the sale on a line Business Central invoiced only in part is measured over the invoiced units, and a rounding cent between Shopify's per-unit allocation and that measure is credited with the discount instead of refusing the refund.
        // [GIVEN] A legacy-path store, and two of the three units of the order's line invoiced at 10.00 each
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302907', '2302917', 2, 10, ShipmentNo);

        // [GIVEN] A queued refund of 0.68 with nothing else recorded, for a 1.00 discount Shopify allocates over the line's three units (0.67 over the two invoiced ones)
        _Lib.InsertRefundQueueRow(StoreCode, '2302999', '2302907', '#2302907', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2302999', '2302907', '#2302907', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2302989', 'bogus', 0.68, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2302917', 3, 10, 1, 25)));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The 0.68 is credited as one discount line
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2302999');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Refund Discrepancy G/L Acc.");
        _Assert.AreEqual(1, SalesCrMemoLine.Count(), 'The discount is one line.');
        SalesCrMemoLine.FindFirst();
        _Assert.AreEqual(0.68, SalesCrMemoLine."Amount Including VAT", 'The rounding cent is credited with the discount.');
    end;

    [Test]
    procedure Posting_ReturnRefundedBeyondItsLineForADiscountGivenAfterTheSale_CreditsTheDiscount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded 10 more than its line, because a discount was given after Business Central invoiced the line (as on Shopify order #1132), credits the line at Shopify's reduced price and the 10 as the discount, on an order without taxes included.
        // [GIVEN] A legacy-path store and the order's line invoiced at its original 110 including VAT
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302912', '2302922', 1, 110, ShipmentNo);

        // [GIVEN] A queued return of that line refunded at 100 (80 plus 20 tax) and paid back 110, on an order whose line Shopify now discounts by 8 off 88 before tax
        _ReturnLib.InsertQueueRow(StoreCode, '2302902', '2302912', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.WithOrderLineItems(_ReturnLib.ReturnDetailResponse('2302902', '2302912', '#2302912', Sku, '2302922', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2302982', 'shopify_payments', 110, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), _Lib.OrderLineItemJson('2302922', 1, 88, 8, 25)));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo totals 110, with the 10 discount on the discrepancy account
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '2302902');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(110, SalesCrMemoHeader."Amount Including VAT", 'The credit memo covers the whole refund.');
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Refund Discrepancy G/L Acc.");
        SalesCrMemoLine.CalcSums("Amount Including VAT");
        _Assert.AreEqual(10, SalesCrMemoLine."Amount Including VAT", 'The 10 discount goes to the discrepancy account.');
    end;

    [Test]
    procedure Import_ReturnRefundedBeyondItsLineWithoutAnyDiscount_IsRefusedNamingTheAmount()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded 10 more than its line, with no adjustment and no discount on the line that Business Central has not credited, is refused naming the amount instead of booking money nothing explains.
        // [GIVEN] A legacy-path store and the order's line invoiced at 100 including VAT, which Shopify still charges
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302918', '2302928', 1, 100, ShipmentNo);

        // [GIVEN] A queued return of that line refunded at 100 and paid back 110
        _ReturnLib.InsertQueueRow(StoreCode, '2302908', '2302918', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.WithOrderLineItems(_ReturnLib.ReturnDetailResponse('2302908', '2302918', '#2302918', Sku, '2302928', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2302978', 'shopify_payments', 110, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), _Lib.OrderLineItemJson('2302928', 1, 80, 0, 25)));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the 10, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'Money nothing explains must not be booked.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Format(10)) > 0, 'The error must name the amount: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'BookUnexplainedRefund') > 0, 'The refusal must come from the unexplained-money rule: ' + GetLastErrorCallStack());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_DiscountGivenAfterTheSale_WithoutDiscrepancyAccount_IsRefusedNamingTheField()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        DiscrepancyAccountNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A discount given after the sale, refunded on a store without a discrepancy account, is refused with an error naming that field, and leaves no Return Order.
        // [GIVEN] A legacy-path store without a discrepancy account, and the order's line invoiced at its original 110
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        DiscrepancyAccountNo := ShopifyStore."Refund Discrepancy G/L Acc.";
        ShopifyStore."Refund Discrepancy G/L Acc." := '';
        ShopifyStore.Modify();
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2302913', '2302923', 1, 110, ShipmentNo);

        // [GIVEN] A queued return of that line refunded at 100 and paid back 110, the 10 being a discount given after the sale
        _ReturnLib.InsertQueueRow(StoreCode, '2302903', '2302913', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.WithOrderLineItems(_ReturnLib.ReturnDetailResponse('2302903', '2302913', '#2302913', Sku, '2302923', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2302983', 'shopify_payments', 110, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()), _Lib.OrderLineItemJson('2302923', 1, 88, 8, 25)));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // Cleanup: restore and commit the store before asserting; the import committed the blank account.
        ShopifyStore.Find();
        ShopifyStore."Refund Discrepancy G/L Acc." := DiscrepancyAccountNo;
        ShopifyStore.Modify();
        Commit();

        // [THEN] It is refused naming the discrepancy account field, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'A discount without a discrepancy account must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), ShopifyStore.FieldCaption("Refund Discrepancy G/L Acc.")) > 0, 'The error must name the field: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'BookUnexplainedRefund') > 0, 'The refusal must come from the unexplained-money rule: ' + GetLastErrorCallStack());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_RefundOfADiscountOnALineInvoicedInTwoParts_IsMeasuredOverBothInvoices()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A discount given after the sale on a line Business Central invoiced in two parts is measured over both invoices and credited as one discount line.
        // [GIVEN] A legacy-path store and an order line of two units invoiced one unit at a time at 50 each
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.PostShopifyOrderInTwoParts(StoreCode, CustomerNo, Sku, LocationCode, '2303001', '2303011', 50);

        // [GIVEN] A queued refund of 10 with nothing else recorded, on an order whose line Shopify now discounts by 10 over its two units
        _Lib.InsertRefundQueueRow(StoreCode, '2303021', '2303001', '#2303001', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2303021', '2303001', '#2303001', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2303031', 'bogus', 10, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2303011', 2, 50, 10, 25)));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The 10 is credited as one discount line
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2303021');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Refund Discrepancy G/L Acc.");
        _Assert.AreEqual(1, SalesCrMemoLine.Count(), 'The line is measured once over both invoices.');
        SalesCrMemoLine.FindFirst();
        _Assert.AreEqual(10, SalesCrMemoLine."Amount Including VAT", 'The whole discount is credited.');
    end;

    [Test]
    procedure Posting_CancelledUnitRefundedWithADiscountAfterTheSale_CreditsTheDiscount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund that cancels a unit Business Central never invoiced and also pays back a discount given after the sale on the invoiced unit credits that discount instead of ending with nothing to credit.
        // [GIVEN] A legacy-path store and a two-unit line at 50 of which only one unit was invoiced, its Sales Order left with nothing to post
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        _Lib.PostShopifyOrderLeavingNothingToPost(StoreCode, CustomerNo, Sku, LocationCode, '2309051', '2309751', 50, SalesHeader);

        // [GIVEN] A queued refund of 50: the cancelled unit at its discounted 40, and 10 back on the invoiced unit after Shopify discounted the line by 20
        _Lib.InsertRefundQueueRow(StoreCode, '2309951', '2309051', '#2309051', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2309951', '2309051', '#2309051', _Lib.RefundTimeAfterNow(), true, _Lib.RefundLineJsonOrdered('2309751', Sku, 1, 2, 'CANCEL', '', 40, 8, 25), '', '', _ReturnLib.RefundTxnJson('2309851', 'bogus', 50, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2309751', 2, 50, 20, 25)));
        MockClient.AddResponse('GetOrderRefunds', _Lib.OrderRefundsResponse('2309051', _Lib.RefundListItemJson('2309951', '2026-09-20T10:00:00Z', '')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The refund is Imported with one discount line of 10 on the discrepancy account
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2309951');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The discount must be credited, not left as nothing to credit.');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetFilter(Quantity, '<>0');
        _Assert.AreEqual(1, SalesCrMemoLine.Count(), 'Only the discount is credited.');
        SalesCrMemoLine.FindFirst();
        _Assert.AreEqual(ShopifyStore."Refund Discrepancy G/L Acc.", SalesCrMemoLine."No.", 'The discount goes to the discrepancy account.');
        _Assert.AreEqual(10, SalesCrMemoLine."Amount Including VAT", 'The discount still owed on the invoiced unit is credited.');
    end;

    [Test]
    procedure Posting_RefundOfDiscountsOnTwoLines_CreditsEachLinesDiscount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ItemB: Record Item;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryInventory: Codeunit "Library - Inventory";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of discounts given after the sale on two order lines credits one discount line per order line, each for that line's discount.
        // [GIVEN] A legacy-path store and an order of items A and B invoiced at 125 each
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.GetStore(StoreCode, ShopifyStore);
        LibraryInventory.CreateItem(ItemB);
        _Lib.PostShopifyOrderTwoLines(StoreCode, CustomerNo, LocationCode, '2303002', Sku, '2303012', ItemB."No.", '2303013', 125);

        // [GIVEN] A queued refund of 15 with nothing else recorded, on an order whose lines Shopify now discounts by 10 and by 5
        _Lib.InsertRefundQueueRow(StoreCode, '2303022', '2303002', '#2303002', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2303022', '2303002', '#2303002', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2303032', 'bogus', 15, _ReturnLib.Lcy(), '')),
            _Lib.OrderLineItemJson('2303012', 1, 125, 10, 25) + ',' + _Lib.OrderLineItemJson('2303013', 1, 125, 5, 25)));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The credit memo carries a discount line of 10 and one of 5
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2303022');
        _ReturnLib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Refund Discrepancy G/L Acc.");
        _Assert.AreEqual(2, SalesCrMemoLine.Count(), 'Each discounted order line gets its own line.');
        SalesCrMemoLine.SetRange("Amount Including VAT", 10);
        _Assert.AreEqual(1, SalesCrMemoLine.Count(), 'Item A''s discount is credited.');
        SalesCrMemoLine.SetRange("Amount Including VAT", 5);
        _Assert.AreEqual(1, SalesCrMemoLine.Count(), 'Item B''s discount is credited.');
    end;

    [Test]
    procedure Import_RefundOfADiscountBeyondTheRoundingCent_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Money a refund pays beyond a measured discount by more than one rounding unit is refused rather than credited with the discount.
        // [GIVEN] A legacy-path store, and two of the three units of the order's line invoiced at 10.00 each
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2303003', '2303014', 2, 10, ShipmentNo);

        // [GIVEN] A queued refund of 0.69 with nothing else recorded, two cents beyond the 0.67 discount on the two invoiced units
        _Lib.InsertRefundQueueRow(StoreCode, '2303023', '2303003', '#2303003', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2303023', '2303003', '#2303003', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2303033', 'bogus', 0.69, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2303014', 3, 10, 1, 25)));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused by the unexplained-money rule, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'Two cents beyond the discount must not be credited.');
        _Assert.IsTrue(StrPos(GetLastErrorCallStack(), 'BookUnexplainedRefund') > 0, 'The refusal must come from the unexplained-money rule: ' + GetLastErrorCallStack());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Import_DiscountOnAnOrderWithMoreLinesThanOneRequestReads_IsRefusedAsTruncated()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Unexplained refund money on an order whose line items do not fit in one request is refused as truncated, since the discounted line may be among those not read.
        // [GIVEN] A legacy-path store and the order's line invoiced at its original 49.97
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2303004', '2303015', 1, 49.97, ShipmentNo);

        // [GIVEN] A queued refund of 9.99 with nothing else recorded, on an order whose line items Shopify returns in more than one page
        _Lib.InsertRefundQueueRow(StoreCode, '2303024', '2303004', '#2303004', QueueRow);
        MockClient.AddResponse('GetRefund', _Lib.WithOrderLineItems(_Lib.RefundDetailResponse('2303024', '2303004', '#2303004', _Lib.RefundTimeAfterNow(), true, '', '', '', _ReturnLib.RefundTxnJson('2303034', 'bogus', 9.99, _ReturnLib.Lcy(), '')), _Lib.OrderLineItemJson('2303015', 1, 49.97, 9.99, 25))
            .Replace('"lineItems":{"pageInfo":{"hasNextPage":false}', '"lineItems":{"pageInfo":{"hasNextPage":true}'));

        // [WHEN] The import runs
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] It is refused naming the truncated connection, and no Return Order exists
        _Assert.IsFalse(Succeeded, 'An order read in part cannot be measured.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'order.lineItems') > 0, 'The error must name the truncated connection: ' + GetLastErrorText());
        _Lib.AssertNoReturnOrder(CustomerNo);
    end;

    [Test]
    procedure Posting_GiftCardShareAlreadyGivenBackByAHandMadeCreditMemo_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        AmountBefore: Decimal;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gift card payment that a corrective credit memo made by hand already gave back counts against the cap, so a Shopify refund of the same money to the card is refused instead of raising the card beyond what was spent from it.
        // [GIVEN] A legacy-path store and gift card 9305 whose voucher paid 200 on the order's invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.CreateVoucherWithGiftCardId('SPFYLRV3005', StoreCode, '9305', Voucher);
        _ReturnLib.InsertPostedInvoiceWithVoucherPayment('SI-2303005', StoreCode, '2303005', Voucher."No.", 200);

        // [GIVEN] A corrective credit memo made by hand, with no Shopify stamps, that already gave the 200 back to the card
        SalesCrMemoHeader.Init();
        SalesCrMemoHeader."No." := 'SCM-2303005';
        SalesCrMemoHeader."Sell-to Customer No." := CustomerNo;
        SalesCrMemoHeader."Bill-to Customer No." := CustomerNo;
        SalesCrMemoHeader.Insert();
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::Payment;
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"Credit Memo";
        VoucherEntry."Document No." := SalesCrMemoHeader."No.";
        VoucherEntry.Correction := true;
        VoucherEntry.Amount := 200;
        VoucherEntry."Remaining Amount" := 200;
        VoucherEntry.Positive := true;
        VoucherEntry.Open := true;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
        Voucher.CalcFields(Amount);
        AmountBefore := Voucher.Amount;

        // [GIVEN] A queued return of that order refunded 300 by card and 200 to the gift card
        _ReturnLib.InsertQueueRow(StoreCode, '2303025', '2303005', QueueRow);
        MockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2303025', '2303005', '#2303005', Sku, '2303016', 2, 400, 100, 25, '71001',
            _ReturnLib.RefundTxnJson('2303035', 'shopify_payments', 300, _ReturnLib.Lcy(), '') + ',' + _ReturnLib.RefundTxnJson('2303036', 'gift_card', 200, _ReturnLib.Lcy(), '9305'), _ReturnLib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The posting is refused naming the voucher, and the card is not credited again
        _Assert.IsFalse(Succeeded, 'Money a hand-made credit memo already gave back must not be given back again.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Voucher."No.") > 0, 'The error must name the voucher: ' + GetLastErrorText());
        Voucher.CalcFields(Amount);
        _Assert.AreEqual(AmountBefore, Voucher.Amount, 'The card must not be credited.');
    end;

    [Test]
    procedure Posting_GiftCardShareAlreadyToppedUpByAReleasedBuild_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        Settlement: Record "NPR Spfy Refund Settlement";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        AmountBefore: Decimal;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gift card payment that an earlier return of the same order already credited back as a top-up, as the released build posted it, counts against the cap, so a refund of the same money to the card is refused.
        // [GIVEN] A legacy-path store and gift card 9361 whose voucher paid 200 on the order's invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.CreateVoucherWithGiftCardId('SPFYLRV9061', StoreCode, '9361', Voucher);
        _ReturnLib.InsertPostedInvoiceWithVoucherPayment('SI-2309061', StoreCode, '2309061', Voucher."No.", 200);

        // [GIVEN] An earlier return 2309961 of that order, posted by the released build: its credit memo topped the card up by 200
        _ReturnLib.InsertPostedCrMemoWithReturnIds('SCM-2309961', StoreCode, '2309961');
        if not Settlement.Get(StoreCode, Settlement."Source Doc. Type"::Return, '2309961') then begin
            Settlement.Init();
            Settlement."Shopify Store Code" := StoreCode;
            Settlement."Source Doc. Type" := Settlement."Source Doc. Type"::Return;
            Settlement."Shopify Id" := '2309961';
            Settlement."Order Id" := '2309061';
            Settlement.Insert();
        end;
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"Credit Memo";
        VoucherEntry."Document No." := 'SCM-2309961';
        VoucherEntry.Amount := 200;
        VoucherEntry."Remaining Amount" := 200;
        VoucherEntry.Positive := true;
        VoucherEntry.Open := true;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
        Voucher.CalcFields(Amount);
        AmountBefore := Voucher.Amount;

        // [GIVEN] A queued return 2309962 of the same order refunded 300 by card and 200 to the gift card
        _ReturnLib.InsertQueueRow(StoreCode, '2309962', '2309061', QueueRow);
        MockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2309962', '2309061', '#2309061', Sku, '2309761', 2, 400, 100, 25, '71001',
            _ReturnLib.RefundTxnJson('2309861', 'shopify_payments', 300, _ReturnLib.Lcy(), '') + ',' + _ReturnLib.RefundTxnJson('2309862', 'gift_card', 200, _ReturnLib.Lcy(), '9361'), _ReturnLib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The posting is refused naming the voucher, and the card is not credited again
        _Assert.IsFalse(Succeeded, 'Money the released build already topped back up must not be given back again.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Voucher."No.") > 0, 'The error must name the voucher: ' + GetLastErrorText());
        Voucher.CalcFields(Amount);
        _Assert.AreEqual(AmountBefore, Voucher.Amount, 'The card must not be credited.');
    end;

    [Test]
    procedure Posting_GiftCardShareAboveThePaymentAfterATopUpCreditedByHand_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        AmountBefore: Decimal;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A credit memo made by hand that takes a sold top-up back off the card lowers its balance and gives nothing back, so it does not raise what a refund may put back on the card: 250 against a payment of 200 is refused.
        // [GIVEN] A legacy-path store and gift card 9381 whose voucher paid 200 on the order's invoice
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.CreateVoucherWithGiftCardId('SPFYLRV9081', StoreCode, '9381', Voucher);
        _ReturnLib.InsertPostedInvoiceWithVoucherPayment('SI-2309081', StoreCode, '2309081', Voucher."No.", 200);

        // [GIVEN] A credit memo made by hand, with no Shopify stamp, that took a sold top-up of 50 back off the card, as the voucher module posts a credited top-up line
        if not SalesCrMemoHeader.Get('SCM-2309981') then begin
            SalesCrMemoHeader.Init();
            SalesCrMemoHeader."No." := 'SCM-2309981';
            SalesCrMemoHeader.Insert();
        end;
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := Voucher."No.";
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
        VoucherEntry."Document Type" := VoucherEntry."Document Type"::"Credit Memo";
        VoucherEntry."Document No." := 'SCM-2309981';
        VoucherEntry.Amount := -50;
        VoucherEntry."Remaining Amount" := -50;
        VoucherEntry.Positive := false;
        VoucherEntry.Correction := true;
        VoucherEntry.Open := true;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
        Voucher.CalcFields(Amount);
        AmountBefore := Voucher.Amount;

        // [GIVEN] A queued return 2309982 of the order refunded 250 by card and 250 to the gift card
        _ReturnLib.InsertQueueRow(StoreCode, '2309982', '2309081', QueueRow);
        MockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2309982', '2309081', '#2309081', Sku, '2309781', 2, 400, 100, 25, '71001',
            _ReturnLib.RefundTxnJson('2309881', 'shopify_payments', 250, _ReturnLib.Lcy(), '') + ',' + _ReturnLib.RefundTxnJson('2309882', 'gift_card', 250, _ReturnLib.Lcy(), '9381'), _ReturnLib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _ReturnLib.RunImport(QueueRow, MockClient);

        // [THEN] The posting is refused naming the voucher, and the card is not credited
        _Assert.IsFalse(Succeeded, 'A credited top-up must not raise what the card may get back.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Voucher."No.") > 0, 'The error must name the voucher: ' + GetLastErrorText());
        Voucher.CalcFields(Amount);
        _Assert.AreEqual(AmountBefore, Voucher.Amount, 'The card must not be credited.');
    end;

    [Test]
    procedure PollJQ_ReturnAndRefundWithTheSameId_AreBothQueued()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Shopify numbers returns and refunds separately, so a return and a refund of the same store may carry the same id; both are queued, each under its own kind.
        // [GIVEN] A legacy-path store with no queued rows
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();

        // [GIVEN] Shopify lists an order with closed return 2303041 and a refund without a return that is also 2303041
        MockClient.AddResponse('sortKey:UPDATED_AT', 'refunds(first: 50) { id createdAt', _Lib.RefundListResponse('gid://shopify/Order/2303006', '#2303006', _Lib.ClosedReturnEdgeJson('gid://shopify/Return/2303041', '#2303006-R1'), _Lib.RefundListItemJson('2303041', '2026-09-21T10:00:00Z', '')));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] Both are queued, the return and the refund under the same id
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        _Assert.AreEqual(2, QueueRow.Count(), 'A return and a refund sharing an id are two rows.');
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '2303041'), 'The return is queued.');
        _Assert.AreEqual('#2303006-R1', QueueRow."Source Doc. Name", 'The return keeps its name.');
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Refund, '2303041'), 'The refund is queued.');
        _Assert.AreEqual('#2303006', QueueRow."Source Doc. Name", 'The refund goes by its order.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure Posting_RefundWithTheIdOfAPostedReturn_IsCreditedOnItsOwn()
    var
        ReturnRow: Record "NPR Spfy NC Return Queue";
        RefundRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ReturnMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        RefundMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShipmentNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund whose id equals a return already posted in the same store is credited by a credit memo of its own, stamped with the refund id, and is not taken for the return's credit memo.
        // [GIVEN] A legacy-path store with return 2303042 imported and posted
        _ReturnLib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _ReturnLib.InsertQueueRow(StoreCode, '2303042', '2303007', ReturnRow);
        ReturnMockClient.AddResponse('GetReturn', _ReturnLib.ReturnDetailResponse('2303042', '2303007', '#2303007', Sku, '2303017', 1, 80, 20, 25, '71001', _ReturnLib.RefundTxnJson('2303052', 'shopify_payments', 100, _ReturnLib.Lcy(), ''), _ReturnLib.Lcy()));
        _Assert.IsTrue(_ReturnLib.RunImport(ReturnRow, ReturnMockClient), 'Precondition: the return must post: ' + GetLastErrorText());
        ReturnRow.Get(ReturnRow."Entry No.");
        _Assert.AreNotEqual('', ReturnRow."Posted Doc. No.", 'Precondition: the return must have a credit memo.');

        // [GIVEN] An invoiced order and a queued refund of 40 on it whose id is also 2303042
        _Lib.PostShopifyOrder(StoreCode, CustomerNo, Sku, LocationCode, '2303008', '2303018', 1, 100, ShipmentNo);
        _Lib.InsertRefundQueueRow(StoreCode, '2303042', '2303008', '#2303008', RefundRow);
        RefundMockClient.AddResponse('GetRefund', _Lib.RefundDetailResponse('2303042', '2303008', '#2303008', _Lib.RefundTimeAfterNow(), true, '', '', _ReturnLib.OrderAdjustmentJson(-40, 0, 'REFUND_DISCREPANCY'), _ReturnLib.RefundTxnJson('2303053', 'bogus', 40, _ReturnLib.Lcy(), '')));

        // [WHEN] The refund is imported with automatic posting
        Succeeded := _ReturnLib.RunImport(RefundRow, RefundMockClient);

        // [THEN] The refund is Imported with a credit memo of its own
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        RefundRow.Get(RefundRow."Entry No.");
        _Assert.AreEqual(RefundRow.Status::Imported, RefundRow.Status, 'The refund must be Imported.');
        _Assert.AreNotEqual(ReturnRow."Posted Doc. No.", RefundRow."Posted Doc. No.", 'The refund must not take the return''s credit memo.');

        // [THEN] The refund's credit memo carries the refund id under its own type, and no return id
        SalesCrMemoHeader.Get(RefundRow."Posted Doc. No.");
        _Assert.AreEqual('2303042', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Refund ID"), 'The credit memo is stamped with the refund id.');
        _Assert.AreEqual('', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'A refund''s credit memo carries no return id.');
    end;

    local procedure LineWithoutOrderLineJson(): Text
    begin
        exit('{"node":{"quantity":1,"restockType":"NO_RESTOCK","restocked":false,"location":null,"subtotalSet":{"presentmentMoney":{"amount":"5"}},"totalTaxSet":{"presentmentMoney":{"amount":"0"}},"lineItem":null}}');
    end;

    local procedure TruncatedLines(RefundDetailJson: Text): Text
    begin
        exit(RefundDetailJson.Replace('"refundLineItems":{"pageInfo":{"hasNextPage":false}', '"refundLineItems":{"pageInfo":{"hasNextPage":true}'));
    end;

    [MessageHandler]
    procedure CaptureMessage(Message: Text[1024])
    begin
        _CapturedMessage := Message;
    end;
}

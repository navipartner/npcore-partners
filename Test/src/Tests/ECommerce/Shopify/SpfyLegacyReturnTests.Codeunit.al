codeunit 85483 "NPR Spfy Legacy Return Tests"
{
    // [FEATURE] Shopify legacy return import
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit Assert;
        _Lib: Codeunit "NPR Library Spfy Legacy Return";
        _CapturedMessage: Text;

    [Test]
    procedure VoucherFacade_PaymentReversalForCreditMemo_RaisesBalanceKeepsInitialAmount()
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        LibrarySpfyVoucher: Codeunit "NPR Library - Spfy Voucher";
    begin
        // [SCENARIO] Reversing a gift card payment for a posted credit memo gives the amount back to the card's balance as a corrective payment entry, keeps its initial amount, needs no top-up permission and leaves no voucher sales line behind.
        // [GIVEN] A Shopify store with a gift card voucher type
        LibrarySpfyVoucher.CreateShopifyStore('SPFYLRV');
        LibrarySpfyVoucher.CreateVoucherType('SPFYLRGIFT', 'SPFYLRV', VoucherType);

        // [GIVEN] A voucher of 100 that does not allow top-up, of which 60 was spent
        LibrarySpfyVoucher.CreateVoucher('SPFYLRV01', VoucherType.Code, 'SPFYLRVREF0001', 100, Voucher);
        Voucher."Allow Top-up" := false;
        Voucher.Modify();
        _Lib.UseVoucherAmount(Voucher."No.", 60);

        // [WHEN] The facade reverses 40 of the payment for credit memo SCM-1
        NpRvVoucherMgt.PostPaymentReversalForCreditMemo(Voucher, 40, WorkDate(), 'SCM-1', '1001-R1');

        // [THEN] The balance is back up to 80 and the initial amount is still 100
        Voucher.CalcFields(Amount, "Initial Amount");
        _Assert.AreEqual(80, Voucher.Amount, 'The voucher balance must grow by the refunded amount.');
        _Assert.AreEqual(100, Voucher."Initial Amount", 'A reversed payment must not change the initial amount.');

        // [THEN] The new entry is a corrective payment of 40 for the credit memo, and no top-up entry exists
        VoucherEntry.SetRange("Voucher No.", Voucher."No.");
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::Payment);
        VoucherEntry.SetRange(Correction, true);
        _Assert.IsTrue(VoucherEntry.FindFirst(), 'A corrective payment entry must exist.');
        _Assert.AreEqual(40, VoucherEntry.Amount, 'The reversal gives back the refunded amount.');
        _Assert.AreEqual(VoucherEntry."Document Type"::"Credit Memo", VoucherEntry."Document Type", 'The entry must reference a credit memo.');
        _Assert.AreEqual('SCM-1', VoucherEntry."Document No.", 'The entry must carry the credit memo number.');
        _Assert.AreEqual('1001-R1', VoucherEntry."External Document No.", 'The entry must carry the Shopify document.');
        VoucherEntry.SetRange(Correction);
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::"Top-up");
        _Assert.IsTrue(VoucherEntry.IsEmpty(), 'A refund to a gift card is no top-up.');

        // [THEN] No voucher sales line was persisted
        NpRvSalesLine.SetRange("Voucher No.", Voucher."No.");
        _Assert.IsTrue(NpRvSalesLine.IsEmpty(), 'The facade must not persist voucher sales lines.');
    end;

    [Test]
    procedure LocationHelper_ResolvesTheLinkOfTheRequestedStore()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A Shopify location id linked in two stores resolves, for the store whose link was assigned second, to that store's own Location Code and not to the first store's.
        // [GIVEN] Two Shopify stores
        LibrarySpfyImport.CreateStore('SPFYLRLOC1');
        LibrarySpfyImport.CreateStore('SPFYLRLOC2');

        // [GIVEN] Store 1 links location A to Shopify location 71001 and store 2 links location B to the same id
        _Lib.CreateLocationLink('SPFYLRLOC1', 'SPFYLRA', '71001');
        _Lib.CreateLocationLink('SPFYLRLOC2', 'SPFYLRB', '71001');

        // [WHEN] Resolving 71001 for store 2, whose link was assigned second
        Succeeded := SpfyStoreLinkMgt.FindLocationCodeByShopifyLocationID('SPFYLRLOC2', '71001', LocationCode);

        // [THEN] The linked location must be found
        _Assert.IsTrue(Succeeded, 'The linked location must be found.');

        // [THEN] Store 2's own location is returned, not store 1's
        _Assert.AreEqual('SPFYLRB', LocationCode, 'The requested store''s own link must win.');
    end;

    [Test]
    procedure LocationHelper_ResolvesTheLinkOfTheFirstStore()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A Shopify location id linked in two stores resolves, for the store whose link was assigned first, to that store's own Location Code.
        // [GIVEN] Two Shopify stores
        LibrarySpfyImport.CreateStore('SPFYLRLOC4');
        LibrarySpfyImport.CreateStore('SPFYLRLOC5');

        // [GIVEN] Store 1 links location A to Shopify location 71001 and store 2 links location B to the same id
        _Lib.CreateLocationLink('SPFYLRLOC4', 'SPFYLRA', '71001');
        _Lib.CreateLocationLink('SPFYLRLOC5', 'SPFYLRB', '71001');

        // [WHEN] Resolving 71001 for store 1
        Succeeded := SpfyStoreLinkMgt.FindLocationCodeByShopifyLocationID('SPFYLRLOC4', '71001', LocationCode);

        // [THEN] The linked location must be found
        _Assert.IsTrue(Succeeded, 'The linked location must be found.');

        // [THEN] Store 1's own location is returned
        _Assert.AreEqual('SPFYLRA', LocationCode, 'The requested store''s own link must win.');
    end;

    [Test]
    procedure LocationHelper_UnmappedIdIsNotFoundAndLeavesLocationBlank()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyStoreLinkMgt: Codeunit "NPR Spfy Store Link Mgt.";
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] An id no store links is not found and leaves the location blank.
        // [GIVEN] A Shopify store
        LibrarySpfyImport.CreateStore('SPFYLRLOC3');

        // [GIVEN] The store links location A to Shopify location 71001
        _Lib.CreateLocationLink('SPFYLRLOC3', 'SPFYLRA', '71001');

        // [GIVEN] LocationCode preset to a non-blank value so the blank-out is observable
        LocationCode := 'SPFYLRA';

        // [WHEN] Resolving an id no store has linked
        Succeeded := SpfyStoreLinkMgt.FindLocationCodeByShopifyLocationID('SPFYLRLOC3', '79999', LocationCode);

        // [THEN] An unmapped id must not resolve
        _Assert.IsFalse(Succeeded, 'An unmapped id must not resolve.');

        // [THEN] The location code is left blank
        _Assert.AreEqual('', LocationCode, 'An unresolved id must leave the location code blank.');
    end;

    [Test]
    procedure ApiHelper_GetReturnList_UsesInjectedGraphQLClient()
    var
        ShopifyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        ShopifyResponse: JsonToken;
        OrdersArr: JsonArray;
        Cursor: Text;
        HasNext: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] The return list query goes through the injected GraphQL client, so tests can answer it without a Shopify URL.
        // [GIVEN] A Shopify store
        LibrarySpfyImport.CreateStore('SPFYLRAPI');
        ShopifyStore.Get('SPFYLRAPI');

        // [GIVEN] A mock client answering the orders query with one closed return
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9001', '#9001', 'gid://shopify/Return/555', '#9001-R1'));
        SpfyOrderApiHelper.SetGraphQLClient(MockClient);

        // [WHEN] The list is fetched
        Succeeded := SpfyOrderApiHelper.GetReturnList(HasNext, ShopifyResponse, ShopifyStore, OrdersArr, Cursor, 'updated_at:>=''2026-01-01''');

        // [THEN] The list call must succeed through the mock
        _Assert.IsTrue(Succeeded, 'The list call must succeed through the mock.');

        // [THEN] One order edge comes back and the mock saw exactly one request
        _Assert.AreEqual(1, OrdersArr.Count(), 'One order must be listed.');
        _Assert.AreEqual(1, MockClient.RequestCount(), 'Exactly one request must have been sent.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_FillsHeaderLinesAndTransactions()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        CardTxnWithoutProcessedAt: Text;
        GiftCardProcessedAt: DateTime;
    begin
        // [SCENARIO] Parsing a return detail response yields one header row with the presentment currency, one line with gross price and VAT %, and refund transactions carrying their gift card id and creation time.
        // [GIVEN] A closed return of 2 units at net 400 plus tax 100 (25 %), restocked to location 71001, refunded 300 by card with no processedAt and 200 to gift card 9001
        CardTxnWithoutProcessedAt := _Lib.RefundTxnJson('1', 'shopify_payments', 300, _Lib.Lcy(), '').Replace('"processedAt":"2026-09-20T10:00:00Z",', '');
        Response.ReadFrom(_Lib.ReturnDetailResponse('555', '9001', '#9001', 'SPFYSNOW', '601', 2, 400, 100, 25, '71001',
            CardTxnWithoutProcessedAt + ',' + _Lib.RefundTxnJson('2', 'gift_card', 200, _Lib.Lcy(), '9001'), _Lib.Lcy()));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '555', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The header carries the order, the presentment currency and no exchange
        TempReturnBuffer.Get('555');
        _Assert.AreEqual('9001', TempReturnBuffer."Order Id", 'Order id must be the numeric id.');
        _Assert.AreEqual(_Lib.Lcy(), TempReturnBuffer."Presentment Currency Code", 'Currency must be the presentment currency.');
        _Assert.IsFalse(TempReturnBuffer."Has Exchange Line", 'No exchange line in the fixture.');

        // [THEN] The line is gross 500 for 2 units at 25 %, restocked to 71001
        _Assert.AreEqual(1, TempLineBuffer.Count(), 'One line expected.');
        TempLineBuffer.FindFirst();
        _Assert.AreEqual(500, TempLineBuffer."Line Amount", 'Line amount is net plus tax.');
        _Assert.AreEqual(250, TempLineBuffer."Unit Price", 'Unit price is gross per unit.');
        _Assert.AreEqual(25, TempLineBuffer."VAT %", 'VAT % comes from the tax line rate.');
        _Assert.AreEqual('71001', TempLineBuffer."Disposition Location Id", 'Restock location id must be numeric.');
        _Assert.IsFalse(TempLineBuffer."Not Restocked", 'A RESTOCKED disposition keeps the flag off.');
        _Assert.AreEqual('601', TempLineBuffer."Order Line Item Id", 'Order line item id must be numeric.');

        // [THEN] Two refund transactions, the second with its gift card id
        _Assert.AreEqual(2, TempRefundTxnBuffer.Count(), 'Two successful REFUND transactions expected.');
        TempRefundTxnBuffer.FindLast();
        _Assert.AreEqual('9001', TempRefundTxnBuffer."Gift Card Id", 'Gift card id must be parsed from receiptJson.');
        _Assert.AreEqual(200, TempRefundTxnBuffer.Amount, 'Transaction amount is the presentment amount.');
        GiftCardProcessedAt := TempRefundTxnBuffer."Processed At";

        // [THEN] The card transaction without processedAt still carries its createdAt, the same instant the gift card transaction was processed at
        TempRefundTxnBuffer.FindFirst();
        _Assert.AreEqual(0DT, TempRefundTxnBuffer."Processed At", 'The fixture has no processedAt on the card transaction.');
        _Assert.AreNotEqual(0DT, TempRefundTxnBuffer."Created At", 'createdAt must be parsed as the fallback refund date.');
        _Assert.AreEqual(GiftCardProcessedAt, TempRefundTxnBuffer."Created At", 'createdAt must be parsed from the transaction.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TruncatedRefundsIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A refunds connection with more pages than one request reads is refused with an error naming the connection, so no amount is computed from partial data.
        // [GIVEN] A detail response whose refunds pageInfo says hasNextPage true
        ResponseText := _Lib.ReturnDetailResponse('556', '9002', '#9002', 'SPFYSNOW', '602', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('3', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"refunds":{"pageInfo":{"hasNextPage":false}', '"refunds":{"pageInfo":{"hasNextPage":true}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '556', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the truncated connection
        _Assert.ExpectedError('refunds');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TruncatedReverseFulfillmentIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A reverseFulfillmentOrders connection with more pages than one request reads is refused with an error naming the connection, so disposition data is never read from a partial page.
        // [GIVEN] A detail response whose reverseFulfillmentOrders pageInfo says hasNextPage true
        ResponseText := _Lib.ReturnDetailResponse('558', '9004', '#9004', 'SPFYSNOW', '604', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('5', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"reverseFulfillmentOrders":{"pageInfo":{"hasNextPage":false}', '"reverseFulfillmentOrders":{"pageInfo":{"hasNextPage":true}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '558', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the truncated connection
        _Assert.ExpectedError('reverseFulfillmentOrders');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_MixedDispositions_KeepsRestockedLocationAndFlagsNotRestocked()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A return line disposed both as restocked and rejected keeps the restocked location and is flagged as not fully restocked.
        // [GIVEN] A closed return whose only line carries a RESTOCKED disposition to location 71001 followed by a REJECTED disposition to location 71002
        Response.ReadFrom(_Lib.ReturnDetailResponse('559', '9005', '#9005', 'SPFYSNOW', '605', 1, 100, 25, 25, '71001',
            _Lib.RefundTxnJson('6', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.MixedDispositionsJson('71001', '71002')));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '559', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The restocked disposition's location is kept even though the rejected disposition is processed after it
        TempLineBuffer.FindFirst();
        _Assert.AreEqual('71001', TempLineBuffer."Disposition Location Id", 'The RESTOCKED disposition''s location must win over a later REJECTED disposition.');

        // [THEN] The line is flagged as not fully restocked because of the REJECTED disposition
        _Assert.IsTrue(TempLineBuffer."Not Restocked", 'A REJECTED disposition must flag the line as not restocked.');
    end;

    [Test]
    procedure Mgt_FindPostedDocument_MatchesCreditMemoOfSameStore()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        PostedDocNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A posted credit memo carrying the return's Entry ID and Store Code is found for that store.
        // [GIVEN] Two Shopify stores
        LibrarySpfyImport.CreateStore('SPFYLRM1');
        LibrarySpfyImport.CreateStore('SPFYLRM2');

        // [GIVEN] Credit memo SCM-LR1 stamped with return 777 of store 1
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR1', 'SPFYLRM1', '777');

        // [WHEN] Looking the return up for store 1
        Succeeded := SpfyLegacyReturnMgt.FindPostedDocumentForReturn('SPFYLRM1', "NPR Spfy Legacy Return Source"::Return, '777', PostedDocNo);

        // [THEN] The credit memo must be found for its own store
        _Assert.IsTrue(Succeeded, 'The credit memo must be found for its own store.');

        // [THEN] The credit memo number comes back
        _Assert.AreEqual('SCM-LR1', PostedDocNo, 'The posted document number must be returned.');
    end;

    [Test]
    procedure Mgt_FindPostedDocument_IgnoresOtherStores()
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        PostedDocNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A posted credit memo carrying a return id is not found for another store with the same return id.
        // [GIVEN] Two Shopify stores
        LibrarySpfyImport.CreateStore('SPFYLRM4');
        LibrarySpfyImport.CreateStore('SPFYLRM5');

        // [GIVEN] Credit memo SCM-LR2 stamped with return 777 of store 1
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR2', 'SPFYLRM4', '777');

        // [WHEN] Looking the return up for store 2
        Succeeded := SpfyLegacyReturnMgt.FindPostedDocumentForReturn('SPFYLRM5', "NPR Spfy Legacy Return Source"::Return, '777', PostedDocNo);

        // [THEN] Another store must not match on the return id alone
        _Assert.IsFalse(Succeeded, 'Another store must not match on the return id alone.');

        // [THEN] No posted document number is returned
        _Assert.AreEqual('', PostedDocNo, 'No posted document must be returned for another store.');
    end;

    [Test]
    procedure Mgt_DiscardDraft_DeletesDraftAndPaymentLinesAndClearsRow()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        QueueRow: Record "NPR Spfy NC Return Queue";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
    begin
        // [SCENARIO] Discarding a draft deletes the Return Order and its payment lines and blanks everything on the row that described the draft.
        // [GIVEN] A Shopify store
        LibrarySpfyImport.CreateStore('SPFYLRM3');

        // [GIVEN] A queue row linked to draft RO-LR1 that has one payment line and a voucher note
        _Lib.InsertReturnOrderWithReturnIds('RO-LR1', 'SPFYLRM3', '778', SalesHeader);
        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := 10000;
        PaymentLine.Amount := 100;
        PaymentLine.Insert();
        _Lib.InsertQueueRow('SPFYLRM3', '778', '9003', QueueRow);
        QueueRow."Sales Header Doc. No." := SalesHeader."No.";
        QueueRow."Location Fallback Used" := true;
        QueueRow."Not Restocked" := true;
        QueueRow.Modify();
        _Lib.SetSettlement(QueueRow, 50, 'V-OLD');

        // [WHEN] The draft is discarded
        SpfyLegacyReturnMgt.DiscardDraft(QueueRow);

        // [THEN] The header and its payment line are gone and the row no longer claims them
        _Assert.IsFalse(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", 'RO-LR1'), 'The draft must be deleted.');
        PaymentLine.SetRange("Document No.", 'RO-LR1');
        _Assert.IsTrue(PaymentLine.IsEmpty(), 'Payment lines of the draft must be deleted.');
        _Assert.AreEqual('', QueueRow."Sales Header Doc. No.", 'The row must forget the draft.');
        _Assert.IsFalse(QueueRow."Location Fallback Used", 'The row must forget the location fallback flag.');
        _Assert.IsFalse(QueueRow."Not Restocked", 'The row must forget the not-restocked flag.');
        _Assert.IsFalse(_Lib.SettlementExists(QueueRow), 'The row must forget the gift card share and the voucher: the draft''s settlement row is removed with it.');
    end;

    [Test]
    procedure Mgt_DeletingQueueRow_RemovesItsDraftWithoutCommit()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        QueueRow: Record "NPR Spfy NC Return Queue";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] Deleting a queue row whose return has no posted document deletes its draft Return Order and payment line from the OnDelete trigger, through the OnDelete trigger alone.
        // [GIVEN] A Shopify store
        LibrarySpfyImport.CreateStore('SPFYLRM6');

        // [GIVEN] A queue row linked to draft RO-LR2 that has one payment line
        _Lib.InsertReturnOrderWithReturnIds('RO-LR2', 'SPFYLRM6', '779', SalesHeader);
        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Header";
        PaymentLine."Document Type" := SalesHeader."Document Type";
        PaymentLine."Document No." := SalesHeader."No.";
        PaymentLine."Line No." := 10000;
        PaymentLine.Amount := 75;
        PaymentLine.Insert();
        _Lib.InsertQueueRow('SPFYLRM6', '779', '9004', QueueRow);
        QueueRow."Sales Header Doc. No." := SalesHeader."No.";
        QueueRow.Modify();

        // [WHEN] The queue row is deleted
        QueueRow.Delete(true);

        // [THEN] The draft and its payment line are gone and the queue row no longer exists
        _Assert.IsFalse(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", 'RO-LR2'), 'The draft must be deleted.');
        PaymentLine.SetRange("Document No.", 'RO-LR2');
        _Assert.IsTrue(PaymentLine.IsEmpty(), 'Payment lines of the draft must be deleted.');
        _Assert.IsFalse(QueueRow.FindSourceDoc('SPFYLRM6', QueueRow."Source Doc. Type"::Return, '779'), 'The queue row must be deleted.');
    end;

    [Test]
    procedure Mgt_DeletingQueueRowOfPostedReturn_LeavesDocumentsAlone()
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        QueueRow: Record "NPR Spfy NC Return Queue";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] Deleting a queue row whose return was already posted, but whose row had not yet recorded the posted document, succeeds without error and leaves the posted document alone.
        // [GIVEN] A Shopify store
        LibrarySpfyImport.CreateStore('SPFYLRM7');

        // [GIVEN] A queue row for return 780 whose credit memo SCM-LR3 already carries the return's ids, with "Posted Doc. No." still blank on the row
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR3', 'SPFYLRM7', '780');
        _Lib.InsertQueueRow('SPFYLRM7', '780', '9005', QueueRow);

        // [WHEN] The queue row is deleted
        QueueRow.Delete(true);

        // [THEN] No error is raised, the credit memo still exists and the queue row is gone
        _Assert.IsTrue(SalesCrMemoHeader.Get('SCM-LR3'), 'The posted credit memo must be left alone.');
        _Assert.IsFalse(QueueRow.FindSourceDoc('SPFYLRM7', QueueRow."Source Doc. Type"::Return, '780'), 'The queue row must be deleted.');
    end;

    [Test]
    procedure Import_CardRefund_BuildsDraftWithGrossLinesPaymentLinesAndIds()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentLine: Record "NPR Magento Payment Line";
        VATPostingSetup: Record "VAT Posting Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Importing a card-refunded return without automatic posting creates one Return Order whose line carries the gross refunded amount at the item's own VAT %, whose payment line mirrors the refund transaction, whose header carries the return id and store code, and whose Payment Method Code is blank.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Automatic posting is switched off so the draft stays open
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] A queued return of 2 units at gross 500 refunded 500 by card, whose tax line reports a 13 % rate the item's VAT setup does not use, and a mock answering the detail query
        _Lib.InsertQueueRow(StoreCode, '801', '9801', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('801', '9801', '#9801', Sku, '601', 2, 400, 100, 13, '71001', _Lib.RefundTxnJson('1', 'shopify_payments', 500, _Lib.Lcy(), ''), _Lib.Lcy()));
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);

        // [WHEN] The import runs
        SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] One Return Order exists for the customer with the ids stamped and no payment method
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.AreEqual(1, SalesHeader.Count(), 'Exactly one Return Order must exist.');
        SalesHeader.FindFirst();
        _Assert.AreEqual(SalesHeader."No.", QueueRow."Sales Header Doc. No.", 'The row must link the draft.');
        _Assert.AreEqual('801', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'Entry ID must be the return id.');
        _Assert.AreEqual(StoreCode, SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code"), 'Store Code must be stamped.');
        _Assert.IsTrue(SalesHeader."Prices Including VAT", 'Prices must include VAT.');
        _Assert.AreEqual('', SalesHeader."Payment Method Code", 'Payment Method Code must be blank so BC does not balance the credit memo itself.');
        _Assert.AreEqual(LocationCode, SalesHeader."Location Code", 'Header location comes from the restock disposition.');
        _Assert.AreEqual('', SalesHeader."Bal. Account No.", 'No balancing account may be set, settlement runs through the payment lines.');
        QueueRow.Find();
        _Assert.IsFalse(QueueRow."Location Fallback Used", 'The location came from the disposition, not from the NpEc Store fallback.');

        // [THEN] The line carries quantity 2, gross line amount 500 at the VAT % of its own VAT Posting Setup, and the order line id
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        _Assert.AreEqual(2, SalesLine.Quantity, 'Quantity from the return line.');
        _Assert.AreEqual(500, SalesLine."Amount Including VAT", 'Line amount is pinned to the gross refunded.');
        VATPostingSetup.Get(SalesLine."VAT Bus. Posting Group", SalesLine."VAT Prod. Posting Group");
        _Assert.AreEqual(VATPostingSetup."VAT %", SalesLine."VAT %", 'VAT % follows the line''s VAT Posting Setup, not the rate Shopify reports.');
        _Assert.AreEqual('601', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'Line Entry ID is the order line item id.');

        // [THEN] One payment line of 500 mirrors the refund transaction
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        _Assert.AreEqual(1, PaymentLine.Count(), 'One payment line per refund transaction.');
        PaymentLine.FindFirst();
        _Assert.AreEqual(500, PaymentLine.Amount, 'Payment line amount is the refund amount.');
        _Assert.AreEqual('1', PaymentLine."External Reference No.", 'Payment line references the transaction id.');
        _Assert.AreNotEqual(0D, PaymentLine."Date Refunded", 'Payment line carries the refund date.');
    end;

    [Test]
    procedure Import_UnknownSku_RollsBackEverything()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return with an unknown SKU fails and leaves no Return Order behind, because the import runs as one transaction that rolls back on error.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A queued return whose only line has a SKU that exists nowhere in BC
        _Lib.InsertQueueRow(StoreCode, '802', '9802', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('802', '9802', '#9802', 'SC-DOES-NOT-EXIST', '602', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('2', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);
        Commit();

        // [WHEN] The import runs and fails
        Succeeded := SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] The import must fail on the unknown SKU
        _Assert.IsFalse(Succeeded, 'The import must fail on the unknown SKU.');

        // [THEN] The error names the SKU and no Return Order exists for the customer
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SC-DOES-NOT-EXIST') > 0, 'The error must name the SKU.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'A failed import must leave no Return Order.');
    end;

    [Test]
    procedure Import_NoRefundTransaction_IsRefusedWithoutADocument()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A closed return whose refund was made on the order rather than the return has no refund transactions and is refused, so no zero-value credit memo is ever created.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A queued return with a line but no successful REFUND transaction
        _Lib.InsertQueueRow(StoreCode, '803', '9803', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('803', '9803', '#9803', Sku, '603', 1, 80, 20, 25, '71001', '', _Lib.Lcy()));
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);
        Commit();

        // [WHEN] The import runs
        Succeeded := SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] The import must fail when nothing was refunded
        _Assert.IsFalse(Succeeded, 'The import must fail when nothing was refunded.');

        // [THEN] The error explains the missing refund and no document exists
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'carries no completed refund') > 0, 'The error must explain the missing refund.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No document may remain.');
    end;

    [Test]
    procedure Import_ExchangeLine_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ResponseText: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return that contains an exchange line is refused with an explicit error.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A detail response with one exchange line item
        _Lib.InsertQueueRow(StoreCode, '804', '9804', QueueRow);
        ResponseText := _Lib.ReturnDetailResponse('804', '9804', '#9804', Sku, '604', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('4', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"exchangeLineItems":{"edges":[]}', '"exchangeLineItems":{"edges":[{"node":{"id":"gid://shopify/ExchangeLineItem/1"}}]}');
        MockClient.AddResponse('GetReturn', ResponseText);
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);
        Commit();

        // [WHEN] The import runs
        Succeeded := SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] The import must fail on an exchange
        _Assert.IsFalse(Succeeded, 'The import must fail on an exchange.');

        // [THEN] The error mentions the exchange
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'exchange') > 0, 'The error must name the exchange line.');
    end;

    [Test]
    procedure Import_ForeignCurrency_SetsPresentmentCurrencyOnHeader()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        Currency: Record Currency;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        LibraryERM: Codeunit "Library - ERM";
        ResponseText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A return refunded in a currency other than LCY creates the Return Order in the presentment currency, not the shop currency.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Automatic posting is switched off so the draft stays open
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] A currency with an exchange rate valid on the return's closing date, 2026-09-20, and a return presented in it on an order whose shop currency is another code
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 7.5);
        _Lib.InsertQueueRow(StoreCode, '805', '9805', QueueRow);
        ResponseText := _Lib.ReturnDetailResponse('805', '9805', '#9805', Sku, '605', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('5', 'shopify_payments', 100, Currency.Code, ''), Currency.Code);
        _Assert.IsTrue(StrPos(ResponseText, '"currencyCode":"' + Currency.Code + '","presentmentCurrencyCode":"' + Currency.Code + '"') > 0, 'Precondition: the fixture carries both currency codes.');
        ResponseText := ResponseText.Replace('"currencyCode":"' + Currency.Code + '","presentmentCurrencyCode"', '"currencyCode":"XXX","presentmentCurrencyCode"');
        MockClient.AddResponse('GetReturn', ResponseText);
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);

        // [WHEN] The import runs
        SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] The header carries the presentment currency
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        _Assert.AreEqual(Currency.Code, SalesHeader."Currency Code", 'Header currency must be the presentment currency, not the shop currency.');
    end;

    [Test]
    procedure Import_UnevenQuantity_PinsLineAmountToGross()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesLine: Record "Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A gross that does not divide evenly by the quantity still lands on the line exactly, because the unit price is rounded up and the line amount is pinned back to the gross.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Automatic posting is switched off so the draft stays open
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] A queued return of 3 units at gross 100 (net 80, tax 20) refunded 100 by card
        _Lib.InsertQueueRow(StoreCode, '806', '9806', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('806', '9806', '#9806', Sku, '606', 3, 80, 20, 25, '71001', _Lib.RefundTxnJson('6', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);

        // [WHEN] The import runs
        SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] The item line carries quantity 3 and exactly the gross 100
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        _Assert.AreEqual(3, SalesLine.Quantity, 'Quantity from the return line.');
        _Assert.AreEqual(100, SalesLine."Amount Including VAT", 'Line amount is pinned to the gross refunded even when it does not divide by the quantity.');
    end;

    [Test]
    procedure Import_TwoGiftCards_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher1: Record "NPR NpRv Voucher";
        Voucher2: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        TransactionsJson: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded to two gift cards is refused for manual handling, because the money cannot be credited back to the right vouchers and a card left short would have its refund taken back by the balance sync.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Automatic posting is switched off so the draft stays open
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] Shopify gift cards 9001 and 9002 each mapped to a voucher
        _Lib.CreateVoucherWithGiftCardId('SPFYLRV871', StoreCode, '9001', Voucher1);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRV872', StoreCode, '9002', Voucher2);

        // [GIVEN] The original order's posted invoice was paid with exactly one voucher, so the order fallback would find it
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR807', StoreCode, '9807', Voucher1."No.");

        // [GIVEN] A queued return of gross 200 refunded 100 and 50 to the two gift cards and 50 by card
        _Lib.InsertQueueRow(StoreCode, '807', '9807', QueueRow);
        TransactionsJson := _Lib.RefundTxnJson('71', 'gift_card', 100, _Lib.Lcy(), '9001') + ',' + _Lib.RefundTxnJson('72', 'gift_card', 50, _Lib.Lcy(), '9002') + ',' + _Lib.RefundTxnJson('73', 'shopify_payments', 50, _Lib.Lcy(), '');
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('807', '9807', '#9807', Sku, '607', 1, 160, 40, 25, '71001', TransactionsJson, _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The import is refused naming the return and the gift cards, and no draft is left
        _Assert.IsFalse(Succeeded, 'Gift cards that cannot be told apart must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9807-R1') > 0, 'The refusal must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'gift cards') > 0, 'The refusal must name the gift cards: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual('', QueueRow."Sales Header Doc. No.", 'No draft may be left.');
    end;

    [Test]
    procedure Import_SameGiftCardTwice_CreditsThatCardBackOnce()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        TransactionsJson: Text;
    begin
        // [SCENARIO] A return refunded to the same gift card in two transactions counts as one gift card, so the row records the combined share and names that card's voucher to credit back.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Automatic posting is switched off so the draft stays open
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] Shopify gift card 9003 mapped to a voucher
        _Lib.CreateVoucherWithGiftCardId('SPFYLRV1505', StoreCode, '9003', Voucher);

        // [GIVEN] A queued return of gross 200 refunded 100 and 50 to gift card 9003 in two transactions and 50 by card
        _Lib.InsertQueueRow(StoreCode, '1505', '9505', QueueRow);
        TransactionsJson := _Lib.RefundTxnJson('15051', 'gift_card', 100, _Lib.Lcy(), '9003') + ',' + _Lib.RefundTxnJson('15052', 'gift_card', 50, _Lib.Lcy(), '9003') + ',' + _Lib.RefundTxnJson('15053', 'shopify_payments', 50, _Lib.Lcy(), '');
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1505', '9505', '#9505', Sku, '1505', 1, 160, 40, 25, '71001', TransactionsJson, _Lib.Lcy()));
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);

        // [WHEN] The import runs
        SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] The row records the 150 gift card share and names the voucher behind gift card 9003
        QueueRow.Find();
        _Assert.IsTrue((_Lib.SettledGiftCardAmount(QueueRow) <> 0), 'The row must flag the gift card refund.');
        _Assert.AreEqual(150, _Lib.SettledGiftCardAmount(QueueRow), 'The gift card share is the sum of both transactions to the card.');
        _Assert.AreEqual(Voucher."No.", _Lib.SettledVoucherNo(QueueRow), 'One card refunded twice must still resolve to its voucher.');
    end;

    [Test]
    procedure Import_AdoptedDraft_RederivesGiftCardShareBeforePosting()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        PaymentMethod: Record "Payment Method";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        LibraryPaymentExport: Codeunit "Library - Payment Export";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ResponseText: Text;
    begin
        // [SCENARIO] A draft found through the shared return marker is adopted with its Payment Method Code blanked, and the row's gift card share, voucher and order number are re-derived from Shopify so settlement does not put everything on the card account.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Automatic posting is switched off so the adopted draft stays open
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] Shopify gift card 9004 mapped to a voucher and a return of gross 200 refunded 200 to that card
        _Lib.CreateVoucherWithGiftCardId('SPFYLRV881', StoreCode, '9004', Voucher);
        ResponseText := _Lib.ReturnDetailResponse('808', '9808', '#9808', Sku, '608', 1, 160, 40, 25, '71001', _Lib.RefundTxnJson('81', 'gift_card', 200, _Lib.Lcy(), '9004'), _Lib.Lcy());

        // [GIVEN] A Return Order for the return that carries its marker but is not linked to the queue row, as the other engine leaves it
        _Lib.InsertQueueRow(StoreCode, '808', '9808', QueueRow);
        _Lib.BuildUnlinkedDraft(QueueRow, ResponseText, SalesHeader);

        // [GIVEN] The draft carries a payment method, and the row has none of the gift card bookkeeping
        LibraryPaymentExport.CreatePaymentMethod(PaymentMethod);
        SalesHeader."Payment Method Code" := PaymentMethod.Code;
        SalesHeader.Modify();
        QueueRow.Find();
        QueueRow."Order No." := '';
        QueueRow.Modify();
        _Lib.SetSettlement(QueueRow, 0, '');

        // [GIVEN] A mock answering the detail query the adoption makes
        MockClient.AddResponse('GetReturn', ResponseText);
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);

        // [WHEN] The import runs
        SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] The row links the adopted document and carries the re-derived gift card share and voucher
        QueueRow.Find();
        _Assert.AreEqual(SalesHeader."No.", QueueRow."Sales Header Doc. No.", 'The row must link the adopted draft.');
        _Assert.AreEqual(200, _Lib.SettledGiftCardAmount(QueueRow), 'The gift card share must be re-derived from the detail.');
        _Assert.AreEqual(Voucher."No.", _Lib.SettledVoucherNo(QueueRow), 'The voucher behind the gift card must be re-derived.');
        _Assert.AreEqual('#9808', QueueRow."Order No.", 'The order number comes from the detail''s order name.');

        // [THEN] The adopted draft no longer carries a payment method, so BC does not balance the credit memo itself
        SalesHeader.Find();
        _Assert.AreEqual('', SalesHeader."Payment Method Code", 'The adopted draft must have its Payment Method Code blanked.');

        // [THEN] No second Return Order was built for the return
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Header", "NPR Spfy ID Type"::"Entry ID", '808', ShopifyAssignedID);
        _Assert.AreEqual(1, ShopifyAssignedID.Count(), 'Only the adopted document may carry the return id.');
    end;

    [Test]
    procedure Posting_AdoptedDraftWithUndatedPaymentLine_IsDatedAndSettledOnce()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PaymentLine: Record "NPR Magento Payment Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ResponseText: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] An adopted draft whose payment line has no Date Refunded gets the refund date stamped before posting, so the credit memo's payment line counts as already refunded and the refund is settled once, through the journal only.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);

        // [GIVEN] A Return Order for return 1602, refunded 100 by card, that carries the return's marker but is not linked to the queue row
        ResponseText := _Lib.ReturnDetailResponse('1602', '9602', '#9602', Sku, '1602', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1602', 'shopify_payments', 100, _Lib.Lcy(), '').Replace('"processedAt":"2026-09-20T10:00:00Z"', '"processedAt":"2026-09-22T10:00:00Z"'), _Lib.Lcy());
        _Lib.InsertQueueRow(StoreCode, '1602', '9602', QueueRow);
        _Lib.BuildUnlinkedDraft(QueueRow, ResponseText, SalesHeader);

        // [GIVEN] The draft's payment line has a blank Date Refunded, as the other engine writes it
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", SalesHeader."Document Type");
        PaymentLine.SetRange("Document No.", SalesHeader."No.");
        PaymentLine.FindFirst();
        PaymentLine."Date Refunded" := 0D;
        PaymentLine.Modify();

        // [GIVEN] A mock answering the detail query the adoption makes
        MockClient.AddResponse('GetReturn', ResponseText);

        // [WHEN] The import adopts the draft and posts it
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Adopting and posting must succeed
        _Assert.IsTrue(Succeeded, 'Adopting and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo's payment line carries a Date Refunded
        _Lib.GetCreditMemoForReturnOrder(SalesHeader."No.", SalesCrMemoHeader);
        PaymentLine.Reset();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        PaymentLine.FindFirst();
        _Assert.AreEqual(20260922D, PaymentLine."Date Refunded", 'The payment line must carry the refund''s processed day, or posting asks the gateway to refund it again.');

        // [THEN] Exactly one Refund entry settles the credit memo
        CustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Refund);
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.AreEqual(1, CustLedgerEntry.Count(), 'Exactly one settlement must be posted.');

        // [THEN] The settlement credits 100 to the card clearing account
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-100, GLEntry.Amount, 'The refund must be settled once on the clearing account.');
    end;

    [Test]
    procedure Import_AdoptedDraftShortOfTheRefund_IsRefusedAndKept()
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
        // [SCENARIO] An adopted draft whose lines total less than Shopify refunded is refused with the short-total error, as a draft built here would be, and the draft is left as it was.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A Return Order for return 1603 worth 100 that carries the return's marker but is not linked to the queue row
        _Lib.InsertQueueRow(StoreCode, '1603', '9603', QueueRow);
        _Lib.BuildUnlinkedDraft(QueueRow, _Lib.ReturnDetailResponse('1603', '9603', '#9603', Sku, '1603', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1603', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()), SalesHeader);

        // [GIVEN] Shopify reports a refund of 125 for the return
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1603', '9603', '#9603', Sku, '1603', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1603', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import tries to adopt the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A draft short of the refund must not be adopted
        _Assert.IsFalse(Succeeded, 'A draft short of the refund must not be adopted.');

        // [THEN] The error is the short-total error
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'short by') > 0, 'The error must report the short total: ' + GetLastErrorText());

        // [THEN] The draft still exists and the row does not link it
        _Assert.IsTrue(SalesHeader.Find(), 'The refused draft must survive.');
        QueueRow.Find();
        _Assert.AreEqual('', QueueRow."Sales Header Doc. No.", 'A refused adoption must not link the draft.');
    end;

    [Test]
    procedure Import_WithheldFee_AddsNegativeFeeLineAtAccountVat()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A return fee Shopify held back becomes a negative G/L line on the store's fee account, carrying the VAT its account's posting setup prescribes, so the document total equals what was refunded.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Automatic posting is switched off so the draft stays open
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] A queued return of gross 100 with a 15 return shipping fee withheld, refunded 85 by card
        _Lib.InsertQueueRow(StoreCode, '809', '9809', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('809', '9809', '#9809', Sku, '609', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('9', 'shopify_payments', 85, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), _Lib.ReturnShippingFeeJson(15), ''));
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);

        // [WHEN] The import runs
        SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] A G/L line on the fee account carries unit price -15 and the VAT % of the account's posting setup
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
        SalesLine.SetRange("No.", ShopifyStore."Return Fee G/L Account No.");
        _Assert.IsTrue(SalesLine.FindFirst(), 'A fee line must exist on the store''s fee account.');
        _Assert.AreEqual(-15, SalesLine."Unit Price", 'The fee line credits back the withheld amount.');
        Customer.Get(CustomerNo);
        GLAccount.Get(ShopifyStore."Return Fee G/L Account No.");
        VATPostingSetup.Get(Customer."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
        _Assert.AreNotEqual(0, VATPostingSetup."VAT %", 'The fixture account must carry VAT for this test to discriminate.');
        _Assert.AreEqual(VATPostingSetup."VAT %", SalesLine."VAT %", 'The fee line follows the account''s VAT setup.');

        // [THEN] The document total equals the 85 refunded
        SalesLine.SetRange(Type);
        SalesLine.SetRange("No.");
        SalesLine.CalcSums("Amount Including VAT");
        _Assert.AreEqual(85, SalesLine."Amount Including VAT", 'The document total must equal the refund.');
    end;

    [Test]
    procedure Import_ShippingRefundWithoutAccount_FailsNamingTheAccount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refunded shipping cost with no shipping refund account on the store fails the import and names the missing setup field, instead of crediting less than was refunded.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] The store has no shipping refund account
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Ret. Shipping Refund G/L Acc." := '';
        ShopifyStore.Modify();

        // [GIVEN] A queued return of gross 100 plus a refunded shipping line of 20 net and 5 tax, refunded 125 by card
        _Lib.InsertQueueRow(StoreCode, '810', '9810', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('810', '9810', '#9810', Sku, '610', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('10', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), '[]', _Lib.RefundShippingLineJson(20, 5)));
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);
        Commit();

        // [WHEN] The import runs
        Succeeded := SpfyLegacyReturnImport.Run(QueueRow);

        // [THEN] The import must fail when the shipping refund has no account
        _Assert.IsFalse(Succeeded, 'The import must fail when the shipping refund has no account.');

        // [THEN] The error names the missing shipping refund account field
        _Assert.IsTrue(StrPos(GetLastErrorText(), ShopifyStore.FieldCaption("Ret. Shipping Refund G/L Acc.")) > 0, 'The error must name the shipping refund account field.');
    end;

    [Test]
    procedure Posting_StoreSendsFulfillments_NoFulfillmentTaskForTheReturnReceipt()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ReturnReceiptHeader: Record "Return Receipt Header";
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] Posting an imported return on a store that sends order fulfillments schedules no Shopify fulfillment for the return receipt.
        // [GIVEN] A legacy-path store with automatic posting that sends order fulfillments to Shopify
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Send Order Fulfillments" := true;
        ShopifyStore.Modify();

        // [GIVEN] A queued return refunded 500 by card
        _Lib.InsertQueueRow(StoreCode, '1609', '9609', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1609', '9609', '#9609', Sku, '1609', 2, 400, 100, 25, '71001', _Lib.RefundTxnJson('1609', 'shopify_payments', 500, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        ImportSucceeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: switch fulfillments off again before asserting, since the import committed the store.
        ShopifyStore.Find();
        ShopifyStore."Send Order Fulfillments" := false;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The import and the posting succeeded
        _Assert.IsTrue(ImportSucceeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] A return receipt was posted
        ReturnReceiptHeader.SetRange("Return Order No.", QueueRow."Sales Header Doc. No.");
        _Assert.IsTrue(ReturnReceiptHeader.FindFirst(), 'Posting must create a return receipt.');

        // [THEN] Neither task list holds a fulfillment task for it
        NcTask.SetRange("Table No.", Database::"Return Receipt Header");
        NcTask.SetRange("Record ID", ReturnReceiptHeader.RecordId());
        _Assert.IsTrue(NcTask.IsEmpty(), 'No NaviConnect fulfillment task may be created for a return receipt.');
        SpfyTask.SetRange("Table No.", Database::"Return Receipt Header");
        SpfyTask.SetRange("Record ID", ReturnReceiptHeader.RecordId());
        _Assert.IsTrue(SpfyTask.IsEmpty(), 'No Shopify Task List fulfillment task may be created for a return receipt.');
    end;

    [Test]
    procedure Posting_TaxesIncludedWithReturnShippingFee_CreditsTheRefundedAmount()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        Response: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] On an order with taxes included in prices, the refund line's subtotal already holds the tax, so a return of an item at 49.97 with a 10.00 return shipping fee posts a credit memo of the 39.97 Shopify refunded.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A queued return of one item at 49.97 including 9.99 tax, a 10.00 return shipping fee and 39.97 refunded by card, on an order with taxes included
        _Lib.InsertQueueRow(StoreCode, '1610', '9610', QueueRow);
        Response := _Lib.ReturnDetailResponse('1610', '9610', '#9610', Sku, '1610', 1, 49.97, 9.99, 25, '71001', _Lib.RefundTxnJson('1610', 'shopify_payments', 39.97, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), _Lib.ReturnShippingFeeJson(10), '');
        MockClient.AddResponse('GetReturn', Response.Replace('"taxesIncluded":false', '"taxesIncluded":true'));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo is worth what Shopify refunded
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(39.97, SalesCrMemoHeader."Amount Including VAT", 'The credit memo must equal the refunded amount.');

        // [THEN] The item line carries the price including tax
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        SalesCrMemoLine.FindFirst();
        _Assert.AreEqual(49.97, SalesCrMemoLine."Amount Including VAT", 'The item line must carry the price including tax.');
    end;

    [Test]
    procedure Import_NoRefundOnTheReturn_IsRefusedWithoutADocument()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        ResponseObj: JsonObject;
        RefundsToken: JsonToken;
        NoEdges: JsonArray;
        Response: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A closed return that carries no refund at all, for instance because the refund was made on the order, is refused instead of posting a credit memo of zero.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A queued return whose Shopify detail lists no refunds
        _Lib.InsertQueueRow(StoreCode, '1611', '9611', QueueRow);
        Response := _Lib.ReturnDetailResponse('1611', '9611', '#9611', Sku, '1611', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1611', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseObj.ReadFrom(Response);
        ResponseObj.SelectToken('data.return.refunds', RefundsToken);
        RefundsToken.AsObject().Replace('edges', NoEdges);
        ResponseObj.WriteTo(Response);
        MockClient.AddResponse('GetReturn', Response);

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A return without a refund must be refused
        _Assert.IsFalse(Succeeded, 'A return without a refund must be refused.');

        // [THEN] The error says no refund was found and no Return Order is linked
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'carries no completed refund') > 0, 'The error must name the missing refund: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual('', QueueRow."Sales Header Doc. No.", 'No Return Order may be created.');
    end;

    [Test]
    procedure Import_UnknownGiftCardId_CreditsNoVoucherBack()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        OrderVoucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund to a gift card BC does not know credits no voucher back, not even the one that paid the original order, because it may be a different card.
        // [GIVEN] A legacy-path store with automatic posting off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] The original order was paid with a voucher linked to Shopify gift card 9612
        _Lib.CreateVoucherWithGiftCardId('SPFYLRV1612', StoreCode, '9612', OrderVoucher);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR1612', StoreCode, '9612', OrderVoucher."No.");

        // [GIVEN] A queued return of gross 100 refunded to Shopify gift card 7612, which has no voucher in BC
        _Lib.InsertQueueRow(StoreCode, '1612', '9612', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1612', '9612', '#9612', Sku, '1612', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1612', 'gift_card', 100, _Lib.Lcy(), '7612'), _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The import must build the draft
        _Assert.IsTrue(Succeeded, 'The import must build the draft: ' + GetLastErrorText());

        // [THEN] The gift card refund is flagged but no voucher is chosen
        QueueRow.Find();
        _Assert.IsTrue((_Lib.SettledGiftCardAmount(QueueRow) <> 0), 'The row must flag the gift card refund.');
        _Assert.AreEqual('', _Lib.SettledVoucherNo(QueueRow), 'The order voucher must not be guessed for an unknown gift card.');
    end;

    [Test]
    procedure ProcessJQ_AutomaticPostingOff_RowIsDraftCreatedNotImported()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] With automatic posting off, the process job leaves the row at Draft Created rather than Imported, because nobody has been credited yet.
        // [GIVEN] A legacy-path store with automatic posting off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] A queued return refunded 100 by card whose draft the import already built
        _Lib.InsertQueueRow(StoreCode, '1613', '9613', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1613', '9613', '#9613', Sku, '1613', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1613', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The import must build the draft: ' + GetLastErrorText());
        QueueRow.Find();
        Commit();

        // [WHEN] The process job processes the row
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is at Draft Created and still linked to its Return Order
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::"Draft Created", QueueRow.Status, 'An unposted draft must not count as Imported.');
        _Assert.AreNotEqual('', QueueRow."Sales Header Doc. No.", 'The row must stay linked to its Return Order.');

        // Cleanup: remove the committed rows.
        QueueRow.Delete(true);
        Commit();
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure FeatureFlagOn_IsRefusedWhileALegacyDraftIsNotPosted()
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
        // [SCENARIO] Enabling the feature is refused while a legacy return row still has an unposted draft, so the other engine cannot build a second document for it.
        // [GIVEN] No unprocessed legacy return queue rows are left over from other tests that commit rows, since the pre-flight check scans the whole table regardless of store
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());

        // [GIVEN] A legacy return row at Draft Created
        _Lib.InsertQueueRow(StoreCode, '1614', '9614', QueueRow);
        QueueRow.Status := QueueRow.Status::"Draft Created";
        QueueRow.Modify();

        Clear(_CapturedMessage);
        // [WHEN] The pre-flight check for enabling runs
        Feature.Enabled := true;
        asserterror ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] It refuses, surfacing a message that names the queue
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The message must name the legacy return queue.');
    end;

    [Test]
    procedure StoreDeleted_WithUnfinishedReturns_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A store that still has returns in the legacy queue that are not imported cannot be deleted.
        // [GIVEN] A legacy-path store with a New return in the queue
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1615', '9615', QueueRow);

        // [WHEN] The store is deleted
        ShopifyStore.Get(StoreCode);
        asserterror ShopifyStore.Delete(true);

        // [THEN] The deletion is refused with a message naming the queue
        _Assert.IsTrue(StrPos(GetLastErrorText(), QueueRow.TableCaption()) > 0, 'The error must name the legacy return queue: ' + GetLastErrorText());
    end;

    [Test]
    procedure StoreDeleted_OnlyImportedReturns_RemovesThem()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        LeftoverRow: Record "NPR Spfy NC Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Deleting a store whose legacy returns are all imported removes those queue rows with it.
        // [GIVEN] A legacy-path store whose queue holds only one return, and that one Imported
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LeftoverRow.SetRange("Shopify Store Code", StoreCode);
        LeftoverRow.DeleteAll(false);
        _Lib.InsertQueueRow(StoreCode, '1616', '9616', QueueRow);
        QueueRow.Status := QueueRow.Status::Imported;
        QueueRow.Modify();

        // [WHEN] The store is deleted
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Delete(true);

        // [THEN] The store's queue rows are gone
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        _Assert.IsTrue(QueueRow.IsEmpty(), 'The deleted store must leave no queue rows behind.');
    end;

    [Test]
    procedure Posting_CardRefund_EndToEnd_PostsSettlesAndMarksRow()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        PaymentLine: Record "NPR Magento Payment Line";
        VATEntry: Record "VAT Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A card-refunded return is imported, posted as a credit memo, settled by a Refund journal line on the card account inside the posting, and the row carries the credit memo number.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);

        // [GIVEN] A queued return refunded 500 by card
        _Lib.InsertQueueRow(StoreCode, '901', '9901', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('901', '9901', '#9901', Sku, '701', 2, 400, 100, 25, '71001', _Lib.RefundTxnJson('11', 'shopify_payments', 500, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo exists, the draft is gone, and the row points at the credit memo
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        _Assert.IsFalse(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No."), 'The Return Order is consumed by posting.');
        _Assert.AreEqual(SalesCrMemoHeader."No.", QueueRow."Posted Doc. No.", 'The row must carry the credit memo number.');

        // [THEN] The credit memo's customer ledger entry is closed by a Refund entry on the card account
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-500, GLEntry.Amount, 'The card share must be credited to the refund clearing account.');

        // [THEN] The settlement books no VAT, although the clearing account carries posting groups
        VATEntry.SetRange("Document Type", VATEntry."Document Type"::Refund);
        VATEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.IsTrue(VATEntry.IsEmpty(), 'The refund settlement must not create VAT entries.');

        // [THEN] The payment line travelled to the credit memo
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.AreEqual(1, PaymentLine.Count(), 'The refund payment line must be copied to the credit memo.');
    end;

    [Test]
    procedure Posting_OneOrderLineInTwoParcels_SplitsTheRefundAcrossBothCreditMemoLines()
    var
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
        // [SCENARIO] Two units of one order line that shipped in two parcels come back as two return lines, and each credit memo line carries half of the refunded gross instead of one line taking all of it.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A queued return of order line item 1601 with one return line per parcel, quantity 1 each, and one refund line of quantity 2 at gross 500 (net 400, tax 100) refunded 500 by card
        _Lib.InsertQueueRow(StoreCode, '1601', '9601', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseParcels('1601', '9601', '#9601', Sku, '1601', 2, 400, 100, 25, '71001', _Lib.RefundTxnJson('1601', 'shopify_payments', 500, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo has two item lines of quantity 1, each carrying 250 including VAT
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        _Assert.AreEqual(2, SalesCrMemoLine.Count(), 'One credit memo line per return line.');
        SalesCrMemoLine.FindSet();
        repeat
            _Assert.AreEqual(1, SalesCrMemoLine.Quantity, 'Each parcel returns one unit.');
            _Assert.AreEqual(250, SalesCrMemoLine."Amount Including VAT", 'Each line must carry its half of the refunded gross.');
        until SalesCrMemoLine.Next() = 0;
    end;

    [Test]
    procedure Posting_TwoParcelsInWholeUnitCurrency_SharesSumToTheGross()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Currency: Record Currency;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] An odd gross split across two return lines of one order line in a currency rounded to whole units gives each line a whole-unit share, so the credit memo lines still add up to the gross and the total check passes.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A currency whose amounts round to whole units, with an exchange rate valid before the return's closing date
        CreateWholeUnitCurrency(Currency);

        // [GIVEN] A queued return of order line item 1606 with one return line per parcel, quantity 1 each, and one refund line of quantity 2 at gross 1001 (net 801, tax 200) refunded 1001 by card in that currency
        _Lib.InsertQueueRow(StoreCode, '1606', '9606', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseParcels('1606', '9606', '#9606', Sku, '1606', 2, 801, 200, 25, '71001', _Lib.RefundTxnJson('1606', 'shopify_payments', 1001, Currency.Code, ''), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed without failing the total check
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed without failing the total check: ' + GetLastErrorText());

        // [THEN] The credit memo has two item lines whose amounts including VAT add up to the gross 1001
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        _Assert.AreEqual(2, SalesCrMemoLine.Count(), 'One credit memo line per return line.');
        SalesCrMemoLine.CalcSums("Amount Including VAT");
        _Assert.AreEqual(1001, SalesCrMemoLine."Amount Including VAT", 'The two shares must add up to the refunded gross.');
    end;

    [Test]
    procedure Posting_FourParcelsOfASmallGross_NoCreditMemoLineGoesNegative()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Currency: Record Currency;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gross smaller than half a currency unit per return line, split across four return lines of one order line in a currency rounded to whole units, leaves no credit memo line negative and the lines still add up to the gross.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A currency whose amounts round to whole units, with an exchange rate valid before the return's closing date
        CreateWholeUnitCurrency(Currency);

        // [GIVEN] A queued return of order line item 1607 with one return line per parcel for four parcels, quantity 1 each, and one refund line of quantity 4 at gross 2 refunded 2 by card in that currency
        _Lib.InsertQueueRow(StoreCode, '1607', '9607', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseParcels('1607', '9607', '#9607', Sku, '1607', 4, 2, 0, 25, '71001', _Lib.RefundTxnJson('1607', 'shopify_payments', 2, Currency.Code, ''), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo has four item lines and none of them carries a negative amount
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        _Assert.AreEqual(4, SalesCrMemoLine.Count(), 'One credit memo line per return line.');
        SalesCrMemoLine.SetFilter("Amount Including VAT", '<0');
        _Assert.IsTrue(SalesCrMemoLine.IsEmpty(), 'No share of the refund may be negative.');

        // [THEN] The lines add up to the refunded gross 2
        SalesCrMemoLine.SetRange("Amount Including VAT");
        SalesCrMemoLine.CalcSums("Amount Including VAT");
        _Assert.AreEqual(2, SalesCrMemoLine."Amount Including VAT", 'The shares must add up to the refunded gross.');
    end;

    [Test]
    procedure Import_LcyKeptOnTheDocument_SharesUseTheLcyCurrencyPrecision()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        LcyCurrency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalPrecision: Decimal;
        OriginalLcyCode: Code[10];
        OriginalLcyPrecision: Decimal;
        LcyExisted: Boolean;
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] On a store that keeps the LCY code on its documents, an odd gross split across two return lines is rounded with the LCY Currency record's precision, as the Sales Line rounds it, not with General Ledger Setup's, so the total check passes.
        // [GIVEN] A legacy-path store with automatic posting off that keeps the LCY code on its documents
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore."Currency Blank for LCY" := false;
        ShopifyStore.Modify();

        // [GIVEN] General Ledger Setup keeps an amount precision of 0.01 and has an LCY code
        GeneralLedgerSetup.Get();
        OriginalPrecision := GeneralLedgerSetup."Amount Rounding Precision";
        OriginalLcyCode := GeneralLedgerSetup."LCY Code";
        GeneralLedgerSetup."Amount Rounding Precision" := 0.01;
        if GeneralLedgerSetup."LCY Code" = '' then
            GeneralLedgerSetup."LCY Code" := 'SPFYLRLCY';
        GeneralLedgerSetup.Modify();

        // [GIVEN] The LCY Currency record rounds amounts to whole units and has an exchange rate valid before the return's closing date
        LcyExisted := LcyCurrency.Get(GeneralLedgerSetup."LCY Code");
        if LcyExisted then
            OriginalLcyPrecision := LcyCurrency."Amount Rounding Precision"
        else begin
            LcyCurrency.Init();
            LcyCurrency.Code := GeneralLedgerSetup."LCY Code";
            LcyCurrency.Insert(true);
        end;
        LcyCurrency.Validate("Amount Rounding Precision", 1);
        LcyCurrency.Modify(true);
        if not CurrencyExchangeRate.Get(LcyCurrency.Code, 20260101D) then
            LibraryERM.CreateExchangeRate(LcyCurrency.Code, 20260101D, 1, 1);

        // [GIVEN] A queued return of order line item 1608 with one return line per parcel for two parcels and one refund line of quantity 2 at gross 1001 (net 801, tax 200) refunded 1001 by card in LCY
        _Lib.InsertQueueRow(StoreCode, '1608', '9608', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseParcels('1608', '9608', '#9608', Sku, '1608', 2, 801, 200, 25, '71001', _Lib.RefundTxnJson('1608', 'shopify_payments', 1001, LcyCurrency.Code, ''), LcyCurrency.Code));

        // [WHEN] The import runs
        ImportSucceeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore and commit the setup before asserting, since the import committed the changed precision.
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Amount Rounding Precision" := OriginalPrecision;
        GeneralLedgerSetup."LCY Code" := OriginalLcyCode;
        GeneralLedgerSetup.Modify();
        LcyCurrency.Find();
        if LcyExisted then
            LcyCurrency.Validate("Amount Rounding Precision", OriginalLcyPrecision)
        else
            LcyCurrency.Validate("Amount Rounding Precision", 0.01);
        LcyCurrency.Modify(true);
        Commit();

        // [THEN] The import passed the total check
        _Assert.IsTrue(ImportSucceeded, 'The import must not fail the total check: ' + GetLastErrorText());

        // [THEN] The Return Order carries the LCY code, so its lines round with the LCY Currency record
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        _Assert.AreEqual(LcyCurrency.Code, SalesHeader."Currency Code", 'The store keeps the LCY code on the document.');

        // [THEN] The two item lines add up to the refunded gross 1001
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        _Assert.AreEqual(2, SalesLine.Count(), 'One line per return line.');
        SalesLine.CalcSums("Amount Including VAT");
        _Assert.AreEqual(1001, SalesLine."Amount Including VAT", 'The two shares must add up to the refunded gross.');
    end;

    [Test]
    procedure Posting_GiftCardRefund_CreditsReceiptVoucherBackAndSplitsSettlement()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherA: Record "NPR NpRv Voucher";
        VoucherB: Record "NPR NpRv Voucher";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund split between a card and gift card A credits exactly voucher A back by the gift-card share, books that share on the gift-card account and the rest on the card account, and leaves voucher B, which also paid the original order, untouched.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);

        // [GIVEN] Voucher A behind gift card 9921 with 100, voucher B behind gift card 9922 with 100, and a return refunded 300 by card and 200 to gift card 9921
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVA', StoreCode, '9921', VoucherA);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVB', StoreCode, '9922', VoucherB);
        _Lib.InsertQueueRow(StoreCode, '902', '9902', QueueRow);

        // [GIVEN] The original order's posted invoice was paid with voucher B first, so the order fallback alone would pick B, and with 200 from voucher A
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR902', StoreCode, '9902', VoucherB."No.");
        _Lib.AddVoucherPaymentToPostedInvoice('SI-LR902', VoucherA."No.", 200);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('902', '9902', '#9902', Sku, '702', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('12', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('13', 'gift_card', 200, _Lib.Lcy(), '9921'), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] Voucher A's balance grew by 200 while its initial amount stayed, voucher B did not move, and the row names voucher A
        VoucherA.CalcFields(Amount, "Initial Amount");
        VoucherB.CalcFields(Amount);
        _Assert.AreEqual(300, VoucherA.Amount, 'The card Shopify credited must gain the refund.');
        _Assert.AreEqual(100, VoucherA."Initial Amount", 'Giving a payment back must not change the initial amount.');
        _Assert.AreEqual(100, VoucherB.Amount, 'The other card must be untouched.');
        _Assert.AreEqual(VoucherA."No.", _Lib.SettledVoucherNo(QueueRow), 'The row must name the voucher credited back.');
        _Assert.IsTrue((_Lib.SettledGiftCardAmount(QueueRow) <> 0), 'The gift card flag must be set.');

        // [THEN] The reversal is a corrective payment entry that references the credit memo
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        VoucherEntry.SetRange("Voucher No.", VoucherA."No.");
        VoucherEntry.SetRange("Entry Type", VoucherEntry."Entry Type"::Payment);
        VoucherEntry.SetRange(Correction, true);
        _Assert.IsTrue(VoucherEntry.FindFirst(), 'A corrective payment entry must exist on voucher A.');
        _Assert.AreEqual(SalesCrMemoHeader."No.", VoucherEntry."Document No.", 'The reversal must reference the credit memo.');
        _Assert.AreEqual(200, VoucherEntry.Amount, 'The reversal gives back the gift card share.');

        // [THEN] Settlement is split 300 on the card account and 200 on the gift-card account
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-300, GLEntry.Amount, 'Card share on the clearing account.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Ret. Gift Card Refund G/L Acc.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-200, GLEntry.Amount, 'Gift-card share on the liability account.');

        // [THEN] Neither settlement line books VAT
        VATEntry.SetRange("Document Type", VATEntry."Document Type"::Refund);
        VATEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.IsTrue(VATEntry.IsEmpty(), 'The refund settlement must not create VAT entries.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_GiftCardLine_IsFlaggedWithoutSku()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] Parsing a return whose line item carries the NP gift card property marks the line as a gift card, with no SKU and the refunded gross as its amount.
        // [GIVEN] A closed return of 2 NP gift cards refunded 100 by card
        Response.ReadFrom(_Lib.ReturnDetailResponseGiftCard('560', '9560', '#9560', '760', 2, 100, '71001', _Lib.RefundTxnJson('60', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '560', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The single line is a gift card line without a SKU, worth the refunded 100
        _Assert.AreEqual(1, TempLineBuffer.Count(), 'One line expected.');
        TempLineBuffer.FindFirst();
        _Assert.IsTrue(TempLineBuffer."Gift Card", 'The line must be flagged as a gift card.');
        _Assert.AreEqual('', TempLineBuffer.SKU, 'A gift card line has no SKU.');
        _Assert.AreEqual('760', TempLineBuffer."Order Line Item Id", 'The order line item id must be kept for the invoice lookup.');
        _Assert.AreEqual(100, TempLineBuffer."Line Amount", 'The line amount is the refunded gross.');
    end;

    [Test]
    procedure Posting_GiftCardReturn_CreditsTheSaleAccountAndArchivesBothVouchers()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        Voucher: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
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
        // [SCENARIO] Returning two NP gift cards credits the account their sale was posted on, writes both vouchers down to zero on the credit memo and archives them although their type allows top-up, and settles the refund like any return.
        // [GIVEN] A legacy-path store with automatic posting
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);

        // [GIVEN] A posted invoice that sold two 50 gift cards on Shopify line 761 and issued one untouched, top-up-enabled voucher per card
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC1', StoreCode, '9561', '761', GLAccountNo, 2, 50, VoucherNos);

        // [GIVEN] A queued return of both cards refunded 100 by card
        _Lib.InsertQueueRow(StoreCode, '561', '9561', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('561', '9561', '#9561', '761', 2, 100, '71001', _Lib.RefundTxnJson('61', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo carries one G/L line on the sale account for 100 and no item line
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", GLAccountNo);
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The gift card line must be credited on the account of its sale.');
        _Assert.AreEqual(2, SalesCrMemoLine.Quantity, 'Both cards are credited.');
        _Assert.AreEqual(100, SalesCrMemoLine."Amount Including VAT", 'The line credits what Shopify refunded.');
        SalesCrMemoLine.SetRange("No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        _Assert.IsTrue(SalesCrMemoLine.IsEmpty(), 'A gift card return has no item line.');

        // [THEN] Both vouchers were written down by the credit memo and archived with nothing left on them
        foreach VoucherNo in VoucherNos do begin
            _Assert.IsFalse(Voucher.Get(VoucherNo), 'Voucher ' + VoucherNo + ' must be archived.');
            _Assert.IsTrue(ArchVoucher.Get(VoucherNo), 'Archived voucher ' + VoucherNo + ' must exist.');
            ArchVoucherEntry.Reset();
            ArchVoucherEntry.SetRange("Arch. Voucher No.", ArchVoucher."No.");
            ArchVoucherEntry.SetRange("Document Type", ArchVoucherEntry."Document Type"::"Credit Memo");
            ArchVoucherEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
            _Assert.IsTrue(ArchVoucherEntry.FindFirst(), 'The write-down must reference the credit memo.');
            _Assert.AreEqual(-50, ArchVoucherEntry.Amount, 'Each voucher is written down by its sale price.');
            ArchVoucher.CalcFields(Amount);
            _Assert.AreEqual(0, ArchVoucher.Amount, 'Nothing may be left on the voucher.');
        end;

        // [THEN] The refund is settled on the card clearing account
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-100, GLEntry.Amount, 'The refund must be credited to the clearing account.');
    end;

    [Test]
    procedure Posting_GiftCardReturn_OneOfTwo_RevokesOneVoucherAndLeavesTheOther()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
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
        ArchivedCount: Integer;
        OpenCount: Integer;
        Succeeded: Boolean;
    begin
        // [SCENARIO] Returning one of two gift cards sold on the same line revokes exactly one voucher and leaves the other with its full balance.
        // [GIVEN] A legacy-path store with automatic posting and a posted sale of two 50 gift cards on Shopify line 762
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC2', StoreCode, '9562', '762', GLAccountNo, 2, 50, VoucherNos);

        // [GIVEN] A queued return of one card refunded 50 by card
        _Lib.InsertQueueRow(StoreCode, '562', '9562', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('562', '9562', '#9562', '762', 1, 50, '71001', _Lib.RefundTxnJson('62', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] One voucher is archived and the other still holds 50
        foreach VoucherNo in VoucherNos do
            if Voucher.Get(VoucherNo) then begin
                OpenCount += 1;
                Voucher.CalcFields(Amount);
                _Assert.AreEqual(50, Voucher.Amount, 'The card that was not returned keeps its balance.');
            end else begin
                ArchivedCount += 1;
                _Assert.IsTrue(ArchVoucher.Get(VoucherNo), 'The returned card must be archived.');
            end;
        _Assert.AreEqual(1, ArchivedCount, 'Exactly one voucher is revoked.');
        _Assert.AreEqual(1, OpenCount, 'Exactly one voucher stays open.');
    end;

    [Test]
    procedure Import_GiftCardReturn_UsedVoucher_IsRefusedWithoutADocument()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
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
        // [SCENARIO] Returning two gift cards when one of them has already been spent in part is refused with an error naming the posted sale, leaves no Return Order and touches neither voucher.
        // [GIVEN] A legacy-path store and a posted sale of two 50 gift cards on Shopify line 763, one of which has been used for 20
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC3', StoreCode, '9563', '763', GLAccountNo, 2, 50, VoucherNos);
        _Lib.UseVoucherAmount(VoucherNos.Get(1), 20);

        // [GIVEN] A queued return of both cards refunded 100 by card
        _Lib.InsertQueueRow(StoreCode, '563', '9563', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('563', '9563', '#9563', '763', 2, 100, '71001', _Lib.RefundTxnJson('63', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A used gift card must refuse the return
        _Assert.IsFalse(Succeeded, 'A used gift card must refuse the return.');

        // [THEN] The error names the posted invoice the cards were sold on, no Return Order exists and both vouchers are still open
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SI-LRGC3') > 0, 'The error must name the posted invoice: ' + GetLastErrorText());
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'A refused import must leave no Return Order.');
        foreach VoucherNo in VoucherNos do
            _Assert.IsTrue(Voucher.Get(VoucherNo), 'Voucher ' + VoucherNo + ' must be untouched by a refused import.');
    end;

    [Test]
    procedure Import_GiftCardReturn_WithoutPostedSale_IsRefusedWithoutADocument()
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
        // [SCENARIO] Returning a gift card whose sale was never posted in BC is refused with an error naming the Shopify line item, and no Return Order is left behind.
        // [GIVEN] A legacy-path store and a queued return of one gift card from Shopify line 764 that no posted invoice carries
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '564', '9564', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('564', '9564', '#9564', '764', 1, 50, '71001', _Lib.RefundTxnJson('64', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A gift card without a posted sale must refuse the return
        _Assert.IsFalse(Succeeded, 'A gift card without a posted sale must refuse the return.');

        // [THEN] The error names the Shopify line item that has no posted sale and no Return Order exists
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'line item 764') > 0, 'The error must name the line item: ' + GetLastErrorText());
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'A refused import must leave no Return Order.');
    end;

    [Test]
    procedure Posting_SettlementFailure_AbortsPostingAndKeepsDraft()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        DraftNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When settlement cannot post, the whole posting is aborted and the committed draft survives, linked to the row, with an error naming the missing refund account.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] The store has no refund account
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Refund G/L Account No." := '';
        ShopifyStore.Modify();

        // [GIVEN] A queued return refunded 100 by card
        _Lib.InsertQueueRow(StoreCode, '903', '9903', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('903', '9903', '#9903', Sku, '703', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('14', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs and posting fails in settlement
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Posting must fail without a refund account
        _Assert.IsFalse(Succeeded, 'Posting must fail without a refund account.');

        // [THEN] The error names the account field
        _Assert.IsTrue(StrPos(GetLastErrorText(), ShopifyStore.FieldCaption("Return Refund G/L Account No.")) > 0, 'The settlement error must name the missing account: ' + GetLastErrorText());

        // [THEN] The draft is kept and linked, and no credit memo exists
        QueueRow.Find();
        DraftNo := QueueRow."Sales Header Doc. No.";
        _Assert.AreNotEqual('', DraftNo, 'The row must stay linked to the committed draft.');
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", DraftNo), 'The committed draft must survive the failed posting.');
        SalesCrMemoHeader.SetRange("Return Order No.", DraftNo);
        _Assert.IsTrue(SalesCrMemoHeader.IsEmpty(), 'No credit memo may exist after an aborted posting.');
    end;

    [Test]
    procedure Posting_RetryAfterSettlementFailure_ReusesTheDraftWithoutShopify()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        EmptyMock: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        DraftNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] After a settlement failure has been fixed in setup, the next run posts the draft it kept, without calling Shopify again.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] The store has no refund account
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Refund G/L Account No." := '';
        ShopifyStore.Modify();

        // [GIVEN] A queued return refunded 100 by card whose first import built and committed the draft, then failed in settlement
        _Lib.InsertQueueRow(StoreCode, '905', '9905', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('905', '9905', '#9905', Sku, '705', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('16', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsFalse(_Lib.RunImport(QueueRow, MockClient), 'The first run must fail without a refund account.');
        QueueRow.Find();
        DraftNo := QueueRow."Sales Header Doc. No.";

        // [GIVEN] The refund account is then set on the store
        ShopifyStore.Find();
        ShopifyStore."Return Refund G/L Account No." := _Lib.CreateDirectPostingGLAccount();
        ShopifyStore.Modify();

        // [WHEN] The import runs again with a mock that has no responses
        Succeeded := _Lib.RunImport(QueueRow, EmptyMock);

        // [THEN] The retry must post the existing draft
        _Assert.IsTrue(Succeeded, 'The retry must post the existing draft: ' + GetLastErrorText());

        // [THEN] Shopify was not called again
        _Assert.AreEqual(0, EmptyMock.RequestCount(), 'The retry must not fetch from Shopify.');

        // [THEN] Exactly one credit memo was posted from the reused draft
        SalesCrMemoHeader.SetRange("Return Order No.", DraftNo);
        _Assert.AreEqual(1, SalesCrMemoHeader.Count(), 'Exactly one credit memo from the reused draft.');
    end;

    [Test]
    procedure Posting_ForeignCurrency_SettlesInDocumentCurrency()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        GLEntry: Record "G/L Entry";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded in a foreign currency is posted and settled in that currency, leaving the credit memo fully applied and the clearing account credited with the LCY equivalent.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);

        // [GIVEN] A currency worth 7.5 LCY per unit from before the return's closing date, 2026-09-20
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);
        CurrencyExchangeRate.Get(Currency.Code, 20260101D);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", 7.5);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", 7.5);
        CurrencyExchangeRate.Modify(true);

        // [GIVEN] A queued return of 100 in that currency, refunded by card
        _Lib.InsertQueueRow(StoreCode, '904', '9904', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('904', '9904', '#9904', Sku, '704', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('15', 'shopify_payments', 100, Currency.Code, ''), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo is in the currency and its ledger entry is closed
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        _Assert.AreEqual(Currency.Code, SalesCrMemoHeader."Currency Code", 'Credit memo currency.');
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled in its own currency.');

        // [THEN] The clearing account receives the 100 converted at 7.5, in LCY
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-750, GLEntry.Amount, 'The card share must reach the clearing account in LCY.');
    end;

    [Test]
    procedure Posting_PartialInvoicing_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        PostResult: Boolean;
    begin
        // [SCENARIO] Posting an imported Return Order with only part of its quantity invoiced is refused and rolled back, because settlement and the voucher credit would otherwise apply the whole refund to each partial credit memo.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Automatic posting is switched off so the draft stays open
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] An imported draft of 2 units refunded 500 by card
        _Lib.InsertQueueRow(StoreCode, '906', '9906', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('906', '9906', '#9906', Sku, '706', 2, 400, 100, 25, '71001', _Lib.RefundTxnJson('17', 'shopify_payments', 500, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The import must build the draft: ' + GetLastErrorText());
        QueueRow.Find();

        // [GIVEN] The item line is set to receive and invoice only 1 of the 2 units
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine.Validate("Return Qty. to Receive", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The Return Order is posted with Receive and Invoice
        PostResult := SalesPost.Run(SalesHeader);

        // [THEN] Posting fails with the partial invoicing error
        _Assert.IsFalse(PostResult, 'Partial invoicing of an imported return must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'invoiced in one go') > 0, 'The error must explain that the return must be invoiced in one go: ' + GetLastErrorText());

        // [THEN] No credit memo exists for the draft
        SalesCrMemoHeader.SetRange("Return Order No.", QueueRow."Sales Header Doc. No.");
        _Assert.IsTrue(SalesCrMemoHeader.IsEmpty(), 'The partial posting must be rolled back.');
    end;

    [Test]
    procedure Posting_WithheldFee_PostsFeeLineAndSettlesTotal()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
        VATPostingSetup: Record "VAT Posting Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        FeeBase: Decimal;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return with a withheld fee posts the fee line with the VAT its account's posting setup prescribes, and the credit memo total of 85 is settled in full on the card account.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);

        // [GIVEN] A queued return of gross 100 with a 15 return shipping fee withheld, refunded 85 by card
        _Lib.InsertQueueRow(StoreCode, '907', '9907', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('907', '9907', '#9907', Sku, '707', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('18', 'shopify_payments', 85, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), _Lib.ReturnShippingFeeJson(15), ''));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo's customer ledger entry is closed
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields("Remaining Amount");
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');

        // [THEN] The card account receives the 85 refunded
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-85, GLEntry.Amount, 'The card share must equal the refunded 85.');

        // [THEN] The fee line was posted to the store's fee account net of the VAT its posting setup prescribes, with a matching VAT entry
        Customer.Get(CustomerNo);
        GLAccount.Get(ShopifyStore."Return Fee G/L Account No.");
        VATPostingSetup.Get(Customer."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
        _Assert.AreNotEqual(0, VATPostingSetup."VAT %", 'The fixture account must carry VAT for this test to discriminate.');
        FeeBase := Round(-15 / (1 + VATPostingSetup."VAT %" / 100), 0.01);
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Fee G/L Account No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(FeeBase, GLEntry.Amount, 'The fee account receives the fee net of VAT.');
        VATEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        VATEntry.SetRange(Base, FeeBase);
        _Assert.IsTrue(VATEntry.FindFirst(), 'The fee line must produce a VAT entry on its net amount.');
        _Assert.AreEqual(-15 - FeeBase, VATEntry.Amount, 'The VAT entry carries the VAT split out of the withheld 15.');
    end;

    [Test]
    procedure Posting_ManualPostingAfterFailedAutoPost_MarksRowImported()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A Return Order whose automatic posting failed and which a user then posts by hand leaves its row Imported with the credit memo number and no error, so the job stops retrying it.
        // [GIVEN] A legacy-path store with automatic posting, a posting-capable customer, item and location, and no refund account
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Refund G/L Account No." := '';
        ShopifyStore.Modify();

        // [GIVEN] A return refunded 100 by card whose import committed the draft and then failed in settlement, leaving the row at Error as the process job records it
        _Lib.InsertQueueRow(StoreCode, '1501', '9501', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1501', '9501', '#9501', Sku, '1501', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1501', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsFalse(_Lib.RunImport(QueueRow, MockClient), 'The automatic posting must fail without a refund account.');
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Retry Count" := 1;
        QueueRow."Last Error" := CopyStr(GetLastErrorText(), 1, MaxStrLen(QueueRow."Last Error"));
        QueueRow.Modify();

        // [GIVEN] The refund account is then set on the store and the Return Order is marked to receive and invoice
        ShopifyStore.Find();
        ShopifyStore."Return Refund G/L Account No." := _Lib.CreateDirectPostingGLAccount();
        ShopifyStore.Modify();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] A user posts the Return Order
        Succeeded := SalesPost.Run(SalesHeader);

        // [THEN] The manual posting must succeed
        _Assert.IsTrue(Succeeded, 'The manual posting must succeed: ' + GetLastErrorText());

        // [THEN] The row is Imported, carries the credit memo number and no longer shows the old error
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A row whose credit memo exists must be Imported.');
        _Assert.AreEqual(SalesCrMemoHeader."No.", QueueRow."Posted Doc. No.", 'The row must carry the credit memo number.');
        _Assert.AreEqual('', QueueRow."Last Error", 'The old error must be cleared.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1501');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure Posting_ReceiveOnly_StampsReceiptAndKeepsStatus()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        GLEntry: Record "G/L Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        LastErrorBefore: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] Posting an imported Return Order with Receive only stamps the return receipt number on the row, leaves its status and error as they were, and posts no settlement, because nobody has been credited yet.
        // [GIVEN] A legacy-path store with automatic posting switched off, a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] An imported draft refunded 100 by card, on a row at Error with an earlier error, so a wrong status change would show
        _Lib.InsertQueueRow(StoreCode, '1503', '9503', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1503', '9503', '#9503', Sku, '1503', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1503', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The import must build the draft: ' + GetLastErrorText());
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Last Error" := 'An earlier attempt failed.';
        QueueRow.Modify();
        LastErrorBefore := QueueRow."Last Error";

        // [GIVEN] The Return Order is marked to receive only
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesHeader.Receive := true;
        SalesHeader.Invoice := false;
        Commit();

        // [WHEN] The Return Order is posted
        Succeeded := SalesPost.Run(SalesHeader);

        // [THEN] Receiving must succeed
        _Assert.IsTrue(Succeeded, 'Receiving must succeed: ' + GetLastErrorText());

        // [THEN] The row carries the return receipt number and keeps its status and error
        ReturnReceiptHeader.SetRange("Return Order No.", QueueRow."Sales Header Doc. No.");
        ReturnReceiptHeader.FindFirst();
        QueueRow.Find();
        _Assert.AreEqual(ReturnReceiptHeader."No.", QueueRow."Posted Doc. No.", 'The row must carry the return receipt number.');
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'A receipt does not credit the customer, so the status must not change.');
        _Assert.AreEqual(LastErrorBefore, QueueRow."Last Error", 'A receipt must leave the error as it was.');

        // [THEN] No settlement was posted to the refund account
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        _Assert.IsTrue(GLEntry.IsEmpty(), 'A receipt must not post any settlement journal line.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1503');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_FailingRow_RetriesUpToLimitThenStops()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        RunNo: Integer;
    begin
        // [SCENARIO] A row whose import keeps failing is retried on each run until the retry limit and then left at Error, with no Return Order created by any attempt.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();

        // [GIVEN] The store's Shopify Url is blank so every import attempt fails, and the retry limit is 3
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();
        SpfyIntegrationSetup.Get();
        SpfyIntegrationSetup."Max Doc Process Retry Count" := 3;
        SpfyIntegrationSetup.Modify();

        // [GIVEN] A New row for a store that cannot reach Shopify
        _Lib.InsertQueueRow(StoreCode, '1001', '9101', QueueRow);
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [WHEN] The process job runs five times
        for RunNo := 1 to 5 do
            SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row is at Error with exactly three attempts recorded and no document exists
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'The row must end at Error.');
        _Assert.AreEqual(3, QueueRow."Retry Count", 'Retries must stop at the limit.');
        _Assert.IsTrue(QueueRow."Last Error" <> '', 'The last error must be kept on the row.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No attempt may leave a Return Order behind.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1001');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_FailingRow_IsAttemptedOncePerRun()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A New row whose import fails is attempted exactly once per job run, not re-swept into the Error pass of the same run.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();

        // [GIVEN] The store's Shopify Url is blank so the attempt fails
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();

        // [GIVEN] A New row for a store that cannot reach Shopify
        _Lib.InsertQueueRow(StoreCode, '1004', '9104', QueueRow);
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [WHEN] The process job runs once
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row was attempted exactly once, not re-picked up by the Error pass within the same run
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'The row must be at Error after the single failing attempt.');
        _Assert.AreEqual(1, QueueRow."Retry Count", 'Exactly one attempt must be recorded, not two.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1004');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_StaleProcessingRow_IsPickedUpAgain()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row left at Processing by a killed session is processed again once it is older than twice the job interval.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();

        // [GIVEN] The store's Shopify Url is blank so the re-attempt fails
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();

        // [GIVEN] A row stuck at Processing since eleven minutes ago, one minute past twice the job interval of 5 minutes
        _Lib.InsertQueueRow(StoreCode, '1002', '9102', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime() - (11 * 60 * 1000);
        QueueRow.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [WHEN] The process job runs
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The stale row was attempted (it fails on the missing URL) and is no longer stuck at Processing
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'The stale row must have been re-attempted.');
        _Assert.AreEqual(2, QueueRow."Retry Count", 'The lost attempt and the failed re-attempt both count as retries.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1002');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_RowForMissingStore_FailsWithProgrammingBugText()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        HealthyQueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A queue row pointing at a store that no longer exists fails with the programming-bug error and does not stop the run before it reaches the other queued row.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();

        // [GIVEN] A row for a store code that has no store
        QueueRow.Init();
        QueueRow."Entry No." := 0;
        QueueRow."Shopify Store Code" := 'SPFYLRGONE';
        QueueRow."Source Doc. ID" := '1003';
        QueueRow.Status := QueueRow.Status::New;
        QueueRow.Insert(true);

        // [GIVEN] A second New row for that store, whose Shopify Url is blank so its own attempt also fails
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1005', '9105', HealthyQueueRow);
        Commit();

        // [WHEN] The process job runs
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row for the missing store is at Error and the message ends with the programming bug marker
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'The row must be marked Error.');
        _Assert.IsTrue(QueueRow."Last Error".EndsWith('This is a programming bug.'), 'The error must be flagged for developers.');

        // [THEN] The second row was also reached and left at Error: the first row's failure did not stop the run
        HealthyQueueRow.Find();
        _Assert.AreEqual(HealthyQueueRow.Status::Error, HealthyQueueRow.Status, 'The run must continue past the first failure to the second row.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", 'SPFYLRGONE');
        QueueRow.SetFilter("Source Doc. ID", '1003');
        QueueRow.DeleteAll();
        HealthyQueueRow.SetRange("Shopify Store Code", StoreCode);
        HealthyQueueRow.SetFilter("Source Doc. ID", '1005');
        HealthyQueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_RowWithPostedCreditMemo_IsMarkedImportedNotRetried()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] An Error row whose "Posted Doc. No." names an existing credit memo is marked Imported by the process job without another import attempt.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();

        // [GIVEN] Credit memo SCM-LR1502 carrying return 1502's ids, and an Error row for the return that points at it after one failed attempt
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR1502', StoreCode, '1502');
        _Lib.InsertQueueRow(StoreCode, '1502', '9502', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Retry Count" := 1;
        QueueRow."Last Error" := 'Shopify return #9502-R1 is already posted as SCM-LR1502 and cannot be processed again.';
        QueueRow."Posted Doc. No." := 'SCM-LR1502';
        QueueRow.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [WHEN] The process job runs
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row is Imported with no error, and the retry count shows no new attempt
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A row whose credit memo exists must be Imported.');
        _Assert.AreEqual('', QueueRow."Last Error", 'The error must be cleared.');
        _Assert.AreEqual(1, QueueRow."Retry Count", 'No new import attempt may be made.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1502');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_SettlementFailure_ShowsTheErrorOnTheRow()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        DraftNo: Code[20];
        Claimed: Boolean;
    begin
        // [SCENARIO] When settlement fails while the process job posts a return, the row ends at Error with the settlement message naming the missing refund account, and the draft stays linked with no credit memo.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A queued return refunded 100 by card whose draft the import built with automatic posting off
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1605', '9605', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1605', '9605', '#9605', Sku, '1605', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1605', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The import must build the draft: ' + GetLastErrorText());
        QueueRow.Find();
        DraftNo := QueueRow."Sales Header Doc. No.";

        // [GIVEN] Automatic posting is then switched on and the store has no refund account
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := true;
        ShopifyStore."Return Refund G/L Account No." := '';
        ShopifyStore.Modify();
        Commit();

        // [WHEN] The process job processes the row, which posts the draft
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is at Error and its Last Error names the missing refund account
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'A failed settlement must leave the row at Error.');
        _Assert.IsTrue(StrPos(QueueRow."Last Error", ShopifyStore.FieldCaption("Return Refund G/L Account No.")) > 0, 'The row must show the settlement error: ' + QueueRow."Last Error");

        // [THEN] The draft is kept and linked, and no credit memo exists
        _Assert.AreEqual(DraftNo, QueueRow."Sales Header Doc. No.", 'The row must stay linked to the draft.');
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", DraftNo), 'The draft must survive the failed posting.');
        SalesCrMemoHeader.SetRange("Return Order No.", DraftNo);
        _Assert.IsTrue(SalesCrMemoHeader.IsEmpty(), 'No credit memo may exist after an aborted posting.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1605');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_ReceivedOnlyReturnOfAnotherEngine_EndsInErrorNotImported()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        SalesPost: Codeunit "Sales-Post";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A return whose Return Order carries the marker and was received but not invoiced, with no queue link, ends in Error with the received-but-not-invoiced message instead of Imported, because the customer has not been credited.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] A Return Order for return 1604 that carries the return's marker but is not linked to the queue row, as the other engine leaves it
        _Lib.InsertQueueRow(StoreCode, '1604', '9604', QueueRow);
        _Lib.BuildUnlinkedDraft(QueueRow, _Lib.ReturnDetailResponse('1604', '9604', '#9604', Sku, '1604', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1604', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()), SalesHeader);

        // [GIVEN] The Return Order is posted with Receive only, which leaves a return receipt carrying the marker and no credit memo
        SalesHeader.Receive := true;
        SalesHeader.Invoice := false;
        Commit();
        _Assert.IsTrue(SalesPost.Run(SalesHeader), 'Receiving must succeed: ' + GetLastErrorText());
        ReturnReceiptHeader.SetRange("Return Order No.", SalesHeader."No.");
        ReturnReceiptHeader.FindFirst();
        QueueRow.Find();

        // [WHEN] The queue row is processed
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is at Error, not Imported, and the error names the return receipt
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'A received but not invoiced return must not be Imported.');
        _Assert.IsTrue(StrPos(QueueRow."Last Error", ReturnReceiptHeader."No.") > 0, 'The error must name the return receipt: ' + QueueRow."Last Error");

        // [THEN] The receipt is not recorded on the row, so a later attempt looks again and finds the credit memo once it exists
        _Assert.AreEqual('', QueueRow."Posted Doc. No.", 'Only a credit memo may be recorded as the posted document.');

        // [THEN] No credit memo exists for the Return Order
        SalesCrMemoHeader.SetRange("Return Order No.", SalesHeader."No.");
        _Assert.IsTrue(SalesCrMemoHeader.IsEmpty(), 'Receiving must not produce a credit memo.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1604');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure PollJQ_InsertsOneNewRowPerClosedReturn()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Polling a store queues one New row per closed return, with numeric ids and the return name.
        // [GIVEN] A legacy-path store with no queued rows
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();

        // [GIVEN] Shopify lists one order with one closed return
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9201', '#9201', 'gid://shopify/Return/1101', '#9201-R1'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] Exactly one New row exists with numeric ids and the return name
        _Assert.AreEqual(1, QueueRow.Count(), 'One row per closed return.');
        QueueRow.FindFirst();
        _Assert.AreEqual('1101', QueueRow."Source Doc. ID", 'Return id must be numeric.');
        _Assert.AreEqual('9201', QueueRow."Order Id", 'Order id must be numeric.');
        _Assert.AreEqual('#9201-R1', QueueRow."Source Doc. Name", 'Return name is kept for the queue page.');
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'New rows start at New.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1101');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure PollJQ_PollingAgain_AddsNothingForAQueuedReturn()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Polling a store whose closed return is already queued adds no second row for it.
        // [GIVEN] A legacy-path store whose only queued row is return 1506
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();
        _Lib.InsertQueueRow(StoreCode, '1506', '9506', QueueRow);

        // [GIVEN] Shopify lists the same closed return again
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9506', '#9506', 'gid://shopify/Return/1506', '#9506-R1'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The store still has exactly one row
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        _Assert.AreEqual(1, QueueRow.Count(), 'A return that is already queued must not be queued twice.');

        // Cleanup: remove the committed rows.
        QueueRow.SetFilter("Source Doc. ID", '1506');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure PollJQ_OneStoreFailing_DoesNotStopTheOthers()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] When Shopify fails for one store, the other stores are still polled and committed, and the job ends in an error that names only the failing store.
        // [GIVEN] A legacy-path store whose window starts in 2026, so its list filter is distinguishable
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetFilter("Shopify Store Code", '%1|%2', StoreCode, 'SPFYLRFAIL');
        QueueRow.DeleteAll();
        QueueRow.Reset();
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Poll Lookback (Days)" := 3650;
        ShopifyStore."Get Returns Starting From" := CreateDateTime(20260101D, 120000T);
        ShopifyStore.Modify();

        // [GIVEN] A second enabled store whose window starts in 2027, so its list filter is distinguishable, and a mock that fails for it
        LibrarySpfyImport.CreateStore('SPFYLRFAIL');
        ShopifyStore.Get('SPFYLRFAIL');
        ShopifyStore.Enabled := true;
        ShopifyStore."Shopify Url" := 'https://npr-fail.myshopify.com';
        ShopifyStore."Sales Return Order Integration" := true;
        ShopifyStore."Return Poll Lookback (Days)" := 3650;
        ShopifyStore."Get Returns Starting From" := CreateDateTime(20270101D, 120000T);
        ShopifyStore.Modify();
        MockClient.AddFailure('2027-01-01');
        MockClient.AddResponse('2026-01-01', _Lib.ReturnListResponse('gid://shopify/Order/9202', '#9202', 'gid://shopify/Return/1102', '#9202-R1'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        asserterror SpfyLegacyReturnPollJQ.PollAllStores();

        // Cleanup: switch the committed failing store off before asserting, so a failing assertion cannot leave it polled by later tests.
        ShopifyStore.Get('SPFYLRFAIL');
        ShopifyStore.Enabled := false;
        ShopifyStore."Sales Return Order Integration" := false;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The error names the failing store, and the healthy store's row was committed
        _Assert.ExpectedError('SPFYLRFAIL');
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        _Assert.AreEqual(1, QueueRow.Count(), 'The healthy store must still be polled and its row committed.');
        QueueRow.SetRange("Shopify Store Code", 'SPFYLRFAIL');
        _Assert.IsTrue(QueueRow.IsEmpty(), 'The failing store gets no rows.');

        // Cleanup: remove the committed row.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1102');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure PollJQ_ReturnClosedBeforeStartDate_IsNotQueued()
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
        // [SCENARIO] A closed return listed on an order updated inside the window is not queued when it closed before the store's "Get Returns Starting From", because it was credited before the engine went live.
        // [GIVEN] A legacy-path store getting returns from 2026-01-01, with a lookback long enough to reach back before that date
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Get Returns Starting From" := CreateDateTime(20260101D, 0T);
        ShopifyStore."Return Poll Lookback (Days)" := 3650;
        ShopifyStore.Modify();

        // [GIVEN] Shopify lists an order updated recently whose only closed return closed on 2025-06-01
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9504', '#9504', 'gid://shopify/Return/1504', '#9504-R1', '2025-06-01T10:00:00Z'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] No row is queued for the return
        _Assert.IsFalse(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1504'), 'A return closed before the start date must not be queued.');
    end;

    [Test]
    procedure PollJQ_SetupJobQueues_CreatesBothEntries()
    var
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [SCENARIO] With the feature flag off and a store opted in, job registration creates the poll and process entries.
        // [GIVEN] A legacy-path store with Sales Return Order Integration on and the new Ecommerce Order Experience feature off, and neither legacy job registered
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", '%1|%2', Codeunit::"NPR Spfy Legacy Return Poll JQ", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        JobQueueEntry.DeleteAll();
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Precondition: no poll job is registered.');

        // [WHEN] Job queues are set up
        SpfyLegacyReturnPollJQ.SetupJobQueues();

        // [THEN] Both entries exist
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Poll job must be registered.');
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Process job must be registered.');
    end;

    [Test]
    procedure PollJQ_SetupJobQueues_RemovesBothEntriesWhenNoStoreOptsIn()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Once every store opts out of sales return integration, re-running job registration removes both entries.
        // [GIVEN] A legacy-path store with Sales Return Order Integration on and both job queue entries already registered
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        SpfyLegacyReturnPollJQ.SetupJobQueues();

        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Precondition: the poll job is registered.');
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Precondition: the process job is registered.');

        // [GIVEN] Every store opts out of sales return integration
        ShopifyStore.ModifyAll("Sales Return Order Integration", false);

        // [WHEN] Job queues are set up again
        SpfyLegacyReturnPollJQ.SetupJobQueues();

        // [THEN] Both entries are cancelled
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Poll job must be cancelled.');
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Process job must be cancelled.');
    end;

    [Test]
    procedure PollJQ_NestedReturnPagingThatNeverEnds_IsStopped()
    var
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A store whose per-order return paging never advances is stopped at the repeated cursor as a programming bug instead of hanging the job forever.
        // [GIVEN] A legacy-path store with a long lookback so the list filter is stable
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Poll Lookback (Days)" := 3650;
        ShopifyStore.Modify();

        // [GIVEN] Shopify lists one order whose inline returns already say there is another page, and every follow-up page for that order keeps saying the same thing with the same cursor
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponseWithMoreReturns('gid://shopify/Order/9301', 'gid://shopify/Return/1301'));
        MockClient.AddResponse('$OrderId', _Lib.OrderReturnsResponseNeverEnding('gid://shopify/Return/1301'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        asserterror SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The run is stopped at the repeated cursor, and the error names the failing store and is a programming bug for Sentry
        _Assert.ExpectedError(StoreCode);
        _Assert.ExpectedError('cursor');
        _Assert.ExpectedError('This is a programming bug');
    end;

    [Test]
    procedure Field95_CanBeEnabledWhileTheFeatureIsOff()
    var
        ShopifyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        // [SCENARIO] With the Shopify Ecommerce Order Experience off, a store can switch Sales Return Order Integration on as long as it has a starting date.
        // [GIVEN] The Shopify Ecommerce Order Experience feature is off, and a store exists
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        LibrarySpfyImport.CreateStore('SPFYLRF95');
        ShopifyStore.Get('SPFYLRF95');

        // [GIVEN] The store has a return starting date
        ShopifyStore."Get Returns Starting From" := CreateDateTime(20260101D, 0T);
        ShopifyStore.Modify();

        // [WHEN] The toggle is validated to true
        ShopifyStore.Validate("Sales Return Order Integration", true);

        // [THEN] It sticks, no longer requiring the feature
        ShopifyStore.Get('SPFYLRF95');
        _Assert.IsTrue(ShopifyStore."Sales Return Order Integration", 'The toggle must no longer require the feature.');
    end;

    [Test]
    procedure StoreDeleted_LastReturnStore_RemovesTheLegacyReturnJobs()
    var
        ShopifyStore: Record "NPR Spfy Store";
        OtherStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Deleting the last store with sales return integration on removes the legacy return jobs.
        // [GIVEN] A legacy-path store with Sales Return Order Integration on, the only one, with both jobs registered
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        OtherStore.SetFilter(Code, '<>%1', StoreCode);
        OtherStore.ModifyAll("Sales Return Order Integration", false);
        SpfyLegacyReturnPollJQ.SetupJobQueues();
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Precondition: poll job registered.');
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Precondition: process job registered.');

        // [GIVEN] No unfinished queue rows of the store are left over from other tests that commit rows, since the store refuses deletion while any exist
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter(Status, '<>%1', QueueRow.Status::Imported);
        QueueRow.DeleteAll();

        // [WHEN] The store is deleted
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Delete(true);

        // [THEN] Both jobs are gone
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Deleting the last return store must remove the poll job.');
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Deleting the last return store must remove the process job.');
    end;

    [Test]
    procedure FeatureFlagOn_RemovesTheLegacyReturnJobs()
    var
        Feature: Record "NPR Feature";
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        MonitoredJQEntry: Record "NPR Monitored Job Queue Entry";
        JobQueueEntry: Record "Job Queue Entry";
        MonitoredJobQueueMgt: Codeunit "NPR Monitored Job Queue Mgt.";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Turning the Shopify Ecommerce Order Experience feature on removes the legacy return job queue entries together with their monitored rows, so the job refresher cannot recreate them.
        // [GIVEN] No unprocessed legacy return queue rows are left over from other tests that commit rows, since the pre-flight check scans the whole table regardless of store
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off and both legacy return jobs registered
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        SpfyLegacyReturnPollJQ.SetupJobQueues();
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Precondition: poll job registered.');
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Precondition: process job registered.');

        // [GIVEN] Both jobs carry a monitored row, as the job refresher writes for every protected job
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", '%1|%2', Codeunit::"NPR Spfy Legacy Return Poll JQ", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        JobQueueEntry.FindSet();
        repeat
            MonitoredJobQueueMgt.AddMonitoredJobQueueEntry(JobQueueEntry);
        until JobQueueEntry.Next() = 0;
        MonitoredJQEntry.SetRange("Object Type to Run", MonitoredJQEntry."Object Type to Run"::Codeunit);
        MonitoredJQEntry.SetFilter("Object ID to Run", '%1|%2', Codeunit::"NPR Spfy Legacy Return Poll JQ", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        _Assert.AreEqual(2, MonitoredJQEntry.Count(), 'Precondition: both legacy jobs are monitored.');

        // [WHEN] The feature flips on
        Feature.Enabled := true;
        ShopifyEcommOrderExp.HandleJobQueues(Feature);

        // [THEN] Both legacy return jobs are gone, and so are their monitored rows
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Flag on must remove the poll job.');
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Flag on must remove the process job.');
        _Assert.IsTrue(MonitoredJQEntry.IsEmpty(), 'Flag on must remove the monitored rows, or the refresher recreates the jobs.');
    end;

    [Test]
    procedure FeatureFlagOff_RegistersTheLegacyReturnJobs()
    var
        Feature: Record "NPR Feature";
        FeatureBeingValidated: Record "NPR Feature";
        JobQueueEntry: Record "Job Queue Entry";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        SpfyIntegrationFeature: Codeunit "NPR Spfy Integration Feature";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalEnabled: Boolean;
        OriginalIntegrationEnabled: Boolean;
    begin
        // [SCENARIO] Switching the Shopify Ecommerce Order Experience feature off registers the legacy return jobs, although the saved feature row still reads Enabled while its validation runs, provided the Shopify Integration feature is on.
        // [GIVEN] No job queue entries for either legacy return codeunit are left over from other tests
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", '%1|%2', Codeunit::"NPR Spfy Legacy Return Poll JQ", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        JobQueueEntry.DeleteAll(true);

        // [GIVEN] A legacy-path store and the Shopify Integration feature on
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        OriginalIntegrationEnabled := SpfyIntegrationFeature.IsFeatureEnabled();
        SpfyIntegrationFeature.SetFeatureEnabled(true);
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Precondition: poll job not registered.');

        // [GIVEN] The saved feature row still Enabled, as it is while the user's switch-off is being validated, and the record under validation carrying Enabled = false
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        OriginalEnabled := Feature.Enabled;
        Feature.Enabled := true;
        Feature.Modify();
        FeatureBeingValidated := Feature;
        FeatureBeingValidated.Enabled := false;

        // [WHEN] The job queue handling runs for the record under validation
        ShopifyEcommOrderExp.HandleJobQueues(FeatureBeingValidated);

        // Cleanup: restore and commit the feature rows before asserting, so a failing assertion leaves the company as it was.
        Feature.Find();
        Feature.Enabled := OriginalEnabled;
        Feature.Modify();
        SpfyIntegrationFeature.SetFeatureEnabled(OriginalIntegrationEnabled);
        Commit();

        // [THEN] Both legacy return jobs exist
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'Flag off must register the poll job again.');
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Flag off must register the process job again.');
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure FeatureFlagOn_IsRefusedWhileLegacyReturnRowsAreUnprocessed()
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
        // [SCENARIO] Enabling the feature is refused while a legacy return row is still New, so a half-imported return cannot be picked up by the other engine.
        // [GIVEN] No unprocessed legacy return queue rows are left over from other tests that commit rows, since the pre-flight check scans the whole table regardless of store
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());

        // [GIVEN] A New legacy return row
        _Lib.InsertQueueRow(StoreCode, '1201', '9301', QueueRow);

        Clear(_CapturedMessage);
        // [WHEN] The pre-flight check for enabling runs
        Feature.Enabled := true;
        asserterror ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] It refuses, surfacing a message that names the queue before the empty Error
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The message must name the legacy return queue.');
    end;

    local procedure CreateWholeUnitCurrency(var Currency: Record Currency)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        LibraryERM: Codeunit "Library - ERM";
    begin
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Rounding Precision", 1);
        Currency.Modify(true);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);
        CurrencyExchangeRate.Get(Currency.Code, 20260101D);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", 0.05);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", 0.05);
        CurrencyExchangeRate.Modify(true);
    end;

    [ConfirmHandler]
    procedure DeclineConfirm(Question: Text[1024]; var Reply: Boolean)
    begin
        _CapturedMessage := Question;
        Reply := false;
    end;

    [ConfirmHandler]
    procedure AcceptConfirm(Question: Text[1024]; var Reply: Boolean)
    begin
        _CapturedMessage := Question;
        Reply := true;
    end;

    [MessageHandler]
    procedure CaptureMessage(Message: Text[1024])
    begin
        _CapturedMessage := Message;
    end;

    [Test]
    procedure Exclusivity_LegacyPostedReturn_NewEngineMarksItsEntryProcessed()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] After the legacy engine posted a return, the new engine's processing of the same return recognises the posted credit memo through the shared ids and creates no second document.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Return 1401 imported and posted by the legacy engine, and an event log entry for it as the new engine would write
        _Lib.InsertQueueRow(StoreCode, '1401', '9401', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1401', '9401', '#9401', Sku, '801', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('21', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'Legacy import must post: ' + GetLastErrorText());
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, '1401', "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        Commit();

        // [WHEN] The new engine processes the entry
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] The entry is Processed and there is still exactly one credit memo and no Return Order for the customer
        LogEntry.Find();
        _Assert.AreEqual(LogEntry."Processing Status"::Processed, LogEntry."Processing Status", 'The new engine must recognise the posted document.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No second Return Order may be created.');
        SalesCrMemoHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.AreEqual(1, SalesCrMemoHeader.Count(), 'Exactly one credit memo for the return.');
        LibrarySpfyImport.CleanupCommittedLogEntries(StoreCode, '1401');
    end;

    [Test]
    procedure Exclusivity_NewEngineDraft_IsAdoptedByTheLegacyImport()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        ShopifyAssignedID: Record "NPR Spfy Assigned ID";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ResponseText: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A Return Order stamped with the return's ids by the other engine is adopted by the legacy import instead of a second header being created.
        // [GIVEN] A legacy-path store with automatic posting switched off, so the adopted draft stays open
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [GIVEN] A Return Order for return 1402 carrying its Entry ID and store code, and a queue row with no link to it
        ResponseText := _Lib.ReturnDetailResponse('1402', '9402', '#9402', Sku, '802', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('22', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy());
        _Lib.InsertQueueRow(StoreCode, '1402', '9402', QueueRow);
        _Lib.BuildUnlinkedDraft(QueueRow, ResponseText, SalesHeader);

        // [GIVEN] A mock answering the detail query the adoption re-fetches to re-derive its bookkeeping
        MockClient.AddResponse('GetReturn', ResponseText);

        // [WHEN] The legacy import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Adopting a draft must only cost the detail fetch
        _Assert.IsTrue(Succeeded, 'Adopting a draft must only cost the detail fetch: ' + GetLastErrorText());

        // [THEN] The row links the existing draft and no second Return Order exists
        _Assert.AreEqual(SalesHeader."No.", QueueRow."Sales Header Doc. No.", 'The existing draft must be adopted.');
        SpfyAssignedIDMgt.FilterWhereUsedInTable(Database::"Sales Header", "NPR Spfy ID Type"::"Entry ID", '1402', ShopifyAssignedID);
        _Assert.AreEqual(1, ShopifyAssignedID.Count(), 'Only the adopted document may carry the return id.');

        // [THEN] Exactly one Shopify request was made: the detail re-fetch the adoption path uses to re-derive the row's bookkeeping
        _Assert.AreEqual(1, MockClient.RequestCount(), 'Adopting a draft costs exactly one request, the detail fetch.');
    end;

    [Test]
    procedure AlreadyPosted_CreditMemoWithIds_MarksRowWithoutTouchingShopify()
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
        // [SCENARIO] A return whose credit memo already exists with the shared ids is recorded on the row and nothing is fetched or created.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);

        // [GIVEN] Credit memo SCM-LR14 stamped with return 1403 and the store, and a New row for the return
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR14', StoreCode, '1403');
        _Lib.InsertQueueRow(StoreCode, '1403', '9403', QueueRow);

        // [WHEN] The import runs against a mock with no responses
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A posted return must be recognised without an error
        _Assert.IsTrue(Succeeded, 'A posted return must be recognised without an error: ' + GetLastErrorText());

        // [THEN] The row carries the credit memo, no request was sent, no Return Order exists
        _Assert.AreEqual('SCM-LR14', QueueRow."Posted Doc. No.", 'The posted document must be recorded.');
        _Assert.AreEqual(0, MockClient.RequestCount(), 'Shopify must not be called for a posted return.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No document may be created.');
    end;

    [Test]
    procedure OrderImport_ExistingLineLookup_SkipsReturnOrderLinesWithTheSameShopifyId()
    var
        OrderHeader: Record "Sales Header";
        OrderLine: Record "Sales Line";
        ReturnHeader: Record "Sales Header";
        ReturnLine: Record "Sales Line";
        FoundLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] The legacy order import's lookup of an existing order line ignores a Return Order line that carries the same Shopify order line item id, although that line was stamped later and sorts first.
        // [GIVEN] A Sales Order line carrying Shopify order line item 7701
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine('7701', 100, OrderHeader, OrderLine);

        // [GIVEN] A Return Order line for the same item and the same Shopify line item id, stamped after the order line
        _Lib.InsertReturnOrderWithReturnIds('RO-LR7701', StoreCode, '7701R', ReturnHeader);
        ReturnLine.Init();
        ReturnLine."Document Type" := ReturnHeader."Document Type";
        ReturnLine."Document No." := ReturnHeader."No.";
        ReturnLine."Line No." := 10000;
        ReturnLine.Type := ReturnLine.Type::Item;
        ReturnLine."No." := OrderLine."No.";
        ReturnLine.Insert();
        SpfyAssignedIDMgt.AssignShopifyID(ReturnLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", '7701', false);

        // [WHEN] The order import looks the Shopify line up
        Succeeded := SpfyOrderMgt.FindExistingSalesLine(OrderHeader."Document Type", '7701', FoundLine);

        // [THEN] The order line must be found
        _Assert.IsTrue(Succeeded, 'The order line must be found.');

        // [THEN] It gets the Sales Order line, not the Return Order line
        _Assert.AreEqual(FoundLine."Document Type"::Order, FoundLine."Document Type", 'The lookup must return the order line.');
        _Assert.AreEqual(OrderHeader."No.", FoundLine."Document No.", 'The lookup must return the line of the Sales Order.');
    end;

    [Test]
    procedure Import_RefundBeyondTheLines_WithoutDiscrepancyAccount_IsRefusedNamingTheField()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShippingAccountNo: Code[20];
        DiscrepancyAccountNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded 20 beyond its line, on a store without a discrepancy account, is refused with an error naming that field, not the shipping account, and leaves no Return Order.
        // [GIVEN] A legacy-path store with neither a shipping refund account nor a discrepancy account, and a queued return of one line worth 100, refunded 120 with an order adjustment of -20
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShippingAccountNo := ShopifyStore."Ret. Shipping Refund G/L Acc.";
        DiscrepancyAccountNo := ShopifyStore."Refund Discrepancy G/L Acc.";
        ShopifyStore."Ret. Shipping Refund G/L Acc." := '';
        ShopifyStore."Refund Discrepancy G/L Acc." := '';
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '812', '9812', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('812', '9812', '#9812', Sku, '612', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('22', 'shopify_payments', 120, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), '[]', '', _Lib.OrderAdjustmentJson(-20, 0, 'REFUND_DISCREPANCY')));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Ret. Shipping Refund G/L Acc." := ShippingAccountNo;
        ShopifyStore."Refund Discrepancy G/L Acc." := DiscrepancyAccountNo;
        ShopifyStore.Modify();
        Commit();

        // [THEN] A refund beyond the lines without an account must be refused
        _Assert.IsFalse(Succeeded, 'A refund beyond the lines without a discrepancy account must be refused.');

        // [THEN] The error names the return and the discrepancy field, does not blame the shipping account, and no Return Order exists
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9812-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), ShopifyStore.FieldCaption("Refund Discrepancy G/L Acc.")) > 0, 'The error must name the discrepancy account field: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), ShopifyStore.FieldCaption("Ret. Shipping Refund G/L Acc.")) = 0, 'The error must not blame the shipping account: ' + GetLastErrorText());
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'A refused import must leave no Return Order.');
    end;

    [Test]
    procedure Posting_WithheldAdjustmentOnTaxesIncludedOrder_TakesTheGrossAmount()
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
        // [SCENARIO] On an order with taxes included, a withheld order adjustment reported as 8 with 2 tax is 8 gross, so a 100 line refunded 92 posts with a fee line of 8 and the total check passes.
        // [GIVEN] A legacy-path store with automatic posting and a taxes-included return of one 100 line refunded 92 with a withheld adjustment of 8 plus 2 tax
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.InsertQueueRow(StoreCode, '813', '9813', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('813', '9813', '#9813', Sku, '613', 1, 100, 0, 0, '71001', _Lib.RefundTxnJson('23', 'shopify_payments', 92, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), '[]', '', _Lib.OrderAdjustmentJson(8, 2, 'REFUND_DISCREPANCY')).Replace('"taxesIncluded":false', '"taxesIncluded":true'));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The fee line withholds 8 gross
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Return Fee G/L Account No.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'A fee line must exist.');
        _Assert.AreEqual(-8, SalesCrMemoLine."Amount Including VAT", 'The withheld adjustment is 8 gross on a taxes-included order.');
    end;

    [Test]
    procedure Posting_StoreCreditRefund_SettlesOnTheLiabilityAccountWithoutCreditingAVoucher()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherB: Record "NPR NpRv Voucher";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GLEntry: Record "G/L Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of 300 to the card and 200 to Shopify store credit settles 300 on the card account and 200 on the gift card liability account, and credits no voucher back although the order was paid with one.
        // [GIVEN] A legacy-path store with automatic posting, voucher B that paid the original order, and a return refunded 300 by card and 200 to store credit
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVS', StoreCode, '9941', VoucherB);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR941', StoreCode, '9941', VoucherB."No.");
        _Lib.InsertQueueRow(StoreCode, '941', '9941', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('941', '9941', '#9941', Sku, '741', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('41', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('42', 'shopify_store_credit', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The store credit share sits on the liability account, the card share on the clearing account
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-300, GLEntry.Amount, 'Only the card share belongs on the clearing account.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Ret. Gift Card Refund G/L Acc.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-200, GLEntry.Amount, 'Store credit is a customer liability, like a gift card.');

        // [THEN] No voucher was credited back and the row shows the share without a voucher
        VoucherB.CalcFields(Amount);
        _Assert.AreEqual(100, VoucherB.Amount, 'The voucher that paid the order must not gain the store credit.');
        _Assert.AreEqual('', _Lib.SettledVoucherNo(QueueRow), 'Store credit has no retail voucher behind it.');
        _Assert.IsTrue((_Lib.SettledGiftCardAmount(QueueRow) <> 0), 'The row must show that part of the refund stayed with Shopify as credit.');
        _Assert.AreEqual(200, _Lib.SettledGiftCardAmount(QueueRow), 'The liability share is the store credit amount.');
    end;

    [Test]
    procedure Posting_GiftCardAndStoreCreditRefund_CreditsTheCardItsOwnShare()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherC: Record "NPR NpRv Voucher";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GLEntry: Record "G/L Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund of 250 to the card, 50 to gift card 9942 and 200 to Shopify store credit settles 250 on the card account and 250 on the liability account, and gives gift card 9942 back its own 50.
        // [GIVEN] A legacy-path store with automatic posting, voucher C behind gift card 9942 that paid 100 on the order
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVC2', StoreCode, '9942', VoucherC);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR942', StoreCode, '9942', VoucherC."No.", 100);
        // [GIVEN] A return of that order refunded 250 by card, 50 to gift card 9942 and 200 to store credit
        _Lib.InsertQueueRow(StoreCode, '942', '9942', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('942', '9942', '#9942', Sku, '742', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('43', 'shopify_payments', 250, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('44', 'gift_card', 50, _Lib.Lcy(), '9942') + ',' + _Lib.RefundTxnJson('45', 'shopify_store_credit', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        // [THEN] The card share sits on the clearing account and the gift card and store credit shares on the liability account
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-250, GLEntry.Amount, 'Only the card share belongs on the clearing account.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Ret. Gift Card Refund G/L Acc.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-250, GLEntry.Amount, 'The gift card and store credit shares are a customer liability.');
        // [THEN] Gift card 9942 gets back its own 50, not the store credit
        VoucherC.CalcFields(Amount);
        _Assert.AreEqual(150, VoucherC.Amount, 'The card must get back exactly what Shopify put back on it.');
    end;

    [Test]
    procedure Posting_StoreCreditRefundOnAnOrderPaidWithTwoVouchers_SettlesWithoutAVoucher()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherU: Record "NPR NpRv Voucher";
        VoucherV: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund to Shopify store credit puts nothing back on a gift card, so it settles without a voucher even when the order was paid with two vouchers BC could not tell apart.
        // [GIVEN] A legacy-path store with automatic posting, and vouchers U and V that each paid 100 on the order's invoice
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVU', StoreCode, '99979', VoucherU);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVV', StoreCode, '99980', VoucherV);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR979', StoreCode, '9979', VoucherU."No.", 100);
        _Lib.AddVoucherPaymentToPostedInvoice('SI-LR979', VoucherV."No.", 100);

        // [GIVEN] A return refunded 300 by card and 200 to store credit
        _Lib.InsertQueueRow(StoreCode, '979', '9979', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('979', '9979', '#9979', Sku, '7979', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('97901', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('97902', 'shopify_store_credit', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Store credit must not be refused for gift cards it does not touch: ' + GetLastErrorText());
        // [THEN] The row names no voucher and neither voucher gained anything
        QueueRow.Find();
        _Assert.AreEqual('', _Lib.SettledVoucherNo(QueueRow), 'Store credit has no retail voucher behind it.');
        VoucherU.CalcFields(Amount);
        _Assert.AreEqual(100, VoucherU.Amount, 'Voucher U must not gain the store credit.');
        VoucherV.CalcFields(Amount);
        _Assert.AreEqual(100, VoucherV.Amount, 'Voucher V must not gain the store credit.');
    end;

    [Test]
    procedure Posting_SettlementWithoutTheCardsOwnShare_GivesTheCardTheWholeGiftCardShare()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherT: Record "NPR NpRv Voucher";
        Settlement: Record "NPR Spfy Refund Settlement";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A settlement row from before the card's own share was recorded, as the upgrade copies it from a released queue row, gives the card the whole gift card share: 200 back on a card that paid 200.
        // [GIVEN] A store posting manually, voucher T behind gift card 99978 that paid 200 on the order's invoice, and a draft built for a refund of 300 by card and 200 to that card
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVT', StoreCode, '99978', VoucherT);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR978', StoreCode, '9978', VoucherT."No.", 200);
        _Lib.InsertQueueRow(StoreCode, '978', '9978', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('978', '9978', '#9978', Sku, '7978', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('97801', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('97802', 'gift_card', 200, _Lib.Lcy(), '99978'), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());
        QueueRow.Find();

        // [GIVEN] The settlement row lacks the card's own share, as a row the upgrade copied from a released queue row does
        Settlement.Get(StoreCode, QueueRow."Source Doc. Type", QueueRow."Source Doc. ID");
        _Assert.AreEqual(200, Settlement."Voucher Refund Amount", 'Precondition: the import records the card''s own share.');
        Settlement."Voucher Refund Amount" := 0;
        Settlement."Voucher Refund Amount (LCY)" := 0;
        Settlement.Modify();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] A user posts the Return Order
        Succeeded := SalesPost.Run(SalesHeader);

        // [THEN] Posting must succeed
        _Assert.IsTrue(Succeeded, 'Posting must succeed: ' + GetLastErrorText());
        // [THEN] The card gets back the whole 200
        VoucherT.CalcFields(Amount);
        _Assert.AreEqual(300, VoucherT.Amount, 'Without its own share recorded the card must get the whole gift card share, as the released build gave it.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '978');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_StoreWithReturnsSwitchedOff_LeavesItsRowsNew()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A queued return of a store whose "Sales Return Order Integration" has since been switched off is left at New by the process job, with no attempt and no document.
        // [GIVEN] A legacy-path store with a queued return, whose return toggle is then switched off and whose Shopify Url would make any attempt fail, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();
        _Lib.InsertQueueRow(StoreCode, '1005', '9105', QueueRow);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Sales Return Order Integration" := false;
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [WHEN] The process job runs
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row is untouched and nothing was built
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'A row of a store with returns off must stay New.');
        _Assert.AreEqual(0, QueueRow."Retry Count", 'No attempt may be recorded.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No Return Order may be built for a store with returns off.');

        // Cleanup: remove the committed row.
        QueueRow.Delete();
        Commit();
    end;

    [Test]
    procedure Mgt_ProcessingRowOfAnotherSession_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row that another session set to Processing moments ago is refused by the manual Process guard, so two sessions cannot build the same return twice.
        // [GIVEN] A row at Processing, attempted just now
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1006', '9106', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();

        // [WHEN] The manual guard runs
        asserterror SpfyLegacyReturnMgt.ErrorIfBeingProcessed(QueueRow);

        // [THEN] The error names the return
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9106-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_StaleProcessingRow_IsNotRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row left at Processing by a killed session a day ago passes the manual Process guard, so a user can retry it.
        // [GIVEN] A row at Processing, attempted a day ago
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1007', '9107', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime() - 24 * 60 * 60 * 1000;
        QueueRow.Modify();

        // [WHEN] The manual guard runs
        SpfyLegacyReturnMgt.ErrorIfBeingProcessed(QueueRow);

        // [THEN] No error was raised and the row is unchanged
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Processing, QueueRow.Status, 'The guard must not change the row.');
    end;

    [Test]
    procedure Mgt_IsCreditMemoPosted_IgnoresACreditMemoWithoutTheReturnId()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        IsPosted: Boolean;
    begin
        // [SCENARIO] A row whose Posted Doc. No. matches a credit memo that does not carry the return's Shopify id is not treated as imported, so a return receipt number that collides with another document's number cannot mark the row done.
        // [GIVEN] A row pointing at a posted credit memo that carries no Shopify return id
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1008', '9108', QueueRow);
        if not SalesCrMemoHeader.Get('SCM-LR1008') then begin
            SalesCrMemoHeader.Init();
            SalesCrMemoHeader."No." := 'SCM-LR1008';
            SalesCrMemoHeader.Insert();
        end;
        QueueRow."Posted Doc. No." := 'SCM-LR1008';
        QueueRow.Modify();

        // [WHEN] The row is checked for its credit memo
        IsPosted := SpfyLegacyReturnMgt.IsCreditMemoPosted(QueueRow);

        // [THEN] The unrelated credit memo does not count
        _Assert.IsFalse(IsPosted, 'A credit memo without the return id is not this return''s credit memo.');
    end;

    [Test]
    procedure Import_GiftCardReturn_WithoutRefundForTheLine_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        VoucherNos: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
        LocationCode: Code[10];
        ShippingAccountNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A returned gift card line that the refund does not name is refused instead of posting a zero line and leaving the card active.
        // [GIVEN] A store with no shipping refund account, a posted sale of one 50 gift card and a return of it whose refund names no line
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShippingAccountNo := ShopifyStore."Ret. Shipping Refund G/L Acc.";
        ShopifyStore."Ret. Shipping Refund G/L Acc." := '';
        ShopifyStore.Modify();
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC4', StoreCode, '9565', '765', GLAccountNo, 1, 50, VoucherNos);
        _Lib.InsertQueueRow(StoreCode, '565', '9565', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.WithoutRefundLines(_Lib.ReturnDetailResponseGiftCard('565', '9565', '#9565', '765', 1, 50, '71001', _Lib.RefundTxnJson('65', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy())));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed store before asserting.
        ShopifyStore.Find();
        ShopifyStore."Ret. Shipping Refund G/L Acc." := ShippingAccountNo;
        ShopifyStore.Modify();
        Commit();

        // [THEN] A gift card line with nothing refunded for it must be refused
        _Assert.IsFalse(Succeeded, 'A gift card line with nothing refunded for it must be refused.');

        // [THEN] The error names the return and is not the shipping-account message, and the card is still open
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9565-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), ShopifyStore.FieldCaption("Ret. Shipping Refund G/L Acc.")) = 0, 'The error must not blame the shipping account: ' + GetLastErrorText());
        _Assert.IsTrue(Voucher.Get(VoucherNos.Get(1)), 'The card must be untouched by a refused import.');
    end;

    [Test]
    procedure Posting_GiftCardReturn_SoldAcrossTwoInvoices_RevokesACardFromEach()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        VouchersA: List of [Code[20]];
        VouchersB: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gift card line whose two units were invoiced on two separate posted invoices returns both: the import collects the vouchers of every invoice that carries the line, not only the first.
        // [GIVEN] Two posted invoices for Shopify line 766, each issuing one 50 gift card
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC5A', StoreCode, '9566', '766', GLAccountNo, 1, 50, VouchersA);
        _Lib.InsertPostedGiftCardSale('SI-LRGC5B', StoreCode, '9566', '766', GLAccountNo, 1, 50, VouchersB);

        // [GIVEN] A queued return of both cards refunded 100 by card
        _Lib.InsertQueueRow(StoreCode, '566', '9566', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('566', '9566', '#9566', '766', 2, 100, '71001', _Lib.RefundTxnJson('66', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] One card from each invoice is archived
        _Assert.IsTrue(ArchVoucher.Get(VouchersA.Get(1)), 'The card of the first invoice must be archived.');
        _Assert.IsTrue(ArchVoucher.Get(VouchersB.Get(1)), 'The card of the second invoice must be archived.');
    end;

    [Test]
    procedure Posting_GiftCardRefund_VoucherGoneBeforePosting_FailsNamingTheReturn()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherA: Record "NPR NpRv Voucher";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A draft whose gift card voucher was deleted before posting fails to post with an error that names the return and the voucher, and keeps the draft.
        // [GIVEN] A store posting manually, a voucher behind gift card 9951, and a draft built for a refund of 300 by card and 200 to that card
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVG', StoreCode, '9951', VoucherA);
        _Lib.InsertQueueRow(StoreCode, '951', '9951', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('951', '9951', '#9951', Sku, '751', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('51', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('52', 'gift_card', 200, _Lib.Lcy(), '9951'), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual(VoucherA."No.", _Lib.SettledVoucherNo(QueueRow), 'Precondition: the row names the voucher.');

        // [GIVEN] The voucher is deleted and automatic posting is switched on
        _Lib.DeleteVoucher(VoucherA."No.");
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := true;
        ShopifyStore.Modify();
        Commit();

        // [WHEN] The row is processed again, which posts the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Posting must fail when the voucher is gone
        _Assert.IsFalse(Succeeded, 'Posting must fail when the voucher is gone.');

        // [THEN] The error names the return and the voucher, and the draft survives
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9951-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), VoucherA."No.") > 0, 'The error must name the voucher: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Discard the draft') > 0, 'On the automatic route the receipt rolls back with the posting, so the advice is to discard the draft: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No."), 'The draft must survive the failed posting.');
    end;

    [Test]
    procedure Posting_VoucherGoneAfterReceipt_FailsNamingTheReceiptInsteadOfAdvisingDiscard()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherA: Record "NPR NpRv Voucher";
        SalesHeader: Record "Sales Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Invoicing a Return Order that was received earlier fails when its gift card voucher has since disappeared, with an error that names the return, the voucher and the return receipt that stops the draft from being discarded.
        // [GIVEN] A store posting manually, a voucher behind gift card 9952, and a draft built for a refund of 300 by card and 200 to that card
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVR', StoreCode, '9952', VoucherA);
        _Lib.InsertQueueRow(StoreCode, '952', '9952', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('952', '9952', '#9952', Sku, '752', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('53', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('54', 'gift_card', 200, _Lib.Lcy(), '9952'), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual(VoucherA."No.", _Lib.SettledVoucherNo(QueueRow), 'Precondition: the row names the voucher.');

        // [GIVEN] The Return Order is received without being invoiced, so a return receipt is posted and stamped on the row
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesHeader.Receive := true;
        SalesHeader.Invoice := false;
        Commit();
        _Assert.IsTrue(SalesPost.Run(SalesHeader), 'Receiving must succeed: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.IsTrue(ReturnReceiptHeader.Get(QueueRow."Posted Doc. No."), 'Precondition: the row carries the return receipt.');

        // [GIVEN] The voucher is deleted and the Return Order is marked to invoice
        _Lib.DeleteVoucher(VoucherA."No.");
        SalesHeader.Find();
        SalesHeader.Receive := false;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] A user invoices the received Return Order
        Clear(SalesPost);
        Succeeded := SalesPost.Run(SalesHeader);

        // [THEN] Invoicing fails when the voucher is gone
        _Assert.IsFalse(Succeeded, 'Invoicing must fail when the voucher is gone.');

        // [THEN] The error names the return, the voucher and the return receipt, because a received draft cannot be discarded
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9952-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), VoucherA."No.") > 0, 'The error must name the voucher: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), ReturnReceiptHeader."No.") > 0, 'The error must name the return receipt that blocks the discard: ' + GetLastErrorText());

        // [THEN] The receipt stays on the row and no credit memo exists
        QueueRow.Find();
        _Assert.AreEqual(ReturnReceiptHeader."No.", QueueRow."Posted Doc. No.", 'The row must keep the return receipt after the failed invoice.');
        SalesCrMemoHeader.SetRange("Return Order No.", SalesHeader."No.");
        _Assert.IsTrue(SalesCrMemoHeader.IsEmpty(), 'No credit memo may exist after the failed invoice.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '952');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure Posting_ForeignCurrencyGiftCardRefund_CreditsTheVoucherBackInLcy()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherA: Record "NPR NpRv Voucher";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gift card share of 20 in a currency worth 7.5 LCY per unit gives the voucher back 150 LCY, the share converted at the credit memo's rate.
        // [GIVEN] A legacy-path store with automatic posting, a currency at 7.5, and voucher A behind gift card 9961 holding 100
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);
        CurrencyExchangeRate.Get(Currency.Code, 20260101D);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", 7.5);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", 7.5);
        CurrencyExchangeRate.Modify(true);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVF', StoreCode, '9961', VoucherA);

        // [GIVEN] A return of 100 in that currency refunded 80 by card and 20 to gift card 9961, which paid 20 on the order's invoice
        _Lib.InsertQueueRow(StoreCode, '961', '9961', QueueRow);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR961', StoreCode, '9961', VoucherA."No.", 20);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('961', '9961', '#9961', Sku, '7961', 1, 80, 20, 25, '71001',
            _Lib.RefundTxnJson('61', 'shopify_payments', 80, Currency.Code, '') + ',' + _Lib.RefundTxnJson('62', 'gift_card', 20, Currency.Code, '9961'), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The voucher gained 150 LCY
        VoucherA.CalcFields(Amount);
        _Assert.AreEqual(250, VoucherA.Amount, 'The gift card share must reach the voucher converted to LCY.');
    end;

    [Test]
    procedure Posting_ForeignCurrencyGiftCardRefund_CreditsTheVoucherWhatShopifyBookedInLcy()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherG: Record "NPR NpRv Voucher";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gift card share of 20 in a foreign currency that Shopify booked as 151.20 in the shop currency, which is the LCY, gives the voucher back 151.20, as Shopify credited the card, and not the 150 the credit memo's rate gives.
        // [GIVEN] A legacy-path store with automatic posting, a currency at 7.5, and voucher G holding 100 that paid 20 on the order's invoice
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);
        CurrencyExchangeRate.Get(Currency.Code, 20260101D);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", 7.5);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", 7.5);
        CurrencyExchangeRate.Modify(true);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVG2', StoreCode, '99962', VoucherG);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR962', StoreCode, '9962', VoucherG."No.", 20);
        // [GIVEN] A return of 100 in that currency refunded 80 by card and 20 to the gift card, booked by the shop as 151.20 LCY
        _Lib.InsertQueueRow(StoreCode, '962', '9962', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('962', '9962', '#9962', Sku, '7962', 1, 80, 20, 25, '71001',
            _Lib.RefundTxnJson('63', 'shopify_payments', 80, Currency.Code, '') + ',' + _Lib.RefundTxnJsonWithShopMoney('64', 'gift_card', 20, Currency.Code, 151.20, _Lib.Lcy()), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());
        // [THEN] The voucher gained the 151.20 Shopify booked
        VoucherG.CalcFields(Amount);
        _Assert.AreEqual(251.20, VoucherG.Amount, 'The voucher must move by what Shopify put back on the card in the shop currency.');
    end;

    [Test]
    procedure Posting_SecondForeignCurrencyGiftCardRefund_ReadsTheFirstBackAtShopifysRate()
    var
        QueueRowA: Record "NPR Spfy NC Return Queue";
        QueueRowB: Record "NPR Spfy NC Return Queue";
        VoucherG: Record "NPR NpRv Voucher";
        Currency: Record Currency;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        MockClientA: Codeunit "NPR Spfy Mock GraphQL Client";
        MockClientB: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Two returns of one order put a 100 gift card payment back in two parts, in a currency BC rates at 7.5 and Shopify booked at 7.56; the second part is within what the card paid, because the first reads back as the 60 Shopify refunded and not as the 60.48 BC's rate makes of its 453.60 LCY.
        // [GIVEN] A legacy-path store with automatic posting, a currency at 7.5, and voucher G holding 100 that paid 100 on the order's invoice
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);
        CurrencyExchangeRate.Get(Currency.Code, 20260101D);
        CurrencyExchangeRate.Validate("Relational Exch. Rate Amount", 7.5);
        CurrencyExchangeRate.Validate("Relational Adjmt Exch Rate Amt", 7.5);
        CurrencyExchangeRate.Modify(true);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVG4', StoreCode, '99976', VoucherG);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR976', StoreCode, '9976', VoucherG."No.", 100);

        // [GIVEN] A first return of the order, refunded 40 by card and 60 to the gift card, booked by the shop as 453.60 LCY, imported and posted
        _Lib.InsertQueueRow(StoreCode, '976', '9976', QueueRowA);
        MockClientA.AddResponse('GetReturn', _Lib.ReturnDetailResponse('976', '9976', '#9976', Sku, '7976', 1, 80, 20, 25, '71001',
            _Lib.RefundTxnJson('97601', 'shopify_payments', 40, Currency.Code, '') + ',' + _Lib.RefundTxnJsonWithShopMoney('97602', 'gift_card', 60, Currency.Code, 453.60, _Lib.Lcy()), Currency.Code));
        _Assert.IsTrue(_Lib.RunImport(QueueRowA, MockClientA), 'The first return must post: ' + GetLastErrorText());

        // [GIVEN] A second return of the order, refunded 60 by card and the last 40 to the gift card, booked as 302.40 LCY
        _Lib.InsertQueueRow(StoreCode, '977', '9976', QueueRowB);
        MockClientB.AddResponse('GetReturn', _Lib.ReturnDetailResponse('977', '9976', '#9976', Sku, '7977', 1, 80, 20, 25, '71001',
            _Lib.RefundTxnJson('97701', 'shopify_payments', 60, Currency.Code, '') + ',' + _Lib.RefundTxnJsonWithShopMoney('97702', 'gift_card', 40, Currency.Code, 302.40, _Lib.Lcy()), Currency.Code));

        // [WHEN] The second return's import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRowB, MockClientB);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'The rest of what the card paid must go back on it: ' + GetLastErrorText());
        // [THEN] The voucher gained the 453.60 and the 302.40 Shopify booked
        VoucherG.CalcFields(Amount);
        _Assert.AreEqual(856.00, VoucherG.Amount, 'The voucher must move by what Shopify put back on the card in the shop currency, both times.');
    end;

    [Test]
    procedure Import_GiftCardReturn_ToppedUpVoucher_IsRefused()
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
        // [SCENARIO] Returning a gift card that has been topped up since its sale is refused with an error naming the posted sale, and the card stays open.
        // [GIVEN] A posted sale of one 50 gift card that was later topped up by 30
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC6', StoreCode, '9567', '767', GLAccountNo, 1, 50, VoucherNos);
        _Lib.TopUpVoucherAmount(VoucherNos.Get(1), 30);
        _Lib.InsertQueueRow(StoreCode, '567', '9567', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('567', '9567', '#9567', '767', 1, 50, '71001', _Lib.RefundTxnJson('67', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A topped-up card must refuse the return
        _Assert.IsFalse(Succeeded, 'A topped-up card must refuse the return.');

        // [THEN] The error names the posted sale and the card is still open
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SI-LRGC6') > 0, 'The error must name the posted invoice: ' + GetLastErrorText());
        _Assert.IsTrue(Voucher.Get(VoucherNos.Get(1)), 'The card must be untouched by a refused import.');
    end;

    [Test]
    procedure Mgt_StoreWithReturnsSwitchedOff_RefusesTheManualProcess()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The manual Process guard refuses a row of a store whose "Sales Return Order Integration" is off, naming the store, so the page honours the toggle like the poll and the process job do.
        // [GIVEN] A legacy-path store with its return toggle switched off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Sales Return Order Integration" := false;
        ShopifyStore.Modify();

        // [WHEN] The manual guard runs for the store
        asserterror SpfyLegacyReturnMgt.ErrorIfReturnsSwitchedOff(StoreCode);

        // [THEN] The error names the store
        _Assert.IsTrue(StrPos(GetLastErrorText(), StoreCode) > 0, 'The error must name the store: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_DiscardDraft_ProcessingRowOfAnotherSession_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Discarding the draft of a row that another session is processing right now is refused and the draft survives, so that session's posting is not pulled from under it.
        // [GIVEN] A row at Processing, attempted just now, linked to a Return Order draft, both committed as the other session left them
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1009', '9109', QueueRow);
        _Lib.InsertReturnOrderWithReturnIds('RO-LR1009', StoreCode, '1009', SalesHeader);
        QueueRow."Sales Header Doc. No." := SalesHeader."No.";
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();
        Commit();

        // [WHEN] The draft is discarded
        asserterror SpfyLegacyReturnMgt.DiscardDraft(QueueRow);

        // [THEN] The error names the return and the draft still exists
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9109-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", 'RO-LR1009'), 'The draft must survive a refused discard.');

        // Cleanup: remove the committed row and draft.
        QueueRow.Delete();
        SalesHeader.Delete();
        Commit();
    end;

    [Test]
    procedure Posting_GiftCardReturn_TwoParcels_RevokesEachCardOnce()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        VoucherNos: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Two gift cards sold on one order line and shipped in two parcels come back as two return lines; each line revokes a different card, so both cards are archived and the credit memo carries one gift card line per parcel.
        // [GIVEN] A posted sale of two 50 gift cards on Shopify line 768 and a return of both as two parcels, refunded 100 by card in one refund line
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC7', StoreCode, '9568', '768', GLAccountNo, 2, 50, VoucherNos);
        _Lib.InsertQueueRow(StoreCode, '568', '9568', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCardParcels('568', '9568', '#9568', '768', 2, 100, '71001', _Lib.RefundTxnJson('68', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] Both cards are archived
        _Assert.IsTrue(ArchVoucher.Get(VoucherNos.Get(1)), 'The first card must be archived.');
        _Assert.IsTrue(ArchVoucher.Get(VoucherNos.Get(2)), 'The second card must be archived.');

        // [THEN] The credit memo carries one gift card line per parcel
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", GLAccountNo);
        _Assert.AreEqual(2, SalesCrMemoLine.Count(), 'One gift card line per parcel.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_GiftCardFlagWrittenAsTrue_IsFlagged()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A returned line whose _is_giftcard property is written as "true", which the legacy order import treats as a gift card, is flagged as a gift card on the return as well.
        // [GIVEN] A return detail whose gift card property reads "true" instead of "1"
        Response.ReadFrom(_Lib.ReturnDetailResponseGiftCard('569', '9569', '#9569', '769', 1, 50, '71001', _Lib.RefundTxnJson('69', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()).Replace('"key":"_is_giftcard","value":"1"', '"key":"_is_giftcard","value":"true"'));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '569', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The line is a gift card line
        TempLineBuffer.FindFirst();
        _Assert.IsTrue(TempLineBuffer."Gift Card", 'A gift card flag written as "true" must count, as it does on the order import.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_ShopifyNativeGiftCard_IsFlagged()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A returned Shopify-native gift card line, marked isGiftCard with no NP property, is flagged as a gift card line.
        // [GIVEN] A return detail whose line is a native gift card without custom attributes
        Response.ReadFrom(_Lib.ReturnDetailResponseGiftCard('570', '9570', '#9570', '770', 1, 50, '71001', _Lib.RefundTxnJson('70', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()).Replace('"isGiftCard":false,"customAttributes":[{"key":"_is_giftcard","value":"1"},{"key":"_np_voucher_type","value":"np-giftcard"}]', '"isGiftCard":true,"customAttributes":[]'));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '570', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The line is a gift card line
        TempLineBuffer.FindFirst();
        _Assert.IsTrue(TempLineBuffer."Gift Card", 'A native Shopify gift card line must be flagged.');
    end;

    [Test]
    procedure Import_GiftCardRefundWithoutId_FindsTheVoucherOnALaterInvoice()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherB: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gift card refund that names no card still falls back to the order's single voucher payment when the order was invoiced in two parts and the voucher payment sits on the second invoice.
        // [GIVEN] A store posting manually, voucher B, and an order invoiced twice: the first invoice carries no payment lines, the second the voucher payment
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVL', StoreCode, '99710', VoucherB);
        _Lib.InsertPostedInvoiceWithOrderIds('SI-LR971A', StoreCode, '9971');
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR971B', StoreCode, '9971', VoucherB."No.");

        // [GIVEN] A return refunded 300 by card and 200 to a gift card that carries no id
        _Lib.InsertQueueRow(StoreCode, '971', '9971', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('971', '9971', '#9971', Sku, '771', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('71', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('72', 'gift_card', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The row names voucher B
        QueueRow.Find();
        _Assert.AreEqual(VoucherB."No.", _Lib.SettledVoucherNo(QueueRow), 'The voucher on the later invoice must be found.');
    end;

    [Test]
    procedure Posting_WithheldAdjustmentWithTax_OnTaxExclusiveOrder_TakesAmountPlusTax()
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
        // [SCENARIO] On an order without taxes included, a withheld order adjustment reported as 8 with 2 tax is 10 gross, so a 100 line refunded 90 posts with a fee line of 10 and the total check passes.
        // [GIVEN] A legacy-path store with automatic posting and a tax-exclusive return of one 100 line refunded 90 with a withheld adjustment of 8 plus 2 tax
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.InsertQueueRow(StoreCode, '814', '9814', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('814', '9814', '#9814', Sku, '614', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('24', 'shopify_payments', 90, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), '[]', '', _Lib.OrderAdjustmentJson(8, 2, 'REFUND_DISCREPANCY')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The fee line withholds 10, amount plus tax
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Return Fee G/L Account No.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'A fee line must exist.');
        _Assert.AreEqual(-10, SalesCrMemoLine."Amount Including VAT", 'The withheld adjustment is amount plus tax on a tax-exclusive order.');
    end;

    [Test]
    procedure Import_GiftCardReturn_SecondOpenDraftOfTheSameLine_TakesTheOtherCard()
    var
        ShopifyStore: Record "NPR Spfy Store";
        FirstQueueRow: Record "NPR Spfy NC Return Queue";
        SecondQueueRow: Record "NPR Spfy NC Return Queue";
        FirstMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SecondMockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        VoucherNos: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Two cards sold on one line come back in two separate returns while the store posts manually; the second draft claims the card the first open draft left, so the two drafts never reference the same card.
        // [GIVEN] A store posting manually, a posted sale of two 50 gift cards on Shopify line 772, and an open draft for return 572 that returns one of them
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC8', StoreCode, '9572', '772', GLAccountNo, 2, 50, VoucherNos);
        _Lib.InsertQueueRow(StoreCode, '572', '9572', FirstQueueRow);
        FirstMockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('572', '9572', '#9572', '772', 1, 50, '71001', _Lib.RefundTxnJson('72', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(FirstQueueRow, FirstMockClient), 'The first draft must build: ' + GetLastErrorText());

        // [WHEN] A second return of the other card is imported while the first draft is still open
        _Lib.InsertQueueRow(StoreCode, '573', '9572', SecondQueueRow);
        SecondMockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('573', '9572', '#9572', '772', 1, 50, '71001', _Lib.RefundTxnJson('73', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()));

        Succeeded := _Lib.RunImport(SecondQueueRow, SecondMockClient);

        // [THEN] The second draft builds beside the open first draft
        _Assert.IsTrue(Succeeded, 'The second draft must build: ' + GetLastErrorText());

        // [THEN] The two drafts reference different cards
        FirstQueueRow.Find();
        SecondQueueRow.Find();
        _Assert.AreNotEqual(_Lib.ReferencedVoucherNo(FirstQueueRow."Sales Header Doc. No."), _Lib.ReferencedVoucherNo(SecondQueueRow."Sales Header Doc. No."), 'Each open draft must claim its own card.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TwoRestockedDispositions_FirstLocationWins()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A return line restocked twice, to two locations, keeps the first restock location and is not flagged as not restocked.
        // [GIVEN] A closed return whose only line carries a RESTOCKED disposition to 71001 followed by a RESTOCKED disposition to 71002
        Response.ReadFrom(_Lib.ReturnDetailResponse('574', '9574', '#9574', 'SPFYSNOW', '574', 1, 100, 25, 25, '71001',
            _Lib.RefundTxnJson('74', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.TwoRestockedDispositionsJson('71001', '71002')));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '574', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The first restock location is kept and the line counts as restocked
        TempLineBuffer.FindFirst();
        _Assert.AreEqual('71001', TempLineBuffer."Disposition Location Id", 'The first RESTOCKED disposition must win over a later one.');
        _Assert.IsFalse(TempLineBuffer."Not Restocked", 'Two restocks leave the line restocked.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_RefundLineForAnotherOrderLine_IsRefused()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A refund line that names an order line item not among the returned lines is refused with an error naming the return and that line item, instead of money that silently reaches no line.
        // [GIVEN] A detail response whose refund line points at order line item 999 while the returned line is 575
        ResponseText := _Lib.ReturnDetailResponse('575', '9575', '#9575', 'SPFYSNOW', '575', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('75', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"lineItem":{"id":"gid://shopify/LineItem/575","taxLines"', '"lineItem":{"id":"gid://shopify/LineItem/999","taxLines"');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '575', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the return and the unmatched order line item
        _Assert.ExpectedError('#9575-R1');
        _Assert.ExpectedError('999');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_MissingTaxesIncludedIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A return detail whose order carries no taxesIncluded flag is refused, because every gross amount depends on it and a silent default would count tax twice or not at all.
        // [GIVEN] A detail response with the order's taxesIncluded flag removed
        ResponseText := _Lib.ReturnDetailResponse('586', '9586', '#9586', 'SPFYSNOW', '586', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('86', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"taxesIncluded":false,') > 0, 'Precondition: the fixture carries the flag.');
        ResponseText := ResponseText.Replace('"taxesIncluded":false,', '');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '586', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the missing flag
        _Assert.ExpectedError('taxesIncluded');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_ZeroQuantityLine_IsRefused()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A returned line with no quantity is refused with an error naming the return and the line item, instead of a return line that cannot be built.
        // [GIVEN] A detail response whose first parcel row of line item 58601 returns a quantity of zero
        Response.ReadFrom(_Lib.ReturnDetailResponseParcelQuantities('587', '9587', '#9587', 'SPFYSNOW', '58601', 0, 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('87', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '587', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the return and the line item
        _Assert.ExpectedError('#9587-R1');
        _Assert.ExpectedError('58601');
        _Assert.ExpectedError('with no quantity');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TruncatedOrderAdjustmentsIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] An orderAdjustments connection with more pages than one request reads is refused with an error naming the connection, so the fee and paid-out split is never computed from partial data.
        // [GIVEN] A detail response whose orderAdjustments pageInfo says hasNextPage true
        ResponseText := _Lib.ReturnDetailResponse('576', '9576', '#9576', 'SPFYSNOW', '576', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('76', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"orderAdjustments":{"pageInfo":{"hasNextPage":false}', '"orderAdjustments":{"pageInfo":{"hasNextPage":true}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '576', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the truncated connection
        _Assert.ExpectedError('orderAdjustments');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_GiftCardFlagWrittenAsOn_IsFlagged()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A returned line whose _is_giftcard property is written as "ON", in any letter case, is flagged as a gift card, as it is on the order import.
        // [GIVEN] A return detail whose gift card property reads "ON"
        Response.ReadFrom(_Lib.ReturnDetailResponseGiftCard('577', '9577', '#9577', '777', 1, 50, '71001', _Lib.RefundTxnJson('77', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()).Replace('"key":"_is_giftcard","value":"1"', '"key":"_is_giftcard","value":"ON"'));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '577', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The line is a gift card line
        TempLineBuffer.FindFirst();
        _Assert.IsTrue(TempLineBuffer."Gift Card", 'A gift card flag written as "ON" must count.');
    end;

    [Test]
    procedure PollJQ_OrderListPagingThatNeverEnds_IsStopped()
    var
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A store whose order list paging never advances is stopped at the repeated cursor as a programming bug instead of hanging the job forever.
        // [GIVEN] A legacy-path store with a long lookback so the list filter is stable
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Poll Lookback (Days)" := 3650;
        ShopifyStore.Modify();

        // [GIVEN] Every page of the order list says there is another page with the same cursor
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponseNeverEnding('gid://shopify/Order/9303', 'gid://shopify/Return/1303'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        asserterror SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The run is stopped at the repeated cursor, and the error names the failing store and is a programming bug for Sentry
        _Assert.ExpectedError(StoreCode);
        _Assert.ExpectedError('cursor');
        _Assert.ExpectedError('This is a programming bug');
    end;

    [Test]
    procedure Posting_OppositeAdjustmentsThatCancelOut_PostWithoutAFeeLine()
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
        // [SCENARIO] A return whose refund carries a withheld adjustment of 8 and a paid-out adjustment of 8 nets to nothing: the 100 line refunded 100 posts with no fee line and is not refused as paid beyond the lines.
        // [GIVEN] A legacy-path store with automatic posting and a return of one 100 line refunded 100 with adjustments of +8 and -8
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.InsertQueueRow(StoreCode, '815', '9815', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('815', '9815', '#9815', Sku, '615', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('25', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), '[]', '', _Lib.OrderAdjustmentJson(8, 0, 'REFUND_DISCREPANCY') + ',' + _Lib.OrderAdjustmentJson(-8, 0, 'REFUND_DISCREPANCY')));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Adjustments that cancel out must not block the import
        _Assert.IsTrue(Succeeded, 'Adjustments that cancel out must not block the import: ' + GetLastErrorText());

        // [THEN] The credit memo carries no fee line
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Return Fee G/L Account No.");
        _Assert.IsTrue(SalesCrMemoLine.IsEmpty(), 'Adjustments that net to zero leave no fee line.');
    end;

    [Test]
    procedure Field95_EnablingTheToggle_RegistersTheLegacyJobs()
    var
        ShopifyStore: Record "NPR Spfy Store";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] With the Ecommerce feature off, switching Sales Return Order Integration on for the only store registers both legacy return jobs through the field's validation.
        // [GIVEN] The feature is off, no store has returns on and the legacy jobs are not registered
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        ShopifyStore.ModifyAll("Sales Return Order Integration", false);
        SpfyLegacyReturnPollJQ.SetupJobQueues();
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Precondition: no process job registered.');

        // [WHEN] The legacy store switches returns on through the field
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore.Validate("Sales Return Order Integration", true);

        // [THEN] Both legacy return jobs are registered
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'The poll job must be registered by the toggle.');
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'The process job must be registered by the toggle.');
    end;

    [Test]
    procedure ProcessJQ_FreshProcessingRow_IsLeftAlone()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row at Processing for eight minutes, with a five-minute job interval, is younger than twice the interval and is left to the session that holds it.
        // [GIVEN] A legacy-path store whose Shopify Url is blank, so any attempt would end in Error, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();

        // [GIVEN] A row at Processing since nine minutes ago, one minute inside twice the job interval of 5 minutes
        _Lib.InsertQueueRow(StoreCode, '1011', '9111', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime() - (9 * 60 * 1000);
        QueueRow.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [WHEN] The process job runs
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row is untouched
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Processing, QueueRow.Status, 'A fresh Processing row belongs to another session.');
        _Assert.AreEqual(0, QueueRow."Retry Count", 'No attempt may be recorded.');

        // Cleanup: remove the committed row.
        QueueRow.Delete();
        Commit();
    end;

    [Test]
    [HandlerFunctions('DeclineConfirm')]
    procedure FeatureFlagOn_WithFailedLegacyReturns_AsksAndStopsWhenDeclined()
    var
        Feature: Record "NPR Feature";
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Enabling the feature while a legacy return row sits at Error asks the user to confirm, naming the queue, and stops when the user declines.
        // [GIVEN] No unprocessed legacy return queue rows are left over from other tests that commit rows, since the pre-flight check scans the whole table regardless of store
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off and one row at Error
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Lib.InsertQueueRow(StoreCode, '1616', '9616', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();

        Clear(_CapturedMessage);
        // [WHEN] The pre-flight check for enabling runs and the user declines the question
        Feature.Enabled := true;
        asserterror ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] The question named the queue
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The question must name the legacy return queue: ' + _CapturedMessage);
    end;

    [Test]
    procedure Mgt_ErrorIfAlreadyPosted_ReceiptWithIds_SaysReceivedNotInvoiced()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row whose posted document is a return receipt carrying the return's ids is refused with the received-but-not-invoiced message, naming the receipt and the Return Order to invoice.
        // [GIVEN] A row pointing at return receipt RR-LR1012 of Return Order RO-LR1012, the receipt carrying the return's ids
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1012', '9112', QueueRow);
        _Lib.InsertPostedReceiptWithReturnIds('RR-LR1012', StoreCode, '1012', 'RO-LR1012');
        QueueRow."Posted Doc. No." := 'RR-LR1012';
        QueueRow.Modify();

        // [WHEN] The already-posted guard runs
        asserterror SpfyLegacyReturnMgt.ErrorIfAlreadyPosted(QueueRow);

        // [THEN] The error names the receipt and the Return Order
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RR-LR1012') > 0, 'The error must name the receipt: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RO-LR1012') > 0, 'The error must name the Return Order to invoice: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_ErrorIfAlreadyPosted_ReceiptWithoutIds_IsNotCalledReceived()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row whose posted document number matches a return receipt that does not carry the return's ids is refused as already posted, not as received, since that receipt is not this return's.
        // [GIVEN] A row pointing at return receipt RR-LR1013 of Return Order RO-LR1013, the receipt carrying no Shopify ids
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1013', '9113', QueueRow);
        _Lib.InsertPostedReceipt('RR-LR1013', 'RO-LR1013');
        QueueRow."Posted Doc. No." := 'RR-LR1013';
        QueueRow.Modify();

        // [WHEN] The already-posted guard runs
        asserterror SpfyLegacyReturnMgt.ErrorIfAlreadyPosted(QueueRow);

        // [THEN] The error is the plain already-posted message, which does not point at the Return Order
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RR-LR1013') > 0, 'The error must name the recorded document: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RO-LR1013') = 0, 'A receipt without the ids must not be presented as this return''s receipt: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_ErrorIfAlreadyPosted_CreditMemoWithIds_SaysAlreadyPosted()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row whose posted document is a credit memo carrying the return's ids is refused as already posted, naming the return and the credit memo.
        // [GIVEN] A row pointing at credit memo SCM-LR1014, which carries the return's ids
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1014', '9114', QueueRow);
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR1014', StoreCode, '1014');
        QueueRow."Posted Doc. No." := 'SCM-LR1014';
        QueueRow.Modify();

        // [WHEN] The already-posted guard runs
        asserterror SpfyLegacyReturnMgt.ErrorIfAlreadyPosted(QueueRow);

        // [THEN] The error names the return and the credit memo
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9114-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SCM-LR1014') > 0, 'The error must name the credit memo: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_ErrorIfEcommerceFeatureEnabled_RefusesWhileTheFeatureIsOn()
    var
        Feature: Record "NPR Feature";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        ErrorText: Text;
    begin
        // [SCENARIO] The guard behind the queue page's manual actions refuses while the Shopify Ecommerce Order Experience feature is on, naming the feature and the queue.
        // [GIVEN] The feature row is on
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Feature.Enabled := true;
        Feature.Modify();

        // [WHEN] The guard runs
        asserterror SpfyLegacyReturnMgt.ErrorIfEcommerceFeatureEnabled();
        ErrorText := GetLastErrorText();
        Feature.Enabled := false;
        Feature.Modify();

        // [THEN] The error names the feature and the queue
        _Assert.IsTrue(StrPos(ErrorText, Feature.Description) > 0, 'The error must name the feature: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, QueueRow.TableCaption()) > 0, 'The error must name the queue: ' + ErrorText);
    end;

    [Test]
    procedure Import_GiftCardRefundWithoutId_TwoVoucherPaymentsOnTheOrder_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherA: Record "NPR NpRv Voucher";
        VoucherB: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gift card refund that names no card is refused for manual handling when the order was paid with two vouchers, on two invoices, since the import never guesses between cards.
        // [GIVEN] A store posting manually, vouchers A and B, and an order invoiced twice with one voucher payment on each invoice
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVM', StoreCode, '99720', VoucherA);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVN', StoreCode, '99721', VoucherB);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR972A', StoreCode, '9972', VoucherA."No.");
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR972B', StoreCode, '9972', VoucherB."No.");

        // [GIVEN] A return refunded 300 by card and 200 to a gift card that carries no id
        _Lib.InsertQueueRow(StoreCode, '972', '9972', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('972', '9972', '#9972', Sku, '772', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('81', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('82', 'gift_card', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The import is refused naming the return and the gift cards, and no draft is left
        _Assert.IsFalse(Succeeded, 'Gift cards that cannot be told apart must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9972-R1') > 0, 'The refusal must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'gift cards') > 0, 'The refusal must name the gift cards: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual('', QueueRow."Sales Header Doc. No.", 'No draft may be left.');
    end;

    [Test]
    procedure Import_GiftCardRefundWithoutId_OneVoucherOnTwoPaymentLines_CreditsThatVoucher()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherQ: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A gift card refund that names no card goes back to the order's voucher when that one voucher paid in two transactions, which leaves two payment lines on the invoice: one card on two lines is not two cards.
        // [GIVEN] A legacy-path store with automatic posting, and voucher Q holding 100 that paid 120 and 80 on the order's invoice in two transactions
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVQ', StoreCode, '99750', VoucherQ);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR975', StoreCode, '9975', VoucherQ."No.", 120);
        _Lib.AddVoucherPaymentToPostedInvoice('SI-LR975', VoucherQ."No.", 80);

        // [GIVEN] A return refunded 300 by card and 200 to a gift card that carries no id
        _Lib.InsertQueueRow(StoreCode, '975', '9975', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('975', '9975', '#9975', Sku, '7975', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('97501', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('97502', 'gift_card', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'One voucher on two payment lines must not be taken for two cards: ' + GetLastErrorText());
        // [THEN] The voucher gained the 200
        VoucherQ.CalcFields(Amount);
        _Assert.AreEqual(300, VoucherQ.Amount, 'The gift card share must go back on the order''s one voucher.');
    end;

    [Test]
    procedure Import_TwoGiftCardRefundsWithoutIds_AreRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherB: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Two gift card refund transactions without ids count as two cards, so the return is refused for manual handling even though the order was paid with exactly one voucher.
        // [GIVEN] A store posting manually, voucher B that paid the order on its single invoice
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVO', StoreCode, '99730', VoucherB);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR973', StoreCode, '9973', VoucherB."No.");

        // [GIVEN] A return refunded 300 by card and twice 100 to gift cards without ids
        _Lib.InsertQueueRow(StoreCode, '973', '9973', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('973', '9973', '#9973', Sku, '773', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('83', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('84', 'gift_card', 100, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('85', 'gift_card', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The import is refused naming the return and the gift cards, and no draft is left
        _Assert.IsFalse(Succeeded, 'Gift cards that cannot be told apart must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9973-R1') > 0, 'The refusal must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'gift cards') > 0, 'The refusal must name the gift cards: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual('', QueueRow."Sales Header Doc. No.", 'No draft may be left.');
    end;

    [Test]
    procedure GiftCardProperty_OneTrueAndOn_CountAsGiftCards()
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        CountsOne: Boolean;
        CountsTrue: Boolean;
        CountsTrueUpper: Boolean;
        CountsOn: Boolean;
        CountsOnMixed: Boolean;
        CountsPadded: Boolean;
    begin
        // [SCENARIO] The NP gift card property counts when the storefront writes 1, true or on, in any letter case, with surrounding blanks ignored.
        // [GIVEN] The shared property rule
        // [WHEN] It is asked about the accepted spellings
        CountsOne := SpfyOrderApiHelper.IsGiftCardPropertyValue('1');
        CountsTrue := SpfyOrderApiHelper.IsGiftCardPropertyValue('true');
        CountsTrueUpper := SpfyOrderApiHelper.IsGiftCardPropertyValue('TRUE');
        CountsOn := SpfyOrderApiHelper.IsGiftCardPropertyValue('on');
        CountsOnMixed := SpfyOrderApiHelper.IsGiftCardPropertyValue('On');
        CountsPadded := SpfyOrderApiHelper.IsGiftCardPropertyValue(' 1 ');

        // [THEN] Each of them counts
        _Assert.IsTrue(CountsOne, '1 must count.');
        _Assert.IsTrue(CountsTrue, 'true must count.');
        _Assert.IsTrue(CountsTrueUpper, 'TRUE must count.');
        _Assert.IsTrue(CountsOn, 'on must count.');
        _Assert.IsTrue(CountsPadded, 'A value with surrounding blanks must count.');
        _Assert.IsTrue(CountsOnMixed, 'On must count.');
    end;

    [Test]
    procedure GiftCardProperty_OtherValues_DoNotCount()
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        CountsZero: Boolean;
        CountsTwo: Boolean;
        CountsYes: Boolean;
        CountsFalse: Boolean;
        CountsOff: Boolean;
        CountsEmpty: Boolean;
    begin
        // [SCENARIO] Any other value of the NP gift card property, including an empty one, does not make a line a gift card.
        // [GIVEN] The shared property rule
        // [WHEN] It is asked about values outside the accepted spellings
        CountsZero := SpfyOrderApiHelper.IsGiftCardPropertyValue('0');
        CountsTwo := SpfyOrderApiHelper.IsGiftCardPropertyValue('2');
        CountsYes := SpfyOrderApiHelper.IsGiftCardPropertyValue('yes');
        CountsFalse := SpfyOrderApiHelper.IsGiftCardPropertyValue('false');
        CountsOff := SpfyOrderApiHelper.IsGiftCardPropertyValue('off');
        CountsEmpty := SpfyOrderApiHelper.IsGiftCardPropertyValue('');

        // [THEN] None of them counts
        _Assert.IsFalse(CountsZero, '0 must not count.');
        _Assert.IsFalse(CountsTwo, '2 must not count.');
        _Assert.IsFalse(CountsYes, 'yes must not count.');
        _Assert.IsFalse(CountsFalse, 'false must not count.');
        _Assert.IsFalse(CountsOff, 'off must not count.');
        _Assert.IsFalse(CountsEmpty, 'An empty value must not count.');
    end;

    [Test]
    procedure Posting_ShippingRefund_PostsTheShippingLine()
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
        // [SCENARIO] A return that also refunds shipping of 10 plus 2.5 tax on a tax-exclusive order posts a shipping line of 12.5 on the shipping refund account and the total check passes.
        // [GIVEN] A legacy-path store with automatic posting and the shipping account set, and a return of one 100 line plus refunded shipping of 10 with 2.5 tax, refunded 112.5 in all
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.InsertQueueRow(StoreCode, '816', '9816', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('816', '9816', '#9816', Sku, '616', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('26', 'shopify_payments', 112.5, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), '[]', _Lib.RefundShippingLineJson(10, 2.5)));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The shipping line carries 12.5 on the shipping refund account
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'A shipping line must exist.');
        _Assert.AreEqual(12.5, SalesCrMemoLine."Amount Including VAT", 'The shipping line carries the refunded shipping gross.');
    end;

    [Test]
    procedure Posting_RestockingFee_PostsAFeeLine()
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
        // [SCENARIO] A restocking fee of 10 on the returned line is withheld from the refund: the 100 line refunded 90 posts with a fee line of 10.
        // [GIVEN] A legacy-path store with automatic posting and a return of one 100 line with a restocking fee of 10, refunded 90
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.InsertQueueRow(StoreCode, '817', '9817', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('817', '9817', '#9817', Sku, '617', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('27', 'shopify_payments', 90, _Lib.Lcy(), ''), _Lib.Lcy()).Replace('"restockingFee":null', '"restockingFee":{"amountSet":{"presentmentMoney":{"amount":"10.00"}}}'));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The fee line withholds 10
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Return Fee G/L Account No.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'A fee line must exist.');
        _Assert.AreEqual(-10, SalesCrMemoLine."Amount Including VAT", 'The restocking fee is withheld on the fee line.');
    end;

    [Test]
    procedure Import_MixedDispositions_FlagsTheRowNotRestocked()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return whose line was partly rejected flags the queue row as not restocked, so the user sees that stock did not come back in full.
        // [GIVEN] A store posting manually and a return whose line is restocked to 71001 and rejected to 71002
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '818', '9818', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('818', '9818', '#9818', Sku, '618', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('28', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.MixedDispositionsJson('71001', '71002')));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The row is flagged as not restocked
        QueueRow.Find();
        _Assert.IsTrue(QueueRow."Not Restocked", 'A rejected disposition must flag the row.');
    end;

    [Test]
    procedure Posting_GiftCardRefund_WithoutLiabilityAccount_SettlesAllOnTheCardAccount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        VoucherA: Record "NPR NpRv Voucher";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        GLEntry: Record "G/L Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] With no gift card liability account on the store, the gift card share settles on the card account like the rest, and the voucher is still credited back.
        // [GIVEN] A legacy-path store with automatic posting and a blank gift card account, voucher A behind gift card 9981, and a return refunded 300 by card and 200 to that card, which paid 200 on the order's invoice
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Ret. Gift Card Refund G/L Acc." := '';
        ShopifyStore.Modify();
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVP', StoreCode, '9981', VoucherA);
        _Lib.InsertQueueRow(StoreCode, '981', '9981', QueueRow);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR981', StoreCode, '9981', VoucherA."No.", 200);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('981', '9981', '#9981', Sku, '781', 2, 400, 100, 25, '71001',
            _Lib.RefundTxnJson('91', 'shopify_payments', 300, _Lib.Lcy(), '') + ',' + _Lib.RefundTxnJson('92', 'gift_card', 200, _Lib.Lcy(), '9981'), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The whole refund settles on the card account and the voucher gained the gift card share
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-500, GLEntry.Amount, 'Without a liability account both shares settle on the card account.');
        VoucherA.CalcFields(Amount);
        _Assert.AreEqual(300, VoucherA.Amount, 'The voucher is credited back regardless of the account.');
    end;

    [Test]
    procedure Mgt_FindQueueRowBySalesHeader_IgnoresAHeaderWithoutTheReturnId()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Found: Boolean;
    begin
        // [SCENARIO] A Return Order that merely reuses the number recorded on a queue row, without carrying that return's Shopify id, is not matched to the row, so the posting subscriber never settles an unrelated document as the return.
        // [GIVEN] A row linked to Return Order number RO-LR1015 and a Return Order with that number carrying no Shopify ids
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1015', '9115', QueueRow);
        QueueRow."Sales Header Doc. No." := 'RO-LR1015';
        QueueRow.Modify();
        if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", 'RO-LR1015') then
            SalesHeader.Delete(true);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader."No." := 'RO-LR1015';
        SalesHeader.Insert();

        // [WHEN] The subscriber's row lookup runs for that header
        Found := SpfyLegacyReturnMgt.FindQueueRowBySalesHeader(SalesHeader, QueueRow);

        // [THEN] No row is matched
        _Assert.IsFalse(Found, 'A header without the return id is not this return''s document.');
    end;

    [Test]
    procedure Mgt_FindQueueRowBySalesHeader_TakesTheRowWithTheHeadersReturnIdWhenTwoShareTheNumber()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Found: Boolean;
    begin
        // [SCENARIO] When two queue rows record the same Return Order number, the subscriber's lookup returns the row whose return id the header carries, not whichever row sorts first.
        // [GIVEN] Two rows recording Return Order number RO-LR1023, the first for return 1023 and the second for return 1024, and a Return Order with that number carrying return 1024's ids
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1023', '10023', OtherRow);
        OtherRow."Sales Header Doc. No." := 'RO-LR1023';
        OtherRow.Modify();
        _Lib.InsertQueueRow(StoreCode, '1024', '10024', QueueRow);
        QueueRow."Sales Header Doc. No." := 'RO-LR1023';
        QueueRow.Modify();
        _Lib.InsertReturnOrderWithReturnIds('RO-LR1023', StoreCode, '1024', SalesHeader);
        Clear(QueueRow);

        // [WHEN] The subscriber's row lookup runs for that header
        Found := SpfyLegacyReturnMgt.FindQueueRowBySalesHeader(SalesHeader, QueueRow);

        // [THEN] The row of return 1024 is the one matched
        _Assert.IsTrue(Found, 'The row carrying the header''s return id must be found.');
        _Assert.AreEqual('1024', QueueRow."Source Doc. ID", 'The lookup must return the row whose return id the header carries.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TruncatedReturnLineItemsIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A returnLineItems connection with more pages than one request reads is refused with an error naming the connection, so nothing is computed from partial data.
        // [GIVEN] A detail response whose returnLineItems pageInfo says hasNextPage true
        ResponseText := _Lib.ReturnDetailResponse('580', '9580', '#9580', 'SPFYSNOW', '620', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('30', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"returnLineItems":{"pageInfo":{"hasNextPage":false}', '"returnLineItems":{"pageInfo":{"hasNextPage":true}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '580', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the truncated connection
        _Assert.ExpectedError('returnLineItems');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TruncatedReverseFulfillmentLinesIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A reverseFulfillmentOrders.lineItems connection with more pages than one request reads is refused with an error naming the connection, so nothing is computed from partial data.
        // [GIVEN] A detail response whose reverseFulfillmentOrders.lineItems pageInfo says hasNextPage true
        ResponseText := _Lib.ReturnDetailResponse('581', '9581', '#9581', 'SPFYSNOW', '621', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('31', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"lineItems":{"pageInfo":{"hasNextPage":false}', '"lineItems":{"pageInfo":{"hasNextPage":true}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '581', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the truncated connection
        _Assert.ExpectedError('reverseFulfillmentOrders.lineItems');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TruncatedRefundTransactionsIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A refunds.transactions connection with more pages than one request reads is refused with an error naming the connection, so nothing is computed from partial data.
        // [GIVEN] A detail response whose refunds.transactions pageInfo says hasNextPage true
        ResponseText := _Lib.ReturnDetailResponse('582', '9582', '#9582', 'SPFYSNOW', '622', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('32', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"transactions":{"pageInfo":{"hasNextPage":false}', '"transactions":{"pageInfo":{"hasNextPage":true}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '582', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the truncated connection
        _Assert.ExpectedError('refunds.transactions');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TruncatedRefundLineItemsIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A refunds.refundLineItems connection with more pages than one request reads is refused with an error naming the connection, so nothing is computed from partial data.
        // [GIVEN] A detail response whose refunds.refundLineItems pageInfo says hasNextPage true
        ResponseText := _Lib.ReturnDetailResponse('583', '9583', '#9583', 'SPFYSNOW', '623', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('33', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"refundLineItems":{"pageInfo":{"hasNextPage":false}', '"refundLineItems":{"pageInfo":{"hasNextPage":true}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '583', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the truncated connection
        _Assert.ExpectedError('refunds.refundLineItems');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TruncatedRefundShippingLinesIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A refunds.refundShippingLines connection with more pages than one request reads is refused with an error naming the connection, so nothing is computed from partial data.
        // [GIVEN] A detail response whose refunds.refundShippingLines pageInfo says hasNextPage true
        ResponseText := _Lib.ReturnDetailResponse('584', '9584', '#9584', 'SPFYSNOW', '624', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('34', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        ResponseText := ResponseText.Replace('"refundShippingLines":{"pageInfo":{"hasNextPage":false}', '"refundShippingLines":{"pageInfo":{"hasNextPage":true}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '584', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the truncated connection
        _Assert.ExpectedError('refunds.refundShippingLines');
    end;

    [Test]
    procedure Posting_GiftCardReturn_RefundedBelowFaceValue_ArchivesTheCardAndWritesOffTheRest()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        VoucherNos: List of [Code[20]];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        GLAccountNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A returned gift card sold for 100 but refunded 60 is credited 60, written down by 60 at posting, and the remaining 40 is written off when the card is archived, so no value stays on a returned card.
        // [GIVEN] A posted sale of one 100 gift card on Shopify line 790 and a return of it refunded 60 by card
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC9', StoreCode, '9590', '790', GLAccountNo, 1, 100, VoucherNos);
        _Lib.InsertQueueRow(StoreCode, '590', '9590', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('590', '9590', '#9590', '790', 1, 60, '71001', _Lib.RefundTxnJson('90', 'shopify_payments', 60, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo carries the refunded 60
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange("No.", GLAccountNo);
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The gift card line must exist.');
        _Assert.AreEqual(60, SalesCrMemoLine."Amount Including VAT", 'The credit is what Shopify refunded.');

        // [THEN] The card is archived with nothing left on it
        _Assert.IsTrue(ArchVoucher.Get(VoucherNos.Get(1)), 'The card must be archived.');
        ArchVoucherEntry.SetRange("Arch. Voucher No.", VoucherNos.Get(1));
        ArchVoucherEntry.CalcSums(Amount);
        _Assert.AreEqual(0, ArchVoucherEntry.Amount, 'The 60 reversal and the 40 write-off must leave the card at zero.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_GiftCardKeyWithoutUnderscore_IsFlagged()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
    begin
        // [SCENARIO] A returned line whose gift card property key is written without the leading underscore, which the legacy order import accepts, is flagged as a gift card on the return as well.
        // [GIVEN] A return detail whose gift card property key reads is_giftcard
        Response.ReadFrom(_Lib.ReturnDetailResponseGiftCard('591', '9591', '#9591', '791', 1, 50, '71001', _Lib.RefundTxnJson('93', 'shopify_payments', 50, _Lib.Lcy(), ''), _Lib.Lcy()).Replace('"key":"_is_giftcard"', '"key":"is_giftcard"'));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '591', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The line is a gift card line
        TempLineBuffer.FindFirst();
        _Assert.IsTrue(TempLineBuffer."Gift Card", 'The key without the underscore must count, as it does on the order import.');
    end;

    [Test]
    procedure Import_AdoptedDraft_WithAnExchangeLine_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ResponseText: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A draft the other engine left for a return that carries an exchange line is refused like a fresh import of that return would be, and stays unlinked.
        // [GIVEN] A legacy-path store and an unlinked Return Order draft for return 1405
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ResponseText := _Lib.ReturnDetailResponse('1405', '9405', '#9405', Sku, '805', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('95', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy());
        _Lib.InsertQueueRow(StoreCode, '1405', '9405', QueueRow);
        _Lib.BuildUnlinkedDraft(QueueRow, ResponseText, SalesHeader);

        // [GIVEN] Shopify now reports an exchange line on the return
        MockClient.AddResponse('GetReturn', ResponseText.Replace('"exchangeLineItems":{"edges":[]}', '"exchangeLineItems":{"edges":[{"node":{"id":"gid://shopify/ExchangeLineItem/1"}}]}'));

        // [WHEN] The legacy import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] An exchange must be refused on an adopted draft too
        _Assert.IsFalse(Succeeded, 'An exchange must be refused on an adopted draft too.');

        // [THEN] The error names the exchange and the draft stays unlinked
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'exchange') > 0, 'The error must name the exchange line: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual('', QueueRow."Sales Header Doc. No.", 'A refused adoption must leave the draft unlinked.');
    end;

    [Test]
    procedure Mgt_DeletingQueueRowOfReceivedReturn_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SalesHeader: Record "Sales Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] A queue row whose return was received but not yet invoiced cannot be deleted while its Return Order still awaits the invoice, since that credit memo can only be settled through the row.
        // [GIVEN] A Shopify store and a committed row whose return receipt RR-LR1016 carries the return's ids, with its Return Order RO-LR1016 still open
        LibrarySpfyImport.CreateStore('SPFYLRM8');
        _Lib.InsertQueueRow('SPFYLRM8', '1016', '9116', QueueRow);
        _Lib.InsertPostedReceiptWithReturnIds('RR-LR1016', 'SPFYLRM8', '1016', 'RO-LR1016');
        _Lib.InsertReturnOrderWithReturnIds('RO-LR1016', 'SPFYLRM8', '1016', SalesHeader);
        QueueRow."Posted Doc. No." := 'RR-LR1016';
        QueueRow.Modify();
        Commit();

        // [WHEN] The queue row is deleted
        asserterror QueueRow.Delete(true);

        // [THEN] The deletion is refused naming the receipt and the Return Order, and the row still exists
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RR-LR1016') > 0, 'The error must name the receipt: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RO-LR1016') > 0, 'The error must name the Return Order to invoice: ' + GetLastErrorText());
        _Assert.IsTrue(QueueRow.FindSourceDoc('SPFYLRM8', QueueRow."Source Doc. Type"::Return, '1016'), 'The row must survive a refused deletion.');

        // Cleanup: remove the committed row, receipt and Return Order.
        QueueRow.Delete();
        if ReturnReceiptHeader.Get('RR-LR1016') then
            ReturnReceiptHeader.Delete();
        if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", 'RO-LR1016') then
            SalesHeader.Delete(true);
        Commit();
    end;

    [Test]
    procedure Posting_DefaultQuantityToShipBlank_PostsTheFullReturn()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        OriginalDefault: Integer;
        Imported: Boolean;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] With "Default Quantity to Ship" set to Blank in the sales setup, where the platform leaves the quantities to post at zero, an automatically posted return still posts its full quantity.
        // [GIVEN] A sales setup with Default Quantity to Ship Blank, and a legacy-path store with automatic posting
        SalesSetup.Get();
        OriginalDefault := SalesSetup."Default Quantity to Ship";
        SalesSetup."Default Quantity to Ship" := SalesSetup."Default Quantity to Ship"::Blank;
        SalesSetup.Modify();
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '819', '9819', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('819', '9819', '#9819', Sku, '619', 2, 160, 40, 25, '71001', _Lib.RefundTxnJson('29', 'shopify_payments', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Imported := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore and commit the sales setup before asserting; the import committed the Blank default, so a failing assertion must not roll the restore back.
        SalesSetup.Get();
        SalesSetup."Default Quantity to Ship" := OriginalDefault;
        SalesSetup.Modify();
        Commit();

        // [THEN] The return posted in full
        _Assert.IsTrue(Imported, 'Import and posting must succeed with a blank default quantity: ' + GetLastErrorText());
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'The item line must be on the credit memo.');
        _Assert.AreEqual(2, SalesCrMemoLine.Quantity, 'The whole returned quantity must be posted.');
    end;

    [Test]
    procedure QueuePage_Process_RefusesWhileTheEcommerceFeatureIsOn()
    var
        Feature: Record "NPR Feature";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The queue page's Process action refuses while the Shopify Ecommerce Order Experience feature is on, naming the feature.
        // [GIVEN] A queued return and the feature row switched on
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1020', '9120', QueueRow);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Feature.Enabled := true;
        Feature.Modify();

        // [WHEN] Process is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        asserterror QueuePage.ProcessRow.Invoke();
        ErrorText := GetLastErrorText();
        QueuePage.Close();
        Feature.Enabled := false;
        Feature.Modify();

        // [THEN] The action refused, naming the feature
        _Assert.IsTrue(StrPos(ErrorText, Feature.Description) > 0, 'Process must refuse while the feature is on: ' + ErrorText);
    end;

    [Test]
    procedure QueuePage_DiscardDraft_RefusesWhileTheEcommerceFeatureIsOn()
    var
        Feature: Record "NPR Feature";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The queue page's Discard Draft and Retry action refuses while the Shopify Ecommerce Order Experience feature is on, naming the feature.
        // [GIVEN] A queued return and the feature row switched on
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1021', '9121', QueueRow);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Feature.Enabled := true;
        Feature.Modify();

        // [WHEN] Discard Draft and Retry is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        asserterror QueuePage.DiscardDraftAndRetry.Invoke();
        ErrorText := GetLastErrorText();
        QueuePage.Close();
        Feature.Enabled := false;
        Feature.Modify();

        // [THEN] The action refused, naming the feature
        _Assert.IsTrue(StrPos(ErrorText, Feature.Description) > 0, 'Discard Draft and Retry must refuse while the feature is on: ' + ErrorText);
    end;

    [Test]
    procedure QueuePage_PollNow_RefusesWhileTheEcommerceFeatureIsOn()
    var
        Feature: Record "NPR Feature";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The queue page's Poll Shopify Now action refuses while the Shopify Ecommerce Order Experience feature is on, naming the feature.
        // [GIVEN] A legacy-path store and the feature row switched on
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Feature.Enabled := true;
        Feature.Modify();

        // [WHEN] Poll Shopify Now is invoked
        QueuePage.OpenView();
        asserterror QueuePage.PollNow.Invoke();
        ErrorText := GetLastErrorText();
        QueuePage.Close();
        Feature.Enabled := false;
        Feature.Modify();

        // [THEN] The action refused, naming the feature
        _Assert.IsTrue(StrPos(ErrorText, Feature.Description) > 0, 'Poll Shopify Now must refuse while the feature is on: ' + ErrorText);
    end;

    [Test]
    procedure OrderMgt_SetupJobQueues_RegistersTheLegacyReturnJobs()
    var
        ShopifyStore: Record "NPR Spfy Store";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The legacy order path's own job registration, which every existing switch point calls, registers the legacy return jobs too.
        // [GIVEN] The feature is off, a legacy store with returns on, and the legacy return jobs cancelled
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        ShopifyStore.ModifyAll("Sales Return Order Integration", false);
        SpfyLegacyReturnPollJQ.SetupJobQueues();
        _Assert.IsFalse(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'Precondition: no process job registered.');
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Sales Return Order Integration" := true;
        ShopifyStore.Modify();

        // [WHEN] The order path's job registration runs
        SpfyOrderMgt.SetupJobQueues();

        // [THEN] Both legacy return jobs are registered
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Poll JQ"), 'The poll job must be registered by the order path.');
        _Assert.IsTrue(SpfyLegacyReturnPollJQ.JobQueueEntryExists(Codeunit::"NPR Spfy Legacy Return Proc JQ"), 'The process job must be registered by the order path.');
    end;

    [Test]
    procedure PollJQ_WindowStart_DefaultsToThirtyDaysBack()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        WindowStart: DateTime;
        ThirtyDays: Duration;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] With no lookback set and a start date far in the past, the poll window begins thirty days ago.
        // [GIVEN] A store with lookback 0 and a start date in 2020
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Poll Lookback (Days)" := 0;
        ShopifyStore."Get Returns Starting From" := CreateDateTime(20200101D, 0T);

        // [WHEN] The window start is computed
        WindowStart := SpfyLegacyReturnPollJQ.WindowStart(ShopifyStore);

        // [THEN] It lies thirty days back, within a couple of minutes
        ThirtyDays := 30;
        ThirtyDays := ThirtyDays * 24 * 60 * 60 * 1000;
        _Assert.IsTrue(Abs(WindowStart - (CurrentDateTime() - ThirtyDays)) < 120000, 'The default window is thirty days.');
    end;

    [Test]
    procedure PollJQ_WindowStart_StartsAtTheStoreDateWhenLater()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        WindowStartDT: DateTime;
    begin
        // [SCENARIO] A start date inside the lookback becomes the window start, so returns closed before it are never scanned.
        // [GIVEN] A store with a ten-year lookback and a start date of 2026-01-01
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Poll Lookback (Days)" := 3650;
        ShopifyStore."Get Returns Starting From" := CreateDateTime(20260101D, 0T);

        // [WHEN] The window start is computed
        WindowStartDT := SpfyLegacyReturnPollJQ.WindowStart(ShopifyStore);

        // [THEN] It is the start date
        _Assert.AreEqual(CreateDateTime(20260101D, 0T), WindowStartDT, 'A later start date wins over the lookback.');
    end;

    [Test]
    procedure Mgt_ErrorIfAlreadyPosted_SharedNumber_PrefersTheReceiptWithIds()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] When a credit memo without the return's ids and a return receipt with them share the number recorded on the row, the receipt is this return's document and the error says received, not invoiced.
        // [GIVEN] A credit memo SH-LR1018 carrying no ids, a return receipt SH-LR1018 carrying the return's ids, and a row recording that number
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1018', '9118', QueueRow);
        if not SalesCrMemoHeader.Get('SH-LR1018') then begin
            SalesCrMemoHeader.Init();
            SalesCrMemoHeader."No." := 'SH-LR1018';
            SalesCrMemoHeader.Insert();
        end;
        _Lib.InsertPostedReceiptWithReturnIds('SH-LR1018', StoreCode, '1018', 'RO-LR1018');
        QueueRow."Posted Doc. No." := 'SH-LR1018';
        QueueRow.Modify();

        // [WHEN] The already-posted guard runs
        asserterror SpfyLegacyReturnMgt.ErrorIfAlreadyPosted(QueueRow);

        // [THEN] The error points at the Return Order to invoice, not at the unrelated credit memo
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RO-LR1018') > 0, 'The receipt with the ids decides: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_IsCreditMemoPosted_IgnoresACreditMemoOfAnotherStore()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        IsPosted: Boolean;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A credit memo carrying the return id of another store's return is not this row's credit memo.
        // [GIVEN] A row whose posted document number matches a credit memo carrying the same return id but another store code
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1019', '9119', QueueRow);
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR1019', 'SPFYLROTHER', '1019');
        QueueRow."Posted Doc. No." := 'SCM-LR1019';
        QueueRow.Modify();

        // [WHEN] The row is checked for its credit memo
        IsPosted := SpfyLegacyReturnMgt.IsCreditMemoPosted(QueueRow);

        // [THEN] The other store's credit memo does not count
        _Assert.IsFalse(IsPosted, 'The store code must match as well as the return id.');
    end;

    [Test]
    procedure Posting_ShippingRefund_TaxesIncluded_AddsTheTaxToTheSubtotal()
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
        // [SCENARIO] On an order with taxes included, refunded shipping reported as 12.5 with 2.5 tax is 15 gross, because Shopify reports a refunded shipping line net of tax with the tax separate even when prices include tax, so a 100 line plus the shipping refunded 115 posts with a shipping line of 15.
        // [GIVEN] A legacy-path store with automatic posting and a taxes-included return of one 100 line plus refunded shipping of 12.5 with 2.5 tax, refunded 115 in all
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.InsertQueueRow(StoreCode, '820', '9820', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('820', '9820', '#9820', Sku, '620', 1, 100, 0, 0, '71001', _Lib.RefundTxnJson('30', 'shopify_payments', 115, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), '[]', _Lib.RefundShippingLineJson(12.5, 2.5)).Replace('"taxesIncluded":false', '"taxesIncluded":true'));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The shipping line carries 15
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'A shipping line must exist.');
        _Assert.AreEqual(15, SalesCrMemoLine."Amount Including VAT", 'Refunded shipping is the subtotal plus its tax, with taxes included too.');
    end;

    [Test]
    procedure Posting_ShippingRefundAndReturnFee_TaxesIncluded_PostsTheRefundedTotal()
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
        // [SCENARIO] A taxes-included return at the amounts of QA return #1159-R1, an item of 612.48 including 122.50 tax, refunded shipping of 23.20 with 5.80 tax and a 40.00 return fee, posts a credit memo of the 601.48 Shopify refunded, with the shipping line at 29.00 and the fee line at minus 40.00.
        // [GIVEN] A legacy-path store with automatic posting and a taxes-included return of one 612.48 line, refunded shipping of 23.20 with 5.80 tax, a 40.00 return shipping fee, refunded 601.48 in all
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.InsertQueueRow(StoreCode, '1159', '91159', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1159', '91159', '#1159', Sku, '51159', 1, 612.48, 122.5, 25, '71001', _Lib.RefundTxnJson('1159', 'shopify_payments', 601.48, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), _Lib.ReturnShippingFeeJson(40), _Lib.RefundShippingLineJson(23.2, 5.8)).Replace('"taxesIncluded":false', '"taxesIncluded":true'));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The credit memo is worth what Shopify refunded
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoHeader.CalcFields("Amount Including VAT");
        _Assert.AreEqual(601.48, SalesCrMemoHeader."Amount Including VAT", 'The credit memo must equal the refunded amount.');

        // [THEN] The shipping line carries the shipping price including its tax and the fee line the withheld fee
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'A shipping line must exist.');
        _Assert.AreEqual(29, SalesCrMemoLine."Amount Including VAT", 'The shipping line must carry 23.20 plus 5.80.');
        SalesCrMemoLine.SetRange("No.", ShopifyStore."Return Fee G/L Account No.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'A fee line must exist.');
        _Assert.AreEqual(-40, SalesCrMemoLine."Amount Including VAT", 'The fee line must carry the withheld 40.00.');
    end;

    [Test]
    procedure Posting_ParcelsWithUnequalQuantities_SplitTheGrossByQuantity()
    var
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
        // [SCENARIO] An order line of three units shipped as a parcel of two and a parcel of one, refunded 90 in one refund line, is split 60 and 30 across the two return lines by quantity.
        // [GIVEN] A legacy-path store with automatic posting and such a return refunded 90 by card
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '821', '9821', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseParcelQuantities('821', '9821', '#9821', Sku, '621', 2, 1, 72, 18, 25, '71001', _Lib.RefundTxnJson('31', 'shopify_payments', 90, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The two item lines carry 60 and 30
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::Item);
        _Assert.IsTrue(SalesCrMemoLine.FindSet(), 'Two item lines expected.');
        _Assert.AreEqual(60, SalesCrMemoLine."Amount Including VAT", 'The parcel of two carries two thirds of the gross.');
        SalesCrMemoLine.Next();
        _Assert.AreEqual(30, SalesCrMemoLine."Amount Including VAT", 'The parcel of one carries one third of the gross.');
    end;

    [Test]
    procedure Import_GenericSkuPrefix_UsesTheGenericItem()
    var
        ShopifyStore: Record "NPR Spfy Store";
        GenericItem: Record Item;
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesLine: Record "Sales Line";
        LibraryInventory: Codeunit "Library - Inventory";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ImportSucceeded: Boolean;
    begin
        // [SCENARIO] A returned product whose SKU starts with the store's generic prefix is imported on the store's generic item, with the Shopify title as description and the SKU kept, without looking the SKU up.
        // [GIVEN] A store posting manually with a generic non-inventory item and the prefix GEN-, and a return of a GEN- product that exists nowhere in Business Central
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LibraryInventory.CreateItem(GenericItem);
        GenericItem.Validate(Type, GenericItem.Type::"Non-Inventory");
        GenericItem.Modify(true);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore."Return Generic Item No." := GenericItem."No.";
        ShopifyStore."Return Generic SKU Prefix" := 'GEN-';
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '822', '9822', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('822', '9822', '#9822', 'GEN-XYZ', '622', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('32', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        ImportSucceeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: clear the committed generic item and prefix before asserting, so later unknown-SKU tests are refused as they expect.
        ShopifyStore.Find();
        ShopifyStore."Return Generic Item No." := '';
        ShopifyStore."Return Generic SKU Prefix" := '';
        ShopifyStore.Modify();
        Commit();

        // [THEN] The draft built on the generic item
        _Assert.IsTrue(ImportSucceeded, 'The draft must build on the generic item: ' + GetLastErrorText());

        // [THEN] The line is the generic item with the SKU kept
        QueueRow.Find();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        _Assert.IsTrue(SalesLine.FindFirst(), 'An item line must exist.');
        _Assert.AreEqual(GenericItem."No.", SalesLine."No.", 'The generic item must be used.');
        _Assert.AreEqual('GEN-XYZ', SalesLine."Description 2", 'The SKU must be kept on the line.');
        _Assert.AreEqual('Test jacket', SalesLine.Description, 'The generic line carries the Shopify title as its description.');
    end;

    [Test]
    procedure Upgrade_PostReturnsAutomatically_IsSwitchedOnForExistingStores()
    var
        ShopifyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyAppUpgrade: Codeunit "NPR Spfy App Upgrade";
    begin
        // [SCENARIO] The upgrade step switches Post Returns Automatically on for a store that existed before the field, so existing stores behave like new ones.
        // [GIVEN] A store with the flag off
        LibrarySpfyImport.CreateStore('SPFYLRUPG');
        ShopifyStore.Get('SPFYLRUPG');
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();

        // [WHEN] The upgrade step's work runs
        SpfyAppUpgrade.SwitchPostReturnsAutomaticallyOn();

        // [THEN] The flag is on
        ShopifyStore.Get('SPFYLRUPG');
        _Assert.IsTrue(ShopifyStore."Post Returns Automatically", 'Existing stores must post returns automatically after the upgrade.');
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure FeatureFlagOn_IsRefusedWhileALegacyRowIsProcessing()
    var
        Feature: Record "NPR Feature";
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Enabling the feature is refused while a legacy return row is being processed, so the other engine cannot take over a return mid-import.
        // [GIVEN] No unprocessed legacy return queue rows are left over from other tests that commit rows, since the pre-flight check scans the whole table regardless of store
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off and a row at Processing
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Lib.InsertQueueRow(StoreCode, '1617', '9617', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow.Modify();

        Clear(_CapturedMessage);
        // [WHEN] The pre-flight check for enabling runs
        Feature.Enabled := true;
        asserterror ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] It refuses, surfacing a message that names the queue
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The message must name the legacy return queue.');
    end;

    [Test]
    procedure ProcessJQ_DraftCreatedRow_IsNotRevisited()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row at Draft Created is left alone by the process job; the draft is posted by hand or once automatic posting is switched on and the row is processed again.
        // [GIVEN] A legacy-path store whose Shopify Url is blank, so any attempt would end in Error, and a row at Draft Created, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1022', '9122', QueueRow);
        QueueRow.Status := QueueRow.Status::"Draft Created";
        QueueRow.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [WHEN] The process job runs
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row is untouched
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::"Draft Created", QueueRow.Status, 'A Draft Created row is not revisited by the job.');
        _Assert.AreEqual(0, QueueRow."Retry Count", 'No attempt may be recorded.');

        // Cleanup: remove the committed row.
        QueueRow.Delete();
        Commit();
    end;

    [Test]
    procedure Mgt_StoreDisabled_RefusesTheManualProcess()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The manual Process guard refuses a row of a disabled store, naming the store, since a disabled store imports nothing whatever its return toggle says.
        // [GIVEN] A legacy-path store that is disabled while its return toggle stays on
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore.Enabled := false;
        ShopifyStore.Modify();

        // [WHEN] The manual guard runs for the store
        asserterror SpfyLegacyReturnMgt.ErrorIfReturnsSwitchedOff(StoreCode);

        // [THEN] The error names the store
        _Assert.IsTrue(StrPos(GetLastErrorText(), StoreCode) > 0, 'The error must name the store: ' + GetLastErrorText());
    end;

    [Test]
    procedure Import_DefaultQuantityToShipBlank_ManualPostingDraftCarriesTheQuantitiesToPost()
    var
        SalesSetup: Record "Sales & Receivables Setup";
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesLine: Record "Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        OriginalDefault: Integer;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Imported: Boolean;
    begin
        // [SCENARIO] With "Default Quantity to Ship" set to Blank and automatic posting off, the draft the import builds already carries the full quantity to receive and invoice, so a user can post it without filling the lines.
        // [GIVEN] A sales setup with Default Quantity to Ship Blank and a legacy-path store posting manually
        SalesSetup.Get();
        OriginalDefault := SalesSetup."Default Quantity to Ship";
        SalesSetup."Default Quantity to Ship" := SalesSetup."Default Quantity to Ship"::Blank;
        SalesSetup.Modify();
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1040', '9140', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1040', '9140', '#9140', Sku, '1040', 2, 160, 40, 25, '71001', _Lib.RefundTxnJson('1040', 'shopify_payments', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Imported := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore and commit the sales setup before asserting; the import committed the Blank default.
        SalesSetup.Get();
        SalesSetup."Default Quantity to Ship" := OriginalDefault;
        SalesSetup.Modify();
        Commit();

        // [THEN] Every line of the draft has its full quantity to receive and to invoice
        _Assert.IsTrue(Imported, 'The draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        SalesLine.SetFilter(Quantity, '<>0');
        _Assert.IsTrue(SalesLine.FindSet(), 'The draft must have lines.');
        repeat
            _Assert.AreEqual(SalesLine.Quantity, SalesLine."Return Qty. to Receive", 'The line must be ready to receive in full.');
            _Assert.AreEqual(SalesLine.Quantity, SalesLine."Qty. to Invoice", 'The line must be ready to invoice in full.');
        until SalesLine.Next() = 0;
    end;

    [Test]
    procedure Import_RetryOfAnEditedDraft_IsRefusedWhenItsTotalFallsBelowThePayments()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A retry that reuses the row's own committed draft checks the draft against its payment lines, so a draft whose line was lowered by hand after a failed posting is refused instead of posting less than Shopify refunded.
        // [GIVEN] A legacy-path store with automatic posting and no refund account, so the first attempt commits the draft and fails in settlement
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Refund G/L Account No." := '';
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1041', '9141', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1041', '9141', '#9141', Sku, '1041', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1041', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsFalse(_Lib.RunImport(QueueRow, MockClient), 'The automatic posting must fail without a refund account.');
        QueueRow.Find();

        // [GIVEN] The draft's item line is lowered to 50 by hand and the refund account is set
        SalesLine.SetRange("Document Type", SalesLine."Document Type"::"Return Order");
        SalesLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine.Validate("Line Amount", 50);
        SalesLine.Modify(true);
        ShopifyStore.Find();
        ShopifyStore."Return Refund G/L Account No." := _Lib.CreateDirectPostingGLAccount();
        ShopifyStore.Modify();
        Commit();

        // [WHEN] The row is processed again
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A draft worth less than its payment lines must not post
        _Assert.IsFalse(Succeeded, 'A draft worth less than its payment lines must not post.');

        // [THEN] The error is the short-total error, the draft survives and no credit memo exists
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'short by') > 0, 'The error must report the short total: ' + GetLastErrorText());
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No."), 'The draft must survive the refused retry.');
        SalesCrMemoHeader.SetRange("Return Order No.", QueueRow."Sales Header Doc. No.");
        _Assert.IsTrue(SalesCrMemoHeader.IsEmpty(), 'No credit memo may exist.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1041');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ReturnApi_ParseDetail_MissingOrderIsAnError()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A return detail without its order is refused, because the customer, the currency and every amount rule depend on the order.
        // [GIVEN] A detail response whose order block is renamed away
        ResponseText := _Lib.ReturnDetailResponse('1042', '9142', '#9142', 'SPFYSNOW', '1042', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1042', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"order":{') > 0, 'Precondition: the fixture carries the order.');
        ResponseText := ResponseText.Replace('"order":{', '"orderGone":{');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '1042', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error is the missing-value error and names the order
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Required value missing') > 0, 'The missing order must raise the required-value error: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'order') > 0, 'The error must name the order: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_DeletingQueueRowOfReceivedReturnInvoicedElsewhere_IsAllowed()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ReturnReceiptHeader: Record "Return Receipt Header";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row whose return was received and then invoiced through a separate credit memo, so that its Return Order no longer exists, can be deleted: there is no invoice left for the row to settle.
        // [GIVEN] A committed row whose return receipt RR-LR1043 carries the return's ids and names a Return Order that no longer exists
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1043', '9143', QueueRow);
        _Lib.InsertPostedReceiptWithReturnIds('RR-LR1043', StoreCode, '1043', 'RO-LR1043');
        QueueRow."Posted Doc. No." := 'RR-LR1043';
        QueueRow.Status := QueueRow.Status::"Draft Created";
        QueueRow.Modify();
        Commit();

        // [WHEN] The queue row is deleted
        QueueRow.Delete(true);

        // [THEN] The row is gone
        _Assert.IsFalse(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1043'), 'A row with nothing left to settle must be deletable.');

        // Cleanup: remove the committed receipt.
        if ReturnReceiptHeader.Get('RR-LR1043') then
            ReturnReceiptHeader.Delete();
        Commit();
    end;

    [Test]
    procedure Mgt_ProcessingAReceivedReturnInvoicedElsewhere_SaysToDismissTheRow()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Processing a row whose return was received and whose Return Order no longer exists tells the user the return was invoiced outside the import and to dismiss the row, instead of asking them to invoice a document that is gone.
        // [GIVEN] A row whose return receipt RR-LR1044 carries the return's ids and names a Return Order that no longer exists
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1044', '9144', QueueRow);
        _Lib.InsertPostedReceiptWithReturnIds('RR-LR1044', StoreCode, '1044', 'RO-LR1044');
        QueueRow."Posted Doc. No." := 'RR-LR1044';
        QueueRow.Modify();

        // [WHEN] The already-posted guard runs for the row
        asserterror SpfyLegacyReturnMgt.ErrorIfAlreadyPosted(QueueRow);

        // [THEN] The error names the receipt and tells the user to dismiss the row
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RR-LR1044') > 0, 'The error must name the receipt: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'dismiss the queue row') > 0, 'The error must offer the dismissal as the remedy: ' + GetLastErrorText());
        if ReturnReceiptHeader.Get('RR-LR1044') then
            ReturnReceiptHeader.Delete();
    end;

    [Test]
    procedure Mgt_DeletingTheRowAnotherSessionIsProcessing_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Deleting a row that another session is processing right now is refused and its draft survives, so that session's posting is not pulled from under it.
        // [GIVEN] A committed row at Processing, attempted just now, linked to a Return Order draft
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1045', '9145', QueueRow);
        _Lib.InsertReturnOrderWithReturnIds('RO-LR1045', StoreCode, '1045', SalesHeader);
        QueueRow."Sales Header Doc. No." := SalesHeader."No.";
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();
        Commit();

        // [WHEN] The queue row is deleted
        asserterror QueueRow.Delete(true);

        // [THEN] The error names the return and both the row and the draft survive
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9145-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1045'), 'The row must survive a refused deletion.');
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", 'RO-LR1045'), 'The draft must survive a refused deletion.');

        // Cleanup: remove the committed row and draft.
        QueueRow.Delete();
        SalesHeader.Delete();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_StaleProcessingRowAtTheRetryLimit_EndsInErrorWithoutAnotherAttempt()
    var
        ShopifyStore: Record "NPR Spfy Store";
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalLimit: Integer;
    begin
        // [SCENARIO] A row left at Processing by a session that died is a lost attempt: when the lost attempt reaches the retry limit the row ends at Error with a message saying so, instead of being picked up again on every run.
        // [GIVEN] A legacy-path store with a posting-capable customer, item and location, and no unfinished rows left behind by earlier tests
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();

        // [GIVEN] A retry limit of 3, a store whose Shopify Url is blank so any attempt would fail, and a row stuck at Processing for eleven minutes, one minute past twice the job interval of 5, with two retries already counted
        if not SpfyIntegrationSetup.Get() then
            SpfyIntegrationSetup.Insert();
        OriginalLimit := SpfyIntegrationSetup."Max Doc Process Retry Count";
        SpfyIntegrationSetup."Max Doc Process Retry Count" := 3;
        SpfyIntegrationSetup.Modify();
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Shopify Url" := '';
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1046', '9146', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime() - (11 * 60 * 1000);
        QueueRow."Retry Count" := 2;
        QueueRow.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [WHEN] The process job runs
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // Cleanup: restore the retry limit before asserting.
        SpfyIntegrationSetup.Get();
        SpfyIntegrationSetup."Max Doc Process Retry Count" := OriginalLimit;
        SpfyIntegrationSetup.Modify();
        Commit();

        // [THEN] The row is at Error with the lost-attempt message and three retries, and was not attempted again
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'The row must end at Error.');
        _Assert.AreEqual(3, QueueRow."Retry Count", 'The lost attempt must count as the last retry.');
        _Assert.IsTrue(StrPos(QueueRow."Last Error", 'did not finish') > 0, 'The error must say the attempt was lost: ' + QueueRow."Last Error");
        _Assert.IsTrue(StrPos(QueueRow."Last Error", '#9146-R1') > 0, 'The error must name the return: ' + QueueRow."Last Error");

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1046');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_TheSameBugOnTwoRowsOfOneStore_IsReportedToSentryOnce()
    var
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        OriginalLimit: Integer;
    begin
        // [SCENARIO] Two rows of one store that fail on the same programming bug produce one Sentry report in a run, keyed on the error site rather than on the error text, which names the return.
        // [GIVEN] No unfinished rows left behind by earlier tests, a retry limit of 1 so the first failure reports, and two rows for a store that does not exist
        _Lib.DeleteUnfinishedQueueRows();
        if not SpfyIntegrationSetup.Get() then
            SpfyIntegrationSetup.Insert();
        OriginalLimit := SpfyIntegrationSetup."Max Doc Process Retry Count";
        SpfyIntegrationSetup."Max Doc Process Retry Count" := 1;
        SpfyIntegrationSetup.Modify();
        QueueRow.Init();
        QueueRow."Entry No." := 0;
        QueueRow."Shopify Store Code" := 'SPFYLRGON2';
        QueueRow."Source Doc. ID" := '1047';
        QueueRow.Status := QueueRow.Status::New;
        QueueRow.Insert(true);
        QueueRow.Init();
        QueueRow."Entry No." := 0;
        QueueRow."Shopify Store Code" := 'SPFYLRGON2';
        QueueRow."Source Doc. ID" := '1048';
        QueueRow.Status := QueueRow.Status::New;
        QueueRow.Insert(true);
        Commit();

        // [WHEN] The process job runs while Sentry payloads are captured
        SentryCapture.Start();
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);
        SentryCapture.Stop();

        // Cleanup: restore the retry limit and remove the committed rows before asserting.
        SpfyIntegrationSetup.Get();
        SpfyIntegrationSetup."Max Doc Process Retry Count" := OriginalLimit;
        SpfyIntegrationSetup.Modify();
        QueueRow.SetRange("Shopify Store Code", 'SPFYLRGON2');
        QueueRow.DeleteAll();
        Commit();

        // [THEN] The first return was reported and the second, failing at the same site, was folded into it
        _Assert.IsTrue(SentryCapture.Contains('1047'), 'The first return of the missing store must be reported.');
        _Assert.IsFalse(SentryCapture.Contains('1048'), 'The second return fails on the same bug at the same site, so it must not be reported again.');
    end;

    [Test]
    procedure ProcessJQ_SuccessfulPostingThroughTheJob_MarksTheRowImported()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] When the process job itself posts a return successfully, the row ends Imported with the credit memo number and no error, through the job's own success path.
        // [GIVEN] A legacy-path store with automatic posting and no refund account, so the first attempt commits the draft and fails in settlement
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Refund G/L Account No." := '';
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1049', '9149', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1049', '9149', '#9149', Sku, '1049', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1049', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsFalse(_Lib.RunImport(QueueRow, MockClient), 'The automatic posting must fail without a refund account.');
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Retry Count" := 1;
        QueueRow.Modify();

        // [GIVEN] The refund account is set, so the committed draft can post without another Shopify call
        ShopifyStore.Find();
        ShopifyStore."Return Refund G/L Account No." := _Lib.CreateDirectPostingGLAccount();
        ShopifyStore.Modify();
        Commit();

        // [WHEN] The job processes the row
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is Imported with the credit memo number and no error
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The job must mark a posted row Imported.');
        _Assert.AreEqual(SalesCrMemoHeader."No.", QueueRow."Posted Doc. No.", 'The row must carry the credit memo number.');
        _Assert.AreEqual('', QueueRow."Last Error", 'The old error must be cleared.');

        // Cleanup: remove the committed rows.
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.SetFilter("Source Doc. ID", '1049');
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure Import_RefundInAnotherShopCurrency_KeepsTheShopAmountOnThePaymentLine()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        PaymentLine: Record "NPR Magento Payment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund whose shop-currency leg differs from the presentment leg keeps the shop amount and currency on the payment line, as the order import does for payments.
        // [GIVEN] A store posting manually and a return refunded 125 in the presentment currency, booked by the shop as 1000 SEK
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1050', '9150', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1050', '9150', '#9150', Sku, '1050', 1, 100, 25, 25, '71001', _Lib.RefundTxnJsonWithShopMoney('1050', 'shopify_payments', 125, _Lib.Lcy(), 1000, 'SEK'), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The payment line carries the presentment amount and the shop amount and currency
        QueueRow.Find();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::"Return Order");
        PaymentLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        _Assert.IsTrue(PaymentLine.FindFirst(), 'A payment line must exist.');
        _Assert.AreEqual(125, PaymentLine.Amount, 'The payment line carries the presentment amount.');
        _Assert.AreEqual(1000, PaymentLine."Amount (Store Currency)", 'The payment line carries the shop amount.');
        _Assert.AreEqual('SEK', PaymentLine."Store Currency Code", 'The payment line carries the shop currency.');
    end;

    [Test]
    procedure Posting_WithheldFee_OnAnAccountWithoutVat_PostsTheFeeWithoutVat()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        Customer: Record Customer;
        GLAccount: Record "G/L Account";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] The fee account decides the VAT on a withheld fee: on an account whose VAT posting setup carries 0 percent, a 15 fee posts as 15 with no VAT, while the same fee on the 25 percent account posts net plus VAT.
        // [GIVEN] A legacy-path store with automatic posting whose fee account has a 0 percent VAT posting setup for the customer's VAT business group
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        Customer.Get(CustomerNo);
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, Customer."VAT Bus. Posting Group", VATProductPostingGroup.Code);
        VATPostingSetup.Validate("VAT Calculation Type", VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.Validate("VAT %", 0);
        VATPostingSetup.Validate("Sales VAT Account", _Lib.CreateDirectPostingGLAccount());
        VATPostingSetup.Modify(true);
        GLAccount.Get(_Lib.CreateSalesGLAccountNo(Sku));
        GLAccount."VAT Prod. Posting Group" := VATProductPostingGroup.Code;
        GLAccount.Modify();
        ShopifyStore.Validate("Return Fee G/L Account No.", GLAccount."No.");
        ShopifyStore.Modify();

        // [GIVEN] A queued return of gross 100 with a 15 return shipping fee withheld, refunded 85 by card
        _Lib.InsertQueueRow(StoreCode, '1051', '9151', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1051', '9151', '#9151', Sku, '1051', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1051', 'shopify_payments', 85, _Lib.Lcy(), ''), _Lib.Lcy(), _Lib.SingleRestockedDispositionJson('71001', 1), _Lib.ReturnShippingFeeJson(15), ''));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The fee line carries 15 without VAT
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        SalesCrMemoLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        SalesCrMemoLine.SetRange(Type, SalesCrMemoLine.Type::"G/L Account");
        SalesCrMemoLine.SetRange("No.", GLAccount."No.");
        _Assert.IsTrue(SalesCrMemoLine.FindFirst(), 'A fee line must exist.');
        _Assert.AreEqual(-15, SalesCrMemoLine."Amount Including VAT", 'The fee line carries the withheld 15.');
        _Assert.AreEqual(-15, SalesCrMemoLine.Amount, 'On a 0 percent account the fee carries no VAT.');
    end;

    [Test]
    procedure Import_LinesRestockedToDifferentLocations_UseTheStoreLocationAndFlagTheFallback()
    var
        NpEcStore: Record "NPR NpEc Store";
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When the returned lines were restocked to different locations, the header takes the NpEc store's location and the row is flagged as having used the fallback.
        // [GIVEN] A store posting manually whose NpEc store location is SPFYLRL3, with two further Shopify locations mapped to SPFYLRL2 and SPFYLRLOC
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateLocationLink(StoreCode, 'SPFYLRL2', '71052');
        _Lib.CreateLocationLink(StoreCode, 'SPFYLRL3', '71053');
        SpfyOrderMgt.FindNpEcStore(StoreCode, 'web', NpEcStore);
        NpEcStore.Validate(LocationCode, 'SPFYLRL3');
        NpEcStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1052', '9152', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseParcelLocations('1052', '9152', '#9152', Sku, '1052', '71001', '71052', 160, 40, 25, _Lib.RefundTxnJson('1052', 'shopify_payments', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the NpEc store location before asserting, since the import committed.
        NpEcStore.Find();
        NpEcStore.Validate(LocationCode, LocationCode);
        NpEcStore.Modify();
        Commit();

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The header carries the store's fallback location and the row is flagged
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        _Assert.AreEqual('SPFYLRL3', SalesHeader."Location Code", 'Disagreeing restock locations fall back to the NpEc store location.');
        _Assert.IsTrue(QueueRow."Location Fallback Used", 'The row must say the fallback was used.');
    end;

    [Test]
    procedure Mgt_ProcessingRowYoungerThanTwiceTheJobInterval_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        IntervalMinutes: Integer;
    begin
        // [SCENARIO] The manual guard reads the registered process job's interval: a Processing row younger than twice that interval is still another session's, so it is refused.
        // [GIVEN] The legacy jobs registered, and a row at Processing attempted one minute less than twice the process job's interval ago
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        SpfyLegacyReturnPollJQ.SetupJobQueues();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        JobQueueEntry.FindFirst();
        IntervalMinutes := JobQueueEntry."No. of Minutes between Runs";
        _Assert.IsTrue(IntervalMinutes > 1, 'Precondition: the process job has an interval.');
        _Lib.InsertQueueRow(StoreCode, '1053', '9153', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime() - ((2 * IntervalMinutes - 1) * 60 * 1000);
        QueueRow.Modify();

        // [WHEN] The manual guard runs
        asserterror SpfyLegacyReturnMgt.ErrorIfBeingProcessed(QueueRow);

        // [THEN] The row is refused as another session's
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9153-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_ProcessingRowOlderThanTwiceTheJobInterval_IsNotRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        IntervalMinutes: Integer;
    begin
        // [SCENARIO] A Processing row older than twice the registered process job's interval counts as a dead session's, so the manual guard lets it through.
        // [GIVEN] The legacy jobs registered, and a row at Processing attempted one minute more than twice the process job's interval ago
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        SpfyLegacyReturnPollJQ.SetupJobQueues();
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        JobQueueEntry.FindFirst();
        IntervalMinutes := JobQueueEntry."No. of Minutes between Runs";
        _Lib.InsertQueueRow(StoreCode, '1054', '9154', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime() - ((2 * IntervalMinutes + 1) * 60 * 1000);
        QueueRow.Modify();

        // [WHEN] The manual guard runs
        SpfyLegacyReturnMgt.ErrorIfBeingProcessed(QueueRow);

        // [THEN] No error was raised, so the row can be processed by hand
        _Assert.AreEqual(QueueRow.Status::Processing, QueueRow.Status, 'The guard leaves the row as it found it.');
    end;

    [Test]
    procedure Store_EnablingReturnsWithoutAStartDate_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] Switching Sales Return Order Integration on without "Get Returns Starting From" is refused, so the poll always has a window to start from.
        // [GIVEN] A store with the Ecommerce feature off and no starting date
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        LibrarySpfyImport.CreateStore('SPFYLRS1');
        ShopifyStore.Get('SPFYLRS1');
        ShopifyStore."Get Returns Starting From" := 0DT;
        ShopifyStore.Modify();

        // [WHEN] The toggle is switched on
        asserterror ShopifyStore.Validate("Sales Return Order Integration", true);

        // [THEN] The error names the starting date field
        _Assert.ExpectedError(ShopifyStore.FieldCaption("Get Returns Starting From"));
    end;

    [Test]
    procedure Store_BlockedRefundAccount_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        GLAccount: Record "G/L Account";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] A blocked G/L account cannot be set as a return account on the store, since the settlement would fail at posting.
        // [GIVEN] A store and a blocked direct-posting account
        LibrarySpfyImport.CreateStore('SPFYLRS2');
        ShopifyStore.Get('SPFYLRS2');
        GLAccount.Get(_Lib.CreateDirectPostingGLAccount());
        GLAccount.Blocked := true;
        GLAccount.Modify();

        // [WHEN] The account is set as the refund account
        asserterror ShopifyStore.Validate("Return Refund G/L Account No.", GLAccount."No.");

        // [THEN] The error names the blocked field
        _Assert.ExpectedError(GLAccount.FieldCaption(Blocked));
    end;

    [Test]
    procedure Store_BlockedGenericItem_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        Item: Record Item;
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        // [SCENARIO] A blocked item cannot be set as the generic return item on the store, since every return line routed to it would fail.
        // [GIVEN] A store and a blocked item
        LibrarySpfyImport.CreateStore('SPFYLRS2');
        ShopifyStore.Get('SPFYLRS2');
        LibraryInventory.CreateItem(Item);
        Item.Validate(Blocked, true);
        Item.Modify(true);

        // [WHEN] The item is set as the generic return item
        asserterror ShopifyStore.Validate("Return Generic Item No.", Item."No.");

        // [THEN] The error names the blocked field
        _Assert.ExpectedError(Item.FieldCaption(Blocked));
    end;

    [Test]
    procedure Import_GiftCardRefundsWithAndWithoutId_AreRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded to one gift card that Shopify names and one it does not counts as a refund to two cards, so it is refused for manual handling.
        // [GIVEN] A store posting manually, a voucher behind gift card 91550, and a return refunded 60 to that card and 40 to a card without an id
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVZ1', StoreCode, '91550', Voucher);
        _Lib.InsertQueueRow(StoreCode, '1055', '9155', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1055', '9155', '#9155', Sku, '1055', 1, 80, 20, 25, '71001',
            _Lib.RefundTxnJson('1055', 'gift_card', 60, _Lib.Lcy(), '91550') + ',' + _Lib.RefundTxnJson('1056', 'gift_card', 40, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The import is refused naming the return and the gift cards, and no draft is left
        _Assert.IsFalse(Succeeded, 'Gift cards that cannot be told apart must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9155-R1') > 0, 'The refusal must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'gift cards') > 0, 'The refusal must name the gift cards: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual('', QueueRow."Sales Header Doc. No.", 'No draft may be left.');
    end;

    [Test]
    procedure Mgt_DismissReturn_ErrorRow_IsDismissedAndTheJobLeavesIt()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Dismissing a failed return marks its row Dismissed, and the process job never attempts a dismissed row again.
        // [GIVEN] No unfinished rows left behind by earlier tests, and a committed row at Error after one failed attempt
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteUnfinishedQueueRows();
        _Lib.InsertQueueRow(StoreCode, '1060', '9160', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Retry Count" := 1;
        QueueRow."Last Error" := 'Handled by hand';
        QueueRow.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;
        Commit();

        // [GIVEN] The return is dismissed
        SpfyLegacyReturnMgt.DismissReturn(QueueRow);
        Commit();

        // [WHEN] The process job runs afterwards
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row is Dismissed and no further attempt was made
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'The row must be Dismissed and stay so through a job run.');
        _Assert.AreEqual(1, QueueRow."Retry Count", 'The job must not attempt a dismissed return.');
        _Assert.AreEqual('Handled by hand', QueueRow."Last Error", 'The dismissal keeps the last error for the record.');

        // Cleanup: remove the committed row.
        QueueRow.Delete();
        Commit();
    end;

    [Test]
    procedure PollJQ_DismissedReturn_IsNotQueuedAgain()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A dismissed return that Shopify still lists in the poll window stays Dismissed: the poll adds no row for it and does not reopen it.
        // [GIVEN] A legacy-path store whose only queued row is return 1061 at Dismissed
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();
        _Lib.InsertQueueRow(StoreCode, '1061', '9161', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();

        // [GIVEN] Shopify lists the same closed return again
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9161', '#9161', 'gid://shopify/Return/1061', '#9161-R1'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The store still has its one row, still Dismissed
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        _Assert.AreEqual(1, QueueRow.Count(), 'A dismissed return must not be queued a second time.');
        QueueRow.FindFirst();
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'The poll must not reopen a dismissed return.');

        // Cleanup: remove the committed rows.
        QueueRow.DeleteAll();
        Commit();
    end;

    [Test]
    procedure Mgt_DismissReturn_WithAnOpenDraft_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A return whose Return Order draft still exists cannot be dismissed; the draft has to be discarded or posted first, so no document is left behind unowned.
        // [GIVEN] A committed row at Draft Created linked to an existing Return Order
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1062', '9162', QueueRow);
        _Lib.InsertReturnOrderWithReturnIds('RO-LR1062', StoreCode, '1062', SalesHeader);
        QueueRow."Sales Header Doc. No." := SalesHeader."No.";
        QueueRow.Status := QueueRow.Status::"Draft Created";
        QueueRow.Modify();
        Commit();

        // [WHEN] The return is dismissed
        asserterror SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // [THEN] The refusal names the Return Order and the row is unchanged
        _Assert.IsTrue(StrPos(GetLastErrorText(), SalesHeader."No.") > 0, 'The refusal must name the Return Order: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::"Draft Created", QueueRow.Status, 'A refused dismissal must leave the status alone.');

        // Cleanup: remove the committed row and draft.
        QueueRow.Delete();
        SalesHeader.Delete();
        Commit();
    end;

    [Test]
    procedure Mgt_DismissReturn_ReceivedNotInvoiced_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A return received on a Return Order that still awaits its invoice cannot be dismissed, even when the row no longer links the order, because the credit memo is settled through the row.
        // [GIVEN] A row with no draft link whose return receipt carries the return's ids and names a Return Order that still exists but carries no ids, so only the receipt can refuse
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1063', '9163', QueueRow);
        if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", 'RO-LR1063') then
            SalesHeader.Delete(true);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader."No." := 'RO-LR1063';
        SalesHeader.Insert();
        _Lib.InsertPostedReceiptWithReturnIds('RR-LR1063', StoreCode, '1063', SalesHeader."No.");
        QueueRow."Posted Doc. No." := 'RR-LR1063';
        QueueRow.Status := QueueRow.Status::"Draft Created";
        QueueRow.Modify();

        // [WHEN] The return is dismissed
        asserterror SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // [THEN] The refusal names the Return Order that still awaits the invoice
        _Assert.IsTrue(StrPos(GetLastErrorText(), SalesHeader."No.") > 0, 'The refusal must name the Return Order awaiting the invoice: ' + GetLastErrorText());
        if ReturnReceiptHeader.Get('RR-LR1063') then
            ReturnReceiptHeader.Delete();
    end;

    [Test]
    procedure Mgt_DismissReturn_ProcessingRowOfAnotherSession_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A row another session is processing right now cannot be dismissed from under it.
        // [GIVEN] A row at Processing attempted just now
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1064', '9164', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();

        // [WHEN] The return is dismissed
        asserterror SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // [THEN] The refusal says another session has the row
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'another session') > 0, 'The refusal must say another session is processing the row: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_DismissReturn_ImportedReturn_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A return whose credit memo is posted has nothing to dismiss: the row is marked Imported instead and the dismissal is refused.
        // [GIVEN] A committed row at Error whose return has a posted credit memo carrying its ids
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1065', '9165', QueueRow);
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR1065', StoreCode, '1065');
        QueueRow."Posted Doc. No." := 'SCM-LR1065';
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();

        // [WHEN] The return is dismissed
        asserterror SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // [THEN] The refusal names the credit memo and the row is Imported, committed before the refusal
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SCM-LR1065') > 0, 'The refusal must name the posted credit memo: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A return with a posted credit memo is Imported, not Dismissed.');

        // Cleanup: remove the committed row and credit memo.
        QueueRow.Delete();
        if SalesCrMemoHeader.Get('SCM-LR1065') then
            SalesCrMemoHeader.Delete();
        Commit();
    end;

    [Test]
    procedure StoreDeleted_WithDismissedReturns_RemovesThem()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        LeftoverRow: Record "NPR Spfy NC Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A dismissed return counts as finished: a store whose queue holds only dismissed and imported returns can be deleted and takes those rows with it.
        // [GIVEN] A legacy-path store whose queue holds one Dismissed and one Imported return
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        LeftoverRow.SetRange("Shopify Store Code", StoreCode);
        LeftoverRow.DeleteAll(false);
        _Lib.InsertQueueRow(StoreCode, '1066', '9166', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();
        _Lib.InsertQueueRow(StoreCode, '1067', '9167', QueueRow);
        QueueRow.Status := QueueRow.Status::Imported;
        QueueRow.Modify();

        // [WHEN] The store is deleted
        ShopifyStore.Get(StoreCode);
        ShopifyStore.Delete(true);

        // [THEN] The store's queue rows are gone
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        _Assert.IsTrue(QueueRow.IsEmpty(), 'A store with only dismissed and imported returns must delete and leave no rows.');
    end;

    [Test]
    [HandlerFunctions('DeclineConfirm')]
    procedure FeatureFlagOn_WithDismissedLegacyReturns_AsksAndStopsWhenDeclined()
    var
        Feature: Record "NPR Feature";
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A dismissed legacy return does not refuse the Ecommerce feature switch but asks the user to confirm, since the e-commerce import may import a return handled by hand again, and stops when the user declines.
        // [GIVEN] No unprocessed or failed legacy return rows left over from other tests, since the pre-flight check scans the whole table
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off and one committed row at Dismissed
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Lib.InsertQueueRow(StoreCode, '1068', '9168', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();
        Commit();

        // [WHEN] The pre-flight check for enabling runs and the user declines the question
        Clear(_CapturedMessage);
        Feature.Enabled := true;
        asserterror ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] The question named the queue and the dismissed returns, and the row is still Dismissed
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The question must name the legacy return queue: ' + _CapturedMessage);
        _Assert.IsTrue(StrPos(_CapturedMessage, 'dismissed') > 0, 'The question must say dismissed returns are at stake: ' + _CapturedMessage);
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'The feature check must leave a dismissed row alone.');

        // Cleanup: remove the committed row.
        QueueRow.Delete();
        Commit();
    end;

    [Test]
    procedure Import_ReturnNoLongerClosed_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        ResponseText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A queued return that Shopify has reopened since the poll is refused when its detail is fetched, naming its status, and no document is built for it.
        // [GIVEN] A queued return whose detail now says OPEN
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1069', '9169', QueueRow);
        ResponseText := _Lib.ReturnDetailResponse('1069', '9169', '#9169', Sku, '1069', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1069', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"status":"CLOSED"') > 0, 'Precondition: the fixture carries a closed return.');
        MockClient.AddResponse('GetReturn', ResponseText.Replace('"status":"CLOSED"', '"status":"OPEN"'));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A return that is no longer closed must be refused
        _Assert.IsFalse(Succeeded, 'A return that is no longer closed must be refused.');

        // [THEN] The error names the status and no Return Order exists for the customer
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'OPEN') > 0, 'The error must name the status: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9169-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No Return Order may be built for a return that is not closed.');
    end;

    [Test]
    procedure Mgt_DeletingADismissedRow_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A dismissed row cannot be deleted, since deleting it would let the poll queue the return again; Discard Draft and Retry is the only way back.
        // [GIVEN] A committed row at Dismissed
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1070', '9170', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();
        Commit();

        // [WHEN] The row is deleted
        asserterror QueueRow.Delete(true);

        // [THEN] The refusal names the return and the row survives, still Dismissed
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9170-R1') > 0, 'The refusal must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1070'), 'A dismissed row must survive a deletion attempt.');
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'The row must stay Dismissed.');

        // Cleanup: reopen and remove the committed row.
        QueueRow.Status := QueueRow.Status::New;
        QueueRow.Modify();
        QueueRow.Delete();
        Commit();
    end;

    [Test]
    procedure Mgt_ErrorIfDismissed_DismissedRow_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The guard the Process action runs refuses a dismissed row and points at Discard Draft and Retry, so a dismissed return is never imported by accident.
        // [GIVEN] A row at Dismissed
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1071', '9171', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();

        // [WHEN] The dismissed guard runs
        asserterror SpfyLegacyReturnMgt.ErrorIfDismissed(QueueRow);

        // [THEN] The refusal names the return and the way back
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9171-R1') > 0, 'The refusal must name the return: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'Discard Draft and Retry') > 0, 'The refusal must point at the way back: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_DismissReturn_UnrecordedCreditMemoWithTheIds_IsRefusedAndRecorded()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A dismissal looks for the return's posted credit memo by its Shopify ids, not only by the number the row recorded, so a credit memo the row never recorded still refuses the dismissal and marks the row Imported.
        // [GIVEN] A committed row at Error recording no posted document, while a credit memo carrying the return's ids exists
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1072', '9172', QueueRow);
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR1072', StoreCode, '1072');
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();

        // [WHEN] The return is dismissed
        asserterror SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // [THEN] The refusal names the credit memo and the row is Imported with the credit memo recorded
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SCM-LR1072') > 0, 'The refusal must name the credit memo found by the ids: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A return with a posted credit memo is Imported, not Dismissed.');
        _Assert.AreEqual('SCM-LR1072', QueueRow."Posted Doc. No.", 'The credit memo found by the ids is recorded on the row.');

        // Cleanup: remove the committed row and credit memo.
        QueueRow.Delete();
        if SalesCrMemoHeader.Get('SCM-LR1072') then
            SalesCrMemoHeader.Delete();
        Commit();
    end;

    [Test]
    procedure Mgt_DismissReturn_UnlinkedDraftWithTheIds_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A Return Order carrying the return's ids refuses the dismissal even when the row does not link it, so an unlinked draft is never left behind unowned.
        // [GIVEN] A row with no draft link and a Return Order carrying the return's ids
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1073', '9173', QueueRow);
        _Lib.InsertReturnOrderWithReturnIds('RO-LR1073', StoreCode, '1073', SalesHeader);

        // [WHEN] The return is dismissed
        asserterror SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // [THEN] The refusal names the unlinked Return Order
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RO-LR1073') > 0, 'The refusal must name the Return Order found by the ids: ' + GetLastErrorText());
    end;

    [Test]
    procedure Mgt_DiscardDraft_DismissedRowWithoutDraft_IsAllowed()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Discard Draft and Retry is the way back from a dismissal: its guard accepts a dismissed row that has no draft, so the page can reset it to New.
        // [GIVEN] A row at Dismissed with no draft and no posted document
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1074', '9174', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();

        // [WHEN] The discard guard runs for the row
        SpfyLegacyReturnMgt.DiscardDraft(QueueRow);

        // [THEN] The row survives for the page to reset
        _Assert.IsTrue(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1074'), 'The discard of a dismissed row without a draft must leave the row for the reset to New.');
    end;

    [Test]
    procedure Import_SingleRestockLocationDifferentFromTheStoreDefault_IsTakenWithoutFallback()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When the returned line was restocked to one linked location that is not the NpEc store's default, the header takes that location and the row is not flagged as having used the fallback.
        // [GIVEN] A store posting manually, whose NpEc store default is the fixture location, with a second Shopify location mapped to SPFYLRL2, and a return restocked there
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateLocationLink(StoreCode, 'SPFYLRL2', '71052');
        _Lib.InsertQueueRow(StoreCode, '1075', '9175', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1075', '9175', '#9175', Sku, '1075', 1, 100, 25, 25, '71052', _Lib.RefundTxnJson('1075', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The header carries the restock location, not the store default, and the row is not flagged
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        _Assert.AreEqual('SPFYLRL2', SalesHeader."Location Code", 'The linked restock location wins over the NpEc store default.');
        _Assert.AreNotEqual(LocationCode, SalesHeader."Location Code", 'Precondition: the restock location differs from the store default.');
        _Assert.IsFalse(QueueRow."Location Fallback Used", 'A resolved restock location is not a fallback.');
    end;

    [Test]
    procedure Import_UnlinkedRestockLocationAndNoStoreLocation_IsRefused()
    var
        NpEcStore: Record "NPR NpEc Store";
        Location: Record Location;
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        ImportSucceeded: Boolean;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A return restocked to a Shopify location the store does not link, on an NpEc store with no location of its own, is refused with an error naming the location and the return instead of building a document without a location.
        // [GIVEN] An NpEc store with its location blanked and a return restocked to an unlinked Shopify location
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        SpfyOrderMgt.FindNpEcStore(StoreCode, 'web', NpEcStore);
        NpEcStore.Validate(LocationCode, '');
        NpEcStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1076', '9176', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1076', '9176', '#9176', Sku, '1076', 1, 100, 25, 25, '71999', _Lib.RefundTxnJson('1076', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs
        ImportSucceeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the NpEc store location before asserting, since the import committed.
        NpEcStore.Find();
        NpEcStore.Validate(LocationCode, LocationCode);
        NpEcStore.Modify();
        Commit();

        // [THEN] The import is refused naming the location and the return, and no Return Order exists
        _Assert.IsFalse(ImportSucceeded, 'A return with no resolvable location must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), Location.TableCaption()) > 0, 'The error must name the location: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), '#9176-R1') > 0, 'The error must name the return: ' + GetLastErrorText());
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No Return Order may be built without a location.');
    end;

    [Test]
    procedure QueuePage_Dismiss_MarksAnErrorRowDismissed()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        // [SCENARIO] The queue page's Dismiss action marks a failed return's row Dismissed.
        // [GIVEN] A row at Error
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1077', '9177', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();

        // [WHEN] Dismiss is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        QueuePage.DismissReturn.Invoke();
        QueuePage.Close();

        // [THEN] The row is Dismissed
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'The Dismiss action must mark the row Dismissed.');
    end;

    [Test]
    procedure QueuePage_DiscardDraftAndRetry_ReopensADismissedRow()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        // [SCENARIO] Discard Draft and Retry on a dismissed row queues the return again: the row is New with no retries counted.
        // [GIVEN] A row at Dismissed after two failed attempts
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1078', '9178', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow."Retry Count" := 2;
        QueueRow."Last Error" := 'Handled by hand';
        QueueRow.Modify();

        // [WHEN] Discard Draft and Retry is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        QueuePage.DiscardDraftAndRetry.Invoke();
        QueuePage.Close();

        // [THEN] The row is New again with the attempt count and the error cleared
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'The reopened row must be New.');
        _Assert.AreEqual(0, QueueRow."Retry Count", 'The reopened row starts its attempts afresh.');
        _Assert.AreEqual('', QueueRow."Last Error", 'The reopened row carries no old error.');
    end;

    [Test]
    procedure QueuePage_Process_RefusesADismissedRow()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
    begin
        // [SCENARIO] The queue page's Process action refuses a dismissed row and names the way back, so a dismissed return is never imported by a click.
        // [GIVEN] A row at Dismissed
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1079', '9179', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();

        // [WHEN] Process is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        asserterror QueuePage.ProcessRow.Invoke();
        ErrorText := GetLastErrorText();
        QueuePage.Close();

        // [THEN] The action refused, naming Discard Draft and Retry
        _Assert.IsTrue(StrPos(ErrorText, 'Discard Draft and Retry') > 0, 'Process must refuse a dismissed row and name the way back: ' + ErrorText);
    end;

    [Test]
    procedure Import_UnlinkedRestockLocationWithAStoreLocation_UsesTheStoreLocationAndFlagsIt()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] When no restock location of the return is linked to the store, the header and its line take the NpEc store's location and the row is flagged as having used the fallback.
        // [GIVEN] A store posting manually whose NpEc store has the fixture location, and a return restocked to a Shopify location the store does not link
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1080', '9180', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1080', '9180', '#9180', Sku, '1080', 1, 100, 25, 25, '71999', _Lib.RefundTxnJson('1080', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The header and the line carry the store location and the row says the fallback was used
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        _Assert.AreEqual(LocationCode, SalesHeader."Location Code", 'An unlinked restock location falls back to the NpEc store location.');
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        _Assert.AreEqual(LocationCode, SalesLine."Location Code", 'The item line takes the header location.');
        _Assert.IsTrue(QueueRow."Location Fallback Used", 'The row must say the fallback was used.');
    end;

    [Test]
    procedure Import_DisagreeingRestockLocationsWithoutAStoreLocation_TakeTheFirstAndFlagIt()
    var
        NpEcStore: Record "NPR NpEc Store";
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        ImportSucceeded: Boolean;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] When the restock locations disagree and the NpEc store has no location of its own, the header takes the first resolved location and the row is flagged as having used the fallback.
        // [GIVEN] A store posting manually whose NpEc store location is blanked, a second Shopify location mapped to SPFYLRL2, and a return restocked to both locations
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.CreateLocationLink(StoreCode, 'SPFYLRL2', '71052');
        SpfyOrderMgt.FindNpEcStore(StoreCode, 'web', NpEcStore);
        NpEcStore.Validate(LocationCode, '');
        NpEcStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1081', '9181', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseParcelLocations('1081', '9181', '#9181', Sku, '1081', '71001', '71052', 160, 40, 25, _Lib.RefundTxnJson('1081', 'shopify_payments', 200, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        ImportSucceeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the NpEc store location before asserting, since the import committed.
        NpEcStore.Find();
        NpEcStore.Validate(LocationCode, LocationCode);
        NpEcStore.Modify();
        Commit();

        // [THEN] The header carries the first resolved location and the row says the fallback was used
        _Assert.IsTrue(ImportSucceeded, 'The draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        _Assert.AreEqual(LocationCode, SalesHeader."Location Code", 'Without a store location, disagreeing restock locations fall back to the first one resolved.');
        _Assert.IsTrue(QueueRow."Location Fallback Used", 'The row must say the fallback was used.');
    end;

    [Test]
    procedure Mgt_DiscardDraft_UnrecordedCreditMemoWithTheIds_IsRefusedAndRecorded()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The discard guard finds a posted credit memo by the return's ids even when the row never recorded it, marks the row Imported, commits that and refuses the discard as already posted.
        // [GIVEN] A committed row at Error recording no posted document, while a credit memo carrying the return's ids exists
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1082', '9182', QueueRow);
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR1082', StoreCode, '1082');
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();

        // [WHEN] The discard guard runs for the row
        asserterror SpfyLegacyReturnMgt.DiscardDraft(QueueRow);

        // [THEN] The refusal names the credit memo and the row is Imported with the credit memo recorded
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SCM-LR1082') > 0, 'The refusal must name the credit memo found by the ids: ' + GetLastErrorText());
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A return with a posted credit memo is Imported, so there is nothing to discard.');
        _Assert.AreEqual('SCM-LR1082', QueueRow."Posted Doc. No.", 'The credit memo found by the ids is recorded on the row.');

        // Cleanup: remove the committed row and credit memo.
        QueueRow.Delete();
        if SalesCrMemoHeader.Get('SCM-LR1082') then
            SalesCrMemoHeader.Delete();
        Commit();
    end;

    [Test]
    procedure Store_RefundAccountWithoutDirectPosting_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        GLAccount: Record "G/L Account";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] A G/L account without direct posting cannot be set as a return account on the store, since the settlement journal would be refused at posting.
        // [GIVEN] A store and an open account with direct posting switched off
        LibrarySpfyImport.CreateStore('SPFYLRS2');
        ShopifyStore.Get('SPFYLRS2');
        GLAccount.Get(_Lib.CreateDirectPostingGLAccount());
        GLAccount."Direct Posting" := false;
        GLAccount.Modify();

        // [WHEN] The account is set as the refund account
        asserterror ShopifyStore.Validate("Return Refund G/L Account No.", GLAccount."No.");

        // [THEN] The error names the direct posting field
        _Assert.ExpectedError(GLAccount.FieldCaption("Direct Posting"));
    end;

    [Test]
    procedure Store_BlockedGiftCardRefundAccount_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        GLAccount: Record "G/L Account";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] The gift card refund account is checked like the refund account: a blocked account is refused.
        // [GIVEN] A store and a blocked direct-posting account
        LibrarySpfyImport.CreateStore('SPFYLRS2');
        ShopifyStore.Get('SPFYLRS2');
        GLAccount.Get(_Lib.CreateDirectPostingGLAccount());
        GLAccount.Blocked := true;
        GLAccount.Modify();

        // [WHEN] The account is set as the gift card refund account
        asserterror ShopifyStore.Validate("Ret. Gift Card Refund G/L Acc.", GLAccount."No.");

        // [THEN] The error names the blocked field
        _Assert.ExpectedError(GLAccount.FieldCaption(Blocked));
    end;

    [Test]
    procedure Store_BlockedShippingRefundAccount_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        GLAccount: Record "G/L Account";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] The shipping refund account is checked like the refund account: a blocked account is refused.
        // [GIVEN] A store and a blocked direct-posting account
        LibrarySpfyImport.CreateStore('SPFYLRS2');
        ShopifyStore.Get('SPFYLRS2');
        GLAccount.Get(_Lib.CreateDirectPostingGLAccount());
        GLAccount.Blocked := true;
        GLAccount.Modify();

        // [WHEN] The account is set as the shipping refund account
        asserterror ShopifyStore.Validate("Ret. Shipping Refund G/L Acc.", GLAccount."No.");

        // [THEN] The error names the blocked field
        _Assert.ExpectedError(GLAccount.FieldCaption(Blocked));
    end;

    [Test]
    procedure Store_BlockedFeeAccount_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        GLAccount: Record "G/L Account";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
    begin
        // [SCENARIO] The return fee account is checked like the refund account: a blocked account is refused.
        // [GIVEN] A store and a blocked direct-posting account
        LibrarySpfyImport.CreateStore('SPFYLRS2');
        ShopifyStore.Get('SPFYLRS2');
        GLAccount.Get(_Lib.CreateDirectPostingGLAccount());
        GLAccount.Blocked := true;
        GLAccount.Modify();

        // [WHEN] The account is set as the fee account
        asserterror ShopifyStore.Validate("Return Fee G/L Account No.", GLAccount."No.");

        // [THEN] The error names the blocked field
        _Assert.ExpectedError(GLAccount.FieldCaption(Blocked));
    end;

    [Test]
    procedure ProcessJQ_ProcessRow_RowClaimedByAnotherSessionMeanwhile_IsLeftAlone()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OtherSessionRow: Record "NPR Spfy NC Return Queue";
        Claimed: Boolean;
    begin
        // [SCENARIO] The process row re-reads the row under a lock before claiming it, so a row another session claimed after the caller's guard is left to that session and not imported a second time.
        // [GIVEN] A row read as New by this session, which another session has since set to Processing in the database
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1083', '9183', QueueRow);
        OtherSessionRow.FindSourceDoc(StoreCode, OtherSessionRow."Source Doc. Type"::Return, '1083');
        OtherSessionRow.Status := OtherSessionRow.Status::Processing;
        OtherSessionRow."Processed At" := CurrentDateTime();
        OtherSessionRow.Modify();
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'Precondition: this session still holds the row as New.');

        // [WHEN] The process row runs with the stale copy
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] No attempt was made: the row is still the other session's, unchanged, and nothing was built
        _Assert.IsFalse(Claimed, 'The stale copy must not claim the row.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Processing, QueueRow.Status, 'The row stays with the session that claimed it.');
        _Assert.AreEqual(0, QueueRow."Retry Count", 'No attempt may be recorded for a row another session holds.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No Return Order may be built for a row another session holds.');
    end;

    [Test]
    procedure ProcessJQ_ProcessRow_RowDeletedMeanwhile_IsSkipped()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherSessionRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A row deleted by a user between the job's snapshot and its claim is skipped without an error, so one deleted row does not abort the whole pass.
        // [GIVEN] A row read by this session that another session has since deleted
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1085', '9185', QueueRow);
        OtherSessionRow.FindSourceDoc(StoreCode, OtherSessionRow."Source Doc. Type"::Return, '1085');
        OtherSessionRow.Delete();

        // [WHEN] The process row runs with the stale copy
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] Nothing was built and the row stays gone
        _Assert.IsFalse(Claimed, 'The stale copy must not claim the row.');
        _Assert.IsFalse(OtherSessionRow.FindSourceDoc(StoreCode, OtherSessionRow."Source Doc. Type"::Return, '1085'), 'A deleted row must not be recreated by the claim.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No Return Order may be built for a deleted row.');
    end;

    [Test]
    procedure Mgt_DismissReturn_ReceivedReturnInvoicedElsewhere_IsDismissed()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A return received on its Return Order and invoiced through a separate credit memo, so that the order is gone, can be dismissed: the receipt alone no longer holds the row.
        // [GIVEN] A committed row at Error whose return receipt carries the return's ids and names a Return Order that no longer exists
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1084', '9184', QueueRow);
        _Lib.InsertPostedReceiptWithReturnIds('RR-LR1084', StoreCode, '1084', 'RO-LR1084');
        QueueRow."Posted Doc. No." := 'RR-LR1084';
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();

        // [WHEN] The return is dismissed
        SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // [THEN] The row is Dismissed
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'A received return whose order was invoiced elsewhere can be dismissed.');

        // Cleanup: remove the committed receipt and the row.
        if ReturnReceiptHeader.Get('RR-LR1084') then
            ReturnReceiptHeader.Delete();
        QueueRow.Status := QueueRow.Status::New;
        QueueRow.Modify();
        QueueRow.Delete();
        Commit();
    end;

    [Test]
    procedure ProcessJQ_ProcessRow_RowDismissedMeanwhile_IsLeftAlone()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherSessionRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A row dismissed by a user between the job's snapshot and its claim stays Dismissed and is not imported, so the job really leaves dismissed returns alone.
        // [GIVEN] A row read as New by this session that another session has since dismissed
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1086', '9186', QueueRow);
        OtherSessionRow.FindSourceDoc(StoreCode, OtherSessionRow."Source Doc. Type"::Return, '1086');
        OtherSessionRow.Status := OtherSessionRow.Status::Dismissed;
        OtherSessionRow.Modify();

        // [WHEN] The process row runs with the stale copy
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is still Dismissed and nothing was built
        _Assert.IsFalse(Claimed, 'The stale copy must not claim the row.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'A row dismissed since the snapshot must stay Dismissed.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No Return Order may be built for a dismissed row.');
    end;

    [Test]
    procedure Mgt_DiscardDraft_DismissedReturnInvoicedElsewhere_IsRefusedAsDismissed()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ReturnReceiptHeader: Record "Return Receipt Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A dismissed return that was received and invoiced outside the import cannot be queued again through Discard Draft and Retry, and the refusal says it is dismissed instead of asking to dismiss it.
        // [GIVEN] A row at Dismissed whose return receipt carries the return's ids and names a Return Order that no longer exists
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1087', '9187', QueueRow);
        _Lib.InsertPostedReceiptWithReturnIds('RR-LR1087', StoreCode, '1087', 'RO-LR1087');
        QueueRow."Posted Doc. No." := 'RR-LR1087';
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();

        // [WHEN] The discard guard runs for the row
        asserterror SpfyLegacyReturnMgt.DiscardDraft(QueueRow);

        // [THEN] The refusal says the return is dismissed and names the receipt, and does not ask to dismiss it
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'is dismissed') > 0, 'The refusal must say the return is dismissed: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'RR-LR1087') > 0, 'The refusal must name the receipt: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'dismiss the queue row') = 0, 'The refusal must not ask to dismiss a dismissed row: ' + GetLastErrorText());
        if ReturnReceiptHeader.Get('RR-LR1087') then
            ReturnReceiptHeader.Delete();
    end;

    [Test]
    [HandlerFunctions('AcceptConfirm')]
    procedure FeatureFlagOn_WithDismissedLegacyReturns_ContinuesWhenAccepted()
    var
        Feature: Record "NPR Feature";
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A dismissed legacy return only asks: when the user accepts the question, enabling the Ecommerce feature goes ahead and the row stays Dismissed.
        // [GIVEN] No unprocessed, failed or dismissed legacy return rows left over from other tests
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off and one row at Dismissed
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Lib.InsertQueueRow(StoreCode, '1088', '9188', QueueRow);
        QueueRow.Status := QueueRow.Status::Dismissed;
        QueueRow.Modify();

        // [WHEN] The pre-flight check for enabling runs and the user accepts the question
        Clear(_CapturedMessage);
        Feature.Enabled := true;
        ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] The question was asked and the check passed with the row still Dismissed
        _Assert.IsTrue(StrPos(_CapturedMessage, 'dismissed') > 0, 'The question about dismissed returns must have been asked: ' + _CapturedMessage);
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Dismissed, QueueRow.Status, 'The feature check must leave a dismissed row alone.');
    end;

    [Test]
    procedure ProcessJQ_ProcessRow_RowImportedMeanwhile_IsLeftAlone()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherSessionRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A row that reached Imported between the job's snapshot and its claim is left alone, so a return posted by hand in that instant is not built again.
        // [GIVEN] A row read as New by this session that another session has since set to Imported
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1089', '9189', QueueRow);
        OtherSessionRow.FindSourceDoc(StoreCode, OtherSessionRow."Source Doc. Type"::Return, '1089');
        OtherSessionRow.Status := OtherSessionRow.Status::Imported;
        OtherSessionRow.Modify();

        // [WHEN] The process row runs with the stale copy
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is still Imported and nothing was built
        _Assert.IsFalse(Claimed, 'The stale copy must not claim the row.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A row imported since the snapshot must stay Imported.');
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'No Return Order may be built for an imported row.');
    end;

    [Test]
    procedure QueuePage_Process_RefusesARowAnotherSessionIsProcessing()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The queue page's Process action refuses a row another session is processing right now, so the page is wired to the same guard the job honours.
        // [GIVEN] A row at Processing attempted just now, with the Ecommerce feature off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1090', '9190', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();

        // [WHEN] Process is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        asserterror QueuePage.ProcessRow.Invoke();
        ErrorText := GetLastErrorText();
        QueuePage.Close();

        // [THEN] The action refused, naming the other session
        _Assert.IsTrue(StrPos(ErrorText, 'another session') > 0, 'Process must refuse a row another session holds: ' + ErrorText);
    end;

    [Test]
    procedure QueuePage_Process_RefusesARowOfAStoreWithReturnsSwitchedOff()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The queue page's Process action refuses a row of a store whose return import is switched off, naming the toggle, so the page is wired to the same guard the job honours.
        // [GIVEN] A queued return of a store whose Sales Return Order Integration is switched off, with the Ecommerce feature off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1091', '9191', QueueRow);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Sales Return Order Integration" := false;
        ShopifyStore.Modify();

        // [WHEN] Process is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        asserterror QueuePage.ProcessRow.Invoke();
        ErrorText := GetLastErrorText();
        QueuePage.Close();

        // [THEN] The action refused, naming the toggle
        _Assert.IsTrue(StrPos(ErrorText, ShopifyStore.FieldCaption("Sales Return Order Integration")) > 0, 'Process must refuse a row of a store with returns switched off: ' + ErrorText);
    end;

    [Test]
    procedure PollJQ_InsertNewRows_StoreDeletedMeanwhile_InsertsNothing()
    var
        TempQueueRow: Record "NPR Spfy NC Return Queue" temporary;
        QueueRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
    begin
        // [SCENARIO] Rows listed for a store that was deleted while its returns were being fetched are not inserted, so no orphan row is left for the import to report as a bug.
        // [GIVEN] A listed return of a store that no longer exists
        TempQueueRow.Init();
        TempQueueRow."Shopify Store Code" := 'SPFYLRGONE3';
        TempQueueRow."Source Doc. ID" := '1092';
        TempQueueRow."Source Doc. Name" := '#9192-R1';
        TempQueueRow.Insert();
        _Assert.IsFalse(QueueRow.FindSourceDoc('SPFYLRGONE3', QueueRow."Source Doc. Type"::Return, '1092'), 'Precondition: no row exists for the deleted store.');

        // [WHEN] The poll inserts its new rows
        SpfyLegacyReturnPollJQ.InsertNewRows(TempQueueRow);

        // [THEN] No row was inserted for the deleted store
        _Assert.IsFalse(QueueRow.FindSourceDoc('SPFYLRGONE3', QueueRow."Source Doc. Type"::Return, '1092'), 'A return of a deleted store must not be queued.');
    end;

    [Test]
    procedure Import_GiftCardReturn_ReservedCard_IsRefusedWithoutADocument()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        Voucher: Record "NPR NpRv Voucher";
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
        // [SCENARIO] Returning two gift cards when one of them is reserved as a payment on an open sale is refused with an error naming the posted sale, since posting could not archive the reserved card.
        // [GIVEN] A legacy-path store and a posted sale of two 50 gift cards on Shopify line 2766, one of which is reserved for 20 by an open sale
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        GLAccountNo := _Lib.CreateSalesGLAccountNo(Sku);
        _Lib.InsertPostedGiftCardSale('SI-LRGC12', StoreCode, '92566', '2766', GLAccountNo, 2, 50, VoucherNos);
        _Lib.ReserveVoucherAmount(VoucherNos.Get(1), 20);
        Voucher.Get(VoucherNos.Get(1));
        Voucher.CalcFields("Reserved Amount", "In-use Quantity");
        _Assert.AreEqual(20, Voucher."Reserved Amount", 'Precondition: the reservation is visible as the voucher''s reserved amount.');
        _Assert.AreEqual(1, Voucher."In-use Quantity", 'Precondition: the reservation counts as the voucher being in use.');

        // [GIVEN] A queued return of both cards refunded 100 by card
        _Lib.InsertQueueRow(StoreCode, '2566', '92566', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseGiftCard('2566', '92566', '#92566', '2766', 2, 100, '71001', _Lib.RefundTxnJson('2666', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] A reserved gift card must refuse the return
        _Assert.IsFalse(Succeeded, 'A reserved gift card must refuse the return.');

        // [THEN] The error names the posted invoice, no Return Order exists and both vouchers are still open
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'SI-LRGC12') > 0, 'The error must name the posted invoice: ' + GetLastErrorText());
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::"Return Order");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        _Assert.IsTrue(SalesHeader.IsEmpty(), 'A refused import must leave no Return Order.');
        foreach VoucherNo in VoucherNos do
            _Assert.IsTrue(Voucher.Get(VoucherNo), 'Voucher ' + VoucherNo + ' must be untouched by a refused import.');
    end;

    [Test]
    procedure PollJQ_SetupJobQueues_RegistersBothJobsToRescheduleAfterAnError()
    var
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Both legacy return jobs are registered to reschedule themselves after an error, so one failing store does not stop the polling of every store for good.
        // [GIVEN] A legacy-path store with the feature off and neither job registered
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetFilter("Object ID to Run", '%1|%2', Codeunit::"NPR Spfy Legacy Return Poll JQ", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        JobQueueEntry.DeleteAll();

        // [WHEN] Job queues are set up
        SpfyLegacyReturnPollJQ.SetupJobQueues();

        // [THEN] Both entries reschedule after an error
        JobQueueEntry.FindSet();
        repeat
            _Assert.IsTrue(JobQueueEntry."NPR Auto-Resched. after Error", 'The legacy return job ' + Format(JobQueueEntry."Object ID to Run") + ' must reschedule itself after an error.');
            _Assert.AreEqual(JobQueueEntry."No. of Minutes between Runs" * 60, JobQueueEntry."NPR Auto-Resched. Delay (sec.)", 'The reschedule delay equals the job interval, so a store that keeps failing costs one run per interval once BC stops retrying.');
        until JobQueueEntry.Next() = 0;
        _Assert.AreEqual(2, JobQueueEntry.Count(), 'Both legacy return jobs must be registered.');
    end;

    [Test]
    procedure PollJQ_StoreWithReturnsSwitchedOff_IsNotPolled()
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
        // [SCENARIO] A store whose Sales Return Order Integration is off is not polled, so none of the closed returns Shopify would list for it are queued.
        // [GIVEN] A legacy-path store with the toggle switched off and no rows, and a mock that would list a closed return for it
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Sales Return Order Integration" := false;
        ShopifyStore.Modify();
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9193', '#9193', 'gid://shopify/Return/1093', '#9193-R1'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The store has no rows
        _Assert.IsTrue(QueueRow.IsEmpty(), 'A store with returns switched off must not be polled.');
    end;

    [Test]
    procedure PollJQ_DisabledStore_IsNotPolled()
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
        // [SCENARIO] A disabled store is not polled, whatever its return toggle says.
        // [GIVEN] A legacy-path store that is disabled and has no rows, and a mock that would list a closed return for it
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        QueueRow.SetRange("Shopify Store Code", StoreCode);
        QueueRow.DeleteAll();
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore.Enabled := false;
        ShopifyStore.Modify();
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9194', '#9194', 'gid://shopify/Return/1094', '#9194-R1'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The store has no rows
        _Assert.IsTrue(QueueRow.IsEmpty(), 'A disabled store must not be polled.');
    end;

    [Test]
    procedure FeatureFlagOn_WithImportedLegacyReturns_PassesWithoutAQuestion()
    var
        Feature: Record "NPR Feature";
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] An imported legacy return neither refuses the Ecommerce feature switch nor asks about it: with only imported rows the check passes silently.
        // [GIVEN] No unprocessed, failed or dismissed legacy return rows left over from other tests
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off and one row at Imported
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Lib.InsertQueueRow(StoreCode, '1095', '9195', QueueRow);
        QueueRow.Status := QueueRow.Status::Imported;
        QueueRow.Modify();

        // [WHEN] The pre-flight check for enabling runs, with no confirm handler, so any question would fail the test
        Feature.Enabled := true;
        ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] The check passed and the row is still Imported
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The feature check must leave an imported row alone.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_OrderLineSkuWinsOverARenamedVariantSku()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A returned line takes the SKU the order line was sold under, not the variant's current SKU, so a SKU renamed in Shopify since the sale still resolves the item the order import used.
        // [GIVEN] A detail response whose variant now carries another SKU than the order line
        ResponseText := _Lib.ReturnDetailResponse('1096', '9196', '#9196', 'SPFYSOLDSKU', '1096', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1096', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"variant":{"id":"gid://shopify/ProductVariant/1","sku":"SPFYSOLDSKU"') > 0, 'Precondition: the fixture carries the sold SKU on the variant.');
        ResponseText := ResponseText.Replace('"variant":{"id":"gid://shopify/ProductVariant/1","sku":"SPFYSOLDSKU"', '"variant":{"id":"gid://shopify/ProductVariant/1","sku":"SPFYRENAMED"');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '1096', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The line carries the order line's SKU
        TempLineBuffer.FindFirst();
        _Assert.AreEqual('SPFYSOLDSKU', TempLineBuffer.SKU, 'The order line SKU must win over the variant SKU.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_OnlySuccessfulRefundTransactionsCount()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        TransactionsJson: Text;
    begin
        // [SCENARIO] Only transactions of kind REFUND with status SUCCESS become refund transactions: a pending refund and a sale transaction on the same refund are left out, and the pending refund is counted.
        // [GIVEN] A detail response whose refund carries a successful refund of 100, a pending refund of 50 and a successful sale of 30
        TransactionsJson := _Lib.RefundTxnJson('3001', 'shopify_payments', 100, _Lib.Lcy(), '') + ',' +
            _Lib.RefundTxnJson('3002', 'shopify_payments', 50, _Lib.Lcy(), '').Replace('"status":"SUCCESS"', '"status":"PENDING"') + ',' +
            _Lib.RefundTxnJson('3003', 'shopify_payments', 30, _Lib.Lcy(), '').Replace('"kind":"REFUND"', '"kind":"SALE"');
        Response.ReadFrom(_Lib.ReturnDetailResponse('1097', '9197', '#9197', 'SPFYSNOW', '1097', 1, 100, 25, 25, '71001', TransactionsJson, _Lib.Lcy()));

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '1097', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] One refund transaction of 100 is recorded
        _Assert.AreEqual(1, TempRefundTxnBuffer.Count(), 'Only the successful refund counts.');
        TempRefundTxnBuffer.FindFirst();
        _Assert.AreEqual(100, TempRefundTxnBuffer.Amount, 'The recorded transaction is the successful refund.');
        _Assert.AreEqual('3001', TempRefundTxnBuffer."Transaction Id", 'The recorded transaction is the successful refund by id.');

        // [THEN] The pending refund is counted, so the import waits for it
        TempReturnBuffer.FindFirst();
        _Assert.AreEqual(1, TempReturnBuffer."Pending Refund Txns", 'The pending refund transaction must be counted.');
    end;

    [Test]
    procedure Import_TwoReturnedOrderLines_BuildTwoLinesCoveringTheRefund()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return of two order lines builds one Return Order line per order line, each carrying its own Shopify line item id and refunded gross, and the lines together cover the refund.
        // [GIVEN] A store posting manually and a return of two order lines of the same SKU: 2 units refunded 250 gross and 1 unit refunded 125 gross, 375 refunded by card
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1098', '9198', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponseTwoLines('1098', '9198', '#9198', Sku, '1098', 2, 200, 50, '2098', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1098', 'shopify_payments', 375, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] Two item lines exist, one per order line, with their gross amounts and line item ids, and their total is the refund
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        _Assert.AreEqual(2, SalesLine.Count(), 'One Return Order line per returned order line.');
        SalesLine.SetRange(Quantity, 2);
        _Assert.IsTrue(SalesLine.FindFirst(), 'The two-unit line must exist.');
        _Assert.AreEqual(250, SalesLine."Line Amount", 'The two-unit line carries its refunded gross.');
        _Assert.AreEqual('1098', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'The two-unit line carries its order line item id.');
        SalesLine.SetRange(Quantity, 1);
        _Assert.IsTrue(SalesLine.FindFirst(), 'The one-unit line must exist.');
        _Assert.AreEqual(125, SalesLine."Line Amount", 'The one-unit line carries its refunded gross.');
        _Assert.AreEqual('2098', SpfyAssignedIDMgt.GetAssignedShopifyID(SalesLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'The one-unit line carries its order line item id.');
        SalesLine.SetRange(Quantity);
        SalesLine.CalcSums("Line Amount");
        _Assert.AreEqual(375, SalesLine."Line Amount", 'The lines together cover the refund.');
    end;

    [Test]
    procedure QueuePage_Process_MarksTheRowImportedWhenItsCreditMemoExists()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Process on a row whose recorded credit memo carries the return's ids marks the row Imported without importing again.
        // [GIVEN] A row at Error recording a posted credit memo that carries the return's ids, with the Ecommerce feature off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1099', '9199', QueueRow);
        _Lib.InsertPostedCrMemoWithReturnIds('SCM-LR1099', StoreCode, '1099');
        QueueRow."Posted Doc. No." := 'SCM-LR1099';
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();

        // [WHEN] Process is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        QueuePage.ProcessRow.Invoke();
        QueuePage.Close();

        // [THEN] The row is Imported
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A row whose credit memo exists is marked Imported by Process.');
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure FeatureFlagOn_WithPendingAndFailedLegacyReturns_RefusesWithoutAsking()
    var
        Feature: Record "NPR Feature";
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        QueueRow: Record "NPR Spfy NC Return Queue";
        FailedRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Enabling the feature while the queue holds both an unprocessed row and a failed row refuses outright, without first asking about the failed row.
        // [GIVEN] No legacy return queue rows are left over from other tests that commit rows, since the pre-flight check scans the whole table regardless of store
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off, one row at New and one at Error
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        _Lib.InsertQueueRow(StoreCode, '1105', '9205', QueueRow);
        _Lib.InsertQueueRow(StoreCode, '1106', '9206', FailedRow);
        FailedRow.Status := FailedRow.Status::Error;
        FailedRow.Modify();

        Clear(_CapturedMessage);
        // [WHEN] The pre-flight check for enabling runs
        Feature.Enabled := true;
        asserterror ShopifyEcommOrderExp.CheckForUnprocessedEntries(Feature);

        // [THEN] The refusal names the queue and no question was asked, since only the message handler is declared
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The refusal must name the legacy return queue: ' + _CapturedMessage);
        _Assert.IsTrue(StrPos(_CapturedMessage, 'not possible') > 0, 'The message must be the refusal, not the question: ' + _CapturedMessage);
    end;

    [Test]
    procedure Posting_InvoiceRounding_PostsTheRoundedTotalAndKeepsTheRefundOnThePaymentLine()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        OriginalInvoiceRounding: Boolean;
        OriginalAllowAdjust: Boolean;
        MappingExisted: Boolean;
        OriginalPrecision: Decimal;
        OriginalRoundingType: Option Nearest,Up,Down;
        Imported: Boolean;
    begin
        // [SCENARIO] On a company with invoice rounding, a return whose gross misses the rounding unit still posts: the refund payment line carries the mapping's adjust flag so the posting accepts it, the line keeps the amount Shopify refunded, and the settlement books the rounded ledger amount.
        // [GIVEN] A legacy-path store with automatic posting and a payment mapping for its gateway that allows adjusting the payment amount
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();

        // [GIVEN] Invoice rounding to whole units, with a rounding account on the customer's posting group
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        OriginalPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
        OriginalRoundingType := GeneralLedgerSetup."Inv. Rounding Type (LCY)";
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := 1;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Nearest;
        GeneralLedgerSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();

        // [GIVEN] A queued return of one unit refunded 124.50 by card, a gross that misses the whole unit
        _Lib.InsertQueueRow(StoreCode, '1110', '9210', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1110', '9210', '#9210', Sku, '1110', 1, 99.6, 24.9, 25, '71001', _Lib.RefundTxnJson('1110', 'shopify_payments', 124.5, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Imported := _Lib.RunImport(QueueRow, MockClient);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the company setup before asserting, since the posting committed it.
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := OriginalPrecision;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := OriginalRoundingType;
        GeneralLedgerSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        Commit();

        // [THEN] The return posted, the credit memo is rounded to 125 and fully settled
        _Assert.IsTrue(Imported, 'The return must post although its total is rounded: ' + ErrorText);
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");
        _Assert.AreEqual(-125, CustLedgerEntry.Amount, 'The credit memo is rounded to the whole unit.');
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');

        // [THEN] The payment line keeps the refunded amount with the adjust flag, and the settlement booked the rounded ledger amount on the clearing account
        PaymentLine.SetRange("Document Table No.", Database::"Sales Cr.Memo Header");
        PaymentLine.SetRange("Document No.", SalesCrMemoHeader."No.");
        _Assert.IsTrue(PaymentLine.FindFirst(), 'The posted credit memo carries the payment line.');
        _Assert.IsTrue(PaymentLine."Allow Adjust Amount", 'The payment line carries the mapping''s adjust flag.');
        _Assert.AreEqual(124.5, PaymentLine.Amount, 'The payment line keeps the amount Shopify refunded.');
        GLEntry.SetRange("G/L Account No.", ShopifyStore."Return Refund G/L Account No.");
        GLEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        GLEntry.CalcSums(Amount);
        _Assert.AreEqual(-125, GLEntry.Amount, 'The settlement books the rounded ledger amount, as the order path captures a rounded payment.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_RefundsFewerUnitsThanReturned_IsRefused()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A return line that returns three units of which Shopify refunded only two is refused naming the return, the SKU and both quantities, instead of receiving three units for two units of refund.
        // [GIVEN] A detail response returning 3 units whose refund line covers 2 of them
        ResponseText := _Lib.ReturnDetailResponse('1122', '9222', '#9222', 'SPFYSNOW', '1122', 3, 200, 50, 25, '71001', _Lib.RefundTxnJson('1122', 'shopify_payments', 250, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"quantity":3,"subtotalSet"') > 0, 'Precondition: the fixture refunds the returned quantity.');
        ResponseText := ResponseText.Replace('"quantity":3,"subtotalSet"', '"quantity":2,"subtotalSet"');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '1122', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the return, the SKU and both quantities
        _Assert.ExpectedError('#9222-R1');
        _Assert.ExpectedError('SPFYSNOW');
        _Assert.ExpectedError('refunds only 2');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_ReturnedLineWithoutARefundLine_IsRefused()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
        SecondRefundLine: Text;
    begin
        // [SCENARIO] A return of two order lines where Shopify refunded only the first is refused instead of building a zero-priced line that is still received.
        // [GIVEN] A two-line detail response with the second order line's refund line removed
        ResponseText := _Lib.ReturnDetailResponseTwoLines('1124', '9224', '#9224', 'SPFYSNOW', '1124', 1, 100, 25, '2124', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1124', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        SecondRefundLine := ',{"node":{"quantity":1,"subtotalSet":{"presentmentMoney":{"amount":"100"}},"totalTaxSet":{"presentmentMoney":{"amount":"25"}},"lineItem":{"id":"gid://shopify/LineItem/2124","taxLines":[{"ratePercentage":25}]}}}';
        _Assert.IsTrue(StrPos(ResponseText, SecondRefundLine) > 0, 'Precondition: the fixture refunds the second line.');
        ResponseText := ResponseText.Replace(SecondRefundLine, '');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '1124', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the return and says no unit of the line was refunded
        _Assert.ExpectedError('#9224-R1');
        _Assert.ExpectedError('refunds only 0');
    end;

    [Test]
    procedure QueuePage_Process_UnderAStatusFilter_StillWritesTheOutcome()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Process on a row shown under a Status filter writes the attempt's outcome back to the row, although the claim moved the row out of the filter while it ran.
        // [GIVEN] A legacy-path store with the feature off and a committed row at Error after one attempt
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1125', '9225', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Retry Count" := 1;
        QueueRow."Last Error" := 'Earlier attempt';
        QueueRow.Modify();
        Commit();

        // [WHEN] Process is invoked on the row while the page is filtered to Error rows, and the attempt fails because the store has no Shopify connection
        QueuePage.OpenView();
        QueuePage.Filter.SetFilter(Status, Format(QueueRow.Status::Error));
        QueuePage.GoToRecord(QueueRow);
        QueuePage.ProcessRow.Invoke();
        QueuePage.Close();

        // [THEN] The row is back at Error with the attempt counted and its error recorded, not stuck at Processing
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'The outcome must be written although the row left the page filter while Processing.');
        _Assert.AreEqual(2, QueueRow."Retry Count", 'The attempt must be counted.');
        _Assert.AreNotEqual('Earlier attempt', QueueRow."Last Error", 'The new error must be recorded.');
        QueueRow.Delete();
    end;

    [Test]
    procedure PollJQ_OrderListPagingBeyondTheCap_IsReportedAsASizingError()
    var
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A store whose order list keeps paging with advancing cursors is stopped at the page cap with a translated error that names the store and the settings to shorten, not as a programming bug.
        // [GIVEN] A legacy-path store with a long lookback so the list filter is stable
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Poll Lookback (Days)" := 3650;
        ShopifyStore.Modify();

        // [GIVEN] Every page of the order list says there is another page, each with a new cursor
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponseNeverEnding('gid://shopify/Order/9226', 'gid://shopify/Return/1126'));
        MockClient.AdvanceCursorPerRequest();
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        asserterror SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The run stopped at the cap with a sizing error naming the store, the page limit and the lookback setting, and no programming-bug marker
        _Assert.ExpectedError(StoreCode);
        _Assert.ExpectedError('1000');
        _Assert.ExpectedError(ShopifyStore.FieldCaption("Return Poll Lookback (Days)"));
        _Assert.IsFalse(GetLastErrorText().Contains('This is a programming bug'), 'The cap is sizing, not a defect: ' + GetLastErrorText());
        _Assert.AreEqual(1000, MockClient.RequestCount(), 'The poll stops when the thousandth page still says there is more.');
    end;

    [Test]
    procedure Import_RefundProcessedAndCreatedOnDifferentDays_DatesThePaymentLineByTheProcessedDay()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        PaymentLine: Record "NPR Magento Payment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        TransactionJson: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund transaction processed two days after it was created dates the payment line by the processed day.
        // [GIVEN] A store posting manually and a return whose refund was created on 20 September and processed on 22 September
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1127', '9227', QueueRow);
        TransactionJson := _Lib.RefundTxnJson('1127', 'shopify_payments', 125, _Lib.Lcy(), '');
        _Assert.IsTrue(StrPos(TransactionJson, '"processedAt":"2026-09-20T10:00:00Z"') > 0, 'Precondition: the fixture processes on 20 September.');
        TransactionJson := TransactionJson.Replace('"processedAt":"2026-09-20T10:00:00Z"', '"processedAt":"2026-09-22T10:00:00Z"');
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1127', '9227', '#9227', Sku, '1127', 1, 100, 25, 25, '71001', TransactionJson, _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The payment line is dated by the processed day
        QueueRow.Find();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::"Return Order");
        PaymentLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        _Assert.IsTrue(PaymentLine.FindFirst(), 'A payment line must exist.');
        _Assert.AreEqual(20260922D, PaymentLine."Date Refunded", 'The processed day wins over the creation day.');
    end;

    [Test]
    procedure Import_RefundWithoutAProcessedDate_DatesThePaymentLineByTheCreationDay()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        PaymentLine: Record "NPR Magento Payment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        TransactionJson: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund transaction without a processed date dates the payment line by its creation day.
        // [GIVEN] A store posting manually and a return closed on 20 September whose refund carries no processedAt and was created on 18 September
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1128', '9228', QueueRow);
        TransactionJson := _Lib.RefundTxnJson('1128', 'shopify_payments', 125, _Lib.Lcy(), '').Replace('"processedAt":"2026-09-20T10:00:00Z"', '"processedAt":null').Replace('"createdAt":"2026-09-20T10:00:00Z"', '"createdAt":"2026-09-18T10:00:00Z"');
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1128', '9228', '#9228', Sku, '1128', 1, 100, 25, 25, '71001', TransactionJson, _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The payment line is dated by the creation day
        QueueRow.Find();
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::"Return Order");
        PaymentLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        _Assert.IsTrue(PaymentLine.FindFirst(), 'A payment line must exist.');
        _Assert.AreEqual(20260918D, PaymentLine."Date Refunded", 'Without a processed date the creation day is used, not the posting date.');
    end;

    [Test]
    procedure Import_RefundWithoutAnyDate_DatesThePaymentLineByThePostingDate()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        TransactionJson: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund transaction with neither a processed nor a creation date dates the payment line by the Return Order's posting date, so posting never meets a blank date.
        // [GIVEN] A store posting manually and a return whose refund carries neither date
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1129', '9229', QueueRow);
        TransactionJson := _Lib.RefundTxnJson('1129', 'shopify_payments', 125, _Lib.Lcy(), '').Replace('"processedAt":"2026-09-20T10:00:00Z"', '"processedAt":null').Replace('"createdAt":"2026-09-20T10:00:00Z"', '"createdAt":null');
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1129', '9229', '#9229', Sku, '1129', 1, 100, 25, 25, '71001', TransactionJson, _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The draft must build
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The payment line is dated by the Return Order's posting date
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::"Return Order");
        PaymentLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        _Assert.IsTrue(PaymentLine.FindFirst(), 'A payment line must exist.');
        _Assert.AreEqual(SalesHeader."Posting Date", PaymentLine."Date Refunded", 'Without any Shopify date the posting date is used.');
    end;

    [Test]
    procedure Mgt_FindQueueRowBySalesHeader_IgnoresAHeaderStampedForAnotherStore()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Found: Boolean;
    begin
        // [SCENARIO] A Return Order that carries the row's return id but another store's code is not matched to the row, so a return id reused by another store never settles this row.
        // [GIVEN] A row linked to Return Order RO-LR1123 for return 1123, and a Return Order of that number stamped with return 1123 and store SPFYOTHER
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1123', '9223', QueueRow);
        QueueRow."Sales Header Doc. No." := 'RO-LR1123';
        QueueRow.Modify();
        if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", 'RO-LR1123') then
            SalesHeader.Delete(true);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader."No." := 'RO-LR1123';
        SalesHeader.Insert();
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", '1123', false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", 'SPFYOTHER', false);

        // [WHEN] The subscriber's row lookup runs for that header
        Found := SpfyLegacyReturnMgt.FindQueueRowBySalesHeader(SalesHeader, QueueRow);

        // [THEN] No row is matched
        _Assert.IsFalse(Found, 'A header stamped for another store is not this return''s document.');
    end;

    [Test]
    procedure Posting_DraftWorthMoreThanTheRefund_IsRefusedBeforeSettlement()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A draft a user made worth more than Shopify refunded is refused at posting, naming the return and both amounts, so the settlement never pays out more than the refund even though the payment line allows adjusting.
        // [GIVEN] A legacy-path store posting manually, a payment mapping for its gateway that allows adjusting, and a draft built for a return refunded 125
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        Commit();
        _Lib.InsertQueueRow(StoreCode, '1130', '9230', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1130', '9230', '#9230', Sku, '1130', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1130', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());

        // [GIVEN] A user adds a 50 line to the draft
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 90000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", 50);
        SalesLine.Validate("Return Qty. to Receive", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The user posts the draft from the Return Order
        Succeeded := SalesPost.Run(SalesHeader);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping before asserting, so a failed assertion cannot leave the flag on.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        Commit();

        // [THEN] The posting is refused naming the return and the refund, and the draft survives
        _Assert.IsFalse(Succeeded, 'The posting must be refused: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, '#9230-R1') > 0, 'The refusal must name the return: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'more than was refunded') > 0, 'The refusal must name the overpayment: ' + ErrorText);
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No."), 'The draft must survive the refused posting.');
    end;

    [Test]
    procedure Posting_DraftWorthLessThanTheRefund_IsRefusedBeforeSettlement()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A draft a user made worth less than Shopify refunded is refused at posting, naming the return, so the settlement never books less than the refund and never gives a gift card back less than Shopify put on it.
        // [GIVEN] A legacy-path store posting manually and a draft built for a return refunded 125
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        Commit();
        _Lib.InsertQueueRow(StoreCode, '1139', '9239', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1139', '9239', '#9239', Sku, '1139', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1139', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());

        // [GIVEN] A user lowers the returned item's price on the draft to 75
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.FindFirst();
        SalesLine.Validate("Unit Price", 75);
        SalesLine.Modify(true);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The user posts the draft from the Return Order
        Succeeded := SalesPost.Run(SalesHeader);
        ErrorText := GetLastErrorText();

        // [THEN] The posting is refused naming the return and the shortfall, and the draft survives
        _Assert.IsFalse(Succeeded, 'The posting must be refused: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, '#9239-R1') > 0, 'The refusal must name the return: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'is below the') > 0, 'The refusal must name the shortfall: ' + ErrorText);
        _Assert.IsTrue(SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No."), 'The draft must survive the refused posting.');
    end;

    [Test]
    procedure Posting_GiftCardRefund_ToAnArchivedCard_RestoresTheCardAndCreditsItBack()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        VoucherFilter: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        VoucherNo: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund to a gift card whose voucher was spent to zero and archived restores the voucher with its Shopify id and gives it back the refund, instead of importing with no voucher.
        // [GIVEN] A legacy-path store with automatic posting and Shopify gift card 9006 mapped to a voucher that is spent and archived
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVARCH', StoreCode, '9006', Voucher);
        VoucherNo := Voucher."No.";
        Voucher."Allow Top-up" := false;
        Voucher.Modify();
        VoucherFilter.SetRange("No.", VoucherNo);
        NpRvVoucherMgt.ArchiveVouchers(VoucherFilter);
        _Assert.IsFalse(Voucher.Get(VoucherNo), 'Precondition: the voucher is archived.');
        ArchVoucher.SetRange("Arch. No.", VoucherNo);
        _Assert.IsTrue(ArchVoucher.FindFirst(), 'Precondition: the archive holds the voucher.');
        _Assert.AreEqual('9006', SpfyAssignedIDMgt.GetAssignedShopifyID(ArchVoucher.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'Precondition: the Shopify id moved to the archive.');

        // [GIVEN] A queued return of gross 125 refunded wholly to that gift card, which paid 125 on the order's invoice
        _Lib.InsertQueueRow(StoreCode, '1131', '9231', QueueRow);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR1131', StoreCode, '9231', 'SPFYLRVARCH', 125);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1131', '9231', '#9231', Sku, '1131', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1131', 'gift_card', 125, _Lib.Lcy(), '9006'), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The voucher is live again under its number with the Shopify id, holds the refund, and the row names it
        _Assert.IsTrue(Voucher.Get(VoucherNo), 'The voucher must be restored from the archive.');
        Voucher.CalcFields(Amount);
        _Assert.AreEqual(125, Voucher.Amount, 'The restored voucher holds the refund.');
        _Assert.AreEqual('9006', SpfyAssignedIDMgt.GetAssignedShopifyID(Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID"), 'The Shopify id must be back on the voucher.');
        _Assert.IsFalse(ArchVoucher.Find(), 'The archive row is gone.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The row is Imported.');
    end;

    [Test]
    procedure Field45_CannotBeBlankedWhileTheToggleIsOn()
    var
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Blanking "Get Returns Starting From" while "Sales Return Order Integration" is on is refused, so the poll always has a start date and never queues returns credited before go-live.
        // [GIVEN] A legacy-path store with the toggle on and a start date
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Assert.IsTrue(ShopifyStore."Sales Return Order Integration", 'Precondition: the toggle is on.');
        _Assert.AreNotEqual(0DT, ShopifyStore."Get Returns Starting From", 'Precondition: the store has a start date.');

        // [WHEN] The start date is blanked
        asserterror ShopifyStore.Validate("Get Returns Starting From", 0DT);

        // [THEN] The validation refuses naming both fields
        _Assert.ExpectedError(ShopifyStore.FieldCaption("Get Returns Starting From"));
        _Assert.ExpectedError(ShopifyStore.FieldCaption("Sales Return Order Integration"));
    end;

    [Test]
    procedure ReturnApi_ParseDetail_RefundWithoutAnyRefundLine_IsRefused()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
        RefundLine: Text;
    begin
        // [SCENARIO] A closed return whose refund carries money but no refund line (a shipping-only refund) is refused for its unrefunded line, instead of building a zero-priced line that is still received.
        // [GIVEN] A detail response whose refund has a transaction but an empty refund line list
        ResponseText := _Lib.ReturnDetailResponse('1132', '9232', '#9232', 'SPFYSNOW', '1132', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1132', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy());
        RefundLine := '{"node":{"quantity":1,"subtotalSet":{"presentmentMoney":{"amount":"100"}},"totalTaxSet":{"presentmentMoney":{"amount":"25"}},"lineItem":{"id":"gid://shopify/LineItem/1132","taxLines":[{"ratePercentage":25}]}}}';
        _Assert.IsTrue(StrPos(ResponseText, RefundLine) > 0, 'Precondition: the fixture carries the refund line.');
        ResponseText := ResponseText.Replace(RefundLine, '');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '1132', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the return and says no unit of the line was refunded
        _Assert.ExpectedError('#9232-R1');
        _Assert.ExpectedError('refunds only 0');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_GiftCardLineRefundedShort_IsNamedByItsTitle()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A gift card line, which carries no SKU, refunded for fewer units than returned is refused with its title in the message, so the message never shows an empty name.
        // [GIVEN] A gift card return of 2 units whose refund line covers 1
        ResponseText := _Lib.ReturnDetailResponseGiftCard('1133', '9233', '#9233', '1133', 2, 100, '71001', _Lib.RefundTxnJson('1133', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"quantity":2,"subtotalSet"') > 0, 'Precondition: the fixture refunds the returned quantity.');
        ResponseText := ResponseText.Replace('"quantity":2,"subtotalSet"', '"quantity":1,"subtotalSet"');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '1133', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the return and the line's title, not a blank
        _Assert.ExpectedError('#9233-R1');
        _Assert.ExpectedError('units of NP Gift Card');
        _Assert.ExpectedError('refunds only 1');
    end;

    [Test]
    procedure Import_ReturnNotClosedWithAShortRefund_IsRefusedAsNotClosed()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        ResponseText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return that is open again and whose line is refunded short is refused for not being closed, the message that tells the user what to wait for, not for the quantity.
        // [GIVEN] A store posting manually and a return with status OPEN returning 3 units of which 2 are refunded
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1134', '9234', QueueRow);
        ResponseText := _Lib.ReturnDetailResponse('1134', '9234', '#9234', Sku, '1134', 3, 200, 50, 25, '71001', _Lib.RefundTxnJson('1134', 'shopify_payments', 250, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"name":"#9234-R1","status":"CLOSED"') > 0, 'Precondition: the fixture closes the return.');
        ResponseText := ResponseText.Replace('"name":"#9234-R1","status":"CLOSED"', '"name":"#9234-R1","status":"OPEN"').Replace('"quantity":3,"subtotalSet"', '"quantity":2,"subtotalSet"');
        MockClient.AddResponse('GetReturn', ResponseText);

        // [WHEN] The import runs
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The import is refused because the return is not closed, not for the quantity
        _Assert.IsFalse(Succeeded, 'An open return must be refused.');
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'OPEN') > 0, 'The refusal must name the status: ' + GetLastErrorText());
        _Assert.IsTrue(StrPos(GetLastErrorText(), 'refunds only') = 0, 'The quantity message must not win over the status message: ' + GetLastErrorText());
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TwoParcelsRefundedAsOne_IsRefused()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] An order line returned in two parcels, each a return line of one unit, whose refund line covers one unit is refused: the returned quantities of one order line add up before they are compared.
        // [GIVEN] A two-parcel return whose refund line quantity is 1
        ResponseText := _Lib.ReturnDetailResponseParcels('1135', '9235', '#9235', 'SPFYSNOW', '1135', 2, 200, 50, 25, '71001', _Lib.RefundTxnJson('1135', 'shopify_payments', 250, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"quantity":2,"subtotalSet"') > 0, 'Precondition: the fixture refunds both parcels.');
        ResponseText := ResponseText.Replace('"quantity":2,"subtotalSet"', '"quantity":1,"subtotalSet"');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '1135', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error says 2 units were returned and 1 refunded
        _Assert.ExpectedError('returns 2 units');
        _Assert.ExpectedError('refunds only 1');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_TwoRefundsOfOneLine_AddUpToTheReturnedQuantity()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        EdgesToken: JsonToken;
        FirstRefund: JsonToken;
        SecondRefund: JsonToken;
        Edges: JsonArray;
    begin
        // [SCENARIO] A line of 2 units refunded in two separate refunds of 1 unit each passes the quantity check and carries the whole refund: refunded quantities of one order line add up across refunds.
        // [GIVEN] A detail response whose single refund of 2 units is split into two refunds of 1 unit and 125 each
        Response.ReadFrom(_Lib.ReturnDetailResponse('1137', '9237', '#9237', 'SPFYSNOW', '1137', 2, 200, 50, 25, '71001', _Lib.RefundTxnJson('1137', 'shopify_payments', 250, _Lib.Lcy(), ''), _Lib.Lcy()));
        Response.SelectToken('data.return.refunds.edges', EdgesToken);
        Edges := EdgesToken.AsArray();
        Edges.Get(0, FirstRefund);
        SecondRefund := FirstRefund.Clone();
        HalveRefundNode(FirstRefund, '11371');
        HalveRefundNode(SecondRefund, '11372');
        Edges.Add(SecondRefund);

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '1137', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The line carries both refunds and both transactions are recorded
        TempLineBuffer.FindFirst();
        _Assert.AreEqual(2, TempLineBuffer.Quantity, 'The line keeps its returned quantity.');
        _Assert.AreEqual(250, TempLineBuffer."Line Amount", 'The line carries the sum of both refunds.');
        _Assert.AreEqual(2, TempRefundTxnBuffer.Count(), 'Both refund transactions are recorded.');
    end;

    local procedure HalveRefundNode(var RefundEdge: JsonToken; TransactionId: Text)
    var
        LineNode: JsonToken;
        MoneyToken: JsonToken;
        TxnNode: JsonToken;
    begin
        RefundEdge.SelectToken('node.refundLineItems.edges[0].node', LineNode);
        LineNode.AsObject().Replace('quantity', 1);
        LineNode.SelectToken('subtotalSet.presentmentMoney', MoneyToken);
        MoneyToken.AsObject().Replace('amount', '100');
        LineNode.SelectToken('totalTaxSet.presentmentMoney', MoneyToken);
        MoneyToken.AsObject().Replace('amount', '25');
        RefundEdge.SelectToken('node.transactions.edges[0].node', TxnNode);
        TxnNode.AsObject().Replace('id', 'gid://shopify/OrderTransaction/' + TransactionId);
        TxnNode.SelectToken('amountSet.presentmentMoney', MoneyToken);
        MoneyToken.AsObject().Replace('amount', '125');
        TxnNode.SelectToken('amountSet.shopMoney', MoneyToken);
        MoneyToken.AsObject().Replace('amount', '125');
    end;

    [Test]
    procedure PollJQ_StoreWithABlankStartDate_IsReportedAndNotPolled()
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
        // [SCENARIO] A store whose "Get Returns Starting From" is blank although its return toggle is on, a state older stores can carry, is reported by the poll and not polled, so no return credited before go-live is queued.
        // [GIVEN] A legacy-path store with the toggle on and a start date blanked without validation, and a mock that would answer any list call
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Get Returns Starting From" := 0DT;
        ShopifyStore.Modify();
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9238', '#9238', 'gid://shopify/Return/1138', '#9238-R1'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        asserterror SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The run reports the store and the blank field, made no Shopify call and queued nothing
        _Assert.ExpectedError(StoreCode);
        _Assert.ExpectedError(ShopifyStore.FieldCaption("Get Returns Starting From"));
        _Assert.AreEqual(0, MockClient.RequestCount(), 'A store without a start date must not be polled.');
        _Assert.IsFalse(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1138'), 'No return may be queued for a store without a start date.');
    end;

    [Test]
    procedure PollJQ_NestedReturnPagingBeyondTheCap_IsReportedAsASizingError()
    var
        ShopifyStore: Record "NPR Spfy Store";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A store whose per-order return paging keeps advancing is stopped at the shared page cap with the sizing error, not as a programming bug.
        // [GIVEN] A legacy-path store with a long lookback, one listed order with more returns, and per-order pages that always say there is another page with a new cursor
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Poll Lookback (Days)" := 3650;
        ShopifyStore.Modify();
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponseWithMoreReturns('gid://shopify/Order/9239', 'gid://shopify/Return/1139'));
        MockClient.AddResponse('$OrderId', _Lib.OrderReturnsResponseNeverEnding('gid://shopify/Return/1139'));
        MockClient.AdvanceCursorPerRequest();
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);

        // [WHEN] The poll runs
        asserterror SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] The run stopped at the cap with the sizing error and no programming-bug marker
        _Assert.ExpectedError(StoreCode);
        _Assert.ExpectedError('1000');
        _Assert.IsFalse(GetLastErrorText().Contains('This is a programming bug'), 'The cap is sizing, not a defect: ' + GetLastErrorText());
        _Assert.AreEqual(1000, MockClient.RequestCount(), 'The list page and the per-order pages share the cap.');
    end;

    [Test]
    procedure PollJQ_WithTheEcommerceFeatureOn_DoesNothing()
    var
        ShopifyStore: Record "NPR Spfy Store";
        Feature: Record "NPR Feature";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The legacy poll makes no Shopify call while the Shopify Ecommerce Order Experience feature is on, so a job entry recreated by a refresh race cannot queue returns the other engine owns.
        // [GIVEN] A legacy-path store and the feature switched on
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        MockClient.AddResponse('sortKey:UPDATED_AT', _Lib.ReturnListResponse('gid://shopify/Order/9240', '#9240', 'gid://shopify/Return/1140', '#9240-R1'));
        SpfyLegacyReturnPollJQ.SetGraphQLClient(MockClient);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Feature.Enabled := true;
        Feature.Modify();

        // [WHEN] The poll runs
        SpfyLegacyReturnPollJQ.PollAllStores();

        // [THEN] No Shopify call was made
        Feature.Enabled := false;
        Feature.Modify();
        _Assert.AreEqual(0, MockClient.RequestCount(), 'The legacy poll must stay idle while the feature is on.');
    end;

    [Test]
    procedure ProcessJQ_WithTheEcommerceFeatureOn_LeavesTheRows()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        Feature: Record "NPR Feature";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] The legacy process job attempts no row while the Shopify Ecommerce Order Experience feature is on.
        // [GIVEN] A committed New row and the feature switched on
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1141', '9241', QueueRow);
        Commit();
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Feature.Enabled := true;
        Feature.Modify();
        JobQueueEntry."No. of Minutes between Runs" := 5;

        // [WHEN] The process job runs
        SpfyLegacyReturnProcessJQ.ProcessQueue(JobQueueEntry);

        // [THEN] The row is untouched
        Feature.Enabled := false;
        Feature.Modify();
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'The job must not attempt rows while the feature is on.');
        _Assert.AreEqual(0DT, QueueRow."Processed At", 'The row must not be claimed.');
        QueueRow.Delete();
    end;

    [Test]
    procedure ProcessJQ_ProcessRowOnAFilteredRecord_WritesTheSuccessOutcome()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A row processed through a record filtered to its old status gets its successful outcome written: the draft already built is verified without Shopify and the row ends at Draft Created, not stuck at Processing.
        // [GIVEN] A store posting manually, a row whose draft was built, and the row set back to Error
        _Lib.DeleteUnfinishedQueueRows();
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1142', '9242', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1142', '9242', '#9242', Sku, '1142', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1142', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'Precondition: the draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();

        // [WHEN] The row is processed through a record filtered to Error rows
        QueueRow.SetRange(Status, QueueRow.Status::Error);
        QueueRow.FindFirst();
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is Draft Created, although the claim moved it out of the filter
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        QueueRow.Reset();
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1142');
        _Assert.AreEqual(QueueRow.Status::"Draft Created", QueueRow.Status, 'The successful outcome must be written through the filtered record.');
    end;

    [Test]
    procedure ProcessJQ_ProcessRowOnAFilteredRecord_PostingAutomatically_MarksTheRowImported()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A row processed through a record filtered to Error, on a store that posts automatically, ends Imported with no error: the posting moves the row out of the filter, and nothing after the posting may write Error over a posted credit memo.
        // [GIVEN] A row whose draft was built while the store posted manually, set back to Error
        _Lib.DeleteUnfinishedQueueRows();
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1176', '9276', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1176', '9276', '#9276', Sku, '1176', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1176', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'Precondition: the draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();

        // [GIVEN] The store now posts returns automatically
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Post Returns Automatically" := true;
        ShopifyStore.Modify();
        Commit();

        // [WHEN] The row is processed through a record filtered to Error rows
        QueueRow.SetRange(Status, QueueRow.Status::Error);
        QueueRow.FindFirst();
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is Imported with no error and its credit memo is posted
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        QueueRow.Reset();
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1176');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A posted return must end Imported: ' + QueueRow."Last Error");
        _Assert.AreEqual('', QueueRow."Last Error", 'A posted return must carry no error.');
        _Assert.AreNotEqual('', QueueRow."Posted Doc. No.", 'The credit memo must be recorded.');
    end;

    [Test]
    procedure QueuePage_Dismiss_OnARowAnotherSessionClaimedSinceTheList_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Dismiss on a row the list still shows as Error, which the job has since claimed, is refused as being processed instead of dismissing the live row.
        // [GIVEN] A committed row at Error shown on the queue page filtered to Error rows
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1143', '9243', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();
        QueuePage.OpenView();
        QueuePage.Filter.SetFilter(Status, Format(QueueRow.Status::Error));
        QueuePage.GoToRecord(QueueRow);

        // [GIVEN] The job claims the row after the list was shown
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();
        Commit();

        // [WHEN] Dismiss is invoked on the stale list row
        asserterror QueuePage.DismissReturn.Invoke();

        // [THEN] The action is refused as being processed and the row is still Processing
        QueuePage.Close();
        _Assert.ExpectedError('being processed');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Processing, QueueRow.Status, 'The live row must not be dismissed.');
        QueueRow.Delete();
    end;

    [Test]
    procedure QueuePage_DiscardDraftAndRetry_OnARowAnotherSessionClaimedSinceTheList_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Discard Draft and Retry on a row the list still shows as Error, which the job has since claimed, is refused as being processed instead of resetting the live row.
        // [GIVEN] A committed row at Error shown on the queue page filtered to Error rows, with the feature off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1144', '9244', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();
        QueuePage.OpenView();
        QueuePage.Filter.SetFilter(Status, Format(QueueRow.Status::Error));
        QueuePage.GoToRecord(QueueRow);

        // [GIVEN] The job claims the row after the list was shown
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime();
        QueueRow.Modify();
        Commit();

        // [WHEN] Discard Draft and Retry is invoked on the stale list row
        asserterror QueuePage.DiscardDraftAndRetry.Invoke();

        // [THEN] The action is refused as being processed and the row is still Processing
        QueuePage.Close();
        _Assert.ExpectedError('being processed');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Processing, QueueRow.Status, 'The live row must not be reset.');
        QueueRow.Delete();
    end;

    [Test]
    procedure Posting_GiftCardRefund_ToACardArchivedUnderItsOwnSeries_RestoresTheCardUnderItsNumber()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        VoucherFilter: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        LibraryERM: Codeunit "Library - ERM";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        VoucherNo: Code[20];
        OriginalArchSeries: Code[20];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund to a card whose voucher type archives under a number series of its own restores the voucher under its own number, and the queue row names that number, so a second row for the card and the Open Voucher action still resolve.
        // [GIVEN] A legacy-path store with automatic posting, a voucher type archiving under its own series, and gift card 9007 mapped to a voucher that is spent and archived under a different number
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVARCS', StoreCode, '9007', Voucher);
        VoucherNo := Voucher."No.";
        VoucherType.Get(Voucher."Voucher Type");
        OriginalArchSeries := VoucherType."Arch. No. Series";
        VoucherType."Arch. No. Series" := LibraryERM.CreateNoSeriesCode();
        VoucherType.Modify();
        Voucher."Allow Top-up" := false;
        Voucher.Modify();
        VoucherFilter.SetRange("No.", VoucherNo);
        NpRvVoucherMgt.ArchiveVouchers(VoucherFilter);
        VoucherType.Get(Voucher."Voucher Type");
        VoucherType."Arch. No. Series" := OriginalArchSeries;
        VoucherType.Modify();
        ArchVoucher.SetRange("Arch. No.", VoucherNo);
        _Assert.IsTrue(ArchVoucher.FindFirst(), 'Precondition: the archive holds the voucher.');
        _Assert.AreNotEqual(VoucherNo, ArchVoucher."No.", 'Precondition: the archive uses a number of its own.');

        // [GIVEN] A queued return of gross 125 refunded wholly to that gift card, which paid 125 on the order's invoice
        _Lib.InsertQueueRow(StoreCode, '1145', '9245', QueueRow);
        _Lib.InsertPostedInvoiceWithVoucherPayment('SI-LR1145', StoreCode, '9245', 'SPFYLRVARCS', 125);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1145', '9245', '#9245', Sku, '1145', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1145', 'gift_card', 125, _Lib.Lcy(), '9007'), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] Import and posting must succeed
        _Assert.IsTrue(Succeeded, 'Import and posting must succeed: ' + GetLastErrorText());

        // [THEN] The voucher is live under its own number with the refund, and the row names that number
        _Assert.IsTrue(Voucher.Get(VoucherNo), 'The voucher must be restored under its own number.');
        Voucher.CalcFields(Amount);
        _Assert.AreEqual(125, Voucher.Amount, 'The restored voucher holds the refund.');
        QueueRow.Find();
        _Assert.AreEqual(VoucherNo, _Lib.SettledVoucherNo(QueueRow), 'The row names the voucher by its own number.');
        _Assert.IsFalse(ArchVoucher.Find(), 'The archive row is gone.');
    end;

    [Test]
    procedure Posting_DraftOverTheRefundByACent_WithoutInvoiceRounding_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        OriginalInvoiceRounding: Boolean;
        OriginalPrecision: Decimal;
        OriginalRoundingType: Option Nearest,Up,Down;
        Succeeded: Boolean;
    begin
        // [SCENARIO] Without invoice rounding the tolerance is zero even when the ledger names a whole-unit rounding precision: a draft one cent over the refund is refused at posting although the payment line allows adjusting.
        // [GIVEN] A store posting manually with an adjustable mapping, invoice rounding off while the ledger names a whole-unit nearest precision, and a draft built for a return refunded 125
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := false;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        OriginalPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
        OriginalRoundingType := GeneralLedgerSetup."Inv. Rounding Type (LCY)";
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := 1;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Nearest;
        GeneralLedgerSetup.Modify();
        Commit();
        _Lib.InsertQueueRow(StoreCode, '1146', '9246', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1146', '9246', '#9246', Sku, '1146', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1146', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());

        // [GIVEN] A user adds a one-cent line to the draft
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 90000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", 0.01);
        SalesLine.Validate("Return Qty. to Receive", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The user posts the draft from the Return Order
        Succeeded := SalesPost.Run(SalesHeader);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := OriginalPrecision;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := OriginalRoundingType;
        GeneralLedgerSetup.Modify();
        Commit();

        // [THEN] The posting is refused for the cent
        _Assert.IsFalse(Succeeded, 'The posting must be refused: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'more than was refunded') > 0, 'A cent over the refund must be refused without invoice rounding: ' + ErrorText);
    end;

    [Test]
    procedure Field45_CanBeBlankedWhileTheToggleIsOff()
    var
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Blanking "Get Returns Starting From" is allowed while "Sales Return Order Integration" is off, so a store that does not import returns is not forced to carry a date.
        // [GIVEN] A store with the toggle off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Sales Return Order Integration" := false;
        ShopifyStore.Modify();

        // [WHEN] The start date is blanked
        ShopifyStore.Validate("Get Returns Starting From", 0DT);

        // [THEN] The value is accepted
        _Assert.AreEqual(0DT, ShopifyStore."Get Returns Starting From", 'A store without the toggle may have no start date.');
    end;

    [Test]
    procedure Posting_ThreeDecimalCurrency_WithoutInvoiceRounding_PostsTheExactRefund()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Currency: Record Currency;
        PaymentMapping: Record "NPR Magento Payment Mapping";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        MappingCode: Text[50];
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        OriginalInvoiceRounding: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded 125.006 in a currency with three decimals posts and settles without invoice rounding, because the over-refund guard compares the ledger amount and the payment at the same G/L precision instead of rounding only the ledger side up to 125.01.
        // [GIVEN] A legacy-path store with automatic posting, an adjustable mapping for its gateway so the Magento payment check stands aside, and invoice rounding off
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := false;
        SalesReceivablesSetup.Modify();
        Commit();

        // [GIVEN] A currency rounded to 0.001 at par with LCY, with a rate valid before the return's closing date
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Rounding Precision", 0.001);
        Currency.Modify(true);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);

        // [GIVEN] A queued return of 100.005 net plus 25.001 tax, refunded 125.006 by card in that currency
        _Lib.InsertQueueRow(StoreCode, '1147', '9247', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1147', '9247', '#9247', Sku, '1147', 1, 100.005, 25.001, 25, '71001', _Lib.RefundTxnJson('1147', 'shopify_payments', 125.006, Currency.Code, ''), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        Commit();

        // [THEN] Import and posting succeed
        _Assert.IsTrue(Succeeded, 'A refund of 125.006 in a three-decimal currency must post: ' + GetLastErrorText());

        // [THEN] The credit memo is worth 125.006 in the currency and is settled
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");
        _Assert.AreEqual(-125.006, CustLedgerEntry.Amount, 'The credit memo carries the refund to the thousandth.');
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled.');
    end;

    [Test]
    procedure Posting_GiftCardRefund_ToACardDeactivatedAtShopify_IsRefusedNamingTheReturn()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        VoucherFilter: Record "NPR NpRv Voucher";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        VoucherNo: Code[20];
        ErrorText: Text;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A refund to a gift card whose archived voucher was deactivated at Shopify is refused with an error naming the voucher and the return, instead of the voucher module's field check, and the archive row is kept.
        // [GIVEN] A legacy-path store with automatic posting and gift card 9008 mapped to a voucher that is archived and marked deactivated at Shopify
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        _Lib.DeleteVoucher('SPFYLRVARCD');
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVARCD', StoreCode, '9008', Voucher);
        VoucherNo := Voucher."No.";
        Voucher."Allow Top-up" := false;
        Voucher.Modify();
        VoucherFilter.SetRange("No.", VoucherNo);
        NpRvVoucherMgt.ArchiveVouchers(VoucherFilter);
        ArchVoucher.SetRange("Arch. No.", VoucherNo);
        _Assert.IsTrue(ArchVoucher.FindFirst(), 'Precondition: the archive holds the voucher.');
        ArchVoucher."Disabled at Shopify" := true;
        ArchVoucher.Modify();

        // [GIVEN] A queued return of gross 125 refunded wholly to that gift card
        _Lib.InsertQueueRow(StoreCode, '1148', '9248', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1148', '9248', '#9248', Sku, '1148', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1148', 'gift_card', 125, _Lib.Lcy(), '9008'), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);
        ErrorText := GetLastErrorText();

        // [THEN] The posting is refused naming the voucher, the return and the deactivation
        _Assert.IsFalse(Succeeded, 'A refund to a card deactivated at Shopify must be refused.');
        _Assert.IsTrue(StrPos(ErrorText, VoucherNo) > 0, 'The refusal must name the voucher: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, '#9248-R1') > 0, 'The refusal must name the return: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'deactivated at Shopify') > 0, 'The refusal must explain the deactivation: ' + ErrorText);

        // [THEN] The voucher stays archived
        _Assert.IsFalse(Voucher.Get(VoucherNo), 'The voucher must not be restored.');
        _Assert.IsTrue(ArchVoucher.Find(), 'The archive row is kept.');
    end;

    [Test]
    procedure Import_RefundPaymentLine_TakesAllowAdjustFromACompanyKeyedMapping()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        PaymentLine: Record "NPR Magento Payment Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        GenericMapping: Record "NPR Magento Payment Mapping";
        ExternalPaymentTypeID: Record "NPR External Payment Type ID";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] A card refund whose payment mapping is keyed by the card company, as the order import stores it, gives the refund payment line the mapping's "Allow Adjust Amount", so a credit memo lifted by invoice rounding is accepted for such a store too.
        // [GIVEN] A legacy-path store posting manually, no adjustable mapping for the bare gateway, and an adjustable mapping keyed by gateway and card company visa
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        if GenericMapping.Get('Shopify', LowerCase(StoreCode + '_shopify_payments')) then
            _Assert.IsFalse(GenericMapping."Allow Adjust Payment Amount", 'Precondition: the bare gateway mapping must not allow adjusting, or the company key is not what this test proves.');
        if not ExternalPaymentTypeID.Get('spfylr_visa_adjust') then begin
            ExternalPaymentTypeID.Init();
            ExternalPaymentTypeID."External Payment Type ID" := 'spfylr_visa_adjust';
            ExternalPaymentTypeID."Store Code" := StoreCode;
            ExternalPaymentTypeID."Payment Gateway" := 'shopify_payments';
            ExternalPaymentTypeID."Credit Card Company" := 'visa';
            ExternalPaymentTypeID.Insert();
        end;
        if not PaymentMapping.Get('Shopify', 'spfylr_visa_adjust') then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := 'spfylr_visa_adjust';
            PaymentMapping.Insert();
        end;
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        Commit();

        // [GIVEN] A queued return refunded 125 by a visa card through shopify_payments
        _Lib.InsertQueueRow(StoreCode, '1149', '9249', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1149', '9249', '#9249', Sku, '1149', 1, 100, 25, 25, '71001', _Lib.RefundTxnJsonWithCompany('1149', 'shopify_payments', 125, _Lib.Lcy(), 'visa'), _Lib.Lcy()));

        // [WHEN] The import builds the draft
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // Cleanup: remove the committed mapping rows before asserting.
        PaymentMapping.Delete();
        ExternalPaymentTypeID.Delete();
        Commit();

        // [THEN] The draft is built
        _Assert.IsTrue(Succeeded, 'The draft must build: ' + GetLastErrorText());

        // [THEN] The detail request asked Shopify for the card company
        _Assert.IsTrue(MockClient.GetRequestContaining('GetReturn').Contains('paymentDetails { ... on CardPaymentDetails { company } }'), 'The detail query must read the card company of each refund transaction.');

        // [THEN] The refund payment line allows adjusting, as the company-keyed mapping says
        PaymentLine.SetRange("Document Table No.", Database::"Sales Header");
        PaymentLine.SetRange("Document Type", PaymentLine."Document Type"::"Return Order");
        PaymentLine.SetRange("Document No.", QueueRow."Sales Header Doc. No.");
        _Assert.IsTrue(PaymentLine.FindFirst(), 'The draft carries a refund payment line.');
        _Assert.IsTrue(PaymentLine."Allow Adjust Amount", 'The payment line must take Allow Adjust Amount from the mapping keyed by the card company.');
    end;

    [Test]
    procedure PollJQ_InsertNewRows_FeatureSwitchedOnDuringTheListing_InsertsNothing()
    var
        TempQueueRow: Record "NPR Spfy NC Return Queue" temporary;
        QueueRow: Record "NPR Spfy NC Return Queue";
        Feature: Record "NPR Feature";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Rows listed for a store before the Shopify Ecommerce Order Experience feature was switched on are not inserted once it is on, so a poll in flight during the switch leaves no New rows the switch's guard could not see.
        // [GIVEN] A listed return of a legacy-path store, and the feature switched on after the listing
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        TempQueueRow.Init();
        TempQueueRow."Shopify Store Code" := StoreCode;
        TempQueueRow."Source Doc. ID" := '1150';
        TempQueueRow."Order Id" := '9250';
        TempQueueRow."Source Doc. Name" := '#9250-R1';
        TempQueueRow.Insert();
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Feature.Enabled := true;
        Feature.Modify();

        // [WHEN] The listed rows are inserted
        SpfyLegacyReturnPollJQ.InsertNewRows(TempQueueRow);

        // [THEN] No row was queued
        Feature.Enabled := false;
        Feature.Modify();
        _Assert.IsFalse(QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1150'), 'No row may be queued once the feature is on.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_ClosedExchangeReturnWithAShortRefund_IsNotRefusedForTheQuantity()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A closed return with an exchange line whose refund covers fewer units than were returned parses without the quantity refusal and keeps its exchange flag, because the exchanged units are not refunded and the exchange refusal names the real reason.
        // [GIVEN] A closed detail response with an exchange line, returning 3 units of which the refund line covers 2
        ResponseText := _Lib.ReturnDetailResponse('1151', '9251', '#9251', 'SPFYSNOW', '1151', 3, 200, 50, 25, '71001', _Lib.RefundTxnJson('1151', 'shopify_payments', 250, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"quantity":3,"subtotalSet"') > 0, 'Precondition: the fixture refunds the returned quantity.');
        ResponseText := ResponseText.Replace('"quantity":3,"subtotalSet"', '"quantity":2,"subtotalSet"');
        _Assert.IsTrue(StrPos(ResponseText, '"exchangeLineItems":{"edges":[]}') > 0, 'Precondition: the fixture has no exchange line.');
        ResponseText := ResponseText.Replace('"exchangeLineItems":{"edges":[]}', '"exchangeLineItems":{"edges":[{"node":{"id":"gid://shopify/ExchangeLineItem/1"}}]}');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        SpfyLegacyReturnAPI.ParseReturnDetail('', '1151', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The return is flagged as an exchange and the line keeps its returned quantity
        TempReturnBuffer.FindFirst();
        _Assert.IsTrue(TempReturnBuffer."Has Exchange Line", 'The exchange line is flagged for the import to refuse.');
        TempLineBuffer.FindFirst();
        _Assert.AreEqual(3, TempLineBuffer.Quantity, 'The returned quantity is kept.');
    end;

    [Test]
    procedure Posting_ReturnOrderWithoutAQueueRow_StillSchedulesTheFulfillmentTask()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        ReturnReceiptHeader: Record "Return Receipt Header";
        NcTask: Record "NPR Nc Task";
        SpfyTask: Record "NPR Spfy Task";
        SalesPost: Codeunit "Sales-Post";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] Posting a Return Order that carries Shopify ids but has no settlement row, and so is not this engine's document, still schedules the module's fulfillment task for its return receipt, so the legacy exit does not silence the other engine's Return Orders.
        // [GIVEN] A store that sends order fulfillments, and a Return Order built from a return whose queue row and settlement row are gone
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Send Order Fulfillments" := true;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1152', '9252', QueueRow);
        _Lib.BuildUnlinkedDraft(QueueRow, _Lib.ReturnDetailResponse('1152', '9252', '#9252', Sku, '1152', 2, 400, 100, 25, '71001', _Lib.RefundTxnJson('1152', 'shopify_payments', 500, _Lib.Lcy(), ''), _Lib.Lcy()), SalesHeader);
        QueueRow.Delete(false);
        _Lib.DeleteSettlement(StoreCode, '1152');
        SalesHeader.Find();
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The Return Order is posted
        Succeeded := SalesPost.Run(SalesHeader);

        // Cleanup: switch fulfillments off again before asserting, since the posting committed.
        ShopifyStore.Find();
        ShopifyStore."Send Order Fulfillments" := false;
        ShopifyStore.Modify();
        Commit();

        // [THEN] The posting succeeded and a return receipt exists
        _Assert.IsTrue(Succeeded, 'The posting must succeed: ' + GetLastErrorText());
        ReturnReceiptHeader.SetRange("Return Order No.", SalesHeader."No.");
        _Assert.IsTrue(ReturnReceiptHeader.FindFirst(), 'Posting must create a return receipt.');

        // [THEN] One of the task lists holds a fulfillment task for the receipt
        NcTask.SetRange("Table No.", Database::"Return Receipt Header");
        NcTask.SetRange("Record ID", ReturnReceiptHeader.RecordId());
        SpfyTask.SetRange("Table No.", Database::"Return Receipt Header");
        SpfyTask.SetRange("Record ID", ReturnReceiptHeader.RecordId());
        _Assert.IsTrue((not NcTask.IsEmpty()) or (not SpfyTask.IsEmpty()), 'A Return Order outside the legacy queue must keep the module''s fulfillment task.');
    end;

    [Test]
    procedure Mgt_DismissReturn_OnAStaleCopyAnotherSessionClaimed_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherSessionRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        LiveStatus: Enum "NPR Spfy Legacy Return Status";
    begin
        // [SCENARIO] Dismissing a row from a copy that still says Error, which another session has since claimed, is refused as being processed, because the dismissal re-reads the row under a lock instead of trusting the caller's copy.
        // [GIVEN] A committed row at Error, held by this session as it was, and set to Processing by another session since
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1153', '9253', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();
        OtherSessionRow.FindSourceDoc(StoreCode, OtherSessionRow."Source Doc. Type"::Return, '1153');
        OtherSessionRow.Status := OtherSessionRow.Status::Processing;
        OtherSessionRow."Processed At" := CurrentDateTime();
        OtherSessionRow.Modify();
        Commit();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'Precondition: this session still holds the row as Error.');

        // [WHEN] The return is dismissed from the stale copy
        asserterror SpfyLegacyReturnMgt.DismissReturn(QueueRow);

        // Cleanup: read the live row and remove it before asserting, since it is committed.
        OtherSessionRow.Find();
        LiveStatus := OtherSessionRow.Status;
        OtherSessionRow.Delete();
        Commit();

        // [THEN] The dismissal is refused as being processed and the live row was still Processing
        _Assert.ExpectedError('being processed');
        _Assert.AreEqual(OtherSessionRow.Status::Processing, LiveStatus, 'The live row must not be dismissed.');
    end;

    [Test]
    procedure Mgt_DiscardDraft_OnAStaleCopyAnotherSessionClaimed_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        OtherSessionRow: Record "NPR Spfy NC Return Queue";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        LiveStatus: Enum "NPR Spfy Legacy Return Status";
    begin
        // [SCENARIO] Discarding from a copy that still says Error, which another session has since claimed, is refused as being processed, because the discard re-reads the row under a lock instead of trusting the caller's copy.
        // [GIVEN] A committed row at Error, held by this session as it was, and set to Processing by another session since
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1154', '9254', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();
        OtherSessionRow.FindSourceDoc(StoreCode, OtherSessionRow."Source Doc. Type"::Return, '1154');
        OtherSessionRow.Status := OtherSessionRow.Status::Processing;
        OtherSessionRow."Processed At" := CurrentDateTime();
        OtherSessionRow.Modify();
        Commit();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'Precondition: this session still holds the row as Error.');

        // [WHEN] The draft is discarded from the stale copy
        asserterror SpfyLegacyReturnMgt.DiscardDraft(QueueRow);

        // Cleanup: read the live row and remove it before asserting, since it is committed.
        OtherSessionRow.Find();
        LiveStatus := OtherSessionRow.Status;
        OtherSessionRow.Delete();
        Commit();

        // [THEN] The discard is refused as being processed and the live row was still Processing
        _Assert.ExpectedError('being processed');
        _Assert.AreEqual(OtherSessionRow.Status::Processing, LiveStatus, 'The live row must not be reset.');
    end;

    [Test]
    procedure Posting_DraftOverTheRefundByACent_WithCentInvoiceRounding_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        OriginalInvoiceRounding: Boolean;
        OriginalPrecision: Decimal;
        OriginalRoundingType: Option Nearest,Up,Down;
        Succeeded: Boolean;
    begin
        // [SCENARIO] With invoice rounding on at a precision of 0.01 to nearest, which lifts no document at all, a draft one cent over the refund is still refused at posting: the tolerance is what the rounding type can add, not the whole precision.
        // [GIVEN] A store posting manually with an adjustable mapping, invoice rounding on at 0.01 nearest, and a draft built for a return refunded 125
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        OriginalPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
        OriginalRoundingType := GeneralLedgerSetup."Inv. Rounding Type (LCY)";
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := 0.01;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Nearest;
        GeneralLedgerSetup.Modify();
        Commit();
        _Lib.InsertQueueRow(StoreCode, '1155', '9255', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1155', '9255', '#9255', Sku, '1155', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1155', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());

        // [GIVEN] A user adds a one-cent line to the draft
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 90000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", 0.01);
        SalesLine.Validate("Return Qty. to Receive", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The user posts the draft from the Return Order
        Succeeded := SalesPost.Run(SalesHeader);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := OriginalPrecision;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := OriginalRoundingType;
        GeneralLedgerSetup.Modify();
        Commit();

        // [THEN] The posting is refused for the cent
        _Assert.IsFalse(Succeeded, 'A cent over the refund must be refused under cent rounding: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'more than was refunded') > 0, 'The refusal must name the overpayment: ' + ErrorText);
    end;

    [Test]
    procedure ProcessJQ_ProcessRow_WithTheEcommerceFeatureOn_DoesNotClaim()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Feature: Record "NPR Feature";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalEnabled: Boolean;
        Claimed: Boolean;
    begin
        // [SCENARIO] A row offered to the process row after the Shopify Ecommerce Order Experience feature was switched on is not claimed, so a run already in progress stops importing through the legacy engine the moment the other engine owns returns.
        // [GIVEN] A committed New row and the feature switched on after the job's snapshot
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1156', '9256', QueueRow);
        Commit();
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        OriginalEnabled := Feature.Enabled;
        Feature.Enabled := true;
        Feature.Modify();

        // [WHEN] The process row runs with the row
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is not claimed and untouched
        Feature.Enabled := OriginalEnabled;
        Feature.Modify();
        _Assert.IsFalse(Claimed, 'The row must not be claimed while the feature is on.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'The row must stay New.');
        _Assert.AreEqual(0DT, QueueRow."Processed At", 'The row must not be attempted.');
        QueueRow.Delete();
    end;

    [Test]
    procedure ProcessJQ_SuccessfulAttempt_ResetsTheRetryCount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A row that failed three times and then posts ends Imported with its retry count back at zero, so the attempts that failed no longer count against a later attempt on the same return.
        // [GIVEN] A legacy-path store with automatic posting and no refund account, so the first attempt commits the draft and fails in settlement, and the row then carries three failed attempts
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Return Refund G/L Account No." := '';
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1157', '9257', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1157', '9257', '#9257', Sku, '1157', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1157', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsFalse(_Lib.RunImport(QueueRow, MockClient), 'The automatic posting must fail without a refund account.');
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Retry Count" := 3;
        QueueRow.Modify();

        // [GIVEN] The refund account is set, so the committed draft can post without another Shopify call
        ShopifyStore.Find();
        ShopifyStore."Return Refund G/L Account No." := _Lib.CreateDirectPostingGLAccount();
        ShopifyStore.Modify();
        Commit();

        // [WHEN] The job processes the row
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is Imported with its retry count reset
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The posted row is Imported: ' + QueueRow."Last Error");
        _Assert.AreEqual(0, QueueRow."Retry Count", 'A successful attempt resets the retry count.');
    end;

    [Test]
    procedure ReturnApi_ParseDetail_LineWithoutAnOrderLine_IsRefusedAsUnsupported()
    var
        TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary;
        TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary;
        TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary;
        SpfyLegacyReturnAPI: Codeunit "NPR Spfy Legacy Return API";
        Response: JsonToken;
        ResponseText: Text;
    begin
        // [SCENARIO] A return line with no order line behind it, as Shopify reports an unverified return line, is refused at parsing with an error naming the return, instead of reaching the quantity check with a blank SKU.
        // [GIVEN] A detail response whose return line carries no lineItem under its fulfillment line
        ResponseText := _Lib.ReturnDetailResponse('1158', '9258', '#9258', 'SPFYSNOW', '1158', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1158', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy());
        _Assert.IsTrue(StrPos(ResponseText, '"lineItem":{"id":"gid://shopify/LineItem/1158"') > 0, 'Precondition: the fixture carries the order line.');
        ResponseText := ResponseText.Replace('"lineItem":{"id":"gid://shopify/LineItem/1158"', '"lineItemGone":{"id":"gid://shopify/LineItem/1158"');
        Response.ReadFrom(ResponseText);

        // [WHEN] The response is parsed
        asserterror SpfyLegacyReturnAPI.ParseReturnDetail('', '1158', Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);

        // [THEN] The error names the return and says the line has no order line behind it
        _Assert.ExpectedError('#9258-R1');
        _Assert.ExpectedError('no order line behind it');
    end;

    [Test]
    procedure Mgt_IsBeingProcessed_WithoutAJobEntry_UsesTheRegisteredInterval()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        JobQueueEntry: Record "Job Queue Entry";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        SpfyLegacyReturnPollJQ: Codeunit "NPR Spfy Legacy Return Poll JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        YoungerRow: Record "NPR Spfy NC Return Queue";
        HeldByAnotherSession: Boolean;
        YoungerHeld: Boolean;
    begin
        // [SCENARIO] While no process job entry exists, a Processing row attempted eleven minutes ago counts as stale, because the stale limit falls back to twice the interval the job is registered with (five minutes), not to a longer default.
        // [GIVEN] No process job entry, and a row at Processing attempted eleven minutes ago
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Spfy Legacy Return Proc JQ");
        JobQueueEntry.DeleteAll();
        _Lib.InsertQueueRow(StoreCode, '1161', '9261', QueueRow);
        QueueRow.Status := QueueRow.Status::Processing;
        QueueRow."Processed At" := CurrentDateTime() - 11 * 60 * 1000;
        QueueRow.Modify();
        _Lib.InsertQueueRow(StoreCode, '1165', '9265', YoungerRow);
        YoungerRow.Status := YoungerRow.Status::Processing;
        YoungerRow."Processed At" := CurrentDateTime() - 9 * 60 * 1000;
        YoungerRow.Modify();

        // [WHEN] The rows are checked for another session's hold
        HeldByAnotherSession := SpfyLegacyReturnMgt.IsBeingProcessed(QueueRow);
        YoungerHeld := SpfyLegacyReturnMgt.IsBeingProcessed(YoungerRow);

        // Cleanup: register the jobs again for the tests that expect them.
        SpfyLegacyReturnPollJQ.SetupJobQueues();

        // [THEN] The eleven-minute row is stale and the nine-minute row is still held, so the limit is ten minutes: twice the registered five
        _Assert.IsFalse(HeldByAnotherSession, 'Without a job entry the stale limit is twice the registered interval, so an attempt eleven minutes old is stale.');
        _Assert.IsTrue(YoungerHeld, 'An attempt nine minutes old is still within twice the registered five-minute interval.');
    end;

    [Test]
    [HandlerFunctions('ArchVoucherCardHandler')]
    procedure QueuePage_OpenVoucher_OnAnArchivedCard_OpensTheArchivedVoucher()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Voucher: Record "NPR NpRv Voucher";
        VoucherFilter: Record "NPR NpRv Voucher";
        QueuePage: TestPage "NPR Spfy Legacy Return Queue";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        VoucherType: Record "NPR NpRv Voucher Type";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        LibraryERM: Codeunit "Library - ERM";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        VoucherNo: Code[20];
        OriginalArchSeries: Code[20];
    begin
        // [SCENARIO] Open Voucher on a row whose voucher is spent and archived under a number of the type's own archive series opens the archived voucher card for that archive row instead of failing with a record-not-found error, since the row carries the voucher's own number until the posting restores it.
        // [GIVEN] A row naming a voucher that is archived under a different number
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.DeleteVoucher('SPFYLRVARCO');
        _Lib.CreateVoucherWithGiftCardId('SPFYLRVARCO', StoreCode, '9009', Voucher);
        VoucherNo := Voucher."No.";
        VoucherType.Get(Voucher."Voucher Type");
        OriginalArchSeries := VoucherType."Arch. No. Series";
        VoucherType."Arch. No. Series" := LibraryERM.CreateNoSeriesCode();
        VoucherType.Modify();
        Voucher."Allow Top-up" := false;
        Voucher.Modify();
        VoucherFilter.SetRange("No.", VoucherNo);
        NpRvVoucherMgt.ArchiveVouchers(VoucherFilter);
        VoucherType.Get(Voucher."Voucher Type");
        VoucherType."Arch. No. Series" := OriginalArchSeries;
        VoucherType.Modify();
        _Assert.IsFalse(Voucher.Get(VoucherNo), 'Precondition: the voucher is archived.');
        ArchVoucher.SetRange("Arch. No.", VoucherNo);
        _Assert.IsTrue(ArchVoucher.FindFirst(), 'Precondition: the archive holds the voucher.');
        _Assert.AreNotEqual(VoucherNo, ArchVoucher."No.", 'Precondition: the archive uses a number of its own.');
        _Lib.InsertQueueRow(StoreCode, '1160', '9260', QueueRow);
        _Lib.SetSettlement(QueueRow, 0, VoucherNo);
        _CapturedMessage := '';

        // [WHEN] Open Voucher is invoked on the row
        QueuePage.OpenView();
        QueuePage.GoToRecord(QueueRow);
        QueuePage.OpenVoucher.Invoke();
        QueuePage.Close();

        // [THEN] The archived voucher card opened on the archive row of the voucher
        _Assert.AreEqual(ArchVoucher."No.", _CapturedMessage, 'The archived voucher card must open on the archive row that holds the row''s voucher.');
    end;

    [PageHandler]
    procedure ArchVoucherCardHandler(var ArchVoucherCard: TestPage "NPR NpRv Arch. Voucher Card")
    begin
        _CapturedMessage := ArchVoucherCard."No.".Value();
        ArchVoucherCard.Close();
    end;

    [Test]
    procedure Posting_InvoiceRoundingUp_PostsTheLiftedTotal()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        OriginalInvoiceRounding: Boolean;
        OriginalAllowAdjust: Boolean;
        MappingExisted: Boolean;
        OriginalPrecision: Decimal;
        OriginalRoundingType: Option Nearest,Up,Down;
        Imported: Boolean;
    begin
        // [SCENARIO] On a company that rounds invoices up to the whole unit, a return refunded 124.40 posts as 125 and settles: rounding up can lift a document by just under the whole unit, and the over-refund check allows exactly that.
        // [GIVEN] A legacy-path store with automatic posting, an adjustable mapping for its gateway, and invoice rounding up to whole units with a rounding account on the customer's posting group
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        OriginalPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
        OriginalRoundingType := GeneralLedgerSetup."Inv. Rounding Type (LCY)";
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := 1;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Up;
        GeneralLedgerSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();

        // [GIVEN] A queued return of one unit refunded 124.40 by card, which rounding up lifts by 0.60
        _Lib.InsertQueueRow(StoreCode, '1162', '9262', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1162', '9262', '#9262', Sku, '1162', 1, 99.52, 24.88, 25, '71001', _Lib.RefundTxnJson('1162', 'shopify_payments', 124.4, _Lib.Lcy(), ''), _Lib.Lcy()));

        // [WHEN] The import runs with automatic posting
        Imported := _Lib.RunImport(QueueRow, MockClient);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the company setup before asserting, since the posting committed it.
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := OriginalPrecision;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := OriginalRoundingType;
        GeneralLedgerSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        Commit();

        // [THEN] The return posted, rounded up to 125 and fully settled
        _Assert.IsTrue(Imported, 'A return lifted by rounding up must post: ' + ErrorText);
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");
        _Assert.AreEqual(-125, CustLedgerEntry.Amount, 'The credit memo is rounded up to the whole unit.');
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be fully settled.');
    end;

    [Test]
    procedure Posting_InvoiceRoundingDown_DraftOverTheRefund_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        OriginalInvoiceRounding: Boolean;
        OriginalAllowAdjust: Boolean;
        MappingExisted: Boolean;
        OriginalPrecision: Decimal;
        OriginalRoundingType: Option Nearest,Up,Down;
        Succeeded: Boolean;
    begin
        // [SCENARIO] On a company that rounds invoices down to the whole unit, a draft raised by a tenth of a unit above a 124.90 refund is refused at posting: rounding down never lifts a document, so no gap above the refund is tolerated.
        // [GIVEN] A store posting manually with an adjustable mapping, invoice rounding down to whole units, and a draft built for a return refunded 124.90
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        OriginalPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
        OriginalRoundingType := GeneralLedgerSetup."Inv. Rounding Type (LCY)";
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := 1;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Down;
        GeneralLedgerSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();
        _Lib.InsertQueueRow(StoreCode, '1163', '9263', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1163', '9263', '#9263', Sku, '1163', 1, 99.92, 24.98, 25, '71001', _Lib.RefundTxnJson('1163', 'shopify_payments', 124.9, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());

        // [GIVEN] A user adds a 0.10 line to the draft, so it is worth 125.00 and rounding down leaves it there
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 90000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", 0.1);
        SalesLine.Validate("Return Qty. to Receive", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The user posts the draft from the Return Order
        Succeeded := SalesPost.Run(SalesHeader);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := OriginalPrecision;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := OriginalRoundingType;
        GeneralLedgerSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        Commit();

        // [THEN] The posting is refused for the tenth of a unit
        _Assert.IsFalse(Succeeded, 'A tenth of a unit over the refund must be refused when rounding down: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'more than was refunded') > 0, 'The refusal must name the overpayment: ' + ErrorText);
    end;

    [Test]
    procedure Posting_ThreeDecimalCurrency_RoundedUp_PostsTheLiftedTotal()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Currency: Record Currency;
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        OriginalInvoiceRounding: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded 10.001 in a three-decimal currency whose invoices round up to the cent posts as 10.01 and settles: the over-refund check sees the lift as a whole cent because it compares at the G/L precision, and allows that much for rounding up in a finer currency.
        // [GIVEN] A legacy-path store with automatic posting, an adjustable mapping, invoice rounding on and a rounding account on the customer's posting group
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();

        // [GIVEN] A currency rounded to 0.001 at par with LCY whose invoices round up to 0.01
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Rounding Precision", 0.001);
        Currency.Validate("Invoice Rounding Precision", 0.01);
        Currency.Validate("Invoice Rounding Type", Currency."Invoice Rounding Type"::Up);
        Currency.Modify(true);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);

        // [GIVEN] A queued return of 8.001 net plus 2.000 tax, refunded 10.001 by card in that currency
        _Lib.InsertQueueRow(StoreCode, '1164', '9264', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1164', '9264', '#9264', Sku, '1164', 1, 8.001, 2, 25, '71001', _Lib.RefundTxnJson('1164', 'shopify_payments', 10.001, Currency.Code, ''), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        Commit();

        // [THEN] Import and posting succeed
        _Assert.IsTrue(Succeeded, 'A refund of 10.001 rounded up to 10.01 must post: ' + ErrorText);

        // [THEN] The credit memo is worth 10.01 in the currency and is settled
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");
        _Assert.AreEqual(-10.01, CustLedgerEntry.Amount, 'The credit memo is rounded up to the cent.');
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled.');
    end;

    [Test]
    procedure ProcessJQ_DraftCreated_ResetsTheRetryCount()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A row that failed three times and then builds its draft on a store posting manually ends at Draft Created with its retry count back at zero and its last error cleared, so the draft posted later by hand starts with the full budget.
        // [GIVEN] A store posting manually, a return whose draft is built and committed, and the row then carrying three failed attempts and their error
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1166', '9266', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1166', '9266', '#9266', Sku, '1166', 1, 80, 20, 25, '71001', _Lib.RefundTxnJson('1166', 'shopify_payments', 100, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Retry Count" := 3;
        QueueRow."Last Error" := 'An earlier attempt failed.';
        QueueRow.Modify();
        Commit();

        // [WHEN] The job processes the row, which reuses the committed draft
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);

        // [THEN] The row is at Draft Created with its retry count reset
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::"Draft Created", QueueRow.Status, 'An unposted draft leaves the row at Draft Created: ' + QueueRow."Last Error");
        _Assert.AreEqual(0, QueueRow."Retry Count", 'A successful attempt resets the retry count.');
        _Assert.AreEqual('', QueueRow."Last Error", 'A successful attempt clears the last error.');
    end;

    [Test]
    procedure Posting_InvoiceRoundingUp_DraftOverTheRefundByAUnit_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GeneralLedgerSetup: Record "General Ledger Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SalesPost: Codeunit "Sales-Post";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        OriginalInvoiceRounding: Boolean;
        OriginalAllowAdjust: Boolean;
        MappingExisted: Boolean;
        OriginalPrecision: Decimal;
        OriginalRoundingType: Option Nearest,Up,Down;
        Succeeded: Boolean;
    begin
        // [SCENARIO] On a company that rounds invoices up to the whole unit, a draft raised by a whole unit above a 124.00 refund is refused at posting: rounding up lifts a document by less than a unit, so a gap of a whole unit is an edit.
        // [GIVEN] A store posting manually with an adjustable mapping, invoice rounding up to whole units, and a draft built for a return refunded 124.00
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        OriginalPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
        OriginalRoundingType := GeneralLedgerSetup."Inv. Rounding Type (LCY)";
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := 1;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Up;
        GeneralLedgerSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();
        _Lib.InsertQueueRow(StoreCode, '1169', '9269', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1169', '9269', '#9269', Sku, '1169', 1, 99.2, 24.8, 25, '71001', _Lib.RefundTxnJson('1169', 'shopify_payments', 124, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());

        // [GIVEN] A user adds a 1.00 line to the draft, so it is worth 125.00, which rounding up leaves there
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 90000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", 1);
        SalesLine.Validate("Return Qty. to Receive", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The user posts the draft from the Return Order
        Succeeded := SalesPost.Run(SalesHeader);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Inv. Rounding Precision (LCY)" := OriginalPrecision;
        GeneralLedgerSetup."Inv. Rounding Type (LCY)" := OriginalRoundingType;
        GeneralLedgerSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        Commit();

        // [THEN] The posting is refused for the whole unit
        _Assert.IsFalse(Succeeded, 'A whole unit over the refund must be refused when rounding up: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'more than was refunded') > 0, 'The refusal must name the overpayment: ' + ErrorText);
    end;

    [Test]
    procedure Posting_ThreeDecimalCurrency_RoundedToTheNearestHalfCent_PostsTheLiftedTotal()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Currency: Record Currency;
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        OriginalInvoiceRounding: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded 10.004 in a three-decimal currency whose invoices round to the nearest half cent posts as 10.005 and settles: the over-refund check compares at the ledger's cents, where the lift of 0.001 shows as a whole cent, and allows one cent in a currency finer than the ledger.
        // [GIVEN] A legacy-path store with automatic posting, an adjustable mapping, invoice rounding on and a rounding account on the customer's posting group
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();

        // [GIVEN] A currency rounded to 0.001 at par with LCY whose invoices round to the nearest 0.005
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Rounding Precision", 0.001);
        Currency.Validate("Invoice Rounding Precision", 0.005);
        Currency.Validate("Invoice Rounding Type", Currency."Invoice Rounding Type"::Nearest);
        Currency.Modify(true);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);

        // [GIVEN] A queued return of 8.003 net plus 2.001 tax, refunded 10.004 by card in that currency
        _Lib.InsertQueueRow(StoreCode, '1168', '9268', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1168', '9268', '#9268', Sku, '1168', 1, 8.003, 2.001, 25, '71001', _Lib.RefundTxnJson('1168', 'shopify_payments', 10.004, Currency.Code, ''), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        Commit();

        // [THEN] Import and posting succeed
        _Assert.IsTrue(Succeeded, 'A refund of 10.004 rounded to 10.005 must post: ' + ErrorText);

        // [THEN] The credit memo is worth 10.005 in the currency and is settled
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");
        _Assert.AreEqual(-10.005, CustLedgerEntry.Amount, 'The credit memo is rounded to the nearest half cent in its currency.');
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled.');
    end;

    [Test]
    [HandlerFunctions('CaptureMessage')]
    procedure FeatureFlagOn_RowQueuedBetweenTheValidateCheckAndTheSave_RefusesTheSave()
    var
        Feature: Record "NPR Feature";
        LegacyReturnQueue: Record "NPR Spfy NC Return Queue";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] A return queued after the feature switch's validate check passed, but before the row is saved, refuses the save with the unprocessed-rows message, because a page saves the flag a round trip after it validated it.
        // [GIVEN] No legacy return queue rows are left over from other tests, since the check scans the whole table regardless of store
        LegacyReturnQueue.SetFilter(Status, '%1|%2|%3|%4|%5|%6', LegacyReturnQueue.Status::New, LegacyReturnQueue.Status::Processing, LegacyReturnQueue.Status::Error, LegacyReturnQueue.Status::"Draft Created", LegacyReturnQueue.Status::Dismissed, LegacyReturnQueue.Status::Waiting);
        LegacyReturnQueue.DeleteAll();

        // [GIVEN] A legacy-path store with the feature off, the feature validated on with an empty queue, and a New row queued since
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        Feature.Validate(Enabled, true);
        _Lib.InsertQueueRow(StoreCode, '1170', '9270', QueueRow);
        Clear(_CapturedMessage);

        // [WHEN] The feature row is saved with its triggers
        asserterror Feature.Modify(true);

        // [THEN] The save is refused naming the queue, and the feature stays off
        _Assert.IsTrue(StrPos(_CapturedMessage, QueueRow.TableCaption()) > 0, 'The refusal at the save must name the legacy return queue: ' + _CapturedMessage);
        _Assert.IsTrue(StrPos(_CapturedMessage, 'not possible') > 0, 'The message must be the refusal: ' + _CapturedMessage);
        _Assert.IsFalse(ShopifyEcommOrderExp.IsFeatureEnabled(), 'The feature must stay off.');
    end;

    [Test]
    procedure Mgt_DiscardDraft_WithTheEcommerceFeatureOn_IsRefused()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
        Feature: Record "NPR Feature";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalEnabled: Boolean;
    begin
        // [SCENARIO] Discarding a draft while the Shopify Ecommerce Order Experience feature is on is refused inside the discard itself, under the switch's lock, so a page whose own guard passed a moment before the switch cannot write a New row the switch would have refused.
        // [GIVEN] A committed row at Error and the feature switched on since
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1171', '9271', QueueRow);
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();
        Commit();
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());
        OriginalEnabled := Feature.Enabled;
        Feature.Enabled := true;
        Feature.Modify();

        // [WHEN] The draft is discarded
        asserterror SpfyLegacyReturnMgt.DiscardDraft(QueueRow);

        // [THEN] The discard is refused for the feature and the row stays at Error
        Feature.Enabled := OriginalEnabled;
        Feature.Modify();
        _Assert.ExpectedError(Feature.Description);
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::Error, QueueRow.Status, 'The row must not be reset while the feature is on.');
        QueueRow.Delete();
    end;

    [Test]
    procedure Posting_ThreeDecimalCurrency_RoundedUpToFiveCents_PostsTheLiftedTotal()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Currency: Record Currency;
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        OriginalInvoiceRounding: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] A return refunded 10.001 in a three-decimal currency whose invoices round up to 0.05 posts as 10.05 and settles: rounding up in a currency finer than the ledger may show the whole precision at the ledger's cents.
        // [GIVEN] A legacy-path store with automatic posting, an adjustable mapping, invoice rounding on and a rounding account on the customer's posting group
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();

        // [GIVEN] A currency rounded to 0.001 at par with LCY whose invoices round up to 0.05
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Rounding Precision", 0.001);
        Currency.Validate("Invoice Rounding Precision", 0.05);
        Currency.Validate("Invoice Rounding Type", Currency."Invoice Rounding Type"::Up);
        Currency.Modify(true);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);

        // [GIVEN] A queued return of 8.001 net plus 2.000 tax, refunded 10.001 by card in that currency
        _Lib.InsertQueueRow(StoreCode, '1172', '9272', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1172', '9272', '#9272', Sku, '1172', 1, 8.001, 2.000, 25, '71001', _Lib.RefundTxnJson('1172', 'shopify_payments', 10.001, Currency.Code, ''), Currency.Code));

        // [WHEN] The import runs with automatic posting
        Succeeded := _Lib.RunImport(QueueRow, MockClient);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        Commit();

        // [THEN] Import and posting succeed
        _Assert.IsTrue(Succeeded, 'A refund of 10.001 rounded up to 10.05 must post: ' + ErrorText);

        // [THEN] The credit memo is worth 10.05 in the currency and is settled
        _Lib.GetCreditMemoForReturnOrder(QueueRow."Sales Header Doc. No.", SalesCrMemoHeader);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");
        _Assert.AreEqual(-10.05, CustLedgerEntry.Amount, 'The credit memo is rounded up to 0.05 in its currency.');
        _Assert.AreEqual(0, CustLedgerEntry."Remaining Amount", 'The credit memo must be settled.');
    end;

    [Test]
    procedure Posting_ThreeDecimalCurrency_DraftOverTheRefundByACent_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        SalesPost: Codeunit "Sales-Post";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        OriginalInvoiceRounding: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] In a three-decimal currency whose invoices round to the nearest half cent, a draft raised by 0.01 above a 10.004 refund is refused at posting: the tolerance there is one ledger cent, and the edit shows as two.
        // [GIVEN] A store posting manually with an adjustable mapping, invoice rounding on and a rounding account on the customer's posting group
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();

        // [GIVEN] A currency rounded to 0.001 at par with LCY whose invoices round to the nearest 0.005
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Rounding Precision", 0.001);
        Currency.Validate("Invoice Rounding Precision", 0.005);
        Currency.Validate("Invoice Rounding Type", Currency."Invoice Rounding Type"::Nearest);
        Currency.Modify(true);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);

        // [GIVEN] A draft built for a return of 8.003 net plus 2.001 tax, refunded 10.004 by card in that currency
        _Lib.InsertQueueRow(StoreCode, '1173', '9273', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1173', '9273', '#9273', Sku, '1173', 1, 8.003, 2.001, 25, '71001', _Lib.RefundTxnJson('1173', 'shopify_payments', 10.004, Currency.Code, ''), Currency.Code));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());

        // [GIVEN] A user adds a 0.01 line to the draft, so it is worth 10.014, which invoice rounding lifts to 10.015
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 90000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", 0.01);
        SalesLine.Validate("Return Qty. to Receive", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The user posts the draft from the Return Order
        Succeeded := SalesPost.Run(SalesHeader);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        Commit();

        // [THEN] The posting is refused for the edit
        _Assert.IsFalse(Succeeded, 'A draft a cent over the refund must be refused in a three-decimal currency: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'more than was refunded') > 0, 'The refusal must name the overpayment: ' + ErrorText);
    end;

    [Test]
    procedure FeatureFlag_SavingAnotherFeatureWithALegacyReturnPending_IsNotRefused()
    var
        Feature: Record "NPR Feature";
        QueueRow: Record "NPR Spfy NC Return Queue";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Saving another feature while a legacy return is still New is not refused: the save check belongs to the Shopify Ecommerce Order Experience feature alone.
        // [GIVEN] A legacy return queued as New
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.InsertQueueRow(StoreCode, '1174', '9274', QueueRow);

        // [GIVEN] Another feature, enabled
        if Feature.Get('CORE2191 TEST FEATURE') then
            Feature.Delete();
        Feature.Init();
        Feature.Id := 'CORE2191 TEST FEATURE';
        Feature.Enabled := true;
        Feature.Insert();

        // [WHEN] The other feature is saved with its triggers
        Feature.Modify(true);

        // [THEN] The save went through and the return is still queued
        Feature.Get('CORE2191 TEST FEATURE');
        _Assert.IsTrue(Feature.Enabled, 'The other feature must stay enabled.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'The queued return must be untouched.');
        Feature.Delete();
        QueueRow.Delete();
    end;

    [Test]
    procedure FeatureFlagOff_SavedWithALegacyReturnPending_IsNotRefused()
    var
        Feature: Record "NPR Feature";
        QueueRow: Record "NPR Spfy NC Return Queue";
        ShopifyEcommOrderExp: Codeunit "NPR Spfy Ecommerce Order Exp";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
    begin
        // [SCENARIO] Saving the Shopify Ecommerce Order Experience feature switched off while a legacy return is still New is not refused: only switching it on must wait for the queue.
        // [GIVEN] A legacy-path store with the feature off and a return queued as New
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        ShopifyEcommOrderExp.SetFeatureEnabled(false);
        _Lib.InsertQueueRow(StoreCode, '1175', '9275', QueueRow);
        Feature.Get(ShopifyEcommOrderExp.GetFeatureId());

        // [WHEN] The feature row is saved off with its triggers
        Feature.Modify(true);

        // [THEN] The save went through, the feature stays off and the return is still queued
        _Assert.IsFalse(ShopifyEcommOrderExp.IsFeatureEnabled(), 'The feature must stay off.');
        QueueRow.Find();
        _Assert.AreEqual(QueueRow.Status::New, QueueRow.Status, 'The queued return must be untouched.');
        QueueRow.Delete();
    end;

    [Test]
    procedure Posting_ThreeDecimalCurrency_RoundedUpToFiveCents_DraftOverTheRefund_IsRefused()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        Currency: Record Currency;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        LibraryERM: Codeunit "Library - ERM";
        SalesPost: Codeunit "Sales-Post";
        MappingCode: Text[50];
        ErrorText: Text;
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        OriginalRoundingAccount: Code[20];
        MappingExisted: Boolean;
        OriginalAllowAdjust: Boolean;
        OriginalInvoiceRounding: Boolean;
        Succeeded: Boolean;
    begin
        // [SCENARIO] In a three-decimal currency whose invoices round up to 0.05, a draft raised by 0.05 above a 10.001 refund is refused at posting: rounding up may show the whole 0.05 at the ledger's cents, and the edit shows as 0.10.
        // [GIVEN] A store posting manually with an adjustable mapping, invoice rounding on and a rounding account on the customer's posting group
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        MappingCode := CopyStr(LowerCase(StoreCode + '_shopify_payments'), 1, MaxStrLen(MappingCode));
        MappingExisted := PaymentMapping.Get('Shopify', MappingCode);
        if not MappingExisted then begin
            PaymentMapping.Init();
            PaymentMapping."External Payment Method Code" := 'Shopify';
            PaymentMapping."External Payment Type" := MappingCode;
            PaymentMapping.Insert();
        end;
        OriginalAllowAdjust := PaymentMapping."Allow Adjust Payment Amount";
        PaymentMapping."Allow Adjust Payment Amount" := true;
        PaymentMapping.Modify();
        SalesReceivablesSetup.Get();
        OriginalInvoiceRounding := SalesReceivablesSetup."Invoice Rounding";
        SalesReceivablesSetup."Invoice Rounding" := true;
        SalesReceivablesSetup.Modify();
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        OriginalRoundingAccount := CustomerPostingGroup."Invoice Rounding Account";
        if CustomerPostingGroup."Invoice Rounding Account" = '' then begin
            CustomerPostingGroup."Invoice Rounding Account" := ShopifyStore."Ret. Shipping Refund G/L Acc.";
            CustomerPostingGroup.Modify();
        end;
        Commit();

        // [GIVEN] A currency rounded to 0.001 at par with LCY whose invoices round up to 0.05
        LibraryERM.CreateCurrency(Currency);
        Currency.Validate("Amount Rounding Precision", 0.001);
        Currency.Validate("Invoice Rounding Precision", 0.05);
        Currency.Validate("Invoice Rounding Type", Currency."Invoice Rounding Type"::Up);
        Currency.Modify(true);
        LibraryERM.CreateExchangeRate(Currency.Code, 20260101D, 1, 1);

        // [GIVEN] A draft built for a return of 8.001 net plus 2.000 tax, refunded 10.001 by card in that currency
        _Lib.InsertQueueRow(StoreCode, '1177', '9277', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1177', '9277', '#9277', Sku, '1177', 1, 8.001, 2.000, 25, '71001', _Lib.RefundTxnJson('1177', 'shopify_payments', 10.001, Currency.Code, ''), Currency.Code));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());

        // [GIVEN] A user adds a 0.05 line to the draft, so it is worth 10.051, which invoice rounding lifts to 10.10
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 90000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", ShopifyStore."Ret. Shipping Refund G/L Acc.");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", 0.05);
        SalesLine.Validate("Return Qty. to Receive", 1);
        SalesLine.Validate("Qty. to Invoice", 1);
        SalesLine.Modify(true);
        SalesHeader.Receive := true;
        SalesHeader.Invoice := true;
        Commit();

        // [WHEN] The user posts the draft from the Return Order
        Succeeded := SalesPost.Run(SalesHeader);
        ErrorText := GetLastErrorText();

        // Cleanup: restore the committed mapping and setup before asserting.
        PaymentMapping.Get('Shopify', MappingCode);
        if MappingExisted then begin
            PaymentMapping."Allow Adjust Payment Amount" := OriginalAllowAdjust;
            PaymentMapping.Modify();
        end else
            PaymentMapping.Delete();
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Invoice Rounding" := OriginalInvoiceRounding;
        SalesReceivablesSetup.Modify();
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup."Invoice Rounding Account" := OriginalRoundingAccount;
        CustomerPostingGroup.Modify();
        Commit();

        // [THEN] The posting is refused for the edit
        _Assert.IsFalse(Succeeded, 'A draft 0.05 over the refund must be refused when rounding up to 0.05: ' + ErrorText);
        _Assert.IsTrue(StrPos(ErrorText, 'more than was refunded') > 0, 'The refusal must name the overpayment: ' + ErrorText);
    end;

    [Test]
    procedure Import_OnARecordFilteredToError_PostingAutomatically_Succeeds()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Succeeded: Boolean;
    begin
        // [SCENARIO] The import run on a record filtered to Error, as a page hands it over, posts the return automatically and succeeds: it re-reads the row by key after the posting moved it out of the filter.
        // [GIVEN] No unfinished rows are left over, and a row whose draft was built while the store posted manually, set back to Error
        _Lib.DeleteUnfinishedQueueRows();
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1178', '9278', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1178', '9278', '#9278', Sku, '1178', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1178', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'Precondition: the draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow.Modify();

        // [GIVEN] The store now posts returns automatically, and the row is read through a filter on Error
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Post Returns Automatically" := true;
        ShopifyStore.Modify();
        QueueRow.SetRange(Status, QueueRow.Status::Error);
        QueueRow.FindFirst();

        // [WHEN] The import runs on the filtered record
        Succeeded := _Lib.RunImport(QueueRow, MockClient);

        // [THEN] The import succeeds and the posting marked the row Imported
        _Assert.IsTrue(Succeeded, 'The import must not fail after its own posting: ' + GetLastErrorText());
        QueueRow.Reset();
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1178');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'The posting marks the row Imported.');
    end;

    [Test]
    procedure ProcessJQ_FailureAfterTheCreditMemoCommitted_MarksTheRowImported()
    var
        ShopifyStore: Record "NPR Spfy Store";
        QueueRow: Record "NPR Spfy NC Return Queue";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyLegacyReturnProcessJQ: Codeunit "NPR Spfy Legacy Return Proc JQ";
        FailAfterPost: Codeunit "NPR Spfy LR Fail After Post";
        SentryCapture: Codeunit "NPR Library - Sentry Capture";
        StoreCode: Code[20];
        Sku: Code[20];
        CustomerNo: Code[20];
        LocationCode: Code[10];
        Claimed: Boolean;
    begin
        // [SCENARIO] A run that fails after Sales-Post committed the credit memo leaves the row Imported with no error and a reset retry count, since the return is posted and settled, and still reports the bug behind the failure to Sentry.
        // [GIVEN] A row whose draft was built while the store posted manually, set back to Error after two failed attempts
        _Lib.DeleteUnfinishedQueueRows();
        _Lib.SetupLegacyReturnStore(StoreCode, Sku, CustomerNo, LocationCode);
        _Lib.GetStore(StoreCode, ShopifyStore);
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        _Lib.InsertQueueRow(StoreCode, '1179', '9279', QueueRow);
        MockClient.AddResponse('GetReturn', _Lib.ReturnDetailResponse('1179', '9279', '#9279', Sku, '1179', 1, 100, 25, 25, '71001', _Lib.RefundTxnJson('1179', 'shopify_payments', 125, _Lib.Lcy(), ''), _Lib.Lcy()));
        _Assert.IsTrue(_Lib.RunImport(QueueRow, MockClient), 'Precondition: the draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        QueueRow.Status := QueueRow.Status::Error;
        QueueRow."Retry Count" := 2;
        QueueRow.Modify();

        // [GIVEN] The store now posts returns automatically, and an after-posting step fails on a programming bug once the credit memo is committed
        ShopifyStore.Get(StoreCode);
        ShopifyStore."Post Returns Automatically" := true;
        ShopifyStore.Modify();
        Commit();
        BindSubscription(FailAfterPost);

        // [WHEN] The job processes the row while Sentry payloads are captured
        SentryCapture.Start();
        Claimed := SpfyLegacyReturnProcessJQ.ProcessRow(QueueRow);
        SentryCapture.Stop();

        // [THEN] The row is Imported with its credit memo, no error and a reset retry count
        UnbindSubscription(FailAfterPost);
        _Assert.IsTrue(Claimed, 'The row must be claimed for the attempt.');
        QueueRow.FindSourceDoc(StoreCode, QueueRow."Source Doc. Type"::Return, '1179');
        _Assert.AreEqual(QueueRow.Status::Imported, QueueRow.Status, 'A posted return must end Imported: ' + QueueRow."Last Error");
        _Assert.AreNotEqual('', QueueRow."Posted Doc. No.", 'The credit memo must be recorded.');
        _Assert.AreEqual('', QueueRow."Last Error", 'A posted return must carry no error.');
        _Assert.AreEqual(0, QueueRow."Retry Count", 'A posted return starts with a reset retry count.');

        // [THEN] The failure after the posting is reported to Sentry for the return
        _Assert.IsTrue(SentryCapture.Contains('1179'), 'A programming bug after the posting must still reach Sentry.');
    end;
}

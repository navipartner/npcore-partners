codeunit 85484 "NPR Library Spfy Legacy Return"
{
    Access = Internal;

    procedure SetupLegacyReturnStore(var StoreCode: Code[20]; var Sku: Code[20]; var CustomerNo: Code[20]; var LocationCode: Code[10])
    var
        Customer: Record Customer;
        Item: Record Item;
        Location: Record Location;
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SpfyStore: Record "NPR Spfy Store";
        NpEcStore: Record "NPR NpEc Store";
        SpfyIntegrationSetup: Record "NPR Spfy Integration Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        StoreCodeTok: Label 'SPFYLRSTORE', Locked = true;
        EcStoreCodeTok: Label 'SPFYLREC', Locked = true;
        LocationCodeTok: Label 'SPFYLRLOC', Locked = true;
        ShopifyLocationIdTok: Label '71001', Locked = true;
        SalespersonTok: Label 'SPFYLRSP', Locked = true;
    begin
        StoreCode := CopyStr(StoreCodeTok, 1, MaxStrLen(StoreCode));
        LocationCode := CopyStr(LocationCodeTok, 1, MaxStrLen(LocationCode));

        // Once per run: library number series restart at the same number.
        if not _NoSeriesInitialized then begin
            LibrarySales.SetReturnOrderNoSeriesInSetup();
            LibrarySales.SetPostedNoSeriesInSetup();
            _NoSeriesInitialized := true;
        end;
        LibrarySales.SetStockoutWarning(false);
        LibrarySales.SetCreditWarningsToNoWarnings();

        if not SpfyIntegrationSetup.Get() then begin
            SpfyIntegrationSetup.Init();
            SpfyIntegrationSetup.Insert();
        end;
        SpfyIntegrationSetup."Enable Integration" := true;
        if SpfyIntegrationSetup."Shopify Api Version" = '' then
            SpfyIntegrationSetup."Shopify Api Version" := '2026-04';
        if SpfyIntegrationSetup."Max Doc Process Retry Count" = 0 then
            SpfyIntegrationSetup."Max Doc Process Retry Count" := 3;
        SpfyIntegrationSetup.Modify();

        if not SalespersonPurchaser.Get(SalespersonTok) then begin
            SalespersonPurchaser.Init();
            SalespersonPurchaser.Code := CopyStr(SalespersonTok, 1, MaxStrLen(SalespersonPurchaser.Code));
            SalespersonPurchaser.Insert();
        end;

        LibrarySales.CreateCustomer(Customer);
        Customer."E-Mail" := 'anna@npretail.test';
        Customer.Modify();
        CustomerNo := Customer."No.";

        LibraryInventory.CreateItem(Item);
        Sku := Item."No.";

        if not Location.Get(LocationCode) then begin
            Location.Init();
            Location.Code := LocationCode;
            Location.Insert();
        end;
        LibraryInventory.UpdateInventoryPostingSetup(Location);

        if not SpfyStore.Get(StoreCode) then begin
            SpfyStore.Init();
            SpfyStore.Code := StoreCode;
            SpfyStore.Insert();
        end;
        SpfyStore.Enabled := true;
        SpfyStore."Shopify Url" := 'https://npr-test.myshopify.com';
        SpfyStore."Sales Return Order Integration" := true;
        SpfyStore."Get Returns Starting From" := CreateDateTime(20260101D, 0T);
        SpfyStore."Get Refunds Starting From" := 0DT;
        SpfyStore."Return Poll Lookback (Days)" := 30;
        SpfyStore."Post Returns Automatically" := true;
        SpfyStore."Currency Blank for LCY" := true;
        SpfyStore."Return Refund G/L Account No." := CreateSalesGLAccountNo(Item);
        SpfyStore."Ret. Gift Card Refund G/L Acc." := CreateSalesGLAccountNo(Item);
        SpfyStore."Ret. Shipping Refund G/L Acc." := CreateSalesGLAccountNo(Item);
        SpfyStore."Return Fee G/L Account No." := CreateSalesGLAccountNo(Item);
        SpfyStore."Refund Discrepancy G/L Acc." := CreateSalesGLAccountNo(Item);
        SpfyStore.Modify();

        if not NpEcStore.Get(EcStoreCodeTok) then begin
            NpEcStore.Init();
            NpEcStore.Code := CopyStr(EcStoreCodeTok, 1, MaxStrLen(NpEcStore.Code));
            NpEcStore.Insert();
        end;
        NpEcStore."Salesperson/Purchaser Code" := CopyStr(SalespersonTok, 1, MaxStrLen(NpEcStore."Salesperson/Purchaser Code"));
        NpEcStore."Shopify Store Code" := StoreCode;
        NpEcStore."Shopify Source Name" := 'web';
        NpEcStore."Spfy Customer No." := CustomerNo;
        NpEcStore."Allow Create Customers" := false;
        // Map by Customer No.: the e-mail lookup could match another test's customer.
        NpEcStore."Customer Mapping" := NpEcStore."Customer Mapping"::"Customer No.";
        NpEcStore.Validate(LocationCode, LocationCode);
        NpEcStore.Modify();

        CreateLocationLink(StoreCode, LocationCode, CopyStr(ShopifyLocationIdTok, 1, 30));
        SpfyIntegrationMgt.SetRereadSetup();
    end;

    local procedure CreateSalesGLAccountNo(Item: Record Item): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        // The library account has no product posting groups; use the item's.
        GLAccount.Get(_LibraryERM.CreateGLAccountNoWithDirectPosting());
        GLAccount."Gen. Posting Type" := GLAccount."Gen. Posting Type"::Sale;
        GLAccount."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
        GLAccount."VAT Prod. Posting Group" := Item."VAT Prod. Posting Group";
        GLAccount.Modify();
        exit(GLAccount."No.");
    end;

    /// <summary>
    /// The gift card share the settlement row of the queue row's return records, 0 without a row.
    /// </summary>
    procedure SettledGiftCardAmount(QueueRow: Record "NPR Spfy NC Return Queue"): Decimal
    var
        Settlement: Record "NPR Spfy Refund Settlement";
    begin
        if Settlement.Get(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID") then
            exit(Settlement."Gift Card Refund Amount");
        exit(0);
    end;

    procedure SettledVoucherNo(QueueRow: Record "NPR Spfy NC Return Queue"): Code[20]
    var
        Settlement: Record "NPR Spfy Refund Settlement";
    begin
        if Settlement.Get(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID") then
            exit(Settlement."Voucher No.");
        exit('');
    end;

    procedure SettlementExists(QueueRow: Record "NPR Spfy NC Return Queue"): Boolean
    var
        Settlement: Record "NPR Spfy Refund Settlement";
    begin
        exit(Settlement.Get(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID"));
    end;

    procedure SetSettlement(QueueRow: Record "NPR Spfy NC Return Queue"; GiftCardAmount: Decimal; VoucherNo: Code[20])
    var
        Settlement: Record "NPR Spfy Refund Settlement";
    begin
        if not Settlement.Get(QueueRow."Shopify Store Code", QueueRow."Source Doc. Type", QueueRow."Source Doc. ID") then begin
            Settlement.Init();
            Settlement."Shopify Store Code" := QueueRow."Shopify Store Code";
            Settlement."Source Doc. Type" := QueueRow."Source Doc. Type";
            Settlement."Shopify Id" := QueueRow."Source Doc. ID";
            Settlement.Insert();
        end;
        Settlement."Return Order No." := QueueRow."Sales Header Doc. No.";
        Settlement."Gift Card Refund Amount" := GiftCardAmount;
        Settlement."Voucher No." := VoucherNo;
        Settlement.Modify();
    end;

    procedure DeleteSettlement(StoreCode: Code[20]; ShopifyId: Text[30])
    var
        Settlement: Record "NPR Spfy Refund Settlement";
    begin
        Settlement.SetRange("Shopify Store Code", StoreCode);
        Settlement.SetRange("Shopify Id", ShopifyId);
        Settlement.DeleteAll();
    end;

    procedure GetStore(StoreCode: Code[20]; var ShopifyStore: Record "NPR Spfy Store")
    begin
        ShopifyStore.Get(StoreCode);
    end;

    procedure CreateLocationLink(StoreCode: Code[20]; LocationCode: Code[10]; ShopifyLocationId: Text[30])
    var
        Location: Record Location;
        StoreLocationLink: Record "NPR Spfy Store-Location Link";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        if not Location.Get(LocationCode) then begin
            Location.Init();
            Location.Code := LocationCode;
            Location.Insert();
        end;
        StoreLocationLink.SetRange("Location Code", LocationCode);
        StoreLocationLink.SetRange("Shopify Store Code", StoreCode);
        if not StoreLocationLink.FindFirst() then begin
            StoreLocationLink.Init();
            StoreLocationLink."Location Code" := LocationCode;
            StoreLocationLink."Shopify Store Code" := StoreCode;
            StoreLocationLink."Line No." := 10000;
            StoreLocationLink.Insert();
        end;
        SpfyAssignedIDMgt.AssignShopifyID(StoreLocationLink.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyLocationId, false);
    end;

    procedure ReturnListResponse(OrderGid: Text; OrderName: Text; ReturnGid: Text; ReturnName: Text): Text
    begin
        exit(ReturnListResponse(OrderGid, OrderName, ReturnGid, ReturnName, '2026-09-20T10:00:00Z'));
    end;

    procedure ReturnListResponse(OrderGid: Text; OrderName: Text; ReturnGid: Text; ReturnName: Text; ClosedAt: Text): Text
    var
        ReturnListTok: Label '{"data":{"orders":{"edges":[{"node":{"id":"%1","updatedAt":"2026-09-20T10:00:00Z","returns":{"edges":[{"node":{"id":"%3","name":"%4","status":"CLOSED","createdAt":"2026-09-19T09:00:00Z","closedAt":"%5"}}],"pageInfo":{"endCursor":null,"hasNextPage":false}}}}],"pageInfo":{"endCursor":null,"hasNextPage":false}}}}', Locked = true;
    begin
        exit(StrSubstNo(ReturnListTok, OrderGid, OrderName, ReturnGid, ReturnName, ClosedAt));
    end;

    procedure ReturnListResponseWithMoreReturns(OrderGid: Text; ReturnGid: Text): Text
    var
        ReturnListMoreReturnsTok: Label '{"data":{"orders":{"edges":[{"node":{"id":"%1","updatedAt":"2026-09-20T10:00:00Z","returns":{"edges":[{"node":{"id":"%2","name":"#R1","status":"CLOSED","createdAt":"2026-09-19T09:00:00Z","closedAt":"2026-09-20T10:00:00Z"}}],"pageInfo":{"endCursor":"CURSOR1","hasNextPage":true}}}}],"pageInfo":{"endCursor":null,"hasNextPage":false}}}}', Locked = true;
    begin
        exit(StrSubstNo(ReturnListMoreReturnsTok, OrderGid, ReturnGid));
    end;

    procedure OrderReturnsResponseNeverEnding(ReturnGid: Text): Text
    var
        OrderReturnsNeverEndingTok: Label '{"data":{"order":{"returns":{"edges":[{"node":{"id":"%1","name":"#R1","status":"CLOSED","createdAt":"2026-09-19T09:00:00Z","closedAt":"2026-09-20T10:00:00Z"}}],"pageInfo":{"endCursor":"CURSOR1","hasNextPage":true}}}}}', Locked = true;
    begin
        exit(StrSubstNo(OrderReturnsNeverEndingTok, ReturnGid));
    end;

    /// <summary>
    /// A return of two order lines of the same SKU, each with its own return line, disposition and refund line, built from the single-line response.
    /// </summary>
    procedure ReturnDetailResponseTwoLines(ReturnId: Text; OrderId: Text; OrderName: Text; Sku: Text; LineItemId1: Text; Qty1: Integer; NetAmount1: Decimal; TaxAmount1: Decimal; LineItemId2: Text; Qty2: Integer; NetAmount2: Decimal; TaxAmount2: Decimal; VatRate: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text): Text
    var
        Assert: Codeunit Assert;
        Response: Text;
        ReturnLinesTail: Text;
        DispositionsTail: Text;
        RefundLinesTail: Text;
        SecondReturnLine: Text;
        SecondDisposition: Text;
        SecondRefundLine: Text;
    begin
        Response := ReturnDetailResponse(ReturnId, OrderId, OrderName, Sku, LineItemId1, Qty1, NetAmount1, TaxAmount1, VatRate, LocationId, TransactionsJson, Currency);
        ReturnLinesTail := '"barcode":null}}}}}]},"reverseFulfillmentOrders"';
        DispositionsTail := '}]}}]}}}]},"refunds"';
        RefundLinesTail := '}]}}}]},"refundShippingLines"';
        Assert.IsTrue(StrPos(Response, ReturnLinesTail) > 0, 'Fixture: the return lines tail must exist.');
        Assert.IsTrue(StrPos(Response, DispositionsTail) > 0, 'Fixture: the dispositions tail must exist.');
        Assert.IsTrue(StrPos(Response, RefundLinesTail) > 0, 'Fixture: the refund lines tail must exist.');
        SecondReturnLine := '{"node":{"id":"gid://shopify/ReturnLineItem/2","quantity":' + Format(Qty2, 0, 9) + ',"restockingFee":null,"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/82","lineItem":{"id":"gid://shopify/LineItem/' + LineItemId2 + '","sku":"' + Sku + '","title":"Test jacket","variant":{"id":"gid://shopify/ProductVariant/1","sku":"' + Sku + '","barcode":null}}}}}';
        SecondDisposition := '{"node":{"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/82"},"dispositions":[{"type":"RESTOCKED","location":{"id":"gid://shopify/Location/' + LocationId + '"},"quantity":' + Format(Qty2, 0, 9) + '}]}}';
        SecondRefundLine := '{"node":{"quantity":' + Format(Qty2, 0, 9) + ',"subtotalSet":{"presentmentMoney":{"amount":"' + Format(NetAmount2, 0, 9) + '"}},"totalTaxSet":{"presentmentMoney":{"amount":"' + Format(TaxAmount2, 0, 9) + '"}},"lineItem":{"id":"gid://shopify/LineItem/' + LineItemId2 + '","taxLines":[{"ratePercentage":' + Format(VatRate, 0, 9) + '}]}}}';
        Response := Response.Replace(ReturnLinesTail, '"barcode":null}}}}},' + SecondReturnLine + ']},"reverseFulfillmentOrders"');
        Response := Response.Replace(DispositionsTail, '}]}},' + SecondDisposition + ']}}}]},"refunds"');
        Response := Response.Replace(RefundLinesTail, '}]}}},' + SecondRefundLine + ']},"refundShippingLines"');
        exit(Response);
    end;

    procedure ReturnDetailResponse(ReturnId: Text; OrderId: Text; OrderName: Text; Sku: Text; LineItemId: Text; Qty: Integer; NetAmount: Decimal; TaxAmount: Decimal; VatRate: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text): Text
    begin
        exit(ReturnDetailResponse(ReturnId, OrderId, OrderName, Sku, LineItemId, Qty, NetAmount, TaxAmount, VatRate, LocationId, TransactionsJson, Currency, StrSubstNo(_SingleRestockedDispositionTok, LocationId, Qty)));
    end;

    procedure ReturnDetailResponse(ReturnId: Text; OrderId: Text; OrderName: Text; Sku: Text; LineItemId: Text; Qty: Integer; NetAmount: Decimal; TaxAmount: Decimal; VatRate: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text; DispositionsJson: Text): Text
    begin
        exit(ReturnDetailResponse(ReturnId, OrderId, OrderName, Sku, LineItemId, Qty, NetAmount, TaxAmount, VatRate, LocationId, TransactionsJson, Currency, DispositionsJson, '[]', ''));
    end;

    procedure ReturnDetailResponse(ReturnId: Text; OrderId: Text; OrderName: Text; Sku: Text; LineItemId: Text; Qty: Integer; NetAmount: Decimal; TaxAmount: Decimal; VatRate: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text; DispositionsJson: Text; ReturnShippingFeesJson: Text; RefundShippingLinesJson: Text): Text
    begin
        exit(ReturnDetailResponse(ReturnId, OrderId, OrderName, Sku, LineItemId, Qty, NetAmount, TaxAmount, VatRate, LocationId, TransactionsJson, Currency, DispositionsJson, ReturnShippingFeesJson, RefundShippingLinesJson, ''));
    end;

    procedure ReturnDetailResponse(ReturnId: Text; OrderId: Text; OrderName: Text; Sku: Text; LineItemId: Text; Qty: Integer; NetAmount: Decimal; TaxAmount: Decimal; VatRate: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text; DispositionsJson: Text; ReturnShippingFeesJson: Text; RefundShippingLinesJson: Text; OrderAdjustmentsJson: Text): Text
    var
        ReturnDetailTok: Label '{"data":{"return":{"id":"gid://shopify/Return/%1","name":"%3-R1","status":"CLOSED","closedAt":"2026-09-20T10:00:00Z","exchangeLineItems":{"edges":[]},"order":{"id":"gid://shopify/Order/%2","name":"%3","number":9001,"email":"anna@npretail.test","phone":null,"sourceName":"web","taxesIncluded":false,"currencyCode":"%12","presentmentCurrencyCode":"%12","customer":{"id":"gid://shopify/Customer/501","firstName":"Anna","lastName":"Test","defaultEmailAddress":{"emailAddress":"anna@npretail.test"},"defaultPhoneNumber":null,"defaultAddress":{"phone":null}},"billingAddress":{"firstName":"Anna","lastName":"Test","company":null,"countryCodeV2":"DK","zip":"2100","address1":"Testvej 1","address2":null,"city":"Copenhagen"},"shippingAddress":{"firstName":"Anna","lastName":"Test","company":null,"address1":"Testvej 1","address2":null,"zip":"2100","city":"Copenhagen","countryCodeV2":"DK","phone":null}},"returnShippingFees":%14,"returnLineItems":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"id":"gid://shopify/ReturnLineItem/1","quantity":%6,"restockingFee":null,"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/81","lineItem":{"id":"gid://shopify/LineItem/%5","sku":"%4","title":"Test jacket","variant":{"id":"gid://shopify/ProductVariant/1","sku":"%4","barcode":null}}}}}]},"reverseFulfillmentOrders":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"lineItems":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/81"},"dispositions":%13}}]}}}]},"refunds":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"id":"gid://shopify/Refund/1","transactions":{"pageInfo":{"hasNextPage":false},"edges":[%11]},"refundLineItems":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"quantity":%6,"subtotalSet":{"presentmentMoney":{"amount":"%7"}},"totalTaxSet":{"presentmentMoney":{"amount":"%8"}},"lineItem":{"id":"gid://shopify/LineItem/%5","taxLines":[{"ratePercentage":%9}]}}}]},"refundShippingLines":{"pageInfo":{"hasNextPage":false},"edges":[%15]},"orderAdjustments":{"pageInfo":{"hasNextPage":false},"edges":[%16]}}}]}}}}', Locked = true;
    begin
        exit(StrSubstNo(ReturnDetailTok, ReturnId, OrderId, OrderName, Sku, LineItemId, Qty, Format(NetAmount, 0, 9), Format(TaxAmount, 0, 9), Format(VatRate, 0, 9), LocationId, TransactionsJson, Currency, DispositionsJson, ReturnShippingFeesJson, RefundShippingLinesJson, OrderAdjustmentsJson));
    end;

    /// <summary>
    /// One order adjustment edge as Shopify reports it: a positive amount is withheld from the customer, a negative one is paid beyond the lines.
    /// </summary>
    procedure OrderAdjustmentJson(Amount: Decimal; TaxAmount: Decimal; Reason: Text): Text
    var
        OrderAdjustmentTok: Label '{"node":{"amountSet":{"presentmentMoney":{"amount":"%1"}},"taxAmountSet":{"presentmentMoney":{"amount":"%2"}},"reason":"%3"}}', Locked = true;
    begin
        exit(StrSubstNo(OrderAdjustmentTok, Format(Amount, 0, 9), Format(TaxAmount, 0, 9), Reason));
    end;

    /// <summary>
    /// Strips every refund line from a return detail response, as Shopify reports a refund that names no line.
    /// </summary>
    procedure WithoutRefundLines(ReturnDetailJson: Text): Text
    var
        StartMarker: Text;
        StartPos: Integer;
        EndPos: Integer;
    begin
        StartMarker := '"refundLineItems":{"pageInfo":{"hasNextPage":false},"edges":[';
        StartPos := StrPos(ReturnDetailJson, StartMarker);
        if StartPos = 0 then
            exit(ReturnDetailJson);
        EndPos := StrPos(CopyStr(ReturnDetailJson, StartPos), ']},"refundShippingLines"');
        exit(CopyStr(ReturnDetailJson, 1, StartPos + StrLen(StartMarker) - 1) + CopyStr(ReturnDetailJson, StartPos + EndPos - 1));
    end;

    /// <summary>
    /// Adds a top-up entry to a voucher, as a later sale of value onto the same card would.
    /// </summary>
    procedure TopUpVoucherAmount(VoucherNo: Code[20]; Amount: Decimal)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        Voucher.Get(VoucherNo);
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := VoucherNo;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::"Top-up";
        VoucherEntry.Amount := Amount;
        VoucherEntry."Remaining Amount" := Amount;
        VoucherEntry.Positive := true;
        VoucherEntry.Open := true;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
    end;

    /// <summary>
    /// Removes a voucher and its entries, as if it had been deleted by hand after a draft was built.
    /// </summary>
    procedure DeleteVoucher(VoucherNo: Code[20])
    begin
        RemoveVoucherTraces(VoucherNo);
    end;

    /// <summary>
    /// Mock return of one order line shipped in ParcelCount parcels, one return line per parcel, refunded in one refund line.
    /// </summary>
    procedure ReturnDetailResponseParcels(ReturnId: Text; OrderId: Text; OrderName: Text; Sku: Text; LineItemId: Text; ParcelCount: Integer; NetAmount: Decimal; TaxAmount: Decimal; VatRate: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text): Text
    var
        ReturnLineEdges: Text;
        ReverseLineEdges: Text;
        Parcel: Integer;
    begin
        for Parcel := 1 to ParcelCount do begin
            if Parcel > 1 then begin
                ReturnLineEdges += ',';
                ReverseLineEdges += ',';
            end;
            ReturnLineEdges += StrSubstNo(_ParcelReturnLineEdgeTok, Parcel, 80 + Parcel, LineItemId, Sku);
            ReverseLineEdges += StrSubstNo(_ParcelReverseLineEdgeTok, 80 + Parcel, LocationId);
        end;
        exit(StrSubstNo(_ReturnDetailParcelsTok, ReturnId, OrderId, OrderName, LineItemId, Format(NetAmount, 0, 9), Format(TaxAmount, 0, 9), Format(VatRate, 0, 9), TransactionsJson, Currency, ReturnLineEdges, ReverseLineEdges, ParcelCount));
    end;

    procedure SingleRestockedDispositionJson(LocationId: Text; Qty: Integer): Text
    begin
        exit(StrSubstNo(_SingleRestockedDispositionTok, LocationId, Qty));
    end;

    procedure ReturnShippingFeeJson(Amount: Decimal): Text
    var
        ReturnShippingFeeTok: Label '[{"amountSet":{"presentmentMoney":{"amount":"%1"}}}]', Locked = true;
    begin
        exit(StrSubstNo(ReturnShippingFeeTok, Format(Amount, 0, 9)));
    end;

    procedure RefundShippingLineJson(SubtotalAmount: Decimal; TaxAmount: Decimal): Text
    var
        RefundShippingLineTok: Label '{"node":{"subtotalAmountSet":{"presentmentMoney":{"amount":"%1"}},"taxAmountSet":{"presentmentMoney":{"amount":"%2"}}}}', Locked = true;
    begin
        exit(StrSubstNo(RefundShippingLineTok, Format(SubtotalAmount, 0, 9), Format(TaxAmount, 0, 9)));
    end;

    procedure CreateVoucherWithGiftCardId(VoucherNo: Code[20]; StoreCode: Code[20]; GiftCardId: Text[30]; var Voucher: Record "NPR NpRv Voucher")
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        _LibrarySpfyVoucher.CreateVoucherType(CopyStr(_VoucherTypeTok, 1, 20), StoreCode, VoucherType);
        if not Voucher.Get(VoucherNo) then
            _LibrarySpfyVoucher.CreateVoucher(VoucherNo, VoucherType.Code, 'SPFYLRREF' + VoucherNo, 100, Voucher);
        SpfyAssignedIDMgt.AssignShopifyID(Voucher.RecordId(), "NPR Spfy ID Type"::"Entry ID", GiftCardId, false);
    end;

    procedure RunImport(var QueueRow: Record "NPR Spfy NC Return Queue"; var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"): Boolean
    var
        SpfyLegacyReturnImport: Codeunit "NPR Spfy Legacy Return Import";
    begin
        Commit();
        ClearLastError();
        SpfyLegacyReturnImport.SetGraphQLClient(MockClient);
        exit(SpfyLegacyReturnImport.Run(QueueRow));
    end;

    /// <summary>
    /// Builds an unposted draft and unlinks it from the queue row, like a draft the other engine left behind.
    /// </summary>
    procedure BuildUnlinkedDraft(var QueueRow: Record "NPR Spfy NC Return Queue"; ReturnDetailResponse: Text; var SalesHeader: Record "Sales Header")
    var
        ShopifyStore: Record "NPR Spfy Store";
        Assert: Codeunit Assert;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        PostAutomatically: Boolean;
    begin
        ShopifyStore.Get(QueueRow."Shopify Store Code");
        PostAutomatically := ShopifyStore."Post Returns Automatically";
        ShopifyStore."Post Returns Automatically" := false;
        ShopifyStore.Modify();
        MockClient.AddResponse('GetReturn', ReturnDetailResponse);
        Assert.IsTrue(RunImport(QueueRow, MockClient), 'The draft must build: ' + GetLastErrorText());
        QueueRow.Find();
        SalesHeader.Get(SalesHeader."Document Type"::"Return Order", QueueRow."Sales Header Doc. No.");
        QueueRow."Sales Header Doc. No." := '';
        QueueRow.Modify();
        ShopifyStore.Find();
        ShopifyStore."Post Returns Automatically" := PostAutomatically;
        ShopifyStore.Modify();
        Commit();
    end;

    /// <summary>
    /// The company's local currency, which the fixtures send as the Shopify currency so that amounts post unconverted on any company.
    /// </summary>
    procedure Lcy(): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" = '' then begin
            GeneralLedgerSetup."LCY Code" := 'DKK';
            GeneralLedgerSetup.Modify();
        end;
        exit(GeneralLedgerSetup."LCY Code");
    end;

    procedure GetCreditMemoForReturnOrder(ReturnOrderNo: Code[20]; var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        SalesCrMemoHeader.SetRange("Return Order No.", ReturnOrderNo);
        SalesCrMemoHeader.FindFirst();
    end;

    procedure CreateDirectPostingGLAccount(): Code[20]
    begin
        exit(_LibraryERM.CreateGLAccountNoWithDirectPosting());
    end;

    /// <summary>
    /// A posted invoice of the Shopify order carrying the order id and the store code, with no payment lines.
    /// </summary>
    procedure InsertPostedInvoiceWithOrderIds(InvoiceNo: Code[20]; StoreCode: Code[20]; OrderId: Text[30])
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        PaymentLine: Record "NPR Magento Payment Line";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        if not SalesInvoiceHeader.Get(InvoiceNo) then begin
            SalesInvoiceHeader.Init();
            SalesInvoiceHeader."No." := InvoiceNo;
            SalesInvoiceHeader.Insert();
        end;
        SpfyAssignedIDMgt.AssignShopifyID(SalesInvoiceHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesInvoiceHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", InvoiceNo);
        PaymentLine.DeleteAll();
    end;

    procedure InsertPostedInvoiceWithVoucherPayment(InvoiceNo: Code[20]; StoreCode: Code[20]; OrderId: Text[30]; VoucherNo: Code[20])
    begin
        InsertPostedInvoiceWithVoucherPayment(InvoiceNo, StoreCode, OrderId, VoucherNo, 100);
    end;

    /// <summary>
    /// A posted invoice of the Shopify order paid with the voucher for the amount, as the order import posts a gift card payment.
    /// </summary>
    procedure InsertPostedInvoiceWithVoucherPayment(InvoiceNo: Code[20]; StoreCode: Code[20]; OrderId: Text[30]; VoucherNo: Code[20]; Amount: Decimal)
    begin
        InsertPostedInvoiceWithOrderIds(InvoiceNo, StoreCode, OrderId);
        AddVoucherPaymentToPostedInvoice(InvoiceNo, VoucherNo, Amount);
    end;

    procedure AddVoucherPaymentToPostedInvoice(InvoiceNo: Code[20]; VoucherNo: Code[20]; Amount: Decimal)
    var
        PaymentLine: Record "NPR Magento Payment Line";
        LineNo: Integer;
    begin
        PaymentLine.SetRange("Document Table No.", Database::"Sales Invoice Header");
        PaymentLine.SetRange("Document No.", InvoiceNo);
        if PaymentLine.FindLast() then
            LineNo := PaymentLine."Line No.";
        PaymentLine.Init();
        PaymentLine."Document Table No." := Database::"Sales Invoice Header";
        PaymentLine."Document Type" := Enum::"Sales Document Type".FromInteger(0);
        PaymentLine."Document No." := InvoiceNo;
        PaymentLine."Line No." := LineNo + 10000;
        PaymentLine."Payment Type" := PaymentLine."Payment Type"::Voucher;
        PaymentLine."Source No." := VoucherNo;
        PaymentLine.Amount := Amount;
        PaymentLine.Insert();
    end;

    procedure MixedDispositionsJson(RestockedLocationId: Text; RejectedLocationId: Text): Text
    var
        MixedDispositionsTok: Label '[{"type":"RESTOCKED","location":{"id":"gid://shopify/Location/%1"},"quantity":1},{"type":"REJECTED","location":{"id":"gid://shopify/Location/%2"},"quantity":1}]', Locked = true;
    begin
        exit(StrSubstNo(MixedDispositionsTok, RestockedLocationId, RejectedLocationId));
    end;

    /// <summary>
    /// Removes every queue row that is not Imported, so a test that runs the whole queue starts from its own rows only.
    /// </summary>
    procedure DeleteUnfinishedQueueRows()
    var
        QueueRow: Record "NPR Spfy NC Return Queue";
    begin
        QueueRow.SetFilter(Status, '<>%1', QueueRow.Status::Imported);
        QueueRow.DeleteAll();
    end;

    procedure InsertQueueRow(StoreCode: Code[20]; ReturnId: Text[30]; OrderId: Text[30]; var QueueRow: Record "NPR Spfy NC Return Queue")
    begin
        InsertQueueRow(StoreCode, QueueRow."Source Doc. Type"::Return, ReturnId, OrderId, '#' + OrderId + '-R1', QueueRow);
    end;

    /// <summary>
    /// A New queue row for a Shopify return or refund, replacing one left by an earlier run together with its draft.
    /// </summary>
    procedure InsertQueueRow(StoreCode: Code[20]; SourceDocType: Enum "NPR Spfy Legacy Return Source"; ShopifyId: Text[30]; OrderId: Text[30]; SourceDocName: Text; var QueueRow: Record "NPR Spfy NC Return Queue")
    var
        SalesHeader: Record "Sales Header";
        SpfyLegacyReturnMgt: Codeunit "NPR Spfy Legacy Return Mgt.";
        Attempts: Integer;
    begin
        if QueueRow.FindSourceDoc(StoreCode, SourceDocType, ShopifyId) then
            QueueRow.Delete();
        // A draft left by an earlier run would be adopted instead of built; remove it so the test exercises the build.
        while SpfyLegacyReturnMgt.FindDraftForReturn(StoreCode, SourceDocType, ShopifyId, SalesHeader) and (Attempts < 5) do begin
            SalesHeader.Delete(true);
            Attempts += 1;
        end;
        QueueRow.Init();
        QueueRow."Entry No." := 0;
        QueueRow."Shopify Store Code" := StoreCode;
        QueueRow."Source Doc. Type" := SourceDocType;
        QueueRow."Source Doc. ID" := ShopifyId;
        QueueRow."Order Id" := OrderId;
        QueueRow."Source Doc. Name" := CopyStr(SourceDocName, 1, MaxStrLen(QueueRow."Source Doc. Name"));
        QueueRow.Status := QueueRow.Status::New;
        QueueRow.Insert(true);
    end;

    procedure InsertPostedCrMemoWithReturnIds(CrMemoNo: Code[20]; StoreCode: Code[20]; ReturnId: Text[30])
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        if not SalesCrMemoHeader.Get(CrMemoNo) then begin
            SalesCrMemoHeader.Init();
            SalesCrMemoHeader."No." := CrMemoNo;
            SalesCrMemoHeader.Insert();
        end;
        SpfyAssignedIDMgt.AssignShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", ReturnId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesCrMemoHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    procedure InsertReturnOrderWithReturnIds(DocumentNo: Code[20]; StoreCode: Code[20]; ReturnId: Text[30]; var SalesHeader: Record "Sales Header")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        if SalesHeader.Get(SalesHeader."Document Type"::"Return Order", DocumentNo) then
            SalesHeader.Delete(true);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Return Order";
        SalesHeader."No." := DocumentNo;
        SalesHeader.Insert();
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", ReturnId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    /// <summary>
    /// A sales G/L account with the posting groups of the store's item, for gift card sales lines.
    /// </summary>
    procedure CreateSalesGLAccountNo(Sku: Code[20]): Code[20]
    var
        Item: Record Item;
    begin
        Item.Get(Sku);
        exit(CreateSalesGLAccountNo(Item));
    end;

    /// <summary>
    /// Inserts a posted NP gift card sale as the order import leaves it: one G/L line carrying the Shopify line id and one untouched voucher per unit.
    /// </summary>
    procedure InsertPostedGiftCardSale(InvoiceNo: Code[20]; StoreCode: Code[20]; OrderId: Text[30]; LineItemId: Text[30]; GLAccountNo: Code[20]; Qty: Integer; UnitPrice: Decimal; var VoucherNos: List of [Code[20]])
    var
        GLAccount: Record "G/L Account";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        VoucherType: Record "NPR NpRv Voucher Type";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
        VoucherNo: Code[20];
        i: Integer;
    begin
        Clear(VoucherNos);
        _LibrarySpfyVoucher.CreateVoucherType(CopyStr(_VoucherTypeTok, 1, 20), StoreCode, VoucherType);
        VoucherType."Account No." := GLAccountNo;
        VoucherType."Allow Top-up" := true;
        VoucherType.Modify();

        if SalesInvoiceHeader.Get(InvoiceNo) then begin
            SalesInvoiceLine.SetRange("Document No.", InvoiceNo);
            SalesInvoiceLine.DeleteAll();
            SalesInvoiceHeader.Delete();
        end;
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := InvoiceNo;
        SalesInvoiceHeader."Prices Including VAT" := true;
        SalesInvoiceHeader.Insert();
        SpfyAssignedIDMgt.AssignShopifyID(SalesInvoiceHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", OrderId, false);
        SpfyAssignedIDMgt.AssignShopifyID(SalesInvoiceHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);

        GLAccount.Get(GLAccountNo);
        SalesInvoiceLine.Init();
        SalesInvoiceLine."Document No." := InvoiceNo;
        SalesInvoiceLine."Line No." := 10000;
        SalesInvoiceLine.Type := SalesInvoiceLine.Type::"G/L Account";
        SalesInvoiceLine."No." := GLAccountNo;
        SalesInvoiceLine.Description := 'NP Gift Card';
        SalesInvoiceLine.Quantity := Qty;
        SalesInvoiceLine."Unit Price" := UnitPrice;
        SalesInvoiceLine.Amount := Qty * UnitPrice;
        SalesInvoiceLine."Amount Including VAT" := Qty * UnitPrice;
        SalesInvoiceLine."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
        SalesInvoiceLine."VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
        SalesInvoiceLine.Insert();
        SpfyAssignedIDMgt.AssignShopifyID(SalesInvoiceLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", LineItemId, false);

        for i := 1 to Qty do begin
            VoucherNo := CopyStr(StrSubstNo('%1-%2', InvoiceNo, i), 1, MaxStrLen(VoucherNo));
            RemoveVoucherTraces(VoucherNo);
            _LibrarySpfyVoucher.CreateVoucher(VoucherNo, VoucherType.Code, CopyStr('SPFYLRGC' + DelChr(VoucherNo, '=', '-'), 1, 50), UnitPrice, Voucher);
            Voucher."Allow Top-up" := true;
            Voucher.Modify();
            VoucherEntry.SetRange("Voucher No.", VoucherNo);
            VoucherEntry.FindFirst();
            VoucherEntry."Document Type" := VoucherEntry."Document Type"::Invoice;
            VoucherEntry."Document No." := InvoiceNo;
            VoucherEntry."Document Line No." := SalesInvoiceLine."Line No.";
            VoucherEntry.Modify();
            VoucherNos.Add(VoucherNo);
        end;
    end;

    local procedure RemoveVoucherTraces(VoucherNo: Code[20])
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
        ArchVoucher: Record "NPR NpRv Arch. Voucher";
        ArchVoucherEntry: Record "NPR NpRv Arch. Voucher Entry";
    begin
        VoucherEntry.SetRange("Voucher No.", VoucherNo);
        VoucherEntry.DeleteAll();
        if Voucher.Get(VoucherNo) then
            Voucher.Delete();
        if ArchVoucher.Get(VoucherNo) then begin
            ArchVoucherEntry.SetRange("Arch. Voucher No.", VoucherNo);
            ArchVoucherEntry.DeleteAll();
            ArchVoucher.Delete();
        end;
    end;

    /// <summary>
    /// Reserves Amount of the voucher as an unposted payment line, as an open sale paying with the card does.
    /// </summary>
    procedure ReserveVoucherAmount(VoucherNo: Code[20]; Amount: Decimal)
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
    begin
        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine.Type := NpRvSalesLine.Type::Payment;
        NpRvSalesLine."Voucher No." := VoucherNo;
        NpRvSalesLine.Amount := Amount;
        NpRvSalesLine.Posted := false;
        NpRvSalesLine.Insert();
    end;

    /// <summary>
    /// Spends part of a voucher, as a POS payment would, so it is no longer untouched.
    /// </summary>
    procedure UseVoucherAmount(VoucherNo: Code[20]; Amount: Decimal)
    var
        Voucher: Record "NPR NpRv Voucher";
        VoucherEntry: Record "NPR NpRv Voucher Entry";
    begin
        Voucher.Get(VoucherNo);
        VoucherEntry.Init();
        VoucherEntry."Entry No." := 0;
        VoucherEntry."Voucher No." := VoucherNo;
        VoucherEntry."Voucher Type" := Voucher."Voucher Type";
        VoucherEntry."Entry Type" := VoucherEntry."Entry Type"::Payment;
        VoucherEntry.Amount := -Amount;
        VoucherEntry."Remaining Amount" := -Amount;
        VoucherEntry.Positive := false;
        VoucherEntry.Open := true;
        VoucherEntry."Posting Date" := WorkDate();
        VoucherEntry.Insert();
    end;

    /// <summary>
    /// Mock return of Qty NP gift cards from one order line (property _is_giftcard, no SKU), taxes included, refunded GrossAmount in one refund line.
    /// </summary>
    procedure ReturnDetailResponseGiftCard(ReturnId: Text; OrderId: Text; OrderName: Text; LineItemId: Text; Qty: Integer; GrossAmount: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text): Text
    var
        ReturnDetailGiftCardTok: Label '{"data":{"return":{"id":"gid://shopify/Return/%1","name":"%3-R1","status":"CLOSED","closedAt":"2026-09-20T10:00:00Z","exchangeLineItems":{"edges":[]},"order":{"id":"gid://shopify/Order/%2","name":"%3","number":9001,"email":"anna@npretail.test","phone":null,"sourceName":"web","taxesIncluded":true,"currencyCode":"%8","presentmentCurrencyCode":"%8","customer":{"id":"gid://shopify/Customer/501","firstName":"Anna","lastName":"Test","defaultEmailAddress":{"emailAddress":"anna@npretail.test"},"defaultPhoneNumber":null,"defaultAddress":{"phone":null}},"billingAddress":{"firstName":"Anna","lastName":"Test","company":null,"countryCodeV2":"DK","zip":"2100","address1":"Testvej 1","address2":null,"city":"Copenhagen"},"shippingAddress":{"firstName":"Anna","lastName":"Test","company":null,"address1":"Testvej 1","address2":null,"zip":"2100","city":"Copenhagen","countryCodeV2":"DK","phone":null}},"returnShippingFees":[],"returnLineItems":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"id":"gid://shopify/ReturnLineItem/1","quantity":%5,"restockingFee":null,"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/81","lineItem":{"id":"gid://shopify/LineItem/%4","sku":null,"title":"NP Gift Card","isGiftCard":false,"customAttributes":[{"key":"_is_giftcard","value":"1"},{"key":"_np_voucher_type","value":"np-giftcard"}],"variant":{"id":"gid://shopify/ProductVariant/2","sku":null,"barcode":null}}}}}]},"reverseFulfillmentOrders":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"lineItems":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/81"},"dispositions":[{"type":"RESTOCKED","location":{"id":"gid://shopify/Location/%9"},"quantity":%5}]}}]}}}]},"refunds":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"id":"gid://shopify/Refund/1","transactions":{"pageInfo":{"hasNextPage":false},"edges":[%7]},"refundLineItems":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"quantity":%5,"subtotalSet":{"presentmentMoney":{"amount":"%6"}},"totalTaxSet":{"presentmentMoney":{"amount":"0"}},"lineItem":{"id":"gid://shopify/LineItem/%4","taxLines":[{"ratePercentage":0}]}}}]},"refundShippingLines":{"pageInfo":{"hasNextPage":false},"edges":[]},"orderAdjustments":{"pageInfo":{"hasNextPage":false},"edges":[]}}}]}}}}', Locked = true;
    begin
        exit(StrSubstNo(ReturnDetailGiftCardTok, ReturnId, OrderId, OrderName, LineItemId, Qty, Format(GrossAmount, 0, 9), TransactionsJson, Currency, LocationId));
    end;

    /// <summary>
    /// Mock return of ParcelCount NP gift cards shipped in as many parcels, one return line each, refunded GrossAmount in one tax-exclusive refund line.
    /// </summary>
    procedure ReturnDetailResponseGiftCardParcels(ReturnId: Text; OrderId: Text; OrderName: Text; LineItemId: Text; ParcelCount: Integer; GrossAmount: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text): Text
    var
        ReturnLineEdges: Text;
        ReverseLineEdges: Text;
        Parcel: Integer;
        GiftCardParcelReturnLineEdgeTok: Label '{"node":{"id":"gid://shopify/ReturnLineItem/%1","quantity":1,"restockingFee":null,"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/%2","lineItem":{"id":"gid://shopify/LineItem/%3","sku":null,"title":"NP Gift Card","isGiftCard":false,"customAttributes":[{"key":"_is_giftcard","value":"1"},{"key":"_np_voucher_type","value":"np-giftcard"}],"variant":{"id":"gid://shopify/ProductVariant/2","sku":null,"barcode":null}}}}}', Locked = true;
    begin
        for Parcel := 1 to ParcelCount do begin
            if Parcel > 1 then begin
                ReturnLineEdges += ',';
                ReverseLineEdges += ',';
            end;
            ReturnLineEdges += StrSubstNo(GiftCardParcelReturnLineEdgeTok, Parcel, 80 + Parcel, LineItemId);
            ReverseLineEdges += StrSubstNo(_ParcelReverseLineEdgeTok, 80 + Parcel, LocationId);
        end;
        exit(StrSubstNo(_ReturnDetailParcelsTok, ReturnId, OrderId, OrderName, LineItemId, Format(GrossAmount, 0, 9), '0', '0', TransactionsJson, Currency, ReturnLineEdges, ReverseLineEdges, ParcelCount));
    end;

    /// <summary>
    /// The voucher the first voucher sales line of a Return Order draft references.
    /// </summary>
    procedure ReferencedVoucherNo(ReturnOrderNo: Code[20]): Code[20]
    var
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        NpRvSalesLineRef: Record "NPR NpRv Sales Line Ref.";
    begin
        NpRvSalesLine.SetRange("Document Source", NpRvSalesLine."Document Source"::"Sales Document");
        NpRvSalesLine.SetRange("Document Type", NpRvSalesLine."Document Type"::"Return Order");
        NpRvSalesLine.SetRange("Document No.", ReturnOrderNo);
        NpRvSalesLine.FindFirst();
        NpRvSalesLineRef.SetRange("Sales Line Id", NpRvSalesLine.Id);
        NpRvSalesLineRef.FindFirst();
        exit(NpRvSalesLineRef."Voucher No.");
    end;

    procedure TwoRestockedDispositionsJson(FirstLocationId: Text; SecondLocationId: Text): Text
    var
        TwoRestockedDispositionsTok: Label '[{"type":"RESTOCKED","location":{"id":"gid://shopify/Location/%1"},"quantity":1},{"type":"RESTOCKED","location":{"id":"gid://shopify/Location/%2"},"quantity":1}]', Locked = true;
    begin
        exit(StrSubstNo(TwoRestockedDispositionsTok, FirstLocationId, SecondLocationId));
    end;

    /// <summary>
    /// A return list page whose orders connection always reports another page with the same cursor.
    /// </summary>
    procedure ReturnListResponseNeverEnding(OrderGid: Text; ReturnGid: Text): Text
    var
        ReturnListNeverEndingTok: Label '{"data":{"orders":{"edges":[{"node":{"id":"%1","updatedAt":"2026-09-20T10:00:00Z","returns":{"edges":[{"node":{"id":"%2","name":"#R1","status":"CLOSED","createdAt":"2026-09-19T09:00:00Z","closedAt":"2026-09-20T10:00:00Z"}}],"pageInfo":{"endCursor":null,"hasNextPage":false}}}}],"pageInfo":{"endCursor":"CURSOR1","hasNextPage":true}}}}', Locked = true;
    begin
        exit(StrSubstNo(ReturnListNeverEndingTok, OrderGid, ReturnGid));
    end;

    /// <summary>
    /// A posted return receipt of the given Return Order, carrying no Shopify ids.
    /// </summary>
    procedure InsertPostedReceipt(ReceiptNo: Code[20]; ReturnOrderNo: Code[20])
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
    begin
        if ReturnReceiptHeader.Get(ReceiptNo) then
            ReturnReceiptHeader.Delete();
        ReturnReceiptHeader.Init();
        ReturnReceiptHeader."No." := ReceiptNo;
        ReturnReceiptHeader."Return Order No." := ReturnOrderNo;
        ReturnReceiptHeader.Insert();
    end;

    procedure InsertPostedReceiptWithReturnIds(ReceiptNo: Code[20]; StoreCode: Code[20]; ReturnId: Text[30]; ReturnOrderNo: Code[20])
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";
    begin
        InsertPostedReceipt(ReceiptNo, ReturnOrderNo);
        ReturnReceiptHeader.Get(ReceiptNo);
        SpfyAssignedIDMgt.AssignShopifyID(ReturnReceiptHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID", ReturnId, false);
        SpfyAssignedIDMgt.AssignShopifyID(ReturnReceiptHeader.RecordId(), "NPR Spfy ID Type"::"Store Code", StoreCode, false);
    end;

    /// <summary>
    /// Mock return of one order line shipped as two parcels of the given quantities, one return line per parcel, refunded in one refund line for the sum.
    /// </summary>
    procedure ReturnDetailResponseParcelQuantities(ReturnId: Text; OrderId: Text; OrderName: Text; Sku: Text; LineItemId: Text; FirstQty: Integer; SecondQty: Integer; NetAmount: Decimal; TaxAmount: Decimal; VatRate: Decimal; LocationId: Text; TransactionsJson: Text; Currency: Text): Text
    var
        ReturnLineEdges: Text;
        ReverseLineEdges: Text;
        ParcelReturnLineEdgeQtyTok: Label '{"node":{"id":"gid://shopify/ReturnLineItem/%1","quantity":%5,"restockingFee":null,"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/%2","lineItem":{"id":"gid://shopify/LineItem/%3","sku":"%4","title":"Test jacket","variant":{"id":"gid://shopify/ProductVariant/1","sku":"%4","barcode":null}}}}}', Locked = true;
        ParcelReverseLineEdgeQtyTok: Label '{"node":{"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/%1"},"dispositions":[{"type":"RESTOCKED","location":{"id":"gid://shopify/Location/%2"},"quantity":%3}]}}', Locked = true;
    begin
        ReturnLineEdges := StrSubstNo(ParcelReturnLineEdgeQtyTok, 1, 81, LineItemId, Sku, FirstQty) + ',' + StrSubstNo(ParcelReturnLineEdgeQtyTok, 2, 82, LineItemId, Sku, SecondQty);
        ReverseLineEdges := StrSubstNo(ParcelReverseLineEdgeQtyTok, 81, LocationId, FirstQty) + ',' + StrSubstNo(ParcelReverseLineEdgeQtyTok, 82, LocationId, SecondQty);
        exit(StrSubstNo(_ReturnDetailParcelsTok, ReturnId, OrderId, OrderName, LineItemId, Format(NetAmount, 0, 9), Format(TaxAmount, 0, 9), Format(VatRate, 0, 9), TransactionsJson, Currency, ReturnLineEdges, ReverseLineEdges, FirstQty + SecondQty));
    end;

    /// <summary>
    /// A card refund whose shop-currency leg differs from the presentment leg, as on a store selling in another currency.
    /// </summary>
    procedure RefundTxnJsonWithShopMoney(TxnId: Text; Gateway: Text; Amount: Decimal; Currency: Text; ShopAmount: Decimal; ShopCurrency: Text): Text
    var
        RefundTxnShopMoneyTok: Label '{"node":{"id":"gid://shopify/OrderTransaction/%1","kind":"REFUND","status":"SUCCESS","gateway":"%2","processedAt":"2026-09-20T10:00:00Z","createdAt":"2026-09-20T10:00:00Z","paymentId":"pay_%1","receiptJson":null,"amountSet":{"presentmentMoney":{"amount":"%3","currencyCode":"%4"},"shopMoney":{"amount":"%5","currencyCode":"%6"}}}}', Locked = true;
    begin
        exit(StrSubstNo(RefundTxnShopMoneyTok, TxnId, Gateway, Format(Amount, 0, 9), Currency, Format(ShopAmount, 0, 9), ShopCurrency));
    end;

    /// <summary>
    /// Mock return of one order line shipped in two parcels of one unit, restocked to two different locations, refunded in one refund line.
    /// </summary>
    procedure ReturnDetailResponseParcelLocations(ReturnId: Text; OrderId: Text; OrderName: Text; Sku: Text; LineItemId: Text; FirstLocationId: Text; SecondLocationId: Text; NetAmount: Decimal; TaxAmount: Decimal; VatRate: Decimal; TransactionsJson: Text; Currency: Text): Text
    var
        ReturnLineEdges: Text;
        ReverseLineEdges: Text;
    begin
        ReturnLineEdges := StrSubstNo(_ParcelReturnLineEdgeTok, 1, 81, LineItemId, Sku) + ',' + StrSubstNo(_ParcelReturnLineEdgeTok, 2, 82, LineItemId, Sku);
        ReverseLineEdges := StrSubstNo(_ParcelReverseLineEdgeTok, 81, FirstLocationId) + ',' + StrSubstNo(_ParcelReverseLineEdgeTok, 82, SecondLocationId);
        exit(StrSubstNo(_ReturnDetailParcelsTok, ReturnId, OrderId, OrderName, LineItemId, Format(NetAmount, 0, 9), Format(TaxAmount, 0, 9), Format(VatRate, 0, 9), TransactionsJson, Currency, ReturnLineEdges, ReverseLineEdges, 2));
    end;

    procedure RefundTxnJson(TxnId: Text; Gateway: Text; Amount: Decimal; Currency: Text; GiftCardId: Text): Text
    var
        Receipt: Text;
        RefundTxnTok: Label '{"node":{"id":"gid://shopify/OrderTransaction/%1","kind":"REFUND","status":"SUCCESS","gateway":"%2","processedAt":"2026-09-20T10:00:00Z","createdAt":"2026-09-20T10:00:00Z","paymentId":"pay_%1","receiptJson":%5,"paymentDetails":null,"amountSet":{"presentmentMoney":{"amount":"%3","currencyCode":"%4"},"shopMoney":{"amount":"%3","currencyCode":"%4"}}}}', Locked = true;
    begin
        if GiftCardId = '' then
            Receipt := 'null'
        else
            Receipt := '"{\"gift_card_id\":' + GiftCardId + '}"';
        exit(StrSubstNo(RefundTxnTok, TxnId, Gateway, Format(Amount, 0, 9), Currency, Receipt));
    end;

    /// <summary>
    /// A card refund transaction whose paymentDetails name the card company, as Shopify reports a card refund.
    /// </summary>
    procedure RefundTxnJsonWithCompany(TxnId: Text; Gateway: Text; Amount: Decimal; Currency: Text; Company: Text): Text
    begin
        exit(RefundTxnJson(TxnId, Gateway, Amount, Currency, '').Replace('"paymentDetails":null', '"paymentDetails":{"company":"' + Company + '"}'));
    end;

    var
        _LibraryERM: Codeunit "Library - ERM";
        _NoSeriesInitialized: Boolean;
        _VoucherTypeTok: Label 'SPFYLRGC', Locked = true;
        _LibrarySpfyVoucher: Codeunit "NPR Library - Spfy Voucher";
        _ReturnDetailParcelsTok: Label '{"data":{"return":{"id":"gid://shopify/Return/%1","name":"%3-R1","status":"CLOSED","closedAt":"2026-09-20T10:00:00Z","exchangeLineItems":{"edges":[]},"order":{"id":"gid://shopify/Order/%2","name":"%3","number":9001,"email":"anna@npretail.test","phone":null,"sourceName":"web","taxesIncluded":false,"currencyCode":"%9","presentmentCurrencyCode":"%9","customer":{"id":"gid://shopify/Customer/501","firstName":"Anna","lastName":"Test","defaultEmailAddress":{"emailAddress":"anna@npretail.test"},"defaultPhoneNumber":null,"defaultAddress":{"phone":null}},"billingAddress":{"firstName":"Anna","lastName":"Test","company":null,"countryCodeV2":"DK","zip":"2100","address1":"Testvej 1","address2":null,"city":"Copenhagen"},"shippingAddress":{"firstName":"Anna","lastName":"Test","company":null,"address1":"Testvej 1","address2":null,"zip":"2100","city":"Copenhagen","countryCodeV2":"DK","phone":null}},"returnShippingFees":[],"returnLineItems":{"pageInfo":{"hasNextPage":false},"edges":[%10]},"reverseFulfillmentOrders":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"lineItems":{"pageInfo":{"hasNextPage":false},"edges":[%11]}}}]},"refunds":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"id":"gid://shopify/Refund/1","transactions":{"pageInfo":{"hasNextPage":false},"edges":[%8]},"refundLineItems":{"pageInfo":{"hasNextPage":false},"edges":[{"node":{"quantity":%12,"subtotalSet":{"presentmentMoney":{"amount":"%5"}},"totalTaxSet":{"presentmentMoney":{"amount":"%6"}},"lineItem":{"id":"gid://shopify/LineItem/%4","taxLines":[{"ratePercentage":%7}]}}}]},"refundShippingLines":{"pageInfo":{"hasNextPage":false},"edges":[]},"orderAdjustments":{"pageInfo":{"hasNextPage":false},"edges":[]}}}]}}}}', Locked = true;
        _ParcelReturnLineEdgeTok: Label '{"node":{"id":"gid://shopify/ReturnLineItem/%1","quantity":1,"restockingFee":null,"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/%2","lineItem":{"id":"gid://shopify/LineItem/%3","sku":"%4","title":"Test jacket","variant":{"id":"gid://shopify/ProductVariant/1","sku":"%4","barcode":null}}}}}', Locked = true;
        _ParcelReverseLineEdgeTok: Label '{"node":{"fulfillmentLineItem":{"id":"gid://shopify/FulfillmentLineItem/%1"},"dispositions":[{"type":"RESTOCKED","location":{"id":"gid://shopify/Location/%2"},"quantity":1}]}}', Locked = true;
        _SingleRestockedDispositionTok: Label '[{"type":"RESTOCKED","location":{"id":"gid://shopify/Location/%1"},"quantity":%2}]', Locked = true;
}

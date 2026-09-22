#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85389 "NPR Spfy Order Import Tests"
{
    // [Feature] Shopify order import
    Subtype = Test;
    TestPermissions = Disabled;

    [Test]
    procedure GiftCardSearchBoundUsesCreatedAtNotUpdatedAt()
    var
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        Assert: Codeunit Assert;
        GiftCardLineId: Text[30];
    begin
        // [SCENARIO] A gift-card fulfillment whose createdAt (11:58:31) precedes its updatedAt (11:58:32).
        // The Shopify gift card is issued at createdAt, so the gift-card search must be bounded by createdAt.
        // Using updatedAt (the previous behaviour) excluded the already-issued gift card -> "No gift cards found".
        GiftCardLineId := '50379026825261';
        SpfyFulfillmentCache.ClearCache();

        // [WHEN] the fulfillment is cached
        Assert.IsTrue(SpfyOrderApiHelper.CacheFulfillment(GiftCardFulfilmentFixture(), SpfyFulfillmentCache), 'Caching the fulfillment failed.');

        // [THEN] the cached gift-card line carries the fulfillment createdAt as the gift-card search bound
        Assert.IsTrue(SpfyFulfillmentCache.GetLineFromCache(GiftCardLineId, TempSpfyFulfillmentBuffer), 'Gift card line was not cached.');
        Assert.AreNotEqual(0DT, TempSpfyFulfillmentBuffer."Created At", 'Created At must be populated from the fulfillment createdAt.');
        Assert.IsTrue(
            TempSpfyFulfillmentBuffer."Created At" < TempSpfyFulfillmentBuffer."Updated At",
            'Gift card search bound must be the fulfillment createdAt (earlier than updatedAt), not updatedAt.');
    end;

    [Test]
    procedure CalculateVAT_IgnoresTaxLineWithZeroAmount()
    var
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        Expected: Decimal;
    begin
        // [SCENARIO] VAT% is the sum of ratePercentage over tax lines that actually carry an amount.
        // A tax line with a zero amount (e.g. the gift-card line on order 1179) must be ignored.

        // [THEN] taxable line (rate 13, amount 118.43) -> 13
        Expected := 13;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalculateVAT(ParseJson('{"taxLines":[{"ratePercentage":13.0,"priceSet":{"presentmentMoney":{"amount":"118.43"}}}]}')), 'Taxable line VAT%.');

        // [THEN] zero-amount tax line (rate 0, amount 0) -> 0
        Expected := 0;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalculateVAT(ParseJson('{"taxLines":[{"ratePercentage":0.0,"priceSet":{"presentmentMoney":{"amount":"0.0"}}}]}')), 'Zero-amount tax line must be ignored.');

        // [THEN] no tax lines -> 0
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalculateVAT(ParseJson('{"taxLines":[]}')), 'No tax lines -> 0.');
    end;

    [Test]
    procedure CalcLineDiscountAmount_SumsAllocations()
    var
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        Expected: Decimal;
    begin
        // [SCENARIO] The raw line discount is the sum of all discountAllocations presentment amounts.

        // [THEN] two allocations (20 + 10) -> 30
        Expected := 30;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalcLineDiscountAmount(ParseJson('{"discountAllocations":[{"allocatedAmountSet":{"presentmentMoney":{"amount":"20.0"}}},{"allocatedAmountSet":{"presentmentMoney":{"amount":"10.0"}}}]}')), 'Sum of discount allocations.');

        // [THEN] no allocations -> 0
        Expected := 0;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalcLineDiscountAmount(ParseJson('{"discountAllocations":[]}')), 'No allocations -> 0.');
    end;

    [Test]
    procedure GiftCardSearchLowerBound_AppliesMargin()
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        Assert: Codeunit Assert;
        CreatedAt: DateTime;
        LowerBound: DateTime;
    begin
        // [SCENARIO] The gift-card search lower bound is the fulfillment createdAt widened backwards, so a gift card
        // issued at createdAt is never excluded by Shopify's created_at filter - the exact width is a margin, not a
        // measurement, so asserting it would only restate the literal it is supposed to protect. What matters is that
        // the bound never lands at or after createdAt (the card would drop out of the search and the import would fail
        // with "no gift cards found"), never grows so wide that the search stops discriminating, and never turns a
        // blank createdAt into a negative datetime.
        CreatedAt := CreateDateTime(DMY2Date(23, 6, 2026), 115832T);
        LowerBound := SpfyOrderApiHelper.GiftCardSearchLowerBound(CreatedAt);

        // [THEN] the bound is strictly before createdAt and still within a sane distance of it
        Assert.IsTrue(LowerBound < CreatedAt, 'The search bound must be strictly earlier than the fulfillment createdAt.');
        Assert.IsTrue(LowerBound >= CreatedAt - (60 * 60 * 1000), 'The search bound must stay within an hour of the fulfillment createdAt.');

        // [THEN] a blank createdAt stays blank (no negative datetime)
        Assert.AreEqual(0DT, SpfyOrderApiHelper.GiftCardSearchLowerBound(0DT), 'Blank createdAt must stay blank.');
    end;

    [Test]
    procedure CalcProratedLineDiscount_ProratesByLineQuantity()
    var
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        Disc30: Text;
        Expected: Decimal;
    begin
        // [SCENARIO] One shared proration for both create (Ecom) and update (Sales) paths.
        Disc30 := '{"discountAllocations":[{"allocatedAmountSet":{"presentmentMoney":{"amount":"30.0"}}}]}';

        // [THEN] full discount when the whole ordered quantity is on the line
        Expected := 30;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalcProratedLineDiscount(ParseJson(Disc30), 2, 2), 'Full when lineQty = originalQty.');

        // [THEN] prorated when only part of the ordered quantity is on the line (30 / 2 * 1)
        Expected := 15;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalcProratedLineDiscount(ParseJson(Disc30), 1, 2), 'Prorated 30/2*1.');

        // [THEN] full discount when originalQty is 0 (no proration base)
        Expected := 30;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalcProratedLineDiscount(ParseJson(Disc30), 2, 0), 'Full when originalQty = 0.');

        // [THEN] zero when there are no allocations
        Expected := 0;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalcProratedLineDiscount(ParseJson('{"discountAllocations":[]}'), 1, 2), 'No discount -> 0.');
    end;

    [Test]
    procedure ResolveUnitPriceAndDiscount_CompareAtBooksTheDifference()
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Assert: Codeunit Assert;
        Discount: Decimal;
        UnitPrice: Decimal;
        Expected: Decimal;
    begin
        // [SCENARIO] One shared compare-at resolution for both create (Ecom) and update (Sales) paths.

        // [THEN] compare-at (100) > actual (80), qty 2 -> unit price 100, discount += (100-80)*2 = 40
        Discount := 0;
        UnitPrice := OrderMgt.ResolveUnitPriceAndDiscount(true, 100, 80, 2, Discount);
        Expected := 100;
        Assert.AreEqual(Expected, UnitPrice, 'Compare-at price becomes the unit price.');
        Expected := 40;
        Assert.AreEqual(Expected, Discount, 'Difference (compare-at - actual) * qty is booked as discount.');

        // [THEN] compare-at (50) <= actual (80) -> actual price, discount untouched
        Discount := 5;
        UnitPrice := OrderMgt.ResolveUnitPriceAndDiscount(true, 50, 80, 2, Discount);
        Expected := 80;
        Assert.AreEqual(Expected, UnitPrice, 'Below-actual compare-at is ignored.');
        Expected := 5;
        Assert.AreEqual(Expected, Discount, 'Discount unchanged when compare-at <= actual.');

        // [THEN] non-item -> actual price regardless of compare-at
        Discount := 0;
        UnitPrice := OrderMgt.ResolveUnitPriceAndDiscount(false, 100, 80, 2, Discount);
        Expected := 80;
        Assert.AreEqual(Expected, UnitPrice, 'Non-item uses the actual price.');
        Expected := 0;
        Assert.AreEqual(Expected, Discount, 'Non-item leaves discount untouched.');

        // [THEN] item without compare-at (CompareAtPrice = 0) -> actual price
        Discount := 0;
        UnitPrice := OrderMgt.ResolveUnitPriceAndDiscount(true, 0, 80, 2, Discount);
        Expected := 80;
        Assert.AreEqual(Expected, UnitPrice, 'No compare-at price -> actual price.');
    end;

    [Test]
    procedure BuildsFulfillmentCacheFromOrderBlobJson()
    var
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        Assert: Codeunit Assert;
        GiftCardLineId: Text[30];
    begin
        // [SCENARIO] The fulfillment cache can be rebuilt purely from the unified order JSON (the blob
        // shape) - foundation for replaying the blob / driving tests without HTTP.
        GiftCardLineId := '50379026825261';
        SpfyFulfillmentCache.ClearCache();

        // [WHEN] the cache is built from the unified order JSON
        Assert.IsTrue(SpfyOrderApiHelper.BuildFulfillmentCacheFromOrderJson(GiftCardOrderJsonFixture(), SpfyFulfillmentCache), 'Gift card should be detected from the order JSON.');

        // [THEN] the gift-card line is cached, carrying the fulfillment createdAt as its search bound
        Assert.IsTrue(SpfyFulfillmentCache.GetLineFromCache(GiftCardLineId, TempSpfyFulfillmentBuffer), 'Gift card line was not cached from JSON.');
        Assert.AreNotEqual(0DT, TempSpfyFulfillmentBuffer."Created At", 'Created At must be populated from the JSON fulfillment.');
        Assert.IsTrue(
            TempSpfyFulfillmentBuffer."Created At" < TempSpfyFulfillmentBuffer."Updated At",
            'Search bound (createdAt) must be earlier than updatedAt, rebuilt from JSON.');
    end;

    local procedure GiftCardOrderJsonFixture() OrderResponse: JsonToken
    var
        Root: JsonObject;
        DataObj: JsonObject;
        OrderObj: JsonObject;
        LineItemsToken: JsonToken;
    begin
        // Unified order JSON (data.order.{fulfillments,lineItems}) - same shape as the "Order Data" blob.
        LineItemsToken := ParseJson('[{"node":{"id":"gid://shopify/LineItem/50379026825261","currentQuantity":1,"isGiftCard":true,"variant":{"price":"100.00"},"unfulfilledQuantity":0,"nonFulfillableQuantity":0}}]');
        OrderObj.Add('fulfillments', GiftCardFulfilmentFixture());
        OrderObj.Add('lineItems', LineItemsToken.AsArray());
        DataObj.Add('order', OrderObj);
        Root.Add('data', DataObj);
        OrderResponse := Root.AsToken();
    end;

    [Test]
    procedure CalculateVAT_SumsMultipleTaxLines()
    var
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        Expected: Decimal;
    begin
        // [SCENARIO] VAT% sums ratePercentage over all tax lines that carry an amount; zero-amount lines ignored.
        Expected := 15;
        Assert.AreEqual(Expected, SpfyEcomSalesDocImport.CalculateVAT(ParseJson(
            '{"taxLines":[' +
            '{"ratePercentage":10.0,"priceSet":{"presentmentMoney":{"amount":"5.0"}}},' +
            '{"ratePercentage":5.0,"priceSet":{"presentmentMoney":{"amount":"2.0"}}},' +
            '{"ratePercentage":99.0,"priceSet":{"presentmentMoney":{"amount":"0.0"}}}]}')),
            'Sum of taxed lines (10+5), zero-amount line ignored.');
    end;

    [Test]
    procedure BuildFulfillmentCache_ItemOnly_NoGiftCard()
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] An item-only order reports no gift card.
        SpfyFulfillmentCache.ClearCache();
        Assert.IsFalse(
            SpfyOrderApiHelper.BuildFulfillmentCacheFromOrderJson(UnifiedOrder(
                '[{"node":{"id":"gid://shopify/LineItem/999","currentQuantity":1,"isGiftCard":false,"variant":{"price":"50.00"},"unfulfilledQuantity":1,"nonFulfillableQuantity":0}}]', '[]'), SpfyFulfillmentCache),
            'Item-only order must not report a gift card.');
    end;

    [Test]
    procedure GiftCardWithoutFulfillment_NotAllFulfilled()
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Gift-card line present but NOT fulfilled -> readiness gate must report not-all-fulfilled
        // (the trigger that postpones processing instead of failing the gift-card lookup).
        SpfyFulfillmentCache.ClearCache();
        SpfyOrderApiHelper.BuildFulfillmentCacheFromOrderJson(UnifiedOrder(
            '[{"node":{"id":"gid://shopify/LineItem/50379026825261","currentQuantity":1,"isGiftCard":true,"variant":{"price":"100.00"},"unfulfilledQuantity":1,"nonFulfillableQuantity":0}}]', '[]'), SpfyFulfillmentCache);
        Assert.IsFalse(SpfyFulfillmentCache.AllFulfilled(), 'Unfulfilled gift card must report NOT all fulfilled.');
    end;

    [Test]
    procedure GiftCardWithFulfillment_AllFulfilled()
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Gift-card line fulfilled (SUCCESS) -> readiness gate reports all fulfilled -> proceed.
        SpfyFulfillmentCache.ClearCache();
        SpfyOrderApiHelper.CacheFulfillment(OrderFulfilmentsFixture(), SpfyFulfillmentCache);
        Assert.IsTrue(SpfyFulfillmentCache.AllFulfilled(), 'Fulfilled gift card must report all fulfilled.');
    end;

    [Test]
    procedure CreatesEcomDocumentForSimpleItemOrder()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
        UnitPrice: Decimal;
        Expected: Decimal;
    begin
        // [SCENARIO] A simple Shopify item order (no gift card) builds an Ecom Sales Header + one item line,
        // driven from the order JSON without any HTTP (integration test of the create path).
        ShopifyId := '900000000001';
        UnitPrice := 666;
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);

        // [WHEN] the create path runs from the order JSON
        Assert.IsTrue(SpfyEcomSalesDocImport.CreateEcommerceDocumentFromJson(LogEntry, LibrarySpfyImport.BuildSimpleItemOrderJson(ShopifyId, Sku, UnitPrice), EcomSalesHeader), 'CreateEcommerceDocumentFromJson should succeed.');

        // [THEN] the header is created for this order with one item line at the right unit price
        Assert.AreEqual(ShopifyId, EcomSalesHeader."External No.", 'Ecom header external no. should be the Shopify order id.');
        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        Assert.AreEqual(1, EcomSalesLine.Count(), 'Exactly one ecom sales line expected.');
        EcomSalesLine.FindFirst();
        Assert.AreEqual(ItemNo, CopyStr(EcomSalesLine."No.", 1, MaxStrLen(ItemNo)), 'Line item no.');
        Expected := 1;
        Assert.AreEqual(Expected, EcomSalesLine.Quantity, 'Line quantity.');
        Assert.AreEqual(UnitPrice, EcomSalesLine."Unit Price", 'Line unit price.');
    end;

    [Test]
    procedure CreatesEcomDocumentWithLineDiscount()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
        UnitPrice: Decimal;
        Expected: Decimal;
    begin
        // [SCENARIO] An item line with a line discount books the discount and the net line amount.
        ShopifyId := '900000000002';
        UnitPrice := 666;
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);

        Assert.IsTrue(
            SpfyEcomSalesDocImport.CreateEcommerceDocumentFromJson(LogEntry, LibrarySpfyImport.BuildItemOrderWithDiscountJson(ShopifyId, Sku, UnitPrice, 50), EcomSalesHeader),
            'Create with discount should succeed.');

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        Assert.IsTrue(EcomSalesLine.FindFirst(), 'Item line expected.');
        Expected := 50;
        Assert.AreEqual(Expected, EcomSalesLine."Line Discount Amount", 'Line discount amount.');
        Expected := 616; // 666 * 1 - 50
        Assert.AreEqual(Expected, EcomSalesLine."Line Amount", 'Net line amount = unit price * qty - discount.');
    end;

    [Test]
    procedure CreatesEcomDocumentWithMultipleLines()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An order with two item lines produces two Ecommerce sales lines.
        ShopifyId := '900000000003';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);

        Assert.IsTrue(
            SpfyEcomSalesDocImport.CreateEcommerceDocumentFromJson(LogEntry, LibrarySpfyImport.BuildMultiLineItemOrderJson(ShopifyId, Sku, 666), EcomSalesHeader),
            'Create with multiple lines should succeed.');

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        Assert.AreEqual(2, EcomSalesLine.Count(), 'Two ecom sales lines expected.');
    end;

    [Test]
    procedure CreatesEcomDocumentWithShippingFee()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesLine: Record "NPR Ecom Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
        Expected: Decimal;
    begin
        // [SCENARIO] A shipping line maps to a shipment fee line on the Ecommerce document.
        ShopifyId := '900000000004';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.SetupShipmentMapping('STD');
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);

        Assert.IsTrue(
            SpfyEcomSalesDocImport.CreateEcommerceDocumentFromJson(LogEntry, LibrarySpfyImport.BuildItemOrderWithShippingJson(ShopifyId, Sku, 666, 'STD', 15), EcomSalesHeader),
            'Create with shipping fee should succeed.');

        EcomSalesLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesLine.SetRange(Type, EcomSalesLine.Type::"Shipment Fee");
        Assert.IsTrue(EcomSalesLine.FindFirst(), 'A shipment fee line is expected.');
        Expected := 15;
        Assert.AreEqual(Expected, EcomSalesLine."Unit Price", 'Shipment fee unit price.');
    end;

    [Test]
    procedure ReplaysOrderDataBlobWithoutFetch()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        Assert: Codeunit Assert;
        Response: JsonToken;
        OrderToken: JsonToken;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] With a usable Order Data blob for a non-gift-card order, GetOrderDetails replays it
        // instead of fetching from Shopify. (A real fetch would error here - the test Spfy Store has no URL/token,
        // so the test passing proves the HTTP fetch was skipped.)
        ShopifyId := '900000000005';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);
        LibrarySpfyImport.WriteOrderDataBlob(LogEntry, LibrarySpfyImport.BuildReplayableItemOrderJson(ShopifyId, Sku, 666));

        // [WHEN] order details are requested
        SpfyOrderApiHelper.GetOrderDetails(LogEntry, Response);

        // [THEN] the response is the replayed blob (no fetch happened, otherwise it would have errored)
        Assert.IsTrue(Response.SelectToken('data.order', OrderToken), 'Replayed response should contain data.order.');
    end;

    [Test]
    procedure FulfillmentCache_SurvivesSetRunGetRoundTrip()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        SourceCache: Codeunit "NPR Spfy Fulfillment Cache";
        RoundTripCache: Codeunit "NPR Spfy Fulfillment Cache";
        Assert: Codeunit Assert;
        ExpectedQty: Decimal;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
        OrderLineId: Text[30];
    begin
        // [SCENARIO] The fulfillment cache is a codeunit holding a temporary record, handed in before the run and read
        // back after it. Every quantity to ship on a closed order comes out of that cache, so if the codeunit-to-
        // codeunit assignment did not carry the record, the caller would read an empty cache and post every order as
        // unfulfilled - silently. Driven through the replay branch, so no Shopify call is made: the fulfillment is in
        // the stored order data and is cached while the run is replaying it.
        ShopifyId := '920000000001';
        OrderLineId := '920000000101';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);
        LibrarySpfyImport.WriteOrderDataBlob(LogEntry, ReplayableOrderWithFulfillmentJson(ShopifyId, OrderLineId, Sku, 666));
        SpfyOrderApiHelper.SetFulfillmentCache(SourceCache);

        // [GIVEN] the cache handed in is empty, so anything read back can only have been put there during the run.
        // (The replay rebuilds the cache from the stored order data, which is why this is the honest control here -
        // a pre-filled cache would be cleared, not carried through.)
        Assert.IsFalse(SourceCache.GetLineFromCache(OrderLineId, TempSpfyFulfillmentBuffer), 'The cache handed in must start empty.');
        Commit(); // the return value of Codeunit.Run is read, which the platform only allows outside a write transaction

        // [WHEN] the order details are produced and the cache is read back out
        Assert.IsTrue(SpfyOrderApiHelper.Run(LogEntry), 'Replaying the stored order data should succeed without any Shopify call.');
        SpfyOrderApiHelper.GetFulfillmentCache(RoundTripCache);

        // [THEN] the fulfillment the run cached is in the cache the caller reads
        Assert.IsTrue(RoundTripCache.GetLineFromCache(OrderLineId, TempSpfyFulfillmentBuffer), 'The fulfilled line must survive the Set/Run/Get round trip.');
        ExpectedQty := 1;
        Assert.AreEqual(ExpectedQty, TempSpfyFulfillmentBuffer."Fulfilled Quantity", 'The fulfilled quantity must survive the round trip.');
        Assert.AreNotEqual(0DT, TempSpfyFulfillmentBuffer."Created At", 'The fulfillment creation time must survive the round trip.');

        LibrarySpfyImport.CleanupCommittedLogEntries(StoreCode, ShopifyId);
    end;

    /// <summary>Stored order data the replay path accepts - one SUCCESS AUTHORIZATION transaction and no gift card -
    /// that also carries a SUCCESS fulfillment for the given order line, so the fulfillment cache is filled from the
    /// blob instead of from Shopify.</summary>
    local procedure ReplayableOrderWithFulfillmentJson(ShopifyId: Text; OrderLineId: Text[30]; Sku: Code[20]; UnitPrice: Decimal) OrderResponse: JsonToken
    var
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        Builder: TextBuilder;
        Amount: Text;
    begin
        Amount := Format(UnitPrice, 0, 9);
        Builder.Append('{"data":{"order":{');
        Builder.Append('"id":"gid://shopify/Order/' + ShopifyId + '",');
        Builder.Append('"name":"#' + ShopifyId + '",');
        Builder.Append('"number":1001,"taxesIncluded":false,');
        Builder.Append('"customer":{"firstName":"Test","lastName":"Buyer","defaultAddress":{"phone":null}},');
        Builder.Append('"lineItems":[' + LibrarySpfyImport.ItemLineNodeText(OrderLineId, Sku, UnitPrice, 1, '[]') + '],');
        Builder.Append('"fulfillments":[{"id":"gid://shopify/Fulfillment/1","status":"SUCCESS","displayStatus":"FULFILLED",');
        Builder.Append('"createdAt":"2026-06-23T11:58:31Z","updatedAt":"2026-06-23T11:58:32Z",');
        Builder.Append('"orderId":"gid://shopify/Order/' + ShopifyId + '","email":"buyer@test.com",');
        Builder.Append('"fulfillmentLineItems":[{"cursor":"a","node":{"id":"gid://shopify/FulfillmentLineItem/1","quantity":1,');
        Builder.Append('"lineItem":{"id":"gid://shopify/LineItem/' + OrderLineId + '","currentQuantity":1,"variant":{"price":"' + Amount + '"},"unfulfilledQuantity":0,"nonFulfillableQuantity":0,"isGiftCard":false,"originalUnitPriceSet":{"presentmentMoney":{"amount":"' + Amount + '"}}}}}]}],');
        Builder.Append('"shippingLines":[],');
        Builder.Append('"transactions":[{"id":"gid://shopify/OrderTransaction/1","kind":"AUTHORIZATION","status":"SUCCESS",');
        Builder.Append('"amountSet":{"presentmentMoney":{"amount":"' + Amount + '","currencyCode":"USD"},"shopMoney":{"amount":"' + Amount + '","currencyCode":"USD"}}}]');
        Builder.Append('}}}');
        OrderResponse := ParseJson(Builder.ToText());
    end;

    [Test]
    procedure UpdatesExistingSalesLineFromFulfillment()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
        OrderLineId: Text[30];
        Expected: Decimal;
    begin
        // [SCENARIO] Update path: an existing Sales Line (qty 1) is updated to the fulfilled quantity (2)
        // coming from Shopify - exercised directly from the order JSON (no HTTP fetch).
        ShopifyId := '900000000006';
        OrderLineId := '700000000001';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(OrderLineId, 666, SalesHeader, SalesLine);

        // [WHEN] the update path applies a fulfillment of qty 2 for that line
        // The SKU is the item the sales order fixture created, not the shared one from SetupSimpleItemOrder: the line
        // has to resolve back to the item on the sales line, or the update is applied to something another test left
        // in the database.
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, LibrarySpfyImport.BuildUpdateOrderJson(ShopifyId, OrderLineId, SalesLine."No.", 666, 2), LogEntry);

        // [THEN] the existing sales line quantity is updated to the fulfilled quantity
        SalesLine.Find();
        Expected := 2;
        Assert.AreEqual(Expected, SalesLine.Quantity, 'Sales line quantity should be updated to the fulfilled quantity.');
    end;

    [Test]
    procedure CancelledFirstImport_DoesNotCreateOrPost()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An order first seen as Cancelled (no prior Open/Closed entry) must not create or post
        // any document; ProcessCancelledLogEntry rejects it with "nothing to process". This pins the
        // Closed/Cancelled separation that the first-import-Closed posting fix relies on (Closed requires
        // cancelledAt = 0D, so a cancelled order must never flow into CreateAndProcess + posting).
        ShopifyId := '900000000007';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);
        LogEntry."Document Status" := LogEntry."Document Status"::Cancelled;
        LogEntry.Modify();
        Commit(); // ProcessEcommerceDocument traps the "nothing to process" error via Codeunit.Run, which requires the setup writes to be committed first (in production the entry is an already-committed row picked up by the job queue).

        // [WHEN] the cancelled first-import entry is processed
        SpfyEventLogDocProcessr.ProcessLogEntry(LogEntry);

        // [THEN] no Ecommerce document was created for this order
        EcomSalesHeader.SetRange("External No.", ShopifyId);
        Assert.IsTrue(EcomSalesHeader.IsEmpty(), 'A cancelled first-import order must not create an Ecommerce document.');

        // [THEN] the entry is not silently marked Processed (it is flagged with the failure outcome)
        LogEntry.Find();
        Assert.AreNotEqual(LogEntry."Processing Status"::Processed, LogEntry."Processing Status", 'Cancelled first-import must not be marked Processed.');

        LibrarySpfyImport.CleanupCommittedLogEntries(StoreCode, ShopifyId);
    end;

    [Test]
    procedure ResolveTopUpVoucher_MatchesExistingGiftCardEntryId()
    var
        NpRvVoucher: Record "NPR NpRv Voucher";
        ResolvedVoucher: Record "NPR NpRv Voucher";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        GiftCardId: Text[30];
    begin
        // [SCENARIO] Top-up parity with legacy SetRetailVoucher: a Shopify gift-card Entry ID that already
        // maps to a BC voucher must resolve to that voucher (a reload/top-up), so a recurring gift-card id
        // does not mint a duplicate voucher. A fresh id (standard Shopify) must NOT resolve -> new voucher.
        GiftCardId := 'GC-TOPUP-0001';

        // [GIVEN] an existing voucher carrying that gift-card Entry ID
        NpRvVoucher.Init();
        NpRvVoucher."No." := 'SPFYTOPUPVCH1';
        NpRvVoucher.Insert(); // no OnInsert trigger: isolated unit test of the Entry-ID -> voucher lookup only
        SpfyAssignedIDMgt.AssignShopifyID(NpRvVoucher.RecordId(), "NPR Spfy ID Type"::"Entry ID", GiftCardId, false);

        // [THEN] the same gift-card id resolves to that voucher (top-up)
        Assert.IsTrue(SpfyEcomSalesDocImport.ResolveTopUpVoucher(GiftCardId, ResolvedVoucher), 'A known gift-card Entry ID must resolve to a top-up.');
        Assert.AreEqual(NpRvVoucher."No.", ResolvedVoucher."No.", 'Top-up must reuse the voucher already carrying the Entry ID.');

        // [THEN] an unknown gift-card id does not resolve (a fresh id -> new voucher)
        Assert.IsFalse(SpfyEcomSalesDocImport.ResolveTopUpVoucher('GC-UNKNOWN-9999', ResolvedVoucher), 'An unknown gift-card id must not resolve to a top-up.');

        // [THEN] a blank gift-card id does not resolve
        Assert.IsFalse(SpfyEcomSalesDocImport.ResolveTopUpVoucher('', ResolvedVoucher), 'A blank gift-card id must not resolve to a top-up.');
    end;

    local procedure UnifiedOrder(LineItemsArrText: Text; FulfilmentsArrText: Text) OrderResponse: JsonToken
    var
        Root: JsonObject;
        DataObj: JsonObject;
        OrderObj: JsonObject;
    begin
        OrderObj.Add('lineItems', ParseJson(LineItemsArrText).AsArray());
        OrderObj.Add('fulfillments', ParseJson(FulfilmentsArrText).AsArray());
        DataObj.Add('order', OrderObj);
        Root.Add('data', DataObj);
        OrderResponse := Root.AsToken();
    end;

    local procedure ParseJson(JsonText: Text): JsonToken
    var
        Token: JsonToken;
        InvalidJsonErr: Label 'Test fixture JSON is not valid: %1', Locked = true;
    begin
        if not Token.ReadFrom(JsonText) then
            Error(InvalidJsonErr, JsonText);
        exit(Token);
    end;

    [Test]
    procedure CancelledFulfillmentIgnored_GiftCardUsesCreatedAt()
    var
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        Assert: Codeunit Assert;
        ExpectedQty: Decimal;
    begin
        // [SCENARIO] Real order 18742205677613: item-fulfillment (SUCCESS), gift-card-fulfillment
        // (SUCCESS), and a CANCELLED item-fulfillment for the same item line. The cancelled one must
        // be ignored, and the gift card must carry its fulfillment createdAt as the search bound.
        SpfyFulfillmentCache.ClearCache();

        // [WHEN] all three fulfillments are cached
        Assert.IsTrue(SpfyOrderApiHelper.CacheFulfillment(OrderFulfilmentsFixture(), SpfyFulfillmentCache), 'Caching the fulfillments failed.');

        // [THEN] the gift-card line is cached with createdAt (< updatedAt) as the search bound
        Assert.IsTrue(SpfyFulfillmentCache.GetLineFromCache('50379026825261', TempSpfyFulfillmentBuffer), 'Gift card line was not cached.');
        Assert.IsTrue(TempSpfyFulfillmentBuffer."Gift Card", 'Line should be flagged as a gift card.');
        Assert.IsTrue(TempSpfyFulfillmentBuffer."Created At" < TempSpfyFulfillmentBuffer."Updated At", 'Gift card search bound must be createdAt (earlier than updatedAt).');
        ExpectedQty := 1;
        Assert.AreEqual(ExpectedQty, TempSpfyFulfillmentBuffer."Fulfilled Quantity", 'Gift card fulfilled quantity.');

        // [THEN] the item line counts only the SUCCESS fulfillment - the CANCELLED one is ignored (qty 1, not 2)
        Assert.IsTrue(SpfyFulfillmentCache.GetLineFromCache('50379026858029', TempSpfyFulfillmentBuffer), 'Item line was not cached.');
        ExpectedQty := 1;
        Assert.AreEqual(ExpectedQty, TempSpfyFulfillmentBuffer."Fulfilled Quantity", 'Cancelled fulfillment must not be counted (expected qty 1).');
    end;

    local procedure OrderFulfilmentsFixture() Fulfilments: JsonArray
    var
        Json: JsonToken;
        Builder: TextBuilder;
        InvalidFixtureErr: Label 'Test fixture JSON is not valid.', Locked = true;
    begin
        // Three fulfillments for order 18742205677613 (AddFulfilmentInfo shape), from the real Shopify response.
        Builder.Append('[');
        // 1) item fulfillment - SUCCESS (the re-fulfilled snowboard)
        Builder.Append('{"id":"gid://shopify/Fulfillment/7101523656749","status":"SUCCESS","displayStatus":"FULFILLED",');
        Builder.Append('"createdAt":"2026-06-23T11:59:30Z","updatedAt":"2026-06-23T11:59:30Z",');
        Builder.Append('"orderId":"gid://shopify/Order/18742205677613","email":"mmilekdub@gmail.com",');
        Builder.Append('"fulfillmentLineItems":[{"cursor":"a","node":{"id":"gid://shopify/FulfillmentLineItem/1","quantity":1,');
        Builder.Append('"lineItem":{"id":"gid://shopify/LineItem/50379026858029","currentQuantity":1,"variant":{"price":"666.00"},"unfulfilledQuantity":0,"nonFulfillableQuantity":1,"isGiftCard":false,"originalUnitPriceSet":{"presentmentMoney":{"amount":"666.0"}}}}}]},');
        // 2) gift-card fulfillment - SUCCESS (createdAt 11:58:31 < updatedAt 11:58:32)
        Builder.Append('{"id":"gid://shopify/Fulfillment/7101523001389","status":"SUCCESS","displayStatus":"FULFILLED",');
        Builder.Append('"createdAt":"2026-06-23T11:58:31Z","updatedAt":"2026-06-23T11:58:32Z",');
        Builder.Append('"orderId":"gid://shopify/Order/18742205677613","email":"mmilekdub@gmail.com",');
        Builder.Append('"fulfillmentLineItems":[{"cursor":"b","node":{"id":"gid://shopify/FulfillmentLineItem/2","quantity":1,');
        Builder.Append('"lineItem":{"id":"gid://shopify/LineItem/50379026825261","currentQuantity":1,"variant":{"price":"100.00"},"unfulfilledQuantity":0,"nonFulfillableQuantity":0,"isGiftCard":true,"originalUnitPriceSet":{"presentmentMoney":{"amount":"100.0"}}}}}]},');
        // 3) item fulfillment - CANCELLED (same item line; must be ignored)
        Builder.Append('{"id":"gid://shopify/Fulfillment/7101522837549","status":"CANCELLED","displayStatus":"CANCELED",');
        Builder.Append('"createdAt":"2026-06-23T11:58:09Z","updatedAt":"2026-06-23T11:58:55Z",');
        Builder.Append('"orderId":"gid://shopify/Order/18742205677613","email":"mmilekdub@gmail.com",');
        Builder.Append('"fulfillmentLineItems":[{"cursor":"c","node":{"id":"gid://shopify/FulfillmentLineItem/3","quantity":1,');
        Builder.Append('"lineItem":{"id":"gid://shopify/LineItem/50379026858029","currentQuantity":1,"variant":{"price":"666.00"},"unfulfilledQuantity":0,"nonFulfillableQuantity":1,"isGiftCard":false,"originalUnitPriceSet":{"presentmentMoney":{"amount":"666.0"}}}}}]}');
        Builder.Append(']');

        if not Json.ReadFrom(Builder.ToText()) then
            Error(InvalidFixtureErr);
        Fulfilments := Json.AsArray();
    end;

    local procedure GiftCardFulfilmentFixture(): JsonArray
    var
        Json: JsonToken;
        Builder: TextBuilder;
        InvalidFixtureErr: Label 'Test fixture JSON is not valid.', Locked = true;
    begin
        // Shape matches the per-fulfillment objects produced by SpfyOrderApiHelper.AddFulfilmentInfo,
        // built from the real Shopify GetFulfilments response for order 18742205677613 (gift card line).
        Builder.Append('[{');
        Builder.Append('"id":"gid://shopify/Fulfillment/7101523001389",');
        Builder.Append('"status":"SUCCESS",');
        Builder.Append('"displayStatus":"FULFILLED",');
        Builder.Append('"createdAt":"2026-06-23T11:58:31Z",');
        Builder.Append('"updatedAt":"2026-06-23T11:58:32Z",');
        Builder.Append('"orderId":"gid://shopify/Order/18742205677613",');
        Builder.Append('"email":"mmilekdub@gmail.com",');
        Builder.Append('"fulfillmentLineItems":[{"cursor":"x","node":{');
        Builder.Append('"id":"gid://shopify/FulfillmentLineItem/18243344465965",');
        Builder.Append('"quantity":1,');
        Builder.Append('"lineItem":{');
        Builder.Append('"id":"gid://shopify/LineItem/50379026825261",');
        Builder.Append('"currentQuantity":1,');
        Builder.Append('"variant":{"price":"100.00"},');
        Builder.Append('"unfulfilledQuantity":0,');
        Builder.Append('"nonFulfillableQuantity":0,');
        Builder.Append('"isGiftCard":true,');
        Builder.Append('"originalUnitPriceSet":{"presentmentMoney":{"amount":"100.0"}}');
        Builder.Append('}}}]');
        Builder.Append('}]');

        if not Json.ReadFrom(Builder.ToText()) then
            Error(InvalidFixtureErr);
        exit(Json.AsArray());
    end;

    // [Feature] Shopify order import - event log entry processing state
    // The "does a BC sales document already exist" predicate, the reopen-an-already-processed-entry path,
    // the stored order data discard paths (per entry and per import marker rollback) and the sibling wait.
    [Test]
    procedure OpenEntry_UnpostedSalesOrderExists_NotHandled()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] After Md1, an Open entry with only an unposted sales order is no longer short-circuited to
        // Processed. It must fall through into the Ecommerce flow, which surfaces
        // "not created by the Ecommerce flow" instead of silently marking the entry Processed.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000001';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, 'SPFYLOG-O01', ShopifyId);

        // [WHEN] the entry is checked for an already handled document
        // [THEN] the predicate reports "not handled" so the caller keeps the entry in its import job
        Assert.IsFalse(SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(LogEntry), 'Open entry with only an unposted sales order must not be treated as already handled after Md1.');

        // [THEN] the entry is not silently closed off as Processed
        LogEntry.Find();
        Assert.AreNotEqual(LogEntry."Processing Status"::Processed, LogEntry."Processing Status", 'The entry must not be marked Processed.');
    end;

    [Test]
    procedure OpenEntry_PostedInvoiceOnly_MarkedProcessed()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] Either kind of document completes an Open entry - a posted invoice is enough on its own.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000002';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertPostedSalesInvoiceWithShopifyId('SPFYLOG-I02', ShopifyId);

        Assert.IsTrue(SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(LogEntry), 'An Open entry with a posted invoice must be treated as already handled.');
        LogEntry.Find();
        Assert.AreEqual(LogEntry."Processing Status"::Processed, LogEntry."Processing Status", 'Processing Status.');
    end;

    [Test]
    procedure ClosedEntry_UnpostedSalesOrderOnly_NotHandled()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A Closed entry has to post, so an unposted sales order does NOT complete it. It must fall
        // through to the posting path instead of being silently marked Processed.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000003';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, 'SPFYLOG-O03', ShopifyId);

        Assert.IsFalse(SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(LogEntry), 'A Closed entry with an unposted sales order must not be treated as already handled.');
        LogEntry.Find();
        Assert.AreNotEqual(LogEntry."Processing Status"::Processed, LogEntry."Processing Status", 'The entry must not be marked Processed.');
    end;

    [Test]
    procedure ClosedEntry_PostedInvoiceExists_MarkedProcessed()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] Only a posted document completes a Closed entry - once the operator posts, the next
        // Process Document run closes the entry.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000004';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.InsertPostedSalesInvoiceWithShopifyId('SPFYLOG-I04', ShopifyId);

        Assert.IsTrue(SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(LogEntry), 'A Closed entry with a posted invoice must be treated as already handled.');
        LogEntry.Find();
        Assert.AreEqual(LogEntry."Processing Status"::Processed, LogEntry."Processing Status", 'Processing Status.');
    end;

    [Test]
    procedure ClosedEntry_PostedInvoiceAndUnpostedOrder_NotHandled()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A Closed entry with BOTH a posted invoice AND a still-unposted sales order carrying the same
        // Shopify id must not be treated as already handled. The Closed branch is 'PostedExists and not
        // UnpostedExists' - a partially-posted state means there is still open work (typically a return or a second
        // document generated by the same import), so the entry must fall through to the posting path rather than be
        // silently marked Processed.

        // [GIVEN] a Closed Open-Order-Import log entry with both a Posted Sales Invoice and an unposted Sales Header
        // carrying the same Shopify id
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000010';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.InsertPostedSalesInvoiceWithShopifyId('SPFYLOG-I10', ShopifyId);
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, 'SPFYLOG-O10', ShopifyId);

        // [WHEN] the entry is checked for an already handled document
        // [THEN] the predicate reports "not handled" - the partially-posted state keeps the entry in its import job
        Assert.IsFalse(SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(LogEntry), 'A Closed entry with a posted invoice AND an unposted sales order must not be treated as already handled.');

        // [THEN] the entry is not silently closed off as Processed
        LogEntry.Find();
        Assert.AreNotEqual(LogEntry."Processing Status"::Processed, LogEntry."Processing Status", 'The entry must not be marked Processed while an unposted document still exists.');
    end;

    [Test]
    procedure Entry_NoSalesDocumentAtAll_NotHandled()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] Nothing exists yet -> the entry keeps its normal import job.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000005';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());

        Assert.IsFalse(SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(LogEntry), 'Without any sales document there is nothing already handled.');
        LogEntry.Find();
        Assert.AreNotEqual(LogEntry."Processing Status"::Processed, LogEntry."Processing Status", 'The entry must not be marked Processed.');
    end;

    [Test]
    procedure CancelledEntry_PostedInvoiceExists_NotHandled()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The predicate only decides for Open and Closed; Cancelled keeps its existing behaviour and
        // is never short-circuited to Processed by an existing document.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000006';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Cancelled, CurrentDateTime());
        LibrarySpfyImport.InsertPostedSalesInvoiceWithShopifyId('SPFYLOG-I06', ShopifyId);

        Assert.IsFalse(SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(LogEntry), 'A Cancelled entry must keep its existing behaviour.');
    end;

    [Test]
    procedure OpenEntry_EcommerceDocumentStillExists_NotHandled()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An Ecommerce document still around means the regular create/update paths own this entry,
        // even when a sales document with the Shopify id already exists.
        ShopifyId := '910000000007';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        Assert.IsTrue(SpfyEcomSalesDocImport.CreateEcommerceDocumentFromJson(LogEntry, LibrarySpfyImport.BuildSimpleItemOrderJson(ShopifyId, Sku, 666), EcomSalesHeader), 'Ecommerce document setup failed.');
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, 'SPFYLOG-O07', ShopifyId);

        Assert.IsFalse(SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(LogEntry), 'An entry that still has an Ecommerce document must be left to the regular paths.');
    end;

    [Test]
    procedure OpenEntry_SalesDocumentOfAnotherStore_NotHandled()
    var
        OtherStoreEntry: Record "NPR Spfy Event Log Entry";
        OwnStoreEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
        OtherStoreShopifyId: Text[30];
        OwnStoreShopifyId: Text[30];
    begin
        // [SCENARIO] Shopify order ids are unique per store, not across stores - the event log itself dedupes on
        // (Store Code, Shopify ID), so the codebase does not assume global uniqueness. A document belonging to another
        // store must therefore not complete this store's entry: that would mark the entry Processed with nothing
        // imported - no document, no capture, no virtual items - and leave the operator a green row.
        // The own-store control below asserts that after Md1 an Open entry with only an unposted sales order is
        // no longer short-circuited to Processed either - the flow must instead surface
        // "not created by the Ecommerce flow" (covered by OpenEntry_UnpostedSalesOrderExists_NotHandled).
        StoreCode := 'SPFYSTOA';
        OtherStoreCode := 'SPFYSTOB';
        OtherStoreShopifyId := '910000000021';
        OwnStoreShopifyId := '910000000022';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.CreateStore(OtherStoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(OtherStoreEntry, StoreCode, OtherStoreShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, 'SPFYSTO-B21', OtherStoreShopifyId, OtherStoreCode);

        // [WHEN] the entry of one store is checked against a document stamped for the other store
        // [THEN] the document is not accepted
        Assert.IsFalse(
            SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(OtherStoreEntry),
            'A sales document belonging to another Shopify store must not complete this store''s entry.');
        OtherStoreEntry.Find();
        Assert.AreNotEqual(OtherStoreEntry."Processing Status"::Processed, OtherStoreEntry."Processing Status", 'The entry must keep its import job.');

        // [GIVEN + THEN] the control: the very same shape, stamped for the entry's own store. After Md1 an
        // unposted-only own-store document no longer short-circuits the entry to Processed either - the flow
        // must fall through to the Ecommerce path. Without this control the "other store" assertion would also
        // pass if the store-scoped lookup stopped finding any document at all, so we still exercise it here
        // but pin the Md1 semantics ("not handled") instead of the pre-Md1 semantics ("handled").
        LibrarySpfyImport.InsertOrderLogEntry(OwnStoreEntry, StoreCode, OwnStoreShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, 'SPFYSTO-A22', OwnStoreShopifyId, StoreCode);
        Assert.IsFalse(
            SpfyEventLogDocProcessr.MarkProcessedIfDocumentAlreadyExists(OwnStoreEntry),
            'Same-store unposted-only sales order must not short-circuit after Md1 - the flow should surface ''not created by the Ecommerce flow'' instead.');
    end;

    [Test]
    procedure SalesDocumentLookupIgnoresDocumentType()
    var
        SalesHeader: Record "Sales Header";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The assigned id is looked up per table, not per document type: the lookup filters the assigned
        // ids of "Sales Header" on the Shopify order id alone, so a return order carrying that id is returned to a
        // caller asking on behalf of an Order entry. Whether the flow should then refuse it is a decision of the
        // caller and is not asserted here - nothing in SalesOrderExists/FindSalesOrder compares the document type
        // (or reads the store code), so an assertion about that comparison would only restate a mapping helper.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000008';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::"Return Order", 'SPFYLOG-R08', ShopifyId);

        // [THEN] the lookup returns the return order even though we asked on behalf of an Order entry
        Assert.IsTrue(OrderMgt.FindSalesOrder(StoreCode, ShopifyId, SalesHeader), 'The assigned id must resolve the sales document regardless of its document type.');
        Assert.AreEqual(SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type", 'The resolved document is the return order.');
    end;

    [Test]
    procedure ProcessedEntryWithoutAnyDocument_IsReopenedAndReprocessed()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        UpdatedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
        ExpectedRetryCount: Integer;
    begin
        // [SCENARIO] A Processed entry that has neither an Ecommerce document nor a sales document left is reset
        // to a state indistinguishable from never-processed and imported again. The reset is observable through
        // the retry count: the reopened entry starts counting from zero, so a failing reattempt lands on 1 and
        // not on 8, and the job queue keeps picking the entry up.
        ShopifyId := '910000000009';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        // No stored order data, so the reattempt has to go to Shopify - which fails, because the test store has
        // no URL or token. That failure is what makes the reset visible in the retry count.
        LibrarySpfyImport.SetProcessingState(LogEntry, LogEntry."Processing Status"::Processed, 7);
        LogEntry.SetRecFilter();
        Commit(); // Processing traps errors via Codeunit.Run, which requires the setup writes to be committed first (in production the entry is an already-committed row picked up by the job queue).

        // [WHEN] the entry is processed again
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] it was reopened (retry count restarted from zero) and the import was actually attempted
        UpdatedEntry.Get(LogEntry."Entry No.");
        ExpectedRetryCount := 1;
        Assert.AreEqual(ExpectedRetryCount, UpdatedEntry."Process Retry Count", 'The reopened entry must start counting retries from zero again.');
        Assert.AreNotEqual(UpdatedEntry."Processing Status"::Processed, UpdatedEntry."Processing Status", 'The entry must no longer be Processed after a failed reattempt.');

        LibrarySpfyImport.CleanupCommittedLogEntries(StoreCode, ShopifyId);
    end;

    [Test]
    procedure ProcessedEntryWithSalesDocument_IsNotReopened()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        UpdatedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        ExpectedRetryCount: Integer;
    begin
        // [SCENARIO] A Processed entry whose sales document is still there is skipped - reprocessing it would
        // duplicate the document.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000010';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingStateWithOrderData(LogEntry, LogEntry."Processing Status"::Processed, 7);
        LibrarySpfyImport.InsertSalesHeaderWithShopifyId("Sales Document Type"::Order, 'SPFYLOG-O10', ShopifyId);
        LogEntry.SetRecFilter();

        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        UpdatedEntry.Get(LogEntry."Entry No.");
        Assert.AreEqual(UpdatedEntry."Processing Status"::Processed, UpdatedEntry."Processing Status", 'The entry must stay Processed.');
        ExpectedRetryCount := 7;
        Assert.AreEqual(ExpectedRetryCount, UpdatedEntry."Process Retry Count", 'A skipped entry must be left completely untouched.');
    end;

    [Test]
    procedure ProcessedEntryWithEcommerceDocument_IsNotReopened()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        UpdatedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
        ExpectedRetryCount: Integer;
    begin
        // [SCENARIO] A Processed entry whose Ecommerce document is still there is skipped as well.
        ShopifyId := '910000000011';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        Assert.IsTrue(SpfyEcomSalesDocImport.CreateEcommerceDocumentFromJson(LogEntry, LibrarySpfyImport.BuildSimpleItemOrderJson(ShopifyId, Sku, 666), EcomSalesHeader), 'Ecommerce document setup failed.');
        LogEntry.Find();
        LibrarySpfyImport.SetProcessingStateWithOrderData(LogEntry, LogEntry."Processing Status"::Processed, 7);
        LogEntry.SetRecFilter();

        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        UpdatedEntry.Get(LogEntry."Entry No.");
        Assert.AreEqual(UpdatedEntry."Processing Status"::Processed, UpdatedEntry."Processing Status", 'The entry must stay Processed.');
        ExpectedRetryCount := 7;
        Assert.AreEqual(ExpectedRetryCount, UpdatedEntry."Process Retry Count", 'A skipped entry must be left completely untouched.');
    end;

    [Test]
    procedure ProcessedCancelledEntry_IsNotReopened()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        UpdatedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        ExpectedRetryCount: Integer;
    begin
        // [SCENARIO] Only Open and Closed entries are reopened; a Processed Cancelled entry is left alone even
        // though it has no documents at all.
        StoreCode := 'SPFYLOGST';
        ShopifyId := '910000000012';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Cancelled, CurrentDateTime());
        LibrarySpfyImport.SetProcessingStateWithOrderData(LogEntry, LogEntry."Processing Status"::Processed, 7);
        LogEntry.SetRecFilter();

        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        UpdatedEntry.Get(LogEntry."Entry No.");
        Assert.AreEqual(UpdatedEntry."Processing Status"::Processed, UpdatedEntry."Processing Status", 'A Cancelled entry must stay Processed.');
        ExpectedRetryCount := 7;
        Assert.AreEqual(ExpectedRetryCount, UpdatedEntry."Process Retry Count", 'A skipped entry must be left completely untouched.');
    end;

    [Test]
    procedure Marker_NotMovedWhenNothingWasListed()
    var
        SpfyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        Assert: Codeunit Assert;
        AreaEnabled: Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean];
        StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]];
        MarkerBefore: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] The whole point of the poller's contract: a cycle that could not list what Shopify has must
        // leave the watermark where it was. Moving it would skip every order in the window that was never examined,
        // silently and permanently - nothing downstream can recover a document that never reached the event log.
        StoreCode := 'SPFYMRK1';
        MarkerBefore := CreateDateTime(DMY2Date(1, 6, 2026), 120000T);
        LibrarySpfyImport.CreateStore(StoreCode); // no Shopify URL and no token, so listing the orders fails
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastOrdersImportedAt(MarkerBefore);
        AreaEnabled.Set("NPR SpfyEventLogDocType"::Order, true);
        AreaEnabled.Set("NPR SpfyEventLogDocType"::"Return Order", false);
        StoresDict.Add(StoreCode, AreaEnabled);

        // [WHEN] a poll cycle runs and the list request fails
        SpfyOrderImportJQ.Process(StoresDict);

        // [THEN] the marker is untouched
        Assert.AreEqual(MarkerBefore, LastOrdersImportedAt(StoreCode), 'A cycle that failed to list must leave the marker where it was.');
    end;

    [Test]
    procedure Marker_SessionMaxAdvancedAndNothingStopped_IsWritten()
    var
        SpfyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        Assert: Codeunit Assert;
        MarkerBefore: DateTime;
        SessionMax: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] The control for the two tests below. A cycle that listed something and hit no failure must move the
        // marker - otherwise "the marker did not move" proves nothing anywhere else, which is exactly the hole the
        // failed-poll test above leaves: there the session max never advanced, so TryUpdateMarker returns on its
        // "nothing new" guard and the marker-stop logic is never reached at all.
        StoreCode := 'SPFYMRK2';
        MarkerBefore := CreateDateTime(DMY2Date(1, 6, 2026), 120000T);
        SessionMax := MarkerBefore + 60000;
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastOrdersImportedAt(MarkerBefore);
        SpfyStore.Get(StoreCode);

        // [WHEN] a cycle advances the session max and finishes without stopping the marker
        SpfyOrderImportJQ.SetMarkers(SpfyStore, "NPR SpfyEventLogDocType"::Order);
        SpfyOrderImportJQ.UpdateSessionMax(StoreCode, "NPR SpfyEventLogDocType"::Order, SessionMax);
        SpfyOrderImportJQ.TryUpdateMarker(SpfyStore, "NPR SpfyEventLogDocType"::Order);

        // [THEN] the marker moves to what the cycle examined
        Assert.AreEqual(SessionMax, LastOrdersImportedAt(StoreCode), 'A clean cycle must move the marker up to the newest order it examined.');
    end;

    [Test]
    procedure Marker_StoppedAfterSessionMaxAdvanced_IsNotWritten()
    var
        SpfyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        Assert: Codeunit Assert;
        MarkerBefore: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] The marker-stop contract, on the only state where it can matter: the session max already advanced,
        // so the "nothing new" guard would let the write through, and only the stop keeps it out. Every failure routes
        // through LogError, which stops the marker for the whole cycle - because something in the window was not
        // examined to the end, and moving the marker past it would drop those orders silently and permanently.
        StoreCode := 'SPFYMRK3';
        MarkerBefore := CreateDateTime(DMY2Date(1, 6, 2026), 120000T);
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastOrdersImportedAt(MarkerBefore);
        SpfyStore.Get(StoreCode);

        // [WHEN] the session max advanced but something in the cycle failed
        SpfyOrderImportJQ.SetMarkers(SpfyStore, "NPR SpfyEventLogDocType"::Order);
        SpfyOrderImportJQ.UpdateSessionMax(StoreCode, "NPR SpfyEventLogDocType"::Order, MarkerBefore + 60000);
        SpfyOrderImportJQ.StopMarker(StoreCode, "NPR SpfyEventLogDocType"::Order);
        SpfyOrderImportJQ.TryUpdateMarker(SpfyStore, "NPR SpfyEventLogDocType"::Order);

        // [THEN] the marker stays where it was, so the window is polled again
        Assert.AreEqual(MarkerBefore, LastOrdersImportedAt(StoreCode), 'A stopped marker must not be written, even when the session max advanced.');
    end;

    [Test]
    procedure Marker_LogErrorFiredWithAdvancedSessionMax_MarkerNotWritten()
    var
        SpfyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        Assert: Codeunit Assert;
        AreaEnabled: Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean];
        StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]];
        MarkerBefore: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] End-to-end wiring behind Marker_StoppedAfterSessionMaxAdvanced_IsNotWritten: a real cycle whose
        // session max has already moved and whose list request then fails must not write the marker. The stop can only
        // reach TryUpdateMarker if LogError calls StopMarker; deleting that call from LogError must fail this test.
        StoreCode := 'SPFYMRK4';
        MarkerBefore := CreateDateTime(DMY2Date(1, 6, 2026), 120000T);

        // [GIVEN] a store whose marker is set and whose session max is seeded above the marker on the JQ instance
        //         that will run the cycle; the store has no URL or token so listing the orders will fail
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastOrdersImportedAt(MarkerBefore);
        SpfyStore.Get(StoreCode);
        SpfyOrderImportJQ.SetMarkers(SpfyStore, "NPR SpfyEventLogDocType"::Order);
        SpfyOrderImportJQ.UpdateSessionMax(StoreCode, "NPR SpfyEventLogDocType"::Order, MarkerBefore + 60 * 60000);
        AreaEnabled.Set("NPR SpfyEventLogDocType"::Order, true);
        AreaEnabled.Set("NPR SpfyEventLogDocType"::"Return Order", false);
        StoresDict.Add(StoreCode, AreaEnabled);

        // [WHEN] the cycle runs and the list request fails, so LogError fires on the same JQ instance
        SpfyOrderImportJQ.Process(StoresDict);

        // [THEN] the marker stays where it was: LogError must have called StopMarker, and the following TryUpdateMarker
        //       must have honoured it even though the seeded session max would otherwise have let the write through
        Assert.AreEqual(MarkerBefore, LastOrdersImportedAt(StoreCode), 'LogError must call StopMarker, so TryUpdateMarker must not write the marker even though session max advanced.');
    end;

    [Test]
    procedure Marker_RolledBackMidCycle_IsNotOverwrittenWithTheStaleMax()
    var
        SpfyStore: Record "NPR Spfy Store";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        Assert: Codeunit Assert;
        MarkerBefore: DateTime;
        RewoundMarker: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] An operator rewinding the marker while a cycle is running must win. The cycle is holding a session
        // max from before the rewind, and writing it would undo the rewind and skip exactly the period the operator
        // asked to re-read.
        StoreCode := 'SPFYMRK4';
        MarkerBefore := CreateDateTime(DMY2Date(1, 6, 2026), 120000T);
        RewoundMarker := MarkerBefore - 3600000; // one hour back
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastOrdersImportedAt(MarkerBefore);
        SpfyStore.Get(StoreCode);

        // [WHEN] the cycle has advanced its session max and the stored marker is rewound underneath it
        SpfyOrderImportJQ.SetMarkers(SpfyStore, "NPR SpfyEventLogDocType"::Order);
        SpfyOrderImportJQ.UpdateSessionMax(StoreCode, "NPR SpfyEventLogDocType"::Order, MarkerBefore + 60000);
        SpfyStore.SetLastOrdersImportedAt(RewoundMarker);
        SpfyStore.Get(StoreCode);
        SpfyOrderImportJQ.TryUpdateMarker(SpfyStore, "NPR SpfyEventLogDocType"::Order);

        // [THEN] the rewind stands
        Assert.AreEqual(RewoundMarker, LastOrdersImportedAt(StoreCode), 'A marker rewound during a cycle must not be overwritten by the session max the cycle was holding.');
    end;

    [Test]
    procedure UpdateSalesLines_LineWithoutFulfillmentOrSalesLine_IsAdded()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AddedLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExpectedQty: Decimal;
        ExpectedCount: Integer;
        ExistingLineId: Text[30];
        NewLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An order line that exists in Shopify but has neither a fulfillment nor a sales line of its own
        // - a line added to the order after the document was created - is put on the document, the way the legacy
        // importer does it. Dropping it silently would leave it off a document that is about to be posted.
        StoreCode := 'SPFYQTY1';
        ShopifyId := '916000000001';
        ExistingLineId := '916000000101';
        NewLineId := '916000000102';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(ExistingLineId, 100, SalesHeader, SalesLine);

        // [WHEN] the order comes back carrying a line the document does not have, and no fulfillments at all
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText(NewLineId, SalesLine."No.", 100, 2, '[]') + ']', '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the document has the extra line, carrying the order's open quantity and nothing to ship
        AddedLine.SetRange("Document Type", SalesHeader."Document Type");
        AddedLine.SetRange("Document No.", SalesHeader."No.");
        AddedLine.SetFilter("Line No.", '>%1', SalesLine."Line No.");
        Assert.IsTrue(AddedLine.FindFirst(), 'The line that is only in Shopify must be added to the document.');
        ExpectedQty := 2;
        Assert.AreEqual(ExpectedQty, AddedLine.Quantity, 'The added line must carry the quantity still open in Shopify.');
        ExpectedQty := 0;
        Assert.AreEqual(ExpectedQty, AddedLine."Qty. to Ship", 'Nothing was fulfilled, so the added line must not be shipped.');
        // Counted on the same filter, which already excludes the line the fixture created.
        ExpectedCount := 1;
        Assert.AreEqual(ExpectedCount, AddedLine.Count(), 'Exactly one line may be added.');
        Assert.AreEqual(NewLineId, SpfyAssignedIDMgt.GetAssignedShopifyID(AddedLine.RecordId(), "NPR Spfy ID Type"::"Entry ID"),
            'The added line must carry the Shopify order line ID. Without it the line is invisible to the ID lookup and the next pass adds it again.');
    end;

    [Test]
    procedure AddNewSaleLine_ShopifyReportsNoTax_ForcesZeroVATPercent()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AddedLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExpectedVATPct: Decimal;
        ExistingLineId: Text[30];
        NewLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] Shopify's tax data wins over the VAT posting setup, including when Shopify reports no tax at all.
        // CalculateVAT cannot tell "0 %" from "no tax data", and the write is unconditional on purpose so the document
        // matches what the customer was charged in Shopify. That is a deliberate decision, so it is pinned here instead
        // of being rediscovered as a bug - and pinned against a setup that really does carry a rate.
        StoreCode := 'SPFYVAT1';
        ShopifyId := '917000000001';
        ExistingLineId := '917000000101';
        NewLineId := '917000000102';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(ExistingLineId, 100, SalesHeader, SalesLine);
        LibrarySpfyImport.ApplyVATRateToSalesLine(25, SalesHeader, SalesLine);

        // [GIVEN] the item really is taxed in Business Central, or the assertion below would prove nothing
        ExpectedVATPct := 25;
        Assert.AreEqual(ExpectedVATPct, SalesLine."VAT %", 'The fixture line must carry the VAT rate of its posting setup.');

        // [WHEN] Shopify sends a line with an empty taxLines array (ItemLineNodeText always does)
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText(NewLineId, SalesLine."No.", 100, 2, '[]') + ']', '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the added line carries 0 %, not the 25 % of its posting setup
        AddedLine.SetRange("Document Type", SalesHeader."Document Type");
        AddedLine.SetRange("Document No.", SalesHeader."No.");
        AddedLine.SetFilter("Line No.", '>%1', SalesLine."Line No.");
        Assert.IsTrue(AddedLine.FindFirst(), 'The line that is only in Shopify must be added to the document.');
        ExpectedVATPct := 0;
        Assert.AreEqual(ExpectedVATPct, AddedLine."VAT %", 'A line Shopify reports without tax lines must land on the document with VAT % 0.');
    end;

    [Test]
    procedure UpdateSalesLines_LineWithoutFulfillmentOrSalesLine_IsNotAddedTwice()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AddedLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExpectedCount: Integer;
        ExistingLineId: Text[30];
        NewLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The line added on the first pass is recognized on the next one. The added line is matched only by its
        // assigned Shopify order line ID, so a line inserted without that ID is re-inserted on every retry of the same
        // entry and the document is posted with duplicated quantities.
        StoreCode := 'SPFYQTY6';
        ShopifyId := '916000000006';
        ExistingLineId := '916000000601';
        NewLineId := '916000000602';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(ExistingLineId, 100, SalesHeader, SalesLine);
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText(NewLineId, SalesLine."No.", 100, 2, '[]') + ']', '[]');

        // [WHEN] the same order is processed twice, the way a retry of the entry does it
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the line was added once
        AddedLine.SetRange("Document Type", SalesHeader."Document Type");
        AddedLine.SetRange("Document No.", SalesHeader."No.");
        AddedLine.SetFilter("Line No.", '>%1', SalesLine."Line No.");
        ExpectedCount := 1;
        Assert.AreEqual(ExpectedCount, AddedLine.Count(),
            'The line that is only in Shopify must be added exactly once, no matter how many times the entry is processed.');
    end;

    [Test]
    procedure UpdateSalesLines_UnfulfilledLine_RepricedOnlyWhenNotVirtual()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        VirtualHeader: Record "Sales Header";
        VirtualLine: Record "Sales Line";
        PlainHeader: Record "Sales Header";
        PlainLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExpectedPrice: Decimal;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A price edit on a line Shopify reports without a fulfillment reaches BC - unless the line is a
        // virtual item. The fulfilled path refuses that same delta outright (IsVirtualLineChanged compares Unit Price
        // and Line Discount Amount, and ValidateAndUpdateExistingSalesLineFromShopify raises VirtualItemExtraErr), so
        // repricing a virtual line here would invoice a provisioned ticket or voucher at an amount it was never issued
        // for. Both halves are asserted together: the plain line is the control that proves the virtual half is not
        // passing simply because no reprice happens on this path at all. The virtual item is a ticket rather than a
        // gift card on purpose: CacheGiftCardOrderLine puts every gift-card order line into the fulfillment buffer, so
        // a gift-card line resolves through the snapshot and never reaches the path this test is about.
        StoreCode := 'SPFYVRT1';
        ShopifyId := '918000000001';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());

        // [GIVEN] one document whose only line is a virtual item, and one whose only line is an ordinary item, both at 100
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine('918000000101', 100, VirtualHeader, VirtualLine);
        LibrarySpfyImport.MakeItemATicketItem(VirtualLine."No.");
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine('918000000102', 100, PlainHeader, PlainLine);

        // [WHEN] Shopify reports each of them at 250, with no fulfillments and the quantity unchanged
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText('918000000101', VirtualLine."No.", 250, 1, '[]') + ']', '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(VirtualHeader, OrderResponse, LogEntry);

        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText('918000000102', PlainLine."No.", 250, 1, '[]') + ']', '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(PlainHeader, OrderResponse, LogEntry);

        // [THEN] the ordinary line took the new price and the virtual line kept the one it was issued at
        PlainLine.Get(PlainLine."Document Type", PlainLine."Document No.", PlainLine."Line No.");
        ExpectedPrice := 250;
        Assert.AreEqual(ExpectedPrice, PlainLine."Unit Price", 'An unfulfilled ordinary line must take the price Shopify reports.');

        VirtualLine.Get(VirtualLine."Document Type", VirtualLine."Document No.", VirtualLine."Line No.");
        ExpectedPrice := 100;
        Assert.AreEqual(ExpectedPrice, VirtualLine."Unit Price", 'An unfulfilled virtual line must keep the price it was issued at - the fulfilled path refuses this change outright.');
    end;

    [Test]
    procedure UpdateSalesLines_NewVirtualLineOnlyInShopify_IsRefused()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExistingLineId: Text[30];
        NewLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The line that is only in Shopify is a gift card, i.e. a virtual item. Adding it would put an
        // unprovisioned voucher on a document that is about to be posted, so the add path has to refuse instead. The
        // classifier is reached with the Shopify order line id of the line being added, which is what lets it resolve
        // the line at all - the same argument that used to be blank on this path.
        StoreCode := 'SPFYQTY7';
        ShopifyId := '916000000007';
        ExistingLineId := '916000000701';
        NewLineId := '916000000702';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(ExistingLineId, 100, SalesHeader, SalesLine);

        // [WHEN] the order comes back with a gift-card line the document does not have, and no fulfillments at all
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.GiftCardLineNodeText(NewLineId, SalesLine."No.", 100, 1) + ']', '[]');
        asserterror SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] it stops and hands the change over. Nothing is read back: the error rolls the fixture back with it.
        Assert.ExpectedError('It is not possible to change virtual items');
    end;

    [Test]
    procedure UpdateSalesLines_ExistingLineWithoutFulfillment_DoesNotError()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        UpdatedLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExpectedQty: Decimal;
        OrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The other side of the previous test: a line that IS on the document and simply has nothing
        // fulfilled is normal - an order closed before everything shipped - and must pass without an error. This is
        // what keeps the check on unplaceable lines from firing on ordinary orders.
        // The quantities to post are not what this proves: UpdateSalesLinesFromJson zeroes them for every line up
        // front (SetQuantities), so asserting them alone could not fail. What is asserted is that the call went
        // through and left the line on the document.
        StoreCode := 'SPFYQTY2';
        ShopifyId := '916000000002';
        OrderLineId := '916000000201';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(OrderLineId, 100, SalesHeader, SalesLine);

        // [WHEN] the order comes back with that same line and no fulfillments
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText(OrderLineId, SalesLine."No.", 100, 1, '[]') + ']', '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the line survived, kept the quantity the order still holds, and has nothing left to post
        Assert.IsTrue(UpdatedLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No."), 'The line must still be on the document.');
        // The quantity is the assertion that carries this test: the two below are zeroed for every line by
        // SetQuantities before the branch under test even runs, so they hold no matter what it does.
        ExpectedQty := 1;
        Assert.AreEqual(ExpectedQty, UpdatedLine.Quantity, 'The quantity must stay what the order holds.');
        ExpectedQty := 0;
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Ship", 'A line without a fulfillment must not be shipped.');
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Invoice", 'A line without a fulfillment must not be invoiced.');
    end;

    [Test]
    procedure UpdateSalesLines_LineWithoutFulfillmentRepriced_FollowsShopify()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        UpdatedLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        DiscountAlloc: Text;
        Expected: Decimal;
        OrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A price or discount change made in Shopify on a line that is still unfulfilled has to reach the
        // document. The line for which a fulfillment exists is re-synced on every pass, so leaving the unfulfilled one
        // out means the amounts that get posted are whatever Shopify said when the document was created - money, not
        // cosmetics. The quantity is deliberately left unchanged here: that is the case the old early exit skipped, so
        // a test where the quantity also moves would pass either way.
        StoreCode := 'SPFYQTY8';
        ShopifyId := '916000000008';
        OrderLineId := '916000000801';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(OrderLineId, 100, SalesHeader, SalesLine);

        // [GIVEN] the line starts at the old price with no discount, so a later assertion of the new ones can fail
        Expected := 100;
        Assert.AreEqual(Expected, SalesLine."Unit Price", 'The fixture line must start at the old unit price.');
        Expected := 0;
        Assert.AreEqual(Expected, SalesLine."Line Discount Amount", 'The fixture line must start without a discount.');
        Expected := 1;
        Assert.AreEqual(Expected, SalesLine.Quantity, 'The fixture line must start at the quantity the order keeps.');

        // [WHEN] the order comes back with the same quantity but a new price and a discount, and no fulfillments
        DiscountAlloc := '[{"allocatedAmountSet":{"presentmentMoney":{"amount":"20.0"}}}]';
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText(OrderLineId, SalesLine."No.", 150, 1, DiscountAlloc) + ']', '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the line carries Shopify's price and discount, and its quantity is untouched
        UpdatedLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        Expected := 150;
        Assert.AreEqual(Expected, UpdatedLine."Unit Price", 'The unit price must follow Shopify even when the quantity did not change.');
        Expected := 20;
        Assert.AreEqual(Expected, UpdatedLine."Line Discount Amount", 'The line discount must follow Shopify even when the quantity did not change.');
        Expected := 1;
        Assert.AreEqual(Expected, UpdatedLine.Quantity, 'The quantity must stay what the order holds.');
    end;

    [Test]
    procedure ClosedEntry_DocumentAlreadyInvoiced_IsProcessedNotFailed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        UpdatedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The Ecommerce document of a closed entry is already invoiced - the entry did its job. It has to
        // end as Processed. Treating it as a failure would put a finished entry into Error, spend its retries and
        // eventually report it to Sentry as if something had gone wrong.
        StoreCode := 'SPFYPOST1';
        ShopifyId := '918000000001';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.CreateInvoicedEcomDocument(StoreCode, ShopifyId, EcomSalesHeader);
        LogEntry.SetRecFilter();
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [WHEN] the entry is processed again
        SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry);

        // [THEN] it completes instead of failing
        UpdatedEntry.Get(LogEntry."Entry No.");
        Assert.AreEqual(UpdatedEntry."Processing Status"::Processed, UpdatedEntry."Processing Status", 'An entry whose document is already invoiced must end as Processed.');

        LibrarySpfyImport.CleanupCommittedLogEntries(StoreCode, ShopifyId);
    end;

    [Test]
    procedure VirtualItems_CaptureDisabledAndNotCapturedExternally_Refused()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        PaymentTok: Label 'SPFYCARD', Locked = true;
    begin
        // [SCENARIO] A virtual item must not be issued before the customer has paid for it. With capture requests
        // disabled for the store, the payment can only count as settled when the mapping says it is captured
        // outside Business Central. Neither holds here, so the import refuses instead of issuing a voucher that
        // nobody paid for.
        StoreCode := 'SPFYCAP1';
        ShopifyId := '917000000001';
        // The store is enabled and the integration is on, so the only thing switching capture requests off is the
        // store's own field. A bare CreateStore would leave the store disabled and the check would refuse for that
        // reason instead - passing without proving anything about the setting this test is named after.
        LibrarySpfyImport.EnableStoreWithCaptureRequestsOff(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.CreateEcomDocWithVirtualItemAndCardPayment(StoreCode, ShopifyId, PaymentTok, false, EcomSalesHeader);

        // [WHEN] the import checks whether the virtual items can be captured
        asserterror SpfyEcomSalesDocImport.CheckVirtualItemsCanBeCaptured(EcomSalesHeader, LogEntry);

        // [THEN] it refuses and names the setup that has to change
        Assert.ExpectedError('cannot be issued before the payment has been captured');
    end;

    [Test]
    procedure VirtualItems_CapturedExternally_Allowed()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        EcomSalesPmtLine: Record "NPR Ecom Sales Pmt. Line";
        PaymentMapping: Record "NPR Magento Payment Mapping";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        PaymentTok: Label 'SPFYEXTCARD', Locked = true;
    begin
        // [SCENARIO] Same setup, except the payment mapping declares the payment is captured outside Business
        // Central. Then there is nothing for the integration to capture and the virtual items may be issued.
        StoreCode := 'SPFYCAP2';
        ShopifyId := '917000000002';
        LibrarySpfyImport.EnableStoreWithCaptureRequestsOff(StoreCode); // same setup as the refusing test
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.CreateEcomDocWithVirtualItemAndCardPayment(StoreCode, ShopifyId, PaymentTok, true, EcomSalesHeader);

        // [GIVEN] the fixture really reaches the branch under test. The check exits early on three separate
        // conditions, so without these the test would be green on an emptied check body, on a document with no
        // virtual items, and on a payment-line filter that matches nothing.
        EcomSalesHeader.Get(EcomSalesHeader."Entry No.");
        Assert.IsTrue(EcomSalesHeader."Virtual Items Exist", 'The document must carry virtual items, or the check exits before it looks at any payment.');
        EcomSalesPmtLine.SetRange("Document Entry No.", EcomSalesHeader."Entry No.");
        EcomSalesPmtLine.SetRange("Payment Method Type", EcomSalesPmtLine."Payment Method Type"::"Payment Method");
        EcomSalesPmtLine.SetFilter(Amount, '<>%1', 0);
        Assert.AreEqual(1, EcomSalesPmtLine.Count(), 'Exactly one payment line must match the filters the check itself applies.');
        Assert.IsTrue(PaymentMapping.Get(PaymentTok, PaymentTok), 'The payment mapping the payment line resolves to must exist.');
        Assert.IsTrue(PaymentMapping."Captured Externally", 'The mapping must be marked as captured externally - that is the only thing that allows the issue here.');

        // [WHEN + THEN] the check passes without raising
        SpfyEcomSalesDocImport.CheckVirtualItemsCanBeCaptured(EcomSalesHeader, LogEntry);
    end;

    [Test]
    procedure Capture_EcommerceLineBlocked_RaisesTheReason()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        PaymentLine: Record "NPR Magento Payment Line";
        TempRequest: Record "NPR PG Payment Request" temporary;
        TempResponse: Record "NPR PG Payment Response" temporary;
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        PaymentTok: Label 'SPFYPGCARD1', Locked = true;
    begin
        // [SCENARIO] A capture that cannot be sent has to be raised as an error when the payment line belongs to an
        // ecommerce document. The ecommerce pipeline never reads the gateway response - it only sees whether the
        // gateway errored - so returning quietly leaves the payment line uncaptured, the document without an error
        // message, and the import free to post a document nobody has paid for.
        StoreCode := 'SPFYPG1';
        ShopifyId := '919000000001';
        LibrarySpfyImport.EnableStoreWithCaptureRequestsOff(StoreCode);
        // The event log entry is the only thing that resolves the store code for an ecommerce document (that branch
        // never sets a RecordId for the assigned-id fallback to read). Without it the store code would be blank and
        // the capture would be refused because no store matched, not because of the store's own setting.
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.CreateEcomDocWithGatewayPaymentLine(StoreCode, ShopifyId, PaymentTok, false, 0D, false, EcomSalesHeader, PaymentLine);
        LibrarySpfyImport.InitEcomCaptureRequest(EcomSalesHeader, PaymentLine, TempRequest);

        // [GIVEN] the integration is on for this store and capture requests are the only thing switched off
        Assert.IsTrue(SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::" ", StoreCode), 'The store must be integrated, or the block below would prove nothing about capture requests.');
        Assert.IsFalse(SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Payment Capture Requests", StoreCode), 'Capture requests must be off for this store.');

        // [WHEN] the gateway is asked to capture that payment line
        asserterror SpfyPaymentGatewayHdlr.Capture(TempRequest, TempResponse);

        // [THEN] the reason reaches the caller as an error instead of only the interaction log
        Assert.ExpectedError('Either sending capture requests is disabled');
    end;

    [Test]
    procedure Capture_EcommerceLineAlreadyCaptured_IsNotBlocked()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        LogEntry: Record "NPR Spfy Event Log Entry";
        PaymentLine: Record "NPR Magento Payment Line";
        RequestedPaymentLine: Record "NPR Magento Payment Line";
        TempRequest: Record "NPR PG Payment Request" temporary;
        TempResponse: Record "NPR PG Payment Response" temporary;
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        RequestedShopifyId: Text[30];
        CapturedTok: Label 'SPFYPGEXT2', Locked = true;
        RequestedTok: Label 'SPFYPGREQ2', Locked = true;
    begin
        // [SCENARIO] The block is only for a payment that still has to be captured. A line that is already captured -
        // which is how an externally captured mapping arrives, born with "Date Captured" stamped from the document's
        // received date - and a line whose capture is already in flight both have nothing left to capture, so the
        // disabled setting must not turn them into an import failure.
        StoreCode := 'SPFYPG2';
        ShopifyId := '919000000002';
        RequestedShopifyId := '919000000012';
        LibrarySpfyImport.EnableStoreWithCaptureRequestsOff(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.CreateEcomDocWithGatewayPaymentLine(StoreCode, ShopifyId, CapturedTok, true, WorkDate(), false, EcomSalesHeader, PaymentLine);
        LibrarySpfyImport.InitEcomCaptureRequest(EcomSalesHeader, PaymentLine, TempRequest);

        // [GIVEN] the line really is captured. A fixture that left this at 0D would be blocked by the guard, and the
        // test would report a failure for the one configuration the guard exists to protect.
        Assert.AreNotEqual(0D, PaymentLine."Date Captured", 'An externally captured line must carry a capture date.');

        // [WHEN] the gateway is asked to capture that line
        SpfyPaymentGatewayHdlr.Capture(TempRequest, TempResponse);

        // [THEN] it returns without raising, and the refusal is still reported through the response. Both halves are
        // asserted: without the response check this test would also be green if the capture had gone through to
        // Shopify instead of being blocked, which is a different behaviour with the same silence.
        Assert.IsFalse(TempResponse."Response Success", 'The capture is still blocked - it must not be reported as accepted.');
        Assert.AreEqual(TempResponse."Reported Operation Status"::Failure, TempResponse."Reported Operation Status", 'The blocked capture must still report a failed operation.');

        // [WHEN] the same happens for a line whose capture was already requested
        Clear(TempResponse);
        LibrarySpfyImport.CreateEcomDocWithGatewayPaymentLine(StoreCode, RequestedShopifyId, RequestedTok, false, 0D, true, EcomSalesHeader, RequestedPaymentLine);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, RequestedShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InitEcomCaptureRequest(EcomSalesHeader, RequestedPaymentLine, TempRequest);
        Assert.IsTrue(RequestedPaymentLine."Capture Requested", 'The second line must carry a capture request, which is the other half of the guard.');

        // [THEN] that one is not blocked either, and reports the same way
        SpfyPaymentGatewayHdlr.Capture(TempRequest, TempResponse);
        Assert.IsFalse(TempResponse."Response Success", 'A capture already in flight must not be reported as accepted either.');
        Assert.AreEqual(TempResponse."Reported Operation Status"::Failure, TempResponse."Reported Operation Status", 'A capture already in flight must still report a failed operation.');
    end;

    [Test]
    procedure Capture_LegacyPaymentLineBlocked_ExitsSilently()
    var
        SalesHeader: Record "Sales Header";
        PaymentLine: Record "NPR Magento Payment Line";
        TempRequest: Record "NPR PG Payment Request" temporary;
        TempResponse: Record "NPR PG Payment Response" temporary;
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The legacy flow reads the gateway response, and its own post-invoice route only reports a blocked
        // capture with a message. Its payment lines never carry an ecommerce sale id, and that is exactly what keeps
        // the ecommerce error off this path: the block must stay a failed response, not an error.
        StoreCode := 'SPFYPG3';
        ShopifyId := '919000000003';
        LibrarySpfyImport.EnableStoreWithCaptureRequestsOff(StoreCode);
        LibrarySpfyImport.CreateLegacySalesDocWithGatewayPaymentLine(StoreCode, 'SPFYPG-L03', ShopifyId, SalesHeader, PaymentLine);
        TempRequest.Init();
        TempRequest."Document Table No." := Database::"Sales Header";
        TempRequest."Document System Id" := SalesHeader.SystemId;
        TempRequest."Payment Line System Id" := PaymentLine.SystemId;

        // [GIVEN] the line is not linked to an ecommerce document
        Assert.IsTrue(IsNullGuid(PaymentLine."NPR Inc Ecom Sale Id"), 'A legacy payment line must not carry an ecommerce sale id.');

        // [WHEN] the gateway is asked to capture it
        SpfyPaymentGatewayHdlr.Capture(TempRequest, TempResponse);

        // [THEN] it does not raise, and reports the refusal through the response
        Assert.IsFalse(TempResponse."Response Success", 'A blocked capture must not be reported as accepted.');
        Assert.AreEqual(TempResponse."Reported Operation Status"::Failure, TempResponse."Reported Operation Status", 'A blocked capture must report a failed operation.');
    end;

    [Test]
    procedure UpdateSalesLines_VirtualItemQuantityChanged_Errors()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        OrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A virtual item was already provisioned - its voucher issued against the quantity on the line -
        // so a quantity that no longer matches cannot be followed silently. The import stops and hands it over,
        // the same answer the path for lines that do have a fulfillment gives.
        StoreCode := 'SPFYQTY4';
        ShopifyId := '916000000004';
        OrderLineId := '916000000401';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(OrderLineId, 100, SalesHeader, SalesLine);
        // A ticket item, not a gift card: gift-card order lines are put into the fulfillment buffer by
        // CacheGiftCardOrderLine, so they are handled by the fulfilled path and never reach the guard tested here.
        LibrarySpfyImport.MakeItemATicketItem(SalesLine."No.");

        // [WHEN] the order comes back saying that virtual line now holds 5 units, with no fulfillment
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText(OrderLineId, SalesLine."No.", 100, 5, '[]') + ']', '[]');
        asserterror SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] it stops. Nothing is read back afterwards on purpose: an error inside asserterror rolls the whole
        // transaction back, fixture included, so any assertion about the line would be asserting against data that
        // no longer exists - and the rollback itself already guarantees nothing was rewritten.
        Assert.ExpectedError('It is not possible to change virtual items');
    end;

    [Test]
    procedure UpdateSalesLines_ReturnOrder_QuantityUntouched()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        UpdatedLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExpectedQty: Decimal;
        OrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The quantity correction is for orders only. A return arrives as one line per refund line, all
        // carrying the same Shopify line id, so several of them resolve to the same sales line and correcting the
        // quantity would overwrite it again and again with the last refund's number. The guard reads the log
        // entry's document type, which is what this drives - the header itself stays an order, as it is on the
        // path where the correction would otherwise run.
        StoreCode := 'SPFYQTY5';
        ShopifyId := '916000000005';
        OrderLineId := '916000000501';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(OrderLineId, 100, SalesHeader, SalesLine);
        SalesLine.Validate(Quantity, 3);
        SalesLine.Modify(true);

        // [WHEN] the return comes back claiming 5 units on that line, with no fulfillment
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText(OrderLineId, SalesLine."No.", 100, 5, '[]') + ']', '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the quantity is left alone
        UpdatedLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        ExpectedQty := 3;
        Assert.AreEqual(ExpectedQty, UpdatedLine.Quantity, 'A return must not have its quantity corrected from the order.');
    end;

    [Test]
    procedure UpdateSalesLines_CancelledFulfillment_QuantityFollowsTheOrder()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        UpdatedLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExpectedQty: Decimal;
        OrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A fulfillment for 3 of the 5 ordered units left the line at quantity 3. The fulfillment is then
        // cancelled in Shopify, so the line comes back with no fulfillment at all. The quantity has to follow the
        // order (5), not the fulfillment that no longer exists - otherwise the document keeps reserving 3 units
        // nobody is shipping, and anyone posting the rest by hand ships them.
        StoreCode := 'SPFYQTY3';
        ShopifyId := '916000000003';
        OrderLineId := '916000000301';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(OrderLineId, 100, SalesHeader, SalesLine);
        SalesLine.Validate(Quantity, 3); // what the earlier fulfillment left behind
        SalesLine.Modify(true);

        // [WHEN] the order comes back with 5 units on that line and no fulfillments
        // The SKU is the item the fixture just created, not a literal: the line has to resolve back to that item or
        // the quantity correction is skipped and this test would pass or fail on what another test left behind.
        OrderResponse := LibrarySpfyImport.WrapOrderText(ShopifyId, '[' + LibrarySpfyImport.ItemLineNodeText(OrderLineId, SalesLine."No.", 100, 5, '[]') + ']', '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the line carries what the order says, and still has nothing to post
        UpdatedLine.Get(SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No.");
        ExpectedQty := 5;
        Assert.AreEqual(ExpectedQty, UpdatedLine.Quantity, 'The quantity must follow the order, not the cancelled fulfillment.');
        ExpectedQty := 0;
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Ship", 'Nothing is fulfilled, so nothing may be shipped.');
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Invoice", 'Nothing is fulfilled, so nothing may be invoiced.');
    end;

    [Test]
    procedure ExpandSelectionToSiblings_EmptySelection_ReturnsNothing()
    var
        ExistingEntry: Record "NPR Spfy Event Log Entry";
        ExpandedEntries: Record "NPR Spfy Event Log Entry";
        SelectedEntries: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
    begin
        // [SCENARIO] Nothing selected must expand to nothing. Returning an unfiltered record instead would hand the
        // page actions every log entry in the database - processing all of them, or discarding all their order data.
        StoreCode := 'SPFYLOGEX';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(ExistingEntry, StoreCode, '915000000001', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());

        // [WHEN] an empty selection is expanded
        SelectedEntries.SetRange("Entry No.", 0); // no entry can have number zero
        SpfyEventLogMgt.ExpandSelectionToSiblings(SelectedEntries, ExpandedEntries);

        // [THEN] the result is empty, not the whole table. Asserted through FindSet, which honours the marks the
        // expansion sets; IsEmpty answers on the filters alone and would not see them.
        Assert.IsFalse(ExpandedEntries.FindSet(), 'An empty selection must not expand to any entry.');
    end;

    [Test]
    procedure ExpandSelectionToSiblings_PullsOpenAndClosedSiblings()
    var
        CancelledEntry: Record "NPR Spfy Event Log Entry";
        ClosedEntry: Record "NPR Spfy Event Log Entry";
        ExpandedEntries: Record "NPR Spfy Event Log Entry";
        OpenEntry: Record "NPR Spfy Event Log Entry";
        OtherOrderEntry: Record "NPR Spfy Event Log Entry";
        SelectedEntries: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        ClosedFound: Boolean;
        OpenFound: Boolean;
        CancelledFound: Boolean;
        OtherOrderFound: Boolean;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] Selecting the closed entry of an order pulls in its open sibling, because the closed one cannot
        // complete while the open one is pending. A cancelled sibling and another order stay out.
        StoreCode := 'SPFYLOGEY';
        ShopifyId := '915000000002';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(OpenEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(ClosedEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(CancelledEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Cancelled, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(OtherOrderEntry, StoreCode, '915000000003', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());

        // [WHEN] only the closed entry is selected
        SelectedEntries.SetRange("Entry No.", ClosedEntry."Entry No.");
        SpfyEventLogMgt.ExpandSelectionToSiblings(SelectedEntries, ExpandedEntries);

        // [THEN] the open sibling comes along, the cancelled one and another order do not.
        // Membership is tested by iterating: Record.Get() reads by primary key and ignores both filters and marks,
        // so it answers "does this row exist" - not "is it in the expanded set" - and would pass for every entry.
        Assert.IsTrue(ExpandedEntries.FindSet(), 'The expansion must return something.');
        repeat
            case ExpandedEntries."Entry No." of
                ClosedEntry."Entry No.":
                    ClosedFound := true;
                OpenEntry."Entry No.":
                    OpenFound := true;
                CancelledEntry."Entry No.":
                    CancelledFound := true;
                OtherOrderEntry."Entry No.":
                    OtherOrderFound := true;
            end;
        until ExpandedEntries.Next() = 0;

        Assert.IsTrue(ClosedFound, 'The selected entry must be included.');
        Assert.IsTrue(OpenFound, 'The open sibling must be included.');
        Assert.IsFalse(CancelledFound, 'A cancelled sibling must not be pulled in.');
        Assert.IsFalse(OtherOrderFound, 'Another order must not be pulled in.');
    end;

    [Test]
    procedure ExpandSelectionToSiblings_ScopedByStoreAndDocType()
    var
        SelectedEntry: Record "NPR Spfy Event Log Entry";
        SameStoreSameTypeSibling: Record "NPR Spfy Event Log Entry";
        OtherStoreEntry: Record "NPR Spfy Event Log Entry";
        OtherDocTypeEntry: Record "NPR Spfy Event Log Entry";
        ExpandedEntries: Record "NPR Spfy Event Log Entry";
        SelectedEntries: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        SelectedFound: Boolean;
        SameStoreSameTypeFound: Boolean;
        OtherStoreFound: Boolean;
        OtherDocTypeFound: Boolean;
        StoreCode1: Code[20];
        StoreCode2: Code[20];
        ShopifyId: Text[30];
        ExpectedCount: Integer;
    begin
        // [SCENARIO] Thread 50 nit 11: ExpandSelectionToSiblings must scope by Store Code AND Document Type.
        // A same-Shopify-ID entry in another store, or of another Document Type, must not be pulled into the
        // expansion - otherwise selecting one store's order would drag in another store's log, or reprocessing
        // an Order would sweep in the paired Return Order and vice versa.
        StoreCode1 := 'SPFYLOGSC1';
        StoreCode2 := 'SPFYLOGSC2';
        ShopifyId := '930000000001';
        LibrarySpfyImport.CreateStore(StoreCode1);
        LibrarySpfyImport.CreateStore(StoreCode2);

        // [GIVEN] four entries sharing the same Shopify ID: the selected Open row in STORE1/Order, a closed
        // sibling in STORE1/Order (must expand), a same-ID Open row in STORE2 (must not expand - different
        // store), and a same-ID Open Return Order in STORE1 (must not expand - different doc type).
        LibrarySpfyImport.InsertOrderLogEntry(SelectedEntry, StoreCode1, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(SameStoreSameTypeSibling, StoreCode1, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(OtherStoreEntry, StoreCode2, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(OtherDocTypeEntry, StoreCode1, ShopifyId, "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());

        // [WHEN] only the STORE1/Order/Open entry is selected
        SelectedEntries.SetRange("Entry No.", SelectedEntry."Entry No.");
        SpfyEventLogMgt.ExpandSelectionToSiblings(SelectedEntries, ExpandedEntries);

        // [THEN] only the selected entry and its same-store, same-doc-type sibling are in the expansion.
        // Membership is tested by iterating: Record.Get() reads by primary key and ignores both filters and
        // marks, so it answers "does this row exist" - not "is it in the expanded set" - and would pass for
        // every entry.
        Assert.IsTrue(ExpandedEntries.FindSet(), 'The expansion must return something.');
        repeat
            case ExpandedEntries."Entry No." of
                SelectedEntry."Entry No.":
                    SelectedFound := true;
                SameStoreSameTypeSibling."Entry No.":
                    SameStoreSameTypeFound := true;
                OtherStoreEntry."Entry No.":
                    OtherStoreFound := true;
                OtherDocTypeEntry."Entry No.":
                    OtherDocTypeFound := true;
            end;
        until ExpandedEntries.Next() = 0;

        ExpectedCount := 2;
        Assert.AreEqual(ExpectedCount, ExpandedEntries.Count(), 'Only the selected entry and its same-store, same-doc-type sibling belong in the expansion.');
        Assert.IsTrue(SelectedFound, 'The selected entry must be included.');
        Assert.IsTrue(SameStoreSameTypeFound, 'The same-store, same-doc-type sibling must be included.');
        Assert.IsFalse(OtherStoreFound, 'A same-Shopify-ID entry from another store must not be pulled in.');
        Assert.IsFalse(OtherDocTypeFound, 'A same-Shopify-ID entry of another Document Type must not be pulled in.');
    end;

    [Test]
    procedure DiscardStoredOrderData_Selection_DiscardsEveryEntry()
    var
        ErrorEntry: Record "NPR Spfy Event Log Entry";
        PostponedEntry: Record "NPR Spfy Event Log Entry";
        ProcessedEntry: Record "NPR Spfy Event Log Entry";
        ReadyEntry: Record "NPR Spfy Event Log Entry";
        SelectedEntries: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        DiscardedCount: Integer;
        ExpectedCount: Integer;
    begin
        // [SCENARIO] "Get Order from Shopify and Process" guarantees a fresh order, so every selected entry loses
        // its stored order data whatever its processing status - nothing stale may survive to be replayed.
        StoreCode := 'SPFYLOGDA';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(ErrorEntry, StoreCode, '911000000001', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetFailedWithOrderData(ErrorEntry, 3);
        LibrarySpfyImport.InsertOrderLogEntry(ReadyEntry, StoreCode, '911000000002', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingStateWithOrderData(ReadyEntry, ReadyEntry."Processing Status"::Ready, 3);
        LibrarySpfyImport.InsertOrderLogEntry(PostponedEntry, StoreCode, '911000000003', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingStateWithOrderData(PostponedEntry, PostponedEntry."Processing Status"::Postponed, 3);
        LibrarySpfyImport.InsertOrderLogEntry(ProcessedEntry, StoreCode, '911000000004', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingStateWithOrderData(ProcessedEntry, ProcessedEntry."Processing Status"::Processed, 3);

        // [WHEN] all four entries are selected for a fresh download
        SelectedEntries.SetRange("Store Code", StoreCode);
        DiscardedCount := SpfyEventLogMgt.DiscardStoredOrderData(SelectedEntries);

        // [THEN] all four lost their stored order data
        ExpectedCount := 4;
        Assert.AreEqual(ExpectedCount, DiscardedCount, 'Every selected entry must be counted.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(ErrorEntry."Entry No."), 'A failed entry must be downloaded again.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(ReadyEntry."Entry No."), 'A Ready entry must be downloaded again.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(PostponedEntry."Entry No."), 'A Postponed entry must be downloaded again.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(ProcessedEntry."Entry No."), 'A Processed entry must be downloaded again.');

        // [THEN] and each of them is restarted: retries back to zero and the wait lifted
        PostponedEntry.Find();
        ExpectedCount := 0;
        Assert.AreEqual(ExpectedCount, PostponedEntry."Process Retry Count", 'The retry count must be reset.');
        Assert.IsFalse(PostponedEntry.Postponed, 'The entry must no longer be postponed.');
        Assert.AreEqual(0DT, PostponedEntry."Not Before Date-Time", 'The wait must be lifted.');
    end;

    [Test]
    procedure DiscardStoredOrderData_MarkerRollback_OnlyAffectsFailedEntries()
    var
        ErrorEntry: Record "NPR Spfy Event Log Entry";
        PostponedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        DiscardedCount: Integer;
        ExpectedCount: Integer;
    begin
        // [SCENARIO] Moving an import marker back is an automatic, store-wide gesture, so unlike the page action it
        // only touches entries in Error. A Postponed entry is waiting on purpose and must keep its backoff.
        StoreCode := 'SPFYLOGDD';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(ErrorEntry, StoreCode, '911000000005', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetFailedWithOrderData(ErrorEntry, 3);
        LibrarySpfyImport.InsertOrderLogEntry(PostponedEntry, StoreCode, '911000000006', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetProcessingStateWithOrderData(PostponedEntry, PostponedEntry."Processing Status"::Postponed, 3);

        // [WHEN] the store's order marker is rewound
        DiscardedCount := SpfyEventLogMgt.DiscardStoredOrderData(StoreCode, "NPR SpfyEventLogDocType"::Order);

        // [THEN] only the failed entry is affected
        ExpectedCount := 1;
        Assert.AreEqual(ExpectedCount, DiscardedCount, 'Only the entry in Error may be counted.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(ErrorEntry."Entry No."), 'The failed entry must be downloaded again.');
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(PostponedEntry."Entry No."), 'A Postponed entry must keep waiting.');
        PostponedEntry.Find();
        ExpectedCount := 3;
        Assert.AreEqual(ExpectedCount, PostponedEntry."Process Retry Count", 'The backoff of a Postponed entry must not be cancelled.');
        Assert.IsTrue(PostponedEntry.Postponed, 'A Postponed entry must stay postponed.');
    end;

    [Test]
    procedure DiscardStoredOrderData_BoundedByStoreAndDocTypeOnly()
    var
        InScopeEntry: Record "NPR Spfy Event Log Entry";
        OtherDocTypeEntry: Record "NPR Spfy Event Log Entry";
        OtherStoreEntry: Record "NPR Spfy Event Log Entry";
        TooOldEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        AnHourAgo: DateTime;
        StoreCode: Code[20];
        OtherStoreCode: Code[20];
        DiscardedCount: Integer;
        ExpectedCount: Integer;
    begin
        // [SCENARIO] The store-wide variant is bounded by the store and by the document type, and by nothing else -
        // rewinding one store's order marker must reach every failed entry of that store and document type, and
        // nothing outside it.
        StoreCode := 'SPFYLOGDB';
        OtherStoreCode := 'SPFYLOGDC';
        AnHourAgo := CurrentDateTime() - 3600000;
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.CreateStore(OtherStoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(InScopeEntry, StoreCode, '912000000001', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetFailedWithOrderData(InScopeEntry, 3);
        LibrarySpfyImport.InsertOrderLogEntry(TooOldEntry, StoreCode, '912000000002', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, AnHourAgo - 3600000);
        LibrarySpfyImport.SetFailedWithOrderData(TooOldEntry, 3);
        LibrarySpfyImport.InsertOrderLogEntry(OtherDocTypeEntry, StoreCode, '912000000003', "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetFailedWithOrderData(OtherDocTypeEntry, 3);
        LibrarySpfyImport.InsertOrderLogEntry(OtherStoreEntry, OtherStoreCode, '912000000004', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.SetFailedWithOrderData(OtherStoreEntry, 3);

        // [WHEN] the order marker of the first store is rewound
        DiscardedCount := SpfyEventLogMgt.DiscardStoredOrderData(StoreCode, "NPR SpfyEventLogDocType"::Order);

        // [THEN] every failed order entry of that store is discarded, whatever its creation time, and nothing else is.
        // The old entry is the point: the marker is an updated_at watermark while an entry only carries the order's
        // createdAt, so bounding the discard on creation time would keep the stale payload on exactly the orders a
        // rewind has to refresh - the ones created long ago but updated recently.
        ExpectedCount := 2;
        Assert.AreEqual(ExpectedCount, DiscardedCount, 'Both failed order entries of that store must be counted.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(InScopeEntry."Entry No."), 'The in-scope entry must be discarded.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(TooOldEntry."Entry No."), 'An entry created long ago must be discarded too - it may have been updated since.');
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(OtherDocTypeEntry."Entry No."), 'A return order entry must be left alone.');
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(OtherStoreEntry."Entry No."), 'Another store must be left alone.');
    end;

    [Test]
    procedure SetLastOrdersImportedAt_MovedBack_DiscardsEveryFailedEntry()
    var
        SpfyStore: Record "NPR Spfy Store";
        InScopeEntry: Record "NPR Spfy Event Log Entry";
        TooOldEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        NowDT: DateTime;
        NewMarker: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] Moving the orders import marker back makes the job queue re-read that period, so the stored order
        // data of the store's failed entries is discarded and downloaded again - regardless of when the order was
        // created. The marker is an updated_at watermark while an entry only carries the order's createdAt, so bounding
        // the discard on creation time would keep the stale payload on the orders a rewind has to refresh: the ones
        // created before the new marker but updated after it.
        StoreCode := 'SPFYLOGM1';
        // Whole seconds: a DateTime is stored with about 3 ms of granularity, so a value carrying milliseconds
        // does not read back exactly as written and a rewrite of "the same" marker looks like a rollback. Shopify's
        // own updatedAt has second resolution, so this also matches what production ever stores.
        NowDT := RoundDateTime(CurrentDateTime(), 1000);
        NewMarker := NowDT - 7200000; // two hours ago
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastOrdersImportedAt(NowDT);
        LibrarySpfyImport.InsertOrderLogEntry(InScopeEntry, StoreCode, '913000000001', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, NowDT - 3600000);
        LibrarySpfyImport.SetFailedWithOrderData(InScopeEntry, 3);
        LibrarySpfyImport.InsertOrderLogEntry(TooOldEntry, StoreCode, '913000000002', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, NowDT - 10800000);
        LibrarySpfyImport.SetFailedWithOrderData(TooOldEntry, 3);

        // [WHEN] the operator moves the marker back through the store card gesture: the page first calls the codeunit
        // to rewind (which discards the stored order data of the store's failed entries) and then writes the marker
        // via the setter as a pure store.
        SpfyEventLogMgt.RewindImportMarker(StoreCode, "NPR SpfyEventLogDocType"::Order, NewMarker);
        SpfyStore.SetLastOrdersImportedAt(NewMarker);

        // [THEN] the marker is stored and every failed entry of the store loses its stored order data
        Assert.AreEqual(NewMarker, LastOrdersImportedAt(StoreCode), 'The new marker must be stored.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(InScopeEntry."Entry No."), 'An entry from the re-read period must be downloaded again.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(TooOldEntry."Entry No."), 'An entry created before the new marker must be downloaded again too - its order may have been updated after the marker.');
    end;

    [Test]
    procedure SetLastOrdersImportedAt_MovedForwardOrUnchanged_KeepsStoredData()
    var
        SpfyStore: Record "NPR Spfy Store";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        Assert: Codeunit Assert;
        NowDT: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] Only a rollback discards. The normal forward movement of the marker (and rewriting the same
        // value) must leave the failed entries and their stored order data alone.
        StoreCode := 'SPFYLOGM2';
        // Whole seconds: a DateTime is stored with about 3 ms of granularity, so a value carrying milliseconds
        // does not read back exactly as written and a rewrite of "the same" marker looks like a rollback. Shopify's
        // own updatedAt has second resolution, so this also matches what production ever stores.
        NowDT := RoundDateTime(CurrentDateTime(), 1000);
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastOrdersImportedAt(NowDT - 7200000);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, '913000000003', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, NowDT - 3600000);
        LibrarySpfyImport.SetFailedWithOrderData(LogEntry, 3);
        // Asserted before the act, so a failure below can only mean the marker write discarded it - not that the
        // fixture never stored anything in the first place.
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(LogEntry."Entry No."), 'The fixture must start with stored order data.');

        // [WHEN] the marker is written again unchanged and then moved forward
        SpfyStore.SetLastOrdersImportedAt(NowDT - 7200000);
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(LogEntry."Entry No."), 'Rewriting the same marker must not discard anything.');
        SpfyStore.SetLastOrdersImportedAt(NowDT);

        // [THEN] the marker moved and the stored order data survived
        Assert.AreEqual(NowDT, LastOrdersImportedAt(StoreCode), 'The new marker must be stored.');
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(LogEntry."Entry No."), 'Moving the marker forward must not discard anything.');
    end;

    [Test]
    procedure SetLastReturnsImportedAt_MovedBack_DiscardsReturnEntriesOnly()
    var
        SpfyStore: Record "NPR Spfy Store";
        OrderEntry: Record "NPR Spfy Event Log Entry";
        ReturnEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        NowDT: DateTime;
        NewMarker: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] The returns marker owns the return order entries only - rewinding it must not touch the
        // store's order entries, which are driven by their own marker.
        StoreCode := 'SPFYLOGM3';
        // Whole seconds: a DateTime is stored with about 3 ms of granularity, so a value carrying milliseconds
        // does not read back exactly as written and a rewrite of "the same" marker looks like a rollback. Shopify's
        // own updatedAt has second resolution, so this also matches what production ever stores.
        NowDT := RoundDateTime(CurrentDateTime(), 1000);
        NewMarker := NowDT - 7200000; // two hours ago
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastReturnsImportedAt(NowDT);
        LibrarySpfyImport.InsertOrderLogEntry(ReturnEntry, StoreCode, '913000000004', "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Open, NowDT - 3600000);
        LibrarySpfyImport.SetFailedWithOrderData(ReturnEntry, 3);
        LibrarySpfyImport.InsertOrderLogEntry(OrderEntry, StoreCode, '913000000005', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, NowDT - 3600000);
        LibrarySpfyImport.SetFailedWithOrderData(OrderEntry, 3);

        // [WHEN] the operator moves the returns marker back through the store card gesture: the page first calls the
        // codeunit to rewind (which discards the stored order data of the store's failed return entries) and then
        // writes the marker via the setter as a pure store.
        SpfyEventLogMgt.RewindImportMarker(StoreCode, "NPR SpfyEventLogDocType"::"Return Order", NewMarker);
        SpfyStore.SetLastReturnsImportedAt(NewMarker);

        // [THEN] the marker is stored and only the return order entry is discarded
        Assert.AreEqual(NewMarker, LastReturnsImportedAt(StoreCode), 'The new returns marker must be stored.');
        Assert.IsFalse(LibrarySpfyImport.HasOrderData(ReturnEntry."Entry No."), 'The return order entry must be downloaded again.');
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(OrderEntry."Entry No."), 'The order entry belongs to the orders marker and must be left alone.');
    end;

    [Test]
    procedure ClosedEntry_WaitsForUnprocessedOpenSibling()
    var
        ClosedEntry: Record "NPR Spfy Event Log Entry";
        OpenEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The Closed entry of an order must not run before the Open entry that creates the document.
        StoreCode := 'SPFYLOGSB';
        ShopifyId := '914000000001';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(OpenEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(ClosedEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());

        Assert.IsFalse(SpfyEventLogDocProcessr.TryCheckForUnprocessedEntry(ClosedEntry), 'The Closed entry must wait for its unprocessed Open sibling.');
    end;

    [Test]
    procedure ClosedEntry_NotBlockedByRetryExhaustedSibling()
    var
        ClosedEntry: Record "NPR Spfy Event Log Entry";
        OpenEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] A sibling that has exhausted its retries never completes on its own, so waiting for it would
        // strand the Closed entry too. Letting it through is safe: the Closed path creates and posts on its own.
        StoreCode := 'SPFYLOGSB';
        ShopifyId := '914000000002';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(OpenEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        OpenEntry."Processing Status" := OpenEntry."Processing Status"::Error;
        OpenEntry."Process Retry Count" := SpfyIntegrationMgt.GetMaxDocRetryCount() + 1;
        OpenEntry.Modify();
        LibrarySpfyImport.InsertOrderLogEntry(ClosedEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());

        Assert.IsTrue(SpfyEventLogDocProcessr.TryCheckForUnprocessedEntry(ClosedEntry), 'A terminally failed sibling must not block the Closed entry.');
    end;

    [Test]
    procedure ClosedEntry_NotBlockedBySiblingOfOtherDocumentType()
    var
        ClosedEntry: Record "NPR Spfy Event Log Entry";
        ReturnEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The wait is per document type: the return order entries of the same Shopify order are a
        // separate document flow and must not hold up the order's Closed entry.
        StoreCode := 'SPFYLOGSB';
        ShopifyId := '914000000003';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(ReturnEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(ClosedEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());

        Assert.IsTrue(SpfyEventLogDocProcessr.TryCheckForUnprocessedEntry(ClosedEntry), 'A sibling of another document type must not block the Closed entry.');
    end;

    [Test]
    procedure ProcessLogEntries_PostponedEntry_IsCountedSeparatelyNotAsSuccess()
    var
        ClosedEntry: Record "NPR Spfy Event Log Entry";
        OpenEntry: Record "NPR Spfy Event Log Entry";
        UpdatedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        NoErrors: Boolean;
        PostponedCount: Integer;
        ExpectedCount: Integer;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An entry that postponed itself imported nothing, so reporting the run as plainly completed tells
        // the operator the opposite of what happened. It is not an error either - the entry is waiting on purpose and
        // will be picked up again - so it is counted on its own. A Closed entry with an unprocessed Open sibling is the
        // production shape of that wait.
        StoreCode := 'SPFYPOSTP';
        ShopifyId := '920000000201';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(OpenEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LibrarySpfyImport.InsertOrderLogEntry(ClosedEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());

        // [GIVEN] the entry is not postponed to begin with, or the count below would not be caused by this run
        Assert.AreEqual(ClosedEntry."Processing Status"::Ready, ClosedEntry."Processing Status", 'The entry must start out ready to be processed.');
        ClosedEntry.SetRecFilter();
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [WHEN] only the Closed entry is processed
        NoErrors := SpfyEventLogDocProcessr.ProcessLogEntries(ClosedEntry, PostponedCount);

        // [THEN] the run reports no errors, but the postponement is reported separately
        UpdatedEntry.Get(ClosedEntry."Entry No.");
        Assert.AreEqual(UpdatedEntry."Processing Status"::Postponed, UpdatedEntry."Processing Status", 'The entry must have postponed itself waiting for its sibling.');
        Assert.IsTrue(NoErrors, 'A postponement is not an error.');
        ExpectedCount := 1;
        Assert.AreEqual(ExpectedCount, PostponedCount, 'A postponed entry must be counted, or the operator is told the import completed when nothing was imported.');

        LibrarySpfyImport.CleanupCommittedLogEntries(StoreCode, ShopifyId);
    end;

    [Test]
    procedure ProcessLogEntries_FailedEntry_IsReportedAsAnError()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        UpdatedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
        NoErrors: Boolean;
        PostponedCount: Integer;
        ExpectedCount: Integer;
        StoreCode: Code[20];
        Sku: Code[20];
        ItemNo: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] The other half of the classification, and the control for the test above: a failing entry still
        // has to come back as an error. Counting postponements separately must not have turned an error into one of
        // them. A first-import Cancelled entry has nothing to process and is the cheapest way to fail an entry.
        ShopifyId := '920000000202';
        LibrarySpfyImport.SetupSimpleItemOrder(StoreCode, Sku, ItemNo);
        LibrarySpfyImport.InitLogEntry(LogEntry, StoreCode, ShopifyId);
        LogEntry."Document Status" := LogEntry."Document Status"::Cancelled;
        LogEntry.Modify();
        LogEntry.SetRecFilter();
        Commit(); // processing reads the result of Codeunit.Run, which the platform only allows outside a write transaction

        // [WHEN] the entry is processed
        NoErrors := SpfyEventLogDocProcessr.ProcessLogEntries(LogEntry, PostponedCount);

        // [THEN] the run reports the failure and counts no postponement
        UpdatedEntry.Get(LogEntry."Entry No.");
        Assert.AreEqual(UpdatedEntry."Processing Status"::Error, UpdatedEntry."Processing Status", 'The entry must have failed.');
        Assert.IsFalse(NoErrors, 'A failed entry must be reported as an error.');
        ExpectedCount := 0;
        Assert.AreEqual(ExpectedCount, PostponedCount, 'A failed entry must not be counted as postponed.');

        LibrarySpfyImport.CleanupCommittedLogEntries(StoreCode, ShopifyId);
    end;

    [Test]
    procedure IsShopifyDocument_DiscriminatesOnDocumentSource()
    var
        EcomSalesHeader: Record "NPR Ecom Sales Header";
        SpfyEventLogDocProcessr: Codeunit "NPR Spfy Event Log DocProcessr";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] Whether an Ecommerce document belongs to Shopify is read off the document itself, not looked
        // up in the event log - so it answers correctly even for a document that has no log entry.
        EcomSalesHeader.Init();
        EcomSalesHeader."External No." := '915000000001';

        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Shopify;
        Assert.IsTrue(SpfyEventLogDocProcessr.IsShopifyDocument(EcomSalesHeader), 'A document with the Shopify source is a Shopify document.');

        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::Entria;
        Assert.IsFalse(SpfyEventLogDocProcessr.IsShopifyDocument(EcomSalesHeader), 'An Entria document is not a Shopify document.');

        EcomSalesHeader."Document Source" := EcomSalesHeader."Document Source"::API;
        Assert.IsFalse(SpfyEventLogDocProcessr.IsShopifyDocument(EcomSalesHeader), 'An API document is not a Shopify document.');
    end;

    [Test]
    procedure FulfilmentStatusFilter_AgreesWithWhatTheCacheCounts()
    var
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        CancelledCache: Codeunit "NPR Spfy Fulfillment Cache";
        SuccessCache: Codeunit "NPR Spfy Fulfillment Cache";
        Assert: Codeunit Assert;
        CancelledFulfilments: JsonArray;
        SuccessFulfilments: JsonArray;
        CancelledLineId: Text[30];
        SuccessLineId: Text[30];
    begin
        // [SCENARIO] Two separate status filters decide the same thing on the fetch path: one picks the fulfillments
        // whose line items are worth paging, the other (inside the cache) picks the fulfillments whose quantities
        // count. They have to agree. If the first ever said no where the second says yes, the cache would be asked for
        // lines that were never fetched: every line would read as unfulfilled, nothing would be left to post, and with
        // "Delete After Final Posting" on the document would be deleted anyway while the entry is marked Processed.
        SuccessLineId := '930000000001';
        CancelledLineId := '930000000002';
        SuccessFulfilments := SingleFulfilmentFixture('9301', SuccessLineId, 'SUCCESS');
        CancelledFulfilments := SingleFulfilmentFixture('9302', CancelledLineId, 'CANCELLED');
        SpfyOrderApiHelper.CacheFulfillment(SuccessFulfilments, SuccessCache);
        SpfyOrderApiHelper.CacheFulfillment(CancelledFulfilments, CancelledCache);

        // [THEN] the fulfillment whose quantities the cache counted is exactly the one whose lines are fetched
        Assert.IsTrue(SuccessCache.GetLineFromCache(SuccessLineId, TempSpfyFulfillmentBuffer), 'The successful fulfillment must reach the cache - otherwise the comparison below is meaningless.');
        Assert.IsTrue(SpfyOrderApiHelper.FulfilmentSucceeded(FirstFulfilmentOf(SuccessFulfilments)), 'The line items of a fulfillment the cache counts must be fetched.');

        // [THEN] and the one the cache ignores is skipped, which is where the request saving comes from
        Assert.IsFalse(CancelledCache.GetLineFromCache(CancelledLineId, TempSpfyFulfillmentBuffer), 'A cancelled fulfillment must not contribute quantities.');
        Assert.IsFalse(SpfyOrderApiHelper.FulfilmentSucceeded(FirstFulfilmentOf(CancelledFulfilments)), 'A cancelled fulfillment must not have its line items fetched.');
    end;

    /// <summary>One fulfillment carrying one line, in the shape SpfyOrderApiHelper.AddFulfilmentInfo produces.</summary>
    local procedure SingleFulfilmentFixture(FulfillmentId: Text; LineId: Text[30]; Status: Text) Fulfilments: JsonArray
    var
        Builder: TextBuilder;
    begin
        Builder.Append('[{"id":"gid://shopify/Fulfillment/' + FulfillmentId + '","status":"' + Status + '","displayStatus":"FULFILLED",');
        Builder.Append('"createdAt":"2026-06-23T11:58:31Z","updatedAt":"2026-06-23T11:58:32Z",');
        Builder.Append('"orderId":"gid://shopify/Order/18742205677613","email":"buyer@test.com",');
        Builder.Append('"fulfillmentLineItems":[{"cursor":"a","node":{"id":"gid://shopify/FulfillmentLineItem/' + FulfillmentId + '","quantity":1,');
        Builder.Append('"lineItem":{"id":"gid://shopify/LineItem/' + LineId + '","currentQuantity":1,"variant":{"price":"100.00"},"unfulfilledQuantity":0,"nonFulfillableQuantity":0,"isGiftCard":false,"originalUnitPriceSet":{"presentmentMoney":{"amount":"100.0"}}}}}]}]');
        Fulfilments := ParseJson(Builder.ToText()).AsArray();
    end;

    local procedure FirstFulfilmentOf(Fulfilments: JsonArray) Fulfilment: JsonObject
    var
        Token: JsonToken;
    begin
        Fulfilments.Get(0, Token);
        Fulfilment := Token.AsObject();
    end;

    [Test]
    procedure FulfilmentCountGuard_RequiresTheCountButAcceptsZero()
    var
        JsonHelper: Codeunit "NPR Json Helper";
        Assert: Codeunit Assert;
        MissingCount: JsonToken;
        ZeroCount: JsonToken;
        Expected: Integer;
    begin
        // [SCENARIO] Shopify's "fulfillments" is a plain list with a truncation argument, not a paginated connection,
        // so a short answer is invisible; the only way to detect it is to compare against the order's own
        // fulfillmentsCount. That guard has to distinguish an order with no fulfillments yet (count 0, a normal state
        // for a freshly closed order) from Shopify not answering at all - and it can only do so with the overload that
        // requires the value while accepting zero. With the plain required overload every order without a fulfillment
        // would fail; with an optional one a missing count silently reads as zero, the guard never fires, the cache
        // stays empty, nothing is left to post and the document is deleted anyway when
        // "Delete After Final Posting" is on. The fetch itself is HTTP-bound and cannot be driven from a test, so this
        // pins the one thing about it that can be: the contract the guard rests on.
        ZeroCount := ParseJson('{"data":{"order":{"fulfillmentsCount":{"count":0}}}}');
        MissingCount := ParseJson('{"data":{"order":{}}}');

        // [THEN] a genuine zero is a valid answer
        Expected := 0;
        Assert.AreEqual(Expected, JsonHelper.GetJInteger(ZeroCount, 'data.order.fulfillmentsCount.count', true, true), 'An order with no fulfillments must be accepted.');

        // [THEN] but only for the overload that allows it - the plain required one rejects the same payload
        asserterror JsonHelper.GetJInteger(ZeroCount, 'data.order.fulfillmentsCount.count', true);
        Assert.ExpectedError('Required value missing');

        // [THEN] and a missing count is refused either way, which is what makes the guard able to fire
        asserterror JsonHelper.GetJInteger(MissingCount, 'data.order.fulfillmentsCount.count', true, true);
        Assert.ExpectedError('Required value missing');
    end;

    [Test]
    procedure CheckFulfilmentsNotTruncated_CountAboveArrayLength_Errors()
    var
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        Assert: Codeunit Assert;
        ResponseBody: JsonToken;
        FulfilmentArr: JsonArray;
        OrderGIDLbl: Label 'gid://shopify/Order/1', Locked = true;
    begin
        // [SCENARIO] The truncation guard extracted from SpfyOrderApiHelper: when Shopify's reported count exceeds the
        // returned array length, the response was truncated and must be rejected.

        // [GIVEN] Shopify reports fulfillmentsCount=2 but the array carries only 1
        ResponseBody := ParseJson('{"data":{"order":{"fulfillmentsCount":{"count":2}}}}');
        Clear(FulfilmentArr);
        FulfilmentArr.Add(ParseJson('{"id":"x"}'));

        // [WHEN] the guard runs
        // [THEN] it errors with the truncation message
        asserterror SpfyAPIOrderHelper.CheckFulfilmentsNotTruncated(ResponseBody, FulfilmentArr, OrderGIDLbl);
        Assert.ExpectedError('fulfillments registered on the order');
    end;

    [Test]
    procedure CheckFulfilmentsNotTruncated_CountZeroEmptyArray_Passes()
    var
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        ResponseBody: JsonToken;
        FulfilmentArr: JsonArray;
        OrderGIDLbl: Label 'gid://shopify/Order/1', Locked = true;
    begin
        // [SCENARIO] The truncation guard must accept an honest empty response - fulfillmentsCount=0 with an empty
        // array is the normal shape of a freshly closed order and must not error.

        // [GIVEN] Shopify reports fulfillmentsCount=0 and the array is empty
        ResponseBody := ParseJson('{"data":{"order":{"fulfillmentsCount":{"count":0}}}}');
        Clear(FulfilmentArr);

        // [WHEN] the guard runs
        // [THEN] it must not raise - reaching the next line is the assertion
        SpfyAPIOrderHelper.CheckFulfilmentsNotTruncated(ResponseBody, FulfilmentArr, OrderGIDLbl);
    end;

    [Test]
    procedure CheckFulfilmentsNotTruncated_MissingCount_Errors()
    var
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        Assert: Codeunit Assert;
        ResponseBody: JsonToken;
        FulfilmentArr: JsonArray;
        OrderGIDLbl: Label 'gid://shopify/Order/1', Locked = true;
    begin
        // [SCENARIO] The truncation guard cannot silently treat a missing fulfillmentsCount as zero: the required-value
        // check underneath must raise so a malformed response is caught rather than accepted as empty.

        // [GIVEN] Shopify omits fulfillmentsCount entirely
        ResponseBody := ParseJson('{"data":{"order":{}}}');
        Clear(FulfilmentArr);

        // [WHEN] the guard runs
        // [THEN] the required-value check underneath raises
        asserterror SpfyAPIOrderHelper.CheckFulfilmentsNotTruncated(ResponseBody, FulfilmentArr, OrderGIDLbl);
        Assert.ExpectedError('Required value missing');
    end;

    [Test]
    procedure SafetyOverlapWindow_NeverCollapses()
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        Assert: Codeunit Assert;
    begin
        // [SCENARIO] The order and return list queries start this far before the stored marker, to absorb Shopify
        // search-index lag. An order that is not yet in Shopify's search index is never listed, so it applies no
        // marker ceiling and never reaches the event log - this buffer is its only protection, and undershooting
        // it loses orders silently and permanently.
        // This guards the collapse case only. The exact value is a margin, not a measurement, so pinning it here
        // would just restate the literal it is meant to protect.
        Assert.IsTrue(SpfyOrderApiHelper.GetSafetyOverlapWindow() > 0, 'The buffer must never collapse to zero.');
        Assert.IsTrue(
            SpfyOrderApiHelper.GetSafetyOverlapWindow() >= 6 * 60 * 1000,
            'The buffer must stay at or above the 6 minutes this integration relied on before the marker was reworked. Polling more often does not compensate: the window is anchored to the stored marker, not to the time of the last poll.');
    end;

    [Test]
    procedure OrderListFilter_StartsAtTheBufferedLowerBound()
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        Assert: Codeunit Assert;
        FromDT: DateTime;
        ExpectedLowerBound: Text;
    begin
        // [SCENARIO] The list filter starts one buffer before the marker it is handed. The filter is built once per poll
        // cycle and reused for every page, because a Shopify cursor points into the result set of one specific query -
        // so this is also the only place the buffer is applied, and dropping the subtraction here would silently narrow
        // the window for both the order and the return query.
        FromDT := CreateDateTime(DMY2Date(17, 8, 2026), 120000T);
        ExpectedLowerBound := Format(FromDT - SpfyOrderApiHelper.GetSafetyOverlapWindow(), 0, 9);

        // [THEN] both list filters carry that lower bound, not the raw marker
        Assert.IsTrue(
            SpfyOrderApiHelper.OrderListFilter("NPR SpfyAPIDocumentStatus"::Open, FromDT).Contains(ExpectedLowerBound),
            'The order list filter must start one search-index-lag buffer before the marker.');
        Assert.IsTrue(
            SpfyOrderApiHelper.ReturnListFilter(FromDT).Contains(ExpectedLowerBound),
            'The return list filter must start one search-index-lag buffer before the marker.');
        Assert.IsFalse(
            SpfyOrderApiHelper.OrderListFilter("NPR SpfyAPIDocumentStatus"::Open, FromDT).Contains(Format(FromDT, 0, 9)),
            'The raw marker must not reach the filter - that would drop the buffer.');
    end;

    [Test]
    procedure PollInterval_BacksOffWhenLittleNewWorkWasFound()
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        Assert: Codeunit Assert;
        OneSecond: Duration;
        FiveSeconds: Duration;
        TenSeconds: Duration;
        OneMinute: Duration;
    begin
        // [SCENARIO] The poller used to sleep a fixed second between cycles. The interval now scales to the number
        //            of orders/returns the previous cycle actually wrote to the event log, so a quiet store stops
        //            hammering the Shopify API once per second.
        // The expected values are Durations, not Integers: Assert.AreEqual compares the variant type as well, so an
        // integer literal fails against a Duration return value before it ever compares the number.
        OneSecond := 1000;
        FiveSeconds := 5 * 1000;
        TenSeconds := 10 * 1000;
        OneMinute := 60 * 1000;

        Assert.AreEqual(OneSecond, SpfyOrderImportJQ.PollInterval(101), 'More than 100 new documents keeps the one second cadence.');
        Assert.AreEqual(FiveSeconds, SpfyOrderImportJQ.PollInterval(100), '100 new documents falls in the 50-100 band.');
        Assert.AreEqual(FiveSeconds, SpfyOrderImportJQ.PollInterval(50), '50 new documents falls in the 50-100 band.');
        Assert.AreEqual(TenSeconds, SpfyOrderImportJQ.PollInterval(49), '49 new documents falls in the 10-50 band.');
        Assert.AreEqual(TenSeconds, SpfyOrderImportJQ.PollInterval(10), '10 new documents falls in the 10-50 band.');
        Assert.AreEqual(OneMinute, SpfyOrderImportJQ.PollInterval(9), 'Fewer than 10 new documents backs off to a minute.');
        Assert.AreEqual(OneMinute, SpfyOrderImportJQ.PollInterval(0), 'An idle cycle backs off to a minute.');
    end;

    [Test]
    procedure SentryThrottlePerStoreAndDocumentType()
    var
        SpfyOrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        Assert: Codeunit Assert;
        BaseDT: DateTime;
    begin
        // [SCENARIO] A persistent import failure is polled every cycle. Sentry must receive at most one event per
        //            hour per store AND document type, so a broken order import does not mask a broken return import.
        BaseDT := CreateDateTime(DMY2Date(1, 1, 2024), 080000T);

        Assert.IsTrue(
            SpfyOrderImportJQ.ShouldEmitSentryError('ZZTEST', "NPR SpfyEventLogDocType"::Order, BaseDT),
            'The first order failure should emit.');
        Assert.IsFalse(
            SpfyOrderImportJQ.ShouldEmitSentryError('ZZTEST', "NPR SpfyEventLogDocType"::Order, BaseDT + (59 * 60 * 1000)),
            'A repeat within the hour should be suppressed.');

        // [THEN] the return-order throttle is tracked separately and still emits
        Assert.IsTrue(
            SpfyOrderImportJQ.ShouldEmitSentryError('ZZTEST', "NPR SpfyEventLogDocType"::"Return Order", BaseDT + (59 * 60 * 1000)),
            'A return failure has its own throttle key and should emit.');

        Assert.IsTrue(
            SpfyOrderImportJQ.ShouldEmitSentryError('ZZTEST', "NPR SpfyEventLogDocType"::Order, BaseDT + (61 * 60 * 1000)),
            'After the throttle window the order failure should re-emit.');
    end;

    [Test]
    procedure InsertShopifyLog_UnresolvableCurrency_StillLogsTheOrder()
    var
        Currency: Record Currency;
        LogEntry: Record "NPR Spfy Event Log Entry";
        LoggedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        OrderNode: JsonToken;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        UnknownCurrencyTok: Label 'XTS', Locked = true;
    begin
        // [SCENARIO] The currency Shopify sent has no Currency card in Business Central. That is a setup problem,
        // not a problem with the order, so the order must still reach the event log - otherwise it is invisible to
        // the operator and the import marker has to be held back at it until the setup is corrected.
        StoreCode := 'SPFYCUR1';
        ShopifyId := '914000000001';
        LibrarySpfyImport.CreateStore(StoreCode);
        Currency.SetRange("ISO Code", UnknownCurrencyTok);
        Assert.IsTrue(Currency.IsEmpty(), 'This test requires a currency that is not set up.');
        Assert.IsFalse(Currency.Get(UnknownCurrencyTok), 'This test requires a currency that is not set up.');

        LogEntry.Init();
        LogEntry."Store Code" := StoreCode;
        LogEntry."Document Type" := LogEntry."Document Type"::Order;
        LogEntry."Document Status" := LogEntry."Document Status"::Open;
        OrderResponse := LibrarySpfyImport.BuildOrderJsonWithCurrency(ShopifyId, UnknownCurrencyTok, 100);
        OrderResponse.SelectToken('data.order', OrderNode);

        // [WHEN] the poller logs the order
        Assert.IsTrue(SpfyEventLogMgt.InsertShopifyLog(OrderNode, LogEntry), 'The order must be logged even when its currency cannot be resolved.');

        // [THEN] the entry is there, its currency is left unresolved, and it says why
        LoggedEntry.SetRange(Type, LoggedEntry.Type::"Incoming Sales Order");
        LoggedEntry.SetRange("Store Code", StoreCode);
        LoggedEntry.SetRange("Shopify ID", ShopifyId);
        Assert.IsTrue(LoggedEntry.FindFirst(), 'The order must be present in the event log.');
        Assert.AreEqual('', LoggedEntry."Presentment Currency Code", 'The currency must be left unresolved for the processing to resolve.');
        Assert.AreNotEqual('', LoggedEntry."Last Error Message", 'The entry must state why the currency is missing.');
    end;

    [Test]
    procedure ResolveCurrencyIfPending_StampsCurrencyFromOrderDetails()
    var
        GLSetup: Record "General Ledger Setup";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        TotalAmount: Decimal;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] An order logged without currency data resolves it from the order details fetched for
        // processing, so the Ecommerce header is built with the real currency instead of a blank one.
        StoreCode := 'SPFYCUR2';
        ShopifyId := '914000000002';
        TotalAmount := 250;
        GLSetup.Get();
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LogEntry."Presentment Currency Code" := '';
        LogEntry.Modify();
        OrderResponse := LibrarySpfyImport.BuildOrderJsonWithCurrency(ShopifyId, GLSetup."LCY Code", TotalAmount);

        // [WHEN] the order is processed
        SpfyEventLogMgt.ResolveCurrencyIfPending(LogEntry, OrderResponse);

        // [THEN] the entry carries the currency and the amounts of that order
        Assert.AreEqual(GLSetup."LCY Code", LogEntry."Presentment Currency Code", 'The presentment currency must be resolved.');
        Assert.AreEqual(TotalAmount, LogEntry."Amount (PCY)", 'The presentment amount must be stamped.');
        Assert.AreEqual(TotalAmount, LogEntry."Amount (SCY)", 'The store amount must be stamped.');
        Assert.AreEqual(TotalAmount, LogEntry."Amount (LCY)", 'The local amount must be stamped.');
    end;

    [Test]
    procedure ResolveCurrencyIfPending_ResolvedEntry_IsLeftAlone()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        LoggedAmount: Decimal;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        OtherCurrencyTok: Label 'XTS', Locked = true;
        ResolvedCurrencyTok: Label 'XTB', Locked = true;
    begin
        // [SCENARIO] An order whose currency was resolved when it was logged keeps those values. Re-reading them
        // from the details would replace the amounts the poller recorded, and would fail on a currency that is
        // still not set up even though this order never needed it.
        StoreCode := 'SPFYCUR3';
        ShopifyId := '914000000003';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        // Set explicitly rather than relying on the library default: that one takes the LCY code from the General
        // Ledger Setup, and a company without one would leave this blank - which is exactly what marks an entry as
        // still unresolved, so the test would exercise the opposite of what it claims.
        LogEntry."Presentment Currency Code" := ResolvedCurrencyTok;
        // Typed, not an integer literal: Assert.AreEqual compares the variant type as well, so comparing 10 against a
        // Decimal field fails on the type rather than on the value.
        LoggedAmount := 10;
        LogEntry."Amount (PCY)" := LoggedAmount;
        LogEntry.Modify();
        OrderResponse := LibrarySpfyImport.BuildOrderJsonWithCurrency(ShopifyId, OtherCurrencyTok, 999);

        // [WHEN] the order is processed
        SpfyEventLogMgt.ResolveCurrencyIfPending(LogEntry, OrderResponse);

        // [THEN] nothing was touched
        Assert.AreEqual(LoggedAmount, LogEntry."Amount (PCY)", 'A resolved entry must keep the amount recorded when it was logged.');
    end;

    [Test]
    procedure InsertShopifyLog_CurrencyFailsAfterStampingIt_KeepsTheEntryUnresolved()
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LoggedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        ExpectedAmount: Decimal;
        StoreCode: Code[20];
        ResolvableShopifyId: Text[30];
        FailingShopifyId: Text[30];
        UnknownCurrencyTok: Label 'XTS', Locked = true;
    begin
        // [SCENARIO] Currency resolution writes the presentment currency first and only then reads the store currency,
        // so it can fail with the presentment field already written. The failing attempt is a TryFunction, and that
        // rolls the database back but not the record it was handed - and this record is then inserted. A blank
        // "Presentment Currency Code" is the only marker of "not resolved yet" there is, so a half-written entry would
        // be logged as resolved with "Amount (LCY)" = 0: never picked up again, wrong in every reconciliation, and the
        // deferral note left on a row nothing will revisit.
        StoreCode := 'SPFYCUR4';
        ResolvableShopifyId := '914000000004';
        FailingShopifyId := '914000000005';
        GLSetup.Get();
        LibrarySpfyImport.CreateStore(StoreCode);
        Assert.AreNotEqual('', GLSetup."LCY Code", 'This test needs a local currency code - without one the presentment currency resolves to blank on its own.');
        Currency.SetRange("ISO Code", UnknownCurrencyTok);
        Assert.IsTrue(Currency.IsEmpty(), 'This test requires a store currency that is not set up.');
        Assert.IsFalse(Currency.Get(UnknownCurrencyTok), 'This test requires a store currency that is not set up.');

        // [GIVEN] the control: an order whose store currency also resolves is logged WITH the currency stamped. This is
        // what proves the field is written before the failure below - otherwise the test would be green on an order
        // that failed on its very first field, which is what the existing unresolvable-currency test already covers.
        InitCurrencyLogEntry(LogEntry, StoreCode);
        Assert.IsTrue(
            SpfyEventLogMgt.InsertShopifyLog(OrderNodeOf(LibrarySpfyImport.BuildOrderJsonWithCurrencies(ResolvableShopifyId, GLSetup."LCY Code", GLSetup."LCY Code", 100)), LogEntry),
            'The control order must be logged.');
        FindLoggedEntry(LoggedEntry, StoreCode, ResolvableShopifyId);
        Assert.AreNotEqual('', LoggedEntry."Presentment Currency Code", 'The control order must end up with its presentment currency stamped.');

        // [WHEN] the same order arrives with a store currency that has no Currency card, so resolution fails after the
        // presentment currency has already been written
        InitCurrencyLogEntry(LogEntry, StoreCode);
        Assert.IsTrue(
            SpfyEventLogMgt.InsertShopifyLog(OrderNodeOf(LibrarySpfyImport.BuildOrderJsonWithCurrencies(FailingShopifyId, GLSetup."LCY Code", UnknownCurrencyTok, 100)), LogEntry),
            'The order must still be logged - an unresolvable currency is a setup problem, not a reason to lose the order.');

        // [THEN] the entry reads as unresolved, so the processing gets another attempt, and no amount was kept from the
        // half-written state
        FindLoggedEntry(LoggedEntry, StoreCode, FailingShopifyId);
        Assert.AreEqual('', LoggedEntry."Presentment Currency Code", 'A failure after the currency was stamped must leave the entry unresolved.');
        Assert.AreEqual('', LoggedEntry."Store Currency Code", 'The store currency must be left unresolved as well.');
        ExpectedAmount := 0;
        Assert.AreEqual(ExpectedAmount, LoggedEntry."Amount (PCY)", 'No amount may survive a failed currency resolution.');
        Assert.AreEqual(ExpectedAmount, LoggedEntry."Amount (LCY)", 'No amount may survive a failed currency resolution.');
        Assert.AreNotEqual('', LoggedEntry."Last Error Message", 'The entry must state why the currency is missing.');
    end;

    [Test]
    procedure ResolveCurrencyIfPending_FailsAfterStampingIt_StaysRetryable()
    var
        Currency: Record Currency;
        GLSetup: Record "General Ledger Setup";
        LogEntry: Record "NPR Spfy Event Log Entry";
        StoredEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        RetriedAmount: Decimal;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        UnknownCurrencyTok: Label 'XTS', Locked = true;
    begin
        // [SCENARIO] The same half-written state on the processing side. Here the resolution is raised rather than
        // deferred again, so what matters is that the entry the caller keeps still reads as unresolved: the next
        // attempt has to actually try again instead of accepting a stamped currency with no amounts behind it. The
        // retry at the end is the assertion that can fail - a leftover currency code makes the whole procedure a no-op
        // and the amounts stay at zero forever.
        StoreCode := 'SPFYCUR5';
        ShopifyId := '914000000006';
        GLSetup.Get();
        LibrarySpfyImport.CreateStore(StoreCode);
        Assert.AreNotEqual('', GLSetup."LCY Code", 'This test needs a local currency code - without one the presentment currency resolves to blank on its own.');
        Currency.SetRange("ISO Code", UnknownCurrencyTok);
        Assert.IsTrue(Currency.IsEmpty(), 'This test requires a store currency that is not set up.');
        Assert.IsFalse(Currency.Get(UnknownCurrencyTok), 'This test requires a store currency that is not set up.');
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, CurrentDateTime());
        LogEntry."Presentment Currency Code" := '';
        LogEntry.Modify();
        // The fixture has to be committed: the failure below is raised, and the rollback that comes with it would
        // otherwise take the log entry with it, leaving the retry nothing to write to.
        Commit();

        // [WHEN] resolution fails on the store currency, after the presentment currency has been written
        asserterror SpfyEventLogMgt.ResolveCurrencyIfPending(LogEntry, LibrarySpfyImport.BuildOrderJsonWithCurrencies(ShopifyId, GLSetup."LCY Code", UnknownCurrencyTok, 250));
        // Only that something was reported, not what: the text comes from the platform's record-not-found error, whose
        // wording and whether it repeats the filter value are not part of any contract this test should depend on. The
        // retry at the end is what proves the failure was the store currency and nothing else about the fixture.
        Assert.AreNotEqual('', GetLastErrorText(), 'The failed currency resolution must be raised, not swallowed.');

        // [THEN] neither the entry the caller holds nor the stored row claims a currency
        Assert.AreEqual('', LogEntry."Presentment Currency Code", 'The entry the caller keeps must still read as unresolved.');
        StoredEntry.Get(LogEntry."Entry No.");
        Assert.AreEqual('', StoredEntry."Presentment Currency Code", 'The stored entry must still read as unresolved.');

        // [THEN] and the next attempt on that same record really resolves, which is what the blank code buys
        SpfyEventLogMgt.ResolveCurrencyIfPending(LogEntry, LibrarySpfyImport.BuildOrderJsonWithCurrency(ShopifyId, GLSetup."LCY Code", 250));
        Assert.AreEqual(GLSetup."LCY Code", LogEntry."Presentment Currency Code", 'A later attempt must be able to resolve the currency.');
        RetriedAmount := 250;
        Assert.AreEqual(RetriedAmount, LogEntry."Amount (PCY)", 'A later attempt must stamp the amounts.');

        LibrarySpfyImport.CleanupCommittedLogEntries(StoreCode, ShopifyId);
    end;

    [Test]
    procedure ResolveUnitPriceAndDiscount_ItemLine_NoCompareAt_KeepsActualPrice()
    var
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Assert: Codeunit Assert;
        ResolvedUnitPrice: Decimal;
        LineDiscountAmount: Decimal;
        ExpectedUnitPrice: Decimal;
        ExpectedDiscount: Decimal;
    begin
        // [SCENARIO] The Ecommerce-create path and the update-Sales path used to keep separate unit-price / discount
        // resolution branches for item lines. The M3 fix routes both paths through the shared resolver so they cannot
        // drift. Asserted directly on the resolver: it is the single point both paths now share.

        // [GIVEN] an item line without Compare-at pricing (CompareAtPrice = 0), unit price 100, quantity 1, discount 10
        LineDiscountAmount := 10;

        // [WHEN] the resolver runs
        ResolvedUnitPrice := SpfyOrderMgt.ResolveUnitPriceAndDiscount(true, 0, 100, 1, LineDiscountAmount);

        // [THEN] it keeps the actual Shopify price and leaves the discount as-passed
        ExpectedUnitPrice := 100;
        Assert.AreEqual(ExpectedUnitPrice, ResolvedUnitPrice, 'With no Compare-at price the resolver must return the actual Shopify unit price.');
        ExpectedDiscount := 10;
        Assert.AreEqual(ExpectedDiscount, LineDiscountAmount, 'With no Compare-at price the resolver must leave the discount amount untouched.');
    end;

    [Test]
    procedure ResolveUnitPriceAndDiscount_ItemLine_CompareAtAboveActual_FoldsDeltaIntoDiscount()
    var
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Assert: Codeunit Assert;
        ResolvedUnitPrice: Decimal;
        LineDiscountAmount: Decimal;
        ExpectedUnitPrice: Decimal;
        ExpectedDiscount: Decimal;
    begin
        // [SCENARIO] For an item line where Compare-at pricing exceeds the actual Shopify price, the resolver lifts the
        // unit price to Compare-at and books the delta as extra discount. This is the branch previously duplicated
        // between the two paths.

        // [GIVEN] an item line with Compare-at 120, actual 100, quantity 2, supplied discount 10
        LineDiscountAmount := 10;

        // [WHEN] the resolver runs
        ResolvedUnitPrice := SpfyOrderMgt.ResolveUnitPriceAndDiscount(true, 120, 100, 2, LineDiscountAmount);

        // [THEN] the unit price is lifted to Compare-at and the discount is widened: 10 + (120 - 100) * 2 = 50
        ExpectedUnitPrice := 120;
        Assert.AreEqual(ExpectedUnitPrice, ResolvedUnitPrice, 'For an item line with Compare-at pricing the resolver must return the Compare-at price.');
        ExpectedDiscount := 50;
        Assert.AreEqual(ExpectedDiscount, LineDiscountAmount, 'The Compare-at / actual delta must be added to the line discount amount.');
    end;

    [Test]
    procedure ResolveUnitPriceAndDiscount_NonItemLine_CompareAtIgnored()
    var
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Assert: Codeunit Assert;
        ResolvedUnitPrice: Decimal;
        LineDiscountAmount: Decimal;
        ExpectedUnitPrice: Decimal;
        ExpectedDiscount: Decimal;
    begin
        // [SCENARIO] The Compare-at math is confined to the IsItem branch so an update-path caller cannot accidentally
        // pull a shipping-line reprice through it. Non-item lines (charge, shipping) must keep the actual price and
        // untouched discount even when Compare-at is supplied.

        // [GIVEN] a non-item line with the same Compare-at inputs as the item-line case
        LineDiscountAmount := 10;

        // [WHEN] the resolver runs with IsItem = false
        ResolvedUnitPrice := SpfyOrderMgt.ResolveUnitPriceAndDiscount(false, 120, 100, 2, LineDiscountAmount);

        // [THEN] Compare-at is ignored - actual price and untouched discount survive
        ExpectedUnitPrice := 100;
        Assert.AreEqual(ExpectedUnitPrice, ResolvedUnitPrice, 'A non-item line must never take a Compare-at price.');
        ExpectedDiscount := 10;
        Assert.AreEqual(ExpectedDiscount, LineDiscountAmount, 'A non-item line must never have its discount amount widened by Compare-at math.');
    end;

    [Test]
    procedure UpdateSalesLinesFromJson_CreatePath_VirtualTicketLineDriftIgnored()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        TicketLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        OrderLineId: Text[30];
    begin
        // [SCENARIO] The virtual-line drift check in ValidateAndUpdateExistingSalesLineFromShopify compares SalesLine
        // amounts against RAW JSON amounts. The Ecommerce->Sales conversion writes CompareAt-folded amounts to the
        // SalesLine (unit price = CompareAt, discount += fold delta), so the SalesLine amounts differ from raw JSON by
        // design. On the create path the SalesLine was just written this cycle, so the drift is not evidence of a
        // rewrite and the check would false-positive VirtualItemExtraErr on the very first CreateAndProcess pass. The
        // real M3 fix skips the check on the create path.

        // [GIVEN] a Sales Order with one ticket line - virtual by Item."NPR Ticket Type", which is what
        // OrderLineIsVirtualItem reads through DetermineItemSubtype. Using the same MakeItemATicketItem fixture the
        // sibling M4 test uses. SalesLine amounts are set to the CompareAt-folded shape (Unit Price 120, Line Discount
        // Amount 20), and the JSON that comes back reports the RAW amounts (originalUnitPriceSet.presentmentMoney.amount
        // 100, no discountAllocations). The two disagree by the CompareAt/discount fold, which is exactly what
        // IsVirtualLineChanged would trip on.
        StoreCode := 'SPFYM3C';
        ShopifyId := '922000000001';
        OrderLineId := '922000000101';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(OrderLineId, 120, SalesHeader, TicketLine);
        LibrarySpfyImport.MakeItemATicketItem(TicketLine."No.");
        TicketLine.Validate("Unit Price", 120);
        TicketLine."Line Discount Amount" := 20;
        TicketLine.Modify();

        // BuildUpdateOrderJson emits one line + a SUCCESS fulfillment for that line, so the fulfilled path resolves
        // through the snapshot and ProcessSaleLine reaches ValidateAndUpdateExistingSalesLineFromShopify. The JSON
        // unit price is 100 (raw), the SalesLine is stamped at 120 - the amount drift the check would trip on.
        OrderResponse := LibrarySpfyImport.BuildUpdateOrderJson(ShopifyId, OrderLineId, TicketLine."No.", 100, 1);

        // [WHEN] the call is made on the create path, the drift check is skipped and the run completes.
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry, true);

        // [THEN] the run did not raise, and the ticket line survived on the document (smoke check; the sibling test
        // UpdateSalesLinesFromJson_UpdatePath_VirtualTicketLineDriftRaises proves the check would otherwise fire on
        // this same shape, so the create-path skip is doing work rather than passing by coincidence).
        Assert.IsTrue(TicketLine.Get(TicketLine."Document Type", TicketLine."Document No.", TicketLine."Line No."), 'The ticket line must still be on the document after the create-path call.');
    end;

    [Test]
    procedure UpdateSalesLinesFromJson_UpdatePath_VirtualTicketLineDriftRaises()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        TicketLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        StoreCode: Code[20];
        ShopifyId: Text[30];
        OrderLineId: Text[30];
    begin
        // [SCENARIO] The complement of the create-path case: on the update path a virtual line may have been
        // provisioned earlier at a different amount, so the drift check still runs and must raise VirtualItemExtraErr
        // on the same CompareAt/discount fold. This half proves the create-path skip in the sibling test is doing work
        // and not passing because the check happened not to fire.

        // [GIVEN] a Sales Order with one ticket line stamped at the CompareAt-folded shape (Unit Price 120, Line
        // Discount Amount 20) - identical fixture to the create-path sibling test.
        StoreCode := 'SPFYM3U';
        ShopifyId := '922000000002';
        OrderLineId := '922000000102';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(OrderLineId, 120, SalesHeader, TicketLine);
        LibrarySpfyImport.MakeItemATicketItem(TicketLine."No.");
        TicketLine.Validate("Unit Price", 120);
        TicketLine."Line Discount Amount" := 20;
        TicketLine.Modify();
        OrderResponse := LibrarySpfyImport.BuildUpdateOrderJson(ShopifyId, OrderLineId, TicketLine."No.", 100, 1);

        // [WHEN] the call is made on the update path (parameterless overload = default IsCreatePath = false)
        asserterror SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the drift check runs and raises VirtualItemExtraErr
        Assert.ExpectedError('It is not possible to change virtual items');
    end;

    [Test]
    procedure SetQuantities_VirtualItemLines_QtyToShipPreserved()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        OrdinaryLine: Record "Sales Line";
        TicketLine: Record "Sales Line";
        VoucherLine: Record "Sales Line";
        NpRvSalesLine: Record "NPR NpRv Sales Line";
        UpdatedLine: Record "Sales Line";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        Assert: Codeunit Assert;
        VoucherItem: Record Item;
        TicketItem: Record Item;
        OrderResponse: JsonToken;
        ExistingLineId: Text[30];
        VoucherOrderLineId: Text[30];
        TicketOrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
        ExpectedQty: Decimal;
    begin
        // [SCENARIO] SetQuantities used to reset Qty. to Ship / Qty. to Invoice on every line of the order header. That
        // clobbered lines a virtual-item module had already provisioned (vouchers, tickets, memberships) - the ship /
        // invoice quantity is the state those modules read to know the line was posted. The M4 fix adds an
        // IsVirtualItemSalesLine guard that skips those lines. Driven here through the update path, which calls
        // SetQuantities as its first side effect on an Order header. Direct call would need SetQuantities to be
        // exposed; the update-path route observes the same behavior without touching the production access modifier.
        // [GIVEN] an Order header with three item lines, each with Qty. to Ship pre-set to non-zero:
        //   - an ordinary item line (control - SetQuantities must still zero this),
        //   - a voucher line linked through NPR NpRv Sales Line the same way MagentoSalesOrderMgt.IsRetailVoucherLine
        //     detects it (Document Source::"Sales Document" + Document Type/No./Line No.),
        //   - a ticket line whose item carries a non-blank NPR Ticket Type (mirrors MagentoSalesOrderMgt.IsTicketLine).
        StoreCode := 'SPFYVI1';
        ShopifyId := '921000000001';
        ExistingLineId := '921000000101';
        VoucherOrderLineId := '921000000102';
        TicketOrderLineId := '921000000103';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(ExistingLineId, 100, SalesHeader, OrdinaryLine);
        OrdinaryLine."Qty. to Ship" := OrdinaryLine.Quantity;
        OrdinaryLine."Qty. to Invoice" := OrdinaryLine.Quantity;
        OrdinaryLine.Modify();

        // Voucher line: create a Sales Line and link an NpRv row on the same document coordinates, without validating -
        // NotBlank fields on the retail-voucher table only fire on Validate, and the guard reads the link only through
        // SetRange filters, so a raw Insert with the four link fields plus the primary key is enough.
        LibraryInventory.CreateItem(VoucherItem);
        LibrarySales.CreateSalesLine(VoucherLine, SalesHeader, VoucherLine.Type::Item, VoucherItem."No.", 1);
        VoucherLine.Validate("Unit Price", 100);
        VoucherLine."Qty. to Ship" := VoucherLine.Quantity;
        VoucherLine."Qty. to Invoice" := VoucherLine.Quantity;
        VoucherLine.Modify();
        SpfyAssignedIDMgt.AssignShopifyID(VoucherLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", VoucherOrderLineId, false);
        NpRvSalesLine.Init();
        NpRvSalesLine.Id := CreateGuid();
        NpRvSalesLine."Document Source" := NpRvSalesLine."Document Source"::"Sales Document";
        NpRvSalesLine."Document Type" := VoucherLine."Document Type";
        NpRvSalesLine."Document No." := VoucherLine."Document No.";
        NpRvSalesLine."Document Line No." := VoucherLine."Line No.";
        NpRvSalesLine."Voucher Type" := 'VT-TEST';
        NpRvSalesLine."Voucher No." := 'VN-TEST';
        NpRvSalesLine.Insert();

        // Ticket line: turn a fresh item into a ticket item using the same fixture MakeItemATicketItem uses in the
        // sibling virtual-line tests, so the guard's ticket branch resolves through Item."NPR Ticket Type".
        LibraryInventory.CreateItem(TicketItem);
        LibrarySpfyImport.MakeItemATicketItem(TicketItem."No.");
        LibrarySales.CreateSalesLine(TicketLine, SalesHeader, TicketLine.Type::Item, TicketItem."No.", 1);
        TicketLine.Validate("Unit Price", 100);
        TicketLine."Qty. to Ship" := TicketLine.Quantity;
        TicketLine."Qty. to Invoice" := TicketLine.Quantity;
        TicketLine.Modify();
        SpfyAssignedIDMgt.AssignShopifyID(TicketLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TicketOrderLineId, false);

        // [WHEN] the update path runs on this Order header (its first side effect is SetQuantities). The response only
        // needs to name one existing line so the caller has something to iterate; the assertion is on the pre-existing
        // lines, not on anything reported here.
        OrderResponse := LibrarySpfyImport.WrapOrderText(
            ShopifyId,
            '[' +
                LibrarySpfyImport.ItemLineNodeText(ExistingLineId, OrdinaryLine."No.", 100, 1, '[]') + ',' +
                LibrarySpfyImport.ItemLineNodeText(VoucherOrderLineId, VoucherLine."No.", 50, 1, '[]') + ',' +
                LibrarySpfyImport.ItemLineNodeText(TicketOrderLineId, TicketLine."No.", 75, 1, '[]') +
            ']',
            '[]');
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the ordinary line's Qty. to Ship and Qty. to Invoice were zeroed (SetQuantities did its job), and both
        // virtual lines kept theirs - the IsVirtualItemSalesLine guard skipped them.
        UpdatedLine.Get(OrdinaryLine."Document Type", OrdinaryLine."Document No.", OrdinaryLine."Line No.");
        ExpectedQty := 0;
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Ship", 'The ordinary line must have Qty. to Ship cleared - SetQuantities must still run on non-virtual lines.');
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Invoice", 'The ordinary line must have Qty. to Invoice cleared - SetQuantities must still run on non-virtual lines.');

        UpdatedLine.Get(VoucherLine."Document Type", VoucherLine."Document No.", VoucherLine."Line No.");
        ExpectedQty := VoucherLine.Quantity;
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Ship", 'A voucher line must keep its Qty. to Ship - clearing it would strand the voucher module''s provisioning state.');
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Invoice", 'A voucher line must keep its Qty. to Invoice - clearing it would strand the voucher module''s provisioning state.');

        UpdatedLine.Get(TicketLine."Document Type", TicketLine."Document No.", TicketLine."Line No.");
        ExpectedQty := TicketLine.Quantity;
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Ship", 'A ticket line must keep its Qty. to Ship - clearing it would strand the ticket module''s provisioning state.');
        Assert.AreEqual(ExpectedQty, UpdatedLine."Qty. to Invoice", 'A ticket line must keep its Qty. to Invoice - clearing it would strand the ticket module''s provisioning state.');
    end;

    [Test]
    procedure SetQuantities_VirtualTicketLine_UpdatePath_ShopifyQtyDiverges_Errs()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        OrdinaryLine: Record "Sales Line";
        TicketLine: Record "Sales Line";
        TicketItem: Record Item;
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExistingLineId: Text[30];
        TicketOrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] On the update path (IsCreatePath = false), a virtual ticket line whose Shopify quantity differs
        // from the BC Quantity and which carries no fulfillment must raise VirtualItemExtraErr. The Finding A fix
        // narrows the M5 IsVirtualItemSalesLine guard in ResetQuantitiesForLineWithoutFulfillment to the create path,
        // so the drift check at QuantityForLineWithoutFulfillment fires exactly as it did pre-M5.
        // [GIVEN] an Order header with one ordinary Shopify line + a virtual ticket line (Quantity 1, Unit Price 250)
        // stamped with a Shopify Assigned ID, and no fulfillments on either line.
        StoreCode := 'SPFYFAU';
        ShopifyId := '921000000201';
        ExistingLineId := '921000000102';
        TicketOrderLineId := '921000000103';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(ExistingLineId, 100, SalesHeader, OrdinaryLine);

        LibraryInventory.CreateItem(TicketItem);
        LibrarySpfyImport.MakeItemATicketItem(TicketItem."No.");
        LibrarySales.CreateSalesLine(TicketLine, SalesHeader, TicketLine.Type::Item, TicketItem."No.", 1);
        TicketLine.Validate("Unit Price", 250);
        TicketLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(TicketLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TicketOrderLineId, false);

        // JSON reports ticket quantity 2 (BC has 1) with '[]' fulfillments at both scopes - drift on an unfulfilled
        // virtual line, exactly the shape QuantityForLineWithoutFulfillment's virtual branch errors on.
        OrderResponse := LibrarySpfyImport.WrapOrderText(
            ShopifyId,
            '[' +
                LibrarySpfyImport.ItemLineNodeText(ExistingLineId, OrdinaryLine."No.", 100, 1, '[]') + ',' +
                LibrarySpfyImport.ItemLineNodeText(TicketOrderLineId, TicketLine."No.", 250, 2, '[]') +
            ']',
            '[]');

        // [WHEN] the update path runs (3-arg overload = IsCreatePath = false).
        asserterror SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] VirtualItemExtraErr fires from QuantityForLineWithoutFulfillment.
        Assert.ExpectedError('It is not possible to change virtual items');
    end;

    [Test]
    procedure SetQuantities_VirtualTicketLine_CreatePath_ShopifyQtyDiverges_Silent()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        OrdinaryLine: Record "Sales Line";
        TicketLine: Record "Sales Line";
        UpdatedLine: Record "Sales Line";
        TicketItem: Record Item;
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExistingLineId: Text[30];
        TicketOrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] On the create path (IsCreatePath = true), the same virtual-line drift is silently accepted:
        // the M5 IsVirtualItemSalesLine guard keeps the BC Quantity / price and the sibling M2 branch already
        // silences its own drift check on this path. Combined with the M4 QtyToShip preservation, the ticket line
        // must survive with Quantity and Qty. to Ship intact.
        // [GIVEN] fresh Order header identical in shape to the update-path sibling.
        StoreCode := 'SPFYFAC';
        ShopifyId := '921000000202';
        ExistingLineId := '921000000104';
        TicketOrderLineId := '921000000105';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(ExistingLineId, 100, SalesHeader, OrdinaryLine);

        LibraryInventory.CreateItem(TicketItem);
        LibrarySpfyImport.MakeItemATicketItem(TicketItem."No.");
        LibrarySales.CreateSalesLine(TicketLine, SalesHeader, TicketLine.Type::Item, TicketItem."No.", 1);
        TicketLine.Validate("Unit Price", 250);
        TicketLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(TicketLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TicketOrderLineId, false);

        OrderResponse := LibrarySpfyImport.WrapOrderText(
            ShopifyId,
            '[' +
                LibrarySpfyImport.ItemLineNodeText(ExistingLineId, OrdinaryLine."No.", 100, 1, '[]') + ',' +
                LibrarySpfyImport.ItemLineNodeText(TicketOrderLineId, TicketLine."No.", 250, 2, '[]') +
            ']',
            '[]');

        // [WHEN] the create path runs (4-arg overload = IsCreatePath = true).
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry, true);

        // [THEN] no error was raised, the BC ticket quantity was preserved, and Qty. to Ship was preserved by M4.
        UpdatedLine.Get(TicketLine."Document Type", TicketLine."Document No.", TicketLine."Line No.");
        Assert.AreEqual(1, UpdatedLine.Quantity, 'Create path must preserve BC ticket quantity');
        Assert.AreEqual(UpdatedLine.Quantity, UpdatedLine."Qty. to Ship", 'Create path must preserve virtual line Qty. to Ship');

        // [THEN] The ordinary line IS reset to zero on the same call. This proves the M5 IsCreatePath narrowing
        // is doing work: the virtual-line early-exit is scoped to virtual lines only, so the ordinary line still
        // flows into ResetQuantitiesForLineWithoutFulfillment's qty-zeroing block. If a future revert of M5
        // widened the exit to all lines (unconditional IsVirtualItemSalesLine early-exit), the ordinary line
        // would also skip the reset and this assertion would fail.
        OrdinaryLine.Get(OrdinaryLine."Document Type", OrdinaryLine."Document No.", OrdinaryLine."Line No.");
        Assert.AreEqual(0, OrdinaryLine."Qty. to Ship", 'Ordinary line must still be reset to zero - proves M5 narrowing distinguishes virtual from ordinary.');
    end;

    [Test]
    procedure SetQuantities_VirtualTicketLine_UpdatePath_NoDrift_QtyToShipPreserved()
    var
        LogEntry: Record "NPR Spfy Event Log Entry";
        SalesHeader: Record "Sales Header";
        OrdinaryLine: Record "Sales Line";
        TicketLine: Record "Sales Line";
        UpdatedLine: Record "Sales Line";
        TicketItem: Record Item;
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        SpfyEcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        ExistingLineId: Text[30];
        TicketOrderLineId: Text[30];
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] On the update path (IsCreatePath = false), a virtual ticket line whose Shopify currentQuantity
        // matches the BC Quantity (no drift) and which carries no fulfillment must retain its Qty. to Ship. This
        // guards R-1, the sibling of CONFIRMED-1 on the update path: without the wrap around the qty-zeroing block
        // in ResetQuantitiesForLineWithoutFulfillment, control would fall through and strand the ticket module's
        // provisioning state by clearing Qty. to Ship / Qty. to Invoice on a still-unfulfilled virtual line.
        // [GIVEN] an Order header with one ordinary Shopify line + a virtual ticket line (Quantity 1, Unit Price 250)
        // stamped with a Shopify Assigned ID, and no fulfillments on either line.
        StoreCode := 'SPFYFAM';
        ShopifyId := '921000000203';
        ExistingLineId := '921000000106';
        TicketOrderLineId := '921000000107';
        LibrarySpfyImport.CreateStore(StoreCode);
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LibrarySpfyImport.SetupSalesOrderWithShopifyLine(ExistingLineId, 100, SalesHeader, OrdinaryLine);

        LibraryInventory.CreateItem(TicketItem);
        LibrarySpfyImport.MakeItemATicketItem(TicketItem."No.");
        LibrarySales.CreateSalesLine(TicketLine, SalesHeader, TicketLine.Type::Item, TicketItem."No.", 1);
        TicketLine.Validate("Unit Price", 250);
        TicketLine.Modify(true);
        SpfyAssignedIDMgt.AssignShopifyID(TicketLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", TicketOrderLineId, false);

        // JSON reports ticket quantity 1 (matches BC) with '[]' fulfillments at both scopes - no drift, no fulfillment.
        OrderResponse := LibrarySpfyImport.WrapOrderText(
            ShopifyId,
            '[' +
                LibrarySpfyImport.ItemLineNodeText(ExistingLineId, OrdinaryLine."No.", 100, 1, '[]') + ',' +
                LibrarySpfyImport.ItemLineNodeText(TicketOrderLineId, TicketLine."No.", 250, 1, '[]') +
            ']',
            '[]');

        // [WHEN] the update path runs (3-arg overload = IsCreatePath = false).
        SpfyEcomSalesDocImport.UpdateSalesLinesFromJson(SalesHeader, OrderResponse, LogEntry);

        // [THEN] the virtual line's BC quantity was preserved and Qty. to Ship / Qty. to Invoice were NOT zeroed.
        UpdatedLine.Get(TicketLine."Document Type", TicketLine."Document No.", TicketLine."Line No.");
        Assert.AreEqual(1, UpdatedLine.Quantity, 'Update path must preserve BC ticket quantity when no drift');
        Assert.AreEqual(UpdatedLine.Quantity, UpdatedLine."Qty. to Ship", 'Update path virtual line must retain Qty. to Ship');
        Assert.AreEqual(UpdatedLine.Quantity, UpdatedLine."Qty. to Invoice", 'Update path virtual line must retain Qty. to Invoice');
    end;

    [Test]
    procedure ClosedEntry_PendingCurrency_UpdatePath_Resolves()
    var
        GLSetup: Record "General Ledger Setup";
        LogEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        SpfyEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        Assert: Codeunit Assert;
        OrderResponse: JsonToken;
        TotalAmount: Decimal;
        StoreCode: Code[20];
        ShopifyId: Text[30];
    begin
        // [SCENARIO] Md3 - A Closed log entry logged when currency was pending (empty Presentment Currency Code,
        // zero amounts) has its currency resolved on the update path. UpdateSalesHeader now invokes
        // ResolveCurrencyIfPending as its first side-effect on the LogEntry, mirroring the create path's
        // ProcessEcommerceHeader. This test pins that helper's behavior on the exact LogEntry shape the update
        // path feeds it: Document Status::Closed with cleared currency fields.
        StoreCode := 'SPFYCUR7';
        ShopifyId := '914000000007';
        TotalAmount := 250;
        GLSetup.Get();
        LibrarySpfyImport.CreateStore(StoreCode);
        // [GIVEN] a Closed order log entry whose currency was deferred at logging time (all currency fields cleared).
        LibrarySpfyImport.InsertOrderLogEntry(LogEntry, StoreCode, ShopifyId, "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Closed, CurrentDateTime());
        LogEntry."Presentment Currency Code" := '';
        LogEntry."Store Currency Code" := '';
        LogEntry."Amount (PCY)" := 0;
        LogEntry."Amount (SCY)" := 0;
        LogEntry."Amount (LCY)" := 0;
        LogEntry.Modify();
        // [GIVEN] the Shopify order details response carrying a resolvable currency.
        OrderResponse := LibrarySpfyImport.BuildOrderJsonWithCurrency(ShopifyId, GLSetup."LCY Code", TotalAmount);

        // [WHEN] the update path resolves the currency (UpdateSalesHeader's first call).
        SpfyEventLogMgt.ResolveCurrencyIfPending(LogEntry, OrderResponse);

        // [THEN] the previously pending Closed entry now carries the currency and the amounts of that order.
        Assert.AreNotEqual('', LogEntry."Presentment Currency Code", 'ResolveCurrencyIfPending must populate Presentment Currency Code for a pending Closed entry on the update path.');
        Assert.AreEqual(GLSetup."LCY Code", LogEntry."Presentment Currency Code", 'The presentment currency must be resolved from the order details.');
        Assert.AreNotEqual(0, LogEntry."Amount (PCY)", 'Amount (PCY) must be non-zero after currency resolution on the update path.');
        Assert.AreEqual(TotalAmount, LogEntry."Amount (PCY)", 'The presentment amount must be stamped from the order details.');
        Assert.AreEqual(TotalAmount, LogEntry."Amount (SCY)", 'The store amount must be stamped from the order details.');
        Assert.AreEqual(TotalAmount, LogEntry."Amount (LCY)", 'The local amount must be stamped from the order details.');
    end;

    [Test]
    procedure PrepareFulfillmentBufferSnapshot_TwiceWithSameVar_CacheSurvives()
    var
        FulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        Line1: Record "NPR Spfy Fulfillment Buffer" temporary;
        Line2: Record "NPR Spfy Fulfillment Buffer" temporary;
        TempBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        ProbeBuffer1: Record "NPR Spfy Fulfillment Buffer" temporary;
        ProbeBuffer2: Record "NPR Spfy Fulfillment Buffer" temporary;
        Assert: Codeunit Assert;
        OrderLineId1: Text[30];
        OrderLineId2: Text[30];
    begin
        // [SCENARIO] Md6 - calling PrepareFulfillmentBufferSnapshot twice with the same TempBuffer variable must
        // not wipe the underlying FulfillmentCache. Pre-Md6, the second call's TempBuffer.DeleteAll() ran against
        // a variable that Copy(..., true) had aliased to Temp_SpfyFulfillmentBuffer on the first call - so
        // DeleteAll cleared the cache itself. Post-Md6, both DeleteAll calls are gone and the cache survives.
        OrderLineId1 := '924000000001';
        OrderLineId2 := '924000000002';
        FulfillmentCache.ClearCache();

        // [GIVEN] two lines cached in the FulfillmentCache with distinct Entry No. and Order Line ID.
        Line1.Init();
        Line1."Entry No." := 24000001;
        Line1."Order Line ID" := OrderLineId1;
        Line1."Fulfilled Quantity" := 1;
        FulfillmentCache.CacheLine(Line1);

        Line2.Init();
        Line2."Entry No." := 24000002;
        Line2."Order Line ID" := OrderLineId2;
        Line2."Fulfilled Quantity" := 1;
        FulfillmentCache.CacheLine(Line2);

        // [WHEN] PrepareFulfillmentBufferSnapshot is called twice with the same caller-owned TempBuffer variable.
        FulfillmentCache.PrepareFulfillmentBufferSnapshot(TempBuffer);
        FulfillmentCache.PrepareFulfillmentBufferSnapshot(TempBuffer);

        // [THEN] both cached lines are still retrievable - the second call did not wipe the cache.
        Assert.IsTrue(FulfillmentCache.GetLineFromCache(OrderLineId1, ProbeBuffer1), 'Line 1 must survive second Snapshot call - Md6 defused DeleteAll landmine');
        Assert.IsTrue(FulfillmentCache.GetLineFromCache(OrderLineId2, ProbeBuffer2), 'Line 2 must survive second Snapshot call - Md6 defused DeleteAll landmine');
    end;

    [Test]
    procedure SystemSetterWrite_DoesNotDiscardOrderData()
    var
        SpfyStore: Record "NPR Spfy Store";
        FailedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        Assert: Codeunit Assert;
        NowDT: DateTime;
        NewMarker: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] Md5 - system callers of the table setter (JQ, upgrade codeunit, legacy paths) that write the
        // Last Orders Imported At marker directly must NOT trigger a mass Discard of Order Data on the store's
        // failed log entries. Only the store card page's operator gesture invokes the rewind side effect - and it
        // does so explicitly via SpfyEventLogMgt.RewindImportMarker before calling the setter. The setter itself
        // is a pure write. This test locks that structural guarantee.
        StoreCode := 'SPFYMD5';
        // Whole seconds: a DateTime is stored with about 3 ms of granularity, so a value carrying milliseconds
        // does not read back exactly as written. Shopify's own updatedAt has second resolution too.
        NowDT := RoundDateTime(CurrentDateTime(), 1000);
        NewMarker := NowDT - 7200000; // two hours ago - a real backward step, well outside the 1s tolerance

        // [GIVEN] a store with the orders marker set to "now" (pre-seeded via the pure-write setter) and a failed
        // order log entry with stored Order Data.
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastOrdersImportedAt(NowDT);
        LibrarySpfyImport.InsertOrderLogEntry(FailedEntry, StoreCode, '925000000001', "NPR SpfyEventLogDocType"::Order, "NPR SpfyAPIDocumentStatus"::Open, NowDT - 3600000);
        LibrarySpfyImport.SetFailedWithOrderData(FailedEntry, 3);
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(FailedEntry."Entry No."), 'The fixture must start with stored order data.');

        // [WHEN] a system caller writes the marker backwards through the table setter directly (this mirrors what
        // SpfyOrderImportJQ / legacy upgrade paths / SpfyAppUpgrade do - no page, no operator).
        SpfyStore.SetLastOrdersImportedAt(NewMarker);

        // [THEN] the setter did its pure write - the marker is stored - but the failed entry's Order Data survives.
        // Direct setter calls must not trigger the rewind side effect; that behaviour belongs on the store card
        // OnValidate only. If a future edit re-couples the setter to DiscardStoredOrderData, this test will fail
        // and no [MessageHandler] here catches the accompanying "fresh start" Message either.
        Assert.AreEqual(NewMarker, LastOrdersImportedAt(StoreCode), 'The new marker must be stored - the setter is a pure write.');
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(FailedEntry."Entry No."), 'Direct setter call must not discard Order Data on failed entries - that side effect belongs on the store card OnValidate only.');
    end;

    [Test]
    procedure SystemSetterWrite_ReturnsMarker_DoesNotDiscardOrderData()
    var
        SpfyStore: Record "NPR Spfy Store";
        FailedEntry: Record "NPR Spfy Event Log Entry";
        LibrarySpfyImport: Codeunit "NPR Library Spfy Import";
        Assert: Codeunit Assert;
        NowDT: DateTime;
        NewMarker: DateTime;
        StoreCode: Code[20];
    begin
        // [SCENARIO] Md5 (Returns sibling) - system callers of the returns table setter (JQ, upgrade codeunit,
        // legacy paths) that write the Last Returns Imported At marker directly must NOT trigger a mass Discard
        // of Order Data on the store's failed return log entries. Only the store card page's operator gesture
        // invokes the rewind side effect - and it does so explicitly via SpfyEventLogMgt.RewindImportMarker
        // before calling the setter. The setter itself is a pure write. This test locks that structural
        // guarantee for the Returns side, mirroring the Orders sibling above.
        StoreCode := 'SPFYMD5R';
        // Whole seconds: a DateTime is stored with about 3 ms of granularity, so a value carrying milliseconds
        // does not read back exactly as written. Shopify's own updatedAt has second resolution too.
        NowDT := RoundDateTime(CurrentDateTime(), 1000);
        NewMarker := NowDT - 7200000; // two hours ago - a real backward step, well outside the 1s tolerance

        // [GIVEN] a store with the returns marker set to "now" (pre-seeded via the pure-write setter) and a
        // failed Return-Order log entry with stored Order Data.
        LibrarySpfyImport.CreateStore(StoreCode);
        SpfyStore.Get(StoreCode);
        SpfyStore.SetLastReturnsImportedAt(NowDT);
        LibrarySpfyImport.InsertOrderLogEntry(FailedEntry, StoreCode, '925000000002', "NPR SpfyEventLogDocType"::"Return Order", "NPR SpfyAPIDocumentStatus"::Open, NowDT - 3600000);
        LibrarySpfyImport.SetFailedWithOrderData(FailedEntry, 3);
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(FailedEntry."Entry No."), 'The fixture must start with stored order data.');

        // [WHEN] a system caller writes the returns marker backwards through the table setter directly (this
        // mirrors what SpfyOrderImportJQ / legacy upgrade paths / SpfyAppUpgrade do - no page, no operator).
        SpfyStore.SetLastReturnsImportedAt(NewMarker);

        // [THEN] the setter did its pure write - the marker is stored - but the failed entry's Order Data survives.
        // Direct setter calls must not trigger the rewind side effect; that behaviour belongs on the store card
        // OnValidate only. If a future edit re-couples the setter to DiscardStoredOrderData, this test will fail
        // and no [MessageHandler] here catches the accompanying "fresh start" Message either.
        Assert.AreEqual(NewMarker, LastReturnsImportedAt(StoreCode), 'The new marker must be stored - the setter is a pure write.');
        Assert.IsTrue(LibrarySpfyImport.HasOrderData(FailedEntry."Entry No."), 'Direct setter call must not discard Order Data on failed return entries - that side effect belongs on the store card OnValidate only.');
    end;

    /// <summary>The unsaved Event Log Entry shape InsertShopifyLog is handed by the poller: store, document type and
    /// document status only - everything else is read off the order JSON.</summary>
    local procedure InitCurrencyLogEntry(var LogEntry: Record "NPR Spfy Event Log Entry"; StoreCode: Code[20])
    begin
        LogEntry.Init();
        LogEntry."Store Code" := StoreCode;
        LogEntry."Document Type" := LogEntry."Document Type"::Order;
        LogEntry."Document Status" := LogEntry."Document Status"::Open;
    end;

    local procedure FindLoggedEntry(var LoggedEntry: Record "NPR Spfy Event Log Entry"; StoreCode: Code[20]; ShopifyId: Text[30])
    var
        Assert: Codeunit Assert;
    begin
        LoggedEntry.Reset();
        LoggedEntry.SetRange(Type, LoggedEntry.Type::"Incoming Sales Order");
        LoggedEntry.SetRange("Store Code", StoreCode);
        LoggedEntry.SetRange("Shopify ID", ShopifyId);
        Assert.IsTrue(LoggedEntry.FindFirst(), 'The order must be present in the event log.');
    end;

    local procedure OrderNodeOf(OrderResponse: JsonToken) OrderNode: JsonToken
    var
        MissingOrderNodeErr: Label 'Test fixture JSON has no data.order node.', Locked = true;
    begin
        if not OrderResponse.SelectToken('data.order', OrderNode) then
            Error(MissingOrderNodeErr);
    end;

    [MessageHandler]
    procedure FreshStartMessageHandler(Msg: Text[1024])
    begin
        // Swallows the "N failed log entries were given a fresh start" message. Rewinding the import marker discards
        // the stored order data of the store's failed entries, and telling the operator how many were touched is
        // deliberate - so every test that rewinds a marker over failed entries has to handle the message.
    end;

    local procedure LastOrdersImportedAt(StoreCode: Code[20]): DateTime
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        SpfyStore.Get(StoreCode);
        SpfyStore.CalcFields("Last Orders Imported At (FF)");
        exit(SpfyStore."Last Orders Imported At (FF)");
    end;

    local procedure LastReturnsImportedAt(StoreCode: Code[20]): DateTime
    var
        SpfyStore: Record "NPR Spfy Store";
    begin
        SpfyStore.Get(StoreCode);
        SpfyStore.CalcFields("Last Returns Imported At (FF)");
        exit(SpfyStore."Last Returns Imported At (FF)");
    end;
}
#endif

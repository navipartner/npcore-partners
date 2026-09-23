#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85467 "NPR Spfy SkipOrderDownloadTest"
{
    Subtype = Test;
    TestPermissions = Disabled;

    // [FEATURE] Shopify Order Download Skip

    var
        _Assert: Codeunit "Assert";

    //
    // Tag normalisation. The two downloads return 'tags' in different shapes, and the product must hand the
    // subscriber one shape. These are the regression guards for reading the token directly instead of going
    // through JsonHelper, whose GetJValue collapses an array to its first element.
    //

    [Test]
    procedure GetOrderTags_RestCommaSeparatedString()
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        Tags: List of [Text];
    begin
        // [SCENARIO] Tags arriving from the REST download as one comma separated string are split per tag.

        // [GIVEN] An order whose tags are a comma separated string
        Order := OrderFrom('{"tags":"vip, b2b"}');

        // [WHEN] The tags are read
        OrderMgt.GetOrderTags(Order, Tags);

        // [THEN] Each tag is returned separately
        _Assert.AreEqual(2, Tags.Count(), 'A comma separated tag string should split into one entry per tag.');
        _Assert.IsTrue(Tags.Contains('vip'), 'The first tag should survive splitting.');
        _Assert.IsTrue(Tags.Contains('b2b'), 'The second tag should survive splitting.');
    end;

    [Test]
    procedure GetOrderTags_GraphQLArray_KeepsEveryTag()
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        Tags: List of [Text];
    begin
        // [SCENARIO] Tags arriving from the GraphQL download as an array are returned in full. Reading them
        //            with JsonHelper would return only element 0, so a rule matching the second tag would fail
        //            intermittently depending on the order Shopify happens to return the tags in.

        // [GIVEN] An order whose tags are an array of three values
        Order := OrderFrom('{"tags":["vip","b2b","webshop"]}');

        // [WHEN] The tags are read
        OrderMgt.GetOrderTags(Order, Tags);

        // [THEN] No tag beyond the first is dropped
        _Assert.AreEqual(3, Tags.Count(), 'Every element of the tag array should be returned, not just the first.');
        _Assert.IsTrue(Tags.Contains('webshop'), 'A tag after the first element must not be dropped.');
    end;

    [Test]
    procedure GetOrderTags_TrimsAndDeduplicates()
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        Tags: List of [Text];
    begin
        // [SCENARIO] Padding and repetition are normalised away, so a subscriber does not have to cope with
        //            either.

        // [GIVEN] An order whose tag string is padded and repeats a tag
        Order := OrderFrom('{"tags":"  vip , b2b ,vip"}');

        // [WHEN] The tags are read
        OrderMgt.GetOrderTags(Order, Tags);

        // [THEN] The tags come back trimmed and without duplicates
        _Assert.AreEqual(2, Tags.Count(), 'Padding should be trimmed and duplicates dropped.');
        _Assert.IsTrue(Tags.Contains('vip'), 'A padded tag should be returned trimmed.');
    end;

    [Test]
    procedure GetOrderTags_EmptyGraphQLArray_ReturnsNothing()
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        Tags: List of [Text];
    begin
        // [SCENARIO] A merchant that does not tag orders is not an error on the GraphQL download.

        // [GIVEN] An order whose tags are an empty array
        Order := OrderFrom('{"tags":[]}');

        // [WHEN] The tags are read
        OrderMgt.GetOrderTags(Order, Tags);

        // [THEN] No tags are returned
        _Assert.AreEqual(0, Tags.Count(), 'An empty GraphQL tag array should produce no tags.');
    end;

    [Test]
    procedure GetOrderTags_EmptyRestString_ReturnsNothing()
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        Tags: List of [Text];
    begin
        // [SCENARIO] A merchant that does not tag orders is not an error on the REST download.

        // [GIVEN] An order whose tags are an empty string
        Order := OrderFrom('{"tags":""}');

        // [WHEN] The tags are read
        OrderMgt.GetOrderTags(Order, Tags);

        // [THEN] No tags are returned
        _Assert.AreEqual(0, Tags.Count(), 'An empty REST tag string should produce no tags.');
    end;

    [Test]
    procedure GetOrderTags_MissingProperty_ReturnsNothing()
    var
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        Order: JsonToken;
        Tags: List of [Text];
    begin
        // [SCENARIO] An order payload without a tags property is read as having no tags rather than failing.

        // [GIVEN] An order carrying no tags property at all
        Order := OrderFrom('{"id":"gid://shopify/Order/1"}');

        // [WHEN] The tags are read
        OrderMgt.GetOrderTags(Order, Tags);

        // [THEN] No tags are returned
        _Assert.AreEqual(0, Tags.Count(), 'An order without a tags property should produce no tags.');
    end;

    //
    // Event wiring. Driven through SpfyOrderImportJQ.SaveOrder, which is the innermost entry point that still
    // raises the event. Cancelled is used deliberately: HasReadyState returns true unconditionally for it, so
    // these tests exercise the skip decision without needing allowed-financial-status setup, and they also pin
    // that the event really is raised on the delete pass and not only on create.
    //

    [Test]
    procedure SaveOrder_NoSubscriber_OrderIsAccepted()
    var
        ShopifyStore: Record "NPR Spfy Store";
        OrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        Accepted: Boolean;
    begin
        // [SCENARIO] The event is inert when nothing subscribes, so adding it changes no existing behaviour.

        // [GIVEN] A Shopify store and no subscriber bound
        InitStore(ShopifyStore);

        // [WHEN] A cancelled order is offered for download
        Accepted := OrderImportJQ.SaveOrder(ShopifyStore, CancelledOrder('1001', '["vip"]'), "NPR SpfyAPIDocumentStatus"::Cancelled, '');

        // [THEN] The order is accepted
        _Assert.IsTrue(Accepted, 'With no subscriber bound the order should be accepted.');
    end;

    [Test]
    procedure SaveOrder_SubscriberSkips_OrderIsRejected()
    var
        ShopifyStore: Record "NPR Spfy Store";
        OrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SkipSub: Codeunit "NPR Spfy SkipOrderDownloadSub";
        Accepted: Boolean;
    begin
        // [SCENARIO] An order a subscriber skips is rejected at download, before anything is written.

        // [GIVEN] A Shopify store and a subscriber that skips orders tagged 'skipme'
        InitStore(ShopifyStore);
        BindSubscription(SkipSub);
        SkipSub.Reset();
        SkipSub.SkipWhenTagged('skipme');

        // [WHEN] A cancelled order carrying that tag is offered for download
        Accepted := OrderImportJQ.SaveOrder(ShopifyStore, CancelledOrder('1002', '["skipme"]'), "NPR SpfyAPIDocumentStatus"::Cancelled, '');
        UnbindSubscription(SkipSub);

        // [THEN] The order is not accepted
        _Assert.IsFalse(Accepted, 'An order the subscriber skipped should not be accepted.');
    end;

    [Test]
    procedure SaveOrder_SubscriberIgnoresOrder_OrderIsAccepted()
    var
        ShopifyStore: Record "NPR Spfy Store";
        OrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SkipSub: Codeunit "NPR Spfy SkipOrderDownloadSub";
        Accepted: Boolean;
    begin
        // [SCENARIO] Leaving SkipImport alone means import. This is the polarity guard: were the parameter
        //            inverted, a subscriber that simply returns would drop every order it did not approve.

        // [GIVEN] A Shopify store and a subscriber that only skips orders tagged 'skipme'
        InitStore(ShopifyStore);
        BindSubscription(SkipSub);
        SkipSub.Reset();
        SkipSub.SkipWhenTagged('skipme');

        // [WHEN] A cancelled order without that tag is offered for download
        Accepted := OrderImportJQ.SaveOrder(ShopifyStore, CancelledOrder('1003', '["vip"]'), "NPR SpfyAPIDocumentStatus"::Cancelled, '');
        UnbindSubscription(SkipSub);

        // [THEN] The order is accepted
        _Assert.IsTrue(Accepted, 'An order the subscriber did not skip should be accepted.');
    end;

    [Test]
    procedure SaveOrder_SubscriberReceivesStoreStatusAndTags()
    var
        ShopifyStore: Record "NPR Spfy Store";
        OrderImportJQ: Codeunit "NPR Spfy Order Import JQ";
        SkipSub: Codeunit "NPR Spfy SkipOrderDownloadSub";
        ReceivedTags: List of [Text];
    begin
        // [SCENARIO] The subscriber is handed the store code, the pass being run and the normalised tags, so a
        //            rule can be scoped to the create pass instead of also vetoing posting and cancellation.

        // [GIVEN] A Shopify store and a subscriber that records what it is given
        InitStore(ShopifyStore);
        BindSubscription(SkipSub);
        SkipSub.Reset();

        // [WHEN] A cancelled order carrying two tags is offered for download
        OrderImportJQ.SaveOrder(ShopifyStore, CancelledOrder('1004', '["vip","b2b"]'), "NPR SpfyAPIDocumentStatus"::Cancelled, '');
        UnbindSubscription(SkipSub);

        // [THEN] The event was raised once, carrying the store, the pass and every tag
        _Assert.AreEqual(1, SkipSub.InvocationCount(), 'The event should be raised exactly once for one order.');
        _Assert.AreEqual(ShopifyStore.Code, SkipSub.LastStoreCode(), 'The store code should be passed to the subscriber.');
        _Assert.AreEqual(
            "NPR SpfyAPIDocumentStatus"::Cancelled, SkipSub.LastOrderStatus(),
            'The order status should identify which download pass is asking.');

        ReceivedTags := SkipSub.LastTags();
        _Assert.AreEqual(2, ReceivedTags.Count(), 'The subscriber should receive every tag on the order.');
        _Assert.IsTrue(ReceivedTags.Contains('b2b'), 'The subscriber should receive tags beyond the first.');
    end;

    local procedure InitStore(var ShopifyStore: Record "NPR Spfy Store")
    begin
        // Not inserted: the code under test reads only the store code on this path, and inserting a store
        // pulls in setup validation unrelated to the skip decision.
        Clear(ShopifyStore);
        ShopifyStore.Code := 'SKIPTEST';
    end;

    /// <summary>
    /// A Cancelled order carrying the fields the earlier eligibility checks require: a source name that is not
    /// the POS, plus the id and name that TryGetOrderProperties reads as required.
    /// </summary>
    local procedure CancelledOrder(OrderNo: Text; TagsJson: Text): JsonToken
    begin
        exit(
            OrderFrom(
                '{"id":"gid://shopify/Order/' + OrderNo + '","name":"#' + OrderNo + '","number":' + OrderNo +
                ',"sourceName":"web","updatedAt":"2026-01-01T00:00:00Z","tags":' + TagsJson + '}'));
    end;

    local procedure OrderFrom(OrderJson: Text) Order: JsonToken
    var
        OrderObject: JsonObject;
    begin
        OrderObject.ReadFrom(OrderJson);
        Order := OrderObject.AsToken();
    end;
}
#endif

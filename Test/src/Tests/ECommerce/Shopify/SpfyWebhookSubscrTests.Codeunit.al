#if not BC17
codeunit 85570 "NPR Spfy Webhook Subscr. Tests"
{
    // [FEATURE] Shopify webhook subscriptions: comparing what Shopify holds with what Business Central registered, and cleaning up this company's subscriptions on enable and disable
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _Assert: Codeunit "Assert";
        _StoreCodeLbl: Label 'SPFYTEST', Locked = true;
        _TenantIdLbl: Label '11111111-2222-3333-4444-555555555555', Locked = true;
        _ThisEnvironmentLbl: Label 'Production', Locked = true;
        _OtherEnvironmentLbl: Label 'Sandbox', Locked = true;
        _ThisCompanyLbl: Label 'CRONUS Golf', Locked = true;

    [Test]
    procedure MatchingSubscriptionDeliveringHere_IsOK()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
    begin
        // [SCENARIO] A subscription Business Central registered that Shopify still holds with the same address, delivering to this company, is OK.

        // [GIVEN] BC registered customers/update with this company's address, and Shopify holds the same subscription
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'CUSTOMERS_UPDATE', ThisCompanyUrl())));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] One line is listed, with status OK and the destination read from the address
        _Assert.RecordCount(TempWebhookSubscrBuffer, 1);
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::OK, TempWebhookSubscrBuffer.Status, 'A subscription both sides agree on and that delivers here must be OK.');
        _Assert.AreEqual('customers/update', TempWebhookSubscrBuffer.Topic, 'The topic must be shown as Shopify names it in notifications.');
        _Assert.AreEqual(_ThisEnvironmentLbl, TempWebhookSubscrBuffer."Destination Environment", 'The destination environment must be read from the address.');
        _Assert.AreEqual(_ThisCompanyLbl, TempWebhookSubscrBuffer."Destination Company", 'The destination company must be read from the address and URL-decoded.');
    end;

    [Test]
    procedure RegisteredSubscriptionShopifyNoLongerHas_IsMissingInShopify()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
    begin
        // [SCENARIO] A subscription Business Central registered that Shopify no longer holds is flagged as missing in Shopify.

        // [GIVEN] BC registered customers/update, but Shopify holds no subscriptions at all
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(''));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] The BC subscription is listed as missing in Shopify, with the destination read from the BC address
        _Assert.RecordCount(TempWebhookSubscrBuffer, 1);
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::"Missing in Shopify", TempWebhookSubscrBuffer.Status, 'A subscription Shopify no longer holds must be flagged as missing in Shopify.');
        _Assert.AreEqual(_ThisEnvironmentLbl, TempWebhookSubscrBuffer."Destination Environment", 'Without a Shopify subscription the destination must come from the BC address.');
    end;

    [Test]
    procedure SameWebhookIdWithDifferentAddress_IsAddressMismatch()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
    begin
        // [SCENARIO] When Shopify delivers a registered subscription to another address than BC recorded, the line is an address mismatch.

        // [GIVEN] BC recorded this company's address, but Shopify holds the same webhook ID with the sandbox's address
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'CUSTOMERS_UPDATE', OtherEnvironmentUrl())));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] One line is listed as an address mismatch, with the destination taken from Shopify's address
        _Assert.RecordCount(TempWebhookSubscrBuffer, 1);
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::"Address Mismatch", TempWebhookSubscrBuffer.Status, 'Differing addresses for the same webhook ID must be flagged.');
        _Assert.AreEqual(_OtherEnvironmentLbl, TempWebhookSubscrBuffer."Destination Environment", 'The destination must be where Shopify actually delivers.');
    end;

    [Test]
    procedure MatchingSubscriptionForAnotherEnvironment_DeliversElsewhere()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
    begin
        // [SCENARIO] A subscription both sides agree on that delivers to another environment, as after an environment copy, is flagged as delivering elsewhere.

        // [GIVEN] BC and Shopify both hold webhook 1001 with the sandbox's address
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', OtherEnvironmentUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'CUSTOMERS_UPDATE', OtherEnvironmentUrl())));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] The line is flagged as delivering elsewhere
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::"Delivers Elsewhere", TempWebhookSubscrBuffer.Status, 'A subscription delivering to another environment must not be OK.');
    end;

    [Test]
    procedure MatchingSubscriptionForAnotherCompany_DeliversElsewhere()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        OtherCompanyLbl: Label 'CRONUS Test', Locked = true;
    begin
        // [SCENARIO] A subscription delivering to another company in the same environment is flagged as delivering elsewhere.

        // [GIVEN] BC and Shopify both hold webhook 1001 with the address of another company in this environment
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', OtherCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'CUSTOMERS_UPDATE', OtherCompanyUrl())));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] The line is flagged as delivering elsewhere and names the other company
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::"Delivers Elsewhere", TempWebhookSubscrBuffer.Status, 'A subscription delivering to another company must not be OK.');
        _Assert.AreEqual(OtherCompanyLbl, TempWebhookSubscrBuffer."Destination Company", 'The destination company must name the other company.');
    end;

    [Test]
    procedure ShopifySubscriptionWithoutBCRecord_IsNotRegistered()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
    begin
        // [SCENARIO] A subscription Shopify holds that this company did not register is listed as not registered, with its destination.

        // [GIVEN] BC registered webhook 1001, and Shopify also holds webhook 2002 delivering to the sandbox
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(
            Node('1001', 'CUSTOMERS_UPDATE', ThisCompanyUrl()) + ',' + Node('2002', 'CUSTOMERS_UPDATE', OtherEnvironmentUrl())));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] Both subscriptions are listed: 1001 is OK, 2002 is not registered and names the sandbox as its destination
        _Assert.RecordCount(TempWebhookSubscrBuffer, 2);
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::OK, TempWebhookSubscrBuffer.Status, 'The registered subscription must stay OK.');
        FindLine(TempWebhookSubscrBuffer, '2002');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::"Not Registered", TempWebhookSubscrBuffer.Status, 'A Shopify-only subscription must be listed as not registered.');
        _Assert.AreEqual(_OtherEnvironmentLbl, TempWebhookSubscrBuffer."Destination Environment", 'A Shopify-only subscription must show where it delivers.');
        _Assert.AreEqual('', TempWebhookSubscrBuffer."Address in BC", 'A Shopify-only subscription has no BC address.');
    end;

    [Test]
    procedure ShopifySubscriptionWithUnknownTopic_IsListedWithShopifyTopicName()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
    begin
        // [SCENARIO] A Shopify subscription for a topic Business Central does not handle is still listed, under Shopify's topic name.

        // [GIVEN] Shopify holds an ORDERS_PAID subscription delivering to an address outside Business Central
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('3003', 'ORDERS_PAID', 'https://example.com/hooks/orders')));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] The subscription is listed as not registered, with the raw topic and no destination
        _Assert.RecordCount(TempWebhookSubscrBuffer, 1);
        FindLine(TempWebhookSubscrBuffer, '3003');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::"Not Registered", TempWebhookSubscrBuffer.Status, 'An unknown-topic subscription must be listed as not registered.');
        _Assert.AreEqual('ORDERS_PAID', TempWebhookSubscrBuffer.Topic, 'An unknown topic must keep Shopify''s name.');
        _Assert.AreEqual('', TempWebhookSubscrBuffer."Destination Company", 'An address outside Business Central has no destination company.');
        _Assert.AreEqual('https://example.com/hooks/orders', TempWebhookSubscrBuffer."Address in Shopify", 'An address without an access key must be shown unchanged.');
    end;

    [Test]
    procedure ShopifyNotReachable_RegisteredSubscriptionsAreNotChecked()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        ShopifyRead: Boolean;
    begin
        // [SCENARIO] When Shopify cannot be reached, the registered subscriptions are still listed, as not checked, and the error is returned.

        // [GIVEN] BC registered webhook 1001, and the request to Shopify fails
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddFailure('webhookSubscriptions');
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        ShopifyRead := SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] The check reports the failure with its reason, and the BC subscription is listed as not checked
        _Assert.IsFalse(ShopifyRead, 'A failed Shopify request must be reported.');
        _Assert.AreEqual('Mock GraphQL client simulated transport failure.', ShopifyErrorText, 'The reason for the failure must be returned.');
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::"Not Checked", TempWebhookSubscrBuffer.Status, 'Without Shopify the BC subscription must not be judged.');
    end;

    [Test]
    procedure ShopifyAnswersWithErrorsOnly_IsNotReadAsAnEmptyList()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        ShopifyRead: Boolean;
    begin
        // [SCENARIO] A Shopify answer that carries GraphQL errors instead of the list is a failure, not "Shopify has no subscriptions".

        // [GIVEN] BC registered webhook 1001, and Shopify answers with an access error and no data
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', '{"errors":[{"message":"Access denied for webhookSubscriptions field."}]}');
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        ShopifyRead := SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] The check fails with Shopify's message, and the BC subscription is not checked rather than missing
        _Assert.IsFalse(ShopifyRead, 'A response without the subscription list must be reported as a failure.');
        _Assert.IsTrue(ShopifyErrorText.Contains('Access denied for webhookSubscriptions field.'), 'The Shopify error message must be passed on.');
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::"Not Checked", TempWebhookSubscrBuffer.Status, 'An error answer must not make the subscription look missing in Shopify.');
    end;

    [Test]
    procedure AccessKeyInAddresses_IsMasked()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
    begin
        // [SCENARIO] The Azure Function key in a notification address never reaches the buffer, on either side.

        // [GIVEN] BC and Shopify both hold webhook 1001 with an address carrying the function key
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'CUSTOMERS_UPDATE', ThisCompanyUrl())));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] Both addresses show the key masked and keep the rest of the address
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(MaskedThisCompanyUrl(), TempWebhookSubscrBuffer."Address in Shopify", 'The key must be masked in the Shopify address.');
        _Assert.AreEqual(MaskedThisCompanyUrl(), TempWebhookSubscrBuffer."Address in BC", 'The key must be masked in the BC address.');
    end;

    [Test]
    procedure SubscriptionsOnLaterPage_AreCompared()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        NextPageCursorLbl: Label 'NEXTPAGECURSOR', Locked = true;
    begin
        // [SCENARIO] Shopify's list is read across all pages, so a subscription on a later page is not reported as missing.

        // [GIVEN] BC registered webhook 1001, and Shopify returns it on the second page
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse(NextPageCursorLbl, LastPage(Node('1001', 'CUSTOMERS_UPDATE', ThisCompanyUrl())));
        MockClient.AddResponse('webhookSubscriptions', SubscriptionsPage(Node('2002', 'PRODUCTS_UPDATE', OtherEnvironmentUrl()), true, NextPageCursorLbl));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] Both pages were read and the registered subscription is OK
        _Assert.AreEqual(2, MockClient.RequestCount(), 'Both pages must be requested.');
        FindLine(TempWebhookSubscrBuffer, '1001');
        _Assert.AreEqual(TempWebhookSubscrBuffer.Status::OK, TempWebhookSubscrBuffer.Status, 'A subscription on the second page must be matched.');
        FindLine(TempWebhookSubscrBuffer, '2002');
        _Assert.AreEqual('products/update', TempWebhookSubscrBuffer.Topic, 'Topics on the second page must be mapped too.');
    end;

    [Test]
    procedure ShopifyRequest_IsNotFilteredByTopic()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        Request: Text;
    begin
        // [SCENARIO] The check asks Shopify for subscriptions of every topic, not only the topics Business Central registered.

        // [GIVEN] BC registered customers/update, and Shopify answers with an empty list
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(''));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] The subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] The request sends no topics variable
        Request := MockClient.GetRequestContaining('webhookSubscriptions');
        _Assert.AreNotEqual('', Request, 'Shopify must be asked for the subscriptions.');
        _Assert.IsFalse(Request.Contains('"topics"'), 'The request must not filter by topic.');
    end;

    [Test]
    procedure SubscriptionsOfAnotherStore_AreIgnored()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        OtherStoreCodeLbl: Label 'SPFYOTHER', Locked = true;
    begin
        // [SCENARIO] Only the checked store's BC records are compared, so another store's records do not show up as missing in Shopify.

        // [GIVEN] BC holds a record for another store only, and Shopify holds no subscriptions for this store
        AddBCSubscription(TempSpfyWebhookSubscription, OtherStoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '9009', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(''));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);

        // [WHEN] This store's subscriptions are compared
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [THEN] Nothing is listed
        _Assert.RecordIsEmpty(TempWebhookSubscrBuffer);
    end;

    [Test]
    procedure Cleanup_RemovesUnrecordedSubscriptionDeliveringHere()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
        ErrorText: Text;
        KeptElsewhere: List of [Text];
    begin
        // [SCENARIO] A subscription for the toggled topic that delivers to this company is removed from Shopify even though BC has no record of it.
        Initialize();

        // [GIVEN] Shopify holds products/update subscription 2002 delivering here, and BC has no record of it
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('2002', 'PRODUCTS_UPDATE', ThisCompanyUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', DeleteResponse());
        InitMgt(SpfyWebhookMgt, MockClient);

        // [WHEN] This company's products/update subscriptions are cleaned up
        SpfyWebhookMgt.RemoveSubscriptionsDeliveringHere(_StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/update", ErrorText, KeptElsewhere);

        // [THEN] Subscription 2002 is deleted in Shopify
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('webhookSubscriptionDelete'), 'Exactly one subscription must be deleted.');
        _Assert.AreNotEqual('', MockClient.GetRequestContaining('webhookSubscriptionDelete', 'WebhookSubscription/2002'), 'The unrecorded subscription delivering here must be deleted.');
    end;

    [Test]
    procedure Cleanup_KeepsSubscriptionsDeliveringElsewhere()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
        ErrorText: Text;
        KeptElsewhere: List of [Text];
    begin
        // [SCENARIO] Subscriptions for the toggled topic that deliver to another environment, another company or outside BC are left alone.
        Initialize();

        // [GIVEN] Shopify holds products/update subscriptions for the sandbox, another company and an outside address
        MockClient.AddResponse('webhookSubscriptions', LastPage(
            Node('3003', 'PRODUCTS_UPDATE', OtherEnvironmentUrl()) + ',' +
            Node('4004', 'PRODUCTS_UPDATE', OtherCompanyUrl()) + ',' +
            Node('5005', 'PRODUCTS_UPDATE', 'https://example.com/hooks/products')));
        MockClient.AddResponse('webhookSubscriptionDelete', DeleteResponse());
        InitMgt(SpfyWebhookMgt, MockClient);

        // [WHEN] This company's products/update subscriptions are cleaned up
        SpfyWebhookMgt.RemoveSubscriptionsDeliveringHere(_StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/update", ErrorText, KeptElsewhere);

        // [THEN] Nothing is deleted
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('webhookSubscriptionDelete'), 'Subscriptions delivering elsewhere must never be deleted by this company.');
    end;

    [Test]
    procedure Cleanup_TouchesOnlyTheToggledTopic()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
        ErrorText: Text;
        KeptElsewhere: List of [Text];
    begin
        // [SCENARIO] The cleanup asks Shopify for the toggled topic only, and never deletes another topic's subscription even if Shopify returns one.
        Initialize();

        // [GIVEN] Shopify returns a customers/update subscription delivering here while products/update is toggled
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('6006', 'CUSTOMERS_UPDATE', ThisCompanyUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', DeleteResponse());
        InitMgt(SpfyWebhookMgt, MockClient);

        // [WHEN] This company's products/update subscriptions are cleaned up
        SpfyWebhookMgt.RemoveSubscriptionsDeliveringHere(_StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/update", ErrorText, KeptElsewhere);

        // [THEN] Shopify was asked for products/update only, and the customers/update subscription survives
        _Assert.AreNotEqual('', MockClient.GetRequestContaining('"topics":["PRODUCTS_UPDATE"]'), 'The request must filter on the toggled topic.');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('webhookSubscriptionDelete'), 'Another topic''s subscription must not be deleted.');
    end;

    [Test]
    procedure Disable_RemovesRecordedAndUnrecordedSubscriptionsDeliveringHere()
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
    begin
        // [SCENARIO] Disabling a webhook removes every subscription for the topic that delivers to this company, recorded or not, keeps the ones delivering elsewhere, and clears BC's records.
        Initialize();

        // [GIVEN] BC recorded products/update subscription 1001; Shopify holds 1001 and 2002 delivering here and 3003 delivering to the sandbox
        AddRecordedSubscription(Enum::"NPR Spfy Webhook Topic"::"products/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(
            Node('1001', 'PRODUCTS_UPDATE', ThisCompanyUrl()) + ',' +
            Node('2002', 'PRODUCTS_UPDATE', ThisCompanyUrl()) + ',' +
            Node('3003', 'PRODUCTS_UPDATE', OtherEnvironmentUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', DeleteResponse());
        InitMgt(SpfyWebhookMgt, MockClient);

        // [WHEN] The products/update webhook is disabled
        SpfyWebhookMgt.DisableWebhook(_StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/update");

        // [THEN] 1001 and 2002 are deleted in Shopify, 3003 is kept
        _Assert.AreEqual(2, MockClient.CountRequestsContaining('webhookSubscriptionDelete'), 'Both subscriptions delivering here must be deleted, and only those.');
        _Assert.AreNotEqual('', MockClient.GetRequestContaining('webhookSubscriptionDelete', 'WebhookSubscription/1001'), 'The recorded subscription must be deleted.');
        _Assert.AreNotEqual('', MockClient.GetRequestContaining('webhookSubscriptionDelete', 'WebhookSubscription/2002'), 'The unrecorded subscription delivering here must be deleted.');
        _Assert.AreEqual('', MockClient.GetRequestContaining('webhookSubscriptionDelete', 'WebhookSubscription/3003'), 'The sandbox''s subscription must be kept.');

        // [THEN] BC no longer has a record for the topic
        SpfyWebhookSubscription.SetRange("Store Code", _StoreCodeLbl);
        SpfyWebhookSubscription.SetRange(Topic, Enum::"NPR Spfy Webhook Topic"::"products/update");
        _Assert.RecordIsEmpty(SpfyWebhookSubscription);
    end;

    [Test]
    [HandlerFunctions('KeptElsewhereMessageHandler')]
    procedure Disable_InRestoredEnvironment_KeepsTheSourceEnvironmentsSubscription()
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
    begin
        // [SCENARIO] In an environment restored with "Skip environment cleanup", disabling a webhook leaves the source environment's subscription in Shopify, drops the copied record and tells the user where the subscription delivers.
        Initialize();

        // [GIVEN] BC holds the copied record of subscription 1001, and Shopify delivers 1001 to the source environment
        AddRecordedSubscription(Enum::"NPR Spfy Webhook Topic"::"products/update", '1001', OtherEnvironmentUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'PRODUCTS_UPDATE', OtherEnvironmentUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', DeleteResponse());
        InitMgt(SpfyWebhookMgt, MockClient);

        // [WHEN] The products/update webhook is disabled
        SpfyWebhookMgt.DisableWebhook(_StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/update");

        // [THEN] Nothing is deleted in Shopify, the copied record is gone, and the message (checked by the handler) names the source environment
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('webhookSubscriptionDelete'), 'The source environment''s subscription must not be deleted.');
        SpfyWebhookSubscription.SetRange("Store Code", _StoreCodeLbl);
        SpfyWebhookSubscription.SetRange(Topic, Enum::"NPR Spfy Webhook Topic"::"products/update");
        _Assert.RecordIsEmpty(SpfyWebhookSubscription);
    end;

    [Test]
    procedure Cleanup_InRestoredEnvironment_KeepsTheSourceEnvironmentsSubscription()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
        ErrorText: Text;
        KeptElsewhere: List of [Text];
    begin
        // [SCENARIO] The cleanup that enabling runs before registering never deletes a recorded subscription that delivers to another environment, and reports it instead.
        Initialize();

        // [GIVEN] BC holds the copied record of subscription 1001, and Shopify delivers 1001 to the source environment
        AddRecordedSubscription(Enum::"NPR Spfy Webhook Topic"::"products/update", '1001', OtherEnvironmentUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'PRODUCTS_UPDATE', OtherEnvironmentUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', DeleteResponse());
        InitMgt(SpfyWebhookMgt, MockClient);

        // [WHEN] This company's products/update subscriptions are cleaned up
        SpfyWebhookMgt.RemoveSubscriptionsDeliveringHere(_StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/update", ErrorText, KeptElsewhere);

        // [THEN] Nothing is deleted, and the subscription is reported with its destination
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('webhookSubscriptionDelete'), 'The source environment''s subscription must not be deleted.');
        _Assert.AreEqual(1, KeptElsewhere.Count(), 'The recorded subscription delivering elsewhere must be reported.');
        _Assert.AreEqual(_OtherEnvironmentLbl + ' / ' + _ThisCompanyLbl, KeptElsewhere.Get(1), 'The report must name the environment and company it delivers to.');
    end;

    [Test]
    procedure DeleteInShopify_DeletesSubscriptionDeliveringElsewhereAndItsRecord()
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        FailedDeletes: List of [Text];
        Deleted: Boolean;
    begin
        // [SCENARIO] A user can delete a subscription that delivers to another environment from the page, which also drops this company's record of it.
        Initialize();

        // [GIVEN] BC holds the copied record of subscription 1001, Shopify delivers it to the source environment, and the page lists it
        AddRecordedSubscription(Enum::"NPR Spfy Webhook Topic"::"products/update", '1001', OtherEnvironmentUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'PRODUCTS_UPDATE', OtherEnvironmentUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', DeleteResponse());
        InitCheck(SpfyWebhookSubscrCheck, MockClient);
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempWebhookSubscrBuffer, ShopifyErrorText);
        FindLine(TempWebhookSubscrBuffer, '1001');
        TempWebhookSubscrBuffer.SetRange("Webhook ID", '1001');

        // [WHEN] The user deletes the selected line in Shopify
        Deleted := SpfyWebhookSubscrCheck.DeleteInShopify(_StoreCodeLbl, TempWebhookSubscrBuffer, FailedDeletes);

        // [THEN] Shopify was asked to delete 1001, the confirmation names its destination, and BC's record is gone
        _Assert.IsTrue(Deleted, 'The delete must succeed.');
        _Assert.AreNotEqual('', MockClient.GetRequestContaining('webhookSubscriptionDelete', 'WebhookSubscription/1001'), 'Subscription 1001 must be deleted in Shopify.');
        _Assert.AreEqual(_OtherEnvironmentLbl + ' / ' + _ThisCompanyLbl, SpfyWebhookSubscrCheck.DescribeDestinations(TempWebhookSubscrBuffer), 'The confirmation must name where the subscription delivers.');
        SpfyWebhookSubscription.SetRange("Store Code", _StoreCodeLbl);
        SpfyWebhookSubscription.SetRange("Webhook ID", '1001');
        _Assert.RecordIsEmpty(SpfyWebhookSubscription);
    end;

    [Test]
    procedure DeleteInShopify_RefusesSubscriptionDeliveringHere()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        FailedDeletes: List of [Text];
    begin
        // [SCENARIO] The page refuses to delete a subscription that delivers to this company, because that one is managed by the webhook setting.

        // [GIVEN] Subscription 1001 is OK and delivers here, and the page lists it
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'CUSTOMERS_UPDATE', ThisCompanyUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', DeleteResponse());
        InitCheck(SpfyWebhookSubscrCheck, MockClient);
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);
        TempWebhookSubscrBuffer.SetRange("Webhook ID", '1001');

        // [WHEN] The user tries to delete it in Shopify
        asserterror SpfyWebhookSubscrCheck.DeleteInShopify(_StoreCodeLbl, TempWebhookSubscrBuffer, FailedDeletes);

        // [THEN] The delete is refused and nothing is sent to Shopify
        _Assert.ExpectedError('cannot be deleted here');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('webhookSubscriptionDelete'), 'A subscription delivering here must not be deleted from the page.');
    end;

    [Test]
    procedure DeleteInShopify_KeepsTheRecordWhenShopifyRefuses()
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        FailedDeletes: List of [Text];
        Deleted: Boolean;
    begin
        // [SCENARIO] When Shopify refuses the delete, the failure is reported with Shopify's reason and this company's record is kept.
        Initialize();

        // [GIVEN] The page lists the copied subscription 1001 delivering elsewhere, and Shopify refuses to delete it
        AddRecordedSubscription(Enum::"NPR Spfy Webhook Topic"::"products/update", '1001', OtherEnvironmentUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('1001', 'PRODUCTS_UPDATE', OtherEnvironmentUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', '{"data":{"webhookSubscriptionDelete":{"deletedWebhookSubscriptionId":null,"userErrors":[{"field":["id"],"message":"Webhook subscription is locked."}]}}}');
        InitCheck(SpfyWebhookSubscrCheck, MockClient);
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempWebhookSubscrBuffer, ShopifyErrorText);
        TempWebhookSubscrBuffer.SetRange("Webhook ID", '1001');

        // [WHEN] The user deletes it in Shopify
        Deleted := SpfyWebhookSubscrCheck.DeleteInShopify(_StoreCodeLbl, TempWebhookSubscrBuffer, FailedDeletes);

        // [THEN] The failure carries Shopify's reason, and BC's record is still there
        _Assert.IsFalse(Deleted, 'A refused delete must be reported.');
        _Assert.AreEqual(1, FailedDeletes.Count(), 'The refused delete must be listed.');
        _Assert.IsTrue(FailedDeletes.Get(1).Contains('Webhook subscription is locked.'), 'The failure must carry Shopify''s reason.');
        SpfyWebhookSubscription.SetRange("Store Code", _StoreCodeLbl);
        SpfyWebhookSubscription.SetRange("Webhook ID", '1001');
        _Assert.RecordIsNotEmpty(SpfyWebhookSubscription);
    end;

    [Test]
    procedure Enable_WhenALeftoverCannotBeRemoved_FailsWithTheReason()
    var
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
    begin
        // [SCENARIO] When a leftover subscription delivering here cannot be removed, enabling stops with Shopify's reason instead of failing later with "Address for this topic has already been taken".
        Initialize();

        // [GIVEN] Shopify holds a products/update subscription delivering here, and refuses to delete it
        MockClient.AddResponse('webhookSubscriptions', LastPage(Node('2002', 'PRODUCTS_UPDATE', ThisCompanyUrl())));
        MockClient.AddResponse('webhookSubscriptionDelete', '{"data":{"webhookSubscriptionDelete":{"deletedWebhookSubscriptionId":null,"userErrors":[{"field":["id"],"message":"Webhook subscription is locked."}]}}}');
        InitMgt(SpfyWebhookMgt, MockClient);

        // [WHEN] The products/update webhook is enabled
        asserterror SpfyWebhookMgt.ToggleWebhook(_StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/update", true);

        // [THEN] Enabling fails with Shopify's reason for the failed removal, and nothing was registered
        _Assert.ExpectedError('Webhook subscription is locked.');
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('webhookSubscriptionCreate'), 'No registration may be attempted after a failed cleanup.');
    end;

    [Test]
    procedure AttentionCount_LeavesOutOtherEnvironmentsSubscriptions()
    var
        TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary;
        TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check";
        ShopifyErrorText: Text;
        RepairableByToggle: Integer;
        ForeignRecords: Integer;
    begin
        // [SCENARIO] Lines this company can repair by toggling and its records of subscriptions delivering elsewhere are counted apart; another environment's own subscription is not counted.

        // [GIVEN] 1001 is OK, 4004 is missing in Shopify, 3003 delivers here without a BC record, 2002 belongs to the sandbox, and 5005 is a record of a subscription delivering to the sandbox
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"customers/update", '1001', ThisCompanyUrl());
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/create", '4004', ThisCompanyUrl());
        AddBCSubscription(TempSpfyWebhookSubscription, _StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/delete", '5005', OtherEnvironmentUrl());
        MockClient.AddResponse('webhookSubscriptions', LastPage(
            Node('1001', 'CUSTOMERS_UPDATE', ThisCompanyUrl()) + ',' +
            Node('3003', 'PRODUCTS_UPDATE', ThisCompanyUrl()) + ',' +
            Node('2002', 'PRODUCTS_UPDATE', OtherEnvironmentUrl()) + ',' +
            Node('5005', 'PRODUCTS_DELETE', OtherEnvironmentUrl())));
        InitCheck(SpfyWebhookSubscrCheck, MockClient);
        SpfyWebhookSubscrCheck.CompareWithShopify(_StoreCodeLbl, TempSpfyWebhookSubscription, TempWebhookSubscrBuffer, ShopifyErrorText);

        // [WHEN] The lines needing attention are counted
        SpfyWebhookSubscrCheck.CountNeedingAttention(TempWebhookSubscrBuffer, RepairableByToggle, ForeignRecords);

        // [THEN] 4004 and 3003 are repairable by toggling, 5005 is a foreign record, and the sandbox's own 2002 is in neither count
        _Assert.AreEqual(2, RepairableByToggle, 'The missing subscription and the unrecorded one delivering here are repaired by toggling.');
        _Assert.AreEqual(1, ForeignRecords, 'Only the record of a subscription delivering elsewhere counts as foreign.');
        FindLine(TempWebhookSubscrBuffer, '3003');
        _Assert.IsTrue(TempWebhookSubscrBuffer."Delivers to This Company", 'The unrecorded subscription delivering here must be flagged as delivering here.');
        FindLine(TempWebhookSubscrBuffer, '2002');
        _Assert.IsFalse(TempWebhookSubscrBuffer."Delivers to This Company", 'The sandbox''s subscription must not be flagged as delivering here.');
    end;

    [Test]
    [HandlerFunctions('RemovalFailedMessageHandler')]
    procedure Disable_WhenShopifyCannotBeRead_WarnsAndClearsRecords()
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt.";
    begin
        // [SCENARIO] When Shopify cannot be read during disable, the user is told and BC's records for the topic are still cleared.
        Initialize();

        // [GIVEN] BC recorded subscription 1001, and reading Shopify fails
        AddRecordedSubscription(Enum::"NPR Spfy Webhook Topic"::"products/update", '1001', ThisCompanyUrl());
        MockClient.AddFailure('webhookSubscriptions');
        InitMgt(SpfyWebhookMgt, MockClient);

        // [WHEN] The products/update webhook is disabled
        SpfyWebhookMgt.DisableWebhook(_StoreCodeLbl, Enum::"NPR Spfy Webhook Topic"::"products/update");

        // [THEN] The warning was shown (checked by the handler), nothing was deleted, and BC's record is gone
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('webhookSubscriptionDelete'), 'Nothing can be deleted without the list.');
        SpfyWebhookSubscription.SetRange("Store Code", _StoreCodeLbl);
        SpfyWebhookSubscription.SetRange(Topic, Enum::"NPR Spfy Webhook Topic"::"products/update");
        _Assert.RecordIsEmpty(SpfyWebhookSubscription);
    end;

    [MessageHandler]
    procedure RemovalFailedMessageHandler(Msg: Text[1024])
    begin
        _Assert.IsTrue(Msg.Contains('Mock GraphQL client simulated transport failure.'), 'The warning must carry the Shopify error.');
    end;

    [MessageHandler]
    procedure KeptElsewhereMessageHandler(Msg: Text[1024])
    begin
        _Assert.IsTrue(Msg.Contains(_OtherEnvironmentLbl + ' / ' + _ThisCompanyLbl), 'The message must name where the kept subscription delivers.');
    end;

    local procedure Initialize()
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
    begin
        // Test isolation is per codeunit, so records written by an earlier test are still there.
        SpfyWebhookSubscription.SetRange("Store Code", _StoreCodeLbl);
        if not SpfyWebhookSubscription.IsEmpty() then
            SpfyWebhookSubscription.DeleteAll();
    end;

    local procedure InitMgt(var SpfyWebhookMgt: Codeunit "NPR Spfy Webhook Mgt."; var MockClient: Codeunit "NPR Spfy Mock GraphQL Client")
    begin
        SpfyWebhookMgt.SetGraphQLClient(MockClient);
        SpfyWebhookMgt.SetCurrentDestination(_TenantIdLbl, _ThisEnvironmentLbl, _ThisCompanyLbl);
    end;

    local procedure AddRecordedSubscription(Topic: Enum "NPR Spfy Webhook Topic"; WebhookId: Text[50]; Address: Text)
    var
        SpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription";
    begin
        SpfyWebhookSubscription.Init();
        SpfyWebhookSubscription."Entry No." := 0;
        SpfyWebhookSubscription."Store Code" := _StoreCodeLbl;
        SpfyWebhookSubscription.Topic := Topic;
        SpfyWebhookSubscription."Webhook ID" := WebhookId;
        SpfyWebhookSubscription."Api Version" := '2025-10';
        SpfyWebhookSubscription.Address := CopyStr(Address, 1, MaxStrLen(SpfyWebhookSubscription.Address));
        SpfyWebhookSubscription.Insert();
    end;

    local procedure DeleteResponse(): Text
    begin
        exit('{"data":{"webhookSubscriptionDelete":{"deletedWebhookSubscriptionId":"gid://shopify/WebhookSubscription/1","userErrors":[]}}}');
    end;

    local procedure InitCheck(var SpfyWebhookSubscrCheck: Codeunit "NPR Spfy Webhook Subscr. Check"; var MockClient: Codeunit "NPR Spfy Mock GraphQL Client")
    begin
        SpfyWebhookSubscrCheck.SetGraphQLClient(MockClient);
        SpfyWebhookSubscrCheck.SetCurrentDestination(_TenantIdLbl, _ThisEnvironmentLbl, _ThisCompanyLbl);
    end;

    local procedure AddBCSubscription(var TempSpfyWebhookSubscription: Record "NPR Spfy Webhook Subscription" temporary; StoreCode: Code[20]; Topic: Enum "NPR Spfy Webhook Topic"; WebhookId: Text[50]; Address: Text)
    var
        EntryNo: BigInteger;
    begin
        TempSpfyWebhookSubscription.Reset();
        if TempSpfyWebhookSubscription.FindLast() then
            EntryNo := TempSpfyWebhookSubscription."Entry No.";
        TempSpfyWebhookSubscription.Init();
        TempSpfyWebhookSubscription."Entry No." := EntryNo + 1;
        TempSpfyWebhookSubscription."Store Code" := StoreCode;
        TempSpfyWebhookSubscription.Topic := Topic;
        TempSpfyWebhookSubscription."Webhook ID" := WebhookId;
        TempSpfyWebhookSubscription."Api Version" := '2025-10';
        TempSpfyWebhookSubscription.Address := CopyStr(Address, 1, MaxStrLen(TempSpfyWebhookSubscription.Address));
        TempSpfyWebhookSubscription.Insert();
    end;

    local procedure FindLine(var TempWebhookSubscrBuffer: Record "NPR Spfy WH Subscr. Buffer" temporary; WebhookId: Text)
    begin
        TempWebhookSubscrBuffer.Reset();
        TempWebhookSubscrBuffer.SetRange("Webhook ID", WebhookId);
        _Assert.RecordCount(TempWebhookSubscrBuffer, 1);
        TempWebhookSubscrBuffer.FindFirst();
        TempWebhookSubscrBuffer.Reset();
    end;

    local procedure NotificationUrl(EnvironmentName: Text; EncodedCompanyName: Text): Text
    var
        NotificationUrlTok: Label 'https://npshopifywebhook.azurewebsites.net/api/ShopifyCloud/%1/%2?code=%3&CompanyName=%4', Locked = true;
        SecretLbl: Label 'S3cr3tFunctionKey==', Locked = true;
    begin
        exit(StrSubstNo(NotificationUrlTok, _TenantIdLbl, EnvironmentName, SecretLbl, EncodedCompanyName));
    end;

    local procedure ThisCompanyUrl(): Text
    begin
        exit(NotificationUrl(_ThisEnvironmentLbl, 'CRONUS%20Golf'));
    end;

    local procedure MaskedThisCompanyUrl(): Text
    var
        MaskedUrlTok: Label 'https://npshopifywebhook.azurewebsites.net/api/ShopifyCloud/%1/%2?code=***&CompanyName=%3', Locked = true;
    begin
        exit(StrSubstNo(MaskedUrlTok, _TenantIdLbl, _ThisEnvironmentLbl, 'CRONUS%20Golf'));
    end;

    local procedure OtherEnvironmentUrl(): Text
    begin
        exit(NotificationUrl(_OtherEnvironmentLbl, 'CRONUS%20Golf'));
    end;

    local procedure OtherCompanyUrl(): Text
    begin
        exit(NotificationUrl(_ThisEnvironmentLbl, 'CRONUS%20Test'));
    end;

    local procedure Node(WebhookId: Text; GraphQLTopic: Text; Address: Text): Text
    var
        NodeTok: Label '{"node":{"id":"gid://shopify/WebhookSubscription/%1","apiVersion":{"displayName":"2025-10","supported":true},"topic":"%2","uri":"%3","createdAt":"2026-10-20T08:15:00Z"}}', Locked = true;
    begin
        exit(StrSubstNo(NodeTok, WebhookId, GraphQLTopic, Address));
    end;

    local procedure LastPage(Edges: Text): Text
    begin
        exit(SubscriptionsPage(Edges, false, ''));
    end;

    local procedure SubscriptionsPage(Edges: Text; HasNextPage: Boolean; EndCursor: Text): Text
    var
        EndCursorJson: Text;
        SubscriptionsPageTok: Label '{"data":{"webhookSubscriptions":{"edges":[%1],"pageInfo":{"endCursor":%2,"hasNextPage":%3}}}}', Locked = true;
    begin
        if EndCursor = '' then
            EndCursorJson := 'null'
        else
            EndCursorJson := '"' + EndCursor + '"';
        exit(StrSubstNo(SubscriptionsPageTok, Edges, EndCursorJson, Format(HasNextPage, 0, 9)));
    end;
}
#endif

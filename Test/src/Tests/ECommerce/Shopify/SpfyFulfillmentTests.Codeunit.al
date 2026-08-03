#if not BC17
codeunit 85265 "NPR Spfy Fulfillment Tests"
{
    // [Feature] Shopify Order Fulfillments
    // Tests for "NPR Spfy Send Fulfillment" driven end-to-end against the reusable mock GraphQL client:
    // single-location baselines plus the multi-location group-by-location behaviour and its failure paths.
    Subtype = Test;
    TestPermissions = Disabled;

    var
        _LibrarySpfyFulfillment: Codeunit "NPR Library - Spfy Fulfillment";
        _Assert: Codeunit "Assert";
        _StoreCodeLbl: Label 'SPFYTEST', Locked = true;

    [Test]
    procedure SingleLocation_SendsOneMutationWithAllLines()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine1: Record "Sales Shipment Line";
        SalesShipmentLine2: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        SendRequest: Text;
    begin
        // [Scenario] An order whose lines are all at one Shopify location fulfills in a single fulfillmentCreate.

        // [Given] A posted shipment with two Shopify-mapped lines, and one Fulfillment Order covering both
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-A', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-A', 10000, 2, '1001', SalesShipmentLine1);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-A', 20000, 3, '1002', SalesShipmentLine2);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5001', SalesShipmentHeader, NcTask);
        ConfigureMock(MockClient, '9001', BuildTwoLineFulfillment());

        // [When] The fulfillment sender runs against the mocked Shopify
        SendFulfillment.SetGraphQLClient(MockClient);
        SendFulfillment.Run(NcTask);

        // [Then] Exactly one fulfillmentCreate mutation was sent, containing both fulfillment-order lines
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('fulfillmentCreate('), 'A single-location order must produce exactly one fulfillmentCreate mutation.');
        SendRequest := MockClient.GetRequestContaining('fulfillmentCreate(');
        _Assert.IsTrue(SendRequest.Contains('FulfillmentOrderLineItem/7001'), 'The mutation must contain the first fulfillment-order line.');
        _Assert.IsTrue(SendRequest.Contains('FulfillmentOrderLineItem/7002'), 'The mutation must contain the second fulfillment-order line.');

        // [Then] One fulfillment entry is persisted per shipment line, each carrying the Shopify Fulfillment id (for later cancellation)
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine1.RecordId()), 'One fulfillment entry expected for line 1.');
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine2.RecordId()), 'One fulfillment entry expected for line 2.');
        _Assert.AreEqual('999', FulfillmentEntryFulfillmentId(SalesShipmentLine1.RecordId()), 'The saved entry must carry the Shopify Fulfillment id returned by fulfillmentCreate.');
    end;

    [Test]
    procedure Tracking_IsAttachedToMutation()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        SendRequest: Text;
    begin
        // [Scenario] Shipment tracking info flows into the fulfillmentCreate mutation.

        // [Given] A posted shipment carrying a shipping agent + tracking number
        _LibrarySpfyFulfillment.CreateShippingAgent('SPFYDHL', 'DHL Express');
        _LibrarySpfyFulfillment.CreateShipmentHeaderWithTracking('SPFYFUL-B', 'SPFYDHL', '1Z999AA10123456784', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-B', 10000, 2, '1001', SalesShipmentLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5002', SalesShipmentHeader, NcTask);
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7001', 2, '1001');
        ConfigureMock(MockClient, '9001', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLines));

        // [When] The fulfillment sender runs
        SendFulfillment.SetGraphQLClient(MockClient);
        SendFulfillment.Run(NcTask);

        // [Then] The mutation carries the tracking company and number
        SendRequest := MockClient.GetRequestContaining('fulfillmentCreate(');
        _Assert.IsTrue(SendRequest.Contains('trackingInfo'), 'The mutation must include trackingInfo.');
        _Assert.IsTrue(SendRequest.Contains('1Z999AA10123456784'), 'The mutation must include the package tracking number.');
        _Assert.IsTrue(SendRequest.Contains('DHL Express'), 'The mutation must include the tracking company name.');
    end;

    [Test]
    procedure PartialPosting_FulfillsRequestedQuantityOnly()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        SpfyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        // [Scenario] Shipping fewer units than the fulfillment order has remaining fulfills only what was shipped.

        // [Given] A shipment line for 2 units against a fulfillment order line with 5 remaining
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-C', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-C', 10000, 2, '1001', SalesShipmentLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5003', SalesShipmentHeader, NcTask);
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7001', 5, '1001');
        ConfigureMock(MockClient, '9001', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLines));

        // [When] The fulfillment sender runs
        SendFulfillment.SetGraphQLClient(MockClient);
        SendFulfillment.Run(NcTask);

        // [Then] The mutation asks Shopify to fulfill exactly the shipped quantity (the wire payload, shaped by AddIntQuantityToJson)
        _Assert.IsTrue(MockClient.GetRequestContaining('fulfillmentCreate(').Contains('"quantity":2'), 'The mutation must fulfill exactly the shipped quantity.');

        // [Then] Exactly the shipped quantity is fulfilled against the still-open fulfillment order line
        SpfyFulfillmentEntry.SetRange("BC Record ID", SalesShipmentLine.RecordId());
        _Assert.AreEqual(1, SpfyFulfillmentEntry.Count(), 'One fulfillment entry expected.');
        SpfyFulfillmentEntry.FindFirst();
        _Assert.AreEqual(2, SpfyFulfillmentEntry."Fulfilled Quantity", 'Only the shipped quantity should be fulfilled.');
        _Assert.AreEqual(5, SpfyFulfillmentEntry."Fulfillable Quantity", 'The fulfillment order line still had 5 remaining.');
    end;

    [Test]
    procedure MultipleFOsAtOneLocation_SingleMutationKeepsAllLines()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine1: Record "Sales Shipment Line";
        SalesShipmentLine2: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        SendRequest: Text;
    begin
        // [Scenario] Two fulfillment orders at the SAME location go into one mutation, and every line survives the
        // fulfillment-order grouping loop (guards the boundary-line-dropping bug the stage-4 rewrite fixes).

        // [Given] A shipment whose two lines map to two fulfillment orders, both at location 100
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-D', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-D', 10000, 2, '1001', SalesShipmentLine1);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-D', 20000, 2, '1002', SalesShipmentLine2);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5004', SalesShipmentHeader, NcTask);
        ConfigureTwoFoFetch(MockClient, '100', '100');
        MockClient.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));

        // [When] The fulfillment sender runs
        SendFulfillment.SetGraphQLClient(MockClient);
        SendFulfillment.Run(NcTask);

        // [Then] Exactly one mutation is sent (one location), carrying both fulfillment orders and both their lines
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('fulfillmentCreate('), 'Two fulfillment orders at one location must produce a single mutation.');
        SendRequest := MockClient.GetRequestContaining('fulfillmentCreate(');
        _Assert.IsTrue(SendRequest.Contains('FulfillmentOrder/9001'), 'The mutation must contain the first fulfillment order.');
        _Assert.IsTrue(SendRequest.Contains('FulfillmentOrder/9002'), 'The mutation must contain the second fulfillment order.');
        _Assert.IsTrue(SendRequest.Contains('FulfillmentOrderLineItem/7001'), 'The first fulfillment order''s line must be present.');
        _Assert.IsTrue(SendRequest.Contains('FulfillmentOrderLineItem/7002'), 'The second fulfillment order''s line must not be dropped at the grouping boundary.');

        // [Then] Each line has its fulfillment entry
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine1.RecordId()), 'One fulfillment entry expected for line 1.');
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine2.RecordId()), 'One fulfillment entry expected for line 2.');
    end;

    [Test]
    procedure MultipleLocations_SendsOneMutationPerLocation()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine1: Record "Sales Shipment Line";
        SalesShipmentLine2: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        RequestLocation1: Text;
        RequestLocation2: Text;
    begin
        // [Scenario] Lines stocked at two Shopify locations each fulfill via their own fulfillmentCreate, with no cross-location
        // leakage, tracking attached to EVERY mutation, and each entry carrying its OWN location's Shopify fulfillment id.

        // [Given] A tracked shipment with two lines, each mapping to a fulfillment order at a different location; each
        // location returns a distinct fulfillment id
        _LibrarySpfyFulfillment.CreateShippingAgent('SPFYDHL', 'DHL Express');
        _LibrarySpfyFulfillment.CreateShipmentHeaderWithTracking('SPFYFUL-E', 'SPFYDHL', '1Z999AA10123456784', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-E', 10000, 2, '1001', SalesShipmentLine1);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-E', 20000, 2, '1002', SalesShipmentLine2);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5005', SalesShipmentHeader, NcTask);
        ConfigureTwoFoFetch(MockClient, '100', '200');
        MockClient.AddResponse('fulfillmentCreate(', 'FulfillmentOrder/9001', _LibrarySpfyFulfillment.ResponseFulfillmentCreate('', '111'));
        MockClient.AddResponse('fulfillmentCreate(', 'FulfillmentOrder/9002', _LibrarySpfyFulfillment.ResponseFulfillmentCreate('', '222'));

        // [When] The fulfillment sender runs
        SendFulfillment.SetGraphQLClient(MockClient);
        SendFulfillment.Run(NcTask);

        // [Then] Two mutations were sent, each containing only its own location's fulfillment order
        _Assert.AreEqual(2, MockClient.CountRequestsContaining('fulfillmentCreate('), 'A two-location order must produce two fulfillmentCreate mutations.');
        RequestLocation1 := MockClient.GetRequestContaining('fulfillmentCreate(', 'FulfillmentOrder/9001');
        RequestLocation2 := MockClient.GetRequestContaining('fulfillmentCreate(', 'FulfillmentOrder/9002');
        _Assert.IsTrue(RequestLocation1 <> '', 'A mutation for the location-1 fulfillment order must be sent.');
        _Assert.IsTrue(RequestLocation2 <> '', 'A mutation for the location-2 fulfillment order must be sent.');
        _Assert.IsFalse(RequestLocation1.Contains('FulfillmentOrder/9002'), 'The location-1 mutation must not contain the location-2 fulfillment order.');
        _Assert.IsFalse(RequestLocation2.Contains('FulfillmentOrder/9001'), 'The location-2 mutation must not contain the location-1 fulfillment order.');

        // [Then] Tracking is attached to EVERY per-location mutation
        _Assert.IsTrue(RequestLocation1.Contains('trackingInfo') and RequestLocation1.Contains('1Z999AA10123456784'), 'The location-1 mutation must carry the shipment tracking.');
        _Assert.IsTrue(RequestLocation2.Contains('trackingInfo') and RequestLocation2.Contains('1Z999AA10123456784'), 'The location-2 mutation must carry the shipment tracking.');

        // [Then] Each line has its entry, stamped with its OWN location's fulfillment id (a crossed id would later cancel the wrong fulfillment)
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine1.RecordId()), 'One fulfillment entry expected for the location-1 line.');
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine2.RecordId()), 'One fulfillment entry expected for the location-2 line.');
        _Assert.AreEqual('111', FulfillmentEntryFulfillmentId(SalesShipmentLine1.RecordId()), 'The location-1 entry must carry location 1''s fulfillment id.');
        _Assert.AreEqual('222', FulfillmentEntryFulfillmentId(SalesShipmentLine2.RecordId()), 'The location-2 entry must carry location 2''s fulfillment id.');
    end;

    [Test]
    procedure PartialFailure_SavesSucceededLocationAndErrors()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine1: Record "Sales Shipment Line";
        SalesShipmentLine2: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        ResponseText: Text;
    begin
        // [Scenario] When the FIRST-processed location fails, the loop still attempts and saves the later location,
        // the task errors so it retries, and the response identifies the failing location. Failing the first location
        // (not the last, which CollectDistinctLocationIds reaches anyway) is what pins "keep going after a failure".

        // [Given] A two-location shipment where location '100' (FO 9001, processed first) returns a userError
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-F', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-F', 10000, 2, '1001', SalesShipmentLine1);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-F', 20000, 2, '1002', SalesShipmentLine2);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5006', SalesShipmentHeader, NcTask);
        ConfigureTwoFoFetch(MockClient, '100', '200');
        MockClient.AddResponse('fulfillmentCreate(', 'FulfillmentOrder/9001', _LibrarySpfyFulfillment.ResponseFulfillmentCreate('Fulfillment could not be created for this location.'));
        MockClient.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));

        // [When] The fulfillment sender runs, it errors (so the NC task retries)
        SendFulfillment.SetGraphQLClient(MockClient);
        asserterror SendFulfillment.Run(NcTask);

        // [Then] Both locations were attempted; the later location still saved despite the earlier one failing
        _Assert.AreEqual(2, MockClient.CountRequestsContaining('fulfillmentCreate('), 'Both locations must be attempted.');
        _Assert.AreEqual(0, FulfillmentEntryCount(SalesShipmentLine1.RecordId()), 'The failed (first-processed) location must not have entries saved.');
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine2.RecordId()), 'The later location must still be attempted and saved after the earlier failure.');

        // [Then] The task response carries the failing location's userError, labelled with its location id and field path
        ResponseText := NcTaskResponseText(NcTask);
        _Assert.IsTrue(ResponseText.Contains('Location 100'), 'The response must identify the failing location.');
        _Assert.IsTrue(ResponseText.Contains('could not be created'), 'The response must carry the Shopify userError message.');
        _Assert.IsTrue(ResponseText.Contains('(field: fulfillment.lineItemsByFulfillmentOrder.0)'), 'The response must carry the Shopify userError field path.');
    end;

    [Test]
    procedure TransportFailure_SavesNoEntriesAndErrors()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        FoIds: List of [Text];
    begin
        // [Scenario] A transport failure on the mutation fails the task and persists no fulfillment entry.

        // [Given] A single-location shipment whose fulfillmentCreate call fails at the HTTP boundary
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-G', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-G', 10000, 2, '1001', SalesShipmentLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5007', SalesShipmentHeader, NcTask);
        FoIds.Add('9001');
        MockClient.AddResponse('fulfillmentOrders(after', _LibrarySpfyFulfillment.ResponseFulfillmentOrders(FoIds));
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7001', 2, '1001');
        MockClient.AddResponse('fulfillmentOrder(id:', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLines));
        MockClient.AddFailure('fulfillmentCreate(');

        // [When] The fulfillment sender runs, it errors
        SendFulfillment.SetGraphQLClient(MockClient);
        asserterror SendFulfillment.Run(NcTask);

        // [Then] The mutation was attempted and nothing was persisted
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('fulfillmentCreate('), 'The mutation must be attempted once.');
        _Assert.AreEqual(0, FulfillmentEntryCount(SalesShipmentLine.RecordId()), 'A transport failure must not persist a fulfillment entry.');
    end;

    [Test]
    procedure NothingToFulfill_CompletesCleanly()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        ResponseText: Text;
    begin
        // [Scenario] When Shopify reports nothing remaining, the task completes cleanly (no mutation, no error) — this is
        // how a retry terminates once everything is already fulfilled; erroring here would retry fulfilled orders forever.

        // [Given] A shipment whose fulfillment order line has 0 remaining quantity
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-H', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-H', 10000, 2, '1001', SalesShipmentLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5008', SalesShipmentHeader, NcTask);
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7001', 0, '1001');
        ConfigureMock(MockClient, '9001', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLines));

        // [When] The fulfillment sender runs — it must NOT error
        SendFulfillment.SetGraphQLClient(MockClient);
        SendFulfillment.Run(NcTask);

        // [Then] No mutation was sent and the task carries the "nothing available" response
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('fulfillmentCreate('), 'No mutation must be sent when nothing remains to fulfill.');
        ResponseText := NcTaskResponseText(NcTask);
        _Assert.IsTrue(ResponseText.Contains('no Shopify fulfillment order lines available'), 'The response must explain that nothing was available to fulfill.');
    end;

    [Test]
    procedure RetryAfterPartialSuccess_DoesNotOverFulfill()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine1: Record "Sales Shipment Line";
        SalesShipmentLine2: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockRun1: Codeunit "NPR Spfy Mock GraphQL Client";
        MockRun2: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        RetryRequest: Text;
    begin
        // [Scenario] After a partial fulfillment succeeds at one location and another location fails, the retry must NOT
        // re-fulfill the already-fulfilled location (otherwise Shopify over-fulfills and the customer is notified twice).

        // [Given] Ship 2 of each of two lines, each mapping to a fulfillment order with 5 remaining at a different location
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-I', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-I', 10000, 2, '1001', SalesShipmentLine1);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-I', 20000, 2, '1002', SalesShipmentLine2);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5009', SalesShipmentHeader, NcTask);

        // [Given] Run 1: location '100' (FO 9001) partially fulfills 2 of 5 and succeeds; location '200' (FO 9002) fails
        ConfigureRetryFetch(MockRun1, 5, 5);
        MockRun1.AddResponse('fulfillmentCreate(', 'FulfillmentOrder/9002', _LibrarySpfyFulfillment.ResponseFulfillmentCreate('Temporary failure'));
        MockRun1.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));
        SendFulfillment.SetGraphQLClient(MockRun1);
        asserterror SendFulfillment.Run(NcTask);

        // [When] The task retries — Shopify now shows FO 9001 with 3 remaining (2 already fulfilled), FO 9002 still 5; both succeed
        ConfigureRetryFetch(MockRun2, 3, 5);
        MockRun2.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));
        SendFulfillment.SetGraphQLClient(MockRun2);
        SendFulfillment.Run(NcTask);

        // [Then] The retry fulfills only the previously-failed location; the already-fulfilled one is not re-sent
        _Assert.AreEqual(1, MockRun2.CountRequestsContaining('fulfillmentCreate('), 'The retry must send only the still-unfulfilled location.');
        RetryRequest := MockRun2.GetRequestContaining('fulfillmentCreate(');
        _Assert.IsFalse(RetryRequest.Contains('FulfillmentOrder/9001'), 'The already-fulfilled location must not be re-fulfilled on retry.');
        _Assert.IsTrue(RetryRequest.Contains('FulfillmentOrder/9002'), 'The previously-failed location must be fulfilled on retry.');
        _Assert.IsTrue(RetryRequest.Contains('"quantity":2'), 'The retry must fulfill the shipped quantity, not an inflated one.');

        // [Then] No duplicate entries, and the fulfilled quantity totals exactly the shipped quantity per line
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine1.RecordId()), 'The partially-fulfilled line must not gain a duplicate entry on retry.');
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine2.RecordId()), 'The retried line must have its entry saved.');
        _Assert.AreEqual(2, FulfillmentEntryQuantity(SalesShipmentLine1.RecordId()), 'Line 1 must be fulfilled for exactly the shipped quantity.');
        _Assert.AreEqual(2, FulfillmentEntryQuantity(SalesShipmentLine2.RecordId()), 'Line 2 must be fulfilled for exactly the shipped quantity.');
    end;

    [Test]
    procedure TransportFailureAtOneLocation_ContinuesAndErrors()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine1: Record "Sales Shipment Line";
        SalesShipmentLine2: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        ThrownError: Text;
    begin
        // [Scenario] A transport failure at the first location must not stop the loop: the later location is still
        // attempted and saved, and the aggregated task error names the failed location (the transport branch, distinct
        // from the userError branch that PartialFailure covers).

        // [Given] A two-location shipment where location '100' (FO 9001, processed first) fails at the HTTP boundary
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-J', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-J', 10000, 2, '1001', SalesShipmentLine1);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-J', 20000, 2, '1002', SalesShipmentLine2);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5010', SalesShipmentHeader, NcTask);
        ConfigureTwoFoFetch(MockClient, '100', '200');
        MockClient.AddFailure('fulfillmentCreate(', 'FulfillmentOrder/9001');
        MockClient.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));

        // [When] The fulfillment sender runs, it errors
        SendFulfillment.SetGraphQLClient(MockClient);
        asserterror SendFulfillment.Run(NcTask);
        ThrownError := GetLastErrorText();

        // [Then] Both locations were attempted; only the succeeded one saved; the error names the failed location
        _Assert.AreEqual(2, MockClient.CountRequestsContaining('fulfillmentCreate('), 'Both locations must be attempted after a transport failure.');
        _Assert.AreEqual(0, FulfillmentEntryCount(SalesShipmentLine1.RecordId()), 'The transport-failed location must not save entries.');
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine2.RecordId()), 'The later location must still save after the earlier transport failure.');
        _Assert.IsTrue(ThrownError.Contains('Location 100'), 'The thrown task error must name the transport-failed location.');
    end;

    [Test]
    procedure RetrySplitLine_FulfillsOnlyTheRemainder()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockRun1: Codeunit "NPR Spfy Mock GraphQL Client";
        MockRun2: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        RetryRequest: Text;
    begin
        // [Scenario] One order line split across two locations: run 1 fulfills part at location 100 and fails at 200; the
        // retry fulfills only the remaining quantity at 200. This exercises AlreadyFulfilledQuantity producing a POSITIVE
        // remainder (not just 0), and confirms the split line totals exactly the shipped quantity with no over-fulfillment.

        // [Given] Ship 2 of one line (order line 1001) split as FO 9001 @loc100 remaining 1 + FO 9002 @loc200 remaining 3
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-K', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-K', 10000, 2, '1001', SalesShipmentLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5011', SalesShipmentHeader, NcTask);

        // [Given] Run 1: location 100 fulfills its 1 unit and succeeds; location 200 fails
        ConfigureSplitLineFetch(MockRun1, 1, 3);
        MockRun1.AddResponse('fulfillmentCreate(', 'FulfillmentOrder/9002', _LibrarySpfyFulfillment.ResponseFulfillmentCreate('Temporary failure'));
        MockRun1.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));
        SendFulfillment.SetGraphQLClient(MockRun1);
        asserterror SendFulfillment.Run(NcTask);

        // [When] The task retries — FO 9001 is now consumed (remaining 0), FO 9002 still has 3; location 200 now succeeds
        ConfigureSplitLineFetch(MockRun2, 0, 3);
        MockRun2.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));
        SendFulfillment.SetGraphQLClient(MockRun2);
        SendFulfillment.Run(NcTask);

        // [Then] The retry fulfills only the remaining 1 unit at location 200
        _Assert.AreEqual(1, MockRun2.CountRequestsContaining('fulfillmentCreate('), 'The retry must send a single mutation for the remainder.');
        RetryRequest := MockRun2.GetRequestContaining('fulfillmentCreate(');
        _Assert.IsTrue(RetryRequest.Contains('FulfillmentOrder/9002'), 'The remainder must be fulfilled at the still-open location.');
        _Assert.IsTrue(RetryRequest.Contains('"quantity":1'), 'The retry must fulfill only the 1-unit remainder, not the full line quantity.');

        // [Then] The split line is fulfilled for exactly its shipped quantity (1 + 1), with no over-fulfillment
        _Assert.AreEqual(2, FulfillmentEntryQuantity(SalesShipmentLine.RecordId()), 'The split line must total exactly the shipped quantity across both runs.');
    end;

    [Test]
    procedure ReturnReceipt_ReprocessDoesNotRefulfill()
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        NcTask: Record "NPR Nc Task";
        TempLinesRun1: Record "NPR Spfy Fulfillment Buffer" temporary;
        TempLinesRun2: Record "NPR Spfy Fulfillment Buffer" temporary;
        MockRun1: Codeunit "NPR Spfy Mock GraphQL Client";
        MockRun2: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
    begin
        // [Scenario] The Return Receipt fulfillment path deducts already-fulfilled quantity on reprocess exactly like the
        // Sales Shipment path — a re-run does not re-fulfill (no over-fulfillment of returns). Guards the return branch of
        // CalculateFulfillmentLines (ReturnReceiptLine.Quantity - AlreadyFulfilledQuantity), which had no coverage.

        // [Given] A return receipt line for 2 units mapped to a Shopify order line
        _LibrarySpfyFulfillment.CreateReturnReceiptHeader('SPFYRET-A', ReturnReceiptHeader);
        _LibrarySpfyFulfillment.CreateReturnReceiptLine('SPFYRET-A', 10000, 2, '1001', ReturnReceiptLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTaskForReturn(_StoreCodeLbl, '6001', ReturnReceiptHeader, NcTask);

        // [Given] Run 1 fulfills the 2 units and succeeds
        ConfigureOneFoFetch(MockRun1, TempLinesRun1, 5);
        MockRun1.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));
        SendFulfillment.SetGraphQLClient(MockRun1);
        SendFulfillment.Run(NcTask);
        _Assert.AreEqual(2, FulfillmentEntryQuantity(ReturnReceiptLine.RecordId()), 'Run 1 must fulfill the returned quantity.');

        // [When] The task is reprocessed — Shopify still shows 3 remaining, but BC already recorded 2 fulfilled
        ConfigureOneFoFetch(MockRun2, TempLinesRun2, 3);
        MockRun2.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));
        SendFulfillment.SetGraphQLClient(MockRun2);
        SendFulfillment.Run(NcTask);

        // [Then] Nothing is re-sent and the returned quantity stays fulfilled exactly once
        _Assert.AreEqual(0, MockRun2.CountRequestsContaining('fulfillmentCreate('), 'Reprocessing must not re-fulfill an already-fulfilled return.');
        _Assert.AreEqual(2, FulfillmentEntryQuantity(ReturnReceiptLine.RecordId()), 'The returned quantity must remain fulfilled exactly once.');
    end;

    [Test]
    procedure SuccessWithoutFulfillmentId_SavesNothingAndErrors()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        FoIds: List of [Text];
        ThrownError: Text;
    begin
        // [Scenario] A 2xx fulfillmentCreate with a null fulfillment and NO userErrors must not be treated as success:
        // committing an id-less entry would make AlreadyFulfilledQuantity block every retry (a permanently lost fulfillment).
        // This shape signals a broken Shopify API contract, so it must fail via the raised-error channel (telemetry), not the
        // quiet userError Error('') where an API-version drift hitting every store would go unnoticed.

        // [Given] A single-location shipment whose fulfillmentCreate returns fulfillment:null with empty userErrors
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-L', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-L', 10000, 2, '1001', SalesShipmentLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5012', SalesShipmentHeader, NcTask);
        FoIds.Add('9001');
        MockClient.AddResponse('fulfillmentOrders(after', _LibrarySpfyFulfillment.ResponseFulfillmentOrders(FoIds));
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7001', 2, '1001');
        MockClient.AddResponse('fulfillmentOrder(id:', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLines));
        MockClient.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreateNullFulfillment());

        // [When] The fulfillment sender runs, it errors
        SendFulfillment.SetGraphQLClient(MockClient);
        asserterror SendFulfillment.Run(NcTask);
        ThrownError := GetLastErrorText();

        // [Then] The mutation was attempted, nothing was persisted, and it failed via the raised-error channel (non-empty
        // error -> telemetry), not the quiet userError Error('')
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('fulfillmentCreate('), 'The mutation must be attempted once.');
        _Assert.AreEqual(0, FulfillmentEntryCount(SalesShipmentLine.RecordId()), 'No entry may be saved when Shopify returns no fulfillment id.');
        _Assert.IsTrue(ThrownError.Contains('no fulfillment id'), 'The raised error must explain the missing fulfillment id.');
    end;

    [Test]
    procedure MixedTransportAndUserErrorFailure_CombinesDiagnostics()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine1: Record "Sales Shipment Line";
        SalesShipmentLine2: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        ThrownError: Text;
    begin
        // [Scenario] One location transport-fails while another returns a userError in the same run — the raised task error
        // combines both, each labelled with its location (the CombineDiagnostics concatenation branch).

        // [Given] location 100 (FO 9001) transport-fails; location 200 (FO 9002) returns a userError
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-M', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-M', 10000, 2, '1001', SalesShipmentLine1);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-M', 20000, 2, '1002', SalesShipmentLine2);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5013', SalesShipmentHeader, NcTask);
        ConfigureTwoFoFetch(MockClient, '100', '200');
        MockClient.AddFailure('fulfillmentCreate(', 'FulfillmentOrder/9001');
        MockClient.AddResponse('fulfillmentCreate(', 'FulfillmentOrder/9002', _LibrarySpfyFulfillment.ResponseFulfillmentCreate('Cannot fulfill here'));

        // [When] The sender runs, it errors
        SendFulfillment.SetGraphQLClient(MockClient);
        asserterror SendFulfillment.Run(NcTask);
        ThrownError := GetLastErrorText();

        // [Then] Both failures surface in the combined error, each labelled with its location
        _Assert.IsTrue(ThrownError.Contains('Location 100'), 'The combined error must name the transport-failed location.');
        _Assert.IsTrue(ThrownError.Contains('Location 200'), 'The combined error must name the userError location.');
        _Assert.IsTrue(ThrownError.Contains('Cannot fulfill here'), 'The combined error must carry the Shopify userError message.');
    end;

    [Test]
    procedure MaxAvailableSubscriber_NotBlockedByRetryDeduction()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
        MaxAvailSubscriber: Codeunit "NPR Spfy Max Avail Subscriber";
        SendRequest: Text;
    begin
        // [Scenario] A subscriber to the public OnCalculateFulfillmentQuantity seam that requests FulfillMaxAvailableQty must
        // NOT be gated by the retry deduction: even when the BC line is already fully accounted for (deducted quantity = 0),
        // Shopify's live remaining must still be fulfilled. Without the fix the deduction gate exits before the event fires,
        // and a still-open location would be silently lost on a task marked processed.

        // [Given] A shipment line for 2 units, already recorded as fully fulfilled in BC, whose FO still shows 5 remaining
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-N', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-N', 10000, 2, '1001', SalesShipmentLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5014', SalesShipmentHeader, NcTask);
        _LibrarySpfyFulfillment.SeedFulfillmentEntry(SalesShipmentLine.RecordId(), 2);
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7001', 5, '1001');
        ConfigureMock(MockClient, '9001', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLines));

        // [When] A subscriber forces max-available and the sender runs
        BindSubscription(MaxAvailSubscriber);
        SendFulfillment.SetGraphQLClient(MockClient);
        SendFulfillment.Run(NcTask);
        UnbindSubscription(MaxAvailSubscriber);

        // [Then] The line is still fulfilled for Shopify's full remaining (5), not gated to nothing by the deduction
        _Assert.AreEqual(1, MockClient.CountRequestsContaining('fulfillmentCreate('), 'Max-available must still send even when the BC deduction has reached zero.');
        SendRequest := MockClient.GetRequestContaining('fulfillmentCreate(');
        _Assert.IsTrue(SendRequest.Contains('"quantity":5'), 'Max-available must fulfill Shopify''s full remaining quantity.');
    end;

    [Test]
    procedure FetchFailure_ErrorsBeforeNothingAvailableExit()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        NcTask: Record "NPR Nc Task";
        MockClient: Codeunit "NPR Spfy Mock GraphQL Client";
        SendFulfillment: Codeunit "NPR Spfy Send Fulfillment";
    begin
        // [Scenario] A failure fetching the fulfillment orders must fail the task (so it retries), NOT fall through to the
        // "nothing available" clean-exit — otherwise a transient fetch outage marks the order fulfilled-nothing and it never
        // retries. Guards the PrepareFulfillment-raises-before-IsEmpty ordering in SendShopifyFulfillment.

        // [Given] A single-location shipment whose fulfillment-order fetch fails at the HTTP boundary
        _LibrarySpfyFulfillment.CreateShipmentHeader('SPFYFUL-O', SalesShipmentHeader);
        _LibrarySpfyFulfillment.CreateShipmentLine('SPFYFUL-O', 10000, 2, '1001', SalesShipmentLine);
        _LibrarySpfyFulfillment.CreateFulfillmentNcTask(_StoreCodeLbl, '5015', SalesShipmentHeader, NcTask);
        MockClient.AddFailure('fulfillmentOrders(after');

        // [When] The fulfillment sender runs, it errors (the fetch failure must not be swallowed as "nothing to fulfill")
        SendFulfillment.SetGraphQLClient(MockClient);
        asserterror SendFulfillment.Run(NcTask);

        // [Then] No mutation was attempted and nothing was persisted
        _Assert.AreEqual(0, MockClient.CountRequestsContaining('fulfillmentCreate('), 'A fetch failure must not reach the mutation stage.');
        _Assert.AreEqual(0, FulfillmentEntryCount(SalesShipmentLine.RecordId()), 'A fetch failure must persist no fulfillment entry.');
    end;

    local procedure ConfigureOneFoFetch(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; var TempLines: Record "NPR Spfy Fulfillment Buffer" temporary; FoRemaining: Decimal)
    var
        FoIds: List of [Text];
    begin
        FoIds.Add('9001');
        MockClient.AddResponse('fulfillmentOrders(after', _LibrarySpfyFulfillment.ResponseFulfillmentOrders(FoIds));
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7001', FoRemaining, '1001');
        MockClient.AddResponse('fulfillmentOrder(id:', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLines));
    end;

    local procedure ConfigureRetryFetch(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; Fo1Remaining: Decimal; Fo2Remaining: Decimal)
    var
        TempLinesFo1: Record "NPR Spfy Fulfillment Buffer" temporary;
        TempLinesFo2: Record "NPR Spfy Fulfillment Buffer" temporary;
        FoIds: List of [Text];
    begin
        FoIds.Add('9001');
        FoIds.Add('9002');
        MockClient.AddResponse('fulfillmentOrders(after', _LibrarySpfyFulfillment.ResponseFulfillmentOrders(FoIds));

        _LibrarySpfyFulfillment.AddBufferLine(TempLinesFo1, '7001', Fo1Remaining, '1001');
        MockClient.AddResponse('fulfillmentOrder(id:', 'FulfillmentOrder/9001', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLinesFo1, '100'));

        _LibrarySpfyFulfillment.AddBufferLine(TempLinesFo2, '7002', Fo2Remaining, '1002');
        MockClient.AddResponse('fulfillmentOrder(id:', 'FulfillmentOrder/9002', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLinesFo2, '200'));
    end;

    local procedure ConfigureSplitLineFetch(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; Fo1Remaining: Decimal; Fo2Remaining: Decimal)
    var
        TempLinesFo1: Record "NPR Spfy Fulfillment Buffer" temporary;
        TempLinesFo2: Record "NPR Spfy Fulfillment Buffer" temporary;
        FoIds: List of [Text];
    begin
        // Both fulfillment orders carry the SAME order line (1001) at different locations — a single BC line split by Shopify.
        FoIds.Add('9001');
        FoIds.Add('9002');
        MockClient.AddResponse('fulfillmentOrders(after', _LibrarySpfyFulfillment.ResponseFulfillmentOrders(FoIds));

        _LibrarySpfyFulfillment.AddBufferLine(TempLinesFo1, '7001', Fo1Remaining, '1001');
        MockClient.AddResponse('fulfillmentOrder(id:', 'FulfillmentOrder/9001', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLinesFo1, '100'));

        _LibrarySpfyFulfillment.AddBufferLine(TempLinesFo2, '7002', Fo2Remaining, '1001');
        MockClient.AddResponse('fulfillmentOrder(id:', 'FulfillmentOrder/9002', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLinesFo2, '200'));
    end;

    local procedure ConfigureTwoFoFetch(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; Location1: Text; Location2: Text)
    var
        TempLinesFo1: Record "NPR Spfy Fulfillment Buffer" temporary;
        TempLinesFo2: Record "NPR Spfy Fulfillment Buffer" temporary;
        FoIds: List of [Text];
    begin
        FoIds.Add('9001');
        FoIds.Add('9002');
        MockClient.AddResponse('fulfillmentOrders(after', _LibrarySpfyFulfillment.ResponseFulfillmentOrders(FoIds));

        _LibrarySpfyFulfillment.AddBufferLine(TempLinesFo1, '7001', 2, '1001');
        MockClient.AddResponse('fulfillmentOrder(id:', 'FulfillmentOrder/9001', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLinesFo1, Location1));

        _LibrarySpfyFulfillment.AddBufferLine(TempLinesFo2, '7002', 2, '1002');
        MockClient.AddResponse('fulfillmentOrder(id:', 'FulfillmentOrder/9002', _LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLinesFo2, Location2));
    end;

    local procedure ConfigureMock(var MockClient: Codeunit "NPR Spfy Mock GraphQL Client"; FoId: Text; FulfillmentOrderLinesResponse: Text)
    var
        FoIds: List of [Text];
    begin
        FoIds.Add(FoId);
        MockClient.AddResponse('fulfillmentOrders(after', _LibrarySpfyFulfillment.ResponseFulfillmentOrders(FoIds));
        MockClient.AddResponse('fulfillmentOrder(id:', FulfillmentOrderLinesResponse);
        MockClient.AddResponse('fulfillmentCreate(', _LibrarySpfyFulfillment.ResponseFulfillmentCreate(''));
    end;

    local procedure BuildTwoLineFulfillment(): Text
    var
        TempLines: Record "NPR Spfy Fulfillment Buffer" temporary;
    begin
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7001', 2, '1001');
        _LibrarySpfyFulfillment.AddBufferLine(TempLines, '7002', 3, '1002');
        exit(_LibrarySpfyFulfillment.ResponseFulfillmentOrderLines(TempLines));
    end;

    local procedure FulfillmentEntryCount(BCRecordID: RecordId): Integer
    var
        SpfyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        SpfyFulfillmentEntry.SetRange("BC Record ID", BCRecordID);
        exit(SpfyFulfillmentEntry.Count());
    end;

    local procedure FulfillmentEntryQuantity(BCRecordID: RecordId): Decimal
    var
        SpfyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        SpfyFulfillmentEntry.SetRange("BC Record ID", BCRecordID);
        SpfyFulfillmentEntry.CalcSums("Fulfilled Quantity");
        exit(SpfyFulfillmentEntry."Fulfilled Quantity");
    end;

    local procedure FulfillmentEntryFulfillmentId(BCRecordID: RecordId): Text[30]
    var
        SpfyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        SpfyFulfillmentEntry.SetRange("BC Record ID", BCRecordID);
        if SpfyFulfillmentEntry.FindFirst() then
            exit(SpfyFulfillmentEntry."Fulfillment ID");
    end;

    local procedure NcTaskResponseText(NcTask: Record "NPR Nc Task") ResponseText: Text
    var
        PersistedNcTask: Record "NPR Nc Task";
        InStr: InStream;
    begin
        // Re-read the committed task; Response is set + committed inside the sender before it errors.
        if not PersistedNcTask.Get(NcTask."Entry No.") then
            exit('');
        PersistedNcTask.CalcFields(Response);
        if not PersistedNcTask.Response.HasValue() then
            exit('');
        PersistedNcTask.Response.CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(ResponseText);
    end;
}
#endif

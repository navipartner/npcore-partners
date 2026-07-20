#if not BC17
codeunit 85265 "NPR Spfy Fulfillment Tests"
{
    // [Feature] Shopify Order Fulfillments
    // Baseline characterization tests for "NPR Spfy Send Fulfillment" as it behaves today
    // (single Shopify location). They lock current correct behaviour before the multi-location
    // change in stage 4, and exercise the injectable GraphQL client seam + reusable mock.
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

        // [Then] One fulfillment entry is persisted per shipment line
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine1.RecordId()), 'One fulfillment entry expected for line 1.');
        _Assert.AreEqual(1, FulfillmentEntryCount(SalesShipmentLine2.RecordId()), 'One fulfillment entry expected for line 2.');
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
}
#endif

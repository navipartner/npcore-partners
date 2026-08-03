#if not BC17
codeunit 85263 "NPR Library - Spfy Fulfillment"
{
    // Test helpers for the Shopify "Order Fulfillments" flow: seeds the minimal BC records the
    // fulfillment sender reads (posted-shipment header/lines + their assigned Shopify line ids and
    // the fulfillment NC task) and builds canned Shopify GraphQL responses for the mock client.
    // Kept separate from the tests so stages 2 and 4 can share it.

    var
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt.";

    #region BC record fixtures

    procedure CreateShipmentHeader(DocNo: Code[20]; var SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        SalesShipmentHeader.Init();
        SalesShipmentHeader."No." := DocNo;
        SalesShipmentHeader.Insert();
    end;

    procedure CreateShipmentHeaderWithTracking(DocNo: Code[20]; ShippingAgentCode: Code[10]; TrackingNo: Text[30]; var SalesShipmentHeader: Record "Sales Shipment Header")
    begin
        CreateShipmentHeader(DocNo, SalesShipmentHeader);
        SalesShipmentHeader."Shipping Agent Code" := ShippingAgentCode;
        SalesShipmentHeader."Package Tracking No." := TrackingNo;
        SalesShipmentHeader.Modify();
    end;

    /// <summary>Inserts a shipment line and links it to its Shopify order-line id, mimicking a posted, Shopify-mapped shipment.</summary>
    procedure CreateShipmentLine(DocNo: Code[20]; LineNo: Integer; Qty: Decimal; ShopifyOrderLineId: Text[30]; var SalesShipmentLine: Record "Sales Shipment Line")
    begin
        SalesShipmentLine.Init();
        SalesShipmentLine."Document No." := DocNo;
        SalesShipmentLine."Line No." := LineNo;
        SalesShipmentLine.Type := SalesShipmentLine.Type::Item;
        SalesShipmentLine.Quantity := Qty;
        SalesShipmentLine.Insert();
        _SpfyAssignedIDMgt.AssignShopifyID(SalesShipmentLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyOrderLineId, false);
    end;

    procedure CreateShippingAgent(AgentCode: Code[10]; AgentName: Text[50])
    var
        ShippingAgent: Record "Shipping Agent";
    begin
        if ShippingAgent.Get(AgentCode) then begin
            ShippingAgent.Name := AgentName;
            ShippingAgent."NPR Spfy Tracking Company" := ShippingAgent."NPR Spfy Tracking Company"::" ";
            ShippingAgent.Modify();
        end else begin
            ShippingAgent.Init();
            ShippingAgent.Code := AgentCode;
            ShippingAgent.Name := AgentName;
            ShippingAgent.Insert();
        end;
    end;

    /// <summary>Builds the fulfillment NC task the sender runs, pointing at the shipment header and Shopify order id.</summary>
    procedure CreateFulfillmentNcTask(StoreCode: Code[20]; ShopifyOrderId: Text; var SalesShipmentHeader: Record "Sales Shipment Header"; var NcTask: Record "NPR Nc Task")
    begin
        CreateFulfillmentNcTask(StoreCode, ShopifyOrderId, Database::"Sales Shipment Header", SalesShipmentHeader.RecordId(), NcTask);
    end;

    procedure CreateReturnReceiptHeader(DocNo: Code[20]; var ReturnReceiptHeader: Record "Return Receipt Header")
    begin
        ReturnReceiptHeader.Init();
        ReturnReceiptHeader."No." := DocNo;
        ReturnReceiptHeader.Insert();
    end;

    /// <summary>Inserts a return receipt line and links it to its Shopify order-line id (the Return Receipt fulfillment path).</summary>
    procedure CreateReturnReceiptLine(DocNo: Code[20]; LineNo: Integer; Qty: Decimal; ShopifyOrderLineId: Text[30]; var ReturnReceiptLine: Record "Return Receipt Line")
    begin
        ReturnReceiptLine.Init();
        ReturnReceiptLine."Document No." := DocNo;
        ReturnReceiptLine."Line No." := LineNo;
        ReturnReceiptLine.Type := ReturnReceiptLine.Type::Item;
        ReturnReceiptLine.Quantity := Qty;
        ReturnReceiptLine.Insert();
        _SpfyAssignedIDMgt.AssignShopifyID(ReturnReceiptLine.RecordId(), "NPR Spfy ID Type"::"Entry ID", ShopifyOrderLineId, false);
    end;

    procedure CreateFulfillmentNcTaskForReturn(StoreCode: Code[20]; ShopifyOrderId: Text; var ReturnReceiptHeader: Record "Return Receipt Header"; var NcTask: Record "NPR Nc Task")
    begin
        CreateFulfillmentNcTask(StoreCode, ShopifyOrderId, Database::"Return Receipt Header", ReturnReceiptHeader.RecordId(), NcTask);
    end;

    local procedure CreateFulfillmentNcTask(StoreCode: Code[20]; ShopifyOrderId: Text; TableNo: Integer; RecID: RecordId; var NcTask: Record "NPR Nc Task")
    begin
        NcTask.Init();
        NcTask."Table No." := TableNo;
        NcTask."Record ID" := RecID;
        NcTask."Record Value" := CopyStr(ShopifyOrderId, 1, MaxStrLen(NcTask."Record Value"));
        NcTask."Store Code" := StoreCode;
        NcTask.Type := NcTask.Type::Insert;
        NcTask.Insert(true);
    end;

    #endregion

    #region Canned Shopify GraphQL responses

    /// <summary>Response for the "GetFulfillmentOrders" query: one open FO per id.</summary>
    procedure ResponseFulfillmentOrders(FoIds: List of [Text]) ResponseText: Text
    var
        Root, DataObj, OrderObj, FulfillmentOrdersObj, PageInfoObj, EdgeObj, NodeObj : JsonObject;
        Edges: JsonArray;
        FoId: Text;
    begin
        AddPageInfo(PageInfoObj);
        foreach FoId in FoIds do begin
            Clear(NodeObj);
            Clear(EdgeObj);
            NodeObj.Add('id', 'gid://shopify/FulfillmentOrder/' + FoId);
            NodeObj.Add('status', 'open');
            EdgeObj.Add('node', NodeObj);
            Edges.Add(EdgeObj);
        end;
        FulfillmentOrdersObj.Add('pageInfo', PageInfoObj);
        FulfillmentOrdersObj.Add('edges', Edges);
        OrderObj.Add('fulfillmentOrders', FulfillmentOrdersObj);
        DataObj.Add('order', OrderObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    /// <summary>Response for the "GetFulfilmentOrder" line-items query, one edge per row in TempLines.</summary>
    procedure ResponseFulfillmentOrderLines(var TempLines: Record "NPR Spfy Fulfillment Buffer" temporary): Text
    begin
        exit(ResponseFulfillmentOrderLines(TempLines, ''));
    end;

    /// <summary>As above, but stamps the fulfillment order's assigned location (empty LocationId = no assignedLocation node).</summary>
    procedure ResponseFulfillmentOrderLines(var TempLines: Record "NPR Spfy Fulfillment Buffer" temporary; LocationId: Text) ResponseText: Text
    var
        Root, DataObj, FulfillmentOrderObj, LineItemsObj, PageInfoObj, EdgeObj, NodeObj, LineItemObj, AssignedLocationObj, LocationObj : JsonObject;
        Edges: JsonArray;
    begin
        if LocationId <> '' then begin
            LocationObj.Add('id', 'gid://shopify/Location/' + LocationId);
            AssignedLocationObj.Add('location', LocationObj);
            FulfillmentOrderObj.Add('assignedLocation', AssignedLocationObj);
        end;
        AddPageInfo(PageInfoObj);
        if TempLines.FindSet() then
            repeat
                Clear(NodeObj);
                Clear(EdgeObj);
                Clear(LineItemObj);
                NodeObj.Add('id', 'gid://shopify/FulfillmentOrderLineItem/' + TempLines."Fulfillment Order Line ID");
                NodeObj.Add('remainingQuantity', TempLines."Fulfillable Quantity");
                LineItemObj.Add('id', 'gid://shopify/LineItem/' + TempLines."Order Line ID");
                NodeObj.Add('lineItem', LineItemObj);
                EdgeObj.Add('node', NodeObj);
                Edges.Add(EdgeObj);
            until TempLines.Next() = 0;
        LineItemsObj.Add('pageInfo', PageInfoObj);
        LineItemsObj.Add('edges', Edges);
        FulfillmentOrderObj.Add('lineItems', LineItemsObj);
        DataObj.Add('fulfillmentOrder', FulfillmentOrderObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    /// <summary>Convenience: a single fulfillment-order-line buffer row.</summary>
    procedure AddBufferLine(var TempLines: Record "NPR Spfy Fulfillment Buffer" temporary; FoLineId: Text[30]; RemainingQty: Decimal; OrderLineId: Text[30])
    begin
        TempLines."Entry No." += 1;
        TempLines."Fulfillment Order Line ID" := FoLineId;
        TempLines."Fulfillable Quantity" := RemainingQty;
        TempLines."Order Line ID" := OrderLineId;
        TempLines.Insert();
    end;

    /// <summary>
    /// Persists a fulfillment entry directly, simulating a prior committed run. Sets exactly the fields
    /// AlreadyFulfilledQuantity reads ("Table No." + "BC Record ID" + "Fulfilled Quantity"), so a test can drive the
    /// retry deduction without a full first send.
    /// </summary>
    procedure SeedFulfillmentEntry(BCRecordID: RecordId; FulfilledQty: Decimal)
    var
        SpfyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        SpfyFulfillmentEntry.Init();
        SpfyFulfillmentEntry."Table No." := BCRecordID.TableNo();
        SpfyFulfillmentEntry."BC Record ID" := BCRecordID;
        SpfyFulfillmentEntry."Fulfilled Quantity" := FulfilledQty;
        SpfyFulfillmentEntry.Insert(true);
    end;

    /// <summary>Response for the "fulfillmentCreate" mutation. Pass a non-empty message to simulate a userError.</summary>
    procedure ResponseFulfillmentCreate(UserErrorMessage: Text): Text
    begin
        exit(ResponseFulfillmentCreate(UserErrorMessage, '999'));
    end;

    /// <summary>As above, with a caller-chosen Shopify Fulfillment id (to assert per-location association).</summary>
    procedure ResponseFulfillmentCreate(UserErrorMessage: Text; FulfillmentId: Text) ResponseText: Text
    var
        Root, DataObj, FulfillmentCreateObj, FulfillmentObj, UserErrorObj : JsonObject;
        UserErrors, FieldPath : JsonArray;
        NullFulfillment: JsonValue;
    begin
        if UserErrorMessage = '' then begin
            FulfillmentObj.Add('id', 'gid://shopify/Fulfillment/' + FulfillmentId);
            FulfillmentObj.Add('status', 'SUCCESS');
            FulfillmentCreateObj.Add('fulfillment', FulfillmentObj);
        end else begin
            // Shopify returns a null fulfillment alongside userErrors when it rejects the mutation, and the userError
            // "field" is an array of path segments ([String!]) — matching the real wire shape so field extraction is tested.
            NullFulfillment.SetValueToNull();
            FulfillmentCreateObj.Add('fulfillment', NullFulfillment);
            FieldPath.Add('fulfillment');
            FieldPath.Add('lineItemsByFulfillmentOrder');
            FieldPath.Add('0');
            UserErrorObj.Add('field', FieldPath);
            UserErrorObj.Add('message', UserErrorMessage);
            UserErrors.Add(UserErrorObj);
        end;
        FulfillmentCreateObj.Add('userErrors', UserErrors);
        DataObj.Add('fulfillmentCreate', FulfillmentCreateObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    /// <summary>A 2xx-shaped response with a null fulfillment and NO userErrors (e.g. a throttling / internal GraphQL error) — the sender must not treat this as success.</summary>
    procedure ResponseFulfillmentCreateNullFulfillment() ResponseText: Text
    var
        Root, DataObj, FulfillmentCreateObj : JsonObject;
        UserErrors: JsonArray;
        NullFulfillment: JsonValue;
    begin
        NullFulfillment.SetValueToNull();
        FulfillmentCreateObj.Add('fulfillment', NullFulfillment);
        FulfillmentCreateObj.Add('userErrors', UserErrors);
        DataObj.Add('fulfillmentCreate', FulfillmentCreateObj);
        Root.Add('data', DataObj);
        Root.WriteTo(ResponseText);
    end;

    local procedure AddPageInfo(var PageInfoObj: JsonObject)
    begin
        PageInfoObj.Add('hasNextPage', false);
        PageInfoObj.Add('endCursor', '');
    end;

    #endregion
}
#endif

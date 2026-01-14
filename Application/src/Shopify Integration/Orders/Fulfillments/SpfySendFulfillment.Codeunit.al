#if not BC17
codeunit 6184818 "NPR Spfy Send Fulfillment"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"Sales Shipment Header",
            Database::"Return Receipt Header":
                SendShopifyFulfillment(Rec);
        end;
    end;

    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        JsonHelper: Codeunit "NPR Json Helper";

    local procedure SendShopifyFulfillment(var NcTask: Record "NPR Nc Task")
    var
        TempCalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        ShopifyResponse: JsonToken;
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        TempCalculatedFulfillmentLines.DeleteAll();

        Success := PrepareFulfillment(NcTask, TempCalculatedFulfillmentLines, SendToShopify);
        if SendToShopify then
            Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse);

        if SendToShopify and Success then
            SaveFulfillmentEntries(TempCalculatedFulfillmentLines);
        NcTask.Modify();
        Commit();

        if not Success then
            Error(GetLastErrorText);
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');
    end;

    [TryFunction]
    local procedure PrepareFulfillment(var NcTask: Record "NPR Nc Task"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var SendToShopify: Boolean)
    var
        TempAvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        FulfillmentOrderIds: List of [Text];
        FulfillmentOrderId: Text[30];
    begin
        TempAvailableFulfillmentLines.Reset();
        TempAvailableFulfillmentLines.DeleteAll();

        if NcTask."Store Code" = '' then
            NcTask."Store Code" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));

        CollectFulfillmentOrders(NcTask, FulfillmentOrderIds);

        foreach FulfillmentOrderId in FulfillmentOrderIds do
            LoadFulfillmentOrderLines(NcTask, FulfillmentOrderId, TempAvailableFulfillmentLines);

        CalculateFulfillmentLines(NcTask, TempAvailableFulfillmentLines, CalculatedFulfillmentLines);
        GenerateFulfillmentPayloadJson(NcTask, CalculatedFulfillmentLines, SendToShopify);
    end;

    local procedure CollectFulfillmentOrders(var NcTask: Record "NPR Nc Task"; var FulfillmentOrderIds: List of [Text])
    var
        FulfillmentOrder: JsonToken;
        ShopifyResponse: JsonToken;
        Cursor: Text;
        FulfillmentOrderID: Text;
        HasNext: Boolean;
        RequestString: Label 'query GetFulfillmentOrders($OrderId: ID!,$afterCursor: String){order(id:$OrderId){fulfillmentOrders(after:$afterCursor,first:50){pageInfo{hasNextPage endCursor} edges{node{id status}}}}}', Locked = true;
    begin
        Clear(FulfillmentOrderIds);
        SpfyCommunicationHandler.InitializePagingState(Cursor, HasNext);
        repeat
            SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, Cursor, NcTask."Store Code", RequestString, 'gid://shopify/Order/' + NcTask."Record Value", true);
            if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
                Error(GetLastErrorText());
            if not ParsePageInfo(ShopifyResponse, 'data.order.fulfillmentOrders', HasNext, Cursor) then
                Error(GetLastErrorText());
            foreach FulfillmentOrder in GetFulfillmentOrderNodes(ShopifyResponse) do
                if JsonHelper.GetJText(FulfillmentOrder, 'status', true).ToLower() <> 'closed' then begin
                    FulfillmentOrderID := OrderMgt.GetNumericId(JsonHelper.GetJText(FulfillmentOrder, 'id', true));
                    if not FulfillmentOrderIds.Contains(FulfillmentOrderID) then
                        FulfillmentOrderIds.Add(FulfillmentOrderID);
                end;
        until not HasNext;
    end;

    local procedure LoadFulfillmentOrderLines(var NcTask: Record "NPR Nc Task"; FulfillmentOrderId: Text; var TempAvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        FulfillmentOrderLine: JsonToken;
        FulfillmentOrderLines: JsonToken;
        ShopifyResponse: JsonToken;
        Cursor: Text;
        HasNext: Boolean;
        RequestString: Label 'query GetFulfilmentOrder($OrderId:ID!,$afterCursor:String){fulfillmentOrder(id:$OrderId){lineItems(first:50,after:$afterCursor){pageInfo{hasNextPage endCursor} edges{node{id remainingQuantity lineItem{id}}}}}}', Locked = true;
    begin
        SpfyCommunicationHandler.InitializePagingState(Cursor, HasNext);
        repeat
            Clear(NcTask."Data Output");
            SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, Cursor, NcTask."Store Code", RequestString, 'gid://shopify/FulfillmentOrder/' + FulfillmentOrderId, true);
            if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
                Error(GetLastErrorText());
            if not ParsePageInfo(ShopifyResponse, 'data.fulfillmentOrder.lineItems', HasNext, Cursor) then
                Error(GetLastErrorText());
            ShopifyResponse.SelectToken('data.fulfillmentOrder.lineItems.edges', FulfillmentOrderLines);
            foreach FulfillmentOrderLine in FulfillmentOrderLines.AsArray() do begin
                TempAvailableFulfillmentLines.Init();
                TempAvailableFulfillmentLines."Fulfillable Quantity" := JsonHelper.GetJDecimal(FulfillmentOrderLine, 'node.remainingQuantity', false);
                if TempAvailableFulfillmentLines."Fulfillable Quantity" > 0 then begin
#pragma warning disable AA0139
                    TempAvailableFulfillmentLines."Fulfillment Order ID" := FulfillmentOrderId;
                    TempAvailableFulfillmentLines."Fulfillment Order Line ID" := OrderMgt.GetNumericId(JsonHelper.GetJText(FulfillmentOrderLine, 'node.id', true));
                    TempAvailableFulfillmentLines."Order Line ID" := OrderMgt.GetNumericId(JsonHelper.GetJText(FulfillmentOrderLine, 'node.lineItem.id', true));
#pragma warning restore AA0139
                    TempAvailableFulfillmentLines."Entry No." += 1;
                    TempAvailableFulfillmentLines.Insert();
                end;
            end;
        until not HasNext;
    end;

    local procedure CalculateFulfillmentLines(NcTask: Record "NPR Nc Task"; var AvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        RecRef: RecordRef;
        SpfyOrderLineId: Text[30];
        CurrentQty: Decimal;
        FulfillMaxAvailableQty: Boolean;
    begin
        case NcTask."Table No." of
            Database::"Sales Shipment Header":
                begin
                    RecRef.Get(NcTask."Record ID");
                    RecRef.SetTable(SalesShipmentHeader);
                    SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                    if SalesShipmentLine.FindSet() then
                        repeat
                            CurrentQty := SalesShipmentLine.Quantity;
                            if IsEligibleForFulfillmentSending(SalesShipmentLine.RecordId(), CurrentQty, SpfyOrderLineId) then begin
                                SpfyIntegrationEvents.OnCalculateFulfillmentQuantity(SalesShipmentLine.RecordId(), SpfyOrderLineId, CurrentQty, FulfillMaxAvailableQty);
                                UpdateFulfillmentBuffer(SalesShipmentLine.RecordId(), AvailableFulfillmentLines, SpfyOrderLineId, CurrentQty, FulfillMaxAvailableQty, CalculatedFulfillmentLines);
                            end;
                        until SalesShipmentLine.Next() = 0;
                end;
            Database::"Return Receipt Header":
                begin
                    RecRef.Get(NcTask."Record ID");
                    RecRef.SetTable(ReturnReceiptHeader);
                    ReturnReceiptLine.SetRange("Document No.", ReturnReceiptHeader."No.");
                    if ReturnReceiptLine.FindSet() then
                        repeat
                            CurrentQty := ReturnReceiptLine.Quantity;
                            if IsEligibleForFulfillmentSending(ReturnReceiptLine.RecordId(), CurrentQty, SpfyOrderLineId) then begin
                                SpfyIntegrationEvents.OnCalculateFulfillmentQuantity(ReturnReceiptLine.RecordId(), SpfyOrderLineId, CurrentQty, FulfillMaxAvailableQty);
                                UpdateFulfillmentBuffer(ReturnReceiptLine.RecordId(), AvailableFulfillmentLines, SpfyOrderLineId, CurrentQty, FulfillMaxAvailableQty, CalculatedFulfillmentLines);
                            end;
                        until ReturnReceiptLine.Next() = 0;
                end;
            else
                SpfyIntegrationMgt.UnsupportedIntegrationTable(NcTask, StrSubstNo('CU%1.%2', Format(Codeunit::"NPR Spfy Send Fulfillment"), 'PrepareFulfillmentLines'));
        end;
    end;

    local procedure IsEligibleForFulfillmentSending(RecID: RecordId; Qty: Decimal): Boolean
    var
        SpfyOrderLineId: Text[30];
    begin
        exit(IsEligibleForFulfillmentSending(RecID, Qty, SpfyOrderLineId));
    end;

    local procedure IsEligibleForFulfillmentSending(RecID: RecordId; Qty: Decimal; var SpfyOrderLineId: Text[30]) Eligible: Boolean
    begin
        SpfyOrderLineId := SpfyAssignedIDMgt.GetAssignedShopifyID(RecID, "NPR Spfy ID Type"::"Entry ID");
        Eligible := (SpfyOrderLineId <> '') and (Qty <> 0);
        SpfyIntegrationEvents.OnCheckIfIsEligibleForFulfillmentSending(RecID, SpfyOrderLineId, Eligible);
    end;

    local procedure UpdateFulfillmentBuffer(RecID: RecordId; var AvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; SpfyOrderLineId: Text[30]; Qty: Decimal; FulfillMaxAvailableQty: Boolean; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        CurrentQtyToFulfill: Decimal;
        NextEntryNo: Integer;
    begin
        AvailableFulfillmentLines.SetRange("Order Line ID", SpfyOrderLineId);
        if FulfillMaxAvailableQty then begin
            AvailableFulfillmentLines.CalcSums("Fulfillable Quantity", "Fulfilled Quantity");
            Qty := AvailableFulfillmentLines."Fulfillable Quantity" - AvailableFulfillmentLines."Fulfilled Quantity";
        end;
        if Qty <= 0 then
            exit;

        if not CalculatedFulfillmentLines.FindLast() then
            Clear(CalculatedFulfillmentLines);
        NextEntryNo := CalculatedFulfillmentLines."Entry No." + 1;

        if AvailableFulfillmentLines.Find('-') then
            repeat
                if AvailableFulfillmentLines."Fulfillable Quantity" - AvailableFulfillmentLines."Fulfilled Quantity" > 0 then begin
                    if Qty > AvailableFulfillmentLines."Fulfillable Quantity" - AvailableFulfillmentLines."Fulfilled Quantity" then
                        CurrentQtyToFulfill := AvailableFulfillmentLines."Fulfillable Quantity" - AvailableFulfillmentLines."Fulfilled Quantity"
                    else
                        CurrentQtyToFulfill := Qty;
                    Qty -= CurrentQtyToFulfill;
                    AvailableFulfillmentLines."Fulfilled Quantity" += CurrentQtyToFulfill;
                    if AvailableFulfillmentLines."Fulfilled Quantity" >= AvailableFulfillmentLines."Fulfillable Quantity" then
                        AvailableFulfillmentLines.Delete()
                    else
                        AvailableFulfillmentLines.Modify();

                    CalculatedFulfillmentLines := AvailableFulfillmentLines;
                    CalculatedFulfillmentLines."Table No." := RecID.TableNo;
                    CalculatedFulfillmentLines."BC Record ID" := RecID;
                    CalculatedFulfillmentLines."Fulfilled Quantity" := CurrentQtyToFulfill;
                    CalculatedFulfillmentLines."Entry No." := NextEntryNo;
                    CalculatedFulfillmentLines.Insert();
                end;
            until (AvailableFulfillmentLines.Next() = 0) or (Qty = 0);
    end;

    local procedure SaveFulfillmentEntries(var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        ShopifyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        CalculatedFulfillmentLines.SetCurrentKey("Table No.", "BC Record ID");
        if CalculatedFulfillmentLines.FindSet() then
            repeat
                ShopifyFulfillmentEntry.TransferFields(CalculatedFulfillmentLines);
                ShopifyFulfillmentEntry."Entry No." := 0;
                ShopifyFulfillmentEntry.Insert();
            until CalculatedFulfillmentLines.Next() = 0;
    end;

    local procedure DeleteFulfillmentEntries(RecID: RecordId)
    var
        ShopifyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        ShopifyFulfillmentEntry.SetRange("Table No.", RecID.TableNo());
        ShopifyFulfillmentEntry.SetRange("BC Record ID", RecID);
        if not ShopifyFulfillmentEntry.IsEmpty() then
            ShopifyFulfillmentEntry.DeleteAll();
    end;

    local procedure GenerateFulfillmentPayloadJson(var NcTask: Record "NPR Nc Task"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var SendToShopify: Boolean)
    var
        RootObj: JsonObject;
        VariablesObj: JsonObject;
        FulfillmentObj: JsonObject;
        TrackingInfo: JsonObject;
        ItemsByFulfillmentOrder: JsonArray;
        OrderLinesArr: JsonArray;
        FulfillmentOrderObj: JsonObject;
        LineObj: JsonObject;
        OutStr: OutStream;
        CurrentFulfillmentOrderId: Text;
        MutationTxt: Label 'mutation fulfillmentCreate($fulfillment: FulfillmentInput!) {fulfillmentCreate(fulfillment: $fulfillment) {fulfillment { id status } userErrors { field message }}}', Locked = true;
        NoFulfillmentAvailableErr: Label 'There are no Shopify fulfillment order lines available to process. Everything may have already been fulfilled. Please check fulfillment status in Shopify.';
    begin
        SendToShopify := false;
        if CalculatedFulfillmentLines.IsEmpty() then begin
            SpfyIntegrationMgt.SetResponse(NcTask, NoFulfillmentAvailableErr);
            exit;
        end;
        CalculatedFulfillmentLines.SetCurrentKey("Fulfillment Order ID", "Fulfillment Order Line ID");
        if not CalculatedFulfillmentLines.FindSet() then
            exit;
        repeat
            CurrentFulfillmentOrderId := CalculatedFulfillmentLines."Fulfillment Order ID";
            Clear(OrderLinesArr);
            repeat
                Clear(LineObj);
                LineObj.Add('id', 'gid://shopify/FulfillmentOrderLineItem/' + CalculatedFulfillmentLines."Fulfillment Order Line ID");
                LineObj.Add('quantity', AddIntQuantityToJson(CalculatedFulfillmentLines."Fulfilled Quantity", CalculatedFulfillmentLines."Fulfillable Quantity"));
                OrderLinesArr.Add(LineObj);
            until (CalculatedFulfillmentLines.Next() = 0) or
                  (CalculatedFulfillmentLines."Fulfillment Order ID" <> CurrentFulfillmentOrderId);

            Clear(FulfillmentOrderObj);
            FulfillmentOrderObj.Add('fulfillmentOrderId', 'gid://shopify/FulfillmentOrder/' + CurrentFulfillmentOrderId);
            FulfillmentOrderObj.Add('fulfillmentOrderLineItems', OrderLinesArr);
            ItemsByFulfillmentOrder.Add(FulfillmentOrderObj);

            CalculatedFulfillmentLines.SetRange("Fulfillment Order ID");

        until CalculatedFulfillmentLines.Next() = 0;

        Clear(FulfillmentObj);
        FulfillmentObj.Add('lineItemsByFulfillmentOrder', ItemsByFulfillmentOrder);
        FulfillmentObj.Add('notifyCustomer', true);
        if GenerateTrackingInfo(NcTask, TrackingInfo) then
            FulfillmentObj.Add('trackingInfo', TrackingInfo);

        Clear(VariablesObj);
        VariablesObj.Add('fulfillment', FulfillmentObj);

        Clear(RootObj);
        RootObj.Add('query', MutationTxt);
        RootObj.Add('variables', VariablesObj);

        NcTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        RootObj.WriteTo(OutStr);

        SendToShopify := true;
    end;

    local procedure GenerateTrackingInfo(var NcTask: Record "NPR Nc Task"; var TrackingInfo: JsonObject): Boolean
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        ShippingAgent: Record "Shipping Agent";
        SpfyTrackingCompany: Enum "NPR Spfy Tracking Company";
        RecRef: RecordRef;
        TrackingCompanyName: Text;
        TrackingUrl: Text;
        Handled: Boolean;
    begin
        Clear(TrackingInfo);
        case NcTask."Table No." of
            Database::"Sales Shipment Header":
                begin
                    RecRef.Get(NcTask."Record ID");
                    RecRef.SetTable(SalesShipmentHeader);
                    if SalesShipmentHeader."Package Tracking No." = '' then
                        exit(false);

                    Handled := false;
                    SpfyIntegrationEvents.OnGetTrackingCompanyName(SalesShipmentHeader, TrackingCompanyName, Handled);
                    if not Handled or (TrackingCompanyName = '') then
                        if SalesShipmentHeader."Shipping Agent Code" <> '' then begin
                            ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code");
                            if ShippingAgent."NPR Spfy Tracking Company" in [ShippingAgent."NPR Spfy Tracking Company"::" ", ShippingAgent."NPR Spfy Tracking Company"::Other] then begin
                                if ShippingAgent.Name = '' then
                                    TrackingCompanyName := ShippingAgent.Code
                                else
                                    TrackingCompanyName := ShippingAgent.Name;
                            end else
                                TrackingCompanyName := SpfyTrackingCompany.Names.Get(SpfyTrackingCompany.Ordinals.IndexOf(ShippingAgent."NPR Spfy Tracking Company".AsInteger()));
                        end;
                    if TrackingCompanyName <> '' then
                        TrackingInfo.Add('company', TrackingCompanyName);

                    TrackingInfo.Add('number', SalesShipmentHeader."Package Tracking No.");

                    Handled := false;
                    SpfyIntegrationEvents.OnGetTrackingUrl(SalesShipmentHeader, TrackingUrl, Handled);
                    if not Handled then
                        if ShippingAgent."Internet Address" <> '' then
                            TrackingUrl := ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No.");
                    if TrackingUrl <> '' then
                        TrackingInfo.Add('url', TrackingUrl);

                    exit(true);
                end;
        end;
    end;

    local procedure GetFulfillmentOrderNodes(ResponseBody: JsonToken) FulfillmentOrdersArr: JsonArray
    var
        EdgesToken: JsonToken;
        EdgeToken: JsonToken;
        NodeToken: JsonToken;
    begin
        Clear(FulfillmentOrdersArr);
        if not ResponseBody.SelectToken('data.order.fulfillmentOrders.edges', EdgesToken) then
            exit;
        foreach EdgeToken in EdgesToken.AsArray() do
            if EdgeToken.SelectToken('node', NodeToken) then
                FulfillmentOrdersArr.Add(NodeToken);
    end;

    [TryFunction]
    local procedure ParsePageInfo(Response: JsonToken; PropertyName: Text; var HasNext: Boolean; var Cursor: Text)
    var
        LinesJObj: JsonObject;
        LinesJToken: JsonToken;
        PageInfo: JsonToken;
        WrongJSONFormatErr: Label 'Invalid JSON format passed to the procedure, this is a programming issue.';
    begin
        HasNext := false;
        if not Response.SelectToken(PropertyName, LinesJToken) then
            Error(WrongJSONFormatErr);

        LinesJObj := LinesJToken.AsObject();
        if LinesJObj.SelectToken('pageInfo', PageInfo) then begin
            HasNext := JsonHelper.GetJBoolean(PageInfo, 'hasNextPage', true);
            Cursor := JsonHelper.GetJText(PageInfo, 'endCursor', false);
        end;
    end;

    local procedure AddIntQuantityToJson(Quantity: Decimal; RemainingUnfulfilledQty: Decimal): Integer
    begin
        Quantity := Round(Quantity, 1, '>');
        if Quantity > RemainingUnfulfilledQty then
            Quantity := Round(RemainingUnfulfilledQty, 1, '<');
        exit(Quantity);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnRunOnBeforeFinalizePosting', '', true, false)]
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnRunOnBeforeFinalizePosting, '', true, false)]
#endif
    local procedure ScheduleSendShopifyFulfillment(var SalesHeader: Record "Sales Header"; var SalesShipmentHeader: Record "Sales Shipment Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    var
        NcTask: Record "NPR Nc Task";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesShipmentLine: Record "Sales Shipment Line";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        ShopifyOrderID: Text[30];
        Found: Boolean;
    begin
        if not (SalesHeader.Ship or SalesHeader.Receive) then
            exit;

        NcTask."Store Code" :=
            CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));

        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Order Fulfillments", NcTask."Store Code") then
            exit;

        ShopifyOrderID := SpfyAssignedIDMgt.GetAssignedShopifyID(SalesHeader.RecordId(), "NPR Spfy ID Type"::"Entry ID");
        if ShopifyOrderID = '' then
            exit;

        Found := false;
        if SalesHeader.Ship then begin
            SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
            if SalesShipmentLine.FindSet() then
                repeat
                    Found := IsEligibleForFulfillmentSending(SalesShipmentLine.RecordId(), SalesShipmentLine.Quantity);
                until (SalesShipmentLine.Next() = 0) or Found;
            if not Found then
                exit;
            RecRef.GetTable(SalesShipmentHeader);
        end else begin
            ReturnReceiptLine.SetRange("Document No.", SalesShipmentHeader."No.");
            if ReturnReceiptLine.FindSet() then
                repeat
                    Found := IsEligibleForFulfillmentSending(ReturnReceiptLine.RecordId(), ReturnReceiptLine.Quantity);
                until (ReturnReceiptLine.Next() = 0) or Found;
            if not Found then
                exit;
            RecRef.GetTable(ReturnReceiptHeader);
        end;
        SpfyScheduleSend.InitNcTask(NcTask."Store Code", RecRef, ShopifyOrderID, NcTask.Type::Insert, NcTask);
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Line", 'OnAfterDeleteEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Sales Shipment Line", OnAfterDeleteEvent, '', true, false)]
#endif
    local procedure OnAfterDeleteSalesShipmentLine_CleanUpFulfillmentEntries(var Rec: Record "Sales Shipment Line")
    begin
        DeleteFulfillmentEntries(Rec.RecordId());
    end;

#if BC18 or BC19 or BC20 or BC21
    [EventSubscriber(ObjectType::Table, Database::"Return Receipt Line", 'OnAfterDeleteEvent', '', true, false)]
#else
    [EventSubscriber(ObjectType::Table, Database::"Return Receipt Line", OnAfterDeleteEvent, '', true, false)]
#endif
    local procedure OnAfterDeleteReturnReceiptLine_CleanUpFulfillmentEntries(var Rec: Record "Return Receipt Line")
    begin
        DeleteFulfillmentEntries(Rec.RecordId());
    end;
}
#endif

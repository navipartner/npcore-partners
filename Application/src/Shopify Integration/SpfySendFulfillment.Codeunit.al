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
                begin
                    SendShopifyFulfillment(Rec);
                end;
        end;
    end;

    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";

    local procedure SendShopifyFulfillment(var NcTask: Record "NPR Nc Task")
    var
        TempCalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SendToShopify: Boolean;
        Success: Boolean;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        ClearLastError();
        TempCalculatedFulfillmentLines.DeleteAll();

        Success := PrepareFulfillment(NcTask, TempCalculatedFulfillmentLines, SendToShopify);
        if SendToShopify then
            Success := SpfyCommunicationHandler.SendFulfillmentRequest(NcTask);
        if SendToShopify and Success then
            SaveFulfillmentEntries(TempCalculatedFulfillmentLines);

        NcTask.Modify();
        Commit();
        if not Success then
            Error(GetLastErrorText);
    end;

    [TryFunction]
    local procedure PrepareFulfillment(var NcTask: Record "NPR Nc Task"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var SendToShopify: Boolean)
    var
        TempAvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        FulfillmentOrder: JsonToken;
        FulfillmentOrderLine: JsonToken;
        FulfillmentOrderLines: JsonToken;
        ShopifyResponse: JsonToken;
        FulfillmentOrderID: Text[30];
    begin
        TempAvailableFulfillmentLines.Reset();
        TempAvailableFulfillmentLines.DeleteAll();

        if NcTask."Store Code" = '' then
            NcTask."Store Code" :=
                CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));
#pragma warning disable AA0139
        SpfyCommunicationHandler.GetShopifyOrderFulfillmentOrders(NcTask."Store Code", NcTask."Record Value", ShopifyResponse);
#pragma warning restore AA0139
        ShopifyResponse.AsObject().Get('fulfillment_orders', ShopifyResponse);
        foreach FulfillmentOrder in ShopifyResponse.AsArray() do
            if JsonHelper.GetJText(FulfillmentOrder, 'status', true) <> 'closed' then begin
#pragma warning disable AA0139
                FulfillmentOrderID := JsonHelper.GetJText(FulfillmentOrder, 'id', MaxStrLen(FulfillmentOrderID), true);
#pragma warning restore AA0139
                FulfillmentOrder.AsObject().Get('line_items', FulfillmentOrderLines);
                foreach FulfillmentOrderLine in FulfillmentOrderLines.AsArray() do begin
                    TempAvailableFulfillmentLines.Init();
                    TempAvailableFulfillmentLines."Fulfillable Quantity" := JsonHelper.GetJDecimal(FulfillmentOrderLine, 'fulfillable_quantity', false);
                    if TempAvailableFulfillmentLines."Fulfillable Quantity" > 0 then begin
                        TempAvailableFulfillmentLines."Fulfillment Order ID" := FulfillmentOrderID;
#pragma warning disable AA0139
                        TempAvailableFulfillmentLines."Fulfillment Order Line ID" := JsonHelper.GetJText(FulfillmentOrderLine, 'id', MaxStrLen(TempAvailableFulfillmentLines."Fulfillment Order Line ID"), true);
                        TempAvailableFulfillmentLines."Order Line ID" := JsonHelper.GetJText(FulfillmentOrderLine, 'line_item_id', MaxStrLen(TempAvailableFulfillmentLines."Fulfillment Order Line ID"), true);
#pragma warning restore AA0139
                        TempAvailableFulfillmentLines."Entry No." += 1;
                        TempAvailableFulfillmentLines.Insert();
                    end;
                end;
            end;

        CalculateFulfillmentLines(NcTask, TempAvailableFulfillmentLines, CalculatedFulfillmentLines);
        GenerateFulfillmentPayloadJson(NcTask, CalculatedFulfillmentLines, SendToShopify);
    end;

    local procedure CalculateFulfillmentLines(NcTask: Record "NPR Nc Task"; var AvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
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
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
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
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        ItemsByFulfillmentOrder: JsonArray;
        OrderLines: JsonArray;
        ChildJObject: JsonObject;
        JObject: JsonObject;
        OutStr: OutStream;
        NoFulfillmentAvailableErr: Label 'There are no Shopify fulfillment order lines available to process. Everything may have already been fulfilled. Please check fulfillment status in Shopify.';
        ShipmentPostedMsg: Label 'BC: the packages has been successfully shipped';
    begin
        SendToShopify := false;
        if CalculatedFulfillmentLines.IsEmpty() then begin
            SpfyIntegrationMgt.SetResponse(NcTask, NoFulfillmentAvailableErr);
            exit;
        end;

        CalculatedFulfillmentLines.SetCurrentKey("Fulfillment Order ID", "Fulfillment Order Line ID");
        if CalculatedFulfillmentLines.FindSet() then
            repeat
                CalculatedFulfillmentLines.SetRange("Fulfillment Order ID", CalculatedFulfillmentLines."Fulfillment Order ID");
                Clear(OrderLines);
                repeat
                    Clear(ChildJObject);
                    ChildJObject.Add('id', CalculatedFulfillmentLines."Fulfillment Order Line ID");
                    ChildJObject.Add('quantity', Format(CalculatedFulfillmentLines."Fulfilled Quantity", 0, 9));
                    OrderLines.Add(ChildJObject);
                until CalculatedFulfillmentLines.Next() = 0;

                Clear(ChildJObject);
                ChildJObject.Add('fulfillment_order_id', CalculatedFulfillmentLines."Fulfillment Order ID");
                ChildJObject.Add('fulfillment_order_line_items', OrderLines);
                ItemsByFulfillmentOrder.Add(ChildJObject);
                CalculatedFulfillmentLines.SetRange("Fulfillment Order ID");
            until CalculatedFulfillmentLines.Next() = 0;

        Clear(ChildJObject);
        ChildJObject.Add('message', ShipmentPostedMsg);
        ChildJObject.Add('notify_customer', true);
        ChildJObject.Add('line_items_by_fulfillment_order', ItemsByFulfillmentOrder);

        JObject.Add('fulfillment', ChildJObject);
        NcTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        JObject.WriteTo(OutStr);
        SendToShopify := true;
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
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
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
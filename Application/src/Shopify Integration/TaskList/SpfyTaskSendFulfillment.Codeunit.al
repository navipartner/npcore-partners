// Native sibling of frozen codeunit "NPR Spfy Send Fulfillment": only sanctioned legacy defect fixes are dual-applied, new-queue behavior changes are not.
codeunit 6151471 "NPR Spfy Task Send Fulfillment"
{
    Access = Internal;
    TableNo = "NPR Spfy Task";

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
        _SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        _SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        _SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        _SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        _OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        _JsonHelper: Codeunit "NPR Json Helper";
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _GraphQLClientSet: Boolean;

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _GraphQLClient := GraphQLClient;
        _GraphQLClientSet := true;
    end;

    local procedure GetGraphQLClient(): Interface "NPR Spfy IGraphQL Client"
    var
        DefaultGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
    begin
        if not _GraphQLClientSet then begin
            _GraphQLClient := DefaultGraphQLClient;
            _GraphQLClientSet := true;
        end;
        exit(_GraphQLClient);
    end;

    local procedure SendShopifyFulfillment(var SpfyTask: Record "NPR Spfy Task")
    var
        TempCalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        FailureErrorText: Text;
        AnyFailure: Boolean;
        NoFulfillmentAvailableErr: Label 'There are no Shopify fulfillment order lines available to process. Everything may have already been fulfilled. Please check fulfillment status in Shopify.';
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        ClearLastError();
        TempCalculatedFulfillmentLines.DeleteAll();

        if not PrepareFulfillment(SpfyTask, TempCalculatedFulfillmentLines) then begin
            SpfyTask.Modify();
            Commit();
            Error(GetTransportErrorText(SpfyTask));
        end;

        if TempCalculatedFulfillmentLines.IsEmpty() then begin
            _SpfyIntegrationMgt.SetResponse(SpfyTask, NoFulfillmentAvailableErr);
            SpfyTask.Modify();
            Commit();
            exit;
        end;

        AnyFailure := SendFulfillmentsPerLocation(SpfyTask, TempCalculatedFulfillmentLines, FailureErrorText);

        SpfyTask.Modify();
        Commit();

        // On any failure, fail the task so it retries. The retry recalculates from Shopify's remaining quantities and
        // deducts the persisted fulfillment entries (see AlreadyFulfilledQuantity) — Shopify still reports the partially
        // fulfilled line as remaining, so the deduction is what makes already-fulfilled locations produce nothing and
        // only the failed ones re-send.
        if AnyFailure then
            Error(FailureErrorText);
    end;

    [TryFunction]
    local procedure PrepareFulfillment(var SpfyTask: Record "NPR Spfy Task"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        TempAvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer" temporary;
        FulfillmentOrderIds: List of [Text[30]];
        FulfillmentOrderId: Text[30];
    begin
        TempAvailableFulfillmentLines.Reset();
        TempAvailableFulfillmentLines.DeleteAll();

        if SpfyTask."Store Code" = '' then
            SpfyTask."Store Code" := CopyStr(_SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(SpfyTask."Store Code"));

        CollectFulfillmentOrders(SpfyTask, FulfillmentOrderIds);

        foreach FulfillmentOrderId in FulfillmentOrderIds do
            LoadFulfillmentOrderLines(SpfyTask, FulfillmentOrderId, TempAvailableFulfillmentLines);

        CalculateFulfillmentLines(SpfyTask, TempAvailableFulfillmentLines, CalculatedFulfillmentLines);
    end;

    local procedure SendFulfillmentsPerLocation(var SpfyTask: Record "NPR Spfy Task"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var ErrorText: Text) AnyFailure: Boolean
    var
        ShopifyResponse: JsonToken;
        LocationIds: List of [Text];
        LocationId: Text;
        FulfillmentId: Text[30];
        TransportErrorText: Text;
        UserErrorText: Text;
        TransportFailureOccurred: Boolean;
        SendToShopify: Boolean;
        Success: Boolean;
        MissingFulfillmentIdErr: Label 'Shopify fulfillmentCreate returned no fulfillment id and no userErrors. This is a programming bug', Locked = true;
    begin
        CollectDistinctLocationIds(CalculatedFulfillmentLines, LocationIds);

        foreach LocationId in LocationIds do begin
            CalculatedFulfillmentLines.Reset();
            CalculatedFulfillmentLines.SetRange("Location ID", LocationId);

            Clear(ShopifyResponse);
            ClearLastError();
            FulfillmentId := '';
            GenerateFulfillmentPayloadJson(SpfyTask, CalculatedFulfillmentLines, SendToShopify);
            if SendToShopify then begin
                Success := GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse);
                if Success then
                    FulfillmentId := GetCreatedFulfillmentId(ShopifyResponse);
                if Success and (FulfillmentId <> '') and not _SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then begin
                    SaveFulfillmentEntries(CalculatedFulfillmentLines, FulfillmentId);
                    Commit();
                end else begin
                    AnyFailure := true;
                    if not Success then begin
                        TransportFailureOccurred := true;
                        TransportErrorText := AppendLocationDiagnostic(TransportErrorText, LocationId, GetTransportErrorText(SpfyTask));
                    end else
                        if _SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
                            UserErrorText := AppendLocationDiagnostic(UserErrorText, LocationId, GetUserErrorMessages(ShopifyResponse))
                        else begin
                            // 2xx with no fulfillment and no userErrors means the Shopify API contract broke (e.g. a version
                            // bump changed the response shape) - it would hit every store at once. Route it to the raised-error
                            // channel so it produces telemetry, instead of the quiet userError Error('') where it goes unnoticed.
                            TransportFailureOccurred := true;
                            TransportErrorText := AppendLocationDiagnostic(TransportErrorText, LocationId, MissingFulfillmentIdErr);
                        end;
                end;
            end;
        end;
        CalculatedFulfillmentLines.Reset();

        if TransportFailureOccurred then
            ErrorText := CombineDiagnostics(TransportErrorText, UserErrorText)
        else
            if UserErrorText <> '' then
                _SpfyIntegrationMgt.SetResponse(SpfyTask, UserErrorText);
    end;

    local procedure CollectDistinctLocationIds(var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var LocationIds: List of [Text])
    begin
        Clear(LocationIds);
        CalculatedFulfillmentLines.Reset();
        CalculatedFulfillmentLines.SetCurrentKey("Location ID", "Fulfillment Order ID", "Fulfillment Order Line ID");
        if CalculatedFulfillmentLines.FindSet() then
            repeat
                if not LocationIds.Contains(CalculatedFulfillmentLines."Location ID") then
                    LocationIds.Add(CalculatedFulfillmentLines."Location ID");
            until CalculatedFulfillmentLines.Next() = 0;
        CalculatedFulfillmentLines.Reset();
    end;

    local procedure GetUserErrorMessages(ShopifyResponse: JsonToken) Messages: Text
    var
        UserErrors: JsonToken;
        UserError: JsonToken;
        Message: Text;
    begin
        if not _SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse, UserErrors) then
            exit('');
        foreach UserError in UserErrors.AsArray() do begin
            Message := FormatUserError(UserError);
            if Message <> '' then begin
                if Messages <> '' then
                    Messages += '; ';
                Messages += Message;
            end;
        end;
    end;

    local procedure FormatUserError(UserError: JsonToken) FormattedError: Text
    var
        PathToken: JsonToken;
        SegmentToken: JsonToken;
        RejectedPath: Text;
        FieldContextLbl: Label '%1 (field: %2)', Comment = '%1 = Shopify userError message, %2 = rejected input field path';
    begin
        FormattedError := _JsonHelper.GetJText(UserError, 'message', false);
        // Shopify returns the rejected input path in "field" (an array of segments); keep it for troubleshooting.
        if not (UserError.SelectToken('field', PathToken) and PathToken.IsArray()) then
            exit;
        foreach SegmentToken in PathToken.AsArray() do begin
            if RejectedPath <> '' then
                RejectedPath += '.';
            RejectedPath += SegmentToken.AsValue().AsText();
        end;
        if (FormattedError <> '') and (RejectedPath <> '') then
            FormattedError := StrSubstNo(FieldContextLbl, FormattedError, RejectedPath);
    end;

    local procedure GetTransportErrorText(var SpfyTask: Record "NPR Spfy Task") ErrorText: Text
    var
        InStr: InStream;
        Body: TextBuilder;
        Line: Text;
        MaxLen: Integer;
    begin
        ErrorText := GetLastErrorText();
        if ErrorText <> '' then
            exit;
        if not SpfyTask.Response.HasValue() then
            exit;
        // Bound the snippet: this text is emitted to error telemetry (which truncates anyway) and shown on the task list,
        // so avoid dumping a multi-KB proxy HTML page — its useful part (status/message) is at the top.
        MaxLen := 2048;
        SpfyTask.Response.CreateInStream(InStr, TextEncoding::UTF8);
        while (not InStr.EOS()) and (Body.Length() < MaxLen) do begin
            InStr.ReadText(Line);
            if Body.Length() > 0 then
                Body.AppendLine();
            Body.Append(Line);
        end;
        ErrorText := CopyStr(Body.ToText(), 1, MaxLen);
    end;

    local procedure AppendLocationDiagnostic(ExistingText: Text; LocationId: Text; Message: Text): Text
    var
        LocationPrefixLbl: Label 'Location %1: %2', Comment = '%1 = Shopify location id, %2 = failure detail';
        NoDetailsLbl: Label 'no error details returned';
        Fragment: Text;
    begin
        // Never drop the location marker: a failure with no message would otherwise leave no trace of which location failed.
        if Message = '' then
            Message := NoDetailsLbl;
        if LocationId = '' then
            Fragment := Message
        else
            Fragment := StrSubstNo(LocationPrefixLbl, LocationId, Message);
        if ExistingText = '' then
            exit(Fragment);
        exit(ExistingText + '; ' + Fragment);
    end;

    local procedure CombineDiagnostics(TransportErrorText: Text; UserErrorText: Text): Text
    begin
        if TransportErrorText = '' then
            exit(UserErrorText);
        if UserErrorText = '' then
            exit(TransportErrorText);
        exit(TransportErrorText + '; ' + UserErrorText);
    end;

    local procedure CollectFulfillmentOrders(var SpfyTask: Record "NPR Spfy Task"; var FulfillmentOrderIds: List of [Text[30]])
    var
        FulfillmentOrder: JsonToken;
        ShopifyResponse: JsonToken;
        Cursor: Text;
        FulfillmentOrderID: Text[30];
        HasNext: Boolean;
        RequestString: Label 'query GetFulfillmentOrders($OrderId: ID!,$afterCursor: String){order(id:$OrderId){fulfillmentOrders(after:$afterCursor,first:50){pageInfo{hasNextPage endCursor} edges{node{id status}}}}}', Locked = true;
    begin
        Clear(FulfillmentOrderIds);
        _SpfyCommunicationHandler.InitializePagingState(Cursor, HasNext);
        repeat
            _SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(SpfyTask, Cursor, SpfyTask."Store Code", RequestString, 'gid://shopify/Order/' + SpfyTask."Record Value", true);
            if not GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse) then
                Error(GetLastErrorText());
            if not ParsePageInfo(ShopifyResponse, 'data.order.fulfillmentOrders', HasNext, Cursor) then
                Error(GetLastErrorText());
            foreach FulfillmentOrder in GetFulfillmentOrderNodes(ShopifyResponse) do
                if _JsonHelper.GetJText(FulfillmentOrder, 'status', true).ToLower() <> 'closed' then begin
                    FulfillmentOrderID := _OrderMgt.GetNumericId(_JsonHelper.GetJText(FulfillmentOrder, 'id', true));
                    if not FulfillmentOrderIds.Contains(FulfillmentOrderID) then
                        FulfillmentOrderIds.Add(FulfillmentOrderID);
                end;
        until not HasNext;
    end;

    local procedure LoadFulfillmentOrderLines(var SpfyTask: Record "NPR Spfy Task"; FulfillmentOrderId: Text[30]; var TempAvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        FulfillmentOrderLine: JsonToken;
        FulfillmentOrderLines: JsonToken;
        ShopifyResponse: JsonToken;
        Cursor: Text;
        FulfillmentOrderLocationId: Text[30];
        HasNext: Boolean;
        LocationCaptured: Boolean;
        RequestString: Label 'query GetFulfilmentOrder($OrderId:ID!,$afterCursor:String){fulfillmentOrder(id:$OrderId){assignedLocation{location{id}} lineItems(first:50,after:$afterCursor){pageInfo{hasNextPage endCursor} edges{node{id remainingQuantity lineItem{id}}}}}}', Locked = true;
    begin
        _SpfyCommunicationHandler.InitializePagingState(Cursor, HasNext);
        repeat
            Clear(SpfyTask."Data Output");
            _SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(SpfyTask, Cursor, SpfyTask."Store Code", RequestString, 'gid://shopify/FulfillmentOrder/' + FulfillmentOrderId, true);
            if not GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse) then
                Error(GetLastErrorText());
            if not ParsePageInfo(ShopifyResponse, 'data.fulfillmentOrder.lineItems', HasNext, Cursor) then
                Error(GetLastErrorText());
            if not LocationCaptured then begin
                FulfillmentOrderLocationId := _OrderMgt.GetNumericId(_JsonHelper.GetJText(ShopifyResponse, 'data.fulfillmentOrder.assignedLocation.location.id', false));
                LocationCaptured := true;
            end;
            ShopifyResponse.SelectToken('data.fulfillmentOrder.lineItems.edges', FulfillmentOrderLines);
            foreach FulfillmentOrderLine in FulfillmentOrderLines.AsArray() do begin
                TempAvailableFulfillmentLines.Init();
                TempAvailableFulfillmentLines."Fulfillable Quantity" := _JsonHelper.GetJDecimal(FulfillmentOrderLine, 'node.remainingQuantity', false);
                if TempAvailableFulfillmentLines."Fulfillable Quantity" > 0 then begin
                    TempAvailableFulfillmentLines."Location ID" := FulfillmentOrderLocationId;
                    TempAvailableFulfillmentLines."Fulfillment Order ID" := FulfillmentOrderId;
                    TempAvailableFulfillmentLines."Fulfillment Order Line ID" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(FulfillmentOrderLine, 'node.id', true));
                    TempAvailableFulfillmentLines."Order Line ID" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(FulfillmentOrderLine, 'node.lineItem.id', true));
                    TempAvailableFulfillmentLines."Entry No." += 1;
                    TempAvailableFulfillmentLines.Insert();
                end;
            end;
        until not HasNext;
    end;

    local procedure CalculateFulfillmentLines(SpfyTask: Record "NPR Spfy Task"; var AvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        ReturnReceiptHeader: Record "Return Receipt Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        RecRef: RecordRef;
        SpfyOrderLineId: Text[30];
        CurrentQty: Decimal;
    begin
        case SpfyTask."Table No." of
            Database::"Sales Shipment Header":
                begin
                    RecRef.Get(SpfyTask."Record ID");
                    RecRef.SetTable(SalesShipmentHeader);
                    SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
                    if SalesShipmentLine.FindSet() then
                        repeat
                            CurrentQty := SalesShipmentLine.Quantity;
                            if IsEligibleForFulfillmentSending(SalesShipmentLine.RecordId(), CurrentQty, SpfyOrderLineId) then
                                CalculateLineFulfillment(SalesShipmentLine.RecordId(), SpfyOrderLineId, CurrentQty, AvailableFulfillmentLines, CalculatedFulfillmentLines);
                        until SalesShipmentLine.Next() = 0;
                end;
            Database::"Return Receipt Header":
                begin
                    RecRef.Get(SpfyTask."Record ID");
                    RecRef.SetTable(ReturnReceiptHeader);
                    ReturnReceiptLine.SetRange("Document No.", ReturnReceiptHeader."No.");
                    if ReturnReceiptLine.FindSet() then
                        repeat
                            CurrentQty := ReturnReceiptLine.Quantity;
                            if IsEligibleForFulfillmentSending(ReturnReceiptLine.RecordId(), CurrentQty, SpfyOrderLineId) then
                                CalculateLineFulfillment(ReturnReceiptLine.RecordId(), SpfyOrderLineId, CurrentQty, AvailableFulfillmentLines, CalculatedFulfillmentLines);
                        until ReturnReceiptLine.Next() = 0;
                end;
            else
                _SpfyIntegrationMgt.UnsupportedIntegrationTable(SpfyTask, StrSubstNo('CU%1.%2', Format(Codeunit::"NPR Spfy Task Send Fulfillment"), 'PrepareFulfillmentLines'));
        end;
    end;

    local procedure CalculateLineFulfillment(RecID: RecordId; SpfyOrderLineId: Text[30]; LineQuantity: Decimal; var AvailableFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer")
    var
        Qty: Decimal;
        FulfillMaxAvailableQty: Boolean;
    begin
        Qty := LineQuantity - AlreadyFulfilledQuantity(RecID);
        _SpfyIntegrationEvents.OnCalculateFulfillmentQuantity(RecID, SpfyOrderLineId, Qty, FulfillMaxAvailableQty);
        if (not FulfillMaxAvailableQty) and (Qty <= 0) then
            exit;
        UpdateFulfillmentBuffer(RecID, AvailableFulfillmentLines, SpfyOrderLineId, Qty, FulfillMaxAvailableQty, CalculatedFulfillmentLines);
    end;

    local procedure IsEligibleForFulfillmentSending(RecID: RecordId; Qty: Decimal; var SpfyOrderLineId: Text[30]) Eligible: Boolean
    begin
        SpfyOrderLineId := _SpfyAssignedIDMgt.GetAssignedShopifyID(RecID, "NPR Spfy ID Type"::"Entry ID");
        Eligible := (SpfyOrderLineId <> '') and (Qty <> 0);
        _SpfyIntegrationEvents.OnCheckIfIsEligibleForFulfillmentSending(RecID, SpfyOrderLineId, Eligible);
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
                    NextEntryNo += 1;
                end;
            until (AvailableFulfillmentLines.Next() = 0) or (Qty = 0);
    end;

    local procedure SaveFulfillmentEntries(var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; FulfillmentId: Text[30])
    var
        ShopifyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        CalculatedFulfillmentLines.SetCurrentKey("Table No.", "BC Record ID");
        if CalculatedFulfillmentLines.FindSet() then
            repeat
                ShopifyFulfillmentEntry.TransferFields(CalculatedFulfillmentLines);
                ShopifyFulfillmentEntry."Entry No." := 0;
                ShopifyFulfillmentEntry."Fulfillment ID" := FulfillmentId;
                ShopifyFulfillmentEntry.Insert();
            until CalculatedFulfillmentLines.Next() = 0;
    end;

    local procedure GetCreatedFulfillmentId(ShopifyResponse: JsonToken): Text[30]
    begin
        exit(CopyStr(_OrderMgt.GetNumericId(_JsonHelper.GetJText(ShopifyResponse, 'data.fulfillmentCreate.fulfillment.id', false)), 1, 30));
    end;

    /// <summary>
    /// Sum of what has already been fulfilled for this BC line, from the persisted "NPR Spfy Fulfillment Entry" rows.
    /// Deducting this from the line quantity makes retries idempotent (a partially fulfilled location is not re-sent).
    /// TRADE-OFF: this makes the BC entry table authoritative rather than Shopify's live remainingQuantity. Fulfillments
    /// are driven from BC, so cancelling must also happen in BC. If a fulfillment is cancelled directly in Shopify (which
    /// reopens the fulfillment order), reprocessing this NC task will NOT re-send it — the saved entries would first have
    /// to be cleared. NP does not currently expose a cancel-fulfillment action, so this is a known, documented limitation.
    /// </summary>
    local procedure AlreadyFulfilledQuantity(RecID: RecordId): Decimal
    var
        ShopifyFulfillmentEntry: Record "NPR Spfy Fulfillment Entry";
    begin
        ShopifyFulfillmentEntry.SetRange("Table No.", RecID.TableNo());
        ShopifyFulfillmentEntry.SetRange("BC Record ID", RecID);
        ShopifyFulfillmentEntry.CalcSums("Fulfilled Quantity");
        exit(ShopifyFulfillmentEntry."Fulfilled Quantity");
    end;

    /// <summary>
    /// Builds the fulfillmentCreate payload for the currently filtered set of calculated lines (one Shopify location).
    /// The caller is expected to have applied a "Location ID" filter, since a Shopify fulfillment must belong to a
    /// single location. Sets SendToShopify to false when the filtered set is empty.
    /// </summary>
    local procedure GenerateFulfillmentPayloadJson(var SpfyTask: Record "NPR Spfy Task"; var CalculatedFulfillmentLines: Record "NPR Spfy Fulfillment Buffer"; var SendToShopify: Boolean)
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
        CurrentFulfillmentOrderId: Text[30];
        MoreLines: Boolean;
        MutationTxt: Label 'mutation fulfillmentCreate($fulfillment: FulfillmentInput!) {fulfillmentCreate(fulfillment: $fulfillment) {fulfillment { id status } userErrors { field message }}}', Locked = true;
    begin
        SendToShopify := false;
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);

        CalculatedFulfillmentLines.SetCurrentKey("Location ID", "Fulfillment Order ID", "Fulfillment Order Line ID");
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
                MoreLines := CalculatedFulfillmentLines.Next() <> 0;
            until (not MoreLines) or (CalculatedFulfillmentLines."Fulfillment Order ID" <> CurrentFulfillmentOrderId);

            Clear(FulfillmentOrderObj);
            FulfillmentOrderObj.Add('fulfillmentOrderId', 'gid://shopify/FulfillmentOrder/' + CurrentFulfillmentOrderId);
            FulfillmentOrderObj.Add('fulfillmentOrderLineItems', OrderLinesArr);
            ItemsByFulfillmentOrder.Add(FulfillmentOrderObj);
        until not MoreLines;

        Clear(FulfillmentObj);
        FulfillmentObj.Add('lineItemsByFulfillmentOrder', ItemsByFulfillmentOrder);
        FulfillmentObj.Add('notifyCustomer', true);
        if GenerateTrackingInfo(SpfyTask, TrackingInfo) then
            FulfillmentObj.Add('trackingInfo', TrackingInfo);

        Clear(VariablesObj);
        VariablesObj.Add('fulfillment', FulfillmentObj);

        Clear(RootObj);
        RootObj.Add('query', MutationTxt);
        RootObj.Add('variables', VariablesObj);

        SpfyTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        RootObj.WriteTo(OutStr);

        SendToShopify := true;
    end;

    local procedure GenerateTrackingInfo(var SpfyTask: Record "NPR Spfy Task"; var TrackingInfo: JsonObject): Boolean
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
        case SpfyTask."Table No." of
            Database::"Sales Shipment Header":
                begin
                    RecRef.Get(SpfyTask."Record ID");
                    RecRef.SetTable(SalesShipmentHeader);
                    if SalesShipmentHeader."Package Tracking No." = '' then
                        exit(false);

                    Handled := false;
                    _SpfyIntegrationEvents.OnGetTrackingCompanyName(SalesShipmentHeader, TrackingCompanyName, Handled);
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
                    _SpfyIntegrationEvents.OnGetTrackingUrl(SalesShipmentHeader, TrackingUrl, Handled);
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
            HasNext := _JsonHelper.GetJBoolean(PageInfo, 'hasNextPage', true);
            Cursor := _JsonHelper.GetJText(PageInfo, 'endCursor', false);
        end;
    end;

    local procedure AddIntQuantityToJson(Quantity: Decimal; RemainingUnfulfilledQty: Decimal): Integer
    begin
        Quantity := Round(Quantity, 1, '>');
        if Quantity > RemainingUnfulfilledQty then
            Quantity := Round(RemainingUnfulfilledQty, 1, '<');
        exit(Quantity);
    end;
}

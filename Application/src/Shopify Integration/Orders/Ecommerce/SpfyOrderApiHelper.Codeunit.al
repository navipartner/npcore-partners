#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248582 "NPR Spfy Order ApiHelper"
{
    Access = Internal;
    Permissions = tabledata "NPR Spfy Store" = rm;
    TableNo = "NPR Spfy Event Log Entry";
    trigger OnRun()
    var
        ShopifyResponse: JsonToken;
    begin
        Clear(_ShopifyResponse);
        GetOrderDetails(Rec, ShopifyResponse);
        _ShopifyResponse := ShopifyResponse;
    end;

    internal procedure GetOrderDetails(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var ShopifyResponse: JsonToken)
    var
        OutStr: OutStream;
        JsonText: Text;
        WrongJSONFormatErr: Label 'Unable to serialize Shopify JSON response.';
    begin
        if SpfyEventLogEntry."Document Type" = SpfyEventLogEntry."Document Type"::"Return Order" then begin
            if not TryGetReturnDetails(SpfyEventLogEntry, ShopifyResponse) then
                Error(GetLastErrorText());
        end else
            if not TryGetOrderDetails(SpfyEventLogEntry, ShopifyResponse) then
                Error(GetLastErrorText());

        if ShouldSkipEcommerceDocumentImport(SpfyEventLogEntry, ShopifyResponse) then
            Error(GetLastErrorText());
        SpfyEventLogEntry.CalcFields("Order Data");
        if SpfyEventLogEntry."Order Data".HasValue() then
            Clear(SpfyEventLogEntry."Order Data");
        if not ShopifyResponse.WriteTo(JsonText) then
            Error(WrongJSONFormatErr);
        SpfyEventLogEntry."Order Data".CreateOutStream(OutStr, TextEncoding::UTF8);
        ShopifyResponse.WriteTo(OutStr);
        SpfyEventLogEntry.Modify();
    end;

    internal procedure GetResponse() ShopifyResponse: JsonToken;
    begin
        exit(_ShopifyResponse);
    end;

    local procedure BuildUnifiedOrderJson(HeaderResponse: JsonObject; LineItemsArr: JsonArray; FulfilmentsArr: JsonArray; ShippingLinesArr: JsonArray): JsonToken
    var
        RootObj: JsonObject;
        DataObj: JsonObject;
        OrderObj: JsonObject;
        DataToken: JsonToken;
        OrderToken: JsonToken;
        MissingDataLbl: Label 'Invalid Shopify response: missing "data" node.', Locked = true;
        MissingOrderLbl: Label 'Invalid Shopify response: missing "data.order" node.', Locked = true;
    begin
        if not HeaderResponse.Get('data', DataToken) then
            Error(MissingDataLbl);
        DataObj := DataToken.AsObject();
        if not DataObj.Get('order', OrderToken) then
            Error(MissingOrderLbl);

        OrderObj := OrderToken.AsObject();
        OrderObj.Add('lineItems', LineItemsArr);
        OrderObj.Add('fulfillments', FulfilmentsArr);
        OrderObj.Add('shippingLines', ShippingLinesArr);
        Clear(DataObj);
        DataObj.Add('order', OrderObj);

        Clear(RootObj);
        RootObj.Add('data', DataObj);
        exit(RootObj.AsToken());
    end;

    local procedure TryGetReturnDetails(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var ShopifyResponse: JsonToken): Boolean
    var
        ReturnResponse: JsonToken;
        ReturnGID: Text;
    begin
        ClearLastError();
        ReturnGID := 'gid://shopify/Return/' + SpfyEventLogEntry."Shopify ID";
        if not GetReturn(ReturnGID, SpfyEventLogEntry."Store Code", ReturnResponse) then
            exit(false);
        exit(BuildUnifiedReturnJson(ReturnResponse, ShopifyResponse));
    end;

    local procedure GetReturn(ReturnGID: Text; ShopifyStoreCode: Code[20]; var ReturnResponse: JsonToken): Boolean
    var
        NcTask: Record "NPR Nc Task";
        ReturnRequest: Label 'query GetReturn($OrderId: ID!) { return(id: $OrderId) { id name status order { id name number email phone note sourceName taxesIncluded currencyCode presentmentCurrencyCode customer { id firstName lastName defaultAddress { phone } } billingAddress { firstName lastName company countryCodeV2 zip address1 address2 city } shippingAddress { firstName lastName company address1 address2 zip city countryCodeV2 } } refunds(first: 50) { pageInfo { hasNextPage } edges { node { id totalRefundedSet { presentmentMoney { amount } shopMoney { amount currencyCode } } refundLineItems(first: 100) { pageInfo { hasNextPage } edges { node { quantity subtotalSet { presentmentMoney { amount } } totalTaxSet { presentmentMoney { amount } } lineItem { id sku name title variantTitle taxLines { ratePercentage priceSet { presentmentMoney { amount } } } } } } } transactions(first: 100) { pageInfo { hasNextPage } edges { node { id kind status gateway processedAt createdAt authorizationExpiresAt amountSet { presentmentMoney { amount currencyCode } shopMoney { amount currencyCode } } paymentId paymentDetails { ... on CardPaymentDetails { company expirationMonth expirationYear name number paymentMethodName } ... on LocalPaymentMethodsPaymentDetails { paymentDescriptor paymentMethodName } } receiptJson } } } } } } } }', Locked = true;
    begin
        ClearLastError();
        Clear(NcTask);
        SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, '', ShopifyStoreCode, ReturnRequest, ReturnGID, false);
        exit(SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ReturnResponse));
    end;

    // Reshapes the Shopify return/refund response into the same unified order JSON shape the importer consumes:
    // data.order { ...header..., lineItems[] (edges, built from refundLineItems), shippingLines[] (empty), transactions[] (refund transactions) }.
    [TryFunction]
    local procedure BuildUnifiedReturnJson(ReturnResponse: JsonToken; var ShopifyResponse: JsonToken)
    var
        RootObj: JsonObject;
        DataObj: JsonObject;
        OrderObj: JsonObject;
        LineItemsArr: JsonArray;
        ShippingLinesArr: JsonArray;
        TransactionsArr: JsonArray;
        OrderToken: JsonToken;
        RefundsToken: JsonToken;
        RefundEdge: JsonToken;
        RefundNode: JsonToken;
        SuccessfulRefundTransactions: Integer;
        IncompleteReturnErr: Label 'The Shopify return has more refunds, refunded lines or refund transactions than the import can retrieve in a single request, so it cannot be imported without risking an incorrect credit memo.';
        MissingOrderLbl: Label 'Invalid Shopify response: missing "data.return.order" node.', Locked = true;
        NoLinesErr: Label 'The Shopify return has no refunded line items to import.';
        NoRefundTransactionErr: Label 'The Shopify return has no successful refund transaction to import.';
    begin
        if not ReturnResponse.SelectToken('data.return.order', OrderToken) then
            Error(MissingOrderLbl);
        OrderObj := OrderToken.AsObject();

        if JsonHelper.GetJBoolean(ReturnResponse, 'data.return.refunds.pageInfo.hasNextPage', false) then
            Error(IncompleteReturnErr);
        if ReturnResponse.SelectToken('data.return.refunds.edges', RefundsToken) and RefundsToken.IsArray() then
            foreach RefundEdge in RefundsToken.AsArray() do begin
                RefundEdge.SelectToken('node', RefundNode);
                if RefundDataTruncated(RefundNode) then
                    Error(IncompleteReturnErr);
                AddReturnLineItems(LineItemsArr, RefundNode);
                AddReturnTransactions(TransactionsArr, RefundNode, SuccessfulRefundTransactions);
            end;

        if LineItemsArr.Count() = 0 then
            Error(NoLinesErr);
        if SuccessfulRefundTransactions = 0 then
            Error(NoRefundTransactionErr);

        OrderObj.Add('lineItems', LineItemsArr);
        OrderObj.Add('shippingLines', ShippingLinesArr);
        OrderObj.Add('transactions', TransactionsArr);

        Clear(DataObj);
        DataObj.Add('order', OrderObj);
        Clear(RootObj);
        RootObj.Add('data', DataObj);
        ShopifyResponse := RootObj.AsToken();
    end;

    local procedure RefundDataTruncated(RefundNode: JsonToken): Boolean
    begin
        exit(
            JsonHelper.GetJBoolean(RefundNode, 'refundLineItems.pageInfo.hasNextPage', false) or
            JsonHelper.GetJBoolean(RefundNode, 'transactions.pageInfo.hasNextPage', false));
    end;

    local procedure AddReturnLineItems(var LineItemsArr: JsonArray; RefundNode: JsonToken)
    var
        RefundLineItemsToken: JsonToken;
        RefundLineItemEdge: JsonToken;
        RefundLineItemNode: JsonToken;
    begin
        if not (RefundNode.SelectToken('refundLineItems.edges', RefundLineItemsToken) and RefundLineItemsToken.IsArray()) then
            exit;
        foreach RefundLineItemEdge in RefundLineItemsToken.AsArray() do begin
            RefundLineItemEdge.SelectToken('node', RefundLineItemNode);
            LineItemsArr.Add(BuildReturnLineItemEdge(RefundLineItemNode));
        end;
    end;

    local procedure BuildReturnLineItemEdge(RefundLineItemNode: JsonToken) EdgeObj: JsonObject
    var
        LineItemNode: JsonObject;
        OriginalUnitPriceSet: JsonObject;
        PresentmentMoney: JsonObject;
        EmptyArray: JsonArray;
        LineItemToken: JsonToken;
        TaxLinesToken: JsonToken;
        Quantity: Decimal;
        UnitPrice: Decimal;
    begin
        RefundLineItemNode.SelectToken('lineItem', LineItemToken);
        Quantity := JsonHelper.GetJDecimal(RefundLineItemNode, 'quantity', true);
        if Quantity <> 0 then
            UnitPrice := JsonHelper.GetJDecimal(RefundLineItemNode, 'subtotalSet.presentmentMoney.amount', false) / Quantity;

        LineItemNode.Add('id', JsonHelper.GetJText(LineItemToken, 'id', false));
        LineItemNode.Add('sku', JsonHelper.GetJText(LineItemToken, 'sku', false));
        LineItemNode.Add('name', JsonHelper.GetJText(LineItemToken, 'name', false));
        LineItemNode.Add('title', JsonHelper.GetJText(LineItemToken, 'title', false));
        LineItemNode.Add('variantTitle', JsonHelper.GetJText(LineItemToken, 'variantTitle', false));
        LineItemNode.Add('quantity', Quantity);
        LineItemNode.Add('unfulfilledQuantity', Quantity);
        LineItemNode.Add('currentQuantity', Quantity);
        LineItemNode.Add('nonFulfillableQuantity', 0);
        LineItemNode.Add('isGiftCard', false);

        PresentmentMoney.Add('amount', UnitPrice);
        OriginalUnitPriceSet.Add('presentmentMoney', PresentmentMoney);
        LineItemNode.Add('originalUnitPriceSet', OriginalUnitPriceSet);

        if LineItemToken.SelectToken('taxLines', TaxLinesToken) and TaxLinesToken.IsArray() then
            LineItemNode.Add('taxLines', TaxLinesToken.AsArray())
        else
            LineItemNode.Add('taxLines', EmptyArray);
        LineItemNode.Add('discountAllocations', EmptyArray);

        EdgeObj.Add('node', LineItemNode);
    end;

    local procedure AddReturnTransactions(var TransactionsArr: JsonArray; RefundNode: JsonToken; var SuccessfulRefundTransactions: Integer)
    var
        TransactionsToken: JsonToken;
        TransactionEdge: JsonToken;
        TransactionNode: JsonToken;
    begin
        if not (RefundNode.SelectToken('transactions.edges', TransactionsToken) and TransactionsToken.IsArray()) then
            exit;
        foreach TransactionEdge in TransactionsToken.AsArray() do begin
            TransactionEdge.SelectToken('node', TransactionNode);
            // Only successful refund transactions are real refunds; FAILURE/PENDING/ERROR must not become payment lines downstream.
            if JsonHelper.GetJText(TransactionNode, 'status', false).ToUpper() = 'SUCCESS' then begin
                TransactionsArr.Add(TransactionNode);
                SuccessfulRefundTransactions += 1;
            end;
        end;
    end;

    local procedure TryGetOrderDetails(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var ShopifyResponse: JsonToken): Boolean
    var
        TempTempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        LineItemsArr: JsonArray;
        HeaderResponse: JsonObject;
        FulfilmentsArr: JsonArray;
        ShippingLinesArr: JsonArray;
        OrderGID: Text;
        HeaderRequest: Label 'query GetHeader($OrderId: ID!) { order(id: $OrderId) { id taxesIncluded displayFinancialStatus createdAt reservationToken: metafield(namespace: "np-ticket", key: "reservation_token") { value } lineItemsData: metafield(namespace: "np-ticket", key: "line_items_data") { value } email phone note sourceName customer{id firstName lastName defaultEmailAddress{emailAddress} defaultPhoneNumber{phoneNumber} defaultAddress{phone}} billingAddress { firstName lastName company countryCodeV2 zip address1 address2 city } shippingAddress { firstName lastName company address1 address2 zip city countryCodeV2 phone } number note sourceName createdAt closedAt cancelledAt totalPriceSet { presentmentMoney { amount } shopMoney { amount } } currencyCode presentmentCurrencyCode capturable transactions(first: 250) { id kind status amountSet { presentmentMoney { amount currencyCode } shopMoney { amount currencyCode } } authorizationCode authorizationExpiresAt processedAt createdAt gateway multiCapturable parentTransaction { id kind } paymentId processedAt status totalUnsettledSet { presentmentMoney { amount currencyCode } shopMoney { amount currencyCode } } paymentDetails { ... on CardPaymentDetails { avsResultCode bin company expirationMonth expirationYear name number paymentMethodName wallet } ... on LocalPaymentMethodsPaymentDetails { paymentDescriptor paymentMethodName } } receiptJson } } }', Locked = true;
        ItemLinesRequest: Label 'query GetOrderLines($OrderId: ID!, $afterCursor:String) { order(id: $OrderId) { lineItems(after:$afterCursor, first: 50) { pageInfo { hasNextPage endCursor } edges { node { id sku  taxLines{ratePercentage priceSet{presentmentMoney{amount}}} originalUnitPriceSet { presentmentMoney { amount } shopMoney { amount } } customAttributes {key value} isGiftCard product {id productType} name title variant{price} quantity variantTitle unfulfilledQuantity currentQuantity nonFulfillableQuantity discountAllocations { allocatedAmountSet { presentmentMoney { amount } } } } } } } }', Locked = true;
        ShippingLinesRequest: Label 'query GetShippingLines($OrderId: ID!, $afterCursor:String) { order(id: $OrderId) { shippingLines(first: 10, after:$afterCursor) { pageInfo { endCursor hasNextPage } edges { node { id code title taxLines{ratePercentage priceSet{presentmentMoney{amount}}} discountAllocations { allocatedAmountSet { presentmentMoney { amount } } } code originalPriceSet { presentmentMoney { amount } } } } } } }', Locked = true;
    begin
        OrderGID := 'gid://shopify/Order/' + SpfyEventLogEntry."Shopify ID";

        if not TryGetOrderLines(OrderGID, SpfyEventLogEntry."Store Code", 'lineItems', ItemLinesRequest, LineItemsArr) then
            exit(false);

        if not TryGetOrderHeader(OrderGID, SpfyEventLogEntry."Store Code", HeaderRequest, HeaderResponse) then
            exit(false)
        else
            if HandleAnonymizedCustomerOrder(HeaderResponse, SpfyEventLogEntry) then
                exit(false);

        if not ValidateTransactions(HeaderResponse) then
            exit(false);

        if not TryGetAndCacheFulfilments(OrderGID, SpfyEventLogEntry, FulfilmentsArr) then
            exit(false);

        if FindAndCacheGiftCards(LineItemsArr) then
            if not CheckIfGiftCardsReady(SpfyEventLogEntry."Document Status", TempTempSpfyFulfillmentBuffer) then
                PostponeProcessing(SpfyEventLogEntry)
            else
                if not TryGetOrderGiftCards(OrderGID, SpfyEventLogEntry."Store Code", TempTempSpfyFulfillmentBuffer) then
                    exit(false);

        if not TryGetOrderLines(OrderGID, SpfyEventLogEntry."Store Code", 'shippingLines', ShippingLinesRequest, ShippingLinesArr) then
            exit(false);

        ShopifyResponse := BuildUnifiedOrderJson(HeaderResponse, LineItemsArr, FulfilmentsArr, ShippingLinesArr);
        exit(true);
    end;

    local procedure HandleAnonymizedCustomerOrder(HeaderResponse: JsonObject; SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"): Boolean
    var
        EcomSalesDocImport: Codeunit "NPR Spfy Ecom Sales Doc Import";
        OrderToken: JsonToken;
        ContinueProcess: Boolean;
        AnonymizedCustomerOrderErr: Label 'The order is for an anonymous customer. If the order has not yet been posted, the system has deleted it. Further processing has been skipped.';
    begin
        HeaderResponse.SelectToken('data.order', OrderToken);
        if not OrderMgt.IsAnonymizedCustomerOrder(JsonHelper.GetJText(OrderToken, 'customer.firstName', false), JsonHelper.GetJText(OrderToken, 'customer.lastName', false)) then
            exit(false);
        EcomSalesDocImport.DeleteDocument(SpfyEventLogEntry);
        ContinueProcess := RaiseError(AnonymizedCustomerOrderErr);
        exit(not ContinueProcess);
    end;

    [TryFunction]
    local procedure RaiseError(Input: Text)
    begin
        Error(input);
    end;

    local procedure PostponeProcessing(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        SpfyEventLogEntry.Postponed := true;
        SpfyEventLogEntry."Not Before Date-Time" := CurrentDateTime + JobQueueManagement.MinutesToDuration(5);
        SpfyEventLogEntry."Last Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(SpfyEventLogEntry."Last Error Message"));
    end;

    local procedure TryGetAndCacheFulfilments(OrderGID: Text; SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; var Result: JsonArray): Boolean
    begin
        //don't check for canceled orders
        Clear(Result);
        if SpfyEventLogEntry."Document Status" <> SpfyEventLogEntry."Document Status"::Cancelled then begin
            if not TryGetOrderFulfilments(OrderGID, SpfyEventLogEntry."Store Code", Result) then
                exit(false);
            exit(CacheFulfillment(Result));
        end;
        exit(true);
    end;

    local procedure TryGetOrderGiftCards(OrderGID: Text; StoreCode: Code[20]; var TempTempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary): Boolean
    begin
        ClearLastError();
        exit(TryProcessGiftCardsForOrder(OrderGID, StoreCode, TempTempSpfyFulfillmentBuffer));
    end;

    [TryFunction]
    local procedure TryProcessGiftCardsForOrder(OrderGID: Text; StoreCode: Code[20]; var TempTempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary)
    begin
        ProcessGiftCardLines(TempTempSpfyFulfillmentBuffer, OrderGID, StoreCode);
    end;

    [TryFunction]
    local procedure CheckIfGiftCardsReady(OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; var TempTempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary)
    var
        NoGiftCardsErr: Label 'No gift cards found in the Fulfillments';
        VouchersNotReadyErr: Label 'The order cannot be processed yet because not all gift cards are fulfilled in Shopify.';
    begin
        ClearLastError();
        if not SpfyFulfillmentCache.GetOrderLines(TempTempSpfyFulfillmentBuffer, true) then
            Error(NoGiftCardsErr);

        //in closed they are All fulfilled
        if OrderStatus = OrderStatus::Open then
            if not SpfyFulfillmentCache.AllFulfilled() then
                Error(VouchersNotReadyErr);
    end;

    local procedure ProcessGiftCardLines(var TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; OrderGID: Text; StoreCode: Code[20])
    begin
        if TempSpfyFulfillmentBuffer.FindSet() then
            repeat
                GetGiftCard(TempSpfyFulfillmentBuffer."Order Line ID", TempSpfyFulfillmentBuffer."Initial Amount", TempSpfyFulfillmentBuffer."Updated At", OrderGID, StoreCode, TempSpfyFulfillmentBuffer.Email);
            until TempSpfyFulfillmentBuffer.Next() = 0;
    end;

    local procedure GetGiftCard(GCOrderLineId: Text[30]; InitialAmt: Decimal; CreatedAt: DateTime; OrderGID: Text; StoreCode: Code[20]; CustEmail: Text)
    var
        GiftCardsArr: JsonArray;
        Cursor: Text;
        HasNext: Boolean;
        FetchedAll: Boolean;
        NoGiftCardErr: Label 'No gift cards found for order %1', Comment = '%1=Shopify Order Id';
    begin
        SpfyCommunicationHandler.InitializePagingState(Cursor, HasNext);
        repeat
            Clear(GiftCardsArr);
            if not MakeGiftCardsRequest(GiftCardsArr, HasNext, Cursor, InitialAmt, CreatedAt, StoreCode, CustEmail) then
                Error(GetLastErrorText());
            if GiftCardsArr.Count = 0 then
                Error(NoGiftCardErr, GetNumericId(OrderGID));
            FetchedAll := CacheGiftCardDetailsForOrder(GCOrderLineId, OrderGID, GiftCardsArr);
        until (not HasNext) or FetchedAll;
    end;

    local procedure CacheGiftCardDetailsForOrder(GCOrderLineId: Text[30]; OrderGID: Text; GiftCardsArr: JsonArray): Boolean
    var
        GiftNode: JsonToken;
        ExpectedCount: Integer;
        FoundCount: Integer;
        GiftCardGID: Text;
        LastCharacters: Text;
        NoMatchingGiftCardsErr: Label 'Unable to find the expected gift card(s) for Shopify Order Line %1 (Shopify Order %2).', Comment = '%1 = GCOrderLineId; %2 = OrderGID';
    begin
        ExpectedCount := SpfyFulfillmentCache.GetExpectedGiftCardCount(GCOrderLineId);
        foreach GiftNode in GiftCardsArr do
            if (JsonHelper.GetJText(GiftNode, 'node.order.id', false) = OrderGID) then begin
                GiftCardGID := JsonHelper.GetJText(GiftNode, 'node.id', true);
                LastCharacters := JsonHelper.GetJText(GiftNode, 'node.lastCharacters', true);
                SpfyFulfillmentCache.AddGiftCardDetails(GCOrderLineId, GiftCardGID, LastCharacters);
                FoundCount += 1;
                if FoundCount >= ExpectedCount then
                    exit(true);
            end;
        Error(NoMatchingGiftCardsErr, GCOrderLineId, OrderGID);
    end;

    [TryFunction]
    local procedure MakeGiftCardsRequest(var GiftCardsArr: JsonArray; var HasNext: Boolean; var Cursor: Text; InitialAmt: Decimal; CreatedAt: DateTime; StoreCode: Code[20]; CustEmail: Text)
    var
        NcTask: Record "NPR Nc Task";
        Response: JsonToken;
        ResponseBody: JsonToken;
        DateTimeSingleQ: Text;
        GiftCardRequest: Label 'query giftCards($afterCursor:String,$queryFilters:String){giftCards(first:100,after:$afterCursor,query:$queryFilters,sortKey: CREATED_AT){pageInfo{hasNextPage endCursor}edges{node{id createdAt updatedAt order{id email} initialValue{amount} lastCharacters maskedCode note recipientAttributes{sendNotificationAt message recipient{id}}}}}}', Locked = true;
    begin
        HasNext := false;
        ClearLastError();
        DateTimeSingleQ := SingleQuotes(Format(CreatedAt, 0, 9));
        CreateRequestForList(NcTask, Cursor, StoreCode, GiftCardRequest, StrSubstNo('created_at:>=%1 AND initial_value:%2 AND %3', DateTimeSingleQ, InitialAmt, CustEmail));
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, Response) then
            Error(GetLastErrorText());
        Cursor := JsonHelper.GetJText(Response, 'data.giftCards.pageInfo.endCursor', false);
        HasNext := JsonHelper.GetJBoolean(Response, 'data.giftCards.pageInfo.hasNextPage', true);
        Response.SelectToken('data.giftCards.edges', ResponseBody);
        GiftCardsArr := ResponseBody.AsArray();
    end;

    local procedure TryGetOrderHeader(OrderGID: Text; ShopifyStoreCode: Code[20]; HeaderRequest: Text; var Result: JsonObject): Boolean
    begin
        ClearLastError();
        Clear(Result);
        exit(TryGetHeader(OrderGID, ShopifyStoreCode, HeaderRequest, Result));
    end;

    [TryFunction]
    local procedure TryGetHeader(OrderGID: Text; ShopifyStoreCode: Code[20]; HeaderRequest: Text; var Result: JsonObject)
    var
        NcTask: Record "NPR Nc Task";
        HeaderResponse: JsonToken;
    begin
        Clear(NcTask);
        SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, '', ShopifyStoreCode, HeaderRequest, OrderGID, false);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, HeaderResponse) then
            Error(GetLastErrorText());

        Result := HeaderResponse.AsObject();
    end;

    local procedure ValidateTransactions(Response: JsonObject): Boolean
    var
        SpfyCapturePayment: Codeunit "NPR Spfy Capture Payment";
        PaymentLinesJsonToken: JsonToken;
        PaymentLineJsonToken: JsonToken;
        ShopifyTransactionKind: Text;
        AuthTxt: label 'Authorization', locked = true;
        NoArrayErr: Label 'The %1 property is not an array.', Locked = true;
        SaleTxt: Label 'Sale', locked = true;
        TransactionsErr: Label 'There are no successful transactions of type %1 or %2', Comment = '%1=Authorization;%2=Sale', Locked = true;
    begin
        PaymentLinesJsonToken := JsonHelper.GetJsonToken(Response.AsToken(), 'data.order.transactions');
        if (not PaymentLinesJsonToken.IsArray()) then
            Error(NoArrayErr, 'data.order.transactions');

        foreach PaymentLineJsonToken in PaymentLinesJsonToken.AsArray() do
            if JsonHelper.GetJText(PaymentLineJsonToken, 'status', true).ToUpper() = 'SUCCESS' then begin
                ShopifyTransactionKind := JsonHelper.GetJText(PaymentLineJsonToken, 'kind', false).ToUpper();
                if SpfyCapturePayment.IsAuthorizationTransaction(ShopifyTransactionKind) or SpfyCapturePayment.IsSaleTransaction(ShopifyTransactionKind) then
                    exit(true);
            end;
        Error(TransactionsErr, AuthTxt, SaleTxt);
    end;

    [TryFunction]
    local procedure TryGetLines(OrderGID: Text; StoreCode: Code[20]; PropertyName: Text; RequestText: Text; var FullResults: JsonArray)
    var
        NcTask: Record "NPR Nc Task";
        Results: JsonArray;
        ResponseBody: JsonToken;
        ResultToken: JsonToken;
        Cursor: Text;
        HasNext: Boolean;
    begin
        SpfyCommunicationHandler.InitializePagingState(Cursor, HasNext);
        ClearLastError();
        Clear(Results);
        repeat
            Clear(NcTask);
            SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, Cursor, StoreCode, RequestText, OrderGID, true);
            if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ResponseBody) then
                Error(GetLastErrorText());
            if not Parse(ResponseBody, PropertyName, Results, HasNext, Cursor, true) then
                Error(GetLastErrorText());
        until not HasNext;
        foreach ResultToken in Results do
            FullResults.Add(ResultToken);
    end;


    local procedure TryGetOrderFulfilments(OrderGID: Text; ShopifyStoreCode: Code[20]; var FullResults: JsonArray): Boolean
    var
        FulfilmentRequest: Label 'query GetFulfilments($OrderId: ID!, $afterCursor: String) { order(id: $OrderId) { fulfillments { createdAt order{id email} updatedAt displayStatus status id fulfillmentLineItems(first: 10, after: $afterCursor) { edges { cursor node { id quantity lineItem { id currentQuantity variant{price} unfulfilledQuantity nonFulfillableQuantity isGiftCard originalUnitPriceSet{presentmentMoney{amount}}} } } pageInfo { endCursor hasNextPage } } } } }', Locked = true;
    begin
        ClearLastError();
        exit(TryGetFulfilments(OrderGID, ShopifyStoreCode, FulfilmentRequest, FullResults));
    end;

    [TryFunction]
    local procedure TryGetFulfilments(OrderGID: Text; ShopifyStoreCode: Code[20]; RequestText: Text; var FullResults: JsonArray)
    var
        NcTask: Record "NPR Nc Task";
        HasNext: Boolean;
        FulfilmentArr: JsonArray;
        Results: JsonArray;
        FulfillmentLineItemsJO: JsonObject;
        FulfilmentJToken: JsonToken;
        ResponseBody: JsonToken;
        Cursor: Text;
    begin
        Clear(FullResults);
        Clear(NcTask);
        SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, Cursor, ShopifyStoreCode, RequestText, OrderGID, true);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ResponseBody) then
            Error(GetLastErrorText());

        ResponseBody.SelectToken('data.order.fulfillments', FulfilmentJToken);
        FulfilmentArr := FulfilmentJToken.AsArray();

        foreach FulfilmentJToken in FulfilmentArr do begin
            Clear(Results);
            Clear(FulfillmentLineItemsJO);
            SpfyCommunicationHandler.InitializePagingState(Cursor, HasNext);
            AddFulfilmentInfo(FulfillmentLineItemsJO, FulfilmentJToken);
            repeat
                ClearLastError();
                Clear(NcTask);
                SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, Cursor, ShopifyStoreCode, RequestText, OrderGID, true);
                if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ResponseBody) then
                    Error(GetLastErrorText());
                if not Parse(FulfilmentJToken, 'fulfillmentLineItems', Results, HasNext, Cursor, false) then
                    Error(GetLastErrorText());
            until not HasNext;

            FulfillmentLineItemsJO.Add('fulfillmentLineItems', Results);
            FullResults.Add(FulfillmentLineItemsJO);
        end;
    end;

    local procedure AddFulfilmentInfo(var TargetObj: JsonObject; FJToken: JsonToken)
    begin
        Clear(TargetObj);
        TargetObj.Add('id', JsonHelper.GetJText(FJToken, 'id', false));
        TargetObj.Add('status', JsonHelper.GetJText(FJToken, 'status', false));
        TargetObj.Add('displayStatus', JsonHelper.GetJText(FJToken, 'displayStatus', false));
        TargetObj.Add('createdAt', JsonHelper.GetJDT(FJToken, 'createdAt', false));
        TargetObj.Add('updatedAt', JsonHelper.GetJDT(FJToken, 'updatedAt', false));
        TargetObj.Add('orderId', JsonHelper.GetJText(FJToken, 'order.id', false));
        TargetObj.Add('email', JsonHelper.GetJText(FJToken, 'order.email', false));
    end;

    [TryFunction]
    procedure Parse(Response: JsonToken; PropertyName: Text; var Results: JsonArray; var HasNext: Boolean; var Cursor: Text; IncludeOrderPath: Boolean)
    var
        EdgesArr: JsonArray;
        LinesJObj: JsonObject;
        EdgeJToken: JsonToken;
        EdgesJToken: JsonToken;
        LinesJToken: JsonToken;
        PageInfo: JsonToken;
        WrongJSONFormatErr: Label 'Invalid JSON format passed to the procedure, this is a programming issue.';
    begin
        HasNext := false;
        if not Response.SelectToken(SetPath(PropertyName, IncludeOrderPath), LinesJToken) then
            Error(WrongJSONFormatErr);

        LinesJObj := LinesJToken.AsObject();
        if LinesJObj.SelectToken('pageInfo', PageInfo) then begin
            HasNext := JsonHelper.GetJBoolean(PageInfo, 'hasNextPage', true);
            Cursor := JsonHelper.GetJText(PageInfo, 'endCursor', false);
        end;

        if LinesJObj.SelectToken('edges', EdgesJToken) then begin
            EdgesArr := EdgesJToken.AsArray();
            foreach EdgeJToken in EdgesArr do begin
                Results.Add(EdgeJToken);
            end;
        end;
    end;

    local procedure CacheGiftCardOrderLine(OrderLine: JsonToken)
    var
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        OrderLineId: Text[30];
    begin
        OrderLineId := GetNumericId(JsonHelper.GetJText(OrderLine, 'id', false));
        if not SpfyFulfillmentCache.GetLineFromCache(OrderLineId, TempSpfyFulfillmentBuffer) then begin
            TempSpfyFulfillmentBuffer.Init();
            MapFulfillmentSharedFields(TempSpfyFulfillmentBuffer, OrderLine, OrderLineId);
            TempSpfyFulfillmentBuffer.Insert();
        end;
        if not TempSpfyFulfillmentBuffer.IsEmpty() then
            SpfyFulfillmentCache.CacheLine(TempSpfyFulfillmentBuffer);
    end;

    local procedure MapFulfillmentSharedFields(var TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary; OrderLine: JsonToken; OrderLineId: Text[30])
    begin
        TempSpfyFulfillmentBuffer."Order Line ID" := OrderLineId;
        TempSpfyFulfillmentBuffer."Entry No." := SpfyFulfillmentCache.GetLastFulfillmentEntryNo() + 1;
        TempSpfyFulfillmentBuffer."Gift Card" := JsonHelper.GetJBoolean(OrderLine, 'isGiftCard', false);
        if TempSpfyFulfillmentBuffer."Gift Card" then
            TempSpfyFulfillmentBuffer."Initial Amount" := JsonHelper.GetJDecimal(OrderLine, 'variant.price', true)
        else
            TempSpfyFulfillmentBuffer."Initial Amount" := JsonHelper.GetJDecimal(OrderLine, 'originalUnitPriceSet.presentmentMoney.amount', true);

        TempSpfyFulfillmentBuffer."Fulfillable Quantity" := JsonHelper.GetJDecimal(OrderLine, 'unfulfilledQuantity', false);
    end;

    local procedure TryGetOrderLines(OrderGID: Text; StoreCode: Code[20]; Property: Text; RequestTxt: Text; var Result: JsonArray) Success: Boolean
    begin
        ClearLastError();
        Clear(Result);
        Success := TryGetLines(OrderGID, StoreCode, Property, RequestTxt, Result);
    end;

    local procedure SetPath(PropertyName: Text; IncludeOrderPath: Boolean) Path: Text
    begin
        if IncludeOrderPath then
            Path := 'data.order.' + PropertyName
        else
            Path := PropertyName;
        exit(Path);
    end;

    [TryFunction]
    internal procedure GetOrderList(var HasNext: Boolean; var ShopifyResponse: JsonToken; ShopifyStore: Record "NPR Spfy Store"; var OrdersArr: JsonArray; var Cursor: Text; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; FromDT: DateTime)
    var
        NcTask: Record "NPR Nc Task";
        ResponseBody: JsonToken;
        DateTimeSingleQ: Text;
        OrderListRequest: Label 'query ($queryFilters: String!, $afterCursor: String) { orders(first: 100, after: $afterCursor, query: $queryFilters, sortKey:UPDATED_AT) { edges { node { id email number displayFinancialStatus createdAt closedAt updatedAt cancelledAt sourceName name customer { firstName lastName } currentTotalPriceSet { presentmentMoney { amount } shopMoney { amount } } presentmentCurrencyCode currencyCode } } pageInfo { endCursor hasNextPage } } }', Locked = true;
    begin
        HasNext := false;
        Clear(OrdersArr);
        ClearLastError();
        DateTimeSingleQ := SingleQuotes(Format(FromDT - 6 * 60 * 1000, 0, 9));//6mins scope
        CreateRequestForList(NcTask, Cursor, ShopifyStore.Code, OrderListRequest, StrSubstNo('status:%1 AND updated_at:>=%2', MapStatusToQueryParam(OrderStatus), DateTimeSingleQ));
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(GetLastErrorText());
        Cursor := JsonHelper.GetJText(ShopifyResponse, 'data.orders.pageInfo.endCursor', false);
        HasNext := JsonHelper.GetJBoolean(ShopifyResponse, 'data.orders.pageInfo.hasNextPage', true);
        ShopifyResponse.SelectToken('data.orders.edges', ResponseBody);
        OrdersArr := ResponseBody.AsArray();
    end;

    // The Shopify Admin API has no top-level returns query, so we poll orders updated since the marker and read their closed returns
    // (orders filtered by updated_at; the inner returns connection filters status:CLOSED). A return_status pre-filter could optimize this later.
    [TryFunction]
    internal procedure GetReturnList(var HasNext: Boolean; var ShopifyResponse: JsonToken; ShopifyStore: Record "NPR Spfy Store"; var OrdersArr: JsonArray; var Cursor: Text; FromDT: DateTime)
    var
        NcTask: Record "NPR Nc Task";
        ResponseBody: JsonToken;
        DateTimeSingleQ: Text;
        ReturnListRequest: Label 'query ($queryFilters: String!, $afterCursor: String) { orders(first: 100, after: $afterCursor, query: $queryFilters, sortKey:UPDATED_AT) { edges { node { id updatedAt returns(first: 10, query: "status:CLOSED") { edges { node { id name status createdAt closedAt } } pageInfo { endCursor hasNextPage } } } } pageInfo { endCursor hasNextPage } } }', Locked = true;
    begin
        HasNext := false;
        Clear(OrdersArr);
        ClearLastError();
        DateTimeSingleQ := SingleQuotes(Format(FromDT - 6 * 60 * 1000, 0, 9));//6mins scope
        CreateRequestForList(NcTask, Cursor, ShopifyStore.Code, ReturnListRequest, StrSubstNo('updated_at:>=%1', DateTimeSingleQ));
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(GetLastErrorText());
        Cursor := JsonHelper.GetJText(ShopifyResponse, 'data.orders.pageInfo.endCursor', false);
        HasNext := JsonHelper.GetJBoolean(ShopifyResponse, 'data.orders.pageInfo.hasNextPage', true);
        ShopifyResponse.SelectToken('data.orders.edges', ResponseBody);
        OrdersArr := ResponseBody.AsArray();
    end;

    [TryFunction]
    internal procedure GetOrderReturns(ShopifyStore: Record "NPR Spfy Store"; OrderGID: Text; var Cursor: Text; var HasNext: Boolean; var ReturnsArr: JsonArray)
    var
        NcTask: Record "NPR Nc Task";
        ShopifyResponse: JsonToken;
        ResponseBody: JsonToken;
        OrderReturnsRequest: Label 'query ($OrderId: ID!, $afterCursor: String) { order(id: $OrderId) { returns(first: 10, after: $afterCursor, query: "status:CLOSED") { edges { node { id name status createdAt closedAt } } pageInfo { endCursor hasNextPage } } } }', Locked = true;
    begin
        HasNext := false;
        Clear(ReturnsArr);
        ClearLastError();
        SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, Cursor, ShopifyStore.Code, OrderReturnsRequest, OrderGID, true);
        if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
            Error(GetLastErrorText());
        Cursor := JsonHelper.GetJText(ShopifyResponse, 'data.order.returns.pageInfo.endCursor', false);
        HasNext := JsonHelper.GetJBoolean(ShopifyResponse, 'data.order.returns.pageInfo.hasNextPage', false);
        ShopifyResponse.SelectToken('data.order.returns.edges', ResponseBody);
        ReturnsArr := ResponseBody.AsArray();
    end;

    local procedure FindAndCacheGiftCards(ItemLineResponseArr: JsonArray): Boolean
    var
        HasGiftCard: Boolean;
    begin
        ClearLastError();
        if not TryFindAndCacheGiftCard(ItemLineResponseArr, HasGiftCard) then
            Error(GetLastErrorText);
        exit(HasGiftCard);
    end;

    [TryFunction]
    local procedure TryFindAndCacheGiftCard(ItemLineResponseArr: JsonArray; var HasGiftCard: Boolean)
    var
        ItemLineToken: JsonToken;
        LineToken: JsonToken;
    begin
        Clear(HasGiftCard);
        foreach ItemLineToken in ItemLineResponseArr do begin
            ItemLineToken.SelectToken('node', LineToken);
            if (JsonHelper.GetJInteger(LineToken, 'currentQuantity', false)) <> 0 then
                if JsonHelper.GetJBoolean(LineToken, 'isGiftCard', false) then begin
                    HasGiftCard := true;
                    CacheGiftCardOrderLine(LineToken);
                end;
        end;
    end;

    local procedure CacheFulfillment(FulfilmentResponseArr: JsonArray): Boolean
    begin
        ClearLastError();
        exit(TryCacheFulfillment(FulfilmentResponseArr));
    end;

    [TryFunction]
    local procedure TryCacheFulfillment(FulfilmentResponseArr: JsonArray)
    var
        TempSpfyFulfillmentBuffer: Record "NPR Spfy Fulfillment Buffer" temporary;
        LineEdgesArr: JsonArray;
        FulfillmentObj: JsonObject;
        FulfillmentToken: JsonToken;
        LineEdgeToken: JsonToken;
        Node: JsonToken;
        UpdatedAt: DateTime;
        FulfilledQty: Decimal;
        LineItemId: Text[30];
        OrderId: Text[30];
        Email: Text[100];
    begin
        if FulfilmentResponseArr.Count() = 0 then
            exit;

        foreach FulfillmentToken in FulfilmentResponseArr do begin
            FulfillmentObj := FulfillmentToken.AsObject();
#pragma warning disable AA0139
            UpdatedAt := JsonHelper.GetJDT(FulfillmentToken, 'updatedAt', true);
            OrderId := GetNumericId(JsonHelper.GetJText(FulfillmentToken, 'orderId', true));
            Email := JsonHelper.GetJText(FulfillmentToken, 'email', false);
#pragma warning restore AA0139
            if JsonHelper.GetJText(FulfillmentToken, 'status', true).ToLower() = 'success' then begin
                if FulfillmentObj.Get('fulfillmentLineItems', LineEdgeToken) then begin
                    LineEdgesArr := LineEdgeToken.AsArray();
                    foreach LineEdgeToken in LineEdgesArr do begin
                        FulfilledQty := JsonHelper.GetJDecimal(LineEdgeToken, 'node.quantity', true);
                        if FulfilledQty > 0 then begin
                            LineEdgeToken.SelectToken('node.lineItem', Node);
                            LineItemId := GetNumericId(JsonHelper.GetJText(Node, 'id', true));
                            if not SpfyFulfillmentCache.GetLineFromCache(LineItemId, TempSpfyFulfillmentBuffer) then begin
                                TempSpfyFulfillmentBuffer.Init();
                                MapFulfillmentSharedFields(TempSpfyFulfillmentBuffer, Node, LineItemId);
                                TempSpfyFulfillmentBuffer."Updated At" := UpdatedAt;
                                TempSpfyFulfillmentBuffer."Fulfilled Quantity" := FulfilledQty;
                                TempSpfyFulfillmentBuffer.Email := Email;
                                TempSpfyFulfillmentBuffer.Insert();
                            end else begin
                                TempSpfyFulfillmentBuffer."Fulfillable Quantity" := JsonHelper.GetJDecimal(Node, 'unfulfilledQuantity', true);
                                TempSpfyFulfillmentBuffer."Fulfilled Quantity" += FulfilledQty;
                                if TempSpfyFulfillmentBuffer."Gift Card" then begin
                                    TempSpfyFulfillmentBuffer."Updated At" := UpdatedAt;
                                    TempSpfyFulfillmentBuffer.Email := Email;
                                    TempSpfyFulfillmentBuffer."Initial Amount" := JsonHelper.GetJDecimal(Node, 'variant.price', true);
                                end;
                            end;
                            TempSpfyFulfillmentBuffer.Modify();
                            SpfyFulfillmentCache.CacheLine(TempSpfyFulfillmentBuffer);
                        end;
                    end;
                end;
            end;
        end;
    end;


    local procedure ShouldSkipEcommerceDocumentImport(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry"; OrderJson: JsonToken) SkipImport: Boolean
    var
        SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
    begin
        SpfyIntegrationEvents.OnCheckShouldSkipEcommerceDocumentImport(SpfyEventLogEntry."Store Code", OrderJson, SkipImport);
        if SkipImport then
            exit(not ApplySkipImport(SpfyEventLogEntry));
    end;

    [TryFunction]
    local procedure ApplySkipImport(var SpfyEventLogEntry: Record "NPR Spfy Event Log Entry")
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SkipImportErr: Label 'The document import was skipped based on external integration logic.';
    begin
        SpfyEventLogEntry."Process Retry Count" := SpfyIntegrationMgt.GetMaxDocRetryCount();
        Error(SkipImportErr);
    end;

    local procedure CreateRequestForList(var NcTask: Record "NPR Nc Task"; Cursor: Text; ShopifyStoreCode: Code[20]; RequestString: Text; queryFilters: Text)
    var
        VariablesJson: JsonObject;
    begin
        Clear(NcTask);
        NcTask."Store Code" := ShopifyStoreCode;
        VariablesJson.Add('queryFilters', queryFilters);
        SpfyCommunicationHandler.AddGraphQLCursor(VariablesJson, Cursor);
        SpfyCommunicationHandler.CompleteGraphQLRequest(RequestString, VariablesJson, NcTask);
    end;

    local procedure SingleQuotes(Input: Text): Text
    begin
        exit('''' + Input + '''');
    end;

    local procedure MapStatusToQueryParam(Status: Enum "NPR SpfyAPIDocumentStatus") Result: Text
    begin
        Status.Names().Get(Status.Ordinals().IndexOf(Status.AsInteger()), Result);
    end;

    internal procedure GetOrderNo(Order: JsonToken; MaxLen: Integer) OrderNo: Text
    var
        OrderNoLbl: Label 'order number';
    begin
        OrderNo := JsonHelper.GetJText(Order, 'number', true);
        if MaxLen <= 0 then
            exit;
        if StrLen(OrderNo) > MaxLen then
            Error(TooLongValueErr, OrderNoLbl, OrderNo, MaxLen);
    end;

    internal procedure GetNumericId(GlobalId: Text) ShopifyId: Text[30]
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        FullShopifyId: Text;
        ShopifyIdLbl: Label 'Shopify Id';
    begin
        FullShopifyId := SpfyIntegrationMgt.RemoveUntil(GlobalId, '/');
        OrderMgt.ValidateMaxLength(FullShopifyId, MaxStrLen(ShopifyId), ShopifyIdLbl);
        ShopifyId := CopyStr(FullShopifyId, 1, MaxStrLen(ShopifyId));
    end;

    internal procedure OrderLineIsGiftCard(OrderLine: JsonToken): Boolean
    var
        OrderLineProperties: JsonToken;
        OrderLineProperty: JsonToken;
    begin
        if JsonHelper.GetJBoolean(OrderLine, 'isGiftCard', false) then
            exit(true);
        if not (JsonHelper.GetJsonToken(OrderLine, 'customAttributes', OrderLineProperties) and OrderLineProperties.IsArray()) then
            exit(false);
        foreach OrderLineProperty in OrderLineProperties.AsArray() do
            if JsonHelper.GetJText(OrderLineProperty, 'key', false) = '_is_giftcard' then
                exit(JsonHelper.GetJInteger(OrderLineProperty, 'value', false) <> 0);
    end;

    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyFulfillmentCache: Codeunit "NPR Spfy Fulfillment Cache";
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        _ShopifyResponse: JsonToken;
        TooLongValueErr: Label 'Incoming Shopify %1 "%2" exceeds maximum allowed length of %3 characters', Comment = '%1 - incoming field name, %2 - incoming field value, %3 - number of characters';

}
#endif
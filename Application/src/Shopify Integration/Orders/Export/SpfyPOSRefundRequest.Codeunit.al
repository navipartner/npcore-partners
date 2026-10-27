codeunit 6151318 "NPR Spfy POS Refund Request"
{
    Access = Internal;

    var
        _JsonHelper: Codeunit "NPR Json Helper";

    procedure QueryOrder(var SpfyTask: Record "NPR Spfy Task"; GraphQLClient: Interface "NPR Spfy IGraphQL Client"; ShopifyOrderID: Text[30]; var OrderResponse: JsonToken)
    var
        OrderQueryTok: Label 'query PosReturnOrder($OrderId: ID!) { order(id: $OrderId) { id presentmentCurrencyCode lineItems(first: 250) { nodes { id sku title refundableQuantity variant { id } originalUnitPriceSet { presentmentMoney { amount } } } } refunds(first: 50) { id note totalRefundedSet { presentmentMoney { amount } } } } }', Locked = true;
        Variables: JsonObject;
    begin
        Variables.Add('OrderId', OrderGID(ShopifyOrderID));
        Execute(SpfyTask, GraphQLClient, OrderQueryTok, Variables, OrderResponse);
    end;

    procedure OrderExists(OrderResponse: JsonToken): Boolean
    var
        Order: JsonToken;
    begin
        if not OrderResponse.SelectToken('data.order', Order) then
            exit(false);
        exit(Order.IsObject());
    end;

    procedure FindRefundByNote(OrderResponse: JsonToken; NoteMarker: Text; var RefundedAmount: Decimal): Text[30]
    var
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        Refunds: JsonToken;
        Refund: JsonToken;
        Note: Text;
    begin
        RefundedAmount := 0;
        if not OrderResponse.SelectToken('data.order.refunds', Refunds) then
            exit('');
        foreach Refund in Refunds.AsArray() do begin
            Note := _JsonHelper.GetJText(Refund, 'note', false);
            if (Note = NoteMarker) or Note.StartsWith(NoteMarker + ':') then begin
                RefundedAmount := _JsonHelper.GetJDecimal(Refund, 'totalRefundedSet.presentmentMoney.amount', false);
                exit(CopyStr(SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(Refund, 'id', false), '/'), 1, 30));
            end;
        end;
        exit('');
    end;

    procedure PresentmentCurrency(OrderResponse: JsonToken): Code[3]
    begin
        exit(CopyStr(_JsonHelper.GetJText(OrderResponse, 'data.order.presentmentCurrencyCode', false), 1, 3));
    end;

    /// <summary>
    /// Sets each return line's Refund Quantity and fills LineItemQuantities with the quantity to refund per Shopify line item id.
    /// A line takes one line item that covers its whole quantity when there is one, so it keeps to its own sale line; otherwise it takes what is left on every matching line item, because the sale sync sends each POS line as its own line item and the same variant can appear on several.
    /// </summary>
    procedure MatchLineItems(OrderResponse: JsonToken; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; ShopifyStoreCode: Code[20]; var LineItemQuantities: Dictionary of [Text, Integer])
    var
        SpfyItemMgt: Codeunit "NPR Spfy Item Mgt.";
        LineItems: JsonToken;
        LineItem: JsonToken;
        Remaining: Dictionary of [Text, Integer];
        LineItemID: Text;
        WantedVariantGID: Text;
        WantedSku: Text;
    begin
        Clear(LineItemQuantities);
        if not OrderResponse.SelectToken('data.order.lineItems.nodes', LineItems) then
            exit;
        foreach LineItem in LineItems.AsArray() do
            Remaining.Add(_JsonHelper.GetJText(LineItem, 'id', false), _JsonHelper.GetJInteger(LineItem, 'refundableQuantity', false));

        if ReturnLineBuf.FindSet() then
            repeat
                ReturnLineBuf."Refund Quantity" := 0;
                if ReturnLineBuf."Is Item Line" then begin
                    WantedVariantGID := SpfyItemMgt.GetAssignedShopifyVariantID(ReturnLineBuf."Item No.", ReturnLineBuf."Variant Code", ShopifyStoreCode, false);
                    if WantedVariantGID <> '' then
                        WantedVariantGID := 'gid://shopify/ProductVariant/' + WantedVariantGID;
                    WantedSku := SpfyItemMgt.GetProductVariantSku(ReturnLineBuf."Item No.", ReturnLineBuf."Variant Code");
                end else begin
                    WantedVariantGID := '';
                    WantedSku := '';
                end;
                LineItemID := '';
                foreach LineItem in LineItems.AsArray() do
                    if LineItemID = '' then
                        if Remaining.Get(_JsonHelper.GetJText(LineItem, 'id', false)) >= ReturnLineBuf.Quantity then
                            if LineItemMatches(LineItem, ReturnLineBuf, WantedVariantGID, WantedSku) then
                                LineItemID := _JsonHelper.GetJText(LineItem, 'id', false);
                if LineItemID <> '' then
                    Allocate(LineItemID, ReturnLineBuf.Quantity, ReturnLineBuf, Remaining, LineItemQuantities)
                else
                    foreach LineItem in LineItems.AsArray() do
                        if ReturnLineBuf."Refund Quantity" < ReturnLineBuf.Quantity then
                            if Remaining.Get(_JsonHelper.GetJText(LineItem, 'id', false)) > 0 then
                                if LineItemMatches(LineItem, ReturnLineBuf, WantedVariantGID, WantedSku) then
                                    Allocate(_JsonHelper.GetJText(LineItem, 'id', false), ReturnLineBuf.Quantity - ReturnLineBuf."Refund Quantity", ReturnLineBuf, Remaining, LineItemQuantities);
                ReturnLineBuf.Modify();
            until ReturnLineBuf.Next() = 0;
    end;

    local procedure Allocate(LineItemID: Text; Wanted: Integer; var ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; var Remaining: Dictionary of [Text, Integer]; var LineItemQuantities: Dictionary of [Text, Integer])
    var
        Take: Integer;
    begin
        Take := Wanted;
        if Take > Remaining.Get(LineItemID) then
            Take := Remaining.Get(LineItemID);
        Remaining.Set(LineItemID, Remaining.Get(LineItemID) - Take);
        ReturnLineBuf."Refund Quantity" += Take;
        if LineItemQuantities.ContainsKey(LineItemID) then
            LineItemQuantities.Set(LineItemID, LineItemQuantities.Get(LineItemID) + Take)
        else
            LineItemQuantities.Add(LineItemID, Take);
    end;

    // A non-item line is found by title and price. An order sent before line discounts were sent carries the original unit price; a later one the price after
    // discount, split into two line items one rounding step apart when the line does not divide evenly.
    local procedure LineItemMatches(LineItem: JsonToken; ReturnLineBuf: Record "NPR Spfy POS Return Line Buf." temporary; WantedVariantGID: Text; WantedSku: Text): Boolean
    var
        LineItemPrice: Decimal;
    begin
        if ReturnLineBuf."Is Item Line" then begin
            if (WantedVariantGID <> '') and (_JsonHelper.GetJText(LineItem, 'variant.id', false) = WantedVariantGID) then
                exit(true);
            exit((WantedSku <> '') and (_JsonHelper.GetJText(LineItem, 'sku', false) = WantedSku));
        end;
        if _JsonHelper.GetJText(LineItem, 'title', false) <> ReturnLineBuf."Line Title" then
            exit(false);
        LineItemPrice := _JsonHelper.GetJDecimal(LineItem, 'originalUnitPriceSet.presentmentMoney.amount', false);
        exit(LineItemPrice in [ReturnLineBuf."Unit Price", ReturnLineBuf."Line Item Price", ReturnLineBuf."Line Item Price 2"]);
    end;

    procedure QuerySuggestedRefund(var SpfyTask: Record "NPR Spfy Task"; GraphQLClient: Interface "NPR Spfy IGraphQL Client"; ShopifyOrderID: Text[30]; LineItemQuantities: Dictionary of [Text, Integer]; var SuggestResponse: JsonToken)
    var
        SuggestQueryTok: Label 'query PosReturnSuggest($OrderId: ID!, $Lines: [RefundLineItemInput!]) { order(id: $OrderId) { suggestedRefund(refundLineItems: $Lines) { amountSet { presentmentMoney { amount } } suggestedTransactions { gateway amountSet { presentmentMoney { amount } } maximumRefundableSet { presentmentMoney { amount } } parentTransaction { id } } } } }', Locked = true;
        Variables: JsonObject;
    begin
        Variables.Add('OrderId', OrderGID(ShopifyOrderID));
        Variables.Add('Lines', RefundLineItemsArray(LineItemQuantities, false));
        Execute(SpfyTask, GraphQLClient, SuggestQueryTok, Variables, SuggestResponse);
    end;

    // What the order's transactions can still pay back of RequestedAmount; zero means a refund must not be sent (it would book a refund discrepancy instead).
    procedure AllocatableAmount(ShopifyOrderID: Text[30]; SuggestResponse: JsonToken; RequestedAmount: Decimal; AmountRoundingPrecision: Decimal) AllocatedAmount: Decimal
    begin
        TransactionsArray(ShopifyOrderID, SuggestResponse, RequestedAmount, AmountRoundingPrecision, AllocatedAmount);
    end;

    procedure SendRefund(var SpfyTask: Record "NPR Spfy Task"; GraphQLClient: Interface "NPR Spfy IGraphQL Client"; ShopifyOrderID: Text[30]; LineItemQuantities: Dictionary of [Text, Integer]; SuggestResponse: JsonToken; RequestedAmount: Decimal; AmountRoundingPrecision: Decimal; Currency: Code[3]; Note: Text; var RefundID: Text[30]; var RefundedAmount: Decimal; var UserErrorText: Text): Boolean
    var
        RefundIdempotentMutationTok: Label 'mutation PosReturnRefundIdem($input: RefundInput!, $key: String!) { refundCreate(input: $input) @idempotent(key: $key) { userErrors { field message } refund { id totalRefundedSet { presentmentMoney { amount } } } } }', Locked = true;
        RefundMutationTok: Label 'mutation PosReturnRefund($input: RefundInput!) { refundCreate(input: $input) { userErrors { field message } refund { id totalRefundedSet { presentmentMoney { amount } } } } }', Locked = true;
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        Variables: JsonObject;
        Input: JsonObject;
        Response: JsonToken;
        UserErrors: JsonToken;
    begin
        RefundID := '';
        RefundedAmount := 0;
        UserErrorText := '';
        Input.Add('orderId', OrderGID(ShopifyOrderID));
        Input.Add('note', Note);
        Input.Add('notify', false);
        Input.Add('currency', Currency);
        Input.Add('refundLineItems', RefundLineItemsArray(LineItemQuantities, true));
        Input.Add('transactions', TransactionsArray(ShopifyOrderID, SuggestResponse, RequestedAmount, AmountRoundingPrecision, RefundedAmount));
        Variables.Add('input', Input);
        // Never resent on a server error: Shopify may have created the refund already, and below API 2026-04 the mutation carries no idempotency key. The next attempt adopts it by its note.
        if SpfyIntegrationMgt.ShopifyApiVersionIsAtLeast('2026-04') then begin
            Variables.Add('key', LowerCase(DelChr(Format(CreateGuid()), '=', '{}')));
            if not TryExecute(SpfyTask, GraphQLClient, RefundIdempotentMutationTok, Variables, false, Response) then
                exit(false);
        end else
            if not TryExecute(SpfyTask, GraphQLClient, RefundMutationTok, Variables, false, Response) then
                exit(false);

        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(Response, UserErrors) then begin
            UserErrorText := UserErrorMessages(UserErrors);
            RefundedAmount := 0;
            exit(true);
        end;
        RefundID := CopyStr(SpfyIntegrationMgt.RemoveUntil(_JsonHelper.GetJText(Response, 'data.refundCreate.refund.id', true), '/'), 1, 30);
        RefundedAmount := _JsonHelper.GetJDecimal(Response, 'data.refundCreate.refund.totalRefundedSet.presentmentMoney.amount', false);
        exit(true);
    end;

    local procedure RefundLineItemsArray(LineItemQuantities: Dictionary of [Text, Integer]; WithRestockType: Boolean) Lines: JsonArray
    var
        Line: JsonObject;
        LineItemID: Text;
    begin
        foreach LineItemID in LineItemQuantities.Keys() do begin
            Clear(Line);
            Line.Add('lineItemId', LineItemID);
            Line.Add('quantity', LineItemQuantities.Get(LineItemID));
            if WithRestockType then
                Line.Add('restockType', 'NO_RESTOCK');
            Lines.Add(Line);
        end;
    end;

    local procedure UserErrorMessages(UserErrors: JsonToken) Messages: Text
    var
        UserError: JsonToken;
        Message: Text;
    begin
        foreach UserError in UserErrors.AsArray() do begin
            Message := _JsonHelper.GetJText(UserError, 'message', false);
            if Message <> '' then
                if Messages = '' then
                    Messages := Message
                else
                    Messages += ' ' + Message;
        end;
        // A refusal must never read as a success, so a user error without a message keeps Shopify's own text.
        if Messages = '' then
            UserErrors.WriteTo(Messages);
    end;

    // One REFUND transaction per suggested parent, each capped by that parent's maximum refundable amount; the sum is what is actually requested.
    local procedure TransactionsArray(ShopifyOrderID: Text[30]; SuggestResponse: JsonToken; RequestedAmount: Decimal; AmountRoundingPrecision: Decimal; var AllocatedAmount: Decimal) Transactions: JsonArray
    var
        Suggested: JsonToken;
        SuggestedTransaction: JsonToken;
        Transaction: JsonObject;
        Remaining: Decimal;
        Amount: Decimal;
        MaxRefundable: Decimal;
    begin
        AllocatedAmount := 0;
        Remaining := RequestedAmount;
        if not SuggestResponse.SelectToken('data.order.suggestedRefund.suggestedTransactions', Suggested) then
            exit;
        foreach SuggestedTransaction in Suggested.AsArray() do begin
            if Remaining <= 0 then
                exit;
            MaxRefundable := _JsonHelper.GetJDecimal(SuggestedTransaction, 'maximumRefundableSet.presentmentMoney.amount', false);
            Amount := Remaining;
            // Rounded down, since Shopify may hold more decimals than the POS currency and the request must stay within the cap.
            if Amount > MaxRefundable then
                Amount := Round(MaxRefundable, AmountRoundingPrecision, '<');
            if Amount > 0 then begin
                Clear(Transaction);
                Transaction.Add('orderId', OrderGID(ShopifyOrderID));
                Transaction.Add('parentId', _JsonHelper.GetJText(SuggestedTransaction, 'parentTransaction.id', true));
                Transaction.Add('kind', 'REFUND');
                Transaction.Add('gateway', _JsonHelper.GetJText(SuggestedTransaction, 'gateway', true));
                Transaction.Add('amount', FormatAmount(Amount, AmountRoundingPrecision));
                Transactions.Add(Transaction);
                AllocatedAmount += Amount;
                Remaining -= Amount;
            end;
        end;
    end;

    // Written with as many decimals as the currency's rounding precision has, so a currency without decimals gets none.
    local procedure FormatAmount(Amount: Decimal; AmountRoundingPrecision: Decimal): Text
    var
        Step: Decimal;
        Decimals: Integer;
        FormatTok: Label '<Precision,%1:%1><Standard Format,9>', Locked = true;
    begin
        Step := AmountRoundingPrecision;
        while (Step > 0) and (Step < 1) and (Decimals < 5) do begin
            Step := Step * 10;
            Decimals += 1;
        end;
        exit(Format(Amount, 0, StrSubstNo(FormatTok, Decimals)));
    end;

    // Queries only: a query is safe to resend on a server error.
    local procedure Execute(var SpfyTask: Record "NPR Spfy Task"; GraphQLClient: Interface "NPR Spfy IGraphQL Client"; Query: Text; Variables: JsonObject; var Response: JsonToken)
    begin
        if not TryExecute(SpfyTask, GraphQLClient, Query, Variables, true, Response) then
            Error(GetLastErrorText());
    end;

    local procedure TryExecute(var SpfyTask: Record "NPR Spfy Task"; GraphQLClient: Interface "NPR Spfy IGraphQL Client"; Query: Text; Variables: JsonObject; ResendOnServerError: Boolean; var Response: JsonToken): Boolean
    var
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
    begin
        Clear(SpfyTask."Data Output");
        SpfyCommunicationHandler.CompleteGraphQLRequest(Query, Variables, SpfyTask);
        ClearLastError();
        exit(GraphQLClient.ExecuteRequest(SpfyTask, true, ResendOnServerError, Response));
    end;

    local procedure OrderGID(ShopifyOrderID: Text[30]): Text
    begin
        exit('gid://shopify/Order/' + ShopifyOrderID);
    end;
}

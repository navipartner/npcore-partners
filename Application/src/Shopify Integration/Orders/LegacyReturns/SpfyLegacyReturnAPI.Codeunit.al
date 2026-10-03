codeunit 6151148 "NPR Spfy Legacy Return API"
{
    Access = Internal;

    var
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _GraphQLClientSet: Boolean;
        _JsonHelper: Codeunit "NPR Json Helper";
        _OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        _SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        _ReturnDetailRequest: Label 'query GetReturn($OrderId: ID!) { return(id: $OrderId) { id name status closedAt exchangeLineItems(first: 1) { edges { node { id } } } order { id name number email phone sourceName taxesIncluded currencyCode presentmentCurrencyCode customer { id firstName lastName defaultEmailAddress { emailAddress } defaultPhoneNumber { phoneNumber } defaultAddress { phone } } billingAddress { firstName lastName company countryCodeV2 zip address1 address2 city } shippingAddress { firstName lastName company address1 address2 zip city countryCodeV2 phone } } returnShippingFees { amountSet { presentmentMoney { amount } } } returnLineItems(first: 100) { pageInfo { hasNextPage } edges { node { id quantity ... on ReturnLineItem { restockingFee { amountSet { presentmentMoney { amount } } } fulfillmentLineItem { id lineItem { id sku title isGiftCard customAttributes { key value } variant { id sku barcode } } } } } } } reverseFulfillmentOrders(first: 50) { pageInfo { hasNextPage } edges { node { lineItems(first: 100) { pageInfo { hasNextPage } edges { node { fulfillmentLineItem { id } dispositions { type location { id } quantity } } } } } } } refunds(first: 50) { pageInfo { hasNextPage } edges { node { id transactions(first: 50) { pageInfo { hasNextPage } edges { node { id kind status gateway processedAt createdAt paymentId receiptJson paymentDetails { ... on CardPaymentDetails { company } } amountSet { presentmentMoney { amount currencyCode } shopMoney { amount currencyCode } } } } } refundLineItems(first: 100) { pageInfo { hasNextPage } edges { node { quantity subtotalSet { presentmentMoney { amount } } totalTaxSet { presentmentMoney { amount } } lineItem { id taxLines { ratePercentage } } } } } refundShippingLines(first: 20) { pageInfo { hasNextPage } edges { node { subtotalAmountSet { presentmentMoney { amount } } taxAmountSet { presentmentMoney { amount } } } } } orderAdjustments(first: 50) { pageInfo { hasNextPage } edges { node { amountSet { presentmentMoney { amount } } taxAmountSet { presentmentMoney { amount } } reason } } } } } } } }', Locked = true;
        _ReturnNotFoundErr: Label 'Shopify did not return any data for return %1 of %2 %3.', Comment = '%1 = Shopify return id, %2 = Shopify Store table caption, %3 = Shopify store code';
        _TruncatedErr: Label 'Return %1 has more %2 than one request reads, so its amounts cannot be calculated reliably. Handle the return manually.', Comment = '%1 = Shopify return id, %2 = name of the truncated connection';
        _BadAmountErr: Label 'Shopify return %1 carries a value in %2 that is not a number. This is a programming bug.', Locked = true;
        _RefundLineUnmatchedErr: Label 'Shopify return %1 refunds order line item %2, which is not among the returned lines, so the refunded amount cannot be placed on a return line. Handle this return manually.', Comment = '%1 = Shopify return name, %2 = Shopify order line item id';
        _ZeroQuantityLineErr: Label 'Shopify return %1 returns line item %2 with no quantity, so no return line can be built for it. Handle this return manually.', Comment = '%1 = Shopify return name, %2 = Shopify order line item id';
        _UnrefundedQuantityErr: Label 'Shopify return %1 returns %2 units of %3 but refunds only %4 of them, so one document cannot carry both the goods and the refund. Handle this return manually.', Comment = '%1 = Shopify return name, %2 = returned quantity, %3 = SKU, or the title for a line without one, %4 = refunded quantity';
        _UnsupportedLineErr: Label 'Shopify return %1 contains a line with no order line behind it, typically a fee or a line added by hand. Only returned order lines are imported; handle this return manually.', Comment = '%1 = Shopify return name';
        _ReturnGidTok: Label 'gid://shopify/Return/%1', Locked = true;

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

    internal procedure GetReturnDetail(ShopifyStoreCode: Code[20]; ReturnId: Text[30]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        NcTask: Record "NPR Nc Task";
        ShopifyStore: Record "NPR Spfy Store";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        Response: JsonToken;
    begin
        Clear(NcTask);
        ClearLastError();
        SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, '', ShopifyStoreCode, _ReturnDetailRequest, StrSubstNo(_ReturnGidTok, ReturnId), false);
        if not GetGraphQLClient().ExecuteRequest(NcTask, false, Response) then
            Error(GetLastErrorText());
        ParseReturnDetail(ShopifyStoreCode, ReturnId, Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
        if not TempReturnBuffer.Get(ReturnId) then
            Error(_ReturnNotFoundErr, ReturnId, ShopifyStore.TableCaption(), ShopifyStoreCode);
    end;

    internal procedure ParseReturnDetail(ShopifyStoreCode: Code[20]; ReturnId: Text[30]; Response: JsonToken; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        ReturnToken: JsonToken;
        OrderToken: JsonToken;
        TaxesIncluded: Boolean;
    begin
        TempReturnBuffer.Reset();
        TempReturnBuffer.DeleteAll();
        TempLineBuffer.Reset();
        TempLineBuffer.DeleteAll();
        TempRefundTxnBuffer.Reset();
        TempRefundTxnBuffer.DeleteAll();

        if not Response.SelectToken('data.return', ReturnToken) then
            exit;
        if not ReturnToken.IsObject() then
            exit;
        CheckNotTruncated(ReturnId, ReturnToken);

        TempReturnBuffer.Init();
        TempReturnBuffer."Return Id" := ReturnId;
        TempReturnBuffer."Return Name" := CopyStr(_JsonHelper.GetJText(ReturnToken, 'name', false), 1, MaxStrLen(TempReturnBuffer."Return Name"));
        TempReturnBuffer."Closed At" := _JsonHelper.GetJDT(ReturnToken, 'closedAt', false);
        TempReturnBuffer.Status := CopyStr(_JsonHelper.GetJText(ReturnToken, 'status', false).ToUpper(), 1, MaxStrLen(TempReturnBuffer.Status));
        TempReturnBuffer."Has Exchange Line" := ArrayCount(ReturnToken, 'exchangeLineItems.edges') > 0;
        // Every amount rule and the customer depend on the order, so a detail without one is refused.
        OrderToken := _JsonHelper.GetJsonToken(ReturnToken, 'order');
        TempReturnBuffer."Order Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(OrderToken, 'id', true));
        TempReturnBuffer."Order Name" := CopyStr(_JsonHelper.GetJText(OrderToken, 'name', false), 1, MaxStrLen(TempReturnBuffer."Order Name"));
        TempReturnBuffer."Order No." := CopyStr(_JsonHelper.GetJText(OrderToken, 'number', false), 1, MaxStrLen(TempReturnBuffer."Order No."));
        TempReturnBuffer."Source Name" := CopyStr(_JsonHelper.GetJText(OrderToken, 'sourceName', false), 1, MaxStrLen(TempReturnBuffer."Source Name"));
        TempReturnBuffer."Presentment Currency Code" := CopyStr(_JsonHelper.GetJText(OrderToken, 'presentmentCurrencyCode', false), 1, MaxStrLen(TempReturnBuffer."Presentment Currency Code"));
        TempReturnBuffer.SetOrderJson(OrderToken);
        TaxesIncluded := _JsonHelper.GetJBoolean(OrderToken, 'taxesIncluded', true);
        TempReturnBuffer."Shipping Refund Amount" := SumRefundShippingLines(ReturnId, ReturnToken);
        SumFees(ReturnId, ReturnToken, TaxesIncluded, TempReturnBuffer."Fee Amount", TempReturnBuffer."Refund Beyond Lines Amount");
        TempReturnBuffer.Insert();

        ParseLines(ReturnId, ReturnToken, TempLineBuffer);
        ApplyDispositions(ReturnToken, TempLineBuffer);
        ApplyRefundLineAmounts(ShopifyStoreCode, ReturnId, ReturnToken, TempReturnBuffer."Presentment Currency Code", TaxesIncluded, (TempReturnBuffer.Status = 'CLOSED') and not TempReturnBuffer."Has Exchange Line", TempLineBuffer);
        ParseRefundTransactions(ReturnId, ReturnToken, TempRefundTxnBuffer);
    end;

    local procedure CheckNotTruncated(ReturnId: Text[30]; ReturnToken: JsonToken)
    var
        RefundsToken: JsonToken;
        RefundEdge: JsonToken;
        ReverseOrdersToken: JsonToken;
        ReverseOrderEdge: JsonToken;
    begin
        if HasNextPage(ReturnToken, 'returnLineItems') then
            Error(_TruncatedErr, ReturnId, 'returnLineItems');
        if HasNextPage(ReturnToken, 'reverseFulfillmentOrders') then
            Error(_TruncatedErr, ReturnId, 'reverseFulfillmentOrders');
        if ReturnToken.SelectToken('reverseFulfillmentOrders.edges', ReverseOrdersToken) then
            foreach ReverseOrderEdge in ReverseOrdersToken.AsArray() do
                if HasNextPage(ReverseOrderEdge, 'node.lineItems') then
                    Error(_TruncatedErr, ReturnId, 'reverseFulfillmentOrders.lineItems');
        if HasNextPage(ReturnToken, 'refunds') then
            Error(_TruncatedErr, ReturnId, 'refunds');
        if ReturnToken.SelectToken('refunds.edges', RefundsToken) then
            foreach RefundEdge in RefundsToken.AsArray() do begin
                if HasNextPage(RefundEdge, 'node.transactions') then
                    Error(_TruncatedErr, ReturnId, 'refunds.transactions');
                if HasNextPage(RefundEdge, 'node.refundLineItems') then
                    Error(_TruncatedErr, ReturnId, 'refunds.refundLineItems');
                if HasNextPage(RefundEdge, 'node.refundShippingLines') then
                    Error(_TruncatedErr, ReturnId, 'refunds.refundShippingLines');
                if HasNextPage(RefundEdge, 'node.orderAdjustments') then
                    Error(_TruncatedErr, ReturnId, 'refunds.orderAdjustments');
            end;
    end;

    local procedure HasNextPage(Token: JsonToken; ConnectionPath: Text): Boolean
    var
        ConnectionToken: JsonToken;
    begin
        if not Token.SelectToken(ConnectionPath, ConnectionToken) then
            exit(false);
        exit(_JsonHelper.GetJBoolean(ConnectionToken, 'pageInfo.hasNextPage', false));
    end;

    local procedure ArrayCount(Token: JsonToken; ArrayPath: Text): Integer
    var
        ArrayToken: JsonToken;
    begin
        if not Token.SelectToken(ArrayPath, ArrayToken) then
            exit(0);
        if not ArrayToken.IsArray() then
            exit(0);
        exit(ArrayToken.AsArray().Count());
    end;

    local procedure GetAmount(ReturnId: Text[30]; Token: JsonToken; Path: Text): Decimal
    var
        Amount: Decimal;
        AmountText: Text;
    begin
        AmountText := _JsonHelper.GetJText(Token, Path, false);
        if AmountText = '' then
            exit(0);
        if not Evaluate(Amount, AmountText, 9) then
            Error(_BadAmountErr, ReturnId, Path);
        exit(Amount);
    end;

    local procedure ParseLines(ReturnId: Text[30]; ReturnToken: JsonToken; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        EdgesToken: JsonToken;
        Edge: JsonToken;
        LineItemToken: JsonToken;
        LineNo: Integer;
        Sku: Text;
    begin
        if not ReturnToken.SelectToken('returnLineItems.edges', EdgesToken) then
            exit;
        foreach Edge in EdgesToken.AsArray() do begin
            LineNo += 10000;
            TempLineBuffer.Init();
            TempLineBuffer."Return Id" := ReturnId;
            TempLineBuffer."Line No." := LineNo;
            TempLineBuffer.Quantity := GetAmount(ReturnId, Edge, 'node.quantity');
            TempLineBuffer."Fulfillment Line Item Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(Edge, 'node.fulfillmentLineItem.id', false));
            if Edge.SelectToken('node.fulfillmentLineItem.lineItem', LineItemToken) then begin
                TempLineBuffer."Order Line Item Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(LineItemToken, 'id', false));
                // The order line's SKU is the one the item was sold and imported under; the variant's SKU may have changed since.
                Sku := _JsonHelper.GetJText(LineItemToken, 'sku', false);
                if Sku = '' then
                    Sku := _JsonHelper.GetJText(LineItemToken, 'variant.sku', false);
                TempLineBuffer.SKU := CopyStr(Sku, 1, MaxStrLen(TempLineBuffer.SKU));
                TempLineBuffer.Title := CopyStr(_JsonHelper.GetJText(LineItemToken, 'title', false), 1, MaxStrLen(TempLineBuffer.Title));
                TempLineBuffer.SetLineItemJson(LineItemToken);
                TempLineBuffer."Gift Card" := _SpfyOrderApiHelper.OrderLineIsGiftCard(LineItemToken);
            end;
            // An unverified return line has no order line behind it, so no document line, refund share or quantity check can be built for it.
            if TempLineBuffer."Order Line Item Id" = '' then
                Error(_UnsupportedLineErr, _JsonHelper.GetJText(ReturnToken, 'name', false));
            if TempLineBuffer.Quantity <= 0 then
                Error(_ZeroQuantityLineErr, _JsonHelper.GetJText(ReturnToken, 'name', false), TempLineBuffer."Order Line Item Id");
            TempLineBuffer.Insert();
        end;
    end;

    local procedure ApplyDispositions(ReturnToken: JsonToken; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        OrdersToken: JsonToken;
        OrderEdge: JsonToken;
        LinesToken: JsonToken;
        LineEdge: JsonToken;
        DispositionsToken: JsonToken;
        Disposition: JsonToken;
        FulfillmentLineItemId: Text[30];
    begin
        // The first RESTOCKED disposition sets the location; any other disposition marks the line Not Restocked.
        if not ReturnToken.SelectToken('reverseFulfillmentOrders.edges', OrdersToken) then
            exit;
        foreach OrderEdge in OrdersToken.AsArray() do
            if OrderEdge.SelectToken('node.lineItems.edges', LinesToken) then
                foreach LineEdge in LinesToken.AsArray() do begin
                    FulfillmentLineItemId := _OrderMgt.GetNumericId(_JsonHelper.GetJText(LineEdge, 'node.fulfillmentLineItem.id', false));
                    TempLineBuffer.Reset();
                    TempLineBuffer.SetRange("Fulfillment Line Item Id", FulfillmentLineItemId);
                    if TempLineBuffer.FindSet() then
                        repeat
                            if LineEdge.SelectToken('node.dispositions', DispositionsToken) then
                                foreach Disposition in DispositionsToken.AsArray() do
                                    if _JsonHelper.GetJText(Disposition, 'type', false).ToUpper() = 'RESTOCKED' then begin
                                        if TempLineBuffer."Disposition Location Id" = '' then
                                            TempLineBuffer."Disposition Location Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(Disposition, 'location.id', false));
                                    end else
                                        TempLineBuffer."Not Restocked" := true;
                            TempLineBuffer.Modify();
                        until TempLineBuffer.Next() = 0;
                end;
        TempLineBuffer.Reset();
    end;

    local procedure ApplyRefundLineAmounts(ShopifyStoreCode: Code[20]; ReturnId: Text[30]; ReturnToken: JsonToken; PresentmentCurrencyCode: Text; TaxesIncluded: Boolean; QuantitiesMustMatch: Boolean; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        RefundsToken: JsonToken;
        RefundEdge: JsonToken;
        RefundLinesToken: JsonToken;
        RefundLineEdge: JsonToken;
        TaxLinesToken: JsonToken;
        TaxLine: JsonToken;
        RefundedQuantities: Dictionary of [Text, Decimal];
        OrderLineItemId: Text[30];
        Gross: Decimal;
        VatRate: Decimal;
        RefundedQuantity: Decimal;
    begin
        if not ReturnToken.SelectToken('refunds.edges', RefundsToken) then
            exit;
        // No refund at all is the "refund made on the order" case, which the total check names more precisely.
        if RefundsToken.AsArray().Count() = 0 then
            exit;
        foreach RefundEdge in RefundsToken.AsArray() do
            if RefundEdge.SelectToken('node.refundLineItems.edges', RefundLinesToken) then
                foreach RefundLineEdge in RefundLinesToken.AsArray() do begin
                    OrderLineItemId := _OrderMgt.GetNumericId(_JsonHelper.GetJText(RefundLineEdge, 'node.lineItem.id', false));
                    RefundedQuantity := 0;
                    if RefundedQuantities.ContainsKey(OrderLineItemId) then
                        RefundedQuantity := RefundedQuantities.Get(OrderLineItemId);
                    RefundedQuantities.Set(OrderLineItemId, RefundedQuantity + GetAmount(ReturnId, RefundLineEdge, 'node.quantity'));
                    Gross := GrossAmount(ReturnId, RefundLineEdge, 'node.subtotalSet.presentmentMoney.amount', 'node.totalTaxSet.presentmentMoney.amount', TaxesIncluded);
                    VatRate := 0;
                    if RefundLineEdge.SelectToken('node.lineItem.taxLines', TaxLinesToken) then
                        foreach TaxLine in TaxLinesToken.AsArray() do
                            VatRate += GetAmount(ReturnId, TaxLine, 'ratePercentage');
                    DistributeRefundLineGross(ShopifyStoreCode, ReturnToken, OrderLineItemId, Gross, VatRate, PresentmentCurrencyCode, TempLineBuffer);
                end;
        // A return that is not closed or carries an exchange is refused by the import with its own message.
        if QuantitiesMustMatch then
            CheckRefundedQuantities(ReturnToken, RefundedQuantities, TempLineBuffer);
        TempLineBuffer.Reset();
    end;

    /// <summary>
    /// Shopify closes a return once it is marked returned, before or without a full refund; a line refunded for fewer units than it returns is refused.
    /// </summary>
    local procedure CheckRefundedQuantities(ReturnToken: JsonToken; RefundedQuantities: Dictionary of [Text, Decimal]; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        ReturnedQuantities: Dictionary of [Text, Decimal];
        OrderLineItemId: Text;
        LineName: Text;
        Returned: Decimal;
        Refunded: Decimal;
    begin
        TempLineBuffer.Reset();
        if TempLineBuffer.FindSet() then
            repeat
                Returned := 0;
                if ReturnedQuantities.ContainsKey(TempLineBuffer."Order Line Item Id") then
                    Returned := ReturnedQuantities.Get(TempLineBuffer."Order Line Item Id");
                ReturnedQuantities.Set(TempLineBuffer."Order Line Item Id", Returned + TempLineBuffer.Quantity);
            until TempLineBuffer.Next() = 0;
        foreach OrderLineItemId in ReturnedQuantities.Keys() do begin
            Refunded := 0;
            if RefundedQuantities.ContainsKey(OrderLineItemId) then
                Refunded := RefundedQuantities.Get(OrderLineItemId);
            if Refunded < ReturnedQuantities.Get(OrderLineItemId) then begin
                TempLineBuffer.SetRange("Order Line Item Id", OrderLineItemId);
                TempLineBuffer.FindFirst();
                LineName := TempLineBuffer.SKU;
                if LineName = '' then
                    LineName := TempLineBuffer.Title;
                Error(_UnrefundedQuantityErr, _JsonHelper.GetJText(ReturnToken, 'name', false), ReturnedQuantities.Get(OrderLineItemId), LineName, Refunded);
            end;
        end;
    end;

    local procedure DistributeRefundLineGross(ShopifyStoreCode: Code[20]; ReturnToken: JsonToken; OrderLineItemId: Text[30]; Gross: Decimal; VatRate: Decimal; PresentmentCurrencyCode: Text; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        TotalQuantity: Decimal;
        Remaining: Decimal;
        Share: Decimal;
        RoundingPrecision: Decimal;
        RowCount: Integer;
        RowsLeft: Integer;
    begin
        // An order line shipped in parcels returns as one line per parcel: share the gross by quantity, rounded down, remainder on the last.
        TempLineBuffer.Reset();
        TempLineBuffer.SetRange("Order Line Item Id", OrderLineItemId);
        if TempLineBuffer.IsEmpty() then
            Error(_RefundLineUnmatchedErr, _JsonHelper.GetJText(ReturnToken, 'name', false), OrderLineItemId);
        TempLineBuffer.CalcSums(Quantity);
        TotalQuantity := TempLineBuffer.Quantity;
        RowCount := TempLineBuffer.Count();
        RowsLeft := RowCount;
        if RowCount > 1 then
            RoundingPrecision := AmountRoundingPrecision(ShopifyStoreCode, PresentmentCurrencyCode);
        Remaining := Gross;
        TempLineBuffer.FindSet();
        repeat
            RowsLeft -= 1;
            if RowsLeft = 0 then
                Share := Remaining
            else
                Share := RoundTowardZero(Gross * TempLineBuffer.Quantity / TotalQuantity, RoundingPrecision);
            Remaining -= Share;
            TempLineBuffer."Line Amount" += Share;
            if VatRate > 0 then
                TempLineBuffer."VAT %" := VatRate;
            // Rounded up: Sales Line refuses a Line Amount above Quantity * Unit Price.
            TempLineBuffer."Unit Price" := Round(TempLineBuffer."Line Amount" / TempLineBuffer.Quantity, 0.01, '>');
            TempLineBuffer.Modify();
        until TempLineBuffer.Next() = 0;
    end;

    local procedure RoundTowardZero(Value: Decimal; Precision: Decimal): Decimal
    begin
        if Value < 0 then
            exit(Round(Value, Precision, '>'));
        exit(Round(Value, Precision, '<'));
    end;

    local procedure AmountRoundingPrecision(ShopifyStoreCode: Code[20]; PresentmentCurrencyCode: Text): Decimal
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyPaymentGatewayHdlr: Codeunit "NPR Spfy Payment Gateway Hdlr";
        CurrencyCode: Code[10];
        CurrencyIsLCY: Boolean;
    begin
        // Resolved as for the Return Order header, so the shares round like its lines.
        CurrencyCode := SpfyPaymentGatewayHdlr.TranslateCurrencyCode(PresentmentCurrencyCode, SpfyIntegrationMgt.CurrencyBlankForLCY(ShopifyStoreCode), CurrencyIsLCY);
        if CurrencyCode <> '' then
            if Currency.Get(CurrencyCode) then
                if Currency."Amount Rounding Precision" <> 0 then
                    exit(Currency."Amount Rounding Precision");
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Amount Rounding Precision" <> 0 then
            exit(GeneralLedgerSetup."Amount Rounding Precision");
        exit(0.01);
    end;

    local procedure ParseRefundTransactions(ReturnId: Text[30]; ReturnToken: JsonToken; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        RefundsToken: JsonToken;
        RefundEdge: JsonToken;
        TxnsToken: JsonToken;
        TxnEdge: JsonToken;
        LineNo: Integer;
    begin
        if not ReturnToken.SelectToken('refunds.edges', RefundsToken) then
            exit;
        foreach RefundEdge in RefundsToken.AsArray() do
            if RefundEdge.SelectToken('node.transactions.edges', TxnsToken) then
                foreach TxnEdge in TxnsToken.AsArray() do
                    if (_JsonHelper.GetJText(TxnEdge, 'node.kind', false).ToUpper() = 'REFUND') and (_JsonHelper.GetJText(TxnEdge, 'node.status', false).ToUpper() = 'SUCCESS') then begin
                        LineNo += 10000;
                        TempRefundTxnBuffer.Init();
                        TempRefundTxnBuffer."Return Id" := ReturnId;
                        TempRefundTxnBuffer."Line No." := LineNo;
                        TempRefundTxnBuffer.Kind := CopyStr(_JsonHelper.GetJText(TxnEdge, 'node.kind', false), 1, MaxStrLen(TempRefundTxnBuffer.Kind));
                        TempRefundTxnBuffer.Gateway := CopyStr(_JsonHelper.GetJText(TxnEdge, 'node.gateway', false), 1, MaxStrLen(TempRefundTxnBuffer.Gateway));
                        TempRefundTxnBuffer."Transaction Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(TxnEdge, 'node.id', true));
                        TempRefundTxnBuffer."Processed At" := _JsonHelper.GetJDT(TxnEdge, 'node.processedAt', false);
                        TempRefundTxnBuffer."Created At" := _JsonHelper.GetJDT(TxnEdge, 'node.createdAt', false);
                        TempRefundTxnBuffer.Amount := GetAmount(ReturnId, TxnEdge, 'node.amountSet.presentmentMoney.amount');
                        TempRefundTxnBuffer."Amount (Store Currency)" := GetAmount(ReturnId, TxnEdge, 'node.amountSet.shopMoney.amount');
                        TempRefundTxnBuffer."Store Currency Code" := CopyStr(_JsonHelper.GetJText(TxnEdge, 'node.amountSet.shopMoney.currencyCode', false), 1, MaxStrLen(TempRefundTxnBuffer."Store Currency Code"));
                        TempRefundTxnBuffer."Gift Card Id" := GiftCardIdFromReceipt(_JsonHelper.GetJText(TxnEdge, 'node.receiptJson', false));
                        TempRefundTxnBuffer."Credit Card Company" := CopyStr(_JsonHelper.GetJText(TxnEdge, 'node.paymentDetails.company', false), 1, MaxStrLen(TempRefundTxnBuffer."Credit Card Company"));
                        TempRefundTxnBuffer.Insert();
                    end;
    end;

    local procedure GiftCardIdFromReceipt(ReceiptJsonText: Text): Text[30]
    var
        ReceiptToken: JsonToken;
    begin
        // receiptJson is a JSON string that itself contains JSON.
        if ReceiptJsonText = '' then
            exit('');
        if not ReceiptToken.ReadFrom(ReceiptJsonText) then
            exit('');
        exit(_OrderMgt.GetNumericId(_JsonHelper.GetJText(ReceiptToken, 'gift_card_id', false)));
    end;

    /// <summary>
    /// Shopify reports a refunded shipping line net of tax with the tax separate, on taxes-included shops too, so its gross is always subtotal plus tax.
    /// </summary>
    local procedure SumRefundShippingLines(ReturnId: Text[30]; ReturnToken: JsonToken) Total: Decimal
    var
        RefundsToken: JsonToken;
        RefundEdge: JsonToken;
        LinesToken: JsonToken;
        LineEdge: JsonToken;
    begin
        if not ReturnToken.SelectToken('refunds.edges', RefundsToken) then
            exit(0);
        foreach RefundEdge in RefundsToken.AsArray() do
            if RefundEdge.SelectToken('node.refundShippingLines.edges', LinesToken) then
                foreach LineEdge in LinesToken.AsArray() do
                    Total += GetAmount(ReturnId, LineEdge, 'node.subtotalAmountSet.presentmentMoney.amount') + GetAmount(ReturnId, LineEdge, 'node.taxAmountSet.presentmentMoney.amount');
    end;

    local procedure GrossAmount(ReturnId: Text[30]; Token: JsonToken; SubtotalPath: Text; TaxPath: Text; TaxesIncluded: Boolean): Decimal
    begin
        // With taxes included in prices, Shopify's subtotal already contains the tax.
        if TaxesIncluded then
            exit(GetAmount(ReturnId, Token, SubtotalPath));
        exit(GetAmount(ReturnId, Token, SubtotalPath) + GetAmount(ReturnId, Token, TaxPath));
    end;

    /// <summary>
    /// Splits the fees Shopify held back from what it paid out beyond the lines, netting the order adjustments first.
    /// </summary>
    local procedure SumFees(ReturnId: Text[30]; ReturnToken: JsonToken; TaxesIncluded: Boolean; var FeeAmount: Decimal; var RefundBeyondLinesAmount: Decimal)
    var
        ArrToken: JsonToken;
        Edge: JsonToken;
        RefundsToken: JsonToken;
        RefundEdge: JsonToken;
        AdjToken: JsonToken;
        AdjEdge: JsonToken;
        AdjustmentTotal: Decimal;
    begin
        FeeAmount := 0;
        RefundBeyondLinesAmount := 0;
        // Shopify signs an order adjustment: positive is withheld from the customer, negative is paid out on top of the lines.
        if ReturnToken.SelectToken('refunds.edges', RefundsToken) then
            foreach RefundEdge in RefundsToken.AsArray() do
                if RefundEdge.SelectToken('node.orderAdjustments.edges', AdjToken) then
                    foreach AdjEdge in AdjToken.AsArray() do
                        AdjustmentTotal += GrossAmount(ReturnId, AdjEdge, 'node.amountSet.presentmentMoney.amount', 'node.taxAmountSet.presentmentMoney.amount', TaxesIncluded);
        if AdjustmentTotal >= 0 then
            FeeAmount += AdjustmentTotal
        else
            RefundBeyondLinesAmount := -AdjustmentTotal;
        if ReturnToken.SelectToken('returnShippingFees', ArrToken) then
            foreach Edge in ArrToken.AsArray() do
                FeeAmount += Abs(GetAmount(ReturnId, Edge, 'amountSet.presentmentMoney.amount'));
        if ReturnToken.SelectToken('returnLineItems.edges', ArrToken) then
            foreach Edge in ArrToken.AsArray() do
                FeeAmount += Abs(GetAmount(ReturnId, Edge, 'node.restockingFee.amountSet.presentmentMoney.amount'));
    end;
}

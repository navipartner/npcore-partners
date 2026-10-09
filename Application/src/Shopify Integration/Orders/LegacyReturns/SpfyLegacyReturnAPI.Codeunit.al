codeunit 6151148 "NPR Spfy Legacy Return API"
{
    Access = Internal;

    var
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _GraphQLClientSet: Boolean;
        _JsonHelper: Codeunit "NPR Json Helper";
        _OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        _TruncatedErr: Label 'Shopify return or refund %1 has more %2 than one request reads, so its amounts cannot be calculated reliably. Handle it manually.', Comment = '%1 = Shopify return id or refund marker, %2 = name of the truncated connection';
        _ZeroQuantityLineErr: Label 'Shopify %1 has line item %2 with no quantity, so no line can be built for it. Handle it manually.', Comment = '%1 = Shopify document caption, %2 = Shopify order line item id';
        _UnsupportedLineErr: Label 'Shopify %1 contains a line with no order line behind it, typically a fee or a line added by hand. Only order lines are imported; handle it manually.', Comment = '%1 = Shopify document caption';
        _RefundGidTok: Label 'gid://shopify/Refund/%1', Locked = true;
        // Locked: the Sentry filter matches the English text.

    internal procedure SetGraphQLClient(GraphQLClient: Interface "NPR Spfy IGraphQL Client")
    begin
        _GraphQLClient := GraphQLClient;
        _GraphQLClientSet := true;
    end;

    local procedure RunQuery(ShopifyStoreCode: Code[20]; Query: Text; Gid: Text) Response: JsonToken
    var
        NcTask: Record "NPR Nc Task";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
    begin
        ClearLastError();
        SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, '', ShopifyStoreCode, Query, Gid, false);
        if not GetGraphQLClient().ExecuteRequest(NcTask, false, Response) then
            Error(GetLastErrorText());
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

    /// <summary>
    /// How messages name a document: "return #1001-R1" or "refund 1124416454897 of order #1146". A refund has no name of its own, so its row carries the order's.
    /// </summary>
    internal procedure DocumentCaption(SourceType: Enum "NPR Spfy Legacy Return Source"; Name: Text; ShopifyId: Text): Text[50]
    var
        ReturnCaptionLbl: Label 'return %1', Comment = '%1 = Shopify return name';
        RefundCaptionLbl: Label 'refund %1 of order %2', Comment = '%1 = Shopify refund id, %2 = Shopify order name';
    begin
        if SourceType = SourceType::Refund then
            exit(CopyStr(StrSubstNo(RefundCaptionLbl, ShopifyId, Name), 1, 50));
        exit(CopyStr(StrSubstNo(ReturnCaptionLbl, Name), 1, 50));
    end;

    internal procedure GetReturnDetail(ShopifyStoreCode: Code[20]; ReturnId: Text[30]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        ShopifyStore: Record "NPR Spfy Store";
        Response: JsonToken;
        ReturnDetailRequest: Label 'query GetReturn($OrderId: ID!) { return(id: $OrderId) { id name status closedAt exchangeLineItems(first: 1) { edges { node { id } } } order { id name number email phone sourceName taxesIncluded currencyCode presentmentCurrencyCode lineItems(first: 100) { pageInfo { hasNextPage } edges { node { id quantity originalUnitPriceSet { presentmentMoney { amount } } discountAllocations { allocatedAmountSet { presentmentMoney { amount } } } taxLines { ratePercentage } } } } customer { id firstName lastName defaultEmailAddress { emailAddress } defaultPhoneNumber { phoneNumber } defaultAddress { phone } } billingAddress { firstName lastName company countryCodeV2 zip address1 address2 city } shippingAddress { firstName lastName company address1 address2 zip city countryCodeV2 phone } } returnShippingFees { amountSet { presentmentMoney { amount } } } returnLineItems(first: 100) { pageInfo { hasNextPage } edges { node { id quantity ... on ReturnLineItem { restockingFee { amountSet { presentmentMoney { amount } } } fulfillmentLineItem { id lineItem { id sku title isGiftCard customAttributes { key value } variant { id sku barcode } } } } } } } reverseFulfillmentOrders(first: 50) { pageInfo { hasNextPage } edges { node { lineItems(first: 100) { pageInfo { hasNextPage } edges { node { fulfillmentLineItem { id } dispositions { type location { id } quantity } } } } } } } refunds(first: 50) { pageInfo { hasNextPage } edges { node { id transactions(first: 50) { pageInfo { hasNextPage } edges { node { id kind status gateway processedAt createdAt paymentId receiptJson paymentDetails { ... on CardPaymentDetails { company } } amountSet { presentmentMoney { amount currencyCode } shopMoney { amount currencyCode } } } } } refundLineItems(first: 100) { pageInfo { hasNextPage } edges { node { quantity subtotalSet { presentmentMoney { amount } } totalTaxSet { presentmentMoney { amount } } lineItem { id taxLines { ratePercentage } } } } } refundShippingLines(first: 20) { pageInfo { hasNextPage } edges { node { subtotalAmountSet { presentmentMoney { amount } } taxAmountSet { presentmentMoney { amount } } } } } orderAdjustments(first: 50) { pageInfo { hasNextPage } edges { node { amountSet { presentmentMoney { amount } } taxAmountSet { presentmentMoney { amount } } reason } } } } } } } }', Locked = true;
        ReturnNotFoundErr: Label 'Shopify did not return any data for return %1 of %2 %3.', Comment = '%1 = Shopify return id, %2 = Shopify Store table caption, %3 = Shopify store code';
        ReturnGidTok: Label 'gid://shopify/Return/%1', Locked = true;
    begin
        Response := RunQuery(ShopifyStoreCode, ReturnDetailRequest, StrSubstNo(ReturnGidTok, ReturnId));
        ParseReturnDetail(ShopifyStoreCode, ReturnId, Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
        if not TempReturnBuffer.Get(ReturnId) then
            Error(ReturnNotFoundErr, ReturnId, ShopifyStore.TableCaption(), ShopifyStoreCode);
    end;

    internal procedure GetRefundDetail(ShopifyStoreCode: Code[20]; RefundId: Text[30]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        ShopifyStore: Record "NPR Spfy Store";
        Response: JsonToken;
        RefundNotFoundErr: Label 'Shopify did not return any data for refund %1 of %2 %3.', Comment = '%1 = Shopify refund id, %2 = Shopify Store table caption, %3 = Shopify store code';
        RefundDetailRequest: Label 'query GetRefund($OrderId: ID!) { refund(id: $OrderId) { id createdAt processedAt return { id } order { id name number cancelledAt fulfillments(first: 50) { status } email phone sourceName taxesIncluded currencyCode presentmentCurrencyCode lineItems(first: 100) { pageInfo { hasNextPage } edges { node { id quantity originalUnitPriceSet { presentmentMoney { amount } } discountAllocations { allocatedAmountSet { presentmentMoney { amount } } } taxLines { ratePercentage } } } } customer { id firstName lastName defaultEmailAddress { emailAddress } defaultPhoneNumber { phoneNumber } defaultAddress { phone } } billingAddress { firstName lastName company countryCodeV2 zip address1 address2 city } shippingAddress { firstName lastName company address1 address2 zip city countryCodeV2 phone } } refundLineItems(first: 100) { pageInfo { hasNextPage } edges { node { quantity restockType restocked location { id } subtotalSet { presentmentMoney { amount } } totalTaxSet { presentmentMoney { amount } } lineItem { id quantity sku title isGiftCard customAttributes { key value } variant { id sku barcode } taxLines { ratePercentage } } } } } refundShippingLines(first: 20) { pageInfo { hasNextPage } edges { node { subtotalAmountSet { presentmentMoney { amount } } taxAmountSet { presentmentMoney { amount } } } } } orderAdjustments(first: 50) { pageInfo { hasNextPage } edges { node { amountSet { presentmentMoney { amount } } taxAmountSet { presentmentMoney { amount } } reason } } } transactions(first: 50) { pageInfo { hasNextPage } edges { node { id kind status gateway processedAt createdAt paymentId receiptJson paymentDetails { ... on CardPaymentDetails { company } } amountSet { presentmentMoney { amount currencyCode } shopMoney { amount currencyCode } } } } } } }', Locked = true;
    begin
        Response := RunQuery(ShopifyStoreCode, RefundDetailRequest, StrSubstNo(_RefundGidTok, RefundId));
        ParseRefundDetail(ShopifyStoreCode, RefundId, Response, TempReturnBuffer, TempLineBuffer, TempRefundTxnBuffer);
        if not TempReturnBuffer.Get(RefundId) then
            Error(RefundNotFoundErr, RefundId, ShopifyStore.TableCaption(), ShopifyStoreCode);
    end;

    /// <summary>
    /// The lines of the order's other Refund-action refunds, marked earlier or later than this one.
    /// What Shopify cannot return in full is flagged on the buffer, not refused: it matters only when units were left off. A failed request still raises.
    /// </summary>
    internal procedure GetOtherRefundLines(ShopifyStoreCode: Code[20]; RefundId: Text[30]; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        Response: JsonToken;
        EarlierRefundIds: List of [Text];
        LaterRefundIds: List of [Text];
        OtherRefundId: Text;
        Incomplete: Boolean;
        OrderGidTok: Label 'gid://shopify/Order/%1', Locked = true;
        OrderRefundsRequest: Label 'query GetOrderRefunds($OrderId: ID!) { order(id: $OrderId) { id refunds(first: 50) { id createdAt return { id } } } }', Locked = true;
    begin
        TempOtherLineBuffer.Reset();
        TempOtherLineBuffer.DeleteAll();
        Response := RunQuery(ShopifyStoreCode, OrderRefundsRequest, StrSubstNo(OrderGidTok, TempReturnBuffer."Order Id"));
        ParseOrderRefundIds(RefundId, TempReturnBuffer."Source Created At", Response, EarlierRefundIds, LaterRefundIds, Incomplete);
        foreach OtherRefundId in EarlierRefundIds do
            if AddOtherRefundLines(ShopifyStoreCode, CopyStr(OtherRefundId, 1, 30), false, TempOtherLineBuffer) then
                Incomplete := true;
        // A refund that takes dropped units waits until the order is closed, and a later refund of a unit that never shipped may be what closed it.
        foreach OtherRefundId in LaterRefundIds do
            if AddOtherRefundLines(ShopifyStoreCode, CopyStr(OtherRefundId, 1, 30), true, TempOtherLineBuffer) then
                Incomplete := true;
        TempReturnBuffer."Other Refunds Incomplete" := Incomplete;
        TempReturnBuffer.Modify();
    end;

    /// <summary>
    /// Splits the order's other Refund-action refunds into earlier and later ones; Incomplete when the list is missing, lacks this refund, or is full and may hold more.
    /// </summary>
    internal procedure ParseOrderRefundIds(RefundId: Text[30]; RefundCreatedAt: DateTime; Response: JsonToken; var EarlierRefundIds: List of [Text]; var LaterRefundIds: List of [Text]; var Incomplete: Boolean)
    var
        RefundsToken: JsonToken;
        RefundToken: JsonToken;
        ReturnToken: JsonToken;
        OtherId: Text;
        BelongsToReturn: Boolean;
        ListsThisRefund: Boolean;
    begin
        Clear(EarlierRefundIds);
        Clear(LaterRefundIds);
        Incomplete := true;
        if not Response.SelectToken('data.order.refunds', RefundsToken) then
            exit;
        if not RefundsToken.IsArray() then
            exit;
        foreach RefundToken in RefundsToken.AsArray() do begin
            OtherId := _OrderMgt.GetNumericId(_JsonHelper.GetJText(RefundToken, 'id', true));
            if OtherId = RefundId then
                ListsThisRefund := true;
            BelongsToReturn := false;
            if RefundToken.SelectToken('return', ReturnToken) then
                BelongsToReturn := ReturnToken.IsObject();
            // A return's refund refunds returned, so fulfilled, units: it never shares the units the order import left out.
            if not BelongsToReturn then
                if OtherId <> RefundId then
                    if IsEarlier(OtherId, _JsonHelper.GetJDT(RefundToken, 'createdAt', true), RefundId, RefundCreatedAt) then
                        EarlierRefundIds.Add(OtherId)
                    else
                        LaterRefundIds.Add(OtherId);
        end;
        // The order's list always holds this refund itself, so a list without it leaves the other refunds unknown; a full one may hold more.
        Incomplete := (not ListsThisRefund) or (RefundsToken.AsArray().Count() >= OrderRefundListSize());
    end;

    local procedure IsEarlier(OtherId: Text; OtherCreatedAt: DateTime; RefundId: Text; RefundCreatedAt: DateTime): Boolean
    var
        OtherNo: BigInteger;
        ThisNo: BigInteger;
        BothNumeric: Boolean;
    begin
        if OtherId = RefundId then
            exit(false);
        if OtherCreatedAt <> RefundCreatedAt then
            exit(OtherCreatedAt < RefundCreatedAt);
        // Same second: Shopify's ids grow, so the lower id was made first.
        BothNumeric := Evaluate(OtherNo, OtherId);
        if BothNumeric then
            BothNumeric := Evaluate(ThisNo, RefundId);
        if BothNumeric then
            exit(OtherNo < ThisNo);
        exit(OtherId < RefundId);
    end;

    /// <summary>
    /// Reads only the line items of another refund, so a refund the import could not build on its own never blocks this one; true when they could not all be read.
    /// </summary>
    local procedure AddOtherRefundLines(ShopifyStoreCode: Code[20]; OtherRefundId: Text[30]; Later: Boolean; var TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary): Boolean
    var
        Response: JsonToken;
        RefundLinesRequest: Label 'query GetRefundLines($OrderId: ID!) { refund(id: $OrderId) { id createdAt refundLineItems(first: 250) { pageInfo { hasNextPage } edges { node { quantity restockType lineItem { id } } } } } }', Locked = true;
    begin
        Response := RunQuery(ShopifyStoreCode, RefundLinesRequest, StrSubstNo(_RefundGidTok, OtherRefundId));
        exit(ParseOtherRefundLines(OtherRefundId, Response, Later, TempOtherLineBuffer));
    end;

    local procedure ParseOtherRefundLines(OtherRefundId: Text[30]; Response: JsonToken; Later: Boolean; var TempOtherLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary) Incomplete: Boolean
    var
        RefundToken: JsonToken;
        EdgesToken: JsonToken;
        Edge: JsonToken;
        LineItemToken: JsonToken;
        DocId: Text[30];
        CreatedAt: DateTime;
        LineNo: Integer;
    begin
        // A refund the order lists but Shopify does not return cannot be counted.
        if not Response.SelectToken('data.refund', RefundToken) then
            exit(true);
        if not RefundToken.IsObject() then
            exit(true);
        DocId := OtherRefundId;
        CreatedAt := _JsonHelper.GetJDT(RefundToken, 'createdAt', true);
        Incomplete := HasNextPage(RefundToken, 'refundLineItems');
        // An amount-only refund has an empty list; a missing one leaves its units unknown.
        if not RefundToken.SelectToken('refundLineItems.edges', EdgesToken) then
            exit(true);
        if not EdgesToken.IsArray() then
            exit(true);
        foreach Edge in EdgesToken.AsArray() do begin
            LineNo += 10000;
            TempOtherLineBuffer.Init();
            TempOtherLineBuffer."Return Id" := DocId;
            TempOtherLineBuffer."Line No." := LineNo;
            TempOtherLineBuffer.Quantity := GetAmount(DocId, Edge, 'node.quantity');
            TempOtherLineBuffer."Restock Type" := CopyStr(_JsonHelper.GetJText(Edge, 'node.restockType', false).ToUpper(), 1, MaxStrLen(TempOtherLineBuffer."Restock Type"));
            if Edge.SelectToken('node.lineItem', LineItemToken) then
                if LineItemToken.IsObject() then
                    TempOtherLineBuffer."Order Line Item Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(LineItemToken, 'id', false));
            TempOtherLineBuffer."Source Created At" := CreatedAt;
            TempOtherLineBuffer."Later Refund" := Later;
            // A line without an order line or units takes none of the units the order import left out.
            if (TempOtherLineBuffer."Order Line Item Id" <> '') and (TempOtherLineBuffer.Quantity > 0) then
                TempOtherLineBuffer.Insert();
        end;
    end;

    local procedure OrderRefundListSize(): Integer
    begin
        exit(50);
    end;

    internal procedure ParseRefundDetail(ShopifyStoreCode: Code[20]; RefundId: Text[30]; Response: JsonToken; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary)
    var
        RefundToken: JsonToken;
        OrderToken: JsonToken;
        ReturnToken: JsonToken;
        DocId: Text[30];
        TaxesIncluded: Boolean;
        TxnLineNo: Integer;
        PendingCount: Integer;
    begin
        TempReturnBuffer.Reset();
        TempReturnBuffer.DeleteAll();
        TempLineBuffer.Reset();
        TempLineBuffer.DeleteAll();
        TempRefundTxnBuffer.Reset();
        TempRefundTxnBuffer.DeleteAll();

        if not Response.SelectToken('data.refund', RefundToken) then
            exit;
        if not RefundToken.IsObject() then
            exit;
        DocId := RefundId;
        CheckRefundNotTruncated(DocId, RefundToken);

        TempReturnBuffer.Init();
        TempReturnBuffer."Return Id" := DocId;
        TempReturnBuffer."Source Type" := TempReturnBuffer."Source Type"::Refund;
        TempReturnBuffer."Source Created At" := _JsonHelper.GetJDT(RefundToken, 'createdAt', true);
        TempReturnBuffer."Posting DateTime" := _JsonHelper.GetJDT(RefundToken, 'processedAt', false);
        if TempReturnBuffer."Posting DateTime" = 0DT then
            TempReturnBuffer."Posting DateTime" := TempReturnBuffer."Source Created At";
        if RefundToken.SelectToken('return', ReturnToken) then
            TempReturnBuffer."Belongs to Return" := ReturnToken.IsObject();
        // Every amount rule and the customer depend on the order, so a detail without one is refused.
        OrderToken := _JsonHelper.GetJsonToken(RefundToken, 'order');
        ReadOrderBlock(OrderToken, TempReturnBuffer, TaxesIncluded);
        TempReturnBuffer."Order Cancelled" := _JsonHelper.GetJDT(OrderToken, 'cancelledAt', false) <> 0DT;
        TempReturnBuffer."Order Fulfilled" := HasSuccessfulFulfillment(OrderToken);
        TempReturnBuffer."Return Name" := TempReturnBuffer."Order Name";
        TempReturnBuffer."Shipping Refund Amount" := SumShippingOfRefund(DocId, RefundToken);
        SplitAdjustments(SumAdjustmentsOfRefund(DocId, RefundToken, TaxesIncluded), TempReturnBuffer."Fee Amount", TempReturnBuffer."Refund Beyond Lines Amount");
        TempReturnBuffer.Insert();

        ParseRefundLines(DocId, TempReturnBuffer."Return Name", RefundToken, TaxesIncluded, TempLineBuffer);
        ParseTransactionsOfRefund(DocId, RefundToken, TempRefundTxnBuffer, TxnLineNo, PendingCount);
        TempReturnBuffer."Pending Refund Txns" := PendingCount;
        TempReturnBuffer.Modify();
    end;

    local procedure ParseRefundLines(DocId: Text[30]; OrderName: Text; RefundToken: JsonToken; TaxesIncluded: Boolean; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        EdgesToken: JsonToken;
        Edge: JsonToken;
        LineItemToken: JsonToken;
        LineNo: Integer;
        OrderedBelowRefundedErr: Label 'Shopify refund %1 refunds more units of line item %2 than were ordered. This is a programming bug.', Locked = true;
    begin
        if not RefundToken.SelectToken('refundLineItems.edges', EdgesToken) then
            exit;
        foreach Edge in EdgesToken.AsArray() do begin
            LineNo += 10000;
            TempLineBuffer.Init();
            TempLineBuffer."Return Id" := DocId;
            TempLineBuffer."Line No." := LineNo;
            TempLineBuffer.Quantity := GetAmount(DocId, Edge, 'node.quantity');
            TempLineBuffer."Restock Type" := CopyStr(_JsonHelper.GetJText(Edge, 'node.restockType', false).ToUpper(), 1, MaxStrLen(TempLineBuffer."Restock Type"));
            if Edge.SelectToken('node.lineItem', LineItemToken) then
                ReadLineItem(LineItemToken, TempLineBuffer);
            case TempLineBuffer."Restock Type" of
                'RETURN', 'LEGACY_RESTOCK':
                    TempLineBuffer."Disposition Location Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(Edge, 'node.location.id', false));
                'NO_RESTOCK':
                    TempLineBuffer."Not Restocked" := true;
            end;
            if TempLineBuffer."Order Line Item Id" = '' then
                Error(_UnsupportedLineErr, DocumentCaption("NPR Spfy Legacy Return Source"::Refund, OrderName, DocId));
            if TempLineBuffer.Quantity <= 0 then
                Error(_ZeroQuantityLineErr, DocumentCaption("NPR Spfy Legacy Return Source"::Refund, OrderName, DocId), TempLineBuffer."Order Line Item Id");
            TempLineBuffer."Ordered Quantity" := GetAmount(DocId, Edge, 'node.lineItem.quantity');
            if TempLineBuffer."Ordered Quantity" < TempLineBuffer.Quantity then
                Error(OrderedBelowRefundedErr, DocId, TempLineBuffer."Order Line Item Id");
            TempLineBuffer."Line Amount" := RefundLineGross(DocId, Edge, TaxesIncluded);
            TempLineBuffer."VAT %" := RefundLineVatRate(DocId, Edge);
            // Rounded up: Sales Line refuses a Line Amount above Quantity * Unit Price.
            TempLineBuffer."Unit Price" := Round(TempLineBuffer."Line Amount" / TempLineBuffer.Quantity, 0.01, '>');
            TempLineBuffer.Insert();
        end;
    end;

    /// <summary>
    /// Shopify shipped something on the order, which the order import ships and invoices however much was refunded since.
    /// </summary>
    local procedure HasSuccessfulFulfillment(OrderToken: JsonToken): Boolean
    var
        FulfillmentsToken: JsonToken;
        Fulfillment: JsonToken;
    begin
        if not OrderToken.SelectToken('fulfillments', FulfillmentsToken) then
            exit(false);
        if not FulfillmentsToken.IsArray() then
            exit(false);
        foreach Fulfillment in FulfillmentsToken.AsArray() do
            if _JsonHelper.GetJText(Fulfillment, 'status', false).ToUpper() = 'SUCCESS' then
                exit(true);
        exit(false);
    end;

    local procedure CheckRefundNotTruncated(DocId: Text[30]; RefundToken: JsonToken)
    begin
        if HasNextPage(RefundToken, 'refundLineItems') then
            Error(_TruncatedErr, DocId, 'refundLineItems');
        if HasNextPage(RefundToken, 'refundShippingLines') then
            Error(_TruncatedErr, DocId, 'refundShippingLines');
        if HasNextPage(RefundToken, 'orderAdjustments') then
            Error(_TruncatedErr, DocId, 'orderAdjustments');
        if HasNextPage(RefundToken, 'transactions') then
            Error(_TruncatedErr, DocId, 'transactions');
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
        TempReturnBuffer."Posting DateTime" := TempReturnBuffer."Closed At";
        TempReturnBuffer.Status := CopyStr(_JsonHelper.GetJText(ReturnToken, 'status', false).ToUpper(), 1, MaxStrLen(TempReturnBuffer.Status));
        TempReturnBuffer."Has Exchange Line" := ArrayCount(ReturnToken, 'exchangeLineItems.edges') > 0;
        // Every amount rule and the customer depend on the order, so a detail without one is refused.
        OrderToken := _JsonHelper.GetJsonToken(ReturnToken, 'order');
        ReadOrderBlock(OrderToken, TempReturnBuffer, TaxesIncluded);
        TempReturnBuffer."Shipping Refund Amount" := SumRefundShippingLines(ReturnId, ReturnToken);
        SumFees(ReturnId, ReturnToken, TaxesIncluded, TempReturnBuffer."Fee Amount", TempReturnBuffer."Refund Beyond Lines Amount");
        TempReturnBuffer.Insert();

        ParseLines(ReturnId, ReturnToken, TempLineBuffer);
        ApplyDispositions(ReturnToken, TempLineBuffer);
        ApplyRefundLineAmounts(ShopifyStoreCode, ReturnId, ReturnToken, TempReturnBuffer."Presentment Currency Code", TaxesIncluded, (TempReturnBuffer.Status = 'CLOSED') and not TempReturnBuffer."Has Exchange Line", TempLineBuffer);
        TempReturnBuffer."Pending Refund Txns" := ParseRefundTransactions(ReturnId, ReturnToken, TempRefundTxnBuffer);
        TempReturnBuffer.Modify();
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

    local procedure ReadOrderBlock(OrderToken: JsonToken; var TempReturnBuffer: Record "NPR Spfy Legacy Return Buffer" temporary; var TaxesIncluded: Boolean)
    begin
        TempReturnBuffer."Order Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(OrderToken, 'id', true));
        TempReturnBuffer."Order Name" := CopyStr(_JsonHelper.GetJText(OrderToken, 'name', false), 1, MaxStrLen(TempReturnBuffer."Order Name"));
        TempReturnBuffer."Order No." := CopyStr(_JsonHelper.GetJText(OrderToken, 'number', false), 1, MaxStrLen(TempReturnBuffer."Order No."));
        TempReturnBuffer."Source Name" := CopyStr(_JsonHelper.GetJText(OrderToken, 'sourceName', false), 1, MaxStrLen(TempReturnBuffer."Source Name"));
        TempReturnBuffer."Presentment Currency Code" := CopyStr(_JsonHelper.GetJText(OrderToken, 'presentmentCurrencyCode', false), 1, MaxStrLen(TempReturnBuffer."Presentment Currency Code"));
        TempReturnBuffer.SetOrderJson(OrderToken);
        TaxesIncluded := _JsonHelper.GetJBoolean(OrderToken, 'taxesIncluded', true);
    end;

    /// <summary>
    /// What Shopify charges now for Units of an order line, gross, after every discount allocated to it, including one given after the sale; the discount is spread over the units as the order import spreads it.
    /// False when the order's line items do not list the line.
    /// </summary>
    internal procedure CurrentOrderLineGross(DocId: Text[30]; OrderToken: JsonToken; LineItemId: Text; Units: Decimal; RoundingPrecision: Decimal; var Gross: Decimal): Boolean
    var
        EdgesToken: JsonToken;
        Edge: JsonToken;
        AllocationsToken: JsonToken;
        Allocation: JsonToken;
        TaxLinesToken: JsonToken;
        TaxLine: JsonToken;
        OrderedQuantity: Decimal;
        Discount: Decimal;
        VatRate: Decimal;
    begin
        Gross := 0;
        // The line the request did not reach could be the discounted one.
        if HasNextPage(OrderToken, 'lineItems') then
            Error(_TruncatedErr, DocId, 'order.lineItems');
        if not OrderToken.SelectToken('lineItems.edges', EdgesToken) then
            exit(false);
        foreach Edge in EdgesToken.AsArray() do
            if _OrderMgt.GetNumericId(_JsonHelper.GetJText(Edge, 'node.id', false)) = LineItemId then begin
                OrderedQuantity := GetAmount(DocId, Edge, 'node.quantity');
                // Without a price nothing can be measured; zero would credit the whole invoiced amount.
                if (OrderedQuantity <= 0) or (_JsonHelper.GetJText(Edge, 'node.originalUnitPriceSet.presentmentMoney.amount', false) = '') then
                    exit(false);
                if Edge.SelectToken('node.discountAllocations', AllocationsToken) then
                    if AllocationsToken.IsArray() then
                        foreach Allocation in AllocationsToken.AsArray() do
                            Discount += GetAmount(DocId, Allocation, 'allocatedAmountSet.presentmentMoney.amount');
                Gross := GetAmount(DocId, Edge, 'node.originalUnitPriceSet.presentmentMoney.amount') * Units - Round(Discount / OrderedQuantity * Units, RoundingPrecision);
                if not _JsonHelper.GetJBoolean(OrderToken, 'taxesIncluded', true) then begin
                    if Edge.SelectToken('node.taxLines', TaxLinesToken) then
                        foreach TaxLine in TaxLinesToken.AsArray() do
                            VatRate += GetAmount(DocId, TaxLine, 'ratePercentage');
                    Gross := Gross * (1 + VatRate / 100);
                end;
                Gross := Round(Gross, RoundingPrecision);
                exit(true);
            end;
        exit(false);
    end;

    local procedure ReadLineItem(LineItemToken: JsonToken; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        SpfyOrderApiHelper: Codeunit "NPR Spfy Order ApiHelper";
        Sku: Text;
    begin
        TempLineBuffer."Order Line Item Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(LineItemToken, 'id', false));
        // The order line's SKU is the one the item was sold and imported under; the variant's SKU may have changed since.
        Sku := _JsonHelper.GetJText(LineItemToken, 'sku', false);
        if Sku = '' then
            Sku := _JsonHelper.GetJText(LineItemToken, 'variant.sku', false);
        TempLineBuffer.SKU := CopyStr(Sku, 1, MaxStrLen(TempLineBuffer.SKU));
        TempLineBuffer.Title := CopyStr(_JsonHelper.GetJText(LineItemToken, 'title', false), 1, MaxStrLen(TempLineBuffer.Title));
        TempLineBuffer.SetLineItemJson(LineItemToken);
        TempLineBuffer."Gift Card" := SpfyOrderApiHelper.OrderLineIsGiftCard(LineItemToken);
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
        BadAmountErr: Label 'Shopify return or refund %1 carries a value in %2 that is not a number. This is a programming bug.', Locked = true;
    begin
        AmountText := _JsonHelper.GetJText(Token, Path, false);
        if AmountText = '' then
            exit(0);
        if not Evaluate(Amount, AmountText, 9) then
            Error(BadAmountErr, ReturnId, Path);
        exit(Amount);
    end;

    local procedure ParseLines(ReturnId: Text[30]; ReturnToken: JsonToken; var TempLineBuffer: Record "NPR Spfy Legacy Return Ln Buf" temporary)
    var
        EdgesToken: JsonToken;
        Edge: JsonToken;
        LineItemToken: JsonToken;
        LineNo: Integer;
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
            if Edge.SelectToken('node.fulfillmentLineItem.lineItem', LineItemToken) then
                ReadLineItem(LineItemToken, TempLineBuffer);
            // An unverified return line has no order line behind it, so no document line, refund share or quantity check can be built for it.
            if TempLineBuffer."Order Line Item Id" = '' then
                Error(_UnsupportedLineErr, DocumentCaption("NPR Spfy Legacy Return Source"::Return, _JsonHelper.GetJText(ReturnToken, 'name', false), ReturnId));
            if TempLineBuffer.Quantity <= 0 then
                Error(_ZeroQuantityLineErr, DocumentCaption("NPR Spfy Legacy Return Source"::Return, _JsonHelper.GetJText(ReturnToken, 'name', false), ReturnId), TempLineBuffer."Order Line Item Id");
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
                    Gross := RefundLineGross(ReturnId, RefundLineEdge, TaxesIncluded);
                    VatRate := RefundLineVatRate(ReturnId, RefundLineEdge);
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
        UnrefundedQuantityErr: Label 'Shopify return %1 returns %2 units of %3 but refunds only %4 of them, so one document cannot carry both the goods and the refund. Handle this return manually.', Comment = '%1 = Shopify return name, %2 = returned quantity, %3 = SKU, or the title for a line without one, %4 = refunded quantity';
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
                Error(UnrefundedQuantityErr, _JsonHelper.GetJText(ReturnToken, 'name', false), ReturnedQuantities.Get(OrderLineItemId), LineName, Refunded);
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
        RefundLineUnmatchedErr: Label 'Shopify return %1 refunds order line item %2, which is not among the returned lines, so the refunded amount cannot be placed on a return line. Handle this return manually.', Comment = '%1 = Shopify return name, %2 = Shopify order line item id';
    begin
        // An order line shipped in parcels returns as one line per parcel: share the gross by quantity, rounded down, remainder on the last.
        TempLineBuffer.Reset();
        TempLineBuffer.SetRange("Order Line Item Id", OrderLineItemId);
        if TempLineBuffer.IsEmpty() then
            Error(RefundLineUnmatchedErr, _JsonHelper.GetJText(ReturnToken, 'name', false), OrderLineItemId);
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

    internal procedure AmountRoundingPrecision(ShopifyStoreCode: Code[20]; PresentmentCurrencyCode: Text): Decimal
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

    local procedure ParseRefundTransactions(ReturnId: Text[30]; ReturnToken: JsonToken; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary) PendingCount: Integer
    var
        RefundsToken: JsonToken;
        RefundEdge: JsonToken;
        RefundNode: JsonToken;
        LineNo: Integer;
    begin
        if not ReturnToken.SelectToken('refunds.edges', RefundsToken) then
            exit;
        foreach RefundEdge in RefundsToken.AsArray() do
            if RefundEdge.SelectToken('node', RefundNode) then
                ParseTransactionsOfRefund(ReturnId, RefundNode, TempRefundTxnBuffer, LineNo, PendingCount);
    end;

    /// <summary>
    /// Reads one refund's successful REFUND transactions and counts those Shopify has not completed yet.
    /// </summary>
    local procedure ParseTransactionsOfRefund(DocId: Text[30]; RefundNode: JsonToken; var TempRefundTxnBuffer: Record "NPR Spfy Legacy Refund Txn Buf" temporary; var LineNo: Integer; var PendingCount: Integer)
    var
        TxnsToken: JsonToken;
        TxnEdge: JsonToken;
        TxnStatus: Text;
    begin
        if not RefundNode.SelectToken('transactions.edges', TxnsToken) then
            exit;
        foreach TxnEdge in TxnsToken.AsArray() do begin
            TxnStatus := _JsonHelper.GetJText(TxnEdge, 'node.status', false).ToUpper();
            if (_JsonHelper.GetJText(TxnEdge, 'node.kind', false).ToUpper() = 'REFUND') and (TxnStatus in ['PENDING', 'AWAITING_RESPONSE']) then
                PendingCount += 1;
            if (_JsonHelper.GetJText(TxnEdge, 'node.kind', false).ToUpper() = 'REFUND') and (TxnStatus = 'SUCCESS') then begin
                LineNo += 10000;
                TempRefundTxnBuffer.Init();
                TempRefundTxnBuffer."Return Id" := DocId;
                TempRefundTxnBuffer."Line No." := LineNo;
                TempRefundTxnBuffer.Kind := CopyStr(_JsonHelper.GetJText(TxnEdge, 'node.kind', false), 1, MaxStrLen(TempRefundTxnBuffer.Kind));
                TempRefundTxnBuffer.Gateway := CopyStr(_JsonHelper.GetJText(TxnEdge, 'node.gateway', false), 1, MaxStrLen(TempRefundTxnBuffer.Gateway));
                TempRefundTxnBuffer."Transaction Id" := _OrderMgt.GetNumericId(_JsonHelper.GetJText(TxnEdge, 'node.id', true));
                TempRefundTxnBuffer."Processed At" := _JsonHelper.GetJDT(TxnEdge, 'node.processedAt', false);
                TempRefundTxnBuffer."Created At" := _JsonHelper.GetJDT(TxnEdge, 'node.createdAt', false);
                TempRefundTxnBuffer.Amount := GetAmount(DocId, TxnEdge, 'node.amountSet.presentmentMoney.amount');
                TempRefundTxnBuffer."Amount (Store Currency)" := GetAmount(DocId, TxnEdge, 'node.amountSet.shopMoney.amount');
                TempRefundTxnBuffer."Store Currency Code" := CopyStr(_JsonHelper.GetJText(TxnEdge, 'node.amountSet.shopMoney.currencyCode', false), 1, MaxStrLen(TempRefundTxnBuffer."Store Currency Code"));
                TempRefundTxnBuffer."Gift Card Id" := GiftCardIdFromReceipt(_JsonHelper.GetJText(TxnEdge, 'node.receiptJson', false));
                TempRefundTxnBuffer."Credit Card Company" := CopyStr(_JsonHelper.GetJText(TxnEdge, 'node.paymentDetails.company', false), 1, MaxStrLen(TempRefundTxnBuffer."Credit Card Company"));
                TempRefundTxnBuffer.Insert();
            end;
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
        RefundNode: JsonToken;
    begin
        if not ReturnToken.SelectToken('refunds.edges', RefundsToken) then
            exit(0);
        foreach RefundEdge in RefundsToken.AsArray() do
            if RefundEdge.SelectToken('node', RefundNode) then
                Total += SumShippingOfRefund(ReturnId, RefundNode);
    end;

    local procedure SumShippingOfRefund(DocId: Text[30]; RefundNode: JsonToken) Total: Decimal
    var
        LinesToken: JsonToken;
        LineEdge: JsonToken;
    begin
        if RefundNode.SelectToken('refundShippingLines.edges', LinesToken) then
            foreach LineEdge in LinesToken.AsArray() do
                Total += GetAmount(DocId, LineEdge, 'node.subtotalAmountSet.presentmentMoney.amount') + GetAmount(DocId, LineEdge, 'node.taxAmountSet.presentmentMoney.amount');
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
        RefundNode: JsonToken;
        AdjustmentTotal: Decimal;
    begin
        FeeAmount := 0;
        RefundBeyondLinesAmount := 0;
        if ReturnToken.SelectToken('refunds.edges', RefundsToken) then
            foreach RefundEdge in RefundsToken.AsArray() do
                if RefundEdge.SelectToken('node', RefundNode) then
                    AdjustmentTotal += SumAdjustmentsOfRefund(ReturnId, RefundNode, TaxesIncluded);
        SplitAdjustments(AdjustmentTotal, FeeAmount, RefundBeyondLinesAmount);
        if ReturnToken.SelectToken('returnShippingFees', ArrToken) then
            foreach Edge in ArrToken.AsArray() do
                FeeAmount += Abs(GetAmount(ReturnId, Edge, 'amountSet.presentmentMoney.amount'));
        if ReturnToken.SelectToken('returnLineItems.edges', ArrToken) then
            foreach Edge in ArrToken.AsArray() do
                FeeAmount += Abs(GetAmount(ReturnId, Edge, 'node.restockingFee.amountSet.presentmentMoney.amount'));
    end;

    local procedure SumAdjustmentsOfRefund(DocId: Text[30]; RefundNode: JsonToken; TaxesIncluded: Boolean) Total: Decimal
    var
        AdjToken: JsonToken;
        AdjEdge: JsonToken;
    begin
        if RefundNode.SelectToken('orderAdjustments.edges', AdjToken) then
            foreach AdjEdge in AdjToken.AsArray() do
                Total += GrossAmount(DocId, AdjEdge, 'node.amountSet.presentmentMoney.amount', 'node.taxAmountSet.presentmentMoney.amount', TaxesIncluded);
    end;

    /// <summary>
    /// Shopify signs an order adjustment: positive is withheld from the customer, negative is paid out on top of the lines.
    /// </summary>
    local procedure SplitAdjustments(AdjustmentTotal: Decimal; var FeeAmount: Decimal; var RefundBeyondLinesAmount: Decimal)
    begin
        if AdjustmentTotal >= 0 then
            FeeAmount += AdjustmentTotal
        else
            RefundBeyondLinesAmount := -AdjustmentTotal;
    end;

    local procedure RefundLineGross(DocId: Text[30]; RefundLineEdge: JsonToken; TaxesIncluded: Boolean): Decimal
    begin
        exit(GrossAmount(DocId, RefundLineEdge, 'node.subtotalSet.presentmentMoney.amount', 'node.totalTaxSet.presentmentMoney.amount', TaxesIncluded));
    end;

    local procedure RefundLineVatRate(DocId: Text[30]; RefundLineEdge: JsonToken) VatRate: Decimal
    var
        TaxLinesToken: JsonToken;
        TaxLine: JsonToken;
    begin
        if RefundLineEdge.SelectToken('node.lineItem.taxLines', TaxLinesToken) then
            foreach TaxLine in TaxLinesToken.AsArray() do
                VatRate += GetAmount(DocId, TaxLine, 'ratePercentage');
    end;

}

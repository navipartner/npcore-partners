codeunit 6184792 "NPR Spfy Order Cancel Check"
{
    Access = Internal;

    /// <summary>
    /// Asks Shopify whether the order is cancelled right now. Stored order data cannot answer that: it shows the order as it was when it was downloaded.
    /// </summary>
    internal procedure IsCancelled(ShopifyStoreCode: Code[20]; ShopifyOrderID: Text[30]): Boolean
    var
        NcTask: Record "NPR Nc Task";
        ShopifyStore: Record "NPR Spfy Store";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        OrderToken: JsonToken;
        Response: JsonToken;
        OrderCancellationRequest: Label 'query GetOrderCancellation($OrderId: ID!) { order(id: $OrderId) { id cancelledAt } }', Locked = true;
        OrderGidTok: Label 'gid://shopify/Order/%1', Locked = true;
        OrderNotFoundErr: Label 'Shopify returned no data for order %1 of %2 %3, so it is unknown whether the order was canceled. The order may be deleted in Shopify, or older than 60 days without the read_all_orders scope.', Comment = '%1 = Shopify order id, %2 = Shopify Store table caption, %3 = Shopify store code';
    begin
        ClearLastError();
        SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, '', ShopifyStoreCode, OrderCancellationRequest, StrSubstNo(OrderGidTok, ShopifyOrderID), false);
        if not GetGraphQLClient().ExecuteRequest(NcTask, false, Response) then
            Error(GetLastErrorText());

        // An order Shopify does not return is not treated as open: a document must not be created on a guess.
        if not Response.SelectToken('data.order', OrderToken) then
            Error(OrderNotFoundErr, ShopifyOrderID, ShopifyStore.TableCaption(), ShopifyStoreCode);
        if not OrderToken.IsObject() then
            Error(OrderNotFoundErr, ShopifyOrderID, ShopifyStore.TableCaption(), ShopifyStoreCode);

        exit(JsonHelper.GetJDT(OrderToken, 'cancelledAt', false) <> 0DT);
    end;

    internal procedure NoDocumentCreatedMsg(): Text
    var
        CancelledMsg: Label 'The order has been canceled in Shopify, so no sales document was created for it.';
    begin
        exit(CancelledMsg);
    end;

    local procedure GetGraphQLClient(): Interface "NPR Spfy IGraphQL Client"
    var
        DefaultGraphQLClient: Codeunit "NPR Spfy GraphQL Client";
        GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        Handled: Boolean;
    begin
        OnBeforeGetGraphQLClient(GraphQLClient, Handled);
        if Handled then
            exit(GraphQLClient);
        exit(DefaultGraphQLClient);
    end;

    // Test seam: the import list and the event log processor create the calling codeunits themselves, so a mock client cannot be handed in from outside.
    [InternalEvent(false)]
    local procedure OnBeforeGetGraphQLClient(var GraphQLClient: Interface "NPR Spfy IGraphQL Client"; var Handled: Boolean)
    begin
    end;
}

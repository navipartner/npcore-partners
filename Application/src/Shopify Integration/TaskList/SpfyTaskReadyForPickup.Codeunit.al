// Native sibling of frozen codeunit "NPR Spfy Ord Ready For Pickup": only sanctioned legacy defect fixes are dual-applied, new-queue behavior changes are not.
codeunit 6151475 "NPR Spfy Task Ready For Pickup"
{
    Access = Internal;
    TableNo = "NPR Spfy Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"NPR NpCs Document":
                SendOrderReadyForPickup(Rec);
        end;
    end;

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

    local procedure SendOrderReadyForPickup(var SpfyTask: Record "NPR Spfy Task")
    var
        ShopifyResponse: JsonToken;
        Success: Boolean;
    begin
        ClearLastError();
        PrepareRequest(SpfyTask);
        Success := GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse);

        SpfyTask.Modify();
        Commit();
        if not Success then
            Error(GetLastErrorText());
        if _SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');
    end;

    local procedure PrepareRequest(var SpfyTask: Record "NPR Spfy Task")
    var
        NpCsDocument: Record "NPR NpCs Document";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        FulfillmentOrderID: Text;
    begin
        Clear(SpfyTask."Data Output");
        Clear(SpfyTask.Response);
        if SpfyTask."Store Code" = '' then
            SpfyTask."Store Code" :=
                CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SpfyTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(SpfyTask."Store Code"));

        // The document may already be archived or deleted: the send does not need it, subscribers get an empty record then.
        if not NpCsDocument.Get(SpfyTask."Record ID") then
            Clear(NpCsDocument);
        _SpfyIntegrationEvents.OnBeforeSendOrderReadyForPickup(NpCsDocument, SpfyTask."Record Value", SpfyTask."Store Code");

        FulfillmentOrderID := CollectFulfillmentOrders(SpfyTask);
        PrepareReadyforPickupRequest(SpfyTask, FulfillmentOrderID);
    end;

    local procedure PrepareReadyForPickupRequest(var SpfyTask: Record "NPR Spfy Task"; FulfillmentOrderID: Text)
    var
        ReadyForPickupMutationTxt: Label 'mutation fulfillmentOrderLineItemsPreparedForPickup($input: FulfillmentOrderLineItemsPreparedForPickupInput!) { fulfillmentOrderLineItemsPreparedForPickup(input: $input) { userErrors { field message } } }', Locked = true;
        RootObj: JsonObject;
        VariablesObj: JsonObject;
        InputObj: JsonObject;
        FulfilmentObj: JsonObject;
        LineItemsByFOArr: JsonArray;
        OutStr: OutStream;
    begin
        FulfilmentObj.Add('fulfillmentOrderId', FulfillmentOrderID);
        LineItemsByFOArr.Add(FulfilmentObj);
        InputObj.Add('lineItemsByFulfillmentOrder', LineItemsByFOArr);
        VariablesObj.Add('input', InputObj);
        RootObj.Add('query', ReadyForPickupMutationTxt);
        RootObj.Add('variables', VariablesObj);
        SpfyTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        RootObj.WriteTo(OutStr);
    end;


    local procedure CollectFulfillmentOrders(var SpfyTask: Record "NPR Spfy Task"): Text;
    var
        FulfillmentOrder: JsonToken;
        ShopifyResponse: JsonToken;
        FulfillmentOrderIds: List of [Text];
        Cursor: Text;
        FulfillmentOrderID: Text;
        HasNext: Boolean;
        RequestString: Label 'query GetFulfillmentOrders($OrderId: ID!,$afterCursor: String){order(id:$OrderId){fulfillmentOrders(after:$afterCursor,first:50){pageInfo{hasNextPage endCursor} edges{node{id status deliveryMethod{methodType}}}}}}', Locked = true;
    begin
        Cursor := '';
        HasNext := true;
        repeat
            _SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(SpfyTask, Cursor, SpfyTask."Store Code", RequestString, 'gid://shopify/Order/' + SpfyTask."Record Value", true);
            if not GetGraphQLClient().ExecuteRequest(SpfyTask, false, ShopifyResponse) then
                Error(GetLastErrorText());
            if not ParsePageInfo(ShopifyResponse, 'data.order.fulfillmentOrders', HasNext, Cursor) then
                Error(GetLastErrorText());
            foreach FulfillmentOrder in GetFulfillmentOrderNodes(ShopifyResponse) do
                if _JsonHelper.GetJText(FulfillmentOrder, 'status', true).ToLower() in ['open', 'in_progress'] then begin
                    if _JsonHelper.GetJText(FulfillmentOrder, 'deliveryMethod.methodType', true).ToLower() = 'pick_up' then begin
                        FulfillmentOrderID := _JsonHelper.GetJText(FulfillmentOrder, 'id', true);
                        if not FulfillmentOrderIds.Contains(FulfillmentOrderID) then
                            FulfillmentOrderIds.Add(FulfillmentOrderID);
                    end;
                end;
        until not HasNext;

        exit(ValidateFulfilmentOrderIds(SpfyTask, FulfillmentOrderIds));
    end;

    local procedure ValidateFulfilmentOrderIds(SpfyTask: Record "NPR Spfy Task"; FulfillmentOrderIds: List of [Text]) FulfillmentOrderID: Text;
    var
        NoFulfilmentOrdErr: Label 'Shopify Order %1 does not have any open pickup fulfillment orders.', Comment = '%1=Shopify Order Id';
        MoreFulfilmentOrdErr: Label 'Shopify order %1 has %2 open pickup fulfillment orders. Unable to determine which one to process.', Comment = '%1=Shopify Order Id,%2=Fulfillment Orders';
    begin
        case FulfillmentOrderIds.Count of
            0:
                Error(NoFulfilmentOrdErr, SpfyTask."Record Value");
            1:
                FulfillmentOrderID := FulfillmentOrderIds.Get(1);
            else
                Error(MoreFulfilmentOrdErr, SpfyTask."Record Value", FulfillmentOrderIds.Count);
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

    var
        _JsonHelper: Codeunit "NPR Json Helper";
        _SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
        _SpfyIntegrationEvents: Codeunit "NPR Spfy Integration Events";
        _GraphQLClient: Interface "NPR Spfy IGraphQL Client";
        _GraphQLClientSet: Boolean;
}

#if not BC17
codeunit 6248688 "NPR Spfy Ord Ready For Pickup"
{
    Access = Internal;
    TableNo = "NPR Nc Task";

    trigger OnRun()
    begin
        Rec.TestField("Table No.", Rec."Record ID".TableNo);
        case Rec."Table No." of
            Database::"NPR NpCs Document":
                SendOrderReadyForPickup(Rec);
        end;
    end;

    internal procedure ScheduleOrderReadyForPickup(Rec: Record "NPR NpCs Document")
    var
        NcTask: Record "NPR Nc Task";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyScheduleSend: Codeunit "NPR Spfy Schedule Send Tasks";
        RecRef: RecordRef;
        SourceDocRecID: RecordId;
        SpfyOrderId: Text[30];
        MissingStoreCodeErr: Label 'Shopify Store Code is missing for source document %1 %2. The task for updating the Shopify fulfillment order status cannot be created.', Comment = '%1=Document Type,%2=Document No.';
    begin
        if Rec."From Document Type" <> Rec."From Document Type"::Order then
            exit;

        case true of
            Rec."Document Type" = Rec."Document Type"::Order:
                begin
                    SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
                    SalesHeader."No." := Rec."From Document No.";
                    SourceDocRecID := SalesHeader.RecordID();
                end;
            Rec."Document Type" = Rec."Document Type"::"Posted Invoice":
                begin
                    SalesInvoiceHeader."No." := Rec."Document No.";
                    SourceDocRecID := SalesInvoiceHeader.RecordID();
                end;
            else
                exit;
        end;
        SpfyOrderId := SpfyAssignedIDMgt.GetAssignedShopifyID(SourceDocRecID, "NPR Spfy ID Type"::"Entry ID");
        if SpfyOrderId = '' then
            exit;
        NcTask."Store Code" := CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(SourceDocRecID, "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));
        if NcTask."Store Code" = '' then
            Error(MissingStoreCodeErr, Rec."Document Type", Rec."Document No.");
        if not SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Order Ready for Pickup", NcTask."Store Code") then
            exit;

        Clear(RecRef);
        RecRef.GetTable(Rec);
        SpfyScheduleSend.InitNcTask(NcTask."Store Code", RecRef, SpfyOrderId, NcTask.Type::Insert, NcTask);
    end;

    local procedure SendOrderReadyForPickup(var NcTask: Record "NPR Nc Task")
    var
        ShopifyResponse: JsonToken;
        Success: Boolean;
    begin
        ClearLastError();
        PrepareRequest(NcTask);
        Success := SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse);

        NcTask.Modify();
        Commit();
        if not Success then
            Error(GetLastErrorText());
        if SpfyCommunicationHandler.UserErrorsExistInGraphQLResponse(ShopifyResponse) then
            Error('');
    end;

    local procedure PrepareRequest(var NcTask: Record "NPR Nc Task")
    var
        SpfyAssignedIDMgt: Codeunit "NPR Spfy Assigned ID Mgt Impl.";
        FulfillmentOrderID: Text;
    begin
        Clear(NcTask."Data Output");
        Clear(NcTask.Response);
        if NcTask."Store Code" = '' then
            NcTask."Store Code" :=
                CopyStr(SpfyAssignedIDMgt.GetAssignedShopifyID(NcTask."Record ID", "NPR Spfy ID Type"::"Store Code"), 1, MaxStrLen(NcTask."Store Code"));

        FulfillmentOrderID := CollectFulfillmentOrders(NcTask);
        PrepareReadyforPickupRequest(NcTask, FulfillmentOrderID);
    end;

    local procedure PrepareReadyForPickupRequest(var NcTask: Record "NPR Nc Task"; FulfillmentOrderID: Text)
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
        NcTask."Data Output".CreateOutStream(OutStr, TextEncoding::UTF8);
        RootObj.WriteTo(OutStr);
    end;


    local procedure CollectFulfillmentOrders(var NcTask: Record "NPR Nc Task"): Text;
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
            SpfyCommunicationHandler.CreateGraphQLRequestWithOrderIdFilter(NcTask, Cursor, NcTask."Store Code", RequestString, 'gid://shopify/Order/' + NcTask."Record Value", true);
            if not SpfyCommunicationHandler.ExecuteShopifyGraphQLRequest(NcTask, false, ShopifyResponse) then
                Error(GetLastErrorText());
            if not ParsePageInfo(ShopifyResponse, 'data.order.fulfillmentOrders', HasNext, Cursor) then
                Error(GetLastErrorText());
            foreach FulfillmentOrder in GetFulfillmentOrderNodes(ShopifyResponse) do
                if JsonHelper.GetJText(FulfillmentOrder, 'status', true).ToLower() in ['open', 'in_progress'] then begin
                    if JsonHelper.GetJText(FulfillmentOrder, 'deliveryMethod.methodType', true).ToLower() = 'pick_up' then begin
                        FulfillmentOrderID := JsonHelper.GetJText(FulfillmentOrder, 'id', true);
                        if not FulfillmentOrderIds.Contains(FulfillmentOrderID) then
                            FulfillmentOrderIds.Add(FulfillmentOrderID);
                    end;
                end;
        until not HasNext;

        exit(ValidateFulfilmentOrderIds(NcTask, FulfillmentOrderIds));
    end;

    local procedure ValidateFulfilmentOrderIds(NcTask: Record "NPR Nc Task"; FulfillmentOrderIds: List of [Text]) FulfillmentOrderID: Text;
    var
        NoFulfilmentOrdErr: Label 'Shopify Order %1 does not have any open pickup fulfillment orders.', Comment = '%1=Shopify Order Id';
        MoreFulfilmentOrdErr: Label 'Shopify order %1 has %2 open pickup fulfillment orders. Unable to determine which one to process.', Comment = '%1=Shopify Order Id,%2=Fulfillment Orders';
    begin
        case FulfillmentOrderIds.Count of
            0:
                Error(NoFulfilmentOrdErr, NcTask."Record Value");
            1:
                FulfillmentOrderID := FulfillmentOrderIds.Get(1);
            else
                Error(MoreFulfilmentOrdErr, NcTask."Record Value", FulfillmentOrderIds.Count);
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

    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyCommunicationHandler: Codeunit "NPR Spfy Communication Handler";
}
#endif
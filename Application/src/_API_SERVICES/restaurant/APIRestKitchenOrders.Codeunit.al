#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248638 "NPR API Rest. Kitchen Orders"
{
    Access = Internal;

    procedure GetKitchenOrders(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        Restaurant: Record "NPR NPRE Restaurant";
        JsonArray: Codeunit "NPR JSON Builder";
        Params: Dictionary of [Text, Text];
        RestaurantId: Guid;
        StatusFilter: Text;
        PageSize: Integer;
        PageContinuation: Boolean;
        RecRef: RecordRef;
        DataFound: Boolean;
        MoreRecords: Boolean;
        Itt: Integer;
        PageKey: Text;
        JObject: JsonObject;
        OrderStatusEnum: Enum "NPR NPRE Kitchen Order Status";
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());
        Params := Request.QueryParams();

        if not Evaluate(RestaurantId, Request.Paths().Get(2)) then
            exit(Response.RespondBadRequest('Invalid restaurantId format'));

        Restaurant.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Restaurant.GetBySystemId(RestaurantId) then
            exit(Response.RespondResourceNotFound());

        // Set filters
        KitchenOrder.ReadIsolation := IsolationLevel::ReadCommitted;
        KitchenOrder.SetRange("Restaurant Code", Restaurant.Code);

        // Optional status filter
        if Params.ContainsKey('status') then begin
            StatusFilter := Params.Get('status');
            if StatusFilter <> '' then begin
                if not Enum::"NPR NPRE Kitchen Order Status".Names().Contains(StatusFilter) then
                    exit(Response.RespondBadRequest(StrSubstNo('Invalid status filter value: %1', StatusFilter)));
                OrderStatusEnum := Enum::"NPR NPRE Kitchen Order Status".FromInteger(Enum::"NPR NPRE Kitchen Order Status".Ordinals().Get(Enum::"NPR NPRE Kitchen Order Status".Names().IndexOf(StatusFilter)));
                KitchenOrder.SetFilter("Order Status", '=%1', OrderStatusEnum);
            end
        end;

        // Pagination with pageKey
        if Params.ContainsKey('pageSize') then
            Evaluate(PageSize, Params.Get('pageSize'))
        else
            PageSize := 50;

        if PageSize > 100 then
            PageSize := 100;
        if PageSize < 1 then
            PageSize := 1;

        if Params.ContainsKey('pageKey') then begin
            KitchenOrder.Reset();
            RecRef.GetTable(KitchenOrder);
            Request.ApplyPageKey(Params.Get('pageKey'), RecRef);
            RecRef.SetTable(KitchenOrder);
            PageContinuation := true;
        end;

        KitchenOrder.SetLoadFields(
            "Order ID",
            "Restaurant Code",
            "Order Status",
            Priority,
            "Created Date-Time",
            "Expected Dine Date-Time",
            "Finished Date-Time",
            "On Hold"
        );

        KitchenOrder.SetCurrentKey("Restaurant Code", "Order Status", Priority, "Created Date-Time");
        KitchenOrder.SetAscending("Created Date-Time", false);

        JsonArray.StartArray();

        if PageContinuation then
            DataFound := KitchenOrder.Find('>')
        else
            DataFound := KitchenOrder.Find('-');

        if DataFound then
            repeat
                JsonArray.StartObject('')
                    .AddProperty('orderId', Format(KitchenOrder.SystemId, 0, 4).ToLower())
                    .AddProperty('orderNo', KitchenOrder."Order ID")
                    .AddProperty('restaurantCode', KitchenOrder."Restaurant Code")
                    .AddProperty('status', Format(KitchenOrder."Order Status"))
                    .AddProperty('priority', KitchenOrder.Priority)
                    .AddProperty('createdDateTime', Format(KitchenOrder."Created Date-Time", 0, 9))
                    .AddProperty('expectedDineDateTime', Format(KitchenOrder."Expected Dine Date-Time", 0, 9))
                    .AddProperty('finishedDateTime', Format(KitchenOrder."Finished Date-Time", 0, 9))
                    .AddProperty('onHold', KitchenOrder."On Hold")
                .EndObject();
                Itt += 1;
                if Itt = PageSize then begin
                    RecRef.GetTable(KitchenOrder);
                    PageKey := Request.GetPageKey(RecRef);
                end;
                MoreRecords := KitchenOrder.Next() <> 0;
            until (not MoreRecords) or (Itt = PageSize);

        JsonArray.EndArray();

        JObject.Add('morePages', MoreRecords);
        JObject.Add('nextPageKey', PageKey);
        JObject.Add('nextPageURL', Request.GetNextPageUrl(PageKey));
        JObject.Add('data', JsonArray.BuildAsArray());

        exit(Response.RespondOK(JObject));
    end;

    procedure GetKitchenOrder(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        Restaurant: Record "NPR NPRE Restaurant";
        Json: Codeunit "NPR JSON Builder";
        RestaurantId: Guid;
        OrderId: Guid;
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        if not Evaluate(RestaurantId, Request.Paths().Get(2)) then
            exit(Response.RespondBadRequest('Invalid restaurantId format'));

        if not Evaluate(OrderId, Request.Paths().Get(4)) then
            exit(Response.RespondBadRequest('Invalid orderId format'));

        Restaurant.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Restaurant.GetBySystemId(RestaurantId) then
            exit(Response.RespondResourceNotFound());

        KitchenOrder.ReadIsolation := IsolationLevel::ReadCommitted;
        KitchenOrder.SetLoadFields(
            "Order ID",
            "Restaurant Code",
            "Order Status",
            Priority,
            "Created Date-Time",
            "Expected Dine Date-Time",
            "Finished Date-Time",
            "On Hold"
        );
        if not KitchenOrder.GetBySystemId(OrderId) then
            exit(Response.RespondResourceNotFound());

        if KitchenOrder."Restaurant Code" <> Restaurant.Code then
            exit(Response.RespondResourceNotFound());

        Json.StartObject('')
            .AddProperty('orderId', Format(KitchenOrder.SystemId, 0, 4).ToLower())
            .AddProperty('orderNo', KitchenOrder."Order ID")
            .AddProperty('restaurantCode', KitchenOrder."Restaurant Code")
            .AddProperty('status', Format(KitchenOrder."Order Status"))
            .AddProperty('priority', KitchenOrder.Priority)
            .AddProperty('createdDateTime', Format(KitchenOrder."Created Date-Time", 0, 9))
            .AddProperty('expectedDineDateTime', Format(KitchenOrder."Expected Dine Date-Time", 0, 9))
            .AddProperty('finishedDateTime', Format(KitchenOrder."Finished Date-Time", 0, 9))
            .AddProperty('onHold', KitchenOrder."On Hold")
        .EndObject();

        exit(Response.RespondOK(Json.Build()));
    end;

    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR NPRE Kitchen Order");
    end;
}

#endif

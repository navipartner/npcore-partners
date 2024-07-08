codeunit 6184836 "NPR KDS Frontend Assist. Impl."
{
    Access = Internal;

    var
        [Obsolete('We will not need it anymore when we have switched to using the separate KDS API endpoints decoupled from Dragonglass', 'NPR35.0')]
        _SkipServerIDCheck: Boolean;

    internal procedure RefreshCustomerDisplayKitchenOrders(restaurantId: Text; lastServerId: Text) Response: JsonObject
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        TempRestaurant: Record "NPR NPRE Restaurant" temporary;
        KitchenOrderList: JsonArray;
        KitchenOrderContent: JsonObject;
    begin
        CheckServerID(lastServerId);
        GetRestaurantList(restaurantId, TempRestaurant);

        KitchenOrder.SetCurrentKey("Restaurant Code", "Order Status", Priority, "Created Date-Time");
        KitchenOrder.SetRange("Order Status", KitchenOrder."Order Status"::"Ready for Serving", KitchenOrder."Order Status"::Planned);

        TempRestaurant.FindSet();
        repeat
            KitchenOrder.SetRange("Restaurant Code", TempRestaurant.Code);
            if KitchenOrder.FindSet() then
                repeat
                    Clear(KitchenOrderContent);
                    KitchenOrderContent.Add('restaurantId', KitchenOrder."Restaurant Code");
                    KitchenOrderContent.Add('orderId', KitchenOrder."Order ID");
                    KitchenOrderContent.Add('orderStatus', KitchenOrder."Order Status".AsInteger());
                    KitchenOrderContent.Add('orderStatusName', StatusEnumValueName(KitchenOrder."Order Status"));
                    KitchenOrderContent.Add('priority', KitchenOrder.Priority);
                    KitchenOrderContent.Add('orderCreatedDT', KitchenOrder."Created Date-Time");
                    KitchenOrderList.Add(KitchenOrderContent);
                until KitchenOrder.Next() = 0;
        until TempRestaurant.Next() = 0;

        Response.Add('orders', KitchenOrderList);
        AddServerIDToResponse(Response);
    end;

    internal procedure RefreshKDSData(restaurantId: Text; stationId: Text; includeFinished: Boolean; startingFrom: DateTime; lastServerId: Text) Response: JsonObject
    begin
        CheckServerID(lastServerId);
        Response.Add('orders', GenerateKDSData(CopyStr(restaurantId, 1, 20), stationId, includeFinished, false, startingFrom));
        AddServerIDToResponse(Response);
    end;

    internal procedure GetFinishedOrders(restaurantId: Text; startingFrom: DateTime; lastServerId: Text) Response: JsonObject
    begin
        CheckServerID(lastServerId);
        Response.Add('orders', GenerateKDSData(CopyStr(restaurantId, 1, 20), '', true, true, startingFrom));
        AddServerIDToResponse(Response);
    end;

    internal procedure GetSetups(lastServerId: Text) Response: JsonObject
    var
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
    begin
        CheckServerID(lastServerId);
        if not RestaurantSetup.Get() then
            RestaurantSetup.Init();
        Response.Add('warningAfterMinutes', RestaurantSetup."Delayed Ord. Threshold 1 (min)");
        Response.Add('errorAfterMinutes', RestaurantSetup."Delayed Ord. Threshold 2 (min)");
        AddServerIDToResponse(Response);
    end;

    internal procedure RunKitchenAction(restaurantId: Text; stationId: Text; kitchenRequestId: BigInteger; orderId: BigInteger; KitchenActionToRun: Option "Accept Change","Set Production Not Started","Start Production","End Production","Set OnHold","Resume","Set Served","Revoke Serving"; lastServerId: Text) Response: JsonObject
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        KitchenRequest: Record "NPR NPRE Kitchen Request";
        KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station";
        KitchenOrderMgt: Codeunit "NPR NPRE Kitchen Order Mgt.";
        RestaurantCode: Code[20];
        MissingContextParamErr: label 'Either ''kitchenRequestId'' or ''orderId'' must be specified.';
    begin
        if (orderId = 0) and (kitchenRequestId = 0) then
            Error(MissingContextParamErr);
        CheckServerID(lastServerId);
        RestaurantCode := CopyStr(restaurantId, 1, MaxStrLen(RestaurantCode));

        KitchenOrderMgt.SetHideValidationDialog(true);

        if (KitchenActionToRun In [KitchenActionToRun::"Set OnHold", KitchenActionToRun::"Resume"]) and (KitchenRequestId = 0) and (stationId = '') then begin
            KitchenOrder.Get(OrderID);
            KitchenOrderMgt.SetKitchenOrderOnHold(KitchenOrder, KitchenActionToRun = KitchenActionToRun::"Set OnHold");
            exit;
        end;

        if KitchenRequestId <> 0 then
            KitchenRequest.SetRange("Request No.", KitchenRequestId)
        else
            KitchenRequest.SetRange("Order ID", OrderID);

        if stationId <> '' then begin
            KitchenRequest.SetFilter("Kitchen Station Filter", stationId);
            KitchenRequest.SetRange("Production Restaurant Filter", RestaurantCode);
        end else
            KitchenRequest.SetRange("Restaurant Code", RestaurantCode);
        case KitchenActionToRun of
            KitchenActionToRun::"Set Served":
                KitchenRequest.SetRange("Line Status", KitchenRequest."Line Status"::"Ready for Serving", KitchenRequest."Line Status"::Planned);
            KitchenActionToRun::"Revoke Serving":
                KitchenRequest.SetRange("Line Status", KitchenRequest."Line Status"::Served);
        end;

        if KitchenRequest.FindSet(true) then
            repeat
                case KitchenActionToRun of
                    KitchenActionToRun::"Accept Change",
                    KitchenActionToRun::"Set Production Not Started",
                    KitchenActionToRun::"Start Production",
                    KitchenActionToRun::"End Production",
                    KitchenActionToRun::"Set OnHold",
                    KitchenActionToRun::"Resume":
                        begin
                            GetRequestStations(KitchenRequest, KitchenRequestStation);
                            if KitchenRequestStation.FindSet(true) then
                                repeat
                                    case KitchenActionToRun of
                                        KitchenActionToRun::"Accept Change":
                                            KitchenOrderMgt.AcceptQtyChange(KitchenRequestStation);
                                        KitchenActionToRun::"Set Production Not Started":
                                            KitchenOrderMgt.SetProductionNotStarted(KitchenRequest, KitchenRequestStation);
                                        KitchenActionToRun::"Start Production":
                                            KitchenOrderMgt.StartProduction(KitchenRequest, KitchenRequestStation);
                                        KitchenActionToRun::"End Production":
                                            KitchenOrderMgt.EndProduction(KitchenRequestStation);
                                        KitchenActionToRun::"Set OnHold",
                                        KitchenActionToRun::"Resume":
                                            KitchenOrderMgt.SetKitchenRequestStationOnHold(KitchenRequestStation, KitchenActionToRun = KitchenActionToRun::"Set OnHold", true);
                                    end;
                                until KitchenRequestStation.Next() = 0;
                        end;

                    KitchenActionToRun::"Set Served":
                        KitchenOrderMgt.SetRequestLineAsServed(KitchenRequest);
                    KitchenActionToRun::"Revoke Serving":
                        KitchenOrderMgt.RevokeServingForRequestLine(KitchenRequest);
                end;
            until KitchenRequest.Next() = 0;
        AddServerIDToResponse(Response);
    end;

    internal procedure CreateOrderReadyNotifications(orderId: BigInteger; lastServerId: Text) Response: JsonObject
    var
        KitchenOrder: Record "NPR NPRE Kitchen Order";
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
    begin
        CheckServerID(lastServerId);
        KitchenOrder.Get(orderId);
        NotificationHandler.CreateOrderNotifications(KitchenOrder, "NPR NPRE Notification Trigger"::KDS_ORDER_READY_FOR_SERVING, 0DT);
        AddServerIDToResponse(Response);
    end;

    local procedure GetRestaurantList(restaurantId: Text; var TempRestaurant: Record "NPR NPRE Restaurant")
    var
        Restaurant: Record "NPR NPRE Restaurant";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
        RestaurantCode: Code[20];
    begin
        if not TempRestaurant.IsTemporary() then
            SetupProxy.ThrowNonTempException('CU6150679.GetRestaurantList');
        Clear(TempRestaurant);
        TempRestaurant.DeleteAll();

        RestaurantCode := CopyStr(restaurantId, 1, MaxStrLen(RestaurantCode));
        if RestaurantCode <> '' then begin
            Restaurant.Get(RestaurantCode);
            TempRestaurant := Restaurant;
            TempRestaurant.Insert();
        end else
            SetupProxy.GetRestaurantList(TempRestaurant);
    end;

    local procedure GenerateKDSData(RestaurantCode: Code[20]; KitchenStationFilter: Text; IncludeFinished: Boolean; FinishedOnly: Boolean; StartingFromDT: DateTime) Orders: JsonArray
    var
        NotificationEntry: Record "NPR NPRE Notification Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotificationHandler: Codeunit "NPR NPRE Notification Handler";
        KitchenReqStationsQry: Query "NPR NPRE Kitchen Req. Stations";
        CustomerDetailsDic: Dictionary of [Text, List of [Text]];
        KitchenRequests: JsonArray;
        KitchenStations: JsonArray;
        KitchenRequest: JsonObject;
        KitchenStation: JsonObject;
        OrderHdr: JsonObject;
        NullJsonValue: JsonValue;
        LastOrderID: BigInteger;
        LastRequestNo: BigInteger;
    begin
        if IncludeFinished or FinishedOnly then begin
            if StartingFromDT = 0DT then
                StartingFromDT := CurrentDateTime() - JobQueueMgt.DaysToDuration(3);
            if FinishedOnly then
                KitchenReqStationsQry.SetFilter(Finished_Date_Time, '%1..', StartingFromDT)
            else
                KitchenReqStationsQry.SetFilter(Created_DateTime, '%1..', StartingFromDT);
        end else
            KitchenReqStationsQry.SetRange(Order_Status, "NPR NPRE Kitchen Order Status"::"Ready for Serving", "NPR NPRE Kitchen Order Status"::Planned);
        if KitchenStationFilter <> '' then begin
            KitchenReqStationsQry.SetRange(Production_Restaurant_Code, RestaurantCode);
            KitchenReqStationsQry.SetFilter(Kitchen_Station, KitchenStationFilter);
            if not (IncludeFinished or FinishedOnly) then
                KitchenReqStationsQry.SetRange(Station_Production_Status, "NPR NPRE K.Req.L. Prod.Status"::"Not Started", "NPR NPRE K.Req.L. Prod.Status"::"On Hold");
        end else
            KitchenReqStationsQry.SetRange(Restaurant_Code, RestaurantCode);
        KitchenReqStationsQry.SetFilter(Line_Status, '<>%1', "NPR NPRE K.Request Line Status"::Cancelled);
        KitchenReqStationsQry.Open();

        LastOrderID := 0;
        NullJsonValue.SetValueToNull();
        while KitchenReqStationsQry.Read() do begin
            //Kitchen order header
            if LastOrderID <> KitchenReqStationsQry.Order_ID then begin
                if LastOrderID <> 0 then begin
                    if LastRequestNo <> 0 then
                        FinishKitchenRequest(KitchenRequest, KitchenStations, KitchenRequests);
                    FinishOrder(OrderHdr, KitchenRequests, CustomerDetailsDic, Orders);
                end;
                LastRequestNo := 0;
                LastOrderID := KitchenReqStationsQry.Order_ID;

                Clear(OrderHdr);
                Clear(KitchenRequests);
                Clear(CustomerDetailsDic);
                OrderHdr.Add('orderId', KitchenReqStationsQry.Order_ID);
                OrderHdr.Add('restaurantId', KitchenReqStationsQry.Restaurant_Code);
                OrderHdr.Add('orderStatus', KitchenReqStationsQry.Order_Status.AsInteger());
                OrderHdr.Add('orderStatusName', StatusEnumValueName(KitchenReqStationsQry.Order_Status));
                OrderHdr.Add('priority', KitchenReqStationsQry.Order_Priority);
                OrderHdr.Add('orderCreatedDT', KitchenReqStationsQry.Created_DateTime);
                if KitchenReqStationsQry.Finished_Date_Time <> 0DT then
                    OrderHdr.Add('orderFinishedDT', KitchenReqStationsQry.Finished_Date_Time)
                else
                    OrderHdr.Add('orderFinishedDT', NullJsonValue);
                if KitchenReqStationsQry.Expected_Dine_DateTime <> 0DT then
                    OrderHdr.Add('orderExpectedDineDT', KitchenReqStationsQry.Expected_Dine_DateTime)
                else
                    OrderHdr.Add('orderExpectedDineDT', NullJsonValue);
                if NotificationHandler.FindLastOrderReadyNotification(KitchenReqStationsQry.Order_ID, "NPR NPRE Notif. Recipient"::CUSTOMER, NotificationEntry) then
                    OrderHdr.Add('orderReadyNotifStatusName', StatusEnumValueName(NotificationEntry."Notification Send Status"))
                else
                    OrderHdr.Add('orderReadyNotifStatusName', NullJsonValue);
            end;

            //Kitchen order line
            if LastRequestNo <> KitchenReqStationsQry.Request_No then begin
                if LastRequestNo <> 0 then
                    FinishKitchenRequest(KitchenRequest, KitchenStations, KitchenRequests);
                LastRequestNo := KitchenReqStationsQry.Request_No;

                Clear(KitchenRequest);
                Clear(KitchenStations);
                KitchenRequest.Add('requestId', KitchenReqStationsQry.Request_No);
                KitchenRequest.Add('lineStatus', KitchenReqStationsQry.Line_Status.AsInteger());
                KitchenRequest.Add('lineStatusName', StatusEnumValueName(KitchenReqStationsQry.Line_Status));
                KitchenRequest.Add('productionStatus', KitchenReqStationsQry.Production_Status.AsInteger());
                KitchenRequest.Add('productionStatusName', StatusEnumValueName(KitchenReqStationsQry.Production_Status));
                KitchenRequest.Add('servingStep', KitchenReqStationsQry.Serving_Step);
                KitchenRequest.Add('lineType', KitchenReqStationsQry.Line_Type.AsInteger());
                KitchenRequest.Add('lineTypeName', LineTypeEnumValueName(KitchenReqStationsQry.Line_Type));
                KitchenRequest.Add('itemNo', KitchenReqStationsQry.Item_No);
                KitchenRequest.Add('variantCode', KitchenReqStationsQry.Variant_Code);
                KitchenRequest.Add('lineDescription', KitchenReqStationsQry.Description);
                KitchenRequest.Add('quantity', KitchenReqStationsQry.Quantity);
                KitchenRequest.Add('UoM', KitchenReqStationsQry.Unit_of_Measure_Code);
                KitchenRequest.Add('lineModifiers', AddItemAddonsAndComments(KitchenReqStationsQry.Request_No));
                RetrieveCustomerDetails(KitchenReqStationsQry.Request_No, CustomerDetailsDic);
            end;

            //Kitchen order line station
            Clear(KitchenStation);
            KitchenStation.Add('entryId', KitchenReqStationsQry.KitchenReqStation_SystemId);
            KitchenStation.Add('productionRestaurantId', KitchenReqStationsQry.Production_Restaurant_Code);
            KitchenStation.Add('productionStep', KitchenReqStationsQry.Kitchen_Station);
            KitchenStation.Add('stationId', KitchenReqStationsQry.Kitchen_Station);
            KitchenStation.Add('stationProductionStatus', KitchenReqStationsQry.Station_Production_Status.AsInteger());
            KitchenStation.Add('stationProductionStatusName', StatusEnumValueName(KitchenReqStationsQry.Station_Production_Status));
            KitchenStations.Add(KitchenStation);
        end;
        KitchenReqStationsQry.Close();

        if LastOrderID <> 0 then begin
            if LastRequestNo <> 0 then
                FinishKitchenRequest(KitchenRequest, KitchenStations, KitchenRequests);
            FinishOrder(OrderHdr, KitchenRequests, CustomerDetailsDic, Orders);
        end;
    end;

    local procedure AddItemAddonsAndComments(KitchenRequestNo: BigInteger) LineModifiers: JsonArray
    var
        KitchenRequestModifier: Record "NPR NPRE Kitchen Req. Modif.";
        Line: JsonObject;
    begin
        Clear(LineModifiers);
        KitchenRequestModifier.SetRange("Request No.", KitchenRequestNo);
        if KitchenRequestModifier.FindSet() then
            repeat
                Clear(Line);
                Line.Add('type', LineTypeEnumValueName(KitchenRequestModifier."Line Type"));
                Line.Add('itemNo', KitchenRequestModifier."No.");
                Line.Add('variantCode', KitchenRequestModifier."Variant Code");
                Line.Add('lineDescription', KitchenRequestModifier.Description);
                Line.Add('lineDescription2', KitchenRequestModifier."Description 2");
                Line.Add('quantity', KitchenRequestModifier.Quantity);
                Line.Add('UoM', KitchenRequestModifier."Unit of Measure Code");
                Line.Add('indentation', KitchenRequestModifier.Indentation);
                LineModifiers.Add(Line);
            until KitchenRequestModifier.Next() = 0;
    end;

    local procedure RetrieveCustomerDetails(KitchenRequestNo: BigInteger; var CustomerDetailsDic: Dictionary of [Text, List of [Text]])
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        KitchReqSrcbyDoc: Query "NPR NPRE Kitch.Req.Src. by Doc";
        CustomerEmailTok: Label 'customerEmail', Locked = true;
        CustomerNameTok: Label 'customerName', Locked = true;
        CustomerPhoneNoTok: Label 'customerPhoneNo', Locked = true;
    begin
        KitchReqSrcbyDoc.SetRange(Request_No_, KitchenRequestNo);
        KitchReqSrcbyDoc.SetFilter(QuantityBase, '<>%1', 0);
        if not KitchReqSrcbyDoc.Open() then
            exit;
        while KitchReqSrcbyDoc.Read() do
            case KitchReqSrcbyDoc.Source_Document_Type of
                KitchReqSrcbyDoc.Source_Document_Type::"Waiter Pad":
                    if WaiterPad.Get(KitchReqSrcbyDoc.Source_Document_No_) then begin
                        AddCustomerDetailToDict(CustomerNameTok, WaiterPad.Description, CustomerDetailsDic);
                        AddCustomerDetailToDict(CustomerPhoneNoTok, WaiterPad."Customer Phone No.", CustomerDetailsDic);
                        AddCustomerDetailToDict(CustomerEmailTok, WaiterPad."Customer E-Mail", CustomerDetailsDic);
                    end;
            end;
        KitchReqSrcbyDoc.Close();
    end;


    local procedure AddCustomerDetailToDict("Key": Text; "Value": Text; var CustomerDetailsDic: Dictionary of [Text, List of [Text]])
    var
        CustomerInfoValues: List of [Text];
    begin
        if "Value" = '' then
            exit;
        if not CustomerDetailsDic.ContainsKey("Key") then begin
            CustomerInfoValues.Add("Value");
            CustomerDetailsDic.Add("Key", CustomerInfoValues);
        end else
            if not CustomerDetailsDic.Get("Key").Contains("Value") then
                CustomerDetailsDic.Get("Key").Add("Value");
    end;

    local procedure FinishKitchenRequest(KitchenRequest: JsonObject; KitchenStations: JsonArray; var KitchenRequests: JsonArray)
    begin
        KitchenRequest.Add('kitchenStations', KitchenStations);
        KitchenRequests.Add(KitchenRequest);
    end;

    local procedure FinishOrder(OrderHdr: JsonObject; KitchenRequests: JsonArray; CustomerDetailsDic: Dictionary of [Text, List of [Text]]; Orders: JsonArray)
    var
        CustomerInfoKey: Text;
        CustomerInfoValues: List of [Text];
    begin
        foreach CustomerInfoKey in CustomerDetailsDic.Keys() do
            if CustomerDetailsDic.Get(CustomerInfoKey, CustomerInfoValues) then
                OrderHdr.Add(CustomerInfoKey, ListToText(CustomerInfoValues));
        OrderHdr.Add('kitchenRequests', KitchenRequests);
        Orders.Add(OrderHdr);
    end;

    local procedure ListToText(CustomerInfoValues: List of [Text]): Text
    var
        CustomerInfoValue: Text;
        CustomerInfoValueString: Text;
    begin
        foreach CustomerInfoValue in CustomerInfoValues do
            if CustomerInfoValue <> '' then begin
                if CustomerInfoValueString <> '' then
                    CustomerInfoValueString := CustomerInfoValueString + ', ';
                CustomerInfoValueString := CustomerInfoValueString + CustomerInfoValue;
            end;
        exit(CustomerInfoValueString);
    end;

    local procedure StatusEnumValueName(OrderStatus: Enum "NPR NPRE Kitchen Order Status") Result: Text
    begin
        OrderStatus.Names().Get(OrderStatus.Ordinals().IndexOf(OrderStatus.AsInteger()), Result);
    end;

    local procedure StatusEnumValueName(LineStatus: Enum "NPR NPRE K.Request Line Status") Result: Text
    begin
        LineStatus.Names().Get(LineStatus.Ordinals().IndexOf(LineStatus.AsInteger()), Result);
    end;

    local procedure StatusEnumValueName(ProductionStatus: Enum "NPR NPRE K.Req.L. Prod.Status") Result: Text
    begin
        ProductionStatus.Names().Get(ProductionStatus.Ordinals().IndexOf(ProductionStatus.AsInteger()), Result);
    end;

    local procedure StatusEnumValueName(NotificationSendStatus: Enum "NPR NPRE Notification Status") Result: Text
    begin
        NotificationSendStatus.Names().Get(NotificationSendStatus.Ordinals().IndexOf(NotificationSendStatus.AsInteger()), Result);
    end;

    local procedure LineTypeEnumValueName(LineType: Enum "NPR POS Sale Line Type") Result: Text
    begin
        LineType.Names().Get(LineType.Ordinals().IndexOf(LineType.AsInteger()), Result);
    end;

    local procedure GetRequestStations(var KitchenRequest: Record "NPR NPRE Kitchen Request"; var KitchenRequestStation: Record "NPR NPRE Kitchen Req. Station")
    begin
        KitchenRequestStation.Reset();
        KitchenRequestStation.SetRange("Request No.", KitchenRequest."Request No.");
        KitchenRequest.CopyFilter("Production Restaurant Filter", KitchenRequestStation."Production Restaurant Code");
        KitchenRequest.CopyFilter("Kitchen Station Filter", KitchenRequestStation."Kitchen Station");
    end;

    local procedure CheckServerID(lastServerId: Text)
    begin
        if _SkipServerIDCheck then
            exit;
        //Unlike control addin requests, inbound webservice requests can be load balanced across multiple NSTs meaning the cache sync delay can lead to invisible records.
        if (lastServerId = '') or (lastServerId <> Format(ServiceInstanceId())) then
            SelectLatestVersion();
    end;

    local procedure AddServerIDToResponse(var Response: JsonObject)
    begin
        Response.Add('serverId', Format(ServiceInstanceId()));
    end;

    [Obsolete('We will not need it anymore when we have switched to using the separate KDS API endpoints decoupled from Dragonglass', 'NPR35.0')]
    internal procedure SetSkipServerIDCheck(Skip: Boolean)
    begin
        _SkipServerIDCheck := Skip;
    end;
}
#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248579 "NPR Spfy Order Import JQ"
{
    Access = Internal;
    Permissions = tabledata "NPR Spfy Store" = r, tabledata "NPR Spfy Data Sync. Pointer" = rim;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        StartTime: DateTime;
        StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]];
        MaxDuration: Duration;
    begin
        if not SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns") then
            SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::"Sales Orders", '');
        StartTime := CurrentDateTime();
        LastStoresReload := CurrentDateTime() - 6 * 60000;
        MaxDuration := JobQueueManagement.HoursToDuration(1);
        InitGlobals();
        repeat
            if EcomJobManagement.ShouldSoftExit(Rec.ID) then
                exit;
            if (CurrentDateTime() - LastStoresReload) > (5 * 60000) then
                LoadEnabledStores(StoresDict);

            Process(StoresDict);
            Commit();
            if Rec."Recurring Job" then
                Sleep(1000);
        until not Rec."Recurring Job" or EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);

        FinalizeMarkers(StoresDict);
    end;

    internal procedure Process(StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]])
    var
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
    begin
        ShopifyStore.SetAutoCalcFields("Last Orders Imported At (FF)", "Last Returns Imported At (FF)");
        foreach StoreCode in StoresDict.Keys() do begin
            ShopifyStore.ReadIsolation := IsolationLevel::ReadCommitted;
            ShopifyStore.Get(StoreCode);
            ProcessStore(ShopifyStore, StoresDict.Get(StoreCode));
        end;
    end;

    local procedure LoadEnabledStores(var StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]])
    var
        ShopifyStore: Record "NPR Spfy Store";
        AreaEnabled: Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean];
    begin
        Clear(StoresDict);
        ShopifyStore.SetCurrentKey(Enabled);
        ShopifyStore.SetRange(Enabled, true);
        if ShopifyStore.FindSet() then
            repeat
                if not StoresDict.ContainsKey(ShopifyStore.Code) then begin
                    AreaEnabled := GetEnabledImportAreas(ShopifyStore);
                    if AreaEnabledFor(AreaEnabled, "NPR SpfyEventLogDocType"::Order) or AreaEnabledFor(AreaEnabled, "NPR SpfyEventLogDocType"::"Return Order") then
                        StoresDict.Add(ShopifyStore.Code, AreaEnabled);
                end;
            until ShopifyStore.Next() = 0;
        LastStoresReload := CurrentDateTime();
    end;

    local procedure GetEnabledImportAreas(ShopifyStore: Record "NPR Spfy Store") AreaEnabled: Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]
    begin
        AreaEnabled.Set("NPR SpfyEventLogDocType"::Order, SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", ShopifyStore));
        AreaEnabled.Set("NPR SpfyEventLogDocType"::"Return Order", SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Returns", ShopifyStore));
    end;

    local procedure AreaEnabledFor(AreaEnabled: Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]; DocType: Enum "NPR SpfyEventLogDocType"): Boolean
    begin
        if AreaEnabled.ContainsKey(DocType) then
            exit(AreaEnabled.Get(DocType));
        exit(false);
    end;

    local procedure ProcessStore(ShopifyStore: Record "NPR Spfy Store"; AreaEnabled: Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean])
    var
        OrderStatus: Enum "NPR SpfyAPIDocumentStatus";
        DocType: Enum "NPR SpfyEventLogDocType";
    begin
        if AreaEnabledFor(AreaEnabled, DocType::Order) then begin
            SetMarkers(ShopifyStore, DocType::Order);
            DownloadOrders(ShopifyStore, OrderStatus::Open);
            if ShopifyStore."Delete on Cancellation" then
                DownloadOrders(ShopifyStore, OrderStatus::Cancelled);
            if ShopifyStore."Post on Completion" then
                DownloadOrders(ShopifyStore, OrderStatus::Closed);
            TryUpdateMarker(ShopifyStore, DocType::Order);
        end;

        if AreaEnabledFor(AreaEnabled, DocType::"Return Order") then begin
            SetMarkers(ShopifyStore, DocType::"Return Order");
            DownloadReturns(ShopifyStore);
            TryUpdateMarker(ShopifyStore, DocType::"Return Order");
        end;
    end;

    local procedure DownloadOrders(ShopifyStore: Record "NPR Spfy Store"; OrderStatus: Enum "NPR SpfyAPIDocumentStatus")
    var
        OrdersArr: JsonArray;
        ShopifyResponse: JsonToken;
        Cursor: Text;
        HasNext: Boolean;
    begin
        Cursor := '';
        HasNext := true;
        repeat
            if not SpfyAPIOrderHelper.GetOrderList(HasNext, ShopifyResponse, ShopifyStore, OrdersArr, Cursor, OrderStatus, GetFromDT(ShopifyStore, "NPR SpfyEventLogDocType"::Order)) then begin
                LogError(GetLastErrorText(), ShopifyStore.Code, "NPR SpfyEventLogDocType"::Order);
                exit;
            end;
            if OrdersArr.Count = 0 then
                exit;
            if ProcessList(OrdersArr, OrderStatus, ShopifyStore) then
                Commit();
        until not HasNext;
    end;

    local procedure ProcessList(OrdersArr: JsonArray; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; ShopifyStore: Record "NPR Spfy Store"): Boolean
    var
        CurrNode: JsonToken;
        OrderTkn: JsonToken;
        OrderGID: Text;
        OrderProcessed: Boolean;
    begin
        foreach OrderTkn in OrdersArr do begin
            OrderTkn.SelectToken('node', CurrNode);
            GetOrderGID(CurrNode, OrderGID);
            if SaveOrder(ShopifyStore, CurrNode, OrderStatus, OrderGID) then
                if ProcessOrder(ShopifyStore, CurrNode, OrderStatus, OrderGID) then
                    OrderProcessed := true;
        end;
        exit(OrderProcessed);
    end;

    internal procedure ProcessOrder(ShopifyStore: Record "NPR Spfy Store"; OrderTkn: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text): Boolean
    begin
        ClearLastError();
        UpdateSessionMax(ShopifyStore.Code, "NPR SpfyEventLogDocType"::Order, JsonHelper.GetJDT(OrderTkn, 'updatedAt', true));
        if InsertShopifyLog(OrderTkn, OrderStatus, "NPR SpfyEventLogDocType"::Order, ShopifyStore) then
            exit(true);
        LogError(GetErrorText(OrderStatus, OrderGID), ShopifyStore.Code, "NPR SpfyEventLogDocType"::Order);
        exit(false);
    end;

    local procedure DownloadReturns(ShopifyStore: Record "NPR Spfy Store")
    var
        OrdersArr: JsonArray;
        ShopifyResponse: JsonToken;
        Cursor: Text;
        HasNext: Boolean;
    begin
        Cursor := '';
        HasNext := true;
        repeat
            if not SpfyAPIOrderHelper.GetReturnList(HasNext, ShopifyResponse, ShopifyStore, OrdersArr, Cursor, GetFromDT(ShopifyStore, "NPR SpfyEventLogDocType"::"Return Order")) then begin
                LogError(GetLastErrorText(), ShopifyStore.Code, "NPR SpfyEventLogDocType"::"Return Order");
                exit;
            end;
            if OrdersArr.Count = 0 then
                exit;
            if ProcessReturnList(OrdersArr, ShopifyStore) then
                Commit();
        until not HasNext;
    end;

    local procedure ProcessReturnList(OrdersArr: JsonArray; ShopifyStore: Record "NPR Spfy Store"): Boolean
    var
        OrderTkn: JsonToken;
        OrderNode: JsonToken;
        ReturnsNode: JsonToken;
        ReturnProcessed: Boolean;
    begin
        foreach OrderTkn in OrdersArr do begin
            OrderTkn.SelectToken('node', OrderNode);
            UpdateSessionMax(ShopifyStore.Code, "NPR SpfyEventLogDocType"::"Return Order", JsonHelper.GetJDT(OrderNode, 'updatedAt', true));
            if OrderNode.SelectToken('returns', ReturnsNode) then
                if ProcessOrderReturns(ShopifyStore, JsonHelper.GetJText(OrderNode, 'id', true), ReturnsNode) then
                    ReturnProcessed := true;
        end;
        exit(ReturnProcessed);
    end;

    local procedure ProcessOrderReturns(ShopifyStore: Record "NPR Spfy Store"; OrderGID: Text; ReturnsNode: JsonToken) ReturnProcessed: Boolean
    var
        ReturnsEdges: JsonToken;
        ReturnsArr: JsonArray;
        Cursor: Text;
        HasNext: Boolean;
    begin
        // First page: the returns connection is embedded in the orders-list response.
        if ReturnsNode.SelectToken('edges', ReturnsEdges) and ReturnsEdges.IsArray() then
            if ProcessReturnEdges(ShopifyStore, ReturnsEdges.AsArray()) then
                ReturnProcessed := true;
        // Remaining pages (rare: an order with more closed returns than the page size). Fetch and process them all so none are dropped.
        HasNext := JsonHelper.GetJBoolean(ReturnsNode, 'pageInfo.hasNextPage', false);
        Cursor := JsonHelper.GetJText(ReturnsNode, 'pageInfo.endCursor', false);
        while HasNext do begin
            if not SpfyAPIOrderHelper.GetOrderReturns(ShopifyStore, OrderGID, Cursor, HasNext, ReturnsArr) then begin
                LogError(GetReturnErrorText(OrderGID), ShopifyStore.Code, "NPR SpfyEventLogDocType"::"Return Order");
                exit;
            end;
            if ProcessReturnEdges(ShopifyStore, ReturnsArr) then
                ReturnProcessed := true;
        end;
    end;

    local procedure ProcessReturnEdges(ShopifyStore: Record "NPR Spfy Store"; ReturnsArr: JsonArray) ReturnProcessed: Boolean
    var
        ReturnEdge: JsonToken;
        ReturnNode: JsonToken;
    begin
        foreach ReturnEdge in ReturnsArr do begin
            ReturnEdge.SelectToken('node', ReturnNode);
            if ProcessReturn(ShopifyStore, ReturnNode) then
                ReturnProcessed := true;
        end;
    end;

    local procedure ProcessReturn(ShopifyStore: Record "NPR Spfy Store"; ReturnNode: JsonToken): Boolean
    var
        ReturnGID: Text;
    begin
        ClearLastError();
        ReturnGID := JsonHelper.GetJText(ReturnNode, 'id', true);
        if not ValidateReturn(ShopifyStore, ReturnNode, ReturnGID) then
            exit(false);
        if InsertShopifyLog(ReturnNode, "NPR SpfyAPIDocumentStatus"::Closed, "NPR SpfyEventLogDocType"::"Return Order", ShopifyStore) then
            exit(true);
        LogError(GetReturnErrorText(ReturnGID), ShopifyStore.Code, "NPR SpfyEventLogDocType"::"Return Order");
        exit(false);
    end;

    local procedure ValidateReturn(ShopifyStore: Record "NPR Spfy Store"; ReturnNode: JsonToken; ReturnGID: Text): Boolean
    var
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
        ReturnId: Text[30];
    begin
        ClearLastError();
        if not TryGetReturnId(ReturnNode, ReturnId) then begin
            LogError(GetReturnErrorText(ReturnGID), ShopifyStore.Code, "NPR SpfyEventLogDocType"::"Return Order");
            exit(false);
        end;
        if SpfyAPIEventLogMgt.LogEntryExist(ReturnId, "NPR SpfyAPIDocumentStatus"::Closed, ShopifyStore.Code, "NPR SpfyEventLogDocType"::"Return Order") then
            exit(false);
        exit(true);
    end;

    [TryFunction]
    local procedure TryGetReturnId(ReturnNode: JsonToken; var ReturnId: Text[30])
    begin
        ReturnId := OrderMgt.GetNumericId(JsonHelper.GetJText(ReturnNode, 'id', true));
    end;

    local procedure GetReturnErrorText(ReturnGID: Text) ErrMsg: Text
    var
        FullReturnTxt: Label 'Import Return %1 failed with error: %2', Comment = '%1=Return GID; %2=GetLastErrorText()', Locked = true;
    begin
        ErrMsg := StrSubstNo(FullReturnTxt, ReturnGID, GetLastErrorText());
    end;
    #region markers 
    /// <summary>
    /// InitialFromDT[StoreCode|DocType] 
    ///   The baseline timestamp read from the database (“Last Orders / Last Returns Imported At”). 
    ///   Used as the starting point for updatedAt filtering during this JQ cycle.
    /// SessionMaxUpdatedAt[StoreCode|DocType] 
    ///   Tracks the highest updatedAt value encountered during this JQ cycle. 
    ///   This value becomes the new “Last Orders / Last Returns Imported At” when the marker is updated.
    /// LastMarkerUpdate[StoreCode|DocType] 
    ///   Records the last time the marker was written to the database. 
    ///   Used to control periodic marker updates and reduce database write frequency.
    ///ErrorsSinceLastMarker[StoreCode|DocType] 
    ///   Marker to track for any errors and prevent “Last Orders / Last Returns Imported At” from being updated is error exists.
    /// </summary>
    local procedure SetMarkers(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType")
    var
        FromDT: DateTime;
        MarkerKeyTxt: Text;
    begin
        MarkerKeyTxt := MarkerKey(ShopifyStore.Code, DocType);
        if not InitialFromDT.ContainsKey(MarkerKeyTxt) then begin
            case DocType of
                DocType::Order:
                    FromDT := ShopifyStore."Last Orders Imported At (FF)";
                DocType::"Return Order":
                    FromDT := ShopifyStore."Last Returns Imported At (FF)";
                else
                    DocTypeNotSupported(DocType);
            end;
            if FromDT = 0DT then
                FromDT := GetImportStartFromDT(ShopifyStore, DocType);
            InitialFromDT.Add(MarkerKeyTxt, FromDT);
        end;

        if not SessionMaxUpdatedAt.ContainsKey(MarkerKeyTxt) then
            SessionMaxUpdatedAt.Add(MarkerKeyTxt, InitialFromDT.Get(MarkerKeyTxt));

        if not LastMarkerUpdate.ContainsKey(MarkerKeyTxt) then
            LastMarkerUpdate.Add(MarkerKeyTxt, CurrentDateTime());

        if not ErrorsSinceLastMarker.ContainsKey(MarkerKeyTxt) then
            ErrorsSinceLastMarker.Add(MarkerKeyTxt, false);
    end;

    local procedure TryUpdateMarker(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType")
    var
        SpfyStore: Record "NPR Spfy Store";
        NowDT: DateTime;
        MarkerKeyTxt: Text;
    begin
        MarkerKeyTxt := MarkerKey(ShopifyStore.Code, DocType);
        NowDT := CurrentDateTime();
        if (NowDT - LastMarkerUpdate.Get(MarkerKeyTxt)) < (5 * 60000) then
            exit;
        if ErrorsSinceLastMarker.Get(MarkerKeyTxt) then
            exit;
        SpfyStore.ReadIsolation := IsolationLevel::UpdLock;
        SpfyStore.Get(ShopifyStore.RecordId);
        UpdateLastImportedAt(SpfyStore, DocType);
        LastMarkerUpdate.Set(MarkerKeyTxt, NowDT);
    end;

    local procedure FinalizeMarkers(StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]])
    var
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
    begin
        foreach StoreCode in StoresDict.Keys() do begin
            ShopifyStore.ReadIsolation := IsolationLevel::ReadCommitted;
            ShopifyStore.Get(StoreCode);
            FinalizeMarker(ShopifyStore, "NPR SpfyEventLogDocType"::Order);
            FinalizeMarker(ShopifyStore, "NPR SpfyEventLogDocType"::"Return Order");
        end;
    end;

    local procedure FinalizeMarker(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType")
    var
        MarkerKeyTxt: Text;
    begin
        MarkerKeyTxt := MarkerKey(ShopifyStore.Code, DocType);
        if not SessionMaxUpdatedAt.ContainsKey(MarkerKeyTxt) then
            exit;
        if ErrorsSinceLastMarker.Get(MarkerKeyTxt) then
            exit;
        UpdateLastImportedAt(ShopifyStore, DocType);
    end;

    local procedure UpdateSessionMax(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"; UpdatedAt: DateTime)
    var
        CurrentMax: DateTime;
        MarkerKeyTxt: Text;
    begin
        MarkerKeyTxt := MarkerKey(StoreCode, DocType);
        CurrentMax := SessionMaxUpdatedAt.Get(MarkerKeyTxt);
        if UpdatedAt > CurrentMax then
            SessionMaxUpdatedAt.Set(MarkerKeyTxt, UpdatedAt);
    end;

    local procedure MarkerKey(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"): Text
    begin
        exit(StrSubstNo('%1|%2', StoreCode, DocType.AsInteger()));
    end;
    #endregion
    local procedure UpdateLastImportedAt(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType")
    var
        SessionMax: DateTime;
    begin
        SessionMax := SessionMaxUpdatedAt.Get(MarkerKey(ShopifyStore.Code, DocType));
        case DocType of
            DocType::Order:
                begin
                    ShopifyStore.CalcFields("Last Orders Imported At (FF)");
                    if ShopifyStore."Last Orders Imported At (FF)" < SessionMax then
                        ShopifyStore.SetLastOrdersImportedAt(SessionMax);
                end;
            DocType::"Return Order":
                begin
                    ShopifyStore.CalcFields("Last Returns Imported At (FF)");
                    if ShopifyStore."Last Returns Imported At (FF)" < SessionMax then
                        ShopifyStore.SetLastReturnsImportedAt(SessionMax);
                end;
            else
                DocTypeNotSupported(DocType);
        end;
        Commit(); // Commit here is required to release UpdLock before next Sleep() iteration
    end;

    local procedure GetOrderGID(OrderTkn: JsonToken; var OrderGID: Text)
    begin
        Clear(OrderGID);
        OrderGID := JsonHelper.GetJText(OrderTkn, 'id', true);
    end;

    local procedure InsertShopifyLog(OrderTkn: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; DocType: Enum "NPR SpfyEventLogDocType"; ShopifyStore: Record "NPR Spfy Store"): Boolean
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        ClearLastError();
        Clear(SpfyEventLogEntry);
        SpfyEventLogEntry."Document Status" := OrderStatus;
        SpfyEventLogEntry."Store Code" := ShopifyStore.Code;
        SpfyEventLogEntry."Document Type" := DocType;
        SpfyEventLogEntry."Not Before Date-Time" := CurrentDateTime();
        exit(SpfyAPIEventLogMgt.InsertShopifyLog(OrderTkn, SpfyEventLogEntry));
    end;

    local procedure LogError(ErrMsg: Text; StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType")
    var
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        EventIdLbl: Label 'NPR_ShopifyAPI_OrderImportFailed', Locked = true;
    begin
        ErrorsSinceLastMarker.Set(MarkerKey(StoreCode, DocType), true);
        SpfyEcomSalesDocPrcssr.EmitMessage(ErrMsg, EventIdLbl);
    end;

    local procedure InitGlobals()
    begin
        Clear(InitialFromDT);
        Clear(SessionMaxUpdatedAt);
        Clear(LastMarkerUpdate);
        Clear(ErrorsSinceLastMarker);
    end;

    local procedure GetFromDT(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType"): DateTime
    var
        MarkerKeyTxt: Text;
    begin
        MarkerKeyTxt := MarkerKey(ShopifyStore.Code, DocType);
        if InitialFromDT.ContainsKey(MarkerKeyTxt) then
            exit(InitialFromDT.Get(MarkerKeyTxt));
        exit(GetImportStartFromDT(ShopifyStore, DocType));
    end;

    local procedure GetImportStartFromDT(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType"): DateTime
    begin
        case DocType of
            DocType::Order:
                exit(GetDefaultFromDT(ShopifyStore));
            DocType::"Return Order":
                begin
                    if ShopifyStore."Get Returns Starting From" <> 0DT then
                        exit(ShopifyStore."Get Returns Starting From");
                    exit(DefaultImportStartDateTime());
                end;
            else
                DocTypeNotSupported(DocType);
        end;
    end;

    local procedure DefaultImportStartDateTime(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(1, 1, 2022), 0T));
    end;

    local procedure GetErrorText(OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text) ErrMsg: Text
    var
        FullOrderTxt: Label 'Import %1 Order %2 failed with error: %3', Comment = '%1= Order Status;%2= Order GID; %3=GetLastErrorText()', Locked = true;
    begin
        ErrMsg := StrSubstNo(FullOrderTxt, Format(OrderStatus), OrderGID, GetLastErrorText());
    end;

    local procedure DocExists(ShopifyStoreCode: Code[20]; OrderId: Text[30]; DocName: Text[100]; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"): Boolean
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        if not ShopifySetup.Get() then
            exit(false);
        if DocName = '' then
            exit(false);
        // check if already processed
        exit(SpfyAPIEventLogMgt.LogEntryExist(OrderId, OrderStatus, ShopifyStoreCode, "NPR SpfyEventLogDocType"::Order));
    end;

    local procedure HasReadyState(ShopifyStore: Record "NPR Spfy Store"; Order: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"): Boolean
    begin
        case OrderStatus of
            OrderStatus::Open:
                exit(SpfyIntegrationMgt.IsAllowedFinancialStatus(JsonHelper.GetJText(Order, 'displayFinancialStatus', false).ToLower(), ShopifyStore.Code));
            OrderStatus::Closed:
                exit(
                    (JsonHelper.GetJDate(Order, 'closedAt', false) >= DT2Date(GetDefaultFromDT(ShopifyStore))) and
                    (JsonHelper.GetJDate(Order, 'cancelledAt', false) = 0D));
            OrderStatus::Cancelled:
                exit(true);
        end;
        exit(false);
    end;

    internal procedure GetDefaultFromDT(ShopifyStore: Record "NPR Spfy Store"): DateTime
    begin
        if ShopifyStore."Get Orders Starting From" <> 0DT then
            exit(ShopifyStore."Get Orders Starting From");
        exit(DefaultImportStartDateTime());
    end;

    internal procedure SaveOrder(ShopifyStore: Record "NPR Spfy Store"; Order: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text) Success: Boolean
    begin
        exit(ValidateOrder(ShopifyStore, Order, OrderStatus, OrderGID));
    end;

    local procedure ValidateOrder(ShopifyStore: Record "NPR Spfy Store"; Order: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text): Boolean
    var
        OrderId: Text[30];
        DocName: Text[100];
    begin
        ClearLastError();

        if not OrderMgt.EligibleSourceName(JsonHelper.GetJText(Order, 'sourceName', true)) then
            exit;

        if not TryGetOrderProperties(Order, OrderId, DocName) then begin
            LogError(GetErrorText(OrderStatus, OrderGID), ShopifyStore.Code, "NPR SpfyEventLogDocType"::Order);
            exit;
        end;

        if not HasReadyState(ShopifyStore, Order, OrderStatus) then
            exit;

        if DocExists(ShopifyStore.Code, OrderId, DocName, OrderStatus) then
            exit;

        if OrderStatus = OrderStatus::Open then
            if OrderMgt.IsAnonymizedCustomerOrder(JsonHelper.GetJText(Order, 'customer.firstName', false), JsonHelper.GetJText(Order, 'customer.lastName', false)) then
                exit;

        exit(true);
    end;

    [TryFunction]
    local procedure TryGetOrderProperties(Order: JsonToken; var OrderId: Text[30]; var DocName: Text[100])
    begin
        OrderId := OrderMgt.GetNumericId(JsonHelper.GetJText(Order, 'id', true));
#pragma warning disable AA0139
        DocName := JsonHelper.GetJText(Order, 'number', true);
#pragma warning restore AA0139
    end;

    internal procedure SetupJobQueues()
    var
        EnableJobQueues: Boolean;
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        EnableJobQueues := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders");
        if not EnableJobQueues then
            EnableJobQueues := SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Returns");
        SetupJobQueue(EnableJobQueues);
    end;

    internal procedure SetupJobQueue(Enable: Boolean)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        GetOrdersFromShopifyLbl: Label 'Get Sales Orders from Shopify';
    begin
        if Enable then begin
            JobQueueMgt.SetJobTimeout(2, 0); //shouldn't be less than loop in the specific job queue
            JobQueueMgt.SetProtected(true);
            JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, 30, '');
            if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId(),
                '', GetOrdersFromShopifyLbl,
                CreateDateTime(Today(), 070000T), 1,
                '', JobQueueEntry)
            then
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
        end else
            JobQueueMgt.CancelNpManagedJobs(JobQueueEntry."Object Type to Run"::Codeunit, CurrCodeunitId());
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR Spfy Order Import JQ");
    end;

    local procedure DocTypeNotSupported(DocType: Enum "NPR SpfyEventLogDocType")
    var
        UnsupportedDocumentTypeErr: Label 'Shopify document type %1 is not supported. This is a programming bug, not a user error. Please contact system vendor.';
    begin
        Error(UnsupportedDocumentTypeErr, DocType);
    end;

    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        LastStoresReload: DateTime;
        ErrorsSinceLastMarker: Dictionary of [Text, Boolean];
        InitialFromDT: Dictionary of [Text, DateTime];
        LastMarkerUpdate: Dictionary of [Text, DateTime];
        SessionMaxUpdatedAt: Dictionary of [Text, DateTime];
}
#endif
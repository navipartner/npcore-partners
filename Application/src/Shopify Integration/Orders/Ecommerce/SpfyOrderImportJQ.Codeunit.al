#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248579 "NPR Spfy Order Import JQ"
{
    Access = Internal;
    Permissions = tabledata "NPR Spfy Store" = r, tabledata "NPR Spfy Data Sync. Pointer" = rim;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        StartTime: DateTime;
        StoresDict: Dictionary of [Code[20], Boolean];
        MaxDuration: Duration;
    begin
        SpfyIntegrationMgt.CheckIsEnabled("NPR Spfy Integration Area"::"Sales Orders", '');
        StartTime := CurrentDateTime();
        LastStoresReload := CurrentDateTime() - 6 * 60000;
        MaxDuration := JobQueueManagement.HoursToDuration(1);
        InitGlobals();
        repeat
            if SpfyEcomSalesDocPrcssr.ShouldSoftExit(Rec.ID) then
                exit;
            if (CurrentDateTime() - LastStoresReload) > (5 * 60000) then
                LoadEnabledStores(StoresDict);

            Process(StoresDict);
            Sleep(1000);

        until DurationLimitReached(StartTime, MaxDuration);

        FinalizeMarkers(StoresDict);
    end;

    internal procedure Process(StoresDict: Dictionary of [Code[20], Boolean])
    var
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
    begin
        foreach StoreCode in StoresDict.Keys() do begin
            ShopifyStore.ReadIsolation := IsolationLevel::ReadCommitted;
            ShopifyStore.SetAutoCalcFields("Last Orders Imported At (FF)");
            ShopifyStore.Get(StoreCode);
            ProcessStore(ShopifyStore);
        end;
    end;

    local procedure LoadEnabledStores(var StoresDict: Dictionary of [Code[20], Boolean])
    var
        ShopifyStore: Record "NPR Spfy Store";
    begin
        Clear(StoresDict);
        ShopifyStore.SetCurrentKey(Enabled);
        ShopifyStore.SetRange(Enabled, true);
        if ShopifyStore.FindSet() then
            repeat
                if not StoresDict.ContainsKey(ShopifyStore.Code) then
                    if SpfyIntegrationMgt.IsEnabled("NPR Spfy Integration Area"::"Sales Orders", ShopifyStore) then
                        StoresDict.Add(ShopifyStore.Code, true);
            until ShopifyStore.Next() = 0;
        LastStoresReload := CurrentDateTime();
    end;

    local procedure ProcessStore(ShopifyStore: Record "NPR Spfy Store")
    var
        OrderStatus: Enum "NPR SpfyAPIDocumentStatus";
    begin
        SetMarkers(ShopifyStore);

        DownloadOrders(ShopifyStore, OrderStatus::Open);
        if ShopifyStore."Delete on Cancellation" then
            DownloadOrders(ShopifyStore, OrderStatus::Cancelled);
        if ShopifyStore."Post on Completion" then
            DownloadOrders(ShopifyStore, OrderStatus::Closed);

        TryUpdateMarker(ShopifyStore);
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
            if not SpfyAPIOrderHelper.GetOrderList(HasNext, ShopifyResponse, ShopifyStore, OrdersArr, Cursor, OrderStatus, GetFromDT(ShopifyStore)) then begin
                LogError(GetLastErrorText(), ShopifyStore.Code);
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
        OrderGID: Text[100];
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

    internal procedure ProcessOrder(ShopifyStore: Record "NPR Spfy Store"; OrderTkn: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text[100]): Boolean
    begin
        ClearLastError();
        UpdateSessionMax(ShopifyStore.Code, JsonHelper.GetJDT(OrderTkn, 'updatedAt', true));
        if InsertShopifyLog(OrderTkn, OrderStatus, ShopifyStore) then
            exit(true);
        LogError(GetErrorText(OrderStatus, OrderGID), ShopifyStore.Code);
        exit(false);
    end;
    #region markers 
    /// <summary>
    /// InitialFromDT[StoreCode] 
    ///   The baseline timestamp read from the database (“Last Orders Imported At”). 
    ///   Used as the starting point for updatedAt filtering during this JQ cycle.
    /// SessionMaxUpdatedAt[StoreCode] 
    ///   Tracks the highest updatedAt value encountered during this JQ cycle. 
    ///   This value becomes the new “Last Orders Imported At” when the marker is updated.
    /// LastMarkerUpdate[StoreCode] 
    ///   Records the last time the marker was written to the database. 
    ///   Used to control periodic marker updates and reduce database write frequency.
    ///ErrorsSinceLastMarker[StoreCode] 
    ///   Marker to track for any errors and prevent “Last Orders Imported At” from being updated is error exists.
    /// </summary>
    local procedure SetMarkers(ShopifyStore: Record "NPR Spfy Store")
    var
        FromDT: DateTime;
    begin
        if not InitialFromDT.ContainsKey(ShopifyStore.Code) then begin
            if ShopifyStore."Last Orders Imported At (FF)" <> 0DT then
                FromDT := ShopifyStore."Last Orders Imported At (FF)"
            else
                FromDT := GetDefaultFromDT(ShopifyStore);
            InitialFromDT.Add(ShopifyStore.Code, FromDT);
        end;

        if not SessionMaxUpdatedAt.ContainsKey(ShopifyStore.Code) then
            SessionMaxUpdatedAt.Add(ShopifyStore.Code, InitialFromDT.Get(ShopifyStore.Code));

        if not LastMarkerUpdate.ContainsKey(ShopifyStore.Code) then
            LastMarkerUpdate.Add(ShopifyStore.Code, CurrentDateTime());

        if not ErrorsSinceLastMarker.ContainsKey(ShopifyStore.Code) then
            ErrorsSinceLastMarker.Add(ShopifyStore.Code, false);
    end;

    local procedure TryUpdateMarker(ShopifyStore: Record "NPR Spfy Store")
    var
        SpfyStore: Record "NPR Spfy Store";
        NowDT: DateTime;
    begin
        NowDT := CurrentDateTime();
        if (NowDT - LastMarkerUpdate.Get(ShopifyStore.Code)) < (5 * 60000) then
            exit;
        if ErrorsSinceLastMarker.Get(ShopifyStore.Code) then
            exit;
        SpfyStore.ReadIsolation := IsolationLevel::UpdLock;
        SpfyStore.Get(ShopifyStore.RecordId);
        UpdateLastImportedAt(SpfyStore);
        LastMarkerUpdate.Set(SpfyStore.Code, NowDT);
    end;

    local procedure FinalizeMarkers(StoresDict: Dictionary of [Code[20], Boolean])
    var
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
    begin
        foreach StoreCode in StoresDict.Keys() do begin
            ShopifyStore.ReadIsolation := IsolationLevel::ReadCommitted;
            ShopifyStore.Get(StoreCode);
            if SessionMaxUpdatedAt.ContainsKey(StoreCode) then
                if not ErrorsSinceLastMarker.Get(StoreCode) then
                    UpdateLastImportedAt(ShopifyStore);
        end;
    end;

    local procedure UpdateSessionMax(StoreCode: Code[20]; UpdatedAt: DateTime)
    var
        CurrentMax: DateTime;
    begin
        CurrentMax := SessionMaxUpdatedAt.Get(StoreCode);
        if UpdatedAt > CurrentMax then
            SessionMaxUpdatedAt.Set(StoreCode, UpdatedAt);
    end;
    #endregion
    local procedure UpdateLastImportedAt(ShopifyStore: Record "NPR Spfy Store")
    begin
        ShopifyStore.CalcFields("Last Orders Imported At (FF)");
        if ShopifyStore."Last Orders Imported At (FF)" < SessionMaxUpdatedAt.Get(ShopifyStore.Code) then
            ShopifyStore.SetLastOrdersImportedAt(SessionMaxUpdatedAt.Get(ShopifyStore.Code));
        Commit(); // Commit here is required to release UpdLock before next Sleep() iteration
    end;

    local procedure GetOrderGID(OrderTkn: JsonToken; var OrderGID: Text[100])
    begin
        Clear(OrderGID);
#pragma warning disable AA0139
        OrderGID := JsonHelper.GetJText(OrderTkn, 'id', true);
#pragma warning restore AA0139
    end;

    internal procedure InsertShopifyLog(OrderTkn: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; ShopifyStore: Record "NPR Spfy Store"): Boolean
    var
        SpfyEventLogEntry: Record "NPR Spfy Event Log Entry";
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        ClearLastError();
        Clear(SpfyEventLogEntry);
        SpfyEventLogEntry."Document Status" := OrderStatus;
        SpfyEventLogEntry."Store Code" := ShopifyStore.Code;
        SpfyEventLogEntry."Document Type" := SpfyEventLogEntry."Document Type"::Order;
        SpfyEventLogEntry."Not Before Date-Time" := CurrentDateTime();
        exit(SpfyAPIEventLogMgt.InsertShopifyLog(OrderTkn, SpfyEventLogEntry));
    end;

    local procedure LogError(ErrMsg: Text; StoreCode: Code[20])
    var
        SpfyEcomSalesDocPrcssr: Codeunit "NPR Spfy Event Log DocProcessr";
        EventIdLbl: Label 'NPR_ShopifyAPI_OrderImportFailed', Locked = true;
    begin
        ErrorsSinceLastMarker.Set(StoreCode, true);
        SpfyEcomSalesDocPrcssr.EmitMessage(ErrMsg, EventIdLbl);
    end;

    local procedure InitGlobals()
    begin
        Clear(InitialFromDT);
        Clear(SessionMaxUpdatedAt);
        Clear(LastMarkerUpdate);
        Clear(ErrorsSinceLastMarker);
    end;

    local procedure GetFromDT(ShopifyStore: Record "NPR Spfy Store"): DateTime
    begin
        if InitialFromDT.ContainsKey(ShopifyStore.Code) then
            exit(InitialFromDT.Get(ShopifyStore.Code));
        exit(GetDefaultFromDT(ShopifyStore));
    end;

    local procedure GetErrorText(OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text[100]) ErrMsg: Text
    var
        FullOrderTxt: Label 'Import %1 Order %2 failed with error: %3', Comment = '%1= Order Status;%2= Order GID; %3=GetLastErrorText()', Locked = true;
    begin
        ErrMsg := StrSubstNo(FullOrderTxt, Format(OrderStatus), OrderGID, GetLastErrorText());
    end;

    local procedure DocExists(ShopifyStoreCode: Code[20]; OrderId: Text[20]; DocName: Text[100]; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"): Boolean
    var
        ShopifySetup: Record "NPR Spfy Integration Setup";
        SpfyAPIEventLogMgt: Codeunit "NPR Spfy Event Log Mgt.";
    begin
        if not ShopifySetup.Get() then
            exit(false);
        if DocName = '' then
            exit(false);
        // check if already processed
        exit(SpfyAPIEventLogMgt.LogEntryExist(OrderId, OrderStatus, ShopifyStoreCode));
    end;

    local procedure HasReadyState(ShopifyStore: Record "NPR Spfy Store"; Order: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"): Boolean
    begin
        case OrderStatus of
            OrderStatus::Open:
                exit(SpfyIntegrationMgt.IsAllowedFinancialStatus(JsonHelper.GetJText(Order, 'displayFinancialStatus', true).ToLower(), ShopifyStore.Code));
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
        exit(CreateDateTime(DMY2Date(1, 1, 2022), 0T));
    end;

    internal procedure SaveOrder(ShopifyStore: Record "NPR Spfy Store"; Order: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text[100]) Success: Boolean
    begin
        exit(ValidateOrder(ShopifyStore, Order, OrderStatus, OrderGID));
    end;

    local procedure ValidateOrder(ShopifyStore: Record "NPR Spfy Store"; Order: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text[100]): Boolean
    var
        OrderId: Text[20];
        DocName: Text[100];
    begin
        ClearLastError();

        if not SpfyOrderMgt.EligibleSourceName(JsonHelper.GetJText(Order, 'sourceName', true)) then
            exit;

        if not TryGetOrderProperties(Order, OrderId, DocName) then begin
            LogError(GetErrorText(OrderStatus, OrderGID), ShopifyStore.Code);
            exit;
        end;

        if not HasReadyState(ShopifyStore, Order, OrderStatus) then
            exit;

        if DocExists(ShopifyStore.Code, OrderId, DocName, OrderStatus) then
            exit;

        if OrderStatus = OrderStatus::Open then
            if SpfyOrderMgt.IsAnonymizedCustomerOrder(JsonHelper.GetJText(Order, 'customer.firstName', false), JsonHelper.GetJText(Order, 'customer.lastName', false)) then
                exit;

        exit(true);
    end;

    local procedure DurationLimitReached(StartDateTime: DateTime; DurationLimit: Duration): Boolean
    begin
        exit(CurrentDateTime - StartDateTime >= DurationLimit);
    end;

    [TryFunction]
    local procedure TryGetOrderProperties(Order: JsonToken; var OrderId: Text[20]; var DocName: Text[100])
    begin
#pragma warning disable AA0139
        OrderId := SpfyAPIOrderHelper.GetNumericId(JsonHelper.GetJText(Order, 'id', true));
        DocName := JsonHelper.GetJText(Order, 'number', true);
#pragma warning restore AA0139
    end;

    internal procedure SetupJobQueues()
    begin
        SpfyIntegrationMgt.SetRereadSetup();
        SetupJobQueue(SpfyIntegrationMgt.IsEnabledForAnyStore("NPR Spfy Integration Area"::"Sales Orders"));
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

    var
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        SpfyOrderMgt: Codeunit "NPR Spfy Order Mgt.";
        LastStoresReload: DateTime;
        ErrorsSinceLastMarker: Dictionary of [Code[20], Boolean];
        InitialFromDT: Dictionary of [Code[20], DateTime];
        LastMarkerUpdate: Dictionary of [Code[20], DateTime];
        SessionMaxUpdatedAt: Dictionary of [Code[20], DateTime];
}
#endif
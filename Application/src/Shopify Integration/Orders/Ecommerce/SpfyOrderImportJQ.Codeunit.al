#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248579 "NPR Spfy Order Import JQ"
{
    Access = Internal;
    Permissions = tabledata "NPR Spfy Store" = r, tabledata "NPR Spfy Data Sync. Pointer" = rim;
    TableNo = "Job Queue Entry";
    trigger OnRun()
    var
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

            _OrdersLoggedInCycle := 0;
            Process(StoresDict);
            Commit();
            if Rec."Recurring Job" then
                SleepUntilInterruptedOrElapsed(PollInterval(_OrdersLoggedInCycle), Rec.ID, StartTime, MaxDuration);
        until not Rec."Recurring Job" or EcomJobManagement.DurationLimitReached(StartTime, MaxDuration);
    end;

    internal procedure PollInterval(OrdersLogged: Integer): Duration
    begin
        case true of
            OrdersLogged > 100:
                exit(1000);
            OrdersLogged >= 50:
                exit(5 * 1000);
            OrdersLogged >= 10:
                exit(10 * 1000);
        end;
        exit(60 * 1000);
    end;

    local procedure SleepUntilInterruptedOrElapsed(TotalInterval: Duration; JobId: Guid; StartTime: DateTime; MaxDuration: Duration)
    var
        SliceMs: Duration;
        Elapsed: Duration;
        Remaining: Duration;
    begin
        // Slice the sleep so ShouldSoftExit and DurationLimitReached are honoured within ~1s instead of up to one full poll interval.
        SliceMs := 1000;
        Elapsed := 0;
        while Elapsed < TotalInterval do begin
            if EcomJobManagement.ShouldSoftExit(JobId) then
                exit;
            if EcomJobManagement.DurationLimitReached(StartTime, MaxDuration) then
                exit;
            Remaining := TotalInterval - Elapsed;
            if Remaining < SliceMs then begin
                Sleep(Remaining);
                Elapsed += Remaining;
            end else begin
                Sleep(SliceMs);
                Elapsed += SliceMs;
            end;
        end;
    end;

    internal procedure Process(StoresDict: Dictionary of [Code[20], Dictionary of [Enum "NPR SpfyEventLogDocType", Boolean]])
    var
        ShopifyStore: Record "NPR Spfy Store";
        StoreCode: Code[20];
    begin
        ShopifyStore.SetAutoCalcFields("Last Orders Imported At (FF)", "Last Returns Imported At (FF)");
        foreach StoreCode in StoresDict.Keys() do begin
            if EcomJobManagement.ApplicationChanged() then
                exit;
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
        QueryFilters: Text;
        HasNext: Boolean;
    begin
        Cursor := '';
        HasNext := true;
        QueryFilters := SpfyAPIOrderHelper.OrderListFilter(OrderStatus, GetFromDT(ShopifyStore, "NPR SpfyEventLogDocType"::Order));
        repeat
            if EcomJobManagement.ApplicationChanged() then
                exit;

            if not SpfyAPIOrderHelper.GetOrderList(HasNext, ShopifyResponse, ShopifyStore, OrdersArr, Cursor, QueryFilters) then begin
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
            if EcomJobManagement.ApplicationChanged() then
                exit(OrderProcessed);

            OrderTkn.SelectToken('node', CurrNode);
            GetOrderGID(CurrNode, OrderGID);
            UpdateSessionMax(ShopifyStore.Code, "NPR SpfyEventLogDocType"::Order, JsonHelper.GetJDT(CurrNode, 'updatedAt', true));
            if SaveOrder(ShopifyStore, CurrNode, OrderStatus, OrderGID) then
                if ProcessOrder(ShopifyStore, CurrNode, OrderStatus, OrderGID) then begin
                    OrderProcessed := true;
                    _OrdersLoggedInCycle += 1;
                end;
        end;
        exit(OrderProcessed);
    end;

    internal procedure ProcessOrder(ShopifyStore: Record "NPR Spfy Store"; OrderTkn: JsonToken; OrderStatus: Enum "NPR SpfyAPIDocumentStatus"; OrderGID: Text): Boolean
    begin
        ClearLastError();
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
        QueryFilters: Text;
        HasNext: Boolean;
    begin
        Cursor := '';
        HasNext := true;
        // Built once and handed to every page - see DownloadOrders.
        QueryFilters := SpfyAPIOrderHelper.ReturnListFilter(GetFromDT(ShopifyStore, "NPR SpfyEventLogDocType"::"Return Order"));
        repeat
            if EcomJobManagement.ApplicationChanged() then
                exit;
            if not SpfyAPIOrderHelper.GetReturnList(HasNext, ShopifyResponse, ShopifyStore, OrdersArr, Cursor, QueryFilters) then begin
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
            // Above UpdateSessionMax, so a skipped order cannot raise the session maximum.
            if EcomJobManagement.ApplicationChanged() then
                exit(ReturnProcessed);

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
            // Its own fetch loop, so it needs its own check: without it a single order with many
            // closed returns keeps calling Shopify after the session is already known to be stale.
            if EcomJobManagement.ApplicationChanged() then
                exit;

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
            // Innermost record loop, so this is what bounds the charge to a single return.
            if EcomJobManagement.ApplicationChanged() then
                exit;

            ReturnEdge.SelectToken('node', ReturnNode);
            if ProcessReturn(ShopifyStore, ReturnNode) then begin
                ReturnProcessed := true;
                _OrdersLoggedInCycle += 1;
            end;
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
    ///   The highest updatedAt this run has examined - written to the event log, or deliberately
    ///   passed over.
    ///   This value becomes the new “Last Orders / Last Returns Imported At” when the marker is written.
    /// _MarkerStopped[StoreCode|DocType]
    ///   Set by LogError: something in this cycle was not examined to the end - a list request that failed
    ///   part way, an order or return that could not be written to the event log - so the marker is not
    ///   written at all this cycle. It is cleared at the start of every cycle, not once per run: the previous
    ///   version never cleared it, so a single failing order froze the store's watermark for the whole hour.
    /// </summary>
    internal procedure SetMarkers(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType")
    var
        FromDT: DateTime;
        MarkerKeyTxt: Text;
    begin
        MarkerKeyTxt := MarkerKey(ShopifyStore.Code, DocType);
        FromDT := StoredImportMarker(ShopifyStore, DocType);
        if not InitialFromDT.ContainsKey(MarkerKeyTxt) then begin
            if FromDT = 0DT then
                FromDT := GetImportStartFromDT(ShopifyStore, DocType);
            InitialFromDT.Add(MarkerKeyTxt, FromDT);
        end else
            if RebaseMarkerAfterRollback(MarkerKeyTxt, FromDT) then;

        if not SessionMaxUpdatedAt.ContainsKey(MarkerKeyTxt) then
            SessionMaxUpdatedAt.Add(MarkerKeyTxt, InitialFromDT.Get(MarkerKeyTxt));

        if _MarkerStopped.ContainsKey(MarkerKeyTxt) then
            _MarkerStopped.Remove(MarkerKeyTxt);
    end;

    internal procedure StopMarker(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType")
    begin
        _MarkerStopped.Set(MarkerKey(StoreCode, DocType), true);
    end;

    local procedure MarkerStopped(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"): Boolean
    begin
        exit(_MarkerStopped.ContainsKey(MarkerKey(StoreCode, DocType)));
    end;

    local procedure RebaseMarkerAfterRollback(MarkerKeyTxt: Text; StoredFromDT: DateTime): Boolean
    begin
        if StoredFromDT = 0DT then
            exit(false);
        if StoredFromDT >= InitialFromDT.Get(MarkerKeyTxt) then
            exit(false);

        InitialFromDT.Set(MarkerKeyTxt, StoredFromDT);
        SessionMaxUpdatedAt.Set(MarkerKeyTxt, StoredFromDT);
        exit(true);
    end;

    internal procedure TryUpdateMarker(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType")
    var
        SpfyStore: Record "NPR Spfy Store";
        MarkerKeyTxt: Text;
    begin
        if EcomJobManagement.ApplicationChanged() then
            exit;
        if MarkerStopped(ShopifyStore.Code, DocType) then
            exit;
        MarkerKeyTxt := MarkerKey(ShopifyStore.Code, DocType);
        // Defense in depth: SetMarkers seeds both dicts at the start of every ProcessStore call, but a future caller that
        // bypasses SetMarkers would otherwise get a "key not present" crash instead of a no-op.
        if not SessionMaxUpdatedAt.ContainsKey(MarkerKeyTxt) then
            exit;
        if not InitialFromDT.ContainsKey(MarkerKeyTxt) then
            exit;
        if SessionMaxUpdatedAt.Get(MarkerKeyTxt) <= InitialFromDT.Get(MarkerKeyTxt) then
            exit;
        SpfyStore.ReadIsolation := IsolationLevel::UpdLock;
        SpfyStore.Get(ShopifyStore.RecordId);
        UpdateLastImportedAt(SpfyStore, DocType);
    end;

    internal procedure UpdateSessionMax(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"; UpdatedAt: DateTime)
    var
        CurrentMax: DateTime;
        MarkerKeyTxt: Text;
    begin
        MarkerKeyTxt := MarkerKey(StoreCode, DocType);
        if not SessionMaxUpdatedAt.ContainsKey(MarkerKeyTxt) then begin
            SessionMaxUpdatedAt.Add(MarkerKeyTxt, UpdatedAt);
            exit;
        end;
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
        NewMarker: DateTime;
        StoredMarker: DateTime;
        MarkerKeyTxt: Text;
    begin
        MarkerKeyTxt := MarkerKey(ShopifyStore.Code, DocType);
        NewMarker := SessionMaxUpdatedAt.Get(MarkerKeyTxt);
        StoredMarker := StoredImportMarker(ShopifyStore, DocType);

        // someone moved the marker back while the cycle was running
        if not RebaseMarkerAfterRollback(MarkerKeyTxt, StoredMarker) then
            if StoredMarker < NewMarker then begin
                WriteImportMarker(ShopifyStore, DocType, NewMarker);
                InitialFromDT.Set(MarkerKeyTxt, StoredImportMarker(ShopifyStore, DocType));
            end;
        Commit(); // Commit here is required to release UpdLock before next Sleep() iteration
    end;

    local procedure StoredImportMarker(ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType"): DateTime
    begin
        case DocType of
            DocType::Order:
                begin
                    ShopifyStore.CalcFields("Last Orders Imported At (FF)");
                    exit(ShopifyStore."Last Orders Imported At (FF)");
                end;
            DocType::"Return Order":
                begin
                    ShopifyStore.CalcFields("Last Returns Imported At (FF)");
                    exit(ShopifyStore."Last Returns Imported At (FF)");
                end;
            else
                DocTypeNotSupported(DocType);
        end;
    end;

    local procedure WriteImportMarker(var ShopifyStore: Record "NPR Spfy Store"; DocType: Enum "NPR SpfyEventLogDocType"; NewMarker: DateTime)
    begin
        case DocType of
            DocType::Order:
                ShopifyStore.SetLastOrdersImportedAt(NewMarker);
            DocType::"Return Order":
                ShopifyStore.SetLastReturnsImportedAt(NewMarker);
            else
                DocTypeNotSupported(DocType);
        end;
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
    begin
        // Every failure reaches this procedure, which is why the marker is stopped here rather than at each call
        // site: whatever went wrong, something in this cycle was not examined to the end.
        StopMarker(StoreCode, DocType);
        if ShouldEmitSentryError(StoreCode, DocType) then
            EmitSentryError(StoreCode, DocType);
        SpfyEcomSalesDocPrcssr.LogTelemetry(ErrMsg, 'NPR_ShopifyAPI_OrderImportFailed');
    end;

    local procedure ShouldEmitSentryError(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"): Boolean
    begin
        exit(ShouldEmitSentryError(StoreCode, DocType, CurrentDateTime()));
    end;

    /// <summary>
    /// Throttles Sentry to at most one event per hour per store and document type, so a persistent failure polled
    /// once every poll cycle does not flood it. App insights telemetry (LogTelemetry) still records every error.
    /// The NowDT parameter exists so the throttle can be unit tested without waiting an hour.
    /// </summary>
    internal procedure ShouldEmitSentryError(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType"; NowDT: DateTime): Boolean
    var
        LastEmitAt: DateTime;
        ThrottleWindow: Duration;
        ThrottleKey: Text;
    begin
        ThrottleWindow := 60 * 60 * 1000;
        ThrottleKey := MarkerKey(StoreCode, DocType);
        if not _LastSentryEmitAt.ContainsKey(ThrottleKey) then begin
            _LastSentryEmitAt.Add(ThrottleKey, NowDT);
            exit(true);
        end;
        LastEmitAt := _LastSentryEmitAt.Get(ThrottleKey);
        if (NowDT - LastEmitAt) < ThrottleWindow then
            exit(false);
        _LastSentryEmitAt.Set(ThrottleKey, NowDT);
        exit(true);
    end;

    local procedure EmitSentryError(StoreCode: Code[20]; DocType: Enum "NPR SpfyEventLogDocType")
    var
        Sentry: Codeunit "NPR Sentry";
        TransactionNameLbl: Label 'Shopify import failed (%1): %2', Comment = '%1 = document type, %2 = Shopify store code', Locked = true;
    begin
        // Logs the active error to Sentry (developers' primary error tool), aligning Shopify with Entria.
        Sentry.InitScopeAndTransaction(StrSubstNo(TransactionNameLbl, Format(DocType), StoreCode), 'bc.shopify.order.import.error');
        Sentry.AddTransactionTag('shopify.store_code', StoreCode);
        Sentry.AddTransactionTag('shopify.doc_type', Format(DocType));
        Sentry.AddLastErrorIfProgrammingBug();
        Sentry.FinalizeScope();
    end;

    local procedure InitGlobals()
    begin
        Clear(InitialFromDT);
        Clear(SessionMaxUpdatedAt);
        Clear(_MarkerStopped);
        Clear(_LastSentryEmitAt);
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
        DocName := JsonHelper.GetJText(Order, 'name', true);
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
        EcomJobManagement: Codeunit "NPR Ecom Job Management";
        JsonHelper: Codeunit "NPR Json Helper";
        SpfyAPIOrderHelper: Codeunit "NPR Spfy Order ApiHelper";
        SpfyIntegrationMgt: Codeunit "NPR Spfy Integration Mgt.";
        OrderMgt: Codeunit "NPR Spfy Order Mgt.";
        LastStoresReload: DateTime;
        InitialFromDT: Dictionary of [Text, DateTime];
        SessionMaxUpdatedAt: Dictionary of [Text, DateTime];
        _LastSentryEmitAt: Dictionary of [Text, DateTime];
        _MarkerStopped: Dictionary of [Text, Boolean];
        _OrdersLoggedInCycle: Integer;
}
#endif